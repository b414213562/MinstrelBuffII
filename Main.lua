import "Turbine";
import "Turbine.Gameplay";
import "CubePlugins.MinstrelBuffII.GeneralFunctions";
import "CubePlugins.MinstrelBuffII.Strings";
import "CubePlugins.MinstrelBuffII.BuffWindow";
import "CubePlugins.MinstrelBuffII.MinstrelEffects";
import "CubePlugins.MinstrelBuffII.MinstrelBuffCommand";
import "CubePlugins.MinstrelBuffII.VindarPatch"
import "CubePlugins.MinstrelBuffII.Settings";
import "CubePlugins.MinstrelBuffII.EventHelper";
import "CubePlugins.MinstrelBuffII.OptionWindow";
import "CubePlugins.MinstrelBuffII.SoliloquyTrackerRow";
import "CubePlugins.MinstrelBuffII.SoliloquyTrackerWindow";
import "CubePlugins.MinstrelBuffII.MelodicInterludeWindow";

LocalPlayer = Turbine.Gameplay.LocalPlayer.GetInstance();
EffectList = LocalPlayer:GetEffects();
AnAnthem = nil;

MinstrelBuffMain = class();

DEBUG_IGNORE_BALLAD_EFFECTS = false;

KEY_ACTION_TOGGLE_HUD = 0x100000B3;    -- F12
KEY_ACTION_REPOSITION_UI = 0x1000007B; -- Ctrl + \

-- Creates the main class.
function MinstrelBuffMain:Constructor()
	self.settings = CubePlugins.MinstrelBuffII.Settings();
	self:RefreshMounted() -- Maybe Minstrelbuff is loaded when mounted.
	self.BuffWindow = CubePlugins.MinstrelBuffII.BuffWindow(self.settings);
	self.SoliloquyWindow = CubePlugins.MinstrelBuffII.SoliloquyTrackerWindow(self.settings);
	self.MelodicInterludeWindow = CubePlugins.MinstrelBuffII.MelodicInterludeWindow(self.settings);
	self.optionWindow = OptionWindow(self.settings);
	self.balladsActive = false;
	self.isSeriousBusinessPresent = false;
	self.seriousBusinessEffect = _LANG.EFFECTS.SERIOUS_BUSINESS;
	self.checkForSeriousBusiness = self.settings:GetSetting("CheckForSeriousBusiness");
	self.showWarSpeechTimers = self.settings:GetSetting("ShowWarSpeechTimers");
	self.showMelodicInterlude = self.settings:GetSetting("ShowMelodicInterlude");

	self.buffWindowWantsChats = false;
	self.soliloquyTrackerWindowWantsChats = false;

	-- Options support for Turbine PluginManager
	plugin.GetOptionsPanel = function() return self:GetOptionControl(); end

	self.settings:AddCallback(
		"CheckForSeriousBusiness",
		function()
			self.checkForSeriousBusiness = self.settings:GetSetting("CheckForSeriousBusiness");
			self.BuffWindow:SetCheckForSeriousBusiness(self.checkForSeriousBusiness);
		end	);

	self.settings:AddCallback(
		"ShowWarSpeechTimers",
		function()
			self.showWarSpeechTimers = self.settings:GetSetting("ShowWarSpeechTimers");
		end	);

	self.settings:AddCallback(
		"ShowMelodicInterlude",
		function()
			self.showMelodicInterlude = self.settings:GetSetting("ShowMelodicInterlude");
		end	);

end

-- Writes all current buffs to the chat window.
function MinstrelBuffMain:WriteBuffsToChat()
	local placeCount = self:GetBuffCount();
	local effectCount = EffectList:GetCount();
	Turbine.Shell.WriteLine( "Current buffs: " .. placeCount );
	for	i = 1, effectCount, 1 do
		local effect = EffectList:Get(i);
		Turbine.Shell.WriteLine( effect:GetName() );	
	--[[
		if (i == 1) then
			effect.test = {};
			for k,v in pairs(effect) do
				Turbine.Shell.WriteLine( k .. " - " .. type(v));
				if (k == "__index" or k == "__metatable") then
					for k2,v2 in pairs(v) do
						Turbine.Shell.WriteLine( "   " .. k2 .. " - " .. type(v2));
						if (type(v2) == "table") then
							for k3,v3 in pairs(v2) do
								Turbine.Shell.WriteLine( "      " .. k3 .. " - " .. type(v3));
							end
						end
					end
				end
			end
		end
	end

	Turbine.Shell.WriteLine( "members" );
	for k,v in pairs(self) do
		Turbine.Shell.WriteLine( k .. "" );
	--]]
	end
