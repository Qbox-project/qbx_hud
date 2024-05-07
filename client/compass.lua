local SendNUIMessage = SendNUIMessage
local currentHeading
local currentStreet
local currentStreet2
local showingMinimap = false
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
    Wait(250)
    while true do
        local sleep = 1000
        if not IsMinimapRendering() then
            if showingMinimap then
                showingMinimap = false
                SendNUIMessage({
                    update = true,
                    data = {
                        {
                            type = 'compass',
                            show = false,
                        }
                    }
                })
            end
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
                            show = true,
                            heading = currentHeading ~= convertedHeading and convertedHeading or nil,
                            street = currentStreet ~= street and street or nil,
                            street2 = currentStreet2 ~= street2 and street2 or nil,
                        }
                    }
                })
                currentHeading, currentStreet, currentStreet2 = convertedHeading, street, street2
                showingMinimap = true
            end
            sleep = 500
            --collectgarbage() -- please help i don't understand why this is necessary
        end
        Wait(sleep)
    end
end)