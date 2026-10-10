Add-Type -ReferencedAssemblies "System.Drawing" -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class BackSpriteProcessor {
    public static void ProcessBackSprite(string srcPath, string outPath, Point[] holeSeeds) {
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
                return (r >= 228 && g >= 228 && b >= 228);
            };

            // Seed outer borders
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

            // Seed interior enclosed holes
            if (holeSeeds != null) {
                foreach (Point p in holeSeeds) {
                    if (p.X >= 0 && p.X < w && p.Y >= 0 && p.Y < h) {
                        int pos = p.Y * w + p.X;
                        if (!isBg[pos] && isWhite(pos * 4)) {
                            isBg[pos] = true;
                            q.Enqueue(pos);
                        }
                    }
                }
            }

            // BFS Flood Fill
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

            // Copy non-background pixels to cutout
            byte[] outBuffer = new byte[cutData.Stride * h];
            int minX = w, maxX = 0, minY = h, maxY = 0;

            for (int i = 0; i < w * h; i++) {
                int bIdx = i * 4;
                if (!isBg[i]) {
                    outBuffer[bIdx] = buffer[bIdx];         // B
                    outBuffer[bIdx + 1] = buffer[bIdx + 1]; // G
                    outBuffer[bIdx + 2] = buffer[bIdx + 2]; // R
                    outBuffer[bIdx + 3] = 255;              // A

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

            // Step 1: Downscale to native DS resolution (80x80 canvas)
            // Back sprites for quadrupeds (Absol: 142px at 160x160 -> 71px at 80x80)
            int nativeCanvas = 80;
            int targetNativeH = 71;
            float aspect = (float)bw / bh;
            int targetNativeW = (int)Math.Round(targetNativeH * aspect);
            if (targetNativeW > 78) {
                targetNativeW = 78;
                targetNativeH = (int)Math.Round(targetNativeW / aspect);
            }

            Bitmap nativeBmp = new Bitmap(nativeCanvas, nativeCanvas, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(nativeBmp)) {
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;

                // Align to bottom-center of the 80x80 canvas (Bottom = 79)
                int drawX = (nativeCanvas - targetNativeW) / 2;
                int drawY = nativeCanvas - targetNativeH;

                g.DrawImage(cutout, new Rectangle(drawX, drawY, targetNativeW, targetNativeH), cropRect, GraphicsUnit.Pixel);
            }

            // Outline hardening on native grid: darken semi-transparent edges and outline pixels
            for (int ny = 0; ny < nativeCanvas; ny++) {
                for (int nx = 0; nx < nativeCanvas; nx++) {
                    Color c = nativeBmp.GetPixel(nx, ny);
                    if (c.A > 0 && c.A < 180) {
                        nativeBmp.SetPixel(nx, ny, Color.FromArgb(0, 0, 0, 0));
                    } else if (c.A >= 180) {
                        // Fully opaque
                        // If near dark outline, solidify to punchy dark
                        int brightness = (int)(c.R * 0.299 + c.G * 0.587 + c.B * 0.114);
                        if (brightness < 60) {
                            nativeBmp.SetPixel(nx, ny, Color.FromArgb(255, (int)(c.R * 0.7), (int)(c.G * 0.7), (int)(c.B * 0.7)));
                        } else {
                            nativeBmp.SetPixel(nx, ny, Color.FromArgb(255, c.R, c.G, c.B));
                        }
                    }
                }
            }

            // Step 2: 2x Integer Upscale with Nearest-Neighbor to 160x160
            Bitmap finalBmp = new Bitmap(160, 160, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(finalBmp)) {
                g.InterpolationMode = InterpolationMode.NearestNeighbor;
                g.PixelOffsetMode = PixelOffsetMode.Half;
                g.SmoothingMode = SmoothingMode.None;

                g.DrawImage(nativeBmp, new Rectangle(0, 0, 160, 160), 0, 0, nativeCanvas, nativeCanvas, GraphicsUnit.Pixel);
            }

            finalBmp.Save(outPath, ImageFormat.Png);

            finalBmp.Dispose();
            nativeBmp.Dispose();
            cutout.Dispose();
        }
    }
}
'@

$brainDir = "C:\Users\Mon POc\.gemini\antigravity\brain\829cfc1b-7134-4156-b9ea-bafe0bbd893b"
$gameDir = "c:\Users\Mon POc\3D Objects\Pokemon Essentials v21.1 2023-07-30"

$seeds = @(
    [System.Drawing.Point]::new(274, 218),
    [System.Drawing.Point]::new(814, 242),
    [System.Drawing.Point]::new(582, 286),
    [System.Drawing.Point]::new(416, 430)
)

Write-Host "Processing Normal Back Sprite..."
[BackSpriteProcessor]::ProcessBackSprite(
    "$brainDir\kindrame_back_shoulder_1791584640163.jpg",
    "$gameDir\Graphics\Pokemon\Back\KINDRAME.png",
    $seeds
)

# Also save copy to brainDir for easy inspection
Copy-Item "$gameDir\Graphics\Pokemon\Back\KINDRAME.png" "$brainDir\kindrame_back_pixelart_2x.png" -Force

Write-Host "Processing Shiny Back Sprite..."
[BackSpriteProcessor]::ProcessBackSprite(
    "$brainDir\kindrame_back_shiny_new_1791584678321.jpg",
    "$gameDir\Graphics\Pokemon\Back shiny\KINDRAME.png",
    $seeds
)

Copy-Item "$gameDir\Graphics\Pokemon\Back shiny\KINDRAME.png" "$brainDir\kindrame_back_shiny_pixelart_2x.png" -Force

Write-Host "Both Back sprites successfully generated, processed and installed!"
