import cv2
import numpy as np
import io
from PIL import Image

class InfectionSeverityClassificationModule:
    def __init__(self):
        self.severity = "UNKNOWN"

    def _load_image(self, image_bytes: bytes):
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        return cv2.cvtColor(np.array(image), cv2.COLOR_RGB2BGR)

    def _segment_leaf(self, image: np.ndarray):
        hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        lower = np.array([25, 40, 40])
        upper = np.array([90, 255, 255])
        mask = cv2.inRange(hsv, lower, upper)
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (15, 15))
        mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
        return mask

    def _compute_infection(self, image: np.ndarray, mask: np.ndarray):
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        blurred = cv2.GaussianBlur(gray, (9, 9), 0)
        edges = cv2.Canny(blurred, 50, 150)
        infected = cv2.bitwise_and(edges, edges, mask=mask)
        infected_area = cv2.countNonZero(infected)
        leaf_area = cv2.countNonZero(mask)
        if leaf_area == 0:
            return 0
        return int(min(100, round((infected_area / leaf_area) * 100)))

    def estimate_severity(self, image_bytes: bytes):
        image = self._load_image(image_bytes)
        mask = self._segment_leaf(image)
        infection_percentage = self._compute_infection(image, mask)

        if infection_percentage < 20:
            severity = "LOW"
        elif infection_percentage < 50:
            severity = "MODERATE"
        else:
            severity = "HIGH"

        return {"severity": severity, "infection_percentage": infection_percentage}
