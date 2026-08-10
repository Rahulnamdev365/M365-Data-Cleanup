# ============================================================
# M365 Cleanup Manager
# Authentication Service
# ============================================================

Set-StrictMode -Version Latest

function Connect-M365CleanupManager {

    [CmdletBinding()]
    param()

    Write-Host ''
    Write-Host 'Microsoft 365 Authentication' `
        -ForegroundColor Cyan

    Write-Host '--------------------------------' `
        -ForegroundColor DarkGray

    Write-Host ''

    try {

        if (-not (Get-Command Connect-MgGraph -ErrorAction SilentlyContinue)) {

            throw @"
Microsoft Graph PowerShell SDK is not installed.

Install it with:

Install-Module Microsoft.Graph -Scope CurrentUser
"@
        }

        Write-Host 'Connecting to Microsoft Graph...' `
            -ForegroundColor Yellow

        Connect-MgGraph `
            -Scopes @(
                'User.Read.All'
                'Directory.Read.All'
                'Mail.Read'
                'Files.Read.All'
                'Sites.Read.All'
            ) `
            -NoWelcome

        $Context = Get-MgContext

        if (-not $Context) {
            throw 'Microsoft Graph authentication returned no context.'
        }

        Write-Host ''
        Write-Host 'Microsoft Graph authentication successful.' `
            -ForegroundColor Green

        Write-Host ''
        Write-Host "Tenant : $($Context.TenantId)"
        Write-Host "Account: $($Context.Account)"
        Write-Host ''

        return $Context

    }
    catch {

        Write-Host ''
        Write-Host 'Microsoft Graph authentication failed.' `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        throw
    }
}