# ============================================================
# M365 Cleanup Manager
# SharePoint Discovery Module
# ============================================================

Set-StrictMode -Version Latest

function Get-M365SharePointData {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName
    )

    Write-Host ''
    Write-Host 'SharePoint Discovery' -ForegroundColor Cyan
    Write-Host '--------------------' -ForegroundColor DarkGray
    Write-Host "User: $UserPrincipalName" -ForegroundColor Gray
    Write-Host ''

    # --------------------------------------------------------
    # Mock Mode
    # --------------------------------------------------------

    if ($Script:Configuration.Development.UseMockData) {

        Write-Host '[MOCK] SharePoint discovery' -ForegroundColor Yellow

        return [PSCustomObject]@{
            UserPrincipalName = $UserPrincipalName

            SitesFound = @(
                [PSCustomObject]@{
                    SiteId          = 'mock-site-001'
                    SiteName        = 'HR'
                    WebUrl          = 'https://example.sharepoint.com/sites/HR'
                    Relationship    = 'Member'
                    DocumentLibraries = 2
                    Status          = 'DISCOVERED'
                }

                [PSCustomObject]@{
                    SiteId          = 'mock-site-002'
                    SiteName        = 'Project Alpha'
                    WebUrl          = 'https://example.sharepoint.com/sites/ProjectAlpha'
                    Relationship    = 'Owner'
                    DocumentLibraries = 3
                    Status          = 'DISCOVERED'
                }
            )

            SiteCount          = 2
            OwnedSiteCount     = 1
            MemberSiteCount    = 1
            ProtectedSiteCount = 0
            Status              = 'READY'
            Error               = $null
        }
    }

    # --------------------------------------------------------
    # Live Microsoft Graph
    # --------------------------------------------------------

    if (-not (Get-Command Get-MgSite -ErrorAction SilentlyContinue)) {

        throw @"
Microsoft Graph Sites module is not available.

Install it with:

Install-Module Microsoft.Graph.Sites -Scope CurrentUser
"@
    }

    try {

        Write-Host 'Searching SharePoint sites...' `
            -ForegroundColor Cyan

        # ----------------------------------------------------
        # IMPORTANT
        # ----------------------------------------------------
        # This first implementation performs a site search
        # using the user's UPN/name as a discovery hint.
        #
        # It does NOT assume that every site returned belongs
        # to the employee.
        # ----------------------------------------------------

        $SearchResults = Get-MgSite `
            -Search $UserPrincipalName `
            -Property Id,DisplayName,WebUrl,SiteCollection

        $Sites = @()

        foreach ($Site in $SearchResults) {

            $Sites += [PSCustomObject]@{
                SiteId            = $Site.Id
                SiteName          = $Site.DisplayName
                WebUrl            = $Site.WebUrl
                Relationship      = 'UNKNOWN'
                DocumentLibraries = $null
                Status            = 'DISCOVERED'
            }
        }

        return [PSCustomObject]@{

            UserPrincipalName = $UserPrincipalName

            SitesFound = $Sites

            SiteCount = $Sites.Count

            OwnedSiteCount = @(
                $Sites |
                Where-Object {
                    $_.Relationship -eq 'Owner'
                }
            ).Count

            MemberSiteCount = @(
                $Sites |
                Where-Object {
                    $_.Relationship -eq 'Member'
                }
            ).Count

            ProtectedSiteCount = 0

            Status = if ($Sites.Count -gt 0) {
                'READY'
            }
            else {
                'NOT_FOUND'
            }

            Error = $null
        }
    }
    catch {

        Write-Host ''
        Write-Host 'SharePoint discovery failed.' `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        return [PSCustomObject]@{

            UserPrincipalName = $UserPrincipalName
            SitesFound        = @()
            SiteCount         = 0
            OwnedSiteCount    = 0
            MemberSiteCount   = 0
            ProtectedSiteCount = 0
            Status            = 'ERROR'
            Error             = $_.Exception.Message
        }
    }
}