Add-Type -AssemblyName System.Drawing

$shinyPath = "Graphics/Pokemon/Front shiny/KINDRAME.png"
$fs = [System.IO.File]::OpenRead($shinyPath)
$bmp = [System.Drawing.Bitmap]::FromStream($fs)
$fs.Close()

function FloodClearHole($bmp, $startX, $startY, $thresh) {
    $w = $bmp.Width
    $h = $bmp.Height
    $visited = New-Object 'bool[,]' $w, $h
    $queue = New-Object System.Collections.Generic.Queue[System.Drawing.Point]
    
    $queue.Enqueue([System.Drawing.Point]::new($startX, $startY))
    $visited[$startX, $startY] = $true
    
    $cleared = 0
    while ($queue.Count -gt 0) {
        $pt = $queue.Dequeue()
        $px = $pt.X
        $py = $pt.Y
        
        $p = $bmp.GetPixel($px, $py)
        # Background pixel condition: pure white / very near white (R,G,B all >= thresh)
        $isBg = ($p.R -ge $thresh -and $p.G -ge $thresh -and $p.B -ge $thresh)
        
        if ($isBg) {
            $bmp.SetPixel($px, $py, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            $cleared++
            
            $dirs = @(@(-1, 0), @(1, 0), @(0, -1), @(0, 1))
            foreach ($d in $dirs) {
                $nx = $px + $d[0]
                $ny = $py + $d[1]
                if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
                    if (-not $visited[$nx, $ny]) {
                        $visited[$nx, $ny] = $true
                        $queue.Enqueue([System.Drawing.Point]::new($nx, $ny))
                    }
                }
            }
        }
    }
    Write-Host "Cleared $cleared pixels from seed ($startX, $startY)"
}

# Clear big hole between neck and smoke
FloodClearHole $bmp 102 55 242

# Clear small hole in tail curl
FloodClearHole $bmp 54 115 242

$outPath = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_shiny_front_fixed.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Host "Saved test to $outPath"
