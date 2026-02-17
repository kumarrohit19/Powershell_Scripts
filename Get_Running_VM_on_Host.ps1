$vCenter = Get-Content -Path "C:\Users\q868895\Documents\Rohit_Scripts\Get_VM_List\vcenter.txt"
$esx_list = Get-Content -Path "C:\Users\q868895\Documents\Rohit_Scripts\Get_VM_List\esx.txt"
$output_file = "C:\Users\q868895\Documents\Rohit_Scripts\Get_VM_List\vm_list.csv"

$results = @()

Connect-VIServer -Server $vCenter -ErrorAction Stop


foreach ($esx in $esx_list){
Write-Host "Checking $esx" -ForegroundColor Yellow

$VMHost = Get-VMHost -Name $esx -ErrorAction SilentlyContinue

if($VMHost){
#get VM List

$vms = Get-VM -Location $VMHost

foreach($vm in $vms){
$row = [PSCustomObject]@{
vcenter = $vCenter
ESX_Host = $esx
VM_Name = $vm.Name
Power_State = $vm.PowerState
CPU = $vm.NumCpu
Memory = $vm.MemoryGB
GuestOS = $vm.Guest.OSFullName}

$results += $row
}
}
else{
Write-Host "Host not found: $esx in $vc" -ForegroundColor Red
}

}

Disconnect-VIServer -Server $vCenter -Confirm:$false
$Results | Export-Csv -Path $output_file -NoTypeInformation
