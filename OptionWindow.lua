import "Turbine.UI.Lotro"

SHOW_DEBUG_OPTIONS = false;

ListItemUnselected = Turbine.UI.Color( 1, 0.3, 0.3, 0.3 );
ListItemSelected = Turbine.UI.Color( 1, 0.4, 0.4, 0.4 );
ListBoxBackground = ListItemUnselected; -- this was Turbine.UI.Color( 0.2, 0.2, 0.2 )

OptionWindow = class(Turbine.UI.Lotro.Window);

function OptionWindow:Constructor(settings)
	Turbine.UI.Lotro.Window.Constructor(self);

	self.settings = settings;
	self:SetPosition( 200, 200 );
	self:SetText("MinstrelBuff - Options");
	self:SetSize( 270, 400 );
	self:SetVisible(false);

	self.control = Turbine.UI.Control();
	local height = 680 + 300; -- base plus Anthem priority
	if (SHOW_DEBUG_OPTIONS) then
		height = height + 200;
	end
	self.control:SetSize( 270, height );
	self:PlaceControls(self.control);
end

function OptionWindow:GetOptionControl()
	return self.control;
end

function OptionWindow:MakeOptionCheckbox(parent, y, optionName)
    local checkbox = Turbine.UI.Lotro.CheckBox();
    checkbox:SetParent(parent);
    checkbox:SetText(_LANG.OPTIONS[optionName]);
    checkbox:SetPosition( 20, y );
    checkbox:SetSize( 230, 25 );
    checkbox:SetChecked(self.settings:GetSetting(optionName));
    checkbox.CheckedChanged = function (sender, args)
        self.settings:SetSetting(
            optionName,
            checkbox:IsChecked());
    end
	return checkbox;
end

function OptionWindow:AddAnthemPriorityControl(parent, y)
	local anthemPriorityLabel = Turbine.UI.Label();
	anthemPriorityLabel:SetParent(parent);
	anthemPriorityLabel:SetSize(150, 20);
	anthemPriorityLabel:SetPosition(20, y);
	anthemPriorityLabel:SetText("Anthem Priority:"); -- note: needs localization
	y = y + 20;

	local anthemRowHeight = 34;
	local anthemCount = 7;
	local anthemListHeight = anthemRowHeight * anthemCount;
	self.anthemPriorityListBox = Turbine.UI.ListBox();
    self.anthemPriorityListBox:SetParent(parent);
	self.anthemPriorityListBox:SetBackColor( ListBoxBackground );
    self.anthemPriorityListBox:SetPosition(20, y);
    self.anthemPriorityListBox:SetSize(OptionsAnthemPriorityListBoxWidth, anthemListHeight);
	y = y + anthemListHeight + 10;

	local order = self.settings:GetSetting("AnthemPriority");
	for i = 1, #order do
		local anthemIndex = order[i];
		local localizedAnthemName = AnthemsForPrioritySelection[anthemIndex];

		local listItemRow = Turbine.UI.Control();
		listItemRow:SetSize(460, anthemRowHeight);
		listItemRow.AnthemIndex = anthemIndex;

		local skillIcon = Turbine.UI.Control();
		skillIcon:SetParent(listItemRow);
		skillIcon:SetSize(32, 32);
		skillIcon:SetPosition(2, 1);
		skillIcon:SetBackground(SkillIcons[localizedAnthemName]);

        local listItemLabel = Turbine.UI.Label();
		listItemLabel:SetParent(listItemRow);
        listItemLabel:SetText(localizedAnthemName);
		listItemLabel:SetLeft(36);
        listItemLabel:SetSize(460, anthemRowHeight);
        listItemLabel:SetTextAlignment(Turbine.UI.ContentAlignment.MiddleLeft);

		self.anthemPriorityListBox:AddItem(listItemRow);
	end
	self:ColorListBoxIndex(self.anthemPriorityListBox);
	self.anthemPriorityListBox.SelectedIndexChanged = function (sender, args)
		self:AnthemPriorityChanged(sender);
		self:UpdatePriorityButtonsEnabled();
	end

	-- Up / Down buttons:
	-- note: Needs localization

	self.upButton = Turbine.UI.Lotro.Button();
	self.upButton:SetParent(parent);
	self.upButton:SetSize(75, 25);
	self.upButton:SetPosition(20, y);
	self.upButton:SetText("Up");
	self.upButton.Click = function(sender, args)
		local oldIndex = self.anthemPriorityListBox:GetSelectedIndex();
		local newIndex = oldIndex - 1;

		-- Don't try to move the topmost item up.
		if (oldIndex <= 1) then return; end

		self:SwapListBoxItems(self.anthemPriorityListBox, oldIndex, newIndex);
		self:UpdatePriorityButtonsEnabled();
		self:SaveAnthemPriorityOrder();
	end

	self.downButton = Turbine.UI.Lotro.Button();
	self.downButton:SetParent(parent);
	self.downButton:SetSize(75, 25);
	self.downButton:SetPosition(100, y);
	self.downButton:SetText("Down");
	self.downButton.Click = function(sender, args)
		local oldIndex = self.anthemPriorityListBox:GetSelectedIndex();
		local newIndex = oldIndex + 1;

		-- Don't try to move the bottommost item down.
		if (newIndex > self.anthemPriorityListBox:GetItemCount()) then return; end

		self:SwapListBoxItems(self.anthemPriorityListBox, oldIndex, newIndex);
		self:UpdatePriorityButtonsEnabled();
		self:SaveAnthemPriorityOrder();
	end
	y = y + 25;

	return y;
