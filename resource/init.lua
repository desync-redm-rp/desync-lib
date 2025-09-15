local debug_getinfo = debug.getinfo

function noop() end

lib = setmetatable({
    name = 'desync-lib',
    context = IsDuplicityVersion() and 'server' or 'client',
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)

        if debug_getinfo(2, 'S').short_src:find('@desync-lib/resource') then
            exports(key, fn)
        end
    end,

    __index = function(self, key)
        local dir = ('imports/%s'):format(key)
        local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, self.context))
        local shared = LoadResourceFile(self.name, ('%s/shared.lua'):format(dir))

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local fn, err = load(chunk, ('@@desync-lib/%s/%s.lua'):format(key, self.context))

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end

            rawset(self, key, fn() or noop)

            return self[key]
        end
    end
})

cache = {
    resource = lib.name,
    game = GetGameName(),
}

-- Check for web UI (optional for basic functionality)
local webUIFile = LoadResourceFile(lib.name, 'web/build/index.html')
if webUIFile and webUIFile ~= "" then
    lib.print.info('Web UI loaded successfully')
else
    lib.print.warn('Web UI not found - some features may not be available')
end

function lib.hasLoaded() return true end

-- Export functions for other resources to check
exports('hasLoaded', lib.hasLoaded)

require = lib.require
