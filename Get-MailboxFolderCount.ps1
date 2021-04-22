function Get-MailboxFolderCount{ 
    Param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$TargetMailbox
        )
    
    # Retrieve mailbox   
    $Mailboxes = Get-Mailbox -Identity $TargetMailbox
    
    $Results = foreach( $Mailbox in $Mailboxes ){
      $Folders = $MailBox |
        Get-MailboxFolderStatistics |
        Measure-Object |
        Select-Object -ExpandProperty Count
      New-Object -TypeName PSCustomObject -Property @{
        Username    = $Mailbox.Alias
        FolderCount = $Folders
        }
    }
    
    $Results |
    Select-Object -Property Username, FolderCount
 }