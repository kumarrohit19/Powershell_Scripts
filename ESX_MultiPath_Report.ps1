Clear-Host

Import-Module VMware.PowerCLI -Scope Local | Out-Null
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

$vCenterListFile = ".\vcenters.txt"
$vCenterServers = Get-Content $vCenterListFile

foreach ($vCenter in $vCenterServers) {
Write-Host "Connecting to $vCenter"  -ForegroundColor Green
Connect-VIServer -Server $vCenter -ErrorAction Stop | Out-Null
}

$esxNames = Get-Content -Path .\esxnames.txt
$esxNames2 = Get-VMHost -Name $esxNames

$report = foreach ($esx in $esxNames2)

{
Write-Host "Checking $esx ..." -ForegroundColor Cyan
    $esxcli = Get-EsxCli -VMHost $esx -V2
    foreach ($adapter in $esxcli.storage.core.adapter.list.Invoke() | where { $_.Driver -match 'fc'})
    {
        $esxcli.storage.core.path.list.Invoke() | where { $_.Adapter -eq  $adapter.HBAName } |
        Group-Object -Property Device |
        Select @{N = 'VMHost'; E = { $esx.Name } },
        @{N = 'HBA'; E = { $adapter.HBAName} },
       # @{N = 'WWN'; E = {'{0:x}' -f $_.PortWorldWideName}},
        @{N = 'Device'; E = { $_.Name} },
        @{N = 'Path#'; E = { $_.Group.Count} },
        @{N = 'PathStatus'; E = { ($_.Group.State | Sort-Object -Unique) -join ','} }
    }
}

$report | Export-Csv .\report.csv -NoTypeInformation -UseCulture

Write-Host "Disconnecting from all vCenter Servers." -ForegroundColor Green
Disconnect-VIServer -Server * -Confirm:$false

Write-Host "Done!" -ForegroundColor Green
Write-Host "output extracted to CSV file with the name report.csv" -ForegroundColor Green