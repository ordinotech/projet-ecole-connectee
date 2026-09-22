Get-ADUser -Filter "Enabled -eq 'True'" -SearchBase "OU=Professeurs,OU=Employés,OU=Udem,DC=udem,DC=lan" -SearchScope Subtree -Properties DisplayName | Select-Object @{N="Name";E={$_.DisplayName}},@{N="Email";E={$_.UserPrincipalName}},@{N="Password";E={"Udem2026!"}},@{N="Role";E={"user"}} | Export-Csv "C:\Scripts\profs.csv" -NoTypeInformation -Encoding UTF8

(Get-Content "C:\Scripts\profs.csv") | ForEach-Object {$_ -replace '"',''} | Set-Content "C:\Scripts\profs.csv"
