function Update-Badge
{
  
  Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]$Identity,
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]$BadgeNo
  )


  $ADUser = Get-ADUser $Identity -Properties *

  $ADUser.extensionAttribute8 = $BadgeNo

  Set-ADUser -Instance $ADUser


}