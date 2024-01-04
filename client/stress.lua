local config = require("config.client")
local stressConfig = config.stress

-- Stress Gain
CreateThread(function() -- Speeding
    while true do
        if LocalPlayer.state.isLoggedIn then
            if cache.vehicle and not LocalPlayer.state.harness and GetVehicleClass(cache.vehicle) ~= 8 then
                local speed = GetEntitySpeed(cache.vehicle) * config.speedMultiplier
                local stressSpeed = seatbeltOn and stressConfig.speedingMini or stressConfig.speedingUnbuckledMini
                if speed >= stressSpeed then
                    TriggerServerEvent('hud:server:GainStress', math.random(stressConfig.speedingStress.min, stressConfig.speedingStress.max))
                end
            end
        end
        Wait(10000)
    end
end)

local function IsWhitelistedWeaponStress(weapon)
    if weapon then
        for _, v in pairs(config.whitelistedWeaponStress) do
            if weapon == v then
                return true
            end
        end
    end
    return false
end

local shootingSleep = 500
CreateThread(function() -- Shooting
    while true do
        local isArmed = IsPedArmed(cache.ped, 7)
        if LocalPlayer.state.isLoggedIn and isArmed then
            local weapon = GetSelectedPedWeapon(cache.ped)
            if weapon ~= `WEAPON_UNARMED` then
                if IsPedShooting(cache.ped) and not IsWhitelistedWeaponStress(weapon) then
                    if math.random() < stressConfig.stressChance then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    end
                end
                shootingSleep = 0
            else
                shootingSleep = 1000
            end
        else
            shootingSleep = 1000
        end
        Wait(shootingSleep)
    end
end)

-- Stress Screen Effects
local function GetBlurIntensity(stresslevel)
    for _, v in pairs(stressConfig.intensity) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.intensity
        end
    end
    return 1500
end

local function GetEffectInterval(stresslevel)
    for _, v in pairs(stressConfig.effectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            return v.timeout
        end
    end
    return 60000
end

CreateThread(function()
    while true do
        local effectInterval = 2500
        if LocalPlayer.state.isLoggedIn then
            effectInterval = GetEffectInterval(stress)
            if stress >= 100 then
                local BlurIntensity = GetBlurIntensity(stress)
                local FallRepeat = math.random(2, 4)
                local RagdollTimeout = FallRepeat * 1750
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)

                if not cache.vehicle and not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
                    SetPedToRagdollWithFall(cache.ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(cache.ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
                end

                Wait(1000)
                for _ = 1, FallRepeat, 1 do
                    Wait(750)
                    TriggerScreenblurFadeIn(1000.0)
                    Wait(BlurIntensity)
                    TriggerScreenblurFadeOut(1000.0)
                    Wait(750)
                    TriggerScreenblurFadeIn(1000.0)
                    Wait(BlurIntensity)
                    TriggerScreenblurFadeOut(1000.0)
                    Wait(750)
                    TriggerScreenblurFadeIn(1000.0)
                    Wait(BlurIntensity)
                    TriggerScreenblurFadeOut(1000.0)
                end
            elseif stress >= stressConfig.stressBlurMini then
                local BlurIntensity = GetBlurIntensity(stress)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        end
        Wait(effectInterval)
    end
end)