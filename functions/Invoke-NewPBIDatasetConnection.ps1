function Invoke-NewPBIDatasetConnection {
    <#
    .SYNOPSIS
        Create a Power BI dataset connection
    .DESCRIPTION
        Create a Power BI dataset connection

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER ConnectionName
        The connection name to setup, which will also be the file name. It is recommended to include the workspace
        in the name.

    .PARAMETER DatasetID
        The GUID from Power BI for the dataset. This can easily be obtained from DAX Studio

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-NewPBIDatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso -DatasetID 56189fd8-4d86-456c-a849-d6e8d1268e5f
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionName,
        [Parameter(Mandatory = $true)]
        [string] $DatasetID

    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $ConnectionsFolder = $Config.ConnectionsFolder 
        $ConnectionFile = $RootPath + "\" + $ConnectionsFolder + "\" + $ConnectionName + ".json"
        Write-Debug $ConnectionFile
        if (Test-Path -Path $ConnectionFile) {
            Throw "Connection already exists"
        }
    }

    Process {
        $Connectionjson = ConvertTo-Json $ConnectionName
        $DatasetIDJson = ConvertTo-Json $DatasetID
        $PBIConnectionTemplate =
        @"
{
    "ConnectionName": $Connectionjson,
    "Type": "PowerBI",
    "DatasetID": $DatasetIDJson
}
"@
        $PBIConnectionTemplate | Out-File -FilePath $ConnectionFile 
    }

} #End of Function