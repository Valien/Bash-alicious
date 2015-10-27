#!/bin/bash

# Author: Allen Vailliencourt
# Email: allen.vailliencourt@erwinpenland.com
# October 26, 2015
#
# Version 0.5 aka "Mango"
#   * Let's you authenticate, create, and list schedules.
#   * Pretty basic and prone to break so just be careful. :)
# License: MIT (See main repo)

# This script is a pretty basic script that lets you see and create MySQL backup schedules via their API.
# This feature is currently not available via the Rackspace control panel.
# API info -- https://developer.rackspace.com/docs/cloud-databases/v1/developer-guide/#document-general-api-info/authenticate

# Cloud DB Datacenter endpoints
#ORD="https://ord.databases.api.rackspacecloud.com/v1.0/"
#DFW="https://dfw.databases.api.rackspacecloud.com/v1.0/"
#IAD="https://iad.databases.api.rackspacecloud.com/v1.0/"
#LON="https://lon.databases.api.rackspacecloud.com/v1.0/"
#SYD="https://syd.databases.api.rackspacecloud.com/v1.0/"
#HKG="https://hkg.databases.api.rackspacecloud.com/v1.0/"

DBENDPOINT="databases.api.rackspacecloud.com/v1.0"

## Check to see if token exists. If so use that one instead of generating a new one
if [ ! -f /tmp/token.txt ]; then
	# # to do: add 24 hour time stamp check
  # # Also to do - error checking and ability to overwrite token/tenant text file
    echo "Token.txt not found! Must generate."
	# # Authentication script from here --  https://github.com/StafDehat/scripts/blob/master/cloud-get-auth-token.sh
	read -p "What's the username for your cloud account? " CLOUD_USERNAME
	read -p "And now enter your API key (not token): " CLOUD_API_KEY
	IDENTITY_ENDPOINT="https://identity.api.rackspacecloud.com/v2.0"
	TOKEN=$( curl $IDENTITY_ENDPOINT/tokens \
	           -H "Content-Type: application/json" \
	           -d '{ "auth": {
	                 "RAX-KSKEY:apiKeyCredentials": {
	                   "apiKey": "'$CLOUD_API_KEY'",
	                   "username": "'$CLOUD_USERNAME'" } } }' 2>/dev/null )
	AUTHTOKEN=$( echo "$TOKEN" | perl -pe 's/.*"token":.*?"id":"(.*?)".*$/\1/' )
	TENANTID=$( echo "$TOKEN" | perl -pe 's/.*"token":.*?"tenant":.*?"id":"(.*?)".*$/\1/' )
	echo $AUTHTOKEN > /tmp/token.txt
	echo $TENANTID > /tmp/tenantid.txt
	echo
	echo "Here's your auth token:   $AUTHTOKEN"
	echo "And your DDI (Tenant ID): $TENANTID"
	echo "Note: The auth token expires after 24 hours."
else
	echo "token.txt found! Reading..."
	read AUTHTOKEN < /tmp/token.txt
	read TENANTID < /tmp/tenantid.txt
	echo "Your auth token is: " $AUTHTOKEN
fi

#Begin Cloud DB backup script

#DB Locations:
#		IAD: https://iad.databases.api.rackspacecloud.com/v1.0/<your account #>/
#		DFW: https://dfw.databases.api.rackspacecloud.com/v1.0/<your account #>/

#
## Functions!
#

#List instances
listinstances () {
	INSTANCES=$( curl -s -XGET -H "X-Auth-Token: $AUTHTOKEN" "https://$DC.$DBENDPOINT/$TENANTID/instances" 2>/dev/null )
	DBINSTANCES=$( echo "$INSTANCES" | jq ".instances | map(.id) | tostring" )

	if [[ "$DBINSTANCES" = '"[\"\"]"' ]] || [[ "$DBINSTANCES" = '"[]"' ]]; then
		echo "There are no database instances in $DC. Terminating script. Have a nice day."
		exit
	else
		echo
		echo "JSON: $DBINSTANCES"
		DBSTRIP=$(echo "${DBINSTANCES:4:${#DBINSTANCES}-8}")
		echo
		echo "Your $DC database instance(s) is (are): $DBSTRIP"
		echo
	fi
}

getinstancedetail () {
	INSTANCEDETAIL=$( curl -s -XGET -H "X-Auth-Token: $AUTHTOKEN" "https://$DC.$DBENDPOINT/$TENANTID/instances/$DBSTRIP" )
}

# create on demand backup
# ondemandbackup () {
# 	#GETLIST=$( curl -s -XGET -H "X-Auth-Token: $AUTHTOKEN" "https://$DC.$DBENDPOINT/$TENANTID/backups" )
# 	CREATEONDEMANDBACKUP=$( curl -s -XPOST -H "Content-Type: application/json X-Auth-Token: $AUTHTOKEN" "https://$DC.$DBENDPOINT/$TENANTID/schedules" \
# 						-d '{ "backup": {
# 						"description": "API Generated Backup",
# 						"instance": "'$DBSTRIP'",
# 						"name": "API DB Snapshot"
# 						}}' )
# }

# list current schedule(s)
listschedule () {
	SHOWSCHEDULE=$( curl -s -X GET https://$DC.$DBENDPOINT/$TENANTID/schedules -H "X-Auth-Token: $AUTHTOKEN" )
}

# Create new schedule in this case Every Sunday @ 0400 hours
createschedule () {
	echo $DBSTRIP
	CREATESCHEDULE=$( curl -s -X POST https://$DC.$DBENDPOINT/$TENANTID/schedules -H "X-Auth-Token: $AUTHTOKEN" -H "Content-Type: application/json" -H "Accept: application/json" \
					-d '{"schedule":
                { "action":"backup",
                  "day_of_week":"0",
                  "hour":"4",
                  "minute":"00",
                  "instance_id":"'$DBSTRIP'" }}' )
		echo "Schedule created successfully!"
		echo
		#listschedule
		#echo $SHOWSCHEDULE | python -m json.tool
}

#Account info:
read -p "Which DC do you want to query? (ORD, DFW, IAD, LON, SYD, HKG)? " DC

if  [[ "$DC" = "ORD" ]] || [[ "$DC" = "DFW" ]] || [[ "$DC" = "IAD" ]] || [[ "$DC" = "LON" ]] || [[ "$DC" = "SYD" ]] || [[ "$DC" = "HKG" ]]; then
	echo
	echo "Now pulling a list of all Cloud DB instances in $DC"
	listinstances
	echo
  # for troubleshooting instance json files, otherwise keep commented out
  #getinstancedetail
	#echo $INSTANCEDETAIL | python -m json.tool
	echo
else
	echo "Not a DC. Terminating!"
	exit
fi

# Create new backup for instance
read -p "Do you want to (l)ist schedules or (c)reate a new backup schedule? " OPTION

case $OPTION in
	"l")
		# Get current schedule if available
		listschedule
		echo $SHOWSCHEDULE | python -m json.tool
		# if [[ $SHOWSCHEDULES = '' ]]; then
		# 	echo "No schedules listed. Creating a new schedule."
		# 	createschedule
		# fi
		;;
	"c")
		createschedule
		listschedule
		echo "Here is your schedule: "
		echo
		echo $SHOWSCHEDULE | python -m json.tool
		;;
	"o")
		# show on demand backups
		ondemandbackup
		echo $CREATEONDEMANDBACKUP | python -m json.tool
		;;
	*)
		echo "Sorry wrong option chosen. Terminating."
		exit
esac
