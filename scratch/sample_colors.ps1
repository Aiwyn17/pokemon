Add-Type -AssemblyName System.Drawing

$frontPath = "Graphics/Pokemon/Front/KINDRAME.png"
$bmp = New-Object System.Drawing.Bitmap($frontPath)

Write-Host "Sampling pixels in the big hole around (x=100, y=55):"
for ($y = 50; $y -le 60; $y += 2) {
    for ($x = 90; $x -le 105; $x += 3) {
        $p = $bmp.GetPixel($x, $y)
        Write-Host "($x,$y): R=$($p.R), G=$($p.G), B=$($p.B), A=$($p.A)"
    }
}

Write-Host "`nSampling pixels on the lamb's chest/neck around (x=68, y=78):"
for ($y = 76; $y -le 82; $y += 2) {
    for ($x = 65; $x -le 72; $x += 2) {
        $p = $bmp.GetPixel($x, $y)
        Write-Host "($x,$y): R=$($p.R), G=$($p.G), B=$($p.B), A=$($p.A)"
    }
}

$bmp.Dispose()
