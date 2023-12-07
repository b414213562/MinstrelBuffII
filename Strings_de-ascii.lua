if (clientLanguage ~= DE) then return; end

_LANG = {
    ["WINDOW"] = {
        ["DRAG_BAR_TITLE"] = "Selbstgespr\195\164ch Tracker";
        ["MELODIC_INTERLUDE_TITLE"] = "Melodic Interlude";
    };

    ["CHAT"] = {
        -- Der Akuserian wandte "Vorteil" mit "Selbstgespr\195\164ch des Geistes" auf den Akuserian an.
        -- Resonanz:
            -- Die Tijdloos wandte "Vorteil" mit "Selbstgespr\195\164ch des Geistes" auf die Tijdloos an.
            -- Die Tijdloos wandte "kritischer Vorteil" mit "Selbstgespr\195\164ch des Geistes" auf die Tijdloos an.
        -- Dissonanz:
            -- Die Tijdloos wandte "Vorteil" mit "Selbstgespr\195\164ch meines Geistes" auf die Tijdloos an.
            -- Die Tijdloos wandte "kritischer Vorteil" mit "Selbstgespr\195\164ch meines Geistes" auf die Tijdloos an.
        ["SOLILOQUY_OF_SPIRIT_PATTERN"] = "wandte \".*Vorteil\" mit \"Selbstgespr\195\164ch .* Geistes\" auf d[ie][en] (.*) an.";

        -- Ihr habt diese Bonus-Eigenschaft f\195\188r Klassenspezialisierung erlangt: Der W\195\164chter der Entschlossenheit.
        ["SPECIALIZATION_CHANGED"] = "Ihr habt diese Bonus%-Eigenschaft f\195\188r Klassenspezialisierung erlangt: (.*)\n";
    };

    ["CLASS"] = {
        ["WATCHER_OF_RESOLVE"] = "Der W\195\164chter der Entschlossenheit.";
        ["SOLILOQUY_OF_SPIRIT"] = "Selbstgespr\195\164ch des Geistes";
    };

    ["OPTIONS"] = {
        ["EffectWindowOnlyVisibleInCombat"] = "Only visible in combat";
        ["ThemeIndex"] = "Select Theme:";
        ["SolilquyWindowUsed"] = "Benutze Selbstgespr\195\164ch Tracker";
        ["CheckForSeriousBusiness"] = "Hide UI when Serious Business is active";
        ["ShowWarSpeechTimers"] = "Show War-Speech Timers";
        ["ShowMelodicInterlude"] = "Show Melodic Interlude Window";
        ["MelodicInterludeWidth"] = "Melodic Interlude Window Ma\195\159stab: %.1fx";
        ["MainWindowWidth"] = "Main Window Scaling: %.1fx";
    };

    ["EFFECTS"] = {
        ["SERIOUS_BUSINESS"] = "Serious Business";
    };
};