-- Zone system for desync-lib
-- Supports spherical, box, and polygonal zones with enter/exit events

---@class zones
lib.zones = {}

local zones = {}
local activeZones = {}
local nextZoneId = 1

-- Helper function to check if point is inside sphere
local function isPointInSphere(point, center, radius)
    local distance = Vdist(point.x, point.y, point.z, center.x, center.y, center.z)
    return distance <= radius
end

-- Helper function to check if point is inside box
local function isPointInBox(point, center, size)
    return point.x >= center.x - size.x/2 and point.x <= center.x + size.x/2 and
           point.y >= center.y - size.y/2 and point.y <= center.y + size.y/2 and
           point.z >= center.z - size.z/2 and point.z <= center.z + size.z/2
end

-- Helper function to check if point is inside polygon (2D)
local function isPointInPolygon(point, vertices)
    local inside = false
    local j = #vertices

    for i = 1, #vertices do
        if ((vertices[i].y > point.y) ~= (vertices[j].y > point.y)) and
           (point.x < (vertices[j].x - vertices[i].x) * (point.y - vertices[i].y) / (vertices[j].y - vertices[i].y) + vertices[i].x) then
            inside = not inside
        end
        j = i
    end

    return inside
end

-- Helper function to check if point is inside 3D polygon (extruded 2D polygon)
local function isPointInPolygon3D(point, vertices, minZ, maxZ)
    -- First check Z bounds
    if point.z < minZ or point.z > maxZ then
        return false
    end

    -- Then check 2D polygon
    return isPointInPolygon(point, vertices)
end

---Create a spherical zone
---@param data table Zone configuration
---@return number zoneId
function lib.zones.sphere(data)
    if not data.coords or not data.radius then
        error('sphere zone requires coords and radius')
    end

    local zoneId = nextZoneId
    nextZoneId = nextZoneId + 1

    zones[zoneId] = {
        id = zoneId,
        type = 'sphere',
        coords = data.coords,
        radius = data.radius,
        onEnter = data.onEnter,
        onExit = data.onExit,
        inside = data.inside,
        debug = data.debug or false,
        isInside = false
    }

    lib.print.verbose(("sphere zone created: %d (radius: %.1f)"):format(zoneId, data.radius))
    return zoneId
end

---Create a box zone
---@param data table Zone configuration
---@return number zoneId
function lib.zones.box(data)
    if not data.coords or not data.size then
        error('box zone requires coords and size')
    end

    local zoneId = nextZoneId
    nextZoneId = nextZoneId + 1

    zones[zoneId] = {
        id = zoneId,
        type = 'box',
        coords = data.coords,
        size = data.size,
        onEnter = data.onEnter,
        onExit = data.onExit,
        inside = data.inside,
        debug = data.debug or false,
        isInside = false
    }

    lib.print.verbose(("box zone created: %d (size: %.1fx%.1fx%.1f)"):format(zoneId, data.size.x, data.size.y, data.size.z))
    return zoneId
end

---Create a polygonal zone
---@param data table Zone configuration
---@return number zoneId
function lib.zones.poly(data)
    if not data.points or #data.points < 3 then
        error('poly zone requires at least 3 points')
    end

    local zoneId = nextZoneId
    nextZoneId = nextZoneId + 1

    -- Calculate bounds for optimization
    local minZ = data.minZ or 0
    local maxZ = data.maxZ or 100

    zones[zoneId] = {
        id = zoneId,
        type = 'poly',
        points = data.points,
        minZ = minZ,
        maxZ = maxZ,
        onEnter = data.onEnter,
        onExit = data.onExit,
        inside = data.inside,
        debug = data.debug or false,
        isInside = false
    }

    lib.print.verbose(("poly zone created: %d (%d points)"):format(zoneId, #data.points))
    return zoneId
end

---Remove a zone
---@param zoneId number
function lib.zones.remove(zoneId)
    if zones[zoneId] then
        zones[zoneId] = nil
        activeZones[zoneId] = nil
        lib.print.verbose(("zone removed: %d"):format(zoneId))
    end
end

---Clear all zones
function lib.zones.clearAll()
    zones = {}
    activeZones = {}
    lib.print.verbose("all zones cleared")
end

---Get all zones
---@return table
function lib.zones.getAll()
    return zones
end

-- Main zone checking thread
Citizen.CreateThread(function()
    while true do
        local playerCoords = GetEntityCoords(PlayerPedId())

        for zoneId, zone in pairs(zones) do
            local isInside = false

            if zone.type == 'sphere' then
                isInside = isPointInSphere(playerCoords, zone.coords, zone.radius)
            elseif zone.type == 'box' then
                isInside = isPointInBox(playerCoords, zone.coords, zone.size)
            elseif zone.type == 'poly' then
                isInside = isPointInPolygon3D(playerCoords, zone.points, zone.minZ, zone.maxZ)
            end

            -- Handle enter/exit events
            if isInside and not zone.isInside then
                zone.isInside = true
                if zone.onEnter then
                    zone:onEnter()
                end
                lib.print.verbose(("entered zone: %d"):format(zoneId))
            elseif not isInside and zone.isInside then
                zone.isInside = false
                if zone.onExit then
                    zone:onExit()
                end
                lib.print.verbose(("exited zone: %d"):format(zoneId))
            end

            -- Handle continuous inside event
            if isInside and zone.inside then
                zone:inside()
            end

            -- Debug visualization
            if zone.debug then
                if zone.type == 'sphere' then
                    -- Draw single sphere marker representing the zone boundary
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x50638AB9, -- sphere marker
                        zone.coords.x, zone.coords.y, zone.coords.z,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        zone.radius, zone.radius, zone.radius, -- radius equals zone size
                        255, 0, 255, 100, -- semi-transparent magenta
                        false, false, 2, false, nil, nil, false)
                elseif zone.type == 'box' then
                    -- Draw single large cube marker representing the box boundaries
                    Citizen.InvokeNative(0x2A32FAA57B937173, 0x6EB7D3BB, -- cube marker
                        zone.coords.x, zone.coords.y, zone.coords.z,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        zone.size.x, zone.size.y, zone.size.z, -- actual box dimensions
                        255, 255, 0, 100, -- semi-transparent yellow
                        false, false, 2, false, nil, nil, false)
                elseif zone.type == 'poly' then
                    -- Draw polygon boundary lines (wireframe only)
                    for i, point in ipairs(zone.points) do
                        local nextPoint = zone.points[i % #zone.points + 1]
                        DrawLine(point.x, point.y, point.z, nextPoint.x, nextPoint.y, nextPoint.z, 0, 255, 255, 255)
                    end
                end
            end
        end

        Wait(0) -- Check zones every frame for smooth debug visualization
    end
end)

-- Export functions
exports('createSphereZone', lib.zones.sphere)
exports('createBoxZone', lib.zones.box)
exports('createPolyZone', lib.zones.poly)
exports('removeZone', lib.zones.remove)
exports('clearAllZones', lib.zones.clearAll)
exports('getAllZones', lib.zones.getAll)

return lib.zones
