# 🚀 Neuro-Spicy DevKit - Quick Launcher
# Simple launcher for the interactive initialization script

Write-Host "🧠 Neuro-Spicy DevKit - Quick Start" -ForegroundColor Magenta
Write-Host "=================================" -ForegroundColor Magenta
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "scripts/neuro-spicy-init.ps1")) {
    Write-Host "❌ Please run this script from the neuro-spicy-devkit root directory" -ForegroundColor Red
    exit 1
}

Write-Host "🚀 Starting interactive initialization..." -ForegroundColor Green
Write-Host ""

# Run the main initialization script
& "./scripts/neuro-spicy-init.ps1"
