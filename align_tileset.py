import cv2
import numpy as np
import math
import os

def align_tileset(input_path, output_path):
    img = cv2.imread(input_path, cv2.IMREAD_UNCHANGED)
    alpha = img[:, :, 3]

    # Extract contours directly from the alpha channel
    contours, _ = cv2.findContours(alpha, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    bounding_boxes = [cv2.boundingRect(c) for c in contours]

    # Filter small noise
    filtered_boxes = [box for box in bounding_boxes if box[2] > 2 and box[3] > 2]

    # Sort top-to-bottom, then left-to-right
    filtered_boxes.sort(key=lambda b: (b[1], b[0]))

    print(f"Found {len(filtered_boxes)} sprites.")

    output_width = 256
    GRID_SIZE = 32
    output_image_data = []

    current_y = 0
    current_x = 0
    row_height = 0

    for (x, y, w, h) in filtered_boxes:
        blocks_wide = math.ceil(w / float(GRID_SIZE))
        blocks_high = math.ceil(h / float(GRID_SIZE))

        needed_width = blocks_wide * GRID_SIZE
        needed_height = blocks_high * GRID_SIZE

        if current_x + needed_width > output_width:
            current_x = 0
            current_y += row_height
            row_height = 0

        sprite_crop = img[y:y+h, x:x+w]

        # Place bottom-centered in its allocated blocks
        canvas = np.zeros((needed_height, needed_width, 4), dtype=np.uint8)

        offset_x = (needed_width - w) // 2
        offset_y = needed_height - h

        canvas[offset_y:offset_y+h, offset_x:offset_x+w] = sprite_crop

        output_image_data.append({
            'img': canvas,
            'x': current_x,
            'y': current_y,
            'w': needed_width,
            'h': needed_height
        })

        current_x += needed_width
        row_height = max(row_height, needed_height)

    final_height = current_y + row_height
    final_image = np.zeros((final_height, output_width, 4), dtype=np.uint8)

    for item in output_image_data:
        final_image[item['y']:item['y']+item['h'], item['x']:item['x']+item['w']] = item['img']

    cv2.imwrite(output_path, final_image)
    print(f"Saved {output_path} ({output_width}x{final_height})")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python align_tileset.py <input_image.png> <output_image.png>")
    else:
        align_tileset(sys.argv[1], sys.argv[2])
