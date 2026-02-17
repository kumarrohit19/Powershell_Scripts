$srv = Get-Content C:\temp\srv.txt

$output = @()
foreach($server in $srv){

$servicestatus = Invoke-Command -ComputerName $server -ScriptBlock {Get-Service cspmclientd}

#$servicestatus | Select-Object Name,Status,PSComputerName | FT -AutoSize

$output += [PSCustomObject]@{

    Server_Name = $servicestatus.PSComputerName
    Service = $servicestatus.Name
    Status = $servicestatus.Status
}
}

#Print Output
$output