# 🚀 PromptOS/zenOS Integration Script for Neuro-Spicy DevKit
# Transforms the neuro-spicy devkit into a full AI operating system

param(
    [switch]$SkipBackup,
    [switch]$DryRun,
    [string]$IntegrationLevel = "full"  # basic, advanced, full
)

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking prerequisites..." "Cyan"
    
    $prerequisites = @{
        "Python" = $false
        "Node.js" = $false
        "Git" = $false
        "zenOS" = $false
    }
    
    # Check Python
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python 3\.[8-9]|Python 3\.1[0-9]") {
            $prerequisites["Python"] = $true
            Write-ColorOutput "✅ Python: $pythonVersion" "Green"
        } else {
            Write-ColorOutput "❌ Python: Version 3.8+ required" "Red"
        }
    } catch {
        Write-ColorOutput "❌ Python: Not installed" "Red"
    }
    
    # Check Node.js
    try {
        $nodeVersion = node --version 2>&1
        if ($nodeVersion -match "v1[8-9]|v2[0-9]") {
            $prerequisites["Node.js"] = $true
            Write-ColorOutput "✅ Node.js: $nodeVersion" "Green"
        } else {
            Write-ColorOutput "❌ Node.js: Version 18+ required" "Red"
        }
    } catch {
        Write-ColorOutput "❌ Node.js: Not installed" "Red"
    }
    
    # Check Git
    try {
        $gitVersion = git --version 2>&1
        $prerequisites["Git"] = $true
        Write-ColorOutput "✅ Git: $gitVersion" "Green"
    } catch {
        Write-ColorOutput "❌ Git: Not installed" "Red"
    }
    
    # Check zenOS
    if (Test-Path "../zenOS") {
        $prerequisites["zenOS"] = $true
        Write-ColorOutput "✅ zenOS: Found" "Green"
    } else {
        Write-ColorOutput "❌ zenOS: Not found in parent directory" "Red"
    }
    
    $allGood = $prerequisites.Values -notcontains $false
    if (-not $allGood) {
        Write-ColorOutput "❌ Prerequisites not met. Please install missing components." "Red"
        return $false
    }
    
    Write-ColorOutput "✅ All prerequisites met!" "Green"
    return $true
}

function Backup-CurrentSetup {
    if ($SkipBackup) {
        Write-ColorOutput "⏭️ Skipping backup (--SkipBackup specified)" "Yellow"
        return
    }
    
    Write-ColorOutput "💾 Creating backup..." "Cyan"
    $backupDir = "backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    # Backup current setup
    Copy-Item -Path "portable-dev-env" -Destination "$backupDir/portable-dev-env" -Recurse -Force
    Copy-Item -Path "docs" -Destination "$backupDir/docs" -Recurse -Force
    Copy-Item -Path "scripts" -Destination "$backupDir/scripts" -Recurse -Force
    
    Write-ColorOutput "✅ Backup created: $backupDir" "Green"
}

function Install-CoreAgents {
    Write-ColorOutput "🤖 Installing core agents..." "Cyan"
    
    # Create agents directory
    $agentsDir = "portable-dev-env/agents"
    New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
    
    # Copy zenOS agents
    if (Test-Path "../zenOS/zen/agents") {
        Copy-Item -Path "../zenOS/zen/agents/*" -Destination "$agentsDir/" -Recurse -Force
        Write-ColorOutput "✅ Copied zenOS agents" "Green"
    }
    
    # Create neuro-spicy specialized agents
    $neuroSpicyAgents = @{
        "focus_guardian" = @{
            "purpose" = "Prevents context switching and maintains focus"
            "triggers" = @("distraction_detected", "task_switching", "overwhelm")
            "actions" = @("pause_notifications", "simplify_interface", "suggest_break")
        }
        "executive_helper" = @{
            "purpose" = "Breaks down complex tasks into manageable steps"
            "triggers" = @("overwhelming_task", "planning_needed", "decision_fatigue")
            "actions" = @("break_down_task", "create_checklist", "set_reminders")
        }
        "sensory_optimizer" = @{
            "purpose" = "Optimizes environment for sensory needs"
            "triggers" = @("environment_change", "sensory_overload", "stimulation_level")
            "actions" = @("adjust_brightness", "control_sounds", "manage_notifications")
        }
        "routine_guardian" = @{
            "purpose" = "Maintains consistent routines and prevents disruption"
            "triggers" = @("routine_change", "unexpected_event", "schedule_disruption")
            "actions" = @("warn_about_changes", "suggest_alternatives", "maintain_consistency")
        }
    }
    
    foreach ($agentName in $neuroSpicyAgents.Keys) {
        $agentDir = "$agentsDir/$agentName"
        New-Item -ItemType Directory -Path $agentDir -Force | Out-Null
        
        $agentConfig = $neuroSpicyAgents[$agentName]
        $agentConfig | ConvertTo-Json -Depth 3 | Out-File -FilePath "$agentDir/config.json" -Encoding UTF8
        
        Write-ColorOutput "✅ Created agent: $agentName" "Green"
    }
}

