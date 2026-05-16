KR = {}
KR.Version = '1.0.0'
KR.Debug = false

KR.Utils = {}

function KR.Utils.print(...)
    local args = {...}
    local msg = '[KR-Lib] '
    for i, v in ipairs(args) do
        msg = msg .. tostring(v) .. (i < #args and ' ' or '')
    end
    print(msg)
end

function KR.Utils.debugPrint(...)
    if KR.Debug then
        KR.Utils.print(...)
    end
end

function KR.Utils.round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function KR.Utils.clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

function KR.Utils.lerp(a, b, t)
    return a + (b - a) * t
end

function KR.Utils.tableContains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function KR.Utils.tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function KR.Utils.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = KR.Utils.deepCopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

function KR.Utils.stringStarts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

function KR.Utils.stringEnds(String, End)
    return End == '' or string.sub(String, -string.len(End)) == End
end

function KR.Utils.stringSplit(inputstr, sep)
    if sep == nil then
        sep = '%s'
    end
    local t = {}
    for str in string.gmatch(inputstr, '([^'..sep..']+)') do
        table.insert(t, str)
    end
    return t
end

function KR.Utils.stringTrim(s)
    return (s:gsub('^%s*(.-)%s*$', '%1'))
end

function KR.Utils.formatNumber(num)
    if type(num) ~= 'number' then return '0' end
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function KR.Utils.formatMoney(amount)
    return '$' .. KR.Utils.formatNumber(amount)
end

function KR.Utils.getDistanceBetween(x1, y1, z1, x2, y2, z2)
    return #(vector3(x1, y1, z1) - vector3(x2, y2, z2))
end

function KR.Utils.isNearCoords(x, y, z, radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    return KR.Utils.getDistanceBetween(coords.x, coords.y, coords.z, x, y, z) <= radius
end

function KR.Utils.getClosestPlayer()
    local players = GetActivePlayers()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closest, closestDist = -1, 10.0

    for _, player in ipairs(players) do
        if player ~= PlayerId() then
            local targetPed = GetPlayerPed(player)
            local targetCoords = GetEntityCoords(targetPed)
            local dist = #(coords - targetCoords)
            if dist < closestDist then
                closest = GetPlayerServerId(player)
                closestDist = dist
            end
        end
    end

    return closest, closestDist
end

function KR.Utils.requestModel(model, timeout)
    timeout = timeout or 10000
    local modelHash = type(model) == 'string' and joaat(model) or model

    if IsModelValid(modelHash) then
        RequestModel(modelHash)
        local timer = 0
        while not HasModelLoaded(modelHash) and timer < timeout do
            Wait(0)
            timer = timer + 10
        end
        return HasModelLoaded(modelHash)
    end
    return false
end

function KR.Utils.requestAnimDict(dict, timeout)
    timeout = timeout or 10000
    RequestAnimDict(dict)
    local timer = 0
    while not HasAnimDictLoaded(dict) and timer < timeout do
        Wait(0)
        timer = timer + 10
    end
    return HasAnimDictLoaded(dict)
end

function KR.Utils.requestAnimSet(animSet, timeout)
    timeout = timeout or 10000
    RequestAnimSet(animSet)
    local timer = 0
    while not HasAnimSetLoaded(animSet) and timer < timeout do
        Wait(0)
        timer = timer + 10
    end
    return HasAnimSetLoaded(animSet)
end

function KR.Utils.requestStreamedTextureDict(dict, timeout)
    timeout = timeout or 10000
    RequestStreamedTextureDict(dict, false)
    local timer = 0
    while not HasStreamedTextureDictLoaded(dict) and timer < timeout do
        Wait(0)
        timer = timer + 10
    end
    return HasStreamedTextureDictLoaded(dict)
end

function KR.Utils.removeModel(model)
    local modelHash = type(model) == 'string' and joaat(model) or model
    if HasModelLoaded(modelHash) then
        SetModelAsNoLongerNeeded(modelHash)
    end
end

function KR.Utils.removeAnimDict(dict)
    if HasAnimDictLoaded(dict) then
        RemoveAnimDict(dict)
    end
end

function KR.Utils.removeAnimSet(animSet)
    if HasAnimSetLoaded(animSet) then
        RemoveAnimSet(animSet)
    end
end

function KR.Utils.removeStreamedTextureDict(dict)
    if HasStreamedTextureDictLoaded(dict) then
        RemoveStreamedTextureDict(dict)
    end
end

function KR.Utils.getVehicleProperties(vehicle)
    if not DoesEntityExist(vehicle) then return nil end

    return {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = KR.Utils.round(GetVehicleBodyHealth(vehicle), 1),
        engineHealth = KR.Utils.round(GetVehicleEngineHealth(vehicle), 1),
        tankHealth = KR.Utils.round(GetVehiclePetrolTankHealth(vehicle), 1),
        fuelLevel = KR.Utils.round(GetVehicleFuelLevel(vehicle), 1),
        dirtLevel = KR.Utils.round(GetVehicleDirtLevel(vehicle), 1),
        color1 = GetVehicleColours(vehicle),
        color2 = GetVehicleColours(vehicle),
        pearlescentColor = GetVehicleExtraColours(vehicle),
        wheelColor = GetVehicleExtraColours(vehicle),
        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        xenon = HasVehicleGotProjector(vehicle),
        neonEnabled = {
            IsVehicleNeonLightEnabled(vehicle, 0),
            IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2),
            IsVehicleNeonLightEnabled(vehicle, 3)
        },
        neonColor = GetVehicleNeonLightsColour(vehicle),
        extras = {},
        tyreSmokeColor = GetVehicleTyreSmokeColor(vehicle),
        modSpoilers = GetVehicleMod(vehicle, 0),
        modFrontBumper = GetVehicleMod(vehicle, 1),
        modRearBumper = GetVehicleMod(vehicle, 2),
        modSideSkirt = GetVehicleMod(vehicle, 3),
        modExhaust = GetVehicleMod(vehicle, 4),
        modFrame = GetVehicleMod(vehicle, 5),
        modGrille = GetVehicleMod(vehicle, 6),
        modHood = GetVehicleMod(vehicle, 7),
        modFender = GetVehicleMod(vehicle, 8),
        modRightFender = GetVehicleMod(vehicle, 9),
        modRoof = GetVehicleMod(vehicle, 10),
        modEngine = GetVehicleMod(vehicle, 11),
        modBrakes = GetVehicleMod(vehicle, 12),
        modTransmission = GetVehicleMod(vehicle, 13),
        modHorns = GetVehicleMod(vehicle, 14),
        modSuspension = GetVehicleMod(vehicle, 15),
        modArmor = GetVehicleMod(vehicle, 16),
        modTurbo = IsToggleModOn(vehicle, 18),
        modSmokeEnabled = IsToggleModOn(vehicle, 20),
        modXenon = IsToggleModOn(vehicle, 22),
        modFrontWheels = GetVehicleMod(vehicle, 23),
        modBackWheels = GetVehicleMod(vehicle, 24),
        modCustomTiresF = GetVehicleModVariation(vehicle, 23),
        modCustomTiresR = GetVehicleModVariation(vehicle, 24),
        modPlateHolder = GetVehicleMod(vehicle, 25),
        modVanityPlate = GetVehicleMod(vehicle, 26),
        modTrimA = GetVehicleMod(vehicle, 27),
        modOrnaments = GetVehicleMod(vehicle, 28),
        modDashboard = GetVehicleMod(vehicle, 29),
        modDial = GetVehicleMod(vehicle, 30),
        modDoorSpeaker = GetVehicleMod(vehicle, 31),
        modSeats = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate = GetVehicleMod(vehicle, 35),
        modSpeakers = GetVehicleMod(vehicle, 36),
        modTrunk = GetVehicleMod(vehicle, 37),
        modHydrolic = GetVehicleMod(vehicle, 38),
        modEngineBlock = GetVehicleMod(vehicle, 39),
        modAirFilter = GetVehicleMod(vehicle, 40),
        modStruts = GetVehicleMod(vehicle, 41),
        modArchCover = GetVehicleMod(vehicle, 42),
        modAerials = GetVehicleMod(vehicle, 43),
        modTrimB = GetVehicleMod(vehicle, 44),
        modTank = GetVehicleMod(vehicle, 45),
        modWindows = GetVehicleMod(vehicle, 46),
        modDoorR = GetVehicleMod(vehicle, 47),
        modLivery = GetVehicleMod(vehicle, 48),
        modRoofLivery = GetVehicleRoofLivery(vehicle),
        modLightbar = GetVehicleMod(vehicle, 49),
        bulletProofTyres = GetVehicleTyresCanBurst(vehicle),
        driftTyres = GetVehicleDriftTyres(vehicle),
    }
end

function KR.Utils.setVehicleProperties(vehicle, props)
    if not DoesEntityExist(vehicle) or not props then return false end

    SetVehicleModKit(vehicle, 0)

    if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
    if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
    if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
    if props.color1 and props.color2 then SetVehicleColours(vehicle, props.color1, props.color2) end
    if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor or 0) end
    if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
    if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

    if props.neonEnabled then
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(vehicle, i, props.neonEnabled[i + 1])
        end
    end

    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end

    if props.modTurbo ~= nil then ToggleVehicleMod(vehicle, 18, props.modTurbo) end
    if props.modSmokeEnabled ~= nil then ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled) end
    if props.modXenon ~= nil then ToggleVehicleMod(vehicle, 22, props.modXenon) end

    if props.modFrontWheels then
        SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF or false)
    end
    if props.modBackWheels then
        SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR or false)
    end

    if props.bulletProofTyres ~= nil then
        SetVehicleTyresCanBurst(vehicle, props.bulletProofTyres)
    end

    local modTypes = {
        [0] = 'modSpoilers', [1] = 'modFrontBumper', [2] = 'modRearBumper',
        [3] = 'modSideSkirt', [4] = 'modExhaust', [5] = 'modFrame',
        [6] = 'modGrille', [7] = 'modHood', [8] = 'modFender',
        [9] = 'modRightFender', [10] = 'modRoof', [11] = 'modEngine',
        [12] = 'modBrakes', [13] = 'modTransmission', [14] = 'modHorns',
        [15] = 'modSuspension', [16] = 'modArmor', [25] = 'modPlateHolder',
        [26] = 'modVanityPlate', [27] = 'modTrimA', [28] = 'modOrnaments',
        [29] = 'modDashboard', [30] = 'modDial', [31] = 'modDoorSpeaker',
        [32] = 'modSeats', [33] = 'modSteeringWheel', [34] = 'modShifterLeavers',
        [35] = 'modAPlate', [36] = 'modSpeakers', [37] = 'modTrunk',
        [38] = 'modHydrolic', [39] = 'modEngineBlock', [40] = 'modAirFilter',
        [41] = 'modStruts', [42] = 'modArchCover', [43] = 'modAerials',
        [44] = 'modTrimB', [45] = 'modTank', [46] = 'modWindows',
        [47] = 'modDoorR', [48] = 'modLivery', [49] = 'modLightbar'
    }

    for modType, propName in pairs(modTypes) do
        if props[propName] then
            SetVehicleMod(vehicle, modType, props[propName], false)
        end
    end

    if props.modRoofLivery then SetVehicleRoofLivery(vehicle, props.modRoofLivery) end

    return true
