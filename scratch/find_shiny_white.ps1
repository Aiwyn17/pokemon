Add-Type -AssemblyName System.Drawing

$shinyPath = "Graphics/Pokemon/Front shiny/KINDRAME.png"
$bmp = New-Object System.Drawing.Bitmap($shinyPath)
Write-Host "Shiny front sprite: $($bmp.Width)x$($bmp.Height)"

$whiteCoords = @()
for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        # Check pixels that are opaque and near white (R,G,B > 230)
        if ($p.A -gt 100 -and $p.R -gt 230 -and $p.G -gt 230 -and $p.B -gt 230) {
            $whiteCoords += [PSCustomObject]@{ X = $x; Y = $y; R = $p.R; G = $p.G; B = $p.B }
        }
    }
}

Write-Host "Found $($whiteCoords.Count) near-white pixels in Shiny Front!"

# Group them into clusters
$clusters = $whiteCoords | Group-Object -Property { [math]::Floor($_.Y / 15) * 15 }
foreach ($c in $clusters) {
    $minX = ($c.Group | Measure-Object -Property X -Minimum).Minimum
    $maxX = ($c.Group | Measure-Object -Property X -Maximum).Maximum
    $minY = ($c.Group | Measure-Object -Property Y -Minimum).Minimum
    $maxY = ($c.Group | Measure-Object -Property Y -Maximum).Maximum
    Write-Host "Cluster Y-range $($c.Name): count=$($c.Count), X=[$minX, $maxX], Y=[$minY, $maxY]"
}

$bmp.Dispose()
