local speedMultiplier = Config.UseMPH and 2.23694 or 3.6
local seatbeltOn = false
local cruiseOn = false
local showAltitude = false
local showSeatbelt = false
local nos = 0
local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local nitroActive = 0
local harness = false
local hp = 100
local armed = false
local parachute = -1
local oxygen = 100
local dev = false
local playerDead = false
local showMenu = false
local showCircleB = false
local showSquareB = false
local CinematicHeight = 0.2
local w = 0
local hasWeapon = false

DisplayRadar(false)

local function cinematicShow(bool)
    SetBigmapActive(true, false)
    Wait(0)
    SetBigmapActive(false, false)
    if bool then
        for i = CinematicHeight, 0, -1.0 do
            Wait(10)
            w = i
        end
    else
        for i = 0, CinematicHeight, 1.0 do
            Wait(10)
            w = i
        end
    end
end

local function loadSettings(settings)
    for k, v in pairs(settings) do
        if k == 'isToggleMapShapeChecked' then
            Config.Menu.isToggleMapShapeChecked = v
            SendNUIMessage({test = true, event = k, toggle = v})
        elseif k == 'isCineamticModeChecked' then
            Config.Menu.isCineamticModeChecked = v
            cinematicShow(v)
            SendNUIMessage({test = true, event = k, toggle = v})
        elseif k == 'isChangeFPSChecked' then
            Config.Menu[k] = v
            local val = v and 'Optimized' or 'Synced'
            SendNUIMessage({test = true, event = k, toggle = val})
        else
            Config.Menu[k] = v
            SendNUIMessage({test = true, event = k, toggle = v})
        end
    end
    exports.qbx_core:Notify(Lang:t('notify.hud_settings_loaded'), 'success')
    Wait(1000)
    TriggerEvent('hud:client:LoadMap')
end

local function saveSettings()
    SetResourceKvp('hudSettings', json.encode(Config.Menu))
end

local function hasHarness(items)
    if not cache.vehicle then return end

    local _harness = false
    if items then
        for _, v in pairs(items) do
            if v.name == 'harness' then
                _harness = true
            end
        end
    end

    harness = _harness
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then loadSettings(json.decode(hudSettings)) end
    stress = QBX.PlayerData.metadata.stress
    hunger = QBX.PlayerData.metadata.hunger
    thirst = QBX.PlayerData.metadata.thirst
    hp = QBX.PlayerData.metadata.health
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000)
    local hudSettings = GetResourceKvpString('hudSettings')
    if hudSettings then loadSettings(json.decode(hudSettings)) end
end)

-- Callbacks & Events
RegisterCommand('menu', function()
    Wait(50)
    if showMenu then return end
    TriggerEvent('hud:client:playOpenMenuSounds')
    SetNuiFocus(true, true)
    SendNUIMessage({action = 'open'})
    showMenu = true
end, false)

RegisterNUICallback('closeMenu', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:playCloseMenuSounds')
    showMenu = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterKeyMapping('menu', Lang:t('info.open_menu'), 'keyboard', Config.OpenMenu)

-- Reset hud
local function restartHud()
    TriggerEvent('hud:client:playResetHudSounds')
    exports.qbx_core:Notify(Lang:t('notify.hud_restart'), 'error')
    if cache.vehicle then
        Wait(2600)
        SendNUIMessage({action = 'car', show = false})
        SendNUIMessage({action = 'car', show = true})
    end
    Wait(2600)
    SendNUIMessage({action = 'hudtick', show = false})
    SendNUIMessage({action = 'hudtick', show = true})
    Wait(2600)
    exports.qbx_core:Notify(Lang:t('notify.hud_start'), 'success')
end

RegisterNUICallback('restartHud', function(_, cb)
    Wait(50)
    restartHud()
    cb('ok')
end)

RegisterCommand('resethud', function(_, cb)
    Wait(50)
    restartHud()
    cb('ok')
end)

RegisterNUICallback('resetStorage', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:resetStorage')
    cb('ok')
end)

RegisterNetEvent('hud:client:resetStorage', function()
    Wait(50)
    if Config.Menu.isResetSoundsChecked then
        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'airwrench', 0.1)
    end
    local menu = lib.callback.await('hud:server:getMenu', false)
    loadSettings(menu)
    SetResourceKvp('hudSettings', json.encode(menu))
end)

