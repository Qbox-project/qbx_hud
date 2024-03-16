local config = require 'config.client'
local playerState = LocalPlayer.state
Stress = playerState.stress or 0
local displayBars = false
local toggleHud = true
local toggleCinematic = false

local directions = {
    N = 360,
    NE = 315,
    E = 270,
    SE = 225,
    S = 180,
    SW = 135,
    W = 90,
    NW = 45,
}

CreateThread(function()
    local currentHeading, currentStreet, currentStreet2
    local sleep, minimapShown
    while true do
        Wait(sleep)
        if not IsMinimapRendering() then
            sleep, minimapShown = 1000, false
            SendNUIMessage({
                update = true,
                data = {
                    {
                        type = 'compass',
                        show = false,
                    }
                }
            })
        else
            local coords = GetEntityCoords(cache.ped)
            local var1, var2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            local street, hash2 = GetStreetNameFromHashKey(var1), GetStreetNameFromHashKey(var2)
            local street2 = ("%s%s"):format(hash2 ~= '' and hash2 .. ', ' or '', GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z)))
            local heading = GetEntityHeading(cache.ped) % 360
            local convertedHeading = 'N'

            for k, v in pairs(directions) do
                if heading >= v - 22.5 and heading <= v + 22.5 then
                    convertedHeading = k
                    break
                end
            end

            if currentHeading ~= convertedHeading or currentStreet ~= street or currentStreet2 ~= street2 then
                SendNUIMessage({
                    update = true,
                    data = {
                        {
                            type = 'compass',
                            show = not minimapShown or nil,
                            heading = currentHeading ~= convertedHeading and convertedHeading or nil,
                            street = currentStreet ~= street and street or nil,
                            street2 = currentStreet2 ~= street2 and street2 or nil,
                        }
                    }
                })
                currentHeading, currentStreet, currentStreet2 = convertedHeading, street, street2
                minimapShown = true
            end
            sleep = 500
            collectgarbage()
        end
    end
end)

local isInVehicle = false
local currentindicatorL, currentindicatorR = false, false
local function vehiclehudloop()
    local indl, indr = false, false
    local currentindicators = GetVehicleIndicatorLights(cache.vehicle)
    if currentindicators == 0 then
        indl, indr = false, false
    elseif currentindicators == 1 then
        indl = true
    elseif currentindicators == 2 then
        indr = true
    elseif currentindicators == 3 then
        indl, indr = true, true
    end

    CreateThread(function()
        while isInVehicle do
            local HasTrailer, Trailer = GetVehicleTrailerVehicle(cache.vehicle)
            if IsControlJustPressed(1, 174) then     -- <- is pressed
                indl = not indl
                SetVehicleIndicatorLights(cache.vehicle, 1, indl)
                if HasTrailer then
                    SetVehicleIndicatorLights(Trailer, 1, indl)
                end
            end
            if IsControlJustPressed(1, 175) then     -- -> is pressed
                indr = not indr
                SetVehicleIndicatorLights(cache.vehicle, 0, indr)
                if HasTrailer then
                    SetVehicleIndicatorLights(Trailer, 0, indr)
                end
            end
            if IsControlJustPressed(1, 173) then     -- down is pressed
                indl = not indl
                indr = not indr
                SetVehicleIndicatorLights(cache.vehicle, 1, indl)
                SetVehicleIndicatorLights(cache.vehicle, 0, indr)
                if HasTrailer then
                    SetVehicleIndicatorLights(Trailer, 1, indl)
                    SetVehicleIndicatorLights(Trailer, 0, indr)
                end
            end
            if IsMinimapRendering() and (currentindicatorL ~= indl or currentindicatorR ~= indr) then
                currentindicatorL, currentindicatorR = indl, indr
                SendNUIMessage({
                    update = true,
                    data = {
                        {
                            type = 'dashboardlights',
                            indicatorL = indl,
                            indicatorR = indr,
                        }
                    }
                })
            end
            Wait(0)
        end
    end)

    CreateThread(function()
        local alert = 0
        local sleep
        while isInVehicle do
            sleep = 1000
            if GetIsVehicleEngineRunning(cache.vehicle) and IsMinimapRendering() then
                local _, highbeam, lowbeam = GetVehicleLightsState(cache.vehicle)
                local nitroLevel = Entity(cache.vehicle).state.nitro or 0
                SendNUIMessage({
                    update = true,
                    data = {
                        {
                            type = 'vehiclehud',
                            show = true
                        },
                        {
                            type = 'speed',
                            speed = GetEntitySpeed(cache.vehicle) * config.speedMultiplier
                        },
                        {
                            type = 'gauge',
                            name = 'fuel',
                            value = GetVehicleFuelLevel(cache.vehicle) or 100
                        },
                        {
                            type = 'gauge',
                            name = 'nitro',
                            value = nitroLevel,
                            show = nitroLevel > 0
                        },
                        {
                            type = 'dashboardlights',
                            highbeam = highbeam,
                            lowbeam = lowbeam
                        }
                    }
                })
                if config.lowFuelAlert and GetVehicleFuelLevel(cache.vehicle) < config.lowFuelAlert then
                    if alert > 0 then
                        alert = alert - 1
                    else
                        alert = 1500
                        qbx.playAudio({
                            audioName = "CONFIRM_BEEP",
                            audioRef = 'HUD_MINI_GAME_SOUNDSET',
                            source = cache.vehicle
                        })
                        exports.qbx_core:Notify(locale("notify.low_fuel"), "error")
                    end
                end
                sleep = 100
            end
            Wait(sleep)
        end
    end)
