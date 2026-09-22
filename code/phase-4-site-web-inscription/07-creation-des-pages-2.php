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
