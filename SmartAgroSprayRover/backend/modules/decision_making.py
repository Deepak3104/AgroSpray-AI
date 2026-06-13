from typing import Dict

class ControlAndDecisionMakingModule:
    def __init__(self):
        self.thresholds = {
            "low": 20,
            "moderate": 50,
        }

    def decide(self, severity_data: Dict[str, int]) -> Dict[str, str]:
        infection_percentage = severity_data.get("infection_percentage", 0)
        if infection_percentage < self.thresholds["low"]:
            spray = "NO"
            pesticide = "None"
            dosage = "0"
            notes = "Crop is healthy or low risk. Continue monitoring."
        elif infection_percentage < self.thresholds["moderate"]:
            spray = "MODERATE"
            pesticide = "Mancozeb"
            dosage = "1g/L"
            notes = "Apply moderate spray for early symptoms."
        else:
            spray = "YES"
            pesticide = "Mancozeb"
            dosage = "2g/L"
            notes = "High severity detected. Apply full spray immediately."

        return {
            "spray": spray,
            "pesticide": pesticide,
            "dosage": dosage,
            "notes": notes,
        }
