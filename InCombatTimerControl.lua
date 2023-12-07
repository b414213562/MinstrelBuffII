import "Turbine.UI.Lotro"
import "CubePlugins.MinstrelBuffII.Class";
import "CubePlugins.MinstrelBuffII.TimerControl";

InCombatTimerControl = class(Turbine.UI.Control);

-- Design Notes:
-- 
-- LOTRO treats entering combat different based on if you were recently in combat
--   (your 9 second timer is still active) or not.
--
-- If you re-enter a combat state, you have to stay in it for 5 seconds
--   to actually restart the timer. However, if the timer expires during a too-short combat,
--   the timer does get refreshed.
--
-- Activating a ballad without being in combat (Resonance Major Ballad, Cry of the Chorus)
--   starts a new out of combat timer if one isn't running.
-- 

function InCombatTimerControl:Constructor()
    Turbine.UI.Control.Constructor(self);

    self.minimumCombatTime = 5;
    self.outOfCombatTime = 9;
    self.warningTime = self.outOfCombatTime - self.minimumCombatTime;
    self.combatMainColor = Turbine.UI.Color(1.0, 1.0, 1.0, 1.0);
    self.combatWarningColor = Turbine.UI.Color(1.0, 1.0, 1.0, 0.0);

    self.CombatActivated = false;
    self.CryOfTheChorusActivated = false;
    self.CryOfTheChorusTime = nil;
    self.MajorBalladActivated = false;
    self.MajorBalladTime = nil;
    self.PrimaryCombat = false;
    self.IsBelowMinimumTime = false;

    self.combatTimerControl = CubePlugins.MinstrelBuffII.TimerControl()
    self.combatInitialized = false;
    self.combatTimerControl:SetDuration(self.outOfCombatTime);
    self:SetCombatTimerWidth(0);

    self.secondaryCombatTimerControl = CubePlugins.MinstrelBuffII.TimerControl()
    self.secondaryInitialized = false;
    self.secondaryCombatTimerControl:SetRightToLeft(false);
    local secondaryBackColor = Turbine.UI.Color(1.0, 1.0, 0.0, 0.0);
    self.secondaryCombatTimerControl:SetBackColor(secondaryBackColor);
    self.secondaryCombatTimerControl:SetDuration(self.minimumCombatTime);

    -- If the plugin is loaded while combat is active, behave sensibly:
    if (LocalPlayer:IsInCombat()) then
        self:EnteringCombat();
    end
end

function InCombatTimerControl:InitializeCombatTimer()
    self.combatTimerControl:SetParent(self);
    self.combatInitialized = true;    
end

function InCombatTimerControl:InitializeSecondaryTimer()
    self.secondaryCombatTimerControl:SetParent(self);
    self.secondaryInitialized = true;
end

-- Wrapper functions around TimerControl-specific functions:

function InCombatTimerControl:SetPosition(x, y)
    Turbine.UI.Control.SetPosition(self, x, y);
end

function InCombatTimerControl:SetSize(width, height)
    Turbine.UI.Control.SetSize(self, width, height);
    self.combatTimerControl:SetTimerSize(width, height);
    self.secondaryCombatTimerControl:SetTimerSize(width, height);
end

function InCombatTimerControl:SetCombatTimerStartTime(time)
    if (not self.combatInitialized) then
        self:InitializeCombatTimer();
    end
    self.combatTimerControl:SetStartTime(time);
end

function InCombatTimerControl:ClearSecondaryTimer()
    self.secondaryCombatTimerControl:SetStartTime(nil);
end

function InCombatTimerControl:SetSecondaryTimerStartTime(time)
    -- We want the secondary bar to fill up the combat bar, and when they're the same length
    -- then combat is refreshed.

    -- For this we need two things:
    -- Adjust the length of the secondary bar to match the current position of the combat bar
    local secondaryWidth = self:GetWidth() * self.combatTimerControl:GetRemainingPercent();
    self.secondaryCombatTimerControl:SetTimerSize(secondaryWidth, self:GetHeight());

    -- Adjust the time of the secondary bar to match time remaining if it's less than 5 seconds   
    local combatTimerRuntime = self.enterCombatTime - self:GetCombatTimerStartTime();
    local remainingCombatTimerTime = self.outOfCombatTime - combatTimerRuntime;
    local adjustTime = 0;
    if (remainingCombatTimerTime < self.minimumCombatTime) then
        -- E.g. if there are 3 seconds left on the combat timer 
        --   and the normal secondary timer is 5 seconds,
        --   then we want to subtract the difference from the secondary start time 
        --   to shorten the overall remaining duration to match:
        adjustTime = self.minimumCombatTime - remainingCombatTimerTime;
    end
    -- Subtract how much bigger the minimum is than the needed to get a shorter duration.
    self.secondaryCombatTimerControl:SetDuration(self.minimumCombatTime - adjustTime);
    self.secondaryCombatTimerControl:SetStartTime(time);
end

function InCombatTimerControl:GetCombatTimerStartTime()
    return self.combatTimerControl:GetStartTime();
