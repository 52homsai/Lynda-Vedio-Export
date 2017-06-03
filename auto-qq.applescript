global runLogin
set runLogin to false
-- Function to create a plist file 
on createAccountsFile(filePath)
	tell application "System Events"
		-- Create the Root Dictionary
		set rootDict to make new property list item with properties {kind:record}
		-- Add the Root Dictionary to a new plist file saved in filePath
		set plistFile to make new property list file with properties {contents:rootDict, name:filePath}
	end tell
end createAccountsFile

-- Function to register a new Apple account
on addAccount(filePath, label, email, pass)
	tell application "System Events"
		-- Open the plist file
		tell property list file filePath
			-- Get the plist file content
			tell contents
				-- Append a new row with all account info to the Root Dictionary of plist file
				make new property list item at end with properties {kind:list, name:label, value:{email, pass}}
			end tell
		end tell
	end tell
end addAccount

-- Function to get all accounts labels
on getLabels(filePath)
	-- Define an empty list that will contains all labels 
	set labels to {}
	tell application "System Events"
		-- Get the plist file content and save it in fileContent variable
		set fileContent to property list items of contents of property list file filePath
		-- Scan each file row and add each label to labels list
		repeat with account in fileContent
			set label to name of account
			set end of labels to label
		end repeat
	end tell
	-- Return the list with all labels
	return labels
end getLabels


-- Function to get email and password of a selected account
on getAccountInfo(filePath, selectedAccount)
	tell application "System Events"
		-- Open the plist file and get its content
		set fileContent to property list file (filePath)
		-- Get information based on selectedAccount
		set info to value of property list item selectedAccount of fileContent
	end tell
	-- Return the info array
	return info
end getAccountInfo

-- Function to get the absolute path of a file
on getPath(fileName)
	tell application "Finder"
		-- Get the absolute path of parent folder of your AppleScript file.
		set _path to parent of (path to me) as string
		-- Transform the path in a POSIX path
		set _path to POSIX path of _path
		-- Concatenate the folder path with the file name
		set _path to _path & fileName
		-- Return the POSIX path of plist file with name 'filename' that is inside the folder of AppleScript file
		return _path
	end tell
end getPath


-- Function for QQ sign in
on iTunesLogin(info)
	-- Launch QQ
	set myCommand to "open  -n " & quoted form of "/Applications/QQ.app"
	do shell script myCommand
	--set pid to (do shell script myCommand & "& echo $!") + 1
	delay 1
	try
		tell application "System Events"
			set pid to id of last process whose name is "QQ"
			--set curprocess to (every process whose unix id is pid)
			--return pid
			tell process id pid
				--display dialog (the value of text field 1 of window 1 as string)
				set the value of text field 1 of window 1 to item 1 of info
				set the value of text field 2 of window 1 to item 2 of info
				click checkbox 3 of window 1
			end tell
		end tell
	end try
	set runLogin to true
end iTunesLogin

--function to kill all QQ

on killAllQQ()
	do shell script ("killall -e " & quoted form of "QQ")
end killAllQQ










-- Set the name of plist file which will contains all your Apple accounts
set fileName to ".accounts.plist"











-- Get the absolute path of plist file using the 'getPath(fileName)' function
set filePath to getPath(fileName)

tell application "Finder"
	-- Check if the plist file already exists. If false let's create it with 'createAccountsFile(filePath)' function
	if not (exists filePath as POSIX file) then
		my createAccountsFile(filePath)
	end if
end tell

-- Display the actions dialog box
--set dialogResult to display dialog "Switch Apple Account" buttons {"Choose Account", "Add Account", "Reset Accounts", "Kill QQs"} with hidden answer

set commandList to {"一键登录所有QQ", "选择指定QQ登录", "添加新的QQ账号", "清除所有QQ密码", "一键关闭所有QQ并退出", "联系作者", "退出本程序"}
set chosenCommand to item 3 of commandList


repeat until runLogin is true
	set chosenCommand to choose from list commandList with title "QQ快速登录器 V1.1.2" with prompt "请选择指令:"
	
	if chosenCommand is false then
		error number -128 (* user cancelled *)
	else
		set chosenCommand to chosenCommand's item 1 (* extract choice from list *)
	end if
	
	--add account
	
	
	
	-- Parse the result
	if chosenCommand = item 1 of commandList then
		-- click on login all QQs
		
		set labels to getLabels(filePath)
		
		if the (count of labels) is not 0 then
			repeat with aAccount in labels
				set info to getAccountInfo(filePath, aAccount)
				iTunesLogin(info)
				
			end repeat
		else
			display dialog "还没有输入任何账号，请先输入账号" buttons {"Done"}
		end if
		
	else if chosenCommand = item 2 of commandList then
		
		-- Click on 'Choose Account' button
		
		-- Get all accounts labels using the 'getLabels(filePath)' function
		set labels to getLabels(filePath)
		
		-- Check if the user has inserted at least one account 
		if the (count of labels) is not 0 then
			
			-- Display all available accounts
			choose from list labels with title "QQ账户" with prompt "登录QQ账户:" OK button name "确定" cancel button name "取消"
			
			-- Save the choice
			copy the result as string to selectedAccount
			
			-- If user has not pressed the Cancel button go ahead 
			if not selectedAccount is equal to "false" then
				-- Get the account info about chosen account using 'getAccountInfo(filePath, selectedAccount)'
				set info to getAccountInfo(filePath, selectedAccount)
				-- Run the login
				iTunesLogin(info)
			end if
			
		else
			display dialog "还没有输入任何账号，请先输入账号" buttons {"Done"}
		end if
	else if chosenCommand = item 3 of commandList then
		
		-- Click on 'Add Account' button
		-- Ask to insert the account label 
		display dialog "请输入要登录的QQ号" default answer ""
		-- Save the field value in label variable
		set label to (text returned of result)
		set email to label
		
		
		-- Ask to insert the account password 
		display dialog "请输入密码" default answer "" with hidden answer
		-- Save the field value in pass variable
		set pass to (text returned of result)
		
		-- Insert the new account inside the plist file using the 'addAccount(filePath, label, email, pass)' function
		addAccount(filePath, label, email, pass)
		
		-- Display a success messagge   
		display dialog "账户 " & label & " 输入成功" buttons {"Done"}
		
	else if chosenCommand = item 4 of commandList then
		
		-- Click on 'Reset Accounts' button
		
		try
			-- Ask user to confirm the action
			display dialog "你确定删除所有QQ密码吗？"
			
			--  If user does not cancel the action overwrite the plist file
			createAccountsFile(filePath)
			
			-- Display a success message
			display dialog "所有账户密码已经成功删除" buttons {"Done"}
		on error
			-- Do nothing
		end try
		
	else if chosenCommand = item 5 of commandList then
		killAllQQ()
		set runLogin to true
	else if chosenCommand = item 6 of commandList then
		display dialog "请联系作者    autoQQ@outlook.com"
	else if chosenCommand = the last item of commandList then
		set runLogin to true
	end if
	
	
	
end repeat







