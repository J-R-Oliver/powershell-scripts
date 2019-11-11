#Create file browser
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
    InitialDirectory = [Environment]::GetFolderPath('Desktop')
    Filter = 'CSV (Comma delimited) (*csv) |*.csv'
}
$FileBrowser.ShowDialog()

#Load csv 
$UsersToDisable = Import-Csv -Path $FileBrowser.FileName

#Get todays date and sets count 
$TodaysDate = Get-Date -Format "dd/MM/yyyy"
$Count = 1

#Script
foreach ( $User in $UsersToDisable ){
    Write-Progress -Id 0 -Activity "Disabling $($User.UserPrincipalName)" -Status "$Count of $($UsersToDisable.Count)" -PercentComplete (($Count / $UsersToDisable.Count) * 100)
    UserAccount = Get-AdUser -Filter "UserPrincipalName -eq '$($User.UserPrincipalName)'"
    Set-ADUser -Identity $UserAccount -Add @{msExchHideFromAddressLists="TRUE"} -Description "Disabled on $TodaysDate"                       
    Disable-ADAccount -Identity $UserAccount
    Move-ADObject -Identity $UserAccount -TargetPath 'OU=DisabledAccounts,DC=st-annes,DC=org,DC=uk' 
    $User."Account Deleted" = 'Disabled'
    $Count ++
}

#Exports array to spreadsheet 
$Path = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath "VEEAMExcludedUserAccounts.csv"
$UsersToDisable | Export-Csv -NoTypeInformation -Path $Path