# Define the list of remote computers
$srv_list = Get-Content -Path C:\Temp\srv.txt


# Create an empty array to store the results
$Local_Users = @()

foreach ($srv in $srv_list) {
    try {
        # Invoke a command on the remote computer to get local group members
        $members = Invoke-Command -ComputerName $srv -ScriptBlock {Get-LocalUser | Select-Object Name, Description, Enabled } -ErrorAction Stop

        # Add the results to the array
        foreach ($member in $members) {
            $Local_Users += [PSCustomObject]@{
                ComputerName = $srv
                UserName = $member.Name
                Description = $member.Description
                Enable = $member.Enabled
            }
        }
    } catch {
        Write-Warning "Failed to retrieve administrator group members from $srv : $($_.Exception.Message)"
    }
}

# Display the results
$Local_Users | Format-Table -AutoSize

# Optionally, export the results to a CSV file
#$Local_Users | Export-Csv -Path "C:\Temp\LocalUsers.csv" -NoTypeInformation