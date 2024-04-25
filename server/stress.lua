local config = require 'config.server'

RegisterNetEvent('hud:server:GainStress', function(amount)
    local playerState = Player(source).state
    local player = exports.qbx_core:GetPlayer(source)
    if not player or (config.disablePoliceStress and player.PlayerData.job.type == 'leo') then return end

    local newStress = playerState.stress + amount
    newStress = lib.math.clamp(newStress, 0, 100)

    playerState:set("stress", newStress, true)
    exports.qbx_core:Notify(source, locale("notify.stress_gain"), 'inform', 2500, nil, nil, {'#141517', '#ffffff'}, 'brain', '#C53030')
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local playerState = Player(source).state
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local newStress = playerState.stress - amount
    newStress = lib.math.clamp(newStress, 0, 100)

    playerState:set("stress", newStress, true)
    exports.qbx_core:Notify(source, locale("notify.stress_removed"), 'inform', 2500, nil, nil, {'#141517', '#ffffff'}, 'brain', '#0F52BA')
end)