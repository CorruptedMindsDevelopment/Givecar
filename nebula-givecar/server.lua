ESX = exports["es_extended"]:getSharedObject()

-- Register the command to give a car to a player
RegisterCommand('givecar', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getGroup() == 'admin' then
        local targetId = tonumber(args[1])
        local vehicleModel = args[2]
        
        if targetId and vehicleModel then
            local targetPlayer = ESX.GetPlayerFromId(targetId)
            
            if targetPlayer then
                local plate = GeneratePlate()
                local vehProps = {
                    model = GetHashKey(vehicleModel),
                    plate = plate
                }
                
                -- Save vehicle in the database (owned_vehicles table) using oxmysql
                exports.oxmysql:execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, job, stored) VALUES (?, ?, ?, ?, ?, ?)', {
                    targetPlayer.identifier,
                    plate,
                    json.encode(vehProps),
                    'car',
                    'civ', -- adjust based on your setup
                    true -- ensure the car is stored in the garage
                }, function(result)
                    if result and result.affectedRows > 0 then
                        TriggerClientEvent('esx:showNotification', targetPlayer.source, 'You have received a new vehicle with plate ' .. plate)
                        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vehicle has been given successfully.')
                    else
                        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Failed to give the vehicle.')
                    end
                end)
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Player not found.')
            end
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Invalid arguments. Usage: /givecar [playerId] [vehicleModel]')
        end
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'You don\'t have permission to use this command.')
    end
end, false)

function GeneratePlate()
    local plate = ''
    local charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    for i = 1, 8 do
        local rand = math.random(1, #charset)
        plate = plate .. charset:sub(rand, rand)
    end
    return plate
end
