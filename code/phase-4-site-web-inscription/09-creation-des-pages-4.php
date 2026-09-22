<?php
// 1. Inclusion de la connexion à la base de données
require_once 'db.php';

// 2. Vérification que les données viennent bien du formulaire en POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    die("Accès refusé.");
}

/* --- ÉTAPE A : NETTOYAGE ET VALIDATION DES ENTRÉES (Pour l'ADDS) --- */
// On utilise filter_input et trim pour enlever les espaces inutiles et nettoyer les chaînes
$nom = uppercase_clean($_POST['nom']);
$prenom = capitalize_clean($_POST['prenom']);
$email = filter_var(trim($_POST['email']), FILTER_VALIDATE_EMAIL);

// Liste des filières strictes correspondant à tes Unités Organisationnelles (OU) Active Directory
$filieres_autorisees = ['informatique', 'sante', 'litterature', 'philosophie', 'maths'];
$filiere = isset($_POST['filiere']) ? strtolower(trim($_POST['filiere'])) : '';

// Validation de la cohérence des données
if (!$nom || !$prenom || !$email || !in_array($filiere, $filieres_autorisees)) {
    die("Erreur : Formulaire invalide ou données incorrectes.");
}

/* --- ÉTAPE B : SÉCURISATION MAXIMALE DE L'UPLOAD (Hardening) --- */
if (!isset($_FILES['preuve']) || $_FILES['preuve']['error'] !== UPLOAD_ERR_OK) {
    die("Erreur lors du transfert du fichier.");
}

$file = $_FILES['preuve'];

// 1. Vérification de la taille (Max 5 Mo = 5 * 1024 * 1024 octets)
$max_size = 5 * 1024 * 1024;
if ($file['size'] > $max_size) {
    die("Erreur : Le fichier est trop volumineux (Maximum 5 Mo).");
}

// 2. Vérification de l'extension (Première barrière)
$filename = $file['name'];
$extension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
$extensions_permises = ['pdf', 'jpg', 'jpeg', 'png'];

if (!in_array($extension, $extensions_permises)) {
    die("Erreur : Type de fichier non autorisé (Uniquement PDF, JPG, JPEG, PNG).");
}

// 3. Vérification du type MIME réel (Deuxième barrière : empêche un pirate de renommer malicieusement un .php en .jpg)
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mime_type = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);

$mimes_permis = ['application/pdf', 'image/jpeg', 'image/png'];
if (!in_array($mime_type, $mimes_permis)) {
    die("Erreur de sécurité : Le contenu réel du fichier ne correspond pas à son extension.");
}

// 4. Renommage unique du fichier (Troisième barrière : empêche l'écrasement de fichiers existants ou les attaques par injection de nom)
$dossier_destination = '/var/www/html/inscription/uploads/';
$nouveau_nom = bin2hex(random_bytes(16)) . '.' . $extension;
$chemin_final = $dossier_destination . $nouveau_nom;

/* --- ÉTAPE C : DÉPLACEMENT ET SÉCURISATION DU FICHIER --- */
if (move_uploaded_file($file['tmp_name'], $chemin_final)) {
    
    /* --- ÉTAPE D : INSERTION DANS LA BASE DE DONNÉES (Via requêtes préparées PDO) --- */
    try {
        // Le champ 'statut_ad' permettra à ton script PowerShell ADDS de savoir quels comptes créer (0 = En attente, 1 = Créé)
        $sql = "INSERT INTO inscriptions (nom, prenom, email, filiere, fichier_preuve, statut_ad) 
                VALUES (:nom, :prenom, :email, :filiere, :fichier, 0)";
        
        $stmt = $pdo->prepare($sql);
        $stmt->execute([
            ':nom'     => $nom,
            ':prenom'  => $prenom,
            ':email'   => $email,
            ':filiere' => $filiere,
            ':fichier' => $nouveau_nom
        ]);

        // Redirection ou message de succès
        echo "<h1>Inscription réussie !</h1>";
        echo "<p>Vos données ont été enregistrées avec succès. Votre compte réseau Active Directory sera créé sous peu dans le département : <strong>" . ucfirst($filiere) . "</strong>.</p>";
        
    } catch (\PDOException $e) {
        // En cas d'erreur de base de données, on supprime le fichier uploadé pour ne pas encombrer le serveur inutilement
        if (file_exists($chemin_final)) { unlink($chemin_final); }
        // On log l'erreur en interne mais on affiche un message neutre à l'écran
        error_log($e->getMessage());
        die("Une erreur technique est survenue lors de l'enregistrement.");
    }

} else {
    die("Erreur critique : Impossible de sauvegarder le fichier sur le serveur.");
}

/* --- FONCTIONS DE NETTOYAGE --- */
function uppercase_clean($data) {
    return mb_strtoupper(preg_replace('/[^a-zA-Z\s]/', '', trim($data)), 'UTF-8');
}

function capitalize_clean($data) {
    return mb_convert_case(preg_replace('/[^a-zA-Z\s]/', '', trim($data)), MB_CASE_TITLE, 'UTF-8');
}
?>
