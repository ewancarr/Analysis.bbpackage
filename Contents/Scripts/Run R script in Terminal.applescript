
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

if (fileName ends with ".r") then
	
	tell application "BBEdit"
		set theSelection to the selection of window 1 of text document 1 as text
		if theSelection is "" then
			set theSelection to (get contents of front window as string)
		end if
	end tell
	set the clipboard to theSelection
	tell application "Terminal"
		activate
		tell application "System Events"
			keystroke "v" using command down
			keystroke return
		end tell
	end tell
	
else
	display alert "Error: this isn't an R file."
end if

