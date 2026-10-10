# Copy RAW file timestamps onto the FotoDif FITS in SequenceFotodiffOUT.
# Pairing comes from Siril's process/light_conversion.txt:
#   'E:\Frames\SequenceFotodiffIN\IMG_0001.CR2' -> '...\process\light_00001.fit'
# The output name is fotodif_Green_light_00001.fit, same index as light_00001.fit.
# Must match fotodif_from_raw.ssf (prefix fotodif_, sequence Green_light).

param(
    [string]$Report = "E:\Frames\SequenceFotodiffIN\process\light_conversion.txt",
    [string]$OutDir = "E:\Frames\SequenceFotodiffOUT"
)

$ErrorActionPreference = "Stop"
$OutPrefix = "fotodif_Green_light_"

if (-not (Test-Path -LiteralPath $Report)) {
    Write-Error "No se encuentra $Report. Lanza antes fotodif_from_raw.ssf."
}

$copied = 0
$missing = 0
$bad = 0

foreach ($line in Get-Content -LiteralPath $Report) {
    $trim = $line.Trim()
    if ($trim.Length -eq 0) { continue }
    $pair = [regex]::Match($trim, "^'(.+)' -> '(.+)'$")
    if (-not $pair.Success) {
        Write-Warning "Linea no reconocida: $trim"
        $bad++
        continue
    }
    $src = $pair.Groups[1].Value
    $converted = $pair.Groups[2].Value
    $file = [regex]::Match($converted, 'light_(\d+)(\.[^.\\/]+)$')
    if (-not $file.Success) {
        Write-Warning "Salida de conversion sin indice: $converted"
        $bad++
        continue
    }
    $idx = $file.Groups[1].Value
    $ext = $file.Groups[2].Value
    $out = Join-Path $OutDir ($OutPrefix + $idx + $ext)

    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "No esta el RAW $src"
        $missing++
        continue
    }
    if (-not (Test-Path -LiteralPath $out)) {
        Write-Warning "Sin FITS de salida para $src ($out)"
        $missing++
        continue
    }

    $srcItem = Get-Item -LiteralPath $src
    $outItem = Get-Item -LiteralPath $out
    $outItem.CreationTime = $srcItem.CreationTime
    $outItem.LastWriteTime = $srcItem.LastWriteTime
    $copied++
}

Write-Output "Fechas copiadas: $copied. Sin par: $missing. Lineas raras: $bad."
if ($copied -eq 0) { exit 1 }
exit 0
