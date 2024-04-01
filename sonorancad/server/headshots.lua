-- source: https://github.com/loaf-scripts/loaf_headshot_base64/blob/main/client.lua

local requests = {}

local function GenerateId()
    local id = ""
    for i = 1, 15 do
        id = id .. (math.random(1, 2) == 1 and string.char(math.random(97, 122)) or tostring(math.random(0,9)))
    end
    return id
end

local function ClearHeadshots()
    for i = 1, 255 do
        if IsPedheadshotValid(i) then 
            UnregisterPedheadshot(i)
        end
    end
end

function GetHeadshot(ped)
    ClearHeadshots()
    if not ped then ped = PlayerPedId() end
    if DoesEntityExist(ped) then
        local handle, timer = RegisterPedheadshot(ped), GetGameTimer() + 5000
        while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
            Wait(50)
            if GetGameTimer() >= timer then
                return {success=false, error="Could not load ped headshot."}
            end
        end

        local txd = GetPedheadshotTxdString(handle)
        local url = string.format("https://nui-img/%s/%s", txd, txd)
        return {success=true, url=url, txd=txd, handle=handle}
    end
end

function GetBase64(ped)
    if not ped then ped = PlayerPedId() end
    local headshot = GetHeadshot(ped)
    if headshot.success then
        local requestId = GenerateId()
        requests[requestId] = nil
        SendNUIMessage({
            type = "convert_base64",
            img = headshot.url,
            handle = headshot.handle,
            id = requestId
        })

        local timer = GetGameTimer() + 5000
        while not requests[requestId] do
            Wait(250)
            if GetGameTimer() >= timer then
                return {success=false, error="Waiting for base64 conversion timed out."}
            end
        end
        return {success=true, base64=requests[requestId]}
    else
        return headshot
    end
end

RegisterNUICallback("base64", function(data, cb)
    if data.handle then
        UnregisterPedheadshot(data.handle)
    end
    if data.id then
        requests[data.id] = data.base64
        Wait(1500)
        requests[data.id] = nil
    end

    cb({ok=true})
end)

exports("getBase64", GetBase64)