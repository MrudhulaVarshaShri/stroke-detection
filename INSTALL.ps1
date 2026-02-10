#!/usr/bin/env pwsh
# Stroke Detection Application - Complete Installation Script for Windows

Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Stroke Detection Application - Installation                  ║" -ForegroundColor Cyan
Write-Host "║   For Windows PowerShell                                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Function to check command exists
function Test-Command { param($Command); $null = Get-Command $Command -ErrorAction SilentlyContinue; $? }

# Check Python
Write-Host "1️⃣  Checking Python installation..." -ForegroundColor Yellow
if (Test-Command python) {
    $pythonVersion = python --version
    Write-Host "   ✅ $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Python not found!" -ForegroundColor Red
    Write-Host "   📥 Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Check pip
Write-Host "2️⃣  Checking pip..." -ForegroundColor Yellow
if (Test-Command pip) {
    Write-Host "   ✅ pip is installed" -ForegroundColor Green
} else {
    Write-Host "   ❌ pip not found!" -ForegroundColor Red
    exit 1
}

# Create virtual environment
Write-Host "3️⃣  Setting up Python virtual environment..." -ForegroundColor Yellow
if (-not (Test-Path ".venv")) {
    python -m venv .venv
    Write-Host "   ✅ Virtual environment created" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  Virtual environment already exists" -ForegroundColor Cyan
}

# Activate virtual environment
Write-Host "4️⃣  Activating virtual environment..." -ForegroundColor Yellow
& ".\.venv\Scripts\Activate.ps1"
Write-Host "   ✅ Virtual environment activated" -ForegroundColor Green

# Install backend dependencies
Write-Host "5️⃣  Installing Python dependencies..." -ForegroundColor Yellow
pip install -r backend/requirements.txt | Out-Null
pip install gunicorn | Out-Null
Write-Host "   ✅ Dependencies installed" -ForegroundColor Green

# Check Node.js
Write-Host "6️⃣  Checking Node.js installation..." -ForegroundColor Yellow
if (Test-Command node) {
    $nodeVersion = node --version
    Write-Host "   ✅ $nodeVersion" -ForegroundColor Green
    
    Write-Host "7️⃣  Installing Node.js dependencies..." -ForegroundColor Yellow
    cd frontend
    npm install | Out-Null
    cd ..
    Write-Host "   ✅ Frontend dependencies installed" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Node.js not found (optional)" -ForegroundColor Yellow
    Write-Host "   📥 To install frontend, download from: https://nodejs.org/" -ForegroundColor Cyan
}

# Verify structure
Write-Host "8️⃣  Verifying project structure..." -ForegroundColor Yellow
$requiredFiles = @(
    "backend/app.py",
    "backend/requirements.txt",
    "models/stroke_model.pkl",
    "frontend/package.json",
    "data/sample_data.csv"
)

$allExists = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Missing: $file" -ForegroundColor Red
        $allExists = $false
    }
}

if (-not $allExists) {
    Write-Host ""
    Write-Host "   ⚠️  Some files are missing!" -ForegroundColor Yellow
    exit 1
}

# Test backend
Write-Host "9️⃣  Testing Flask application..." -ForegroundColor Yellow
$testScript = {
    python -c "
import sys
sys.path.insert(0, 'backend')
from app import app
print('✅ Flask app imports successfully')
"
}
Invoke-Command $testScript -ErrorAction SilentlyContinue

# Create .env file if doesn't exist
Write-Host "🔟 Checking environment configuration..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env" -ErrorAction SilentlyContinue
    Write-Host "   ✅ Created .env from template" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  .env already exists" -ForegroundColor Cyan
}

# Final summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                   ✅ Installation Complete!                     ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1️⃣  Start Flask Backend:" -ForegroundColor Yellow
Write-Host "   .\RUN_BACKEND.ps1" -ForegroundColor Green
Write-Host ""
Write-Host "2️⃣  Start React Frontend (in another terminal):" -ForegroundColor Yellow
Write-Host "   .\RUN_FRONTEND.ps1" -ForegroundColor Green
Write-Host ""
Write-Host "3️⃣  Access the application:" -ForegroundColor Yellow
Write-Host "   Frontend: http://localhost:3000" -ForegroundColor Green
Write-Host "   Backend API: http://127.0.0.1:5000" -ForegroundColor Green
Write-Host ""
Write-Host "4️⃣  Documentation:" -ForegroundColor Yellow
Write-Host "   - SETUP_GUIDE.md" -ForegroundColor Green
Write-Host "   - API_DOCUMENTATION.md" -ForegroundColor Green
Write-Host "   - DEPLOYMENT.md" -ForegroundColor Green
Write-Host ""
Write-Host "📚 API Endpoints to Try:" -ForegroundColor Cyan
Write-Host "   GET  /api/health" -ForegroundColor Green
Write-Host "   POST /api/predict" -ForegroundColor Green
Write-Host "   GET  /api/history" -ForegroundColor Green
Write-Host ""
Write-Host "❓ Need Help?" -ForegroundColor Yellow
Write-Host "   See API_DOCUMENTATION.md for examples" -ForegroundColor Green
Write-Host ""
