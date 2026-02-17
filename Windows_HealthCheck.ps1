#This script can be used to find cpu/memory usage, stopped automatic services,status of share access,OS,Uptime,manufacture
#give the servers in text servers.txt where powershell runs
#output file healthcheck.csv will be generated at the same location

################################################

$servers = Get-Content servers.txt
#clear-content healthcheck.csv
"ServerName,OS,Manufacturer,CPU Usage %, Memory usage % , Uptime ,Share access, Stopped service, Disks in GB Total Free Percentage " | Add-content healthcheck.csv
ForEach($server in $servers)
{
   
    Write-Host "working on $server..."
 
   
      if ( Test-Connection -ComputerName $server -Count 1 -ErrorAction SilentlyContinue )
   
            {
     
            Try
            {
             # Processor utilization
                  $Processor = (gwmi -ComputerName $server -Class win32_processor -ErrorAction Stop | Measure-Object -Property LoadPercentage -Average | Select-Object Average).Average
 
             # Memory utilization
                  $serverMemory = gwmi -ComputerName $server -Class win32_operatingsystem -ErrorAction Stop
             $Memory = ((($serverMemory.TotalVisibleMemorySize - $serverMemory.FreePhysicalMemory)*100)/ $serverMemory.TotalVisibleMemorySize)
           
            $wmi =Get-WmiObject Win32_OperatingSystem -ComputerName $server
            $manu=Get-WmiObject win32_computersystem -computername $server
            $manuf= $manu.manufacturer -replace "," , ""
            $os=$wmi.caption
            $arch=$wmi.osarchitecture
            $boottime = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
            $d=[datetime]::Now
            $Uptime = $d-$boottime
            $display = "Uptime : " + $uptime.days + "Days " + $uptime.hours + " Hours " + $uptime.minutes + " Minutes"
            $line= $server + "," + $os + "," + $manuf + "," + $processor + "," + [math]::Round($Memory, 2) + "," + $display

            #share access
            If(Test-Path -Path "\\$server\c$" -ErrorAction SilentlyContinue)

            {
                   $share = "Remote share working"
            }
            Else
            {
            $share = "Remote share not working"
            
            }
            

            $line = $line + "," + $share
      #automatic service with stopped status
      $service= gwmi -Class win32_service  -computername $server -ErrorAction Stop | where {$_.StartMode -eq "Auto" -and $_.State -eq "stopped"} | select DisplayName
      $line = $line + "," + $service.Displayname

       $disk = gwmi win32_logicaldisk -computername $server -EA Stop | ?{$_.drivetype -ne 2 -and $_.Drivetype -ne 4 -and $_.drivetype -ne 5} | select DeviceID,FreeSpace,Size
                  foreach($d in $disk)
                        {
                        $drive=$d.DeviceID
                        $size=$d.size / 1024 /1024 / 1024
                        $free=$d.FreeSpace / 1024 /1024 / 1024
                        $perc = $free * 100 / $size
                        #$line= $line + "," + $drive + "," + [math]::Round($size ,3) + "," + [math]::Round($free ,3)
                        $line1= $line1 + " " + "Drive : " + $drive + " " + "Total " + [math]::Round($size ,3) +  " "+ " Free space " + [math]::Round($free ,3) + " " + [math]::Round($perc ,3) + "% Free ;"
                        }
                  $line = $line + "," + $line1
                  $line | add-content healthcheck.csv
                  $line = $line1 = " "

                  

        }
        Catch
        {
            $server + "," + "Remote access error" | add-content healthcheck.csv
           
        }
 
       
       
    }
   Else
{
   $server + "," + " is not pinging" | add-content healthcheck.csv
            
}
}

$style = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
import-csv healthcheck.csv | convertTo-html -Head $style -Body "<h1>Health Check Report</h1>`n<h5>Generated on $(Get-Date)</h5>" | out-file healthcheck.html
invoke-item healthcheck.html
remove-item healthcheck.csv