end

local function initVehicleHud()
    Wait(250)
    local data = {
        {
            type = 'vehiclehud',
            show = false
        }
    }

    if isInVehicle then
        local nitroLevel = Entity(cache.vehicle).state.nitro or 0
        data = {
            {
                type = 'gauge',
                name = 'nitro',
                value = nitroLevel,
                show = nitroLevel > 0
            },
            {
                type = 'speedmax',
                speed = GetVehicleEstimatedMaxSpeed(cache.vehicle) * 5.6 -- meh idk
            }
        }
        vehiclehudloop()
    end

    SendNUIMessage({
        update = true,
        data = data
    })
end

lib.onCache('vehicle', function(value)
    isInVehicle = value
    initVehicleHud()
    if not value then
        playerState:set('seatbelt', false, true)
        playerState:set('harness', false, true)
        SendNUIMessage({
            update = true,
            data = {
                {
                    type = 'seatbelt',
                    value = false,
                }
            }
        })
    end
    if not config.minimapAlwaysOn then
        DisplayRadar(value)
    end
end)

local function initHud()
    if config.minimapAlwaysOn then
        DisplayRadar(playerState.isLoggedIn)
    end
    SendNUIMessage({
        update = true,
        data = {
            { type = 'showHud', value = playerState.isLoggedIn },
            { type = 'progress', name = 'hunger', value = playerState.hunger or 0, option = { backgroundColor = playerState.hunger and playerState.hunger < 30 and '#881111ff' or false } },
            { type = 'progress', name = 'thirst', value = playerState.thirst or 0, option = { backgroundColor = playerState.thirst and playerState.thirst < 30 and '#881111ff' or false } },
            { type = 'progress', name = 'stress', value = playerState.stress or 0, option = { backgroundColor = playerState.stress and playerState.stress > 75 and '#881111ff' or false } },
            { type = 'progress', name = 'voice', value = playerState.proximity.distance * 10 },
            { type = 'balance', set = true, isCash = true, value = QBX.PlayerData?.money?.cash},
            { type = 'balance', set = true, isCash = false, value = QBX.PlayerData?.money?.bank },
        }
    })
end

RegisterNetEvent('hud:client:OnMoneyChange', function(type, amount, isNegative)
    SendNUIMessage({
        update = true,
        data = {{
            type = 'balance',
            set = true,
            value = QBX.PlayerData.money[type],
            amount = amount,
            isNegative = isNegative,
            isCash = type == 'cash' and true or false
        }},
    })
end)

