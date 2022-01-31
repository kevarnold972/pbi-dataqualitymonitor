function Get-ProjectConfig {
    <#
    .SYNOPSIS
        Obtains the project Config and returns a Config Object
    .DESCRIPTION
        Obtains the project Config and returns a Config Object 

    .PARAMETER ProjectPath
        The directory path to create the project

	.PARAMETER ProjectName
        The Project name to setup

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-ProjectConfig -ProjectPath 'c:\DQM' -ProjectName Example1 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string] $ProjectPath,
        [Parameter(Mandatory = $true)]
        [string] $ProjectName

    )

    

    Begin {
        $ProjectNamePath = $ProjectPath + "\" + $ProjectName
        $ConfigFile = $ProjectNamePath + "\config.json"

        if ( ! (Test-Path -Path $ProjectNamePath )) {
            Throw "The Project does not exists"
        }

        if ( ! (Test-Path -Path $ConfigFile )) {
            Throw "The Project Config file does not exists"
        }

    }

    Process {
        $Config = Get-Content $ConfigFile | ConvertFrom-Json
        return $Config
    }

} #End of Function