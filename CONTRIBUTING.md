# 🧠 Contributing to Neuro-Spicy DevKit

Welcome, friend! We are thrilled that you want to help make the **Neuro-Spicy DevKit** even better. Whether you're here to fix a bug, add a feature, or polish the documentation, your contributions are incredibly valuable.

As a project built by and for neurodivergent developers, we prioritize **clarity, directness, and predictability**. We want to make sure contributing is as stress-free and rewarding as possible. No hidden rules, no mind-reading required.

---

## 🏛️ GlitchWorks Agnostic Architecture Protocol

Since this repository provides a portable, multi-platform development environment, all scripts and tools must adhere to the **GlitchWorks Agnostic Architecture Protocol**. This ensures that our tools are robust, portable, and safe to run anywhere.

When writing or modifying scripts (PowerShell or Bash), always design with the following four pillars in mind:

### 1. Cross-Platform Portability
We support **Windows (PowerShell 5.1+ and PowerShell Core)** and **Linux/macOS (POSIX-compliant Bash 4+)**.
* **No Platform Assumptions**: Never assume a utility like `sed`, `awk`, or `grep` behaves the same way across GNU/Linux and macOS (BSD).
* **Dual Implementations**: If a script performs a system-level action, ensure both a `.ps1` (PowerShell) and `.sh` (Bash) equivalent exist and behave identically.
* **Line Endings**: Keep line endings consistent. Bash scripts (`.sh`) must use LF line endings, while PowerShell scripts (`.ps1`) can use LF or CRLF, but LF is preferred for repository consistency.

### 2. Dry-Run Safety
Any script that modifies the user's system, writes files, or changes configurations **must** support a dry-run mode.
* **The Flag**: Implement `--dry-run` or `-d` as a standard command-line argument.
* **The Behavior**: When dry-run is active, the script must print exactly what actions it *would* perform (e.g., "Would install Node.js", "Would write settings to ~/.bashrc") without actually executing them or modifying any files.
* **Verification**: Dry-run paths must be tested and validated to ensure they do not accidentally execute state-changing commands.

### 3. Environment Variable Sandboxing
Scripts must respect the user's shell environment and avoid polluting it.
* **Local Scopes**: In Bash, always use `local` for variables inside functions. In PowerShell, use local or script-scoped variables.
* **No Global Pollution**: Do not permanently modify global environment variables unless explicitly requested by the user or required for core functionality (and clearly documented).
* **Sandboxed Execution**: If a script depends on temporary environment variables, set them only for the duration of that script's execution.

### 4. Idempotent Script Execution
Running a script multiple times must be completely safe and produce the same final state.
* **Check Before Doing**: Before installing a tool, writing a configuration, or appending to a file, check if it has already been done.
* **No Duplications**: Never blindly append lines to files like `.bashrc` or `settings.json`. Always check if the line/setting already exists, or use idempotent block-replacement techniques.
* **Graceful Skipping**: If a step is already complete, log a helpful message (e.g., `[SKIP] Node.js is already installed`) and proceed without error.

---

## 🚧 Submodule Boundary Rule

The **Neuro-Spicy DevKit** is designed to be used as a standalone repository or as a **Git submodule** within larger superprojects (such as `dev-master`). 

To maintain clean boundaries:
* **Code & Product Docs Only**: This submodule must contain only its own code, configuration templates, and product-facing documentation.
* **No Monorepo Spillover**: Never commit internal workflows, private guides, or monorepo-specific notes belonging to a parent project inside this repository.
* **Self-Contained**: All scripts, tests, and guides in this repository must be fully self-contained and run independently of any parent project's environment.

---

## 📁 Repository Layout

To help you navigate, here is a clean breakdown of our directory structure:

