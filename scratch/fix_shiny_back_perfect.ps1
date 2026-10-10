Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
$w = $norm.Width
$h = $norm.Height

$shiny = New-Object System.Drawing.Bitmap($w, $h)

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $p = $norm.GetPixel($x, $y)
        if ($p.A -eq 0) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            continue
        }
        
        $r = $p.R; $g = $p.G; $b = $p.B
        $bright = [int]($r * 0.299 + $g * 0.587 + $b * 0.114)
        
        # Check if pixel is bordering transparent background (true outer outline)
        $isOuterEdge = $false
        $dirs = @(@(-1,0), @(1,0), @(0,-1), @(0,1))
        foreach ($d in $dirs) {
            $nx = $x + $d[0]
            $ny = $y + $d[1]
            if ($nx -lt 0 -or $nx -ge $w -or $ny -lt 0 -or $ny -ge $h -or ($norm.GetPixel($nx, $ny).A -eq 0)) {
                $isOuterEdge = $true
                break
            }
        }
        
        # Classification:
        # 1. Wolf Eye: Top-right head, glowing cyan in normal
        if ($x -ge 95 -and $x -le 130 -and $y -le 55 -and $b -gt 135 -and $g -gt 115 -and $r -lt 110) {
            # Shiny: Glowing Golden Amber Eye
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 215, 30))
            continue
        }
        
        # 2. Wolf Skull Mask: Top-right head, bone white in normal
        if ($x -ge 95 -and $x -le 135 -and $y -le 55 -and $bright -ge 110) {
            # Shiny: Obsidian Skull Mask with smooth shading
            $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 110) / 145.0))
            $sr = [int](20 + $ratio * 22)
            $sg = [int](20 + $ratio * 22)
            $sb = [int](30 + $ratio * 26)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # 3. Lamb Horn: x in [84..134], y in [64..102], and was dark in normal
        $isHorn = ($x -ge 84 -and $x -le 134 -and $y -ge 64 -and $y -le 102 -and $bright -lt 85)
        if ($isHorn) {
            if ($isOuterEdge -and $bright -lt 15) {
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 75, 50, 10))
                continue
            }
            # Radiant antique gold horn
            $ratio = [math]::Min(1.0, [math]::Max(0.0, $bright / 85.0))
            $sr = [int](175 + $ratio * 75)
            $sg = [int](135 + $ratio * 75)
            $sb = [int](25 + $ratio * 40)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # 4. Wolf Smoke Plume:
        # - Anywhere at y < 64 (top arch and head fur)
        # - Left arch at x < 58 (down to y=115)
        # - Lower right tail curl at x > 110 and y > 115
        $isWolfSmoke = ($y -lt 64) -or ($x -lt 58 -and $y -le 115) -or ($x -gt 110 -and $y -gt 115)
        if ($isWolfSmoke) {
            # Outer edge of smoke gets soft dark navy outline
            if ($isOuterEdge -and $bright -lt 15) {
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 18, 22, 38))
                continue
            }
            # Inside the smoke: smooth luminous moonlit cyan mist! NO BLACK DOTS!
            $ratio = [math]::Min(1.0, [math]::Max(0.0, $bright / 90.0))
            $sr = [int](150 + $ratio * 75)
            $sg = [int](180 + $ratio * 65)
            $sb = [int](225 + $ratio * 30)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # 5. Lamb Fleece Body:
        # Outer edge of fleece
        if ($isOuterEdge -and $bright -lt 15) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 6, 6, 10))
            continue
        }
        # Velvet obsidian midnight charcoal fleece (NO YELLOW, pure smooth shading)
        $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 30) / 225.0))
        $sr = [int](14 + $ratio * 26)
        $sg = [int](14 + $ratio * 26)
        $sb = [int](22 + $ratio * 34)
        $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
    }
}

$norm.Dispose()

$outGame = "Graphics/Pokemon/Back shiny/KINDRAME.png"
$outArtifact = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_fixed_perfect.png"

$shiny.Save($outGame, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Perfect Shiny Back sprite generated!"
