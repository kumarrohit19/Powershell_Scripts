#Import required Modules
Import-Module ActiveDirectory

#Path Of CSV File
$filepath = Read-Host -Prompt "Please enter the file path "

#Import files into Variables
$Groups = Import-Csv $filepath

#Loop for each row of the CSV file
foreach ($gname in $Groups){

#Gather User Information

$name = $gname.'Name'



#Command to add Groups in Active Directory
New-ADGroup -Name "$name" -SamAccountName "$name" -GroupCategory Security -GroupScope Global -DisplayName "$name" -Path "OU=Mylab-Groups,DC=mylab,DC=com"

}
