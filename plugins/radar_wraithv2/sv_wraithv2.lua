--[[
    Sonaran CAD Plugins

    Plugin Name: wraithv2
    Creator: SonoranCAD
    Description: Implements plate auto-lookup for the wraithv2 plate reader by WolfKnight

    Put all server-side logic in this file.
]]

local pluginConfig = Config.plugins["wraithv2"]

RegisterNetEvent("wk:onPlateLocked")
AddEventHandler("wk:onPlateLocked", function(cam, plate, index)
    debugLog(("plate lock: %s - %s - %s"):format(cam, plate, index))
    local source = source
    cadPlateLookup(plate, function(data)
        local reg = data.vehicleRegistrations[1] -- scanner is always full lookup
        if reg then
            local mi = reg.person.mi ~= "" and ", "..reg.person.mi or ""
            debugLog(("DATA: Plate [%s]: S: %s E: %s O: %s"):format(reg.vehicle.plate, reg.status, reg.expiration, reg.person.first.." "..reg.person.last..mi))
            
            TriggerClientEvent("chat:addMessage", source, {args = {"^3 ALPR ^0", ("Plate [%s]: Status: %s Expires: %s Owner: %s"):format(reg.vehicle.plate, reg.status, reg.expiration, reg.person.first.." "..reg.person.last..mi)}})
        else
            TriggerClientEvent("chat:addMessage", source, {args = {"^3 ALPR ^0", "No license records found for locked plate." }})
        end
    end)
end)

-- NOTE: event needs to detect AI versus players?
RegisterNetEvent("wk:onPlateScanned")
AddEventHandler("wk:onPlateScanned", function(cam, plate, index)
    debugLog(("plate scan: %s - %s - %s"):format(cam, plate, index))
    local source = source
    cadPlateLookup(plate, function(data)
        local reg = data.vehicleRegistrations[1] -- scanner is always full lookup
        if reg then
            local mi = reg.person.mi ~= "" and ", "..reg.person.mi or ""
            debugLog(("DATA: Plate [%s]: S: %s E: %s O: %s"):format(reg.vehicle.plate, reg.status, reg.expiration, reg.person.first.." "..reg.person.last..mi))
            
            TriggerClientEvent("chat:addMessage", source, {args = {"^3 ALPR ^0", ("Plate [%s]: Status: %s Expires: %s Owner: %s"):format(reg.vehicle.plate, reg.status, reg.expiration, reg.person.first.." "..reg.person.last..mi)}})
        end
    end)
end)