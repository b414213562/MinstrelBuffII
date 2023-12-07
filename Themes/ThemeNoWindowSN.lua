ThemeNoWindowSN = class();

ThemePath7 = ThemesPath .. "7 No Window SN/";

function ThemeNoWindowSN:Constructor()
	self.name = "No Window - Single line"; -- Name of the theme
	
	-- The whole window.
	self.windowBackground = ThemePath7 .. "minstrel_buffbar_background_1line.tga"; -- The background for the window. Use it, when you have a combined picture of ballads and anthems. Can be nil for no image.
	self.windowBackgroundHarmony = nil; -- The background for the window in harmony stance. Use it, when you have a combined picture of ballads and anthems. Can be nil for no image.
	self.windowBackgroundWarSpeech = nil; -- The background for the window in war speech stance. Use it, when you have a combined picture of ballads and anthems. Can be nil for no image.
	self.windowWidth = 356; -- The size of the window.
	self.windowHeight = 50; -- The size of the window.

	-- More than 3 Anthem support
	self.supportsExtraAnthems = true;
	self.windowBackgrounds = {};
	self.windowBackgrounds[3] = ThemePath7 .. "minstrel_buffbar_background_1line_anthems_3.tga";
	self.windowBackgrounds[4] = ThemePath7 .. "minstrel_buffbar_background_1line_anthems_4.tga";
	self.windowBackgrounds[5] = ThemePath7 .. "minstrel_buffbar_background_1line_anthems_5.tga";
	self.windowBackgrounds[6] = ThemePath7 .. "minstrel_buffbar_background_1line_anthems_6.tga";
	
	-- Ballad images
	self.balladBackground = nil; -- The background for the ballad area. Can be nil for no image.
	self.balladPosX = 0; -- The position for the ballad area relative to the window.
	self.balladPosY = 0; -- The position for the ballad area relative to the window.
	self.balladWidth = 0; -- The size of the ballad area.
	self.balladHeight = 0; -- The size of the ballad area.
	self.balladEffectStartX = 2; -- The first ballad image starts here. Relative to the window.
	self.balladEffectSpaceX = 39; -- The space between the ballad images from the left (must include the width).
	self.balladEffectY = 10; -- The ballad images space from top. Relative to the window.
	self.balladEffectWidth = 28; -- The size of the ballad images.
	self.balladEffectHeight = 28; -- The size of the ballad images.

	-- Anthem images
	self.showAnthems = true; -- Enables or disables anthem handling. If true, all other anthem-settings are ignored.
	self.fixedAnthems = false; -- If true, the anthems have fixed positions (order is set in MinstrelEffects.lua and for all themes the same).
	self.anthemBackground = nil; -- The background for the anthem area. Can be nil for no image.
	self.anthemBackgroundHarmony = nil; -- The background for the anthem area in harmony stance. Can be nil for the standard image.
	self.anthemBackgroundWarSpeech = nil; -- The background for the anthem area in war speech stance. Can be nil for the standard image.
	self.anthemBorder = nil; -- The background for the anthem border. Can be nil for no image. Only used, when fixedAnthems is true.
	self.anthemPosX = 0; -- The position for the anthem area relative to the window.
	self.anthemPosY = 0; -- The position for the anthem area relative to the window.
	self.anthemWidth = 0; -- The size of the anthem area.
	self.anthemHeight = 0; -- The size of the anthem area.
	self.anthemEffectStartX = 119; -- The first anthem image starts here. Relative to the window.
	self.anthemEffectSpaceX = 40; -- The space between the anthem images from the left (must include the width).
	self.anthemEffectY = 1; -- The anthem images space from top relative to the window.
	self.anthemEffectWidth = 36; -- The size of the anthem images.
	self.anthemEffectHeight = 36; -- The size of the anthem images.
	
	-- Anthem timers
	self.anthemTimeStartX = 120; -- The first anthem timer starts here. Relative to the window
	self.anthemTimeSpaceX = 40; -- The space between the anthem timers from the left (must include the width).
	self.anthemTimeY = 42; -- The anthem timer space from top relative to the window.
	self.anthemTimeWidth = 34; -- The size of the anthem timer.
	self.anthemTimeHeight = 5; -- The size of the anthem timer.

	-- Priority anthem
	self.priorityAnthemX = 235;
	self.priorityAnthemY = 0;

	-- Combat timer
	self.combatTimerX = 120;
	self.combatTimerY = 51;
	self.combatTimerHeight = 3;
	self.combatTimerWidth = 114;

end