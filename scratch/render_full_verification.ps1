Add-Type -AssemblyName System.Drawing

$fNorm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Front/KINDRAME.png")
$fShin = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Front shiny/KINDRAME.png")
$bNorm = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back/KINDRAME.png")
$bShin = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Back shiny/KINDRAME.png")

# 4 sprites across (640 wide), 2 rows (320 high: top row dark bg, bottom row grass arena bg)
$w = 160 * 4
$h = 160 * 2
$sheet = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($sheet)

$brushDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 34, 34, 38))
$brushGrass = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 116, 184, 104))

# Fill backgrounds
$g.FillRectangle($brushDark, 0, 0, $w, 160)
$g.FillRectangle($brushGrass, 0, 160, $w, 160)

# Draw Top Row (Dark BG)
$g.DrawImage($fNorm, 0, 0, 160, 160)
$g.DrawImage($bNorm, 160, 0, 160, 160)
$g.DrawImage($fShin, 320, 0, 160, 160)
$g.DrawImage($bShin, 480, 0, 160, 160)

# Draw Bottom Row (Grass Arena BG)
$g.DrawImage($fNorm, 0, 160, 160, 160)
$g.DrawImage($bNorm, 160, 160, 160, 160)
$g.DrawImage($fShin, 320, 160, 160, 160)
$g.DrawImage($bShin, 480, 160, 160, 160)

$font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$brushText = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$brushShadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)

$labels = @("Face Normal", "Dos Normal (Gen 5)", "Face Shiny", "Dos Shiny (Gen 5)")
for ($i = 0; $i -lt 4; $i++) {
    $x = $i * 160 + 8
    $g.DrawString($labels[$i], $font, $brushShadow, $x + 1, 9)
    $g.DrawString($labels[$i], $font, $brushText, $x, 8)
    
    $g.DrawString($labels[$i], $font, $brushShadow, $x + 1, 169)
    $g.DrawString($labels[$i], $font, $brushText, $x, 168)
}

$g.Dispose()
$fNorm.Dispose(); $fShin.Dispose(); $bNorm.Dispose(); $bShin.Dispose()

$outPath = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_complete_verification_sheet.png"
$sheet.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$sheet.Dispose()

Write-Host "Verification sheet saved to $outPath"
