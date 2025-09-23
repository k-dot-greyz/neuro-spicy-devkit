# 🧹 Cleanup Personal References Script
# Removes all personal references to make this a generic template

param(
    [switch]$DryRun,
    [switch]$Verbose
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Clean-File {
    param(
        [string]$FilePath,
        [hashtable]$Replacements
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-ColorOutput "⚠️ File not found: $FilePath" "Yellow"
        return
    }
    
    Write-ColorOutput "🧹 Cleaning: $FilePath" "Cyan"
    
    $content = Get-Content $FilePath -Raw
    $originalContent = $content
    
    foreach ($search in $Replacements.Keys) {
        $replace = $Replacements[$search]
        $content = $content -replace [regex]::Escape($search), $replace
    }
    
    if ($content -ne $originalContent) {
        if ($DryRun) {
            Write-ColorOutput "  Would replace personal references" "Yellow"
        } else {
            $content | Out-File -FilePath $FilePath -Encoding UTF8
            Write-ColorOutput "  ✅ Cleaned personal references" "Green"
        }
    } else {
        Write-ColorOutput "  No personal references found" "Blue"
    }
}

function Clean-Directory {
    param(
        [string]$Directory,
        [hashtable]$Replacements
    )
    
    if (-not (Test-Path $Directory)) {
        Write-ColorOutput "⚠️ Directory not found: $Directory" "Yellow"
        return
    }
    
    $files = Get-ChildItem -Path $Directory -Recurse -File | Where-Object { 
        $_.Extension -match '\.(md|json|ps1|sh|py|html|txt)$' -and 
        $_.Name -notlike '*.git*' 
    }
    
    foreach ($file in $files) {
        Clean-File -FilePath $file.FullName -Replacements $Replacements
    }
}

# Define replacements - only include actual personal references that need to be cleaned
$replacements = @{
    "yourusername" = "yourusername"
    "yourname.yourname@gmail.com" = "your.email@example.com"
    "k.yourname" = "yourname"
    "Your Name" = "Your Name"
    "yourname" = "yourname"
    "yourname" = "yourname"
    "yourname" = "yourname"
    "your-repo-name" = "your-repo-name"
    "yourname Foundry OS" = "Your Project Name"
    "human:yourname" = "human:yourname"
}

# Files to clean
$filesToClean = @(
    "README.md",
    "LICENSE",
    "docs/CORE_FOCUS_PLAN.md",
    "docs/PROMPTOS_ZENOS_INTEGRATION_PLAN.md",
    "docs/BASH_LINUX_DEFAULT.md",
    "portable-dev-env/scripts/neuro-spicy-setup.ps1",
    "portable-dev-env/scripts/neuro-spicy-setup.sh",
    "portable-dev-env/scripts/demo-workflow.sh",
    "portable-dev-env/scripts/README.md",
    "portable-dev-env/gists/gist-config.json",
    "scripts/integrate-promptos-zenos.ps1",
    "genesis-block-soundtrack.json",
    "soundtrack-player.html",
    "SOUNDTRACK.md",
    "DEV_ENVIRONMENT_SETUP.md",
    "DEV_SETUP_CHEAT_SHEET.md",
    "get_setup_commands.py",
    "NEURO_SPICY_INTEGRATION.md",
    "scripts/comprehensive-audit.ps1"
)

# Directories to clean
$directoriesToClean = @(
    "docs",
    "portable-dev-env",
    "scripts"
)

# Main execution
Write-ColorOutput "🧹 Personal References Cleanup" "Magenta"
Write-ColorOutput "=============================" "Magenta"
Write-ColorOutput ""

if ($DryRun) {
    Write-ColorOutput "🔍 DRY RUN MODE - No changes will be made" "Yellow"
    Write-ColorOutput ""
}

Write-ColorOutput "Replacing:" "Cyan"
foreach ($search in $replacements.Keys) {
    Write-ColorOutput "  '$search' → '$($replacements[$search])'" "White"
}
Write-ColorOutput ""

# Clean individual files
Write-ColorOutput "📄 Cleaning individual files..." "Cyan"
foreach ($file in $filesToClean) {
    Clean-File -FilePath $file -Replacements $replacements
}

Write-ColorOutput ""

# Clean directories
Write-ColorOutput "📁 Cleaning directories..." "Cyan"
foreach ($dir in $directoriesToClean) {
    Clean-Directory -Directory $dir -Replacements $replacements
}

Write-ColorOutput ""
Write-ColorOutput "🎉 Cleanup complete!" "Green"
Write-ColorOutput "===================" "Green"
Write-ColorOutput ""

if ($DryRun) {
    Write-ColorOutput "This was a dry run. To apply changes, run:" "Yellow"
    Write-ColorOutput ".\scripts\cleanup-personal-refs.ps1" "Blue"
} else {
    Write-ColorOutput "All personal references have been replaced with generic placeholders." "Green"
    Write-ColorOutput "The neuro-spicy devkit is now a generic template!" "Green"
}

Write-ColorOutput ""
Write-ColorOutput "🧠 Your neuro-spicy devkit is now ready for public release! 🚀" "Magenta"