end

function OptionWindow:UpdatePriorityButtonsEnabled()
	local index = self.anthemPriorityListBox:GetSelectedIndex();
	local itemCount = self.anthemPriorityListBox:GetItemCount();

	local firstItemIndex = 1;
	local lastItemIndex = itemCount;

	-- Default to enabled
	local isUpEnabled = true;
	local isDownEnabled = true;

	-- If first item is selected, disable up
	if (index <= firstItemIndex) then
		isUpEnabled = false;
	-- If last item is selected, disable down
	elseif (index >= lastItemIndex) then
		isDownEnabled = false;
	end

	self.upButton:SetEnabled(isUpEnabled);
	self.downButton:SetEnabled(isDownEnabled);
end

function OptionWindow:SwapListBoxItems(listBox, oldIndex, newIndex)
	-- Swap the settings values using a temporary variable?

	-- Swap two list items
	local tempListItem = listBox:GetItem(oldIndex);
	listBox:RemoveItemAt(oldIndex);
	listBox:InsertItem(newIndex, tempListItem);

	-- Selection is lost when items are added / removed.
	-- Reselect the new location.
	self.anthemPriorityListBox:SetSelectedIndex(newIndex);
end

function OptionWindow:PlaceControls(parent)
	-- Combat Visibility
	self.combatVisibleCheckBox = self:MakeOptionCheckbox(parent, 40, "EffectWindowOnlyVisibleInCombat");

	-- Theme options
	local themeLabel = Turbine.UI.Label();
	themeLabel:SetPosition( 20, 70 );
	themeLabel:SetSize( 230, 20 );
	themeLabel:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
	themeLabel:SetText(_LANG.OPTIONS.ThemeIndex);
	themeLabel:SetParent(parent);
	
	local themeList = self.settings:GetThemeList();
	local themeIndex = self.settings:GetThemeIndex();
	local themeCount = #themeList;
	
	self.listBox = Turbine.UI.ListBox();
	self.listBox:SetParent( parent );
	self.listBox:SetBackColor( ListBoxBackground );
	self.listBox:SetPosition( 20, 100 );
	self.listBox:SetSize( 230, 20 * themeCount );

	for i = 1, themeCount do
		local listItem = Turbine.UI.Label();
		listItem:SetSize( 230, 20 );
		listItem:SetTextAlignment( Turbine.UI.ContentAlignment.MiddleLeft );
		listItem:SetText(themeList[i].name);
		self.listBox:AddItem( listItem );
	end
	self.listBox:SetSelectedIndex(themeIndex);
	self:ColorListBoxIndex(self.listBox);
	self.listBox.SelectedIndexChanged = function (sender, args) self:ThemeChanged(sender); end

	local y = 100 + 20 * themeCount + 20;

	-- Anthem Priority Used?
	self.anthemPriorityUsedCheckBox = self:MakeOptionCheckbox(parent, y, "AnthemPriorityUsed");
	y = y + 40;

	-- Add the control for anthem priority:
	y = self:AddAnthemPriorityControl(parent, y);

	-- Soliloquy Visibility
	self.soliloquyVisibleCheckBox = self:MakeOptionCheckbox(parent, y, "SolilquyWindowUsed");
	y = y + 40;

	-- Checking for Serious Business
	self.seriousBusinessCheckbox = self:MakeOptionCheckbox(parent, y, "CheckForSeriousBusiness");
    y = y + 40;

	-- Show War-Speech Timers:
	self.showWarSpeechTimersCheckbox = self:MakeOptionCheckbox(parent, y, "ShowWarSpeechTimers");
    y = y + 40;

    -- Show Melodic Interlude Window:
    self.showMelodicInterludeCheckbox = self:MakeOptionCheckbox(parent, y, "ShowMelodicInterlude");
    y = y + 40;

	-- Anthem Overlay Used?
	self.anthemOverlayUsedCheckBox = self:MakeOptionCheckbox(parent, y, "AnthemOverlayUsed");
	y = y + 40;

	-- Size of Melodic Interlude Window:
	local screenWidth = Turbine.UI.Display:GetWidth(); -- e.g. 1920

	local mainWindowProportionalWidth = self.settings:GetSetting("MainWindowWidth"); -- e.g. 0.026 (2.6%)
	local mainWindowActualWidth = mainWindowProportionalWidth * screenWidth; -- e.g. 2.6% * 1920 = ~50 (49.92)

	local mainWindowDefaultWidth = BuffWindow.GetDefaultWidth(); -- e.g. 100
	local mainWindowScaledWidth = mainWindowActualWidth / mainWindowDefaultWidth; -- e.g. 49.92 / 100 = 50%
	-- scollbar is using integer values between 5 and 100 to represent 0.5 to 10.0.
	-- Multiply here:
	local mainScalingScrollbarValue = mainWindowScaledWidth * 10;

	-- Label for the Main Window (BuffWindow) scaling scrollbar
	self.mainScalingScrollbarLabel = Turbine.UI.Label();
	self.mainScalingScrollbarLabel:SetParent(parent);
	self.mainScalingScrollbarLabel:SetSize(300, 25);
	self.mainScalingScrollbarLabel:SetText(string.format(_LANG.OPTIONS["MainWindowWidth"], mainWindowScaledWidth));
	self.mainScalingScrollbarLabel:SetPosition(20, y);
	y = y + 20;

	-- Scrollbar to adjust the Main Window scaling
	self.mainScalingScrollbar = Turbine.UI.Lotro.ScrollBar();
	self.mainScalingScrollbar:SetParent(parent);
	self.mainScalingScrollbar:SetOrientation(Turbine.UI.Orientation.Horizontal);
	self.mainScalingScrollbar:SetSize(200, 10);
	self.mainScalingScrollbar:SetPosition(20, y);
	self.mainScalingScrollbar:SetMinimum(5);
	self.mainScalingScrollbar:SetMaximum(100);
	self.mainScalingScrollbar:SetValue(mainScalingScrollbarValue);
	self.mainScalingScrollbar.ValueChanged = function(sender, args)
		local currentValue = self.mainScalingScrollbar:GetValue(); -- e.g. 32
		local scaledValue = currentValue / 10; -- 3.2x

		-- practical minimum: 1x = 32x32, in 1920 x 1080 => 32/1920 = about 1.6%
		-- practical maximum: 10x = 320x320, about 16%

		self.mainScalingScrollbarLabel:SetText(string.format(_LANG.OPTIONS["MainWindowWidth"], scaledValue));

		local screenWidth = Turbine.UI.Display:GetWidth();
		local actualWidth = scaledValue * BuffWindow.GetDefaultWidth();
		local proportinalWidth = actualWidth / screenWidth;
		self.settings:SetSetting("MainWindowWidth", proportinalWidth);
		mbMain.BuffWindow:Redraw();
	end
	y = y + 25;

	-- Size of Melodic Interlude Window:
	local miWindowProportionalWidth = self.settings:GetSetting("MelodicInterludeWidth"); -- e.g. 0.026 (2.6%)
	local miWindowActualWidth = miWindowProportionalWidth * screenWidth; -- e.g. 2.6% * 1920 = ~50 (49.92)

	local miWindowDefaultWidth = MelodicInterludeWindow.GetDefaultWidth(); -- e.g. 100
	local miWindowScaledWidth = miWindowActualWidth / miWindowDefaultWidth; -- e.g. 49.92 / 100 = 50%
	-- scollbar is using integer values between 5 and 100 to represent 0.5 to 10.0.
	-- Multiple here:
	local miScalingScrollbarValue = miWindowScaledWidth * 10;
	
	-- Label for the Melodic Interlude window scaling scrollbar
    self.melodicInterludeScalingScrollbarLabel = Turbine.UI.Label();
    self.melodicInterludeScalingScrollbarLabel:SetParent(parent);
    self.melodicInterludeScalingScrollbarLabel:SetSize(300, 25);
    self.melodicInterludeScalingScrollbarLabel:SetText(string.format(_LANG.OPTIONS["MelodicInterludeWidth"], miWindowScaledWidth));
    self.melodicInterludeScalingScrollbarLabel:SetPosition(20, y);
	y = y + 20;

    -- Scrollbar to adjust Melodic Interlude window size
    self.melodicInterludeScalingScrollbar = Turbine.UI.Lotro.ScrollBar();
    self.melodicInterludeScalingScrollbar:SetParent(parent);
    self.melodicInterludeScalingScrollbar:SetOrientation(Turbine.UI.Orientation.Horizontal);
    self.melodicInterludeScalingScrollbar:SetSize(200, 10);
    self.melodicInterludeScalingScrollbar:SetPosition(20, y);
    self.melodicInterludeScalingScrollbar:SetMinimum(5);
    self.melodicInterludeScalingScrollbar:SetMaximum(100);
    self.melodicInterludeScalingScrollbar:SetValue(miScalingScrollbarValue);
    self.melodicInterludeScalingScrollbar.ValueChanged = function(sender, args)
        local currentValue = self.melodicInterludeScalingScrollbar:GetValue(); -- e.g. 32
        local scaledValue = currentValue / 10; -- 3.2x

        -- practical minimum: 1x = 32x32, in 1920 x 1080 => 32/1920 = about 1.6%
        -- practical maximum: 10x = 320x320, about 16%

        self.melodicInterludeScalingScrollbarLabel:SetText(string.format(_LANG.OPTIONS["MelodicInterludeWidth"], scaledValue));

		local screenWidth = Turbine.UI.Display:GetWidth();
		local actualWidth = scaledValue * MelodicInterludeWindow.GetDefaultWidth();
		local proportinalWidth = actualWidth / screenWidth;
		self.settings:SetSetting("MelodicInterludeWidth", proportinalWidth);
        mbMain.MelodicInterludeWindow:Redraw();
    end
	y = y + 25;



	y = y + 20; -- Space the Debug Options out more.
	if (SHOW_DEBUG_OPTIONS) then
		self.debugSectionLabel = Turbine.UI.Label();
		self.debugSectionLabel:SetParent(parent);
		self.debugSectionLabel:SetSize(200, 30);
		self.debugSectionLabel:SetPosition(20, y);
		self.debugSectionLabel:SetText("Debug Options");
		y = y + 30;

		self.debugClearBalladsButton = Turbine.UI.Lotro.Button();
		self.debugClearBalladsButton:SetParent( parent );
		self.debugClearBalladsButton:SetPosition(20, y);
		self.debugClearBalladsButton:SetSize(150, 20);
		self.debugClearBalladsButton:SetText("Clear Ballads");
		self.debugClearBalladsButton.Click = function(sender, args)
			DEBUG_IGNORE_BALLAD_EFFECTS = true;
			mbMain:RefreshEffectDisplay();
			DEBUG_IGNORE_BALLAD_EFFECTS = false;
		end
		y = y + 30;

		self.debugEnterCombatButton = Turbine.UI.Lotro.Button();
		self.debugEnterCombatButton:SetParent(parent);
		self.debugEnterCombatButton:SetPosition(20, y);
		self.debugEnterCombatButton:SetSize(150, 20);
		self.debugEnterCombatButton:SetText("Enter Combat");
		self.debugEnterCombatButton.Click = function(sender, args)
			local isInCombat = true;
			mbMain:HandleCombatChanged(isInCombat);
		end
		y = y + 30;

		self.debugExitCombatButton = Turbine.UI.Lotro.Button();
		self.debugExitCombatButton:SetParent(parent);
		self.debugExitCombatButton:SetPosition(20, y);
		self.debugExitCombatButton:SetSize(150, 20);
		self.debugExitCombatButton:SetText("Exit Combat");
		self.debugExitCombatButton.Click = function(sender, args)
			local isInCombat = false;
			mbMain:HandleCombatChanged(isInCombat);
		end
		y = y + 30;

		self.debugDetectMelodicInterludeStart = Turbine.UI.Lotro.Button();
		self.debugDetectMelodicInterludeStart:SetParent(parent);
		self.debugDetectMelodicInterludeStart:SetPosition(20, y);
		self.debugDetectMelodicInterludeStart:SetSize(200, 20);
		self.debugDetectMelodicInterludeStart:SetText("Start Melodic Interlude");
		self.debugDetectMelodicInterludeStart.Click = function(sender, args)
			local mock = self:GetDebugEffect("Melodic Interlude");
			mbMain:EffectAdded(nil, mock);
		end
		y = y + 30;

		self.debugDetectMelodicInterludeStop = Turbine.UI.Lotro.Button();
        self.debugDetectMelodicInterludeStop:SetParent(parent);
        self.debugDetectMelodicInterludeStop:SetPosition(20, y);
        self.debugDetectMelodicInterludeStop:SetSize(200, 20);
        self.debugDetectMelodicInterludeStop:SetText("Stop Melodic Interlude");
        self.debugDetectMelodicInterludeStop.Click = function(sender, args)
			local mock = self:GetDebugEffect("Melodic Interlude");
			mbMain:EffectRemoved(nil, mock);
        end
        y = y + 30;


	end

