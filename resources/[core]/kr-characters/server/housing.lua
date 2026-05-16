RegisterNetEvent('kr-characters:purchaseProperty')
AddEventHandler('kr-characters:purchaseProperty', function(propertyId)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local propertyId = tonumber(propertyId)

    if not character or not propertyId then return end

    MySQL.Async.fetchAll('SELECT price, owned, owner FROM properties WHERE id = @propertyId', {
        ['@propertyId'] = propertyId
    }, function(result)
        if result[1] then
            local price = result[1].price
            local owned = result[1].owned

            if owned == 0 then
                if character.cash >= price then
                    MySQL.Async.execute('UPDATE properties SET owned = 1, owner = @owner WHERE id = @propertyId', {
                        ['@owner'] = character.id,
                        ['@propertyId'] = propertyId
                    }, function()
                        MySQL.Async.execute('UPDATE player_characters SET cash = cash - @price WHERE id = @id', {
                            ['@price'] = price,
                            ['@id'] = character.id
                        }, function()
                            character.cash = character.cash - price
                            TriggerClientEvent('kr-core:updateCash', source, character.cash)
                            TriggerClientEvent('kr-characters:purchaseSuccess', source, propertyId)
                            TriggerEvent('kr-characters:propertyPurchased', source, propertyId, character.id)
                        end)
                    end)
                else
                    TriggerClientEvent('kr-characters:purchaseFailed', source, 'Not enough money')
                end
            else
                TriggerClientEvent('kr-characters:purchaseFailed', source, 'Property already owned')
            end
        else
            TriggerClientEvent('kr-characters:purchaseFailed', source, 'Property not found')
        end
    end)
end)

RegisterNetEvent('kr-characters:sellProperty')
AddEventHandler('kr-characters:sellProperty', function(propertyId)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local propertyId = tonumber(propertyId)

    if not character or not propertyId then return end

    MySQL.Async.fetchAll('SELECT price, owned, owner FROM properties WHERE id = @propertyId', {
        ['@propertyId'] = propertyId
    }, function(result)
        if result[1] then
            local price = result[1].price
            local owned = result[1].owned
            local owner = result[1].owner

            if owned == 1 and owner == character.id then
                local sellPrice = math.floor(price * 0.75)

                MySQL.Async.execute('UPDATE properties SET owned = 0, owner = NULL WHERE id = @propertyId', {
                    ['@propertyId'] = propertyId
                }, function()
                    MySQL.Async.execute('UPDATE player_characters SET cash = cash + @price WHERE id = @id', {
                        ['@price'] = sellPrice,
                        ['@id'] = character.id
                    }, function()
                        character.cash = character.cash + sellPrice
                        TriggerClientEvent('kr-core:updateCash', source, character.cash)
                        TriggerClientEvent('kr-characters:sellSuccess', source, propertyId, sellPrice)
                        TriggerEvent('kr-characters:propertySold', source, propertyId, character.id, sellPrice)
                    end)
                end)
            else
                TriggerClientEvent('kr-characters:sellFailed', source, 'You do not own this property')
            end
        else
            TriggerClientEvent('kr-characters:sellFailed', source, 'Property not found')
        end
    end)
end)

RegisterNetEvent('kr-characters:rentProperty')
AddEventHandler('kr-characters:rentProperty', function(propertyId)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local propertyId = tonumber(propertyId)

    if not character or not propertyId then return end

    MySQL.Async.fetchAll('SELECT rent, owned, owner FROM properties WHERE id = @propertyId', {
        ['@propertyId'] = propertyId
    }, function(result)
        if result[1] then
            local rent = result[1].rent
            local owned = result[1].owned

            if owned == 0 then
                if character.cash >= rent then
                    MySQL.Async.execute('UPDATE properties SET owned = 1, owner = @owner WHERE id = @propertyId', {
                        ['@owner'] = character.id,
                        ['@propertyId'] = propertyId
                    }, function()
                        MySQL.Async.execute('UPDATE player_characters SET cash = cash - @rent WHERE id = @id', {
                            ['@rent'] = rent,
                            ['@id'] = character.id
                        }, function()
                            character.cash = character.cash - rent
                            TriggerClientEvent('kr-core:updateCash', source, character.cash)
                            TriggerClientEvent('kr-characters:rentSuccess', source, propertyId, rent)
                            TriggerEvent('kr-characters:propertyRented', source, propertyId, character.id, rent)
                        end)
                    end)
                else
                    TriggerClientEvent('kr-characters:rentFailed', source, 'Not enough money for rent')
                end
            else
                TriggerClientEvent('kr-characters:rentFailed', source, 'Property already rented/owned')
            end
        else
            TriggerClientEvent('kr-characters:rentFailed', source, 'Property not found')
        end
    end)
end)

