--[[
    Sonaran CAD Plugins

    Plugin Name: callcommands
    Creator: SonoranCAD
    Description: Implements 311/511/911 commands
]]
local pluginConfig = Config.plugins["callcommands"]

---------------------------------------------------------------------------
-- Chat Suggestions **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
CreateThread(function()
    if Config.enable911 then
        TriggerEvent('chat:addSuggestion', '/911', 'Sends a emergency call to your SonoranCAD', {
            { name="Description of Call", help="State what the call is about" }
        })
    end
    if Config.enable511 then

    end
    if Config.enable311 then
        TriggerEvent('chat:addSuggestion', '/311', 'Sends a non-emergency call to your SonoranCAD', {
            { name="Description of Call", help="State what the call is about" }
        })
    end
    if Config.enablePanic then
        TriggerEvent('chat:addSuggestion', '/panic', 'Sends a panic signal to your SonoranCAD')
    end

end)
