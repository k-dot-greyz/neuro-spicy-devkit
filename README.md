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

## 🚀 Core Essentials Setup

**Lean, Focused Development Environment**

The most painful part of development? Environment setup. We've solved that with core essentials only.

### **One-Command Setup (Core Essentials)**
```bash
# Clone and setup
git clone https://github.com/yourusername/neuro-spicy-devkit.git && cd neuro-spicy-devkit

# Make scripts executable
chmod +x scripts/*.sh

# Check environment
./scripts/health-check-core.sh

# Setup core essentials
./scripts/neuro-spicy-setup-core.sh --components core
```

### **Core Commands (That's It!)**
```bash
./scripts/health-check-core.sh                    # Check environment
./scripts/neuro-spicy-setup-core.sh --components core  # Setup environment
./scripts/git-push-retry.sh --branch main         # Reliable git operations
```

### **Neuro-Spicy Core Features**
- **Low Cognitive Load**: Simple, clear commands
- **Fast Setup**: < 5 minutes to working environment
- **Error Recovery**: Graceful handling of failures
- **Progress Tracking**: Know where you are
- **Success Confirmation**: Clear completion signals
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