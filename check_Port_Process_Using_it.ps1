param (
    [string[]]$Computers = @("localhost"),    # Replace or pass list of computers
    [int[]]$Ports = @(80, 443, 3389)          # Replace or pass list of ports
)

foreach ($computer in $Computers) {
    Write-Host "`n===================" -ForegroundColor Cyan
    Write-Host "Checking on computer: $computer" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan

    foreach ($port in $Ports) {
        try {
            $connections = Invoke-Command -ComputerName $computer -ScriptBlock {
                param($p)
                Get-NetTCPConnection -LocalPort $p -ErrorAction SilentlyContinue | ForEach-Object {
                    [PSCustomObject]@{
                        Port = $_.LocalPort
                        PID  = $_.OwningProcess
                    }
                }
            } -ArgumentList $port -ErrorAction Stop

            if ($connections.Count -eq 0) {
                Write-Host "Port $port is NOT in use on $computer" -ForegroundColor Red
            } else {
                foreach ($conn in $connections) {
                    $pid = $conn.PID
                    $procName = Invoke-Command -ComputerName $computer -ScriptBlock {
                        param($pid)
                        try {
                            (Get-Process -Id $pid -ErrorAction Stop).ProcessName
                        } catch {
                            "Unknown Process"
                        }
                    } -ArgumentList $pid -ErrorAction SilentlyContinue

                    Write-Host "Port $($conn.Port) is used by '$procName' (PID: $pid) on $computer" -ForegroundColor Green
                }
            }
        } catch {
            Write-Host "Failed to query $computer on port $port. Error: $_" -ForegroundColor Yellow
        }
    }
}

Get Outlook for iOS