RegisterNetEvent('kr-characters:evictFromProperty')
AddEventHandler('kr-characters:evictFromProperty', function(propertyId)
    local source = source
    local propertyId = tonumber(propertyId)

    if not propertyId then return end

    if IsPlayerAceAllowed(source, 'command') or source == 0 then
        MySQL.Async.fetchAll('SELECT owner FROM properties WHERE id = @propertyId', {
            ['@propertyId'] = propertyId
        }, function(result)
            if result[1] and result[1].owner then
                MySQL.Async.execute('UPDATE properties SET owned = 0, owner = NULL WHERE id = @propertyId', {
                    ['@propertyId'] = propertyId
                }, function()
                    TriggerClientEvent('kr-characters:evictedFromProperty', source, propertyId)
                    TriggerEvent('kr-characters:propertyEvicted', source, propertyId, result[1].owner)
                end)
            else
                TriggerClientEvent('kr-characters:evictFailed', source, 'Property is not owned')
            end
        end)
    else
        TriggerClientEvent('kr-characters:evictFailed', source, 'Insufficient permissions')
    end
end)

RegisterNetEvent('kr-characters:getPlayerProperties')
AddEventHandler('kr-characters:getPlayerProperties', function()
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)

    if not character then return end

    MySQL.Async.fetchAll('SELECT p.id, p.name, p.label, p.price, p.rent FROM properties p WHERE p.owner = @owner', {
        ['@owner'] = character.id
    }, function(result)
        TriggerClientEvent('kr-characters:returnPlayerProperties', source, result or {})
    end)
end)

RegisterNetEvent('kr-characters:getAllProperties')
AddEventHandler('kr-characters:getAllProperties', function()
    local source = source

    MySQL.Async.fetchAll('SELECT id, name, label, price, rent, owned, owner FROM properties', {}, function(result)
        TriggerClientEvent('kr-characters:returnAllProperties', source, result or {})
    end)
end)

AddEventHandler('kr-core:playerLoaded', function(character)
    TriggerClientEvent('kr-characters:loadProperties', character.source)
end)

CreateThread(function()
    while true do
        Wait(86400000)

        MySQL.Async.fetchAll('SELECT id, owner, rent FROM properties WHERE owned = 1 AND owner IS NOT NULL', {}, function(result)
            for _, property in ipairs(result) do
                local ownerId = property.owner
                local rent = property.rent

                if ownerId and rent and rent > 0 then
                    MySQL.Async.fetchScalar('SELECT id, cash FROM player_characters WHERE id = @id', {
                        ['@id'] = ownerId
                    }, function(ownerChar)
                        if ownerChar then
                            if ownerChar.cash >= rent then
                                MySQL.Async.execute('UPDATE player_characters SET cash = cash - @rent WHERE id = @id', {
                                    ['@rent'] = rent,
                                    ['@id'] = ownerId
                                })
                                print(('Rent collected: character %d paid $%d'):format(ownerId, rent))
                            else
                                MySQL.Async.execute('UPDATE properties SET owned = 0, owner = NULL WHERE id = @propertyId', {
                                    ['@propertyId'] = property.id
                                })
                                print(('Evicted character %d for not paying rent on property %d'):format(ownerId, property.id))
                            end
                        end
                    end)
                end
            end
        end)
    end
end)
