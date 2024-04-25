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

AddStateBagChangeHandler('proximity', ('player:%s'):format(cache.serverId), function(_, _, value)
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