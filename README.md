# desync-lib - RedM Library

A comprehensive library for RedM (Red Dead Redemption 2 multiplayer) that replicates ox_lib functionality with RedM-specific optimizations.

## 🚀 Features

### Core Systems
- ✅ **Dynamic Module Loading** - Automatic import system
- ✅ **Callback System** - Client-server communication
- ✅ **Localization** - Multi-language support
- ✅ **Settings Management** - User preferences
- ✅ **Logging System** - Configurable print levels

### Utility Libraries
- ✅ **Math Utilities** - Vector operations, interpolation, rounding
- ✅ **Table Utilities** - Search, manipulation, safety features
- ✅ **String Utilities** - Random generation, patterns

### Game Integration
- ✅ **Entity Detection** - Closest ped/vehicle finding
- ✅ **Nearby Entities** - Multi-entity detection
- ✅ **Points System** - 3D interactive points with events
- ✅ **Zone System** - Spherical, box, and polygonal zones with events
- ✅ **Marker System** - Easy marker drawing with string names

### UI Components
- ✅ **Notifications** - Toast notifications with animations
- ✅ **Input Dialogs** - Interactive forms
- ✅ **Progress Bars** - Linear and circular indicators
- ✅ **3D World Text** - Text display in game world coordinates

## 📦 Installation

1. **Download** the desync-lib resource
2. **Place** in your `resources/` directory
3. **Add** to your `server.cfg`:
   ```cfg
   ensure desync-lib
   ```
4. **In your resource's `fxmanifest.lua`**:
   ```lua
   shared_script '@desync-lib/init.lua'
   ```

## 🛠️ Core System APIs

### Logging & Localization

```lua
-- Logging functions
lib.print.info("Info message")
lib.print.warn("Warning message")
lib.print.error("Error message")
lib.print.verbose("Verbose message")

-- Localization
local currentLocale = lib.getLocale() -- Returns "en", "fr", etc.
local translatedText = locale("settings") -- Translate a string key
```

### Settings

```lua
-- Access global settings
local defaultLocale = lib.settings.default_locale
local notificationPos = lib.settings.notification_position
local audioEnabled = lib.settings.notification_audio
```

## 🎨 UI APIs

### Notifications

Display toast notifications with animations and different types.

```lua
lib.notify({
    title = "Mission Complete",
    description = "You successfully completed the mission!",
    type = "success",        -- "success", "error", "warning", "info"
    duration = 5000,         -- Display duration in milliseconds
    position = "top-right"   -- "top-left", "top-right", "bottom-left", "bottom-right"
})
```

**Notification Types:**
- `"success"` - Green checkmark notification
- `"error"` - Red X notification
- `"warning"` - Yellow exclamation notification
- `"info"` - Blue info notification

### Progress Bars

Display loading/progress indicators.

```lua
-- Linear progress bar
lib.progressBar({
    label = "Loading resources...",
    duration = 5000,     -- Total duration in milliseconds
    canCancel = true     -- Allow player to cancel with click
})

-- Circular progress indicator
lib.progressCircle({
    duration = 3000,
    position = "middle"   -- Screen position
})

-- Manual progress updates
lib.progressBar({
    label = "Downloading...",
    duration = 10000,
    canCancel = true
})

-- Update progress (0-100)
lib.updateProgress(75, "75% complete")

-- Hide progress
lib.hideProgress()
```

### 3D World Text

Display floating text in the game world.

```lua
-- Create 3D text
local textId = lib.worldText.show({
    coords = vec3(100.0, 200.0, 300.0),  -- World coordinates
    text = "Welcome to the shop!",        -- Text to display
    size = "large",                       -- "small", "medium", "large"
    color = "yellow",                     -- "white", "red", "green", "blue", "yellow"
    maxDistance = 50.0                    -- Max render distance
})

-- Update existing text
lib.worldText.update(textId, {
    text = "Shop is closed!",
    color = "red"
})

-- Hide specific text
lib.worldText.hide(textId)

-- Clear all world text
lib.worldText.clear()
```

### Markers

Draw visual markers using string names instead of hex hashes.

```lua
-- Draw a marker
lib.markers.draw("cylinder", vec3(100.0, 200.0, 300.0), {
    scale = 2.0,      -- Size multiplier
    red = 255,         -- Color components (0-255)
    green = 0,
    blue = 0,
    alpha = 150,       -- Transparency (0-255)
    bobUpAndDown = false,  -- Animation options
    faceCamera = false,
    p19 = 2
})

-- Available marker types
local types = lib.markers.getTypes()
-- Returns: {"cylinder", "ring", "sphere", "cube", "num_0", "num_1", ...}

-- Get hash for a marker type
local hash = lib.markers.getHash("cylinder") -- Returns hex hash
```

