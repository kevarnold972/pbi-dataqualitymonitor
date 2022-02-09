function Invoke-Test {
    <#
    .SYNOPSIS
        Executes the Test 
    .DESCRIPTION
        The test will be executed using the provided connection and results will be returned and
        saved in the file 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER TestName
        The Test name to run

    .PARAMETER RunID
        The execution run this is associated with

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-Test -Config $Config -TestName Test1 -RunID "Run01"
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $TestName,
        [Parameter(Mandatory = $true)]
        [string] $RunID
    )

    End {

        
        $RunPath = $Config.RootPath + "\" + $Config.RunsFolder + "\" + $RunID

        if ( ! (Test-Path -Path $RunPath )) {
            New-Item -Path $RunPath -ItemType Directory | Out-Null
        }
        
        $Test = Get-Test -Config $Config -TestName $TestName
        
        $QryResults = [System.Collections.ArrayList]::new()
        foreach ($q in $Test.Queries) {
            
            $Connection = Get-Connection -Config $Config -ConnectionName $q.ConnectionName
            $QueryFileName = $q.QueryFile
            
            $Query = Get-Query -Config $Config -QueryName $QueryFileName 
            
            $ResultFileName = $RunPath + "\" + $Test.TestName + "-qry-" + `
                $Connection.ConnectionName + "-" + $q.QueryFile + ".json"
            $QryResult = Invoke-Query -Connection $Connection -Query $Query -ResultsFileName $ResultFileName
            [void]$QryResults.Add($QryResult)
        }

        
        switch ($Test.Type) {
            "equal" {
                $Query1 = $QryResults[0] | ConvertTo-Json
                $Query2 = $QryResults[1] | ConvertTo-Json
                $TestResult = if ($Query1 -eq $Query2) {
                    $true | ConvertTo-Json
                }
                else {
                    $false | ConvertTo-Json
                }
                break
            }
            "RowCountEqual" {
                $QueryRowCount = $QryResults[0].Count
                $ExpectedRowCount = $Test.ExpectedCount
                $TestResult = if ($QueryRowCount -eq $ExpectedRowCount) {
                    $true | ConvertTo-Json
                }
                else {
                    $false | ConvertTo-Json
                }
                break
            }
            Default { Throw "Test type is not implemented"; break }
        }
        
        $TestResultFileName = $RunPath + "\" + $Test.TestName + "-Result.json"
        $ProjectName = $Config.ProjectName | ConvertTo-Json
        $Rundate = Get-Date -Format "MM/dd/yyyy HH:mm" | ConvertTo-Json
        $TestNameJson = $TestName | ConvertTo-Json
        $RunIDJson = $RunID | ConvertTo-Json
        
        $Resultjson = @"
{
    "ProjectName": $ProjectName,
    "TestName": $TestNameJson,
    "RunID": $RunIDJson,
    "RunDate": $Rundate,
    "Result": $TestResult
}
"@
        $Resultjson | Out-File -FilePath $TestResultFileName
    }

} #End of Function
