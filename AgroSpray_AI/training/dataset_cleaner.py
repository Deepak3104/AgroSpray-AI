from __future__ import annotations

import argparse
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageOps

from training.data_prep.catalog import canonicalize_class_label, normalize_component
from training.data_prep.utils import (
    augment_image,
    dataset_statistics,
    ensure_dir,
    iter_image_files,
    load_json,
    save_json,
    save_standardized_image,
    sha256_file,
)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT_ROOT = PROJECT_ROOT / "dataset_merged"
DEFAULT_OUTPUT_ROOT = PROJECT_ROOT / "dataset_cleaned"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Clean the merged AgroSpray dataset.")
    parser.add_argument("--input-root", type=Path, default=DEFAULT_INPUT_ROOT)
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT_ROOT)
    parser.add_argument("--target-size", type=int, default=224)
    return parser.parse_args()


def _class_name_from_path(path: Path) -> str:
    return path.parent.name


def main() -> None:
    args = parse_args()
    ensure_dir(args.output_root)

    seen_hashes: set[str] = set()
    cleaned_manifest: list[dict] = []
    class_counts: dict[str, int] = defaultdict(int)

    for image_path in iter_image_files(args.input_root):
        image_hash = sha256_file(image_path)
        if image_hash in seen_hashes:
            continue
        seen_hashes.add(image_hash)

        class_name = canonicalize_class_label(_class_name_from_path(image_path))
        destination_dir = ensure_dir(args.output_root / normalize_component(class_name))
        destination = destination_dir / f"{image_path.stem}_{image_hash[:10]}.jpg"
        save_standardized_image(image_path, destination, size=(args.target_size, args.target_size))
        class_counts[class_name] += 1
        cleaned_manifest.append(
            {
                "source_path": str(image_path),
                "destination_path": str(destination),
                "label": class_name,
                "sha256": image_hash,
            }
        )

    save_json(args.output_root / "cleaned_manifest.json", cleaned_manifest)
    save_json(args.output_root / "class_counts.json", dict(sorted(class_counts.items())))
    save_json(args.output_root / "statistics.json", dataset_statistics(args.output_root))
    print(f"Cleaned dataset written to {args.output_root}")


if __name__ == "__main__":
    main()
