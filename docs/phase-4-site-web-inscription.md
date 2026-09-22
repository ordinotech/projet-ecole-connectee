[← Retour au README](../README.md)

# **Phase 4 — Site web d'inscription (PHP + MariaDB)**

Architecture 2-tier, base de données des inscriptions, formulaire PHP avec upload de preuve de paiement.

## Configuration Réseau & Pare-feu (OPNsense)

Règle pour permettre aux Etudiants et aux Profs d’atteindre le site Web et de pouvoir faire afficher la page

- Vlan Etudiants

|  | int. | src | dst | proto. |  |  | Description |
| --- | --- | --- | --- | --- | --- | --- | --- |

![Configuration Réseau & Pare-feu (OPNsense)](../images/017-configuration-reseau-pare-feu-opnsense.png)

- Vlan Profs

![Configuration Réseau & Pare-feu (OPNsense)](../images/018-configuration-reseau-pare-feu-opnsense-2.png)

<aside>
🚨

**WebServer ➔ DbSrv (Via VmBr2)**

### Proxy au niveau du WebServer

Ici, c'est le point critique : OPNsense est aveugle sur ce segment. Le flux passe directement d'un container à l'autre via le bridge Proxmox `VmBr2`. Ce qui fait que le DataBaseServer n’a aucun accès internet, il totalement coupé du monde, c’est bien ce qu’on veut en le mettant en architecture 2-Tier mais faut qu’il puisse accéder au repository au moins pour les app et les update sans pour autant qu’on expose notre base de données. Je mets en place un proxy avec Nginx sur le web server pour que ce segment…

![Proxy au niveau du WebServer](../images/019-proxy-au-niveau-du-webserver.png)

…servent à la base de données CT de chemin sécurisé pour aller chercher de mise à jour sur internet

Sur le Ubuntu Web Server

`apt update 
apt install net-tools
apt install nginx -y
nginx -v
service nginx status`

![Proxy au niveau du WebServer](../images/020-proxy-au-niveau-du-webserver-2.png)

![Proxy au niveau du WebServer](../images/021-proxy-au-niveau-du-webserver-3.png)

<aside>
📝

Test rapide depuis le windows server

![Proxy au niveau du WebServer](../images/022-proxy-au-niveau-du-webserver-4.png)

</aside>

`nano /etc/nginx/sites-available/apt-proxy`

Dans le fichier on configure le proxy

```bash
server {
    listen 8080;

    location / {
        proxy_pass http://archive.ubuntu.com;
        proxy_set_header Host archive.ubuntu.com;
        proxy_cache_valid 200 302 60m;
        allow 10.0.1.3;
				deny all;
    }
}
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/01-proxy-au-niveau-du-webserver.sh`](../code/phase-4-site-web-inscription/01-proxy-au-niveau-du-webserver.sh)*

<aside>
📝

`proxy_cache_valid 200 302 60m;`

- **200 302 :** Ce sont les codes de réponse HTTP (200 = OK, 302 = Redirection).
- **60m :** Signifie 60 minutes.

Nginx va garder en mémoire (dans son cache) les fichiers téléchargés depuis Ubuntu pendant **1 heure**.

</aside>

J’active la configuration et je redémarre le service

`ln -s /etc/nginx/sites-available/apt-proxy /etc/nginx/sites-enabled/
nginx -t  
systemctl restart nginx`

Sur le Database Server (CT 104)

Je crée le fichier de configuration apt 

`sudo nano /etc/apt/apt.conf.d/00proxy`

J’ajoute la directive 

```bash
Acquire::http::Proxy "http://10.0.1.2:8080";
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/02-proxy-au-niveau-du-webserver-2.sh`](../code/phase-4-site-web-inscription/02-proxy-au-niveau-du-webserver-2.sh)*

![Proxy au niveau du WebServer](../images/023-proxy-au-niveau-du-webserver-5.png)

Le DataBaseServer peut désormais telecharger des applications et faire des update

