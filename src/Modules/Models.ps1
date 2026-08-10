# ============================================================
# M365 Cleanup Manager
# Data Models
# ============================================================

Set-StrictMode -Version Latest

function New-M365UserDiscoveryResult {

    param(
        [string]$ObjectId,
        [string]$DisplayName,
        [string]$UserPrincipalName,
        [string]$Mail,
        [bool]$AccountEnabled,
        [string]$UserType,
        [datetime]$CreatedDate,
        [string]$JobTitle,
        [string]$Department
    )

    return [PSCustomObject]@{
        ObjectId          = $ObjectId
        DisplayName       = $DisplayName
        UserPrincipalName = $UserPrincipalName
        Mail              = $Mail
        AccountEnabled    = $AccountEnabled
        UserType          = $UserType
        CreatedDate       = $CreatedDate
        JobTitle          = $JobTitle
        Department        = $Department
    }
}