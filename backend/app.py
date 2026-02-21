from flask import Flask, jsonify, request
from flask_cors import CORS
import pickle
import numpy as np
from datetime import datetime
import os
import logging
import sqlite3

# -------------------- Logging --------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# -------------------- App Setup --------------------
app = Flask(__name__)
CORS(app)

app.config["JSON_SORT_KEYS"] = False
app.config["DATABASE"] = "stroke_predictions.db"

# -------------------- Model Loading --------------------
model = None
try:
    base_dir = os.path.dirname(os.path.abspath(__file__))
    model_path = os.path.join(base_dir, "..", "models", "stroke_model.pkl")

    with open(model_path, "rb") as f:
        model = pickle.load(f)

    logger.info("ML model loaded successfully")

except Exception as e:
    logger.error(f"Error loading model: {e}")
    model = None

# -------------------- Database --------------------
def init_db():
    try:
        conn = sqlite3.connect(app.config["DATABASE"])
        c = conn.cursor()
        c.execute("""
            CREATE TABLE IF NOT EXISTS predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT,
                age INTEGER,
                hypertension INTEGER,
                heart_disease INTEGER,
                avg_glucose_level REAL,
                bmi REAL,
                smoking_status INTEGER,
                prediction INTEGER,
                stroke_probability REAL,
                no_stroke_probability REAL,
                risk_level TEXT
            )
        """)
        conn.commit()
        conn.close()
        logger.info("Database initialized")
    except Exception as e:
        logger.error(f"Database init error: {e}")

init_db()

predictions_history = []

# -------------------- Health Routes --------------------
@app.route("/health", methods=["GET"])
@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "model_loaded": model is not None,
        "timestamp": datetime.utcnow().isoformat()
    }), 200

# -------------------- Prediction --------------------
@app.route("/api/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json()

        if not data:
            return jsonify({"error": "Empty request body"}), 400

        if model is None:
            return jsonify({"error": "Model not loaded"}), 500

        features = np.array([[
            data["age"],
            data["hypertension"],
            data["heart_disease"],
            data["avg_glucose_level"],
            data["bmi"],
            data["smoking_status"]
        ]])

        prediction = int(model.predict(features)[0])
        probabilities = model.predict_proba(features)[0]

        stroke_prob = float(probabilities[1])
        no_stroke_prob = float(probabilities[0])

        if stroke_prob >= 0.7:
            risk = "High"
        elif stroke_prob >= 0.4:
            risk = "Medium"
        else:
            risk = "Low"

        result = {
            "timestamp": datetime.utcnow().isoformat(),
            "prediction": prediction,
            "stroke_probability": stroke_prob,
            "no_stroke_probability": no_stroke_prob,
            "risk_level": risk
        }

        predictions_history.append(result)

        return jsonify(result), 200

    except Exception as e:
        logger.error(f"Prediction error: {e}")
        return jsonify({"error": "Prediction failed"}), 500

# -------------------- Error Handlers --------------------
@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({"error": "Internal server error"}), 500

# -------------------- Run --------------------
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)