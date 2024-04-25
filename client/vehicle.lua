local config = require 'config.client'
local currentindicatorL, currentindicatorR = false, false
local getEntitySpeed = GetEntitySpeed
local getVehicleFuelLevel = GetVehicleFuelLevel
local getIsVehicleEngineRunning = GetIsVehicleEngineRunning
local getVehicleLightsState = GetVehicleLightsState
local getVehicleTrailerVehicle = GetVehicleTrailerVehicle
local getVehicleIndicatorLights = GetVehicleIndicatorLights
local isMinimapRendering = IsMinimapRendering
local isControlJustPressed = IsControlJustPressed
local setVehicleIndicatorLights = SetVehicleIndicatorLights
local sendNUIMessage = SendNUIMessage

local function vehiclehudloop()
    local currentindicators = getVehicleIndicatorLights(cache.vehicle)
    local indl = currentindicators == 1 or currentindicators == 3
    local indr = currentindicators == 2 or currentindicators == 3
    local warning = false

    CreateThread(function()
        local sleep
        while cache.seat == -1 do
            sleep = 1000
                if getIsVehicleEngineRunning(cache.vehicle) and isMinimapRendering() then
                local HasTrailer, Trailer = getVehicleTrailerVehicle(cache.vehicle)
                if isControlJustPressed(1, 174) then     -- <- is pressed
                    indl = warning or not indl
                    indr = indr and false
                    warning = false
                end
                if isControlJustPressed(1, 175) then     -- -> is pressed
                    indr = warning or not indr
                    indl = indl and false
                    warning = false
                end
                if isControlJustPressed(1, 173) then     -- down is pressed
                    warning = not warning
                    indl = warning
                    indr = warning
                end

                if isMinimapRendering() and (currentindicatorL ~= indl or currentindicatorR ~= indr) then
                    currentindicatorL, currentindicatorR = indl, indr

                    setVehicleIndicatorLights(cache.vehicle, 1, indl)
                    setVehicleIndicatorLights(cache.vehicle, 0, indr)
                    if HasTrailer then
                        setVehicleIndicatorLights(Trailer, 1, indl)
                        setVehicleIndicatorLights(Trailer, 0, indr)
                    end

                    sendNUIMessage({
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
                sleep = 0
            end
            Wait(sleep)
        end
    end)

    CreateThread(function()
        local alert = 0
        local sleep
        local showingHud = true
        while cache.vehicle do
            local data
            local engineIsRunning = getIsVehicleEngineRunning(cache.vehicle)
            if showingHud and not engineIsRunning then
                data = {
                    {
                        type = 'vehiclehud',
                        show = false
                    }
                }
                showingHud = false
            end

            sleep = 1000
            if engineIsRunning and isMinimapRendering() then
                showingHud = true
                local _, highbeam, lowbeam = getVehicleLightsState(cache.vehicle)
                data = {
                    {
                        type = 'vehiclehud',
                        show = true
                    },
                    {
                        type = 'speed',
                        speed = getEntitySpeed(cache.vehicle) * config.speedMultiplier
                    },
                    {
                        type = 'gauge',
                        name = 'fuel',
                        value = getVehicleFuelLevel(cache.vehicle) or 100
                    },
                    {
                        type = 'dashboardlights',
                        highbeam = highbeam,
                        lowbeam = lowbeam,
                    }
                }


                if config.lowFuelAlert and getVehicleFuelLevel(cache.vehicle) < config.lowFuelAlert then
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

            if data then
                sendNUIMessage({
                    update = true,
                    data = data
                })
            end
            Wait(sleep)
        end
    end)
end

local function initVehicleHud()
    local data = {
        {
            type = 'vehiclehud',
            show = false
        }
    }

    if cache.seat == -1 then
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

    sendNUIMessage({
        update = true,
        data = data
    })
end

qbx.entityStateHandler('nitro', function(veh, _, value)
    if veh ~= cache.vehicle then return end
    sendNUIMessage({
        update = true,
        data = {
            {
                type = 'gauge',
                name = 'nitro',
                value = value,
                show = value > 0
            }
        }
    })
end)

lib.onCache('vehicle', function(value)
    if not value then
        PlayerState:set('seatbelt', false, true)
        PlayerState:set('harness', false, true)
        sendNUIMessage({
            update = true,
            data = {
                {
                    type = 'vehiclehud',
                    show = false
                },
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

lib.onCache('seat', function(seat)
    if seat == -1 then
        SetTimeout(250, initVehicleHud)
    end
end)

CreateThread(function()
    SetTimeout(250, initVehicleHud)
end)

local harnessOn = false
AddStateBagChangeHandler('seatbelt', ('player:%s'):format(cache.serverId), function(_, _, value)
    if harnessOn then return end
    sendNUIMessage({
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

    sendNUIMessage({
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