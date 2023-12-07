import "CubePlugins.MinstrelBuffII.Border";

-- Soliloquy of Sprit
soliloquyOfSpiritIcon = 0x410E3A1F;

-- Inner Strength - Tier 1, Inner Strength - Tier 2, Inner Strength - Tier 3
innerStrengthIcon = 0x41155210; -- 1091916304

maxSoliloquyOfSpirits = 3;
maxInnerStrengthTier = 3;
soliloquyOfSpiritDurationSeconds = 45;
innerStrengthDurationSeconds = 30;

rowBackOpacity = 0.40;
-- Color(opacity, red, green, blue)
rowBackColorGood = Turbine.UI.Color(rowBackOpacity, 0.0, 0.0, 0.0);
rowBackColorMissingSoliloquy = Turbine.UI.Color(rowBackOpacity, 1.0, 1.0, 0.0);
rowBackColorMissingInnerStrength = Turbine.UI.Color(rowBackOpacity, 1.0, 0.0, 0.0);

rowCloseButtonWidth    = 16;
rowCloseButtonHeight   = rowCloseButtonWidth;
rowCloseButtonNormal   = 0x41000196;
rowCloseButtonRollover = 0x41000198;
rowColesButtonPressed  = 0x41000197;

SoliloquyTrackerRow = class(Turbine.UI.Control);

function SoliloquyTrackerRow:GetPartyEntity()
    if (self.patientName == LocalPlayer:GetName()) then
        return LocalPlayer;
    end

    local party = LocalPlayer:GetParty();
    if (party == nil) then return nil; end

    local count = party:GetMemberCount();
    for i=1, count do
        local member = party:GetMember(i);
        if (member:GetName() == self.patientName) then
            return member;
        end
    end

    return nil;
end

