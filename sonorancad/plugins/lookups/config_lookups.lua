--[[
    Sonoran Plugins

    Plugin Configuration
]]
local config = {
    pluginName = "lookups", -- name your plugin here
    pluginVersion = "1.0", -- version of your plugin
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    maxCacheTime = 120 -- max time to cache a plate hit, in seconds
}

Config.RegisterPluginConfig(config.pluginName, config)