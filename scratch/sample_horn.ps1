Add-Type -AssemblyName System.Drawing

$normPath = "Graphics/Pokemon/Back/KINDRAME.png"
$bmp = [System.Drawing.Bitmap]::FromFile($normPath)

Write-Host "Sampling Lamb Horn colors at (x=105, y=85):"
for ($y = 80; $y -le 90; $y += 2) {
    for ($x = 100; $x -le 110; $x += 2) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 0) {
            Write-Host "($x,$y): R=$($p.R), G=$($p.G), B=$($p.B), Brightness=$([int]($p.R*0.299+$p.G*0.587+$p.B*0.114))"
        }
    }
}

$bmp.Dispose()
