KR.Progress = {}
KR.Progress.Active = false
KR.Progress.Cancelled = false

function KR.Progress.Circle(duration, label, useWhileDead, canCancel)
    KR.Progress.Active = true
    KR.Progress.Cancelled = false

    useWhileDead = useWhileDead or false
    canCancel = canCancel ~= false

    SendNUIMessage({
        action = 'progressCircle',
        duration = duration,
        label = label or 'Working...'
    })

    local endTime = GetGameTimer() + duration
    local cancelled = false

    CreateThread(function()
        while KR.Progress.Active and GetGameTimer() < endTime do
            if canCancel and IsControlJustPressed(0, 177) then
                KR.Progress.Cancelled = true
                KR.Progress.Active = false
                cancelled = true
            end

            if not useWhileDead and IsEntityDead(PlayerPedId()) then
                KR.Progress.Cancelled = true
                KR.Progress.Active = false
                cancelled = true
            end

            Wait(0)
        end
    end)

    while KR.Progress.Active and GetGameTimer() < endTime do
        Wait(100)
    end

    SendNUIMessage({
        action = 'hideProgress'
    })

    KR.Progress.Active = false
    return not cancelled
end

function KR.Progress.Bar(duration, label, useWhileDead, canCancel)
    return KR.Progress.Circle(duration, label, useWhileDead, canCancel)
end

function KR.Progress.Cancel()
    if KR.Progress.Active then
        KR.Progress.Active = false
        KR.Progress.Cancelled = true
        SendNUIMessage({
            action = 'hideProgress'
        })
    end
end

function KR.Progress.IsBusy()
    return KR.Progress.Active
end

exports('Progress', function(duration, label, useWhileDead, canCancel)
    return KR.Progress.Circle(duration, label, useWhileDead, canCancel)
end)

exports('CancelProgress', function()
    KR.Progress.Cancel()
end)

exports('IsProgressActive', function()
    return KR.Progress.IsBusy()
end)
