--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.

]]
local config = {
    enabled = false,
    configVersion = "1.1",
    pluginName = "civintegration", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {} -- required plugins for this plugin to work, separated by commas

    -- time to cache characters in seconds
    ,cacheTime = 3600 -- one hour

    -- allow civilians to use /setid and set a custom ID (for characters not registered in the CAD)
    ,allowCustomIds = true

    -- allow players to use /refreshid which causes the next /showid to re-fetch from the CAD. Useful if the player swaps characters.
    ,allowPurge = true

    -- if false, disables the built-in commands of this plugin so it can be used in custom code instead.
    ,enableCommands = true

    -- if true, you must have the sonoran_idcard resource started in your server in order for it to work
    ,enableIDCardUI = false
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end
