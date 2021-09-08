--[[
    Sonaran CAD Plugins

    Plugin Name: template
    Creator: template
    Description: Describe your plugin here

    Put all client-side logic in this file.
]]

CreateThread(function() 
    Config.LoadPlugin("yourpluginname", function(pluginConfig)

        if pluginConfig.enabled then
            -- logic here
        end
    end) 
end)