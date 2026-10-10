Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Front shiny/KINDRAME.png")
$colors = @{}

for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 100) {
            $key = "{0:x2}{1:x2}{2:x2}" -f $p.R, $p.G, $p.B
            $colors[$key] = ($colors[$key] + 1)
        }
    }
}

$bmp.Dispose()
Write-Host "Top colors in Front Shiny:"
$sorted = $colors.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 20
foreach ($s in $sorted) {
    Write-Host "#$($s.Key) : $($s.Value) pixels"
}
