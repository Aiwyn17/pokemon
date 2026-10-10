Add-Type -AssemblyName System.Drawing

$shinyPath = "Graphics/Pokemon/Front shiny/KINDRAME.png"
$fs = [System.IO.File]::OpenRead($shinyPath)
$bmp = [System.Drawing.Bitmap]::FromStream($fs)
$fs.Close()

Write-Host "Sampling pixels in Front Shiny around (102, 55):"
for ($y = 48; $y -le 62; $y += 2) {
    for ($x = 95; $x -le 115; $x += 3) {
        $p = $bmp.GetPixel($x, $y)
        Write-Host "($x,$y): R=$($p.R), G=$($p.G), B=$($p.B), A=$($p.A)"
    }
}

$bmp.Dispose()
