#!/bin/bash
####################################################################################################
#
# ABOUT
#
#   Creates a self-destructing LaunchDaemon and script to run a Recon
#   at next Reboot (after confirming your Jamf Pro server is available)
#
####################################################################################################
#
# HISTORY
#
# Version 1.0.0, 10-Nov-2016, Dan K. Snelson (@dan-snelson)
#   Original version
#
# Version 1.0.1, 12-Aug-2022, Dan K. Snelson (@dan-snelson)
#   Added check for Jamf Pro server connection
#
# Version 1.1, 09-July-2024, Andrew Barnett (@andrewmbarnett)
#   Added recon at the end and reboot
#
####################################################################################################



####################################################################################################
#
# Variables
#
####################################################################################################

scriptVersion="1.1"
plistDomain="com.organization"       # Hard-coded domain name
plistLabel="symStart"                  # Unique label for this plist
plistLabel="$plistDomain.$plistLabel"       # Prepend domain to label
timestamp=$( /bin/date '+%Y-%m-%d-%H%M%S' ) # Used in log file



####################################################################################################
#
# Program
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Logging preamble
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Setup Your Mac - at Reboot (${scriptVersion})"



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Create launchd plist to call a shell script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Create the LaunchDaemon ..."

/bin/echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
    <dict>
        <key>Label</key>
        <string>${plistLabel}</string>
        <key>ProgramArguments</key>
        <array>
            <string>/bin/sh</string>
            <string>/private/var/tmp/symAtReboot.bash</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
</plist>" > /Library/LaunchDaemons/$plistLabel.plist



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Set the permission on the file
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Set LaunchDaemon file permissions ..."

/usr/sbin/chown root:wheel /Library/LaunchDaemons/$plistLabel.plist
/bin/chmod 644 /Library/LaunchDaemons/$plistLabel.plist
/bin/chmod +x /Library/LaunchDaemons/$plistLabel.plist



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Create reboot script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Create the script ..."

cat << '==endOfScript==' > /private/var/tmp/symAtReboot.bash
#!/bin/bash
####################################################################################################
#
# ABOUT
#
#    Setup Your Mac - at Reboot
#
####################################################################################################
#
# HISTORY
#
# Version 1.0.0, 10-Nov-2016, Dan K. Snelson
#   Original version
#
# Version 1.0.1, 12-Aug-2022, Dan K. Snelson (@dan-snelson)
#   Added check for Jamf Pro server connection
#
# Version 1.1, 09-July-2024, Andrew Barnett (@andrewmbarnett)
#   Added recon at the end and reboot
#
####################################################################################################



####################################################################################################
#
# Variables
#
####################################################################################################

scriptVersion="1.1"
plistDomain="com.organization"       # Hard-coded domain name
plistLabel="symStart"                  # Unique label for this plist
plistLabel="$plistDomain.$plistLabel"       # Prepend domain to label
timestamp=$( /bin/date '+%Y-%m-%d-%H%M%S' ) # Used in log file
scriptResult=""


####################################################################################################
#
# Functions
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Check for a Jamf Pro server connection
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

jssConnectionStatus () {

    scriptResult+="Check for Jamf Pro server connection; "

    unset jssStatus
    jssStatus=$( /usr/local/bin/jamf checkJSSConnection 2>&1 | /usr/bin/tr -d '\n' )

    case "${jssStatus}" in

        *"The JSS is available."        )   jssAvailable="yes" ;;
        *"No such file or directory"    )   jssAvailable="not installed" ;;
        *                               )   jssAvailable="unknown" ;;

    esac

}



####################################################################################################
#
# Program
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Logging preamble
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Starting Recon at Reboot (${scriptVersion}) at $timestamp" >> /private/var/tmp/$plistLabel.log



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Hard-coded sleep of 25 seconds for auto-launched applications to start
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

sleep "25"



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Check for a Jamf Pro server connection
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

jssConnectionStatus

counter=1

until [[ "${jssAvailable}" == "yes" ]] || [[ "${counter}" -gt "10" ]]; do
    scriptResult+="Check ${counter} of 10: Jamf Pro server NOT reachable; waiting to re-check; "
    sleep "30"
    jssConnectionStatus
    ((counter++))
done



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# If Jamf Pro server is available, Run SYM Policy
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ "${jssAvailable}" == "yes" ]]; then

    echo "Jamf Pro server is available, proceeding; " >> /private/var/tmp/$plistLabel.log

    scriptResult+="Resuming Setup Your Mac at Reboot; "

    scriptResult+="Running Setup Your Mac; "

    /usr/local/bin/jamf policy -event symStart

else

    scriptResult+="Jamf Pro server is NOT available; exiting."

fi



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Delete launchd plist
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

scriptResult+="Delete $plistLabel.plist; "
/bin/rm -fv /Library/LaunchDaemons/$plistLabel.plist



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Delete script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

scriptResult+="Delete script; "
/bin/rm -fv /private/var/tmp/symAtReboot.bash



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Exit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

scriptResult+="End-of-line."

echo "${scriptResult}" >> /private/var/tmp/$plistLabel.log

exit 0
==endOfScript==



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Set the permission on the script
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Set script file permissions ..."
/usr/sbin/chown root:wheel /private/var/tmp/symAtReboot.bash
/bin/chmod 644 /private/var/tmp/symAtReboot.bash
/bin/chmod +x /private/var/tmp/symAtReboot.bash



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Create Log File
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "Create Log File at /private/var/tmp/$plistLabel.log ..."
touch /private/var/tmp/$plistLabel.log
echo "Created $plistLabel.log on $timestamp" > /private/var/tmp/$plistLabel.log



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Exit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo "LaunchDaemon and Script created."

/usr/local/bin/jamf recon

echo "Submitting Inventory, then rebooting"

sleep 5 && shutdown -r now

exit 0
