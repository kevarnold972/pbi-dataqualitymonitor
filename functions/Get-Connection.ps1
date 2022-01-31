function Get-Connection {
    <#
    .SYNOPSIS
        Obtains the project Config and returns a Config Object
    .DESCRIPTION
        Obtains the project Config and returns a Config Object 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER ConnectionName
        The Connection name to return

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-Connection -Config $Config -ConnectionName Test1 
        
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
        $ConnectionFolder = $Config.ConnectionsFolder
        $ConnectionFile = $RootPath + "\" + $ConnectionFolder + "\" + $ConnectionName + ".json"
        Write-Debug $ConnectionFile

        if ( ! (Test-Path -Path $ConnectionFile )) {
            Throw "The Connection file does not exists"
        }

    }

    End {
        $Connection = Get-Content $ConnectionFile | ConvertFrom-Json
        return $Connection
    }

} #End of Function
function Get-AllConnections {
    <#
    .SYNOPSIS
        Obtains All the Connections in the project
    .DESCRIPTION
        Obtains All the Connections in the project

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
        Get-AllConnections -Config $Config 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $ConnectionsFolder = $Config.ConnectionsFolder
        $ConnectionPath = $RootPath + "\" + $ConnectionsFolder 
        Write-Debug $ConnectionPath

        if ( ! (Test-Path -Path $ConnectionPath )) {
            Throw "The Connection Folder does not exists"
        }
        
        $Connections = [System.Collections.ArrayList]::new()
    }

    End {
        $FilestoProcess = Get-ChildItem -Path $ConnectionPath -Filter "*.json"
        foreach ($f in $FilestoProcess) {
            $ConnectionName = $f.Name.Replace(".json","")
            $Connection = Get-Connection -Config $Config -ConnectionName $ConnectionName
            [void]$Connections.Add( $Connection) 
        }
        
        return $Connections
    }

} #End of Function