$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$BuildScript = $ModulePath + "\\BuildModules-Test.ps1" #Ensure the test psm1 file is rebuilt. 
&$BuildScript
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath -Force

$Config = Get-ProjectConfig -ProjectPath 'e:\_DQM' -ProjectName Example3 
Add-NewPBIDatasetConnection  -Config $Config -ConnectionName DevWorkspace-Contoso -DatasetID 56189fd8-4d86-456c-a849-d6e8d1268e5f
