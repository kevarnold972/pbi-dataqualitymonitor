function Add-StaticResultConnection {
    <#
    .SYNOPSIS
        Create a Static Results connection
    .DESCRIPTION
        Create a Static Results connection that can be used in the project

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Add-StaticResultConnection -Config $Config
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config

    )

    

    Begin {
        $ConnectionName = "StaticResult"
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
        $StaticConnectionTemplate =
        @"
{
    "ConnectionName": $Connectionjson,
    "Type": "Static"
}
"@
        $StaticConnectionTemplate | Out-File -FilePath $ConnectionFile 
    }

} #End of Function