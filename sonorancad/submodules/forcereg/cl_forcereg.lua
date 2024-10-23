--[[
    Sonaran CAD Plugins

    Plugin Name: forcereg
    Creator: Era#1337
    Description: Requires players to link their API IDs to a valid Sonoran account.
    
]]

local pluginConfig = Config.GetPluginConfig("forcereg")

if pluginConfig.enabled then

    local isNagging = false
    local isFreezing = false
    local freezePos = nil
    local isNoSpawn = false
    local id = nil
    local idString = nil

    RegisterNetEvent("SonoranCAD::forcereg:PlayerReg")
    AddEventHandler("SonoranCAD::forcereg:PlayerReg", function(identifier, exists)
        if not exists then
            Wait(1)
            id = identifier
            idString = identifier
            if isPluginLoaded("esxsupport") then
                if Config.plugins.esxsupport.usePrefix then
                    idString = ("%s:%s"):format(Config.primaryIdentifier, identifier)
                else
                    idString = identifier
                end
            end
            print(("Identifier %s does not exist."):format(idString))
            if pluginConfig.captiveOption:lower() == "nag" then
                isNagging = true
            elseif pluginConfig.captiveOption:lower() == "freeze" then
                isFreezing = true
            elseif pluginConfig.captiveOption:lower() == "nospawn" then
                isNoSpawn = true
            else
                assert(false, 'Invalid captiveOption!')
            end
        else
            print("Identity verified.")
            isNagging = false
            isFreezing = false
            freezePos = nil
            isNoSpawn = false
        end
    end)

    TriggerServerEvent("SonoranCAD::forcereg:CheckPlayer")

    RegisterCommand("verifycad", function(source, args, rawCommand)
        TriggerServerEvent("SonoranCAD::forcereg:CheckPlayer")
    end)

    CreateThread(function()
        while true do
            if isNagging then
                -- USER CONFIG: Change the below to adjust the text to your liking
                if pluginConfig.nagDrawTextLocation:lower() == "top" then
                    DrawText2D(pluginConfig.captiveMessage, 0, 0, 0.305, 0.01, 0.3, 255, 255, 255, 150)
                    DrawText2D(pluginConfig.instructionalMessage, 0, 0, 0.3, 0.03, 0.3, 255, 255, 255, 150)
                    DrawText2D(pluginConfig.verifyMessage.." API ID: ~r~"..id, 0, 0, 0.35, 0.06, 0.3, 255, 255, 255, 150)
                elseif pluginConfig.nagDrawTextLocation:lower() == "center" then
                    DrawText2D(pluginConfig.captiveMessage, 0, 0, 0.2, 0.4, 0.5, 255, 255, 255, 150)
                    DrawText2D(pluginConfig.instructionalMessage, 0, 0, 0.195, 0.45, 0.5, 255, 255, 255, 150)
                    DrawText2D(pluginConfig.verifyMessage.." API ID: ~r~"..idString, 0, 0, 0.265, 0.5, 0.5, 255, 255, 255, 150)
                end
                -- END USER CONFIG
                Wait(0)
            elseif isFreezing then
                CreateThread(function()
                    while isFreezing do
                        if freezePos == nil then
                            freezePos = GetEntityCoords(PlayerPedId())
                        end
                        FreezeEntityPosition(PlayerPedId(), true)
                        ClearPedTasksImmediately(PlayerPedId())
                        SetEntityCoords(PlayerPedId(), freezePos, 0.0, 0.0, 0.0, false)

                        -- USER CONFIG: Change the below to adjust the text to your liking
                        DrawText2D(pluginConfig.captiveMessage, 0, 0, 0.2, 0.4, 0.5, 255, 255, 255, 150)
                        DrawText2D(pluginConfig.instructionalMessage, 0, 0, 0.195, 0.45, 0.5, 255, 255, 255, 150)
                        DrawText2D(pluginConfig.verifyMessage.." API ID: ~r~"..idString, 0, 0, 0.265, 0.5, 0.5, 255, 255, 255, 150)
                        -- END USER CONFIG
                        Wait(0)
                    end
                    FreezeEntityPosition(PlayerPedId(), false)
                    freezePos = nil
                end)
                Wait(1000)
                while freezePos ~= nil do
                    Wait(10)
                end

            elseif isNoSpawn then
                -- do nothing, for now
            else
                Wait(100)
            end
        end
    end)

end


-- utility

local AspectRatio
local ScreenWidth
local ScreenHeight

Citizen.CreateThread(function()
	AspectRatio = GetAspectRatio(false)
	ScreenWidth = 1080 * AspectRatio
	ScreenHeight = 1080
end)

function DrawText2D(text, font, centre, px, py, scale, r, g, b, a, labelGen)
    if labelGen then 
        AddTextEntry(labelGen, text)
    end
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r or 255, g or 255, b or 255, a or 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    --SetTextOutline()
    SetTextCentre(centre)
    SetTextEntry(labelGen or "STRING")
	AddTextComponentString(text)
	local x = px + (scale / 2.0) / ScreenWidth
	local y = py + (scale / 2.0) / ScreenHeight
    DrawText(x, y)
end
