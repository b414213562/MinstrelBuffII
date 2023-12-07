import "CubePlugins.MinstrelBuffII.Themes.ThemeList";
import "CubePlugins.MinstrelBuffII.Themes.WarsteedThemeList";
import "CubePlugins.MinstrelBuffII.SettingsEncoder"

Settings = class();

PluginName = plugin:GetName();
PluginVersion = plugin:GetVersion();

AnthemsForPrioritySelection = {
	[1] = Anthem1LesserResonanceSkill,
	[2] = Anthem1GreaterCompassionSkill,
	[3] = Anthem2LesserDissonanceSkill,
	[4] = Anthem2GreaterWarSkill,
	[5] = Anthem3LesserComposureSkill,
	[6] = Anthem3GreaterProwessSkill,
	[7] = AnthemFreePeopleSkill,
};

AnthemEffectsToAnthemSkills = {
	[Anthem1LesserResonanceEffect] = { Anthem1LesserResonanceSkill };
	[Anthem1GreaterCompassionEffect] = { Anthem1GreaterCompassionSkill };
	[Anthem1LesserAndGreaterEffect] = { Anthem1LesserResonanceSkill, Anthem1GreaterCompassionSkill };
	[Anthem2LesserDissonanceEffect] = { Anthem2LesserDissonanceSkill };
	[Anthem2GreaterWarEffect] = { Anthem2GreaterWarSkill };
	[Anthem2LesserAndGreaterEffect] = { Anthem2LesserDissonanceSkill, Anthem2GreaterWarSkill };
	[Anthem3LesserComposureEffect] = { Anthem3LesserComposureSkill };
	[Anthem3GreaterProwessEffect] = { Anthem3GreaterProwessSkill };
	[Anthem3LesserAndGreaterEffect] = { Anthem3LesserComposureSkill, Anthem3GreaterProwessSkill };
	[AnthemFreePeopleEffect] = { AnthemFreePeopleSkill };
};

AnthemSkillRemainingTimes = {
	[Anthem1LesserResonanceSkill] = 0;
	[Anthem1GreaterCompassionSkill] = 0;
	[Anthem2LesserDissonanceSkill] = 0;
	[Anthem2GreaterWarSkill] = 0;
	[Anthem3LesserComposureSkill] = 0;
	[Anthem3GreaterProwessSkill] = 0;
	[AnthemFreePeopleSkill] = 0;
};

function ResetAnthemSkillRemainingTimes()
	AnthemSkillRemainingTimes[Anthem1LesserResonanceSkill] = 0;
	AnthemSkillRemainingTimes[Anthem1GreaterCompassionSkill] = 0;
	AnthemSkillRemainingTimes[Anthem2LesserDissonanceSkill] = 0;
	AnthemSkillRemainingTimes[Anthem2GreaterWarSkill] = 0;
	AnthemSkillRemainingTimes[Anthem3LesserComposureSkill] = 0;
	AnthemSkillRemainingTimes[Anthem3GreaterProwessSkill] = 0;
	AnthemSkillRemainingTimes[AnthemFreePeopleSkill] = 0;
end

SkillIcons = {
	[Anthem1LesserResonanceSkill]   = 0x41221406; -- 1092752390
	[Anthem1GreaterCompassionSkill] = 0x41221405; -- 1092752389
	[Anthem2LesserDissonanceSkill]  = 0x4122140A; -- 1092752394
	[Anthem2GreaterWarSkill]        = 0x41221408; -- 1092752392
	[Anthem3LesserComposureSkill]   = 0x41221407; -- 1092752391
	[Anthem3GreaterProwessSkill]    = 0x41221409; -- 1092752393
	[AnthemFreePeopleSkill]         = 0x4121DB45; -- 1092737861
};

IconSkills = {
	[0x41221406] = Anthem1LesserResonanceSkill; 	-- 1092752390
	[0x41221405] = Anthem1GreaterCompassionSkill; 	-- 1092752389
	[0x4122140A] = Anthem2LesserDissonanceSkill; 	-- 1092752394
	[0x41221408] = Anthem2GreaterWarSkill; 			-- 1092752392
	[0x41221407] = Anthem3LesserComposureSkill; 	-- 1092752391
	[0x41221409] = Anthem3GreaterProwessSkill; 		-- 1092752393
	[0x4121DB45] = AnthemFreePeopleSkill; 			-- 1092737861
};

SkillIds = {
	[Anthem1LesserResonanceSkill]   = "0x700264BA"; -- 1879205050 (700264BA) or 1879449578 (70061FEA)
	[Anthem1GreaterCompassionSkill] = "0x70061EDE"; -- 1879449310 (70061EDE) or 1879449573 (70061FE5)
	[Anthem2LesserDissonanceSkill]  = "0x700264B9"; -- 1879205049 (700264B9) or 1879449574 (70061FE6)
	[Anthem2GreaterWarSkill]        = "0x7000317F"; -- 1879060863 (7000317F) or 1879449575 (70061FE7)
	[Anthem3LesserComposureSkill]   = "0x70003E80"; -- 1879064192 (70003E80) or 1879449576 (70061FE8)
	[Anthem3GreaterProwessSkill]    = "0x70003E7F"; -- 1879064191 (70003E7F) or 1879449577 (70061FE9)
	[AnthemFreePeopleSkill]         = "0x70061ECD"; -- 1879449293 (70061ECD) or 1879449579 (70061FEB)
};

