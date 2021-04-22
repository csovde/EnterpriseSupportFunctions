function New-CustomADUser{    
 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$FirstName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$LastName,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$PersonnelNo,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][Int]$CostCenter,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][Int]$Department,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][ValidateSet('MKS','RNV','BCO','NNH','CPA','MGA','Field',IgnoreCase)][String]$Location,
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
      'MKS' {$OUPath = 'OU=Users,OU=US-MP-McPherson,DC=americas,DC=dir'}
      'RNV' {$OUPath = 'OU=Users,OU=US-RE-Reno,DC=americas,DC=dir'}
      'CPA' {$OUPath = 'OU=Users,OU=US-CA-Carlisle,DC=americas,DC=dir'}
      'BCO' {$OUPath = 'OU=IM Users,OU=Users,OU=US-DV-Denver,DC=americas,DC=dir'}
      'NNH' {$OUPath = 'OU=Users,OU=US-NA-Nashua,DC=americas,DC=dir'}
      'MGA' {$OUPath = 'OU=Users,OU=US-MD-McDonough,DC=americas,DC=dir'}
      'Field' {$OUPath = 'OU=Users,OU=US-MO-Mobile,DC=americas,DC=dir'}
    }
    
    # Determine M365 License
    switch($M365LType){
      'E3' {$M365Group='CN=GL_SA_US_M365-E3-User-STD_LIC,OU=M365 Licensing,OU=Groups,OU=Common,DC=americas,DC=dir'}
      'F3' {$M365Group='CN=GL_SA_US_M365-F3-User-Light_LIC,OU=M365 Licensing,OU=Groups,OU=Common,DC=americas,DC=dir'}
    }
    
    # Determine Manager
    $Manager = Get-ADUser -Filter {mail -like $ManagerUPN} -Properties DistinguishedName | Select-Object DistinguishedName
    $Manager = $Manager.DistinguishedName
    
    # Creat AD User Account
    
    New-ADUser -Name "$LastName $FirstName" `
    -SamAccountName $samAccountName `
    -UserPrincipalName $UPN `
    -DisplayName "$LastName $FirstName" `
    -GivenName $FirstName `
    -Surname $LastName `
    -ChangePasswordAtLogon:$true `
    -AccountPassword (Read-Host -Prompt "Account Password" -AsSecureString) `
    -Description $Title `
    -Title $Title `
    -Company 'Viega LLC' `
    -ScriptPath 'ViegaLLC.bat' `
    -Manager $Manager `
    -Department $Department `
    -StreetAddress $StreetAddress `
    -City $City `
    -State $State `
    -PostalCode $PostalCode `
    -Enabled:$true
    
    Set-ADUser $samAccountName -Replace @{
      'msDS-preferredDataLocation'='NAM'
      'extensionAttribute1' = $samAccountName.ToUpper()
      'extensionAttribute15'='3'
      'extensionAttribute2'=$PersonnelNo
      'extensionAttribute3'=$CostCenter
      'extensionAttribute4'='Sync'      
      'c'='US'
      'co'='United States'
    }  
        
    # Set M365 License
    
    Add-ADPrincipalGroupMembership -Identity $samAccountName -MemberOf $M365Group
    
    # Add some basic groups (ACS group, NA All Users)
    
    $BaseGroups = `
        'CN=ACS Group,OU=Groups,OU=Common,DC=americas,DC=dir',`
        'CN=All Users-Azure Sync,OU=Groups,OU=Common,DC=americas,DC=dir',`
        'CN=NA All Users,OU=Distribution,OU=Groups,OU=Common,DC=americas,DC=dir',`
        'CN=W3_AZU_SA_SAP_SuccessFactors_US,OU=IT Groups,OU=Groups,OU=Common,DC=americas,DC=dir', `
        'CN=NA ServiceNow All Users,OU=Resource Access,OU=Groups,OU=Common,DC=americas,DC=dir', `
        'CN=Print Users,OU=Resource Access,OU=Groups,OU=Common,DC=americas,DC=dir', `
        'CN=Screensaver Whitelist 10 min,OU=GPO Security Filter,OU=Groups,OU=Common,DC=americas,DC=dir', `
        'CN=US ZIA Basic,OU=Groups,OU=Common,DC=americas,DC=dir', `
        'CN=US ZPA Basic,OU=Groups,OU=Common,DC=americas,DC=dir', `
        'CN=US ZPA Discovery,OU=Groups,OU=Common,DC=americas,DC=dir', `
        'CN=Azure_Conditional_Access,OU=IT Groups,OU=Groups,OU=Common,DC=americas,DC=dir', ` # May need to be conditional
        'CN=GL Mark External Emails,OU=Resource Access,OU=Groups,OU=Common,DC=americas,DC=dir'
    
    Add-ADPrincipalGroupMembership -Identity $samAccountName -MemberOf $BaseGroups   
    
 }