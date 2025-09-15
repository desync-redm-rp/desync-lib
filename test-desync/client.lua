-- Comprehensive test client for desync-lib
-- Automatic tests disabled to reduce console spam
-- Use manual test commands instead (/testmath, /testentities, etc.)

-- Test notification system
RegisterCommand('testnotify', function()
    lib.notify({
        title = 'Test Notification',
        description = 'This is a test notification',
        type = 'info',
        duration = 3000
    })
    Wait(1000)
    lib.notify({
        title = 'Success!',
        description = 'Operation completed successfully',
        type = 'success'
    })
    Wait(1000)
    lib.notify({
        title = 'Warning',
        description = 'Something might be wrong',
        type = 'warning'
    })
    Wait(1000)
    lib.notify({
        title = 'Error',
        description = 'Something went wrong',
        type = 'error'
    })
end)

-- Test progress bars
RegisterCommand('testprogress', function()
    lib.progressBar({
        label = 'Processing data...',
        duration = 5000,
        canCancel = true
    })
end)

-- Test progress circle
RegisterCommand('testcircle', function()
    lib.progressCircle({
        duration = 3000,
        position = 'middle'
    })
end)

-- Test world text
RegisterCommand('testworldtext', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local textId = lib.worldText.show({
        coords = playerCoords + vec3(2.0, 0.0, 1.0),
        text = "Hello World!",
        size = 'large',
        color = 'yellow',
        maxDistance = 25.0
    })

    -- Update the text after 3 seconds
    Citizen.SetTimeout(3000, function()
        lib.worldText.update(textId, {
            text = "Updated Text!",
            color = 'green'
        })
    end)

    -- Hide after 6 seconds
    Citizen.SetTimeout(6000, function()
        lib.worldText.hide(textId)
    end)
end)

-- Clear world text
RegisterCommand('clearworldtext', function()
    lib.worldText.clear()
end)

-- Test callback system
RegisterCommand('testcallback', function()
    lib.callback('desync-lib:testCallback', false, function(result)
    end, "Test message from command")
end)

-- Test math utilities
RegisterCommand('testmath', function()
end)

-- Test table utilities
RegisterCommand('testtable', function()
end)

-- Test string utilities
RegisterCommand('teststring', function()
end)

-- Test entity detection
RegisterCommand('testentities', function()
end)

-- Test points system
RegisterCommand('testpoints', function()
    local point = lib.points.new({
        coords = GetEntityCoords(PlayerPedId()) + vec3(2.0, 0.0, 0.0),
        distance = 3.0,
        onEnter = function(self)
        end,
        onExit = function(self)
        end
    })
end)

-- Test streaming requests
RegisterCommand('teststreaming', function()
    lib.requestAnimDict("script_re@bear_fighting@leader", function(success)
    end)

    lib.requestAudioBank("dlc_redm\\script\\audio\\sfx\\redm_audio_bank_1", function(success)
    end)
end)

-- Test wait utilities
RegisterCommand('testwait', function()
    Citizen.CreateThread(function()
        lib.waitFor(function()
            return IsPedOnFoot(PlayerPedId())
        end, "Waiting for player to be on foot", 5000)
    end)
end)

-- Clear all points
RegisterCommand('clearpoints', function()
    lib.points.clearAll()
end)

