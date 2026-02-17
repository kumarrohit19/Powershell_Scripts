$srv_list = Get-Content -Path C:\Temp\srv.txt

foreach ($srv in $srv_list) {
#Write-Host "Checking on '$srv'"
Invoke-Command -ComputerName $srv -ScriptBlock {(Get-HotFix | Sort-Object -Property InstalledOn)[-1,-2,-3,-4]}

}