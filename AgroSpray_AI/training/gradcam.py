from __future__ import annotations

from pathlib import Path
from typing import Optional, Tuple

import cv2
import matplotlib.cm as cm
import numpy as np
import tensorflow as tf

from training.common import IMAGE_SIZE, preprocess_image


def _find_last_conv_layer(model: tf.keras.Model) -> str:
    for layer in reversed(model.layers):
        if isinstance(layer, (tf.keras.layers.Conv2D, tf.keras.layers.DepthwiseConv2D)):
            return layer.name
        if hasattr(layer, "layers"):
            try:
                nested = _find_last_conv_layer(layer)
                if nested:
                    return nested
            except ValueError:
                pass
    raise ValueError("Could not locate a convolutional layer for Grad-CAM.")


def make_gradcam_heatmap(
    image_array: np.ndarray,
    model: tf.keras.Model,
    last_conv_layer_name: Optional[str] = None,
    pred_index: Optional[int] = None,
) -> np.ndarray:
    if last_conv_layer_name is None:
        last_conv_layer_name = _find_last_conv_layer(model)

    grad_model = tf.keras.models.Model(
        [model.inputs],
        [model.get_layer(last_conv_layer_name).output, model.output],
    )

    with tf.GradientTape() as tape:
        conv_outputs, predictions = grad_model(image_array)
        if pred_index is None:
            pred_index = tf.argmax(predictions[0])
        class_channel = predictions[:, pred_index]

    grads = tape.gradient(class_channel, conv_outputs)
    pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))
    conv_outputs = conv_outputs[0]
    heatmap = tf.reduce_sum(conv_outputs * pooled_grads, axis=-1)

    heatmap = np.maximum(heatmap, 0)
    max_value = np.max(heatmap)
    if max_value > 0:
        heatmap /= max_value
    return heatmap


def save_gradcam_overlay(
    model: tf.keras.Model,
    image_path: str | Path,
    output_path: str | Path,
    pred_index: Optional[int] = None,
    alpha: float = 0.4,
) -> Path:
    image_path = Path(image_path)
    output_path = Path(output_path)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    image = tf.keras.utils.load_img(image_path, target_size=IMAGE_SIZE)
    image_array = tf.keras.utils.img_to_array(image)
    input_tensor = np.expand_dims(image_array / 255.0, axis=0)

    heatmap = make_gradcam_heatmap(input_tensor, model, pred_index=pred_index)
    heatmap = cv2.resize(heatmap, IMAGE_SIZE)
    heatmap = np.uint8(255 * heatmap)
    colormap = cm.get_cmap("jet")
    colored_heatmap = colormap(heatmap)[:, :, :3]
    colored_heatmap = np.uint8(255 * colored_heatmap)

    original_image = cv2.imread(str(image_path))
    original_image = cv2.resize(original_image, IMAGE_SIZE)
    overlay = cv2.addWeighted(original_image, 1 - alpha, colored_heatmap[:, :, ::-1], alpha, 0)
    cv2.imwrite(str(output_path), overlay)
    return output_path