Journalisation sur WebServer donc sur le proxy 

`cat /var/log/nginx/access.log`

![Proxy au niveau du WebServer](../images/024-proxy-au-niveau-du-webserver-6.png)

</aside>

## Configuration du Serveur Web

### Installation des logiciels

`sudo apt install nginx php-fpm php-mysql php-curl php-gd php-mbstring` 

![Installation des logiciels](../images/025-installation-des-logiciels.png)

- `php-fpm` : Le moteur PHP.
- `php-mysql` : Le connecteur indispensable pour parler à MariaDB plus tard.
- `php-gd/mbstring` : Pour gérer les images et les caractères spéciaux des formulaires.

![Installation des logiciels](../images/026-installation-des-logiciels-2.png)

Important de verifier la version de mon php pour la configuration du virtual Host. 8.1 dans mon cas donc 

### Configuration du virtual host

Sur le WebServer dans `/etc/nginx/sites-available` , `nano inscription`

![Configuration du virtual host](../images/027-configuration-du-virtual-host.png)

#### Activation du site

```bash
ln -s /etc/nginx/sites-available/inscription /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default 
nginx -t 
systemctl restart nginx
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/03-configuration-du-virtual-host.sh`](../code/phase-4-site-web-inscription/03-configuration-du-virtual-host.sh)*

![Configuration du virtual host](../images/028-configuration-du-virtual-host-2.png)

### Préparation de la structure des fichiers

On prépare le répertoire pour le code PHP et HTML 

![Préparation de la structure des fichiers](../images/029-preparation-de-la-structure-des-fichiers.png)

![Préparation de la structure des fichiers](../images/030-preparation-de-la-structure-des-fichiers-2.png)

```bash
mkdir -p /var/www/html/inscription/uploads
chown -R www-data:www-data /var/www/html/inscription
chmod -R 755 /var/www/html/inscription
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/04-preparation-de-la-structure-des-fichiers.sh`](../code/phase-4-site-web-inscription/04-preparation-de-la-structure-des-fichiers.sh)*

`www-data` est l'utilisateur de Nginx. En lui donnant la propriété du dossier `uploads`, il pourra y enregistrer les preuves de paiement des étudiants.

### Test de validation

Toujours dans `/var/www/html/inscription/` je crée un fichier test.php et je met le code php 

```php
<?php echo "Test de validation"; ?>
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/05-test-de-validation.php`](../code/phase-4-site-web-inscription/05-test-de-validation.php)*

Depuis un poste windows (j’utilise le winServer), dans un navigateur je fais `http://10.0.20.3/test.php`

![Test de validation](../images/031-test-de-validation.png)

### Création des pages

Dans `/var/www/html/inscription/` , il faut créer les fichiers suivants pour que le site fonctionne. 

![Création des pages](../images/032-creation-des-pages.png)

![Création des pages](../images/033-creation-des-pages-2.png)

#### 1. Le Fichier de Connexion : `/var/www/html/inscription/db.php`

Ce fichier sert à centraliser les informations pour la connexion a la base de donnée qu’on aura à créer sur la machine DbServer . `Code généré par IA`

```php
<?php
$host = '10.0.1.3'; // L'IP privée de ta DB sur vmbr2
$db   = 'school_db';
$user = 'web_app';
$pass = 'Password01$'; // Celui que tu mettras dans MariaDB
$charset = 'utf8mb4';

$dsn = "mysql:host=$host;dbname=$db;charset=$charset";
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION, // Active les erreurs SQL sous forme d'exceptions
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,       // Récupère les données sous forme de tableau associatif
    PDO::ATTR_EMULATE_PREPARES   => false,                  // Désactive l'émulation pour forcer les vraies requêtes préparées (Anti-Injection SQL)
];

try {
     $pdo = new PDO($dsn, $user, $pass, $options);
} catch (\PDOException $e) {
     // En production, on ne montre JAMAIS l'erreur brute à l'utilisateur (sécurité)
     die("Erreur de connexion au serveur de données."); 
}
?>
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/06-creation-des-pages.php`](../code/phase-4-site-web-inscription/06-creation-des-pages.php)*

