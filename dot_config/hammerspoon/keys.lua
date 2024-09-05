hs.application.enableSpotlightForNameSearches(true)

local Binder = {}
Binder.__index = Binder

function Binder.new(mod, key)
    return setmetatable({
        mod = mod,
        key = key
    }, Binder)
end

function Binder:bind(fn)
    hs.hotkey.bind(self.mod, self.key, fn)
end

function Binder:app(app_name)
    self.app = app_name
    return self
end

function Binder:open(app_name)
    self:bind(function()
        hs.application.launchOrFocus(app_name)
        local app = hs.appfinder.appFromName(app_name)
        if app then
            app:activate()
        end
    end)
end

function Binder:show(app_name)
    self:bind(function()
        local app = hs.appfinder.appFromName(app_name)
        if app and app.isRunning then
            app:activate()
        end
    end)
end

function Binder:menu(menu)
    self:bind(function()
        local app = hs.appfinder.appFromName(self.app)
        if app == nil then
            return
        end
        local activeApp = hs.application.frontmostApplication()
        if activeApp:name() ~= app:name() then
            app:activate()
            app:selectMenuItem(menu)
            activeApp:activate()
        else
            app:selectMenuItem(menu)
        end
    end)
end

----------------------------------------------------------------

local M = {}

function M.hyp(key) return Binder.new({"⌘", "⌥", "⇧", "⌃"}, key) end
function M.opt(key) return Binder.new({"⌥"}, key) end

return M
