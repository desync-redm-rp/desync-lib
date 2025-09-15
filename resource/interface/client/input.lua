--[[
    Replicated from ox_lib for RedM as desync-lib

    Original: https://github.com/overextended/ox_lib
    Licensed under LGPL-3.0-or-later
]]

local input

---@class InputDialogRowProps
---@field type 'input' | 'number' | 'checkbox' | 'select' | 'slider' | 'multi-select' | 'date' | 'date-range' | 'time' | 'textarea' | 'color'
---@field label string
---@field options? { value: string, label: string, default?: string }[]
---@field password? boolean
---@field icon? string | {[1]: IconProp, [2]: string};
---@field iconColor? string
---@field placeholder? string
---@field default? string | number
---@field disabled? boolean
---@field checked? boolean
---@field min? number
---@field max? number
---@field step? number
---@field autosize? boolean
---@field required? boolean
---@field format? string
---@field returnString? boolean
---@field clearable? boolean
---@field searchable? boolean
---@field description? string
---@field maxSelectedValues? number

---@class InputDialogOptionsProps
---@field allowCancel? boolean

---@param heading string
---@param rows string[] | InputDialogRowProps[]
---@param options InputDialogOptionsProps[]?
---@return string[] | number[] | boolean[] | nil
function lib.inputDialog(heading, rows, options)
    if input then return end
    input = promise.new()

    -- Backwards compat with string tables
    for i = 1, #rows do
        if type(rows[i]) == 'string' then
            rows[i] = { type = 'input', label = rows[i] --[[@as string]] }
        end
    end

    -- Check if web UI is available before sending NUI message
    local webUIFile = LoadResourceFile(lib.name, 'web/build/index.html')
    print("📝 [DEBUG] Input dialog - Web UI file loaded:", webUIFile and "YES" or "NO", "Length:", webUIFile and #webUIFile or 0)

    if webUIFile and webUIFile ~= "" then
        print("📝 [DEBUG] Web UI available, sending NUI message with controlled focus")
        -- Set NUI focus with proper parameters to avoid mouse issues
        lib.setNuiFocus(true, true, true)  -- hasFocus=true, allowInput=true, disableCursor=true
        SendNUIMessage({
            action = 'openDialog',
            data = {
                heading = heading,
                rows = rows,
                options = options
            }
        })

        return Citizen.Await(input)
    else
        print("📝 [DEBUG] Web UI not available")
        lib.print.warn('Input dialog requires web UI - build with: cd web && npm run build')
        input:resolve(nil)
        input = nil
        return nil
    end
end

function lib.closeInputDialog()
    if not input then return end

    -- Only send NUI message if web UI is available
    local webUIFile = LoadResourceFile(lib.name, 'web/build/index.html')
    if webUIFile and webUIFile ~= "" then
        print("📝 [DEBUG] Closing input dialog, resetting focus")
        lib.resetNuiFocus()
        SendNUIMessage({
            action = 'closeInputDialog'
        })
    end

    input:resolve(nil)
    input = nil
end

RegisterNUICallback('inputData', function(data, cb)
    cb(1)
    print("📝 [DEBUG] Input dialog callback received, resetting focus")
    lib.resetNuiFocus()

    local promise = input
    input = nil

    promise:resolve(data)
end)

-- Export functions for other resources
exports('inputDialog', lib.inputDialog)
exports('closeInputDialog', lib.closeInputDialog)
