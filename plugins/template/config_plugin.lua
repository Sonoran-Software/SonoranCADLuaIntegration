--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    pluginName = "template", -- name your plugin here
    pluginVersion = "1.0", -- version of your plugin
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {"lookups"}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    myConfigOption = "value"
}

Config.RegisterPluginConfig(config.pluginName, config)