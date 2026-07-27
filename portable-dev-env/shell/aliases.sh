#!/bin/bash
# 🧠 Neuro-Spicy DevKit — Shell Aliases & Shortcuts
# Source this from ~/.bashrc or ~/.zshrc:
#   [ -f /path/to/neuro-spicy-devkit/portable-dev-env/shell/aliases.sh ] && source /path/to/neuro-spicy-devkit/portable-dev-env/shell/aliases.sh

# === Dev lifecycle ===
alias dev='npm run dev 2>/dev/null || cargo run 2>/dev/null || python3 -m flask run 2>/dev/null || echo "No dev command found"'
alias build='npm run build 2>/dev/null || cargo build --release 2>/dev/null || echo "No build command found"'
alias test='npm test 2>/dev/null || cargo test 2>/dev/null || python3 -m pytest 2>/dev/null || echo "No test command found"'
alias start='npm start 2>/dev/null || cargo run 2>/dev/null || echo "No start command found"'

# === Linting (polyglot) ===
alias lint='shellcheck scripts/*.sh 2>/dev/null; npx eslint . 2>/dev/null; cargo clippy 2>/dev/null; ruff check . 2>/dev/null'
alias fmt='shfmt -w -i 4 -ci scripts/*.sh 2>/dev/null; npx prettier --write . 2>/dev/null; cargo fmt 2>/dev/null; ruff format . 2>/dev/null'

# === Git shortcuts ===
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gb='git branch -vv'
alias gpull='git pull --rebase'
alias push='./scripts/git-push-retry.sh'

# === Neuro-Spicy DevKit ===
alias check='bash scripts/health-check-core.sh --verbose'
alias checkfix='bash scripts/health-check-core.sh --fix'
alias setup='bash scripts/neuro-spicy-setup-core.sh'
alias dryrun='bash scripts/neuro-spicy-setup-core.sh --dry-run'

# === Docker shortcuts ===
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dcb='docker compose build'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dclean='docker system prune -f'

# === Navigation ===
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lahF'
alias la='ls -A'
alias l='ls -CF'

# === Safety nets ===
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# === Cleanup ===
alias nuke='rm -rf node_modules dist build .next .astro target __pycache__ .pytest_cache .ruff_cache'
alias prune='git fetch --prune && git branch --merged | grep -v "main\|master\|\*" | xargs -r git branch -d'

# === Quick edits ===
alias hosts='sudo $EDITOR /etc/hosts'
alias bashrc='$EDITOR ~/.bashrc && source ~/.bashrc'
alias zshrc='$EDITOR ~/.zshrc && source ~/.zshrc'

# === System info ===
alias ports='ss -tulnp 2>/dev/null || netstat -tulnp 2>/dev/null'
alias myip='curl -s ifconfig.me'
alias diskuse='df -h | grep -v tmpfs | grep -v udev'
