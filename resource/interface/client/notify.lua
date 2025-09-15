-- Notification system for desync-lib
-- Replicated from ox_lib for RedM as desync-lib

---@class notify
lib.notify = {}

local positions = {
    ['top-left'] = 'top-left',
    ['top-right'] = 'top-right',
    ['bottom-left'] = 'bottom-left',
    ['bottom-right'] = 'bottom-right',
    ['top'] = 'top',
    ['bottom'] = 'bottom',
    ['center'] = 'center'
}

---Shows a notification to the player
---@param data notifyData
function lib.notify(data)
    if type(data) ~= 'table' then
        error('notify data must be a table')
    end

    data.action = 'showNotification'

    -- Validate position
    if data.position and not positions[data.position] then
        lib.print.warn(("invalid notification position '%s'"):format(data.position))
        data.position = 'top-right'
    end

    -- Set defaults
    data.type = data.type or 'info'
    data.title = data.title or 'Notification'
    data.description = data.description or ''
    data.duration = data.duration or 5000
    data.position = data.position or 'top-right'

    -- Send to NUI
    SendNUIMessage(data)

    lib.print.verbose(("notification shown: %s"):format(data.title))
end

-- Export the notify function
exports('notify', lib.notify)