-- Note: We're not using LocalPlayer:GetTarget(), this is 
-- a recipient determined through Combat chat parsing.
-- recipientTarget sounds more annoying to type.
-- patientName recommended by Chromite :D
function SoliloquyTrackerRow:Constructor(patientName, isInCombat, soliloquyWindow)
    Turbine.UI.Control.Constructor(self);
    self.patientName = patientName;
    self.window = soliloquyWindow;
    self.isInCombat = isInCombat;

    -- Be wide enough for 3 Soliloquy of Spirit and 1 Inner Strength
    -- with X pixels between each icon, and Y pixels border to left and right
    local leftRightBorderPixels = 4;
    local marginBetweenIconPixels = 2;
    local iconWidth = 32;
    local controlWidth = leftRightBorderPixels * 2 + iconWidth * 4 + marginBetweenIconPixels * 3;

    -- Be tall enough for the name, the inner strength tier dots, and the icons
    local topBottomBorderPixels = 4;
    local nameHeight = 20;
    local nameIconMargin = 3;
    local innerStrengthTierSpace = 5;
    local iconHeight = 32;
    local aboveTimerMargin = 2;
    local timerHeight = 5;
    local controlHeight = 
        topBottomBorderPixels * 2 + nameHeight + nameIconMargin + 
        innerStrengthTierSpace + iconHeight + aboveTimerMargin + timerHeight;

    self:SetBackColor(rowBackColorGood);

    self:SetSize(controlWidth, controlHeight);
    self:SetMouseVisible(false);

    local borderThickness = 2;
    local borderColor = Turbine.UI.Color.White;
    self.border = Border(self, borderThickness, borderColor);
    self.border:SetVisible(self:IsTarget());

    -- Make an EntityControl if the target is in our party:
    self.entityControl = nil;
    local entity = self:GetPartyEntity();
    if (entity ~= nil) then
        self.entityControl = Turbine.UI.Lotro.EntityControl();
        self.entityControl:SetParent(self);
        self.entityControl:SetEntity(entity);
        self.entityControl:SetSize(controlWidth, controlHeight);
        self.entityControl:SetMouseVisible(true);
        self.entityControl:SetSelectionEnabled(true);
        self.entityControl:SetContextMenuEnabled(true); -- what does this do?
    end

    local playerNameLabel = Turbine.UI.Label();
    playerNameLabel:SetParent(self);
    playerNameLabel:SetSize(controlWidth, nameHeight);
    playerNameLabel:SetLeft(5);
    playerNameLabel:SetFont(Turbine.UI.Lotro.Font.TrajanPro20);
    if (self.entityControl == nil) then
        playerNameLabel:SetText("- " .. patientName);
    else
        playerNameLabel:SetText(patientName);
    end
    playerNameLabel:SetMouseVisible(false);

    -- Create Icons and Timers for each of the three Soliloquy of Sprits:
    self.soliloquyOfSpritIcons = { };
    self.soliloquyOfSpritTimers = { };

    local y = topBottomBorderPixels + nameHeight + innerStrengthTierSpace;
    for i = 1, maxSoliloquyOfSpirits do
        -- Create Icons:
        local x = 
            leftRightBorderPixels + 
            (i - 1) * (marginBetweenIconPixels + iconWidth);
        self.soliloquyOfSpritIcons[i] = Turbine.UI.Control();
        self.soliloquyOfSpritIcons[i]:SetParent(self);
        self.soliloquyOfSpritIcons[i]:SetPosition(x, y);
        self.soliloquyOfSpritIcons[i]:SetVisible(false);
        self.soliloquyOfSpritIcons[i]:SetSize(iconWidth, iconHeight);
        self.soliloquyOfSpritIcons[i]:SetBackground(soliloquyOfSpiritIcon);
        self.soliloquyOfSpritIcons[i]:SetMouseVisible(false);

        -- Create Timer:
        self.soliloquyOfSpritTimers[i] = CubePlugins.MinstrelBuffII.TimerControl()
        self.soliloquyOfSpritTimers[i]:SetParent(self);
        self.soliloquyOfSpritTimers[i]:SetPosition(x, y + iconHeight + aboveTimerMargin);
        self.soliloquyOfSpritTimers[i]:SetVisible(false);
        self.soliloquyOfSpritTimers[i]:SetTimerSize(iconWidth, timerHeight);
        self.soliloquyOfSpritTimers[i]:SetMouseVisible(false);
        self.soliloquyOfSpritTimers[i]:SetDuration(soliloquyOfSpiritDurationSeconds);
        self.soliloquyOfSpritTimers[i].TimerElapsed = function() self:SoliloquyTimerElapsed(i); end
    end

    -- Create ticks for Inner Strength Tier:
    local x = 
        leftRightBorderPixels + 
        maxSoliloquyOfSpirits * (marginBetweenIconPixels + iconWidth);

    -- UI looks like: - - -
    self.innerStrengthTiers = {};
    for i = 1, maxInnerStrengthTier do
        self.innerStrengthTiers[i] = Turbine.UI.Control();
        self.innerStrengthTiers[i]:SetParent(self);
        self.innerStrengthTiers[i]:SetPosition(x + (i-1)*(9+2), y - innerStrengthTierSpace);
        self.innerStrengthTiers[i]:SetSize(9, 3);
        self.innerStrengthTiers[i]:SetBackColor(Turbine.UI.Color.White);
        self.innerStrengthTiers[i]:SetVisible(false);
        self.innerStrengthTiers[i]:SetMouseVisible(false);
    end

    -- Create Icon for the Inner Strength:
    self.innerStrengthIcon = Turbine.UI.Control();
    self.innerStrengthIcon:SetParent(self);
    self.innerStrengthIcon:SetPosition(x, y);
    self.innerStrengthIcon:SetVisible(false);
    self.innerStrengthIcon:SetSize(iconWidth, iconHeight);
    self.innerStrengthIcon:SetBackground(innerStrengthIcon);
    self.innerStrengthIcon:SetMouseVisible(false);

    -- Create Inner Strength Timer:
    self.innerStrengthTimer = CubePlugins.MinstrelBuffII.TimerControl()
    self.innerStrengthTimer:SetParent(self);
    self.innerStrengthTimer:SetPosition(x, y + iconHeight + aboveTimerMargin);
    self.innerStrengthTimer:SetVisible(false);
    self.innerStrengthTimer:SetTimerSize(iconWidth, timerHeight);
    self.innerStrengthTimer:SetMouseVisible(false);
    self.innerStrengthTimer:SetDuration(innerStrengthDurationSeconds);
    self.innerStrengthTimer.TimerElapsed = function() self:InnerStrengthTimerElapsed(); end
    self.innerStrengthTimer.WarningPercent = 0.25;
    self.innerStrengthWarned = false;
    self.innerStrengthTimer.WarningElapsed = function()
        self.innerStrengthWarned = true;
        self:UpdateUI();
    end

    self.soliloquyOfSpiritCount = 0;
    self.soliloquyOfSpiritStartTimes = {};
    self.innerStrengthTier = 0;

    -- Make a 'close' button:
    self.closeButton = Turbine.UI.Control();
    self.closeButton:SetParent(self);
    self.closeButton:SetBackground(rowCloseButtonNormal);
    self.closeButton:SetLeft(controlWidth - rowCloseButtonWidth);
    self.closeButton:SetSize(rowCloseButtonWidth, rowCloseButtonHeight);
    self.closeButton:SetBlendMode(Turbine.UI.BlendMode.AlphaBlend);
    self.closeButton.MouseClick = function()
        -- Get rid of this row in a way that keeps it gone for this combat
        local ignorePlayer = true;
        self:RemoveRow(ignorePlayer);
    end
    self.closeButton.MouseEnter = function()
        self.closeButton:SetBackground(rowCloseButtonRollover);
    end
    self.closeButton.MouseDown = function()
        self.closeButton:SetBackground(rowColesButtonPressed);
    end
    self.closeButton.MouseUp = function()
        self.closeButton:SetBackground(rowCloseButtonRollover);
    end
    self.closeButton.MouseLeave = function()
        self.closeButton:SetBackground(rowCloseButtonNormal);
    end
    self.closeButton:SetZOrder(0x7FFFFFFF); -- Most on-top we can get

    self:HandleSoliloquy(self.patientName);