RegisterNetEvent('qbx_hud:client:showMoney', function(isCash)
    SendNUIMessage({
        update = true,
        data = {{
            type = 'balance',
            isCash = isCash
        }},
    })
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        isInVehicle = cache.vehicle
        initVehicleHud()
        initHud()
    end
end)

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
                    backgroundColor = (playerState.radioActive and '#5A93FF') or (talking and '#FF935A') or false
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

AddStateBagChangeHandler('hunger', ('player:%s'):format(cache.serverId), function(_, _, value)
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'hunger',
                value = value,
                option = {
                    backgroundColor = value < 30 and '#881111ff' or false,
                }
            }
        }
    })
end)

AddStateBagChangeHandler('thirst', ('player:%s'):format(cache.serverId), function(_, _, value)
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'thirst',
                value = value,
                option = {
                    backgroundColor = value < 30 and '#881111ff' or false,
                }
            }
        }
    })
end)

AddStateBagChangeHandler('stress', ('player:%s'):format(cache.serverId), function(_, _, value)
    Stress = value
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'progress',
                name = 'stress',
                value = value,
                option = {
                    backgroundColor = value > 75 and '#881111ff' or false,
                }
            }
        }
    })
end)


seatbeltOn = false
harnessOn = false
AddStateBagChangeHandler('seatbelt', ('player:%s'):format(cache.serverId), function(_, _, value)
    seatbeltOn = value
    if harnessOn then return end
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'seatbelt',
                value = value,
            }
        }
    })
end)

AddStateBagChangeHandler('harness', ('player:%s'):format(cache.serverId), function(_, _, value)
    harnessOn = value

    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'seatbelt',
                value = value or seatbeltOn,
                harness = value,
            }
        }
    })
end)

AddStateBagChangeHandler('isLoggedIn', ('player:%s'):format(cache.serverId), function(_, _, value)
    if value then
        isInVehicle = cache.vehicle
        initVehicleHud()
        initHud()
    end

    if config.minimapAlwaysOn then
        DisplayRadar(value)
    else
        DisplayRadar(value == false)
    end

    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'showHud',
                value = value,
            }
        }
    })
end)

CreateThread(function()
    -- Disable the minimap on login
    if not playerState.isLoggedIn then
        DisplayRadar(false)
    end

    while true do
        SetRadarBigmapEnabled(false, false)
        SetRadarZoom(200)
        Wait(500)
    end
end)

local function BlackBars()
    DrawRect(0.0, 0.0, 2.0, config.cinematicHeight, 0, 0, 0, 255)
    DrawRect(0.0, 1.0, 2.0, config.cinematicHeight, 0, 0, 0, 255)
end

local function cinematicThread()
    CreateThread(function()
        while displayBars do
            BlackBars()
            Wait(0)
        end
    end)
end

local function togglehud()
    toggleHud = not toggleHud
    if displayBars then
        toggleHud = false
    end

    DisplayRadar(toggleHud)
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'showHud',
                value = toggleHud,
            }
        }
    })
end

local function toggleCinematicMode()
    toggleCinematic = not toggleCinematic
    if toggleCinematic then
        cinematicThread()
        displayBars = true
    else
        displayBars = false
    end
    togglehud()
end

RegisterNetEvent('qbx_hud:client:toggleCinematicMode', function()
    toggleCinematicMode()
    exports.qbx_core:Notify(locale(("notify.cinematic_%s"):format(toggleCinematic and 'on' or 'off')))
end)

RegisterNetEvent('qbx_hud:client:hideHud', function()
    SendNUIMessage({
        update = true,
        data = {
            {
                type = 'showHud',
                value = false,
            }
        }
    })
end)

RegisterNetEvent('qbx_hud:client:showHud', function()
    if not toggleCinematic and toggleHud then
        SendNUIMessage({
            update = true,
            data = {
                {
                    type = 'showHud',
                    value = true,
                }
            }
        })
    end
end)

RegisterNetEvent('qbx_hud:client:togglehud', function()
    if not displayBars then
        togglehud()
        exports.qbx_core:Notify(locale(("notify.hud_%s"):format(toggleHud and 'on' or 'off')))
    end
end)