-- Send document (or selection) to Stata
-- 2013-08-21 
-- ======================================

-- Based on: http://dataninja.wordpress.com/2006/03/03/send-to-stata-applescript-for-textwrangler/

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