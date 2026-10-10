Add-Type -AssemblyName System.Drawing

$src = New-Object System.Drawing.Bitmap("Graphics/Pokemon/Front shiny/KINDRAME.png")
$w = 320
$h = 160
$composite = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($composite)

$brushDark = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 34, 34, 38))
$g.FillRectangle($brushDark, 0, 0, 160, 160)

$brushGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 116, 184, 104))
$g.FillRectangle($brushGreen, 160, 0, 160, 160)

$g.DrawImage($src, 0, 0, 160, 160)
$g.DrawImage($src, 160, 0, 160, 160)

$g.Dispose()
$src.Dispose()

$out = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b\kindrame_shiny_check_bg.png"
$composite.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$composite.Dispose()
Write-Host "Saved shiny verification composite to $out"
