local SendNUIMessage = SendNUIMessage
local MumbleIsPlayerTalking = MumbleIsPlayerTalking

--- Set the talking status
---@param talking boolean
local function setTalking(talking)
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'voice',
                option = {
                    stroke = (PlayerState.radioActive and '#5A93FF') or (talking and '#FF935A') or false
                }
            }
        }
    })
end

require '@pma-voice.shared'
local proximityLevels = Cfg.voiceModes or {}
local highestLevel
for i = 1, #proximityLevels do
    if not highestLevel or proximityLevels[i][1] > highestLevel then
        highestLevel = proximityLevels[i][1]
    end
end

local shouldShowMarker = false
local function showMarker(distance)
    shouldShowMarker = true
    SetTimeout(500, function()
        if LocalPlayer.state.proximity.distance == distance then
            shouldShowMarker = false
        end
    end)
    while shouldShowMarker do
        Wait(0)
        local coords = GetEntityCoords(cache.ped)
        DrawMarker(1, coords.x, coords.y, coords.z - (cache.vehicle and 0.5 or 1), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, distance, distance, 0.6, 255, 147, 90, 200, false, true, 2, false, nil, nil, false)
    end
end

AddStateBagChangeHandler('proximity', ('player:%s'):format(cache.serverId), function(_, _, value)
    shouldShowMarker = false
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'voice',
                value = value.distance / highestLevel * 100
            }
        }
    })
    SetTimeout(50, function()
        showMarker(value.distance)
    end)
end)

local isTalking = false
CreateThread(function()
    while true do
        local talking = MumbleIsPlayerTalking(cache.playerId)
        if isTalking ~= talking then
            isTalking = talking
            setTalking(talking)
        end
        Wait(125)
    end
end)