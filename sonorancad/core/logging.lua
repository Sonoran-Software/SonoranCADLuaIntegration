local function sendConsole(level, color, message)
    print(("[SonoranCAD:%s%s^7]%s %s^0"):format(color, level, color, message))
end

function debugLog(message)
    if Config.debugMode then
        sendConsole("DEBUG", "^7", message)
    end
end

function debugPrint(message)
    debugLog(message)
end

function errorLog(message)
    sendConsole("ERROR", "^8", message)
end

function warnLog(message)
    sendConsole("WARNING", "^3", message)
end

function infoLog(message)
    sendConsole("INFO", "^5", message)
end

-- command to toggle debug mode, console only
RegisterCommand("caddebug", function()
    if source ~= nil then
        print("Console only command!")
        return
    end
    Config.debugMode = not Config.debugMode
    infoLog(("Debug mode toggled to %s"):format(Config.debugMode))
end, true)

RegisterServerEvent("SonoranCAD::core:writeLog")
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

print([[
    _____                                    _________    ____     
    / ___/____  ____  ____  _________ _____  / ____/   |  / __ \    
    \__ \/ __ \/ __ \/ __ \/ ___/ __ `/ __ \/ /   / /| | / / / /    
   ___/ / /_/ / / / / /_/ / /  / /_/ / / / / /___/ ___ |/ /_/ /     
  /____/\____/_/ /_/\____/_/   \__,_/_/ /_/\____/_/  |_/_____/      
                                                                    
]])
infoLog("Starting up...")