function Remove-DatasetConnection {
    <#
    .SYNOPSIS
        Removes the dataset Connection from the project
    .DESCRIPTION
        Removes the dataset Connection from the project 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER ConnectionName
        The connection name to setup, which will also be the file name. It is recommended to include the workspace
        in the name.

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Remove-DatasetConnection -Config $Config -ConnectionName DevWorkspace-Contoso
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $ConnectionName
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $ConnectionsFolder = $Config.ConnectionsFolder 
        $ConnectionFile = $RootPath + "\" + $ConnectionsFolder + "\" + $ConnectionName + ".json"
        Write-Debug $ConnectionFile
        
    }

    Process {
        Remove-Item $ConnectionFile -ErrorAction Ignore
    }

} #End of Function