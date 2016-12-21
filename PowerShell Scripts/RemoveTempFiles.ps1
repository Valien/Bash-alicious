# Clears out .tmp.zip files leftover from directory. Script is modified from
# http://stackoverflow.com/questions/17829785/delete-files-older-than-15-days-using-powershell
# Author: Allen Vailliencourt
# Email: allen.vailliencourt@erwinpenland.com
# Last modified: December 21, 2016
# Version 1.0
# Note: Add a Remove-Item -WhatIf -- to run a test scenario. Remove the -WhatIf to remove files (PROD)

$old = 7
$now = Get-Date
$files = Get-Item C:\Windows\Temp\*.tmp.zip

Get-ChildItem $files -Recurse |
Where-Object {-not $_.PSIsContainer -and $now.Subtract($_.CreationTime).Days -gt $old } |
Remove-Item