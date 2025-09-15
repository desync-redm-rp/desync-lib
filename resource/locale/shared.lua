--[[
    Replicated from ox_lib for RedM as desync-lib

    Original: https://github.com/overextended/ox_lib
    Licensed under LGPL-3.0-or-later
]]

local locales = {}
local currentLocale = 'en'

---@param locale string
---@param data table
function lib.registerLocale(locale, data)
    locales[locale] = data
end

---@param str string
---@param ... any
---@return string
function locale(str, ...)
    if not str then return '' end

    local locale = locales[currentLocale]

    if not locale then
        return ('locale %s not loaded'):format(currentLocale)
    end

    local translation = locale[str] or str

    if type(translation) ~= 'string' then
        return str
    end

    if ... then
        translation = translation:format(...)
    end

    return translation
end

---@param locale string
function lib.setLocale(locale)
    if not locales[locale] then
        return lib.print.error(('locale %s not registered'):format(locale))
    end

    currentLocale = locale
    lib.print.info(('locale set to %s'):format(locale))

    TriggerEvent('desync-lib:setLocale', locale)
end

---@return string
function lib.getLocale()
    return currentLocale
end

-- Load locales from JSON files
local function loadLocales()
    local localeFiles = {
        'en.json'
    }

    for _, file in ipairs(localeFiles) do
        local content = LoadResourceFile('desync-lib', ('locales/%s'):format(file))
        if content then
            local localeName = file:gsub('%.json$', '')
            local success, data = pcall(json.decode, content)
            if success and data then
                lib.registerLocale(localeName, data)
                lib.print.verbose(('Loaded locale: %s'):format(localeName))
            else
                lib.print.error(('Failed to parse locale file: %s'):format(file))
            end
        else
            lib.print.warn(('Locale file not found: %s'):format(file))
        end
    end
end

loadLocales()

-- Fallback if no locales loaded
if not locales['en'] then
    lib.registerLocale('en', {
        language = 'English',
        settings = 'Settings'
    })
end

-- Export functions for other resources
exports('registerLocale', lib.registerLocale)
exports('setLocale', lib.setLocale)
exports('getLocale', lib.getLocale)
exports('locale', locale)
