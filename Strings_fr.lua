if (clientLanguage ~= FR) then return; end

_LANG = {
    ["WINDOW"] = {
        ["DRAG_BAR_TITLE"] = "Soliloquy Tracker";
        ["MELODIC_INTERLUDE_TITLE"] = "Melodic Interlude";
    };

    ["CHAT"] = {
        ["SOLILOQUY_OF_SPIRIT_PATTERN"] = " a appliqué un bénéfice .*avec Esprit de soliloque (.*).";
        ["SPECIALIZATION_CHANGED"] = "Vous avez obtenu le trait bonus de spécialisation de classe : (.*)\n";
        ["ADVANCEMENT_TRAIT_ACQUIRED"] = "Vous avez obtenu le trait de classe :";
    };

    ["CLASS"] = {
        ["WATCHER_OF_RESOLVE"] = "Veilleur déterminé.";
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
        ["AnthemPriorityUsed"] = "Use Anthem Priority";
        ["AnthemOverlayUsed"] = "Use Anthem Overlay (L/G/L+G)";
    };

    ["EFFECTS"] = {
        ["SERIOUS_BUSINESS"] = "Serious Business";
    };
};