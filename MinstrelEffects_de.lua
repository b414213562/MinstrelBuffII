if (clientLanguage ~= DE) then return; end

---- German effect names ----
ValidBalladEffects = {
	["Bonusschaden bei Balladen"] = true,
	["Bonus für empfangene Heilung durch Balladen"] = true,
	["Balladenheilungs-Bonus"] = true,
	["Klagegesang"] = true, -- Auf dem Kriegsross
	["Gesang"] = true, -- Auf dem Kriegsross
	["Sage"] = true -- Auf dem Kriegsross
}

-- Anthem Effect Names
Anthem1LesserResonanceEffect = "Hymne I - Resonanz";
Anthem1GreaterCompassionEffect = "Hymne I - Mitgefühl";
Anthem1LesserAndGreaterEffect = "Hymne I - Resonanz und Mitgefühl";
Anthem2LesserDissonanceEffect = "Hymne II - Dissonanz";
Anthem2GreaterWarEffect = "Hymne II - Krieg";
Anthem2LesserAndGreaterEffect = "Hymne II - Dissonanz und Krieg";
Anthem3LesserComposureEffect = "Hymne III - Selbstbeherrschung";
Anthem3GreaterProwessEffect = "Hymne III - Tüchtigkeit";
Anthem3LesserAndGreaterEffect = "Hymne III - Selbstbeherrschung und Tüchtigkeit";
AnthemFreePeopleEffect = "Hymne der Freien Völker";

-- Anthem Skill Names
Anthem1LesserResonanceSkill = "Kleine Hymne I - Resonanz";
Anthem1GreaterCompassionSkill = "Große Hymne I - Mitgefühl";
Anthem2LesserDissonanceSkill = "Kleine Hymne II - Dissonanz ";
Anthem2GreaterWarSkill = "Große Hymne II - Krieg";
Anthem3LesserComposureSkill = "Kleine Hymne III - Selbstbeherrschung";
Anthem3GreaterProwessSkill = "Große Hymne III - Tüchtigkeit";
AnthemFreePeopleSkill = "Hymne der Freien Völker";

-- Based on the longest Anthem skill name in this locale:
OptionsAnthemPriorityListBoxWidth = 330;

ValidAnthemEffects = {
	-- War-steed:
	["Hymnen der Rohirrim"] = 1,
	["Hymne der Morgenröte"] = 2,
	["Hymne der Riddermark"] = 3,
	-- 2022 Minstrel Revamp:
	[Anthem1LesserResonanceEffect] = 1,  -- In blauer Traitlinie
	[Anthem1GreaterCompassionEffect] = 1,
	[Anthem1LesserAndGreaterEffect] = 1,
	[Anthem2LesserDissonanceEffect] = 2, -- In roter Traitlinie
	[Anthem2GreaterWarEffect] = 2,
	[Anthem2LesserAndGreaterEffect] = 2,
	[Anthem3LesserComposureEffect] = 3,			  -- In gelber Traitlinie
	[Anthem3GreaterProwessEffect] = 3,
	[Anthem3LesserAndGreaterEffect] = 3,
	[AnthemFreePeopleEffect] = 4,
}

ValidPersonalAnthemEffects = {
	["Persönliche Hymne - Resonanz"] = true,
	["Persönliche Hymne - Dissonanz"] = true,
}

Lesser = "L";
Greater = "G";
LesserAndGreater = "L+G";

AnthemOverlays = {
	["Hymne des Dritten Zeitalters - Resonanz"] = Lesser,
	["Hymne des Mitgefühls"] = Greater,
	["Anthem I - Resonance and Compassion"] = LesserAndGreater,
	["Hymne des Dritten Zeitalters - Dissonanz"] = Lesser,
	["Hymne des Krieges"] = Greater,
	["Anthem II - Dissonance and War"] = LesserAndGreater,
	["Hymne der Selbstbeherrschung"] = Lesser,
	["Hymne der Tüchtigkeit"] = Greater,
	["Anthem III - Composure and Prowess"] = LesserAndGreater,
	["Hymne der Freien Völker"] = "",
};

ValidCodaSkillNames = {
	["Coda der Lebenskraft"] = true,                  -- Meta-Fertigkeit, in Haltung ersetzt
	["Coda der Melodie"] = true,                      -- In Haltung: Melodie
	["Coda der Resonanz"] = true,                     -- In Haltung: Resonanz
	["Coda der Wut"] = true,                          -- In Haltung: Dissonanz (Kriegsrede)
	["Coda der Eorlingas"] = true,                    -- Auf dem Kriegsross
	["Verbesserte Coda der Melodie"] = true,          -- In Haltung: Melodie
	["Verbesserte Coda der Resonanz"] = true,         -- In Haltung: Resonanz
	["Verbesserte Coda der Wut"] = true,              -- In Haltung: Dissonanz (Kriegsrede)
}

ValidCrySkillNames = {
	["Lied der Einheit"] = true, -- On War-steed
	["Schrei des Chors (Dissonanz)"] = true,
	["Schrei des Chors"] = true,
	["Schrei des Chors (Resonanz)"] = true,
	["Verbesserter Schrei des Chors (Dissonanz)"] = true,
	["Verbesserung: Schrei des Chors"] = true,
	["Verbesserter Schrei des Chors (Resonanz)"] = true,
}

ValidMajorBalladSkillNames = {
	["Balladenheilungs-Bonus"] = true,
}

ValidYellowTraitSkillNames = {
	["Hymne der Tüchtigkeit"] = true
}

ValidWarSpeechSkillNames = {
	["War-Speech"] = true;
};

ValidMelodicInterludeNames = {
	["Melodic Interlude"] = true;
};
