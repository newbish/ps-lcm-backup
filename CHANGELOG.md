##2015-05-05
 - Replaced DOS based directory removal with PowerShell syntax

Bugfixes:
 - Updated for compatibility with 11.1.2.3.5XX
 - Moved datestamp from XML to folder creation to fix issues with Essbase data not extracting to the correct folder for the zip.
 - Removed seperate removal of XML since its now contained in date stamp folder.
 
##2014-06-13
 - Changed license from 2-clause BSD to 1-clause since clause 2 does not apply to powershell scripts.

##2014-06-12
 - Removed previous client information
 
Features:
 - Compatability with EPM 11.1.2.2
 - Retention policy for number of backups to keep.
 - Zip Archive of LCM Export files 
 - Date Stamp applied to backups
 - Logging of process
 - Email on error