IsAnthemTrained = {
	[Anthem1LesserResonanceSkill] = false;
	[Anthem1GreaterCompassionSkill] = false;
	[Anthem2LesserDissonanceSkill] = false;
	[Anthem2GreaterWarSkill] = false;
	[Anthem3LesserComposureSkill] = false;
	[Anthem3GreaterProwessSkill] = false;
	[AnthemFreePeopleSkill] = false;
};

function ResetTrainedAnthems()
	IsAnthemTrained[Anthem1LesserResonanceSkill] = false;
	IsAnthemTrained[Anthem1GreaterCompassionSkill] = false;
	IsAnthemTrained[Anthem2LesserDissonanceSkill] = false;
	IsAnthemTrained[Anthem2GreaterWarSkill] = false;
	IsAnthemTrained[Anthem3LesserComposureSkill] = false;
	IsAnthemTrained[Anthem3GreaterProwessSkill] = false;
	IsAnthemTrained[AnthemFreePeopleSkill] = false;
end

function Settings:Constructor()
	self:Load();
	self:DetectLocalization();
end

function Settings:FixupNumber(key)
	self.settingsTable[key] = euroNormalize(self.settingsTable[key]);
end

function Settings:SetDefaultIfMissing(key, value)
	if (self.settingsTable[key] == nil) then
		self.settingsTable[key] = value;
	end
end

