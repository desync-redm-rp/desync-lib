-- Progress bar system for desync-lib
-- Replicated from ox_lib for RedM as desync-lib

---@class progress
lib.progressBar = {}
lib.progressCircle = {}

local activeProgress = nil
local progressCallbacks = {}

---Shows a linear progress bar
---@param data progressData
---@return boolean success
function lib.progressBar(data)
    if type(data) ~= 'table' then
        error('progressBar data must be a table')
    end

    -- Hide any existing progress
    lib.hideProgress()

    data.action = 'showProgressBar'

    -- Set defaults
    data.label = data.label or 'Loading...'
    data.duration = data.duration or 5000
    data.canCancel = data.canCancel or false

    -- Send to NUI
    SendNUIMessage(data)

    activeProgress = {
        type = 'bar',
        data = data,
        startTime = GetGameTimer(),
        endTime = GetGameTimer() + data.duration
    }

    lib.print.verbose(("progress bar shown: %s"):format(data.label))

    -- Handle automatic completion
    if not data.canCancel then
        Citizen.CreateThread(function()
            local startTime = activeProgress.startTime
            local endTime = activeProgress.endTime

            while activeProgress and activeProgress.type == 'bar' do
                local currentTime = GetGameTimer()
                local progress = math.min(100, ((currentTime - startTime) / (endTime - startTime)) * 100)

                SendNUIMessage({
                    action = 'updateProgress',
                    progress = progress
                })

                if progress >= 100 then
                    lib.hideProgress()
                    break
                end

                Wait(50)
            end
        end)
    end

    return true
end

---Shows a circular progress indicator
---@param data progressData
---@return boolean success
function lib.progressCircle(data)
    if type(data) ~= 'table' then
        error('progressCircle data must be a table')
    end

    -- Hide any existing progress
    lib.hideProgress()

    data.action = 'showProgressCircle'

    -- Set defaults
    data.duration = data.duration or 3000
    data.position = data.position or 'middle'
    data.canCancel = data.canCancel or false

    -- Send to NUI
    SendNUIMessage(data)

    activeProgress = {
        type = 'circle',
        data = data,
        startTime = GetGameTimer(),
        endTime = GetGameTimer() + data.duration
    }

    lib.print.verbose(("progress circle shown: %s"):format(data.label or 'Loading...'))

    -- Handle automatic completion
    if not data.canCancel then
        Citizen.CreateThread(function()
            local startTime = activeProgress.startTime
            local endTime = activeProgress.endTime

            while activeProgress and activeProgress.type == 'circle' do
                local currentTime = GetGameTimer()
                local progress = math.min(100, ((currentTime - startTime) / (endTime - startTime)) * 100)

                SendNUIMessage({
                    action = 'updateProgress',
                    progress = progress
                })

                if progress >= 100 then
                    lib.hideProgress()
                    break
                end

                Wait(50)
            end
        end)
    end

    return true
end

---Hides the active progress indicator
function lib.hideProgress()
    if activeProgress then
        SendNUIMessage({
            action = 'hideProgress'
        })

        activeProgress = nil
        lib.print.verbose("progress hidden")
    end
end

---Updates the progress of the active progress indicator
---@param progress number 0-100
---@param label? string
function lib.updateProgress(progress, label)
    if not activeProgress then return end

    progress = math.max(0, math.min(100, progress))

    SendNUIMessage({
        action = 'updateProgress',
        progress = progress,
        label = label
    })

    lib.print.verbose(("progress updated: %d%%"):format(progress))
end

-- Handle progress cancellation from NUI
RegisterNUICallback('progressCancelled', function(data, cb)
    if activeProgress and activeProgress.data.canCancel then
        lib.hideProgress()

        -- Call cancellation callback if provided
        if activeProgress.data.onCancel then
            activeProgress.data.onCancel()
        end
    end

    cb({})
end)

-- Export functions
exports('progressBar', lib.progressBar)
exports('progressCircle', lib.progressCircle)
exports('hideProgress', lib.hideProgress)
exports('updateProgress', lib.updateProgress)
