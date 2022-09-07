#Requires -Modules ExchangeOnlineManagement, MicrosoftTeams

[CmdletBinding()]
param()

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
        [string] $MailNickName
    )
    # Initialize Checks
    $validDisplayName = $False
    $validMailNickName = $False

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
}

Get-Team | ForEach-Object {
    if($_.DisplayName -clike 'ARCHIVED*') {
        Write-Verbose "INFORMATION: Ignoring archived Team: $($_.DisplayName)"
        continue
    } else {
        Confirm-GroupAttributes -DisplayName "$($_.DisplayName)" -MailNickName "$($_.MailNickName)"
    }
}