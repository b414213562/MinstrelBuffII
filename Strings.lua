
clientLanguage = Turbine.Engine:GetLanguage();

EN = Turbine.Language.English;
DE = Turbine.Language.German;
FR = Turbine.Language.French;

if (clientLanguage == DE) then
    import "CubePlugins.MinstrelBuffII.Strings_de";
elseif (clientLanguage == FR) then
    import "CubePlugins.MinstrelBuffII.Strings_fr";
else
    import "CubePlugins.MinstrelBuffII.Strings_en";
end
