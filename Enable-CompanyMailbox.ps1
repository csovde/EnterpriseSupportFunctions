function Enable-CompanyMailbox{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$username
        )
    
    Enable-RemoteMailbox -Identity "$username@company.com" -RemoteRoutingAddress "$username@company.mail.onmicrosoft.com" -DomainController 'dc.company.dir'
    
    Enable-RemoteMailbox -Identity "$username@company.com" -Archive -DomainController 'dc.company.dir'
    
 }