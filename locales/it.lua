local Translations = {
    notify = {
        low_fuel = 'Livello del carburante basso!',
        stress_gain = 'Ti senti più stressato!',
        stress_removed = 'Ti senti più rilassato!',
        cinematic_on = 'Modalità cinematografica abilitata!',
        cinematic_off = 'Modalità cinematografica disabilitata!',
        hud_on = 'HUD abilitato!',
        hud_off = 'HUD disabilitato!',
    },
    commands = {
        bank = {
            help = 'Mostra il saldo bancario'
        },
        cash = {
            help = 'Mostra il saldo in contanti'
        }
    }
}

if GetConvar('qb_locale', 'en') == 'it' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
