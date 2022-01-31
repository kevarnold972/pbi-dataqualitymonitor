$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath 

Connect-PowerBIServiceAccount

$RunGuid = New-Guid
$RunID = "Run" + $RunGuid

$Config = Get-ProjectConfig -ProjectPath '<Your local path' -ProjectName <ProjectName>

$Tests = Get-AllTest -Config $Config 

foreach ($Test in $Tests) {
    $TestName = $Test.TestName
    Invoke-Test -Config $Config -TestName $TestName -RunID $RunID 
}