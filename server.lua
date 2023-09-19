local resetStress = false

-- Callbacks

lib.callback.register('hud:server:getMenu', function()
    return Config.Menu
end)

-- Network Events

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if not Player or (Config.DisablePoliceStress and Player.PlayerData.job.type == 'leo') then return end
    if not resetStress then
        if not Player.PlayerData.metadata.stress then
            Player.PlayerData.metadata.stress = 0
        end
        newStress = Player.PlayerData.metadata.stress + amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('QBCore:Notify', src, Lang:t("notify.stress_gain"), 'inform', 2500, _, _, {'#141517', '#ffffff'}, 'brain', '#C53030')
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local newStress
    if not Player then return end
    if not resetStress then
        if not Player.PlayerData.metadata.stress then
            Player.PlayerData.metadata.stress = 0
        end
        newStress = Player.PlayerData.metadata.stress - amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('QBCore:Notify', src, Lang:t("notify.stress_removed"), 'inform', 2500, _, _, {'#141517', '#ffffff'}, 'brain', '#0F52BA')
end)

-- Commands

lib.addCommand(Lang:t('commands.cash'), {
    help = Lang:t('commands.help.cash'),
    restricted = 'group.admin'
}, function(source)
    local player = QBCore.Functions.GetPlayer(source)
    local cashAmount = player.PlayerData.money.cash
    TriggerClientEvent('hud:client:ShowAccounts', source, 'cash', cashAmount)
end)

lib.addCommand(Lang:t('commands.bank'), {
    help = Lang:t('commands.help.bank'),
}, function(source)
    local player = QBCore.Functions.GetPlayer(source)
    local bankAmount = player.PlayerData.money.bank
    TriggerClientEvent('hud:client:ShowAccounts', source, 'bank', bankAmount)
end)

lib.addCommand('dev', {
    help = Lang:t('commands.help.dev'),
    restricted = 'group.admin'
}, function(source)
    TriggerClientEvent("qb-admin:client:ToggleDevmode", source)
end)
