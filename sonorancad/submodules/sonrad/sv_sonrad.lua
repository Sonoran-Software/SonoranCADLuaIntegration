--[[
    Sonaran CAD Plugins

    Plugin Name: sonrad
    Creator: Sonoran Software Systems
    Description: Sonoran Radio integration plugin

    Put all server-side logic in this file.
]]

CreateThread(function() Config.LoadPlugin("sonrad", function(pluginConfig)

    if pluginConfig.enabled then

        local CallCache = {}
        local UnitCache = {}
        local TowerCache = {}

        
        if Config.apiVersion > 3 then
            -- Register Api Types
            registerApiType("ADD_BLIP", "emergency")
            registerApiType("MODIFY_BLIP", "emergency")
            registerApiType("REMOVE_BLIP", "emergency")
            registerApiType("GET_BLIPS", "emergency")
            
            BlipMan = {
                addBlip = function(coords, radius, colorHex, subType, toolTip, icon, dataTable, cb)
                    local data = {{
                        ["serverId"] = GetConvar("sonoran_serverId", 1),
                        ["blip"] = {
                            ["id"] = -1,
                            ["subType"] = subType,
                            ["coordinates"] = {
                                ["x"] = coords.x,
                                ["y"] = coords.y
                            },
                            ["radius"] = radius,
                            ["icon"] = icon,
                            ["color"] = colorHex,
                            ["tooltip"] = toolTip,
                            ["data"] = dataTable
                        }
                    }}
                    
                    performApiRequest(data, "ADD_BLIP", function(res)
                        if cb ~= nil then
                            cb(res)
                        end
                    end)
                end,
        
                addBlips = function(blips, cb)
                    performApiRequest(blips, "ADD_BLIP", function(res)
                        if cb ~= nil then
                            cb(res)
                        end
                    end)
                end,
        
                removeBlip = function(ids, cb)
                    performApiRequest({{
                        ["ids"] = ids
                    }}, "REMOVE_BLIP", function(res)
                        if cb ~= nil then
                            cb(res)
                        end
                    end)
                end,
        
                modifyBlips = function(dataTable, cb)
                    performApiRequest(dataTable, "MODIFY_BLIP", function(res)
                        if cb ~= nil then
                            cb(res)
                        end
                    end)
                end,

                getBlips = function(cb)
                    local data = {{
                        ["serverId"] = GetConvar("sonoran_serverId", 1)
                    }}
                    performApiRequest(data, "GET_BLIPS", function(res)
                        if cb ~= nil then
                            cb(res)
                        end
                    end)
                end,
        
                removeWithSubtype = function(subType, cb)
                    BlipMan.getBlips(function(res)
                        local dres = json.decode(res)
                        local ids = {}
                        for _, v in ipairs(dres) do
                            if v.subType == subType then
                                table.insert(ids, #ids + 1, v.id)
                            end
                        end
                        BlipMan.removeBlip(ids, cb)
                    end)
                end,
            }

            function GetTower(coords)
                for i = 1, #TowerCache do
                    if TowerCache[i].PropPosition == coords then
                        return TowerCache[i], i
                    end
                end
                return nil, nil
            end
            function GetTowerFromId(id)
                for i, t in ipairs(TowerCache) do
                    if t.Id == id then
                        return t, i
                    end
                end
            end
            function GetTowerCapacity(tower)
                if #tower.DishStatus < 1 then
                    return 1.0
                end
            
                local n = 0.0
                for i = 1, #tower.DishStatus do
                    if tower.DishStatus[i] == 'alive' then
                        n = n + 1.0
                    end
                end
                return n / #tower.DishStatus
            end

            RegisterNetEvent("SonoranCAD::sonrad:SyncTowers")
            AddEventHandler("SonoranCAD::sonrad:SyncTowers", function(Towers)
                BlipMan.removeWithSubtype("repeater", function(res)
                    debugLog(res)

                    TowerCache = Towers

                    local BlipQueue = {}

                    debugLog(json.encode(TowerCache))
                    for _,t in ipairs(TowerCache) do

                        if TowerCache[i].NotPhysical then
                            -- Handling for Mobile Repeaters
                            title = "Mobile Repeater"
                            color = "#ff00f6"
                            status = "MOBILE"
                        else
                            -- Handling for Stationary Repeaters
                            title = "Radio Tower"
                            color = "#00a6ff"
                            status = "HEALTHY"
                        end

                        local CurrentBlip = {
                            ["serverId"] = GetConvar("sonoran_serverId", 1),
                            ["blip"] = {
                                ["id"] = -1,
                                ["subType"] = "repeater",
                                ["coordinates"] = {
                                    ["x"] = t.PropPosition.x,
                                    ["y"] = t.PropPosition.y
                                },
                                ["radius"] = t.Range * 0.7937,
                                ["icon"] = "https://sonoransoftware.com/assets/images/icons/email/radio.png",
                                ["color"] = color,
                                ["tooltip"] =  title,
                                ["data"] = {
                                    {
                                        ["title"] = "Status",
                                        ["text"] = status,
                                    }
                                }
                            }
                        }

                        table.insert(BlipQueue, #BlipQueue + 1, CurrentBlip)
                    end

                    BlipMan.addBlips(BlipQueue, function(res)
                        local blips = json.decode(res)
                        for i=1, #TowerCache do
                            TowerCache[i].BlipID = blips[i].id
                        end
                        debugLog("Tower Cache:" .. json.encode(TowerCache))
                    end)
                end)
            end)
                        
            CreateThread(function()
                while true do
                    Wait(5000)
                    for i=1, #TowerCache do
                        if TowerCache[i].Modified then
                            debugLog("Change found during batch... Sending")
                            TowerCache[i].Modified = false
                            local color = nil
                            local status = nil
                            local title = nil
                            if TowerCache[i].NotPhysical then
                                -- Handling for Mobile Repeaters
                                title = "Mobile Repeater"
                                color = "#ff00f6"
                                status = "MOBILE"
                            else
                                -- Handling for Stationary Repeaters
                                title = "Radio Tower"
                                color = "#00a6ff"
                                status = "HEALTHY"
                            end
                            local data = {{
                                ["id"] = TowerCache[i].BlipID,
                                ["subType"] = "repeater",
                                ["coordinates"] = {
                                    ["x"] = TowerCache[i].PropPosition.x,
                                    ["y"] = TowerCache[i].PropPosition.y
                                },
                                ["radius"] = TowerCache[i].Range * 0.7937,
                                ["icon"] = "https://sonoransoftware.com/assets/images/icons/email/radio.png",
                                ["color"] = color,
                                ["tooltip"] = title,
                                ["data"] = {
                                    {
                                        ["title"] = "Health",
                                        ["text"] = status
                                    }
                                }
                            }}
                            BlipMan.modifyBlips(data, function(res)
                                debugLog(res)
                            end)
                        else
                            --debugLog("No changes during batch... Ignoring")
                        end
                    end
                end
            end)

            RegisterNetEvent("SonoranCAD::sonrad:SyncOneTower")
            AddEventHandler("SonoranCAD::sonrad:SyncOneTower", function(towerId, newTower)
                local oldTower, towerIndex = GetTowerFromId(towerId)
                local BlipID = oldTower.BlipID
                if oldTower.PropPosition.x == newTower.PropPosition.x and oldTower.PropPosition.y == newTower.PropPosition.y then
                    --debugLog("No Changes During Sync... Ignoring" .. towerIndex)
                else
                    debugLog("Changes found during sync... Queuing" .. towerIndex)
                    TowerCache[towerIndex] = newTower
                    TowerCache[towerIndex].BlipID = BlipID
                    TowerCache[towerIndex].Modified = true
                end
            end)

            RegisterNetEvent("SonoranCAD::sonrad:SetDishStatus")
            AddEventHandler("SonoranCAD::sonrad:SetDishStatus", function(towerId, dishStatus)
                local tower = GetTowerFromId(towerId)
                if not tower then return end
                tower.DishStatus = dishStatus
                local pct = GetTowerCapacity(tower)
                local color = nil
                local status = nil
                if pct == 1 then
                    -- Tower is alive and well.
                    debugLog("TOWER IS HEALTHY")
                    color = "#00a6ff"
                    status = "HEALTHY"
                elseif pct == 0 then
                    -- Tower is offline
                    debugLog("TOWER IS OFFLINE")
                    color = "#ff0000"
                    status = "OFFLINE"
                else
                    -- Tower is degraded
                    debugLog("TOWER IS DEGRADED")
                    color = "#ff8c00"
                    status = "DEGRADED"
                end

                local data = {{
                    ["id"] = tower.BlipID,
                    ["subType"] = "repeater",
                    ["coordinates"] = {
                        ["x"] = tower.PropPosition.x,
                        ["y"] = tower.PropPosition.y
                    },
                    ["radius"] = tower.Range * 0.7937,
                    ["icon"] = "https://sonoransoftware.com/assets/images/icons/email/radio.png",
                    ["color"] = color,
                    ["tooltip"] =  "Radio Tower",
                    ["data"] = {
                        {
                            ["title"] = "Health",
                            ["text"] = status,
                        }
                    }
                }}
                BlipMan.modifyBlips(data, function(res)
                    debugLog(res)
                end)
            end)
        else
            debugLog("Disabling blip management, API version too low.")
        end
        

        CreateThread(function()
            while true do
                Wait(5000)
                CallCache = GetCallCache()
                UnitCache = GetUnitCache()
                for k, v in pairs(CallCache) do
                    v.dispatch.units = {}
                    if v.dispatch.idents then
                        for ka, va in pairs(v.dispatch.idents) do
                            local unit
                            local unitId = GetUnitById(va)
                            table.insert(v.dispatch.units, UnitCache[unitId])
                        end
                    end
                end
            end
        end)

        RegisterNetEvent("SonoranCAD::sonrad:GetCurrentCall")
        AddEventHandler("SonoranCAD::sonrad:GetCurrentCall", function()
            local playerid = source
            local unit = GetUnitByPlayerId(source)
            -- print("unit: " .. json.encode(unit))
            for k, v in pairs(CallCache) do
                if v.dispatch.idents then
                    -- print(json.encode(v))
                    for ka, va in pairs(v.dispatch.idents) do
                        -- print("Comparing " .. unit.id .. " to " .. va)
                        if unit then
                            if unit.id == va then
                                TriggerClientEvent("SonoranCAD::sonrad:UpdateCurrentCall", source, v)
                                -- print("SonoranCAD::sonrad:UpdateCurrentCall " .. source .. " " .. json.encode(v))
                            end
                        end
                    end
                end
            end
        end)

        RegisterNetEvent("SonoranCAD::sonrad:RadioPanic")
        AddEventHandler("SonoranCAD::sonrad:RadioPanic", function()
            if not isPluginLoaded("callcommands") then
                errorLog("Cannot process radio panic as the required callcommands plugin is not present.")
                return
            end
            sendPanic(source, true)
        end)

        RegisterNetEvent("SonoranCAD::sonrad:GetUnitInfo")
        AddEventHandler("SonoranCAD::sonrad:GetUnitInfo", function()
            local unit = GetUnitByPlayerId(source)
            if unit then
                TriggerClientEvent("SonoranCAD::sonrad:GetUnitInfo:Return", source, unit)
            end
        end)
    end

end) end)
