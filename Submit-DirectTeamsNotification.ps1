$deviceName = hostname
$teamsWebhookURL = 'https://fqdn/you/get/when/setting/up/a/teams/webhook/workflow';
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
# Create the Header block
$headerBlock = @{
  type = "TextBlock"
  text = "&#x2139; Device Rebuild Completed"
  wrap = $true
  size = "ExtraLarge"
  weight = "Bolder"
  style = "heading"
  color = "Warning"
}
# Create the Rebuild Details block
$rebuildDetailsBlock = @{
  type = "Container"
  items = @(
    @{
      type = "TextBlock"
      text = "Rebuild Details:"
      wrap = $true
      weight = "Bolder"
    }
    @{
      type = "TextBlock"
      text = "$deviceName completed task sequence on $formattedDateTime"
      wrap = $true
    }
  )
}
# Create the Installation Details column
$installationDetailsColumn = @{
  type = "Column"
  width = "stretch"
  items = @(
    @{
      type = "TextBlock"
      text = "Installation Details:"
      wrap = $true
      weight = "Bolder"
      style = "columnHeader"
    }
    @{
      type = "TextBlock"
      text = "&#x25FC; $InstallType`n`n&#x25FC; $OSData"
      wrap = $true
      fontType = "Monospace"
      color = "Attention"
    }
  )
}
# Create the Device Details column
$deviceDetailsColumn = @{
  type = "Column"
  width = "stretch"
  items = @(
    @{
      type = "TextBlock"
      text = "Device Details:"
      wrap = $true
      weight = "Bolder"
      style = "columnHeader"
    }
    @{
      type = "TextBlock"
      text = "&#x25FC; $MAC`n`n&#x25FC; firmware $FirmwareRev"
      wrap = $true
      fontType = "Monospace"
      color = "Attention"
    }
  )
}
# Create the AD OU block
$adOuBlock = @{
  type = "Container"
  items = @(
    @{
      type = "TextBlock"
      text = "AD Organizational Unit:"
      wrap = $true
      weight = "Bolder"
      style = "columnHeader"
    }
    @{
      type = "TextBlock"
      text = $OSDOUCN
      wrap = $true
      fontType = "Monospace"
      color = "Accent"
    }
  )
}
# Create the card body layout/content
$cardBodyContent = @(
  # Header
  $headerBlock
  # Rebuild Details
  $rebuildDetailsBlock
  # Columns
  @{
    type = "ColumnSet"
    columns = @(
      # Installation Details
      $installationDetailsColumn
      # Device Details
      $deviceDetailsColumn
    )
  }
  # AD OU
  $adOuBlock
)
# Create the post data payload
$payloadData = @{
  type = "message"
  attachments = @(
    @{
      contentType = "application/vnd.microsoft.card.adaptive"
      contentUrl = $null
      content = @{
        type = "AdaptiveCard"
        '$schema' = "http://adaptivecards.io/schemas/adaptive-card.json"
        version = "1.5"
        body = $cardBodyContent
      }
    }
  )
}
# Convert the payload to JSON (recursively)
$jsonPayload = $payloadData | ConvertTo-Json -Depth 9
# Create Headers
$headers = @{"Content-Type" = "application/json"}
# Parameter Hashtable
$Params = @{
  Uri = $teamsWebhookURL
  Method = "Post"
  Headers = $headers
  Body = $jsonPayload
}
# Submit!
$response = Invoke-RestMethod @Params
$response | ConvertTo-Json
