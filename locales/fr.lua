local Translations = {
    notify = {
        low_fuel = 'Niveau de carburant faible!',
        stress_gain = 'Vous stressez!',
        stress_removed = 'Vous vous détendez!',
        cinematic_on = 'Mode cinématique activé!',
        cinematic_off = 'Mode cinématique désactivé!',
        hud_on = 'HUD activé!',
        hud_off = 'HUD désactivé!',
    },
    commands = {
        bank = {
            help = 'Afficher le solde bancaire'
        },
        cash = {
            help = 'Afficher le solde en espèces'
        }
    }
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end