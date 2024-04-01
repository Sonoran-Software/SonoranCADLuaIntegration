--[[
    Sonaran CAD Plugins

    Plugin Name: civintegration
    Creator: civintegration
    Description: Describe your plugin here

    Put all client-side logic in this file.
]]

local pluginConfig = Config.GetPluginConfig("civintegration")

if pluginConfig.enabled then

    AddTextEntry("ENTER_NAME", "Enter first and last name")
    AddTextEntry("ENTER_DOB", "Enter character date of birth in format month/day/year")

    local customId = {
        ['first'] = nil,
        ['last'] = nil,
        ['dob'] = nil,
        ['img'] = nil
    }

    RegisterNetEvent("SonoranCAD::civintegration:SetCustomId")
    AddEventHandler("SonoranCAD::civintegration:SetCustomId", function()
        DisplayOnscreenKeyboard(1, "ENTER_NAME", "", customId.first ~= nil and ("%s %s"):format(customId.first, customId.last), "", "", "", 50)
        while (UpdateOnscreenKeyboard() == 0) do
            DisableAllControlActions(0);
            Wait(0);
        end
        if (GetOnscreenKeyboardResult()) then
            local result = GetOnscreenKeyboardResult()
            customId.first = stringsplit(result, " ")[1]
            customId.last = stringsplit(result, " ")[2]
            DisplayOnscreenKeyboard(1, "ENTER_DOB", "", customId.dob ~= nil and customId.dob or "", "", "", "", 50)
            while (UpdateOnscreenKeyboard() == 0) do
                DisableAllControlActions(0);
                Wait(0);
            end
            if (GetOnscreenKeyboardResult()) then
                local result = GetOnscreenKeyboardResult()
                customId.dob = result
            end
        end
        TriggerServerEvent("SonoranCAD::civintegration:SetCustomId", customId)
        TriggerEvent("chat:addMessage", {args = {"^0[ ^1ID ^0] ", "Custom name and DOB set. Use /resetid to remove."}})
    end)

end