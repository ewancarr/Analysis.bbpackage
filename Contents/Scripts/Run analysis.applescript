-- Run script.applescript
-- 2013-08-21 
-- ----------------------------------------------------------
-- Runs the frontmost file (or selection) in the appropriate 
-- application (R, Stata, or Mplus).

-- TODO: 
-- * Make alerts prettier (e.g. take icon of respective app).
-- ==========================================================

-- Subroutines

on theSplit(theString, theDelimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelimiter
	set theArray to every text item of theString
	set AppleScript's text item delimiters to oldDelimiters
	return theArray
end theSplit

on isInstalled(appID)
	try
		tell application "Finder"
			return name of application file id appID
		end tell
	on error err_msg number err_num
		return null
	end try
end isInstalled

-- ============================================================

-- 1) Save the frontmost BBedit document; get the filename and path.

tell application "BBEdit"
	save text document 1
	set fileName to name of text document 1
	set filePath to file of text document 1 as string
end tell

-- 2) Based on the file extension, run the approriate script

-- R scripts
-- =====================================================
-- =====================================================

if (fileName ends with ".r") then
	set appExists to isInstalled("org.R-project.R")
	if (appExists = null) then
		display alert "R is not installed."
		return
	end if
	
	-- Run the file in R
	
	tell application "BBEdit"
		set theSelection to the selection of window 1 of text document 1 as text
		if theSelection is "" then
			set theSelection to (get contents of front window as string)
		end if
	end tell
	
	tell application "R"
		activate
		cmd theSelection
	end tell

-- Mplus input files (.inp) 
-- =====================================================
-- =====================================================
	
else if (fileName ends with ".inp") then
	set appExists to isInstalled("meditor.MEditor")
	if (appExists = null) then
		display alert "Mplus is not installed."
		return
	end if

-- run script "~/Dropbox/Application Support/BBEdit/Scripts/Run in Mplus.applescript"
	
	tell application "BBEdit"
		save text document 1
		set theName to name of text document 1
		set theFile to file of text document 1 as string
		set thePath to POSIX path of theFile
		set fileName to my theSplit(theName, ".")
		set nameWithoutExtension to item 1 of fileName
		set fileExtension to item 2 of fileName
		
		-- Get line count
		set lineCount to length of lines of window 1
		set scrollPosition to lineCount + 120
	end tell
	
	tell application "Finder"
		set parentFolder to container of item theFile
		set parentAlias to parentFolder as alias
		set basePath to POSIX path of parentAlias
	end tell
	

	-- Run the input file using `mplus` in Terminal.app (in a new tab)
	
	tell application "Terminal"
		activate
		tell application "System Events" to keystroke "t" using command down
		repeat while contents of selected tab of window 1 starts with linefeed
			delay 0.01
		end repeat
		set outputFile to basePath & nameWithoutExtension & ".out"
		set theCommand to "/Applications/Mplus/mplus \"" & thePath & "\" \"" & outputFile & "\""
		do script theCommand in window 1
	end tell
	
	tell application "BBEdit"
		open outputFile opening in front_window
		tell window 1
			select insertion point before line (scrollPosition as integer)
		end tell
	end tell

	
else if (fileName ends with ".out") then
	display dialog "Error: This is an output file"
	
	
-- Stata ".do" files
-- =====================================================
-- =====================================================
	
else if (fileName ends with ".do") then
	set appExists to isInstalled("com.stata.stata12")
	if (appExists = null) then
		display alert "Stata is not installed."
		return
	else
		--	run script "/Users/ewancarr/Dropbox/Application Support/BBEdit/Scripts/Run in Stata.applescript"
		tell application "BBEdit"
			set theSelection to the selection of window 1 of text document 1 as text
			set filePath to file of text document 1 as string
			if theSelection is "" then -- If selection is empty, run whole document.
				tell application "StataSE"
					activate
					open filePath
				end tell
			else -- If selection is not empty, run just the selection
				set theSelection to (get contents of front window as string)
				set the clipboard to theSelection as text
				do shell script "pbpaste > /tmp/stata.do"
				do shell script "echo \"
	
			\" >> /tmp/stata.do"
				
				tell application "StataSE"
					activate
					open "/tmp/stata.do"
				end tell
				
			end if
		end tell
		
	end if
else
	display alert "Error: this isn't a recognised file type."
end if


-- END.