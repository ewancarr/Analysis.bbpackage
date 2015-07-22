(*
Run frontmost BBEdit document in R/Stata/Mplus
Ewan Carr

Version 0.0.3
Date: 22 July 2015

Version: 0.0.2
Date: 13 September 2013

This AppleScript is released under a Creative Commons Attribution-ShareAlike License:
<http://creativecommons.org/licenses/by-sa/3.0/>


TODO: 
* Make alerts prettier (e.g. take icon of respective app).
*)

-- Subroutines

on theSplit(theString, theDelimiter)
	set oldDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to theDelimiter
	set theArray to every text item of theString
	set AppleScript's text item delimiters to oldDelimiters
	return theArray
end theSplit

on isInstalled(app_name)
	set isInstalled to null
	try
		set isInstalled to do shell script "ls /Applications/ | grep '" & app_name & "'"
	end try
	return isInstalled
end isInstalled

-- 1) Save the frontmost BBEdit document; get the filename and path.

tell application "BBEdit"
	save text document 1
	set fileName to name of text document 1
	set filePath to file of text document 1 as string
end tell

tell application "Finder"
	set parentFolder to container of item filePath
	set parentAlias to parentFolder as alias
	set basePath to POSIX path of parentAlias
end tell

-- 2) Based on the file extension, run the approriate script

-- R scripts
-- =====================================================
-- =====================================================

if (fileName ends with ".r") then
	set appExists to isInstalled("R.app")
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
	set appExists to isInstalled("Mplus")
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
		-- Check if a window already exists
		try
			set windowCount to (count of windows)
		on error
			set windowCount to 0
		end try
		
		
		if windowCount > 0 then -- If Terminal window exists, create a new tab
			tell application "System Events" to keystroke "t" using command down
		end if
		if windowCount = 0 then -- If no window exists, open a new window
			tell application "System Events" to keystroke "n" using command down
		end if
		
		repeat while contents of selected tab of window 1 starts with linefeed
			delay 0.01
		end repeat
		
		set outputFile to basePath & nameWithoutExtension & ".out"
		set theCommand to "/Applications/Mplus/mplus \"" & thePath & "\" \"" & outputFile & "\""
		do script "cd \"" & basePath & "\"" in window 1
		do script theCommand in window 1
		
		set tabCount to count of tabs of window 1
		if tabCount > 1 then -- Close other tabs, if any are open
			tell application "System Events" to keystroke "w" using command down & option down
		end if
		
	end tell
	
	tell application "BBEdit"
		open outputFile opening in front_window with read only
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
	set appExists to isInstalled("Stata")
	if (appExists = null) then
		display alert "Stata is not installed."
		return
	else
		set whichStata to do shell script "ls /Applications/Stata/ | grep '.app'"
		tell application "BBEdit"
			set theSelection to ""
			set theSelection to the selection of window 1 of text document 1 as text
			set filePath to file of text document 1 as alias
			if (theSelection = "") then -- If selection is empty, run whole document.
				tell application whichStata
					ignoring application responses
						activate
						open filePath
					end ignoring
				end tell
			else -- If selection is not empty, run just the selection
				set theSelection to (get the selection of window 1 of text document 1 as text)
				set the clipboard to theSelection as text
				do shell script "pbpaste > /tmp/stata.do"
				do shell script "echo \"
	
			\" >> /tmp/stata.do"
				
				tell application whichStata
					ignoring application responses
						activate
						open "/tmp/stata.do"
					end ignoring
				end tell
				
			end if
		end tell
		
	end if
else
	display alert "Error: this isn't a recognised file type."
end if


-- END.
