local PropertyBlips = {}
local Properties = {}

RegisterNetEvent('kr-characters:loadProperties')
AddEventHandler('kr-characters:loadProperties', function()
    TriggerServerEvent('kr-characters:getAllProperties')
end)

function CreatePropertyBlips()
    for _, blip in ipairs(PropertyBlips) do
        RemoveBlip(blip)
    end
    PropertyBlips = {}

    for _, prop in ipairs(Properties) do
        local pos = {}
        if prop.position then
            pos = json.decode(prop.position)
        end

        if pos.x and pos.y then
            local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
            SetBlipSprite(blip, prop.owned == 1 and 40 or 374)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, prop.owned == 1 and 2 or 3)
            SetBlipAsShortRange(blip, true)

            local status = prop.owned == 1 and 'Owned' or 'Available'
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(('%s [%s] - $%s'):format(prop.label, status, prop.price > 0 and prop.price or prop.rent))
            EndTextCommandSetBlipName(blip)

            table.insert(PropertyBlips, blip)
        end
    end
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)

        for _, prop in ipairs(Properties) do
            local pos = {}
            if prop.position then
                pos = json.decode(prop.position)
            end

            if pos.x and pos.y then
                local propCoords = vector3(pos.x, pos.y, pos.z)
                local dist = #(coords - propCoords)

                if dist < 50.0 then
                    sleep = 0

                    DrawMarker(
                        1,
                        pos.x, pos.y, pos.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        1.5, 1.5, 0.5,
                        prop.owned == 1 and 255 or 0,
                        prop.owned == 1 and 0 or 255,
                        prop.owned == 1 and 0 or 150,
                        100,
                        false, true, 2, false, nil, nil, false
                    )

                    if dist < 2.0 then
                        local actionText = prop.owned == 1 and 'Press ~INPUT_PICKUP~ to interact' or ('Press ~INPUT_PICKUP~ to %s ($%s)'):format(prop.price > 0 and 'buy' or 'rent', prop.price > 0 and prop.price or prop.rent)

                        SetTextScale(0.35, 0.35)
                        SetTextFont(4)
                        SetTextProportional(1)
                        SetTextColour(255, 255, 255, 215)
                        SetTextEntry('STRING')
                        SetTextCentre(1)
                        AddTextComponentString(actionText)
                        DrawText(0.5, 0.85)

                        if IsControlJustPressed(0, 38) then
                            if prop.owned == 1 then
                                TriggerServerEvent('kr-characters:getPlayerProperties')
                            else
                                if prop.price > 0 then
                                    TriggerServerEvent('kr-characters:purchaseProperty', prop.id)
                                else
                                    TriggerServerEvent('kr-characters:rentProperty', prop.id)
                                end
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('kr-characters:returnAllProperties')
AddEventHandler('kr-characters:returnAllProperties', function(props)
    Properties = props
    CreatePropertyBlips()
end)
