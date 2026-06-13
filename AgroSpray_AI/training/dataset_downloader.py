from __future__ import annotations

import argparse
import json
import shutil
import tarfile
import urllib.request
import zipfile
from pathlib import Path
from typing import Iterable

from training.data_prep.catalog import DATASET_SPECS, find_dataset_spec, normalize_component
from training.data_prep.utils import ensure_dir, is_image_file

DEFAULT_OUTPUT_ROOT = Path(__file__).resolve().parents[1] / "dataset_sources"

# These are placeholder sources because public dataset URLs vary by mirror and license.
# Users can point each dataset to a local path, direct URL, or archive file.


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Download or register agricultural datasets.")
    parser.add_argument("--manifest", type=Path, default=Path(__file__).resolve().parents[1] / "datasets_manifest.json")
    parser.add_argument("--output-root", type=Path, default=DEFAULT_OUTPUT_ROOT)
    return parser.parse_args()


def _extract_archive(archive_path: Path, destination: Path) -> Path:
    ensure_dir(destination)
    if archive_path.suffix.lower() == ".zip":
        with zipfile.ZipFile(archive_path) as handle:
            handle.extractall(destination)
    elif archive_path.suffix.lower() in {".tar", ".gz", ".bz2", ".xz", ".tgz", ".tbz2"}:
        with tarfile.open(archive_path) as handle:
            handle.extractall(destination)
    else:
        raise ValueError(f"Unsupported archive type: {archive_path}")
    return destination


def _download_file(url: str, destination: Path) -> Path:
    ensure_dir(destination.parent)
    urllib.request.urlretrieve(url, destination)
    return destination


def _iter_sources(manifest_path: Path) -> Iterable[dict]:
    if not manifest_path.exists():
        raise FileNotFoundError(
            f"Dataset manifest not found at {manifest_path}. Create one with local paths or URLs."
        )
    payload = json.loads(manifest_path.read_text(encoding="utf-8"))
    if isinstance(payload, dict):
        payload = payload.get("datasets", [])
    return payload


def main() -> None:
    args = parse_args()
    ensure_dir(args.output_root)

    for item in _iter_sources(args.manifest):
        name = item.get("name") or item.get("dataset")
        if not name:
            continue
        spec = find_dataset_spec(name)
        dataset_dir = ensure_dir(args.output_root / normalize_component(name))
        source = item.get("source") or item.get("path") or item.get("url")

        if source is None:
            print(f"Skipping {name}: no source provided in manifest.")
            continue

        source_path = Path(str(source))
        if source_path.exists():
            if source_path.is_file() and source_path.suffix.lower() in {".zip", ".tar", ".gz", ".bz2", ".xz", ".tgz", ".tbz2"}:
                _extract_archive(source_path, dataset_dir)
            elif source_path.is_dir():
                shutil.copytree(source_path, dataset_dir, dirs_exist_ok=True)
            else:
                shutil.copy2(source_path, dataset_dir / source_path.name)
            print(f"Registered local dataset: {name} -> {dataset_dir}")
            continue

        if str(source).startswith(("http://", "https://")):
            archive_path = dataset_dir / Path(str(source)).name
            _download_file(str(source), archive_path)
            if is_image_file(archive_path):
                print(f"Downloaded single image for {name}: {archive_path}")
            else:
                _extract_archive(archive_path, dataset_dir)
                print(f"Downloaded and extracted {name} to {dataset_dir}")
            continue

        print(f"Skipping {name}: source not found ({source}).")

    print("Dataset download/registration completed.")


if __name__ == "__main__":
    main()
