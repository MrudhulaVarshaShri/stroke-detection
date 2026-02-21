# Stroke Detection Application

A full-stack machine learning application for predicting stroke risk based on patient health data. This application uses a trained Random Forest model to assess stroke risk and provides real-time predictions through a REST API and React web interface.

## 🎯 Features

- **Patient Risk Assessment**: Form-based patient data input
- **Real-time Stroke Prediction**: ML-powered risk assessment
- **Prediction History**: Track and review past assessments
- **REST API**: Backend API for integration with other systems
- **Responsive UI**: Modern React-based web interface
- **Health Check**: API health monitoring endpoint

## 📁 Project Structure

```
stroke-detection/
├── backend/                 # Flask API server
│   ├── app.py              # Main Flask application
│   ├── requirements.txt     # Python dependencies
│   └── .env.example        # Environment configuration template
├── frontend/               # React web application
│   ├── src/               # React components and styles
│   ├── public/            # Static files
│   └── package.json       # Node dependencies
├── models/                # ML model files
│   ├── stroke_model.pkl   # Trained model (generated after training)
│   └── train_model.py     # Model training script
├── data/                  # Sample datasets
│   └── sample_data.csv    # Example patient data
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Node.js 14+
- npm or yarn

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Create a virtual environment (optional but recommended):
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install Python dependencies:
```bash
pip install -r requirements.txt
```

4. Train the model (from the models directory):
```bash
cd ../models
python train_model.py
```

5. Start the Flask server:
```bash
cd ../backend
python app.py
```

The API will be available at `http://localhost:5000`

### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install Node dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm start
```

The web application will open at `http://localhost:3000`

## 🔌 API Endpoints

### Health Check
```
GET /api/health
```

Returns the API status and current timestamp.

### Make Prediction
```
POST /api/predict
Content-Type: application/json

{
  "age": 45,
  "hypertension": 0,
  "heart_disease": 0,
  "avg_glucose_level": 150.5,
  "bmi": 25.5,
  "smoking_status": 0
}
```

**Response:**
```json
{
  "timestamp": "2026-02-07T10:30:00",
  "patient_data": {...},
  "prediction": 0,
  "stroke_probability": 0.25,
  "no_stroke_probability": 0.75,
  "risk_level": "Low"
}
```

### Get Prediction History
```
GET /api/history
```

Returns the last 10 predictions made.

### Clear History
```
DELETE /api/history
```

Clears all stored prediction history.

## 📊 Input Parameters

| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| age | integer | 20-85 | Patient age in years |
| hypertension | integer | 0-1 | 0=No, 1=Yes |
| heart_disease | integer | 0-1 | 0=No, 1=Yes |
| avg_glucose_level | float | 50-300 | Average blood glucose level |
| bmi | float | 15-40 | Body Mass Index |
| smoking_status | integer | 0-2 | 0=Never, 1=Former, 2=Current |

## 🤖 Model Details

- **Algorithm**: Random Forest Classifier
- **Features**: 6 patient health indicators
- **Training Data**: Sample synthetic data (1000 samples)
- **Output**: Binary classification (0=No Stroke, 1=Stroke)
- **Metrics**: Returns both prediction and probability

## 📝 Usage Example

### Using cURL
```bash
curl -X POST http://localhost:5000/api/predict \
  -H "Content-Type: application/json" \
  -d '{
    "age": 45,
    "hypertension": 0,
    "heart_disease": 0,
    "avg_glucose_level": 150.5,
    "bmi": 25.5,
    "smoking_status": 0
  }'
```

### Using Python
```python
import requests

url = "http://localhost:5000/api/predict"
data = {
    "age": 45,
    "hypertension": 0,
    "heart_disease": 0,
    "avg_glucose_level": 150.5,
    "bmi": 25.5,
    "smoking_status": 0
}

response = requests.post(url, json=data)
print(response.json())
```

## ⚠️ Disclaimer

This application is for educational and informational purposes only. It should not be used as a substitute for professional medical advice. Always consult with a healthcare professional for medical decisions.

## 📄 License

This project is provided as-is for educational purposes.

## 🤝 Support

For issues or questions, please refer to the project documentation or contact the development team.

---

**Last Updated**: February 7, 2026
