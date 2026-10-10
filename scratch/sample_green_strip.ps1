Add-Type -AssemblyName System.Drawing

$vis = [System.Drawing.Bitmap]::FromFile("C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_segmentation_v2.png")

Write-Host "Sampling green pixels above the black line:"
for ($y = 40; $y -le 65; $y += 2) {
    for ($x = 60; $x -le 110; $x += 4) {
        $p = $vis.GetPixel($x, $y)
        if ($p.R -eq 50 -or ($p.G -eq 205 -and $p.R -eq 50) -or ($p.G -gt 200 -and $p.R -lt 50)) {
            Write-Host "Green pixel at 160x160: ($x, $y) -> 80x80: ($([int]($x/2)), $([int]($y/2)))"
        }
    }
}
$vis.Dispose()
