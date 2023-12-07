import "Turbine.UI.Lotro"
import "CubePlugins.MinstrelBuffII.MinstrelEffects";
import "CubePlugins.MinstrelBuffII.TimerControl";
import "CubePlugins.MinstrelBuffII.InCombatTimerControl";
import "CubePlugins.MinstrelBuffII.DragBar";

BuffWindow = class(Turbine.UI.Window);

MinstrelStanceMelody = Turbine.Gameplay.Attributes.MinstrelStance.None;
MinstrelStanceDissonance = Turbine.Gameplay.Attributes.MinstrelStance.WarSpeech;
MinstrelStanceResonance = Turbine.Gameplay.Attributes.MinstrelStance.Harmony;

function BuffWindow:Constructor(settings)
	Turbine.UI.Window.Constructor(self);
	self.settings = settings;
	self.settings.ThemeChanged = function() self:Restart(); end
	self.settings:AddCallback("EffectWindowOnlyVisibleInCombat", function() self:SetVisibility(); end);
	self.settings:AddCallback("AnthemPriorityUsed", function() self:UpdateAnthemPriorityUsed(); end);
	self.settings:AddCallback("AnthemOverlayUsed", function() self:UpdateAnthemOverlayUsed(); end);
end

BuffWindow.GetDefaultWidth = function()
	local defaultWidth = 300; -- ThemeList[1].windowWidth;

	if (mbMain == nil) then return defaultWidth; end

	local theme = mbMain.settings:GetTheme();
	if (theme == nil) then return defaultWidth; end

	return theme.windowWidth;
end

BuffWindow.GetDefaultHeight = function()
	local defaultHeight = 115; -- ThemeList[1].windowHeight;

	if (mbMain == nil) then return defaultHeight; end

	local theme = mbMain.settings:GetTheme();
	if (theme == nil) then return ThemeList[1].windowHeight; end

	return theme.windowHeight;
end

-- Scale the window based on the setting.
function BuffWindow:Redraw()
    local displayWidth = Turbine.UI.Display:GetWidth();

    local defaultWidth = BuffWindow.GetDefaultWidth();
    self.stretchedWindowWidth = displayWidth * self.settings:GetSetting("MainWindowWidth");

    local defaultHeight = BuffWindow.GetDefaultHeight();
    self.stretchedWindowHeight = (self.stretchedWindowWidth / defaultWidth) * defaultHeight;

    -- Stretch the window:
    self.window:SetSize(self.stretchedWindowWidth, self.stretchedWindowHeight);
    self.overlayWindow:SetSize(self.stretchedWindowWidth, self.stretchedWindowHeight);
    -- End stretch code
end

function BuffWindow:GetName()
	return "BuffWindow";
end

function BuffWindow:IsRunning()
	return ( self.window ~= nil );
end

function BuffWindow:ProcessKeyDown(sender, args)
    if (args.Action == KEY_ACTION_REPOSITION_UI) then
        -- lock / unlock the control for movement
		self:UiLocked(not self.locked);
    elseif (args.Action == KEY_ACTION_TOGGLE_HUD) then
        -- hide / show ui elements
        self:UiHidden(not self.hidden);
	end
end

function BuffWindow:UiLocked(locked)
    self.locked = locked;
    if (not self.locked) then
        self.dragBar = CubePlugins.MinstrelBuffII.DragBar(self.window, "Minstrelbuffs");
        self.dragBar:SetBarOnTop(true);
        self.dragBar:SetBarVisible(true);
        self.dragBar:SetDraggable(true);
        self.window.SizeChanged = function(sender, args)
            self.dragBar:Layout();
        end		
    else
        if (self.dragBar ~= nil) then
            self.dragBar:SetDraggable(false);
            self.dragBar:SetTarget(nil);
            self.dragBar = nil;
        end
        self.window.SizeChanged = nil;
		self:SavePosition();
		self:SetVisibility();
    end
end

function BuffWindow:SavePosition()
	self.settings:SetWindowPosition("Main", self.window:GetPosition());
end

function BuffWindow:UiHidden(hide)
	self.hidden = hide;
	self:SetVisibility();
end

