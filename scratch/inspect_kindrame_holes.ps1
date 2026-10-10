Add-Type -AssemblyName System.Drawing

$frontPath = "Graphics/Pokemon/Front/KINDRAME.png"
$bmp = New-Object System.Drawing.Bitmap($frontPath)
Write-Host "Front sprite dimensions: $($bmp.Width)x$($bmp.Height)"

# Find all pixels that are near-white: R > 230, G > 230, B > 230, A > 0
$whiteCoords = @()
for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 100 -and $p.R -gt 235 -and $p.G -gt 235 -and $p.B -gt 235) {
            $whiteCoords += [PSCustomObject]@{ X = $x; Y = $y; R = $p.R; G = $p.G; B = $p.B }
        }
    }
}

Write-Host "Found $($whiteCoords.Count) near-white pixels."
# Group by Y ranges or bounding boxes to see where they are
$groups = $whiteCoords | Group-Object -Property { [math]::Floor($_.Y / 20) * 20 }
foreach ($g in $groups) {
    $minX = ($g.Group | Measure-Object -Property X -Minimum).Minimum
    $maxX = ($g.Group | Measure-Object -Property X -Maximum).Maximum
    $minY = ($g.Group | Measure-Object -Property Y -Minimum).Minimum
    $maxY = ($g.Group | Measure-Object -Property Y -Maximum).Maximum
    Write-Host "Y-range $($g.Name): count=$($g.Count), X=[$minX, $maxX], Y=[$minY, $maxY]"
}

$bmp.Dispose()
