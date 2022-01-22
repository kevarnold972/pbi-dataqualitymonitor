$command = $MyInvocation.MyCommand.Source.Replace("-Test","").Replace("tests","functions")

. $command

Invoke-NewProject -ProjectPath 'e:\_DQM' -ProjectName Example2 