#!/bin/bash

# Script to clean up files in /var/www/html after processing. Looks for files older than 24 hours.
# Allen Vailliencourt
# October 14, 2015

DIRECTORY="/var/www/html"
#LIST="ls -alt"

cd $DIRECTORY
find -type f -mtime +1 -exec rm -f {} \;