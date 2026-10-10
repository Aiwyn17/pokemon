Add-Type -AssemblyName System.Drawing

$normPath = "Graphics/Pokemon/Back/KINDRAME.png"
$bmp = [System.Drawing.Bitmap]::FromFile($normPath)

Write-Host "Sampling Wolf Smoke colors at (x=40, y=30):"
for ($y = 25; $y -le 35; $y += 2) {
    for ($x = 35; $x -le 45; $x += 2) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 0) {
            Write-Host "($x,$y): R=$($p.R), G=$($p.G), B=$($p.B), Brightness=$([int]($p.R*0.299+$p.G*0.587+$p.B*0.114))"
        }
    }
}

Write-Host "`nSampling Lamb Body colors at (x=60, y=120):"
for ($y = 115; $y -le 125; $y += 2) {
    for ($x = 55; $x -le 65; $x += 2) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 0) {
            Write-Host "($x,$y): R=$($p.R), G=$($p.G), B=$($p.B), Brightness=$([int]($p.R*0.299+$p.G*0.587+$p.B*0.114))"
        }
    }
}

$bmp.Dispose()
