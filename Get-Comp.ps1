function Get-Comp {
    
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)][String]$compname
    )
    
    Get-ADComputer -LDAPFilter "(name=*$compname*)" -Properties DistinguishedName, Name, SamAccountName, Description, departmentNumber, Enabled, LastLogonDate | `
    Select-Object Name, Description, @{n='departmentNumber'
    e={$_.departmentNumber}}, SamAccountName, DistinguishedName, Enabled, LastLogonDate
}