$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath 

$Config = Get-ProjectConfig -ProjectPath '<Your local path>' -ProjectName <ProjectName>

#This example shows running different queries against the same model and expects them to return the same result
Add-NewQueriesEqualTest -Config $Config -TestName "<Test1 Name>" `
                -Query1ConnectionName "<Connection1 Name>" -Query1Name "Query1.dax" `
                -Query2ConnectionName "<Connection1 Name>" -Query2Name "Query2.dax" 

Add-NewQueriesEqualTest -Config $Config -TestName "<Test2 Name>" `
                -Query1ConnectionName "<Connection1 Name>" -Query1Name "Query3.dax" `
                -Query2ConnectionName "<Connection2 Name>" -Query2Name "Query3.dax"  