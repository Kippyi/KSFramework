local PlayerProperties = {}
local AllProperties = {}
local nearProperty = nil

RegisterNetEvent('kr-characters:purchaseSuccess')
AddEventHandler('kr-characters:purchaseSuccess', function(propertyId)
    SendNUIMessage({
        action = 'notification',
        message = ('You have successfully purchased property #%d!'):format(propertyId),
        type = 'success'
    })
end)

RegisterNetEvent('kr-characters:purchaseFailed')
AddEventHandler('kr-characters:purchaseFailed', function(reason)
    SendNUIMessage({
        action = 'notification',
        message = reason,
        type = 'error'
    })
end)

RegisterNetEvent('kr-characters:sellSuccess')
AddEventHandler('kr-characters:sellSuccess', function(propertyId, amount)
    SendNUIMessage({
        action = 'notification',
        message = ('You have sold property #%d for $%d!'):format(propertyId, amount),
        type = 'success'
    })
end)

RegisterNetEvent('kr-characters:sellFailed')
AddEventHandler('kr-characters:sellFailed', function(reason)
    SendNUIMessage({
        action = 'notification',
        message = reason,
        type = 'error'
    })
end)

RegisterNetEvent('kr-characters:rentSuccess')
AddEventHandler('kr-characters:rentSuccess', function(propertyId, amount)
    SendNUIMessage({
        action = 'notification',
        message = ('You have rented property #%d for $%d!'):format(propertyId, amount),
        type = 'success'
    })
end)

RegisterNetEvent('kr-characters:rentFailed')
AddEventHandler('kr-characters:rentFailed', function(reason)
    SendNUIMessage({
        action = 'notification',
        message = reason,
        type = 'error'
    })
end)

RegisterNetEvent('kr-characters:evictedFromProperty')
AddEventHandler('kr-characters:evictedFromProperty', function(propertyId)
    SendNUIMessage({
        action = 'notification',
        message = ('You have been evicted from property #%d.'):format(propertyId),
        type = 'error'
    })
end)

RegisterNetEvent('kr-characters:returnPlayerProperties')
AddEventHandler('kr-characters:returnPlayerProperties', function(properties)
    PlayerProperties = properties
end)

RegisterNetEvent('kr-characters:returnAllProperties')
AddEventHandler('kr-characters:returnAllProperties', function(properties)
    AllProperties = properties
end)

RegisterCommand('buyproperty', function(source, args, rawCommand)
    if #args >= 1 then
        local propertyId = tonumber(args[1])
        if propertyId then
            TriggerServerEvent('kr-characters:purchaseProperty', propertyId)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Property ID must be a number'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /buyproperty [propertyId]'}
        })
    end
end, false)

RegisterCommand('sellproperty', function(source, args, rawCommand)
    if #args >= 1 then
        local propertyId = tonumber(args[1])
        if propertyId then
            TriggerServerEvent('kr-characters:sellProperty', propertyId)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Property ID must be a number'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /sellproperty [propertyId]'}
        })
    end
end, false)

RegisterCommand('rentproperty', function(source, args, rawCommand)
    if #args >= 1 then
        local propertyId = tonumber(args[1])
        if propertyId then
            TriggerServerEvent('kr-characters:rentProperty', propertyId)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Property ID must be a number'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /rentproperty [propertyId]'}
        })
    end
end, false)

RegisterCommand('myproperties', function(source, args, rawCommand)
    TriggerServerEvent('kr-characters:getPlayerProperties')
end, false)

RegisterCommand('listproperties', function(source, args, rawCommand)
    TriggerServerEvent('kr-characters:getAllProperties')
end, false)

function GetPlayerProperties()
    return PlayerProperties or {}
end

function GetAllProperties()
    return AllProperties or {}
end

function IsPropertyOwned(propertyId)
    if not AllProperties then return false end
    for _, prop in ipairs(AllProperties) do
        if prop.id == propertyId then
            return prop.owned == 1
        end
    end
    return false
end

function GetPropertyOwner(propertyId)
    if not AllProperties then return nil end
    for _, prop in ipairs(AllProperties) do
        if prop.id == propertyId then
            return prop.owner
        end
    end
    return nil
end

exports('GetPlayerProperties', GetPlayerProperties)
exports('GetAllProperties', GetAllProperties)
exports('IsPropertyOwned', IsPropertyOwned)
exports('GetPropertyOwner', GetPropertyOwner)
