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
function Invoke-DeleteDatasetConnection {
    <#
    .SYNOPSIS
        Removes the dataset Connection from the project
    .DESCRIPTION
        Removes the dataset Connection from the project 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER ConnectionName
        The connection name to setup, which will also be the file name. It is recommended to include the workspace
        in the name.

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-DeleteDatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionName
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $ConnectionsFolder = $Config.ConnectionsFolder 
        $ConnectionFile = $RootPath + "\" + $ConnectionsFolder + "\" + $ConnectionName + ".json"
        Write-Debug $ConnectionFile
        
    }

    Process {
        Remove-Item $ConnectionFile -ErrorAction Ignore
    }

} #End of Function
function Invoke-DeleteTest {
    <#
    .SYNOPSIS
        Removes the Test from the project
    .DESCRIPTION
        Removes the Test from the project 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER TestName
        The name of the Test

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-DeleteTest -Config $Config -TestName Test1
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $TestName
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $TestsFolder = $Config.TestFolder
        $TestFile = $RootPath + "\" + $TestsFolder + "\" + $TestName + ".json"
        Write-Debug $TestFile
        
    }

    Process {
        Remove-Item $TestFile -ErrorAction Ignore
    }

} #End of Function
function Invoke-NewPBIDatasetConnection {
    <#
    .SYNOPSIS
        Create a Power BI dataset connection
    .DESCRIPTION
        Create a Power BI dataset connection

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER ConnectionName
        The connection name to setup, which will also be the file name. It is recommended to include the workspace
        in the name.

    .PARAMETER DatasetID
        The GUID from Power BI for the dataset. This can easily be obtained from DAX Studio

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-NewPBIDatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso -DatasetID 56189fd8-4d86-456c-a849-d6e8d1268e5f
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionName,
        [Parameter(Mandatory = $true)]
        [string] $DatasetID

    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $ConnectionsFolder = $Config.ConnectionsFolder 
        $ConnectionFile = $RootPath + "\" + $ConnectionsFolder + "\" + $ConnectionName + ".json"
        Write-Debug $ConnectionFile
        if (Test-Path -Path $ConnectionFile) {
            Throw "Connection already exists"
        }
    }

    Process {
        $Connectionjson = ConvertTo-Json $ConnectionName
        $DatasetIDJson = ConvertTo-Json $DatasetID
        $PBIConnectionTemplate =
        @"
{
    "ConnectionName": $Connectionjson,
    "Type": "PowerBI",
    "DatasetID": $DatasetIDJson
}
"@
        $PBIConnectionTemplate | Out-File -FilePath $ConnectionFile 
    }

} #End of Function
function Invoke-NewProject {
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
        Invoke-NewProject -ProjectPath 'c:\DQM' -ProjectName Example1 
        
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
    }

} #End of Function
function Invoke-NewQueriesEqualTest {
    <#
    .SYNOPSIS
        Create a equal compare test
    .DESCRIPTION
        Create a test that will run 2 queries and ensure the results are equal

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

    .PARAMETER TestName
        The name of the Test
        
	.PARAMETER Query1ConnectionName
        The connection name to use with the first query

    .PARAMETER Query1Name
        The file name in query directory to execute. The file extension needs to be include, 
        for example ordercount.dax

	.PARAMETER Query2ConnectionName
        The connection name to use with the first query

    .PARAMETER Query2Name
        The file name in query directory to execute. The file extension needs to be include, 
        for example ordercount.dax

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-NewQueriesEqualTest -Config $Config -TestName OrderCount-DevProd-Match`
                -Query1ConnectionName DevWorkspace-Contoso -Query1Name ordercount.dax `
                -Query2ConnectionName ProdWorkspace-Contoso -Query2Name ordercount.dax
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $TestName,
        [Parameter(Mandatory = $true)]
        [string] $Query1ConnectionName,
        [Parameter(Mandatory = $true)]
        [string] $Query1Name,
        [Parameter(Mandatory = $true)]
        [string] $Query2ConnectionName,
        [Parameter(Mandatory = $true)]
        [string] $Query2Name

    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $TestsFolder = $Config.TestFolder
        $TestFile = $RootPath + "\" + $TestsFolder + "\" + $TestName + ".json"
        Write-Debug $TestFile
        if (Test-Path -Path $TestFile) {
            Throw "Test already exists"
        }
    }

    Process {
        $TestNamejson = ConvertTo-Json $TestName
        $Connection1Json = ConvertTo-Json $Query1ConnectionName
        $Query1Json = ConvertTo-Json $Query1Name
        $Connection2Json = ConvertTo-Json $Query2ConnectionName
        $Query2Json = ConvertTo-Json $Query2Name
        $TestTemplate =
        @"
{
    "TestName": $TestNamejson,
    "Type": "Equal",
    "Queries":  {
        "Query1": {
            "ConnectionName": $Connection1Json,
            "QueryFile": $Query1Json
        },
        "Query2": {
            "ConnectionName": $Connection2Json,
            "QueryFile": $Query2Json
        }
    }
}
"@
        $TestTemplate | Out-File -FilePath $TestFile 
    }

} #End of Function
