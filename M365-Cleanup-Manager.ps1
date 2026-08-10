# ============================================================
# M365 Cleanup Manager
# ============================================================
#
# Microsoft 365 Data Discovery & Controlled Cleanup
#
# Version: 0.2.0
# Environment: Development
#
# IMPORTANT:
# Destructive operations are NOT implemented.
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
    Version     = '0.2.0'
    Environment = 'Development'
    Mode        = 'READ-ONLY'
}

# ------------------------------------------------------------
# Project Paths
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

$ServiceFiles = @(
    'Configuration.ps1'
    'Authentication.ps1'
)

foreach ($ServiceFile in $ServiceFiles) {

    $ServicePath = Join-Path `
        $Script:Paths.Services `
        $ServiceFile

    if (-not (Test-Path $ServicePath)) {
        throw "Required service not found: $ServicePath"
    }

    . $ServicePath
}

# ------------------------------------------------------------
# Load Modules
# ------------------------------------------------------------

$ModuleFiles = @(
    'Models.ps1'
    'UserDiscovery.ps1'
    'ExchangeDiscovery.ps1'
    'OneDriveDiscovery.ps1'

)

foreach ($ModuleFile in $ModuleFiles) {

    $ModulePath = Join-Path `
        $Script:Paths.Modules `
        $ModuleFile

    if (-not (Test-Path $ModulePath)) {
        throw "Required module not found: $ModulePath"
    }

    . $ModulePath
}

# ------------------------------------------------------------
# Application Banner
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

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

try {

    $Script:Configuration = Get-M365CleanupConfiguration

    Write-Host 'Configuration loaded.' `
        -ForegroundColor Green

    Write-Host "Mock Data   : $($Script:Configuration.Development.UseMockData)"
    Write-Host ''

}
catch {

    Write-Host ''
    Write-Host 'Configuration error.' `
        -ForegroundColor Red

    Write-Host $_.Exception.Message `
        -ForegroundColor Red

    exit 1
}

# ------------------------------------------------------------
# Authentication
# ------------------------------------------------------------

if ($Script:Configuration.Development.UseMockData) {

    Write-Host 'Development mode enabled.' `
        -ForegroundColor Yellow

    Write-Host 'Microsoft 365 authentication is currently skipped.' `
        -ForegroundColor Yellow

}
else {

    Write-Host 'Starting Microsoft 365 authentication...' `
        -ForegroundColor Cyan

    $Script:M365Context = Connect-M365CleanupManager
}

Write-Host ''
Write-Host 'Application initialized successfully.' `
    -ForegroundColor Green

Write-Host ''
Write-Host 'Discovery engine ready.' `
    -ForegroundColor Green

Write-Host ''

# ------------------------------------------------------------
# Development Discovery Test
# ------------------------------------------------------------

Write-Host ''
Write-Host 'Running development discovery test...' `
    -ForegroundColor Cyan

$TestUser = Get-M365CleanupUser `
    -UserPrincipalName 'test.employee@example.com'

if ($null -eq $TestUser) {

    Write-Host ''
    Write-Host 'Test user could not be discovered.' `
        -ForegroundColor Red

    exit 1
}

Write-Host ''
Write-Host 'Discovery Result' `
    -ForegroundColor Cyan

$TestUser |
    Format-List

# ------------------------------------------------------------
# Exchange Discovery Test
# ------------------------------------------------------------

Write-Host ''
Write-Host 'Running Exchange discovery test...' `
    -ForegroundColor Cyan

$ExchangeData = Get-M365ExchangeData `
    -UserPrincipalName $TestUser.UserPrincipalName

Write-Host ''
Write-Host 'Exchange Discovery Result' `
    -ForegroundColor Cyan

$ExchangeData |
    Format-List

Write-Host ''
Write-Host 'Discovery tests completed.' `
    -ForegroundColor Green

    # ------------------------------------------------------------
# OneDrive Discovery Test
# ------------------------------------------------------------

Write-Host ''
Write-Host 'Running OneDrive discovery test...' `
    -ForegroundColor Cyan

$OneDriveData = Get-M365OneDriveData `
    -UserPrincipalName $TestUser.UserPrincipalName

Write-Host ''
Write-Host 'OneDrive Discovery Result' `
    -ForegroundColor Cyan

$OneDriveData |
    Format-List

Write-Host ''
Write-Host 'OneDrive discovery test completed.' `
    -ForegroundColor Green