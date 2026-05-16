local Inventory = {}

RegisterNetEvent('kr-inventory:itemUpdate')
AddEventHandler('kr-inventory:itemUpdate', function(itemName, count, action)
    if action == 'add' then
        if Inventory[itemName] then
            Inventory[itemName] = Inventory[itemName] + count
        else
            Inventory[itemName] = count
        end
    elseif action == 'remove' then
        if Inventory[itemName] then
            Inventory[itemName] = Inventory[itemName] - count
            if Inventory[itemName] <= 0 then
                Inventory[itemName] = nil
            end
        end
    end

    SendNUIMessage({
        action = 'inventoryUpdate',
        item = itemName,
        count = count,
        operation = action
    })
end)

RegisterNetEvent('kr-inventory:itemUsed')
AddEventHandler('kr-inventory:itemUsed', function(itemName, count)
    SendNUIMessage({
        action = 'notification',
        message = ('You used %d x %s'):format(count, itemName),
        type = 'info'
    })
end)

RegisterNetEvent('kr-inventory:itemError')
AddEventHandler('kr-inventory:itemError', function(message)
    SendNUIMessage({
        action = 'notification',
        message = message,
        type = 'error'
    })
end)

RegisterNetEvent('kr-inventory:returnInventory')
AddEventHandler('kr-inventory:returnInventory', function(items)
    Inventory = {}
    for _, item in ipairs(items) do
        Inventory[item.name] = {
            count = item.count,
            label = item.label,
            weight = item.weight
        }
    end

    SendNUIMessage({
        action = 'fullInventory',
        inventory = Inventory
    })
end)

RegisterCommand('giveitem', function(source, args, rawCommand)
    if #args >= 1 then
        local itemName = args[1]
        local count = tonumber(args[2]) or 1
        TriggerServerEvent('kr-inventory:giveItem', itemName, count)
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /giveitem [itemName] [count]'}
        })
    end
end, false)

RegisterCommand('removeitem', function(source, args, rawCommand)
    if #args >= 1 then
        local itemName = args[1]
        local count = tonumber(args[2]) or 1
        TriggerServerEvent('kr-inventory:removeItem', itemName, count)
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /removeitem [itemName] [count]'}
        })
    end
end, false)

RegisterCommand('useitem', function(source, args, rawCommand)
    if #args >= 1 then
        local itemName = args[1]
        TriggerServerEvent('kr-inventory:useItem', itemName)
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /useitem [itemName]'}
        })
    end
end, false)

RegisterCommand('inventory', function(source, args, rawCommand)
    TriggerServerEvent('kr-inventory:getInventory')
end, false)

function GetItemCount(itemName)
    return Inventory[itemName] or 0
end

function HasItem(itemName, count)
    count = count or 1
    return (Inventory[itemName] or 0) >= count
end

function GetInventory()
    return Inventory
end

exports('GetItemCount', GetItemCount)
exports('HasItem', HasItem)
exports('GetInventory', GetInventory)
