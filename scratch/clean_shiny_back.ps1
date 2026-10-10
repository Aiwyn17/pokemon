Add-Type -AssemblyName System.Drawing

$normPath = "Graphics/Pokemon/Back/KINDRAME.png"
$bmp = [System.Drawing.Bitmap]::FromFile($normPath)
$w = $bmp.Width
$h = $bmp.Height

$shiny = New-Object System.Drawing.Bitmap($w, $h)

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.A -eq 0) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
            continue
        }
        
        $r = $c.R; $g = $c.G; $b = $c.B
        $bright = [int]($r * 0.299 + $g * 0.587 + $b * 0.114)
        
        # 1. Dark outline -> stay dark outline
        if ($bright -lt 28) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 10, 10, 14))
            continue
        }
        
        # 2. Glowing cyan wolf eye / markings
        if ($b -gt 150 -and $g -gt 130 -and $r -lt 110) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 215, 30))
            continue
        }
        
        # Determine if pixel belongs to Wolf or Lamb
        # Lamb horn bounds: x between 86 and 132, y between 66 and 100, and it's dark
        $isHorn = ($x -ge 84 -and $x -le 134 -and $y -ge 65 -and $y -le 102 -and $bright -lt 115)
        
        # Wolf region:
        # - Upper smoke mane: y < 58 (excluding horn area)
        # - Left smoke trail: x < 65 and y < 105
        # - Right smoke curl: x > 115 and y > 115
        $isWolf = (-not $isHorn) -and (($y -lt 58) -or ($x -lt 65 -and $y -lt 105) -or ($x -gt 115 -and $y -gt 115))
        
        if ($isWolf) {
            # Is it Wolf's skull mask? (Top-right x >= 96, y >= 24, y <= 56 and bright)
            $isWolfMask = ($x -ge 96 -and $y -ge 24 -and $y -le 56 -and $bright -gt 130)
            if ($isWolfMask) {
                # In Shiny, skull mask becomes obsidian black with subtle shading
                $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 130) / 125.0))
                $sr = [int](22 + $t * 22)
                $sg = [int](22 + $t * 22)
                $sb = [int](32 + $t * 26)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
                continue
            }
            
            # Wolf smoke body (was dark navy) -> Luminous moonlit cyan/lavender mist!
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 28) / 100.0))
            # Smooth interpolation:
            # Shadow mist: (145, 175, 225) -> Highlight mist: (225, 240, 255)
            $sr = [int](145 + $t * 80)
            $sg = [int](175 + $t * 65)
            $sb = [int](225 + $t * 30)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        if ($isHorn) {
            # Lamb's horns: Shimmering gold!
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 28) / 85.0))
            # Shadow gold: (170, 130, 25) -> Bright gold: (250, 215, 65)
            $sr = [int](170 + $t * 80)
            $sg = [int](130 + $t * 85)
            $sb = [int](25 + $t * 40)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # Lamb's wool (everything else on the lamb body)
        # Was white/cyan fleece -> Obsidian midnight fleece!
        $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 80) / 175.0))
        # Shadow fleece: (14, 14, 22) -> Highlight fleece: (38, 38, 52)
        $sr = [int](14 + $t * 26)
        $sg = [int](14 + $t * 26)
        $sb = [int](22 + $t * 32)
        $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
    }
}

$bmp.Dispose()

$outGame = "Graphics/Pokemon/Back shiny/KINDRAME.png"
$outArtifact = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_clean_fixed.png"

$shiny.Save($outGame, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Clean Shiny Back sprite generated and saved to $outGame and $outArtifact!"
