<#
.SYNOPSIS
    Install the obsidian-memory Agent Skill for multiple AI clients.

.DESCRIPTION
    Copies the skill into the per-client skill directories:

      ~/.agents/skills/obsidian-memory   Codex / Cursor / GitHub Copilot / Gemini CLI (user scope)
      ~/.claude/skills/obsidian-memory   Claude Code (personal skills)

    With -Project, installs into the target repository instead:
        <project>/.agents/skills/obsidian-memory
        <project>/.claude/skills/obsidian-memory

    When -Vault is provided, the installed copies get __VAULT_PATH__ replaced
    with the real Obsidian vault path, so they work immediately. The repository
    source keeps the placeholder.

.PARAMETER Vault
    Absolute path to the Obsidian vault root, e.g. "D:\Obsidian\MyVault".

.PARAMETER Project
    Install into a project/repository instead of user directories.

.PARAMETER ProjectPath
    Project root used with -Project (default: current directory).

.PARAMETER Force
    Overwrite an existing installation (the old copy is backed up first).

.PARAMETER UserHome
    Override the home directory (useful for testing).

.EXAMPLE
    .\install.ps1 -Vault "D:\Obsidian\MyVault"

.EXAMPLE
    .\install.ps1 -Project -ProjectPath "D:\my-repo" -Vault "D:\Obsidian\MyVault"
#>
param(
    [string]$Vault,
    [switch]$Project,
    [string]$ProjectPath = ".",
    [switch]$Force,
    [string]$UserHome = $env:USERPROFILE
)

$ErrorActionPreference = 'Stop'
$source = Join-Path $PSScriptRoot 'obsidian-memory'
if (-not (Test-Path (Join-Path $source 'SKILL.md'))) {
    throw "Cannot find $source\SKILL.md - run this script from the repository root."
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$installed = New-Object System.Collections.Generic.List[string]

function Install-Skill([string]$target) {
    $target = [IO.Path]::GetFullPath($target)
    if (Test-Path $target) {
        if (-not $Force) {
            Write-Host "skip (already exists): $target" -ForegroundColor Yellow
            Write-Host "     use -Force to overwrite (the old copy is backed up first)" -ForegroundColor DarkGray
            return
        }
        $backup = "$target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Move-Item -LiteralPath $target -Destination $backup
        Write-Host "backup: $backup" -ForegroundColor DarkGray
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force

    if ($Vault) {
        $skillFile = Join-Path $target 'SKILL.md'
        $text = [IO.File]::ReadAllText($skillFile, $utf8)
        if ($text.Contains('__VAULT_PATH__')) {
            $text = $text.Replace('__VAULT_PATH__', $Vault)
            [IO.File]::WriteAllText($skillFile, $text, $utf8)
        }
    }

    $installed.Add($target)
    Write-Host "installed: $target" -ForegroundColor Green
}

if ($Project) {
    $root = (Resolve-Path $ProjectPath).Path
    Install-Skill (Join-Path $root '.agents\skills\obsidian-memory')
    Install-Skill (Join-Path $root '.claude\skills\obsidian-memory')
} else {
    Install-Skill (Join-Path $UserHome '.agents\skills\obsidian-memory')
    Install-Skill (Join-Path $UserHome '.claude\skills\obsidian-memory')
}

Write-Host ""
if ($installed.Count -eq 0) {
    Write-Host "Nothing installed (existing copies were skipped; use -Force to overwrite)." -ForegroundColor Yellow
    exit 0
}

if (-not $Vault) {
    Write-Host "Note: -Vault was not provided, so VAULT in the installed copies is still __VAULT_PATH__." -ForegroundColor Yellow
    Write-Host "      Re-run: .\install.ps1 -Vault `"D:\Obsidian\MyVault`" -Force" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your AI client (Claude Code / Codex / Cursor / Copilot / Gemini CLI) so it rescans skills."
Write-Host "  2. For always-on behavior, add the rule from obsidian-memory\references\always-on.md to"
Write-Host "     AGENTS.md / CLAUDE.md / GEMINI.md / .cursor/rules / .github/copilot-instructions.md."
Write-Host "  3. Chat-only clients (ChatGPT web / Claude.ai / mobile):"
Write-Host "     node obsidian-memory\scripts\memory-pack.mjs --vault `"$Vault`" --out MEMORY_PACK.md"
Write-Host "     then attach MEMORY_PACK.md to a Project or chat."
Write-Host ""
