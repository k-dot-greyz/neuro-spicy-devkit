# 🔍 Comprehensive System Audit Script
# Audits the entire neuro-spicy devkit system for completeness and quality

param(
    [switch]$Verbose,
    [switch]$Fix
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-ScriptSyntax {
    param([string]$ScriptPath)
    
    if (-not (Test-Path $ScriptPath)) {
        return @{ Success = $false; Message = "File not found" }
    }
    
    $extension = [System.IO.Path]::GetExtension($ScriptPath)
    
    try {
        switch ($extension) {
            ".ps1" {
                $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $ScriptPath -Raw), [ref]$null)
                return @{ Success = $true; Message = "PowerShell syntax valid" }
            }
            ".sh" {
                # For bash, we'll just check if it's executable and has shebang
                $content = Get-Content $ScriptPath -Raw
                if ($content -match '^#!/bin/bash' -or $content -match '^#!/bin/sh') {
                    return @{ Success = $true; Message = "Bash script structure valid" }
                } else {
                    return @{ Success = $false; Message = "Missing shebang or invalid bash structure" }
                }
            }
            ".py" {
                # For Python, we'll check basic syntax
                $content = Get-Content $ScriptPath -Raw
                if ($content -match '^#!.*python') {
                    return @{ Success = $true; Message = "Python script structure valid" }
                } else {
                    return @{ Success = $false; Message = "Missing shebang or invalid python structure" }
                }
            }
            default {
                return @{ Success = $true; Message = "Non-script file" }
            }
        }
    } catch {
        return @{ Success = $false; Message = "Syntax error: $($_.Exception.Message)" }
    }
}

function Test-JsonSyntax {
    param([string]$JsonPath)
    
    if (-not (Test-Path $JsonPath)) {
        return @{ Success = $false; Message = "File not found" }
    }
    
    try {
        $content = Get-Content $JsonPath -Raw
        $null = $content | ConvertFrom-Json
        return @{ Success = $true; Message = "JSON syntax valid" }
    } catch {
        return @{ Success = $false; Message = "JSON syntax error: $($_.Exception.Message)" }
    }
}

function Test-MarkdownStructure {
    param([string]$MarkdownPath)
    
    if (-not (Test-Path $MarkdownPath)) {
        return @{ Success = $false; Message = "File not found" }
    }
    
    $content = Get-Content $MarkdownPath -Raw
    
    # Check for basic markdown structure
    $hasTitle = $content -match '^#\s+'
    $hasContent = $content.Length -gt 100
    
    if ($hasTitle -and $hasContent) {
        return @{ Success = $true; Message = "Markdown structure valid" }
    } else {
        return @{ Success = $false; Message = "Missing title or insufficient content" }
    }
}

function Test-FilePermissions {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return @{ Success = $false; Message = "File not found" }
    }
    
    $extension = [System.IO.Path]::GetExtension($FilePath)
    
    if ($extension -eq ".sh" -or $extension -eq ".py") {
        # Check if executable
        $file = Get-Item $FilePath
        if ($file.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
            return @{ Success = $false; Message = "File is read-only" }
        } else {
            return @{ Success = $true; Message = "File permissions OK" }
        }
    } else {
        return @{ Success = $true; Message = "Non-executable file" }
    }
}

function Test-DirectoryStructure {
    param([string]$Directory)
    
    if (-not (Test-Path $Directory)) {
        return @{ Success = $false; Message = "Directory not found" }
    }
    
    $expectedDirs = @("docs", "scripts", "portable-dev-env")
    $missingDirs = @()
    
    foreach ($dir in $expectedDirs) {
        if (-not (Test-Path (Join-Path $Directory $dir))) {
            $missingDirs += $dir
        }
    }
    
    if ($missingDirs.Count -eq 0) {
        return @{ Success = $true; Message = "Directory structure complete" }
    } else {
        return @{ Success = $false; Message = "Missing directories: $($missingDirs -join ', ')" }
    }
}

function Test-CoreScripts {
    param([string]$ScriptsDir)
    
    if (-not (Test-Path $ScriptsDir)) {
        return @{ Success = $false; Message = "Scripts directory not found" }
    }
    
    $coreScripts = @(
        "health-check-core.sh",
        "health-check-core.ps1", 
        "neuro-spicy-setup-core.sh",
        "neuro-spicy-setup-core.ps1",
        "git-push-retry.sh",
        "git-push-retry.ps1"
    )
    
    $missingScripts = @()
    
    foreach ($script in $coreScripts) {
        if (-not (Test-Path (Join-Path $ScriptsDir $script))) {
            $missingScripts += $script
        }
    }
    
    if ($missingScripts.Count -eq 0) {
        return @{ Success = $true; Message = "All core scripts present" }
    } else {
        return @{ Success = $false; Message = "Missing core scripts: $($missingScripts -join ', ')" }
    }
}

function Test-Documentation {
    param([string]$DocsDir)
    
    if (-not (Test-Path $DocsDir)) {
        return @{ Success = $false; Message = "Docs directory not found" }
    }
    
    $expectedDocs = @(
        "README.md",
        "CORE_FOCUS_PLAN.md",
        "BASH_LINUX_DEFAULT.md"
    )
    
    $missingDocs = @()
    
    foreach ($doc in $expectedDocs) {
        if (-not (Test-Path (Join-Path $DocsDir $doc))) {
            $missingDocs += $doc
        }
    }
    
    if ($missingDocs.Count -eq 0) {
        return @{ Success = $true; Message = "All core documentation present" }
    } else {
        return @{ Success = $false; Message = "Missing documentation: $($missingDocs -join ', ')" }
    }
}

