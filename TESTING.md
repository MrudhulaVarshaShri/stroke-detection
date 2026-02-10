# Testing Guide

This document describes testing procedures for the Stroke Detection application.

## Table of Contents
1. [Unit Testing](#unit-testing)
2. [Integration Testing](#integration-testing)
3. [API Testing](#api-testing)
4. [Load Testing](#load-testing)
5. [Security Testing](#security-testing)

---

## Unit Testing

### Backend Unit Tests

#### Setup
```bash
pip install pytest pytest-cov
```

#### Run Tests
```bash
# Run all tests
pytest backend/tests/ -v

# Run with coverage
pytest backend/tests/ --cov=backend --cov-report=html

# Run specific test
pytest backend/tests/test_predictions.py::test_valid_prediction -v
```

#### Sample Test Structure
```python
# backend/tests/test_predictions.py
import pytest
from app import app, model

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_endpoint(client):
    response = client.get('/api/health')
    assert response.status_code == 200
    assert response.json['status'] == 'healthy'

def test_valid_prediction(client):
    data = {
        'age': 45,
        'hypertension': 0,
        'heart_disease': 0,
        'avg_glucose_level': 150.5,
        'bmi': 25.5,
        'smoking_status': 0
    }
    response = client.post('/api/predict', json=data)
    assert response.status_code == 200
    assert 'prediction' in response.json
    assert 'stroke_probability' in response.json
```

### Frontend Unit Tests

#### Setup
```bash
cd frontend
npm install --save-dev @testing-library/react @testing-library/jest-dom
```

#### Run Tests
```bash
cd frontend
npm test

# Run with coverage
npm test -- --coverage

# Watch mode
npm test -- --watch
```

#### Sample Test
```javascript
// frontend/src/__tests__/PredictionForm.test.js
import { render, screen, fireEvent } from '@testing-library/react';
import PredictionForm from '../PredictionForm';

test('renders prediction form', () => {
  render(<PredictionForm />);
  const submitButton = screen.getByText(/Get Risk Assessment/i);
  expect(submitButton).toBeInTheDocument();
});

test('submits form with valid data', () => {
  render(<PredictionForm />);
  const ageInput = screen.getByLabelText(/Age/i);
  fireEvent.change(ageInput, { target: { value: '45' } });
  // ... add more field inputs
  const submitButton = screen.getByText(/Get Risk Assessment/i);
  fireEvent.click(submitButton);
  // ... assert results
});
```

---

## Integration Testing

### End-to-End API Tests

```bash
# Using pytest with fixtures
pytest backend/tests/test_integration.py -v
```

### Example Integration Test
```python
# backend/tests/test_integration.py
import pytest
import json
from app import app, db

class TestAPIIntegration:
    @pytest.fixture(autouse=True)
    def setup(self):
        app.config['TESTING'] = True
        with app.app_context():
            db.create_all()
            yield
            db.session.remove()
            db.drop_all()
    
    def test_full_prediction_flow(self):
        with app.test_client() as client:
            # 1. Health check
            resp = client.get('/api/health')
            assert resp.status_code == 200
            
            # 2. Make prediction
            data = {...}
            resp = client.post('/api/predict', json=data)
            assert resp.status_code == 200
            
            # 3. Check history
            resp = client.get('/api/history')
            assert len(resp.json) > 0
```

---

## API Testing

### Manual Testing with PowerShell

#### Test 1: Health Check
```powershell
Invoke-WebRequest -Uri http://127.0.0.1:5000/api/health | Select-Object -ExpandProperty Content | ConvertFrom-Json
```

#### Test 2: Valid Prediction
```powershell
$body = @{
    age = 45
    hypertension = 0
    heart_disease = 0
    avg_glucose_level = 150.5
    bmi = 25.5
    smoking_status = 0
} | ConvertTo-Json

$response = Invoke-WebRequest -Uri http://127.0.0.1:5000/api/predict `
  -Method POST `
  -Headers @{'Content-Type'='application/json'} `
  -Body $body

$response.Content | ConvertFrom-Json | Format-List
```

#### Test 3: Invalid Data (Missing Fields)
```powershell
$body = @{ age = 45 } | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri http://127.0.0.1:5000/api/predict `
      -Method POST `
      -Headers @{'Content-Type'='application/json'} `
      -Body $body
} catch {
    Write-Host "Expected error: $($_.Exception.Response.StatusCode)"
}
```

### Using cURL (if available)
```bash
# Health check
curl http://127.0.0.1:5000/api/health

# Prediction
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

### Using Postman
1. Import or create collection
2. Add requests:
   - `GET /api/health`
   - `POST /api/predict`
   - `GET /api/history`
3. Use JSON body for POST
4. Save environment variables for base URL

---

## Load Testing

### Using Apache Bench
```bash
# Install
sudo apt install apache2-utils  # Linux
# Or download from Apache site for Windows/Mac

# Test API endpoint (1000 requests, 10 concurrent)
ab -n 1000 -c 10 http://127.0.0.1:5000/api/health

# POST request
ab -n 1000 -c 10 -p data.json -T application/json http://127.0.0.1:5000/api/predict
```

### Using Locust
```bash
# Install
pip install locust

# Create locustfile.py
```

```python
# locustfile.py
from locust import HttpUser, task, between
import json

class StrokePredictionUser(HttpUser):
    wait_time = between(1, 5)
    
    @task
    def health_check(self):
        self.client.get("/api/health")
    
    @task(3)
    def predict_stroke(self):
        data = {
            "age": 45,
            "hypertension": 0,
            "heart_disease": 0,
            "avg_glucose_level": 150.5,
            "bmi": 25.5,
            "smoking_status": 0
        }
        self.client.post("/api/predict", json=data)
```

Run:
```bash
locust -f locustfile.py --host=http://127.0.0.1:5000
# Open http://localhost:8089
```

---

## Security Testing

### Input Validation

#### Test SQL Injection (if using database queries)
```python
def test_sql_injection_protection(client):
    data = {
        "age": "'; DROP TABLE users; --",
        ...
    }
    response = client.post('/api/predict', json=data)
    assert response.status_code in [400, 500]  # Should fail safely
```

#### Test XSS Prevention (Frontend)
```python
def test_xss_prevention(client):
    data = {
        "age": "<script>alert('xss')</script>",
        ...
    }
    response = client.post('/api/predict', json=data)
    assert response.status_code == 400
```

### CORS Testing
```bash
# Check CORS headers
curl -H "Origin: http://example.com" \
     -H "Access-Control-Request-Method: POST" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS http://127.0.0.1:5000/api/predict -v
```

### SSL/TLS Testing
```bash
# Check SSL certificate (production)
openssl s_client -connect stroke-detection.example.com:443
```

---

## Performance Benchmarking

### Backend Response Time
```python
import time
from app import app

client = app.test_client()

times = []
for i in range(100):
    start = time.time()
    response = client.post('/api/predict', json=valid_data)
    end = time.time()
    times.append(end - start)

avg_time = sum(times) / len(times)
print(f"Average prediction time: {avg_time * 1000:.2f}ms")
print(f"Min: {min(times) * 1000:.2f}ms, Max: {max(times) * 1000:.2f}ms")
```

### Frontend Performance
```bash
cd frontend
npm install --save-dev lighthouse
npx lighthouse http://localhost:3000 --view
```

---

## Continuous Integration

### GitHub Actions
```yaml
# .github/workflows/tests.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - run: pip install -r backend/requirements.txt pytest
      - run: pytest backend/tests/
```

---

## Test Checklist

### Before Release
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] API endpoints responding correctly
- [ ] Error handling working
- [ ] Database operations tested
- [ ] Frontend rendering correctly
- [ ] Form validation working
- [ ] API responses properly formatted
- [ ] CORS headers correct
- [ ] Performance acceptable
- [ ] Security tests passing
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Input validation working
- [ ] Error messages appropriate

---

## Test Metrics

### Coverage Goals
- Backend: 80%+
- Frontend: 70%+
- Critical paths: 95%+

### Performance Targets
- API response time: < 200ms (P95)
- Frontend load time: < 3s
- Prediction latency: < 100ms

---

## Continuous Testing

```bash
# Run tests on file changes
pytest-watch backend/tests/

# Frontend watch
npm test -- --watch
```

---

**Last Updated:** February 10, 2026  
**Version:** 1.0.0
