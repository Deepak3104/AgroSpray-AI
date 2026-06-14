from __future__ import annotations

import json
import os
from pathlib import Path
import random
from PIL import Image, ImageDraw

def create_mock_leaf_image(class_name: str, output_path: Path) -> None:
    # 224x224 image
    img = Image.new("RGB", (224, 224), color=(80, 55, 35))  # Earthy soil background
    draw = ImageDraw.Draw(img)
    
    # Draw a leaf shape (green ellipse)
    # Forest Green color for leaf: (34, 139, 34)
    leaf_color = (40, 150, 45)
    draw.ellipse([30, 40, 194, 184], fill=leaf_color, outline=(25, 100, 30), width=2)
    
    # Draw veins
    draw.line([112, 40, 112, 184], fill=(25, 100, 30), width=2)
    for y in range(60, 160, 20):
        # Left vein
        draw.line([112, y, 70, y - 15], fill=(25, 100, 30), width=1)
        # Right vein
        draw.line([112, y, 154, y - 15], fill=(25, 100, 30), width=1)
        
    # Apply disease marks based on class name
    cls_lower = class_name.lower()
    
    if "healthy" in cls_lower:
        # Healthy leaf: clean and green, maybe minor variation
        pass
        
    elif "early_blight" in cls_lower or "early blight" in cls_lower:
        # Early Blight: target-like circular concentric brown spots with yellow halos
        # Add 3-5 spots
        for _ in range(random.randint(3, 5)):
            cx = random.randint(60, 160)
            cy = random.randint(60, 160)
            # Yellow halo
            draw.ellipse([cx-12, cy-12, cx+12, cy+12], fill=(210, 210, 50))
            # Concentric brown rings
            draw.ellipse([cx-8, cy-8, cx+8, cy+8], fill=(100, 60, 20))
            draw.ellipse([cx-4, cy-4, cx+4, cy+4], fill=(70, 40, 10))
            
    elif "late_blight" in cls_lower or "late blight" in cls_lower:
        # Late Blight: large, dark, water-soaked patches that turn brown/black
        for _ in range(random.randint(2, 3)):
            cx = random.randint(50, 170)
            cy = random.randint(50, 170)
            r = random.randint(15, 25)
            # Pale yellow edge
            draw.ellipse([cx-r-2, cy-r-2, cx+r+2, cy+r+2], fill=(180, 180, 90))
            # Dark greyish brown patch
            draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(50, 50, 50))
            
    elif "bacterial_spot" in cls_lower or "bacterial spot" in cls_lower:
        # Bacterial Spot: numerous small, angular, dark spots with yellow border
        for _ in range(random.randint(15, 25)):
            cx = random.randint(50, 170)
            cy = random.randint(50, 170)
            r = random.randint(2, 4)
            # Yellow halo
            draw.ellipse([cx-r-1, cy-r-1, cx+r+1, cy+r+1], fill=(220, 220, 40))
            # Black/dark brown spot
            draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(20, 20, 20))
            
    elif "leaf_mold" in cls_lower or "leaf mold" in cls_lower:
        # Leaf Mold: olive green or grey velvety mold patches
        for _ in range(random.randint(4, 6)):
            cx = random.randint(50, 170)
            cy = random.randint(50, 170)
            r = random.randint(10, 18)
            # Velvet mold look (pale yellowish-grey)
            draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(130, 140, 110))
            
    elif "septoria" in cls_lower:
        # Septoria Leaf Spot: small circular spots with dark brown margins and grey centers
        for _ in range(random.randint(8, 12)):
            cx = random.randint(50, 170)
            cy = random.randint(50, 170)
            r = random.randint(3, 6)
            # Dark border
            draw.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(80, 50, 30))
            # Grey center
            draw.ellipse([cx-r+1, cy-r+1, cx+r-1, cy+r-1], fill=(160, 160, 160))
            
    # Save the generated image
    img.save(output_path, "JPEG", quality=95)

def main() -> None:
    project_root = Path(__file__).resolve().parent
    mock_dir = project_root / "mock_raw_data" / "PlantVillage"
    mock_dir.mkdir(parents=True, exist_ok=True)
    
    classes = [
        "Tomato___Healthy",
        "Tomato___Early_blight",
        "Tomato___Late_blight",
        "Potato___Healthy",
        "Potato___Early_blight",
        "Potato___Late_blight",
        "Pepper___Healthy",
        "Pepper___Bacterial_spot",
        "Tomato___Leaf_Mold",
        "Tomato___Septoria_Leaf_Spot"
    ]
    
    print(f"Generating synthetic leaf dataset in {mock_dir}...")
    
    # We will generate 30 images per class for training/validation/testing splits
    images_per_class = 30
    for cls in classes:
        cls_dir = mock_dir / cls
        cls_dir.mkdir(parents=True, exist_ok=True)
        for i in range(images_per_class):
            img_path = cls_dir / f"leaf_{i:03d}.jpg"
            create_mock_leaf_image(cls, img_path)
            
    print("Synthetic images generated successfully.")
    
    # Now create datasets_manifest.json pointing to this mock data folder
    manifest_path = project_root / "datasets_manifest.json"
    manifest_data = {
        "datasets": [
            {
                "name": "PlantVillage",
                "source": str(mock_dir.resolve())
            }
        ]
    }
    
    manifest_path.write_text(json.dumps(manifest_data, indent=2), encoding="utf-8")
    print(f"Manifest written to {manifest_path}")

if __name__ == "__main__":
    main()
