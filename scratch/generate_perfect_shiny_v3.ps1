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
        
        # Grid coords in 80x80 space (each pixel is 2x2 in 160x160)
        $gx = [int]($x / 2)
        $gy = [int]($y / 2)
        
        # === 1. WOLF HEAD & MASK ===
        # Wolf head is strictly at gx in [44..70], gy in [16..31]
        $isWolfHead = ($gx -ge 44 -and $gx -le 70 -and $gy -ge 16 -and $gy -le 31)
        if ($isWolfHead) {
            # Is it the Wolf Eye? (cyan glow: b > 140, g > 120, r < 110)
            if ($b -gt 140 -and $g -gt 120 -and $r -lt 110) {
                # Glowing Golden Amber Eye
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 215, 30))
                continue
            }
            
            # Is it the Wolf Mask? (bright bone white: bright >= 115)
            if ($bright -ge 115) {
                # Obsidian Black Skull Mask
                $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 115) / 140.0))
                $sr = [int](22 + $t * 22)
                $sg = [int](22 + $t * 22)
                $sb = [int](32 + $t * 26)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
                continue
            }
            
            # Wolf Head Fur / Outline
            if ($bright -lt 15) {
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 12, 14, 24))
                continue
            }
            
            # Head smoke/fur
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 15) / 95.0))
            $sr = [int](155 + $t * 70)
            $sg = [int](185 + $t * 60)
            $sb = [int](230 + $t * 25)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # === 2. WOLF SMOKE PLUME ===
        # Upper plume (gy < 46 and gx <= 42), or top wisps (gy < 16), or right lower curl (gx >= 55 and gy >= 48)
        $isWolfSmoke = ($gy -lt 16) -or ($gx -le 42 -and $gy -lt 48) -or ($gx -ge 55 -and $gy -ge 48)
        if ($isWolfSmoke) {
            if ($bright -lt 15) {
                # Dark navy outline for ethereal mist
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 18, 22, 38))
                continue
            }
            
            # Smooth glowing moonlit cyan/lavender mist
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 15) / 90.0))
            $sr = [int](155 + $t * 75)
            $sg = [int](185 + $t * 60)
            $sb = [int](230 + $t * 25)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # === 3. LAMB HORN ===
        # Ram horn is strictly at gx in [42..68], gy in [32..48], and dark (bright < 80)
        $isHorn = ($gx -ge 42 -and $gx -le 68 -and $gy -ge 32 -and $gy -le 48 -and $bright -lt 80)
        if ($isHorn) {
            if ($bright -lt 15) {
                # Dark bronze outline
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 95, 65, 15))
                continue
            }
            # Radiant antique gold horn
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 15) / 65.0))
            $sr = [int](185 + $t * 65)
            $sg = [int](145 + $t * 65)
            $sb = [int](30 + $t * 35)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # === 4. LAMB FLEECE BODY ===
        # Everything else belongs to the lamb's body!
        # Dark outline
        if ($bright -lt 15) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 8, 8, 12))
            continue
        }
        
        # Velvet obsidian midnight charcoal fleece (NO YELLOW!)
        $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 60) / 195.0))
        $sr = [int](12 + $t * 26)
        $sg = [int](12 + $t * 26)
        $sb = [int](20 + $t * 34)
        $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
    }
}

$norm.Dispose()

$outGame = "Graphics/Pokemon/Back shiny/KINDRAME.png"
$outArtifact = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_perfect_v3.png"

$shiny.Save($outGame, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Perfect Shiny Back v3 generated and saved!"
