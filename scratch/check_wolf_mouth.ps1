Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_fixed_perfect.png")

for ($y = 35; $y -le 46; $y++) {
    for ($x = 110; $x -le 130; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.R -gt 150 -and $p.G -gt 100 -and $p.B -lt 80) {
            Write-Host "Yellow/Gold pixel at ($x,$y): R=$($p.R), G=$($p.G), B=$($p.B)"
        }
    }
}

$bmp.Dispose()
