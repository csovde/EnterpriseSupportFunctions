function Add-ProxyAddress{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$username,
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$proxyaddress
        )
        
    # Retrieve user    
    $USER = Get-ADUser -Identity $username -Properties proxyAddresses
    
    # Add new address
    $USER.proxyAddresses.Add("smtp:$proxyaddress") | Out-Null
    
    # Print all proxy addresses
    $USER.proxyAddresses
    
    # Set the attribute    
    Set-ADUser -Instance $USER
    
 }