#### 2. Le Formulaire : `/var/www/html/inscription/index.php`

C’est la page d’accueil avec le formulaire html à remplir. `Code généré par IA`

- **Standardisation des valeurs (`value="..."`) :** Dans le menu déroulant, ce que l'étudiant voit est écrit en grand (ex: `Informatique`), mais ce que le script PHP va envoyer à la base de données est la valeur en minuscule sans accent (`informatique`).
- **Correspondance directe avec l'OU :** Dans le script PowerShell de synchronisation ADDS, on pourra directement mapper cette variable pour définir le *Distinguished Name* (DN) :
`$OU = "OU=$filiere,OU=Etudiants,DC=tondomaine,DC=local"`
- **Attribution des groupes :** On pourra aussi ajouter l'étudiant automatiquement au groupe de sécurité de sa filière (ex: `G_Etudiants_Informatique`).

```php
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Portail d'Inscription - Liaison Active Directory</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h2>Formulaire d'Inscription Académique</h2>
        <p class="subtitle">Les informations saisies serviront à la création automatique de vos accès réseau.</p>
        
        <form action="submit.php" method="POST" enctype="multipart/form-data">
            
            <div class="form-group">
                <label for="nom">Nom de famille :</label>
                <input type="text" id="nom" name="nom" placeholder="Ex: SOW" required maxLength="50">
            </div>

            <div class="form-group">
                <label for="prenom">Prénom :</label>
                <input type="text" id="prenom" name="prenom" placeholder="Ex: Mamadou" required maxLength="50">
            </div>

            <div class="form-group">
                <label for="email">Adresse Email Personnelle :</label>
                <input type="email" id="email" name="email" placeholder="Ex: mamadou.sow@gmail.com" required>
            </div>

            <div class="form-group">
                <label for="filiere">Filière / Département d'affectation :</label>
                <select id="filiere" name="filiere" required>
                    <option value="" disabled selected>-- Choisissez votre filière --</option>
                    <option value="informatique">Informatique</option>
                    <option value="sante">Santé</option>
                    <option value="litterature">Littérature</option>
                    <option value="philosophie">Philosophie</option>
                    <option value="maths">Maths</option>
                </select>
            </div>

            <div class="form-group">
                <label for="preuve">Preuve de paiement (PDF, JPG, PNG - Max 5Mo) :</label>
                <input type="file" id="preuve" name="preuve" accept=".pdf,.jpg,.jpeg,.png" required>
            </div>

            <button type="submit">Valider mon inscription académique</button>
        </form>
    </div>
</body>
</html>
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/07-creation-des-pages-2.php`](../code/phase-4-site-web-inscription/07-creation-des-pages-2.php)*

#### 3. Le fichier Style de base : `/var/www/html/inscription/style.css`

`Code généré par IA`