end

function OptionWindow:GetDebugEffect(effectName)
	local mock = {
		Effect = {
			GetName = function() return effectName; end
		};
	};
	return mock;
end

function OptionWindow:Show()
	self:SetVisible(true);
end

function OptionWindow:ThemeChanged(sender)
	self:ColorListBoxIndex(sender);
	self.settings:SetThemeIndex(sender:GetSelectedIndex());	
end

function OptionWindow:AnthemPriorityChanged(sender)
	self:ColorListBoxIndex(sender);
end

function OptionWindow:ColorListBoxIndex(sender)
	for i = 1, sender:GetItemCount() do
		local listItem = sender:GetItem(i);
		if (i == sender:GetSelectedIndex()) then
			listItem:SetBackColor( ListItemSelected );
		else
			listItem:SetBackColor( ListItemUnselected );
		end
	end
end

-- Expected output: A table that looks like this:
-- {
--   [1] = 7;
--   [2] = 2;
--   ...
--   [7] = 3;
-- }
function OptionWindow:GetAnthemPriorityOrder()
	local anthemPriorityList = { };
	for i = 1, self.anthemPriorityListBox:GetItemCount() do
		local listItem = self.anthemPriorityListBox:GetItem(i);
		local anthemPriority = listItem.AnthemIndex;
		table.insert(anthemPriorityList, anthemPriority);
	end
	return anthemPriorityList;
end

function OptionWindow:SaveAnthemPriorityOrder()
	local order = self:GetAnthemPriorityOrder();
	self.settings:SetSetting("AnthemPriority", order);
end