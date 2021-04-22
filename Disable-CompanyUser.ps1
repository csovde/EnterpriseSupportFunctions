function Disable-CompanyUser{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$SAM
        )
        
    # Get user
    $ADuser = Get-ADUser -Identity $SAM -Properties *
        
    # Collect all distro groups user is a memeber of
    $DistroGroups = Get-ADPrincipalGroupMembership $ADuser | `
    Where-Object {$_.GroupCategory -like 'Distribution'} | `
    Select-Object -ExpandProperty distinguishedName
    
    # Collect current OU information
    $DN = $ADuser.distinguishedName
    $DisplayName = $ADuser.DisplayName
    $CN = "CN=$DisplayName,"
    $OU = $DN.Replace($CN,"")
        
    # Store and Alter Description
    $Description = $ADuser.Description
    $Date = Get-Date -Format "MM/dd/yyyy"
    $Append = " - Disabled $Date - $env:USERNAME"
    $ADuser.Description = $ADuser.Description + $Append
    
    # Set the ADuser
    Set-ADUser -Instance $ADuser           
    
    # Set the Attributes
    
    try
    {
      Set-ADUser -Identity $SAM -Add @{
        extensionName=$DistroGroups
        extensionAttribute6=$OU
        extensionAttribute7=$Description
      } -ErrorAction Stop
    }    
    catch [System.ArgumentException]
    {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
      
      # output information. Post-process collected info, and log info (optional)
      $info
    }   
      
    # Remove user from distro groups
    $DistroGroups | Remove-ADGroupMember -Members $ADuser -Confirm:$false
    
    # Move the user to pre-delete
    Move-ADObject -Identity $ADuser -TargetPath 'OU=ZZ-Pre-Delete Users,DC=company,DC=dir'
    
    # Disable the user
    Disable-ADAccount -Identity $SAM -Confirm:$false
    
    <#
        .SYNOPSIS
        Disable a user in AD. 

        .DESCRIPTION
        This removes the user from all distro groups and stores those groups, the user's present OU, and description in the attributes.
        Moves the user to the pre-delete OU, changes the description, and disables the user account.

        .PARAMETER SAM
        This is the SAMAccountName. Standard username for logging into windows.

        .INPUTS
        Objects cannot be piped into this function
        
        .OUTPUTS
        This function does not have any outputs
        
        .RELATED LINKS
        

  #>
    
}