**Available Marker Types:**
- Basic: `"cylinder"`, `"ring"`, `"sphere"`, `"cube"`
- Numbers: `"num_0"` through `"num_9"`
- Special: `"halo"`, `"halo_point"`, `"halo_rotate"`
- Race: `"checkpoint"`, `"finish"`
- Objects: `"canoe_pole"`, `"buoy"`

## 🏘️ Zone APIs

Create interactive areas that trigger events when players enter/exit.

### Spherical Zones

```lua
local zoneId = lib.zones.sphere({
    coords = vec3(100.0, 200.0, 300.0),  -- Center point
    radius = 10.0,                        -- Zone radius
    debug = true,                         -- Show visual boundary
    onEnter = function()
        lib.notify({
            title = "Entered Zone",
            description = "You entered the spherical zone!",
            type = "success"
        })
    end,
    onExit = function()
        lib.notify({
            title = "Left Zone",
            description = "You left the spherical zone",
            type = "warning"
        })
    end,
    inside = function()
        -- Called every frame while inside
        DrawText3D(coords.x, coords.y, coords.z + 2.0, "Inside zone!")
    end
})
```

### Box Zones

```lua
local zoneId = lib.zones.box({
    coords = vec3(100.0, 200.0, 300.0),  -- Center point
    size = vec3(5.0, 5.0, 3.0),          -- Width, Length, Height
    debug = true,
    onEnter = function()
        print("Entered box zone")
    end,
    onExit = function()
        print("Left box zone")
    end
})
```

### Polygonal Zones

```lua
local zoneId = lib.zones.poly({
    points = {                            -- Array of vec3 points
        vec3(0.0, 0.0, 0.0),
        vec3(10.0, 0.0, 0.0),
        vec3(10.0, 10.0, 0.0),
        vec3(0.0, 10.0, 0.0)
    },
    minZ = 0.0,                         -- Minimum height
    maxZ = 5.0,                         -- Maximum height
    debug = true,
    onEnter = function()
        print("Entered polygon zone")
    end,
    onExit = function()
        print("Left polygon zone")
    end
})
```

### Zone Management

```lua
-- Remove specific zone
lib.zones.remove(zoneId)

-- Clear all zones
lib.zones.clearAll()

-- Get all active zones
local allZones = lib.zones.getAll()
```

## 📍 Points APIs

Create proximity-based interactive points.

```lua
local point = lib.points.new({
    coords = vec3(100.0, 200.0, 300.0),
    distance = 5.0,                      -- Trigger distance
    onEnter = function(self)
        print("Entered point area")
        print("Distance:", self.currentDistance)
    end,
    onExit = function(self)
        print("Left point area")
    end,
    nearby = function(self)
        -- Called while near (but not inside)
        if math.random() < 0.05 then
            print("Near point:", self.currentDistance)
        end
    end
})

-- Point management
lib.points.clearAll()
local allPoints = lib.points.getAllPoints()
local nearbyPoints = lib.points.getNearbyPoints()
local closestPoint = lib.points.getClosestPoint()
```

## 👥 Entity Detection APIs

Find and work with game entities.

```lua
local coords = GetEntityCoords(PlayerPedId())

-- Find closest entities
local ped, pedCoords = lib.getClosestPed(coords, 20.0)
local vehicle, vehCoords = lib.getClosestVehicle(coords, 30.0)

if ped then
    local distance = Vdist(coords.x, coords.y, coords.z,
                          pedCoords.x, pedCoords.y, pedCoords.z)
    print("Closest ped is", distance, "units away")
end

-- Find multiple nearby entities
local nearbyPeds = lib.getNearbyPeds(coords, 50.0)        -- Returns array
local nearbyVehicles = lib.getNearbyVehicles(coords, 50.0) -- Returns array

print("Found", #nearbyPeds, "peds and", #nearbyVehicles, "vehicles nearby")
```

## 🎬 Streaming APIs

Load game assets asynchronously.

```lua
-- Load animation dictionary
lib.requestAnimDict("script_re@bear_fighting@leader", function(success)
    if success then
        print("Animation dictionary loaded!")
        -- Use animations here
    else
        print("Failed to load animation dictionary")
    end
end)

-- Load audio bank
lib.requestAudioBank("dlc_redm\\script\\audio\\sfx\\redm_audio_bank_1", function(success)
    if success then
        print("Audio bank loaded!")
        -- Use audio here
    else
        print("Failed to load audio bank")
    end
end)
```

## ⏳ Utility APIs

### Wait Functions

```lua
-- Wait for a condition with timeout
lib.waitFor(function()
    return IsPedOnFoot(PlayerPedId())  -- Condition to check
end, "Waiting for player to be on foot", 5000)  -- Message and timeout
```

### Math Utilities

```lua
local rounded = math.round(3.14159, 2)     -- 3.14
local vector = math.tovector("1, 2, 3")    -- vec3(1, 2, 3)
local clamped = math.clamp(15, 1, 10)      -- 10 (clamped to max)
local hex = math.tohex(255)                 -- "FF"
```

### Table Utilities

