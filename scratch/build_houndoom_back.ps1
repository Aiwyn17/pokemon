Add-Type -ReferencedAssemblies "System.Drawing" -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class HoundoomBackProcessor {
    public static void ProcessSprites(string srcPath, string outNormPath, string outShinyPath) {
        using (Bitmap src = new Bitmap(srcPath)) {
            int w = src.Width;
            int h = src.Height;
            Bitmap cutout = new Bitmap(w, h, PixelFormat.Format32bppArgb);

            BitmapData srcData = src.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            BitmapData cutData = cutout.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

            byte[] buffer = new byte[srcData.Stride * h];
            Marshal.Copy(srcData.Scan0, buffer, 0, buffer.Length);
            src.UnlockBits(srcData);

            bool[] isBg = new bool[w * h];
            Queue<int> q = new Queue<int>(w * h / 2);

            Func<int, bool> isWhite = (int idx) => {
                byte b = buffer[idx];
                byte g = buffer[idx + 1];
                byte r = buffer[idx + 2];
                return (r >= 235 && g >= 235 && b >= 235);
            };

            // Outer borders
            for (int x = 0; x < w; x++) {
                int topPos = x;
                if (isWhite(topPos * 4)) { isBg[topPos] = true; q.Enqueue(topPos); }
                int botPos = (h - 1) * w + x;
                if (isWhite(botPos * 4)) { isBg[botPos] = true; q.Enqueue(botPos); }
            }
            for (int y = 0; y < h; y++) {
                int leftPos = y * w;
                if (!isBg[leftPos] && isWhite(leftPos * 4)) { isBg[leftPos] = true; q.Enqueue(leftPos); }
                int rightPos = y * w + (w - 1);
                if (!isBg[rightPos] && isWhite(rightPos * 4)) { isBg[rightPos] = true; q.Enqueue(rightPos); }
            }

            // Inner hole seeds
            Point[] seeds = {
                new Point(506, 108),
                new Point(192, 478),
                new Point(750, 870),
                new Point(876, 824)
            };
            foreach (Point p in seeds) {
                int pos = p.Y * w + p.X;
                if (pos >= 0 && pos < w * h && !isBg[pos] && isWhite(pos * 4)) {
                    isBg[pos] = true;
                    q.Enqueue(pos);
                }
            }

            // BFS
            int[] dx = { -1, 1, 0, 0 };
            int[] dy = { 0, 0, -1, 1 };
            while (q.Count > 0) {
                int curr = q.Dequeue();
                int cx = curr % w;
                int cy = curr / w;

                for (int i = 0; i < 4; i++) {
                    int nx = cx + dx[i];
                    int ny = cy + dy[i];
                    if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
                        int npos = ny * w + nx;
                        if (!isBg[npos] && isWhite(npos * 4)) {
                            isBg[npos] = true;
                            q.Enqueue(npos);
                        }
                    }
                }
            }

            byte[] outBuffer = new byte[cutData.Stride * h];
            int minX = w, maxX = 0, minY = h, maxY = 0;

            for (int i = 0; i < w * h; i++) {
                int bIdx = i * 4;
                if (!isBg[i]) {
                    outBuffer[bIdx] = buffer[bIdx];
                    outBuffer[bIdx + 1] = buffer[bIdx + 1];
                    outBuffer[bIdx + 2] = buffer[bIdx + 2];
                    outBuffer[bIdx + 3] = 255;

                    int cx = i % w;
                    int cy = i / w;
                    if (cx < minX) minX = cx;
                    if (cx > maxX) maxX = cx;
                    if (cy < minY) minY = cy;
                    if (cy > maxY) maxY = cy;
                }
            }
            Marshal.Copy(outBuffer, 0, cutData.Scan0, outBuffer.Length);
            cutout.UnlockBits(cutData);

            int bw = maxX - minX + 1;
            int bh = maxY - minY + 1;
            Rectangle cropRect = new Rectangle(minX, minY, bw, bh);

            // Step 1: Native 80x80 canvas (Absol/Houndoom back size: ~72px high)
            int nativeCanvas = 80;
            int targetNativeH = 72;
            float aspect = (float)bw / bh;
            int targetNativeW = (int)Math.Round(targetNativeH * aspect);
            if (targetNativeW > 78) {
                targetNativeW = 78;
                targetNativeH = (int)Math.Round(targetNativeW / aspect);
            }

            Bitmap nativeNorm = new Bitmap(nativeCanvas, nativeCanvas, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(nativeNorm)) {
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;

                int drawX = (nativeCanvas - targetNativeW) / 2;
                int drawY = nativeCanvas - targetNativeH;
                g.DrawImage(cutout, new Rectangle(drawX, drawY, targetNativeW, targetNativeH), cropRect, GraphicsUnit.Pixel);
            }

            // Outline hardening
            for (int ny = 0; ny < nativeCanvas; ny++) {
                for (int nx = 0; nx < nativeCanvas; nx++) {
                    Color c = nativeNorm.GetPixel(nx, ny);
                    if (c.A > 0 && c.A < 180) {
                        nativeNorm.SetPixel(nx, ny, Color.FromArgb(0, 0, 0, 0));
                    } else if (c.A >= 180) {
                        int brightness = (int)(c.R * 0.299 + c.G * 0.587 + c.B * 0.114);
                        if (brightness < 55) {
                            nativeNorm.SetPixel(nx, ny, Color.FromArgb(255, (int)(c.R * 0.65), (int)(c.G * 0.65), (int)(c.B * 0.65)));
                        } else {
                            nativeNorm.SetPixel(nx, ny, Color.FromArgb(255, c.R, c.G, c.B));
                        }
                    }
                }
            }

            // Step 2: 2x Integer Upscale with Nearest-Neighbor to 160x160 (Normal)
            Bitmap finalNorm = new Bitmap(160, 160, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(finalNorm)) {
                g.InterpolationMode = InterpolationMode.NearestNeighbor;
                g.PixelOffsetMode = PixelOffsetMode.Half;
                g.SmoothingMode = SmoothingMode.None;
                g.DrawImage(nativeNorm, new Rectangle(0, 0, 160, 160), 0, 0, nativeCanvas, nativeCanvas, GraphicsUnit.Pixel);
            }
            finalNorm.Save(outNormPath, ImageFormat.Png);

            // Step 3: Create Shiny version by palette transformation on native grid
            Bitmap nativeShiny = new Bitmap(nativeCanvas, nativeCanvas, PixelFormat.Format32bppArgb);
            for (int ny = 0; ny < nativeCanvas; ny++) {
                for (int nx = 0; nx < nativeCanvas; nx++) {
                    Color c = nativeNorm.GetPixel(nx, ny);
                    if (c.A == 0) {
                        nativeShiny.SetPixel(nx, ny, Color.FromArgb(0, 0, 0, 0));
                        continue;
                    }

                    int r = c.R, g = c.G, b = c.B;
                    int brightness = (int)(r * 0.299 + g * 0.587 + b * 0.114);

                    // 1. Dark outline (very dark) -> keep dark
                    if (brightness < 35) {
                        nativeShiny.SetPixel(nx, ny, Color.FromArgb(255, 18, 18, 24));
                        continue;
                    }

                    // 2. Cyan eyes / runes (high green & blue, low red)
                    if (b > 150 && g > 130 && r < 100) {
                        // In shiny, eyes/runes glow golden amber
                        nativeShiny.SetPixel(nx, ny, Color.FromArgb(255, 255, 215, 55));
                        continue;
                    }

                    // 3. Wolf's dark smoke body (darker navy: r < 90, g < 95, b < 130, brightness < 110)
                    // -> Remap to shiny luminous moonlit cyan/lavender mist
                    if (brightness < 110 && b >= r && r < 95) {
                        float t = (float)brightness / 110f;
                        int sr = (int)(155 + t * 75);
                        int sg = (int)(195 + t * 55);
                        int sb = 255;
                        nativeShiny.SetPixel(nx, ny, Color.FromArgb(255, sr, sg, sb));
                        continue;
                    }

                    // 4. Lamb's white/light blue wool (bright fleece: brightness >= 130 and b >= 140)
                    // -> Remap to shiny obsidian midnight black wool
                    if (brightness >= 120 && b >= 130 && Math.Abs(r - g) < 40) {
                        float t = (float)(brightness - 120) / 135f;
                        int sr = (int)(25 + t * 35);
                        int sg = (int)(25 + t * 35);
                        int sb = (int)(35 + t * 45);
                        nativeShiny.SetPixel(nx, ny, Color.FromArgb(255, sr, sg, sb));
                        continue;
                    }

                    // 5. Wolf white mask (top-right area, bright white r,g,b > 170)
                    if (r > 170 && g > 170 && b > 180 && ny < 40 && nx > 40) {
                        // Remap to shiny obsidian skull mask
                        int sr = 35 + (255 - r) / 4;
                        int sg = 35 + (255 - g) / 4;
                        int sb = 45 + (255 - b) / 4;
                        nativeShiny.SetPixel(nx, ny, Color.FromArgb(255, sr, sg, sb));
                        continue;
                    }

                    // 6. Lamb horns / dark markings (medium dark: brightness between 35 and 90)
                    // -> Remap to golden horns / runes
                    if (brightness >= 35 && brightness < 90) {
                        float t = (float)(brightness - 35) / 55f;
                        int sr = (int)(190 + t * 60);
                        int sg = (int)(150 + t * 55);
                        int sb = (int)(40 + t * 40);
                        nativeShiny.SetPixel(nx, ny, Color.FromArgb(255, sr, sg, sb));
                        continue;
                    }

                    // Default fallback: keep original
                    nativeShiny.SetPixel(nx, ny, c);
                }
            }

            // Step 4: 2x Integer Upscale for Shiny
            Bitmap finalShiny = new Bitmap(160, 160, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(finalShiny)) {
                g.InterpolationMode = InterpolationMode.NearestNeighbor;
                g.PixelOffsetMode = PixelOffsetMode.Half;
                g.SmoothingMode = SmoothingMode.None;
                g.DrawImage(nativeShiny, new Rectangle(0, 0, 160, 160), 0, 0, nativeCanvas, nativeCanvas, GraphicsUnit.Pixel);
            }
            finalShiny.Save(outShinyPath, ImageFormat.Png);

            finalShiny.Dispose();
            nativeShiny.Dispose();
            finalNorm.Dispose();
            nativeNorm.Dispose();
            cutout.Dispose();
        }
    }
}
'@

$brainDir = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b"
$gameDir = "c:\Users\Mon POc\3D Objects\Pokemon Essentials v21.1 2023-07-30"

$src = "$brainDir\kindrame_back_perfect_houndoom_1791585386206.jpg"
$outNorm = "$gameDir\Graphics\Pokemon\Back\KINDRAME.png"
$outShiny = "$gameDir\Graphics\Pokemon\Back shiny\KINDRAME.png"

Write-Host "Processing Houndoom-style Back sprites..."
[HoundoomBackProcessor]::ProcessSprites($src, $outNorm, $outShiny)

Copy-Item $outNorm "$brainDir\kindrame_back_houndoom_pixelart.png" -Force
Copy-Item $outShiny "$brainDir\kindrame_back_houndoom_shiny_pixelart.png" -Force

Write-Host "Completed successfully!"
