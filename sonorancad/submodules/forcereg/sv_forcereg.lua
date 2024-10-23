--[[
    Sonaran CAD Plugins

    Plugin Name: forcereg
    Creator: Era#1337
    Description: Requires players to link their API IDs to a valid Sonoran account.

]]

local pluginConfig = Config.GetPluginConfig("forcereg")

if pluginConfig.enabled then

    if pluginConfig.captiveOption == "whitelist" then
        local function checkApiId(apiId, deferral, cb)
            cadApiIdExists(apiId, function(exists)
                debugLog(("checkApiId %s"):format(exists))
                cb(exists, deferral)
            end)
        end

        AddEventHandler("playerConnecting", function(name, setMessage, deferrals)
            local source = source
            deferrals.defer()
            Wait(1)
            deferrals.update("Checking CAD account, please wait...")
            checkApiId(GetIdentifiers(source)[Config.primaryIdentifier], deferrals, function(exists, deferral)
                print("exists: "..tostring(exists))
                if not exists then
                    deferral.done(pluginConfig.captiveMessage)
                else
                    deferral.done()
                end
            end)
        end)
    end

    

    RegisterNetEvent("SonoranCAD::forcereg:CheckPlayer")
    AddEventHandler("SonoranCAD::forcereg:CheckPlayer", function()
        TriggerEvent("SonoranCAD::apicheck:CheckPlayerLinked", source)
    end)

    AddEventHandler("SonoranCAD::apicheck:CheckPlayerLinkedResponse", function(player, identifier, exists)
        TriggerClientEvent("SonoranCAD::forcereg:PlayerReg", player, identifier, exists)
    end)

    

end