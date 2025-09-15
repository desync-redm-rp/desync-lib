--[[
    desync-lib server initialization
    Replicated from ox_lib for RedM
]]

-- Server-side initialization
lib.print.info('desync-lib server loaded')

-- Test callback for testing purposes (only if test mode is enabled)
local testMode = GetConvar('desync:testMode', 'false')
print('[desync-lib] Server test mode convar value: ' .. tostring(testMode))

-- Replicate the convar to all clients
SetConvarReplicated('desync:testMode', testMode)

if testMode == 'true' or testMode == '1' then
    lib.callback.register('desync-lib:testCallback', function(message)
        print("Server received: " .. tostring(message))
        return "Response from server!"
    end)

    lib.print.info('Test mode enabled - server callbacks registered')
end
