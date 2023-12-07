if (clientLanguage ~= DE) then return; end

---- German effect names ----
ValidBalladEffects = {
	["Bonusschaden bei Balladen"] = true,
	["Kraftbonus bei Balladen"] = true,
	["Balladenheilungs-Bonus"] = true,
	["Klagegesang"] = true, -- Auf dem Kriegsross
	["Gesang"] = true, -- Auf dem Kriegsross
	["Sage"] = true -- Auf dem Kriegsross
}

ValidAnthemEffects = {
	["Hymne des Mitgef\195\188hls"] = 1,                     -- removed in U12
	["Hymne des Dritten Zeitalters"] = 4,             -- Meta, nicht verf\195\188gbar
	["Hymne des Dritten Zeitalters - Dissonanz"] = 4, -- In roter Traitlinie
	["Hymne des Dritten Zeitalters - Resonanz"] = 4,  -- In blauer Traitlinie
	["Hymne des Dritten Zeitalters - Melodie"] = 4,   -- In gelber Traitlinie
	["Hymne der freien V\195\182lker"] = 5,                  -- removed in U12
	["Hymne des Krieges"] = 2,
	["Hymne der T\195\188chtigkeit"] = 3,
	["Hymne der Selbstbeherrschung"] = 6,
	["Hymnen der Rohirrim"] = 1,                      -- Auf dem Kriegsross
	["Hymne der Morgenr\195\182te"] = 2,                     -- Auf dem Kriegsross
	["Hymne der Riddermark"] = 3                      -- Auf dem Kriegsross
}

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
	["Dur-Ballade"] = true,
}

ValidYellowTraitSkillNames = {
	["Hymne der T\195\188chtigkeit"] = true
}

ValidWarSpeechSkillNames = {
	["War-Speech"] = true;
};

ValidMelodicInterludeNames = {
	["Melodic Interlude"] = true;
};
