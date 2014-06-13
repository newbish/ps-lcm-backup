# LCM Backup (PowerShell)
This PowerShell script executes Oracle EPM Life Cycle Management backups. 

##Features
* Uses Standard LCM XML file to control backup
* Files are zipped using 7-Zip (http://7-zip.org)
* Zip file is timestamped
* Retention policy removes old backups from folder
* Available functionality for generating an email indicating the status (success or fail) of the backup operation
