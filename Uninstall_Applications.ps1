#This is the powershell Script for Uninstalling Dynatrace & Splunk
#Need to Create srv.txt file that will contain the server list.

#Fetch server list from text file
$ComputerNames = Get-Content C:\temp\srv.txt


#Defining Array for collecting uninstallation details
$output = @()

#Starting loop for getting the software detail and uninstall it.
foreach($server in $ComputerNames){

try{
# Check if the software is installed using Win32_Product
Write-Host "Checking Splunk installed on $server"
$InstalledSoftware =  Invoke-Command -ComputerName $server -ScriptBlock {Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "UniversalForwarder"}}

Write-Host ""
if($InstalledSoftware) {
    Write-Host "Software"$InstalledSoftware.Name" is installed on $server"
    Write-host "Proceeding to Uninstall "$InstalledSoftware.Name"" -ForegroundColor Yellow
    Invoke-Command -ComputerName $server -ScriptBlock { $MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "UniversalForwarder"}
                                                        msiexec /x $MyApp.IdentifyingNumber /passive  /l*vx C:\temp\splunk_uninstall.log}
    Write-Host "Uninstalled "$InstalledSoftware.Name"on $server" -ForegroundColor Green
    Write-Host "`n"
    $output += [PSCustomObject]@{
    Server_Name = $server
    Splunk = "Un-installed"}
    

}
 else {
    Write-Host "Splunk is not installed on $server"
    $output += [PSCustomObject]@{
    Server_Name = $server
    Splunk = "Not Available"}
    Write-Host "`n"
}
}catch{Write-Output "Failed to invoke command :$($_.Exception.Message)"}
}


#Show the data collected in this array in tabulab Format
$output | FT