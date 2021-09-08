--[[
    Sonaran CAD Plugins

    Plugin Name: template
    Creator: template
    Description: Describe your plugin here

    Put all server-side logic in this file.
]]

CreateThread(function() Config.LoadPlugin("yourpluginname", function(pluginConfig)

    if pluginConfig.enabled then

        -- logic here

        -- example HTTP registration
        RegisterPluginHttpEvent("yourpluginname:hello", function(data)
            debugLog(("Got data: %s"):format(json.encode(data)))
            return { result = "ok, got some data!" }
        end)
    
    end

end) end)