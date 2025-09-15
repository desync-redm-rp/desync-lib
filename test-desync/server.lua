-- Comprehensive test server for desync-lib
Citizen.CreateThread(function()
    Wait(1000)
    if not lib then
        print("^1[ERROR] lib is nil on server! desync-lib not loaded properly^0")
        return
    end

    print("=== desync-lib Server Test ===")
    print("✅ Server library loaded successfully!")

    -- Test callback registration
    lib.callback.register('desync-lib:testCallback', function(source, message)
        print("📨 Server received callback from client " .. tostring(source) .. ":", tostring(message))
        return "Response from server to client " .. tostring(source) .. "!"
    end)

    print("✅ Server callback registered!")
end)

-- Test commands for server-side testing
print("🎯 [DEBUG] Registering server test commands")

-- Test server callback
RegisterCommand('testservercallback', function(source, args, raw)
    print("🔄 Testing server callback...")
    -- This would be called from client, but we can test the registration
    print("Server callback 'desync-lib:testCallback' should be registered")
end)

-- Test server utilities
RegisterCommand('testserverutils', function(source, args, raw)
    print("🖥️ Testing server utilities...")

    -- Test print functions
    lib.print.info("This is an info message")
    lib.print.warn("This is a warning message")
    lib.print.error("This is an error message")
    lib.print.verbose("This is a verbose message")

    -- Test locale
    print("📍 Server locale:", lib.getLocale() or "unknown")

    -- Test settings
    print("⚙️ Server settings:", lib.settings and "Settings loaded" or "Settings not loaded")
end)

print("🎯 [DEBUG] Server test commands registered successfully!")
