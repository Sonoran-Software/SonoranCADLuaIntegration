--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.

]]
local config = {
    enabled = false,
    configVersion = "1.0",
    pluginName = "template", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author

    -- put your configuration options below
    myConfigOption = "value"
}

if config.enabled then
    Config.RegisterPluginConfig(config.pluginName, config)
end