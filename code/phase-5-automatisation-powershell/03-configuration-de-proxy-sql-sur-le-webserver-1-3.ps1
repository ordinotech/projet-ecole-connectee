<#
.SYNOPSIS
    Script d'automatisation V2.8 (MySqlConnector) - Projet École Connectée
    Interroge MariaDB, génère un matricule unique à 6 chiffres, crée le compte AD
    et prépare le mappage du dossier personnel privé (H:) sur le serveur de fichiers Linux.
#>

# ---- TRANSCRIPT : capture toute la sortie console dans un fichier log ----
$LogFolder = "C:\Scripts\logs"
if (-not (Test-Path $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path "$LogFolder\log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt" -Append

# ---- CHARGEMENT DES DLL : handler AssemblyResolve protégé contre la récursion ----
# NOTE V2.7 : le chargement explicite en boucle (V2.6) exige que le NUMÉRO DE VERSION
# exact de chaque DLL corresponde à ce que MySqlConnector demande (ex: System.Memory
# Version=4.0.1.0) -> échec si le package NuGet téléchargé porte une version différente.
# Le handler AssemblyResolve tolère ces écarts de version (charge le fichier trouvé peu
# importe son numéro exact), MAIS un handler naïf peut se redéclencher lui-même en
# boucle en contexte non-interactif -> stack overflow (0xC00000FD), comme vu en V2.5.
# Solution : un verrou anti-récursion (HashSet) qui empêche le handler de retraiter une
# assembly déjà en cours de résolution.
$script:ResolvingAssemblies = New-Object 'System.Collections.Generic.HashSet[string]'

$onResolve = [System.ResolveEventHandler]{
    param($senderObj, $resolveArgs)
    $simpleName = ([System.Reflection.AssemblyName]$resolveArgs.Name).Name
    if ($script:ResolvingAssemblies.Contains($simpleName)) {
        return $null   # Déjà en cours de résolution -> on coupe la boucle ici
    }
    [void]$script:ResolvingAssemblies.Add($simpleName)
    try {
        $path = "C:\Scripts\$simpleName.dll"
        if (Test-Path $path) {
            return [System.Reflection.Assembly]::LoadFrom($path)
        }
        return $null
    } finally {
        [void]$script:ResolvingAssemblies.Remove($simpleName)
    }
}
[AppDomain]::CurrentDomain.add_AssemblyResolve($onResolve)

# Chargement initial de MySqlConnector.dll : c'est le seul chargement manuel nécessaire,
# le handler ci-dessus résout automatiquement toutes ses dépendances transitives à la demande.
$DllPath = "C:\Scripts\MySqlConnector.dll"
if (-not (Test-Path $DllPath)) {
    Write-Error "[CRITIQUE] DLL manquante : $DllPath"
    Stop-Transcript
    Exit 1
}
[void][System.Reflection.Assembly]::LoadFrom($DllPath)

# --- CONFIGURATION INDISPENSABLE ---
#$DBServer      = "10.0.1.3"         # IP privée de ton conteneur MariaDB (bridge vmbr2)
$DBServer 	= "10.0.20.3" 	     # Ne vise pas l'IP interne 10.0.1.3, vise l'IP d'écoute de ton WebSrv !
$DBDatabase     = "school_db"        # Nom de ta base de données
$DBUser         = "web_app"          # Utilisateur SQL
$DBPass         = "Password01$"      # Mot de passe SQL
$DomainDN       = "DC=udem,DC=lan"   # Distinguished Name du domaine AD

# --- CONFIGURATION DU SERVEUR DE FICHIERS LINUX SMB ---
$FileServerIP   = "10.0.20.4"        # IP  conteneur Ubuntu FileServer SMB
$HomeFolderUNC  = "\\$FileServerIP\homes\"

# --- CHAÎNE DE CONNEXION ---
$ConnectionString = "Server=$DBServer;Database=$DBDatabase;Uid=$DBUser;Pwd=$DBPass;SslMode=None;ConnectionTimeout=30;"

try {
    # La création de l'objet est DANS le try, avec -ErrorAction Stop, pour ne jamais
    # laisser $Connection à $null silencieusement en cas de chaîne de connexion invalide.
    $Connection = New-Object MySqlConnector.MySqlConnection($ConnectionString) -ErrorAction Stop
    $Connection.Open()
    Write-Host "[OK] Connexion réussie à MariaDB via MySqlConnector." -ForegroundColor Green

    # Extraction des seules inscriptions en attente (statut_ad = 0)
    $Query = "SELECT id, nom, prenom, email, filiere FROM inscriptions WHERE statut_ad = 0"
    $Command = New-Object MySqlConnector.MySqlCommand($Query, $Connection)
    $DataAdapter = New-Object MySqlConnector.MySqlDataAdapter($Command)
    $DataTable = New-Object System.Data.DataTable
    [void]$DataAdapter.Fill($DataTable)

    Write-Host "[INFO] Nombre d'inscriptions à traiter : $($DataTable.Rows.Count)" -ForegroundColor Cyan

    # --- TRAITEMENT CHAQUE ÉTUDIANT ---
    foreach ($Row in $DataTable.Rows) {
        $ID       = $Row["id"]
        $Nom      = $Row["nom"]      
        $Prenom   = $Row["prenom"]   
        $Email    = $Row["email"]
        $Filiere  = $Row["filiere"]  

        Write-Host "--------------------------------------------------" -ForegroundColor Yellow
        Write-Host "[TRAITEMENT] Traitement du dossier de : $Prenom $Nom" -ForegroundColor Yellow

        # 1. GÉNÉRATION DU MATRICULE UNIQUE À 6 CHIFFRES
        $IsUnique = $false
        $Matricule = ""
        while (-not $IsUnique) {
            $RandomDigits = Get-Random -Minimum 1000 -Maximum 9999
            $Matricule = "26" + $RandomDigits 
            if (-not (Get-ADUser -Filter "SamAccountName -eq '$Matricule'")) {
                $IsUnique = $true
            }
        }
        Write-Host "[MATRICULE] Matricule unique généré : $Matricule" -ForegroundColor Cyan

        # 2. OU CIBLE & GROUPES DE SÉCURITÉ SÉLECTIONNÉS
        $OU_Filiere = switch ($Filiere) {
            "informatique" { "OU=Informatique,OU=Etudiants,OU=Udem,$DomainDN" }
            "sante"        { "OU=Santé,OU=Etudiants,OU=Udem,$DomainDN" }
            "litterature"  { "OU=Littérature,OU=Etudiants,OU=Udem,$DomainDN" }
            "philosophie"  { "OU=Philosophie,OU=Etudiants,OU=Udem,$DomainDN" }
            "maths"        { "OU=Maths,OU=Etudiants,OU=Udem,$DomainDN" }
        }
        
        $GroupCible = switch ($Filiere) {
            "informatique" { "Group Etu info" }
            "sante"        { "Group Etu Santé" }
            "litterature"  { "Group Etu Litté" }
            "philosophie"  { "Group Etu Philo" }
            "maths"        { "Group Etu Maths" }
        }

        # 3. CONCEPTION DU MOT DE PASSE INITIAL SÉCURISÉ
        $PasswordClair = "EtuUDEM!" + (Get-Random -Minimum 10000 -Maximum 99999) + "*"
        $SecurePassword = ConvertTo-SecureString $PasswordClair -AsPlainText -Force

        # 4. CONFIGURATION DES ATTRIBUTS DE L'UTILISATEUR AD
        $UserParams = @{
            Name                  = "$Prenom $Nom"
            SamAccountName        = $Matricule              
            UserPrincipalName     = "$Matricule@udem.lan"   
            GivenName             = $Prenom
            Surname               = $Nom
            EmailAddress          = $Email
            Path                  = $OU_Filiere             
            AccountPassword       = $SecurePassword
            ChangePasswordAtLogon = $true                   
            Enabled               = $true                   
            
            # Mappage automatique du stockage Linux
            HomeDrive             = "H:"                        
            HomeDirectory         = "$HomeFolderUNC$Matricule"  
        }

        try {
            # Création du compte dans l'Active Directory
            New-ADUser @UserParams
            Write-Host "[AD] Compte créé avec succès pour le matricule $Matricule (Lecteur H: configuré)." -ForegroundColor Green

            # Rattachement au groupe global de sa filière
            if ($GroupCible -and (Get-ADGroup -Filter "Name -eq '$GroupCible'")) {
                Add-ADGroupMember -Identity $GroupCible -Members $Matricule
                Write-Host "[AD] Utilisateur ajouté au groupe : $GroupCible" -ForegroundColor Green
            }

            # 5. MISE À JOUR DU FLAG DANS LA BASE MARIADB BACKEND
            $UpdateQuery = "UPDATE inscriptions SET statut_ad = 1 WHERE id = @id"
            $UpdateCmd = New-Object MySqlConnector.MySqlCommand($UpdateQuery, $Connection)
            [void]$UpdateCmd.Parameters.AddWithValue("@id", $ID)
            [void]$UpdateCmd.ExecuteNonQuery()

            Write-Host "[DB] Statut synchronisé à 1 dans MariaDB pour l'ID $ID." -ForegroundColor Green
            Write-Host "[MÉMO SECRÉTARIAT] Matricule : $Matricule | Mot de passe : $PasswordClair" -ForegroundColor Cyan

        } catch {
            Write-Host "[ERREUR SYSTEM] Échec de la création pour l'étudiant ID $ID :" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            $innerAD = $_.Exception.InnerException
            while ($innerAD) {
                Write-Host $innerAD.GetType().FullName -ForegroundColor Yellow
                Write-Host $innerAD.Message
                $innerAD = $innerAD.InnerException
            }
        }
    }

} catch [System.Exception] {
    Write-Host "=== [CRITIQUE] Message principal ===" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red

    Write-Host "=== InnerException(s) ===" -ForegroundColor Red
    $inner = $_.Exception.InnerException
    while ($inner) {
        Write-Host $inner.GetType().FullName -ForegroundColor Yellow
        Write-Host $inner.Message
        $inner = $inner.InnerException
    }
} finally {
    if ($Connection -and $Connection.State -eq [System.Data.ConnectionState]::Open) {
        $Connection.Close()
        Write-Host "[DB] Connexion MariaDB fermée proprement." -ForegroundColor Cyan
    }
    Stop-Transcript
}
