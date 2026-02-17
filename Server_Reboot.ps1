#Get Server List
$srv = Get-Content C:\temp\srv.txt

#Starting Loop to reboot the server one by one
foreach($server in $srv){
Write-host "Rebooting $server"
Restart-Computer -ComputerName $srv -Wait -For PowerShell -Timeout 600 -Force

}