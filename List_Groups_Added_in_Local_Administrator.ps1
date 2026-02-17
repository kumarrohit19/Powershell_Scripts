# Define the list of remote computers
$srv_list = Get-Content -Path C:\Temp\srv.txt

# Define the local group to query
$AdminGroupName = "Administrators"

# Create an empty array to store the results
$AdminGroupMembers = @()

foreach ($srv in $srv_list) {
    try {
        # Invoke a command on the remote computer to get local group members
        $members = Invoke-Command -ComputerName $srv -ScriptBlock {Get-LocalGroupMember -Group $using:AdminGroupName | Select-Object Name, PrincipalSource} -ErrorAction Stop

        # Add the results to the array
        foreach ($member in $members) {
            $AdminGroupMembers += [PSCustomObject]@{
                ComputerName = $srv
                MemberName = $member.Name
                PrincipalSource = $member.PrincipalSource
            }
        }
    } catch {
        Write-Warning "Failed to retrieve administrator group members from $srv : $($_.Exception.Message)"
    }
}

# Display the results
$AdminGroupMembers | Format-Table -AutoSize

# Optionally, export the results to a CSV file
# $adminGroupMembers | Export-Csv -Path "C:\Temp\LocalAdmins.csv" -NoTypeInformation