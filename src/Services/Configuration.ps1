# ============================================================
# M365 Cleanup Manager
# Configuration Service
# ============================================================

Set-StrictMode -Version Latest

function Get-M365CleanupConfiguration {

    [CmdletBinding()]
    param()

    $ConfigPath = Join-Path `
        $Script:Paths.Config `
        'config.json'

    if (-not (Test-Path $ConfigPath)) {
        throw @"
Configuration file not found.

Expected:
$ConfigPath

Copy:
config\config.example.json

to:
config\config.json

Then configure the local environment.
"@
    }

    try {
        $Configuration = Get-Content `
            -Path $ConfigPath `
            -Raw |
            ConvertFrom-Json

        return $Configuration
    }
    catch {
        throw "Unable to load configuration: $($_.Exception.Message)"
    }
}