from flask import Flask, jsonify, request
from flask_cors import CORS
import pickle
import numpy as np
import json
from datetime import datetime
import os
import logging
import sqlite3

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuration
app.config['JSON_SORT_KEYS'] = False
app.config['DATABASE'] = 'stroke_predictions.db'

# Create logs directory
os.makedirs('logs', exist_ok=True)

# Load the pre-trained model
model = None
try:
    model_path = os.path.join(os.path.dirname(__file__), '..', 'models', 'stroke_model.pkl')
    with open(model_path, 'rb') as f:
        model = pickle.load(f)
    logger.info("ML Model loaded successfully")
except Exception as e:
    logger.error(f"Error loading model: {e}")
    model = None

# Initialize database
def init_db():
    """Initialize SQLite database"""
    try:
        conn = sqlite3.connect(app.config['DATABASE'])
        c = conn.cursor()
        c.execute('''CREATE TABLE IF NOT EXISTS predictions
                     (id INTEGER PRIMARY KEY AUTOINCREMENT,
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
                      risk_level TEXT)''')
        conn.commit()
        conn.close()
        logger.info("Database initialized")
    except Exception as e:
        logger.error(f"Database init error: {e}")

init_db()

# Store predictions history (in-memory for session)
predictions_history = []

# Model metadata
MODEL_INFO = {
    'model_type': 'RandomForestClassifier',
    'training_date': '2026-02-07',
    'accuracy': 0.95,
    'features': ['age', 'hypertension', 'heart_disease', 'avg_glucose_level', 'bmi', 'smoking_status']
}

# Validation constraints
VALIDATION_RULES = {
    'age': {'min': 18, 'max': 120, 'type': int},
    'hypertension': {'min': 0, 'max': 1, 'type': int},
    'heart_disease': {'min': 0, 'max': 1, 'type': int},
    'avg_glucose_level': {'min': 50, 'max': 300, 'type': float},
    'bmi': {'min': 10, 'max': 50, 'type': float},
    'smoking_status': {'min': 0, 'max': 3, 'type': int}
}

def validate_input(data):
    """Validate input data against constraints"""
    errors = []
    
    for field, rules in VALIDATION_RULES.items():
        if field not in data:
            errors.append(f"Missing required field: {field}")
            continue
        
        try:
            value = rules['type'](data[field])
            if value < rules['min'] or value > rules['max']:
                errors.append(f"{field} must be between {rules['min']} and {rules['max']}")
        except (ValueError, TypeError):
            errors.append(f"{field} must be a valid {rules['type'].__name__}")
    
    return errors

def save_prediction_to_db(result):
    """Save prediction to database"""
    try:
        conn = sqlite3.connect(app.config['DATABASE'])
        c = conn.cursor()
        c.execute('''INSERT INTO predictions 
                     (timestamp, age, hypertension, heart_disease, avg_glucose_level, bmi, smoking_status,
                      prediction, stroke_probability, no_stroke_probability, risk_level)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                  (result['timestamp'],
                   result['patient_data']['age'],
                   result['patient_data']['hypertension'],
                   result['patient_data']['heart_disease'],
                   result['patient_data']['avg_glucose_level'],
                   result['patient_data']['bmi'],
                   result['patient_data']['smoking_status'],
                   result['prediction'],
                   result['stroke_probability'],
                   result['no_stroke_probability'],
                   result['risk_level']))
        conn.commit()
        conn.close()
        return True
    except Exception as e:
        logger.error(f"DB save error: {e}")
        return False

@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'Stroke Detection API is running',
        'model_status': 'loaded' if model is not None else 'not_loaded',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    }), 200

@app.route('/api/predict', methods=['POST'])
def predict():
    """Predict stroke risk based on patient data"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'Request body cannot be empty'}), 400
        
        # Validate input
        validation_errors = validate_input(data)
        if validation_errors:
            logger.warning(f"Validation errors: {validation_errors}")
            return jsonify({'error': 'Validation failed', 'details': validation_errors}), 400
        
        # Check model
        if model is None:
            logger.error("Model not loaded")
            return jsonify({'error': 'ML model not available'}), 500
        
        # Prepare features for prediction
        features = np.array([[
            data['age'],
            data['hypertension'],
            data['heart_disease'],
            data['avg_glucose_level'],
            data['bmi'],
            data['smoking_status']
        ]])
        
        # Make prediction
        prediction = model.predict(features)[0]
        probability = model.predict_proba(features)[0]
        
        # Determine risk level
        prob_stroke = float(probability[1])
        if prob_stroke >= 0.7:
            risk_level = 'High'
        elif prob_stroke >= 0.4:
            risk_level = 'Medium'
        else:
            risk_level = 'Low'
        
        # Build result
        result = {
            'timestamp': datetime.now().isoformat(),
            'patient_data': data,
            'prediction': int(prediction),
            'stroke_probability': prob_stroke,
            'no_stroke_probability': float(probability[0]),
            'risk_level': risk_level,
            'confidence': max(prob_stroke, 1 - prob_stroke)
        }
        
        # Store in memory
        predictions_history.append(result)
        
        # Save to database
        save_prediction_to_db(result)
        
        logger.info(f"Prediction - Age: {data['age']}, Risk: {risk_level}")
        return jsonify(result), 200
    
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        return jsonify({'error': 'Prediction failed', 'message': str(e)}), 500

@app.route('/api/model-info', methods=['GET'])
def get_model_info():
    """Get model information"""
    # Make a JSON-serializable copy of validation rules (convert type objects to names)
    serializable_rules = {}
    for field, rules in VALIDATION_RULES.items():
        serializable_rules[field] = {
            'min': rules.get('min'),
            'max': rules.get('max'),
            'type': rules.get('type').__name__ if isinstance(rules.get('type'), type) else str(rules.get('type'))
        }

    return jsonify({
        'model': MODEL_INFO,
        'model_loaded': model is not None,
        'features': MODEL_INFO.get('features', []),
        'validation_rules': serializable_rules
    }), 200

@app.route('/api/history', methods=['GET'])
def get_history():
    """Get prediction history from session"""
    limit = request.args.get('limit', default=10, type=int)
    offset = request.args.get('offset', default=0, type=int)
    
    history_slice = predictions_history[offset:offset + limit]
    
    return jsonify({
        'count': len(predictions_history),
        'returned': len(history_slice),
        'predictions': history_slice
    }), 200

@app.route('/api/history', methods=['DELETE'])
def clear_history():
    """Clear session prediction history"""
    global predictions_history
    count = len(predictions_history)
    predictions_history = []
    logger.info(f"Cleared {count} predictions")
    return jsonify({'message': f'Cleared {count} predictions'}), 200

@app.route('/api/stats', methods=['GET'])
def get_stats():
    """Get prediction statistics"""
    if not predictions_history:
        return jsonify({'total_predictions': 0, 'stats': {}}), 200
    
    high_risk = sum(1 for p in predictions_history if p['risk_level'] == 'High')
    medium_risk = sum(1 for p in predictions_history if p['risk_level'] == 'Medium')
    low_risk = sum(1 for p in predictions_history if p['risk_level'] == 'Low')
    
    avg_age = np.mean([p['patient_data']['age'] for p in predictions_history])
    
    return jsonify({
        'total_predictions': len(predictions_history),
        'risk_distribution': {
            'high': high_risk,
            'medium': medium_risk,
            'low': low_risk
        },
        'average_age': float(avg_age),
        'timestamp': datetime.now().isoformat()
    }), 200

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def server_error(error):
    """Handle 500 errors"""
    logger.error(f"Server error: {error}")
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
