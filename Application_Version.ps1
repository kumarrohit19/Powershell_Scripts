$srv = Get-Content C:\temp\srv.txt
$Results = @()

foreach($server in $srv){

$version = Invoke-Command -ComputerName $server -ScriptBlock {Get-WmiObject -Class Win32_Product | Where-Object Name -EQ "StateStreet - Node.js"}
$Results += [PSCustomObject]@{

Server = $version.PSComputerName
Name = $version.Name
Version = $version.Version
}

}