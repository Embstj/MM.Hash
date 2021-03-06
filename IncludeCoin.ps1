function Set-Stat {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Name, 
        [Parameter(Mandatory=$true)]
        [Double]$Value, 
        [Parameter(Mandatory=$false)]
        [DateTime]$Date = (Get-Date)
    )

    $Path = "Stats\$Name.txt"
    $Date = $Date.ToUniversalTime()
    $SmallestValue = 1E-20

    $Stat = [PSCustomObject]@{
        Live = $Value
        Minute = $Value
        Minute_Fluctuation = 1/2
        Minute_5 = $Value
        Minute_5_Fluctuation = 1/2
        Minute_10 = $Value
        Minute_10_Fluctuation = 1/2
        Hour = $Value
        Hour_Fluctuation = 1/2
        Day = $Value
        Day_Fluctuation = 1/2
        Week = $Value
        Week_Fluctuation = 1/2
        Updated = $Date
    }

    if(Test-Path $Path){$Stat = Get-Content $Path | ConvertFrom-Json}

    $Stat = [PSCustomObject]@{
        Live = [Double]$Stat.Live
        Minute = [Double]$Stat.Minute
        Minute_Fluctuation = [Double]$Stat.Minute_Fluctuation
        Minute_5 = [Double]$Stat.Minute_5
        Minute_5_Fluctuation = [Double]$Stat.Minute_5_Fluctuation
        Minute_10 = [Double]$Stat.Minute_10
        Minute_10_Fluctuation = [Double]$Stat.Minute_10_Fluctuation
        Hour = [Double]$Stat.Hour
        Hour_Fluctuation = [Double]$Stat.Hour_Fluctuation
        Day = [Double]$Stat.Day
        Day_Fluctuation = [Double]$Stat.Day_Fluctuation
        Week = [Double]$Stat.Week
        Week_Fluctuation = [Double]$Stat.Week_Fluctuation
        Updated = [DateTime]$Stat.Updated
    }
    
    $Span_Minute = [Math]::Min(($Date-$Stat.Updated).TotalMinutes,1)
    $Span_Minute_5 = [Math]::Min((($Date-$Stat.Updated).TotalMinutes/5),1)
    $Span_Minute_10 = [Math]::Min((($Date-$Stat.Updated).TotalMinutes/10),1)
    $Span_Hour = [Math]::Min(($Date-$Stat.Updated).TotalHours,1)
    $Span_Day = [Math]::Min(($Date-$Stat.Updated).TotalDays,1)
    $Span_Week = [Math]::Min((($Date-$Stat.Updated).TotalDays/7),1)

    $Stat = [PSCustomObject]@{
        Live = $Value
        Minute = ((1-$Span_Minute)*$Stat.Minute)+($Span_Minute*$Value)
        Minute_Fluctuation = ((1-$Span_Minute)*$Stat.Minute_Fluctuation)+
            ($Span_Minute*([Math]::Abs($Value-$Stat.Minute)/[Math]::Max([Math]::Abs($Stat.Minute),$SmallestValue)))
        Minute_5 = ((1-$Span_Minute_5)*$Stat.Minute_5)+($Span_Minute_5*$Value)
        Minute_5_Fluctuation = ((1-$Span_Minute_5)*$Stat.Minute_5_Fluctuation)+
            ($Span_Minute_5*([Math]::Abs($Value-$Stat.Minute_5)/[Math]::Max([Math]::Abs($Stat.Minute_5),$SmallestValue)))
        Minute_10 = ((1-$Span_Minute_10)*$Stat.Minute_10)+($Span_Minute_10*$Value)
        Minute_10_Fluctuation = ((1-$Span_Minute_10)*$Stat.Minute_10_Fluctuation)+
            ($Span_Minute_10*([Math]::Abs($Value-$Stat.Minute_10)/[Math]::Max([Math]::Abs($Stat.Minute_10),$SmallestValue)))
        Hour = ((1-$Span_Hour)*$Stat.Hour)+($Span_Hour*$Value)
        Hour_Fluctuation = ((1-$Span_Hour)*$Stat.Hour_Fluctuation)+
            ($Span_Hour*([Math]::Abs($Value-$Stat.Hour)/[Math]::Max([Math]::Abs($Stat.Hour),$SmallestValue)))
        Day = ((1-$Span_Day)*$Stat.Day)+($Span_Day*$Value)
        Day_Fluctuation = ((1-$Span_Day)*$Stat.Day_Fluctuation)+
            ($Span_Day*([Math]::Abs($Value-$Stat.Day)/[Math]::Max([Math]::Abs($Stat.Day),$SmallestValue)))
        Week = ((1-$Span_Week)*$Stat.Week)+($Span_Week*$Value)
        Week_Fluctuation = ((1-$Span_Week)*$Stat.Week_Fluctuation)+
            ($Span_Week*([Math]::Abs($Value-$Stat.Week)/[Math]::Max([Math]::Abs($Stat.Week),$SmallestValue)))
        Updated = $Date
    }

    if(-not (Test-Path "Stats")){New-Item "Stats" -ItemType "directory"}
    [PSCustomObject]@{
        Live = [Decimal]$Stat.Live
        Minute = [Decimal]$Stat.Minute
        Minute_Fluctuation = [Double]$Stat.Minute_Fluctuation
        Minute_5 = [Decimal]$Stat.Minute_5
        Minute_5_Fluctuation = [Double]$Stat.Minute_5_Fluctuation
        Minute_10 = [Decimal]$Stat.Minute_10
        Minute_10_Fluctuation = [Double]$Stat.Minute_10_Fluctuation
        Hour = [Decimal]$Stat.Hour
        Hour_Fluctuation = [Double]$Stat.Hour_Fluctuation
        Day = [Decimal]$Stat.Day
        Day_Fluctuation = [Double]$Stat.Day_Fluctuation
        Week = [Decimal]$Stat.Week
        Week_Fluctuation = [Double]$Stat.Week_Fluctuation
        Updated = [DateTime]$Stat.Updated
    } | ConvertTo-Json | Set-Content $Path

    $Stat
}


