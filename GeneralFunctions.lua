
-- Basic debug function to look at a table:
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

--[[
function DebugTable(class)
	if type(class) ~= "table" then
	 Turbine.Shell.WriteLine( tostring(class) .. ": (" .. type(class) .. ")");
	 return;
	end
  local sortAtable = {}
  for key,v in pairs(class) do table.insert(sortAtable, {key,v}) end
  table.sort(sortAtable,compareItems);
	Turbine.Shell.WriteLine( tostring(class) .. ": (" .. type(class) .. ") " .. " : # " .. #sortAtable);
	cltb = getmetatable(class);
	for n,var in pairs(sortAtable) do
	 k = var[1]; v = var[2];
	 Turbine.Shell.WriteLine( "(" .. k .. "): (" .. type(v) .. ") " .. tostring(v) .. " ;" );
	 if k == "__implementation" then
	  u = getmetatable(v);	v3 = v;
	  if u then
	   for k2, v2 in pairs( u ) do
	    Turbine.Shell.WriteLine( "C: (" .. k2 .. "): " .. tostring(v2) );
	    if k2 == "__index" then v3 = v2; end
	   end
	   if v3 == v then
	    if u.__index then v3 = u.__index;
	    elseif cltb and type(v) == "userdata" then
	     if cltb.__index then v3 = cltb.__index;
	     else v3 = cltb; end
	    end
	   end
	  end
	  u = v3;
	 elseif k == "__index" and not cltb and getmetatable(v) then u = getmetatable(v).__index;
	 else u = v; end
--	 Turbine.Shell.WriteLine( "(" .. k .. "): (" .. type(u) .. ") " .. tostring(u) .. " ;" );
	 if type(u) == "table" then  -- can call DebugTable(u) recursively instead, but it's not advisable
	  table.sort(u);
	  for k2, v2 in pairs( u ) do
	    Turbine.Shell.WriteLine( "(" .. k2 .. "): " .. tostring(v2) );
	  end
	 elseif u ~= v then
	  Turbine.Shell.WriteLine( tostring(u) );
	 end
	end
	if cltb then
	 for k2, v2 in pairs( cltb ) do
	  Turbine.Shell.WriteLine( "  (" .. k2 .. "): " .. tostring(v2) );
	 end
	end
end
]]--

