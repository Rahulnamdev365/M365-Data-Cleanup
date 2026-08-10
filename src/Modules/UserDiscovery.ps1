# ============================================================
# M365 Cleanup Manager
# User Discovery
# ============================================================

Set-StrictMode -Version Latest

function Get-M365CleanupUser {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )

    # --------------------------------------------------------
    # Development / Mock Mode
    # --------------------------------------------------------

    if ($Script:Configuration.Development.UseMockData) {

        Write-Host ''
        Write-Host '[MOCK] Searching for user:' `
            -ForegroundColor Yellow

        Write-Host $UserPrincipalName `
            -ForegroundColor Gray

        $MockPath = Join-Path `
            $Script:Paths.Tests `
            'TestData\sample-user.json'

        if (-not (Test-Path $MockPath)) {
            throw "Mock user data not found: $MockPath"
        }

        $MockUser = Get-Content `
            -Path $MockPath `
            -Raw |
            ConvertFrom-Json

        return $MockUser
    }

    # --------------------------------------------------------
    # Microsoft Graph
    # --------------------------------------------------------

    Write-Host ''
    Write-Host 'Searching Microsoft Entra ID...' `
        -ForegroundColor Cyan

    try {

        $User = Get-MgUser `
            -UserId $UserPrincipalName `
            -Property `
                Id,
                DisplayName,
                UserPrincipalName,
                Mail,
                AccountEnabled,
                UserType,
                CreatedDateTime,
                JobTitle,
                Department

        if (-not $User) {
            return $null
        }

        return [PSCustomObject]@{
            ObjectId          = $User.Id
            DisplayName       = $User.DisplayName
            UserPrincipalName = $User.UserPrincipalName
            Mail              = $User.Mail
            AccountEnabled    = $User.AccountEnabled
            UserType          = $User.UserType
            CreatedDate       = $User.CreatedDateTime
            JobTitle          = $User.JobTitle
            Department        = $User.Department
        }
    }
    catch {

        Write-Host ''
        Write-Host 'User discovery failed.' `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        throw
    }
}