from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

from training.data_prep.utils import ensure_dir

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the full AgroSpray dataset preparation pipeline.")
    parser.add_argument("--manifest", type=Path, default=PROJECT_ROOT / "datasets_manifest.json")
    parser.add_argument("--source-root", type=Path, default=PROJECT_ROOT / "dataset_sources")
    parser.add_argument("--merged-root", type=Path, default=PROJECT_ROOT / "dataset_merged")
    parser.add_argument("--clean-root", type=Path, default=PROJECT_ROOT / "dataset_cleaned")
    parser.add_argument("--augmented-root", type=Path, default=PROJECT_ROOT / "dataset_augmented")
    parser.add_argument("--output-root", type=Path, default=PROJECT_ROOT / "dataset")
    return parser.parse_args()


def _run(module: str, *args: str) -> None:
    command = [sys.executable, "-m", module, *args]
    subprocess.run(command, check=True)


def main() -> None:
    args = parse_args()
    ensure_dir(args.source_root)
    ensure_dir(args.merged_root)
    ensure_dir(args.clean_root)
    ensure_dir(args.augmented_root)
    ensure_dir(args.output_root)

    _run("training.dataset_downloader", "--manifest", str(args.manifest), "--output-root", str(args.source_root))
    _run("training.dataset_merger", "--source-root", str(args.source_root), "--output-root", str(args.merged_root))
    _run("training.dataset_cleaner", "--input-root", str(args.merged_root), "--output-root", str(args.clean_root))
    _run("training.dataset_augmentation", "--input-root", str(args.clean_root), "--output-root", str(args.augmented_root))
    _run("training.dataset_splitter", "--input-root", str(args.augmented_root), "--output-root", str(args.output_root))


if __name__ == "__main__":
    main()
