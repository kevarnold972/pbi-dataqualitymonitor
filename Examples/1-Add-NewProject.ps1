$ModulePath = Split-Path $MyInvocation.MyCommand.Path 
$ModulePath = $ModulePath + "\\DataQualityMonitor.psm1"
Import-Module $ModulePath 

Add-NewProject -ProjectPath '<Your local path>' -ProjectName <ProjectName>
