--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    pluginName = "wraithv2", -- name your plugin here
    pluginVersion = "1.0", -- version of your plugin
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {"lookups"}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    isPluginEnabled = false -- disable this plugin by default
}

Config.RegisterPluginConfig(config.pluginName, config)