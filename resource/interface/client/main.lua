--[[
    Replicated from ox_lib for RedM as desync-lib

    Original: https://github.com/overextended/ox_lib
    Licensed under LGPL-3.0-or-later
]]

---@alias IconProp 'fas' | 'far' | 'fal' | 'fat' | 'fad' | 'fab' | 'fak' | 'fass'

local keepInput = IsNuiFocusKeepingInput()

function lib.setNuiFocus(hasFocus, allowInput, disableCursor)
    print("🎯 [DEBUG] lib.setNuiFocus called with hasFocus:", hasFocus, "allowInput:", allowInput, "disableCursor:", disableCursor)

    keepInput = IsNuiFocusKeepingInput()
    print("🎯 [DEBUG] Current keepInput:", keepInput)

    -- Only set NUI focus if web UI is available
    local webUIFile = LoadResourceFile(lib.name, 'web/build/index.html')
    print("🎯 [DEBUG] Web UI file loaded:", webUIFile and "YES" or "NO", "Length:", webUIFile and #webUIFile or 0)

    if webUIFile and webUIFile ~= "" then
        print("🎯 [DEBUG] Setting NUI focus:", hasFocus, not disableCursor)
        SetNuiFocus(hasFocus, not disableCursor)
        SetNuiFocusKeepInput(allowInput)
        print("🎯 [DEBUG] NUI focus set successfully")
    else
        print("🎯 [DEBUG] Web UI not available, skipping NUI focus")
        lib.print.warn('Cannot set NUI focus - web UI not available')
    end
end

function lib.resetNuiFocus()
    -- Always reset NUI focus safely
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(keepInput)
end

-- Export functions for other resources
exports('setNuiFocus', lib.setNuiFocus)
exports('resetNuiFocus', lib.resetNuiFocus)
