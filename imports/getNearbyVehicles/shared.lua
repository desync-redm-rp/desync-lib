--[[
    Replicated from ox_lib for RedM as desync-lib

    Original: https://github.com/overextended/ox_lib
    Licensed under LGPL-3.0-or-later
]]

---@param coords vector3 The coords to check from.
---@param maxDistance? number The max distance to check.
---@return { vehicle: number, coords: vector3 }[]
function lib.getNearbyVehicles(coords, maxDistance)
    local vehicles = GetGamePool('CVehicle')
    local nearby = {}
    local count = 0
    maxDistance = maxDistance or 2.0

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(coords - vehicleCoords)

        if distance < maxDistance then
            count += 1
            nearby[count] = {
                vehicle = vehicle,
                coords = vehicleCoords,
            }
        end
    end

    return nearby
end

return lib.getNearbyVehicles
