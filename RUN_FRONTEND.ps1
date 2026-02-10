#!/usr/bin/env pwsh
# Stroke Detection - Frontend Startup Script

Write-Host "Stroke Detection - React Frontend" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js and npm are not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After installation, run:" -ForegroundColor Yellow
    Write-Host "  npm install" -ForegroundColor Green
    Write-Host "  npm start" -ForegroundColor Green
    exit 1
}

Set-Location frontend
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm install

Write-Host ""
Write-Host "Starting React Development Server..." -ForegroundColor Yellow
Write-Host "Frontend will be available at: http://localhost:3000" -ForegroundColor Green
Write-Host "Make sure Flask backend is running on port 5000" -ForegroundColor Yellow
Write-Host ""

npm start
