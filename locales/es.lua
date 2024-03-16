local Translations = {
    notify = {
        low_fuel = 'Nivel de combustible bajo!',
        stress_gain = '¡Te estresas!',
        stress_removed = '¡Te relajas!',
        cinematic_on = '¡Modo cinematográfico activado!',
        cinematic_off = '¡Modo cinematográfico desactivado!',
        hud_on = '¡HUD activado!',
        hud_off = '¡HUD desactivado!',
    },
    commands = {
        bank = {
            help = 'Mostrar saldo bancario'
        },
        cash = {
            help = 'Mostrar saldo en efectivo'
        }
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
