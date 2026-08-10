# ============================================================
# M365 Cleanup Manager
# ============================================================
#
# Purpose:
#   Microsoft 365 data discovery and controlled cleanup tool.
#
# Repository:
#   M365-Cleanup-Manager
#
# Current Version:
#   0.1.0
#
# Current Mode:
#   READ-ONLY / DEVELOPMENT
#
# IMPORTANT:
#   No destructive operations are implemented in this version.
#
# ============================================================

[CmdletBinding()]
param()

Set-StrictMode -Version Latest

$ErrorActionPreference = 'Stop'

# ------------------------------------------------------------
# Application Information
# ------------------------------------------------------------

$Script:Application = @{
    Name        = 'M365 Cleanup Manager'
    Version     = '0.1.0'
    Environment = 'Development'
    Mode        = 'READ-ONLY'
}

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

$Script:RootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$Script:Paths = @{
    Root     = $Script:RootPath
    Source   = Join-Path $Script:RootPath 'src'
    Modules  = Join-Path $Script:RootPath 'src\Modules'
    GUI      = Join-Path $Script:RootPath 'src\GUI'
    Services = Join-Path $Script:RootPath 'src\Services'
    Tests    = Join-Path $Script:RootPath 'tests'
    Docs     = Join-Path $Script:RootPath 'docs'
    Config   = Join-Path $Script:RootPath 'config'
    Logs     = Join-Path $Script:RootPath 'logs'
    Reports  = Join-Path $Script:RootPath 'reports'
}

# ------------------------------------------------------------
# Load Services
# ------------------------------------------------------------

$AuthenticationModule = Join-Path `
    $Script:Paths.Services `
    'Authentication.ps1'

if (Test-Path $AuthenticationModule) {
    . $AuthenticationModule
}
else {
    throw "Authentication module not found: $AuthenticationModule"
}

# ------------------------------------------------------------
# Startup
# ------------------------------------------------------------

Clear-Host

Write-Host ''
Write-Host '============================================================' `
    -ForegroundColor Cyan

Write-Host '                 M365 CLEANUP MANAGER' `
    -ForegroundColor Cyan

Write-Host '============================================================' `
    -ForegroundColor Cyan

Write-Host ''

Write-Host "Version     : $($Script:Application.Version)"
Write-Host "Environment : $($Script:Application.Environment)"
Write-Host "Mode        : $($Script:Application.Mode)" `
    -ForegroundColor Yellow

Write-Host ''

Write-Host 'Application initialized successfully.' `
    -ForegroundColor Green

Write-Host ''

Write-Host 'IMPORTANT:' -ForegroundColor Yellow
Write-Host 'Destructive operations are disabled in this version.' `
    -ForegroundColor Yellow

Write-Host ''

# ------------------------------------------------------------
# Authentication Test
# ------------------------------------------------------------

Write-Host "Starting Microsoft 365 authentication..." `
    -ForegroundColor Cyan

$M365Context = Connect-M365CleanupManager

Write-Host ""
Write-Host "Authentication test completed successfully." `
    -ForegroundColor Green

    # ------------------------------------------------------------
# Load Discovery Modules
# ------------------------------------------------------------

$UserDiscoveryModule = Join-Path `
    $Script:Paths.Modules `
    'UserDiscovery.ps1'

if (Test-Path $UserDiscoveryModule) {
    . $UserDiscoveryModule
}
else {
    throw "User discovery module not found: $UserDiscoveryModule"
}