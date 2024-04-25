AddStateBagChangeHandler('hunger', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value == PlayerState.hunger then return end
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'hunger',
                value = value,
                option = {
                    stroke = value < 30 and '#881111ff' or false,
                }
            }
        }
    })
end)

AddStateBagChangeHandler('thirst', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value == PlayerState.thirst then return end
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'thirst',
                value = value,
                option = {
                    stroke = value < 30 and '#881111ff' or false,
                }
            }
        }
    })
end)

AddStateBagChangeHandler('stress', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value == Stress then return end
    Stress = value

    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'stress',
                value = value,
                option = {
                    stroke = value > 75 and '#881111ff' or false,
                }
            }
        }
    })
end)