-- UI Test Commands for desync-lib
RegisterCommand('uitest', function()
    -- Create a point with world text and visual marker
    local playerCoords = GetEntityCoords(PlayerPedId())
    local testCoords = playerCoords + vec3(5.0, 0.0, 0.0)

    local point = lib.points.new({
        coords = testCoords,
        distance = 3.0,
        onEnter = function(self)
            lib.notify({
                title = 'Point Entered',
                description = 'You entered the test point!',
                type = 'success'
            })

            -- Show text when entering
            lib.worldText.show({
                coords = self.coords + vec3(0.0, 0.0, 2.0),
                text = "You're here!",
                size = 'large',
                color = 'red',
                maxDistance = 15.0
            })
        end,
        onExit = function(self)
            lib.notify({
                title = 'Point Left',
                description = 'You left the test point',
                type = 'warning'
            })

            -- Clear all world text
            lib.worldText.clear()
        end,
        nearby = function(self)
            -- Show distance when nearby
            if math.random() < 0.05 then -- Only show occasionally to avoid spam
                lib.notify({
                    title = 'Getting Close',
                    description = ('Distance: %.1f units'):format(self.currentDistance),
                    type = 'info',
                    duration = 1000
                })
            end
        end
    })

    -- Create visual marker for debugging
    Citizen.CreateThread(function()
        local markerActive = true
        local endTime = GetGameTimer() + 300000 -- 5 minutes

        while markerActive and GetGameTimer() < endTime do
            -- Draw vertical cylinder marker (working RedM example)
            Citizen.InvokeNative(
                0x2A32FAA57B937173, -- DrawMarker native
                0x94FDAE17, -- Vertical cylinder
                testCoords.x, testCoords.y, testCoords.z, -- position
                0.0, 0.0, 0.0, -- Direction
                0.0, 0.0, 0.0, -- Rotation
                3.0, 3.0, 5.0, -- Scale (diameter, diameter, height)
                255, 255, 0, 150, -- Yellow, semi-transparent
                false, -- Bob up and down
                false, -- Face camera
                2, -- P19 (texture dict)
                false, -- Rotate
                nil, nil, -- Texture dict/name
                false -- Draw on ents
            )

            -- Draw debug line from ground to above (working RedM example)
            Citizen.InvokeNative(
                0x6B7256074AE34680, -- DrawLine native
                testCoords.x, testCoords.y, testCoords.z,
                testCoords.x, testCoords.y, testCoords.z + 3.0, -- Line to 3 units above
                255, 255, 0, 255 -- Yellow line
            )

            -- Draw distance text with outline
            local playerPos = GetEntityCoords(PlayerPedId())
            local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, testCoords.x, testCoords.y, testCoords.z)

            if distance < 15.0 then
                DrawText3D(testCoords.x, testCoords.y, testCoords.z + 3.5,
                    ("Test Point\nDistance: %.1f"):format(distance))
            end

            Wait(0)
        end
    end)

    lib.notify({
        title = 'Point Created',
        description = 'Look for the yellow sphere marker and walk to it',
        type = 'info',
        duration = 6000
    })

    -- Auto-cleanup after 5 minutes
    Citizen.SetTimeout(300000, function()
        lib.points.clearAll()
        lib.worldText.clear()
    end)
end)

-- Helper function to draw 3D text (for debugging)
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFontForCurrentCommand(1)
        SetTextColor(255, 255, 255, 215)
        SetTextCentre(1)
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), _x, _y)
    end
end

