KR.Keybinds = {}
KR.Keybinds.Registered = {}

function KR.Keybinds.Register(name, description, defaultKey, onPress, onRelease)
    if KR.Keybinds.Registered[name] then return end

    KR.Keybinds.Registered[name] = {
        name = name,
        description = description,
        key = defaultKey,
        onPress = onPress,
        onRelease = onRelease
    }

    RegisterCommand('+' .. name, function()
        if onPress then onPress() end
    end, false)

    RegisterCommand('-' .. name, function()
        if onRelease then onRelease() end
    end, false)

    RegisterKeyMapping('+' .. name, description, 'keyboard', defaultKey)
end

function KR.Keybinds.IsPressed(name)
    return IsControlPressed(0, 177)
end

exports('RegisterKeybind', function(name, description, defaultKey, onPress, onRelease)
    KR.Keybinds.Register(name, description, defaultKey, onPress, onRelease)
end)