end

function MinstrelBuffMain:HandleCombatChanged(isInCombat)
	self:RefreshVisibility();
	self.SoliloquyWindow:HandleCombatChanged(isInCombat);
end

-- Prepares all event handling and shows the buff window.
function MinstrelBuffMain:ShowWindow()
	self.EffectAddedCallback = function(sender, args) self:EffectAdded(sender, args); end
	self.EffectRemovedCallback = function(sender, args) self:EffectRemoved(sender, args); end
	self.EffectsClearedCallback = function(sender, args) self:EffectsCleared(sender, args); end
	self.InCombatChanged = function(sender, args)
		local isInCombat = LocalPlayer:IsInCombat();
		self:HandleCombatChanged(isInCombat);
	end
	self.MountChanged = function(sender, args) self:RefreshMounted(); end
	self.MinstrelStanceChangedCallback = function(sender, args) self:MinstrelStanceChanged(); end
	self.CodaSkillResetTimeChangedCallback = function(sender) self:CodaSkillResetTimeChanged(); end
	self.CrySkillResetTimeChangedCallback = function(sender) self:CrySkillResetTimeChanged(); end
	self.MajorBalladResetTimeChangedCallback = function(sender) self:MajorBalladResetTimeChanged(); end
	self.codaWasPlayed = false;
	self.codaSkillList = { };
	self.crySkillList = { };
	self.majorBalladSkillList = { };
	
	-- Add buff, combat and warsteed events.
	AddCallback(EffectList, "EffectAdded", self.EffectAddedCallback);
	AddCallback(EffectList, "EffectRemoved", self.EffectRemovedCallback);
	AddCallback(EffectList, "EffectCleared", self.EffectsClearedCallback);
	AddCallback(LocalPlayer, "InCombatChanged", self.InCombatChanged);
	AddCallback(LocalPlayer, "MountChanged", self.MountChanged);
	if (LocalPlayer:GetClass() == Turbine.Gameplay.Class.Minstrel) then
		-- Add stance events
		self.classAttributes = LocalPlayer:GetClassAttributes();
		AddCallback(self.classAttributes, "StanceChanged", self.MinstrelStanceChangedCallback);
		
		-- Add coda events.
		local skillList = LocalPlayer:GetTrainedSkills();
		local skillCount = skillList:GetCount();
		--Turbine.Shell.WriteLine( "Current trained skills: " .. skillCount );
		local codaSkillListIndex = 1;
		local crySkillListIndex = 1;
		local majorBalladSkillListIndex = 1;
		for	i = 1, skillCount, 1 do
			local skill = skillList:GetItem(i);
			if (self:IsValidCodaSkill(skill)) then
				self.codaSkillList[codaSkillListIndex] = skill;
				codaSkillListIndex = codaSkillListIndex + 1;
				AddCallback(skill, "ResetTimeChanged", self.CodaSkillResetTimeChangedCallback);
			end

			if (self:IsValidCrySkill(skill)) then
				self.crySkillList[crySkillListIndex] = skill;
				crySkillListIndex = crySkillListIndex + 1;
				AddCallback(skill, "ResetTimeChanged", self.CrySkillResetTimeChangedCallback);
			end

			if (self:IsValidMajorBalladSkill(skill)) then
				self.majorBalladSkillList[majorBalladSkillListIndex] = skill;
				majorBalladSkillListIndex = majorBalladSkillListIndex + 1;
				AddCallback(skill, "ResetTimeChanged", self.MajorBalladResetTimeChangedCallback);
			end
		end		
	end

	-- Add event for position changing.
	self.PositionChangedCallback = function(sender, args) self:SaveMainPositionSettings(); end
	AddCallback(self.BuffWindow, "PositionChanged", self.PositionChangedCallback);

	-- Show the window.
	self.BuffWindow:Start();
	self.BuffWindow:SetCheckForSeriousBusiness(self.checkForSeriousBusiness);
	self:RefreshEffectDisplay();
end

