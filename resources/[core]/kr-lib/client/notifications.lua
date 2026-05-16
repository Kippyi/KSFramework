KR.Notify = {}
KR.Notify.Queue = {}
KR.Notify.Active = false

KR.Notify.Types = {
    success = { color = '#06d6a0', icon = '✓' },
    error = { color = '#ff6b6b', icon = '✕' },
    warning = { color = '#ffcc00', icon = '!' },
    info = { color = '#4cc9f0', icon = 'i' }
}

function KR.Notify.Show(message, type, duration)
    type = type or 'info'
    duration = duration or 3000

    local style = KR.Notify.Types[type] or KR.Notify.Types.info

    SendNUIMessage({
        action = 'krNotify',
        message = message,
        type = type,
        color = style.color,
        icon = style.icon,
        duration = duration
    })
end

function KR.Notify.Success(message, duration)
    KR.Notify.Show(message, 'success', duration)
end

function KR.Notify.Error(message, duration)
    KR.Notify.Show(message, 'error', duration)
end

function KR.Notify.Warning(message, duration)
    KR.Notify.Show(message, 'warning', duration)
end

function KR.Notify.Info(message, duration)
    KR.Notify.Show(message, 'info', duration)
end

function KR.Notify.Chat(title, message, color)
    color = color or {255, 255, 255}
    TriggerEvent('chat:addMessage', {
        color = color,
        args = {title, message}
    })
end

AddEventHandler('kr-lib:notify', function(data)
    KR.Notify.Show(data.message, data.type, data.duration)
end)

exports('Notify', function(message, type, duration)
    KR.Notify.Show(message, type, duration)
end)

exports('Success', function(message, duration)
    KR.Notify.Success(message, duration)
end)

exports('Error', function(message, duration)
    KR.Notify.Error(message, duration)
end)

exports('Warning', function(message, duration)
    KR.Notify.Warning(message, duration)
end)

exports('Info', function(message, duration)
    KR.Notify.Info(message, duration)
end)

exports('Chat', function(title, message, color)
    KR.Notify.Chat(title, message, color)
end)
