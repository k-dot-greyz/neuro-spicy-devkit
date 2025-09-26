# 🧠 Neuro-Spicy DevKit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Cross-Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue.svg)](https://github.com/yourusername/neuro-spicy-devkit)

**Neuro-Spicy DevKit** is a lean, mean development environment setup tool designed for ADHD/autism-friendly workflows. It provides a clean, portable development environment that can be easily customized and shared.

## ✨ Features

- 🚀 **One-Command Setup**: Interactive initialization with guided prompts
- 🔧 **Cross-Platform**: Windows (PowerShell) and Linux/macOS (Bash) support
- 📦 **Portable**: Easy to clone, customize, and share
- 🎯 **Lean & Mean**: Focused on essential tools only
- 🔒 **Secure**: MIT licensed with no personal data collection
- 🌈 **Customizable**: JSON-based profile system for different workflows
- 📚 **Well-Documented**: Clear guides for beginners and advanced users

## 🚀 Quick Start

### Prerequisites

- **Windows**: PowerShell 5.1+ or PowerShell Core
- **Linux/macOS**: Bash shell
- **Git**: For version control
- **Node.js**: For MCP servers (optional)

### Installation

`ash
# Clone the repository
git clone https://github.com/yourusername/neuro-spicy-devkit.git
cd neuro-spicy-devkit

# Run the interactive setup
# Windows
.\init.ps1

# Linux/macOS
./init.sh
`

The interactive setup will guide you through:
1. **Git Configuration** - Set up your name and email
2. **GitHub Token** - Configure GitHub authentication
3. **Cursor Setup** - Configure AI-powered development
4. **Health Check** - Verify all tools are working

## 📁 Project Structure

`
neuro-spicy-devkit/
├── init.ps1                     # Windows quick launcher
├── init.sh                      # Linux/macOS quick launcher
├── scripts/                     # Core setup scripts
│   ├── neuro-spicy-init.ps1     # Windows interactive setup
│   ├── neuro-spicy-init.sh     # Linux/macOS interactive setup
│   ├── health-check-core.ps1   # Windows health check
│   ├── health-check-core.sh    # Linux/macOS health check
│   └── ...
├── docs/                        # Documentation
│   ├── CORE_FOCUS_PLAN.md      # Core philosophy
│   ├── BASH_LINUX_DEFAULT.md   # Bash/Linux guide
│   └── BEGINNER_JOURNEY.md      # Beginner's guide
├── portable-dev-env/            # Portable development environment
│   ├── cursor/                  # Cursor configuration
│   ├── vscode/                  # VSCode configuration
│   ├── profiles/                # Profile templates
│   └── docs/                    # Usage documentation
└── LICENSE                      # MIT License
`

## 🎯 Core Philosophy

The Neuro-Spicy DevKit follows these principles:

1. **Simplicity First**: Minimal setup, maximum productivity
2. **Portability**: Easy to share and customize
3. **Accessibility**: ADHD/autism-friendly workflows
4. **Cross-Platform**: Works everywhere
5. **Open Source**: MIT licensed, community-driven

## 📚 Documentation

