Oh hai.

Here be a few bash files that I've collected, written, and use. Feel free to utilize as well!

Here are some other very cool script repos:

* https://github.com/matthewmccullough/scripts
* https://github.com/StafDehat/scripts

**Script Descriptions (bash)**

* `cleanfiles.sh` - super simple script that runs once a day and deletes files older than 24 hours in x folder.

* `directorytotxt.sh` - another simple script that you can use to extract a list of file names and dump them to a txt file

* `rackspace-clouddb-backup.sh` -- This script lets you set a nightly backup schedule for your Cloud Databases. A feature that is currently not available outside of the Rackspace API. You will need your Account Name and API key.

* `slack-stream-images-webhook.sh` - this script queries a folder for any changes and posts images to a Slack channel using the Slack webhook api. Set a cron job to run this all the time and voila! Enjoy the data.

* `ssl-query.sh` - this script utilizes OpenSSL to query any URL and returns it's certificate information

**Script Descriptions (PowerShell)**

* `DeleteSQLBackups.ps1` -- This script runs through a specified folder and removes all SQL Express backups (.bak) after an X amount of time.

* `ExtractMulti-Zips.ps1` -- This script simply extracts all .zip files in current working directory.

* `FileCount.ps1` -- This script just runs through a bunch of folders and outputs a total file count to a .txt file

* `RemoveTempFiles.ps1` -- This script removes temporary files in whatever directory you set. Similar to the DeleteSQLBackups.ps1 script.
