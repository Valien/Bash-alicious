#!/bin/bash

# Author: Allen Vailliencourt
# Email: allen.vailliencourt@erwinpenland.com
#
# Last updated: November 6, 2015
# Version 0.6.1 aka "Guava"
#   * Let's you authenticate, create, and list schedules.
#   * Pretty basic and prone to break so just be careful. :)
# License: MIT (See main repo)

# This script is a pretty basic script that lets you see and create MySQL backup schedules via their API.
# This feature is currently not available via the Rackspace control panel.
# API info -- https://developer.rackspace.com/docs/cloud-databases/v1/developer-guide/#document-general-api-info/authenticate
#

# Requirements:
#  Bash 3.2 or greater
#  jq - for making the .json data spiffy looking
#  perl 5 or greater
#  awk
#  Most of the above should be standard on any OSX or Linux system. You might need to manually add jq though.

# Cloud DB Datacenter endpoints
#ORD="https://ord.databases.api.rackspacecloud.com/v1.0/"
#DFW="https://dfw.databases.api.rackspacecloud.com/v1.0/"
#IAD="https://iad.databases.api.rackspacecloud.com/v1.0/"
#LON="https://lon.databases.api.rackspacecloud.com/v1.0/"
#SYD="https://syd.databases.api.rackspacecloud.com/v1.0/"
#HKG="https://hkg.databases.api.rackspacecloud.com/v1.0/"

DBENDPOINT="databases.api.rackspacecloud.com/v1.0"

## functions! ##

generatetoken () {
  # Authentication script from here --  https://github.com/StafDehat/scripts/blob/master/cloud-get-auth-token.sh
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
}

options() {
	echo "Do you want to..."
	echo "(l)ist current schedules"
	echo "(c)reate a new backup schedule"
	echo "(v)iew current backups"
	echo "(d)elete a backup"
	echo "e(x)it the script"
	read -p "Make a selection: " OPTION

	case $OPTION in
		"l")
			# Get current schedule if available
			listschedule
			echo $SHOWSCHEDULE | jq ''
	    # ack! this is broken. Need to fix it...
			# if [[ $SHOWSCHEDULES = '' ]]; then
			# 	echo "No schedules listed. Creating a new schedule."
			# 	createschedule
			# fi
			echo
			options
			;;
		"c")
			createschedule
			listschedule
			echo "Here is your schedule: "
			echo
			echo $SHOWSCHEDULE | jq ''
			echo
			options
			;;
		"o")
			# show on demand backups
			ondemandbackup
			echo $CREATEONDEMANDBACKUP | jq ''
			echo
			options
			;;
		"v")
			listbackups
			echo
			options
			;;
		"d")
			deletebackup
			echo
			options
			;;
	  *)
			echo
			echo "Hey, thanks for using the script. Have a good day."
	    exit
	    ;;
	  esac
}

#List instances
listinstances () {
	INSTANCES=$( curl -s -XGET -H "X-Auth-Token: $AUTHTOKEN" "https://$DCTOLOWER.$DBENDPOINT/$TENANTID/instances" 2>/dev/null )
	DBINSTANCES=$( echo "$INSTANCES" | jq ".instances | map(.id) | tostring" )

	if [[ "$DBINSTANCES" = '"[\"\"]"' ]] || [[ "$DBINSTANCES" = '"[]"' ]]; then
		echo "There are no database instances in $DC. Terminating script. Have a nice day."
		exit
	else
		echo
		# used for troubleshooting: echo "JSON: $DBINSTANCES"
		DBSTRIP=$(echo "${DBINSTANCES:4:${#DBINSTANCES}-8}")
		echo
		echo "Your $DC database instance(s) is (are): $DBSTRIP"
		echo
	fi
}

