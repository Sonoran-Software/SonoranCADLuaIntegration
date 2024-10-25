--[[
    Sonaran CAD Plugins
    Plugin Name: fivepd
    Creator: SonoranCAD
    Description: Callouts and Record Sync with FivePD
]]

CreateThread(function()
    Config.LoadPlugin("fivepd", function(pluginConfig)
        if pluginConfig.enabled then
            local postalsConfig = Config.GetPluginConfig('postals')
            registerApiType("NEW_DISPATCH", "emergency")

            -- New Callout Handler
            function CreateNewCallout(src, callName, callDesc, callResponse, callLocation, callCoord)
                local identifier = GetIdentifiers(src)[Config.primaryIdentifier]
                local units = {identifier}
                local notes = ""
                local postal = ""
                if postalsConfig and postalsConfig.enabled then
                    postal = getPostalFromVector3(callCoord) or ""
                end

                local data = {
                    ['serverId'] = Config.serverId,
                    ['origin'] = pluginConfig.origin,
                    ['status'] = pluginConfig.status,
                    ['priority'] = callResponse,
                    ['block'] = "", -- not used, but required
                    ['postal'] = postal,
                    ['address'] = callLocation ~= nil and callLocation or 'Unknown',
                    ['title'] = callName,
                    ['code'] = pluginConfig.code, -- TODO
                    ['description'] = callDesc,
                    ['units'] = units,
                    ['notes'] = {} -- required but empty
                }

                debugLog("Sending New Callout")
                performApiRequest({data}, 'NEW_DISPATCH', function() end)
            end

            RegisterServerEvent("SonoranCAD::fivepd:CalloutReceived", function(src, callIdent, callId, callName, callDesc, callResponse, callLocX, callLocY, callLocZ)
                -- This Event doesn't seem to trigger so I didn't use it.
            end)
            RegisterServerEvent("SonoranCAD::fivepd:CalloutAccepted", function(src, callIdent, callId, callName, callDesc, callResponse, callLocation, callCoord)
                CreateNewCallout(src, callName, callDesc, callResponse, callLocation, callCoord)
            end)
            RegisterServerEvent("SonoranCAD::fivepd:CalloutCompleted", function(src, callIdent, callId, callName, callDesc, callResponse, callLocX, callLocY, callLocZ)
                print(src .. " completed callout: " .. json.encode(callout))

            end)
            RegisterServerEvent("SonoranCAD::fivepd:DutyStatusChange", function(src, onDuty)
                print(src .. " is on duty: " .. tostring(onDuty))

            end)
            RegisterServerEvent("SonoranCAD::fivepd:ServiceCalled", function(src, service)
                print(src .. " called for: " .. tostring(service))

            end)
            RegisterServerEvent("SonoranCAD::fivepd:RankChanged", function(src, rank)
                print(src .. " is now rank: " .. tostring(rank))

            end)
            RegisterServerEvent("SonoranCAD::fivepd:PedArrested", function(src, pedData)
                print(src .. " arrested ped: " .. tostring(pedData.FirstName) .. " " .. tostring(pedData.LastName))

            end)

        end

    end)
end)
