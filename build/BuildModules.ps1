
$OutPutPath = Split-Path $MyInvocation.MyCommand.Path

$InPutPath = $OutPutPath.Replace("build","functions") + "\\*.ps1"

$OutPutPath = $OutPutPath.Replace("build","") + "\\DWValidation.psm1"

Get-Content -Path $InPutPath | Set-Content -Path $OutPutPath