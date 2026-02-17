# Get-CimInstance -ClassName Win32_Processor | Select-Object NumberOfLogicalProcessors
# systeminfo | findstr /i Processor

$srv_list = Get-Content -Path C:\Temp\srv.txt

$Results = @()
foreach ($srv in $srv_list) {
  Write-Host "Fetching Processor Details From $srv"
 $cpuCount = Invoke-Command -ComputerName $srv -ScriptBlock {Get-CimInstance -ClassName Win32_Processor | Select-Object NumberOfLogicalProcessors}

 $Results += [PSCustomObject]@{
 Server = $srv
 CPU_Count = $cpuCount.Count
 }
}