-- Removes all events and hides the buff window.
function MinstrelBuffMain:HideWindow()
	if (self.EffectAddedCallback ~= nil) then
		RemoveCallback(EffectList, "EffectAdded", self.EffectAddedCallback);
		RemoveCallback(EffectList, "EffectRemoved", self.EffectRemovedCallback);
		RemoveCallback(EffectList, "EffectCleared", self.EffectsClearedCallback);
		RemoveCallback(LocalPlayer, "InCombatChanged", self.InCombatChanged);
		RemoveCallback(LocalPlayer, "MountChanged", self.MountChanged);
		if (self.classAttributes ~= nil) then
			RemoveCallback(self.classAttributes, "StanceChanged", self.MinstrelStanceChangedCallback);
			self.classAttributes = nil;
		end
		for i = 1, #self.codaSkillList, 1 do
			RemoveCallback(self.codaSkillList[i], "ResetTimeChanged", self.CodaSkillResetTimeChangedCallback);
		end
		for i = 1, #self.crySkillList, 1 do
			RemoveCallback(self.crySkillList[i], "ResetTimeChanged", self.CrySkillResetTimeChangedCallback);
		end
		for i = 1, #self.majorBalladSkillList, 1 do
			RemoveCallback(self.majorBalladSkillList[i], "ResetTimeChanged", self.MajorBalladResetTimeChanged);
		end
		self.EffectAddedCallback = nil;
		self.EffectRemovedCallback = nil;
		self.EffectsClearedCallback = nil;
	end	
	
	if (self.PositionChangedCallback ~= nil) then
		RemoveCallback(self.BuffWindow, "PositionChanged", self.PositionChangedCallback);
		self.PositionChangedCallback = nil;
	end
	self.BuffWindow:Stop();
end

