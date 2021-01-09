# Set Windows "hosts" file for specific user group.
# Copyright (C) 2021  Matas Gumbinas

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

param (
    [string] $PoliciesPath = ".\Policies",
    [string] $BlacklistsPath = ".\Blacklists",
    [string] $DefaultBlacklist = "Default",
    [string] $HostsPath = "C:\Users\matas\OneDrive\Desktop\funapp\Test\hosts",
    [bool] $Debug = $false
)

class Policy
{
    [string] $Name
    [string] $Path
}

class User
{
    [string] $Name
    [Policy] $Policy
}

function Invoke-Exception {
    param (
        [string] $Message
    )

    Set-Location -Path $PSScriptRunPath
    throw $Message
}

function Assert-LocalUserName
{
    param (
        [string] $Name
    )    

    try
    {
        $LocalUser = Get-LocalUser -Name $Name  # TODO: Handle non-existing and disabled local users.
    }
    catch
    {
        Invoke-Exception "Local user '$Name' was not found. Please check if listed usernames in policy files are correct."
    }
    
    if (!$LocalUser.Enabled)
    {
        Invoke-Exception "Local user '$($LocalUser.Name)' exists but is not enabled. Please check if listed usernames in policy files are correct."
    }
}

function Assert-BlacklistPolicy
{
    param (
        [string] $PolicyName,
        [string] $BlacklistsPath
    )

    $BlacklistFilePath = (Join-Path -Path $BlacklistsPath -ChildPath $PolicyName) | Resolve-Path
    $BlacklistFileExists = Test-Path -Path $BlacklistFilePath -PathType Leaf
    if (!$BlacklistFileExists)
    {
        Invoke-Exception "Blacklist file for the policy '$PolicyName' was not found. Check blacklist files and make sure their names correspond to policy filenames (without the file extension part)."
    }
}

Write-Output "Set-UserHosts  Copyright (C) 2021  Matas Gumbinas
This program comes with ABSOLUTELY NO WARRANTY. This is free software, 
and you are welcome to redistribute it under certain conditions."

if ($Debug) { $DebugPreference = "Continue" }
$ErrorActionPreference = "Stop"

$PSScriptRunPath = Get-Location
Set-Location -Path $PSScriptRoot

Assert-BlacklistPolicy -PolicyName $DefaultBlacklist -BlacklistsPath $BlacklistsPath

$CurrentUser = Get-LocalUser -SID ([System.Security.Principal.WindowsIdentity]::GetCurrent().User)
$MatchedUser = $null

$UniqueUsernames = @{}

$PoliciesFiles = Get-ChildItem -Path $PoliciesPath
foreach ($PolicyFile in $PoliciesFiles)
{
    $PolicyFilePath = (Join-Path -Path $PoliciesPath -ChildPath $PolicyFile.Name) | Resolve-Path

    $Policy = [Policy]::new()
    $Policy.Name = (Get-Item -Path $PolicyFilePath).BaseName
    $Policy.Path = $PolicyFilePath

    Assert-BlacklistPolicy -PolicyName $Policy.Name -BlacklistsPath $BlacklistsPath

    $UserNamesList = Get-Content -Path $PolicyFilePath
    foreach ($UserName in $UserNamesList)
    {
        $UserName = $UserName.Trim()

        # Skip empty lines.
        if (!$UserName) { continue }

        Assert-LocalUserName -Name $UserName
        
        if ($UniqueUsernames.ContainsKey($UserName)) 
        {
            Invoke-Exception -Message "User with a name '$UserName' was found in multiple policy files. Please check policies for duplicate user names."
        }

        $UniqueUsernames[$UserName] = $null

        $User = [User]::new()
        $User.Name = $UserName
        $User.Policy = $Policy

        # Match currently logged user with policies.
        if ($CurrentUser.Name -eq $User.Name)
        {
            if ($MatchedUser)
            {
                Invoke-Exception "Current user '$($CurrentUser.Name)' is assigned to policy more than once! Please check policy files for duplicate user names."
            }

            $MatchedUser = $User
        }
    }
}

$MatchedPolicyName = if (!$MatchedUser) { $DefaultBlacklist } else { $MatchedUser.Policy.Name }
$BlacklistPath = (Join-Path -Path $BlacklistsPath -ChildPath $MatchedPolicyName) | Resolve-Path

Write-Debug "Current user name: $($CurrentUser.Name)"
Write-Debug "Matched policy name: $MatchedPolicyName"
Write-Debug "Blacklist path: $BlacklistPath"
Write-Debug "Hosts path: $HostsPath"

if ($Debug) { Copy-Item -Path $BlacklistPath -Destination $HostsPath -WhatIf }
else { Copy-Item -Path $BlacklistPath -Destination $HostsPath }

Set-Location -Path $PSScriptRunPath