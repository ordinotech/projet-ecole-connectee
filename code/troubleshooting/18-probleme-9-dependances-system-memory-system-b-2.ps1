Invoke-WebRequest "https://www.nuget.org/api/v2/package/System.Memory/4.5.4"           -OutFile "C:\Scripts\memory.zip"
Invoke-WebRequest "https://www.nuget.org/api/v2/package/System.Buffers/4.5.1"          -OutFile "C:\Scripts\buffers.zip"
Invoke-WebRequest "https://www.nuget.org/api/v2/package/System.Runtime.CompilerServices.Unsafe/4.5.3" -OutFile "C:\Scripts\unsafe.zip"