end

function InCombatTimerControl:GetCombatTimerDuration()
    return self.combatTimerControl:GetDuration();
end

function InCombatTimerControl:GetCombatTimerRemainingPercent()
    return self.combatTimerControl:GetRemainingPercent();
end

function InCombatTimerControl:GetSecondaryTimerRemainingPercent()
    return self.secondaryCombatTimerControl:GetRemainingPercent();
end

function InCombatTimerControl:SetCombatTimerWantsUpdates(wantsUpdates)
    -- This is an exception to the normal passthrough logic.
    -- If the combat timer is running, this should be visible too.
    -- If the combat timer is not running, neither should the secondary combat timer.
    self:SetWantsUpdates(wantsUpdates);
end

function InCombatTimerControl:GetCombatTimerWidth()
    return self.combatTimerControl:GetWidth();
end

function InCombatTimerControl:GetCombatTimerCurrentWidth()
    return self.combatTimerControl.TimerWidth;
end

function InCombatTimerControl:SetCombatTimerWidth(width)
    self.combatTimerControl:SetWidth(width);
end

function InCombatTimerControl:GetSecondaryTimerWidth()
    return self.secondaryCombatTimerControl:GetWidth();
end

function InCombatTimerControl:GetSecondaryTimerCurrentWidth()
    return self.secondaryCombatTimerControl.TimerWidth;
end

function InCombatTimerControl:SetSecondaryTimerWidth(width)
    self.secondaryCombatTimerControl:SetWidth(width);
end

--

function InCombatTimerControl:CryOfTheChorus()
    -- Cry of the Chorus should start a timer if:
    --  a) the player is not already in combat
    --  b) there is not already a combat countdown happening
    --  c) there is not already a major ballad countdown happening
    --  d) there is not already a cry of the chorus countdown happening
    if (not LocalPlayer:IsInCombat() and not self.CombatActivated and not self.MajorBalladActivated and not self.CryOfTheChorusActivated) then
        self.CryOfTheChorusActivated = true;
        self.CryOfTheChorusTime = Turbine.Engine.GetGameTime();
        self:SetCombatTimerStartTime(self.CryOfTheChorusTime);
        self:SetCombatTimerWantsUpdates(true);
    end
end

function InCombatTimerControl:MajorBallad()
    -- Major Ballad (Resonance) should start a timer if:
    --  a) the player is not already in combat
    --  b) there is not already a combat countdown happening
    --  c) there is not already a major ballad countdown happening
    --  d) there is not already a cry of the chorus countdown happening
    if (not LocalPlayer:IsInCombat() and not self.CombatActivated and not self.MajorBalladActivated and not self.CryOfTheChorusActivated) then
        self.MajorBalladActivated = true;
        self.MajorBalladTime = Turbine.Engine.GetGameTime();
        self:SetCombatTimerStartTime(self.MajorBalladTime);
        self:SetCombatTimerWantsUpdates(true);
    end
end

function InCombatTimerControl:EnteringCombat()
    self.enterCombatTime = Turbine.Engine.GetGameTime();

    -- This is a primary combat if:
    --  a) the combat timer is not currently running
    --  b) the major ballad timer is not currently running
    --  c) cry of the chorus is not currently running
    if (not self.CombatActivated and not self.MajorBalladActivated and not self.CryOfTheChorusActivated) then
        self.PrimaryCombat = true;
    else
        if (not self.secondaryInitialized) then
            self:InitializeSecondaryTimer()
        end
        self:SetSecondaryTimerStartTime(self.enterCombatTime);
    end

    -- When first initialized, the width is 0 to account for being visible outside of combat. Fix that here:
    if (self:GetCombatTimerWidth() == 0) then
        self:SetCombatTimerWidth(self:GetCombatTimerCurrentWidth());
    end

    -- either way we're going to want to process update messages:
    self:SetCombatTimerWantsUpdates(true);
end

function InCombatTimerControl:LeavingCombat()
    local leaveCombatTime = Turbine.Engine.GetGameTime();

    local isSecondaryCombatLongEnough = (leaveCombatTime - self.enterCombatTime) > self.minimumCombatTime;

    -- When leaving combat, the timer should reset if:
    --  a) this is a primary combat
    --  b) this is a secondary combat that lasted long enough
    --  c) this is a secondary combat that occured while the timer hit 0
    if (self.PrimaryCombat or isSecondaryCombatLongEnough or self.ranOverTime) then
        -- start the clock over again:
        self.CombatActivated = true;

        -- clear all three possible ways we could get here:
        self.PrimaryCombat = false;
        self:SetCombatTimerStartTime(leaveCombatTime);
        self.ranOverTime = false;
    end

    -- No matter what, stop the secondary combat timer:
    self:ClearSecondaryTimer();
end

function InCombatTimerControl:BalladEnded()
    -- if a ballad ended, it's because our out-of-combat timer expired.
    -- In case we didn't predict it correctly, cancel the combat timers.
    self:SetCombatTimerWidth(0);
    self.MajorBalladActivated = false;

    self:SetCombatTimerStartTime(0);
    self:ClearSecondaryTimer();
