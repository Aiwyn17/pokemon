Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")

# Find the black divider line between y=20 and y=40 for each column x=20..70
Write-Host "Scanning divider line between wolf and lamb:"
for ($gx = 20; $gx -le 70; $gx += 2) {
    # Scan vertically downwards
    for ($gy = 20; $gy -le 40; $gy++) {
        $p = $norm.GetPixel($gx * 2, $gy * 2)
        if ($p.A -gt 0) {
            $bright = [int]($p.R * 0.299 + $p.G * 0.587 + $p.B * 0.114)
            if ($bright -lt 15) {
                Write-Host "gx=$gx : divider at gy=$gy"
                break
            }
        }
    }
}
$norm.Dispose()
