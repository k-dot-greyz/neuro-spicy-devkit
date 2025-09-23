# neuro-spicy-devkit
init blueprint 

# The Neuro-Spicy Devkit: An API for a Different Processor

## Core Philosophy

This is not a self-help guide. It's a devkit. We are not "broken" people needing to be fixed. We are running a different, highly-specialized operating system on different hardware. This devkit is a collection of drivers, utilities, and community-tested middleware to help us interface with a world built for a more common OS.

**Motto:** _Turning bugs into features._

## Guiding Principles

1.  **Embrace the Architecture:** Our "bugs" (hyperfocus, sensitivity, pattern-matching obsession, context-switching latency) are features. The goal is not to suppress them, but to understand their APIs and write code that leverages them.
2.  **Pragmatism over Theory:** If a hack works, it works. This is a space for practical, DIY solutions that solve real problems, not for endless theoretical debates.
3.  **Forking is Encouraged:** This is open source for the self. Take what you need, adapt it, and build your own custom "distro." There is no one-size-fits-all solution.
4.  **Documentation is Self-Respect:** We document our personal APIs, our mental models, and our environmental configs because future-us will need it. It's an act of kindness to the person you will be tomorrow.

## Who is this for?

For the ADHD coder who has 150 browser tabs open. For the autistic systems thinker who needs to script their social interactions. For anyone who feels like they're trying to run `macOS` on `x86` hardware and wondering why it keeps kernel panicking.

## 🚀 Dev Environment Setup

**Your One Anchor Point for All Development Setups**

The most painful part of development? Environment setup. We've solved that.

### **One-Command Setup (Any Environment)**
```bash
# Option 1: Full zenOS setup (includes everything)
git clone https://github.com/kasparsgreizis/zenOS.git && cd zenOS && python setup.py

# Option 2: Portable Dev Environment (Cursor/VSCode optimized)
git clone https://github.com/kasparsgreizis/neuro-spicy-devkit.git && cd neuro-spicy-devkit
./portable-dev-env/scripts/setup.sh --platform linux --components all
```

### **Quick Reference**
- **[Complete Guide](DEV_ENVIRONMENT_SETUP.md)** - Your anchor point for all dev setups
- **[Cheat Sheet](DEV_SETUP_CHEAT_SHEET.md)** - One-page quick reference
- **[Smart Commands](get_setup_commands.py)** - Get environment-specific setup commands
- **[Portable Dev Environment](portable-dev-env/README.md)** - Cross-platform Cursor/VSCode setup

### **Neuro-Spicy Features**
- **Hyperfocus-Friendly**: One command, no decision fatigue
- **Context-Switching Support**: Phase-based, resumable setup
- **Sensory-Friendly**: Minimal output, predictable behavior
- **Executive Function Support**: AI-powered troubleshooting
- **AI-Optimized**: Casual, engaging AI interaction tailored for ADHD/autism
- **Portable**: Deploy anywhere, share via GitHub Gists

### **Get Started**
```bash
# Get commands for your environment
python get_setup_commands.py

# Or just run the one-command setup
git clone https://github.com/kasparsgreizis/zenOS.git && cd zenOS && python setup.py

# Or setup portable dev environment
./portable-dev-env/scripts/setup.sh --platform linux --components all
```

*"Turning environment setup bugs into features, one setup at a time."*