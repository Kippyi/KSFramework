KR.TextUI = {}
KR.TextUI.Visible = false

function KR.TextUI.Show(text, options)
    options = options or {}

    SendNUIMessage({
        action = 'showTextUI',
        text = text,
        position = options.position or 'bottom',
        style = options.style or {}
    })

    KR.TextUI.Visible = true
end

function KR.TextUI.Hide()
    if KR.TextUI.Visible then
        SendNUIMessage({
            action = 'hideTextUI'
        })
        KR.TextUI.Visible = false
    end
end

function KR.TextUI.IsVisible()
    return KR.TextUI.Visible
end

exports('TextUI', function(text, options)
    KR.TextUI.Show(text, options)
end)

exports('HideTextUI', function()
    KR.TextUI.Hide()
end)

exports('IsTextUIVisible', function()
    return KR.TextUI.IsVisible()
end)