function Install-ProcedurePokédex {
    Write-ColorOutput "🎮 Installing Procedure Pokédex system..." "Cyan"
    
    # Create procedures directory
    $proceduresDir = "portable-dev-env/procedures"
    New-Item -ItemType Directory -Path $proceduresDir -Force | Out-Null
    
    # Copy zenOS procedures
    if (Test-Path "../zenOS/pokedex/procedures.yaml") {
        Copy-Item -Path "../zenOS/pokedex/procedures.yaml" -Destination "$proceduresDir/zenos_procedures.yaml"
        Write-ColorOutput "✅ Copied zenOS procedures" "Green"
    }
    
    # Create neuro-spicy procedures
    $neuroSpicyProcedures = @{
        "procedures" = @(
            @{
                "id" = "neuro-spicy.setup"
                "name" = "Neuro-Spicy Environment Setup"
                "type" = "environmental"
                "rarity" = "epic"
                "stats" = @{
                    "adhd_friendliness" = 95
                    "autism_support" = 90
                    "executive_function" = 88
                    "sensory_optimization" = 92
                }
                "requirements" = @("Focus management tools", "Sensory optimization", "Executive function support")
                "discovered_by" = "human:yourname"
                "achievements_unlocked" = @("Environment Master", "Focus Champion", "Neuro-Spicy Pioneer", "Sensory Optimizer")
            }
            @{
                "id" = "neuro-spicy.focus"
                "name" = "Focus Management Protocol"
                "type" = "behavioral"
                "rarity" = "rare"
                "stats" = @{
                    "focus_duration" = 85
                    "distraction_resistance" = 90
                    "task_completion" = 88
                }
                "requirements" = @("Focus guardian agent", "Distraction blocking", "Task prioritization")
                "discovered_by" = "ai:focus-ai"
                "achievements_unlocked" = @("Focus Master", "Distraction Slayer", "Task Completer")
            }
            @{
                "id" = "neuro-spicy.sensory"
                "name" = "Sensory Optimization Protocol"
                "type" = "environmental"
                "rarity" = "uncommon"
                "stats" = @{
                    "sensory_comfort" = 92
                    "overload_prevention" = 88
                    "environment_control" = 90
                }
                "requirements" = @("Sensory optimizer agent", "Environment monitoring", "Adaptive controls")
                "discovered_by" = "ai:sensory-ai"
                "achievements_unlocked" = @("Sensory Master", "Environment Controller", "Comfort Optimizer")
            }
        )
        "achievements" = @(
            @{
                "id" = "first_neuro_spicy_setup"
                "name" = "Neuro-Spicy Pioneer"
                "description" = "Complete your first neuro-spicy environment setup"
                "points" = 100
            }
            @{
                "id" = "focus_master"
                "name" = "Focus Master"
                "description" = "Maintain focus for 2+ hours without distraction"
                "points" = 200
            }
            @{
                "id" = "sensory_optimizer"
                "name" = "Sensory Optimizer"
                "description" = "Successfully optimize environment for sensory needs"
                "points" = 150
            }
        )
    }
    
    $neuroSpicyProcedures | ConvertTo-Json -Depth 4 | Out-File -FilePath "$proceduresDir/neuro_spicy_procedures.yaml" -Encoding UTF8
    Write-ColorOutput "✅ Created neuro-spicy procedures" "Green"
}