getinstancedetail () {
	INSTANCEDETAIL=$( curl -s -X GET https://$DCTOLOWER.$DBENDPOINT/$TENANTID/instances/$DBSTRIP -H "X-Auth-Token: $AUTHTOKEN")
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

# Create new schedule in this case Every Sunday @ 0400 hours
createschedule () {
	read -p "This will create a default weekly schedule on Sunday @ 0400 hours. Do you want to continue? (Y/N) " CONTINUE
	if [[ ("$CONTINUE" = "Y")  || ("$CONTINUE" = "y") ]]; then
		echo
		echo $DBSTRIP
		CREATESCHEDULE=$( curl -s -X POST https://$DCTOLOWER.$DBENDPOINT/$TENANTID/schedules -H "X-Auth-Token: $AUTHTOKEN" -H "Content-Type: application/json" -H "Accept: application/json" \
						-d '{"schedule":
	                { "action":"backup",
	                  "day_of_week":"0",
	                  "hour":"4",
	                  "minute":"00",
	                  "instance_id":"'$DBSTRIP'" }}' )
			echo "Schedule created successfully!"
			echo
		else
			echo "No schedules created or modified."
			options
			exit
	fi

		#listschedule
		#echo $SHOWSCHEDULE | python -m json.tool
}

# list current schedule(s)
listschedule () {
	SHOWSCHEDULE=$( curl -s -X GET https://$DCTOLOWER.$DBENDPOINT/$TENANTID/schedules -H "X-Auth-Token: $AUTHTOKEN" )
}

#
# listschedulebyid () {
#   # to do: add ability to list backup schedules by ID.
#   # https://developer.rackspace.com/docs/cloud-databases/v1/developer-guide/#list-schedule-for-running-backup-by-schedule-id
# }
#
# updateschedulebyid () {
#   # to do: add ability to update backup schedule by ID.
#   # https://developer.rackspace.com/docs/cloud-databases/v1/developer-guide/#update-schedule-for-backups-by-schedule-id
# }
#
# deleteschedulebyid () {
#   # to do: add ability to delete schedules by ID.
#   # https://developer.rackspace.com/docs/cloud-databases/v1/developer-guide/#delete-schedule-for-running-backup-by-schedule-id
# }

# Get current list of backups on system
listbackups() {
	GETBACKUPS=$( curl -s -X GET https://$DCTOLOWER.$DBENDPOINT/$TENANTID/backups?datastore=mysql -H "X-Auth-Token: $AUTHTOKEN" )
	NUMOFBACKUPS=$( echo "$GETBACKUPS" | jq ".backups | length" )
	echo
	echo "There are a total of " $NUMOFBACKUPS " backups currently."
	#echo $GETBACKUPS | jq ''
	echo
	echo "Backup #          Date Completed                         Backup ID"
	echo "============================================================================"
	for (( i=0; i < "$NUMOFBACKUPS"; i++ )) #in
	do
		printf "$i)          "
		echo "$GETBACKUPS" | jq ".backups | map(.updated)["$i"]+\"     \"+map(.id)["$i"]"
	done
}

# let's you delete older instances of backups via API
# https://developer.rackspace.com/docs/cloud-databases/v1/developer-guide/#delete-backup
deletebackup() {
 #DELETE /{version}/{accountId}/backups/{backupId}
 listbackups
 read -p "Which backup do you want to delete (enter the number)? " NUMOFINSTANCE
 INSTANCESELECTED=$(echo "$GETBACKUPS" | jq ".backups | map(.id)["$NUMOFINSTANCE"]")
 INSTANCEDELETEDSTRIP=$(echo "${INSTANCESELECTED:1:${#INSTANCESELECTED}-2}")
 echo $( curl -s -X DELETE https://$DCTOLOWER.$DBENDPOINT/$TENANTID/backups/$INSTANCEDELETEDSTRIP -H "X-Auth-Token: $AUTHTOKEN" )
 echo "$INSTANCEDELETEDSTRIP backup deleted!"
}

## end functions ##

## Check to see if token exists. If so use that one instead of generating a new one
if [ ! -f /tmp/token.txt ]; then
  # # Also to do - error checking and ability to overwrite token/tenant text file
  echo "Token.txt not found! Must generate."
	generatetoken
else
	echo "token.txt found! Reading..."
  if [ $(find /tmp/token.txt -mmin +1440) ]; then
    echo "Your token is more than 24 hours old. Regenerating."
    generatetoken
  else
	  read AUTHTOKEN < /tmp/token.txt
	  read TENANTID < /tmp/tenantid.txt
	  echo "Your auth token is: " $AUTHTOKEN
  fi
fi

#Begin Cloud DB backup script

#DB Locations:
#		IAD: https://iad.databases.api.rackspacecloud.com/v1.0/<your account #>/
#		DFW: https://dfw.databases.api.rackspacecloud.com/v1.0/<your account #>/

#Account info:
read -p "Which DC do you want to query? (ORD, DFW, IAD, LON, SYD, HKG)? " DC
DCTOLOWER=$(echo "$DC" | awk '{print tolower($0)}')

if  [[ "$DCTOLOWER" = "ord" ]] || [[ "$DCTOLOWER" = "dfw" ]] || [[ "$DCTOLOWER" = "iad" ]] || [[ "$DCTOLOWER" = "lon" ]] || [[ "$DCTOLOWER" = "syd" ]] || [[ "$DCTOLOWER" = "hkg" ]]; then
	echo
	echo "Now pulling a list of all Cloud DB instances in $DC"
	listinstances
	echo
  # for troubleshooting instance json files, otherwise keep commented out
  #getinstancedetail
	#echo $INSTANCEDETAIL | python -m json.tool
	echo
else
	echo "Sorry! Your entry is not one of the datacenters listed above. Terminating the script!"
	exit
fi


options