function BuffWindow:Start()
	-- Initialize class variables to a good default:
	self.WasInCombat = false;
	self.CryOfTheChorusActivated = false;
	self.MajorBalladActivated = false;
	self.IsSeriousBusiness = false;
	self.CheckForSeriousBusiness = false;
	self.nextWarSpeechTimerPlace = 1;
	self.nextBalladEffectPlace = 1;
	self.nextAnthemEffectPlace = 1; -- Only used in non-fixed mode
	self.anthemCooldownSeconds = 25;
	self.anthemCooldownBufferSeconds = 2; -- How much extra time to allot to anthem cooldown for animations.
	self.anthemResetTime = 0;
	self.nextAdvancementChannelHandleTime = 0;
	self.nextUpdateTrainedAnthemsTime = 0;
	self.nextAnthemBelowCooldownTime = 0;
	self.AnthemPriorityUsed = self.settings:GetSetting("AnthemPriorityUsed");
	self.AnthemOverlayUsed = self.settings:GetSetting("AnthemOverlayUsed");

	--Turbine.Shell.WriteLine("BuffWindow:Start()");
	self.locked = true;
	self.hidden = false;

	local posx, posy = self.settings:GetWindowPosition("Main");

	-- Don't create multiple windows.
	if ( self.window ~= nil ) then
		return;
	end

	-- background-Window
	--self.window = Turbine.UI.Lotro.Window();
	self.window = Turbine.UI.Window();
	if (self.AnthemOverlayUsed) then
		self.window:SetZOrder(-1);
	end
	if posx == nil then
		posx = 100;
	end
	if posy == nil then
		posy = 100;
	end
	local theme = self.settings:GetTheme();
	self.isAnthemFixed = theme.fixedAnthems;
	--Turbine.Shell.WriteLine(theme.name);
	self.window:SetPosition( posx, posy );
	self.window:SetSize(theme.windowWidth , theme.windowHeight );
	self.window:SetText( "Minstrel" );
	self.window:SetVisible( true );
	self.window:SetMouseVisible(false);
	self.window:SetWantsKeyEvents(true);
	self.window.KeyDown	= function(sender, args) self:ProcessKeyDown(sender, args); end
	self.window:SetBackground( theme.windowBackground );

	self.overlayWindow = Turbine.UI.Window();
	self.overlayWindow:SetPosition( posx, posy );
	self.overlayWindow:SetSize(theme.windowWidth , theme.windowHeight );
	self.overlayWindow:SetMouseVisible(false);
	self.overlayWindow:SetVisible( self.AnthemOverlayUsed );

	self.window.PositionChanged = function(sender, args)
		-- Keep overlay window and main window in sync
		self.overlayWindow:SetPosition(self.window:GetPosition());
	end

	self.anthemCount = 3;
	--self:SetBackgroundImage();

	-- Override the default GetSize() so DragBar knows our scaled size.
	-- Note: This syntax isn't working. There's probably a better way.
	--       In the meantime, DragBar is stuck in original size
	--       until this nested window thing is taken care of.
	self.window.GetSize = function( s )
		--Turbine.Shell.WriteLine("self.window.GetSize()");
		if (s.stretchedWindowWidth ~= nil and
			s.stretchedWindowHeight ~= nil) then
			return s.stretchedWindowWidth, s.stretchedWindowHeight;
		else
			return Turbine.UI.Control.GetSize(s);
		end
	end

	self.window.Closed = function( sender, args )
		self:Stop();
	end

	-- Ballad background
	self.balladBackground = Turbine.UI.Control();
	self.balladBackground:SetParent(self.window);
	self.balladBackground:SetSize( theme.balladWidth, theme.balladHeight );
	self.balladBackground:SetPosition(theme.balladPosX, theme.balladPosY);
	self.balladBackground:SetVisible(true);
	self.balladBackground:SetMouseVisible(false);
	self.balladBackground:SetBackground(theme.balladBackground);
	
	-- Anthem background
	self.anthemBackground = Turbine.UI.Control();
	self.anthemBackground:SetParent(self.window);
	self.anthemBackground:SetSize( theme.anthemWidth, theme.anthemHeight );
	self.anthemBackground:SetPosition( theme.anthemPosX, theme.anthemPosY );
	self.anthemBackground:SetVisible(true);
	self.anthemBackground:SetMouseVisible(false);
	self.anthemBackground:SetBackground( theme.anthemBackground );
	
	-- Ballad effect controls
	self.balladEffectDisplays = { };
	for i = 1, 4, 1 do
		local posx = theme.balladEffectStartX + (i - 1) * theme.balladEffectSpaceX;
		self.balladEffectDisplays[i] = Turbine.UI.Lotro.EffectDisplay();
		self.balladEffectDisplays[i]:SetParent(self.window);
		self.balladEffectDisplays[i]:SetPosition( posx, theme.balladEffectY );
		self.balladEffectDisplays[i]:SetVisible(false);
		self.balladEffectDisplays[i]:SetMouseVisible(false);
		self.balladEffectDisplays[i]:SetSize(theme.balladEffectWidth, theme.balladEffectHeight);
	end

	self.warSpeechTimeDisplays = { };
	for i = 1, 4, 1 do -- Make an extra to hold the temporary 4th
		local posx = theme.balladEffectStartX + (i - 1) * theme.balladEffectSpaceX;
		local posy = theme.balladEffectY + theme.balladEffectHeight + 6;
		local warSpeechHeight = theme.combatTimerHeight; -- make this it's own value in the theme?

		self.warSpeechTimeDisplays[i] = CubePlugins.MinstrelBuffII.TimerControl()
		self.warSpeechTimeDisplays[i]:SetParent(self.window);
		self.warSpeechTimeDisplays[i]:SetPosition( posx, posy );
		self.warSpeechTimeDisplays[i]:SetVisible(false);
		self.warSpeechTimeDisplays[i]:SetMouseVisible(false);
		self.warSpeechTimeDisplays[i]:SetSize(theme.balladEffectWidth, warSpeechHeight);
		self.warSpeechTimeDisplays[i]:SetDuration(8); -- War-speech always lasts 8 seconds
		self.warSpeechTimeDisplays[i]:SetBackColor(Turbine.UI.Color.Red);
	end
	
	-- Anthem effect controls
	self.anthemInFixedLocationId = { };
	self.anthemEffectDisplays = { };
	self.anthemEffectBorders = { };
	self.anthemEffectOverlays = { };

	for i = 1, 7, 1 do
		local x = theme.anthemEffectStartX + (i - 1) * theme.anthemEffectSpaceX;
		local y = theme.anthemEffectY;
		local width = theme.anthemEffectWidth;
		local height = theme.anthemEffectWidth;

		self.anthemEffectDisplays[i] = Turbine.UI.Lotro.EffectDisplay()
		self.anthemEffectDisplays[i]:SetParent(self.window);
		self.anthemEffectDisplays[i]:SetPosition( x, y );
		self.anthemEffectDisplays[i]:SetVisible(false);
		self.anthemEffectDisplays[i]:SetMouseVisible(false);
		self.anthemEffectDisplays[i]:SetSize(width, height);

		-- Note: We should be able to use a single label for each anthem,
		-- but maybe something about the SetSetchMode? is preventing the label
		-- from being updated. For now, use a label for each state.
		self.anthemEffectOverlays[i] = { };
		self.anthemEffectOverlays[i][Lesser] = self:CreateOverlayLabel(x, y, width, height, Lesser);
		self.anthemEffectOverlays[i][Greater] = self:CreateOverlayLabel(x, y, width, height, Greater);
		self.anthemEffectOverlays[i][LesserAndGreater] = self:CreateOverlayLabel(x, y, width, height, LesserAndGreater);

		if (theme.fixedAnthems) then
			-- Border, when the anthem is active for the next coda.
			-- Works only, when a theme with fixed anthem positions is used.
			self.anthemEffectBorders[i] = Turbine.UI.Control()
			self.anthemEffectBorders[i]:SetParent(self.window);
			self.anthemEffectBorders[i]:SetPosition( x, y );
			self.anthemEffectBorders[i]:SetVisible(false);
			self.anthemEffectBorders[i]:SetSize(width, height);
			self.anthemEffectBorders[i]:SetMouseVisible(false);
			self.anthemEffectBorders[i]:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
			self.anthemEffectBorders[i]:SetBackground(theme.anthemBorder);
		end
	end
	
	-- Anthem time controls
	self.anthemTimeDisplays = { };
	for i = 1, 7, 1 do
		local posx = theme.anthemTimeStartX + (i - 1) * theme.anthemTimeSpaceX;
		self.anthemTimeDisplays[i] = CubePlugins.MinstrelBuffII.TimerControl()
		self.anthemTimeDisplays[i]:SetParent(self.window);
		self.anthemTimeDisplays[i]:SetPosition( posx, theme.anthemTimeY );
		self.anthemTimeDisplays[i]:SetVisible(false);
		self.anthemTimeDisplays[i]:SetMouseVisible(false);
		self.anthemTimeDisplays[i]:SetTimerSize(theme.anthemTimeWidth, theme.anthemTimeHeight);
	end	

	self.inCombatTimeDisplay = CubePlugins.MinstrelBuffII.InCombatTimerControl()
	self.inCombatTimeDisplay:SetParent(self.window);
	self.inCombatTimeDisplay:SetPosition(theme.combatTimerX, theme.combatTimerY);
	self.inCombatTimeDisplay:SetVisible(false);
	self.inCombatTimeDisplay:SetMouseVisible(false);
	self.inCombatTimeDisplay:SetSize(theme.combatTimerWidth, theme.combatTimerHeight);
	self.inCombatTimeDisplay.CombatTimerExpired = function() self:SetVisibility(); end

	-- Anthem Priority Display
	local shortcutTypeSkill = 6;
	local defaultPrioritySkill = SkillIds[Anthem2LesserDissonanceSkill];
	self.anthemPriorityShortcut = Turbine.UI.Lotro.Shortcut(shortcutTypeSkill, defaultPrioritySkill);

    self.anthemPriorityQuickslot = Turbine.UI.Lotro.Quickslot();
    self.anthemPriorityQuickslot:SetParent(self.window);
    self.anthemPriorityQuickslot:SetSize(36, 36);
    self.anthemPriorityQuickslot:SetPosition(theme.priorityAnthemX, theme.priorityAnthemY);
    self.anthemPriorityQuickslot:SetShortcut(self.anthemPriorityShortcut);
    self.anthemPriorityQuickslot:SetAllowDrop(false);
	self.anthemPriorityQuickslot:SetVisible(self.AnthemPriorityUsed);

	self:SetAnthemBackgroundFromStance();
	self:SetVisibility();

	self.window:SetStretchMode(1);
	self.overlayWindow:SetStretchMode(1);
    self:Redraw();

	self.window.Update = function(sender, args) self:Update(sender, args); end

	self:UpdateTrainedAnthems();
	self:RecalculateAnthemPriority();

	mbMain:SetBuffWindowWantsChats(self.AnthemPriorityUsed);
