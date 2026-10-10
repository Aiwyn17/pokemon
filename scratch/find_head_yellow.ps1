Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile("C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_shiny_fixed_perfect.png")

for ($y = 10; $y -le 64; $y++) {
    for ($x = 90; $x -le 140; $x++) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.R -gt 150 -and $p.G -gt 100 -and $p.B -lt 80) {
            Write-Host "Yellow pixel at ($x,$y): R=$($p.R), G=$($p.G), B=$($p.B)"
        }
    }
}

$bmp.Dispose()