function Get-Stat {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Name
    )

    if(-not (Test-Path "Stats")){New-Item "Stats" -ItemType "directory"}
    Get-ChildItem "Stats" | Where-Object Extension -NE ".ps1" | Where-Object BaseName -EQ $Name | Get-Content | ConvertFrom-Json
}

function Remove-Stat {
    param(
          [Parameter(Mandatory=$true)]
	  [String]$Name
   )

     $Remove = Join-Path ".\Stats" "$Name"
     if(Test-Path $Remove)
      {
	Remove-Item -path $Remove
      }
 }



function Get-ChildItemContent {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Path
    )

    $ChildItems = Get-ChildItem $Path | ForEach-Object {
        $Name = $_.BaseName
        $Content = @()
        if($_.Extension -eq ".ps1")
        {
           $Content = &$_.FullName
        }
        else
        {
           $Content = $_ | Get-Content | ConvertFrom-Json

        }
        $Content | ForEach-Object {
            [PSCustomObject]@{Name = $Name; Content = $_}
        }
    }

    $ChildItems | ForEach-Object {
        $Item = $_
        $ItemKeys = $Item.Content.PSObject.Properties.Name.Clone()
        $ItemKeys | ForEach-Object {
            if($Item.Content.$_ -is [String])
            {
                $Item.Content.$_ = Invoke-Expression "`"$($Item.Content.$_)`""
            }
            elseif($Item.Content.$_ -is [PSCustomObject])
            {
                $Property = $Item.Content.$_
                $PropertyKeys = $Property.PSObject.Properties.Name
                $PropertyKeys | ForEach-Object {
                    if($Property.$_ -is [String])
                    {
                        $Property.$_ = Invoke-Expression "`"$($Property.$_)`""
                    }
                }
            }
        }
    }

    $ChildItems
}
<#
function Set-Algorithm {
    param(
        [Parameter(Mandatory=$true)]
        [String]$API,
        [Parameter(Mandatory=$true)]
        [Int]$Port,
        [Parameter(Mandatory=$false)]
        [Array]$Parameters = @()
    )

    $Server = "localhost"

    switch($API)
    {
        "nicehash"
        {
        }
    }
}
#>
function Get-HashRate {
    param(
        [Parameter(Mandatory=$true)]
        [String]$API,
        [Parameter(Mandatory=$true)]
        [Int]$Port,
        [Parameter(Mandatory=$false)]
        [Object]$Parameters = @{},
        [Parameter(Mandatory=$false)]
        [Bool]$Safe = $false
    )

    $Server = "localhost"

    $Multiplier = 1000
    $Delta = 0.05
    $Interval = 5
    $HashRates = @()

    try
    {
        switch($API)
        {
            "xgminer"
            {
                $Message = @{command="summary"; parameter=""} | ConvertTo-Json -Compress

                do
                {
                    $Client = New-Object System.Net.Sockets.TcpClient $server, $port
                    $Writer = New-Object System.IO.StreamWriter $Client.GetStream()
                    $Reader = New-Object System.IO.StreamReader $Client.GetStream()
                    $Writer.AutoFlush = $true

                    $Writer.WriteLine($Message)
                    $Request = $Reader.ReadLine()

                    $Data = $Request.Substring($Request.IndexOf("{"),$Request.LastIndexOf("}")-$Request.IndexOf("{")+1) -replace " ","_" | ConvertFrom-Json

                    $HashRate = if($Data.SUMMARY.HS_5s -ne $null){[Double]$Data.SUMMARY.HS_5s*[Math]::Pow($Multiplier,0)}
                        elseif($Data.SUMMARY.KHS_5s -ne $null){[Double]$Data.SUMMARY.KHS_5s*[Math]::Pow($Multiplier,1)}
                        elseif($Data.SUMMARY.MHS_5s -ne $null){[Double]$Data.SUMMARY.MHS_5s*[Math]::Pow($Multiplier,2)}
                        elseif($Data.SUMMARY.GHS_5s -ne $null){[Double]$Data.SUMMARY.GHS_5s*[Math]::Pow($Multiplier,3)}
                        elseif($Data.SUMMARY.THS_5s -ne $null){[Double]$Data.SUMMARY.THS_5s*[Math]::Pow($Multiplier,4)}
                        elseif($Data.SUMMARY.PHS_5s -ne $null){[Double]$Data.SUMMARY.PHS_5s*[Math]::Pow($Multiplier,5)}

                    if($HashRate -ne $null)
                    {
                        $HashRates += $HashRate
                        if(-not $Safe){break}
                    }

                    $HashRate = if($Data.SUMMARY.HS_av -ne $null){[Double]$Data.SUMMARY.HS_av*[Math]::Pow($Multiplier,0)}
                        elseif($Data.SUMMARY.KHS_av -ne $null){[Double]$Data.SUMMARY.KHS_av*[Math]::Pow($Multiplier,1)}
                        elseif($Data.SUMMARY.MHS_av -ne $null){[Double]$Data.SUMMARY.MHS_av*[Math]::Pow($Multiplier,2)}
                        elseif($Data.SUMMARY.GHS_av -ne $null){[Double]$Data.SUMMARY.GHS_av*[Math]::Pow($Multiplier,3)}
                        elseif($Data.SUMMARY.THS_av -ne $null){[Double]$Data.SUMMARY.THS_av*[Math]::Pow($Multiplier,4)}
                        elseif($Data.SUMMARY.PHS_av -ne $null){[Double]$Data.SUMMARY.PHS_av*[Math]::Pow($Multiplier,5)}

                    if($HashRate -eq $null){$HashRates = @(); break}
                    $HashRates += $HashRate
                    if(-not $Safe){break}

                    Start-sleep $Interval
                } while($HashRates.Count -lt 6)
            }
            "ccminer"
            {
                $Message = "summary"

                do
                {
                    $Client = New-Object System.Net.Sockets.TcpClient $server, $port
                    $Writer = New-Object System.IO.StreamWriter $Client.GetStream()
                    $Reader = New-Object System.IO.StreamReader $Client.GetStream()
                    $Writer.AutoFlush = $true

                    $Writer.WriteLine($Message)
                    $Request = $Reader.ReadLine()

                    $Data = $Request -split ";" | ConvertFrom-StringData

                    $HashRate = if([Double]$Data.KHS -ne 0 -or [Double]$Data.ACC -ne 0){$Data.KHS}

                    if($HashRate -eq $null){$HashRates = @(); break}

                    $HashRates += [Double]$HashRate*$Multiplier

                    if(-not $Safe){break}

                    Start-Sleep $Interval
                } while($HashRates.Count -lt 6)
            }
            "nicehashequihash"
            {
                $Message = "status"

                $Client = New-Object System.Net.Sockets.TcpClient $server, $port
                $Writer = New-Object System.IO.StreamWriter $Client.GetStream()
                $Reader = New-Object System.IO.StreamReader $Client.GetStream()
                $Writer.AutoFlush = $true

                do
                {
                    $Writer.WriteLine($Message)
                    $Request = $Reader.ReadLine()

                    $Data = $Request | ConvertFrom-Json

                    $HashRate = $Data.result.speed_hps

                    if($HashRate -eq $null){$HashRate = $Data.result.speed_sps}

                    if($HashRate -eq $null){$HashRates = @(); break}

                    $HashRates += [Double]$HashRate

                    if(-not $Safe){break}

                    Start-Sleep $Interval
                } while($HashRates.Count -lt 6)
            }
            "nicehash"
            {
                $Message = @{id = 1; method = "algorithm.list"; params = @()} | ConvertTo-Json -Compress

                $Client = New-Object System.Net.Sockets.TcpClient $server, $port
                $Writer = New-Object System.IO.StreamWriter $Client.GetStream()
                $Reader = New-Object System.IO.StreamReader $Client.GetStream()
                $Writer.AutoFlush = $true

                do
                {
                    $Writer.WriteLine($Message)
                    $Request = $Reader.ReadLine()

                    $Data = $Request | ConvertFrom-Json

                    $HashRate = $Data.algorithms.workers.speed

                    if($HashRate -eq $null){$HashRates = @(); break}

                    $HashRates += [Double]($HashRate | Measure-Object -Sum).Sum

                    if(-not $Safe){break}

                    Start-Sleep $Interval
                } while($HashRates.Count -lt 6)
            }
            "ewbf"
            {
                $Message = @{id = 1; method = "getstat"} | ConvertTo-Json -Compress

                $Client = New-Object System.Net.Sockets.TcpClient $server, $port
                $Writer = New-Object System.IO.StreamWriter $Client.GetStream()
                $Reader = New-Object System.IO.StreamReader $Client.GetStream()
                $Writer.AutoFlush = $true

                do
                {
                    $Writer.WriteLine($Message)
                    $Request = $Reader.ReadLine()

                    $Data = $Request | ConvertFrom-Json

                    $HashRate = $Data.result.speed_sps

                    if($HashRate -eq $null){$HashRates = @(); break}

                    $HashRates += [Double]($HashRate | Measure-Object -Sum).Sum

                    if(-not $Safe){break}

                    Start-Sleep $Interval
                } while($HashRates.Count -lt 6)
            }
          "claymore"
            {
                do
                {
                    $Request = Invoke-WebRequest "http://$($Server):$Port" -UseBasicParsing

                    $Data = $Request.Content.Substring($Request.Content.IndexOf("{"),$Request.Content.LastIndexOf("}")-$Request.Content.IndexOf("{")+1) | ConvertFrom-Json

                    $HashRate = $Data.result[2].Split(";")[0]
                    if($HashRate -eq $null){$HashRates = @()}
		    $HashRates += [Double]$HashRate*$Multiplier

                    if(-not $Safe){break}

		    Start-Sleep $Interval
                } while($HashRates.Count -lt 6)
            }
            "dstm" {
                $Message = "summary"

                do {
                    $Client = New-Object System.Net.Sockets.TcpClient $server, $port
                    $Writer = New-Object System.IO.StreamWriter $Client.GetStream()
                    $Reader = New-Object System.IO.StreamReader $Client.GetStream()
                    $Writer.AutoFlush = $true

                    $Writer.WriteLine($Message)

                    $Request = $Reader.ReadLine()

                    $Data = $Request | ConvertFrom-Json

                    $HashRate = [Double]($Data.result.sol_ps | Measure-Object -Sum).Sum
                    if (-not $HashRate) {$HashRate = [Double]($Data.result.speed_sps | Measure-Object -Sum).Sum} #ewbf fix
            
                    if ($HashRate -eq $null) {$HashRates = @(); break}
                    
                    $HashRates += [Double]$HashRate
                    
                    if (-not $Safe) {break}

                    Start-Sleep $Interval
                } while ($HashRates.Count -lt 6)
              }
              
            "fireice"
            {
                do
                {
                    $Request = Invoke-WebRequest "http://$($Server):$Port/h" -UseBasicParsing

                    $Data = $Request.Content -split "</tr>" -match "total*" -split "<td>" -replace "<[^>]*>",""

                    $HashRate = $Data[1]
                    if($HashRate -eq ""){$HashRate = $Data[2]}
                    if($HashRate -eq ""){$HashRate = $Data[3]}

                    if($HashRate -eq $null){$HashRates = @(); break}

                    $HashRates += [Double]$HashRate

                    if(-not $Safe){break}

                    Start-Sleep $Interval
               } while($HashRates.Count -lt 6)
            }
            "wrapper"
            {
                do
                {
                    $HashRate = Get-Content ".\Wrapper_$Port.txt"


                    if($HashRate -eq $null){$HashRates = @(); break}

                    $HashRates += [Double]$HashRate

                    if(-not $Safe){break}

		   Start-Sleep $Interval
                } while($HashRates.Count -lt 6)
            }
        }

        $HashRates_Info = $HashRates | Measure-Object -Maximum -Minimum -Average
        if($HashRates_Info.Maximum-$HashRates_Info.Minimum -le $HashRates_Info.Average*$Delta){$HashRates_Info.Maximum}

        $HashRates_Info_Dual = $HashRates_Dual | Measure-Object -Maximum -Minimum -Average
        if($HashRates_Info_Dual.Maximum-$HashRates_Info_Dual.Minimum -le $HashRates_Info_Dual.Average*$Delta){$HashRates_Info_Dual.Maximum}
    }
    catch
    {
    }
}

