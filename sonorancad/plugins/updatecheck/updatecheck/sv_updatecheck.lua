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
local url = "https://raw.githubusercontent.com/Sonoran-Software/SonoranCADLuaIntegration/"..Config.updateBranch.."/sonorancad/version.json"
local version = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
local latest = true

function checkForUpdate()
    PerformHttpRequest(url, function(err, data, headers)
        local parsed = json.decode(data)
        _, _, r1, r2, r3 = string.find( version, "(%d+)%.(%d+)%.(%d+)" )
        _, _, v1, v2, v3 = string.find( parsed["resource"], "(%d+)%.(%d+)%.(%d+)" )
        v1 = v1 and tonumber(v1) or 0
        v2 = v2 and tonumber(v2) or 0
        v3 = v3 and tonumber(v3) or 0
        r1 = tonumber(r1)
        r2 = tonumber(r2)
        r3 = tonumber(r3)
        debugLog(("versions: %s.%s.%s - %s.%s.%s"):format(r1, r2, r3, v1, v2, v3))
        if v1 > r1 or v2 > r2 or v3 > r3 then
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

CreateThread(function()
    checkForUpdate()
end)