--[[
    Sonaran CAD Plugins

    Plugin Name: postals
    Creator: SonoranCAD
    Description: Fetches nearest postal from client
]]


local pluginConfig = Config.plugins["postals"]

-- Don't touch this!

local function getNearestPostal()
    if pluginConfig.getPostalMethod == "nearestpostal" then
        if exports[pluginConfig.nearestPostalResourceName] ~= nil then
            return exports[pluginConfig.nearestPostalResourceName]:getPostal()
        else
            assert(false, "Required postal resource is not loaded. Cannot use postals plugin.")
        end
    else if pluginConfig.getPostalMethod == "custom" then
        return getPostalCustom()
    else
        errorLog("MISCONFIGURATION: postals plugin is misconfigured. Please check it.")
        assert(false, "Postal configuration is not correct.")
    end
end
local function sendPostalData()
    local postal = getNearestPostal()
    if postal ~= nil then
        TriggerServerEvent("cadClientPostal", postal)
    end
end
CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(10)
    end
    TriggerServerEvent("getShouldSendPostal")
    while true do
        if shouldSendPostalData then
            sendPostalData()
        end
        Wait(postalPulseTimer)
    end
end)

RegisterNetEvent("getShouldSendPostalResponse")
AddEventHandler("getShouldSendPostalResponse", function(toggle)
    shouldSendPostalData = toggle
end)