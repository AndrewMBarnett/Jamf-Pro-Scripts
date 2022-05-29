#!/bin/bash
####################################################################################################
#
# ABOUT
#
#    Disk Usage: Root Volume
#
####################################################################################################
#
# HISTORY
#
#   Version 1.0, 8-Dec-2014, Dan K. Snelson (@dan-snelson) (@dan-snelson)
#       Original version
#   Version 1.1, 8-Jun-2015, Dan K. Snelson (@dan-snelson)
#       See: https://jamfnation.jamfsoftware.com/discussion.html?id=14701
#   Version 1.2, 4-Jan-2017, Dan K. Snelson (@dan-snelson)
#       Updated for macOS 10.12
#   Version 1.3, 4-Jul-2018, Dan K. Snelson (@dan-snelson)
#       Updated for macOS 10.13
#   Version 1.4, 11-Nov-2020, Dan K. Snelson (@dan-snelson)
#       Increased version number to match "Disk Usage Home Directory"
#   Version 1.5, 28-May-2022, Dan K. Snelson (@dan-snelson)
#       See: https://snelson.us/2022/05/disk-usage-report-monterey-compatible/
#
####################################################################################################



####################################################################################################
#
# Variables
#
####################################################################################################

scriptVersion="1.5"
scriptResult="Version ${scriptVersion}; "
loggedInUser=$( /bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }' )
loggedInUserHome=$( /usr/bin/dscl . -read /Users/$loggedInUser NFSHomeDirectory | /usr/bin/awk '{print $NF}' ) # mm2270
machineName=$( /usr/sbin/scutil --get LocalHostName )
volumeName=$( /usr/sbin/diskutil info / | /usr/bin/grep "Volume Name:" | /usr/bin/awk '{print $3,$4}' )



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Calculate Free Space
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FreeSpace=$( /usr/sbin/diskutil info / | /usr/bin/grep  -E 'Free Space|Available Space|Container Free Space' | /usr/bin/awk -F ":\s*" '{ print $2 }' | awk -F "(" '{ print $1 }' | xargs )
FreeBytes=$( /usr/sbin/diskutil info / | /usr/bin/grep -E 'Free Space|Available Space|Container Free Space' | /usr/bin/awk -F "(\\\(| Bytes\\\))" '{ print $2 }' )
DiskBytes=$( /usr/sbin/diskutil info / | /usr/bin/grep -E 'Total Space' | /usr/bin/awk -F "(\\\(| Bytes\\\))" '{ print $2 }' )
FreePercentage=$(echo "scale=2; $FreeBytes*100/$DiskBytes" | bc)
diskSpace="$FreeSpace free (${FreePercentage}% available)"
outputFileName="$loggedInUserHome/Desktop/$machineName-ComputerDiskUsage-`date '+%Y-%m-%d-%H%M%S'`.txt"



####################################################################################################
#
# Functions
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# JAMF Display Message
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function jamfDisplayMessage() {
    echo "${1}"
    scriptResult+="${1}; "
    /usr/local/jamf/bin/jamf displayMessage -message "${1}" &
}



####################################################################################################
#
# Program
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Logging preamble
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Disk Usage: Root Volume (${scriptVersion})"



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Display message
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

jamfDisplayMessage "Please wait 15 minutes (or more) while the disk usage for the entire \"$volumeName\" is analyzed."



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Output to log
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "### Disk usage for volume \"$volumeName\" on computer \"$machineName\"  ###"
echo "Disk Space: $diskSpace"
echo "Report Location: $outputFileName"



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Output to user
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

/bin/echo "-----------------------------------------------------------------------------------------------------------------------------------------" > $outputFileName
/bin/echo "Disk usage for volume \"$volumeName\" on computer \"$machineName\" " >> $outputFileName
/bin/echo "Disk Space: $diskSpace" >> $outputFileName
/bin/echo "Report Location: $outputFileName" >> $outputFileName
/bin/echo "-----------------------------------------------------------------------------------------------------------------------------------------" >> $outputFileName
/bin/echo " " >> $outputFileName
/bin/echo " " >> $outputFileName
/bin/echo " " >> $outputFileName
/bin/echo "GBs    Directory or File" >> $outputFileName
/bin/echo " " >> $outputFileName
/usr/bin/du -axrg / 2>&1 | /usr/bin/sort -nr | /usr/bin/head -n 50 >> $outputFileName
/bin/echo " " >> $outputFileName
/bin/echo "-----------------------------------------------------------------------------------------------------------------------------------------" >> $outputFileName



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Open in Safari
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [ -f $outputFileName ]; then
    /usr/bin/su - $loggedInUser -c "open -a safari $outputFileName"
fi



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Exit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

scriptResult+="End-of-line"
echo ${scriptResult}

exit 0        ## Success
exit 1        ## Failure