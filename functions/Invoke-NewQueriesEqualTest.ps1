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