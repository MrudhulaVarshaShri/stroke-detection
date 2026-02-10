# 📋 Quick Reference Guide

## ⚡ Most Common Commands

### Start Applications
```powershell
# Backend only
.\RUN_BACKEND.ps1

# Frontend (requires Node.js)
.\RUN_FRONTEND.ps1

# Both (in separate terminals)
.\RUN_BACKEND.ps1  # Terminal 1
.\RUN_FRONTEND.ps1  # Terminal 2
```

### Test API
```powershell
# Health check
Invoke-WebRequest http://127.0.0.1:5000/api/health

# Make prediction
$body = @{
    age=45; hypertension=0; heart_disease=0
    avg_glucose_level=150.5; bmi=25.5; smoking_status=0
} | ConvertTo-Json

Invoke-WebRequest -Uri http://127.0.0.1:5000/api/predict `
  -Method POST -Headers @{'Content-Type'='application/json'} -Body $body
```

### View Logs
```bash
# Backend
tail -f backend/logs/api.log

# Docker
docker-compose logs -f backend
```

---

## 📚 Documentation Map

| Document | Purpose |
|----------|---------|
| [BUILD_SUMMARY.md](BUILD_SUMMARY.md) | 📊 Complete build overview |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | 🔧 Installation & configuration |
| [API_DOCUMENTATION.md](API_DOCUMENTATION.md) | 📖 API reference & examples |
| [DEPLOYMENT.md](DEPLOYMENT.md) | 🚀 Production deployment guide |
| [TESTING.md](TESTING.md) | 🧪 Testing procedures |
| [README.md](README.md) | 📝 Project overview |
| Makefile | 🎯 Development shortcuts |

---

## 🔗 API Endpoints

```
GET    /api/health              → Check if API is running
POST   /api/predict             → Get stroke risk prediction
GET    /api/history             → View prediction history
GET    /api/model-info          → Get model information
```

---

## 🎯 Quick Start (5 minutes)

### 1. Start Backend
```powershell
.\RUN_BACKEND.ps1
```
→ API at `http://127.0.0.1:5000`

### 2. Test Immediately
```powershell
Invoke-WebRequest http://127.0.0.1:5000/api/health
```

### 3. Optional: Start Frontend (requires Node.js)
```powershell
.\RUN_FRONTEND.ps1
```
→ UI at `http://localhost:3000`

---

## 🐳 Docker Deployment

```bash
# Build and run
docker-compose up --build

# Stop
docker-compose down

# Logs
docker-compose logs -f
```

---

## 🔐 Environment Variables

Copy `.env.example` to `.env`:
```bash
FLASK_ENV=production
DEBUG=False
API_PORT=5000
API_WORKERS=4
```

---

## 📊 API Response Example

```json
{
  "prediction": 0,
  "stroke_probability": 0.39,
  "no_stroke_probability": 0.61,
  "risk_level": "Low",
  "timestamp": "2026-02-10T09:21:16"
}
```

---

## ⚙️ Architecture

```
┌─────────────────────────────────────┐
│   React Frontend (Port 3000)         │
│   • Patient Assessment Form           │
│   • Results Display                   │
└──────────────┬──────────────────────┘
               │ HTTP REST
┌──────────────▼──────────────────────┐
│   Flask Backend (Port 5000)          │
│   • /api/predict                     │
│   • /api/history                     │
│   • /api/health                      │
└──────────────┬──────────────────────┘
               │ Model Inference
┌──────────────▼──────────────────────┐
│   ML Model (Random Forest)           │
│   • 6 input features                 │
│   • Binary classification            │
│   • 95% accuracy                     │
└──────────────┬──────────────────────┘
               │ Data Storage
┌──────────────▼──────────────────────┐
│   SQLite Database                    │
│   • Prediction history               │
│   • Patient records (when ready)     │
└──────────────────────────────────────┘
```

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| Backend won't start | Run `install_python_packages` or check port 5000 |
| Port 5000 in use | Change port in `backend/app.py` or kill process |
| Frontend can't connect | Ensure backend is running, check URL in `.env` |
| Model not found | Verify `models/stroke_model.pkl` exists |
| Slow predictions | Reduce workers or check system resources |

---

## 📞 Getting Help

1. **API Errors:** Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
2. **Setup Issues:** See [SETUP_GUIDE.md](SETUP_GUIDE.md)
3. **Deployment:** Review [DEPLOYMENT.md](DEPLOYMENT.md)
4. **Testing:** Consult [TESTING.md](TESTING.md)

---

## 🎓 Key Files

```
backend/
  app.py              → Flask application (MAIN)
  requirements.txt    → Python dependencies
  
models/
  stroke_model.pkl    → Trained ML model
  train_model.py      → Model training script

frontend/
  src/App.js         → Main React component
  src/PredictionForm.js → Prediction UI
  package.json       → Node dependencies
  
data/
  sample_data.csv    → Training dataset
```

---

## ✅ Verification Checklist

- [ ] Backend running on port 5000
- [ ] `/api/health` returns status
- [ ] Prediction endpoint responding
- [ ] Model loading successfully
- [ ] Frontend loads (optional)
- [ ] Database initialized

---

## 📈 Performance Tips

- **Backend:** Use Gunicorn with 4-8 workers
- **Frontend:** Run build optimization for production
- **Database:** Regular VACUUM for SQLite
- **Caching:** Cache predictions when possible

---

## 🔒 Security Reminders

- Change `SECRET_KEY` in production
- Use HTTPS with SSL certificate
- Restrict CORS origins
- Implement rate limiting
- Validate all inputs
- Regular security audits

---

## 📚 External Resources

- Flask Documentation: https://flask.palletsprojects.com/
- React Documentation: https://react.dev/
- scikit-learn: https://scikit-learn.org/
- Docker: https://www.docker.com/

---

**Application Version:** 1.0.0  
**Last Updated:** February 10, 2026  
**Status:** ✅ Ready for Use

For detailed information, refer to the detailed documentation files listed above.