```css
/* --- Réinitialisation et Base --- */
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background-color: #f4f6f9;
    color: #333;
    line-height: 1.6;
    padding: 40px 20px;
}

/* --- Conteneur Principal --- */
.container {
    max-width: 550px;
    background: #ffffff;
    padding: 40px;
    margin: 0 auto;
    border-radius: 8px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
    border-top: 5px solid #0056b3; /* Rappel couleur académique */
}

/* --- Typographie --- */
h2 {
    text-align: center;
    color: #111;
    font-size: 24px;
    margin-bottom: 8px;
}

.subtitle {
    text-align: center;
    font-size: 14px;
    color: #666;
    margin-bottom: 30px;
    padding: 0 10px;
}

/* --- Formulaire et Champs --- */
.form-group {
    margin-bottom: 22px;
}

label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    font-size: 14px;
    color: #444;
}

/* Centralisation du design des entrées et du menu déroulant ADDS */
input[type="text"],
input[type="email"],
select {
    width: 100%;
    padding: 12px;
    border: 1px solid #ccc;
    border-radius: 4px;
    background-color: #fff;
    font-size: 15px;
    transition: border-color 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

/* Style spécifique pour le champ d'upload */
input[type="file"] {
    width: 100%;
    padding: 10px;
    background: #fafafa;
    border: 1px dashed #bbb;
    border-radius: 4px;
    font-size: 14px;
    cursor: pointer;
}

input[type="file"]:hover {
    background: #f1f5f9;
    border-color: #0056b3;
}

/* --- Effets de Focus (Ergonomie) --- */
input[type="text"]:focus,
input[type="email"]:focus,
select:focus {
    border-color: #0056b3;
    box-shadow: 0 0 0 3px rgba(0, 86, 179, 0.15);
    outline: none;
}

/* --- Bouton de Soumission --- */
button {
    width: 100%;
    padding: 14px;
    background: #0056b3;
    color: #ffffff;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 0.5px;
    transition: background 0.2s ease-in-out;
    margin-top: 10px;
}

button:hover {
    background: #004085;
}

/* --- Robustesse Responsive --- */
@media (max-width: 480px) {
    body {
        padding: 20px 10px;
    }
    .container {
        padding: 25px 20px;
    }
}
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/08-creation-des-pages-3.css`](../code/phase-4-site-web-inscription/08-creation-des-pages-3.css)*

![Création des pages](../images/034-creation-des-pages-3.png)

#### 4. Le fichier de soumission `/var/www/html/inscription/submit.php`

`Code généré par IA`

```php
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
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/09-creation-des-pages-4.php`](../code/phase-4-site-web-inscription/09-creation-des-pages-4.php)*

<aside>
⚙

**Double vérification de l'upload :** On ne fait pas confiance au nom du fichier. On ouvre le fichier en arrière-plan (`finfo_file`) pour lire sa signature binaire (Magic Numbers) afin d'être sûr que c'est bien une image ou un PDF.

**Renommage aléatoire :** Si un étudiant upload un fichier nommé `../../index.php`, le script efface ce nom  et le remplace par une chaîne de caractères aléatoire unique (ex : `a1b2c3d4e5f6....png`).

**Préparation ADDS intégrée :** Le script formate automatiquement les noms en MAJUSCULES et les prénoms avec la première lettre en majuscule, évitant les caractères bizarres qui cassent les scripts PowerShell. De plus, la colonne `statut_ad = 0` servira de filtre parfait pour l’automatisme AD.

</aside>

## Configuration du Serveur de Base de Données

### Installation de maria-DB

[Installing MariaDB Server Guide | Server | MariaDB Documentation](https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide)

- **Switch to unix_socket authentication?** `N`
- **Change the root password?** `Y`
- **Remove anonymous users?** `Y`
- **Reload privilege tables now?** `Y`
- **Disallow root login remotely?** `Y`
- **Remove test database and access to it?** `Y`

![Installation de maria-DB](../images/035-installation-de-maria-db.png)

### Test de connexion après installation

![Test de connexion après installation](../images/036-test-de-connexion-apres-installation.png)

### Activer l'écoute sur le réseau privé

Par défaut, MariaDB n'écoute que sur `127.0.0.1`. Le serveur Web (`10.0.1.2`) ne pourra pas lui parler si on en change pas le bind-address dans le fichier de config

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/10-activer-l-ecoute-sur-le-reseau-prive.sh`](../code/phase-4-site-web-inscription/10-activer-l-ecoute-sur-le-reseau-prive.sh)*

Avant modification

![Activer l'écoute sur le réseau privé](../images/037-activer-l-ecoute-sur-le-reseau-prive.png)

Après modification

![Activer l'écoute sur le réseau privé](../images/038-activer-l-ecoute-sur-le-reseau-prive-2.png)

![Activer l'écoute sur le réseau privé](../images/039-activer-l-ecoute-sur-le-reseau-prive-3.png)

Pour finir, on enregistre et on restart mariadb pour faire appliquer la modification

### Création de la base de données pour le formulaire

Pour le moment aucune BD n’est créé, il s’agit ici des BD par défaut

![Création de la base de données pour le formulaire](../images/040-creation-de-la-base-de-donnees-pour-le-formulaire.png)

Bloc de requêtes SQL pour créer la BD ainsi que la table d'inscription

```sql
CREATE DATABASE school_db;
USE school_db;

