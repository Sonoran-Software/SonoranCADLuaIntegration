RegisterServerEvent('sonorancad:getIdentity')
AddEventHandler('sonorancad:getIdentity', function(target)
    local returnData = GetIdentity(target)
    local src = source
    TriggerClientEvent('sonorancad:returnIdentity', src, returnData)
end)

function GetIdentity(target)
    local identifier = GetPlayerIdentifiers(target)[1]
    local result = MySQL.Sync.fetchAll("SELECT firstname, lastname, sex, dateofbirth, height FROM users WHERE identifier = @identifier", {
            ['@identifier'] = identifier
    })
    local returnData = nil
    if result[1] ~= nil then
        local user = result[1]
    
        return {
            firstname = user['firstname'],
            lastname = user['lastname'],
            dateofbirth = user['dateofbirth'],
            sex = user['sex'],
            height = user['height'],
            name = user['name']
        }
    else
        return nil
    end
end

RegisterNetEvent('esx_identity:characterUpdated')
AddEventHandler('esx_identity:characterUpdated', function(playerId, data)
    TriggerClientEvent('sonorancad:characterUpdated', playerId, data)
end)
