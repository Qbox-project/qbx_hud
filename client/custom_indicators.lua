local indicators = {}
local owners = {}

local function validString(value, limit)
    return type(value) == 'string' and value:find('%S') ~= nil and #value <= limit
end

local function validValue(value)
    return type(value) == 'number' and value == value and value > -math.huge and value < math.huge
end

local function invokingResource()
    return GetInvokingResource() or GetCurrentResourceName()
end

local function ownsIndicator(id)
    return validString(id, 64) and indicators[id] ~= nil and owners[id] == invokingResource()
end

---Add or replace an indicator owned by the calling resource.
---@param data table
---@return boolean success
local function addCustomIndicator(data)
    if type(data) ~= 'table' or not validString(data.id, 64) then return false end
    if indicators[data.id] and not ownsIndicator(data.id) then return false end
    if data.value ~= nil and not validValue(data.value) then return false end
    if data.icon ~= nil and not validString(data.icon, 128) then return false end
    if data.color ~= nil and not validString(data.color, 128) then return false end
    if data.label ~= nil and not validString(data.label, 128) then return false end
    if data.alwaysShow ~= nil and type(data.alwaysShow) ~= 'boolean' then return false end

    local indicator = {
        id = data.id,
        icon = data.icon or 'fas fa-circle',
        color = data.color or '#ffffff',
        value = math.max(0, math.min(100, data.value or 0)),
        label = data.label or data.id,
        alwaysShow = data.alwaysShow or false,
    }
    indicators[data.id] = indicator
    owners[data.id] = invokingResource()
    SendNUIMessage({action = 'addCustomIndicator', indicator = indicator})
    return true
end

---@param id string
---@param value number
---@param color? string
---@return boolean success
local function updateCustomIndicator(id, value, color)
    if not ownsIndicator(id) or not validValue(value) then return false end
    if color ~= nil and not validString(color, 128) then return false end
    local indicator = indicators[id]
    indicator.value = math.max(0, math.min(100, value))
    indicator.color = color or indicator.color
    SendNUIMessage({action = 'updateCustomIndicator', id = id, value = indicator.value, color = indicator.color})
    return true
end

local function removeIndicator(id)
    indicators[id] = nil
    owners[id] = nil
    SendNUIMessage({action = 'removeCustomIndicator', id = id})
end

---@param id string
---@return boolean success
local function removeCustomIndicator(id)
    if not ownsIndicator(id) then return false end
    removeIndicator(id)
    return true
end

---@return table<string, table> indicators A snapshot, keyed by indicator ID.
local function getCustomIndicators()
    local snapshot = {}
    for id, indicator in pairs(indicators) do
        snapshot[id] = {}
        for key, value in pairs(indicator) do
            snapshot[id][key] = value
        end
    end
    return snapshot
end

exports('AddCustomIndicator', addCustomIndicator)
exports('UpdateCustomIndicator', updateCustomIndicator)
exports('RemoveCustomIndicator', removeCustomIndicator)
exports('GetCustomIndicators', getCustomIndicators)

RegisterNUICallback('customIndicatorsReady', function(_, cb)
    SendNUIMessage({action = 'setCustomIndicators', indicators = getCustomIndicators()})
    cb('ok')
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    for id, owner in pairs(owners) do
        if owner == resourceName then removeIndicator(id) end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    for id in pairs(indicators) do
        removeIndicator(id)
    end
end)
