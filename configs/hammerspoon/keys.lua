local M = {}
local Binder = {}
Binder.__index = Binder

function M.hyp(key) return Binder.new({"⌘", "⌥", "⇧", "⌃"}, key) end
function M.opt(key) return Binder.new({"⌥"}, key) end

hs.application.enableSpotlightForNameSearches(true)


function Binder.new(mod, key)
    return setmetatable({
        mod = mod,
        key = key
    }, Binder)
end

function Binder:run(fn)
    hs.hotkey.bind(self.mod, self.key, fn)
end

function Binder:app(app_name)
    self.app = app_name
    return self
end

function Binder:open(app_name)
    self:run(function()
        hs.application.launchOrFocus(app_name)
        local app = hs.appfinder.appFromName(app_name)
        if app then
            app:activate()
        end
    end)
end

function Binder:show(app_name)
    self:run(function()
        local app = hs.appfinder.appFromName(app_name)
        if app and app.isRunning then
            app:activate()
        end
    end)
end

function Binder:menu(menu)
    self:run(function()
        local app = hs.appfinder.appFromName(self.app)
        if app and app.isRunning then
            app:selectMenuItem(menu)
        end
    end)
end

return M
