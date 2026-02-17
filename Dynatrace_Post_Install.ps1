#Below is the script to perform the post-installation for dynatrace
#Need to update the $networkPath where the post-install file is located as per the server
#Create a text file srv.text at c:\temp and insert the list of servers

#Below are the log files generated
$FailedSesion = "C:\temp\dynatrace\failed_session.txt"
$SuccessfulExecution = "C:\temp\dynatrace\successful_execution.txt"
$FailedExecution = "C:\temp\dynatrace\Failed_Execution.txt"
$errorfile = "C:\temp\dynatrace\error.txt"

New-Item -Path $errorfile -ItemType File -Force | Out-Null

#Clear the error logs
Clear-Content C:\temp\dynatrace\error.txt -Force

#Ensure the output file exist and clear previous content

New-Item -Path $FailedSesion -ItemType File -Force | Out-Null
New-Item -Path $SuccessfulExecution -ItemType File -Force | Out-Null
New-Item -Path $FailedExecution -ItemType File -Force | Out-Null


#Network path where the post-install file is availlable it needs to be updated as per the path provided by the Dynatrace Team
$networkPath = "\\isis\common\Common\Dynatrace\DTManaged_Installers\post_install_properties\PROD\Windows\CORP"

#import the list of servers for performing post-install
$server_list = Get-Content -Path "C:\temp\srv.txt"

#Starting the loop to process the post-install config one by one on each server
foreach ($vmName in $server_list) {
    Write-host "Copying properties file to $vmName"

    # Copy the post install file to the remote computer directory

    Copy-Item -Path "$networkPath\$vmName.properties" -Destination "\\$vmName\c$\temp\" -Recurse -Force
    Write-host "Properties file Copied locally"
   
    try{
    # Establish a session with the remote computer

    $session = New-PSSession -ComputerName $vmName -ErrorAction Stop
    } catch{
            Write-Output "Failed to create session for $vmName"
            Add-Content -Path $FailedSesion -Value $vmName
            continue
            }



try{
Write-Output "Processing Post Install Configuration on $vmName"

Invoke-Command -Session $session -ScriptBlock {

             Write-Host "Performing post-install"
             $computer = hostname
             $post_install_properties = @()
             $post_install_properties = Get-Content -Path "C:\temp\$computer.properties"
             
             Stop-Service 'Dynatrace OneAgent'
             #Goto the installation path
             $install_location = Get-WmiObject -Class Win32_Product | Where-Object Name -EQ "Dynatrace OneAgent" | Select-Object InstallLocation
             $extract_path = Split-Path $install_location.InstallLocation
             cd $extract_path\oneagent\agent\tools
             
             #cd 'E:\vendor_apps_non_shared\dynatrace\oneagent\agent\tools'
             
             #Read the post-install file to extract Token and Host-Group
             $tenant = $post_install_properties[0]
             $tenant_token = $post_install_properties[1]
             $host_group = $post_install_properties[2]
             cmd /c oneagentctl.exe --set-tenant=$tenant --set-tenant-token=$tenant_token --set-host-group=$host_group
             $configPath = "C:\ProgramData\dynatrace\oneagent\agent\config\hostcustomproperties.conf"
             
             if (Test-Path $configPath) {
                    Clear-Content $configPath -Force
               }
             
             #Select elements starting from index 3 and add them to the file
             $post_install_properties[3..($post_install_properties.Length - 1)] | Add-Content -Path $configPath
             Start-Service 'Dynatrace OneAgent'

            Write-Output "Post-Install executed successfully."

         }

    #Log Successful Execution
    Add-Content -Path $SuccessfulExecution -Value $vmName
    } catch{
        #log unsuccessful execution
      $($_.Exception.Message) | Add-Content -Path C:\temp\dynatrace\error.txt
        Write-Host "Failed to execute script"
        Add-Content -Path $FailedExecution -Value $vmName
        }

    # Clean up the session

    Remove-PSSession -Session $session

}