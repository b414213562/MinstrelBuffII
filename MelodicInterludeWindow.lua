import "Turbine.UI";
import "Turbine.UI.Lotro";

import "CubePlugins.MinstrelBuffII.DragBar";


MelodicInterludeWindow = class(Turbine.UI.Window);

function MelodicInterludeWindow:Constructor(settings)
    Turbine.UI.Window.Constructor(self);

    local timerHeight = 8;

    self.settings = settings;
    self:SetPosition(self.settings:GetWindowPosition("MelodicInterlude"));
    self:SetSize(
        MelodicInterludeWindow.GetDefaultWidth(),
        MelodicInterludeWindow.GetDefaultHeight());
    self:SetBackColor(Turbine.UI.Color.Green);
    self:SetWantsKeyEvents(true);
    self.KeyDown = function(sender, args) self:ProcessKeyDown(sender, args); end

    self.locked = true; -- UI Elements cannot be repositioned
    self.dragBar = CubePlugins.MinstrelBuffII.DragBar(
        self,
        _LANG.WINDOW.MELODIC_INTERLUDE_TITLE);
    self.dragBar:SetBarOnTop(true);
    self.dragBar:SetBarVisible(false);
    self.dragBar:SetDraggable(false);
    self.SizeChanged = function(sender, args)
        self.dragBar:Layout();
    end

    self.hidden = false; -- true if HUD is hidden
    self.shown = false; -- true if Melodic Interlude is active

    local shortcutTypeSkill = 6;
    local raiseTheSpiritData = "0x70003E7B";
    local chordOfSalvationData = "0x7000BC01";

    -- Notes on skill IDs:
    -- Raise the Spirit: 70003E7B or 700299B6 ?
    -- Raise my Spirit: 700299B8 -- does not work

    -- Chord of Salvation: 7000BC01
    -- Improved Chord of Salvation: 70029888 or 700299BD?
    -- Chord of My Salvation: 700299BF
    -- Improved Chord of My Salvation: 700299BC -- does not work

    self.raiseTheSpiritShortcut = Turbine.UI.Lotro.Shortcut(shortcutTypeSkill, raiseTheSpiritData);

    self.raiseTheSpiritQuickslot = Turbine.UI.Lotro.Quickslot();
    self.raiseTheSpiritQuickslot:SetParent(self);
    self.raiseTheSpiritQuickslot:SetSize(36, 36);
    self.raiseTheSpiritQuickslot:SetPosition(2, 2);
    self.raiseTheSpiritQuickslot:SetShortcut(self.raiseTheSpiritShortcut);
    self.raiseTheSpiritQuickslot:SetAllowDrop(false);

    self.chordOfSalvationShortcut = Turbine.UI.Lotro.Shortcut(shortcutTypeSkill, chordOfSalvationData);
    
    self.chordOfSalvationQuickslot = Turbine.UI.Lotro.Quickslot();
    self.chordOfSalvationQuickslot:SetParent(self);
    self.chordOfSalvationQuickslot:SetSize(36, 36);
    self.chordOfSalvationQuickslot:SetPosition(42, 2);
    self.chordOfSalvationQuickslot:SetShortcut(self.chordOfSalvationShortcut);
    self.chordOfSalvationQuickslot:SetAllowDrop(false);

    self.melodicInterludeTimeDisplay = CubePlugins.MinstrelBuffII.TimerControl()
	self.melodicInterludeTimeDisplay:SetParent(self);
	self.melodicInterludeTimeDisplay:SetPosition( 0, self:GetHeight() - timerHeight );
	self.melodicInterludeTimeDisplay:SetVisible(false);
	self.melodicInterludeTimeDisplay:SetTimerSize(self:GetWidth(), timerHeight);
	self.melodicInterludeTimeDisplay:SetDuration(10); -- Melodic Interlude always lasts 10 seconds
	self.melodicInterludeTimeDisplay:SetBackColor(Turbine.UI.Color.LightGreen);

    self:SetStretchMode(1);
    self:Redraw();
end

MelodicInterludeWindow.GetDefaultWidth = function()
    local leftMargin = 2;
    local iconWidth = 36;
    local spaceBetweenIcons = 4;
    local rightMarign = leftMargin + 2;

    local width = leftMargin + iconWidth * 2 + spaceBetweenIcons + rightMarign;
    return width;
end

MelodicInterludeWindow.GetDefaultHeight = function()
    return 50;
end

-- Override the default GetSize() so DragBar knows our scaled size.
function MelodicInterludeWindow:GetSize()
    if (self.stretchedWindowWidth ~= nil and 
        self.stretchedWindowHeight ~= nil) then
        return self.stretchedWindowWidth, self.stretchedWindowHeight;
    else
        return Turbine.UI.Control.GetSize(self);
    end
end

-- Scale the window based on the setting.
function MelodicInterludeWindow:Redraw()
    local displayWidth = Turbine.UI.Display:GetWidth();

    local defaultWidth = MelodicInterludeWindow.GetDefaultWidth();
    self.stretchedWindowWidth = displayWidth * self.settings:GetSetting("MelodicInterludeWidth");

    local defaultHeight = MelodicInterludeWindow.GetDefaultHeight();
    self.stretchedWindowHeight = (self.stretchedWindowWidth / defaultWidth) * defaultHeight;

    -- Stretch the window:
    self:SetSize(self.stretchedWindowWidth, self.stretchedWindowHeight);
    -- End stretch code
end

function MelodicInterludeWindow:ProcessKeyDown(sender, args)
    if (args.Action == KEY_ACTION_REPOSITION_UI) then
        -- lock / unlock the control for movement
		self:UiLocked(not self.locked);
    elseif (args.Action == KEY_ACTION_TOGGLE_HUD) then
        -- hide / show ui elements
        self:UiHidden(not self.hidden);
	end
end

function MelodicInterludeWindow:UiLocked(locked)
    self.locked = locked;
    local shouldDragBarBeActive = not self.locked and not self.hidden;
    self.dragBar:SetBarVisible(shouldDragBarBeActive);
    self.dragBar:SetDraggable(shouldDragBarBeActive);
    self:SetVisibility();

    if (locked) then
        self.settings:SetWindowPosition("MelodicInterlude", self:GetPosition());
    end
end

function MelodicInterludeWindow:UiHidden(hidden)
    self.hidden = hidden;
    self:SetVisibility();
end

function MelodicInterludeWindow:SetVisibility()
	local isVisible =
        (not self.hidden) and
        (not self.locked or self.shown);
	self:SetVisible(isVisible);
end

-- Melodic Interlude functions, move down to other related functions
-- after merging with rework-effect-list-processing branch

function MelodicInterludeWindow:MelodicInterludeStart()
    self.shown = true;
    self:SetVisibility();

	local gameTime = Turbine.Engine.GetGameTime();
	self.melodicInterludeTimeDisplay:SetStartTime(gameTime);
	self.melodicInterludeTimeDisplay:SetVisible(true);
end

function MelodicInterludeWindow:MelodicInterludeStop()
    self.shown = false;
    self:SetVisibility();

	self.melodicInterludeTimeDisplay:SetStartTime(0);
	self.melodicInterludeTimeDisplay:SetVisible(false);
end

