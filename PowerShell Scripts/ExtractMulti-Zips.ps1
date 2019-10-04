# This simple script extracts all zip files at once. Handy for all those Disney Photo Pass zip files you get when you download them all at once...
# Allen Vailliencourt
# October 3, 2019
# Version 1.0

Get-ChildItem -Filter *.zip | Expand-Archive -DestinationPath $PWD -Force