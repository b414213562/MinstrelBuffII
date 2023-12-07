
ThemeNoteFixedAnthems = class();

ThemePath10 = ThemesPath .. "10 Note Fixed Anthems/";

function ThemeNoteFixedAnthems:Constructor()
	self.name = "Note Theme - Small fixed anthems"; -- Name of the theme
	
	-- The whole window.
	self.windowBackground = nil; -- The background for the window. Use it, when you have a combined picture of ballads and anthems. Can be nil for no image.
	self.windowWidth = 198; -- The size of the window.
	self.windowHeight = 114; -- The size of the window.

	-- Ballad images
	self.balladBackground = ThemesPath .. "mb_ballad_background.tga"; -- The background for the ballad area. Can be nil for no image.
	self.balladPosX = 0; -- The position for the ballad area relative to the window.
	self.balladPosY = 0; -- The position for the ballad area relative to the window.
	self.balladWidth = 155; -- The size of the ballad area.
	self.balladHeight = 67; -- The size of the ballad area.
	self.balladEffectStartX = 39; -- The first ballad image starts here. Relative to the window.
	self.balladEffectSpaceX = 39; -- The space between the ballad images from the left (must include the width).
	self.balladEffectY = 18; -- The ballad images space from top. Relative to the window.
	self.balladEffectWidth = 28; -- The size of the ballad images.
	self.balladEffectHeight = 28; -- The size of the ballad images.

	-- Anthem images
	self.showAnthems = true; -- Enables or disables anthem handling. If true, all other anthem-settings are ignored.
	self.fixedAnthems = true; -- If true, the anthems have fixed positions (order is set in MinstrelEffects.lua and for all themes the same).
	self.anthemBackground = ThemePath10 .. "mb_anthem_background_fixed.tga"; -- The background for the anthem area. Can be nil for no image.
	self.anthemBorder = ThemesPath .. "mb_anthem_border_small.tga"; -- The background for the anthem border. Can be nil for no image. Only used, when fixedAnthems is true.
	self.anthemPosX = 0; -- The position for the anthem area relative to the window.
	self.anthemPosY = 67; -- The position for the anthem area relative to the window.
	self.anthemWidth = 279; -- The size of the anthem area.
	self.anthemHeight = 48; -- The size of the anthem area.
	self.anthemEffectStartX = 39; -- The first anthem image starts here. Relative to the window.
	self.anthemEffectSpaceX = 39; -- The space between the anthem images from the left (must include the width).
	self.anthemEffectY = 71; -- The anthem images space from top relative to the window.
	self.anthemEffectWidth = 28; -- The size of the anthem images.
	self.anthemEffectHeight = 28; -- The size of the anthem images.
	
	-- Anthem timers
	self.anthemTimeStartX = 41; -- The first anthem timer starts here. Relative to the window
	self.anthemTimeSpaceX = 39; -- The space between the anthem timers from the left (must include the width).
	self.anthemTimeY = 106; -- The anthem timer space from top relative to the window.
	self.anthemTimeWidth = 24; -- The size of the anthem timer.
	self.anthemTimeHeight = 6; -- The size of the anthem timer.

	-- Priority anthem
	self.priorityAnthemX = 155;
	self.priorityAnthemY = 14;

	-- Combat timer
	self.combatTimerX = 38;
	self.combatTimerY = 118;
	self.combatTimerHeight = 3;
	self.combatTimerWidth = 143;

end