-- Locks or unlocks the ui for positioning (CTRL + #)
-- locked - boolean
function MinstrelBuffMain:UiLocked(locked)
	self:SaveMainPositionSettings();
	self.BuffWindow:UiLocked(locked);
end

-- Opens the options window (in the turbine plugin manager)
function MinstrelBuffMain:ShowOptions()
	Turbine.PluginManager.ShowOptions(Plugins[PluginName]);
end

-- Returns the options control. Used by turbines plugin manager.
function MinstrelBuffMain:GetOptionControl()
	return self.optionWindow:GetOptionControl();
end

-- Saves the position of the window.
function MinstrelBuffMain:SaveMainPositionSettings()
	--Turbine.Shell.WriteLine("SavePosition");
	if (self.BuffWindow ~= nil) then
		self.BuffWindow:SavePosition();
	end
end

-- Returns the localized effect names.
function MinstrelBuffMain:GetLocalization()
	return self.settings:GetEffectLocalizationNames();
end

function MinstrelBuffMain:GetEffectFromEffectCallback(args)
	local effect = nil;
	if (args.Effect ~= nil) then
		effect = args.Effect;
	else
		if (EffectList:GetCount() >= args.Index) then
			effect = EffectList:Get(args.Index);
		end
	end
	return effect;
end

function MinstrelBuffMain:TellMeMore(args)
	local text = "Index: " .. args.Index;
	local effect = self:GetEffectFromEffectCallback(args);
	if (effect ~= nil) then
		text = text .. ", Name: " .. effect:GetName() .. ", ID: " .. effect:GetID() .. ", start: " .. effect:GetStartTime();
	end
	return text;
end

-- Note: When a 4th Ballad is sung, then we see that added,
-- and then the 1st Ballad removed. (First in, First out)

-- Note: When a Anthum is re-sung, we first add the new version,
-- and then the old version is removed. (First in, First out)

function MinstrelBuffMain:EffectAdded(sender, args)
	local effect = self:GetEffectFromEffectCallback(args);

	if (effect ~= nil) then
		self:ProcessEffectAdded(effect);
	end

end

function MinstrelBuffMain:ProcessEffectAdded(effect)
	local name = effect:GetName();

	if (self:IsValidBalladEffect(name)) then
		self.BuffWindow:BalladAdded(effect);

	elseif (self:IsValidAnthemEffect(name)) then
		self.BuffWindow:AnthemAdded(effect);
		--Turbine.Shell.WriteLine("<rgb=#00FF00>EffectAdded - Anthem: " .. self:TellMeMore(args) .. "</rgb>");

	elseif (self.showWarSpeechTimers and self:IsValidWarSpeechEffect(name)) then -- need a check for warrior-skald
		-- In the case of war speech already being active when we load the plugin,
		-- We could pay attention to the effect duration instead of hard-coding 8 seconds.
		self.BuffWindow:WarSpeechAdded();

	elseif(self.showMelodicInterlude and self:IsValidMelodicInterludeEffect(name)) then
		self.MelodicInterludeWindow:MelodicInterludeStart();

	elseif(self:IsSeriousBusiness(name)) then
		self.isSeriousBusinessPresent = true;
		self.BuffWindow:SetSeriousBusiness(true);

	end
end

function MinstrelBuffMain:EffectRemoved(sender, args)
	local effect = self:GetEffectFromEffectCallback(args);

	if (effect ~= nil) then
		self:ProcessEffectRemoved(effect);
	end
end

function MinstrelBuffMain:ProcessEffectRemoved(effect)
	local name = effect:GetName();

	if (self:IsValidBalladEffect(name)) then
		self.BuffWindow:BalladRemoved(effect);

	elseif (self:IsValidAnthemEffect(name)) then
		self.BuffWindow:AnthemRemoved(effect);
		--Turbine.Shell.WriteLine("<rgb=#FF0000>EffectRemoved - Anthem: " .. self:TellMeMore(args) .. "</rgb>");

	elseif (self:IsValidWarSpeechEffect(name)) then
		self.BuffWindow:WarSpeechRemoved();

	elseif(self:IsValidMelodicInterludeEffect(name)) then
		self.MelodicInterludeWindow:MelodicInterludeStop();

	elseif(self:IsSeriousBusiness(name)) then
		self.isSeriousBusinessPresent = false;
		self.BuffWindow:SetSeriousBusiness(false);

	end
end

function MinstrelBuffMain:EffectsCleared(sender, args)
	--Turbine.Shell.WriteLine("EffectsCleared: " .. "args: " .. dump(args));

	self:RefreshEffectDisplay();
end

-- Refreshes the BuffWindow contents completely by
-- rescanning every Effect on the player.
function MinstrelBuffMain:RefreshEffectDisplay()
	local effectCount = EffectList:GetCount();
	local sortedEffects = {};
	local isSeriousBusiness = false;
	for	i = 1, effectCount, 1 do
		sortedEffects[i] = EffectList:Get(i);

		if (self.checkForSeriousBusiness and
			not isSeriousBusiness and
			sortedEffects[i]:GetName() == self.seriousBusinessEffect) then
			isSeriousBusiness = true;
		end
	end
	table.sort(sortedEffects, function(a,b) return a:GetStartTime() < b:GetStartTime() end);

	for i = 1, effectCount do
		self:ProcessEffectAdded(sortedEffects[i]);
	end

end

-- Returns true, if the effect is a valid ballad effect.
-- effectName - string
function MinstrelBuffMain:IsValidBalladEffect(effectName)
	return ValidBalladEffects[effectName] ~= nil;
end

-- Returns true, if the effect is a valid anthem effect.
-- effectName - string
function MinstrelBuffMain:IsValidAnthemEffect(effectName)
	return ValidAnthemEffects[effectName] ~= nil;
end

-- Returns the position of the effect.
-- effectName - string
function MinstrelBuffMain:GetAnthemEffectPosition(effectName)
	return ValidAnthemEffects[effectName];
end

function MinstrelBuffMain:IsValidWarSpeechEffect(effectName)
	return ValidWarSpeechSkillNames[effectName];
end

-- Melodic Interlude has been seen after the following skills:
--  Call to Fate, Dissonant Piercing Cry, Call of Oromë,
--  Cry of the Valar, Cry of the Wizards, Call of the Second Age
function MinstrelBuffMain:IsValidMelodicInterludeEffect(effectName)
	return ValidMelodicInterludeNames[effectName];
end

-- Returns true if effectName is a Serious Business
-- Returns false otherwise.
function MinstrelBuffMain:IsSeriousBusiness(effectName)
	return effectName == self.seriousBusinessEffect;
end

-- Returns true, if the skill is a minstrel coda.
-- skill - Turbine.Gameplay.ActiveSkill
function MinstrelBuffMain:IsValidCodaSkill(skill)
	local skillInfo = skill:GetSkillInfo();
	local skillName = skillInfo:GetName();
	return ValidCodaSkillNames[skillName] ~= nil;
end

function MinstrelBuffMain:IsValidCrySkill(skill)
	local skillInfo = skill:GetSkillInfo();
	local skillName = skillInfo:GetName();
	return ValidCrySkillNames[skillName] ~= nil;
end

function MinstrelBuffMain:IsValidMajorBalladSkill(skill)
	local skillInfo = skill:GetSkillInfo();
	local skillName = skillInfo:GetName();
	return ValidMajorBalladSkillNames[skillName] ~= nil;
end

function MinstrelBuffMain:IsValidYellowTraitSkill(skill)
	local skillInfo = skill:GetSkillInfo();
	local skillName = skillInfo:GetName();
	return ValidYellowTraitSkillNames[skillName] ~= nil;
end

-- Gets the count of the buffs.
function MinstrelBuffMain:GetBuffCount()
	local count = 0;
	count = EffectList:GetCount();
	return count;
end

-- Returns true, if the player is currently on a war steed.
function MinstrelBuffMain:IsPlayerOnWarsteed()
    local mount = LocalPlayer:GetMount();
    return mount ~= nil and mount:IsA(Turbine.Gameplay.CombatMount);
end

-- Occurs, when the minstrel stance was changed.
function MinstrelBuffMain:MinstrelStanceChanged()
	-- Using Stance change to re-check anthem cooldown will be necessary starting U34:
	-- "Melody stance now increases Anthem durations by 15 seconds."
	self.BuffWindow:AnthemResetTimeChanged(AnAnthem, nil);

	self.BuffWindow:SetAnthemBackgroundFromStance();
	--Turbine.Shell.WriteLine(self.classAttributes:GetStance());
end

-- Occurs, when a coda skill was used.
function MinstrelBuffMain:CodaSkillResetTimeChanged()
	self.codaWasPlayed = true; -- only mark coda as played, because the resetting event for the anthems and ballads can occur later.
	--self.BuffWindow:HideAllAnthemBorders();
end

-- Occurs, when a cry skill was used.
function MinstrelBuffMain:CrySkillResetTimeChanged()
	-- Tell the window about the event:
	self.BuffWindow:CryOfTheChorus();
end

-- Occurs, when a major ballad skill was used.
function MinstrelBuffMain:MajorBalladResetTimeChanged()
	-- Tell the window about the event:
	self.BuffWindow:MajorBallad();
end

-- Refreshes the visibility of the main window (i.e. when out of combat, no effects displayed).
function MinstrelBuffMain:RefreshVisibility()
	self.BuffWindow:SetVisibility();
end

-- Refreshes the window when the player is on a war steed or gets off a war steed.
function MinstrelBuffMain:RefreshMounted()
	self.settings:SetIsOnWarsteed(self:IsPlayerOnWarsteed());
end

function MinstrelBuffMain:InitializeChatMonitoring()
	self:UpdateChatMonitoring();
end

function MinstrelBuffMain:HandleAllChat(sender, args)
	-- SoliloquyTrackerWindow wants to know about chats:
	if (self.soliloquyTrackerWindowWantsChats) then
		self.SoliloquyWindow:ChatReceived(sender, args);
	end

	-- BuffWindow wants to know about chats:
	if (self.buffWindowWantsChats) then
		self.BuffWindow:ChatReceived(sender, args);
	end
end

function MinstrelBuffMain:UpdateChatMonitoring()
	-- Only enable chat monitoring if one of the systems wants it:
	if (not self.soliloquyTrackerWindowWantsChats and
		not self.buffWindowWantsChats) then
		Turbine.Chat.Received = nil;
	elseif (Turbine.Chat.Received == nil) then
		Turbine.Chat.Received = function(sender, args) self:HandleAllChat(sender, args); end
	else
		-- Chat should be enabled and already is, so do nothing.
	end
end

function MinstrelBuffMain:SetSoliloquyTrackerWindowWantsChats(soliloquyTrackerWindowWantsChats)
	self.soliloquyTrackerWindowWantsChats = soliloquyTrackerWindowWantsChats;
	self:UpdateChatMonitoring();
end

function MinstrelBuffMain:SetBuffWindowWantsChats(buffWindowWantsChats)
	self.buffWindowWantsChats = buffWindowWantsChats;
	self:UpdateChatMonitoring();
end

mbMain = MinstrelBuffMain();
mbCommand = CubePlugins.MinstrelBuffII.MinstrelBuffCommand();
Turbine.Shell.AddCommand( "minstrelbuff", mbCommand);
Turbine.Shell.AddCommand( "mb", mbCommand);

mbMain:ShowWindow();
mbMain:InitializeChatMonitoring();
MinstrelBuffCommand:ShowHelpText();
