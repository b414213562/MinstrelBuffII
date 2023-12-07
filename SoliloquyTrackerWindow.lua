
SoliloquyTrackerWindow = class(Turbine.UI.Window);

function SoliloquyTrackerWindow:Constructor(settings)
    Turbine.UI.Window.Constructor(self);

    self.settings = settings;
    self.used = self.settings:GetSetting("SolilquyWindowUsed");
    self.isInWatcherOfResolve = self:IsInWatcherOfResolve();
    self.settings:AddCallback(
        "SolilquyWindowUsed",
        function()
            self.used = not self.used;
            self:UiHidden(self.used);
            self:EnableDisableChatMonitoring();
        end );

    self.isInCombat = false;

    local posx, posy = self.settings:GetWindowPosition("Soliloquy");

    self:SetSize(142, 1); -- Note: Get width from Row someday
    self:SetPosition(posx, posy);
    self:SetMouseVisible(false);
    self:SetWantsKeyEvents(true);
    self.KeyDown = function(sender, args)
        self:ProcessKeyDown(sender, args);
    end

    self.locked = true;
    self.dragBar = CubePlugins.MinstrelBuffII.DragBar(
        self,
        _LANG.WINDOW.DRAG_BAR_TITLE);

    self.dragBar:SetBarOnTop(true);
    self.dragBar:SetBarVisible(false);
    self.dragBar:SetDraggable(false);
    self.SizeChanged = function(sender, args)
        self.dragBar:Layout();
    end

    self.listBox = Turbine.UI.ListBox();
    self.listBox:SetParent(self);
    self.listBox:SetSize(self:GetSize());
    self.listBox:SetMouseVisible(false);

    self.ignorePlayer = { };

    LocalPlayer.TargetChanged = function(sender, args)
        local target = LocalPlayer:GetTarget();
        local targetName = nil;
        if (target ~= nil) then
            targetName = target:GetName();
        end
        self:HandleTargetChanged(targetName);
    end

    self:UiHidden(self.used);

    self:SetWantsUpdates(true);
end

-- Do anything that requires mbMain to be initialized:
function SoliloquyTrackerWindow:Update()
    self:SetWantsUpdates(false);

    self:EnableDisableChatMonitoring();
end

function SoliloquyTrackerWindow:IsInWatcherOfResolve()
    local skillList = LocalPlayer:GetTrainedSkills();
    for i=1, skillList:GetCount() do
        local item = skillList:GetItem(i);
        local name = item:GetSkillInfo():GetName();
        if (name == _LANG.CLASS.SOLILOQUY_OF_SPIRIT) then
            return true;
        end
    end
    return false;
end

function SoliloquyTrackerWindow:EnableDisableChatMonitoring()
    mbMain:SetSoliloquyTrackerWindowWantsChats(self.used);
end

---Gets a SoliloquyTrackerRow at the specified index.
---@param index number The index of the item to get.
---@return SoliloquyTrackerRow #The item at the specified index.
function SoliloquyTrackerWindow:GetRow(index)
    return self.listBox:GetItem(index);
end

-- If targetName is nil, then we clear the selection
-- If targetName is not nil, then we select a row if present
function SoliloquyTrackerWindow:HandleTargetChanged(targetName)
    local count = self.listBox:GetItemCount();
    for i = count, 1, -1 do
        local row = self:GetRow(i);
        row:HandleTargetChanged(targetName);
    end
end

function SoliloquyTrackerWindow:HandleCombatChanged(isInCombat)
    self.isInCombat = isInCombat;

    local count = self.listBox:GetItemCount();
    for i = count, 1, -1 do
        local row = self:GetRow(i);
        row:HandleCombatChanged(isInCombat);
    end

    if (isInCombat == true) then
        self.ignorePlayer = { };
    end
end

function SoliloquyTrackerWindow:UpdateSize(isAdded, rowWidth, rowHeight)
    -- Change window and listbox sizes:
    local windowWidth, windowHeight = self:GetSize();
    if (isAdded and (rowWidth > windowWidth)) then
        self:SetWidth(rowWidth);
        self.listBox:SetWidth(rowWidth);
    end

    local delta = rowHeight;
    if (not isAdded) then
        delta = -rowHeight;
    end

    self:SetHeight(windowHeight + delta);
    self.listBox:SetHeight(windowHeight + delta);
end

function SoliloquyTrackerWindow:AddPlayer(playerName)
    local row = CubePlugins.MinstrelBuffII.SoliloquyTrackerRow(playerName, self.isInCombat, self);
    if (playerName == LocalPlayer:GetName()) then
        self.listBox:InsertItem(1, row);
    else
        self.listBox:AddItem(row);
    end

    local isAdded = true;
    self:UpdateSize(isAdded, row:GetSize());
