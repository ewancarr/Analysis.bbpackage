-- Run script.applescript
-- 2013-08-21 
-- ==============================================
-- Runs the frontmost file in the appropriate application (R, Stata, or Mplus).
-- Will check these are installed before running
-- the corresponding script
-- ==============================================

-- TODO: 
-- - Make alerts prettier (e.g. take icon of respective app).

on isInstalled(appID)
	try
		tell application "Finder"
			return name of application file id appID
		end tell
	on error err_msg number err_num
		return null
	end try
end isInstalled

-- 1) Save the frontmost BBedit document; get the filename and path.

tell application "BBEdit"
	save text document 1
	set fileName to name of text document 1
	set filePath to file of text document 1 as string
end tell

-- 2) Based on the file extension, run the approriate script

-- R scripts =====================

if (fileName ends with ".r") then
	set appExists to isInstalled("org.R-project.R")
	if (appExists = null) then
		display alert "R is not installed."
		return
	end if
	run script "/Users/ewancarr/Dropbox/Application Support/BBEdit/Packages/R.bbpackage/Contents/Scripts/Send to R.applescript"
	
	-- Mplus input files (.inp) ==================
	
else if (fileName ends with ".inp") then
	set appExists to isInstalled("meditor.MEditor")
	if (appExists = null) then
		display alert "Mplus is not installed."
		return
	end if
	run script "/Users/ewancarr/Dropbox/Application Support/BBEdit/Scripts/Run in Mplus.applescript"
else if (fileName ends with ".out") then
	display dialog "Error: This is an output file"
	
	-- Stata ".do" files =============================
	
else if (fileName ends with ".do") then
	set appExists to isInstalled("com.stata.stata12")
	if (appExists = null) then
		display alert "Stata is not installed."
		return
	else
		run script "/Users/ewancarr/Dropbox/Application Support/BBEdit/Scripts/Run in Stata.applescript"
	end if
else
	display alert "Error: this isn't a recognised file type."
end if


