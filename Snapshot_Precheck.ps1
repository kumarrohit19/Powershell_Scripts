#prompt the User to enter the vcenter name that needs to be connected
$vcenterserver = Read-Host "Enter vCenter Server Name"

#Connect the vCenter
Connect-VIServer -Server $vcenterserver

# Define the path of the text file containing VM names
$vmListFile = "C:\temp\VM-List.txt"

# Check if the file exists
if (-Not (Test-Path $vmListFile)) {
    Write-Host "VM list file not found at $vmListFile"
    exit
}

# Read VM names from the file
$vmNames = Get-Content -Path $vmListFile

# Define a array for collecting the output
$output = @()

# Loop through each VM and get datastore info
foreach ($vmName in $vmNames) {
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm) {
        #Get Total provisioned space
        $provisionedSpaceGB = [math]::Round(($vm | Measure-Object -Property ProvisionedSpaceGB -Sum).Sum,2)
       
        #Check Shared Disk Status
        $sharedDisk = "No"
        $vm.ExtensionData.Config.Hardware.Device | Where-Object {$_ -is [VMware.Vim.VirtualDisk] } | ForEach-Object {
        if ($_.Backing.Sharing -eq "SharingMultiWriter") {
            $sharedDisk = "Yes"
            }
        }

       
        $vm.ExtensionData.Storage.PerDatastoreUsage | ForEach-Object {
        $ds = Get-Datastore -Id $_.Datastore
        $output +=[PSCustomObject]@{
                VMName       = $vm.Name
                State = $vm.PowerState
                Datastore    = $ds.Name
                CapacityGB   = [math]::Round($ds.CapacityGB, 2)
                #UsedSpaceGB  = [math]::Round($ds.CapacityGB - $ds.FreeSpaceGB, 2)
                VMSizeGB     = $provisionedSpaceGB
                FreeSpaceGB  = [math]::Round($ds.FreeSpaceGB, 2)
                SharedDisk   = $sharedDisk
               
            }
        }
       
    } else {
        Write-Host "VM $vmName not found in vCenter."
    }
}

#output Result
$output | FT

#disconnect the vCenter
Disconnect-VIServer -Confirm:$false