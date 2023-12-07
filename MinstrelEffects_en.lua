if (clientLanguage ~= EN) then return; end

-- Used for the ballads.
ValidBalladEffects = {

	["Ballad Damage Bonus"] = true,			-- Minor ballad
	["Ballad Incoming Healing Bonus"] = true,	-- Perfect ballad
	["Ballad Healing Bonus"] = true,		-- Major ballad
	["Dirge"] = true, -- On a war-steed		-- Discipline: Red Dawn
	["Saga"] = true, -- On a war-steed		-- Discipline: Rohirrim
	["Chant"] = true--, -- On a war-steed	-- Discipline: Riddermark
	--["Skills Bonus"] = true
}

-- Anthem Effect Names
Anthem1LesserResonanceEffect = "Anthem I - Resonance";
Anthem1GreaterCompassionEffect = "Anthem I - Compassion";
Anthem1LesserAndGreaterEffect = "Anthem I - Resonance and Compassion";
Anthem2LesserDissonanceEffect = "Anthem II - Dissonance";
Anthem2GreaterWarEffect = "Anthem II - War";
Anthem2LesserAndGreaterEffect = "Anthem II - Dissonance and War";
Anthem3LesserComposureEffect = "Anthem III - Composure";
Anthem3GreaterProwessEffect = "Anthem III - Prowess";
Anthem3LesserAndGreaterEffect = "Anthem III - Composure and Prowess";
AnthemFreePeopleEffect = "Anthem of the Free Peoples";

-- Anthem Skill Names
Anthem1LesserResonanceSkill = "Lesser Anthem I - Resonance";
Anthem1GreaterCompassionSkill = "Greater Anthem I - Compassion";
Anthem2LesserDissonanceSkill = "Lesser Anthem II - Dissonance ";
Anthem2GreaterWarSkill = "Greater Anthem II - War";
Anthem3LesserComposureSkill = "Lesser Anthem III - Composure";
Anthem3GreaterProwessSkill = "Greater Anthem III - Prowess";
AnthemFreePeopleSkill = "Anthem of the Free Peoples";

-- Based on the longest Anthem skill name in this locale:
OptionsAnthemPriorityListBoxWidth = 260;

-- Used for the anthems. The numbers sets the order in fixed themes.
--- This section updated based on 9/30/2018 post by Mines_ofMoria for release 22.2 ---
ValidAnthemEffects = {
	-- War-steed:
	["Anthem of the Rohirrim"] = 1,
	["Anthem of the Red Dawn"] = 2,
	["Anthem of the Riddermark"] = 3,
	-- 2022 Minstrel Revamp:
	[Anthem1LesserResonanceEffect] = 1,
	[Anthem1GreaterCompassionEffect] = 1,
	[Anthem1LesserAndGreaterEffect] = 1,
	[Anthem2LesserDissonanceEffect] = 2,
	[Anthem2GreaterWarEffect] = 2,
	[Anthem2LesserAndGreaterEffect] = 2,
	[Anthem3LesserComposureEffect] = 3,
	[Anthem3GreaterProwessEffect] = 3,
	[Anthem3LesserAndGreaterEffect] = 3,
	[AnthemFreePeopleEffect] = 4,
}

ValidPersonalAnthemEffects = {
	["Personal Anthem - Resonance"] = true,
	["Personal Anthem - Dissonance"] = true,
}

Lesser = "L";
Greater = "G";
LesserAndGreater = "L+G";

AnthemOverlays = {
	["Anthem I - Resonance"] = Lesser,
	["Anthem I - Compassion"] = Greater,
	["Anthem I - Resonance and Compassion"] = LesserAndGreater,
	["Anthem II - Dissonance"] = Lesser,
	["Anthem II - War"] = Greater,
	["Anthem II - Dissonance and War"] = LesserAndGreater,
	["Anthem III - Composure"] = Lesser,
	["Anthem III - Prowess"] = Greater,
	["Anthem III - Composure and Prowess"] = LesserAndGreater,
	["Anthem of the Free Peoples"] = "",
};

-- Used to recognize a coda
--- This section updated based on 10/8/2019 post by Bellom ---
ValidCodaSkillNames = {
	["Coda of the Eorlingas"] = true, -- In war speech stance
	["Coda of Vigour"] = true, -- In no stance and in harmony stance
	["Coda of Resonance"] = true,
	["Improved Coda of Resonance"] = true,
	["Improved Coda of Melody"] = true,
	["Improved Coda of Fury"] = true,
	["Coda of Melody"] = true,
	["Coda of Fury"] = true
}

-- Used to recognize a Cry of the Chorus
ValidCrySkillNames = {
	["Song of Unity"] = true, -- On War-steed
	["Cry of the Chorus (Dissonance)"] = true,
	["Cry of the Chorus (Melody)"] = true,
	["Cry of the Chorus (Resonance)"] = true,
	["Improved Cry of the Chorus (Dissonance)"] = true,
	["Improved Cry of the Chorus (Melody)"] = true,
	["Improved Cry of the Chorus (Resonance)"] = true,
}

-- Used to recognize a Major Ballad
ValidMajorBalladSkillNames = {
	["Major Ballad - Resonance"] = true,
}

-- Used to determine, that the player is in the yellow trait line.
ValidYellowTraitSkillNames = {
	["Anthem of Prowess"] = true
}

ValidWarSpeechSkillNames = {
	["War-Speech"] = true;
};

ValidMelodicInterludeNames = {
	["Melodic Interlude"] = true;
};
