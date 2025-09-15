---@meta
--[[
    Replicated from ox_lib for RedM as desync-lib

    Original: https://github.com/overextended/ox_lib
    Licensed under LGPL-3.0-or-later
]]

if not _VERSION:find('5.4') then
    error('Lua 5.4 must be enabled in the resource manifest!', 2)
end

local resourceName = GetCurrentResourceName()
local desync_lib = 'desync-lib'

-- Some people have decided to load this file as part of desync-lib's fxmanifest?
if resourceName == desync_lib then return end

if lib and lib.name == desync_lib then
    error(("Cannot load desync-lib more than once.\n\tRemove any duplicate entries from '@%s/fxmanifest.lua'"):format(resourceName))
end

local export = exports[desync_lib]

if GetResourceState(desync_lib) ~= 'started' then
    error('^1desync-lib must be started before this resource.^0', 0)
end

local status = export.hasLoaded()

if status ~= true then error(status, 2) end

-- Ignore invalid types during msgpack.pack (e.g. userdata)
msgpack.setoption('ignore_invalid', true)

-----------------------------------------------------------------------------------------------
-- Module
-----------------------------------------------------------------------------------------------

local LoadResourceFile = LoadResourceFile
local context = IsDuplicityVersion() and 'server' or 'client'

function noop() end

local function loadModule(self, module)
    local dir = ('imports/%s'):format(module)
    local chunk = LoadResourceFile(desync_lib, ('%s/%s.lua'):format(dir, context))
    local shared = LoadResourceFile(desync_lib, ('%s/shared.lua'):format(dir))

    if shared then
        chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
    end

    if chunk then
        local fn, err = load(chunk, ('@@desync-lib/imports/%s/%s.lua'):format(module, context))

        if not fn or err then
            if shared then
                lib.print.warn(("An error occurred when importing '@desync-lib/imports/%s'.\nThis is likely caused by improperly updating desync-lib.\n%s'")
                    :format(module, err))
                fn, err = load(shared, ('@@desync-lib/imports/%s/shared.lua'):format(module))
            end

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end
        end

        local result = fn()
        self[module] = result or noop
        return self[module]
    end
end

-----------------------------------------------------------------------------------------------
-- API
-----------------------------------------------------------------------------------------------

local function call(self, index, ...)
    local module = rawget(self, index)

    if not module then
        self[index] = noop
        module = loadModule(self, index)

        if not module then
            local function method(...)
                return export[index](nil, ...)
            end

            if not ... then
                self[index] = method
            end

            return method
        end
    end

    return module
end

local lib = setmetatable({
    name = desync_lib,
    context = context,
}, {
    __index = call,
    __call = call,
})

local intervals = {}
--- Dream of a world where this PR gets accepted.
---@param callback function | number
---@param interval? number
---@param ... any
function SetInterval(callback, interval, ...)
    interval = interval or 0

    if type(interval) ~= 'number' then
        return error(('Interval must be a number. Received %s'):format(json.encode(interval --[[@as unknown]])))
    end

    local cbType = type(callback)

    if cbType == 'number' and intervals[callback] then
        intervals[callback] = interval or 0
        return
    end

    if cbType ~= 'function' then
        return error(('Callback must be a function. Received %s'):format(cbType))
    end

    local args, id = { ... }

    Citizen.CreateThreadNow(function(ref)
        id = ref
        intervals[id] = interval or 0
        repeat
            interval = intervals[id]
            Wait(interval)
            callback(table.unpack(args))
        until interval < 0
        intervals[id] = nil
    end)

    return id
end

---@param id number
function ClearInterval(id)
    if type(id) ~= 'number' then
        return error(('Interval id must be a number. Received %s'):format(json.encode(id --[[@as unknown]])))
    end

    if not intervals[id] then
        return error(('No interval exists with id %s'):format(id))
    end

    intervals[id] = -1
end

--[[
    lua language server doesn't support generics when using @overload
    see https://github.com/LuaLS/lua-language-server/issues/723
    this function stub allows the following to work

    local key = cache('key', function() return 'abc' end) -- fff: 'abc'
    local game = cache.game -- game: string
]]

