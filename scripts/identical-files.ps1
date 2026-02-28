#$Base = "C:\Program Files (x86)\Steam\steamapps\common\Europa Universalis IV\gfx"
#$Base = "~\Documents\Links\Europa Universalis 4\Anbennar"
$Base = ".\src\interface"
$Mod = "~\Documents\Links\Europa Universalis 4\Anbennar\interface"
#$Mod  = "..\src"

$BaseFull = (Resolve-Path $Base).Path
$ModFull  = (Resolve-Path $Mod).Path

$identical = New-Object System.Collections.Generic.List[string]
$different = New-Object System.Collections.Generic.List[string]
$missing   = New-Object System.Collections.Generic.List[string]

Get-ChildItem -LiteralPath $ModFull -Recurse -File | ForEach-Object {
    $rel = [System.IO.Path]::GetRelativePath($ModFull, $_.FullName)
    $baseFile = Join-Path $BaseFull $rel

    if (-not (Test-Path -LiteralPath $baseFile)) {
        $missing.Add($rel)
        return
    }

    # szybki filtr po rozmiarze, potem hash
    $baseItem = Get-Item -LiteralPath $baseFile
    if ($_.Length -ne $baseItem.Length) {
        $different.Add($rel)
        return
    }

    $h1 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    $h2 = (Get-FileHash -LiteralPath $baseFile   -Algorithm SHA256).Hash

    if ($h1 -eq $h2) { $identical.Add($rel) } else { $different.Add($rel) }
}

$identical | Set-Content -Encoding UTF8 "identical.txt"
$different | Set-Content -Encoding UTF8 "different.txt"
$missing   | Set-Content -Encoding UTF8 "missing_in_base.txt"

Write-Host "Identical: $($identical.Count)"
Write-Host "Different : $($different.Count)"
Write-Host "Missing   : $($missing.Count)"
Write-Host "Zapisano: identical.txt / different.txt / missing_in_base.txt"