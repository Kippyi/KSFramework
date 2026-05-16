PlayerData = {}
local playerLoaded = false

RegisterNetEvent('kr-core:showCharacterSelection')
AddEventHandler('kr-core:showCharacterSelection', function(characters)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showCharacterSelection',
        characters = characters
    })
end)

RegisterNetEvent('kr-core:showCharacterCreation')
AddEventHandler('kr-core:showCharacterCreation', function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'showCharacterCreation'
    })
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('kr-core:selectCharacter', data.characterId)
    cb('ok')
end)

RegisterNUICallback('createCharacter', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('kr-core:createCharacter', data)
    cb('ok')
end)

RegisterNetEvent('kr-core:spawnPlayer')
AddEventHandler('kr-core:spawnPlayer', function(spawnPos, character)
    local coords = vector3(spawnPos.x or -540.0, spawnPos.y or -212.0, spawnPos.z or 37.0)
    PlayerData = character
    playerLoaded = true

    DoScreenFadeOut(500)
    Wait(500)

    SetEntityCoords(GetPlayerPed(-1), coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(GetPlayerPed(-1), 0.0)

    DoScreenFadeIn(1000)

    SendNUIMessage({
        action = 'updateCharacter',
        firstname = PlayerData.firstname,
        lastname = PlayerData.lastname,
        job = PlayerData.job,
        job_grade = PlayerData.job_grade,
        level = PlayerData.level,
        cash = PlayerData.cash,
        bank = PlayerData.bank
    })

    TriggerEvent('kr-core:playerLoaded', PlayerData)
end)

RegisterNetEvent('kr-core:characterCreated')
AddEventHandler('kr-core:characterCreated', function(character)
    PlayerData = character
    playerLoaded = true

    SendNUIMessage({
        action = 'updateCharacter',
        firstname = PlayerData.firstname,
        lastname = PlayerData.lastname,
        job = PlayerData.job,
        job_grade = PlayerData.job_grade,
        level = PlayerData.level,
        cash = PlayerData.cash,
        bank = PlayerData.bank
    })

    TriggerEvent('kr-core:playerLoaded', PlayerData)
end)

RegisterNetEvent('kr-core:updateCash')
AddEventHandler('kr-core:updateCash', function(amount)
    if PlayerData then
        PlayerData.cash = amount
        SendNUIMessage({
            action = 'updateCash',
            cash = amount
        })
    end
end)

RegisterNetEvent('kr-core:updateBank')
AddEventHandler('kr-core:updateBank', function(amount)
    if PlayerData then
        PlayerData.bank = amount
        SendNUIMessage({
            action = 'updateBank',
            bank = amount
        })
    end
end)

RegisterNetEvent('kr-core:paycheck')
AddEventHandler('kr-core:paycheck', function(amount)
    SendNUIMessage({
        action = 'notification',
        message = 'You received a paycheck of $' .. amount .. '!',
        type = 'success'
    })
end)

RegisterNetEvent('kr-core:addMoney')
AddEventHandler('kr-core:addMoney', function(amount)
    SendNUIMessage({
        action = 'notification',
        message = 'You received $' .. amount .. '!',
        type = 'success'
    })
end)

RegisterNetEvent('kr-core:jobUpdate')
AddEventHandler('kr-core:jobUpdate', function(jobName, grade)
    if PlayerData then
        PlayerData.job = jobName
        PlayerData.job_grade = grade
        SendNUIMessage({
            action = 'jobUpdate',
            job = jobName,
            grade = grade
        })
    end
end)

RegisterCommand('deposit', function(source, args, rawCommand)
    if #args >= 1 then
        local amount = tonumber(args[1])
        if amount and amount > 0 then
            TriggerServerEvent('kr-core:deposit', amount)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Usage: /deposit [amount]'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /deposit [amount]'}
        })
    end
end, false)

RegisterCommand('withdraw', function(source, args, rawCommand)
    if #args >= 1 then
        local amount = tonumber(args[1])
        if amount and amount > 0 then
            TriggerServerEvent('kr-core:withdraw', amount)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Usage: /withdraw [amount]'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /withdraw [amount]'}
        })
    end
end, false)

RegisterCommand('transfer', function(source, args, rawCommand)
    if #args >= 2 then
        local target = tonumber(args[1])
        local amount = tonumber(args[2])
        if target and amount and amount > 0 then
            TriggerServerEvent('kr-core:transferMoney', target, amount)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Usage: /transfer [playerId] [amount]'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /transfer [playerId] [amount]'}
        })
    end
end, false)

RegisterCommand('loan', function(source, args, rawCommand)
    if #args >= 1 then
        local amount = tonumber(args[1])
        if amount and amount > 0 then
            TriggerServerEvent('kr-core:takeLoan', amount)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Usage: /loan [amount]'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /loan [amount]'}
        })
    end
end, false)

RegisterCommand('repayloan', function(source, args, rawCommand)
    if #args >= 1 then
        local amount = tonumber(args[1])
        if amount and amount > 0 then
            TriggerServerEvent('kr-core:repayLoan', amount)
        else
            TriggerEvent('chat:addMessage', {
                color = {255, 0, 0},
                args = {'[Error]', 'Usage: /repayloan [amount]'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            args = {'[Error]', 'Usage: /repayloan [amount]'}
        })
    end
end, false)

RegisterCommand('myjob', function(source, args, rawCommand)
    TriggerServerEvent('kr-core:getJob')
end, false)

RegisterCommand('onduty', function(source, args, rawCommand)
    TriggerServerEvent('kr-core:setDuty', true)
end, false)

RegisterCommand('offduty', function(source, args, rawCommand)
    TriggerServerEvent('kr-core:setDuty', false)
end, false)

function IsPlayerLoaded()
    return playerLoaded
end

function GetPlayerData()
    return PlayerData
end

exports('IsPlayerLoaded', IsPlayerLoaded)
exports('GetPlayerData', GetPlayerData)
