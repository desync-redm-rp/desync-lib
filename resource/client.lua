--[[
    desync-lib client initialization
    Replicated from ox_lib for RedM
]]

-- Client-side initialization
lib.print.info('desync-lib client loaded')

-- Ensure NUI frame is visible (RedM specific)
SetNuiFocus(false, false)
SendNUIMessage({ action = 'init', message = 'Hello from desync-lib!' })

-- NUI Callbacks for testing
RegisterNUICallback('testResponse', function(data, cb)
    cb(1)
    print('🎯 [NUI Test] Received response from UI:', json.encode(data))
end)

RegisterNUICallback('testFromUI', function(data, cb)
    cb(1)
    print('🎯 [NUI Test] Received message from UI:', json.encode(data))
end)

-- Test functionality (only runs if test mode is enabled)
local testMode = GetConvar('desync:testMode', 'false')
print('[desync-lib] Test mode convar value: ' .. tostring(testMode))

if testMode == 'true' or testMode == '1' then
    Citizen.CreateThread(function()
        Wait(1000)

        print("=== desync-lib Test Mode ===")

        if not lib then
            print("^1ERROR: lib is nil^7")
            return
        end

        lib.print.info("✅ Library loaded successfully!")
        print("📍 Current locale: " .. lib.getLocale())
        print("⚙️ Settings: " .. locale('settings'))

        -- Test math utilities
        print("🔢 Math test: " .. math.round(3.14159, 2) .. " (should be 3.14)")
        print("📐 Vector test: " .. tostring(math.tovector({1.5, 2.3, 3.7})))

        -- Test table utilities
        local testTable = {1, 2, 3, 4, 5}
        table.shuffle(testTable)
        print("🔀 Shuffled table: " .. table.concat(testTable, ", "))

        -- Test string utilities
        print("🎲 Random string: " .. string.random("AAA111", 8))

        -- Test points system
        local testPoint = lib.points.new({
            coords = GetEntityCoords(PlayerPedId()) + vec3(2.0, 0.0, 0.0),
            distance = 5.0,
            onEnter = function(self)
                print("📍 Entered test point!")
            end,
            onExit = function(self)
                print("📍 Exited test point!")
            end,
            nearby = function(self)
                print("📍 Near test point (distance: " .. tostring(self.currentDistance) .. ")")
            end
        })

        print("📍 Created test point at: " .. tostring(testPoint.coords))

        -- Test entity detection
        local playerCoords = GetEntityCoords(PlayerPedId())
        local closestPed, pedCoords = lib.getClosestPed(playerCoords, 10.0)
        if closestPed then
            print("🚶 Closest ped: " .. closestPed .. " at distance: " .. tostring(#(playerCoords - pedCoords)))
        else
            print("🚶 No peds found within 10 units")
        end

        local closestVehicle, vehicleCoords = lib.getClosestVehicle(playerCoords, 15.0)
        if closestVehicle then
            print("🚗 Closest vehicle: " .. closestVehicle .. " at distance: " .. tostring(#(playerCoords - vehicleCoords)))
        else
            print("🚗 No vehicles found within 15 units")
        end

        -- Test nearby entities
        local nearbyPeds = lib.getNearbyPeds(playerCoords, 20.0)
        print("👥 Nearby peds: " .. #nearbyPeds .. " within 20 units")

        local nearbyVehicles = lib.getNearbyVehicles(playerCoords, 25.0)
        print("🚙 Nearby vehicles: " .. #nearbyVehicles .. " within 25 units")

        -- Test notification (will work once web UI is built)
        lib.notify({
            title = 'Test Notification',
            description = 'desync-lib is working!',
            type = 'success',
            duration = 5000
        })

        -- Use namespaced callback to avoid conflicts
        lib.callback('desync-lib:testCallback', false, function(result)
            print("📨 Callback result: " .. tostring(result))

            -- Test progress bar after callback succeeds
            Wait(2000)
            print("⏳ Testing progress bar...")
            local success = lib.progressBar({
                label = 'Testing Progress',
                duration = 3000,
                canCancel = true
            })

            if success then
                print("✅ Progress bar completed successfully!")
            else
                print("❌ Progress bar was cancelled")
            end

            -- Test input dialog after progress bar
            Wait(2000)
            local input = lib.inputDialog('Test Input', {
                { type = 'input', label = 'Enter your name', placeholder = 'John Doe' },
                { type = 'number', label = 'Enter your age', default = 25 }
            })

            if input then
                print("📝 Input received: " .. tostring(input[1]) .. ", Age: " .. tostring(input[2]))
            end
        end, "Hello from test script!")
    end)

    -- Test commands
    RegisterCommand('testnotify', function()
        lib.notify({
            title = 'Command Test',
            description = 'Notification from command!',
            type = 'info',
            position = 'top-left'
        })
    end)

    RegisterCommand('testprogress', function()
        lib.progressBar({
            label = 'Command Progress',
            duration = 5000
        })
    end)

    RegisterCommand('testinput', function()
        lib.inputDialog('Command Input', {
            { type = 'input', label = 'Your message', required = true },
            { type = 'select', label = 'Choose option', options = {
                { value = 'option1', label = 'Option 1' },
                { value = 'option2', label = 'Option 2' }
            }}
        })
    end)

    RegisterCommand('testcircle', function()
        lib.progressCircle({
            label = 'Circle Progress',
            duration = 4000,
            position = 'middle'
        })
    end)

    RegisterCommand('testmath', function()
        print("🔢 Math.round(3.14159, 2): " .. math.round(3.14159, 2))
        print("📐 Vector: " .. tostring(math.tovector({1, 2, 3})))
        print("🎯 Clamp: " .. math.clamp(15, 0, 10))
    end)

    RegisterCommand('testtable', function()
        local t = {1, 2, 3, 4, 5}
        table.shuffle(t)
        print("🔀 Shuffled: " .. table.concat(t, ", "))
        print("✅ Contains 3: " .. tostring(table.contains(t, 3)))
    end)

    RegisterCommand('teststring', function()
        print("🎲 Random: " .. string.random("AAA111", 8))
    end)

    RegisterCommand('testentities', function()
        local coords = GetEntityCoords(PlayerPedId())
        local ped, pedCoords = lib.getClosestPed(coords, 10.0)
        local vehicle, vehCoords = lib.getClosestVehicle(coords, 15.0)

        if ped then
            print("🚶 Closest ped: " .. ped .. " at " .. tostring(#(coords - pedCoords)) .. " units")
        end
        if vehicle then
            print("🚗 Closest vehicle: " .. vehicle .. " at " .. tostring(#(coords - vehCoords)) .. " units")
        end
    end)

    lib.print.info('Test mode enabled - use /testnotify, /testprogress, /testinput, /testcircle, /testmath, /testtable, /teststring, /testentities')
end
