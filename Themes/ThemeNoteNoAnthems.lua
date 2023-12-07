ThemeNoteNoAnthems = class();

ThemePath6 = ThemesPath .. "6 Note No Anthems/";

function ThemeNoteNoAnthems:Constructor()
	self.name = "Note Theme - No anthems"; -- Name of the theme
	
	-- The whole window.
	self.windowBackground = nil; -- The background for the window. Use it, when you have a combined picture of ballads and anthems. Can be nil for no image.
	self.windowBackgroundHarmony = nil; -- The background for the window in harmony stance. Use it, when you have a combined picture of ballads and anthems. Can be nil for no image.
	self.windowBackgroundWarSpeech = nil; -- The background for the window in war speech stance. Use it, when you have a combined picture of ballads and anthems. Can be nil for no image.
	self.windowWidth = 200; -- The size of the window.
	self.windowHeight = 70; -- The size of the window.

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
	self.showAnthems = false; -- Enables or disables anthem handling. If true, all other anthem-settings are ignored.
	self.fixedAnthems = false; -- If true, the anthems have fixed positions (order is set in MinstrelEffects.lua and for all themes the same).
	self.anthemBackground = nil; -- The background for the anthem area. Can be nil for no image.
	self.anthemBackgroundHarmony = nil; -- The background for the anthem area in harmony stance. Can be nil for the standard image.
	self.anthemBackgroundWarSpeech = nil; -- The background for the anthem area in war speech stance. Can be nil for the standard image.
	self.anthemBorder = nil; -- The background for the anthem border. Can be nil for no image. Only used, when fixedAnthems is true.
	self.anthemPosX = 0; -- The position for the anthem area relative to the window.
	self.anthemPosY = 0; -- The position for the anthem area relative to the window.
	self.anthemWidth = 0; -- The size of the anthem area.
	self.anthemHeight = 0; -- The size of the anthem area.
	self.anthemEffectStartX = 0; -- The first anthem image starts here. Relative to the window.
	self.anthemEffectSpaceX = 0; -- The space between the anthem images from the left (must include the width).
	self.anthemEffectY = 0; -- The anthem images space from top relative to the window.
	self.anthemEffectWidth = 0; -- The size of the anthem images.
	self.anthemEffectHeight = 0; -- The size of the anthem images.
	
	-- Anthem timers
	self.anthemTimeStartX = 0; -- The first anthem timer starts here. Relative to the window
	self.anthemTimeSpaceX = 0; -- The space between the anthem timers from the left (must include the width).
	self.anthemTimeY = 0; -- The anthem timer space from top relative to the window.
	self.anthemTimeWidth = 0; -- The size of the anthem timer.
	self.anthemTimeHeight = 0; -- The size of the anthem timer.

	-- Priority anthem
	self.priorityAnthemX = 155;
	self.priorityAnthemY = 14;

	-- Combat timer
	self.combatTimerX = 38;
	self.combatTimerY = 50;
	self.combatTimerHeight = 3;
	self.combatTimerWidth = 107;
end