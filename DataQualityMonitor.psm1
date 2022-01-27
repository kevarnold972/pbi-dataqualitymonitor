function Add-NewPBIDatasetConnection {
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
        Add-NewPBIDatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso -DatasetID 56189fd8-4d86-456c-a849-d6e8d1268e5f
        
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
    }

} #End of Function
function Add-NewQueriesEqualTest {
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
        Add-NewQueriesEqualTest -Config $Config -TestName OrderCount-DevProd-Match`
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
    "Queries":  [
         {
            "ConnectionName": $Connection1Json,
            "QueryFile": $Query1Json
        },
         {
            "ConnectionName": $Connection2Json,
            "QueryFile": $Query2Json
        }
    ]
}
"@
        $TestTemplate | Out-File -FilePath $TestFile 
    }

} #End of Function
function Get-Connection {
    <#
    .SYNOPSIS
        Obtains the project Config and returns a Config Object
    .DESCRIPTION
        Obtains the project Config and returns a Config Object 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER ConnectionName
        The Connection name to return

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-Connection -Config $Config -ConnectionName Test1 
        
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
        $ConnectionFolder = $Config.ConnectionsFolder
        $ConnectionFile = $RootPath + "\" + $ConnectionFolder + "\" + $ConnectionName + ".json"
        Write-Debug $ConnectionFile

        if ( ! (Test-Path -Path $ConnectionFile )) {
            Throw "The Connection file does not exists"
        }

    }

    End {
        $Connection = Get-Content $ConnectionFile | ConvertFrom-Json
        return $Connection
    }

} #End of Function
function Get-AllConnections {
    <#
    .SYNOPSIS
        Obtains All the Connections in the project
    .DESCRIPTION
        Obtains All the Connections in the project

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-AllConnections -Config $Config 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $ConnectionsFolder = $Config.ConnectionsFolder
        $ConnectionPath = $RootPath + "\" + $ConnectionsFolder 
        Write-Debug $ConnectionPath

        if ( ! (Test-Path -Path $ConnectionPath )) {
            Throw "The Connection Folder does not exists"
        }
        
        $Connections = [System.Collections.ArrayList]::new()
    }

    End {
        $FilestoProcess = Get-ChildItem -Path $ConnectionPath -Filter "*.json"
        foreach ($f in $FilestoProcess) {
            $ConnectionName = $f.Name.Replace(".json","")
            $Connection = Get-Connection -Config $Config -ConnectionName $ConnectionName
            [void]$Connections.Add( $Connection) 
        }
        
        return $Connections
    }

} #End of Function
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
function Get-Query {
    <#
    .SYNOPSIS
        Obtains the Query file contents
    .DESCRIPTION
        Obtains the Query file contents 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER QueryName
        The Query name to return

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-Query -Config $Config -QueryName NewOrderCount.dax 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $QueryName
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $QueriesFolder = $Config.QueriesFolder
        $QueryFile = $RootPath + "\" + $QueriesFolder + "\" + $QueryName 
        Write-Debug $QueryFile

        if ( ! (Test-Path -Path $QueryFile )) {
            Throw "The Query file does not exists"
        }

    }

    End {
        $Query = Get-Content $QueryFile 
        return $Query
    }

} #End of Function
function Get-AllQueries {
    <#
    .SYNOPSIS
        Obtains All the Queries in the project
    .DESCRIPTION
        Obtains All the Queries in the project

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-AllQueries -Config $Config 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $QueriesFolder = $Config.QueriesFolder
        $QueryPath = $RootPath + "\" + $QueriesFolder 
        Write-Debug $QueryPath

        if ( ! (Test-Path -Path $QueryPath )) {
            Throw "The Query Folder does not exists"
        }
        
        $Queries = [System.Collections.ArrayList]::new()
    }

    End {
        $FilestoProcess = Get-ChildItem -Path $QueryPath 
        foreach ($f in $FilestoProcess) {
            $QueryName = $f.Name
            $Query = Get-Query -Config $Config -QueryName $QueryName
            [void]$Queries.Add( $Query) 
        }
        
        return $Queries
    }

} #End of Function
function Get-Test {
    <#
    .SYNOPSIS
        Obtains the project Config and returns a Config Object
    .DESCRIPTION
        Obtains the project Config and returns a Config Object 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER TestName
        The Test name to return

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-Test -Config $Config -TestName Test1 
        
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

        if ( ! (Test-Path -Path $TestFile )) {
            Throw "The Test file does not exists"
        }

    }

    End {
        $Test = Get-Content $TestFile | ConvertFrom-Json
        return $Test
    }

} #End of Function
function Get-AllTest {
    <#
    .SYNOPSIS
        Obtains All the Test in the project
    .DESCRIPTION
        Obtains All the Test in the project

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-AllTest -Config $Config 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $TestsFolder = $Config.TestFolder
        $TestPath = $RootPath + "\" + $TestsFolder 
        Write-Debug $TestFile

        if ( ! (Test-Path -Path $TestPath )) {
            Throw "The Test Folder does not exists"
        }
        
        $Tests = [System.Collections.ArrayList]::new()
    }

    End {
        $FilestoProcess = Get-ChildItem -Path $TestPath -Filter "*.json"
        foreach ($f in $FilestoProcess) {
            $TestName = $f.Name.Replace(".json","")
            $Test = Get-Test -Config $Config -TestName $TestName
            [void]$Tests.Add( $Test) 
        }
        
        return $Tests
    }

} #End of Function
function Invoke-Query {
    <#
    .SYNOPSIS
        Executes the query 
    .DESCRIPTION
        The query will be executed using the provided connection and results will be returned and
        saved in the file 

    .PARAMETER Connection
        The Connection object returned by Get-Connection 

	.PARAMETER Query
        The Query Test returned from Get-Query

    .PARAMETER ResultsFileName
        The full path file name to save the results as json

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-Query -Connection $Connection -Query "evalute table" -ResultsFileName "E:\_DQM\Example3\runs\rundate\connectionamequeryname.json"
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Connection,
        [Parameter(Mandatory = $true)]
        [string] $Query,
        [Parameter(Mandatory = $true)]
        [string] $ResultsFileName
    )

    End {
       
        switch ($Connection.Type) {
            "PowerBI" { 
                $DatasetID = $Connection.DatasetID
                $Result = Invoke-PowerBIQuery -DatasetID $DatasetID -Query $Query
                break
             }
            Default {Throw "Connection type is not implemented"; break}
        }

        $Result | ConvertTo-Json | Out-File -FilePath $ResultsFileName 
        return $Result
    }

} #End of Function

function Invoke-PowerBIQuery {
    <#
    .SYNOPSIS
        Executes a PowerBI query 
    .DESCRIPTION
        The PowerBI Query will be executed and the first result set returned. This assumes the 
        Power Bi Connection has already been established.  

    .PARAMETER DatasetID
        The Connection object returned by Get-Connection 

	.PARAMETER Query
        The Query string to be executed

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-PowerBIQuery -DatasetID $DatasetID -Query "evalute table"
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $DatasetID,
        [Parameter(Mandatory = $true)]
        [string] $Query
    )

    End {
        $Queryjson = $Query | ConvertTo-Json 
        Write-Debug $DatasetID
        Write-Debug $Queryjson
        
        $PBIQuery = @"
{
    "queries": [
        {
        "query": $Queryjson
        }
    ]
    }
"@
        $URL = "https://api.powerbi.com/v1.0/myorg/datasets/" + $DatasetID + "/executeQueries"
        $Result = Invoke-PowerBIRestMethod -Method POST -Url $URL -Body $PBIQuery | ConvertFrom-Json
        $ReturnRows = $Result.results.tables.rows
        return $ReturnRows
    }

} #End of Function


function Invoke-Test {
    <#
    .SYNOPSIS
        Executes the Test 
    .DESCRIPTION
        The test will be executed using the provided connection and results will be returned and
        saved in the file 

    .PARAMETER Connection
        The Connection object returned by Get-Connection 

	.PARAMETER Query
        The Query Test returned from Get-Query

    .PARAMETER ResultsFileName
        The full path file name to save the results as json

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-Query -Connection $Connection -Query "evalute table" -ResultsFileName "E:\_DQM\Example3\runs\rundate\connectionamequeryname.json"
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Connection,
        [Parameter(Mandatory = $true)]
        [string] $Query,
        [Parameter(Mandatory = $true)]
        [string] $ResultsFileName
    )

    End {
       
        switch ($Connection.Type) {
            "PowerBI" { 
                $DatasetID = $Connection.DatasetID
                $Result = Invoke-PowerBIQuery -DatasetID $DatasetID -Query $Query
                break
             }
            Default {Throw "Connection type is not implemented"; break}
        }

        $Result | ConvertTo-Json | Out-File -FilePath $ResultsFileName 
        return $Result
    }

} #End of Function

function Invoke-PowerBIQuery {
    <#
    .SYNOPSIS
        Executes a PowerBI query 
    .DESCRIPTION
        The PowerBI Query will be executed and the first result set returned. This assumes the 
        Power Bi Connection has already been established.  

    .PARAMETER DatasetID
        The Connection object returned by Get-Connection 

	.PARAMETER Query
        The Query string to be executed

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-PowerBIQuery -DatasetID $DatasetID -Query "evalute table"
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $DatasetID,
        [Parameter(Mandatory = $true)]
        [string] $Query
    )

    End {
        $Queryjson = $Query | ConvertTo-Json 
        Write-Debug $DatasetID
        Write-Debug $Queryjson
        
        $PBIQuery = @"
{
    "queries": [
        {
        "query": $Queryjson
        }
    ]
    }
"@
        $URL = "https://api.powerbi.com/v1.0/myorg/datasets/" + $DatasetID + "/executeQueries"
        $Result = Invoke-PowerBIRestMethod -Method POST -Url $URL -Body $PBIQuery | ConvertFrom-Json
        $ReturnRows = $Result.results.tables.rows
        return $ReturnRows
    }

} #End of Function


function Remove-DatasetConnection {
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
        Remove-DatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso
        
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
function Remove-Test {
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
        Remove-Test -Config $Config -TestName Test1
        
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
