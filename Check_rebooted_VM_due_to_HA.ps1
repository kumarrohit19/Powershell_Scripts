#Enter vcenter name

$vcServer = "dc3pavc0018.statestr.com"

#Enter cluster name

$cluster = "DCCPRD112"

 
$Date = Get-Date

#Enter interval in days to get that much days output


$HAVMrestartold =4



Connect-VIServer $vcServer | Out-Null

get-cluster $cluster | get-vm | get-vievent -maxsamples 100000 -Start ($Date).AddDays(-$HAVMrestartold) -type warning | Where {$_.FullFormattedMessage -match "vSphere HA restarted virtual machine"} | select ObjectName, CreatedTime, FullFormattedMessage >>dccpehc0038.txt