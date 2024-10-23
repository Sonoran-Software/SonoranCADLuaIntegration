--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.

]]
local config = {
    enabled = false,
    configVersion = "1.0",
    pluginName = "sonrad", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {},
    -- put your configuration options below

    -- Should radio panics generate CAD calls?
    addPanicCall = true
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end