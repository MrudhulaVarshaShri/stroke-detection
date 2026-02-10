#!/usr/bin/env pwsh
# Stroke Detection API Test Script

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Stroke Detection - API Test Suite" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://127.0.0.1:5000"
$headers = @{'Content-Type' = 'application/json'}

# Test 1: Health Check
Write-Host "Test 1: Health Check" -ForegroundColor Yellow
Write-Host "-" * 50
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/health" -ErrorAction Stop
    Write-Host "✓ Status: $($response.StatusCode)" -ForegroundColor Green
    $response.Content | ConvertFrom-Json | Format-List
    Write-Host ""
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Ensure backend is running with: .\RUN_BACKEND.ps1" -ForegroundColor Yellow
    exit 1
}

# Test 2: Low Risk Prediction
Write-Host "Test 2: Low Risk Patient (Young, Healthy)" -ForegroundColor Yellow
Write-Host "-" * 50
$lowRiskBody = @{
    age = 25
    hypertension = 0
    heart_disease = 0
    avg_glucose_level = 100
    bmi = 22
    smoking_status = 0
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/predict" `
        -Method POST `
        -Headers $headers `
        -Body $lowRiskBody `
        -ErrorAction Stop
    Write-Host "✓ Prediction received" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "  Risk Level: $($data.risk_level)"
    Write-Host "  Stroke Probability: $(($data.stroke_probability * 100).ToString('F2'))%"
    Write-Host ""
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Medium Risk Prediction
Write-Host "Test 3: Medium Risk Patient" -ForegroundColor Yellow
Write-Host "-" * 50
$medRiskBody = @{
    age = 50
    hypertension = 1
    heart_disease = 0
    avg_glucose_level = 150
    bmi = 27
    smoking_status = 1
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/predict" `
        -Method POST `
        -Headers $headers `
        -Body $medRiskBody `
        -ErrorAction Stop
    Write-Host "✓ Prediction received" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "  Risk Level: $($data.risk_level)"
    Write-Host "  Stroke Probability: $(($data.stroke_probability * 100).ToString('F2'))%"
    Write-Host ""
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: High Risk Prediction
Write-Host "Test 4: High Risk Patient (Older, Multiple Conditions)" -ForegroundColor Yellow
Write-Host "-" * 50
$highRiskBody = @{
    age = 70
    hypertension = 1
    heart_disease = 1
    avg_glucose_level = 200
    bmi = 31
    smoking_status = 2
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/predict" `
        -Method POST `
        -Headers $headers `
        -Body $highRiskBody `
        -ErrorAction Stop
    Write-Host "✓ Prediction received" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "  Risk Level: $($data.risk_level)"
    Write-Host "  Stroke Probability: $(($data.stroke_probability * 100).ToString('F2'))%"
    Write-Host ""
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Prediction History
Write-Host "Test 5: Prediction History" -ForegroundColor Yellow
Write-Host "-" * 50
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/history" -ErrorAction Stop
    Write-Host "✓ History retrieved" -ForegroundColor Green
    $data = $response.Content | ConvertFrom-Json
    Write-Host "  Total predictions: $($data.Count)"
    Write-Host ""
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Model Information
Write-Host "Test 6: Model Information" -ForegroundColor Yellow
Write-Host "-" * 50
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/model-info" -ErrorAction Stop
    Write-Host "✓ Model info retrieved" -ForegroundColor Green
    $response.Content | ConvertFrom-Json | Format-List
} catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 7: Error Handling - Missing Fields
Write-Host "Test 7: Error Handling (Missing Required Fields)" -ForegroundColor Yellow
Write-Host "-" * 50
$invalidBody = @{
    age = 45
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/api/predict" `
        -Method POST `
        -Headers $headers `
        -Body $invalidBody `
        -ErrorAction Stop
    Write-Host "✓ Response received" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✓ Correctly returned 400 Bad Request" -ForegroundColor Green
        $errorData = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Host "  Error: $($errorData.error)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Unexpected error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Test Suite Complete" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "All tests completed. See results above." -ForegroundColor Green
Write-Host "For more details, visit: http://127.0.0.1:5000/api/health" -ForegroundColor Cyan
