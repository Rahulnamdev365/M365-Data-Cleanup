# ============================================================
# M365 Cleanup Manager
# Authentication Service
# ============================================================

Set-StrictMode -Version Latest

function Connect-M365CleanupManager {

    [CmdletBinding()]
    param()

    Write-Host ""
    Write-Host "Microsoft 365 Authentication" -ForegroundColor Cyan
    Write-Host "--------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    try {

        Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Yellow

        Connect-MgGraph `
            -Scopes @(
                "User.Read.All",
                "Directory.Read.All",
                "Files.Read.All",
                "Sites.Read.All",
                "Mail.Read"
            ) `
            -NoWelcome

        $Context = Get-MgContext

        if (-not $Context) {
            throw "Microsoft Graph authentication did not return a valid context."
        }

        Write-Host ""
        Write-Host "Connected successfully." -ForegroundColor Green
        Write-Host ""
        Write-Host "Tenant ID : $($Context.TenantId)"
        Write-Host "Account   : $($Context.Account)"
        Write-Host ""

        return $Context

    }
    catch {

        Write-Host ""
        Write-Host "Authentication failed." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""

        throw
    }
}