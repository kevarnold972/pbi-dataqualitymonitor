function Get-Test {
    <#
    .SYNOPSIS
        Obtains the project Config and returns a Config Object
    .DESCRIPTION
        Obtains the project Config and returns a Config Object 

    .PARAMETER Config
        The Config object returned by Get-ProjectConfig 

	.PARAMETER TestName
        The Test name to return

	.NOTES
        Tags: 
        Author:  Kevin Arnold
        Twitter: https://twitter.com/kevarnold
        License: MIT https://opensource.org/licenses/MIT
    .LINK
        https://github.com/kevarnold972/pbi-dataqualitymonitor
    .EXAMPLE
        Get-Test -Config $Config -TestName Test1 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config,
        [Parameter(Mandatory = $true)]
        [string] $TestName
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $TestsFolder = $Config.TestFolder
        $TestFile = $RootPath + "\" + $TestsFolder + "\" + $TestName + ".json"
        Write-Debug $TestFile

        if ( ! (Test-Path -Path $TestFile )) {
            Throw "The Test file does not exists"
        }

    }

    End {
        $Test = Get-Content $TestFile | ConvertFrom-Json
        return $Test
    }

} #End of Function
function Get-AllTest {
    <#
    .SYNOPSIS
        Obtains All the Test in the project
    .DESCRIPTION
        Obtains All the Test in the project

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
        Get-AllTest -Config $Config 
        
	#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object] $Config
    )

    

    Begin {
        $RootPath = $Config.RootPath 
        $TestsFolder = $Config.TestFolder
        $TestPath = $RootPath + "\" + $TestsFolder 
        Write-Debug "Test File to get " $TestFile

        if ( ! (Test-Path -Path $TestPath )) {
            Throw "The Test Folder does not exists"
        }
        
        $Tests = [System.Collections.ArrayList]::new()
    }

    End {
        $FilestoProcess = Get-ChildItem -Path $TestPath -Filter "*.json"
        foreach ($f in $FilestoProcess) {
            $TestName = $f.Name.Replace(".json","")
            $Test = Get-Test -Config $Config -TestName $TestName
            [void]$Tests.Add( $Test) 
        }
        
        return $Tests
    }

} #End of Function