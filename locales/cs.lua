local Translations = {
    notify = {
        hud_settings_loaded = "Nastavení HUD načteno!",
        hud_restart = "HUD se restartuje!",
        hud_start = "HUD je nyní spuštěn!",
        hud_command_info = "Tento příkaz resetuje vaše aktuální nastavení HUD!",
        load_square_map ="Načítá se mapa čtverce...",
        loaded_square_map = "Čtvercová mapa se načetla!",
        load_circle_map = "Načítá se mapa kruhů...",
        loaded_circle_map = "Kruhová mapa se načetla!",
        cinematic_on = "Cinematic Mode On!",
        cinematic_off = "Cinematic Mode Off!",
        engine_on = "Engine Started!",
        engine_off = "Engine Shut Down!",
        low_fuel = "Nízká hladina paliva!",
        access_denied = "Nejste oprávněn!",
        stress_gain = "Cítíte se více ve stresu!",
        stress_removed = "Cítím se uvolněněji!",
    },
    info = {
        open_menu = "Otevřít nabídku",
    },
    commands = {
        cash = 'cash',
        bank = 'bank',
        dev = 'dev',
        help = {
            cash = 'Check Cash Balance',
            bank = 'Check Bank Balance',
            dev = 'Zapnout/vypnout režim pro vývojáře'
        }
    }
}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
--translate by stepan_valic
