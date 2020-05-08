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
local version = "1.2.4"
local latest = true

local rawData = LoadResourceFile(GetCurrentResourceName(), "version.json")

if not rawData then
    print("SonoranCAD ERROR: Couldn't read \"versions.json\" file.. Please make sure it's readable and exists.")
else
    rawData = json.decode(rawData)
    version = rawData["resource"]
end

function checkForUpdate()
    PerformHttpRequest(url, function(err, data, headers)
        local parsed = json.decode(data)

        if (parsed["resource"] ~= version) then
            print("^3|===========================================================================|")
            print("^3|                        ^5SonoranCAD Update Available                        ^3|")
            print("^3|                             ^8Current : " .. version .. "                               ^3|")
            print("^3|                             ^2Latest  : " .. parsed["resource"] .. "                               ^3|")
            print("^3| Download at: ^4https://github.com/Sonoran-Software/SonoranCADLuaIntegration ^3|")
            print("^3|===========================================================================|^7")
            latest = false -- Stop running the timeout
        end

        -- Every 30 minutes, do the check (print the message if it's not up to date)
        if latest then
            SetTimeout( 30 * (60*1000), checkForUpdate)
        end

    end, "GET", "",  { ["Content-Type"] = 'application/json' })
end

checkForUpdate();
