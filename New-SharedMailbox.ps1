function New-SharedMailbox{ 
 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$firstname,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$lastname
        ) 
        
    Import-Module ActiveDirectory   

    if($lastname.Length -lt 9){

      $samAccountName = $lastname + $firstname.Substring(0,2)

    }else{

      $samAccountName = $lastname.Substring(0,9) + $firstname.Substring(0,2)

    }
    
    $UPN = "$firstname.$lastname@company.com"
        
    New-RemoteMailbox -Name "$firstname $lastname" `
    -SamAccountName $samAccountName `
    -UserPrincipalName $UPN `
    -PrimarySmtpAddress $UPN `
    -Displayname "$lastname $firstname" `
    -FirstName $firstname -LastName $lastname `
    -OnPremisesOrganizationalUnit 'OU=Shared Mailboxes,OU=Users,OU=Common,DC=company,DC=dir' `
    -DomainController 'dc.company.dir' `
    -AccountDisabled `
    -ErrorAction Stop

    Set-RemoteMailbox $UPN -Type Shared -DomainController 'dc.company.dir'
    Set-RemoteMailbox $UPN -CustomAttribute4 'Sync' -DomainController 'dc.company.dir'

    Get-ADUser $samAccountName -Properties msDS-preferredDataLocation | Set-ADUser -Replace @{'msDS-preferredDataLocation'='NAM'}

 }