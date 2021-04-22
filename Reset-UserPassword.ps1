function Reset-UserPassword{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$Identity
        )
    
    Set-ADAccountPassword -Identity $Identity -Reset -NewPassword (Read-Host -Prompt "Provide New Password" -AsSecureString)
    
    Set-ADUser $Identity -ChangePasswordAtLogon:$true -PasswordNeverExpires:$false -CannotChangePassword:$false
 }