--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
config = {
    pluginName = "callcommands", -- name your plugin here
    pluginVersion = "1.0", -- version of your plugin
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {"locations"}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    enable911 = true,
    enable511 = true,
    enable311 = true,
    enablePanic = true
}

Config.RegisterPluginConfig(config.pluginName, config)