-- Marker drawing system for desync-lib
-- Provides easy-to-use marker functions with string names

---@class markers
lib.markers = {}

-- Marker hash mappings (from RedM documentation)
local markerHashes = {
    -- Basic shapes
    ["cylinder"] = 0x94FDAE17,        -- prop_mk_cylinder
    ["ring"] = 0xEC032ADD,            -- prop_mk_ring
    ["sphere"] = 0x50638AB9,          -- prop_mk_sphere
    ["cube"] = 0x6EB7D3BB,            -- prop_mk_cube

    -- Numbers
    ["num_0"] = 0x29FE305A,           -- prop_mk_num_0
    ["num_1"] = 0xE3C923F1,           -- prop_mk_num_1
    ["num_2"] = 0xD57F875E,           -- prop_mk_num_2
    ["num_3"] = 0x40675D1C,           -- prop_mk_num_3
    ["num_4"] = 0x4E94F977,           -- prop_mk_num_4
    ["num_5"] = 0x234BA2E5,           -- prop_mk_num_5
    ["num_6"] = 0xF9B24FB3,           -- prop_mk_num_6
    ["num_7"] = 0x075FEB0E,           -- prop_mk_num_7
    ["num_8"] = 0xDD839756,           -- prop_mk_num_8
    ["num_9"] = 0xE9F6303B,           -- prop_mk_num_9

    -- Special effects
    ["halo"] = 0x6903B113,            -- prop_mp_halo
    ["halo_point"] = 0xD6445746,      -- prop_mp_halo_point
    ["halo_rotate"] = 0x07DCE236,     -- prop_mp_halo_rotate

    -- Race markers
    ["checkpoint"] = 0xE60FF3B9,      -- s_racecheckpoint01x
    ["finish"] = 0x664669A6,          -- s_racefinish01x

    -- Objects
    ["canoe_pole"] = 0xE03A92AE,      -- p_canoepole01x
    ["buoy"] = 0x751F27D6,            -- p_buoy01x

    -- Legacy names for backwards compatibility
    ["vertical_cylinder"] = 0x94FDAE17,
    ["horizontal_ring"] = 0xEC032ADD,
    ["number_1"] = 0xE3C923F1,
}

---Draws a marker at the specified coordinates
---@param markerType string | number Marker type (string name or hex hash)
---@param coords vector3 | table Coordinates to draw marker at
---@param options? table Additional options
function lib.markers.draw(markerType, coords, options)
    if type(markerType) ~= 'string' and type(markerType) ~= 'number' then
        error('markerType must be a string name or number hash')
    end

    -- Convert string names to hashes
    local markerHash
    if type(markerType) == 'string' then
        markerHash = markerHashes[markerType:lower()]
        if not markerHash then
            error(('Unknown marker type: %s'):format(markerType))
        end
    else
        markerHash = markerType
    end

    -- Set defaults
    options = options or {}
    local scaleX = options.scaleX or options.scale or 1.0
    local scaleY = options.scaleY or options.scale or 1.0
    local scaleZ = options.scaleZ or options.scale or 1.0
    local red = options.red or options.r or 255
    local green = options.green or options.g or 255
    local blue = options.blue or options.b or 255
    local alpha = options.alpha or options.a or 255
    local bobUpAndDown = options.bobUpAndDown or false
    local faceCamera = options.faceCamera or false
    local p19 = options.p19 or 2
    local rotate = options.rotate or false
    local textureDict = options.textureDict
    local textureName = options.textureName
    local drawOnEnts = options.drawOnEnts or false

    -- Convert coords to numbers if needed
    local x, y, z
    if type(coords) == 'vector3' then
        x, y, z = coords.x, coords.y, coords.z
    elseif type(coords) == 'table' then
        x, y, z = coords.x or coords[1], coords.y or coords[2], coords.z or coords[3]
    else
        error('coords must be a vector3 or table')
    end

    -- Draw the marker
    Citizen.InvokeNative(
        0x2A32FAA57B937173, -- DrawMarker native
        markerHash,
        x, y, z,
        0.0, 0.0, 0.0, -- Direction
        0.0, 0.0, 0.0, -- Rotation
        scaleX, scaleY, scaleZ,
        red, green, blue, alpha,
        bobUpAndDown,
        faceCamera,
        p19,
        rotate,
        textureDict, textureName,
        drawOnEnts
    )
end

---Gets the hash for a marker type
---@param markerType string
---@return number? hash
function lib.markers.getHash(markerType)
    if type(markerType) == 'string' then
        return markerHashes[markerType:lower()]
    end
    return markerType
end

---Gets all available marker types
---@return table
function lib.markers.getTypes()
    local types = {}
    for name, _ in pairs(markerHashes) do
        table.insert(types, name)
    end
    table.sort(types)
    return types
end

-- Export functions
exports('drawMarker', lib.markers.draw)
exports('getMarkerHash', lib.markers.getHash)
exports('getMarkerTypes', lib.markers.getTypes)
