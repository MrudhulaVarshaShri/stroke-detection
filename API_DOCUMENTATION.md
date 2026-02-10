# Stroke Detection API Documentation

## Overview
The Flask backend provides a REST API for stroke risk prediction using machine learning.

## Running the Backend

### Option 1: PowerShell Script (Windows)
```powershell
.\RUN_BACKEND.ps1
```

### Option 2: Direct Command
```powershell
.venv\Scripts\python.exe backend\app.py
```

The API will start on: **http://127.0.0.1:5000**

---

## API Endpoints

### 1. Health Check
**Endpoint:** `GET /api/health`

Check if the API is running.

**Response:**
```json
{
  "status": "healthy",
  "message": "Stroke Detection API is running",
  "timestamp": "2026-02-10T09:21:16.145296"
}
```

**Test with PowerShell:**
```powershell
Invoke-WebRequest -Uri http://127.0.0.1:5000/api/health
```

---

### 2. Stroke Risk Prediction
**Endpoint:** `POST /api/predict`

Predict stroke risk based on patient data.

**Request Payload:**
```json
{
  "age": 45,
  "hypertension": 0,
  "heart_disease": 0,
  "avg_glucose_level": 150.5,
  "bmi": 25.5,
  "smoking_status": 0
}
```

**Field Descriptions:**
- `age` (number): Patient age in years (18-120)
- `hypertension` (int): 1 if has hypertension, 0 otherwise
- `heart_disease` (int): 1 if has heart disease, 0 otherwise
- `avg_glucose_level` (number): Average glucose level in mg/dL (50-300)
- `bmi` (number): Body Mass Index (10-50)
- `smoking_status` (int): 0 = never, 1 = formerly, 2 = smokes, 3 = unknown

**Response:**
```json
{
  "prediction": 0,
  "stroke_probability": 0.39,
  "no_stroke_probability": 0.61,
  "risk_level": "Low",
  "patient_data": {
    "age": 45,
    "hypertension": 0,
    "heart_disease": 0,
    "avg_glucose_level": 150.5,
    "bmi": 25.5,
    "smoking_status": 0
  },
  "timestamp": "2026-02-10T09:21:16.145296"
}
```

**Response Fields:**
- `prediction`: 0 = No stroke, 1 = Stroke risk
- `stroke_probability`: Probability of stroke (0-1)
- `no_stroke_probability`: Probability of no stroke (0-1)
- `risk_level`: "Low", "Medium", or "High"
- `timestamp`: Prediction timestamp in ISO format

**Test with PowerShell:**
```powershell
$body = @{
    age = 45
    hypertension = 0
    heart_disease = 0
    avg_glucose_level = 150.5
    bmi = 25.5
    smoking_status = 0
} | ConvertTo-Json

$response = Invoke-WebRequest `
  -Uri http://127.0.0.1:5000/api/predict `
  -Method POST `
  -Headers @{'Content-Type'='application/json'} `
  -Body $body

$response.Content | ConvertFrom-Json | Format-List
```

**Test with cURL (if available):**
```bash
curl -X POST http://127.0.0.1:5000/api/predict \
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

---

### 3. Prediction History
**Endpoint:** `GET /api/history`

Get all predictions made in the current session.

**Response:**
```json
[
  {
    "prediction": 0,
    "stroke_probability": 0.39,
    "risk_level": "Low",
    "timestamp": "2026-02-10T09:21:16.145296"
  }
]
```

**Test with PowerShell:**
```powershell
Invoke-WebRequest -Uri http://127.0.0.1:5000/api/history | `
  Select-Object -ExpandProperty Content | `
  ConvertFrom-Json | Format-Table
```

---

### 4. Model Information
**Endpoint:** `GET /api/model-info`

Get information about the trained ML model.

**Response:**
```json
{
  "model_type": "RandomForestClassifier",
  "training_date": "2026-02-07",
  "accuracy": 0.95,
  "features": [
    "age",
    "hypertension",
    "heart_disease",
    "avg_glucose_level",
    "bmi",
    "smoking_status"
  ]
}
```

**Test with PowerShell:**
```powershell
Invoke-WebRequest http://127.0.0.1:5000/api/model-info | `
  Select-Object -ExpandProperty Content | `
  ConvertFrom-Json | Format-List
```

---

## Error Handling

### Missing Required Fields
**Status:** 400 Bad Request

**Response:**
```json
{
  "error": "Missing required fields",
  "missing": ["age", "bmi"]
}
```

### Invalid Data Values
**Status:** 400 Bad Request

**Response:**
```json
{
  "error": "Invalid data values",
  "details": "age must be between 18 and 120"
}
```

### Server Error
**Status:** 500 Internal Server Error

**Response:**
```json
{
  "error": "Prediction failed",
  "message": "Error description"
}
```

---

## Example Test Cases

### Low Risk Patient (Young, Healthy)
```powershell
$body = @{
    age = 25
    hypertension = 0
    heart_disease = 0
    avg_glucose_level = 100
    bmi = 22
    smoking_status = 0
} | ConvertTo-Json

Invoke-WebRequest -Uri http://127.0.0.1:5000/api/predict -Method POST `
  -Headers @{'Content-Type'='application/json'} -Body $body | `
  Select-Object -ExpandProperty Content | ConvertFrom-Json | Format-List
```

### High Risk Patient (Older, Multiple Conditions)
```powershell
$body = @{
    age = 70
    hypertension = 1
    heart_disease = 1
    avg_glucose_level = 200
    bmi = 30
    smoking_status = 2
} | ConvertTo-Json

Invoke-WebRequest -Uri http://127.0.0.1:5000/api/predict -Method POST `
  -Headers @{'Content-Type'='application/json'} -Body $body | `
  Select-Object -ExpandProperty Content | ConvertFrom-Json | Format-List
```

---

## CORS Configuration

The API is configured with CORS to allow requests from:
- `http://localhost:3000` (React frontend)
- `http://127.0.0.1:3000`
- `*` (All origins in development mode)

---

## Architecture

```
Backend (Flask)
    ├── app.py              - Main API server
    ├── requirements.txt    - Python dependencies
    └── models/
        ├── stroke_model.pkl      - Trained ML model
        └── train_model.py        - Model training script

ML Model: Random Forest Classifier
- Trained on healthcare dataset
- 6 input features
- Binary classification (stroke/no stroke)
- Accuracy: ~95%
```

---

## Next Steps

1. **Install Node.js:** Download from https://nodejs.org/
2. **Run Frontend:** Execute `.\RUN_FRONTEND.ps1`
3. **Access UI:** Open http://localhost:3000 in your browser
4. **Connect to Backend:** The React app will communicate with this API

---

## Troubleshooting

### Model Not Found
If you see "Error loading model", ensure [models/stroke_model.pkl](../models/stroke_model.pkl) exists.

### Port Already in Use
If port 5000 is in use, modify the port in [backend/app.py](../backend/app.py):
```python
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)  # Change 5000 to 5001
```

### CORS Errors
Ensure the frontend is making requests to `http://127.0.0.1:5000` (or your configured backend URL).

---

**Version:** 1.0.0  
**Last Updated:** February 10, 2026  
**Status:** ✅ Backend API Operational
