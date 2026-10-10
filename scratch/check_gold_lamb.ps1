Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_fixed_clean.png")

for ($y = 120; $y -lt 160; $y++) {
    for ($x = 30; $x -lt 120; $x++) {
        $p = $bmp.GetPixel($x, $y)
        # Check if pixel has gold/yellow hue (R > 150, G > 100, B < 80)
        if ($p.R -gt 150 -and $p.G -gt 100 -and $p.B -lt 80) {
            Write-Host "Gold pixel at ($x,$y): R=$($p.R), G=$($p.G), B=$($p.B)"
        }
    }
}

$bmp.Dispose()
