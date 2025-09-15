-- 3D World Text system for desync-lib
-- Displays text in the game world that follows coordinates

---@class worldtext
lib.worldText = {}

local activeTexts = {}
local nextTextId = 1

---Shows 3D text in the world at specified coordinates
---@param data worldTextData
---@return number textId
function lib.worldText.show(data)
    if type(data) ~= 'table' then
        error('worldText data must be a table')
    end

    if not data.coords or not data.text then
        error('worldText requires coords and text')
    end

    local textId = nextTextId
    nextTextId = nextTextId + 1

    -- Set defaults
    data.size = data.size or 'medium'
    data.color = data.color or 'white'
    data.duration = data.duration or nil -- nil means persistent until hidden

    activeTexts[textId] = data

    lib.print.verbose(("world text shown: %s"):format(data.text))

    -- Start the rendering thread if this is the first text
    local textCount = 0
    for _ in pairs(activeTexts) do textCount = textCount + 1 end
    if textCount == 1 then
        Citizen.CreateThread(lib.worldText.renderThread)
    end

    return textId
end

---Updates an existing world text
---@param textId number
---@param data worldTextData
function lib.worldText.update(textId, data)
    if not activeTexts[textId] then
        lib.print.warn(("world text with id %d not found"):format(textId))
        return
    end

    -- Update the data
    for k, v in pairs(data) do
        activeTexts[textId][k] = v
    end

    lib.print.verbose(("world text updated: %d"):format(textId))
end

---Hides a specific world text
---@param textId number
function lib.worldText.hide(textId)
    if activeTexts[textId] then
        activeTexts[textId] = nil
        lib.print.verbose(("world text hidden: %d"):format(textId))

        -- Send hide message to NUI
        SendNUIMessage({
            action = 'hideWorldText',
            id = textId
        })
    end
end

---Clears all world text
function lib.worldText.clear()
    activeTexts = {}
    SendNUIMessage({
        action = 'clearWorldTexts'
    })
    lib.print.verbose("all world text cleared")
end

---Rendering thread that converts world coords to screen coords
function lib.worldText.renderThread()
    while next(activeTexts) ~= nil do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for textId, data in pairs(activeTexts) do
            -- Calculate distance
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z,
                                 data.coords.x, data.coords.y, data.coords.z)

            -- Only show if within range
            if distance <= (data.maxDistance or 50.0) then
                -- Convert world coordinates to screen coordinates
                local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(
                    data.coords.x, data.coords.y, data.coords.z
                )

                if onScreen then
                    -- Convert to percentage for CSS
                    screenX = screenX * 100
                    screenY = screenY * 100

                    -- Send to NUI
                    SendNUIMessage({
                        action = 'showWorldText',
                        id = textId,
                        text = data.text,
                        screenX = screenX,
                        screenY = screenY,
                        size = data.size,
                        color = data.color
                    })
                else
                    -- Hide if not on screen
                    SendNUIMessage({
                        action = 'hideWorldText',
                        id = textId
                    })
                end
            else
                -- Hide if too far
                SendNUIMessage({
                    action = 'hideWorldText',
                    id = textId
                })
            end
        end

        Wait(0) -- Update every frame
    end
end

-- Export functions
exports('showWorldText', lib.worldText.show)
exports('updateWorldText', lib.worldText.update)
exports('hideWorldText', lib.worldText.hide)
exports('clearWorldText', lib.worldText.clear)
