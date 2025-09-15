--[[
    Replicated from ox_lib for RedM as desync-lib

    Original: https://github.com/overextended/ox_lib
    Licensed under LGPL-3.0-or-later
]]

---@param requestFunc function The function to request the asset
---@param hasLoadedFunc function The function to check if the asset has loaded
---@param assetType string The type of asset being requested (for error messages)
---@param assetName string The name of the asset being requested
---@param timeout? number Timeout in milliseconds (default 10000)
---@return any
function lib.streamingRequest(requestFunc, hasLoadedFunc, assetType, assetName, timeout)
    timeout = timeout or 10000

    requestFunc(assetName)

    local startTime = GetGameTimer()

    while not hasLoadedFunc(assetName) do
        Wait(0)

        if GetGameTimer() - startTime > timeout then
            error(("failed to load %s '%s' - timed out after %dms"):format(assetType, assetName, timeout))
        end
    end

    return assetName
end

return lib.streamingRequest
