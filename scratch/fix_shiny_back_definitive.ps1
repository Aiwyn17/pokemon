Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
$w = $norm.Width
$h = $norm.Height

$shiny = New-Object System.Drawing.Bitmap($w, $h)

# Tag array:
# 0 = BG
# 2 = Lamb Fleece (Obsidian)
# 3 = Lamb Horn (Gold)
# 4 = Wolf Smoke (Cyan Mist)
# 5 = Wolf Mask (Obsidian Mask)
# 6 = Wolf Eye (Amber Glow)
# 7 = Lamb Outline (Pure Black)
# 8 = Wolf Outline (Navy Black)

$tag = New-Object 'int[,]' $w, $h

# 1. Flood tag Lamb Fleece (start at x=60, y=130)
# A pixel belongs to the fleece if it is non-transparent and NOT the wolf or horn
$visited = New-Object 'bool[,]' $w, $h
$q = New-Object System.Collections.Generic.Queue[System.Drawing.Point]
$q.Enqueue([System.Drawing.Point]::new(60, 130))
$visited[60, 130] = $true

while ($q.Count -gt 0) {
    $pt = $q.Dequeue()
    $px = $pt.X
    $py = $pt.Y
    
    $p = $norm.GetPixel($px, $py)
    $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
    
    # Horn area boundary: horns are at px >= 85 and py in [65..100] with bright < 70
    $isHornPixel = ($px -ge 84 -and $px -le 130 -and $py -ge 65 -and $py -le 100 -and $bright -lt 70)
    
    if ($isHornPixel) {
        $tag[$px, $py] = 3 # Horn
    } elseif ($bright -lt 8) {
        $tag[$px, $py] = 7 # Lamb outline
    } else {
        $tag[$px, $py] = 2 # Lamb fleece
    }
    
    $dirs = @(@(-1,0), @(1,0), @(0,-1), @(0,1))
    foreach ($d in $dirs) {
        $nx = $px + $d[0]
        $ny = $py + $d[1]
        if ($nx -ge 0 -and $nx -lt $w -and $ny -ge 0 -and $ny -lt $h) {
            if (-not $visited[$nx, $ny]) {
                $np = $norm.GetPixel($nx, $ny)
                if ($np.A -gt 0) {
                    # Do not cross into wolf region:
                    # Wolf is at ny < 62 (unless part of lamb's head) or wolf tail curl (nx > 110 and ny > 115 and dark)
                    $nbright = [int]($np.R * 0.299 + $np.G * 0.587 + $np.B * 0.114)
                    $isWolfTail = ($nx -gt 110 -and $ny -gt 115 -and $nbright -lt 100)
                    $isWolfPlume = ($ny -lt 62 -and $nx -lt 84) -or ($ny -lt 55)
                    
                    if (-not $isWolfTail -and -not $isWolfPlume) {
                        $visited[$nx, $ny] = $true
                        $q.Enqueue([System.Drawing.Point]::new($nx, $ny))
                    }
                }
            }
        }
    }
}

# 2. Also ensure all horn pixels in [84..130, 65..100] are tagged as Horn (tag 3)
for ($y = 65; $y -le 100; $y++) {
    for ($x = 84; $x -le 130; $x++) {
        $p = $norm.GetPixel($x, $y)
        if ($p.A -gt 0) {
            $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
            if ($bright -lt 75 -and $tag[$x, $y] -ne 7) {
                $tag[$x, $y] = 3
            }
        }
    }
}

# 3. All other non-transparent pixels belong to the WOLF!
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $p = $norm.GetPixel($x, $y)
        if ($p.A -gt 0 -and $tag[$x, $y] -eq 0) {
            $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
            # Wolf Eye: cyan glow (b > 140, g > 120, r < 110) at head
            if ($x -ge 95 -and $x -le 130 -and $y -le 55 -and $p.B -gt 140 -and $p.G -gt 120 -and $p.R -lt 110) {
                $tag[$x, $y] = 6 # Eye
            } elseif ($x -ge 95 -and $y -le 55 -and $bright -ge 120) {
                $tag[$x, $y] = 5 # Mask
            } elseif ($bright -lt 6) {
                $tag[$x, $y] = 8 # Wolf outline
            } else {
                $tag[$x, $y] = 4 # Wolf smoke
            }
        }
    }
}

Write-Host "Coloring Shiny sprite..."

# 4. Color the Shiny sprite using clean palette mappings
for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $p = $norm.GetPixel($x, $y)
        if ($p.A -eq 0) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            continue
        }
        
        $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
        $t = $tag[$x, $y]
        
        switch ($t) {
            2 {
                # Lamb Fleece Body: Velvet Obsidian Midnight Black
                $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 40) / 215.0))
                $sr = [int](14 + $ratio * 26)
                $sg = [int](14 + $ratio * 26)
                $sb = [int](22 + $ratio * 34)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            }
            3 {
                # Lamb Horn: Rich Radiant Antique Gold
                $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 8) / 65.0))
                $sr = [int](185 + $ratio * 65)
                $sg = [int](145 + $ratio * 65)
                $sb = [int](25 + $ratio * 40)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            }
            4 {
                # Wolf Smoke: Luminous Moonlit Cyan / Lavender Mist
                $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 6) / 95.0))
                $sr = [int](155 + $ratio * 75)
                $sg = [int](185 + $ratio * 60)
                $sb = [int](230 + $ratio * 25)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            }
            5 {
                # Wolf Skull Mask: Obsidian Black Mask
                $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 120) / 135.0))
                $sr = [int](22 + $ratio * 22)
                $sg = [int](22 + $ratio * 22)
                $sb = [int](32 + $ratio * 26)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            }
            6 {
                # Wolf Eye: Radiant Glowing Golden Amber
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 215, 30))
            }
            7 {
                # Lamb Outline: Deep Black
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 8, 8, 12))
            }
            8 {
                # Wolf Outline: Navy Midnight
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 18, 22, 38))
            }
            default {
                # Fallback: Lamb fleece
                $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 40) / 215.0))
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, [int](14 + $ratio * 26), [int](14 + $ratio * 26), [int](22 + $ratio * 34)))
            }
        }
    }
}

$norm.Dispose()

$outGame = "Graphics/Pokemon/Back shiny/KINDRAME.png"
$outArtifact = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_clean_definitive.png"

$shiny.Save($outGame, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Definitive Shiny Back sprite generated successfully!"
