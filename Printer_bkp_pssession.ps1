# Define a list of servers to export printer data from
$servers = "server1", "server2", "server3"

# Loop through each server in the list and use PSSession to run printbrm.exe to export printer data to the prnt_bkp folder
foreach ($server in $servers) {
    $session = New-PSSession -ComputerName $server
    Invoke-Command -Session $session -ScriptBlock {
        # Create a folder named "prnt_bkp" in the root of the C drive if it doesn't exist
        $folderPath = "C:\prnt_bkp"
        if (-not (Test-Path $folderPath)) {
            New-Item -ItemType Directory -Path $folderPath | Out-Null
        }

        # Create a folder named "${env:COMPUTERNAME}_print_data" under prnt_bkp if it doesn't exist
        $exportPath = "C:\prnt_bkp\${env:COMPUTERNAME}_print_data"
        $logPath = "${exportPath}.log"
        if (-not (Test-Path $exportPath)) {
            New-Item -ItemType Directory -Path $exportPath | Out-Null
        }

        # Use printbrm.exe to export printer data to the ${env:COMPUTERNAME}_print_data folder
        printbrm.exe -B -S $env:COMPUTERNAME -F $exportPath -L $logPath
    }
    Remove-PSSession $session
}
