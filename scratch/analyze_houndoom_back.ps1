Add-Type -AssemblyName System.Drawing

$img = New-Object System.Drawing.Bitmap("C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_perfect_houndoom_1791585386206.jpg")
$w = $img.Width
$h = $img.Height
Write-Host "Image size: ${w}x${h}"

# Quick analysis of white clusters
$visited = New-Object 'bool[,]' $w, $h
for ($y = 0; $y -lt $h; $y += 4) {
    for ($x = 0; $x -lt $w; $x += 4) {
        if (-not $visited[$x, $y]) {
            $p = $img.GetPixel($x, $y)
            if ($p.R -ge 245 -and $p.G -ge 245 -and $p.B -ge 245) {
                $q = New-Object System.Collections.Generic.Queue[System.Drawing.Point]
                $q.Enqueue([System.Drawing.Point]::new($x, $y))
                $visited[$x, $y] = $true
                $count = 0
                $minX = $x; $maxX = $x; $minY = $y; $maxY = $y
                $touchesBorder = $false

                while ($q.Count -gt 0) {
                    $pt = $q.Dequeue()
                    $count++
                    if ($pt.X -lt $minX) { $minX = $pt.X }
                    if ($pt.X -gt $maxX) { $maxX = $pt.X }
                    if ($pt.Y -lt $minY) { $minY = $pt.Y }
                    if ($pt.Y -gt $maxY) { $maxY = $pt.Y }
                    if ($pt.X -le 4 -or $pt.X -ge ($w - 5) -or $pt.Y -le 4 -or $pt.Y -ge ($h - 5)) {
                        $touchesBorder = $true
                    }

                    $dirs = @(@(-4,0), @(4,0), @(0,-4), @(0,4))
                    foreach ($d in $dirs) {
                        $nx = $pt.X + $d[0]
                        $ny = $pt.Y + $d[1]
                        if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
                            if (-not $visited[$nx, $ny]) {
                                $visited[$nx, $ny] = $true
                                $np = $img.GetPixel($nx, $ny)
                                if ($np.R -ge 245 -and $np.G -ge 245 -and $np.B -ge 245) {
                                    $q.Enqueue([System.Drawing.Point]::new($nx, $ny))
                                }
                            }
                        }
                    }
                }
                if ($count -gt 20) {
                    Write-Host "Component: count=$count, touchesBorder=$touchesBorder, X=[$minX, $maxX], Y=[$minY, $maxY], Center=($([int](($minX+$maxX)/2)), $([int](($minY+$maxY)/2)))"
                }
            }
        }
    }
}
$img.Dispose()
