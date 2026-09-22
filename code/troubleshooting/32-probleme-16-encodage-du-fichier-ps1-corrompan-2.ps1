$content = Get-Content -Path "C:\Scripts\Sync-ADInscriptions.ps1" -Raw -Encoding UTF8
Set-Content -Path "C:\Scripts\Sync-ADInscriptions.ps1" -Value $content -Encoding UTF8