end

function InCombatTimerControl:Update()
    local currentTime = Turbine.Engine.GetGameTime();
    local combatStartTime = self:GetCombatTimerStartTime();
    local combatTimerTimePassed = 0;
    if (combatStartTime ~= nil) then
        combatTimerTimePassed = currentTime - self:GetCombatTimerStartTime();
    end

    -- Check some conditions:
    local hasCryTimedOut = self.CryOfTheChorusTime ~= nil and ((currentTime - self.CryOfTheChorusTime) >= 9);
    local shouldTurnOffCry = self.CryOfTheChorusActivated and hasCryTimedOut;

    local hasMajorBalladTimedOut = self.MajorBalladTime ~= nil and ((currentTime - self.MajorBalladTime) >= 9);
    local shouldTurnOffMajorBallad = self.MajorBalladActivated and hasMajorBalladTimedOut;

    local isPrimaryCombat = self.PrimaryCombat;
    local isSecondaryCombatLongEnough = 
        self.enterCombatTime ~= nil and 
        (not self.PrimaryCombat) and 
        ((currentTime - self.enterCombatTime) > self.minimumCombatTime);
    local isQualifyingCombat = LocalPlayer:IsInCombat() and (isPrimaryCombat or isSecondaryCombatLongEnough);

    local didTimeRunOut = self:GetCombatTimerStartTime() ~= nil and (combatTimerTimePassed > self:GetCombatTimerDuration());
    local didTimeRunOutWithCombatActive = didTimeRunOut and LocalPlayer:IsInCombat();

    -- Will be set to true if the timer bar should stop shrinking:
    local pauseTimer = false;

    -- Determine what timer state (if any) is happening:

    -- Is a qualifying combat underway, or are we in combat at the end of the timer?:
    if (isQualifyingCombat or didTimeRunOutWithCombatActive) then
        -- Combat overrides other timer sources:
        self.CryOfTheChorusActivated = false;
        self.MajorBalladActivated = false;

        -- We're in a combat state now:
        self.CombatActivated = true;

        -- As long as we're in a qualifying combat state, restart the 9 second timer.
        self:SetCombatTimerStartTime(currentTime);

        -- Let other logic know we ran over:
        if (didTimeRunOutWithCombatActive) then
            self.ranOverTime = true;
        end

        -- No matter what, stop the secondary combat timer:
        self:ClearSecondaryTimer();
    -- Was Cry of the Chorus active and just run out?
    elseif (shouldTurnOffCry) then
        self.CryOfTheChorusActivated = false;
        self:SetCombatTimerWantsUpdates(false);
    -- Was Major Ballad active and just run out?
    elseif (shouldTurnOffMajorBallad) then
        self.MajorBalladActivated = false;
        self:SetCombatTimerWantsUpdates(false);
    -- Are we in a possibly-qualifying combat but need to wait a bit?
    elseif (LocalPlayer:IsInCombat()) then
        -- Pause the timer to show we're waiting on a longer combat.
        pauseTimer = true;
        self.combatTimerControl:Pause();
    elseif (didTimeRunOut) then
        -- The combat timer just ran out:
        self.CombatActivated = false;
        self:SetCombatTimerWantsUpdates(false);
        self:CombatTimerExpired();
    end

    -- Change the combat timer color if we're below the secondary threshold.
    -- Being in combat past the end of the timer reset the timer.
    -- This helps the player know we've switched from needing 5 seconds to needing
    -- however much time is left.
    local changeToWarningColor = combatTimerTimePassed > self.warningTime;
    if (changeToWarningColor and not self.IsBelowMinimumTime and not pauseTimer) then
        self.IsBelowMinimumTime = true;
        self.combatTimerControl:SetBackColor(self.combatWarningColor);
    elseif (not changeToWarningColor and self.IsBelowMinimumTime) then
        self.IsBelowMinimumTime = false;
        self.combatTimerControl:SetBackColor(self.combatMainColor);
    end

    -- The bar should be counting down when:
    --   a) counting down after Cry of the Chorus while out of combat
    --   b) counting down after Major Ballad (Resonance) while out of combat
    --   c) counting down after leaving a qualifying combat:
    --      1) a primary combat that starts when the timer is not active
    --      2) a secondary combat that starts while the timer is running that lasts at least 5 seconds,
    --          or past the end of the existing timer
    -- It should pause while waiting to confirm if a secondary combat is long enough.
    if (pauseTimer) then
        local uiTimerWidth = math.max(0, self:GetSecondaryTimerRemainingPercent() * self:GetSecondaryTimerCurrentWidth());
        self:SetSecondaryTimerWidth(uiTimerWidth);
    else
        self.combatTimerControl:Resume();
        local uiTimerWidth = math.max(0, self:GetCombatTimerRemainingPercent() * self:GetCombatTimerCurrentWidth());
        self:SetCombatTimerWidth(uiTimerWidth);
    end

end
