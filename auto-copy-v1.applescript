

on copyFolderToFolder(srcFolder, dstFolder)
	tell application "System Events"
		
		try
			(path of disk item (srcFolder as string)) as alias
		on error
			return "Source folder is not exist. It has now stoped"
		end try
		do shell script "cp -R " & quoted form of srcFolder & " " & quoted form of dstFolder
		
		return "Files has been copied"
	end tell
end copyFolderToFolder


set dstFolder to "/Users/user/Desktop/lynda_course"
set srcFolder to "/Users/User/Library/Containers/com.lyndadotcom.lyndaosx/Data/Library/Caches/com.lyndadotcom.lyndaosx/offlnvds"
copyFolderToFolder(srcFolder, dstFolder)

