<?php
  $slackWebhookURL = 'https://hooks.slack.com/you/generated/when/setting/up';
  $dataPath = __DIR__ . '/data/';
  // Create multidimensional array of all active files
  $notifyDevices = array();
  foreach (glob($dataPath . '*.php') as $newFile) {
    $deviceName = explode('.php', basename($newFile))[0];
    $notifyDevices[$deviceName] = include $newFile;
  }
  // Push the new device notifications to Slack
  foreach ($notifyDevices as $notification) {
    $channel  = '#quiet-private-channel-name-goes-here';
    $bot_name = 'Device Rebuild Completed';
    $icon     = ':information_source:';
    $message = '';
    $blockMessage = ":computer: $notification[name] completed task sequence on " . date("F j, g:i a", $notification['time']);
    $attachments = array([
      'fallback' => "Device rebuild detected: $notification[name] completed task sequence on $notification[time]",
      'pretext'  => ':information_source: Device Rebuild Completed',
      'color'    => '#8c1919',
      'fields'   => array(
        [
          'title' => 'Rebuild Details:',
          'value' => $blockMessage,
          'short' => false
        ],
        [
          'title' => 'Installation Details:',
          'value' => ":triangular_flag_on_post: `$notification[install]`\n`$notification[osdata]`",
          'short' => true
        ],
        [
          'title' => 'Device Details:',
          'value' => ":desktop_computer: `$notification[macaddress]`\nfirmware revision `$notification[firmware]`",
          'short' => true
        ],
        [
          'title' => 'AD Organizational Unit:',
          'value' => "`$notification[ou]`",
          'short' => false
        ]
      )
    ]);
    $data = array(
      'channel'     => $channel,
      'username'    => $bot_name,
      'text'        => $message,
      'icon_emoji'  => $icon,
      'attachments' => $attachments
    );
    $data_string = json_encode($data);
    $ch = curl_init($slackWebhookURL);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json',
        'Content-Length: ' . strlen($data_string)
      )
    );
    // Execute cURL
    $result = curl_exec($ch);
    curl_close($ch);
  }
  // Remove the notified files
  array_map('unlink', glob($dataPath . '*.php'));
?>