RegisterCommand('uitest_progress', function()
    -- Create a progress bar that simulates a complex task
    lib.progressBar({
        label = 'Initializing...',
        duration = 8000,
        canCancel = true
    })

    Citizen.CreateThread(function()
        local stages = {
            "Loading assets...",
            "Connecting to server...",
            "Validating data...",
            "Finalizing setup...",
            "Complete!"
        }

        for i, stage in ipairs(stages) do
            Wait(1600) -- 8 seconds / 5 stages
            local progress = (i / #stages) * 100
            lib.updateProgress(progress, stage)
        end

        Wait(1000)
        lib.hideProgress()

        lib.notify({
            title = 'Task Complete',
            description = 'Advanced progress test finished!',
            type = 'success'
        })
    end)
end)

RegisterCommand('uitest_text', function()
    local playerCoords = GetEntityCoords(PlayerPedId())

    -- Create a countdown timer in world text
    local textId = lib.worldText.show({
        coords = playerCoords + vec3(0.0, 2.0, 1.5),
        text = "Starting countdown...",
        size = 'large',
        color = 'yellow',
        maxDistance = 20.0
    })

    Citizen.CreateThread(function()
        for i = 10, 0, -1 do
            Wait(1000)

            local color = 'yellow'
            if i <= 3 then
                color = 'red'
            elseif i <= 6 then
                color = 'orange'
            end

            lib.worldText.update(textId, {
                text = "Countdown: " .. i,
                color = color
            })
        end

        lib.worldText.update(textId, {
            text = "BOOM!",
            color = 'red',
            size = 'large'
        })

        Wait(2000)
        lib.worldText.hide(textId)

        lib.notify({
            title = 'Countdown Complete',
            description = 'Dynamic text test finished!',
            type = 'success'
        })
    end)
end)

RegisterCommand('uitest_clear', function()
    lib.hideProgress()
    lib.worldText.clear()
    lib.points.clearAll()

    lib.notify({
        title = 'UI Cleared',
        description = 'All UI elements have been cleared',
        type = 'info'
    })
end)

-- Test all available marker types using the new marker system
RegisterCommand('testmarkers', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local baseCoords = playerCoords + vec3(0.0, 8.0, 0.0)

    -- Get all available marker types from the marker system
    local markerTypes = lib.markers.getTypes()

    -- Create markers in a grid (5 per row)
    local markersPerRow = 5
    local spacing = 4.0

    for i, markerName in ipairs(markerTypes) do
        local row = math.floor((i-1) / markersPerRow)
        local col = (i-1) % markersPerRow

        local markerCoords = baseCoords + vec3(col * spacing, row * spacing * -1, 0.0)

        Citizen.CreateThread(function()
            local endTime = GetGameTimer() + 60000 -- 60 seconds

            while GetGameTimer() < endTime do
                -- Use the new marker system
                lib.markers.draw(markerName, markerCoords, {
                    scale = 1.5,
                    red = 255,
                    green = 0,
                    blue = 255,
                    alpha = 200
                })

                -- Label each marker
                DrawText3D(markerCoords.x, markerCoords.y, markerCoords.z + 2.0,
                    markerName)

                Wait(0)
            end
        end)
    end

    local totalMarkers = #markerTypes
    local rows = math.ceil(totalMarkers / markersPerRow)

    lib.notify({
        title = 'Marker Test',
        description = ('Testing %d marker types in a %dx%d grid'):format(totalMarkers, markersPerRow, rows),
        type = 'info',
        duration = 8000
    })
end)

-- Test zones system
RegisterCommand('testzones', function()
    local playerCoords = GetEntityCoords(PlayerPedId())

    -- Test sphere zone (far right)
    local sphereId = lib.zones.sphere({
        coords = playerCoords + vec3(25.0, 0.0, 0.0),
        radius = 5.0,
        debug = true,
        onEnter = function()
            lib.notify({
                title = 'Entered Sphere',
                description = 'You entered the spherical zone!',
                type = 'success'
            })
        end,
        onExit = function()
            lib.notify({
                title = 'Left Sphere',
                description = 'You left the spherical zone',
                type = 'warning'
            })
        end,
        inside = function()
            -- Only show occasionally to avoid spam
            if math.random() < 0.02 then
                DrawText3D(playerCoords.x + 25.0, playerCoords.y, playerCoords.z + 3.0,
                    "Inside Sphere Zone!")
            end
        end
    })

    -- Test box zone (far forward)
    local boxId = lib.zones.box({
        coords = playerCoords + vec3(0.0, 25.0, 0.0),
        size = vec3(6.0, 6.0, 4.0),
        debug = true,
        onEnter = function()
            lib.notify({
                title = 'Entered Box',
                description = 'You entered the box zone!',
                type = 'info'
            })
        end,
        onExit = function()
            lib.notify({
                title = 'Left Box',
                description = 'You left the box zone',
                type = 'warning'
            })
        end
    })

    -- Test poly zone (far left, larger triangle)
    local polyId = lib.zones.poly({
        points = {
            playerCoords + vec3(-20.0, -10.0, 0.0),
            playerCoords + vec3(-10.0, -10.0, 0.0),
            playerCoords + vec3(-15.0, 5.0, 0.0),
            playerCoords + vec3(-15.0, 20.0, 1.0),
            playerCoords + vec3(-14.0, 25.0, 0.5),
            playerCoords + vec3(5.0, 15.0, 0.0),
            playerCoords + vec3(10.0, 4.9, 2.0),
        },
        minZ = playerCoords.z - 2.0,
        maxZ = playerCoords.z + 2.0,
        debug = true,
        onEnter = function()
            lib.notify({
                title = 'Entered Polygon',
                description = 'You entered the poly zone!',
                type = 'success'
            })
        end,
        onExit = function()
            lib.notify({
                title = 'Left Polygon',
                description = 'You left the poly zone',
                type = 'warning'
            })
        end,
        inside = function()
            print("Inside poly zone")
        end
    })

    lib.notify({
        title = 'Zones Created',
        description = 'Sphere (magenta), Box (yellow), Triangle (cyan) - all with debug visualization',
        type = 'info',
        duration = 8000
    })

    -- Auto-cleanup after 5 minutes
    Citizen.SetTimeout(300000, function()
        lib.zones.clearAll()
    end)
end)

-- Clear zones
RegisterCommand('clearzones', function()
    lib.zones.clearAll()

    lib.notify({
        title = 'Zones Cleared',
        description = 'All zones have been removed',
        type = 'info'
    })
end)
