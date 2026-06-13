from __future__ import annotations

import argparse
import random
import shutil
from collections import defaultdict
from pathlib import Path

from training.data_prep.utils import (
    ensure_dir,
    iter_image_files,
    save_json,
    save_standardized_image,
    dataset_statistics,
)

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_INPUT_ROOT = PROJECT_ROOT / "dataset_augmented"
DEFAULT_OUTPUT_ROOT = PROJECT_ROOT / "dataset"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Split the prepared dataset into train/validation/test folders.")
    parser.add_argument("--input-root", type=Path, default=DEFAULT_INPUT_ROOT)
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT_ROOT)
    parser.add_argument("--train-ratio", type=float, default=0.7)
    parser.add_argument("--validation-ratio", type=float, default=0.2)
    parser.add_argument("--test-ratio", type=float, default=0.1)
    parser.add_argument("--seed", type=int, default=42)
    return parser.parse_args()


def _copy_split(items: list[Path], destination_dir: Path) -> None:
    ensure_dir(destination_dir)
    for image_path in items:
        destination = destination_dir / image_path.name
        save_standardized_image(image_path, destination)


def main() -> None:
    args = parse_args()
    if round(args.train_ratio + args.validation_ratio + args.test_ratio, 6) != 1.0:
        raise ValueError("Train, validation, and test ratios must add up to 1.0")

    rng = random.Random(args.seed)
    split_root = args.output_root
    train_root = ensure_dir(split_root / "train")
    validation_root = ensure_dir(split_root / "validation")
    test_root = ensure_dir(split_root / "test")

    class_groups: dict[str, list[Path]] = defaultdict(list)
    for image_path in iter_image_files(args.input_root):
        class_groups[image_path.parent.name].append(image_path)

    manifest = {
        "train": {},
        "validation": {},
        "test": {},
    }

    for class_name, items in class_groups.items():
        rng.shuffle(items)
        total = len(items)
        train_end = int(total * args.train_ratio)
        validation_end = train_end + int(total * args.validation_ratio)

        train_items = items[:train_end]
        validation_items = items[train_end:validation_end]
        test_items = items[validation_end:]

        _copy_split(train_items, train_root / class_name)
        _copy_split(validation_items, validation_root / class_name)
        _copy_split(test_items, test_root / class_name)

        manifest["train"][class_name] = len(train_items)
        manifest["validation"][class_name] = len(validation_items)
        manifest["test"][class_name] = len(test_items)

    save_json(split_root / "split_manifest.json", manifest)
    save_json(split_root / "statistics.json", dataset_statistics(split_root))
    print(f"Prepared dataset written to {split_root}")


if __name__ == "__main__":
    main()
