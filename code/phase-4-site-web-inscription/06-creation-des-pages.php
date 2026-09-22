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
