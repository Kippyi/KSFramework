KR.Server = {}

function KR.Server.GetPlayers()
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        table.insert(players, tonumber(id))
    end
    return players
end

function KR.Server.GetPlayerCount()
    return #GetPlayers()
end

function KR.Server.Notify(source, message, type, duration)
    TriggerClientEvent('kr-lib:notify', source, {
        message = message,
        type = type or 'info',
        duration = duration or 3000
    })
end

function KR.Server.NotifyAll(message, type, duration)
    for _, playerId in ipairs(GetPlayers()) do
        KR.Server.Notify(tonumber(playerId), message, type, duration)
    end
end

function KR.Server.Chat(source, title, message, color)
    color = color or {255, 255, 255}
    TriggerClientEvent('chat:addMessage', source, {
        color = color,
        args = {title, message}
    })
end

function KR.Server.ChatAll(title, message, color)
    color = color or {255, 255, 255}
    TriggerClientEvent('chat:addMessage', -1, {
        color = color,
        args = {title, message}
    })
end

function KR.Server.GetIdentifier(source)
    return GetPlayerIdentifier(source, 0)
end

function KR.Server.GetIdentifiers(source)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, 'license:') then
            identifiers.license = id
        elseif string.find(id, 'steam:') then
            identifiers.steam = id
        elseif string.find(id, 'discord:') then
            identifiers.discord = id
        elseif string.find(id, 'fivem:') then
            identifiers.fivem = id
        elseif string.find(id, 'xbl:') then
            identifiers.xbl = id
        elseif string.find(id, 'live:') then
            identifiers.live = id
        elseif string.find(id, 'ip:') then
            identifiers.ip = id
        end
    end
    return identifiers
end

function KR.Server.HasAce(source, ace)
    return IsPlayerAceAllowed(source, ace)
end

function KR.Server.IsAdmin(source)
    return KR.Server.HasAce(source, 'admin') or KR.Server.HasAce(source, 'command')
end

function KR.Server.GetPlayersByName(name)
    local results = {}
    local searchName = string.lower(name)

    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        local playerName = GetPlayerName(src)
        if string.find(string.lower(playerName), searchName) then
            table.insert(results, src)
        end
    end

    return results
end

function KR.Server.TriggerCallback(name, source, cb, ...)
    TriggerClientEvent('kr-lib:serverCallback', source, name, ...)

    RegisterNetEvent('kr-lib:serverCallbackReturn:' .. name)
    AddEventHandler('kr-lib:serverCallbackReturn:' .. name, function(...)
        cb(...)
        RemoveEventHandler('kr-lib:serverCallbackReturn:' .. name)
    end)
end

function KR.Server.RegisterCallback(name, cb)
    RegisterNetEvent('kr-lib:serverCallback:' .. name)
    AddEventHandler('kr-lib:serverCallback:' .. name, function(...)
        local source = source
        local args = {...}

        cb(source, function(...)
            TriggerClientEvent('kr-lib:serverCallbackReturn:' .. name, source, ...)
        end, ...)
    end)
end

exports('Notify', function(source, message, type, duration)
    KR.Server.Notify(source, message, type, duration)
end)

exports('NotifyAll', function(message, type, duration)
    KR.Server.NotifyAll(message, type, duration)
end)

exports('Chat', function(source, title, message, color)
    KR.Server.Chat(source, title, message, color)
end)

exports('ChatAll', function(title, message, color)
    KR.Server.ChatAll(title, message, color)
end)

exports('GetIdentifier', function(source)
    return KR.Server.GetIdentifier(source)
end)

exports('GetIdentifiers', function(source)
    return KR.Server.GetIdentifiers(source)
end)

exports('IsAdmin', function(source)
    return KR.Server.IsAdmin(source)
end)

exports('HasAce', function(source, ace)
    return KR.Server.HasAce(source, ace)
end)

exports('GetPlayersByName', function(name)
    return KR.Server.GetPlayersByName(name)
end)

exports('RegisterCallback', function(name, cb)
    KR.Server.RegisterCallback(name, cb)
end)
