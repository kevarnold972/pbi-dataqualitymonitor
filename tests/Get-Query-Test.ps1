$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$BuildScript = $ModulePath + "\\BuildModules-Test.ps1" #Ensure the test psm1 file is rebuilt. 
&$BuildScript
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath -Force

$Config = Get-ProjectConfig -ProjectPath 'e:\_DQM' -ProjectName Example3 

$RootPath = $Config.RootPath
$QueriesFolder = $Config.QueriesFolder
$QueryFile = $RootPath + "\" + $QueriesFolder + "\\testing.dax"
$QueryFile
"Query Text Here" | Out-File -FilePath $QueryFile

$Query = Get-Query -Config $Config -QueryName "testing.dax"
$Query

