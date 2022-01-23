
$OutPutPath = Split-Path $MyInvocation.MyCommand.Path

$InPutPath = $OutPutPath.Replace("tests","functions") + "\\*.ps1"

$OutPutPath = $OutPutPath + "\\DataQualityMonitor.psm1"

Get-Content -Path $InPutPath  | Set-Content -Path $OutPutPath