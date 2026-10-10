Add-Type -AssemblyName System.Drawing

function MeasureSprite($path, $name) {
    $bmp = New-Object System.Drawing.Bitmap($path)
    $minX = $bmp.Width; $maxX = 0; $minY = $bmp.Height; $maxY = 0
    for ($y = 0; $y -lt $bmp.Height; $y++) {
        for ($x = 0; $x -lt $bmp.Width; $x++) {
            $p = $bmp.GetPixel($x, $y)
            if ($p.A -gt 20) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $w = $maxX - $minX + 1
    $h = $maxY - $minY + 1
    Write-Host "$name : Width=$w, Height=$h, X=[$minX, $maxX], Y=[$minY, $maxY], BottomY=$maxY"
    $bmp.Dispose()
}

MeasureSprite "Graphics/Pokemon/Back/ABSOL.png" "Absol Back"
MeasureSprite "Graphics/Pokemon/Back/COBALION.png" "Cobalion Back"
MeasureSprite "Graphics/Pokemon/Back/SUICUNE.png" "Suicune Back"
MeasureSprite "Graphics/Pokemon/Back/ZIGGS.png" "Ziggs Back"
