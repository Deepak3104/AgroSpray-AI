from __future__ import annotations

import argparse
import json
import shutil
from collections import defaultdict
from pathlib import Path

from training.data_prep.catalog import canonicalize_class_label, find_dataset_spec, normalize_component
from training.data_prep.utils import (
    FileRecord,
    count_images,
    ensure_dir,
    iter_image_files,
    save_json,
    save_standardized_image,
    sha256_file,
    dataset_statistics,
)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = PROJECT_ROOT / "dataset_sources"
MERGED_ROOT = PROJECT_ROOT / "dataset_merged"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Merge multiple agricultural datasets into one canonical structure.")
    parser.add_argument("--source-root", type=Path, default=SOURCE_ROOT)
    parser.add_argument("--output-root", type=Path, default=MERGED_ROOT)
    parser.add_argument("--metadata", type=Path, default=PROJECT_ROOT / "output" / "dataset_manifest.json")
    parser.add_argument("--target-size", type=int, default=224)
    return parser.parse_args()


def _detect_dataset_name(source_dir: Path) -> str:
    spec = find_dataset_spec(source_dir.name)
    if spec:
        return spec.name
    return source_dir.name


def _discover_label_from_parent(file_path: Path, source_root: Path) -> str:
    relative_parts = file_path.relative_to(source_root).parts
    if len(relative_parts) >= 2:
        return relative_parts[-2]
    return file_path.parent.name


def main() -> None:
    args = parse_args()
    ensure_dir(args.output_root)

    seen_hashes: set[str] = set()
    label_counts: dict[str, int] = defaultdict(int)
    manifest_records: list[dict] = []

    source_dirs = [path for path in args.source_root.iterdir() if path.is_dir()] if args.source_root.exists() else []
    for source_dir in source_dirs:
        dataset_name = _detect_dataset_name(source_dir)
        spec = find_dataset_spec(dataset_name)
        default_crop = spec.default_crop if spec else None

        for image_path in iter_image_files(source_dir):
            image_hash = sha256_file(image_path)
            if image_hash in seen_hashes:
                continue
            seen_hashes.add(image_hash)

            raw_label = _discover_label_from_parent(image_path, source_dir)
            canonical_label = canonicalize_class_label(raw_label, default_crop=default_crop)
            label_dir = ensure_dir(args.output_root / normalize_component(canonical_label))
            destination = label_dir / f"{image_path.stem}_{image_hash[:10]}.jpg"
            save_standardized_image(image_path, destination, size=(args.target_size, args.target_size))
            label_counts[canonical_label] += 1
            manifest_records.append(
                {
                    "source_dataset": dataset_name,
                    "source_path": str(image_path),
                    "destination_path": str(destination),
                    "label": canonical_label,
                    "sha256": image_hash,
                }
            )

    save_json(args.output_root / "manifest.json", manifest_records)
    save_json(args.output_root / "class_counts.json", dict(sorted(label_counts.items())))
    save_json(args.metadata, {
        "source_root": str(args.source_root),
        "merged_root": str(args.output_root),
        "statistics": dataset_statistics(args.output_root),
        "duplicate_images_removed": max(0, sum(count_images(args.output_root).values()) - len(manifest_records)),
    })
    print(f"Merged dataset written to {args.output_root}")
    print(f"Class count: {len(label_counts)}")


if __name__ == "__main__":
    main()
