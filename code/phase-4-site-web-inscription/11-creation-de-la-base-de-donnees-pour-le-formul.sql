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
