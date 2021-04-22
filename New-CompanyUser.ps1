function New-CompanyUser{    
 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$FirstName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$LastName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$PersonnelNo,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][Int]$CostCenter,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][Int]$Department,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateSet('Location1','Location2','Location3','Location4','Location5','Location6','Location7',IgnoreCase)][String]$Location,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateSet('E3','F3',IgnoreCase)][String]$M365LType,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$ManagerUPN,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$Title,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$StreetAddress,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$City,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$State,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][Int]$PostalCode
        )  
    
    # Import Modules
    
    Import-Module ActiveDirectory
    
    # Determine samAccountName
        
    if($LastName.Length -lt 9){
      $samAccountName = $LastName + $FirstName.Substring(0,2)
    }else{
      $samAccountName = $LastName.Substring(0,9) + $FirstName.Substring(0,2)
    }
    
    if(Get-ADUser -Filter {samAccountName -like $samAccountName}){
       #samAccountName already exists       
       if($LastName.Length -lt 9){
         $samAccountName = $LastName + $FirstName.Substring(0,3)
       }else{
        $samAccountName = $LastName.Substring(0,9) + $FirstName.Substring(0,3)
       }       
    }
    
    # Set UPN    
    $UPN = "$FirstName.$LastName@viega.us"
    
    # Determine OU path
    switch($Location){    
      'location 1' {$OUPath = 'OU=Users,OU=location01,DC=company,DC=dir'}
      'location 2' {$OUPath = 'OU=Users,OU=location02,DC=company,DC=dir'}
      'location 3' {$OUPath = 'OU=Users,OU=location03,DC=company,DC=dir'}
      'location 4' {$OUPath = 'OU=Users,OU=location04,DC=company,DC=dir'}
      'location 5' {$OUPath = 'OU=Users,OU=location05,DC=company,DC=dir'}
      'location 6' {$OUPath = 'OU=Users,OU=location06,DC=company,DC=dir'}
      'location 7' {$OUPath = 'OU=Users,OU=location07,DC=company,DC=dir'}
    }
    
    # Determine M365 License
    switch($M365LType){
      'E3' {$M365Group='Licence Group DN'}
      'F3' {$M365Group='Licence Group DN'}
    }
    
    # Determine Manager
    $Manager = Get-ADUser -Filter {mail -like $ManagerUPN} -Properties DistinguishedName | Select-Object DistinguishedName
    $Manager = $Manager.DistinguishedName
    
    # Create mailbox and user accounts            
    New-RemoteMailbox -Name "$LastName $FirstName" `
    -SamAccountName $samAccountName `
    -UserPrincipalName $UPN `
    -PrimarySmtpAddress $UPN `
    -Displayname "$LastName $FirstName" `
    -FirstName $FirstName -LastName $LastName `
    -OnPremisesOrganizationalUnit $OUPath `
    -DomainController 'dc.company.dir' `
    -ResetPasswordOnNextLogon:$true `
    -ErrorAction Stop
      
    Enable-RemoteMailbox -Identity $UPN -Archive -DomainController 'dc.company.dir'
    
    # Wait for DC to sync
    
    Start-Sleep -Seconds 5
    
    # Set Attributes
    
    Set-ADUser $samAccountName -Replace @{
      'msDS-preferredDataLocation'='NAM'
      'extensionAttribute1' = $samAccountName.ToUpper()
      'extensionAttribute15'='3'
      'extensionAttribute2'=$PersonnelNo
      'extensionAttribute3'=$CostCenter
      'extensionAttribute4'='Sync'
      'Department'=$Department
      'Manager'=$Manager
      'Company'='company'
      'Title'=$Title
      'Description'=$Title
      'ScriptPath'='company.bat'
      'c'='US'
      'co'='United States'
    }
    
    # Set Address
    
    $user = Get-ADUser $samAccountName -Properties *

    $user.StreetAddress = $StreetAddress
    $user.City = $City
    $user.State = $State
    $user.PostalCode = $PostalCode

    Set-ADUser -Instance $user
    
    # Set M365 License
    Add-ADPrincipalGroupMembership -Identity $samAccountName -MemberOf $M365Group
    
    # Add some basic groups (ACS group, NA All Users)
    $BaseGroups = `
        'CN=ACS Group,OU=Groups,OU=Common,DC=company,DC=dir',`
        'CN=All Users-Azure Sync,OU=Groups,OU=Common,DC=company,DC=dir'        
    
    Add-ADPrincipalGroupMembership -Identity $samAccountName -MemberOf $BaseGroups
    
    
    
 }