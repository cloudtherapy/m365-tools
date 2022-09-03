#Requires -Modules ExchangeOnlineManagement, MicrosoftTeams

# Verify connection to MS Teams or establish new
try {
   $null = Get-CsTenant
} catch {
    $null = Connect-MicrosoftTeams
}

function Confirm-GroupAttributes {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $DisplayName,
        
        [Parameter()]
        [string] $PrimarySmtpAddress
    )
    # Initialize Checks
    $validDisplayName = $False
    $validPrimarySmtpAddress = $False

    # Check Display Name is created by Orchestry. Should start with ORG- or PRJ-
    if (($DisplayName -clike 'PRJ-*') -or ($DisplayName -clike 'ORG-*')) {
        $validDisplayName = $True
    } else {
        Write-Output "Group '$($DisplayName)' appears to have been created independently of Orchestry"
    }

    # Check SMTP Primary Address is derivative of Display Name
    $expectedName = $DisplayName.ToLower() -replace ' ','-' -replace '\+g|\&|,' -replace '--','-'
    $expectedName += '@cetechllc.com'
    if ($PrimarySmtpAddress -eq $expectedName) {
        $validPrimarySmtpAddress = $True
    } else {
        Write-Output "Group '$($DisplayName)' smtp address '$($PrimarySmtpAddress)' does not match expected name '$($expectedName)'"
    }
}

Get-UnifiedGroup | ForEach-Object {
   Confirm-GroupAttributes -DisplayName "$($_.DisplayName)" -PrimarySmtpAddress "$($_.PrimarySmtpAddress)"
}