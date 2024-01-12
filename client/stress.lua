local config = require("config.client")
local stressConfig = config.stress
local playerState = LocalPlayer.state

-- Stress Gain
CreateThread(function() -- Speeding
    while true do
        if playerState.isLoggedIn then
            if cache.vehicle and not playerState.harness and GetVehicleClass(cache.vehicle) ~= 8 then
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

local function armedLoop()
    while cache.weapon do
        if IsPedShooting(cache.ped) then
            if math.random() < stressConfig.stressChance then
                TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
            end
        end
        Wait(0)
    end
end

lib.onCache('weapon', function(weapon)
    if weapon and not config.whitelistedWeaponStress[weapon] then
        CreateThread(armedLoop)
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
        if playerState.isLoggedIn then
            effectInterval = GetEffectInterval(Stress)
            if Stress >= 100 then
                local BlurIntensity = GetBlurIntensity(Stress)
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
            elseif Stress >= stressConfig.stressBlurMini then
                local BlurIntensity = GetBlurIntensity(Stress)
                TriggerScreenblurFadeIn(1000.0)
                Wait(BlurIntensity)
                TriggerScreenblurFadeOut(1000.0)
            end
        end
        Wait(effectInterval)
    end
end)