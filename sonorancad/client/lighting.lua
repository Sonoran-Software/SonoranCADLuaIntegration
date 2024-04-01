light_port = 9990
light_last_event = "restore"

local function runEvent(event)
    if event == nil then
        return
    end
    if event == light_last_event or (light_last_event == "panic" and event ~= "restore") then
        return
    end
    light_last_event = event
    debugLog("send light event "..json.encode({ type = "light_event", event = event, port = light_port }))
    SendNUIMessage({ type = "light_event", event = event, port = light_port })
end

local function vehicleSignalState(veh)
    local lights = GetVehicleIndicatorLights(veh)
    if lights ~= nil then
        if lights == 0 then
            return "restore"
        elseif lights == 1 then
            return "left"
        elseif lights == 2 then
            return "right"
        elseif lights == 3 then
            return "hazard"
        else
            return "restore"
        end
    else
        return "restore"
    end
end

local function vehicleEmergencyState(veh)
    return (IsVehicleSirenOn(veh) == 1)
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(10)
    end
    while true do
        local ped = GetPlayerPed(PlayerId())
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh then
                if vehicleEmergencyState(veh) then
                    runEvent("lights")
                else
                    local state = vehicleSignalState(veh)
                    if state ~= light_last_event then
                        runEvent(state)
                    end
                end
            end
        else
            runEvent("restore")
        end
        Wait(1000)
    end
end)

RegisterCommand("setlightport", function(source, args, rawCommand)
    local port = args[1]
    if args[1] == nil or not tonumber(args[1]) then
        return print("Invalid argument.")
    end
    port = tonumber(port)
    if port < 1 or port > 65535 then
        return print("Invalid port")
    end
    light_port = port
end)