end

function BuffWindow:Update(sender, args)
	local currentTime = Turbine.Engine.GetGameTime();

	-- Update can be requested for several reasons:

	-- We need to update trained anthems:
	if (self.nextUpdateTrainedAnthemsTime ~= 0 and
		currentTime >= self.nextUpdateTrainedAnthemsTime) then
		self.nextUpdateTrainedAnthemsTime = 0;
		self:UpdateTrainedAnthems();
	end

	-- We need to recalculate anthem priority:

	-- Only force an anthem priority calculation
	-- when the next anthem effect drops below the anthem cooldown:
	if (self.nextAnthemBelowCooldownTime ~= 0 and
		currentTime >= self.nextAnthemBelowCooldownTime) then
		self.nextAnthemBelowCooldownTime = 0;
		self:RecalculateAnthemPriority();
	end

	-- if we aren't doing any of these, then stop updates:
	if (self.nextUpdateTrainedAnthemsTime == 0 and
		self.nextAnthemBelowCooldownTime == 0) then
		self.window:SetWantsUpdates(false);
	end
end

function BuffWindow:CreateOverlayLabel(x, y, width, height, text)
	local label = Turbine.UI.Label();
	label:SetParent(self.overlayWindow);
	label:SetPosition( x, y );
	label:SetSize(width - 4, height);
	label:SetVisible(false);
	label:SetMouseVisible(false);
	label:SetFont(Turbine.UI.Lotro.Font.TrajanProBold16);
	label:SetFontStyle(Turbine.UI.FontStyle.Outline);
	label:SetMultiline(false);
	label:SetTextAlignment(Turbine.UI.ContentAlignment.BottomRight);
	label:SetText(text);
	return label;
end

