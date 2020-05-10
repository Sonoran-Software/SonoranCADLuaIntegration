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

    -- VERY IMPORTANT: YOU MUST EDIT THE RADAR CODE TO SCAN PLAYER PLATES ONLY!
}

-- IMPORTANT: UNCOMMENT THE BELOW LINE ON ACTUAL PLUGINS!

Config.RegisterPluginConfig(config.pluginName, config)