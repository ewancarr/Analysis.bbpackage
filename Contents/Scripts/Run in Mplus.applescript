-- Run in Mplus
-- Ewan Carr
-- 2013-08-20 

-- Subroutines

on theSplit(theString, theDelimiter)
	-- save delimiters to restore old settings
	set oldDelimiters to AppleScript's text item delimiters
	-- set delimiters to delimiter to be used
	set AppleScript's text item delimiters to theDelimiter
	-- create the array
	set theArray to every text item of theString
	-- restore the old setting
	set AppleScript's text item delimiters to oldDelimiters
	-- return the result
	return theArray
end theSplit


-- Remove old output files

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

if fileExtension is "out" then
	display alert ("Error: Please select an input file (.inp)")
	return
end if


tell application "Finder"
	set parentFolder to container of item theFile
	set parentAlias to parentFolder as alias
	set basePath to POSIX path of parentAlias
end tell


-- Run the input file using `mplus` in Terminal.app

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

