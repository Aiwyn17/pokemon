Add-Type -AssemblyName System.Drawing

$normPath = "Graphics/Pokemon/Back/KINDRAME.png"
$bmp = [System.Drawing.Bitmap]::FromFile($normPath)

$colorCounts = @{}
for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 0) {
            $hex = "{0:x2}{1:x2}{2:x2}" -f $p.R, $p.G, $p.B
            $colorCounts[$hex] = ($colorCounts[$hex] + 1)
        }
    }
}

$bmp.Dispose()

Write-Host "Total unique colors in Normal Back: $($colorCounts.Count)"
$sorted = $colorCounts.GetEnumerator() | Sort-Object Value -Descending
foreach ($c in $sorted) {
    Write-Host "#$($c.Key) : $($c.Value) px"
}
