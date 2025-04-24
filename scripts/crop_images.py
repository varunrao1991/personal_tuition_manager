import os
import argparse
from PIL import Image

def crop_image(img_path, crop_pixels_b, crop_pixels_t, dst_folder):
    img = Image.open(img_path)
    width, height = img.size
    cropped = img.crop((0, crop_pixels_t, width, height - crop_pixels_b))
    filename = os.path.basename(img_path)
    save_path = os.path.join(dst_folder, filename)
    cropped.save(save_path)

def process_folder(src_folder, dst_folder, crop_pixels_b, crop_pixels_t):
    if not os.path.exists(dst_folder):
        os.makedirs(dst_folder)
    for filename in os.listdir(src_folder):
        if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif', '.tiff')):
            img_path = os.path.join(src_folder, filename)
            try:
                crop_image(img_path, crop_pixels_b, crop_pixels_t, dst_folder)
                print(f"Cropped and saved: {filename}")
            except Exception as e:
                print(f"Failed to process {filename}: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Crop top and bottom of all images in a folder.")
    parser.add_argument("--src", required=True, help="Source folder with images.")
    parser.add_argument("--dst", required=True, help="Destination folder to save cropped images.")
    parser.add_argument("--b", type=int, required=True, help="Number of pixels to crop from bottom.")
    parser.add_argument("--t", type=int, required=True, help="Number of pixels to crop from top.")
    
    args = parser.parse_args()
    process_folder(args.src, args.dst, args.b, args.t)
