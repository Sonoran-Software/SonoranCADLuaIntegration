--[[
    Sonaran CAD Plugins

    Plugin Name: civintegration
    Creator: civintegration
    Description: Describe your plugin here

    Put all server-side logic in this file.
]]

local pluginConfig = Config.GetPluginConfig("civintegration")

if pluginConfig.enabled then

    CharacterCache = {}
    CustomCharacterCache = {}
    local CharacterCacheTimers = {}

    registerApiType("GET_CHARACTERS", "civilian")

    AddEventHandler("playerDropped", function()
        CharacterCache[source] = nil
        CharacterCacheTimers[source] = nil
        CustomCharacterCache[source] = nil
    end)

    local function getCharactersApi(player, callback)
        local apiId = GetIdentifiers(player)[Config.primaryIdentifier]
        if not apiId or apiId == nil then
            callback(nil)
            return
        end
        local payload = { ['apiId'] = apiId }
        performApiRequest({payload}, "GET_CHARACTERS", function(result)
            if result ~= nil then
                local characters = {}
                for _, records in pairs(json.decode(result)) do
                    local charData = {}
                   -- debugLog(("check record %s"):format(json.encode(records)))
                    for _, section in pairs(records.sections) do
                        if section.category == 7 then
                            debugLog("cat 7")
                            for _, field in pairs(section.fields) do
                                if field.uid == "img" then
                                    debugLog("add image")
                                    charData["img"] = field.value
                                end
                            end
                        elseif section.category == 0 then
                            for _, field in pairs(section.fields) do
                                debugLog(("add %s = %s"):format(field.uid, field.value))
                                charData[field.uid] = field.value
                            end
                        end
                    end
                    table.insert(characters, charData)
                end
                callback(characters)
            else
                callback(nil)
            end
        end)
    end

    function GetCharacters(player, callback)
        if CustomCharacterCache[player] ~= nil then
            callback(CustomCharacterCache[player])
        elseif CharacterCache[player] ~= nil then
            if CharacterCacheTimers[player] < GetGameTimer()+(1000*pluginConfig.cacheTime) then
                getCharactersApi(player, function(characters)
                    CharacterCache[player] = characters
                    CharacterCacheTimers[player] = GetGameTimer()
                    callback(characters)
                end)
            else
                callback(CharacterCache[player])
            end
        else
            getCharactersApi(player, function(characters)
                CharacterCache[player] = characters
                CharacterCacheTimers[player] = GetGameTimer()
                callback(characters)
            end)
        end
    end

    exports('GetCharacters', GetCharacters)

    if pluginConfig.enableCommands then
        RegisterCommand("showid", function(source, args, rawCommand)
            local target = nil
            local source = source
            if args[1] == nil then
                target = source
            else
                target = args[1]
            end
            GetCharacters(target, function(characters)
                if characters == nil or #characters < 1 then
                    TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^1Error ^0] ", "No characters found."}})
                else
                    local char = characters[1]
                    local name = ("%s %s"):format(char.first, char.last)
                    local dob = char.dob
                    if char.img == "statics/images/blank_user.jpg" then
                        char.img = "https://sonorancad.com/statics/images/blank_user.jpg"
                    end
                    if pluginConfig.enableIDCardUI then
                        TriggerClientEvent("SonoranCAD::civint:DisplayID", source, char.img, target, name, dob)
                    else
                        TriggerClientEvent("pNotify:SendNotification", source, {
                            text = ("<h3>ID Lookup</h3><img width=\"96px\" height=\"128px\" align=\"left\" src=\"%s\"></image><p><strong>Player ID:</strong> %s </p><p><strong>Name:</strong> %s </p><p><strong>Date of Birth:</strong> %s</p>"):format(char.img, target, name, dob),
                            type = "success",
                            layout = "bottomcenter",
                            timeout = "10000"
                        })
                    end
                end
            end)
        end)

        if pluginConfig.allowCustomIds then
            RegisterCommand("setid", function(source, args, rawCommand)
                TriggerClientEvent("SonoranCAD::civintegration:SetCustomId", source)
            end)
        
            RegisterCommand("resetid", function(source, args, rawCommand)
                if CustomCharacterCache[source] ~= nil then
                    CustomCharacterCache[source] = nil
                    TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^2OK ^0] ", "Custom character removed."}})
                end
            end)

            RegisterNetEvent("SonoranCAD::civintegration:SetCustomId")
            AddEventHandler("SonoranCAD::civintegration:SetCustomId", function(id)
                CustomCharacterCache[source] = {{ ['first'] = id.first, ['last'] = id.last, ['dob'] = id.dob, img = "https://sonorancad.com/statics/images/blank_user.jpg" }}
            end)
        end

        if pluginConfig.allowPurge then
            RegisterCommand("refreshid", function(source, args, rawCommand)
                CharacterCacheTimers[source] = 0
                TriggerClientEvent("chat:addMessage", source, {args = {"^0[ ^2OK ^0] ", "Reset character list. Use /showid again."}})
            end)
        end
    end

    
end