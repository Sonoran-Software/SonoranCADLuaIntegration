--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    enabled = false,
    pluginName = "locations", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {},
    -- put your configuration options below
    checkTime = 5000, -- how frequently to send locations to the server
    prefixPostal = true -- prefix postal code on locations sent, requires postal plugin
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end