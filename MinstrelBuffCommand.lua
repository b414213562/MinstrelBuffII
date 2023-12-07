import "Turbine";

MinstrelBuffCommand = class(Turbine.ShellCommand);

function MinstrelBuffCommand:Constructor()
	Turbine.ShellCommand.Constructor(self);
end

function MinstrelBuffCommand:Execute( command, arguments )
	local operation = self:GetFirstArgument(arguments);

	if (operation == nil) then
		Turbine.Shell.WriteLine(self:GetHelp());
		return
	end

	if ( operation == "on" ) then
		mbMain:ShowWindow();
	elseif( operation == "off" ) then
		mbMain:HideWindow();
	elseif( operation == "list" ) then
		mbMain:WriteBuffsToChat();
	elseif ( operation == "unlock" ) then
		mbMain:UiLocked(false);
	elseif ( operation == "lock" ) then
		mbMain:UiLocked(true);
	elseif ( operation == "options" ) then
		mbMain:ShowOptions();
	else
		Turbine.Shell.WriteLine( "Invalid operation: " .. operation );
	end
end

function MinstrelBuffCommand:GetFirstArgument(arguments)
	-- No arguments, return nil.
	if ( ( arguments == nil ) or ( string.len( arguments ) == 0 ) ) then
		return nil;
	end

		-- Parse the arguments into a list.
	local argumentList = { };
	local index = 1;

	for word in arguments:gmatch( "%w+" ) do
		argumentList[index] = word;
		index = index + 1;
	end

	-- Extract the operation and example name.
	local operation = string.lower( argumentList[1] );
	return operation;
end

function MinstrelBuffCommand:GetHelp()
	local helpText = string.format("'%s' v%s, by Cube\n", PluginName, PluginVersion);

	helpText = helpText .. "/minstrelbuff [on|off|list|lock|unlock|options]\n";
	helpText = helpText .. "/mb [on|off|list|lock|unlock|options]";
	return helpText;
end

function MinstrelBuffCommand:GetShortHelp()
	local helpText = string.format("'%s' v%s, by Cube\n", PluginName, PluginVersion);
	return helpText;
end

function MinstrelBuffCommand:ShowHelpText()
	Turbine.Shell.WriteLine( self:GetShortHelp() );
end