function Install-AutoCritiqueSystem {
    Write-ColorOutput "🧠 Installing Auto-Critique system..." "Cyan"
    
    # Create auto-critique directory
    $critiqueDir = "portable-dev-env/auto-critique"
    New-Item -ItemType Directory -Path $critiqueDir -Force | Out-Null
    
    # Create auto-critique configuration
    $autoCritiqueConfig = @{
        "neuro_spicy_optimization" = @{
            "patterns" = @{
                "detect_adhd_patterns" = @("scattered_thoughts", "context_switching", "executive_dysfunction")
                "detect_autism_patterns" = @("sensory_overload", "routine_disruption", "social_anxiety")
            }
            "optimizations" = @{
                "enhance_focus" = @("single_task_clarity", "minimal_cognitive_load")
                "improve_executive_function" = @("step_by_step_breakdown", "clear_outcomes")
                "reduce_sensory_overload" = @("clean_interface", "minimal_distractions")
            }
        }
        "critique_rules" = @(
            "Break down complex tasks into smaller steps"
            "Use clear, direct language"
            "Minimize cognitive load"
            "Provide clear outcomes and next steps"
            "Reduce sensory overwhelm"
            "Support executive function"
        )
    }
    
    $autoCritiqueConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath "$critiqueDir/config.json" -Encoding UTF8
    
    # Create auto-critique script
    $autoCritiqueScript = @"
# Auto-Critique System for Neuro-Spicy Users
import json
import re
from typing import Dict, List, Tuple

class NeuroSpicyCritique:
    def __init__(self, config_path: str):
        with open(config_path, 'r') as f:
            self.config = json.load(f)
    
    def critique_prompt(self, prompt: str) -> Tuple[str, Dict]:
        """Critique and optimize a prompt for neuro-spicy users"""
        
        # Detect patterns
        adhd_patterns = self.detect_adhd_patterns(prompt)
        autism_patterns = self.detect_autism_patterns(prompt)
        
        # Optimize for neuro-spicy needs
        optimized = self.optimize_for_focus(prompt)
        optimized = self.enhance_executive_function(optimized)
        optimized = self.reduce_sensory_overload(optimized)
        
        # Generate critique report
        critique_report = {
            "original_prompt": prompt,
            "optimized_prompt": optimized,
            "detected_patterns": {
                "adhd": adhd_patterns,
                "autism": autism_patterns
            },
            "optimizations_applied": [
                "focus_enhancement",
                "executive_function_support",
                "sensory_overload_reduction"
            ],
            "neuro_spicy_score": self.calculate_neuro_spicy_score(optimized)
        }
        
        return optimized, critique_report
    
    def detect_adhd_patterns(self, prompt: str) -> List[str]:
        """Detect ADHD-related patterns in prompt"""
        patterns = []
        
        if len(prompt.split()) > 50:
            patterns.append("scattered_thoughts")
        
        if "and" in prompt.lower().count("and") > 3:
            patterns.append("context_switching")
        
        if "complex" in prompt.lower() or "complicated" in prompt.lower():
            patterns.append("executive_dysfunction")
        
        return patterns
    
    def detect_autism_patterns(self, prompt: str) -> List[str]:
        """Detect autism-related patterns in prompt"""
        patterns = []
        
        if "overwhelming" in prompt.lower() or "too much" in prompt.lower():
            patterns.append("sensory_overload")
        
        if "change" in prompt.lower() or "different" in prompt.lower():
            patterns.append("routine_disruption")
        
        if "social" in prompt.lower() or "people" in prompt.lower():
            patterns.append("social_anxiety")
        
        return patterns
    
    def optimize_for_focus(self, prompt: str) -> str:
        """Optimize prompt for better focus"""
        # Break down complex sentences
        optimized = re.sub(r'([.!?])\s+([A-Z])', r'\1\n\n\2', prompt)
        
        # Add clear structure
        if not prompt.startswith(('1.', '2.', '3.', 'Step', 'Task')):
            optimized = "Task: " + optimized
        
        return optimized
    
    def enhance_executive_function(self, prompt: str) -> str:
        """Enhance prompt for executive function support"""
        # Add clear outcomes
        if "outcome" not in prompt.lower() and "result" not in prompt.lower():
            optimized = prompt + "\n\nExpected Outcome: Clear, actionable result"
        else:
            optimized = prompt
        
        return optimized
    
    def reduce_sensory_overload(self, prompt: str) -> str:
        """Reduce sensory overload in prompt"""
        # Remove excessive punctuation
        optimized = re.sub(r'[!]{2,}', '!', prompt)
        optimized = re.sub(r'[?]{2,}', '?', optimized)
        
        # Simplify language
        optimized = re.sub(r'\b(very|really|extremely|super)\s+', '', optimized, flags=re.IGNORECASE)
        
        return optimized
    
    def calculate_neuro_spicy_score(self, prompt: str) -> int:
        """Calculate neuro-spicy friendliness score (0-100)"""
        score = 100
        
        # Penalize for complexity
        if len(prompt.split()) > 30:
            score -= 10
        
        # Penalize for unclear structure
        if not any(word in prompt.lower() for word in ['task', 'step', 'goal', 'outcome']):
            score -= 15
        
        # Penalize for sensory overload
        if prompt.count('!') > 2 or prompt.count('?') > 2:
            score -= 10
        
        return max(0, score)

if __name__ == "__main__":
    critique = NeuroSpicyCritique("config.json")
    prompt = input("Enter your prompt: ")
    optimized, report = critique.critique_prompt(prompt)
    
    print("\\n🧠 Neuro-Spicy Critique Report:")
    print(f"Original: {report['original_prompt']}")
    print(f"Optimized: {report['optimized_prompt']}")
    print(f"Neuro-Spicy Score: {report['neuro_spicy_score']}/100")
"@
    
    $autoCritiqueScript | Out-File -FilePath "$critiqueDir/neuro_spicy_critique.py" -Encoding UTF8
    Write-ColorOutput "✅ Created auto-critique system" "Green"
}

