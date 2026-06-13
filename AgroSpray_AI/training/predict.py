from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np

from training.common import (
    MODEL_PATH,
    OUTPUT_DIR,
    class_name_to_display_name,
    ensure_directories,
    load_class_names,
    load_model,
    preprocess_image,
    top_prediction,
)
from training.gradcam import save_gradcam_overlay


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Predict crop disease from a leaf image.")
    parser.add_argument("image", type=Path, help="Path to a test image.")
    parser.add_argument("--model", type=Path, default=MODEL_PATH)
    parser.add_argument("--save-heatmap", action="store_true", help="Save a Grad-CAM heatmap overlay.")
    return parser.parse_args()


def predict(image_path: Path, model_path: Path) -> tuple[str, float, int, list[str]]:
    model = load_model(model_path)
    class_names = load_class_names()
    image_tensor = preprocess_image(image_path)
    probabilities = model.predict(image_tensor, verbose=0)
    class_name, confidence, index = top_prediction(probabilities, class_names)
    return class_name, confidence, index, class_names


def main() -> None:
    args = parse_args()
    ensure_directories()
    class_name, confidence, index, class_names = predict(args.image, args.model)
    display_name = class_name_to_display_name(class_name)
    print(f"Disease Name: {display_name}")
    print(f"Confidence Score: {confidence * 100:.2f}%")

    if args.save_heatmap:
        model = load_model(args.model)
        heatmap_path = OUTPUT_DIR / "gradcam" / f"{args.image.stem}_heatmap.jpg"
        save_gradcam_overlay(model, args.image, heatmap_path, pred_index=index)
        print(f"Grad-CAM heatmap saved to {heatmap_path}")


if __name__ == "__main__":
    main()
