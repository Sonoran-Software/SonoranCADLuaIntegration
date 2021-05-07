Config = {
    plugins = {}
}
Plugins = {}

Config.RegisterPluginConfig = function(pluginName, configs)
    Config.plugins[pluginName] = {}
    for k, v in pairs(configs) do
        Config.plugins[pluginName][k] = v
    end 
    table.insert(Plugins, pluginName)
end
Config.GetPluginConfig = function(pluginName) 
    if Config.plugins[pluginName] ~= nil then
        if Config.plugins[pluginName].enabled == nil then
            Config.plugins[pluginName].enabled = true
        end
        return Config.plugins[pluginName]
    else
        if pluginName == "yourpluginname" then
            return { enabled = false }
        end
        return { enabled = false }
    end
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(1)
    end
    TriggerServerEvent("SonoranCAD::core:sendClientConfig")
end)

RegisterNetEvent("SonoranCAD::core:recvClientConfig")
AddEventHandler("SonoranCAD::core:recvClientConfig", function(config)
    for k, v in pairs(config) do
        Config[k] = v
    end
    Config.inited = true
    debugLog("Configuration received")
end)

CreateThread(function()
    while not Config.inited do
        Wait(10)
    end
    if Config.devHiddenSwitch then
        debugLog("Spawned discord thread")
        SetDiscordAppId(747991263172755528)
        SetDiscordRichPresenceAsset("cad_logo")
        SetDiscordRichPresenceAssetSmall("sonoran_logo")
        while true do
            SetRichPresence("Developing SonoranCAD!")
            Wait(5000)
            SetRichPresence("sonorancad.com")
            Wait(5000)
        end
    end
end)

local inited = false
AddEventHandler("playerSpawned", function()
    TriggerServerEvent("SonoranCAD::core:PlayerReady")
    inited = true
end)