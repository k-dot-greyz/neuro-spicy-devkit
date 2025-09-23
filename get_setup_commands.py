#!/usr/bin/env python3
"""
Get Setup Commands for Current Environment - Neuro-Spicy Edition

This script detects your current environment and provides the exact commands
you need to run for a complete development setup. Designed for neurodivergent
developers who need reliable, repeatable setup procedures.

Motto: "Turning environment setup bugs into features"
"""

import os
import sys
import platform
import subprocess
from pathlib import Path

def detect_environment():
    """Detect the current environment and return setup commands"""
    
    # Detect OS
    os_name = platform.system().lower()
    if os_name == "windows":
        return get_windows_commands()
    elif os_name == "linux":
        return get_linux_commands()
    elif os_name == "darwin":
        return get_macos_commands()
    else:
        return get_generic_commands()

def get_windows_commands():
    """Windows-specific setup commands"""
    return {
        "platform": "Windows",
        "one_liner": "git clone https://github.com/yourusername/zenOS.git && cd zenOS && python setup.py",
        "prerequisites": [
            "winget install Git.Git",
            "winget install Python.Python.3.11", 
            "winget install OpenJS.NodeJS"
        ],
        "setup": [
            "git clone https://github.com/yourusername/zenOS.git",
            "cd zenOS",
            "python setup.py --unattended"
        ],
        "validation": "python setup.py --validate-only",
        "neuro_tips": [
            "Use PowerShell for better Unicode support",
            "Run as administrator if you get permission errors",
            "The --unattended flag avoids decision fatigue"
        ]
    }

def get_linux_commands():
    """Linux-specific setup commands"""
    return {
        "platform": "Linux",
        "one_liner": "git clone https://github.com/yourusername/zenOS.git && cd zenOS && python setup.py",
        "prerequisites": [
            "sudo apt update && sudo apt install git python3 python3-pip nodejs",
            "# Or for other distros:",
            "# sudo dnf install git python3 python3-pip nodejs  # Fedora",
            "# sudo pacman -S git python python-pip nodejs     # Arch"
        ],
        "setup": [
            "git clone https://github.com/yourusername/zenOS.git",
            "cd zenOS", 
            "python3 setup.py --unattended"
        ],
        "validation": "python3 setup.py --validate-only",
        "neuro_tips": [
            "Use tab completion for commands",
            "The setup system handles all the decisions",
            "Clear progress indicators show what's happening"
        ]
    }

def get_macos_commands():
    """macOS-specific setup commands"""
    return {
        "platform": "macOS",
        "one_liner": "git clone https://github.com/yourusername/zenOS.git && cd zenOS && python setup.py",
        "prerequisites": [
            "brew install git python node",
            "# If you don't have Homebrew:",
            "# /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        ],
        "setup": [
            "git clone https://github.com/yourusername/zenOS.git",
            "cd zenOS",
            "python3 setup.py --unattended"
        ],
        "validation": "python3 setup.py --validate-only",
        "neuro_tips": [
            "Homebrew handles all the complexity",
            "The setup system is predictable and reliable",
            "No need to remember complex commands"
        ]
    }

def get_generic_commands():
    """Generic setup commands for unknown platforms"""
    return {
        "platform": "Unknown",
        "one_liner": "git clone https://github.com/yourusername/zenOS.git && cd zenOS && python setup.py",
        "prerequisites": [
            "Install Git, Python 3.7+, and Node.js (optional)",
            "See DEV_ENVIRONMENT_SETUP.md for details"
        ],
        "setup": [
            "git clone https://github.com/yourusername/zenOS.git",
            "cd zenOS",
            "python setup.py --unattended"
        ],
        "validation": "python setup.py --validate-only",
        "neuro_tips": [
            "The setup system adapts to your environment",
            "One command handles everything",
            "Clear error messages if something goes wrong"
        ]
    }

def check_termux():
    """Check if running in Termux"""
    return os.environ.get("TERMUX_VERSION") is not None

def get_termux_commands():
    """Termux-specific setup commands"""
    return {
        "platform": "Termux (Android)",
        "one_liner": "pkg update && pkg upgrade && pkg install git python nodejs && git clone https://github.com/yourusername/zenOS.git && cd zenOS && python setup.py",
        "prerequisites": [
            "pkg update && pkg upgrade",
            "pkg install git python nodejs"
        ],
        "setup": [
            "git clone https://github.com/yourusername/zenOS.git",
            "cd zenOS",
            "python setup.py --unattended"
        ],
        "validation": "python setup.py --validate-only",
        "neuro_tips": [
            "Perfect for coding on the go",
            "The setup system works great on mobile",
            "No need to remember complex mobile commands"
        ]
    }

def print_commands(commands):
    """Print the setup commands in a neuro-friendly format"""
    print(f"\n🧠 Setup Commands for {commands['platform']}")
    print("=" * 50)
    
    print(f"\n📋 One-Command Setup:")
    print(f"   {commands['one_liner']}")
    
    print(f"\n🔧 Prerequisites (if not installed):")
    for cmd in commands['prerequisites']:
        print(f"   {cmd}")
    
    print(f"\n⚙️  Manual Setup Steps:")
    for i, cmd in enumerate(commands['setup'], 1):
        print(f"   {i}. {cmd}")
    
    print(f"\n✅ Validation:")
    print(f"   {commands['validation']}")
    
    if 'neuro_tips' in commands:
        print(f"\n🧠 Neuro-Spicy Tips:")
        for tip in commands['neuro_tips']:
            print(f"   • {tip}")
    
    print(f"\n📚 Full Guide: DEV_ENVIRONMENT_SETUP.md")
    print(f"📋 Cheat Sheet: DEV_SETUP_CHEAT_SHEET.md")

def main():
    """Main function"""
    print("🧠 Neuro-Spicy Dev Environment Setup")
    print("=" * 40)
    print("Turning environment setup bugs into features")
    print()
    
    # Check if we're in Termux
    if check_termux():
        commands = get_termux_commands()
    else:
        commands = detect_environment()
    
    print_commands(commands)
    
    # Check if zenOS is already available
    if Path("setup.py").exists():
        print(f"\n🎉 zenOS detected in current directory!")
        print(f"   Run: python setup.py --validate-only")
        print(f"   Or:  python setup.py --unattended")
    else:
        print(f"\n💡 Tip: Run the one-command setup above to get started!")
        print(f"   This will handle all the complexity for you!")

if __name__ == "__main__":
    main()
