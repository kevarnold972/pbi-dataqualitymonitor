function Invoke-Query {
    <#
    .SYNOPSIS
        Executes the query 
    .DESCRIPTION
        The query will be executed using the provided connection and results will be returned and
        saved in the file 

    .PARAMETER Connection
        The Connection object returned by Get-Connection 

	.PARAMETER Query
        The Query Test returned from Get-Query

    .PARAMETER ResultsFileName
        The full path file name to save the results as json

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-Query -Connection $Connection -Query "evalute table" -ResultsFileName "E:\_DQM\Example3\runs\rundate\connectionamequeryname.json"
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Connection,
        [Parameter(Mandatory = $true)]
        [string] $Query,
        [Parameter(Mandatory = $true)]
        [string] $ResultsFileName
    )

    End {
       
        switch ($Connection.Type) {
            "PowerBI" { 
                $DatasetID = $Connection.DatasetID
                $Result = Invoke-PowerBIQuery -DatasetID $DatasetID -Query $Query
                break
             }
            Default {Throw "Connection type is not implemented"; break}
        }

        $Result | ConvertTo-Json | Out-File -FilePath $ResultsFileName 
        return $Result
    }

} #End of Function

function Invoke-PowerBIQuery {
    <#
    .SYNOPSIS
        Executes a PowerBI query 
    .DESCRIPTION
        The PowerBI Query will be executed and the first result set returned. This assumes the 
        Power Bi Connection has already been established.  

    .PARAMETER DatasetID
        The Connection object returned by Get-Connection 

	.PARAMETER Query
        The Query string to be executed

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Invoke-PowerBIQuery -DatasetID $DatasetID -Query "evalute table"
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $DatasetID,
        [Parameter(Mandatory = $true)]
        [string] $Query
    )

    End {
        $Queryjson = $Query | ConvertTo-Json 
        Write-Debug $DatasetID
        Write-Debug $Queryjson
        
        $PBIQuery = @"
{
    "queries": [
        {
        "query": $Queryjson
        }
    ]
    }
"@
        $URL = "https://api.powerbi.com/v1.0/myorg/datasets/" + $DatasetID + "/executeQueries"
        $Result = Invoke-PowerBIRestMethod -Method POST -Url $URL -Body $PBIQuery | ConvertFrom-Json
        $ReturnRows = $Result.results.tables.rows
        return $ReturnRows
    }

} #End of Function