filter ConvertTo-Hash {
    $Hash = $_
    switch([math]::truncate([math]::log($Hash,[Math]::Pow(1000,1))))
    {
        0 {"{0:n2}  hs" -f ($Hash / [Math]::Pow(1000,0))}
        1 {"{0:n2} khs" -f ($Hash / [Math]::Pow(1000,1))}
        2 {"{0:n2} mhs" -f ($Hash / [Math]::Pow(1000,2))}
        3 {"{0:n2} ghs" -f ($Hash / [Math]::Pow(1000,3))}
        4 {"{0:n2} ths" -f ($Hash / [Math]::Pow(1000,4))}
        Default {"{0:n2} PH" -f ($Hash / [Math]::Pow(1000,5))}
    }
}

filter ConvertTo-LogHash {
    $Hash = $_
    switch([math]::truncate([math]::log($Hash,[Math]::Pow(1000,1))))
    {
        0 {"{0:n2}  `nhs" -f ($Hash / [Math]::Pow(1000,0))}
        1 {"{0:n2} `nkhs" -f ($Hash / [Math]::Pow(1000,1))}
        2 {"{0:n2} `nmhs" -f ($Hash / [Math]::Pow(1000,2))}
        3 {"{0:n2} `nghs" -f ($Hash / [Math]::Pow(1000,3))}
        4 {"{0:n2} `nths" -f ($Hash / [Math]::Pow(1000,4))}
        Default {"{0:n2} `n PH" -f ($Hash / [Math]::Pow(1000,5))}
    }
}

