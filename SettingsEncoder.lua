-- Functions to encode numbers in german and french versions
-- found at KragenBars
-- http://svn.lotrointerface.com/filedetails.php?repname=KragenBars&path=%2Fbranches%2F321%2FKragenBars%2FMain.lua&rev=68

SettingsEncoder = class();
locale = Turbine.Engine.GetLocale();

function SettingsEncoder:EncodeTable(data)
        if ((locale == "fr" or locale == "de") and data ~= nil) then
                local newdata = {};
                local newkey = nil;
                
                for k,v in pairs(data) do
                        if (type(k) == "number") then
                                newkey = ("<num>%f</num>"):format(k);
                        else
                                newkey = k;
                        end
                        if (type(data[k]) == "number") then
                                newdata[newkey] = ("<num>%f</num>"):format(data[k]);
                        elseif(type(data[k]) == "table") then
                                newdata[newkey] = self:EncodeTable(data[k]);
                        else
                                newdata[newkey] = data[k];
                        end
                end
                return newdata;
        else
                return data;
        end
end

function SettingsEncoder:DecodeTable(data)
        if ((locale == "fr" or locale == "de") and data ~= nil) then
                local newdata = {};
                local newkey = nil;
        
                for k,v in pairs(data) do
                        if (type(k) == "string") then
                                local match = k:match("<num>(%d+.%d+)</num>");
                                if (match ~= nil) then
                                        newkey = tonumber(match);
                                else
                                        newkey = k;
                                end
                        else
                                newkey = k;
                        end
                        if (type(data[k]) == "string") then
                                local match = data[k]:match("<num>(%d+.%d+)</num>");
                                if (match ~= nil) then
                                        newdata[newkey] = tonumber(match);
                                else
                                        newdata[newkey] = data[k];
                                end
                        elseif(type(data[k]) == "table") then
                                newdata[newkey] = self:DecodeTable(data[k]);
                        else
                                newdata[newkey] = data[k];
                        end
                end
                return newdata;
        else
                return data;
        end
end

-- this will be true if the number is formatted with a 
-- comma for the decimal place / radix point, false otherwise
isEuroFormat=(tonumber("1,000")==1);

-- create a function to automatcially convert in string format to number:
if (isEuroFormat) then
    function euroNormalize(value)
        if (value == nil) then return 0.0; end
        return tonumber((string.gsub(value, "%.", ",")));
    end
else
    function euroNormalize(value)
        if (value == nil) then return 0.0; end
        return tonumber((string.gsub(value, ",", ".")));
    end
end