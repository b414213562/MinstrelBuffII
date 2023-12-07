if (clientLanguage ~= EN) then return; end

_LANG = {
    ["WINDOW"] = {
        ["DRAG_BAR_TITLE"] = "Soliloquy Tracker";
        ["MELODIC_INTERLUDE_TITLE"] = "Melodic Interlude";
    };

    ["CHAT"] = {
        ["SOLILOQUY_OF_SPIRIT_PATTERN"] = "benefit with Soliloquy of .*Spirit on (.*).";
        ["SPECIALIZATION_CHANGED"] = "You have acquired the Class Specialization Bonus Trait: (.*)\n";
        ["ADVANCEMENT_TRAIT_ACQUIRED"] = "You have acquired the Class Trait:";
    };

    ["CLASS"] = {
        ["WATCHER_OF_RESOLVE"] = "The Watcher of Resolve.";
        ["SOLILOQUY_OF_SPIRIT"] = "Soliloquy of Spirit";
    };

    ["OPTIONS"] = {
        ["EffectWindowOnlyVisibleInCombat"] = "Only visible in combat";
        ["ThemeIndex"] = "Select Theme:";
        ["SolilquyWindowUsed"] = "Use Soliloquy Tracker";
        ["CheckForSeriousBusiness"] = "Hide UI when Serious Business is active";
        ["ShowWarSpeechTimers"] = "Show War-Speech Timers";
        ["ShowMelodicInterlude"] = "Show Melodic Interlude Window";
        ["MelodicInterludeWidth"] = "Melodic Interlude Window Scaling: %.1fx";
        ["MainWindowWidth"] = "Main Window Scaling: %.1fx";
        ["AnthemPriorityUsed"] = "Use Anthem Priority";
        ["AnthemOverlayUsed"] = "Use Anthem Overlay (L/G/L+G)";
    };

    ["EFFECTS"] = {
        ["SERIOUS_BUSINESS"] = "Serious Business";
    };
};