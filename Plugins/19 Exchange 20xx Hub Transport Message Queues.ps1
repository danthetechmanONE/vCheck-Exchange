$Title = "Exchange 20xx Hub Transport Mail Queues"
$Header = "Exchange 20xx Hub Transport Mail Queues"
$Comments = "Hub Transport Mail Queues"
$Display = "None"
$Author = "Phil Randal"
$PluginVersion = 2.1
$PluginCategory = "Exchange2010"

# Based on code in http://www.powershellneedfulthings.com/?page_id=281

# Start of Settings
# Report Message Queues with >= x messages
$MessageQueueThreshold=0
# End of Settings

# Changelog
## 2.0 : Initial implementation
## 2.1 : Add Server Name filter

If ($2007Snapin -or $2010Snapin) {
  $exServers = Get-ExchangeServer  -ErrorAction SilentlyContinue |
    Where {$_.IsExchange2007OrLater -eq $True -and $_.ServerRole -like "*HubTransport*" -and $_.Name -match $exServerFilter} |
	Sort Name
  If ($exServers) {
    ForEach ($Server in $exServers) {
	  $Target = $Server.Name
      Write-CustomOut "...Collating Queue Details for $Target"
	  $colQs = Get-Queue -server $Target |
	    Where { $_.MessageCount -ge $MessageQueueThreshold } |
	    Sort NextHopDomain
	  If ($colQs -ne $null) { 
	    $Header = "Hub Transport Mail Queues on $Target"
        If ($MessageQueueThreshold -gt 0) {
	      $Header += " with more than $($MessageQueueThreshold) queued messages"
	    }
	    $script:MyReport += Get-CustomHeader $Header $Comments
        $script:MyReport += Get-HTMLTable ($colQs | Select-Object NextHopDomain, Status, MessageCount, NextRetryTime)
        $script:MyReport += Get-CustomHeaderClose
	  }
	}
  }
}
