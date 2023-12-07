import "Turbine.UI.Lotro"
import "CubePlugins.MinstrelBuffII.Class";

TimerControl = class(Turbine.UI.Control);

function TimerControl:Constructor()
	Turbine.UI.Control.Constructor(self);

	local backColor = Turbine.UI.Color(1.0, 1.0, 1.0, 1.0);
	self:SetBackColor(backColor);
	self.TimerWidth = 34;
	self:SetSize( self.TimerWidth, 10 );

	self.IsPaused = false;
	self.RightToLeft = true;
end

function TimerControl:SetWidth(width)
	if (not self.RightToLeft) then
		width = self.TimerWidth - width;
		-- Hide a "full" ltr bar:
		if (width >= self.TimerWidth) then
			width = 0;
		end
	end
    Turbine.UI.Control.SetWidth(self, width);
end

function TimerControl:SetTimerSize( width, height )
	self.TimerWidth = width;
	self:SetSize( self.TimerWidth, height );	
end

-- Properties
function TimerControl:SetStartTime(value)
	self.startTime = value;
	self:RefreshDisplayBehaviour();
end

function TimerControl:GetStartTime()
	return self.startTime;
end

function TimerControl:SetDuration(value)
	self.duration = value;
	self:RefreshDisplayBehaviour();
end

function TimerControl:GetDuration()
	return self.duration;
end

function TimerControl:SetRightToLeft(rtl)
	self.RightToLeft = rtl;
end

-- Functions
function TimerControl:GetRemainingPercent()
	local gameTime = Turbine.Engine.GetGameTime();
	if (self:GetStartTime() == nil or self:GetDuration() == nil) then
		return 0;
	end
    local elapsedTime = gameTime - self:GetStartTime();
    local percentComplete = elapsedTime / self:GetDuration();
	local remainingPercent = 1 - percentComplete;
	return remainingPercent;
end

function TimerControl:RefreshDisplayBehaviour()
	local remainingPercent = self:GetRemainingPercent();
	if (remainingPercent > 0) then
		self:SetWantsUpdates(true);
	end
	
end

function TimerControl:Update()
	if (self.IsPaused) then
		return;
	end

	local remainingPercent = self:GetRemainingPercent();
	self:SetWidth(remainingPercent * self.TimerWidth);
	
	-- Deactivate Update, when timer is elapsed.
	if (remainingPercent <= 0) then
		self:SetWantsUpdates(false);

		-- Call a callback function if it exists:
		if (self.TimerElapsed ~= nil) then self.TimerElapsed(); end
	end

	if (self.warned == false and
		self.WarningPercent ~= nil and 
		remainingPercent < self.WarningPercent) then
		self.warned = true;
		if (self.WarningElapsed ~= nil) then self.WarningElapsed(); end
	else
		self.warned = false;
	end

end

function TimerControl:Pause()
	if (self.IsPaused) then
		return;
	end

	self.IsPaused = true;
	self:SetWantsUpdates(false);
end

function TimerControl:Resume()
	if (not self.IsPaused) then
		return;
	end

	self.IsPaused = false;
	self:SetWantsUpdates(true);
end
