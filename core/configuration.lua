Config = {
    communityID = "",
    apiKey = "",
    apiURL = 'https://api.sonorancad.com/emergency',
    postTime = 5000, --Recommended to stay above 5000ms3
    serverId = "1", -- Default is 1
    serverType = "standalone", -- Either specify "standalone" or "esx", "standalone" will use Player Name as the Caller ID, and "esx" will use "esx-identity" to use your character's name.
    primaryIdentifier = "steam", -- Used for location data. What ID will players specify?
    apiSendEnabled = true, -- Set to false to disable sending over the API and you use your own 911 handler

    debugMode = true, -- When set to true, print every web request to console. Very spammy, only set if asked to by support!

    plugins = {}
}



-- On server startup, fetch configuration info and fill the Config object
Config.communityID = communityID
Config.apiKey = apiKey
Config.apiUrl = apiUrl
Config.postTime = postTime
Config.serverId = serverId
Config.serverType = serverType
Config.primaryIdentifier = primaryIdentifier
Config.apiSendEnabled = apiSendEnabled
Config.debugMode = debugMode

Config.RegisterPluginConfig = function(pluginName, configs)
    Config.plugins[pluginName] = {}
    for k, v in pairs(configs) do
        Config.plugins[pluginName][k] = v
        debugLog(("plugin %s set %s = %s"):format(pluginName, k, v))
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