function Get-Combination {
    param(
        [Parameter(Mandatory=$true)]
        [Array]$Value,
        [Parameter(Mandatory=$false)]
        [Int]$SizeMax = $Value.Count,
        [Parameter(Mandatory=$false)]
        [Int]$SizeMin = 1
    )

    $Combination = [PSCustomObject]@{}

    for($i = 0; $i -lt $Value.Count; $i++)
    {
        $Combination | Add-Member @{[Math]::Pow(2, $i) = $Value[$i]}
    }

    $Combination_Keys = $Combination | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

    for($i = $SizeMin; $i -le $SizeMax; $i++)
    {
        $x = [Math]::Pow(2, $i)-1

        while($x -le [Math]::Pow(2, $Value.Count)-1)
        {
            [PSCustomObject]@{Combination = $Combination_Keys | Where-Object {$_ -band $x} | ForEach-Object {$Combination.$_}}
            $smallest = ($x -band -$x)
            $ripple = $x + $smallest
            $new_smallest = ($ripple -band -$ripple)
            $ones = (($new_smallest/$smallest) -shr 1) - 1
            $x = $ripple -bor $ones
        }
   }
}

function Start-SubProcess {
    param(
        [parameter(Mandatory=$true)]
        [String]$MinerFilePath,
        [parameter(Mandatory=$true)]
        [String]$MinerArgumentList,
        [parameter(Mandatory=$true)]
        [String]$MinerWorkingDir
    )

    $MinerStart = Start-Job -ArgumentList $PID, $MinerFilePath, $MinerArgumentList, $MinerWorkingDir {
        param($ControllerProcessID, $FilePath, $ArgumentList, $WorkingDirectory)
        Set-Location "$WorkingDirectory"
        $ControllerProcess = Get-Process -Id $ControllerProcessID
        if($ControllerProcess -eq $null){return}
        $ProcessParam = @{}
        if($FilePath -ne ""){$ProcessParam.Add("FilePath", $FilePath)}
        if($ArgumentList -ne ""){$ProcessParam.Add("ArgumentList", $ArgumentList)}
        $Process = Start-Process @ProcessParam -PassThru
        if($Process -eq $null){[PSCustomObject]@{ProcessId = $null}}

        [PSCustomObject]@{ProcessId = $Process.Id; ProcessHandle = $Process.Handle}

        $ControllerProcess.Id | Out-Null
        $Process.Id | Out-Null

        do{if($ControllerProcess.WaitForExit(1000)){Start-Process "kill" -ArgumentList "-SIGTERM $($Process.Id)" | Out-Null}}
        while($Process.HasExited -eq $false)
    }

    do{sleep 1; $JobOutput = Receive-Job $MinerStart}
    while($JobOutput -eq $null)
    $Process = Get-Process | Where Id -EQ $JobOutput.ProcessId
    $Process.Id
    $Process
}


