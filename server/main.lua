lib.versionCheck('Qbox-project/qbx_hud')

AddEventHandler('ox_inventory:openedInventory', function(source)
    TriggerClientEvent('qbx_hud:client:hideHud', source)
end)

AddEventHandler('ox_inventory:closedInventory', function(source)
    TriggerClientEvent('qbx_hud:client:showHud', source)
end)

lib.addCommand('bank', {
    help = locale('commands.bank.help'),
    restricted = false,
}, function (source)
    TriggerClientEvent('qbx_hud:client:showMoney', source, false)
end)

lib.addCommand('cash', {
    help = locale('commands.cash.help'),
    restricted = false,
}, function (source)
    TriggerClientEvent('qbx_hud:client:showMoney', source, true)
end)

lib.addCommand('testfuel', {
    help = nil,
    params = {
        {name = 'amount', help = 'Amount of fuel to set', type = 'number'}
    },
    restricted = false,
}, function (source, args)
    Entity(GetVehiclePedIsIn(GetPlayerPed(source))).state.fuel = tonumber(args.amount)
end)