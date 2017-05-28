--https://developer.apple.com/library/content/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html#//apple_ref/doc/uid/TP40000983-CH216-SW10

--
set dstFolder to "/Users/user/Desktop/lynda_course"
set srcFolder to "/Users/User/Library/Containers/com.lyndadotcom.lyndaosx/Data/Library/Caches/com.lyndadotcom.lyndaosx/offlnvds"

on moveFileToFolder(srcFile, dstFolder, dstFileName)
	tell application "System Events"
		set dstFile to dstFolder & "/" & dstFileName
		--create dir if not exist
		set shellScript to "mkdir -p " & my replaceFileOrPathName(dstFolder)
		my doShellScript(shellScript)
		
		--move file to new dir with new name
		set shellScript to "mv  " & my replaceFileOrPathName(srcFile) & " " & my replaceFileOrPathName(dstFile)
		try
			my doShellScript(shellScript)
		on error
			log shellScript
		end try
		return "Files has been copied"
	end tell
end moveFileToFolder

on doShellScript(cmd)
	--log cmd
	return do shell script cmd
end doShellScript

on replaceFileOrPathName(this_text)
	set this_text to replace_chars(this_text, " ", "_")
	set this_text to replace_chars(this_text, ",", "_")
	set this_text to replace_chars(this_text, "-", "_")
	set this_text to replace_chars(this_text, "?", "_")
	set this_text to replace_chars(this_text, "!", "_")
	set this_text to replace_chars(this_text, "\\", "_")
	set this_text to replace_chars(this_text, "'", "_")
	set this_text to replace_chars(this_text, "\"", "_")
	return this_text
end replaceFileOrPathName



on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

on trashAllFilesInFolder(folderSrc)
	try
		my doShellScript("mkdir " & folderSrc)
	end try
	my doShellScript("/usr/local/bin/trash  " & folderSrc)
	try
		my doShellScript("mkdir " & folderSrc)
	end try
end trashAllFilesInFolder

global courseName
global chapterName
global chaperIndex
global chaperCourseIndex
set chaperIndex to 0
set chaperCourseIndex to 0
set totalCopied to 0

--====================Main====================--
tell application "System Events"
	tell process "Lynda.com"
		--click button "Next" of window 1
		set courses to row of table 1 of scroll area 3 of window 1
		set coursesSize to count of courses
		set courseIndex to 0
		set unitName to value of static text 1 of window 1
		set dstFolder to dstFolder & "/" & my replaceFileOrPathName(unitName)
		my trashAllFilesInFolder(dstFolder)
		repeat
			set courseIndex to courseIndex + 1
			if courseIndex > coursesSize then exit repeat
			--Clear existing
			my trashAllFilesInFolder(my replaceFileOrPathName(srcFolder))
			select row courseIndex of table 1 of scroll area 3 of window 1
			
			try
				set courseName to value of static text 2 of UI element 1 of row courseIndex of table 1 of scroll area 3 of window 1
				
				set courseName to my replace_chars(courseName, "/", "_")
				--Produce error if the src file does not exist
				set theFiles to my doShellScript("ls " & my replaceFileOrPathName(srcFolder) & "/*")
				set chaperCourseIndex to chaperCourseIndex + 1
				my moveFileToFolder(theFiles, dstFolder & "/" & chaperIndex & "_" & chapterName, chaperCourseIndex & "_" & item 2 of courseName & ".mp4")
				--log "=====Copy file =====" & courseName
				set totalCopied to totalCopied + 1
			on error
				set chapterName to item 2 of courseName
				set chaperIndex to chaperIndex + 1
				set chaperCourseIndex to 0
			end try
			
			set courseName to ""
		end repeat
		display dialog "The number of total copied file = " & totalCopied
	end tell
end tell








