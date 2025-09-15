--[[
    Replicated from ox_lib for RedM as desync-lib

    Original: https://github.com/overextended/ox_lib
    Licensed under LGPL-3.0-or-later
]]

---@class PointProperties
---@field coords vector3
---@field distance number
---@field onEnter? fun(self: CPoint)
---@field onExit? fun(self: CPoint)
---@field nearby? fun(self: CPoint)
---@field [string] any

---@class CPoint : PointProperties
---@field id number
---@field currentDistance number
---@field isClosest? boolean
---@field remove fun()

---@type table<number, CPoint>
local points = {}
---@type CPoint[]
local nearbyPoints = {}
local nearbyCount = 0
---@type CPoint?
local closestPoint

local function removePoint(self)
    if closestPoint?.id == self.id then
        closestPoint = nil
    end

    points[self.id] = nil

    -- Remove from nearby points
    for i = 1, nearbyCount do
        if nearbyPoints[i] == self then
            table.remove(nearbyPoints, i)
            nearbyCount = nearbyCount - 1
            break
        end
    end
end

CreateThread(function()
    while true do
        local coords = GetEntityCoords(cache.ped)
        local newNearby = {}
        local newCount = 0
        closestPoint = nil

        -- Check all points for proximity
        for _, point in pairs(points) do
            local distance = #(coords - point.coords)

            if distance <= point.distance then
                point.currentDistance = distance

                -- Track closest point
                if not closestPoint or distance < (closestPoint.currentDistance or point.distance) then
                    if closestPoint then closestPoint.isClosest = nil end
                    point.isClosest = true
                    closestPoint = point
                end

                -- Track nearby points
                newCount = newCount + 1
                newNearby[newCount] = point

                -- Trigger enter event
                if point.onEnter and not point.inside then
                    point.inside = true
                    point:onEnter()
                end

                -- Trigger nearby event
                if point.nearby then
                    point:nearby()
                end
            elseif point.inside then
                -- Trigger exit event
                if point.onExit then
                    point:onExit()
                end
                point.inside = nil
                point.currentDistance = nil
                point.isClosest = nil
            end
        end

        -- Update nearby points list
        nearbyPoints = newNearby
        nearbyCount = newCount

        Wait(300)
    end
end)

local function toVector(coords)
    local _type = type(coords)

    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end

        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end

    return coords
end

lib.points = {}

---@return CPoint
---@overload fun(data: PointProperties): CPoint
---@overload fun(coords: vector3, distance: number, data?: PointProperties): CPoint
function lib.points.new(...)
    local args = { ... }
    local id = #points + 1
    local self

    -- Support sending a single argument containing point data
    if type(args[1]) == 'table' then
        self = args[1]
        self.id = id
        self.remove = removePoint
    else
        -- Backwards compatibility for original implementation (args: coords, distance, data)
        self = {
            id = id,
            coords = args[1],
            remove = removePoint,
        }
    end

    self.coords = toVector(self.coords)
    self.distance = self.distance or args[2]
    self.radius = self.distance

    if args[3] then
        for k, v in pairs(args[3]) do
            self[k] = v
        end
    end

    points[id] = self

    return self
end

function lib.points.getAllPoints() return points end

function lib.points.getNearbyPoints() return nearbyPoints end

---@return CPoint?
function lib.points.getClosestPoint() return closestPoint end

---@deprecated
lib.points.closest = lib.points.getClosestPoint

---Clear all points
function lib.points.clearAll()
    for id, point in pairs(points) do
        if point.remove then
            point:remove()
        end
    end

    points = {}
    nearbyPoints = {}
    nearbyCount = 0
    closestPoint = nil

    lib.print.verbose("all points cleared")
end

return lib.points
