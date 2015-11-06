# This script reads for changes in a directory and uses a web hook to post to a Slack channel
# Make sure to set a cronjob with the following settings:
# * * * * * sh /home/ep/slack-integration/streamImgs.sh
# Replace the <text> with your custom links, user, password, etc.

files=`find /<your directory levels>/ -maxdepth 1 -mindepth 1 -mmin -1 | grep png`

for f in $files;
do
  file=`echo $f | rev | cut -d"/" -f1 | rev`;
  curl -H "Content-Type: application/json" -X POST -d "{\"channel\":\"<slack channel>\",\"username\":\"<slack user>\",\"icon_url\":\"<slack avatar link - AWS>\",\"text\":\"<end point - example would be a CDN link>/$file\"}" https://hooks.slack.com/services/<your slack web hook>;
done
