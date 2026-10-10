Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_back_perfect_houndoom_1791585386206.jpg"
$bmp = New-Object System.Drawing.Bitmap($srcPath)
Write-Host "Image dimensions: $($bmp.Width)x$($bmp.Height)"

# Sample horizontal slice across y=550 (near boundary between wolf and lamb)
for ($x = 200; $x -le 900; $x += 50) {
    $p = $bmp.GetPixel($x, 550)
    Write-Host "x=$x, y=550: R=$($p.R), G=$($p.G), B=$($p.B)"
}

$bmp.Dispose()