end

function SoliloquyTrackerRow:IsTarget()
    local target = LocalPlayer:GetTarget();
    if (target ~= nil) then
        return target:GetName() == self.patientName;
    end
    return false;
end

-- returns true if handled, false if not
function SoliloquyTrackerRow:DidHandleSoliloquy(patientName)
    if (self.patientName == patientName) then
        self:HandleSoliloquy(patientName);

        return true;
    end

    return false;
end

function SoliloquyTrackerRow:HandleTargetChanged(targetName)
    local shouldBorderBeVisible = (targetName == self.patientName);
    self.border:SetVisible(shouldBorderBeVisible);
end

function SoliloquyTrackerRow:HandleSoliloquy(patientName)
    local currentTime = Turbine.Engine.GetGameTime();

    -- If next spot = max then:
    if (self.soliloquyOfSpiritCount == maxSoliloquyOfSpirits) then
        -- Shift each entry left by one
        -- e.g.     [10 seconds ago], [15 seconds ago], [20 seconds ago]
        -- becomes: [15 seconds ago], [20 seconds ago], [nil]
        for i=1, maxSoliloquyOfSpirits - 1 do
            self.soliloquyOfSpiritStartTimes[i] = self.soliloquyOfSpiritStartTimes[i+1];
        end
    end

    -- increment next spot
    if (self.soliloquyOfSpiritCount < maxSoliloquyOfSpirits) then
        self.soliloquyOfSpiritCount = self.soliloquyOfSpiritCount + 1
    end

    -- put new time in next spot
    self.soliloquyOfSpiritStartTimes[self.soliloquyOfSpiritCount] = currentTime;

    -- Inner Strength:
    --   increase the tier (max 3)
    --   restart the timer (30 seconds)
    if (self.innerStrengthTier < 3) then
        self.innerStrengthTier = self.innerStrengthTier + 1;
    end
    self.innerStrengthTimerStartTime = currentTime;

    self.innerStrengthWarned = false;

    self:UpdateUI();
