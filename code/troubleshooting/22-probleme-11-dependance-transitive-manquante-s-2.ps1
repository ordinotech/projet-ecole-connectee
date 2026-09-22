Invoke-WebRequest "https://www.nuget.org/api/v2/package/System.Numerics.Vectors/4.5.0" -OutFile "C:\Scripts\numerics.zip"
Expand-Archive "C:\Scripts\numerics.zip" -DestinationPath "C:\Scripts\numerics_extract" -Force
Copy-Item "C:\Scripts\numerics_extract\lib\net46\System.Numerics.Vectors.dll" -Destination "C:\Scripts\" -Force
Unblock-File "C:\Scripts\System.Numerics.Vectors.dll"
