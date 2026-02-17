$Servers = GC C:\Temp\srv.txt

$result = @()

foreach($server in $servers) {

$group_name = Get-ADPrincipalGroupMembership -Identity "$server$" | Where-Object { $_.Name -eq "ETS-Windows-Baseline-Update-23Q1 GPO Security Group" }

$result +=[PSCustomObject]@{
                VMName       = $Server
                Group = $group_name.Name
}
}

$result