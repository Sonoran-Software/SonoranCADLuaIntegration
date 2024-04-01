--[[
    Sonaran CAD Plugins

    Plugin Name: callcommands
    Creator: SonoranCAD
    Description: Implements 311/511/911 commands
]]
CreateThread(function() Config.LoadPlugin("callcommands", function(pluginConfig)

if pluginConfig.enabled then
---------------------------------------------------------------------------
-- Chat Suggestions **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
    CreateThread(function()
        for _, call in pairs(pluginConfig.callTypes) do
            TriggerEvent('chat:addSuggestion', '/'..call.command, call.suggestionText, {
                { name="Description of Call", help="State what the call is about" }
            })
        end
        if pluginConfig.enablePanic then
            TriggerEvent('chat:addSuggestion', '/panic', 'Sends a panic signal to your SonoranCAD')
        end
    end)
end
end) end)