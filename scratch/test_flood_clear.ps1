Add-Type -AssemblyName System.Drawing

$srcPath = "Graphics/Pokemon/Front/KINDRAME.png"
$bmp = New-Object System.Drawing.Bitmap($srcPath)

function FloodClearHole($bmp, $startX, $startY, $thresh) {
    $w = $bmp.Width
    $h = $bmp.Height
    $visited = New-Object 'bool[,]' $w, $h
    $queue = New-Object System.Collections.Generic.Queue[System.Drawing.Point]
    
    $queue.Enqueue((New-Object System.Drawing.Point($startX, $startY)))
    $visited[$startX, $startY] = $true
    
    $cleared = 0
    while ($queue.Count -gt 0) {
        $pt = $queue.Dequeue()
        $px = $pt.X
        $py = $pt.Y
        
        $p = $bmp.GetPixel($px, $py)
        # Background pixel condition: near white or very light grey (R,G,B all > thresh)
        # Also include anti-aliasing pixels that are close to white
        $isBg = ($p.R -ge $thresh -and $p.G -ge $thresh -and $p.B -ge $thresh)
        if (-not $isBg -and ($p.R + $p.G + $p.B -ge ($thresh * 3 - 30))) {
            $isBg = $true
        }
        
        if ($isBg) {
            $bmp.SetPixel($px, $py, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            $cleared++
            
            $dirs = @(
                @(-1, 0), @(1, 0), @(0, -1), @(0, 1)
            )
            foreach ($d in $dirs) {
                $nx = $px + $d[0]
                $ny = $py + $d[1]
                if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
                    if (-not $visited[$nx, $ny]) {
                        $visited[$nx, $ny] = $true
                        $queue.Enqueue((New-Object System.Drawing.Point($nx, $ny)))
                    }
                }
            }
        }
    }
    Write-Host "Cleared $cleared pixels from seed ($startX, $startY)"
}

# Clear big hole between neck and smoke
FloodClearHole $bmp 102 55 200

# Clear small hole in tail curl
FloodClearHole $bmp 54 115 200

$outPath = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_front_fixed_test.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Saved to $outPath"