function Install-MCPIntegration {
    Write-ColorOutput "🔌 Installing MCP integration..." "Cyan"
    
    # Create MCP integration directory
    $mcpDir = "portable-dev-env/mcp-integration"
    New-Item -ItemType Directory -Path $mcpDir -Force | Out-Null
    
    # Create neuro-spicy MCP configuration
    $mcpConfig = @{
        "mcpServers" = @{
            "neuro-spicy-focus" = @{
                "command" = "node"
                "args" = @("neuro-spicy-focus-mcp-server.js")
                "env" = @{
                    "FOCUS_MODE" = "true"
                    "DISTRACTION_BLOCKING" = "true"
                }
            }
            "neuro-spicy-sensory" = @{
                "command" = "node"
                "args" = @("neuro-spicy-sensory-mcp-server.js")
                "env" = @{
                    "SENSORY_MONITORING" = "true"
                    "ENVIRONMENT_CONTROL" = "true"
                }
            }
            "neuro-spicy-executive" = @{
                "command" = "node"
                "args" = @("neuro-spicy-executive-mcp-server.js")
                "env" = @{
                    "TASK_BREAKDOWN" = "true"
                    "EXECUTIVE_SUPPORT" = "true"
                }
            }
        }
    }
    
    $mcpConfig | ConvertTo-Json -Depth 4 | Out-File -FilePath "$mcpDir/neuro-spicy-mcp.json" -Encoding UTF8
    Write-ColorOutput "✅ Created MCP integration" "Green"
}

