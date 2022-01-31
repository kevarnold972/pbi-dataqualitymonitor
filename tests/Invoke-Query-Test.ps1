$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$BuildScript = $ModulePath + "\\BuildModules-Test.ps1" #Ensure the test psm1 file is rebuilt. 
&$BuildScript
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath -Force

$Config = Get-ProjectConfig -ProjectPath 'e:\_DQM' -ProjectName Example3 
Remove-DatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso

Add-NewPBIDatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso -DatasetID guid

$Connection = Get-Connection -Config $Config -ConnectionName DevWorkspace-Contoso

$RootPath = $Config.RootPath 
$Runfolder = $Config.RunsFolder
$ResultsFileName = $RootPath + "\" + "\" + $Runfolder + "\\invokequery.json"
Connect-PowerBIServiceAccount

$Query = "query"
$Result = Invoke-Query -Connection $Connection -Query $Query -ResultsFileName $ResultsFileName

$Result