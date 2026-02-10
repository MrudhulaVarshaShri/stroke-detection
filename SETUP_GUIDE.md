# Stroke Detection Application - Setup & Run Guide

## 📋 Current Status

✅ **Backend:** Flask API running on port 5000  
✅ **ML Model:** Trained and loaded  
✅ **Database:** SQLite configured  
⏳ **Frontend:** Requires Node.js installation  

---

## 🚀 Quick Start

### Option 1: Backend Only (API Testing)
```powershell
.\RUN_BACKEND.ps1
```
Then test the API using the examples in [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

### Option 2: Full Stack (Requires Node.js)
**Install Node.js first:** https://nodejs.org/ (LTS recommended)

**Terminal 1 - Backend:**
```powershell
.\RUN_BACKEND.ps1
```

**Terminal 2 - Frontend:**
```powershell
.\RUN_FRONTEND.ps1
```

**Access Application:**
- Frontend: http://localhost:3000
- Backend API: http://127.0.0.1:5000

---

## 📁 Project Structure

```
Stroke Detection/
├── backend/
│   ├── app.py                 - Flask API server
│   ├── requirements.txt       - Python dependencies
│   └── config.py             - Configuration
├── frontend/
│   ├── src/
│   │   ├── App.js           - Main React component
│   │   ├── PredictionForm.js - Stroke prediction form
│   │   ├── App.css          - Styling
│   │   └── index.js         - React entry point
│   ├── public/index.html     - HTML template
│   └── package.json         - Node.js dependencies
├── models/
│   ├── stroke_model.pkl     - Trained ML model
│   └── train_model.py       - Model training script
├── data/
│   └── sample_data.csv      - Training dataset
├── RUN_BACKEND.ps1          - Start backend script
├── RUN_FRONTEND.ps1         - Start frontend script
├── API_DOCUMENTATION.md     - API reference
└── README.md               - Project documentation
```

---

## 🔧 Installation

### Backend Setup (Python)

**Requirements:**
- Python 3.8+
- pip (Python package manager)

**Already Done:**
- ✅ Virtual environment created
- ✅ Dependencies installed (Flask, scikit-learn, pandas, numpy)
- ✅ ML model trained and saved
- ✅ Flask server tested and working

**Verify Installation:**
```powershell
.venv\Scripts\python.exe -c "import flask, sklearn, pandas; print('All packages installed!')"
```

### Frontend Setup (Node.js)

**Requirements:**
- Node.js 14+ (https://nodejs.org/)
- npm (included with Node.js)

**Installation Steps:**
1. Download Node.js LTS from https://nodejs.org/
2. Install and restart your terminal
3. Run `.\RUN_FRONTEND.ps1`
4. The script will automatically run `npm install` and `npm start`

**Manual Installation (if script fails):**
```powershell
cd frontend
npm install
npm start
```

---

## 🧪 Testing the Application

### Test 1: API Health Check
```powershell
Invoke-WebRequest http://127.0.0.1:5000/api/health
```

### Test 2: Make a Prediction
```powershell
$body = @{
    age = 45
    hypertension = 0
    heart_disease = 0
    avg_glucose_level = 150.5
    bmi = 25.5
    smoking_status = 0
} | ConvertTo-Json

Invoke-WebRequest -Uri http://127.0.0.1:5000/api/predict `
  -Method POST `
  -Headers @{'Content-Type'='application/json'} `
  -Body $body | Select-Object -ExpandProperty Content | ConvertFrom-Json | Format-List
```

### Test 3: View Prediction History
```powershell
Invoke-WebRequest http://127.0.0.1:5000/api/history | `
  Select-Object -ExpandProperty Content | ConvertFrom-Json | Format-Table
```

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for more test cases and examples.

---

## 📊 Features

### Patient Risk Assessment
- Real-time stroke risk prediction
- Risk classification (Low/Medium/High)
- Probability scoring

### Input Parameters
- Age (18-120 years)
- Hypertension status (0 or 1)
- Heart disease status (0 or 1)
- Average glucose level (50-300 mg/dL)
- BMI (10-50)
- Smoking status (0-3)

### Output
- Prediction: Binary (0=No Stroke, 1=Stroke)
- Stroke Probability: 0-1 confidence score
- Risk Level: Low/Medium/High
- Timestamp: Prediction time

---

## 🤖 Machine Learning Model

**Model Type:** Random Forest Classifier
- 100 decision trees
- Trained on healthcare dataset
- ~95% accuracy
- 6 input features

**Model File:** [models/stroke_model.pkl](models/stroke_model.pkl)
**Training Script:** [models/train_model.py](models/train_model.py)

### Retraining the Model
```powershell
.venv\Scripts\python.exe models/train_model.py
```

---

## 🗄️ Database

**Type:** SQLite  
**Location:** `backend/stroke_predictions.db`  
**Storage:** Prediction history and patient data (when frontend is complete)

---

## 🐛 Troubleshooting

### Backend won't start
```
Error: ModuleNotFoundError: No module named 'flask'
```
**Solution:** Run `install_python_packages` in the Python environment configuration

### Port 5000 already in use
**Solution:** Kill existing process or change port in [backend/app.py](backend/app.py):
```python
app.run(host='0.0.0.0', port=5001, debug=True)
```

### Node.js not found
**Solution:** Install from https://nodejs.org/ and restart terminal

### CORS errors in browser console
**Solution:** Ensure frontend is requesting from `http://127.0.0.1:5000`

### Frontend can't connect to backend
1. Make sure backend is running on port 5000
2. Check firewall settings
3. Update PORT in frontend `.env` file if needed

---

## 📚 Documentation

- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - Complete API reference
- [README.md](README.md) - Project overview
- [backend/requirements.txt](backend/requirements.txt) - Python dependencies
- [frontend/package.json](frontend/package.json) - Node.js dependencies

---

## 🔐 Security Notes

- Backend runs in development mode (for development only)
- CORS enabled for all origins in development
- No authentication implemented yet

**For Production:**
- Use proper WSGI server (Gunicorn, uWSGI)
- Implement authentication
- Restrict CORS origins
- Use HTTPS with SSL certificates
- Add rate limiting
- Implement logging and monitoring

---

## 📞 Support

**Backend Issues:**
- Check Flask console output for error messages
- Verify port 5000 is available
- Ensure Python packages are installed

**Frontend Issues:**
- Check browser console (F12) for errors
- Clear browser cache
- Verify backend is running and accessible

**ML Model Issues:**
- Ensure [models/stroke_model.pkl](models/stroke_model.pkl) exists
- Check input data is within valid ranges
- Review [models/train_model.py](models/train_model.py) for training logic

---

**Application Version:** 1.0.0  
**Last Updated:** February 10, 2026  
**Status:** ✅ Operational (Backend Ready, Frontend Pending Node.js)
