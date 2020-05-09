--[[
    Sonaran CAD Plugins

    Plugin Name: callcommands
    Creator: SonoranCAD
    Description: Implements 311/511/911 commands
]]

---------------------------------------------------------------------------
-- Chat Suggestions **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
TriggerEvent('chat:addSuggestion', '/panic', 'Sends a panic signal to your SonoranCAD')
TriggerEvent('chat:addSuggestion', '/911', 'Sends a emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})TriggerEvent('chat:addSuggestion', '/311', 'Sends a non-emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})