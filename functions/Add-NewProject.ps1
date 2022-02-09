function Add-NewProject {
    <#
    .SYNOPSIS
        Create the root project directory
    .DESCRIPTION
        This command creates the directory structure and default files for a new project  

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
        Add-NewProject -ProjectPath 'c:\DQM' -ProjectName Example1 
        
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

        if ( ! (Test-Path -Path $ProjectPath -PathType Container)) {
            Throw "ProjectPath must be a valid folder"
        }

        if (Test-Path -Path $ProjectNamePath) {
            Throw "Project already exists"
        }
    }

    Process {
        New-Item -Path $ProjectNamePath -ItemType Directory                         | Out-Null
        New-Item -Path ($ProjectNamePath + "\connections") -ItemType Directory  | Out-Null
        New-Item -Path ($ProjectNamePath + "\queries") -ItemType Directory  | Out-Null
        New-Item -Path ($ProjectNamePath + "\tests") -ItemType Directory    | Out-Null
        New-Item -Path ($ProjectNamePath + "\runs") -ItemType Directory | Out-Null
        $ConfigFile = $ProjectNamePath + "\config.json"
        
        $RPJson = ConvertTo-Json -InputObject $ProjectNamePath
        $PNJson = ConvertTo-Json -InputObject $ProjectName
        $ConfigTemplate =
        @"
{
    "ProjectName": $PNJson,
    "RootPath": $RPJson,
    "ConnectionsFolder": "connections",
    "QueriesFolder": "queries",
    "TestFolder": "tests",
    "RunsFolder": "runs"
}
"@
        $ConfigTemplate | Out-File -FilePath $ConfigFile 
        $Config = Get-ProjectConfig -ProjectPath $ProjectPath -ProjectName $ProjectName
        Add-StaticResultConnection  -Config $Config
    }
    

} #End of Function