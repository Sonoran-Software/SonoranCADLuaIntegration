--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    pluginName = "locations", -- name your plugin here
    pluginVersion = "1.0", -- version of your plugin
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    checkTime = 5000, -- how frequently to send locations to the server
    prefixPostal = true -- prefix postal code on locations sent, requires postal plugin
}

Config.RegisterPluginConfig(config.pluginName, config)