#!/bin/bash

# 🧪 Integration Test Suite — Neuro-Spicy DevKit
# Verifies: public access, health check, secrets detection, script interfaces

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

REPO="k-dot-greyz/neuro-spicy-devkit"
REPO_URL="https://github.com/${REPO}.git"
RAW_URL="https://raw.githubusercontent.com/${REPO}/main"
PASS=0
FAIL=0
SKIP=0

log_test() { echo -e "${CYAN}TEST: $1${NC}"; }
log_pass() { echo -e "${GREEN}  ✅ PASS: $1${NC}"; PASS=$((PASS + 1)); }
log_fail() { echo -e "${RED}  ❌ FAIL: $1${NC}"; FAIL=$((FAIL + 1)); }
log_skip() { echo -e "${YELLOW}  ⏭️ SKIP: $1${NC}"; SKIP=$((SKIP + 1)); }

# ============================================================
# 1. Public Access (no credentials required)
# ============================================================
log_test "Public repo clone via HTTPS"
CLONE_DIR="$(mktemp -d)"
if git clone --depth 1 --quiet "$REPO_URL" "$CLONE_DIR/repo" 2>/dev/null; then
    log_pass "git clone (no auth)"
    rm -rf "$CLONE_DIR"
else
    log_fail "git clone failed — repo may be private or network blocked"
    rm -rf "$CLONE_DIR"
fi

log_test "raw.githubusercontent.com access"
if curl -sf --proto '=https' --tlsv1.2 "${RAW_URL}/README.md" -o /dev/null 2>/dev/null; then
    log_pass "curl raw content (TLS-hardened)"
else
    log_fail "raw.githubusercontent.com unreachable"
fi

log_test "GitHub API access"
if command -v gh >/dev/null 2>&1; then
    if gh api "repos/${REPO}" --jq '.visibility' 2>/dev/null | grep -q "public"; then
        log_pass "gh api confirms public repo"
    else
        log_fail "gh api failed or repo not public"
    fi
else
    log_skip "gh CLI not installed"
fi

