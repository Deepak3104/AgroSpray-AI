from __future__ import annotations

import argparse
from pathlib import Path

import tensorflow as tf

from training.common import MODEL_PATH, OUTPUT_DIR, TFLITE_PATH, ensure_directories, load_model


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Convert the Keras model to TensorFlow Lite.")
    parser.add_argument("--model", type=Path, default=MODEL_PATH)
    parser.add_argument("--output", type=Path, default=TFLITE_PATH)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    ensure_directories()
    model = load_model(args.model)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]
    tflite_model = converter.convert()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(tflite_model)
    print(f"TFLite model saved to {args.output}")


if __name__ == "__main__":
    main()
