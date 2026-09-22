<#
.SYNOPSIS
    Pré-staging en masse des comptes ordinateur Active Directory - Projet École Connectée
    Lit un CSV (Nom, OU) et crée les comptes ordinateur correspondants dans AD,
    prêts à être joints par les postes Windows 10 (Add-Computer ou Offline Domain Join).
#>

# ---- TRANSCRIPT ----
$LogFolder = "C:\Scripts\logs"
if (-not (Test-Path $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path "$LogFolder\prestage_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt" -Append

# ---- CONFIGURATION ----
$CsvPath = "C:\Scripts\Postes.csv"

if (-not (Test-Path $CsvPath)) {
    Write-Error "[CRITIQUE] Fichier CSV introuvable : $CsvPath"
    Stop-Transcript
    Exit 1
}

$Postes = Import-Csv -Path $CsvPath

Write-Host "[INFO] Nombre de postes à pré-stager : $($Postes.Count)" -ForegroundColor Cyan

foreach ($Poste in $Postes) {
    $Nom = $Poste.Nom
    $OU  = $Poste.OU

    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    Write-Host "[TRAITEMENT] Poste : $Nom -> $OU" -ForegroundColor Yellow

    try {
        # Vérifie que le compte n'existe pas déjà (pas de doublon)
        if (Get-ADComputer -Filter "Name -eq '$Nom'" -ErrorAction SilentlyContinue) {
            Write-Host "[SKIP] Le compte $Nom existe déjà dans AD." -ForegroundColor DarkYellow
            continue
        }

        New-ADComputer -Name $Nom -Path $OU -Enabled $true -ErrorAction Stop
        Write-Host "[AD] Compte ordinateur créé avec succès : $Nom" -ForegroundColor Green

    } catch {
        Write-Host "[ERREUR SYSTEM] Échec de la création pour $Nom :" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        $inner = $_.Exception.InnerException
        while ($inner) {
            Write-Host $inner.GetType().FullName -ForegroundColor Yellow
            Write-Host $inner.Message
            $inner = $inner.InnerException
        }
    }
}

Write-Host "--------------------------------------------------" -ForegroundColor Yellow
Write-Host "[TERMINÉ] Pré-staging terminé." -ForegroundColor Green

Stop-Transcript
