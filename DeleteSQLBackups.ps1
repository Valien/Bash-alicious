# This script is designed to remove old SQL Express (or anything else) .bak files after backup. By default SQL Server Express
# does not have any built-in tools to remove old backups. So this script can help that. Just set it up to run in the Task
# Scheduler and voila!
# Allen vailliencourt
# June 21, 2016
# License: Have fun.
# Instructions: Set your date limit (default 14 days), what extension you want to be deleted, and the directory path

# Original script is here: http://stackoverflow.com/questions/17829785/delete-files-older-than-15-days-using-powershell and look for the
# highest voted answer. I modified it slightly but all original credit goes to http://stackoverflow.com/users/602585/deadlydog

# Set your variables
$limit = (Get-Date).AddDays(-14)
$extension = ".bak"
$path = "C:\temp"

# Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit -and $_.Extension -eq $extension} | Remove-Item -Force

# Optional: If you have any directories you can use this secondary script. 
# Delete any empty directories left behind after deleting the old files.
#Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
