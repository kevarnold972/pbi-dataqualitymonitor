$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath 

$Config = Get-ProjectConfig -ProjectPath 'e:\_DQM' -ProjectName Example3 

$Config