from __future__ import annotations

from dataclasses import dataclass
import re
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class DatasetSpec:
    name: str
    aliases: tuple[str, ...]
    default_crop: str | None = None


DATASET_SPECS: tuple[DatasetSpec, ...] = (
    DatasetSpec(name="PlantVillage", aliases=("plantvillage", "plant village")),
    DatasetSpec(name="PlantDoc", aliases=("plantdoc", "plant doc")),
    DatasetSpec(name="Rice Leaf Disease", aliases=("rice leaf disease", "rice_leaf_disease", "rice"), default_crop="Rice"),
    DatasetSpec(name="Paddy Doctor", aliases=("paddy doctor", "paddy_doctor", "paddy"), default_crop="Rice"),
    DatasetSpec(name="Cassava Leaf Disease", aliases=("cassava leaf disease", "cassava"), default_crop="Cassava"),
    DatasetSpec(name="Cotton Disease", aliases=("cotton disease", "cotton"), default_crop="Cotton"),
    DatasetSpec(name="Corn Disease", aliases=("corn disease", "corn", "maize"), default_crop="Corn"),
    DatasetSpec(name="Wheat Disease", aliases=("wheat disease", "wheat"), default_crop="Wheat"),
    DatasetSpec(name="Mango Leaf Disease", aliases=("mango leaf disease", "mango"), default_crop="Mango"),
    DatasetSpec(name="Banana Disease", aliases=("banana disease", "banana"), default_crop="Banana"),
    DatasetSpec(name="Tea Leaf Disease", aliases=("tea leaf disease", "tea"), default_crop="Tea"),
    DatasetSpec(name="Citrus Disease", aliases=("citrus disease", "citrus"), default_crop="Citrus"),
    DatasetSpec(name="Apple Disease", aliases=("apple disease", "apple"), default_crop="Apple"),
    DatasetSpec(name="Grape Disease", aliases=("grape disease", "grape"), default_crop="Grape"),
    DatasetSpec(name="Soybean Disease", aliases=("soybean disease", "soybean"), default_crop="Soybean"),
)


def normalize_key(value: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", value.lower())


def find_dataset_spec(value: str | Path) -> DatasetSpec | None:
    candidate = normalize_key(str(value))
    for spec in DATASET_SPECS:
        if candidate == normalize_key(spec.name):
            return spec
        for alias in spec.aliases:
            if candidate == normalize_key(alias):
                return spec
    return None


def normalize_component(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9]+", " ", value).strip()
    if not cleaned:
        return "Unknown"
    return "_".join(part[:1].upper() + part[1:].lower() for part in cleaned.split())


def canonicalize_class_label(raw_label: str, default_crop: str | None = None) -> str:
    label = Path(raw_label).stem.replace("\\", "/").split("/")[-1].strip()
    label = label.replace("__", "_")

    if "___" in label:
        crop_part, disease_part = label.split("___", 1)
        return f"{normalize_component(crop_part)}___{normalize_component(disease_part)}"

    cleaned = normalize_component(label)
    if default_crop:
        crop = normalize_component(default_crop)
        if cleaned.lower() == "healthy":
            return f"{crop}___Healthy"
        if cleaned.startswith(crop + "___"):
            return cleaned
        return f"{crop}___{cleaned}"

    if cleaned.lower() == "healthy":
        return "Healthy"
    return cleaned


def display_label(canonical_label: str) -> str:
    if "___" in canonical_label:
        _, disease = canonical_label.split("___", 1)
        return disease.replace("_", " ")
    return canonical_label.replace("_", " ")


def iter_known_dataset_names() -> Iterable[str]:
    for spec in DATASET_SPECS:
        yield spec.name