-- Notifications
RegisterNUICallback('openMenuSounds', function(_, cb)
    Wait(50)
    Config.Menu.isOpenMenuSoundsChecked = not Config.Menu.isOpenMenuSoundsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:playOpenMenuSounds', function()
    Wait(50)
    if not Config.Menu.isOpenMenuSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'monkeyopening', 0.5)
end)

RegisterNetEvent('hud:client:playCloseMenuSounds', function()
    Wait(50)
    if not Config.Menu.isOpenMenuSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'catclosing', 0.05)
end)

RegisterNUICallback('resetHudSounds', function(_, cb)
    Wait(50)
    Config.Menu.isResetSoundsChecked = not Config.Menu.isResetSoundsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:playResetHudSounds', function()
    Wait(50)
    if not Config.Menu.isResetSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'airwrench', 0.1)
end)

RegisterNUICallback('checklistSounds', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:checklistSounds')
    cb('ok')
end)

RegisterNetEvent('hud:client:checklistSounds', function()
    Wait(50)
    Config.Menu.isListSoundsChecked = not Config.Menu.isListSoundsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
end)

RegisterNetEvent('hud:client:playHudChecklistSound', function()
    Wait(50)
    if not Config.Menu.isListSoundsChecked then return end
    TriggerServerEvent('InteractSound_SV:PlayOnSource', 'shiftyclick', 0.5)
end)

