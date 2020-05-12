--[[
    Sonoran Plugins

    Plugin Configuration

    Put all needed configuration in this file.
]]
config = {
    pluginName = "trafficstop", -- name your plugin here
    pluginVersion = "1.0", -- version of your plugin
    pluginAuthor = "SonoranCAD", -- author
<<<<<<< HEAD
    requiresPlugins = {"locations"}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    enablets = true,
    origin = 3, -- 1 = CALLER / 2 = RADIO DISPATCH / 3 = OBSERVED / 4 = WALK_UP
    status = 2, -- 1 = PENDING / 2 = ACTIVE / 3 = CLOSED
=======
    requiresPlugins = {"locations", "postals"}, -- required plugins for this plugin to work, separated by commas

    -- put your configuration options below
    enablets = true,
    origin = 1, -- 1 = CALLER / 2 = RADIO DISPATCH / 3 = OBSERVED / 4 = WALK_UP
    status = 1, -- 1 = PENDING / 2 = ACTIVE / 3 = CLOSED
>>>>>>> 3069eab40b91408980f14f34e06c4f5db228f417
    priority = 1, -- 1, 2, or 3
    title = "Traffic Stop", -- This is the title of the call by default it is sent as "Traffic Stop"
    code = "10-11 - Traffic Stop" -- Change this to reflect your communities 10 Code for a Traffic Stop
}

Config.RegisterPluginConfig(config.pluginName, config)