CREATE TABLE inscriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    filiere VARCHAR(30) NOT NULL,
    fichier_preuve VARCHAR(255) NOT NULL,
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    statut_ad INT DEFAULT 0 
);

CREATE USER 'web_app'@'10.0.1.2' IDENTIFIED BY 'Password01$';

GRANT ALL PRIVILEGES ON school_db.inscriptions TO 'web_app'@'10.0.1.2';

FLUSH PRIVILEGES;
EXIT;
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/11-creation-de-la-base-de-donnees-pour-le-formul.sql`](../code/phase-4-site-web-inscription/11-creation-de-la-base-de-donnees-pour-le-formul.sql)*

La requete `statut_ad INT DEFAULT 0` est en fait  0 = En attente ADDS, 1 = Compte créé

La base de donnes a été créé avec succès 

![Création de la base de données pour le formulaire](../images/041-creation-de-la-base-de-donnees-pour-le-formulaire-2.png)

Avec la table Inscriptions 

![Création de la base de données pour le formulaire](../images/042-creation-de-la-base-de-donnees-pour-le-formulaire-3.png)

Qui contient les colonnes :

![Création de la base de données pour le formulaire](../images/043-creation-de-la-base-de-donnees-pour-le-formulaire-4.png)

La table ne contient encore aucune information 

![Création de la base de données pour le formulaire](../images/044-creation-de-la-base-de-donnees-pour-le-formulaire-5.png)

### Test de remplissage du formulaire en ligne

![Test de remplissage du formulaire en ligne](../images/045-test-de-remplissage-du-formulaire-en-ligne.png)

<aside>
⚙

![Test de remplissage du formulaire en ligne](../images/046-test-de-remplissage-du-formulaire-en-ligne-2.png)

Résolution dans la partie </aside>

![Test de remplissage du formulaire en ligne](../images/047-test-de-remplissage-du-formulaire-en-ligne-3.png)

## DNS sur Windows Server et Pi-hole pour la résolution locale avec Conditionnal Forwarders

### Enregistrement DNS sur Windows Server

![Enregistrement DNS sur Windows Server](../images/048-enregistrement-dns-sur-windows-server.png)

![Enregistrement DNS sur Windows Server](../images/049-enregistrement-dns-sur-windows-server-2.png)

### Configurer la Redirection Conditionnelle sur Pi-Hole

Passez en mode expert

![Configurer la Redirection Conditionnelle sur Pi-Hole](../images/050-configurer-la-redirection-conditionnelle-sur-pi-ho.png)

![Configurer la Redirection Conditionnelle sur Pi-Hole](../images/051-configurer-la-redirection-conditionnelle-sur-pi-ho-2.png)

```sass
true,10.0.0.0/16,10.0.20.10,udem.lan
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/12-configurer-la-redirection-conditionnelle-sur-.scss`](../code/phase-4-site-web-inscription/12-configurer-la-redirection-conditionnelle-sur-.scss)*

**Le réseau client à intercepter (VLAN 10 et 30) :** Pour englober toutes tes machines de l'infrastructure, on peut spécifier le super-réseau `10.0.0.0/16`.

![Configurer la Redirection Conditionnelle sur Pi-Hole](../images/052-configurer-la-redirection-conditionnelle-sur-pi-ho-3.png)

### Test depuis un client

![Test depuis un client](../images/053-test-depuis-un-client.png)

![Test depuis un client](../images/054-test-depuis-un-client-2.png)

Le site est en http et présente donc un danger 

![Test depuis un client](../images/055-test-depuis-un-client-3.png)

## De http a https avec ADCS

[AD CS : délivrer un certificat TLS pour un serveur Web Linux](https://www.it-connect.fr/ad-cs-comment-delivrer-un-certificat-tls-pour-un-serveur-web-linux/)

### Installation et configuration de ADCS

![Installation et configuration de ADCS](../images/056-installation-et-configuration-de-adcs.png)

![Installation et configuration de ADCS](../images/057-installation-et-configuration-de-adcs-2.png)

![Installation et configuration de ADCS](../images/058-installation-et-configuration-de-adcs-3.png)

![Installation et configuration de ADCS](../images/059-installation-et-configuration-de-adcs-4.png)

![Installation et configuration de ADCS](../images/060-installation-et-configuration-de-adcs-5.png)

![Installation et configuration de ADCS](../images/061-installation-et-configuration-de-adcs-6.png)

![Installation et configuration de ADCS](../images/062-installation-et-configuration-de-adcs-7.png)

![Installation et configuration de ADCS](../images/063-installation-et-configuration-de-adcs-8.png)

![Installation et configuration de ADCS](../images/064-installation-et-configuration-de-adcs-9.png)

### Clé privée et CSR

![Clé privée et CSR](../images/065-cle-privee-et-csr.png)

openssl req -new -out inscription.csr -keyout inscription.key -nodes -config /tmp/inscription.conf

![Clé privée et CSR](../images/066-cle-privee-et-csr-2.png)

`openssl req -text -noout -verify -in inscription.csr`

![Clé privée et CSR](../images/067-cle-privee-et-csr-3.png)

![Clé privée et CSR](../images/068-cle-privee-et-csr-4.png)

### Obtenir le certificat TLS depuis ADCS

![Obtenir le certificat TLS depuis ADCS](../images/069-obtenir-le-certificat-tls-depuis-adcs.png)

![Obtenir le certificat TLS depuis ADCS](../images/070-obtenir-le-certificat-tls-depuis-adcs-2.png)

![Obtenir le certificat TLS depuis ADCS](../images/071-obtenir-le-certificat-tls-depuis-adcs-3.png)

![Obtenir le certificat TLS depuis ADCS](../images/072-obtenir-le-certificat-tls-depuis-adcs-4.png)

![Obtenir le certificat TLS depuis ADCS](../images/073-obtenir-le-certificat-tls-depuis-adcs-5.png)

![Obtenir le certificat TLS depuis ADCS](../images/074-obtenir-le-certificat-tls-depuis-adcs-6.png)

### Configuration de Nginx pour le https

```bash
sudo mv /root/inscription.crt /etc/ssl/certs/inscription.crt
sudo mv /root/inscription.key /etc/ssl/private/inscription.key
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/13-configuration-de-nginx-pour-le-https.sh`](../code/phase-4-site-web-inscription/13-configuration-de-nginx-pour-le-https.sh)*

![Configuration de Nginx pour le https](../images/075-configuration-de-nginx-pour-le-https.png)

```bash
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name inscription.udem.lan;

    ssl_certificate /etc/ssl/certs/inscription.cer;
    ssl_certificate_key /etc/ssl/private/inscription.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    root /var/www/html/inscription;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
 }
```
*📄 Fichier complet : [`code/phase-4-site-web-inscription/14-configuration-de-nginx-pour-le-https-2.sh`](../code/phase-4-site-web-inscription/14-configuration-de-nginx-pour-le-https-2.sh)*

![Configuration de Nginx pour le https](../images/076-configuration-de-nginx-pour-le-https-2.png)

Puis `sudo systemctl restart nginx`

### Test du site en https

![Test du site en https](../images/077-test-du-site-en-https.png)

![Test du site en https](../images/078-test-du-site-en-https-2.png)