RegisterNUICallback('showOutMap', function(_, cb)
    Wait(50)
    Config.Menu.isOutMapChecked = not Config.Menu.isOutMapChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showOutCompass', function(_, cb)
    Wait(50)
    Config.Menu.isOutCompassChecked = not Config.Menu.isOutCompassChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showFollowCompass', function(_, cb)
	Wait(50)
    Config.Menu.isCompassFollowChecked = not Config.Menu.isCompassFollowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showMapNotif', function(_, cb)
    Wait(50)
    Config.Menu.isMapNotifChecked = not Config.Menu.isMapNotifChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showFuelAlert', function(_, cb)
    Wait(50)
    Config.Menu.isLowFuelChecked = not Config.Menu.isLowFuelChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showCinematicNotif', function(_, cb)
    Wait(50)
    Config.Menu.isCinematicNotifChecked = not Config.Menu.isCinematicNotifChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

-- Status
RegisterNUICallback('dynamicHealth', function(_, cb)
    Wait(50)
    TriggerEvent('hud:client:ToggleHealth')
    cb('ok')
end)

RegisterNetEvent('hud:client:ToggleHealth', function()
    Wait(50)
    Config.Menu.isDynamicHealthChecked = not Config.Menu.isDynamicHealthChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
end)

RegisterNUICallback('dynamicArmor', function(_, cb)
    Wait(50)
    Config.Menu.isDynamicArmorChecked = not Config.Menu.isDynamicArmorChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicHunger', function(_, cb)
    Wait(50)
    Config.Menu.isDynamicHungerChecked = not Config.Menu.isDynamicHungerChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicThirst', function(_, cb)
    Wait(50)
    Config.Menu.isDynamicThirstChecked = not Config.Menu.isDynamicThirstChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicStress', function(_, cb)
    Wait(50)
    Config.Menu.isDynamicStressChecked = not Config.Menu.isDynamicStressChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicOxygen', function(_, cb)
    Wait(50)
    Config.Menu.isDynamicOxygenChecked = not Config.Menu.isDynamicOxygenChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

-- Vehicle
RegisterNUICallback('changeFPS', function(_, cb)
    Wait(50)
    Config.Menu.isChangeFPSChecked = not Config.Menu.isChangeFPSChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('HideMap', function(_, cb)
    Wait(50)
    Config.Menu.isHideMapChecked = not Config.Menu.isHideMapChecked
    DisplayRadar(not Config.Menu.isHideMapChecked)
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:LoadMap', function()
    Wait(50)
    -- Credit to Dalrae for the solve.
    local defaultAspectRatio = 1920 / 1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio-aspectRatio) / 3.6) - 0.008
    end
    if Config.Menu.isToggleMapShapeChecked == 'square' then
        lib.requestStreamedTextureDict('squaremap', false)
        if Config.Menu.isMapNotifChecked then
            exports.qbx_core:Notify(Lang:t('notify.load_square_map'), 'inform')
        end
        SetMinimapClipType(0)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
        AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
        -- 0.0 = nav symbol and icons left
        -- 0.1638 = nav symbol and icons stretched
        -- 0.216 = nav symbol and icons raised up
        SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)

        -- icons within map
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)

        -- -0.01 = map pulled left
        -- 0.025 = map raised up
        -- 0.262 = map stretched
        -- 0.315 = map shorten
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetBigmapActive(true, false)
        SetMinimapClipType(0)
        Wait(50)
        SetBigmapActive(false, false)
        if Config.Menu.isToggleMapBordersChecked then
            showCircleB = false
            showSquareB = true
        end
        Wait(1200)
        if Config.Menu.isMapNotifChecked then
            exports.qbx_core:Notify(Lang:t('notify.loaded_square_map'), 'success')
        end
    elseif Config.Menu.isToggleMapShapeChecked == 'circle' then
        lib.requestStreamedTextureDict('circlemap', false)
        if Config.Menu.isMapNotifChecked then
            exports.qbx_core:Notify(Lang:t('notify.load_circle_map'), 'inform')
        end
        SetMinimapClipType(1)
        AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'circlemap', 'radarmasksm')
        AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'circlemap', 'radarmasksm')
        -- -0.0100 = nav symbol and icons left
        -- 0.180 = nav symbol and icons stretched
        -- 0.258 = nav symbol and icons raised up
        SetMinimapComponentPosition('minimap', 'L', 'B', -0.0100 + minimapOffset, -0.030, 0.180, 0.258)

        -- icons within map
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.200 + minimapOffset, 0.0, 0.065, 0.20)

        -- -0.00 = map pulled left
        -- 0.015 = map raised up
        -- 0.252 = map stretched
        -- 0.338 = map shorten
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.015, 0.252, 0.338)
        SetBlipAlpha(GetNorthRadarBlip(), 0)
        SetMinimapClipType(1)
        SetBigmapActive(true, false)
        Wait(50)
        SetBigmapActive(false, false)
        if Config.Menu.isToggleMapBordersChecked then
            showSquareB = false
            showCircleB = true
        end
        Wait(1200)
        if Config.Menu.isMapNotifChecked then
            exports.qbx_core:Notify(Lang:t('notify.loaded_circle_map'), 'success')
        end
    end
end)

