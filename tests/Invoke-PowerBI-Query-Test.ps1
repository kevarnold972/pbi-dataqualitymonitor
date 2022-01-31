$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$BuildScript = $ModulePath + "\\BuildModules-Test.ps1" #Ensure the test psm1 file is rebuilt. 
&$BuildScript
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath -Force

Connect-PowerBIServiceAccount
$DatasetID = "guid"
$Query = "query"
$Result = Invoke-PowerBIQuery -DatasetID $DatasetID -Query $Query

$Result