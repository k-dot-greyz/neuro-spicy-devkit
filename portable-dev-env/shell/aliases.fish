# Neuro-Spicy DevKit — fish shell adapter
# Requires: fish 3.x. Never source bash aliases in fish.

if not set -q NS_DEVKIT_ROOT
    set -l _shell_dir (dirname (status filename))
    set -gx NS_DEVKIT_ROOT (cd "$_shell_dir/../.."; and pwd)
end

set -gx NS_SCRIPTS "$NS_DEVKIT_ROOT/scripts"
set -gx NS_CLI "$NS_SCRIPTS/ns"

function ns_engine
    bash $NS_CLI $argv
end

function check
    bash $NS_SCRIPTS/health-check-core.sh $argv
end

function setup
    bash $NS_SCRIPTS/neuro-spicy-setup-core.sh $argv
end

function doctor
    bash $NS_SCRIPTS/doctor-core.sh $argv
end

function push
    bash $NS_SCRIPTS/git-push-retry.sh $argv
end

function dryrun
    bash $NS_SCRIPTS/neuro-spicy-setup-core.sh --dry-run $argv
end

# Optional: same name as bash `checkfix`
function checkfix
    bash $NS_SCRIPTS/health-check-core.sh --fix $argv
end
