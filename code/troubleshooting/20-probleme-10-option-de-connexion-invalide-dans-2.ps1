(Get-Content "C:\Scripts\Sync-ADInscriptions.ps1") -replace ';UseExtendedProperties=false', '' |
Set-Content "C:\Scripts\Sync-ADInscriptions.ps1"
