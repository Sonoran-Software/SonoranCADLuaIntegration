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
        return Config.plugins[pluginName]
    else
        return nil
    end
end

CreateThread(function()
    TriggerServerEvent("SonoranCAD::core:sendClientConfig")
end)

RegisterNetEvent("SonoranCAD::core:recvClientConfig")
AddEventHandler("SonoranCAD::core:recvClientConfig", function(config)
    for k, v in pairs(config) do
        Config[k] = v
    end
end)