| Path | Description |
| :--- | :--- |
| `init.sh` | Entrypoint script for Linux/macOS interactive initialization. |
| `init.ps1` | Entrypoint script for Windows PowerShell interactive initialization. |
| `scripts/` | Core scripts for setup, health checks, and testing. |
| `scripts/neuro-spicy-init.sh` | Interactive setup script for Linux/macOS. |
| `scripts/neuro-spicy-init.ps1` | Interactive setup script for Windows. |
| `scripts/neuro-spicy-setup-core.sh` | Core installation and configuration script for Linux/macOS. |
| `scripts/neuro-spicy-setup-core.ps1` | Core installation and configuration script for Windows. |
| `scripts/health-check-core.sh` | Environment validation and diagnostic script for Linux/macOS. |
| `scripts/health-check-core.ps1` | Environment validation and diagnostic script for Windows. |
| `scripts/test-bash-scripts.sh` | Automated test suite for validating Bash scripts syntax, help, and dry-runs. |
| `scripts/make-executable-core.sh` | Utility script to ensure all shell scripts have execution permissions. |
| `docs/` | Product-facing documentation and guides. |
| `docs/BEGINNER_JOURNEY.md` | Step-by-step onboarding guide for new users. |
| `docs/CORE_FOCUS_PLAN.md` | DevKit core philosophy and streamlining plan. |
| `docs/BASH_LINUX_DEFAULT.md` | Detailed guide for Linux/macOS environments. |
| `portable-dev-env/` | Portable configuration templates for editors and profiles. |
| `portable-dev-env/cursor/` | AI-powered development rules and context memories for Cursor. |
| `portable-dev-env/vscode/` | VSCode settings and extension recommendations. |
| `portable-dev-env/profiles/` | Custom profile templates for different developer workflows. |
| `LICENSE` | MIT License file. |

---

## 🚦 Quality Gates

Before submitting a Pull Request, your changes must pass through our quality gates. We expect all contributors to run these checks locally.

### 1. Linting & Syntax Checks
* **Bash Scripts**:
  * Run `bash -n <script>` to verify syntax.
  * Run `shellcheck <script>` to catch common shell script bugs and non-portable code. There should be zero warnings or errors.
* **PowerShell Scripts**:
  * Run `PSScriptAnalyzer` checks on any modified `.ps1` files to ensure they follow best practices and have no syntax errors.

### 2. Dry-Run Validation
* Any script that alters system state (installs tools, writes files, modifies configurations) must support a `--dry-run` or `-d` flag.
* Running the script with `--dry-run` must produce clear, descriptive output of all actions it *would* perform, without executing any of them.
* Verify your dry-run behavior using our test suite:
  ```bash
  ./scripts/test-bash-scripts.sh
  ```

### 3. Idempotency Validation
* Run your script once to apply changes.
* Run the exact same script a second time.
* **Gate**: The second run must succeed, must not duplicate any lines in user files, and should gracefully skip already-completed steps.

### 4. Cross-Platform Validation
* If you modify a Bash script, verify it on both Linux and macOS if possible.
* If you modify a PowerShell script, verify it on both Windows PowerShell 5.1 and PowerShell Core (6+).

---

## 🔄 Contribution Workflow

We follow a standard Git workflow with conventional commits.

### 1. Create a Branch
Create a descriptive branch from `main`:
```bash
git checkout -b docs/add-contributing-workflow
```

### 2. Commit Guidelines
We use **Conventional Commits** to keep our history clean and readable:
`type(scope): message`

* **Types**:
  * `feat`: A new feature or script
  * `fix`: A bug fix in a script or configuration
  * `docs`: Documentation changes (`CONTRIBUTING.md`, guides)
  * `refactor`: Refactoring script logic without changing behavior
  * `test`: Adding or updating tests
  * `chore`: Maintenance tasks or dependency updates
* **Example**:
  ```bash
  docs(scope): add contributing guidelines and standards
  ```

### 3. Push and Open a Pull Request
Push your branch to your fork or origin:
```bash
git push -u origin docs/add-contributing-workflow
```
Then open a Pull Request against the default branch (`main`) of the upstream repository.

---

Thank you for helping us build a mindful, AI-powered, and neurodivergent-friendly development environment! If you have any questions or need help, feel free to open an issue or reach out. Let's make coding awesome and maybe a little weird! 🚀🧠✨
