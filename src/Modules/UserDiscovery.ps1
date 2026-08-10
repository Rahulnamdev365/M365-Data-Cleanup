# ============================================================
# M365 Cleanup Manager
# User Discovery Module
# ============================================================

Set-StrictMode -Version Latest

function Get-M365CleanupUser {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )

    Write-Host ""
    Write-Host "Searching for user..." -ForegroundColor Cyan
    Write-Host "UPN: $UserPrincipalName" -ForegroundColor Gray
    Write-Host ""

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
            Write-Host "User not found." -ForegroundColor Red
            return $null
        }

        [PSCustomObject]@{
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

        Write-Host ""
        Write-Host "User discovery failed." -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host ""

        throw
    }
}