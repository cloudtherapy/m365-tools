#Requires -Modules ExchangeOnlineManagement, MicrosoftTeams

[CmdletBinding()]
param()

# Verify connection to MS Teams or establish new
try {
    $null = Get-CsTenant
} catch {
    Write-Host "[Connecting to Microsoft Teams]"
    $null = Connect-MicrosoftTeams
}

# Verify connection to Exchange online or establish new
try {
    $null = Get-UnifiedGroup
} catch {
    Write-Host "[Connecting to Exchange Online]"
    $null = Connect-ExchangeOnline -ShowBanner:$false
}
    

function Confirm-GroupAttributes {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $DisplayName,
        
        [Parameter()]
        [string] $MailNickName,

        [Parameter()]
        [string] $SmtpAddress
    )
    # Initialize Checks
    $validDisplayName = $False
    $validMailNickName = $False
    $validSmtpAddress = $False

    # Check Display Name is created by Orchestry. Should start with ORG- or PRJ-
    if (($DisplayName -clike 'PRJ-*') -or ($DisplayName -clike 'ORG-*')) {
        $validDisplayName = $True
    } else {
        Write-Output "Team '$($DisplayName)' appears to have been created independently of Orchestry"
    }

    # Check Mail Nickname is derivative of Display Name
    $expectedName = $DisplayName.ToLower() -replace ' ','-' -replace '\+g|\&|,' -replace '--','-'
    if ($MailNickName -eq $expectedName) {
        $validMailNickName = $True
    } else {
        Write-Output "Team '$($DisplayName)' mail nickname '$($MailNickName)' does not match expected name '$($expectedName)'"
    }

    # Check SMTP Primary Address is derivative of Display Name
    $expectedAddress = $DisplayName.ToLower() -replace ' ','-' -replace '\+g|\&|,' -replace '--','-'
    $expectedAddress += '@cetechllc.com'
    if ($SmtpAddress -eq $expectedName) {
        $validSmtpAddress = $True
    } else {
        Write-Output "Group '$($DisplayName)' smtp address '$($SmtpAddress)' does not match expected address '$($expectedAddress)'"
    }
}

Get-Team | ForEach-Object {
    if($_.DisplayName -clike 'ARCHIVED*') {
        Write-Verbose "INFORMATION: Ignoring archived Team: $($_.DisplayName)"
        continue
    } else {
        $smtpAddress = (Get-unifiedGroup $_.DisplayName).PrimarySmtpAddress
        Confirm-GroupAttributes -DisplayName "$($_.DisplayName)" -MailNickName "$($_.MailNickName)" -SmtpAddress $smtpAddress
    }
}