# ============================================================
# 2. Script Interfaces (syntax, --help, --dry-run)
# ============================================================
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_test "Bash syntax validation (all .sh scripts)"
syntax_fail=0
for f in "$SCRIPTS_DIR"/*.sh; do
    if ! bash -n "$f" 2>/dev/null; then
        log_fail "syntax: $(basename "$f")"
        syntax_fail=1
    fi
done
if [[ -f "$SCRIPTS_DIR/../init.sh" ]]; then
    bash -n "$SCRIPTS_DIR/../init.sh" 2>/dev/null || syntax_fail=1
fi
if [[ $syntax_fail -eq 0 ]]; then
    log_pass "all scripts pass bash -n"
fi

log_test "--help flags"
for script in health-check-core.sh neuro-spicy-setup-core.sh git-push-retry.sh setup-github-token.sh; do
    if [[ -f "$SCRIPTS_DIR/$script" ]]; then
        if bash "$SCRIPTS_DIR/$script" --help >/dev/null 2>&1; then
            log_pass "--help: $script"
        else
            log_fail "--help: $script"
        fi
    else
        log_skip "--help: $script (not found)"
    fi
done

log_test "--dry-run flags"
for script in neuro-spicy-setup-core.sh git-push-retry.sh setup-github-token.sh; do
    if [[ -f "$SCRIPTS_DIR/$script" ]]; then
        if bash "$SCRIPTS_DIR/$script" --dry-run >/dev/null 2>&1; then
            log_pass "--dry-run: $script"
        else
            log_fail "--dry-run: $script"
        fi
    else
        log_skip "--dry-run: $script (not found)"
    fi
done

# ============================================================
# 3. Health Check Full Run
# ============================================================
log_test "Health check runs to completion"
hc_output=$(GITHUB_TOKEN="ghp_test0000000000000000000000000000000000000" bash "$SCRIPTS_DIR/health-check-core.sh" 2>&1) || true
if echo "$hc_output" | grep -q "Total Checks:"; then
    log_pass "health check reaches summary"
    total=$(echo "$hc_output" | grep "Total Checks:" | awk '{print $NF}')
    passed=$(echo "$hc_output" | grep "Passed:" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $NF}')
    log_pass "reported $passed/$total checks passed"
else
    log_fail "health check did not reach summary (set -e killed it?)"
fi

# ============================================================
# 4. Secret Detection
# ============================================================
log_test "Secrets: detects GITHUB_TOKEN"
sec_output=$(GITHUB_TOKEN="ghp_test" bash "$SCRIPTS_DIR/health-check-core.sh" 2>&1) || true
if echo "$sec_output" | grep -q "GITHUB_TOKEN: Set"; then
    log_pass "GITHUB_TOKEN detected when set"
else
    log_fail "GITHUB_TOKEN not detected"
fi

log_test "Secrets: detects missing GITHUB_TOKEN"
sec_output2=$(unset GITHUB_TOKEN; bash "$SCRIPTS_DIR/health-check-core.sh" 2>&1) || true
if echo "$sec_output2" | grep -q "GITHUB_TOKEN: Not"; then
    log_pass "GITHUB_TOKEN absence detected"
else
    log_fail "missing GITHUB_TOKEN not flagged"
fi

log_test "Secrets: detects AI provider key"
sec_output3=$(GITHUB_TOKEN="ghp_test" ANTHROPIC_API_KEY="sk-ant-test" bash "$SCRIPTS_DIR/health-check-core.sh" 2>&1) || true
if echo "$sec_output3" | grep -q "ANTHROPIC_API_KEY: Set"; then
    log_pass "ANTHROPIC_API_KEY detected"
else
    log_fail "ANTHROPIC_API_KEY not detected"
fi

log_test "Secrets: detects missing AI keys"
sec_output4=$(GITHUB_TOKEN="ghp_test" bash "$SCRIPTS_DIR/health-check-core.sh" 2>&1) || true
if echo "$sec_output4" | grep -q "AI provider key: None"; then
    log_pass "missing AI keys flagged"
else
    log_fail "missing AI keys not flagged"
fi

# ============================================================
# 5. JSON Validation
# ============================================================
log_test "JSON template validation"
if command -v jq >/dev/null 2>&1; then
    json_dir="$SCRIPTS_DIR/../portable-dev-env/profiles/templates"
    if [[ -d "$json_dir" ]]; then
        json_fail=0
        for f in "$json_dir"/*.json; do
            if ! jq empty "$f" 2>/dev/null; then
                log_fail "invalid JSON: $(basename "$f")"
                json_fail=1
            fi
        done
        if [[ $json_fail -eq 0 ]]; then
            log_pass "all profile templates valid JSON"
        fi
    else
        log_skip "profiles/templates/ not found"
    fi
else
    log_skip "jq not installed"
fi

# ============================================================
# 6. Security regression: GITHUB_TOKEN must not be embedded in
#    the user-profile template (Bug: world-readable credential file)
# ============================================================
log_test "Security: neuro-spicy-init.sh does not embed GITHUB_TOKEN in profile JSON"
if grep -q '"githubToken".*GITHUB_TOKEN' "$SCRIPTS_DIR/neuro-spicy-init.sh" 2>/dev/null; then
    log_fail "GITHUB_TOKEN is still embedded in create_user_profile() — credential leak risk"
else
    log_pass "GITHUB_TOKEN not embedded in user profile template"
fi

# ============================================================
# 7. Correctness regression: --components minimal must exit 0
#    (Bug: test_setup() checked Cursor/VSCode configs that minimal
#    never installs, causing a false-failure exit on every run)
# ============================================================
log_test "--components minimal exits 0 (post-fix correctness check)"
if bash "$SCRIPTS_DIR/neuro-spicy-setup-core.sh" --components minimal --skip-backup >/dev/null 2>&1; then
    log_pass "--components minimal exits 0"
else
    log_fail "--components minimal exited non-zero — test_setup() may still be component-unaware"
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo -e "${MAGENTA}🧪 Integration Test Summary${NC}"
echo -e "${MAGENTA}===========================${NC}"
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo -e "${YELLOW}Skipped: $SKIP${NC}"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAIL test(s) failed${NC}"
    exit 1
fi
