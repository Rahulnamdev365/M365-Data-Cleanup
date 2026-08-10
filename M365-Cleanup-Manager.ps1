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