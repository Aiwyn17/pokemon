Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
$w = $norm.Width
$h = $norm.Height

# We will create an explicit, accurate mask on the native 80x80 grid
$mask = New-Object 'int[,]' 80, 80

# Entities:
# 0 = Transparent
# 1 = Wolf Smoke
# 2 = Wolf Head
# 3 = Lamb Horns
# 4 = Lamb Body Fleece

# Load native 80x80 colors
$grid = New-Object 'int[,]' 80, 80
for ($gy = 0; $gy -lt 80; $gy++) {
    for ($gx = 0; $gx -lt 80; $gx++) {
        $p = $norm.GetPixel($gx * 2, $gy * 2)
        if ($p.A -gt 0) {
            # Brightness
            $grid[$gx, $gy] = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
        } else {
            $grid[$gx, $gy] = -1
        }
    }
}
$norm.Dispose()

# Let's define the precise spatial regions on 80x80:
for ($gy = 0; $gy -lt 80; $gy++) {
    for ($gx = 0; $gx -lt 80; $gx++) {
        $b = $grid[$gx, $gy]
        if ($b -lt 0) { continue }
        
        # 1. Wolf Head:
        # Wolf head is at gx >= 48, gy <= 22
        if ($gx -ge 48 -and $gy -le 22) {
            $mask[$gx, $gy] = 2 # Wolf Head
            continue
        }
        
        # 2. Wolf Smoke Plume:
        # - Top smoke mane: gy <= 25 and gx < 48
        # - Left smoke arch: gx <= 28 and gy <= 56
        # - Lower tail curl: gx >= 56 and gy >= 58
        if (($gy -le 25 -and $gx -lt 48) -or ($gx -le 28 -and $gy -le 56) -or ($gx -ge 56 -and $gy -ge 58)) {
            $mask[$gx, $gy] = 1 # Wolf Smoke
            continue
        }
        
        # 3. Lamb Horns:
        # The horns are curved ram horns at gx in [42..65], gy in [32..50], and dark
        if ($gx -ge 42 -and $gx -le 65 -and $gy -ge 32 -and $gy -le 50 -and $b -lt 85) {
            $mask[$gx, $gy] = 3 # Lamb Horns
            continue
        }
        
        # 4. Everything else is Lamb Body Fleece!
        $mask[$gx, $gy] = 4 # Lamb Body Fleece
    }
}

# Visualize mask:
# Smoke = Cyan, Head = Magenta, Horns = Yellow, Fleece = Green
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

$visPath = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_segmentation_check.png"
$vis.Save($visPath, [System.Drawing.Imaging.ImageFormat]::Png)
$vis.Dispose()
Write-Host "Segmentation check saved to $visPath"
