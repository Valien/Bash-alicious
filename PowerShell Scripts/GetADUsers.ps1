# Allen Vailliencourt <allen@valien.net>
# February 28, 2017
# This script loops through AD users and outputs group membership to a CSV file

# Script is as-is and probably buggy and broken. Mainly here for reference. 

# Get all AD Users
$users = Get-ADUser -Filter *;

# Loop through and get group membership info
$(foreach ($user in $user) {
    $user.name;
    Get-ADUser -Identity $user -Properties MemberOf
}) |

Out-File C:\temp\spout.txt
# or
Export-csv C:\temp\spout.csv