function BuffWindow:UpdateBackground(anthemCount, forceUpdate)
	if (not self.settings:DoesThemeSupportExtraAnthems()) then
		return;
	end

	if (anthemCount == self.anthemCount
	    and not forceUpdate) then return; end

	local background = self.settings:GetWindowBackground(anthemCount);
	self.window:SetBackground(background);
	self.anthemCount = anthemCount;
end

function BuffWindow:SetAnthemBackgroundFromStance()
	local theme = self.settings:GetTheme();
	local isInYellowSpec = self:IsInYellowSpec();

	if (self:GetActiveStance() == MinstrelStanceMelody) then
		self.window:SetBackground( theme.windowBackground );
		self.anthemBackground:SetBackground( theme.anthemBackground );
		if (isInYellowSpec and theme.anthemBackgroundYellow ~= nil) then
			self.anthemBackground:SetBackground( theme.anthemBackgroundYellow );
		end
	elseif (self:GetActiveStance() == MinstrelStanceResonance) then
		if (theme.windowBackgroundHarmony ~= nil) then
			self.window:SetBackground( theme.windowBackgroundHarmony );
		end
		if (theme.anthemBackgroundHarmony ~= nil) then
			self.anthemBackground:SetBackground( theme.anthemBackgroundHarmony );
		end
	elseif (self:GetActiveStance() == MinstrelStanceDissonance) then
		if (theme.windowBackgroundWarSpeech ~= nil) then
			self.window:SetBackground( theme.windowBackgroundWarSpeech );
		end
		if (theme.anthemBackgroundWarSpeech ~= nil) then
			self.anthemBackground:SetBackground( theme.anthemBackgroundWarSpeech );
		end
	-- Doing nothing with an unknown stance is fine.
	end

	self:UpdateBackground(self.anthemCount, true);
end

function BuffWindow:GetActiveStance()
	if (LocalPlayer:GetClass() == Turbine.Gameplay.Class.Minstrel and self.classAttributes == nil) then
		self.classAttributes = LocalPlayer:GetClassAttributes();
	end
	if (self.classAttributes == nil) then
		return nil;
	end
	return self.classAttributes:GetStance();
end

-- Returns true, if the minstrel is in yellow trait line.
-- Searches for "Anthem of prowess".
function BuffWindow:IsInYellowSpec()
	local skillList = LocalPlayer:GetTrainedSkills();
	local skillCount = skillList:GetCount();
	for	i = 1, skillCount, 1 do
		local skill = skillList:GetItem(i);
		if (mbMain:IsValidYellowTraitSkill(skill)) then
			return true;
		end
	end
	return false;
end

function BuffWindow:GetPosition()
	return self.window:GetPosition();
end

function BuffWindow:Stop()
	-- Free the window which will free its child controls.
	-- Note: Hide the window first, otherwise the skill shortcuts can
	-- 		 appear briefly at screen coordinates 0, 0.
	if (self.window) then
		self.window:SetVisible(false);
		self.window = nil;
	end
end

function BuffWindow:Restart()
	self:Stop();
	self:Start();
	mbMain:RefreshEffectDisplay();
end

function BuffWindow:GetWindowVisible()
	return
		(not self.CheckForSeriousBusiness or not self.IsSeriousBusiness) and
		(not self.hidden) and 
		(
			not self.settings:GetSetting("EffectWindowOnlyVisibleInCombat") or 
			LocalPlayer:IsInCombat() or 
			self:AreEffectsVisible()
		);
end

function BuffWindow:CryOfTheChorus()
	-- In case the cry happens before the window is shown:
	if (self.inCombatTimeDisplay == nil) then
		self:Start();
	end

	self.CryOfTheChorusActivated = true;
	self:SetVisibility();
end

function BuffWindow:MajorBallad()
	-- In case the ballad happens before the window is shown:
	if (self.inCombatTimeDisplay == nil) then
		self:Start();
	end

	self.MajorBalladActivated = true;
	self:SetVisibility();
end

function BuffWindow:EnsureCombatTimerVisible()
	if (self.settings:GetShowAnthemTime()) then
		self.inCombatTimeDisplay:SetVisible(true);
	end
end

function BuffWindow:StartCombatTimer()
	self.inCombatTimeDisplay:EnteringCombat();
end

function BuffWindow:LeavingCombat()
	self.inCombatTimeDisplay:LeavingCombat();
end

function BuffWindow:BalladEnded()
	self.inCombatTimeDisplay:BalladEnded();
end

function BuffWindow:SetVisibility()
	if (self.CryOfTheChorusActivated) then
		self.CryOfTheChorusActivated = false;
		self.inCombatTimeDisplay:CryOfTheChorus();
	end
	if (self.MajorBalladActivated) then
		self.MajorBalladActivated = false;
		self.inCombatTimeDisplay:MajorBallad();
	end
	if ((LocalPlayer:IsInCombat() and not self.WasInCombat)) then
		-- Entering Combat:
		self:StartCombatTimer();
	elseif (not LocalPlayer:IsInCombat() and self.WasInCombat) then
		-- Leaving Combat:
		self:LeavingCombat();
	end
	self.WasInCombat = LocalPlayer:IsInCombat();

	if (self.window ~= nil) then
		local visible = self:GetWindowVisible();
		self.window:SetVisible(visible);
		self.overlayWindow:SetVisible(visible and self.AnthemOverlayUsed);
		self:EnsureCombatTimerVisible();
	end
end

function BuffWindow:SetText(text)
	--self.label:SetText(text);
end

function BuffWindow:AreEffectsVisible()
	--Turbine.Shell.WriteLine(self.effectCount);
	--return self.effectCount > 0;
	for i = 1, #self.balladEffectDisplays, 1 do
		if (self.balladEffectDisplays[i]:IsVisible()) then
			return true;
		end
	end
	for i = 1, #self.anthemEffectDisplays, 1 do
		if (self.anthemEffectDisplays[i]:IsVisible()) then
			return true;
		end
	end
	if (self.inCombatTimeDisplay:GetWantsUpdates()) then
		return true;
	end
	return false;
