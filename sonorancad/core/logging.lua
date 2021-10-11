local MessageBuffer = {}

local function LocalTime()
	local _, _, _, h, m, s = GetLocalTime()
	return '' .. h .. ':' .. m .. ':' .. s
end

local function sendConsole(level, color, message)
    local debugging = true
    if Config ~= nil then
        debugging = (Config.debugMode == true and Config.debugMode ~= "false")
    end
    local time = os and os.date("%X") or LocalTime()
    local info = debug.getinfo(3, 'S')
    local source = "."
    if info.source:find("@@sonorancad") then
        source = info.source:gsub("@@sonorancad/","")..":"..info.linedefined
    end
    local msg = ("[%s][%s:%s%s^7]%s %s^0"):format(time, debugging and source or "SonoranCAD", color, level, color, message)
    print(msg)
    if not IsDuplicityVersion() then
        if #MessageBuffer > 10 then
            table.remove(MessageBuffer)
        end
        table.insert(MessageBuffer, 1, msg)
    end
end

function debugLog(message)
    if Config == nil then
        return
    elseif ((Config.debugMode == true or Config.debugMode == "true") and Config.debugMode ~= "false") then
        
        sendConsole("DEBUG", "^7", message)
    end
end

function debugPrint(message)
    debugLog(message)
end

function errorLog(message)
    sendConsole("ERROR", "^1", message)
end

function warnLog(message)
    sendConsole("WARNING", "^3", message)
end

function infoLog(message)
    sendConsole("INFO", "^5", message)
end

--RegisterServerEvent("SonoranCAD::core:writeLog")
AddEventHandler("SonoranCAD::core:writeLog", function(level, message)
    if level == "debug" then
        debugLog(message)
    elseif level == "info" then
        infoLog(message)
    elseif level == "error" then
        errorLog(message)
    else
        debugLog(message)
    end
end)

RegisterNetEvent("SonoranCAD::core:RequestLogBuffer")
AddEventHandler("SonoranCAD::core:RequestLogBuffer", function()
    if not IsDuplicityVersion() then
        TriggerServerEvent("SonoranCAD::core:LogBuffer", MessageBuffer)
        print("log buffer requested")
    end
end)

print(("^5%s^0"):format([[
    _____                                    _________    ____     
   / ___/____  ____  ____  _________ _____  / ____/   |  / __ \    
   \__ \/ __ \/ __ \/ __ \/ ___/ __ `/ __ \/ /   / /| | / / / /    
  ___/ / /_/ / / / / /_/ / /  / /_/ / / / / /___/ ___ |/ /_/ /     
 /____/\____/_/ /_/\____/_/   \__,_/_/ /_/\____/_/  |_/_____/      
                                                                   
]]))
infoLog("Starting up...")