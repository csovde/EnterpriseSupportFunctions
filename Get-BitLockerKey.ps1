function Get-BitLockerKey {
  Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]$hostname
  )
  
  Get-ADObject -filter {objectclass -eq "msFVE-RecoveryInformation"} -Properties distinguishedName, msFVE-RecoveryPassword | `
  Where-Object { $_.distinguishedName -like "*$hostname*" } | `
  Select-Object distinguishedName, msFVE-RecoveryPassword | `
  Format-List distinguishedName, msFVE-RecoveryPassword
  
}