function Add-NewQueryRowCountTest {
    <#
    .SYNOPSIS
        Compare the row count to a value
    .DESCRIPTION
        Create test to compare the number of rows the query returned to a predetermined value
        This could be used to check for 0 rows when looking for blank rows being added

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

    .PARAMETER TestName
        The name of the Test
        
	.PARAMETER QueryConnectionName
        The connection name to use with the first query

    .PARAMETER QueryName
        The file name in query directory to execute. The file extension needs to be include, 
        for example ordercount.dax

	.PARAMETER ExpectedCount
        The value to be be compared to the query row count

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Add-NewQueryRowCountTest -Config $Config -TestName RowCount-Match `
                -QueryConnectionName StaticResult -QueryName invokequery.json `
                -ExpectedCount 4
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $TestName,
        [Parameter(Mandatory = $true)]
        [string] $QueryConnectionName,
        [Parameter(Mandatory = $true)]
        [string] $QueryName,
        [Parameter(Mandatory = $true)]
        [string] $ExpectedCount

    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $TestsFolder = $Config.TestFolder
        $TestFile = $RootPath + "\" + $TestsFolder + "\" + $TestName + ".json"
        Write-Debug $TestFile
        if (Test-Path -Path $TestFile) {
            Throw "Test already exists"
        }

        #TODO - Verify Connection and Query file exists
    }

    Process {
        $TestNamejson = ConvertTo-Json $TestName
        $ConnectionJson = ConvertTo-Json $QueryConnectionName
        $QueryJson = ConvertTo-Json $QueryName
        $ExpectedCount = ConvertTo-Json $ExpectedCount
        $TestTemplate =
        @"
{
    "TestName": $TestNamejson,
    "Type": "RowCountEqual",
    "ExpectedCount": $ExpectedCount,
    "Queries":  [
         {
            "ConnectionName": $ConnectionJson,
            "QueryFile": $QueryJson
        }
    ]
}
"@
        $TestTemplate | Out-File -FilePath $TestFile 
    }

} #End of Function