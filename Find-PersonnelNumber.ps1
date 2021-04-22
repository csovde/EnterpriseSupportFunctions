function Find-PersonnelNumber{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$PersonnelNo
        )
    Get-ADUser -LDAPFilter "(extensionAttribute2=$PersonnelNo)" -Properties extensionAttribute2,Name,UserPrincipalName | `
    Format-Table @{L='Personnel No.';E={$_.extensionAttribute2}},@{L='UPN';E={$_.UserPrincipalName}},Name
 }