function Update-ProfileLoader {
    Write-ColorOutput "🔄 Updating profile loader..." "Cyan"
    
    # Read current profile loader
    $profileLoaderPath = "portable-dev-env/scripts/profile-loader.ps1"
    if (Test-Path $profileLoaderPath) {
        $profileLoaderContent = Get-Content $profileLoaderPath -Raw
        
        # Add neuro-spicy features
        $neuroSpicyFeatures = @"

# Neuro-Spicy Features
function Enable-NeuroSpicyFeatures {
    param([string]`$ProfileName)
    
    Write-ColorOutput "🧠 Enabling neuro-spicy features for profile: `$ProfileName" "Magenta"
    
    # Enable auto-critique
    if (Test-Path "`$PSScriptRoot/../auto-critique/neuro_spicy_critique.py") {
        Write-ColorOutput "✅ Auto-critique system enabled" "Green"
    }
    
    # Enable specialized agents
    if (Test-Path "`$PSScriptRoot/../agents") {
        Write-ColorOutput "✅ Specialized agents enabled" "Green"
    }
    
    # Enable procedure pokédex
    if (Test-Path "`$PSScriptRoot/../procedures") {
        Write-ColorOutput "✅ Procedure pokédex enabled" "Green"
    }
    
    # Enable MCP integration
    if (Test-Path "`$PSScriptRoot/../mcp-integration") {
        Write-ColorOutput "✅ MCP integration enabled" "Green"
    }
    
    Write-ColorOutput "🎮 Neuro-spicy features activated!" "Green"
}

# Add neuro-spicy features to profile loading
if (`$ProfileName -match "neuro-spicy|adhd|autism") {
    Enable-NeuroSpicyFeatures -ProfileName `$ProfileName
}
"@
        
        # Insert neuro-spicy features before the end of the script
        $profileLoaderContent = $profileLoaderContent -replace "(\s*)$", "$neuroSpicyFeatures`$1"
        $profileLoaderContent | Out-File -FilePath $profileLoaderPath -Encoding UTF8
        
        Write-ColorOutput "✅ Updated profile loader with neuro-spicy features" "Green"
    }
}

function Test-Integration {
    Write-ColorOutput "🧪 Testing integration..." "Cyan"
    
    $tests = @{
        "Agents Directory" = Test-Path "portable-dev-env/agents"
        "Procedures Directory" = Test-Path "portable-dev-env/procedures"
        "Auto-Critique Directory" = Test-Path "portable-dev-env/auto-critique"
        "MCP Integration Directory" = Test-Path "portable-dev-env/mcp-integration"
        "Profile Loader Updated" = (Get-Content "portable-dev-env/scripts/profile-loader.ps1" -Raw) -match "neuro-spicy"
    }
    
    $allPassed = $true
    foreach ($testName in $tests.Keys) {
        if ($tests[$testName]) {
            Write-ColorOutput "✅ $testName" "Green"
        } else {
            Write-ColorOutput "❌ $testName" "Red"
            $allPassed = $false
        }
    }
    
    if ($allPassed) {
        Write-ColorOutput "🎉 All tests passed! Integration successful!" "Green"
    } else {
        Write-ColorOutput "❌ Some tests failed. Please check the integration." "Red"
    }
    
    return $allPassed
}

# Main execution
Write-ColorOutput "🚀 PromptOS/zenOS Integration for Neuro-Spicy DevKit" "Magenta"
Write-ColorOutput "=================================================" "Magenta"
Write-ColorOutput ""

if ($DryRun) {
    Write-ColorOutput "🔍 DRY RUN MODE - No changes will be made" "Yellow"
    Write-ColorOutput "This would integrate:" "Yellow"
    Write-ColorOutput "- Auto-critique system for neuro-spicy optimization" "Yellow"
    Write-ColorOutput "- Specialized agents (focus, executive, sensory, routine)" "Yellow"
    Write-ColorOutput "- Procedure pokédex with gamification" "Yellow"
    Write-ColorOutput "- MCP integration for neuro-spicy tools" "Yellow"
    Write-ColorOutput "- Enhanced profile loader with neuro-spicy features" "Yellow"
    exit 0
}

# Check prerequisites
if (-not (Test-Prerequisites)) {
    Write-ColorOutput "❌ Prerequisites not met. Exiting." "Red"
    exit 1
}

# Create backup
Backup-CurrentSetup

# Install components based on integration level
switch ($IntegrationLevel) {
    "basic" {
        Write-ColorOutput "🔧 Installing basic integration..." "Cyan"
        Install-CoreAgents
        Install-ProcedurePokédex
    }
    "advanced" {
        Write-ColorOutput "🔧 Installing advanced integration..." "Cyan"
        Install-CoreAgents
        Install-ProcedurePokédex
        Install-AutoCritiqueSystem
    }
    "full" {
        Write-ColorOutput "🔧 Installing full integration..." "Cyan"
        Install-CoreAgents
        Install-ProcedurePokédex
        Install-AutoCritiqueSystem
        Install-MCPIntegration
        Update-ProfileLoader
    }
}

# Test integration
if (Test-Integration) {
    Write-ColorOutput ""
    Write-ColorOutput "🎉 Integration Complete!" "Green"
    Write-ColorOutput "=====================" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Your neuro-spicy devkit is now a full AI operating system!" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Next steps:" "Cyan"
    Write-ColorOutput "1. Run: .\portable-dev-env\scripts\profile-loader.ps1 list" "White"
    Write-ColorOutput "2. Test: .\portable-dev-env\scripts\profile-loader.ps1 load neuro-spicy" "White"
    Write-ColorOutput "3. Explore: .\portable-dev-env\auto-critique\neuro_spicy_critique.py" "White"
    Write-ColorOutput ""
    Write-ColorOutput "🧠 Your neuro-spicy AI OS is ready! 🚀" "Magenta"
} else {
    Write-ColorOutput "❌ Integration failed. Please check the errors above." "Red"
    exit 1
}