function Settings:Load()
	local wasSettingsFileCorrect, temp = pcall(function() self.settingsTable = PatchDataLoad(Turbine.DataScope.Character, "MinstrelBuff"); end);

	if (self.settingsTable == nil) then
		self.settingsTable = {};
	end

	self:SetDefaultIfMissing("MainPosX", 100);
	self:SetDefaultIfMissing("MainPosY", 100);
	self:SetDefaultIfMissing("SoliloquyPosX", 200);
	self:SetDefaultIfMissing("SoliloquyPosY", 200);
	self:SetDefaultIfMissing("MelodicInterludePosX", 300);
	self:SetDefaultIfMissing("MelodicInterludePosY", 300);
	-- MelodicInterludeWidth is stored as a percentage of the screen width.
	self:SetDefaultIfMissing("MelodicInterludeWidth", MelodicInterludeWindow.GetDefaultWidth() / Turbine.UI.Display:GetWidth());
	-- MainWindowWidth is also stored as a percentage of the screen width.
	self:SetDefaultIfMissing("MainWindowWidth", BuffWindow.GetDefaultWidth() / Turbine.UI.Display:GetWidth());
	self:SetDefaultIfMissing("ThemeIndex", 1);
	self:SetDefaultIfMissing("EffectWindowOnlyVisibleInCombat", false);
	self:SetDefaultIfMissing("SolilquyWindowUsed", false);
	self:SetDefaultIfMissing("AnthemPriorityUsed", false);
	self:SetDefaultIfMissing("AnthemOverlayUsed", false);

	-- Add Anthem Priority if missing:
	if (self.settingsTable["AnthemPriority"] == nil) then
		self.settingsTable["AnthemPriority"] = {
			[1] = 1,
			[2] = 2,
			[3] = 3,
			[4] = 4,
			[5] = 5,
			[6] = 6,
			[7] = 7,
		};
	end

	self:FixupNumber("ThemeIndex");
	self:FixupNumber("MainPosX");
	self:FixupNumber("MainPosY");
	self:FixupNumber("SoliloquyPosX");
	self:FixupNumber("SoliloquyPosY");
	self:FixupNumber("MelodicInterludePosX");
	self:FixupNumber("MelodicInterludePosY");
	self:FixupNumber("MelodicInterludeWidth");
	self:FixupNumber("MainWindowWidth");

	-- Validate the Theme Range:
	local themeIndex = self.settingsTable["ThemeIndex"];
	if (themeIndex == nil or
		themeIndex < 1 or
		themeIndex > #CubePlugins.MinstrelBuffII.Themes.ThemeList) then
		themeIndex = 1;
		self.settingsTable["ThemeIndex"] = 1;
		wasSettingsFileCorrect = false;
	end

	-- events
	self.SettingChanged = {};

	-- events to be removed:
	self.ThemeChanged = nil;
	if (not wasSettingsFileCorrect) then
		self:Save();
		Turbine.Shell.WriteLine("Minstrel Buff - Settings file corrupt. Created a new file");
	end
	--Turbine.Shell.WriteLine( "Settings:Load" );
end

-- Note: Save does not happen on plugin unload.
-- If you make a change that should be saved, call save.
function Settings:Save()
	if (self.settingsTable ~= nil) then
		PatchDataSave(Turbine.DataScope.Character, "MinstrelBuff", self.settingsTable);
	end
end

-- Generic Window Position Functions:
-- Pass in names like "Main", "Soliloquy"

function Settings:GetWindowPosition(windowName)
	local x = 200;
	local y = 200;

	if (self.settingsTable[windowName .. "PosX"] ~= nil) then
		x = self.settingsTable[windowName .. "PosX"];
	end
	if (self.settingsTable[windowName .. "PosY"] ~= nil) then
		y = self.settingsTable[windowName .. "PosY"];
	end
	return x, y;
end

function Settings:SetWindowPosition(windowName, posx, posy)
	self.settingsTable[windowName .. "PosX"] = posx;
	self.settingsTable[windowName .. "PosY"] = posy;
	self:Save();
end

-- End Generic Window Position Functions

-- Generic Helper Functions:

function Settings:GetSetting(settingName)
	return self.settingsTable[settingName];
end

function Settings:SetSetting(settingName, settingValue)
	self.settingsTable[settingName] = settingValue;
	self:Save();
	self:TriggerCallback(settingName);
end

function Settings:AddCallback(settingName, callback)
	self.SettingChanged[settingName] = callback;
end

function Settings:TriggerCallback(settingName)
	local callback = self.SettingChanged[settingName];
	if (callback ~= nil and type(callback) == "function") then
		callback();
	end
end

-- End Generic Helper Functions

function Settings:DetectLocalization()
	if Turbine.Shell.IsCommand("hilfe") then
        self.Localization = "de";
    elseif Turbine.Shell.IsCommand("aide") then
        self.Localization = "fr";
    else
		self.Localization = "en";
	end
end

function Settings:GetEffectLocalizationNames()
	return self.Localization;
end

-- Theme Settings
function Settings:DoesThemeSupportExtraAnthems()
	local theme = self:GetTheme();
	return theme.supportsExtraAnthems;
end

function Settings:GetWindowBackground(anthemCount)
	local theme = self:GetTheme();
	local supports = self:DoesThemeSupportExtraAnthems();
	if (not supports) then
		return theme.windowBackground;
	end
	if (anthemCount == nil) then anthemCount = 3; end

	local countToUse = anthemCount;
	if (anthemCount <= 3) then countToUse = 3;
	elseif (anthemCount > 6) then countToUse = 6;
	end

	return theme.windowBackgrounds[countToUse];
end

function Settings:GetFixedAnthemPositions()
	local theme = self:GetTheme();
	return theme.fixedAnthems;
end

function Settings:GetShowAnthems()
	local theme = self:GetTheme();
	return theme.showAnthems;
end

function Settings:GetShowAnthemTime()
	local theme = self:GetTheme();
	if (theme.showAnthemTime ~= nil) then
		return theme.showAnthemTime;
	else
		return true;
	end
end

function Settings:GetThemeList()
	return CubePlugins.MinstrelBuffII.Themes.ThemeList;
end

function Settings:GetTheme()
	if (self.isOnWarsteed) then
		return CubePlugins.MinstrelBuffII.Themes.WarsteedThemeList[self:GetWarsteedThemeIndex()];
	else
		return CubePlugins.MinstrelBuffII.Themes.ThemeList[self:GetThemeIndex()];
	end
end

function Settings:GetThemeIndex()
	return self.settingsTable["ThemeIndex"];
end

function Settings:GetWarsteedThemeIndex()
	return 1;
end

-- Adjust the MainWindowWidth setting.
-- This is needed because themes don't always have the same width.
-- (MainWindowWidth is stored as a proportion between the scaled size and the window size.)
function Settings:AdjustMainWindowWidthForNewTheme(newThemeIndex)
	local screenWidth = Turbine.UI.Display:GetWidth(); -- e.g. 1920
	local mainWindowProportionalWidth = self:GetSetting("MainWindowWidth"); -- e.g. 0.026 (2.6%)
	local mainWindowActualWidth = mainWindowProportionalWidth * screenWidth; -- e.g. 2.6% * 1920 = ~50 (49.92)

	local mainWindowDefaultWidth = BuffWindow.GetDefaultWidth(); -- e.g. 100
	local mainWindowScaledWidth = mainWindowActualWidth / mainWindowDefaultWidth; -- e.g. 49.92 / 100 = 50%

	local newThemeDefaultWidth = CubePlugins.MinstrelBuffII.Themes.ThemeList[newThemeIndex].windowWidth;
	local newThemeStretchedWidth = newThemeDefaultWidth * mainWindowScaledWidth;
	local newThemeProportionalWidth = newThemeStretchedWidth / screenWidth;
	self:SetSetting("MainWindowWidth", newThemeProportionalWidth);
end

function Settings:SetThemeIndex(value)
	if (self.settingsTable["ThemeIndex"] == value) then return; end

	self:AdjustMainWindowWidthForNewTheme(value);

	self.settingsTable["ThemeIndex"] = value;
	self:Save();
	if (type(self.ThemeChanged) == "function") then
		self.ThemeChanged();
	end
end

function Settings:SetIsOnWarsteed(value)
	if (self.isOnWarsteed ~= value) then
		self.isOnWarsteed = value;
		if (type(self.ThemeChanged) == "function") then
			self.ThemeChanged();
		end
	end
end