- **[Core Focus Plan](docs/CORE_FOCUS_PLAN.md)** - Understanding the philosophy
- **[Bash/Linux Default](docs/BASH_LINUX_DEFAULT.md)** - Linux/macOS setup guide
- **[Beginner's Journey](docs/BEGINNER_JOURNEY.md)** - Step-by-step guide for new users
- **[Usage Guide](portable-dev-env/docs/USAGE_GUIDE.md)** - Advanced usage patterns

## 🔧 Customization

The devkit uses a profile-based system for customization:

`json
{
  "name": "frontend-developer",
  "description": "Frontend development profile",
  "tools": ["node", "npm", "git"],
  "mcp_servers": ["docker", "github"],
  "shell_config": "bash"
}
`

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

Neuro-Spicy DevKit is MIT licensed. See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

Built with ❤️ for the neurodivergent developer community.

---

**"Code with confidence, develop with purpose"** 🧠✨

# GlitchWorks

it does

## 💰 Support This Project

Help us build amazing things! Your support keeps this project alive and growing.

### 🚀 Quick Donate
[![Donate Crypto](https://img.shields.io/badge/Donate-Crypto-brightgreen?style=for-the-badge&logo=bitcoin&logoColor=white)](https://github.com/GlitchWorks)

### 💳 Supported Cryptocurrencies



#### Bitcoin (BTC)
```
bc1q3rfg8nxtqtmqvqk9yted68j3ny9v3xzlh2tqen
```

![BTC QR Code](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAXIAAAFyAQAAAADAX2ykAAACsklEQVR4nO1aUWrkMAyVlUA/E9gDzFEyNyt7s/goPcBC8llw0CLZzmRccBzYzsaN3keoR48iEJKfJBuCI7B4iA6g/Dxwx55C+Xngjj2F8vPAHXsK5eeBO/YUyr8C3wS0ALYPR4A5fDzuL/SnHHiAe2H+QIwJwLxPi4GBHBjTNyy+GjHRuf0vBl6UP8cMtZzEEtWxcyC/+cR+rT+lwGLmNfltciZ7B/DJOnyY1/uDyv9WvnnnWmz7hdO5IRr/8f/fA+4ynqH8svztOGdnrs/9n5aGjxYI5sVIJtOJ/Ufll/CtSOReqvIbSerGz+Ll8zO/GKj8/8oHegZnMomclr9SjGfzH5WfB4WoOpD+iGgKt64cYYgfjW/FfJJYcpClIEt/tOl/f9+IK/Xr/CkHHuBeOH8Hia+HtL6cq53bWDV/q75/JwAfVR9Gb3A82HJAYxxiaXxr40PIUA6jv3DX63hkq/9EzaXxrVg/g4Q2CCpO2OmLutb41q2fGy7NTcxVEH0lWH87m/+o/LL9Qsv6+dOYe+fikqHjIs1Hrt4JvxSo/HPUZ+dlVLiJ10kHRBGt9blmvjUt+NSVWszHIK04sWV6qf1vjXyIHe5javVY6DehEw6dkuZv1fUZNgV5WkM7NdsirfGtvf8NkP6oCfqZs1vzt2I++V7IjzGCYA7rQq+0PnU/WPN+34RT48Amj3LmX453/nHJfzb/UfmH3k+SNLwsmB87JeDnHKqff8b7SYYPrb2FSPtN/3hq/0uBF94PDiKj4iZpM45W/fxz3scCuJbHlY4AlpbsjcDA/EZmGM/oPyo/D1pXR4+GKIwru3VTqPlbKx/irEoQHuR4VQU+vnE6rfGttz7Tel4fPIdMBo91U3g2/1H5WWDe/AXKzwN37CmUnwfu2FMoPw/csadQfh7fra/+AlDLOKl2jaeJAAAAAElFTkSuQmCC)




#### Ethereum (ETH)
```
17615664617464603742703041625285135091637690948
```

![ETH QR Code](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAUoAAAFKAQAAAABTUiuoAAACFUlEQVR4nO2aQYrkMAxFv5TALF3QB5ijdG5WV0uO0jeIlw0JGiTLaWZR4F40MW39RSp23kIgvi3ZRYJGbdxKAoFyoAi0WRwoAm0WBwoVuWbQouNNB0uu00tPsTaJfzX6Lqrd3k+iZ3mbbFY6i7VF/LvRXC20PSbB9gBkLaabu4u1QTwKmme12uFr4g0BvBS//jQoKuooIP+R/mMdD539N2l2MkA6kO3vUaalp1g5UOAqAumh9cYO0PPDsniWkrCzWDG6t+QaC/JJ9nC//XQAHCi+iZLaqtZ/k9CSbCU8yTuvnmIdGUVpqVZMAmiOrPPSUqO0X1odOsJ3x8rDoyipEDEzacpqT+xzqQ7W22PlQKHyRTAdkDVdrVYp489YCbtB4cbRRMluttKUqcuuRdBXR747Vh4ehedjr/uWLYdlaM1yimz1t2/taqv9OsuopxpuushWdyh53e6O+tq8Yt/qqzsmpE+SjSYhYDoIyT/T+/5We2e+O1YOFCpbCa2sKLXFmolst7Kv4a3evFU0HbI9dk3ZOQP57aiVh+r2WDlQ/H93TEvW635rtTRRei/ZWawDo6gVvB2/X3V7OdXwuagJe0VFdzB6yid9JS/2rV69JdpgubQxvhAJb6EbNPnJu/3dyfqtehBf10R0EytG95bLyngdmsHsAqWU9uEtVYd3xyiP6+WI7riK0SwOFIE2iwNFoM3i4dF/giVM58wZs3YAAAAASUVORK5CYII=)




#### Solana (SOL)
```
Eh8yq5CWVVJu5dM73XxQzTnptaRwpKGeXMNqnTKPqqkw
```

![SOL QR Code](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAXIAAAFyAQAAAADAX2ykAAACvklEQVR4nO1bbYqkQAxNRaF/KuwB5ijODfZIwx5pblB1lD5Ag/4csMmS1Me2DlTZCzra5v1wtPJoAo9XJrHGEDwDh0/RAZSfBxbicyg/DyzE51B+HliIz6H8PLAQn0P5Z+CbgBrAteERHF9giLH3DfNZDnyCe2J+R4wewHz0dxPW+oqLr0pCtO/8FwNPyh+iQx2bmOU2hp3Ma97Y2+azFLiY6XF2Plm+/OGtuUtO/sF8SsAi49z8evZsOtmJm1sN0Iw1wbBtPqj8VfRtWFbW0rW3WiSWi+k+w91//j4qfw98JyVyy1XV9ULmgy/vw4WVvfvyedt8FgOXU0/sX/q34N5GtvMI5N6+DE3du7/8Ufl5kG9+WFDuj4h6boh66ZlGbpKkUwo8snvLH5W/RN/Oy5dEZmkBKvLSWrlTfQ/Ih+DL1BqxlmJi8S/ZJphY/XtIPnjdvGFlkxYZRVUKl+hp1fe4+vYVmzjOIkVaaJKx+U71PXR9RXFD5kX/1m1C4AGq73HrK/j2WD34V+urQ/IhvnAfVfVvYuulnb6Y95Y/Kj8P8oaNrW+slaW0okfh1b8Hnl+5thoNNDywGqoR3O8bj6N/sXfv/JGh3SofVP46/q3it3w/vwrlNKQiWv177PnzyK/ZHoKJ4W6IHwmGegyBTfJB5a9TP49pTJVGkyR3aRKt/j3y/CpAauVQREOYOmv9/ELnJzv+YOTRfPH5yenaPvNfDjz5+UmyLKiYuLteop1lbct8FgOXU8/e/wIX0XGgEWeWCbo/vwTf8IFYslw/20FO5STNfySfErDImOLsfKKr7MWxHbbNCHISS/9/4SXOT5rukydZELverr/X0FluhzfJB5W/xvs3oJqc1KHU/+r3/Vc5P0nhb+x/A2iv+aPys8B8+BuUnwcW4nMoPw8sxOdQfh5YiM+h/DzWrq/+AvLyF+aJ0YLpAAAAAElFTkSuQmCC)




### 🎯 Donation Tips
- **Test First**: Send a small amount to verify the address
- **Privacy**: Addresses rotate for privacy protection
- **Support**: Your donations help maintain and improve this project
- **Questions**: Open an issue for any donation-related questions

### 📊 What Your Support Enables
- 🐛 Bug fixes and improvements
- 🚀 New features and enhancements
- 📚 Documentation and tutorials
- 🎨 UI/UX improvements
- 🔧 Infrastructure and hosting

---

**Thank you for supporting GlitchWorks!** 🙏


🔗 **Project**: [GlitchWorks](https://github.com/k-dot-greyz/GlitchWorks)

