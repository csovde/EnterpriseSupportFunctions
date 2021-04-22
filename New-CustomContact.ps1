function New-CustomContact{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipelinebyPropertyName=$true)][String]$FirstName,
        [Parameter(Mandatory=$true,ValueFromPipelinebyPropertyName=$true)][String]$LastName,
        [Parameter(Mandatory=$true,ValueFromPipelinebyPropertyName=$true)][String]$EMail
        )
    
    New-MailContact -FirstName $FirstName -LastName $LastName -ExternalEmailAddress $EMail `
      -Name "$FirstName $LastName" `
      -OrganizationalUnit 'Destination' `
      -DomainController 'domaincontroller'    

    
    # For use in a hybrid environment, runs against an on site exchange server 
    
 }