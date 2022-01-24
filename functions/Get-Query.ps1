function Get-Query {
    <#
    .SYNOPSIS
        Obtains the Query file contents
    .DESCRIPTION
        Obtains the Query file contents 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER QueryName
        The Query name to return

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-Query -Config $Config -QueryName NewOrderCount.dax 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $QueryName
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $QueriesFolder = $Config.QueriesFolder
        $QueryFile = $RootPath + "\" + $QueriesFolder + "\" + $QueryName 
        Write-Debug $QueryFile

        if ( ! (Test-Path -Path $QueryFile )) {
            Throw "The Query file does not exists"
        }

    }

    End {
        $Query = Get-Content $QueryFile 
        return $Query
    }

} #End of Function
function Get-AllQueries {
    <#
    .SYNOPSIS
        Obtains All the Queries in the project
    .DESCRIPTION
        Obtains All the Queries in the project

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
        Get-AllQueries -Config $Config 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $QueriesFolder = $Config.QueriesFolder
        $QueryPath = $RootPath + "\" + $QueriesFolder 
        Write-Debug $QueryPath

        if ( ! (Test-Path -Path $QueryPath )) {
            Throw "The Query Folder does not exists"
        }
        
        $Queries = [System.Collections.ArrayList]::new()
    }

    End {
        $FilestoProcess = Get-ChildItem -Path $QueryPath 
        foreach ($f in $FilestoProcess) {
            $QueryName = $f.Name
            $Query = Get-Query -Config $Config -QueryName $QueryName
            [void]$Queries.Add( $Query) 
        }
        
        return $Queries
    }

} #End of Function