--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    enabled = false,
    configVersion = "1.1",
    pluginName = "apicheck", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {}, -- required plugins for this plugin to work, separated by commas
    forceSetApiId = true,
}

-- IMPORTANT: UNCOMMENT THE BELOW LINE ON ACTUAL PLUGINS!

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end