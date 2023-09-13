#!/bin/bash -
##################################################################
# Author:               Christo Deale                  
# Date  :               2023-09-13            
# rhel9_vulnerascan:    Utility to scan for RHEL 9 vulnerabilities
#                       and report using OSCAP
# requirements:         yum install openscap openscap-scanner             
##################################################################
# Check if oval.xml exists
if [ ! -f "./oval.xml" ]; then
    wget -O - https://www.redhat.com/security/data/oval/v2/RHEL9/rhel-9.oval.xml.bz2 | bzip2 --decompress > rhel-9.oval.xml
fi

# Function to open HTML report in Firefox
open_report() {
    firefox "$1"
}

# Dialog box to choose an option
dialog --backtitle "Vulnerability Scanner" --title "Options" \
    --menu "Choose an option:" 12 60 4 \
    1 "Scan Vulnerabilities" \
    2 "HIPAA Evaluation" \
    3 "Remediate Now" \
    4 "Write Script to Remediate Later" \
    2> option.txt

# Read the selected option from the file
option=$(cat option.txt)

# Perform actions based on the selected option
case $option in
    1)
        # Scan Vulnerabilities
        oscap oval eval --report vulnerability.html rhel-9.oval.xml
        open_report "vulnerability.html"
        ;;
    2)
        # HIPAA Evaluation
        oscap xccdf eval --profile hipaa --report hipaa-report.html /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
        open_report "hipaa-report.html"
        ;;
    3)
        # Remediate Now
        oscap xccdf eval --report hipaa_report.html --profile hipaa /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
        open_report "hipaa_report.html"
        ;;
    4)
        # Write Script to Remediate Later
        oscap xccdf generate fix --profile hipaa --fix-type bash --output hipaa-remediations.sh hipaa-results.xml
        ;;
    *)
        # Invalid option selected
        dialog --msgbox "Invalid option selected." 8 40
        ;;
esac

# Remove the option file
rm option.txt
