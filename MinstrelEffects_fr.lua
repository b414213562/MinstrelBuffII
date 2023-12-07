if (clientLanguage ~= FR) then return; end

---- French effect names ----
ValidBalladEffects = {
	["Bonus de dégâts de ballade"] = true,
	["Ballade - Bonus de soins reçus"] = true,
	["Bonus de guérison de ballade"] = true,
	["Chant funèbre"] = true,
	["Saga"] = true,
	["Chant"] = true
}

-- Anthem Effect Names
Anthem1LesserResonanceEffect = "Hymne I - Résonance";
Anthem1GreaterCompassionEffect = "Hymne I - Compassion";
Anthem1LesserAndGreaterEffect = "Hymne I - Résonance et compassion";
Anthem2LesserDissonanceEffect = "Hymne II - Dissonance";
Anthem2GreaterWarEffect = "Hymne II - Guerre";
Anthem2LesserAndGreaterEffect = "Hymne II - Dissonance et guerre";
Anthem3LesserComposureEffect = "Hymne III - Contenance";
Anthem3GreaterProwessEffect = "Hymne III - Prouesse";
Anthem3LesserAndGreaterEffect = "Hymne III - Contenance et prouesse";
AnthemFreePeopleEffect = "Hymne des Peuples Libres";

-- Anthem Skill Names
Anthem1LesserResonanceSkill = "Hymne faible I - Résonance";
Anthem1GreaterCompassionSkill = "Hymne fort I - Compassion";
Anthem2LesserDissonanceSkill = "Hymne faible II - Dissonance ";
Anthem2GreaterWarSkill = "Hymne fort II - Guerre";
Anthem3LesserComposureSkill = "Hymne faible III - Contenance";
Anthem3GreaterProwessSkill = "Hymne fort III - Prouesse";
AnthemFreePeopleSkill = "Hymne des Peuples Libres";

-- Based on the longest Anthem skill name in this locale:
OptionsAnthemPriorityListBoxWidth = 300;

ValidAnthemEffects = {
	-- War-steed:
	["Hymne de l'Aube rouge"] = 1,
	["Hymne du Riddermark"] = 2,
	["Hymne des Rohirrim"] = 3,
	-- 2022 Minstrel Revamp:
	[Anthem1LesserResonanceEffect] = 1,     -- ligne bleue
	[Anthem1GreaterCompassionEffect] = 1,
	[Anthem1LesserAndGreaterEffect] = 1,
	[Anthem2LesserDissonanceEffect] = 2,    -- ligne rouge
	[Anthem2GreaterWarEffect] = 2,
	[Anthem2LesserAndGreaterEffect] = 2,
	[Anthem3LesserComposureEffect] = 3,                    -- ligne jaune
	[Anthem3GreaterProwessEffect] = 3,
	[Anthem3LesserAndGreaterEffect] = 3,
	[AnthemFreePeopleEffect] = 4,
}

ValidPersonalAnthemEffects = {
	["Hymne personnel - Résonance"] = true,
	["Hymne personnel - Dissonance"] = true,
}

Lesser = "L";
Greater = "G";
LesserAndGreater = "L+G";

AnthemOverlays = {
	["Hymne du Troisième Âge - Résonance"] = Lesser,
	["Hymne de compassion"] = Greater,
	["Anthem I - Resonance and Compassion"] = LesserAndGreater,
	["Hymne du Troisième Âge - Dissonance"] = Lesser,
	["Hymne de guerre"] = Greater,
	["Anthem II - Dissonance and War"] = LesserAndGreater,
	["Hymne de contenance"] = Lesser,
	["Hymne aux prouesses"] = Greater,
	["Anthem III - Composure and Prowess"] = LesserAndGreater,
	["Hymne des Peuples Libres"] = "",
};

ValidCodaSkillNames = {
	["Coda des Eorlingas"] = true,                  -- mounted
	["Coda de fureur"] = true,                      -- dissonance
	["Coda de mélodie"] = true,                     -- mélodie
	["Coda de résonance"] = true,                   -- résonance
	["Coda de fureur améliorée"] = true,            -- dissonance
	["Coda de mélodie améliorée"] = true,           -- mélodie
	["Coda de résonance améliorée"] = true          -- résonance
}

ValidCrySkillNames = {
	["Chant de l'unité"] = true, -- On War-steed
	["Cri du chœur (Dissonance)"] = true,
	["Cri du chœur"] = true,
	["Cri du chœur (Résonance)"] = true,
	["Cri du chœur amélioré (Dissonance)"] = true,
	["Cri du chœur amélioré"] = true,
	["Cri du chœur amélioré (Résonance)"] = true,
}

ValidMajorBalladSkillNames = {
	["Bonus de guérison de ballade"] = true,
}

ValidYellowTraitSkillNames = {
	["Hymne aux prouesses"] = true
}

ValidWarSpeechSkillNames = {
	["War-Speech"] = true;
};

ValidMelodicInterludeNames = {
	["Melodic Interlude"] = true;
};
