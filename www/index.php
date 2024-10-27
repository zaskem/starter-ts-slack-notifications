<?php
  $authCode = "samerandomstringgoeshere";
  if (isset($_POST['auth'])) {
    if ($authCode == $_POST['auth']) {
      // Write to file named for the host at the data path
      $filename = __DIR__ . '/../data/'.$_POST['name'].'.php';
      // Write out device data after removing the auth code
      unset($_POST['auth']);
      file_put_contents($filename, '<?php return ' . var_export($_POST, true) . '; ?>');
      chmod($filename, 0660);
      print "Request Successful.";
    } else {
      print "Request Failed.";
    }
  } else {
    print "Request Failed.";
  }
?>
