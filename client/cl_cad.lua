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
-- Config options
---------------------------------------------------------------------------
local checkTime = 1000 -- Location check time in milliseconds

---------------------------------------------------------------------------
-- Client Event Handling **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
        ---------------------------------
        -- Unit Location Update
        ---------------------------------
Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        -- Determine location format
        if (GetStreetNameFromHashKey(var2) == '') then
            currentLocation = GetStreetNameFromHashKey(var1)
            if (currentLocation ~= lastLocation) then
                -- Updated location - Save and send to server API call queue
                lastLocation = currentLocation
                TriggerServerEvent('sonorancad:cadSendLocation', currentLocation) 
            end
        else 
            currentLocation = GetStreetNameFromHashKey(var1) .. ' / ' .. GetStreetNameFromHashKey(var2)
            if (currentLocation ~= lastLocation) then
                -- Updated location - Save and send to server API call queue
                lastLocation = currentLocation
                TriggerServerEvent('sonorancad:cadSendLocation', currentLocation) 
            end
        end
        -- Wait (1000ms) before checking for an updated unit location
        Citizen.Wait(checkTime)
    end
end)
---------------------------------------------------------------------------
-- Chat Suggestions **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
-- Add helpers to chat when typing commands
TriggerEvent('chat:addSuggestion', '/panic', 'Sends a panic signal to your SonoranCAD')
TriggerEvent('chat:addSuggestion', '/911', 'Sends a emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})TriggerEvent('chat:addSuggestion', '/311', 'Sends a non-emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})
