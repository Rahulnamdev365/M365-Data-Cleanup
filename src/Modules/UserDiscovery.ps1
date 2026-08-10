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

    # --------------------------------------------------------
    # Mock Mode
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

        try {

            $MockUser = Get-Content `
                -Path $MockPath `
                -Raw |
                ConvertFrom-Json

        }
        catch {

            throw "Unable to load mock user data: $($_.Exception.Message)"
        }

        # ----------------------------------------------------
        # Validate mock object
        # ----------------------------------------------------

        if ($null -eq $MockUser) {
            throw "Mock user data returned no object."
        }

        if (-not ($MockUser.PSObject.Properties.Name -contains 'UserPrincipalName')) {
            throw @"
Mock user data is missing the required property:

UserPrincipalName

Expected file:
$MockPath
"@
        }

        # ----------------------------------------------------
        # Verify requested user
        # ----------------------------------------------------

        if ($MockUser.UserPrincipalName -ne $UserPrincipalName) {

            Write-Host ''
            Write-Host '[MOCK] User not found.' `
                -ForegroundColor Yellow

            Write-Host ''
            Write-Host "Requested : $UserPrincipalName"
            Write-Host "Available : $($MockUser.UserPrincipalName)"

            return $null
        }

        # ----------------------------------------------------
        # Return normalized object
        # ----------------------------------------------------

        return [PSCustomObject]@{
            ObjectId          = $MockUser.ObjectId
            DisplayName       = $MockUser.DisplayName
            UserPrincipalName = $MockUser.UserPrincipalName
            Mail              = $MockUser.Mail
            AccountEnabled    = $MockUser.AccountEnabled
            UserType          = $MockUser.UserType
            CreatedDate       = $MockUser.CreatedDate
            JobTitle          = $MockUser.JobTitle
            Department        = $MockUser.Department
        }
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