# ------------------------------------------------------------------------
# NAME: LCMBackup.ps1
# AUTHOR: Keith Kikta, EPM Intelligence (http://epmintelligence.com)
# DATE: 06/05/2014
#
# COMMENTS: This script creates an LCM backup file
# based upon the date-time stamp. Script also has 
# email capabilities that have been commented out.
#
# ------------------------------------------------------------------------

$epm_instance_home = "E:\Oracle\Middleware\user_projects\epmsystem<instance>"
$epm_home = "X:\Oracle\Middleware\EPMSystem11R1"
$lcm_utilty = "\bin\Utility.bat"
$output_path = ".\BackupFiles"
$date = Get-Date
$keep = 30
$dateformat = "yyyyMMdd-HHmm"
$log_path = ".\Logs\"
$email_address_list = "email@address.com"

function create-7zip([String] $aDirectory, [String] $aZipfile){
    [string]$pathToZipExe = "C:\Program Files\7-zip\7z.exe";
    [Array]$arguments = "a", "-t7z", "$aZipfile", "$aDirectory", "-r";
    & $pathToZipExe $arguments;
}

function getLog([String] $logPath, [String] $dateToken) {
	[string]$output = $logPath + "lcm_export_" + $dateToken + ".log";
	return $output;
}

function emailOnError([String] $log_path, $dateToken, [String] $email_address_list) {
	$logfile = getLog $log_path $dateToken
	$failure_reason = (Get-Content $logfile | Select-Object -last 1);
	Write-Host $failure_reason;
	if ($failure_reason.Trim() -ne "Migration Status - Success")
	{
		Write-Host "Sending Email";
		#SMTP server name
		$smtpServer = "smtp.emailserver.com";
		
		#Creating a Mail object
		$msg = new-object Net.Mail.MailMessage;
		
		#Creating SMTP server object
		$smtp = new-object Net.Mail.SmtpClient($smtpServer);
		#Email structure
		$msg.From = "lcm@address.com";
		$msg.ReplyTo = "no-reply@address.com";
		$addresses = $email_address_list.split(',');
		for ($i = 0; $i -lt $addresses.Count; $i++)
		{
			$msg.To.Add($addresses[$i]);
		}
		$msg.subject = "LCM - FAILURE [$dateToken]";
		$msg.body = "An error occurred during the nightly backup."
		$attachment = New-Object System.Net.Mail.Attachment((Resolve-Path $logfile).ToString(), "text/plain")
		$msg.Attachments.Add($attachment)
		#Sending email
		$smtp.Send($msg)
	}
}

function GenerateXML([String] $source, [String] $destination, [String] $dateToken) { 
	#Create Directory
	New-Item $dateToken -type directory
	Copy-Item $source -Destination $destination
}

# Create zip file path based on value in output_path.
IF ($output_path.length -ne 0)
{
	$zipfile = $output_path + "\" + $date.ToString($dateformat)
} else {
	$zipfile = ".\" + $date.ToString($dateformat)
	$output_path = ".\"
}

# Generate name for output file
$output_file = $date.ToString($dateformat) + "\temp" + $date.ToString($dateformat) + ".xml"
$log_file = getLog $log_path $date.ToString($dateformat)
GenerateXML $args[0] $output_file $date.ToString($dateformat)

# Build command for  LCM Utility
$command = $epm_instance_home + $lcm_utilty
# Execute LCM Utility
invoke-expression "$command $output_file > $log_file"
#emailOnError $log_path $date.ToString($dateformat) $email_address_list

# Create zip archive of LCM Extract
create-7zip $date.ToString($dateformat) $zipfile

# Remove directory created by LCM Utility
Remove-Item $date.ToString($dateformat) -Force -Recurse

# Get list of 7zip files in output directory
$files = Get-ChildItem $output_path\*.7z
# Remove old files keeping the newest based on the number in $keep
if ($files.Count -gt $keep) {
    $files | Sort-Object CreationTime | Select-Object -First ($files.Count - $keep) | Remove-Item -Force
}