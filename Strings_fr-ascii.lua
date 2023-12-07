if (clientLanguage ~= FR) then return; end

_LANG = {
    ["WINDOW"] = {
        ["DRAG_BAR_TITLE"] = "Soliloquy Tracker";
        ["MELODIC_INTERLUDE_TITLE"] = "Melodic Interlude";
    };

    ["CHAT"] = {
        ["SOLILOQUY_OF_SPIRIT_PATTERN"] = " a appliqu\195\169 un b\195\169n\195\169fice .*avec Esprit de soliloque (.*).";
        ["SPECIALIZATION_CHANGED"] = "Vous avez obtenu le trait bonus de sp\195\169cialisation de classe : (.*)\n";
    };

    ["CLASS"] = {
        ["WATCHER_OF_RESOLVE"] = "Veilleur d\195\169termin\195\169.";
        ["SOLILOQUY_OF_SPIRIT"] = "Esprit de soliloque";
    };

    ["OPTIONS"] = {
        ["EffectWindowOnlyVisibleInCombat"] = "Only visible in combat";
        ["ThemeIndex"] = "Select Theme:";
        ["SolilquyWindowUsed"] = "Use Soliloquy Tracker";
        ["CheckForSeriousBusiness"] = "Hide UI when Serious Business is active";
        ["ShowWarSpeechTimers"] = "Show War-Speech Timers";
        ["ShowMelodicInterlude"] = "Show Melodic Interlude Window";
        ["MelodicInterludeWidth"] = "Melodic Interlude Window Echelle: %.1fx";
        ["MainWindowWidth"] = "Main Window Scaling: %.1fx";
    };

    ["EFFECTS"] = {
        ["SERIOUS_BUSINESS"] = "Serious Business";
    };
};