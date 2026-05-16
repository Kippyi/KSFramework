KR.Menu = {}
KR.Menu.Open = false
KR.Menu.Current = nil

function KR.Menu.OpenMenu(type, data)
    KR.Menu.Open = true
    KR.Menu.Current = { type = type, data = data }

    SendNUIMessage({
        action = 'openMenu',
        menuType = type,
        data = data
    })
end

function KR.Menu.CloseMenu()
    KR.Menu.Open = false
    KR.Menu.Current = nil

    SendNUIMessage({
        action = 'closeMenu'
    })
end

function KR.Menu.IsOpen()
    return KR.Menu.Open
end

function KR.Menu.GetCurrent()
    return KR.Menu.Current
end

exports('OpenMenu', function(type, data)
    KR.Menu.OpenMenu(type, data)
end)

exports('CloseMenu', function()
    KR.Menu.CloseMenu()
end)

exports('IsMenuOpen', function()
    return KR.Menu.IsOpen()
end)
