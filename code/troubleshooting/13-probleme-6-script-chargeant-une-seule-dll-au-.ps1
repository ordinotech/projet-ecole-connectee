$onResolve = [System.ResolveEventHandler]{
    param($s, $e)
    $name = ([System.Reflection.AssemblyName]$e.Name).Name
    $path = "C:\Scripts\$name.dll"
    if (Test-Path $path) { return [System.Reflection.Assembly]::LoadFile($path) }
    return $null
}
[AppDomain]::CurrentDomain.add_AssemblyResolve($onResolve)

Get-ChildItem "C:\Scripts\*.dll" | ForEach-Object {
    [void][System.Reflection.Assembly]::LoadFile($_.FullName)
}