end

-- War-speech functions, move down to other related functions
-- after merging with rework-effect-list-processing branch

-- NOTE: If you have 3 War-speech effects already, a 4th Effect WILL NOT BE ADDED.

function BuffWindow:WarSpeechShift()
	for i = 1, #self.warSpeechTimeDisplays - 1 do
		self.warSpeechTimeDisplays[i]:SetStartTime(self.warSpeechTimeDisplays[i+1]:GetStartTime());
	end

	-- update visibility:
	self.warSpeechTimeDisplays[self.nextWarSpeechTimerPlace]:SetStartTime(0);
	self.warSpeechTimeDisplays[self.nextWarSpeechTimerPlace]:SetVisible(false);

end

function BuffWindow:WarSpeechAdded()
    -- start 8 second timer in the next available spot
	local gameTime = Turbine.Engine.GetGameTime();

	local timeControl = self.warSpeechTimeDisplays[self.nextWarSpeechTimerPlace];
    timeControl:SetStartTime(gameTime);

    if (self.nextWarSpeechTimerPlace < 4) then
		timeControl:SetVisible(true);

		self.nextWarSpeechTimerPlace = self.nextWarSpeechTimerPlace + 1;
	else
		self:WarSpeechShift();
    end

    -- Do we want to call self:SetVisibility()?
end

function BuffWindow:WarSpeechRemoved()
	-- remove war speech in first spot, shift any remaining over
	self:WarSpeechShift();

	-- This can't be in WarSpeechShift because WarSpeechAdded needs to call WarSpeechShift too.
	if (self.nextWarSpeechTimerPlace > 1) then
		self.nextWarSpeechTimerPlace = self.nextWarSpeechTimerPlace - 1;
	end

	-- Do we want to call self:SetVisibility()?
end

--

function BuffWindow:GetEffectDisplay(index)
	return self.balladEffectDisplays[index];
end

function BuffWindow:GetAnthemEffectDisplay(index)
	return self.anthemEffectDisplays[index];
end

function BuffWindow:GetAnthemEffectOverlays(index)
	return self.anthemEffectOverlays[index];
end

function BuffWindow:GetAnthemTimeDisplay(index)
	return self.anthemTimeDisplays[index];
end

-- New functions:

function BuffWindow:BalladShift()
	for i = 1, #self.balladEffectDisplays - 1 do
		self.balladEffectDisplays[i]:SetEffect(self.balladEffectDisplays[i+1]:GetEffect());
	end
end

function BuffWindow:BalladAdded(effect)
	--Turbine.Shell.WriteLine("BalladAdded(" .. effect:GetName() .. ")");
	-- If all three are filled (e.g. if the 3rd is filled)
	-- Then move 2 to 1, 3 to 2, and then put the new one in 3

	-- If all three are not filled (e.g. if the 3rd or 2nd is not filled)
	-- Then put the new effect there.

	local positionToInsert = self.nextBalladEffectPlace;
	if (self.nextBalladEffectPlace <= 4) then
		self.nextBalladEffectPlace = self.nextBalladEffectPlace + 1;
	else
		-- This branch will normally not be called.
		self:BalladShift();
		positionToInsert = #self.balladEffectDisplays;
	end
	self.balladEffectDisplays[positionToInsert]:SetEffect(effect);
	self.balladEffectDisplays[positionToInsert]:SetVisible(true);

end

-- Either called after a 4th ballad is added to remove the oldest,
-- or if all of the ballads are going to be removed.
function BuffWindow:BalladRemoved(effect)
	self:BalladShift();
	if (self.nextBalladEffectPlace > 1) then
		self.nextBalladEffectPlace = self.nextBalladEffectPlace - 1;
	end
	--self.balladEffectDisplays[self.nextBalladEffectPlace]:SetEffect(nil);
	self.balladEffectDisplays[self.nextBalladEffectPlace]:SetVisible(false);
end

--- New Anthem functions:

-- Note: If you call this on a ballad, your time remaining will be max.
-- Ballads don't expire in the normal way.
function BuffWindow:GetRemainingAnthemTime(effect)
	if (effect == nil) then return; end

	local currentTime = Turbine.Engine.GetGameTime();
	local elapsedTime = currentTime - effect:GetStartTime();
	local timeRemaining = effect:GetDuration() - elapsedTime;

	--Turbine.Shell.WriteLine(
	--	"Current: " .. currentTime .. ", effect:GetStartTime(): " .. effect:GetStartTime() .. ", effect:GetDuration(): " .. effect:GetDuration());

	return timeRemaining;
end

-- Returns the position of the effect.
-- effectName - string

-- Note: Original is in Main.lua, needs to be removed from there
function BuffWindow:GetAnthemEffectPosition(effectName)
	return ValidAnthemEffects[effectName];
end

