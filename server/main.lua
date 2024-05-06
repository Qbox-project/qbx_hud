lib.versionCheck('Qbox-project/qbx_hud')

AddEventHandler('ox_inventory:openedInventory', function(source)
    TriggerClientEvent('qbx_hud:client:hideHud', source)
end)

AddEventHandler('ox_inventory:closedInventory', function(source)
    TriggerClientEvent('qbx_hud:client:showHud', source)
end)