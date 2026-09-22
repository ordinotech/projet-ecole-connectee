PS C:\Windows\system32> Add-Computer -DomainName "udem.lan" -NewName "PC-PROF-01" -Credential (Get-Credential) -Force -Restart
cmdlet Get-Credential at command pipeline position 1
Supply values for the following parameters:
Credential
Add-Computer : Computer 'DESKTOP-I1L0RFM' was successfully joined to the new domain 'udem.lan', but renaming it to
'PC-PROF-01' failed with the following error message: The account already exists.
