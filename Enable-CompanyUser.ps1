function Enable-CompanyUser{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$SAM
        )
    # Get user
    $ADuser = Get-ADUser -Identity $SAM -Properties *
    
    # Retrieve and Add Distribution Groups
    $Groups = $ADuser | Select-Object -ExpandProperty extensionName
    $Groups | Add-ADGroupMember -Members $ADuser
    Set-ADUser -Identity $SAM -Clear extensionName
          
    # Retrieve and Set Description
    Set-ADUser -Identity $SAM -Clear extensionAttribute7 -Replace @{'Description'=$ADuser.extensionAttribute7}
    
    # Move User to Original Location
    $OU = $ADuser.extensionAttribute6
    Move-ADObject -Identity $ADuser -TargetPath $OU
    Set-ADUser -Identity $SAM -Clear extensionAttribute6   
    
    # Enable the user
    Enable-ADAccount -Identity $SAM -Confirm:$false
 }