end

function KR.Utils.draw3DText(x, y, z, text, scale, font, r, g, b, a)
    scale = scale or 0.35
    font = font or 4
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 215

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(font)
        SetTextProportional(true)
        SetTextColour(r, g, b, a)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function KR.Utils.drawMarker(type, x, y, z, r, g, b, a, scale)
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 100
    scale = scale or 1.0

    DrawMarker(
        type,
        x, y, z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        scale, scale, scale * 0.5,
        r, g, b, a,
        false, true, 2, false, nil, nil, false
    )
end

function KR.Utils.getForwardVector()
    local heading = GetEntityHeading(GetPlayerPed(-1))
    local headingRad = math.rad(heading + 90.0)
    return vector3(-math.sin(headingRad), math.cos(headingRad), 0.0)
end

function KR.Utils.getOffsetFromEntityInWorldCoords(entity, offsetX, offsetY, offsetZ)
    return GetOffsetFromEntityInWorldCoords(entity, offsetX, offsetY, offsetZ)
end

function KR.Utils.isPlayerInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

function KR.Utils.getVehicleInDirection()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = KR.Utils.getForwardVector()
    local rayHandle = StartShapeTestRay(
        coords.x, coords.y, coords.z,
        coords.x + forward.x * 5.0, coords.y + forward.y * 5.0, coords.z + forward.z * 5.0,
        10, ped, 0
    )
    local _, _, _, _, entityHit = GetShapeTestResult(rayHandle)
    if entityHit and GetEntityType(entityHit) == 2 then
        return entityHit
    end
    return nil
end

return KR
