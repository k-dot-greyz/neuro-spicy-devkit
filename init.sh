#!/bin/bash

# 🚀 Neuro-Spicy DevKit - Quick Launcher
# Simple launcher for the interactive initialization script

echo -e "\033[0;35m🧠 Neuro-Spicy DevKit - Quick Start\033[0m"
echo -e "\033[0;35m=================================\033[0m"
echo ""

# Check if we're in the right directory
if [ ! -f "scripts/neuro-spicy-init.sh" ]; then
    echo -e "\033[0;31m❌ Please run this script from the neuro-spicy-devkit root directory\033[0m"
    exit 1
fi

echo -e "\033[0;32m🚀 Starting interactive initialization...\033[0m"
echo ""

# Make the script executable and run it
chmod +x scripts/neuro-spicy-init.sh
./scripts/neuro-spicy-init.sh
