# Wipes the deployed copy of the mod and lays it down fresh.
#
# Wiping rather than overwriting is deliberate: a file you delete from the repo
# would otherwise linger in the game folder forever and keep being loaded.
#
# Run with:  .\deploy.ps1  [-GameDir <path>] [-WhatIf]

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$GameDir = "D:\SteamLibrary\steamapps\common\Teamfight Manager2"
)

$ErrorActionPreference = "Stop"
$repo = $PSScriptRoot
$modId = Split-Path -Leaf $repo

# --- what gets deployed -----------------------------------------------------
# mod.workshop_id is deliberately absent: it is for the uploader, not the game.
$Include = @(
    "mod.mod_info",
    "mod.override_info",
    "LICENSE",
    "preview.png",
    "ui"
)

$ExcludeExtensions = @(".xcf", ".psd", ".bak", ".orig")
# ---------------------------------------------------------------------------

$deploy = Join-Path (Join-Path $GameDir "mods") $modId

# Guard rails before anything is deleted: the target must be a `mods\<mod id>`
# folder and nothing else, so a bad -GameDir cannot wipe a game install.
$parent = Split-Path -Parent $deploy
if ((Split-Path -Leaf $deploy) -ne $modId -or (Split-Path -Leaf $parent) -ne "mods") {
    Write-Error "Refusing to touch '$deploy' - it is not a mods\$modId folder."
}
if (-not (Test-Path -LiteralPath $parent)) {
    Write-Error "No mods folder at '$parent' - is -GameDir right?"
}

if (Test-Path -LiteralPath $deploy) {
    if ($PSCmdlet.ShouldProcess($deploy, "Delete contents")) {
        # -LiteralPath does not expand wildcards, so "$deploy\*" would match
        # nothing; enumerate the children instead.
        Get-ChildItem -LiteralPath $deploy -Force | Remove-Item -Recurse -Force
    }
} else {
    New-Item -ItemType Directory -Path $deploy | Out-Null
}

$copied = 0
$skipped = 0
foreach ($name in $Include) {
    $source = Join-Path $repo $name
    if (-not (Test-Path -LiteralPath $source)) {
        Write-Warning "not found, skipping: $name"
        continue
    }

    if (Test-Path -LiteralPath $source -PathType Container) {
        # Rebuild the tree by hand so the extension filter applies at any depth.
        foreach ($file in Get-ChildItem -LiteralPath $source -Recurse -File) {
            if ($ExcludeExtensions -contains $file.Extension.ToLower()) {
                $skipped++
                continue
            }
            $relative = $file.FullName.Substring($repo.Length).TrimStart('\')
            $destination = Join-Path $deploy $relative
            $destinationDir = Split-Path -Parent $destination
            if (-not (Test-Path -LiteralPath $destinationDir)) {
                New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
            }
            Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
            $copied++
        }
    } else {
        Copy-Item -LiteralPath $source -Destination (Join-Path $deploy $name) -Force
        $copied++
    }
}

Write-Host "Deployed $copied files to $deploy" -ForegroundColor Green
if ($skipped) { Write-Host "Skipped $skipped source files ($($ExcludeExtensions -join ', '))" }