function Expand-WebRequest {
    param(
        [Parameter(Mandatory=$false)]
        [String]$Uri,
	[Parameter(Mandatory=$false)]
	[String]$BuildPath,
	[Parameter(Mandatory=$false)]
	[String]$Path,
        [Parameter(Mandatory=$false)]
	[String]$MineName,
	[Parameter(Mandatory=$false)]
        [String]$MineType
          )
     if (-not (Test-Path ".\Bin")) {New-Item "Bin" -ItemType "directory" | Out-Null}
     if (-not (Test-Path ".\x64")) {New-Item "x64" -ItemType "directory" | Out-Null}
     if (-not $Path) {$Path = Join-Path ".\x64" ([IO.FileInfo](Split-Path $Uri -Leaf)).BaseName}
	$Old_Path = Split-Path $Uri -Parent
        $New_Path = Split-Path $Old_Path -Leaf
	$FileName = Join-Path ".\Bin" $New_Path
        $FileName1 = Join-Path ".\x64" (Split-Path $Uri -Leaf)
        

        if($BuildPath -eq "Linux")
	 {
	  if(-not (Test-Path $Filename))
	   {
       Write-Host "Cloning Miner" -BackgroundColor "Red" -ForegroundColor "White"
       Set-Location ".\Bin"
       Start-Process -FilePath "git" -ArgumentList "clone $Uri $New_Path" -Wait
       Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
       Write-Host "Building Miner" -BackgroundColor "Red" -ForegroundColor "White"
       Copy-Item .\Build\*  -Destination $Filename -recurse -force
       Set-Location $Filename
       Start-Process -Filepath "chmod" -ArgumentList "+x ./configure.sh" -Wait
       Start-Process -Filepath "bash" -ArgumentList "autogen.sh" -Wait
       Start-Process -Filepath "bash" -ArgumentList "configure" -Wait
       Start-Process -FilePath "bash" -ArgumentList "build.sh" -Wait
       Write-Host "Miner Completed!" -BackgroundColor "Red" -ForegroundColor "White"
       Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
          }
         }
	if($BuildPath -eq "Linux-Clean")
	 {
	 if(-not (Test-Path $Filename))
	  {
       Write-Host "Cloning Miner" -BackgroundColor "Red" -ForegroundColor "White"
       Set-Location ".\Bin"
       Start-Process -FilePath "git" -ArgumentList "clone $Uri $New_Path" -Wait
       Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
       Write-Host "Building Miner" -BackgroundColor "Red" -ForegroundColor "White"
       Copy-Item .\Build\KlausT\*  -Destination $Filename -recurse -force
       Set-Location $Filename
       Start-Process -Filepath "bash" -ArgumentList "autogen.sh" -Wait
       Start-Process -Filepath "bash" -ArgumentList "configure" -Wait
       Start-Process -FilePath "bash" -ArgumentList "build.sh" -Wait
       Write-Host "Miner Completed!" -BackgroundColor "Red" -ForegroundColor "White"
       Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
	   }
          }

    if($BuildPath -eq "Linux-Zip-Build")
     {
     if(-not (Test-Path $Path))
      {
      $MinerFolder = Split-Path $Path -Leaf
      Write-Host "Downloading Miner" -BackgroundColor "red" -ForegroundColor "white"
      set-location ".\Bin"
      Start-Process -FilePath "wget" -ArgumentList "$Uri -O temp" -Wait
      Start-Process "unzip" -ArgumentList "temp -d zip" -Wait
      Get-ChildItem -Path zip -Recurse -Directory | Move-Item -Destination $MinerFolder
      Remove-Item "temp" -recurse -force
      Remove-Item "zip" -recurse -force
      Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
      Write-Host "Building Miner" -BackgroundColor "Red" -ForegroundColor "White"
      Copy-Item .\Build\KlausT\*  -Destination $Path -recurse -force
      Set-Location $Path
      Start-Process -FilePath "bash" -ArgumentList "build.sh" -Wait
      Write-Host "Miner Completed!" -BackgroundColor "Red" -ForegroundColor "White"
      Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
      }
    }

	if($BuildPath -eq "Zip")
	 {
	  if (Test-Path $FileName1) {Remove-Item $FileName1}
	    Write-Host "Downloading Windows Binaries"
	    Start-Process -Filepath "wget" -ArgumentList "$Uri -O $FileName1" -Wait
           if (".msi", ".exe" -contains ([IO.FileInfo](Split-Path $Uri -Leaf)).Extension)
	    {
             Start-Process -FilePath "wine" -ArgumentList "$FileName" -Wait
            }
  	    else {
		   $Path_Old = (Join-Path (Split-Path $Path) ([IO.FileInfo](Split-Path $Uri -Leaf)).BaseName)
                   $Path_New = (Join-Path (Split-Path $Path) (Split-Path $Path -Leaf))


                    if (Test-Path $Path_Old) {Remove-Item $Path_Old -Recurse -Force}

                    Start-Process "7z" "x `"$([IO.Path]::GetFullPath($FileName1))`" -o`"$([IO.Path]::GetFullPath($Path_Old))`" -y" -Wait


                    if (Test-Path $Path_New) {Remove-Item $Path_New -Recurse -Force}
                    if (Get-ChildItem $Path_Old | Where-Object PSIsContainer -EQ $false)
		     {
                     Rename-Item $Path_Old (Split-Path $Path -Leaf)
                     }
                    else
		       {
                         Get-ChildItem $Path_Old | Where-Object PSIsContainer -EQ $true | ForEach-Object {Move-Item (Join-Path $Path_Old $_) $Path_New}
                         $MinerNewFile = (Join-Path $Path_New ("$($MineName)" -replace "-$($MineType)",""))
			 Rename-Item -Path $MinerNewFile -NewName "$($MineName)"
                         Remove-Item $Path_Old
		       }
                  }

          }

if($BuildPath -eq "Linux-Zip")
	 {
	  if(-not (Test-Path $Path))
	   {
	     $NewDir = (Split-Path $Path -Leaf)
	     Start-Process -Filepath "wget" -ArgumentList "$Uri -O $FileName1" -Wait
	     New-Item -Path ".\Bin" -Name "$NewDir" -ItemType "directory"
	     Start-Process tar "-xvf `"$([IO.Path]::GetFullPath($FileName1))`" -C `"$([IO.Path]::GetFullPath($Path))`"" -Wait

          }
	}
 }


 function Get-Coin {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Coin
    )

    $Coins = Get-Content "Coins.txt" | ConvertFrom-Json

    $Coin = (Get-Culture).TextInfo.ToTitleCase(($Coin -replace "_"," ")) -replace " "

    if($Coins.$Coin){$Coins.$Coin}
    else{$Coin}
}

function Get-Algorithm {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Algorithm
    )

    $Algorithms = Get-Content "Algorithms.txt" | ConvertFrom-Json

    $Algorithm = (Get-Culture).TextInfo.ToTitleCase(($Algorithm -replace "-"," " -replace "_"," ")) -replace " "

    if($Algorithms.$Algorithm){$Algorithms.$Algorithm}
    else{$Algorithm}
}

function Get-Algo {
    param(
        [Parameter(Mandatory=$true)]
        [String]$Algorithm
    )

    $Algorithms = Get-Content "AlgoText.txt" | ConvertFrom-Json

    $Algorithm = (Get-Culture).TextInfo.ToTitleCase(($Algorithm -replace "-"," " -replace "_"," ")) -replace " "

    if($Algorithms.$Algorithm){$Algorithms.$Algorithm}
    else{$Algorithm}
}

function Convert-DateString ([string]$Date, [string[]]$Format)
	{
	  $result = New-Object DateTime

	 $Convertible = [DateTime]::TryParseExact(
		$Date,
		$Format,
		[System.Globalization.CultureInfo]::InvariantCulture,
		[System.Globalization.DateTimeStyles]::None,
		[ref]$result)

		if ($Convertible) { $result }
	}
