# ============================================================
# M365 Cleanup Manager
# OneDrive Discovery Module
# ============================================================

Set-StrictMode -Version Latest

function Get-M365OneDriveData {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )

    Write-Host ''
    Write-Host 'OneDrive Discovery' -ForegroundColor Cyan
    Write-Host '------------------' -ForegroundColor DarkGray
    Write-Host "User: $UserPrincipalName" -ForegroundColor Gray
    Write-Host ''

    # --------------------------------------------------------
    # Mock Mode
    # --------------------------------------------------------

    if ($Script:Configuration.Development.UseMockData) {

        Write-Host '[MOCK] OneDrive discovery' -ForegroundColor Yellow

        return [PSCustomObject]@{
            OneDriveExists       = $true
            UserPrincipalName    = $UserPrincipalName
            DisplayName          = 'Test Employee'
            DriveId              = 'mock-drive-0001'
            DriveType            = 'business'
            WebUrl               = 'https://example.sharepoint.com/personal/test_employee_example_com'
            StorageUsedGB        = 8.70
            FileCount            = 8721
            LastModified         = [datetime]'2026-07-15T10:30:00'
            Orphaned             = $false
            RetentionProtected   = $false
            DeletionAllowed      = $true
            Status               = 'READY'
            Error                = $null
        }
    }

    # --------------------------------------------------------
    # Live Microsoft Graph
    # --------------------------------------------------------

    if (-not (Get-Command Get-MgUserDrive -ErrorAction SilentlyContinue)) {

        throw @"
Microsoft Graph Files module is not available.

Install it with:

Install-Module Microsoft.Graph.Files -Scope CurrentUser
"@
    }

    try {

        Write-Host 'Querying Microsoft Graph...' `
            -ForegroundColor Cyan

        $Drive = Get-MgUserDrive `
            -UserId $UserPrincipalName

        if (-not $Drive) {

            return [PSCustomObject]@{
                OneDriveExists    = $false
                UserPrincipalName = $UserPrincipalName
                Orphaned          = $false
                DeletionAllowed   = $false
                Status            = 'NOT_FOUND'
                Error             = $null
            }
        }

        # ----------------------------------------------------
        # Drive quota
        # ----------------------------------------------------

        $StorageUsedGB = 0

        if ($Drive.Quota -and $null -ne $Drive.Quota.Used) {

            $StorageUsedGB = [math]::Round(
                [double]$Drive.Quota.Used / 1GB,
                2
            )
        }

        # ----------------------------------------------------
        # Result
        # ----------------------------------------------------

        return [PSCustomObject]@{
            OneDriveExists       = $true
            UserPrincipalName    = $UserPrincipalName
            DisplayName          = $Drive.Owner.User.DisplayName
            DriveId              = $Drive.Id
            DriveType            = $Drive.DriveType
            WebUrl               = $Drive.WebUrl
            StorageUsedGB        = $StorageUsedGB
            FileCount            = $null
            LastModified         = $Drive.LastModifiedDateTime
            Orphaned             = $false
            RetentionProtected   = $false
            DeletionAllowed      = $true
            Status               = 'READY'
            Error                = $null
        }
    }
    catch {

        Write-Host ''
        Write-Host 'OneDrive discovery failed.' `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        return [PSCustomObject]@{
            OneDriveExists    = $false
            UserPrincipalName = $UserPrincipalName
            Orphaned          = $false
            DeletionAllowed   = $false
            Status            = 'ERROR'
            Error             = $_.Exception.Message
        }
    }
}