RegisterNUICallback('ToggleMapShape', function(_, cb)
    Wait(50)
    if not Config.Menu.isHideMapChecked then
        Config.Menu.isToggleMapShapeChecked = Config.Menu.isToggleMapShapeChecked == 'circle' and 'square' or 'circle'
        Wait(50)
        TriggerEvent('hud:client:LoadMap')
    end
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('ToggleMapBorders', function(_, cb)
    Wait(50)
    Config.Menu.isToggleMapBordersChecked = not Config.Menu.isToggleMapBordersChecked
    if Config.Menu.isToggleMapBordersChecked then
        if Config.Menu.isToggleMapShapeChecked == 'square' then
            showSquareB = true
        else
            showCircleB = true
        end
    else
        showSquareB = false
        showCircleB = false
    end
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicEngine', function(_, cb)
    Wait(50)
    Config.Menu.isDynamicEngineChecked = not Config.Menu.isDynamicEngineChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('dynamicNitro', function(_, cb)
    Wait(50)
    Config.Menu.isDynamicNitroChecked = not Config.Menu.isDynamicNitroChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

-- Compass
RegisterNUICallback('showCompassBase', function(_, cb)
	Wait(50)
    Config.Menu.isCompassShowChecked = not Config.Menu.isCompassShowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showStreetsNames', function(_, cb)
	Wait(50)
    Config.Menu.isShowStreetsChecked = not Config.Menu.isShowStreetsChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showPointerIndex', function(_, cb)
	Wait(50)
    Config.Menu.isPointerShowChecked = not Config.Menu.isPointerShowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('showDegreesNum', function(_, cb)
	Wait(50)
    Config.Menu.isDegreesShowChecked = not Config.Menu.isDegreesShowChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('changeCompassFPS', function(_, cb)
	Wait(50)
    Config.Menu.isChangeCompassFPSChecked = not Config.Menu.isChangeCompassFPSChecked
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNUICallback('cinematicMode', function(_, cb)
    Wait(50)
    if Config.Menu.isCineamticModeChecked then
        cinematicShow(false)
        Config.Menu.isCineamticModeChecked = false
        if Config.Menu.isCinematicNotifChecked then
            exports.qbx_core:Notify(Lang:t('notify.cinematic_off'), 'error')
        end
        DisplayRadar(true)
    else
        cinematicShow(true)
        Config.Menu.isCineamticModeChecked = true
        if Config.Menu.isCinematicNotifChecked then
            exports.qbx_core:Notify(Lang:t('notify.cinematic_on'), 'success')
        end
    end
    TriggerEvent('hud:client:playHudChecklistSound')
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:ToggleAirHud', function()
    showAltitude = not showAltitude
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst) -- Triggered in qb-core
    hunger = newHunger
    thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress) -- Add this event with adding stress elsewhere
    stress = newStress
end)

RegisterNetEvent('hud:client:ToggleShowSeatbelt', function()
    showSeatbelt = not showSeatbelt
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() -- Triggered in smallresources
    seatbeltOn = not seatbeltOn
end)

RegisterNetEvent('seatbelt:client:ToggleCruise', function() -- Triggered in smallresources
    cruiseOn = not cruiseOn
end)

RegisterNetEvent('hud:client:UpdateNitrous', function(_, nitroLevel, bool)
    nos = nitroLevel
    nitroActive = bool
end)

RegisterNetEvent('hud:client:UpdateHarness', function(harnessHp)
    hp = harnessHp
end)

RegisterNetEvent('qb-admin:client:ToggleDevmode', function()
    dev = not dev
end)

local function IsWhitelistedWeaponArmed(weapon)
    if weapon then
        for _, v in pairs(Config.WhitelistedWeaponArmed) do
            if weapon == v then
                return true
            end
        end
    end
    return false
end

local prevPlayerStats = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}

local function updatePlayerHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevPlayerStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevPlayerStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'hudtick',
            show = data[1],
            dynamicHealth = data[2],
            dynamicArmor = data[3],
            dynamicHunger = data[4],
            dynamicThirst = data[5],
            dynamicStress = data[6],
            dynamicOxygen = data[7],
            dynamicEngine = data[8],
            dynamicNitro = data[9],
            health = data[10],
            playerDead = data[11],
            armor = data[12],
            thirst = data[13],
            hunger = data[14],
            stress = data[15],
            voice = data[16],
            radio = data[17],
            talking = data[18],
            armed = data[19],
            oxygen = data[20],
            parachute = data[21],
            nos = data[22],
            cruise = data[23],
            nitroActive = data[24],
            harness = data[25],
            hp = data[26],
            speed = data[27],
            engine = data[28],
            cinematic = data[29],
            dev = data[30],
        })
    end
end

local prevVehicleStats = {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}

local function updateVehicleHud(data)
    local shouldUpdate = false
    local invOpen = LocalPlayer.state.invOpen
    for k, v in pairs(data) do
        if prevVehicleStats[k] ~= v then shouldUpdate = true break end
    end
    prevVehicleStats = data
    if shouldUpdate and not invOpen then
        SendNUIMessage({
            action = 'car',
            show = data[1],
            isPaused = data[2],
            seatbelt = data[3],
            speed = data[4],
            fuel = data[5],
            altitude = data[6],
            showAltitude = data[7],
            showSeatbelt = data[8],
            showSquareB = data[9],
            showCircleB = data[10],
        })
    end
end

local lastFuelUpdate = 0
local lastFuelCheck = 0

local function getFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(GetVehicleFuelLevel(vehicle))
    end
    return lastFuelCheck
end

-- HUD Update loop

CreateThread(function()
    local wasInVehicle = false
    while true do
        if Config.Menu.isChangeFPSChecked then
            Wait(500)
        else
            Wait(50)
        end
        if LocalPlayer.state.isLoggedIn then
            local show = true
            local weapon = GetSelectedPedWeapon(cache.ped)
            -- Player hud
            if not IsWhitelistedWeaponArmed(weapon) then
                if weapon ~= `WEAPON_UNARMED` then
                    armed = true
                else
                    armed = false
                end
            end
            playerDead = IsEntityDead(cache.ped) or QBX.PlayerData.metadata.inlaststand or QBX.PlayerData.metadata.isdead
            parachute = GetPedParachuteState(cache.ped)
            -- Stamina
            if not IsEntityInWater(cache.ped) then
                oxygen = 100 - GetPlayerSprintStaminaRemaining(cache.playerId)
            end
            -- Oxygen
            if IsEntityInWater(cache.ped) then
                oxygen = GetPlayerUnderwaterTimeRemaining(cache.playerId) * 10
            end
            -- Player hud
            local talking = NetworkIsPlayerTalking(cache.playerId)
            local voice = 0
            if LocalPlayer.state.proximity then
                voice = LocalPlayer.state.proximity.distance
            end
            if IsPauseMenuActive() then
                show = false
            end
            if not (cache.vehicle and not IsThisModelABicycle(cache.vehicle)) then
            updatePlayerHud({
                show,
                Config.Menu.isDynamicHealthChecked,
                Config.Menu.isDynamicArmorChecked,
                Config.Menu.isDynamicHungerChecked,
                Config.Menu.isDynamicThirstChecked,
                Config.Menu.isDynamicStressChecked,
                Config.Menu.isDynamicOxygenChecked,
                Config.Menu.isDynamicEngineChecked,
                Config.Menu.isDynamicNitroChecked,
                GetEntityHealth(cache.ped) - 100,
                playerDead,
                GetPedArmour(cache.ped),
                thirst,
                hunger,
                stress,
                voice,
                LocalPlayer.state.radioChannel,
                talking,
                armed,
                oxygen,
                parachute,
                -1,
                cruiseOn,
                nitroActive,
                harness,
                hp,
                math.ceil(GetEntitySpeed(cache.vehicle) * speedMultiplier),
                -1,
                Config.Menu.isCineamticModeChecked,
                dev,
            })
            end
            -- Vehicle hud
            if IsPedInAnyHeli(cache.ped) or IsPedInAnyPlane(cache.ped) then
                showAltitude = true
                showSeatbelt = false
            end
            if cache.vehicle and not IsThisModelABicycle(cache.vehicle) then
                if not wasInVehicle then
                    DisplayRadar(true)
                end
                wasInVehicle = true
                updatePlayerHud({
                    show,
                    Config.Menu.isDynamicHealthChecked,
                    Config.Menu.isDynamicArmorChecked,
                    Config.Menu.isDynamicHungerChecked,
                    Config.Menu.isDynamicThirstChecked,
                    Config.Menu.isDynamicStressChecked,
                    Config.Menu.isDynamicOxygenChecked,
                    Config.Menu.isDynamicEngineChecked,
                    Config.Menu.isDynamicNitroChecked,
                    GetEntityHealth(cache.ped) - 100,
                    playerDead,
                    GetPedArmour(cache.ped),
                    thirst,
                    hunger,
                    stress,
                    voice,
                    LocalPlayer.state.radioChannel,
                    talking,
                    armed,
                    oxygen,
                    GetPedParachuteState(cache.ped),
                    nos,
                    cruiseOn,
                    nitroActive,
                    harness,
                    hp,
                    math.ceil(GetEntitySpeed(cache.vehicle) * speedMultiplier),
                    (GetVehicleEngineHealth(cache.vehicle) / 10),
                    Config.Menu.isCineamticModeChecked,
                    dev,
                })
                updateVehicleHud({
                    show,
                    IsPauseMenuActive(),
                    seatbeltOn,
                    math.ceil(GetEntitySpeed(cache.vehicle) * speedMultiplier),
                    getFuelLevel(cache.vehicle),
                    math.ceil(GetEntityCoords(cache.ped).z * 0.5),
                    showAltitude,
                    showSeatbelt,
                    showSquareB,
                    showCircleB,
                })
                showAltitude = false
                showSeatbelt = true
            else
                if wasInVehicle then
                    wasInVehicle = false
                    SendNUIMessage({
                        action = 'car',
                        show = false,
                        seatbelt = false,
                        cruise = false,
                    })
                    seatbeltOn = false
                    cruiseOn = false
                    harness = false
                end
                DisplayRadar(Config.Menu.isOutMapChecked)
            end
        else
            SendNUIMessage({
                action = 'hudtick',
                show = false
            })
        end
    end
end)

-- Low fuel
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            if cache.vehicle and not IsThisModelABicycle(GetEntityModel(cache.vehicle)) then
                if getFuelLevel(cache.vehicle) <= 20 then -- At 20% Fuel Left
                    if Config.Menu.isLowFuelChecked then
                        TriggerServerEvent('InteractSound_SV:PlayOnSource', 'pager', 0.10)
                        exports.qbx_core:Notify(Lang:t('notify.low_fuel'), 'error')
                        Wait(60000) -- repeats every 1 min until empty
                    end
                end
            end
        end
        Wait(10000)
    end
end)

