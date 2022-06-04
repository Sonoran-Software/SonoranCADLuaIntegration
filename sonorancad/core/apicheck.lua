registerApiType("CHECK_APIID", "general")

function cadApiIdExists(apiId, callback)
    if apiId == "" or apiId == nil then
        debugLog("cadApiIdExists: No API ID specified, assuming false.")
        callback(false)
    else
        performApiRequest({{["apiId"] = apiId}}, "CHECK_APIID", function(res, exists)
            callback(exists)
        end)
    end
end

RegisterCommand("forcecheck", function(source, args, rawCommand)
    performApiRequest({{["apiId"] = args[1]}}, "CHECK_APIID", function(res, exists)
        print("exists: "..tostring(exists))
    end)
end)

RegisterServerEvent("SonoranCAD::apicheck:CheckPlayerLinked")
AddEventHandler("SonoranCAD::apicheck:CheckPlayerLinked", function(player)
    local identifier = GetIdentifiers(player)[Config.primaryIdentifier]
    cadApiIdExists(identifier, function(exists)
        TriggerEvent("SonoranCAD::apicheck:CheckPlayerLinkedResponse", player, identifier, exists)
    end)
end)

exports('CadIsPlayerLinked', cadApiIdExists)

RegisterCommand("apiid", function(source, args, rawCommand)
    local identifiers = GetIdentifiers(source)
    local pid = nil
    if isPluginLoaded("esxsupport") then
        local type = Config.plugins["esxsupport"].identityType
        if identifiers[type] ~= nil then
            if Config.plugins["esxsupport"].usePrefix then
                pid = ("%s:%s"):format(type, identifiers[type])
            else
                pid = identifiers[type]
            end
        end
    elseif isPluginLoaded("frameworksupport") then
        local type = Config.plugins["frameworksupport"].identityType
        if identifiers[type] ~= nil then
            if Config.plugins["frameworksupport"].usePrefix then
                pid = ("%s:%s"):format(type, identifiers[type])
            else
                pid = identifiers[type]
            end
        end
    else
        if identifiers[Config.primaryIdentifier] ~= nil then
            pid = identifiers[Config.primaryIdentifier]
        end
    end
    if pid ~= nil then
        print("Your API ID: "..tostring(pid))
    else
        print("API ID not found")
    end
end)

if Config.forceSetApiId == nil then Config.forceSetApiId = false end

if Config.forceSetApiId then
    debugLog("forceSetApiId enabled")
    RegisterNetEvent("sonoran:tablet:forceCheckApiId")
    AddEventHandler("sonoran:tablet:forceCheckApiId", function()
        local identifier=GetIdentifiers(source)[Config.primaryIdentifier]
        local plid=source
    
        cadApiIdExists(identifier, function(exists)
            if not exists then
                TriggerClientEvent("sonoran:tablet:apiIdNotFound", plid)
            else
                TriggerClientEvent("sonoran:tablet:apiIdFound", plid)
            end
        end)
    end)
    
    RegisterNetEvent("sonoran:tablet:setApiId")
    AddEventHandler("sonoran:tablet:setApiId", function(session,username)
        local identifier=GetIdentifiers(source)[Config.primaryIdentifier]
        local source = source
        cadApiIdExists(identifier, function(exists)
            if not exists then
                
                registerApiType("SET_API_ID", "general")
                
                local data = {{
                        ["apiIds"] = { identifier },
                        ["sessionId"] = session,
                        ["username"] = username
                }}
                
                performApiRequest(data, "SET_API_ID", function(res, flag)
                    if (not flag) then
                        TriggerClientEvent("sonoran:tablet:failed", source, res)
                    end
                end)
                
            end
        end)
        
        
    end)

end