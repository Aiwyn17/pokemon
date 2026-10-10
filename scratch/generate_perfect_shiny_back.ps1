Add-Type -AssemblyName System.Drawing

$normPath = "Graphics/Pokemon/Back/KINDRAME.png"
$bmp = [System.Drawing.Bitmap]::FromFile($normPath)
$w = $bmp.Width
$h = $bmp.Height

# We will create shiny on 160x160 directly or on native grid
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
        
        # 1. Dark outline (very dark black/charcoal)
        if ($bright -lt 30) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 12, 12, 16))
            continue
        }
        
        # 2. Glowing cyan eyes / runes (high blue/green, low red)
        if ($b -gt 160 -and $g -gt 130 -and $r -lt 120) {
            # Shiny eyes/runes glow golden amber
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 215, 50))
            continue
        }
        
        # 3. Determine if pixel belongs to the Wolf (upper region y < 65 or left smoke curl x < 70, y < 100 or right tail curl x > 110)
        $isWolf = ($y -lt 68) -or ($x -lt 65 -and $y -lt 105) -or ($x -gt 115 -and $y -gt 115)
        
        if ($isWolf) {
            # Check if this is the Wolf's white skull mask (top right: x >= 95, y >= 25, y <= 68 and bright)
            $isMask = ($x -ge 95 -and $y -ge 24 -and $y -le 68 -and $bright -gt 140)
            if ($isMask) {
                # Skull mask becomes obsidian dark in Shiny
                $t = ($bright - 140) / 115.0
                $sr = [int](25 + $t * 20)
                $sg = [int](25 + $t * 20)
                $sb = [int](35 + $t * 25)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
                continue
            }
            
            # Rest of Wolf: dark smoke -> luminous moonlit cyan/lavender ethereal mist!
            $t = [math]::Min(1.0, [math]::Max(0.0, $bright / 140.0))
            $sr = [int](150 + $t * 70)
            $sg = [int](185 + $t * 60)
            $sb = [int](230 + $t * 25)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # 4. The Lamb (y >= 68)
        # Horns / mask markings: medium-dark pixels on lamb's head (x between 85 and 130, y between 65 and 105, brightness < 110)
        $isHorn = ($x -ge 80 -and $x -le 135 -and $y -ge 65 -and $y -le 105 -and $bright -lt 115)
        if ($isHorn) {
            # Horns and mask markings become radiant gold!
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 30) / 85.0))
            $sr = [int](195 + $t * 55)
            $sg = [int](150 + $t * 65)
            $sb = [int](35 + $t * 50)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # Lamb's wool fleece: bright white/blue -> obsidian midnight fleece!
        $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 90) / 165.0))
        $sr = [int](18 + $t * 30)
        $sg = [int](18 + $t * 30)
        $sb = [int](28 + $t * 35)
        $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
    }
}

$bmp.Dispose()

# Save Shiny Back sprite
$shiny.Save("Graphics/Pokemon/Back shiny/KINDRAME.png", [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save("C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_houndoom_fixed.png", [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Shiny Back sprite generated and saved successfully!"
