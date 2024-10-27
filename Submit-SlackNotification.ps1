$authCode = "randomstringgoeshere"
$deviceName = hostname
$checkinUrl = 'https://fqdn/path/to/receiver/'
$timestamp = [math]::Truncate((New-TimeSpan -Start (Get-Date "01/01/1970") -End ((Get-Date).ToUniversalTime())).TotalSeconds) # Adjust output to UTC
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
# Create POST Body (hashtable)
$body = @{
    name = $deviceName
    auth = $authCode
    time = $timestamp
    install = $InstallType
    ou = $OSDOUCN
    macaddress = $MAC
    firmware = $FirmwareRev
    osdata = $OSData
}
# Create Headers
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/x-www-form-urlencoded")
# Parameter Hashtable
$Params = @{
    Uri = $checkinUrl
    Method = "Post"
    Headers = $headers
    Body = $body
}
# Submit!
$response = Invoke-RestMethod @Params
$response | ConvertTo-Json
