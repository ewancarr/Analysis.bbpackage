-- Run in Mplus
-- Ewan Carr
-- 2013-08-20 

-- Remove old output files

tell application "BBEdit"
	save text document 1
	set theName to name of text document 1
	set theFile to file of text document 1 as string
	set thePath to POSIX path of theFile
	set fileName to my theSplit(theName, ".")
	set nameWithoutExtension to item 1 of fileName
	set fileExtension to item 2 of fileName
end tell

if fileExtension is "out" then
	display alert ("Error: Please select an input file (.inp)")
	error number -128
end if


tell application "Finder"
	set parentFolder to container of item theFile
	set parentAlias to parentFolder as alias
	set basePath to POSIX path of parentAlias
end tell


-- Run the input file using `mplus` in Terminal.app

tell application "Terminal"
	set outputFile to basePath & nameWithoutExtension & ".out"
	set theCommand to "/Applications/Mplus/mplus \"" & thePath & "\" \"" & outputFile & "\""
	do script theCommand
end tell

tell application "BBEdit"
	open outputFile opening in front_window
end tell


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
