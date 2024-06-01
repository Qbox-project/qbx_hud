return {
    menuKey = 'I', -- Key to open the HUD menu
    useMPH = true, -- If true, speed math will be done as MPH, if false KPH will be used (YOU HAVE TO CHANGE CONTENT IN STYLES.CSS TO DISPLAY THE CORRECT TEXT)

    stress = {
        chance = 0.1, -- Percentage stress chance when shooting (0-1)
        minForShaking = 50, -- Minimum stress level for screen shaking
        minForSpeeding = 1000, -- Minimum stress level for speeding while buckled
        minForSpeedingUnbuckled = 50, -- Minimum stress level for speeding while unbuckled
        whitelistedWeapons = { -- Weapons which don't give stress
            `weapon_petrolcan`,
            `weapon_hazardcan`,
            `weapon_fireextinguisher`,
        },
        blurIntensity = { -- Blur intensity for different stress levels
            [1] = {min = 50, max = 60, intensity = 1500},
            [2] = {min = 60, max = 70, intensity = 2000},
            [3] = {min = 70, max = 80, intensity = 2500},
            [4] = {min = 80, max = 90, intensity = 2700},
            [5] = {min = 90, max = 100, intensity = 3000},
        },
        effectInterval = { -- Effect interval for different stress levels
            [1] = {min = 50, max = 60, timeout = math.random(50000, 60000)},
            [2] = {min = 60, max = 70, timeout = math.random(40000, 50000)},
            [3] = {min = 70, max = 80, timeout = math.random(30000, 40000)},
            [4] = {min = 80, max = 90, timeout = math.random(20000, 30000)},
            [5] = {min = 90, max = 100, timeout = math.random(15000, 20000)},
        },
    },

    weaponsArmedMode = { -- Weapons which won't trigger armed mode
        -- Miscellaneous
        `weapon_petrolcan`,
        `weapon_hazardcan`,
        `weapon_fireextinguisher`,
        -- Melee
        `weapon_dagger`,
        `weapon_bat`,
        `weapon_bottle`,
        `weapon_crowbar`,
        `weapon_flashlight`,
        `weapon_golfclub`,
        `weapon_hammer`,
        `weapon_hatchet`,
        `weapon_knuckle`,
        `weapon_knife`,
        `weapon_machete`,
        `weapon_switchblade`,
        `weapon_nightstick`,
        `weapon_wrench`,
        `weapon_battleaxe`,
        `weapon_poolcue`,
        `weapon_briefcase`,
        `weapon_briefcase_02`,
        `weapon_garbagebag`,
        `weapon_handcuffs`,
        `weapon_bread`,
        `weapon_stone_hatchet`,
        -- Throwables
        `weapon_grenade`,
        `weapon_bzgas`,
        `weapon_molotov`,
        `weapon_stickybomb`,
        `weapon_proxmine`,
        `weapon_snowball`,
        `weapon_pipebomb`,
        `weapon_ball`,
        `weapon_smokegrenade`,
        `weapon_flare`,
    },
}