local config = require 'config.server'

local function alterStress(source, amount)
    local playerState = Player(source).state
    local player = exports.qbx_core:GetPlayer(source)
    if not player or (amount > 0 and config.disablePoliceStress and player.PlayerData.job.type == 'leo') then return end

    local newStress = playerState.stress + amount
    newStress = lib.math.clamp(newStress, 0, 100)

    playerState:set("stress", newStress, true)

    if amount > 0 then
        exports.qbx_core:Notify(source, locale("notify.stress_gain"), 'inform', 2500, nil, nil, {'#141517', '#ffffff'}, 'brain', '#C53030')
    else
        exports.qbx_core:Notify(source, locale("notify.stress_removed"), 'inform', 2500, nil, nil, {'#141517', '#ffffff'}, 'brain', '#0F52BA')
    end
end

RegisterNetEvent('hud:server:GainStress', function(amount)
    alterStress(source, amount)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    alterStress(source, -amount)
end)