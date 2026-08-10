# ============================================================
# M365 Cleanup Manager
# Exchange Discovery Module
# ============================================================

Set-StrictMode -Version Latest

function Get-M365ExchangeData {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )

    Write-Host ''
    Write-Host 'Exchange Discovery' -ForegroundColor Cyan
    Write-Host '------------------' -ForegroundColor DarkGray
    Write-Host "User: $UserPrincipalName" -ForegroundColor Gray
    Write-Host ''

    # --------------------------------------------------------
    # Mock Mode
    # --------------------------------------------------------

    if ($Script:Configuration.Development.UseMockData) {

        Write-Host '[MOCK] Exchange discovery' -ForegroundColor Yellow

        return [PSCustomObject]@{
            MailboxExists              = $true
            UserPrincipalName          = $UserPrincipalName
            DisplayName                = 'Test Employee'
            MailboxType                = 'UserMailbox'
            PrimarySmtpAddress         = $UserPrincipalName
            MailboxSizeGB              = 12.40
            ArchiveEnabled             = $true
            ArchiveSizeGB              = 4.20
            InactiveMailbox            = $false
            LitigationHoldEnabled     = $false
            InPlaceHolds               = @()
            ComplianceTagHoldApplied  = $false
            DelayHoldApplied          = $false
            RetentionHoldEnabled      = $false
            DeletionAllowed            = $true
            Status                     = 'READY'
            Error                      = $null
        }
    }

    # --------------------------------------------------------
    # Live Exchange Online
    # --------------------------------------------------------

    if (-not (Get-Command Get-EXOMailbox -ErrorAction SilentlyContinue)) {

        throw @"
Exchange Online PowerShell is not available.

Install it with:

Install-Module ExchangeOnlineManagement -Scope CurrentUser
"@
    }

    try {

        # ----------------------------------------------------
        # Locate mailbox
        # ----------------------------------------------------

        $Mailbox = Get-EXOMailbox `
            -Identity $UserPrincipalName `
            -Properties `
                LitigationHoldEnabled,
                InPlaceHolds,
                ComplianceTagHoldApplied,
                DelayHoldApplied,
                RetentionHoldEnabled,
                ArchiveStatus,
                RecipientTypeDetails,
                PrimarySmtpAddress

        if (-not $Mailbox) {

            return [PSCustomObject]@{
                MailboxExists = $false
                UserPrincipalName = $UserPrincipalName
                Status = 'NOT_FOUND'
                Error = $null
            }
        }

        # ----------------------------------------------------
        # Mailbox statistics
        # ----------------------------------------------------

        $Statistics = Get-EXOMailboxStatistics `
            -Identity $UserPrincipalName

        $MailboxSizeGB = 0

        if ($Statistics.TotalItemSize) {

            $SizeString = $Statistics.TotalItemSize.ToString()

            if ($SizeString -match '\(([\d,]+)\s+bytes\)') {

                $Bytes = [double](
                    $Matches[1] -replace ',', ''
                )

                $MailboxSizeGB = [math]::Round(
                    $Bytes / 1GB,
                    2
                )
            }
        }

        # ----------------------------------------------------
        # Determine protection status
        # ----------------------------------------------------

        $Protected = $false

        if ($Mailbox.LitigationHoldEnabled) {
            $Protected = $true
        }

        if ($Mailbox.InPlaceHolds.Count -gt 0) {
            $Protected = $true
        }

        if ($Mailbox.ComplianceTagHoldApplied) {
            $Protected = $true
        }

        if ($Mailbox.DelayHoldApplied) {
            $Protected = $true
        }

        if ($Mailbox.RetentionHoldEnabled) {
            $Protected = $true
        }

        $Status = if ($Protected) {
            'BLOCKED'
        }
        else {
            'READY'
        }

        return [PSCustomObject]@{

            MailboxExists             = $true

            UserPrincipalName         =
                $UserPrincipalName

            DisplayName               =
                $Mailbox.DisplayName

            MailboxType               =
                $Mailbox.RecipientTypeDetails

            PrimarySmtpAddress        =
                $Mailbox.PrimarySmtpAddress

            MailboxSizeGB             =
                $MailboxSizeGB

            ArchiveEnabled            =
                ($Mailbox.ArchiveStatus -eq 'Active')

            ArchiveStatus             =
                $Mailbox.ArchiveStatus

            InactiveMailbox           = $false

            LitigationHoldEnabled     =
                $Mailbox.LitigationHoldEnabled

            InPlaceHolds              =
                $Mailbox.InPlaceHolds

            ComplianceTagHoldApplied =
                $Mailbox.ComplianceTagHoldApplied

            DelayHoldApplied          =
                $Mailbox.DelayHoldApplied

            RetentionHoldEnabled      =
                $Mailbox.RetentionHoldEnabled

            DeletionAllowed           =
                (-not $Protected)

            Status                    =
                $Status

            Error                     =
                $null
        }
    }
    catch {

        Write-Host ''
        Write-Host 'Exchange discovery failed.' `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        return [PSCustomObject]@{
            MailboxExists     = $false
            UserPrincipalName = $UserPrincipalName
            Status            = 'ERROR'
            Error             = $_.Exception.Message
        }
    }
}