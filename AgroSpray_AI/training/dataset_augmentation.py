from __future__ import annotations

import argparse
import random
from collections import defaultdict
from pathlib import Path

from training.data_prep.utils import (
    augment_image,
    dataset_statistics,
    ensure_dir,
    iter_image_files,
    open_image,
    save_image,
    save_json,
)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT_ROOT = PROJECT_ROOT / "dataset_cleaned"
DEFAULT_OUTPUT_ROOT = PROJECT_ROOT / "dataset_augmented"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Augment underrepresented crop disease classes.")
    parser.add_argument("--input-root", type=Path, default=DEFAULT_INPUT_ROOT)
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT_ROOT)
    parser.add_argument("--target-count", type=int, default=0, help="Minimum samples per class. 0 uses the majority class count.")
    parser.add_argument("--seed", type=int, default=42)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    rng = random.Random(args.seed)
    ensure_dir(args.output_root)

    class_files: dict[str, list[Path]] = defaultdict(list)
    for image_path in iter_image_files(args.input_root):
        class_files[image_path.parent.name].append(image_path)

    class_counts = {class_name: len(files) for class_name, files in class_files.items()}
    if not class_counts:
        raise FileNotFoundError(f"No images found in {args.input_root}")

    target_count = args.target_count or max(class_counts.values())
    augmentation_manifest: list[dict] = []

    for class_name, files in class_files.items():
        destination_dir = ensure_dir(args.output_root / class_name)
        for image_path in files:
            destination = destination_dir / image_path.name
            save_image(open_image(image_path), destination)
            augmentation_manifest.append(
                {
                    "source_path": str(image_path),
                    "destination_path": str(destination),
                    "label": class_name,
                    "type": "original",
                }
            )

        generated_count = 0
        while len(files) + generated_count < target_count:
            source = rng.choice(files)
            augmented = augment_image(open_image(source), rng)
            destination = destination_dir / f"aug_{generated_count:04d}_{source.stem}.jpg"
            save_image(augmented, destination)
            augmentation_manifest.append(
                {
                    "source_path": str(source),
                    "destination_path": str(destination),
                    "label": class_name,
                    "type": "augmented",
                }
            )
            generated_count += 1

    save_json(args.output_root / "augmentation_manifest.json", augmentation_manifest)
    save_json(args.output_root / "statistics.json", dataset_statistics(args.output_root))
    print(f"Augmented dataset written to {args.output_root}")
    print(f"Target class count: {target_count}")


if __name__ == "__main__":
    main()
