#!/usr/bin/env pwsh
# Stroke Detection - Backend Startup Script

Write-Host "Stroke Detection - Flask Backend" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

$venvPath = ".venv\Scripts\python.exe"
$appPath = "backend\app.py"

Write-Host "Starting Flask Backend..." -ForegroundColor Yellow
Write-Host "API will be available at: http://127.0.0.1:5000" -ForegroundColor Green
Write-Host ""

& $venvPath $appPath
