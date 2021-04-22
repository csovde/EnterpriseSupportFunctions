function Get-CostCenter{

    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][ValidateScript({Get-ADUser $_})][String]$samAccountName
    )
    
    $ADUser = Get-ADUser $samAccountName -Properties *
    
    $Location = $ADUser.'msDS-preferredDataLocation'
   
    $OutputUserObject = [pscustomobject]@{
        Name = $ADUser.CN
        Username = $ADUser.SamAccountName
        PersonnelNo = $ADUser.extensionAttribute2
        Title = $ADUser.Title
        Description = $ADUser.Description
        Department = $ADUser.Department
        CostCenter = $ADUser.extensionAttribute3
        CCDescription = (Import-CSV C:\resources\CCList.csv | Where-Object CCNo -Like $ADUser.extensionAttribute3 | Select-Object -ExpandProperty CCDescr)
        EMail = $ADUser.mail
        Enabled = $ADUser.Enabled
        Sync = $ADUser.extensionAttribute4
        Badge = $ADUser.extensionAttribute8
        Location = $Location
        License = (Get-ADPrincipalGroupMembership $username | Where-Object name -like "*M365*" | Select-Object -ExpandProperty name)
      } 
      
      $OutputUserObject
  }