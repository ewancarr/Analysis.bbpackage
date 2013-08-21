-- Title: Send to R 
-- Updated: 2013-08-21 
-- Author: Ewan Carr
-- ================================
-- Sends selected text to R.app.
-- If selection is empty, sends entire document.

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


