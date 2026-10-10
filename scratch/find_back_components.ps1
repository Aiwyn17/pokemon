Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
$w = $norm.Width
$h = $norm.Height

# Let's inspect the connected components of non-outline, non-transparent pixels
# Outline pixels: brightness < 20
# We can find all connected components of (A > 0 and brightness >= 20)
$visited = New-Object 'bool[,]' $w, $h
$components = @()

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        if (-not $visited[$x, $y]) {
            $p = $norm.GetPixel($x, $y)
            if ($p.A -gt 0 -and ($p.R*0.299 + $p.G*0.587 + $p.B*0.114) -ge 20) {
                # BFS
                $q = New-Object System.Collections.Generic.Queue[System.Drawing.Point]
                $q.Enqueue([System.Drawing.Point]::new($x, $y))
                $visited[$x, $y] = $true
                $pts = @()
                
                while ($q.Count -gt 0) {
                    $pt = $q.Dequeue()
                    $pts += $pt
                    
                    $dirs = @(@(-1,0), @(1,0), @(0,-1), @(0,1))
                    foreach ($d in $dirs) {
                        $nx = $pt.X + $d[0]
                        $ny = $pt.Y + $d[1]
                        if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
                            if (-not $visited[$nx, $ny]) {
                                $np = $norm.GetPixel($nx, $ny)
                                if ($np.A -gt 0 -and ($np.R*0.299 + $np.G*0.587 + $np.B*0.114) -ge 20) {
                                    $visited[$nx, $ny] = $true
                                    $q.Enqueue([System.Drawing.Point]::new($nx, $ny))
                                }
                            }
                        }
                    }
                }
                if ($pts.Count -gt 10) {
                    $minX = ($pts | Measure-Object -Property X -Minimum).Minimum
                    $maxX = ($pts | Measure-Object -Property X -Maximum).Maximum
                    $minY = ($pts | Measure-Object -Property Y -Minimum).Minimum
                    $maxY = ($pts | Measure-Object -Property Y -Maximum).Maximum
                    Write-Host "Component: size=$($pts.Count), X=[$minX, $maxX], Y=[$minY, $maxY]"
                }
            }
        }
    }
}
$norm.Dispose()
