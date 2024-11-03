$deviceName = hostname
$slackWebhookURL = 'https://hooks.slack.com/you/generated/when/setting/up';
$formattedDateTime = (Get-Date).ToString("MMMM d, h:mm tt")
# Task Sequence Variables
$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
# These variables are globally available
$MACAddress = (Get-NetAdapter | Where-Object Status -eq "Up").MacAddress
$OSInfo = (Get-ComputerInfo | Select-Object OsName, OsVersion)
$OSData = ($OSInfo.OsName -replace "Microsoft ", "") + " (" + $OSInfo.OsVersion + ")"
if ($MACAddress.Count -gt 1) {
  $MAC = $MACAddress[0]
} else {
  $MAC = $MACAddress
}
# These variables are custom and will be empty unless your TS declares/sets them
$InstallType = $tsenv.Value("InstallType")
$OSDOUCN = $tsenv.Value("OSDOUCN")
$FirmwareRev = $tsenv.Value("OSDDeviceFirmwareVersion")
# Variables containing the bits to submit in the Slack webhook
$channel  = '#quiet-private-channel-name-goes-here';
$bot_name = 'Device Rebuild Completed';
$icon     = ':information_source:';
$message = '';
$blockMessage = ":computer: $deviceName completed task sequence on $formattedDateTime";
# Create the block fields for data points (array of hashtables)
$blockFields = @(
  @{
    title = 'Rebuild Details:'
    value = $blockMessage
    short = $false
  }
  @{
    title = 'Installation Details:'
    value = ":triangular_flag_on_post: ``$InstallType``
  ``$OSData``"
    short = $true
  }
  @{
    title = 'Device Details:'
    value = ":desktop_computer: ``$MAC``
  firmware revision ``$FirmwareRev``"
    short = $true
  }
  @{
    title = 'AD Organizational Unit:'
    value = "``$OSDOUCN``"
    short = $false
  }
)
# Create the attachments payload
$attachments = @(
  @{
    fallback = "Device rebuild detected: $deviceName completed task sequence on $formattedDateTime"
    pretext  = ':information_source: Device Rebuild Completed'
    color    = '#8c1919'
    fields   = $blockFields
  }
)
# Create the actual webhook data payload
$data = @{
  channel     = $channel
  username    = $bot_name
  text        = $message
  icon_emoji  = $icon
  attachments = $attachments
}
# Convert the payload to JSON (recursively)
$data_string = $data | ConvertTo-Json -Depth 4
# Create Headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Content-Length", $data_string.Length)
# Parameter Hashtable
$Params = @{
  Uri = $slackWebhookURL
  Method = "Post"
  Headers = $headers
  Body = $data_string
}
# Submit!
$response = Invoke-RestMethod @Params
$response | ConvertTo-Json