function BuffWindow:AnthemShift(effectID)
	if (effectID == nil and self.anthemEffectDisplays[1]:GetEffect() ~= nil) then
		effectID = self.anthemEffectDisplays[1]:GetEffect():GetID();
	end

	local foundTheEffect = false;
	for i = 1, #self.anthemEffectDisplays - 1 do
		if (not foundTheEffect and
			self.anthemEffectDisplays[i]:GetEffect() ~= nil and
			self.anthemEffectDisplays[i]:GetEffect():GetID() == effectID) then
			foundTheEffect = true;
		end

		if (foundTheEffect) then
			self.anthemEffectDisplays[i]:SetEffect(self.anthemEffectDisplays[i+1]:GetEffect());
			self.anthemTimeDisplays[i]:SetStartTime(self.anthemTimeDisplays[i+1]:GetStartTime());
			self.anthemTimeDisplays[i]:SetDuration(self.anthemTimeDisplays[i+1]:GetDuration());

			self.anthemEffectOverlays[i][Lesser]:SetVisible(self.anthemEffectOverlays[i+1][Lesser]:IsVisible());
			self.anthemEffectOverlays[i][Greater]:SetVisible(self.anthemEffectOverlays[i+1][Greater]:IsVisible());
			self.anthemEffectOverlays[i][LesserAndGreater]:SetVisible(self.anthemEffectOverlays[i+1][LesserAndGreater]:IsVisible());
		end
	end
end

function BuffWindow:AnthemAdded(effect)
	local effectName = effect:GetName();
	if (self.isAnthemFixed) then
		local anthemEffectPosition = self:GetAnthemEffectPosition(effectName);
		self:ShowAnthem(effect, anthemEffectPosition);
		-- Effect border only works with fixed anthems.
		self:ShowAnthemBorder(anthemEffectPosition);

		self.anthemInFixedLocationId[anthemEffectPosition] = effect:GetID();
	else
		-- If all spaces are not filled (e.g. if the 3rd or 2nd is not filled)
		-- Then put the new effect there.

		-- Otherwise, put new anthem in fake spot #7
		-- Then anthem removal will shift it

		local positionToInsert = self.nextAnthemEffectPlace;
		if (self.nextAnthemEffectPlace < 7) then
			self.nextAnthemEffectPlace = self.nextAnthemEffectPlace + 1;
		else
			-- This branch will normally not be called.
			self:AnthemShift();
			positionToInsert = #self.balladEffectDisplays;
		end
		self:ShowAnthem(effect, positionToInsert);
		self:UpdateBackground(positionToInsert);
	end

	-- if an anthem effect was added, recalculate the anthem priority queue
	-- Change to TriggerRecalculation()
	self:RecalculateAnthemPriority();
end

function BuffWindow:AnthemRemoved(effect)
	local effectName = effect:GetName();
	if (self.isAnthemFixed) then
		local anthemEffectPosition = self:GetAnthemEffectPosition(effectName);
		
		if (self.anthemInFixedLocationId[anthemEffectPosition] == effect:GetID()) then
			self:HideAnthem(anthemEffectPosition);
			self.anthemEffectBorders[anthemEffectPosition]:SetVisible(false);
			self.anthemInFixedLocationId[anthemEffectPosition] = 0;
		end
	else
		-- Find the anthem that's being removed.
		-- Shift everything to the right.
		self:AnthemShift(effect:GetID());
		if (self.nextAnthemEffectPlace > 1) then
			self.nextAnthemEffectPlace = self.nextAnthemEffectPlace - 1;
		end
		self:HideAnthem(self.nextAnthemEffectPlace);
		self:UpdateBackground(self.nextAnthemEffectPlace - 1);
	end

	-- if an anthem effect was removed, recalculate the anthem priority queue
	-- Change to TriggerRecalculation()
	self:RecalculateAnthemPriority();
end


----

function BuffWindow:ShowEffect(effect, index)
	--Turbine.Shell.WriteLine("ShowEffect(" .. effect:GetName() .. ", " .. index .. ")");

	local wnd = self:GetEffectDisplay(index);
	wnd:SetEffect(effect);
	wnd:SetVisible(true);
	self:SetVisibility();
end

function BuffWindow:HideEffect(index)
	--Turbine.Shell.WriteLine("HideEffect(" .. index .. ")");
	local wnd = self:GetEffectDisplay(index);
	wnd:SetVisible(false);
	self:SetVisibility();
end

---Shows an anthem effect in a specific position
---@param effect Effect The text to display.
function BuffWindow:ShowAnthem(effect, index)
	--Turbine.Shell.WriteLine("ShowAnthem(" .. effect:GetName() .. ", " .. index .. ")");
	local wnd = self:GetAnthemEffectDisplay(index);
	wnd:SetEffect(effect);
	wnd:SetVisible(true);

	local overlayText = AnthemOverlays[effect:GetName()];
	local overlays = self:GetAnthemEffectOverlays(index);
	-- Turn them all off:
	overlays[Lesser]:SetVisible(false);
	overlays[Greater]:SetVisible(false);
	overlays[LesserAndGreater]:SetVisible(false);
	-- Turn the right one back on:
	if (overlays[overlayText] ~= nil) then
		overlays[overlayText]:SetVisible(true);
	end

	local timeWnd = self:GetAnthemTimeDisplay(index);
	timeWnd:SetDuration(effect:GetDuration());
	timeWnd:SetStartTime(effect:GetStartTime());
	if (self.settings:GetShowAnthemTime()) then
		timeWnd:SetVisible(true);
	end
	self:SetVisibility();
end

function BuffWindow:HideAnthem(index)
	local wnd = self:GetAnthemEffectDisplay(index);
	wnd:SetVisible(false);

	local overlays = self:GetAnthemEffectOverlays(index);
	overlays[Lesser]:SetVisible(false);
	overlays[Greater]:SetVisible(false);
	overlays[LesserAndGreater]:SetVisible(false);

	local timeWnd = self:GetAnthemTimeDisplay(index);
	timeWnd:SetVisible(false);
	self:SetVisibility();
end

function BuffWindow:ShowAnthemBorder(index)
	self.anthemEffectBorders[index]:SetVisible(true);
end

function BuffWindow:HideAllAnthemBorders()
	for i = 1, #self.anthemEffectBorders, 1 do
		self.anthemEffectBorders[i]:SetVisible(false);
	end
end

