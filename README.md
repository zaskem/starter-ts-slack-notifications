# starter-ts-slack-notifications
A "starter" set of scripts to collect and process completed Task Sequence data by sending to a Slack webhook. A resulting submission would appear similar to this image:
![Screen snip of a successful Slack webhook notification using this script](DeviceNotification.png)

The [companion blog post for this repository](https://mzonline.com/blog/2024-10/triggering-slack-notification-completion-task-sequence) explains the use case and other details behind this repository.

## Basic Setup/Configuration
### `www/index.php`
This script lives on a Linux/Apache/PHP host and is the "receiver" for data submitted from a workstation completing the Task Sequence. It must be reachable and respond to POST requests from devices completing a TS (internal web host) and it is _not_ recommended this host be Internet-facing. Line 2 is a "salt" sort of value for additional security and must match the value of line 1 of `Submit-SlackNotification.ps1`

### `Submit-SlackNotification.ps1`
This script is what would be invoked (by Package reference or a direct Powershell script in the step) as one of the final steps in your Task Sequence. Only lines 1 and 3 _require_ editing, but the variables in lines 17-19 are custom variables and not available by default so they need to be set or otherwise changed/removed along with their tailing references.

Edit line 1 (`$authCode`) to be a "salt" sort of value for additional security obfuscation. It must match the value of line 2 in `www/index.php`.

Edit line 3 (`$checkinUrl`) to be the FQDN to the `www/index.php` script.

### `TSCompleteNotifier.php`
This script is invoked on a schedule (via `cron` or similar) on the web host for `www/index.php` and processes queued notification submissions, sending them to a pre-configured Slack webhook URL.

Edit line 2 (`$slackWebhookURL`) to be the FQDN for your Slack webhook.

Edit line 12 (`$channel`) to match the desired Slack notification channel.

## Provided AS-IS
Happy to entertain improvements and suggestions, though this companion repo and blog post was created to explain and illustrate an existing process (with additional unrelated/unexplained parts) and should not be considered a "drop in" solution for your environments.

## TODO (Maybe/If Time Allows)
* Create a single Powershell script to directly fire the Slack notification from the workstation completing the Task Sequence.