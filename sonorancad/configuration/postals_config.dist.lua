--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]] local config = {
    enabled = false,
    pluginName = "postals", -- name your plugin here
    pluginAuthor = "SonoranCAD", -- author
    configVersion = "1.3.0",
    requiresPlugins = {{name = "locations", critical = true}},
    -- put your configuration options below
    sendTimer = 950, -- how often to send postal to client
    shouldSendPostalData = true, -- toggles this plugin on/off

    nearestPostalResourceName = "nearest-postal", -- if using nearestpostal, specify the name of the resource here if you changed it
    -- optionally use an event fired by another resource, set mode to "event" and add the name of the event below, set mode to "file" if you are using a custom postal file
    mode = "resource",
    nearestPostalEvent = "",

    -- if not using nearest-postal, place a json file containing the postals in the plugin's folder and specify a name below
    customPostalCodesFile = ""
}

if config.enabled then Config.RegisterPluginConfig(config.pluginName, config) end
