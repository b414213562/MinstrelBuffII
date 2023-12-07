if (clientLanguage ~= DE) then return; end

_LANG = {
    ["WINDOW"] = {
        ["DRAG_BAR_TITLE"] = "Selbstgespräch Tracker";
        ["MELODIC_INTERLUDE_TITLE"] = "Melodic Interlude";
    };

    ["CHAT"] = {
        -- Der Akuserian wandte "Vorteil" mit "Selbstgespräch des Geistes" auf den Akuserian an.
        -- Resonanz:
            -- Die Tijdloos wandte "Vorteil" mit "Selbstgespräch des Geistes" auf die Tijdloos an.
            -- Die Tijdloos wandte "kritischer Vorteil" mit "Selbstgespräch des Geistes" auf die Tijdloos an.
        -- Dissonanz:
            -- Die Tijdloos wandte "Vorteil" mit "Selbstgespräch meines Geistes" auf die Tijdloos an.
            -- Die Tijdloos wandte "kritischer Vorteil" mit "Selbstgespräch meines Geistes" auf die Tijdloos an.
        ["SOLILOQUY_OF_SPIRIT_PATTERN"] = "wandte \".*Vorteil\" mit \"Selbstgespräch .* Geistes\" auf d[ie][en] (.*) an.";

        -- Ihr habt diese Bonus-Eigenschaft für Klassenspezialisierung erlangt: Der Wächter der Entschlossenheit.
        ["SPECIALIZATION_CHANGED"] = "Ihr habt diese Bonus%-Eigenschaft für Klassenspezialisierung erlangt: (.*)\n";
        ["ADVANCEMENT_TRAIT_ACQUIRED"] = "Ihr habt diese Klasseneigenschaft erlangt:";
    };

    ["CLASS"] = {
        ["WATCHER_OF_RESOLVE"] = "Der Wächter der Entschlossenheit.";
        ["SOLILOQUY_OF_SPIRIT"] = "Selbstgespräch des Geistes";
    };

    ["OPTIONS"] = {
        ["EffectWindowOnlyVisibleInCombat"] = "Only visible in combat";
        ["ThemeIndex"] = "Select Theme:";
        ["SolilquyWindowUsed"] = "Benutze Selbstgespräch Tracker";
        ["CheckForSeriousBusiness"] = "Hide UI when Serious Business is active";
        ["ShowWarSpeechTimers"] = "Show War-Speech Timers";
        ["ShowMelodicInterlude"] = "Show Melodic Interlude Window";
        ["MelodicInterludeWidth"] = "Melodic Interlude Window Maßstab: %.1fx";
        ["MainWindowWidth"] = "Main Window Scaling: %.1fx";
        ["AnthemPriorityUsed"] = "Use Anthem Priority";
        ["AnthemOverlayUsed"] = "Use Anthem Overlay (L/G/L+G)";
    };

    ["EFFECTS"] = {
        ["SERIOUS_BUSINESS"] = "Serious Business";
    };
};