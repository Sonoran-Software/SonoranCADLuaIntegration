---------------------------------------------------------------------------
-- Config Options
---------------------------------------------------------------------------
local checkTime = "1000" -- Location check time in milliseconds

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
        local postal = getPostal()
        -- Determine location format
        if (GetStreetNameFromHashKey(var2) == '') then
            currentLocation = GetStreetNameFromHashKey(var1)
            if (currentLocation ~= lastLocation) then
                -- Updated location - Save and send to server API call queue
                lastLocation = currentLocation
            end
        else 
            currentLocation = GetStreetNameFromHashKey(var1) .. ' / ' .. GetStreetNameFromHashKey(var2)
            if (currentLocation ~= lastLocation) then
                -- Updated location - Save and send to server API call queue
                lastLocation = currentLocation
            end
        end
        if shouldSendPostalData and postal ~= nil then
            currentLocation = "["..tostring(postal).."] "..currentLocation
        end
        TriggerServerEvent('cadSendLocation', currentLocation) 
        -- Wait (1000ms) before checking for an updated unit location
        Citizen.Wait(checkTime)
    end
end)

---------------------------------------------------------------------------
-- Chat Suggestions **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
TriggerEvent('chat:addSuggestion', '/panic', 'Sends a panic signal to your SonoranCAD')
TriggerEvent('chat:addSuggestion', '/911', 'Sends a emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})TriggerEvent('chat:addSuggestion', '/311', 'Sends a non-emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})