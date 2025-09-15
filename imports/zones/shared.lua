-- Shared zone utilities for desync-lib

---@class zones
lib.zones = {}

---Helper function to create a simple sphere zone
---@param coords vector3
---@param radius number
---@param onEnter? function
---@param onExit? function
---@param inside? function
---@return table
function lib.zones.createSphere(coords, radius, onEnter, onExit, inside)
    return {
        coords = coords,
        radius = radius,
        onEnter = onEnter,
        onExit = onExit,
        inside = inside,
        debug = false
    }
end

---Helper function to create a simple box zone
---@param coords vector3
---@param size vector3
---@param onEnter? function
---@param onExit? function
---@param inside? function
---@return table
function lib.zones.createBox(coords, size, onEnter, onExit, inside)
    return {
        coords = coords,
        size = size,
        onEnter = onEnter,
        onExit = onExit,
        inside = inside,
        debug = false
    }
end

---Helper function to create a simple poly zone
---@param points table
---@param minZ? number
---@param maxZ? number
---@param onEnter? function
---@param onExit? function
---@param inside? function
---@return table
function lib.zones.createPoly(points, minZ, maxZ, onEnter, onExit, inside)
    return {
        points = points,
        minZ = minZ or 0,
        maxZ = maxZ or 100,
        onEnter = onEnter,
        onExit = onExit,
        inside = inside,
        debug = false
    }
end

return lib.zones