end

function SoliloquyTrackerWindow:ProcessKeyDown(sender, args)
    if (args.Action == KEY_ACTION_REPOSITION_UI) then
        -- lock / unlock the control for movement
        self:UiLocked(not self.locked);
    elseif (args.Action == KEY_ACTION_TOGGLE_HUD) then
        -- hide / show ui elements
        self:UiHidden(not self:IsVisible());
    end
end

function SoliloquyTrackerWindow:UiLocked(locked)
    local isVisibleOrDraggable = self.locked;
    self.locked = locked;
    self.dragBar:SetBarVisible(isVisibleOrDraggable);
    self:SetVisible(true);
    self.dragBar:SetDraggable(isVisibleOrDraggable);

    if (locked) then
        self.settings:SetWindowPosition("Soliloquy", self:GetPosition());
    end
end

function SoliloquyTrackerWindow:UiHidden(isVisible)
    local isUsedAndVisible = self.used and isVisible;
    self:SetVisible(isUsedAndVisible);
end

function SoliloquyTrackerWindow:AddSoliloquy(playerName)
    if (self.ignorePlayer[playerName] ~= nil) then
        return;
    end

    local count = self.listBox:GetItemCount();
    for i = 1, count do
        local row = self:GetRow(i);
        local didHandle = row:DidHandleSoliloquy(playerName);
        if (didHandle) then
            return;
        end
    end

    -- Adding a row automatically adds one (1) soliloquy
    self:AddPlayer(playerName);
end

function SoliloquyTrackerWindow:RemoveSoliloquyRow(row, ignorePlayer)
    -- Get row size
    local isAdded = false;
    local rowWidth, rowHeight = row:GetSize();

    -- shrink window size
    self:UpdateSize(isAdded, rowWidth, rowHeight)

    -- remove row from listBox
    self.listBox:RemoveItem(row);

    if (ignorePlayer) then
        self.ignorePlayer[row.patientName] = true;
    end
end

function SoliloquyTrackerWindow:CheckForSpecializationChanged(args)
    -- Specialization checking inspired by Exo's Auras plugin

    -- args.Message can be nil when you whisper someone who is offline
    -- and receive 'The player is offline.'
    if (args.Message == nil) then return; end

    local pattern = _LANG.CHAT.SPECIALIZATION_CHANGED;
    local newSpecialization = string.match(args.Message, pattern);
    if (newSpecialization ~= nil) then
        self.isInWatcherOfResolve = 
            newSpecialization == _LANG.CLASS.WATCHER_OF_RESOLVE;
    end
end

function SoliloquyTrackerWindow:CheckForSoliloquyOfSpirit(args)
    if args.ChatType == Turbine.ChatType.PlayerCombat then
        -- Affodil applied a benefit with Soliloquy of Spirit on Affodil.
        -- Affodil applied a benefit with Soliloquy of Spirit on Veldspaat.
        -- Affodil applied a critical benefit with Soliloquy of Spirit on Affodil.
        -- Affodil applied a benefit with Soliloquy of My Spirit on Affodil.
        local soliloquyApplied = _LANG.CHAT.SOLILOQUY_OF_SPIRIT_PATTERN;
        local message = GetRawText(args.Message);
        local playerName = string.match(message, soliloquyApplied);
        if (playerName ~= nil) then
            -- If the client is French and the minstrel is in Dissonance stance,
            -- Then don't include "personnel " in the name!
            -- (personnel comes at the end of the skill name, so it does not seem
            -- possible to handle this in the pattern.)
            if (clientLanguage == FR) then
                if (playerName:sub(1, 10) == "personnel ") then
                    playerName = playerName:sub(11);
                end
            end

            -- Call a function that adds a solilquy to an existing row
            -- or creates a new row.

            self:AddSoliloquy(playerName);
        end
    end
end

function SoliloquyTrackerWindow:ChatReceived(sender, args)
    if (args.ChatType == Turbine.ChatType.Advancement) then
        self:CheckForSpecializationChanged(args);
    elseif (
        (args.ChatType == Turbine.ChatType.PlayerCombat) and
        self.isInWatcherOfResolve) then 
        self:CheckForSoliloquyOfSpirit(args);
    end
end

-- This label is for stripping markup, do not touch!
getRawText = Turbine.UI.Label();
getRawText:SetMarkupEnabled(true);

function GetRawText(textWithMarkup)
    getRawText:SetText(textWithMarkup);
    return getRawText:GetText();
end
-- End stripping markup
