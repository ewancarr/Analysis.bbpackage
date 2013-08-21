-- formatR: This script cleans up the text in the front window of BBEdit
--          using the "tidy.source()" function from the "formatR" package.

-- 03/06/2012 

local theContent
local withSpace
local tidyText

tell application "BBEdit"
	set theContent to the text of window 1 of document 1 as text
	set withSpace to theContent & "
	
	"
end tell

tell application "Finder" to set the clipboard to withSpace as text

set tidyText to do shell script "/usr/bin/Rscript -e \"library(formatR); tidy.source()\""

tell application "BBEdit"
	set the contents of text window 1 to tidyText
end tell
