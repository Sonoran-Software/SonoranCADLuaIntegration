--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
local config = {
    pluginName = "template", -- name your plugin here
    pluginVersion = "1.0", -- version of your plugin
    pluginAuthor = "SonoranCAD", -- author
    requiresPlugins = {"locations"}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    sendTimer = 950, -- how often to send postal to client
    shouldSendPostalData = true, -- toggles this plugin on/off
    --[[ 
        Method to get the postals from a client.

        This plugin includes code to fetch from the "Nearest Postal" plugin, featured here: https://forum.cfx.re/t/release-nearest-postal-script/293511
        If you use this resource, check README_postals.md for instructions and set getPostalMethod to "nearestpostal"

        If using a custom script, set getPostalMethod to "custom" and specify below.

    --]]
    getPostalMethod = "custom",
    nearestPostalResourceName = "nearest-postal" -- if using nearestpostal, specify the name of the resource here if you changed it
}

-- User-edited code

-- edit the below function if specifying "custom" postal handler above
function getPostalCustom()
    return nil -- remove this line!
end

Config.RegisterPluginConfig(config.pluginName, config)