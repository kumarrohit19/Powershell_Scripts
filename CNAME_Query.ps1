#Input Server List
$srv = Get-Content C:\temp\srv.txt

#Creating Array For Storing Output
$CNAME = @()

foreach($Server in $srv){

$Record = Get-DnsServerResourceRecord -ComputerName GDCPWVC1908 -ZoneName "corp.statestr.com" -RRType CNAME | Where-Object {$_.RecordData.HostNameAlias -like "$Server*"}

$CNAME += [PSCustomObject]@{
Server = $Server
CNAME = $Record.HostName
Record_Typ = $Record.RecordType
}

}

#Show Output
$CNAME