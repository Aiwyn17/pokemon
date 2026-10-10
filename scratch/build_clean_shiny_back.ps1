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
        
        # 1. Wolf's glowing cyan eye (strictly at top-right head: x in [100..130], y in [24..55])
        if ($x -ge 100 -and $x -le 130 -and $y -ge 24 -and $y -le 55 -and $b -gt 140 -and $g -gt 120 -and $r -lt 110) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 255, 215, 40))
            continue
        }
        
        # Determine entity:
        # Horn region on the lamb:
        $isHorn = ($x -ge 84 -and $x -le 134 -and $y -ge 60 -and $y -le 104 -and $bright -lt 85)
        
        # Wolf region:
        $isWolf = (-not $isHorn) -and (($y -lt 62) -or ($x -lt 65 -and $y -lt 110) -or ($x -gt 115 -and $y -gt 115))
        
        if ($isWolf) {
            # Wolf's skull mask: top-right, bright
            if ($x -ge 96 -and $y -ge 24 -and $y -le 56 -and $bright -ge 120) {
                $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 120) / 135.0))
                $sr = [int](22 + $t * 22)
                $sg = [int](22 + $t * 22)
                $sb = [int](32 + $t * 26)
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
                continue
            }
            
            # Dark border/outline of the wolf mist
            if ($bright -lt 10) {
                $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 18, 22, 38))
                continue
            }
            
            # Luminous moonlit cyan mist
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 10) / 95.0))
            $sr = [int](155 + $t * 70)
            $sg = [int](185 + $t * 60)
            $sb = [int](230 + $t * 25)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # Lamb Entity:
        # Dark outline of the lamb
        if ($bright -lt 10) {
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 8, 8, 12))
            continue
        }
        
        if ($isHorn) {
            # Shiny golden horns:
            $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 10) / 75.0))
            $sr = [int](185 + $t * 65)
            $sg = [int](145 + $t * 65)
            $sb = [int](30 + $t * 40)
            $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
            continue
        }
        
        # Lamb Fleece: smooth, pure midnight obsidian charcoal!
        $t = [math]::Min(1.0, [math]::Max(0.0, ($bright - 60) / 195.0))
        $sr = [int](12 + $t * 26)
        $sg = [int](12 + $t * 26)
        $sb = [int](20 + $t * 34)
        $shiny.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $sr, $sg, $sb))
    }
}

$bmp.Dispose()

$outGame = "Graphics/Pokemon/Back shiny/KINDRAME.png"
$outArtifact = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_fixed_clean.png"

$shiny.Save($outGame, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)
$shiny.Dispose()

Write-Host "Updated Shiny Back sprite saved cleanly!"