```lua
-- Shuffle array
local original = {1, 2, 3, 4, 5}
local shuffled = table.shuffle(original)    -- Random order

-- Check if contains value
local hasValue = table.contains({1, 2, 3}, 2)  -- true

-- Merge tables
local merged = table.merge({a = 1}, {b = 2})   -- {a = 1, b = 2}
```

### String Utilities

```lua
-- Generate random strings with patterns
local randomId = string.random("AAA111", 8)     -- "ABC12345"
local letters = string.random("AAAA", 4)        -- "ABCD"
local numbers = string.random("1111", 4)        -- "1234"
```

## 📡 Callback System

Client-server communication system.

### Client to Server

```lua
-- Send data to server and get response
lib.callback('myServerEvent', false, function(response)
    print("Server responded:", response)
end, "Hello from client!")
```

### Server Callback Handler

```lua
-- Register server-side callback handler
lib.callback.register('myServerEvent', function(source, data)
    print("Client", source, "sent:", data)

    -- Process data...
    local result = "Processed: " .. data

    return result  -- Send back to client
end)
```

### Await Style (Client Only)

```lua
-- Synchronous-style callback (waits for response)
local response = lib.callback.await('myServerEvent', false, "data")
print("Response:", response)
```

## 🧪 Testing Commands

### Core Tests
```
/testmath /testtable /teststring /testentities /testpoints
/teststreaming /testwait /testcallback
```

### UI Tests
```
/testnotify /testmarkers /uitest /uitest_progress /uitest_text
/uitest_clear /clearworldtext
```

### Zone Tests
```
/testzones /clearzones
```

### Utility
```
/clearpoints
```

## 🚀 Quick Start Example

```lua
-- In fxmanifest.lua
shared_script '@desync-lib/init.lua'

-- In client.lua
Citizen.CreateThread(function()
    -- Wait for desync-lib
    while not lib do Wait(100) end

    -- Create a welcome zone
    lib.zones.sphere({
        coords = vec3(-200.0, 200.0, 100.0),
        radius = 10.0,
        onEnter = function()
            lib.notify({
                title = "Welcome!",
                description = "You entered the welcome area",
                type = "success"
            })
        end
    })

    -- Add a marker
    Citizen.CreateThread(function()
        while true do
            lib.markers.draw("cylinder", vec3(-200.0, 200.0, 100.0), {
                scale = 1.0,
                red = 0, green = 255, blue = 0
            })
            Wait(0)
        end
    end)
end)
```

## 🔧 Configuration

### Settings (resource/settings.lua)
```lua
return {
    default_locale = 'en',
    notification_position = 'top-right',
    notification_audio = false
}
```

### Localization (locales/en.json)
```json
{
    "settings": "Settings",
    "cancel_progress": "Cancel Progress",
    "confirm": "Confirm",
    "cancel": "Cancel"
}
```

## 🏗️ Architecture

### File Structure
```
desync-lib/
├── fxmanifest.lua          # Resource manifest
├── init.lua               # Main initialization
├── resource/              # Core modules
│   ├── client.lua
│   ├── server.lua
│   ├── settings.lua
│   ├── locale/
│   └── interface/
├── imports/               # Utility modules
│   ├── callback/
│   ├── math/
│   ├── table/
│   ├── string/
│   ├── points/
│   ├── zones/
│   ├── markers/
│   └── getClosest*/
├── locales/               # Language files
├── boilerplate/           # Resource template
├── test-desync/           # Test resource
└── README.md
```

### Module System
- **Dynamic Loading**: Modules loaded on-demand
- **Shared Scripts**: Available to all resources
- **Export System**: Functions available via `exports`
- **Metatable System**: Clean API with `__index` magic

## 🎯 Compatibility

- ✅ **RedM** - Optimized for Red Dead Redemption 2
- ✅ **OneSync** - Full compatibility
- ✅ **Lua 5.4** - Modern Lua features
- ✅ **ox_lib API** - Drop-in replacement

## 📝 Notes

- All coordinates use `vec3(x, y, z)` format
- Colors are RGB (0-255) with optional alpha
- Distances are in game units
- Callbacks support both sync and async patterns
- Zones automatically clean up on resource stop
- Debug mode shows visual boundaries for zones

## 🐛 Troubleshooting

### Common Issues

**"lib is nil"**
- Ensure desync-lib is started before your resource
- Check resource load order in server.cfg

**Functions not available**
- Verify module is loaded in fxmanifest.lua
- Check for typos in function names
- Ensure proper resource dependencies

### Debug Commands
```bash
# Check library status
/libstatus

# Test all functions
/testall

# Clear all points
/clearpoints
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

LGPL-3.0-or-later - Same as ox_lib

## 🙏 Credits

- **ox_lib** - Original library this is based on
- **Linden** - ox_lib creator
- **RedM Community** - For their contributions and support

---

**Ready to revolutionize your RedM development with modern UI and powerful utilities! 🚀**
