Add-Type -AssemblyName System.Drawing

$front = [System.Drawing.Bitmap]::FromFile("Graphics/Pokemon/Front shiny/KINDRAME.png")

function SampleArea($label, $x0, $x1, $y0, $y1) {
    Write-Host "`n=== $label ==="
    $colors = @{}
    for ($y = $y0; $y -le $y1; $y++) {
        for ($x = $x0; $x -le $x1; $x++) {
            $p = $front.GetPixel($x, $y)
            if ($p.A -gt 100) {
                $hex = "{0:x2}{1:x2}{2:x2}" -f $p.R, $p.G, $p.B
                $colors[$hex] = ($colors[$hex] + 1)
            }
        }
    }
    $sorted = $colors.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 6
    foreach ($s in $sorted) {
        Write-Host "#$($s.Key) (count $($s.Value))"
    }
}

# 1. Lamb's bone/ivory mask & horns (around x=55..75, y=35..65)
SampleArea "Lamb Bone Mask & Horns" 55 75 35 65

# 2. Lamb's black fleece (around x=60..100, y=90..130)
SampleArea "Lamb Black Fleece" 60 100 90 130

# 3. Wolf's lilac/cyan smoke plume (around x=30..60, y=15..40)
SampleArea "Wolf Lilac Smoke Plume" 30 60 15 40

# 4. Wolf's black head (around x=30..50, y=55..80)
SampleArea "Wolf Black Head" 30 50 55 80

# 5. Golden runes (around x=60..80, y=75..95)
SampleArea "Golden Runes" 60 80 75 95

$front.Dispose()
