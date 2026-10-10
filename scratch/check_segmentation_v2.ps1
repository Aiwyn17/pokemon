Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
$w = $norm.Width
$h = $norm.Height

$mask = New-Object 'int[,]' 80, 80

# 1. Start with transparency
# 2. Wolf Head: gx >= 48 and gy <= 25
# 3. Wolf Smoke: 
#    - All gy <= 28 (except wolf head)
#    - Arch on the left: gx <= 32 and gy <= 52
#    - Tail curl on the right: gx >= 54 and gy >= 58
# 4. Lamb Horns:
#    - Inside the lamb's head (gy in [30..49], gx in [44..65]), any pixel that was dark in normal (bright < 85)
# 5. Lamb Fleece Body:
#    - Everything else!

for ($gy = 0; $gy -lt 80; $gy++) {
    for ($gx = 0; $gx -lt 80; $gx++) {
        $p = $norm.GetPixel($gx * 2, $gy * 2)
        if ($p.A -eq 0) { continue }
        
        $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
        
        # Wolf Head:
        if ($gx -ge 48 -and $gy -le 24) {
            $mask[$gx, $gy] = 2 # Wolf Head
            continue
        }
        
        # Wolf Smoke:
        $isSmoke = ($gy -le 28) -or ($gx -le 31 -and $gy -le 52) -or ($gx -ge 54 -and $gy -ge 58)
        if ($isSmoke) {
            $mask[$gx, $gy] = 1 # Wolf Smoke
            continue
        }
        
        # Lamb Horn:
        if ($gx -ge 44 -and $gx -le 65 -and $gy -ge 30 -and $gy -le 49 -and $bright -lt 85) {
            $mask[$gx, $gy] = 3 # Lamb Horn
            continue
        }
        
        # Lamb Fleece:
        $mask[$gx, $gy] = 4 # Lamb Fleece
    }
}
$norm.Dispose()

# Render verification
$vis = New-Object System.Drawing.Bitmap(160, 160)
for ($y = 0; $y -lt 160; $y++) {
    for ($x = 0; $x -lt 160; $x++) {
        $m = $mask[[int]($x/2), [int]($y/2)]
        switch ($m) {
            1 { $vis.SetPixel($x, $y, [System.Drawing.Color]::Cyan) }
            2 { $vis.SetPixel($x, $y, [System.Drawing.Color]::Magenta) }
            3 { $vis.SetPixel($x, $y, [System.Drawing.Color]::Yellow) }
            4 { $vis.SetPixel($x, $y, [System.Drawing.Color]::LimeGreen) }
            default { $vis.SetPixel($x, $y, [System.Drawing.Color]::Black) }
        }
    }
}

$visPath = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_segmentation_v2.png"
$vis.Save($visPath, [System.Drawing.Imaging.ImageFormat]::Png)
$vis.Dispose()
Write-Host "Segmentation v2 saved to $visPath"