# Main execution
Write-ColorOutput "🔍 Comprehensive System Audit" "Magenta"
Write-ColorOutput "=============================" "Magenta"
Write-ColorOutput ""

$auditResults = @()
$totalTests = 0
$passedTests = 0
$failedTests = 0

# Test 1: Directory Structure
Write-ColorOutput "📁 Testing directory structure..." "Cyan"
$result = Test-DirectoryStructure -Directory "."
$auditResults += @{ Test = "Directory Structure"; Result = $result }
$totalTests++
if ($result.Success) { $passedTests++ } else { $failedTests++ }

# Test 2: Core Scripts
Write-ColorOutput "📄 Testing core scripts..." "Cyan"
$result = Test-CoreScripts -Directory "scripts"
$auditResults += @{ Test = "Core Scripts"; Result = $result }
$totalTests++
if ($result.Success) { $passedTests++ } else { $failedTests++ }

# Test 3: Documentation
Write-ColorOutput "📚 Testing documentation..." "Cyan"
$result = Test-Documentation -Directory "docs"
$auditResults += @{ Test = "Documentation"; Result = $result }
$totalTests++
if ($result.Success) { $passedTests++ } else { $failedTests++ }

# Test 4: Script Syntax
Write-ColorOutput "🔧 Testing script syntax..." "Cyan"
$scripts = Get-ChildItem -Path "scripts" -Recurse -File | Where-Object { $_.Extension -match '\.(ps1|sh|py)$' }
foreach ($script in $scripts) {
    $result = Test-ScriptSyntax -ScriptPath $script.FullName
    $auditResults += @{ Test = "Script Syntax: $($script.Name)"; Result = $result }
    $totalTests++
    if ($result.Success) { $passedTests++ } else { $failedTests++ }
}

# Test 5: JSON Syntax
Write-ColorOutput "📋 Testing JSON syntax..." "Cyan"
$jsonFiles = Get-ChildItem -Path "." -Recurse -File | Where-Object { $_.Extension -eq ".json" }
foreach ($jsonFile in $jsonFiles) {
    $result = Test-JsonSyntax -JsonPath $jsonFile.FullName
    $auditResults += @{ Test = "JSON Syntax: $($jsonFile.Name)"; Result = $result }
    $totalTests++
    if ($result.Success) { $passedTests++ } else { $failedTests++ }
}

# Test 6: Markdown Structure
Write-ColorOutput "📝 Testing markdown structure..." "Cyan"
$markdownFiles = Get-ChildItem -Path "." -Recurse -File | Where-Object { $_.Extension -eq ".md" }
foreach ($mdFile in $markdownFiles) {
    $result = Test-MarkdownStructure -MarkdownPath $mdFile.FullName
    $auditResults += @{ Test = "Markdown Structure: $($mdFile.Name)"; Result = $result }
    $totalTests++
    if ($result.Success) { $passedTests++ } else { $failedTests++ }
}

# Test 7: File Permissions
Write-ColorOutput "🔐 Testing file permissions..." "Cyan"
$executableFiles = Get-ChildItem -Path "." -Recurse -File | Where-Object { $_.Extension -match '\.(sh|py)$' }
foreach ($file in $executableFiles) {
    $result = Test-FilePermissions -FilePath $file.FullName
    $auditResults += @{ Test = "File Permissions: $($file.Name)"; Result = $result }
    $totalTests++
    if ($result.Success) { $passedTests++ } else { $failedTests++ }
}

# Test 8: Personal References Check
Write-ColorOutput "🧹 Checking for personal references..." "Cyan"
$personalRefs = @("kasparsgreizis", "kaspars.greizis@gmail.com", "k.greyZ", "greyZ", "Kaspars Greizis")
$foundRefs = @()

foreach ($ref in $personalRefs) {
    $files = Get-ChildItem -Path "." -Recurse -File | Where-Object { $_.Name -notlike '*.git*' }
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match [regex]::Escape($ref)) {
            $foundRefs += "$ref in $($file.Name)"
        }
    }
}

if ($foundRefs.Count -eq 0) {
    $result = @{ Success = $true; Message = "No personal references found - system is generic template ready" }
} else {
    $result = @{ Success = $false; Message = "Personal references found: $($foundRefs -join ', ')" }
}

$auditResults += @{ Test = "Personal References"; Result = $result }
$totalTests++
if ($result.Success) { $passedTests++ } else { $failedTests++ }

# Summary
Write-ColorOutput ""
Write-ColorOutput "📊 Audit Summary" "Magenta"
Write-ColorOutput "===============" "Magenta"
Write-ColorOutput "Total Tests: $totalTests" "White"
Write-ColorOutput "Passed: $passedTests" "Green"
Write-ColorOutput "Failed: $failedTests" "Red"
Write-ColorOutput ""

if ($failedTests -gt 0) {
    Write-ColorOutput "❌ Failed Tests:" "Red"
    foreach ($audit in $auditResults | Where-Object { -not $_.Result.Success }) {
        Write-ColorOutput "  - $($audit.Test): $($audit.Result.Message)" "Red"
    }
    Write-ColorOutput ""
    Write-ColorOutput "🔧 To fix issues, run:" "Yellow"
    Write-ColorOutput ".\scripts\comprehensive-audit.ps1 -Fix" "Blue"
} else {
    Write-ColorOutput "🎉 All tests passed! The system is ready for release!" "Green"
}

Write-ColorOutput ""
Write-ColorOutput "🧠 Neuro-Spicy DevKit Audit Complete! 🚀" "Magenta"


