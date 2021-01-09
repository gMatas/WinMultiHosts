# WinMultiHosts

## Description

Windows Multi-Hosts (WSB) is a Powershell (>=5.1) application that is designed to extend the normal  Windows `hosts` file (located at `C:\Windows\System32\drivers\etc\hosts`) functionality by making it available to be configured for multiple specific users. This is accomplished simply by loading user depended pre-defined `hosts` file on user sign-in.

This application can be particulary usefull for **Parental Control** purposes. By loading specific `hosts` file for a particular group of users, the administrator of this app can blacklist insecure, dangerous and/or illicit websites not apropriate for various people.

WSB app consists of three main parts:

- `Set-UserHosts.ps1` powershell script that handles all of the logic behind the app;
- `Policies\` directory is made up of policy files for specific user groups that defines which `hosts` file template will be loaded for which user;
- `Templates\` directory that contains pre-defined `hosts` files for specific policies.

## Usage

To use this app, follow these steps:

1. Backup original `hosts` file (found at `C:\Windows\System32\drivers\etc\hosts`)!
2. Download this repository and extract it.
3. Create two new folders "`Policies`" and "`Templates`" in the extracted app folder `WinMultiHosts`.
4. For each different users group create a new policy file in the policies directory (see "Policy file" section below for creating policy files).
5. For each created policy file add a matching template file (See "Template file" section below for creating template files) that will replace `hosts` file for user listed in the policy.
6. TODO: add more steps.

### Policy file

Policy files are just text files that lists users names to which a specific `hosts` file is created. Example policy files can be found in `.\Example\Policies\` directory. There, two policy files were created: "*Gaming.txt*" and "*Study.txt*". In each of these files users names are listed line-by-line. 

Single user name can not be listed more than once in a single policy file. Otherwise, an error will occur.

### Template file

Template files are just `hosts` files specific for a particular user group policy. 

Only template files that have matching names (without file extension part) with policy files are used. An exception is the "Default" template file, that does not have a defined policy file. The default template file is activated when a user that is not defined in any of the policies, logs-in. See example template files in `.\Example\Templates\` directory.

## License

**WinMultiHosts**  Copyright (C) 2021  Matas Gumbinas

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.