---@generic T
---@param key string
---@param func fun(...: any): T
---@param timeout? number
---@return T
---Caches the result of a function, optionally clearing it after timeout ms.
function cache(key, func, timeout) end

local cacheEvents = {}

local cache = setmetatable({ game = GetGameName(), resource = resourceName }, {
    __index = function(self, key)
        cacheEvents[key] = {}

        AddEventHandler(('desync-lib:cache:%s'):format(key), function(value)
            local oldValue = self[key]
            local events = cacheEvents[key]

            for i = 1, #events do
                Citizen.CreateThreadNow(function()
                    events[i](value, oldValue)
                end)
            end

            self[key] = value
        end)

        return rawset(self, key, export.cache(nil, key) or false)[key]
    end,

    __call = function(self, key, func, timeout)
        local value = rawget(self, key)

        if value == nil then
            value = func()

            rawset(self, key, value)

            if timeout then SetTimeout(timeout, function() self[key] = nil end) end
        end

        return value
    end,
})

function lib.onCache(key, cb)
    if not cacheEvents[key] then
        getmetatable(cache).__index(cache, key)
    end

    table.insert(cacheEvents[key], cb)
end

_ENV.lib = lib
_ENV.cache = cache
_ENV.require = lib.require

local notifyEvent = ('__desync_notify_%s'):format(cache.resource)

if context == 'client' then
    RegisterNetEvent(notifyEvent, function(data)
        if locale then
            if data.title then
                data.title = locale(data.title) or data.title
            end

            if data.description then
                data.description = locale(data.description) or data.description
            end
        end

        return export:notify(data)
    end)

    cache.playerId = PlayerId()
    cache.serverId = GetPlayerServerId(cache.playerId)
else
    ---`server`\
    ---Trigger a notification on the target playerId from the server.\
    ---If locales are loaded, the title and description will be formatted automatically.\
    ---Note: No support for locale placeholders when using this function.
    ---@param playerId number
    ---@param data NotifyProps
    ---@deprecated
    ---@diagnostic disable-next-line: duplicate-set-field
    function lib.notify(playerId, data)
        TriggerClientEvent(notifyEvent, playerId, data)
    end

    local poolNatives = {
        CPed = GetAllPeds,
        CObject = GetAllObjects,
        CVehicle = GetAllVehicles,
    }

    ---@param poolName 'CPed' | 'CObject' | 'CVehicle'
    ---@return number[]
    ---Server-side parity for the `GetGamePool` client native.
    function GetGamePool(poolName)
        local fn = poolNatives[poolName]
        return fn and fn() --[[@as number[] ]]
    end

    ---@return number[]
    ---Server-side parity for the `GetPlayers` client native.
    function GetActivePlayers()
        local playerNum = GetNumPlayerIndices()
        local players = table.create(playerNum, 0)

        for i = 1, playerNum do
            players[i] = tonumber(GetPlayerFromIndex(i - 1))
        end

        return players
    end
end

for i = 1, GetNumResourceMetadata(cache.resource, 'desync-lib') do
    local name = GetResourceMetadata(cache.resource, 'desync-lib', i - 1)

    if not rawget(lib, name) then
        local module = loadModule(lib, name)

        if type(module) == 'function' then pcall(module) end
    end
end

-- Load essential modules first
-- Load settings
local settingsChunk = LoadResourceFile(desync_lib, 'resource/settings.lua')
if settingsChunk then
    local fn, err = load(settingsChunk, '@@desync-lib/resource/settings.lua')
    if fn then
        lib.settings = fn()
    end
end

-- Load locale module from resource directory
local localeChunk = LoadResourceFile(desync_lib, 'resource/locale/shared.lua')
if localeChunk then
    local fn, err = load(localeChunk, '@@desync-lib/resource/locale/shared.lua')
    if fn then
        local localeModule = fn()
        if localeModule then
            lib.locale = localeModule
        end
    end
end

-- Fallback if modules failed to load
if not lib.settings then
    lib.settings = {
        default_locale = 'en',
        notification_position = 'top-right',
        notification_audio = false
    }
end

if not lib.locale then
    lib.locale = function(str, ...) return str end
end

-- Set up global functions for other resources
-- Make locale function globally available
_G.locale = function(str, ...)
    return lib.locale(str, ...)
end