function BuffWindow:SetSeriousBusiness(isSeriousBusiness)
	if (isSeriousBusiness ~= self.IsSeriousBusiness) then
		self.IsSeriousBusiness = isSeriousBusiness;
		self:SetVisibility();
	end
end

function BuffWindow:SetCheckForSeriousBusiness(checkForSeriousBusiness)
	self.CheckForSeriousBusiness = checkForSeriousBusiness;
	self:SetVisibility();
end

-- Update our internal state of how long anthems take to cool down
-- based on an actual anthem.
-- If our state changes, recalculate the anthem priority.
function BuffWindow:SetAnthemCooldownSecondsAndResetTime(anthemCooldownSeconds, anthemResetTime)
	local somethingChanged = false;

	if (self.anthemCooldownSeconds ~= anthemCooldownSeconds) then
		self.anthemCooldownSeconds = anthemCooldownSeconds;
		somethingChanged = true;
	end
	if (self.anthemResetTime ~= anthemResetTime) then
		self.anthemResetTime = anthemResetTime;
		somethingChanged = true;
	end

	if (somethingChanged) then
		-- change to TriggerRecalculation()
		self:RecalculateAnthemPriority();
	end
end

-- Returns nil for Anthem of the Free Peoples
function BuffWindow:GetPairedAnthem(possiblyPairedAnthemSkill)
	-- Lesser/Greater I:
	if (possiblyPairedAnthemSkill == Anthem1LesserResonanceSkill) then
		return Anthem1GreaterCompassionSkill;
	elseif (possiblyPairedAnthemSkill == Anthem1GreaterCompassionSkill) then
		return Anthem1LesserResonanceSkill;

	-- Lesser/Greater II:
	elseif (possiblyPairedAnthemSkill == Anthem2LesserDissonanceSkill) then
		return Anthem2GreaterWarSkill;
	elseif (possiblyPairedAnthemSkill == Anthem2GreaterWarSkill) then
		return Anthem2LesserDissonanceSkill;

	-- Lesser/Greater III:
	elseif (possiblyPairedAnthemSkill == Anthem3LesserComposureSkill) then
		return Anthem3GreaterProwessSkill;
	elseif (possiblyPairedAnthemSkill == Anthem3GreaterProwessSkill) then
		return Anthem3LesserComposureSkill;

	end

	-- Anthem of the Free Peoples:
	return nil;
end

function BuffWindow:RecalculateAnthemPriority()
	--Turbine.Shell.WriteLine("BuffWindow:RecalculateAnthemPriority()");

	local currentTime = Turbine.Engine:GetGameTime();
	self.nextAnthemBelowCooldownTime = 0;

	-- The hard part goes here!

	-- Check our current anthem effects for remaining time
	-- correlate the effects with the underlying skill
	-- save off the remaining time for each skill

	ResetAnthemSkillRemainingTimes();
	-- Check on each active effect:
	for i = 1, #self.anthemEffectDisplays do
		local effect = self.anthemEffectDisplays[i]:GetEffect();
		if (effect) then
			local effectName = effect:GetName();
			local effectStartTime = effect:GetStartTime();
			local effectDuration = effect:GetDuration();
			local effectExpirationTime = effectStartTime + effectDuration;
			local timeRemaining = effectExpirationTime - currentTime;

			-- Update the remaining time for each skill associated with the effect:
			for j = 1, #AnthemEffectsToAnthemSkills[effectName] do
				local skill = AnthemEffectsToAnthemSkills[effectName][j];
				AnthemSkillRemainingTimes[skill] = timeRemaining;
			end
		end
	end

	-- for each anthem in priority list
	local prioritySkill = nil;
	local anthemPriority = self.settings:GetSetting("AnthemPriority");

	-- Also track how long until the shortest remaining time
	-- is below the anthem cooldown threshold.
	-- We should call RecalculateAnthemPriority() at that time,
	-- if it hasn't been called by then.
	local shortestRemainingTimeSet = false;
	local anthemCooldownPlusBufferSeconds = self:GetAnthemCooldownSeconds();
	local shortestRemainingTime = anthemCooldownPlusBufferSeconds;
	for i = 1, #anthemPriority do
		-- Note: while (prioritySkill == nil) will loop forever if we don't find a priority skill.
		-- This if statement allows for finding no priority skill.
		if (prioritySkill == nil) then
			local anthemIndex = anthemPriority[i];
			local localizedAnthemName = AnthemsForPrioritySelection[anthemIndex];

			if (IsAnthemTrained[localizedAnthemName]) then
				-- Then go through the Anthem priority queue
				-- for each one, check if it's trained.
				-- If it is, check if its effect is not present or will expire soon
				-- If this is true, set it as the new shortcut.

				local remainingTime = AnthemSkillRemainingTimes[localizedAnthemName];
				local isExpired = remainingTime <= 0;
				local notEnoughTimeForOtherAnthem = remainingTime < anthemCooldownPlusBufferSeconds;
				local pairedAnthem = self:GetPairedAnthem(localizedAnthemName);
				local pairedAnthemIsTrained = false;
				local pairedAnthemIsExpired = false;
				if (pairedAnthem ~= nil) then
					pairedAnthemIsTrained = IsAnthemTrained[pairedAnthem];
					pairedAnthemIsExpired = AnthemSkillRemainingTimes[pairedAnthem] <= 0;
				end
				local isPairedAnthemTrainedAndNotExpired =
					(not pairedAnthemIsTrained) or
					(pairedAnthemIsTrained and not pairedAnthemIsExpired);

				--Turbine.Shell.WriteLine(localizedAnthemName .. ": isExpired: " .. dump(isExpired) .. ", notEnough: " .. dump(notEnoughTimeForOtherAnthem) .. ", is...: " .. dump(isPairedAnthemTrainedAndNotExpired));
				if (isExpired or
				    (notEnoughTimeForOtherAnthem and isPairedAnthemTrainedAndNotExpired) ) then
					prioritySkill = localizedAnthemName;
				end

				if (not isExpired and
					((remainingTime < shortestRemainingTime) or
					 (not shortestRemainingTimeSet))) then
					shortestRemainingTime = remainingTime;
					shortestRemainingTimeSet = true;
				end

			end
		end
	end

	-- We should recheck the priority queue when
	-- the shortest anthem crosses the cooldown threshold.
	if (shortestRemainingTime > anthemCooldownPlusBufferSeconds) then
		local excessCooldownTime = shortestRemainingTime - anthemCooldownPlusBufferSeconds;
		self.nextAnthemBelowCooldownTime = currentTime + excessCooldownTime;
		self.window:SetWantsUpdates(true);
	end

	if (prioritySkill) then
		local data = SkillIds[prioritySkill];
		self.anthemPriorityShortcut:SetData(data);
		self.anthemPriorityQuickslot:SetShortcut(self.anthemPriorityShortcut);
		self.anthemPriorityQuickslot:SetVisible(self.AnthemPriorityUsed);
	else
		self.anthemPriorityQuickslot:SetVisible(false);
	end
