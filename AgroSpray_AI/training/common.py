from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DATASET_DIR = PROJECT_ROOT / "dataset"
MODELS_DIR = PROJECT_ROOT / "models"
OUTPUT_DIR = PROJECT_ROOT / "output"
MODEL_PATH = OUTPUT_DIR / "agrospray_model.keras"
TFLITE_PATH = OUTPUT_DIR / "agrospray_model.tflite"
CLASS_NAMES_PATH = MODELS_DIR / "class_names.json"
PREDICTION_HISTORY_PATH = OUTPUT_DIR / "prediction_history.json"
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
VALIDATION_SPLIT = 0.2
SEED = 42


def ensure_directories() -> None:
    for path in (MODELS_DIR, OUTPUT_DIR, OUTPUT_DIR / "gradcam", OUTPUT_DIR / "uploads"):
        path.mkdir(parents=True, exist_ok=True)


def build_model(num_classes: int):
    import tensorflow as tf
    from tensorflow.keras import layers, models

    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(*IMAGE_SIZE, 3),
        include_top=False,
        weights="imagenet",
    )
    base_model.trainable = False

    inputs = layers.Input(shape=(*IMAGE_SIZE, 3))
    x = layers.Rescaling(1.0 / 255.0)(inputs)
    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dense(128, activation="relu")(x)
    x = layers.Dropout(0.3)(x)
    outputs = layers.Dense(num_classes, activation="softmax")(x)

    model = models.Model(inputs, outputs, name="AgroSpray_MobileNetV2")
    model.compile(
        optimizer="adam",
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )
    return model


def create_image_generators(dataset_dir: Path):
    import tensorflow as tf

    train_dir = dataset_dir / "train"
    validation_dir = dataset_dir / "validation"

    if not train_dir.exists() or not validation_dir.exists():
        raise FileNotFoundError(
            f"Expected prepared dataset directories at {train_dir} and {validation_dir}."
        )

    train_datagen = tf.keras.preprocessing.image.ImageDataGenerator(
        rescale=1.0 / 255.0,
        rotation_range=20,
        zoom_range=0.2,
        horizontal_flip=True,
        fill_mode="nearest",
    )
    valid_datagen = tf.keras.preprocessing.image.ImageDataGenerator(
        rescale=1.0 / 255.0,
    )

    train_generator = train_datagen.flow_from_directory(
        directory=str(train_dir),
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode="categorical",
        shuffle=True,
        seed=SEED,
    )

    validation_generator = valid_datagen.flow_from_directory(
        directory=str(validation_dir),
        target_size=IMAGE_SIZE,
        batch_size=BATCH_SIZE,
        class_mode="categorical",
        shuffle=False,
        seed=SEED,
    )

    return train_generator, validation_generator


def save_class_names(class_indices: Dict[str, int]) -> List[str]:
    class_names = [name for name, _ in sorted(class_indices.items(), key=lambda item: item[1])]
    CLASS_NAMES_PATH.write_text(json.dumps(class_names, indent=2), encoding="utf-8")
    return class_names


def load_class_names() -> List[str]:
    if not CLASS_NAMES_PATH.exists():
        raise FileNotFoundError(
            f"Class names file not found at {CLASS_NAMES_PATH}. Run training first."
        )
    return json.loads(CLASS_NAMES_PATH.read_text(encoding="utf-8"))


def load_model(path: Path = MODEL_PATH):
    import tensorflow as tf

    if not path.exists():
        raise FileNotFoundError(f"Model file not found at {path}. Train the model first.")
    return tf.keras.models.load_model(path)


def preprocess_image(image_path: str | Path) -> np.ndarray:
    import tensorflow as tf

    image = tf.keras.utils.load_img(image_path, target_size=IMAGE_SIZE)
    array = tf.keras.utils.img_to_array(image)
    array = np.expand_dims(array, axis=0)
    array = array / 255.0
    return array.astype(np.float32)


def class_name_to_display_name(class_name: str) -> str:
    if "___" in class_name:
        _, disease = class_name.split("___", 1)
    else:
        disease = class_name
    disease = disease.replace("_", " ").strip()
    if disease.lower() == "healthy":
        return "Healthy"
    return disease.title()


def display_name_to_slug(display_name: str) -> str:
    return display_name.strip().replace(" ", "_").replace("__", "_")


def top_prediction(probabilities: np.ndarray, class_names: List[str]) -> Tuple[str, float, int]:
    index = int(np.argmax(probabilities[0]))
    confidence = float(probabilities[0][index])
    return class_names[index], confidence, index


def load_pesticide_database(path: Path) -> Dict[str, dict]:
    if not path.exists():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def build_callbacks(output_dir: Path):
    return [
        tf.keras.callbacks.ModelCheckpoint(
            filepath=str(output_dir / "agrospray_model.keras"),
            monitor="val_accuracy",
            save_best_only=True,
            save_weights_only=False,
            verbose=1,
        ),
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=5,
            restore_best_weights=True,
            verbose=1,
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.3,
            patience=2,
            min_lr=1e-6,
            verbose=1,
        ),
    ]
