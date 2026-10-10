Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
Write-Host "Size: $($norm.Width)x$($norm.Height)"

# Print ASCII map of the sprite at 80x80 (step of 2)
# . = transparent, W = Wolf smoke, M = Wolf mask, E = Wolf eye, H = Horn, L = Lamb fleece, O = Outline
$rows = @()
for ($y = 0; $y -lt 160; $y += 4) {
    $line = ""
    for ($x = 0; $x -lt 160; $x += 4) {
        $p = $norm.GetPixel($x, $y)
        if ($p.A -eq 0) { $line += " " }
        else {
            $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
            if ($bright -lt 15) { $line += "#" }
            elseif ($p.B -gt 150 -and $p.G -gt 130 -and $p.R -lt 110) { $line += "*" }
            elseif ($bright -gt 120) { $line += "W" }
            else { $line += "." }
        }
    }
    Write-Host ("{0:d2}: {1}" -f ($y/4), $line)
}
$norm.Dispose()
