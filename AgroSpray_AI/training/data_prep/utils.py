from __future__ import annotations

import hashlib
import json
import random
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageEnhance, ImageOps

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".bmp", ".webp", ".tif", ".tiff"}
DEFAULT_IMAGE_SIZE = (224, 224)


@dataclass(frozen=True)
class FileRecord:
    source: Path
    label: str
    dataset_name: str


def ensure_dir(path: Path) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    return path


def is_image_file(path: Path) -> bool:
    return path.suffix.lower() in IMAGE_EXTENSIONS


def iter_image_files(root: Path) -> Iterable[Path]:
    if not root.exists():
        return []
    return (path for path in root.rglob("*") if path.is_file() and is_image_file(path))


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def average_hash(image: Image.Image, hash_size: int = 8) -> str:
    grayscale = ImageOps.grayscale(image).resize((hash_size, hash_size), Image.Resampling.LANCZOS)
    pixels = list(grayscale.getdata())
    average = sum(pixels) / len(pixels)
    bits = ["1" if pixel >= average else "0" for pixel in pixels]
    return "".join(bits)


def open_image(path: Path) -> Image.Image:
    return Image.open(path).convert("RGB")


def standardize_image(image: Image.Image, size: tuple[int, int] = DEFAULT_IMAGE_SIZE) -> Image.Image:
    return ImageOps.fit(image.convert("RGB"), size, method=Image.Resampling.LANCZOS)


def save_standardized_image(source: Path, destination: Path, size: tuple[int, int] = DEFAULT_IMAGE_SIZE) -> None:
    ensure_dir(destination.parent)
    image = open_image(source)
    standardized = standardize_image(image, size=size)
    standardized.save(destination, format="JPEG", quality=95, optimize=True)


def load_json(path: Path, default):
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def save_json(path: Path, payload) -> None:
    ensure_dir(path.parent)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def count_images(root: Path) -> dict[str, int]:
    counts: dict[str, int] = {}
    if not root.exists():
        return counts
    for class_dir in sorted(p for p in root.iterdir() if p.is_dir()):
        counts[class_dir.name] = sum(1 for _ in iter_image_files(class_dir))
    return counts


def dataset_statistics(root: Path) -> dict:
    counts = count_images(root)
    total_images = sum(counts.values())
    class_count = len(counts)
    max_count = max(counts.values()) if counts else 0
    min_count = min(counts.values()) if counts else 0
    imbalance_ratio = (max_count / min_count) if min_count else None
    return {
        "root": str(root),
        "total_images": total_images,
        "class_count": class_count,
        "class_distribution": counts,
        "max_images_per_class": max_count,
        "min_images_per_class": min_count,
        "imbalance_ratio": imbalance_ratio,
    }


def copy_with_new_name(source: Path, destination_dir: Path, prefix: str | None = None) -> Path:
    ensure_dir(destination_dir)
    suffix = source.suffix.lower() or ".jpg"
    stem = source.stem
    if prefix:
        stem = f"{prefix}_{stem}"
    destination = destination_dir / f"{stem}{suffix}"
    shutil.copy2(source, destination)
    return destination


def next_available_path(directory: Path, base_stem: str, suffix: str = ".jpg") -> Path:
    ensure_dir(directory)
    candidate = directory / f"{base_stem}{suffix}"
    counter = 1
    while candidate.exists():
        candidate = directory / f"{base_stem}_{counter}{suffix}"
        counter += 1
    return candidate


def augment_image(image: Image.Image, rng: random.Random, size: tuple[int, int] = DEFAULT_IMAGE_SIZE) -> Image.Image:
    work = image.convert("RGB")

    if rng.random() < 0.55:
        work = ImageOps.mirror(work)
    if rng.random() < 0.15:
        work = ImageOps.flip(work)

    angle = rng.uniform(-22.0, 22.0)
    work = work.rotate(angle, resample=Image.Resampling.BICUBIC, expand=False, fillcolor=(0, 0, 0))

    brightness = rng.uniform(0.8, 1.2)
    contrast = rng.uniform(0.8, 1.25)
    color = rng.uniform(0.85, 1.15)
    sharpness = rng.uniform(0.9, 1.25)

    work = ImageEnhance.Brightness(work).enhance(brightness)
    work = ImageEnhance.Contrast(work).enhance(contrast)
    work = ImageEnhance.Color(work).enhance(color)
    work = ImageEnhance.Sharpness(work).enhance(sharpness)

    return standardize_image(work, size=size)


def save_image(image: Image.Image, destination: Path) -> None:
    ensure_dir(destination.parent)
    image.save(destination, format="JPEG", quality=95, optimize=True)
