from __future__ import annotations

import argparse
import json
from pathlib import Path

import tensorflow as tf

from training.common import (
    DATASET_DIR,
    IMAGE_SIZE,
    MODEL_PATH,
    OUTPUT_DIR,
    build_callbacks,
    build_model,
    create_image_generators,
    ensure_directories,
    save_class_names,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Train the AgroSpray crop disease detector.")
    parser.add_argument(
        "--dataset",
        type=Path,
        default=DATASET_DIR,
        help="Path to the prepared dataset directory containing train/validation/test.",
    )
    parser.add_argument("--epochs", type=int, default=20, help="Number of training epochs.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    ensure_directories()

    train_dir = args.dataset / "train"
    validation_dir = args.dataset / "validation"

    if not train_dir.exists() or not validation_dir.exists():
        raise FileNotFoundError(
            f"Prepared dataset folders not found at {train_dir} and {validation_dir}."
        )

    train_generator, validation_generator = create_image_generators(args.dataset)
    class_names = save_class_names(train_generator.class_indices)
    model = build_model(num_classes=len(class_names))

    callbacks = build_callbacks(OUTPUT_DIR)
    history = model.fit(
        train_generator,
        validation_data=validation_generator,
        epochs=args.epochs,
        callbacks=callbacks,
    )

    model.save(MODEL_PATH)
    history_path = OUTPUT_DIR / "training_history.json"
    history_path.write_text(json.dumps(history.history, indent=2), encoding="utf-8")

    print(f"Model saved to {MODEL_PATH}")
    print(f"Class names saved to {len(class_names)} labels in {class_names}")


if __name__ == "__main__":
    main()