-- Money HUD

RegisterNetEvent('hud:client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = amount
        })
    else
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = amount
        })
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isMinus)
    cashAmount = QBX.PlayerData.money.cash
    bankAmount = QBX.PlayerData.money.bank
    SendNUIMessage({
        action = 'updatemoney',
        cash = cashAmount,
        bank = bankAmount,
        amount = amount,
        minus = isMinus,
        type = type
    })
end)

-- Harness Check

CreateThread(function()
    while true do
        Wait(1000)
        if cache.vehicle then
            hasHarness(QBX.PlayerData.items)
        end
    end
end)

-- Stress Gain

CreateThread(function() -- Speeding
    while true do
        if LocalPlayer.state.isLoggedIn then
            if cache.vehicle then
                local vehClass = GetVehicleClass(cache.vehicle)
                local speed = GetEntitySpeed(cache.vehicle) * speedMultiplier

                if vehClass ~= 13 and vehClass ~= 14 and vehClass ~= 15 and vehClass ~= 16 and vehClass ~= 21 then
                    local stressSpeed
                    if vehClass == 8 then
                        stressSpeed = Config.MinimumSpeed
                    else
                        stressSpeed = seatbeltOn and Config.MinimumSpeed or Config.MinimumSpeedUnbuckled
                    end
                    if speed >= stressSpeed then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    end
                end
            end
        end
        Wait(10000)
    end
end)

