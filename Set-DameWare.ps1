function Set-DameWare {
  Param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]$hostname
  )
  
  Invoke-Command -ComputerName $hostname `
    -ScriptBlock { 
      Set-ItemProperty -Path "Registry::HKLM\SOFTWARE\DameWare Development\Mini Remote Control Service\Settings" `
      -Name 'Permission Required' -Value 0
    }
  Invoke-Command -ComputerName $hostname `
    -ScriptBlock { 
      Get-ItemProperty -Path "Registry::HKLM\SOFTWARE\DameWare Development\Mini Remote Control Service\Settings" `
      -Name 'Permission Required'
     } | Format-List PSComputerName, 'Permission Required', PSPath
  
}