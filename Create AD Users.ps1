#Import required Modules
Import-Module ActiveDirectory

#Path Of CSV File
$filepath = Read-Host -Prompt "Please enter the file path "

#Setting Passworrd
$securepassword = ConvertTo-SecureString "Pa$$w0rd" -AsPlainText -Force

#Import files into Variables
$users = Import-Csv $filepath

#Loop for each row of the CSV file
foreach ($user in $users){

#Gather User Information

$fname = $user.'First Name'
$lname = $user.'Last Name'
$OUpath = $user.Path
$descryption = $user.'Descryption'
$samaccount = $user.samAccountName
$Email = $user.samAccountName + "@mylab.com"


#Command to add users in Active Directory
New-ADUser -Name "$fname $lname" -GivenName $fname -Description $descryption -SamAccountName $samaccount -EmailAddress $Email -Path $OUpath -DisplayName "$fname $lname" -PasswordNeverExpires $true -CannotChangePassword $true -AccountPassword $securepassword -Enabled $true

}
