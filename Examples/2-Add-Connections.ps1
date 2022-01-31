$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath 

$Config = Get-ProjectConfig -ProjectPath '<Your local path>' -ProjectName <ProjectName>
Add-NewPBIDatasetConnection  -Config $Config -ConnectionName "<Connection1 Name>" -DatasetID <DatasetGUID>
Add-NewPBIDatasetConnection  -Config $Config -ConnectionName "<Connection2 Name>" -DatasetID <DatasetGUID>

 