Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
$w = $norm.Width
$h = $norm.Height

# Map every pixel to an entity tag:
# 0 = Transparent / Background
# 1 = Outline (black border)
# 2 = Lamb Fleece
# 3 = Lamb Horns
# 4 = Wolf Smoke
# 5 = Wolf Head / Mask

$tag = New-Object 'int[,]' $w, $h

# Helper BFS to flood tag a component from a seed
function FloodTag($startX, $startY, $entityId) {
    if ($startX -lt 0 -or $startX -ge $w -or $startY -lt 0 -or $startY -ge $h) { return }
    $visited = New-Object 'bool[,]' $w, $h
    $q = New-Object System.Collections.Generic.Queue[System.Drawing.Point]
    
    $p0 = $norm.GetPixel($startX, $startY)
    $bright0 = [int]($p0.R * 0.299 + $p0.G * 0.587 + $p0.B * 0.114)
    if ($p0.A -eq 0 -or $bright0 -lt 15) { return }
    
    $q.Enqueue([System.Drawing.Point]::new($startX, $startY))
    $visited[$startX, $startY] = $true
    
    while ($q.Count -gt 0) {
        $pt = $q.Dequeue()
        $px = $pt.X
        $py = $pt.Y
        $tag[$px, $py] = $entityId
        
        $dirs = @(@(-1,0), @(1,0), @(0,-1), @(0,1))
        foreach ($d in $dirs) {
            $nx = $px + $d[0]
            $ny = $py + $d[1]
            if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
                if (-not $visited[$nx, $ny]) {
                    $visited[$nx, $ny] = $true
                    $np = $norm.GetPixel($nx, $ny)
                    $nbright = [int]($np.R * 0.299 + $np.G * 0.587 + $np.B * 0.114)
                    # Non-outline, non-transparent pixel belongs to the component
                    if ($np.A -gt 0 -and $nbright -ge 15) {
                        $q.Enqueue([System.Drawing.Point]::new($nx, $ny))
                    }
                }
            }
        }
    }
}

# 1. First, tag Lamb Fleece (huge 5012 px component) from (x=60, y=130)
FloodTag 60 130 2

# 2. Tag Lamb Horns from known horn components
FloodTag 100 85 3
FloodTag 118 85 3
FloodTag 60 80 3

# 3. Tag Wolf Smoke (upper plume from x=50, y=40, and lower tail curl from x=125, y=130 and x=115, y=148)
FloodTag 50 40 4
FloodTag 125 130 4
FloodTag 115 148 4
FloodTag 76 18 4
FloodTag 90 20 4

# 4. Tag Wolf Head & Mask from (x=115, y=40)
FloodTag 115 40 5

Write-Host "Segmentation complete. Now building Shiny sprite..."

$shiny = New-Object System.Drawing.Bitmap($w, $h)

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $p = $norm.GetPixel($x, $y)
        if ($p.A -eq 0) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            continue
        }
        
        $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
        $tId = $tag[$x, $y]
        
        # A. Outline pixels (or any untagged very dark pixels)
        if ($bright -lt 15) {
            # Wolf outline (upper or curl)
            if ($y -lt 65 -or ($x -gt 110 -and $y -gt 115)) {
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 18, 22, 38))
            } else {
                # Lamb outline
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 8, 8, 12))
            }
            continue
        }
        
        # B. Wolf Head & Mask (tId == 5)
        if ($tId -eq 5) {
            # Is it the Wolf's glowing cyan eye? (b > 140, g > 120, r < 110)
            if ($p.B -gt 140 -and $p.G -gt 120 -and $p.R -lt 110) {
                # Golden amber eye
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 215, 30))
                continue
            }
            # Wolf skull mask (bright bone white): In Shiny -> Obsidian skull mask!
            if ($bright -ge 120) {
                $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 120) / 135.0))
                $sr = [int](20 + $t * 22)
                $sg = [int](20 + $t * 22)
                $sb = [int](30 + $t * 26)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
                continue
            }
            # Wolf head fur/snout shading
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 15) / 100.0))
            $sr = [int](155 + $t * 70)
            $sg = [int](185 + $t * 60)
            $sb = [int](230 + $t * 25)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # C. Wolf Smoke Plume (tId == 4)
        if ($tId -eq 4) {
            # Ethereal moonlit cyan mist
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 15) / 95.0))
            $sr = [int](155 + $t * 75)
            $sg = [int](185 + $t * 60)
            $sb = [int](230 + $t * 25)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # D. Lamb Horns (tId == 3)
        if ($tId -eq 3) {
            # Shimmering antique gold horns
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 15) / 75.0))
            $sr = [int](190 + $t * 60)
            $sg = [int](150 + $t * 65)
            $sb = [int](30 + $t * 35)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # E. Lamb Fleece Body (tId == 2 or fallback)
        # Smooth velvet obsidian midnight black fleece
        $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 40) / 215.0))
        $sr = [int](12 + $t * 28)
        $sg = [int](12 + $t * 28)
        $sb = [int](20 + $t * 36)
        $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
    }
}

$norm.Dispose()

$outGame = "Graphics/Pokemon/Back shiny/KINDRAME.png"
$outArtifact = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_perfect_connected.png"

$shiny.Save($outGame, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Perfect Connected Shiny Back sprite generated!"
