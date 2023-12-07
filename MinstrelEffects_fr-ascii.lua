if (clientLanguage ~= FR) then return; end

---- French effect names ----
ValidBalladEffects = {
	["Bonus de d\195\169g\195\162ts de ballade"] = true,
	["Bonus de Puissance de ballade"] = true,
	["Bonus de gu\195\169rison de ballade"] = true,
	["Chant fun\195\168bre"] = true,
	["Saga"] = true,
	["Chant"] = true
}

ValidAnthemEffects = {
	["Hymne de guerre"] = 1,
	["Hymne aux prouesses"] = 2,
	["Hymne de contenance"] = 3,
	["Hymne du Troisi\195\168me Âge"] = 4,                 -- meta, indisponible
	["Hymne du Troisi\195\168me Âge - Dissonance"] = 4,    -- ligne rouge
	["Hymne du Troisi\195\168me Âge - M\195\169lodie"] = 4,       -- ligne jaune
	["Hymne du Troisi\195\168me Âge - R\195\169sonance"] = 4,     -- ligne bleue
	["Hymne de l'Aube rouge"] = 1,
	["Hymne du Riddermark"] = 2,
	["Hymne des Rohirrim"] = 3
}

ValidCodaSkillNames = {
	["Coda des Eorlingas"] = true,                  -- mounted
	["Coda de fureur"] = true,                      -- dissonance
	["Coda de m\195\169lodie"] = true,                     -- m\195\169lodie
	["Coda de r\195\169sonance"] = true,                   -- r\195\169sonance
	["Coda de fureur am\195\169lior\195\169e"] = true,            -- dissonance
	["Coda de m\195\169lodie am\195\169lior\195\169e"] = true,           -- m\195\169lodie
	["Coda de r\195\169sonance am\195\169lior\195\169e"] = true          -- r\195\169sonance
}

ValidCrySkillNames = {
	["Chant de l'unit\195\169"] = true, -- On War-steed
	["Cri du chœur (Dissonance)"] = true,
	["Cri du chœur"] = true,
	["Cri du chœur (R\195\169sonance)"] = true,
	["Cri du chœur am\195\169lior\195\169 (Dissonance)"] = true,
	["Cri du chœur am\195\169lior\195\169"] = true,
	["Cri du chœur am\195\169lior\195\169 (R\195\169sonance)"] = true,
}

ValidMajorBalladSkillNames = {
	["Ballade majeure"] = true,
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
