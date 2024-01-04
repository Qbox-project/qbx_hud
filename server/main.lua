local config = require 'config.server'

lib.versionCheck('Qbox-project/qbx_hud')

AddEventHandler('ox_inventory:openedInventory', function(source)
    TriggerClientEvent('qbx_hud:client:hideHud', source)
end)

AddEventHandler('ox_inventory:closedInventory', function(source)
    TriggerClientEvent('qbx_hud:client:showHud', source)
end)

RegisterNetEvent('hud:server:GainStress', function(amount)
    local player = exports.qbx_core:GetPlayer(source)
    local newStress
    if not player or (config.disablePoliceStress and player.PlayerData.job.type == 'leo') then return end
    if not player.PlayerData.metadata.stress then
        player.PlayerData.metadata.stress = 0
    end
    newStress = player.PlayerData.metadata.stress + amount
    newStress = newStress <= 0 and 0 or newStress > 100 and 100 or newStress

    Player(source).state:set('stress', newStress, true)
    player.Functions.SetMetaData('stress', newStress)
    exports.qbx_core:Notify(source, Lang:t("notify.stress_gain"), 'error', 1500)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local player = exports.qbx_core:GetPlayer(source)
    local newStress
    if not player then return end
    if not player.PlayerData.metadata.stress then
        player.PlayerData.metadata.stress = 0
    end
    newStress = player.PlayerData.metadata.stress - amount
    newStress = newStress <= 0 and 0 or newStress > 100 and 100 or newStress

    Player(source).state:set('stress', newStress, true)
    player.Functions.SetMetaData('stress', newStress)
    exports.qbx_core:Notify(source, Lang:t("notify.stress_removed"))
end)

lib.addCommand('bank', {
    help = Lang:t('commands.bank.help'),
    restricted = false,
}, function (source)
    TriggerClientEvent('qbx_hud:client:showMoney', source, false)
end)

lib.addCommand('cash', {
    help = Lang:t('commands.cash.help'),
    restricted = false,
}, function (source)
    TriggerClientEvent('qbx_hud:client:showMoney', source, true)
end)