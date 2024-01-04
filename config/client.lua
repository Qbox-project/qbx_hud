return {
    speedMultiplier = 3.6, -- 3.6 for km/h, 2.236936 for mph
    whitelistedWeaponStress = {
        `weapon_petrolcan`,
        `weapon_hazardcan`,
        `weapon_fireextinguisher`
    },
    cinematicHeight = 0.15,
    lowFuelAlert = 15,
    minimapAlwaysOn = true,
    stress = {
        speedingMini = 180,
        speedingUnbuckledMini = 75,
        stressBlurMini = 40,
        stressChance = 0.05,
        speedingStress = {
            min = 1,
            max = 3,
        },
        intensity = {
            {
                min = 50,
                max = 60,
                intensity = 1500,
            },
            {
                min = 60,
                max = 70,
                intensity = 2000,
            },
            {
                min = 70,
                max = 80,
                intensity = 2500,
            },
            {
                min = 80,
                max = 90,
                intensity = 2700,
            },
            {
                min = 90,
                max = 100,
                intensity = 3000,
            },
        },
        effectInterval = {
            {
                min = 50,
                max = 60,
                timeout = math.random(180000, 240000)
            },
            {
                min = 60,
                max = 70,
                timeout = math.random(120000, 180000)
            },
            {
                min = 70,
                max = 80,
                timeout = math.random(90000, 120000)
            },
            {
                min = 80,
                max = 90,
                timeout = math.random(60000, 90000)
            },
            {
                min = 90,
                max = 100,
                timeout = math.random(30000, 60000)
            }
        },
    }
}