end

function SoliloquyTrackerRow:UpdateUI()
    local count = self.soliloquyOfSpiritCount;

    for i = 1, count do
        self.soliloquyOfSpritIcons[i]:SetVisible(true);
        self.soliloquyOfSpritTimers[i]:SetStartTime(
            self.soliloquyOfSpiritStartTimes[i]);
        self.soliloquyOfSpritTimers[i]:SetVisible(true);
        self.soliloquyOfSpritTimers[i]:Resume();
    end

    for i = count + 1, maxSoliloquyOfSpirits do
        self.soliloquyOfSpritIcons[i]:SetVisible(false);
        self.soliloquyOfSpritTimers[i]:SetVisible(false);
        self.soliloquyOfSpritTimers[i]:Pause();
    end

    local showInnerStrength = self.innerStrengthTier > 0;
    if (showInnerStrength) then
        self.innerStrengthTimer:SetStartTime(
            self.innerStrengthTimerStartTime);
        self.innerStrengthTimer:Resume();
    else
        self.innerStrengthTimer:Pause();
    end

    for i = 1, maxInnerStrengthTier do
        self.innerStrengthTiers[i]:SetVisible(self.innerStrengthTier >= i);
    end
    
    self.innerStrengthIcon:SetVisible(showInnerStrength);
    self.innerStrengthTimer:SetVisible(showInnerStrength);

    if (self.innerStrengthTier < maxInnerStrengthTier or
        self.innerStrengthWarned) then
        self:SetBackColor(rowBackColorMissingInnerStrength);
    elseif (count < maxSoliloquyOfSpirits) then
        self:SetBackColor(rowBackColorMissingSoliloquy);
    else
        self:SetBackColor(rowBackColorGood);
    end
end

function SoliloquyTrackerRow:SoliloquyTimerElapsed(timerIndex)
    -- examples

    -- 5 0 25 
    -- timerIndex = 2
    -- move 3 to 2

    -- 0 5 25
    -- timerIndex = 1
    -- move 2 to 1
    -- move 3 to 2

    -- 0
    -- timerIndex = 1
    -- just decrement count

    -- decrement how many effects there are
    if (self.soliloquyOfSpiritCount > 0) then
        self.soliloquyOfSpiritCount = self.soliloquyOfSpiritCount - 1
    end

    -- We need to move each soliloquyOfSpiritStartTimes over by one
    for i=timerIndex, maxSoliloquyOfSpirits - 1 do
        self.soliloquyOfSpiritStartTimes[i] = self.soliloquyOfSpiritStartTimes[i+1];
    end

    self:UpdateUI();
    self:CheckForRowFinished();
end

function SoliloquyTrackerRow:InnerStrengthTimerElapsed()
    self.innerStrengthTier = 0;
    self:UpdateUI();
    self:CheckForRowFinished();
end

function SoliloquyTrackerRow:HandleCombatChanged(isInCombat)
    self.isInCombat = isInCombat;
    self:CheckForRowFinished();
end

function SoliloquyTrackerRow:CheckForRowFinished()
    local isInCombat = self.isInCombat;
    local timersExpired = 
        self.soliloquyOfSpiritCount == 0 and 
        self.innerStrengthTier == 0;
    local rowFinished = timersExpired and not isInCombat;

    if (rowFinished and self.window ~= nil) then
        local ignorePlayer = false;
        self:RemoveRow(ignorePlayer);
    end
end

function SoliloquyTrackerRow:RemoveRow(ignorePlayer)
    local window = self.window;
    self.window = nil;

    if (self.entityControl ~= nil) then
        self.entityControl:SetParent(nil);
        self.entityControl:SetEntity(nil);
    end

    self.border:Detach();
    self.border = nil;

    window:RemoveSoliloquyRow(self, ignorePlayer);
end