end

---Treat a skill as if it is an ActiveSkill
---@return ActiveSkill #Information about an active/trained skill
function GetActiveSkill(skill)
	return skill;
end

function BuffWindow:AnthemResetTimeChanged(sender, args)
	-- sender is nill if character has no anthems trained.
	-- For instance, they are too low level, or their trait trees have been reset.
	if (sender == nil) then return; end

	-- Turbine.Shell.WriteLine("BuffWindow:AnthemResetTimeChanged()");
	local activeSkill = GetActiveSkill(sender);
	local anthemCooldownSeconds = activeSkill:GetCooldown();
	local anthemResetTime = activeSkill:GetResetTime();
	self:SetAnthemCooldownSecondsAndResetTime(anthemCooldownSeconds, anthemResetTime);
end

function BuffWindow:UpdateTrainedAnthems()
	-- Turbine.Shell.WriteLine("BuffWindow:UpdateTrainedAnthems()");
	local trainedSkills = LocalPlayer:GetTrainedSkills();
	local trainedSkillsCount = trainedSkills:GetCount();

	-- Start by assuming each anthem is not trained:
	ResetTrainedAnthems();

	local newAnthemTimesFound = false;
	local newCooldownSeconds = self.anthemCooldownSeconds;
	local newAnthemResetTime = self.anthemResetTime;

	for i=1, trainedSkillsCount do
		local skill = GetActiveSkill(trainedSkills:GetItem(i));
		local skillInfo = skill:GetSkillInfo();
		local skillName = skillInfo:GetName();

		if (IsAnthemTrained[skillName] ~= nil) then
			--Turbine.Shell.WriteLine("Found an anthem! \"" .. skillName .. "\"");

			-- Mark it as trained:
			IsAnthemTrained[skillName] = true;

			-- Grab possibly updated information:
			if (not newAnthemTimesFound) then
				newAnthemTimesFound = true;
				newCooldownSeconds = skill:GetCooldown();
				newAnthemResetTime = skill:GetResetTime();
			end

			if (AnAnthem == nil) then
				AnAnthem = skill;
				AnAnthem.ResetTimeChanged = function(sender, args) self:AnthemResetTimeChanged(sender, args); end
			end
		else
			--Turbine.Shell.WriteLine("\"" .. skillName .. "\" is not an anthem");
		end
	end

	self:SetAnthemCooldownSecondsAndResetTime(newCooldownSeconds, newAnthemResetTime);

end

function BuffWindow:ChatReceived(sender, args)
    if (args.ChatType == Turbine.ChatType.Advancement) then
		self:HandleAdvancementChat(args.Message);
    end
end

function BuffWindow:HandleAdvancementChat(message)
	-- Looking for something like "You have acquired the Class Trait:"
	-- Once we see it, don't bother checking for 5 seconds.
	local currentTime = Turbine.Engine.GetGameTime();
	if (currentTime >= self.nextAdvancementChannelHandleTime) then
		-- It's been long enough, start parsing chat:
		if (string.find(message, _LANG.CHAT.ADVANCEMENT_TRAIT_ACQUIRED)) then
			self.nextAdvancementChannelHandleTime = currentTime + 5;
			self.nextUpdateTrainedAnthemsTime = currentTime + 5;
			self.window:SetWantsUpdates(true);
		end
	end

end

function BuffWindow:GetAnthemCooldownSeconds()
	local cooldownPlusBuffer = self.anthemCooldownSeconds + self.anthemCooldownBufferSeconds;
	return cooldownPlusBuffer;
end

function BuffWindow:UpdateAnthemPriorityUsed()
	self.AnthemPriorityUsed = self.settings:GetSetting("AnthemPriorityUsed");
	self.anthemPriorityQuickslot:SetVisible(self.AnthemPriorityUsed);
	mbMain:SetBuffWindowWantsChats(self.AnthemPriorityUsed);

	-- Todo: Update background image
end

function BuffWindow:UpdateAnthemOverlayUsed()
	self.AnthemOverlayUsed = self.settings:GetSetting("AnthemOverlayUsed");

	local visible = self:GetWindowVisible();
	self.overlayWindow:SetVisible(visible and self.AnthemOverlayUsed);
	-- We only need the ZOrder = -1 workaround if the overlay window is in use.
	if (self.AnthemOverlayUsed) then
		self.window:SetZOrder(-1);
	else
		self.window:SetZOrder(0);
	end
end
