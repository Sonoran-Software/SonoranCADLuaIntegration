--[[
        SonoranCAD FiveM - A SonoranCAD integration for FiveM servers
              Copyright (C) 2020  Sonoran Software Systems LLC

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file "LICENSE".  If not, see <http://www.gnu.org/licenses/>.
]]


---------------------------------------------------------------------------
-- Update Checker
---------------------------------------------------------------------------
local url = "https://raw.githubusercontent.com/Sonoran-Software/SonoranCADLuaIntegration/master/version.json"
local version = "1.2.0"
local latest = true

local rawData = LoadResourceFile(GetCurrentResourceName(), "version.json")

if not rawData then
    print("Couldn't read \"versions.json\" file.. Please make sure it's readable and exists.")
else
    rawData = json.decode(rawData)
    version = rawData["resource"]
end

function checkForUpdate()
    PerformHttpRequest(url, function(err, data, headers)
        local parsed = json.decode(data)

        if (parsed["resource"] ~= version) then
            print("|===========================================================================|")
            print("|                        SonoranCAD Update Available                        |")
            print("|                           Current : " .. version .. "                                 |")
            print("|                           Latest  : " .. parsed["resource"] .. "                                 |")
            print("| Download at: https://github.com/Sonoran-Software/SonoranCADLuaIntegration |")
            print("|===========================================================================|")
            latest = false -- Stop running the timeout
        end

        -- Every 30 minutes, do the check (print the message if it's not up to date)
        SetTimeout( 30 * (60*1000), checkForUpdate)

    end, "GET", "",  { ["Content-Type"] = 'application/json' })
end

checkForUpdate();
