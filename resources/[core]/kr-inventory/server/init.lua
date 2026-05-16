RegisterNetEvent('kr-inventory:giveItem')
AddEventHandler('kr-inventory:giveItem', function(itemName, count)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local count = tonumber(count) or 1

    if not character or not itemName or count <= 0 then return end

    MySQL.Async.fetchScalar('SELECT id, count FROM items WHERE character_id = @characterId AND name = @itemName', {
        ['@characterId'] = character.id,
        ['@itemName'] = itemName
    }, function(existingItemId)
        if existingItemId then
            MySQL.Async.execute('UPDATE items SET count = count + @count WHERE id = @itemId', {
                ['@count'] = count,
                ['@itemId'] = existingItemId
            }, function()
                TriggerClientEvent('kr-inventory:itemUpdate', source, itemName, count, 'add')
            end)
        else
            MySQL.Async.execute('INSERT INTO items (character_id, name, label, count, weight) VALUES (@characterId, @itemName, @label, @count, @weight)', {
                ['@characterId'] = character.id,
                ['@itemName'] = itemName,
                ['@label'] = itemName,
                ['@count'] = count,
                ['@weight'] = 1.0
            }, function()
                TriggerClientEvent('kr-inventory:itemUpdate', source, itemName, count, 'add')
            end)
        end
    end)
end)

RegisterNetEvent('kr-inventory:removeItem')
AddEventHandler('kr-inventory:removeItem', function(itemName, count)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local count = tonumber(count) or 1

    if not character or not itemName or count <= 0 then return end

    MySQL.Async.fetchAll('SELECT id, count FROM items WHERE character_id = @characterId AND name = @itemName', {
        ['@characterId'] = character.id,
        ['@itemName'] = itemName
    }, function(result)
        if result[1] then
            local itemId = result[1].id
            local currentCount = result[1].count

            if currentCount >= count then
                local newCount = currentCount - count
                if newCount > 0 then
                    MySQL.Async.execute('UPDATE items SET count = @count WHERE id = @itemId', {
                        ['@count'] = newCount,
                        ['@itemId'] = itemId
                    })
                else
                    MySQL.Async.execute('DELETE FROM items WHERE id = @itemId', {
                        ['@itemId'] = itemId
                    })
                end
                TriggerClientEvent('kr-inventory:itemUpdate', source, itemName, count, 'remove')
            else
                TriggerClientEvent('kr-inventory:itemError', source, 'Not enough items')
            end
        else
            TriggerClientEvent('kr-inventory:itemError', source, 'Item not found')
        end
    end)
end)

RegisterNetEvent('kr-inventory:getInventory')
AddEventHandler('kr-inventory:getInventory', function()
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)

    if not character then
        TriggerClientEvent('kr-inventory:returnInventory', source, {})
        return
    end

    MySQL.Async.fetchAll('SELECT name, label, count, weight FROM items WHERE character_id = @characterId', {
        ['@characterId'] = character.id
    }, function(result)
        TriggerClientEvent('kr-inventory:returnInventory', source, result or {})
    end)
end)

RegisterNetEvent('kr-inventory:useItem')
AddEventHandler('kr-inventory:useItem', function(itemName)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)

    if not character or not itemName then return end

    MySQL.Async.fetchAll('SELECT id, count, usable FROM items WHERE character_id = @characterId AND name = @itemName', {
        ['@characterId'] = character.id,
        ['@itemName'] = itemName
    }, function(result)
        if result[1] then
            local itemId = result[1].id
            local count = result[1].count
            local usable = result[1].usable

            if usable == 1 then
                if count > 1 then
                    MySQL.Async.execute('UPDATE items SET count = count - 1 WHERE id = @itemId', {
                        ['@itemId'] = itemId
                    })
                else
                    MySQL.Async.execute('DELETE FROM items WHERE id = @itemId', {
                        ['@itemId'] = itemId
                    })
                end
                TriggerClientEvent('kr-inventory:itemUsed', source, itemName, 1)
            else
                TriggerClientEvent('kr-inventory:itemError', source, 'Item cannot be used')
            end
        else
            TriggerClientEvent('kr-inventory:itemError', source, 'Item not found')
        end
    end)
end)

RegisterNetEvent('kr-inventory:addMoneyToPlayer')
AddEventHandler('kr-inventory:addMoneyToPlayer', function(amount)
    local source = source
    local character = exports['kr-core']:GetPlayerData(source)
    local amount = tonumber(amount)

    if not character or not amount or amount <= 0 then return end

    MySQL.Async.execute('UPDATE player_characters SET cash = cash + @amount WHERE id = @id', {
        ['@amount'] = amount,
        ['@id'] = character.id
    })

    character.cash = character.cash + amount
    TriggerClientEvent('kr-core:updateCash', source, character.cash)
end)