local function IsWhitelistedWeaponStress(weapon)
    if weapon then
        for _, v in pairs(Config.WhitelistedWeaponStress) do
            if weapon == v then
                return true
            end
        end
    end
    return false
end

local function startWeaponStressThread(weapon)
    if IsWhitelistedWeaponStress(weapon) then return end
    hasWeapon = true

    CreateThread(function()
        while hasWeapon do
            if IsPedShooting(cache.ped) then
                if math.random() <= Config.StressChance then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 5))
                end
            end
            Wait(0)
        end
    end)
end

AddEventHandler('ox_inventory:currentWeapon', function(currentWeapon)
    hasWeapon = false
    Wait(0)

    if not currentWeapon then return end

    startWeaponStressThread(currentWeapon.name)
end)

-- Stress Screen Effects

local function GetBlurIntensity(stresslevel)
    for _, v in pairs(Config.Intensity.blur) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(Config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

CreateThread(function()
    while true do
        local effectInterval = GetEffectInterval(stress)
        if stress >= 100 then
            local blurIntensity = GetBlurIntensity(stress)
            local fallRepeat = math.random(2, 4)
            local ragdollTimeout = fallRepeat * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(blurIntensity)
            TriggerScreenblurFadeOut(1000.0)

            if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
                local forwardVector = GetEntityForwardVector(cache.ped)
                SetPedToRagdollWithFall(cache.ped, ragdollTimeout, ragdollTimeout, 1, forwardVector.x, forwardVector.y, forwardVector.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(1000)
            for _ = 1, fallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(blurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stress >= Config.MinimumStress then
            local blurIntensity = GetBlurIntensity(stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(blurIntensity)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(effectInterval)
    end
end)

-- Minimap update
CreateThread(function()
    while true do
        SetBigmapActive(false, false)
        Wait(500)
    end
end)

local function BlackBars()
    DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
    DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
end

CreateThread(function()
    local minimap = lib.requestScaleformMovie('minimap')
    while true do
        if w > 0 then
            BlackBars()
            DisplayRadar(false)
            SendNUIMessage({
                action = 'hudtick',
                show = false,
            })
            SendNUIMessage({
                action = 'car',
                show = false,
            })
        end
        Wait(0)
    end
end)

-- Compass
local prevBaseplateStats = {nil, nil, nil, nil, nil, nil, nil}

local function updateBaseplateHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevBaseplateStats[k] ~= v then shouldUpdate = true break end
    end
    prevBaseplateStats = data
    if shouldUpdate then
        SendNUIMessage ({
            action = 'baseplate',
            show = data[1],
            street1 = data[2],
            street2 = data[3],
            showCompass = data[4],
            showStreets = data[5],
            showPointer = data[6],
            showDegrees = data[7],
        })
    end
end

local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}

local function getCrossroads(player)
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(player)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = {GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2)}
    end
    return lastCrossroadCheck
end

-- Compass Update loop

CreateThread(function()
	local lastHeading = 1
    local heading
	while true do
        if Config.Menu.isChangeCompassFPSChecked then
            Wait(50)
        else
            Wait(0)
        end
        local show = true
        local camRot = GetGameplayCamRot(0)
        if Config.Menu.isCompassFollowChecked then
            heading = math.round(360.0 - ((camRot.z + 360.0) % 360.0))
        else
            heading = math.round(360.0 - GetEntityHeading(cache.ped))
        end
		if heading == 360 then heading = 0 end
        if heading ~= lastHeading then
            if cache.vehicle then
                local crossroads = getCrossroads(cache.ped)
                SendNUIMessage ({
                    action = 'update',
                    value = heading
                })
                updateBaseplateHud({
                    show,
                    crossroads[1],
                    crossroads[2],
                    Config.Menu.isCompassShowChecked,
                    Config.Menu.isShowStreetsChecked,
                    Config.Menu.isPointerShowChecked,
                    Config.Menu.isDegreesShowChecked,
                })
            else
                if Config.Menu.isOutCompassChecked then
                    SendNUIMessage ({
                        action = 'update',
                        value = heading
                    })
                    SendNUIMessage ({
                        action = 'baseplate',
                        show = true,
                        showCompass = true,
                    })
                else
                    SendNUIMessage ({
                        action = 'baseplate',
                        show = false,
                    })
                end
            end
        end
        lastHeading = heading
    end
end)

RegisterNetEvent('qbx_hud:client:showHud', function()
    if cache.vehicle then
        DisplayRadar(true)
        updateVehicleHud({
            true,
            IsPauseMenuActive(),
            seatbeltOn,
            math.ceil(GetEntitySpeed(cache.vehicle) * speedMultiplier),
            getFuelLevel(cache.vehicle),
            math.ceil(GetEntityCoords(cache.ped).z * 0.5),
            showAltitude,
            showSeatbelt,
            showSquareB,
            showCircleB,
        })
    end
end)

RegisterNetEvent('qbx_hud:client:hideHud', function()
    if cache.vehicle then
        DisplayRadar(false)
        SendNUIMessage({
            action = 'car',
            show = false,
        })
    end
end)
