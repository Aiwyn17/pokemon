Add-Type -AssemblyName System.Drawing

$norm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")

# Native 80x80 bitmap
$native = New-Object System.Drawing.Bitmap(80, 80)
for ($y = 0; $y -lt 80; $y++) {
    for ($x = 0; $x -lt 80; $x++) {
        $p = $norm.GetPixel($x * 2, $y * 2)
        $native.SetPixel($x, $y, $p)
    }
}
$norm.Dispose()

$native.Save("C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_native80.png", [System.Drawing.Imaging.ImageFormat]::Png)
$native.Dispose()
Write-Host "Saved 80x80 native grid"
