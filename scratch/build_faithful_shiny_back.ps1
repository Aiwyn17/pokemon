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
        
        # Check if pixel is on the outer outline bordering transparency
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
        
        # 1. Wolf Eye: Top-right head, cyan in normal
        if ($x -ge 95 -and $x -le 130 -and $y -le 55 -and $b -gt 135 -and $g -gt 115 -and $r -lt 110) {
            # Shiny Wolf Eye: piercing cyan/white glow (like in Face Shiny)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 185, 245, 255))
            continue
        }
        
        # 2. Wolf Head (at top right: x >= 95, y <= 55)
        if ($x -ge 95 -and $x -le 135 -and $y -le 55) {
            # In Face Shiny, the wolf head is JET BLACK / OBSIDIAN (#0e0e18 to #181926)
            $ratio = [math]::Min(1.0, [math]::Max(0.0, $bright / 200.0))
            $sr = [int](14 + $ratio * 16)
            $sg = [int](14 + $ratio * 16)
            $sb = [int](22 + $ratio * 20)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # 3. Lamb Ram Horns: x in [84..134], y in [64..102], was dark in normal (bright < 85)
        $isHorn = ($x -ge 84 -and $x -le 134 -and $y -ge 64 -and $y -le 102 -and $bright -lt 85)
        if ($isHorn) {
            # In Face Shiny, the horns are BONE IVORY (#dfdac6, #e2ddca, #bbb9e9)
            if ($isOuterEdge -and $bright -lt 15) {
                # Dark horn outline
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 30, 28, 26))
                continue
            }
            # Smooth bone ivory shading:
            # Shadow bone: #b8b2a2 -> Highlight bone: #eeebe0
            $ratio = [math]::Min(1.0, [math]::Max(0.0, $bright / 80.0))
            $sr = [int](185 + $ratio * 52)
            $sg = [int](180 + $ratio * 54)
            $sb = [int](165 + $ratio * 58)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # 4. Wolf Smoke Plume:
        # - Anywhere at y < 64 (top arch)
        # - Left arch at x < 58 (down to y=115)
        # - Lower right tail curl at x > 110 and y > 115
        $isWolfSmoke = ($y -lt 64) -or ($x -lt 58 -and $y -le 115) -or ($x -gt 110 -and $y -gt 115)
        if ($isWolfSmoke) {
            # Outer edge of smoke
            if ($isOuterEdge -and $bright -lt 15) {
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 38, 36, 60))
                continue
            }
            # In Face Shiny, smoke is pastel lilac / moonlit cyan mist (#b7b4e3, #bfd5ec, #d5ffff)
            # Smooth gradient from shadow lilac to bright cyan/white mist
            $ratio = [math]::Min(1.0, [math]::Max(0.0, $bright / 90.0))
            $sr = [int](180 + $ratio * 40)
            $sg = [int](180 + $ratio * 55)
            $sb = [int](225 + $ratio * 30)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # 5. Lamb Fleece Body:
        # In Face Shiny, the fleece is PURE VELVET OBSIDIAN BLACK (#090910, #101118, #161726)
        if ($isOuterEdge -and $bright -lt 15) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 6, 6, 10))
            continue
        }
        # Smooth obsidian shading:
        $ratio = [math]::Min(1.0, [math]::Max(0.0, ($bright - 30) / 225.0))
        $sr = [int](10 + $ratio * 20)
        $sg = [int](10 + $ratio * 20)
        $sb = [int](16 + $ratio * 26)
        $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
    }
}

$norm.Dispose()

$outGame = "Graphics/Pokemon/Back shiny/KINDRAME.png"
$outArtifact = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_faithful.png"

$shiny.Save($outGame, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Faithful Shiny Back sprite successfully generated!"
