try {
    $Connection = New-Object MySqlConnector.MySqlConnection($ConnectionString) -ErrorAction Stop
    $Connection.Open()
} catch {
    Write-Host $_.Exception.Message
    $inner = $_.Exception.InnerException
    while ($inner) {
        Write-Host $inner.Message
        $inner = $inner.InnerException
    }
}
