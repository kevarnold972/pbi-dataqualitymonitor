$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$BuildScript = $ModulePath + "\\BuildModules-Test.ps1" #Ensure the test psm1 file is rebuilt. 
&$BuildScript
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath -Force

$Config = Get-ProjectConfig -ProjectPath 'e:\_DQM' -ProjectName Example3 


$Connection = Get-Connection -Config $Config -ConnectionName StaticResult

$RootPath = $Config.RootPath 
$Runfolder = $Config.RunsFolder
$ResultsFileName = $RootPath + "\" + "\" + $Runfolder + "\\Staticinvokequery.json"

$Query = Get-Query -Config $Config -QueryName "invokequery.json"
$Result = Invoke-Query -Connection $Connection -Query $Query -ResultsFileName $ResultsFileName

$Result