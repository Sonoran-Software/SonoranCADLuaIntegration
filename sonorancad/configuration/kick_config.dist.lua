--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    enabled = true,
    pluginName = "kick", -- name your plugin here
    pluginAuthor = "TaylorMade#4860", -- author
    requiresPlugins = {}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below

}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end