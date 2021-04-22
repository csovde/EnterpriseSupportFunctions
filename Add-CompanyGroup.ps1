function Add-CompanyGroup { 

  Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$Identity
  )

  $GridGroup = (Get-ADGroup -Filter * -SearchBase 'DC=company,DC=Dir' | `
    Select-Object Name,Description,distinguishedName | `
  Out-GridView -Title "Select Groups" -OutputMode Multiple).distinguishedName

  $GridGroup | Add-ADGroupMember -Members $Identity

  <#
        .SYNOPSIS
        Quickly Select a group or multiple groups to add to the specified user

        .DESCRIPTION
        Pulls a list of all groups and outputs to gridview for selection

        .PARAMETER Identity
        This can be anything that AD uses for identity

        .INPUTS
        Objects cannot be piped into this function
        
        .OUTPUTS
        This function does not have any outputs
        
        .RELATED LINKS

  #>
}