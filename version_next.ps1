$pubspec = "pubspec.yaml"

# Obtener la fecha en formato YYYYMMDD
$today = Get-Date -Format "yyyyMMdd"

# Leer línea de versión actual
$versionLine = Select-String "^version:" $pubspec | ForEach-Object { $_.Line }
$split = $versionLine -replace "version: ", "" -split "\+"

$verName = $split[0]
$verCode = if ($split.Count -gt 1) { $split[1] } else { "" }

# Calcular nuevo contador
$build = "01"
if ($verCode -ne "") {
    $prefix = $verCode.Substring(0,8)
    $suffix = $verCode.Substring(8)
    if ($prefix -eq $today) {
        $num = [int]$suffix + 1
        $build = $num.ToString("D2")
    }
}

$newCode = "$today$build"
$newLine = "version: $verName+$newCode"

# Reemplazar en pubspec.yaml (manteniendo UTF-8)
(Get-Content $pubspec) -replace "^version:.*", $newLine | Set-Content -Encoding UTF8 $pubspec

Write-Host "✅ Nueva versión actualizada en pubspec.yaml"
Write-Host "👉 $newLine"
Write-Host ""
Write-Host "ℹ️  Ahora puedes ejecutar manualmente:"
Write-Host "    flutter build appbundle --release"
Write-Host ""
