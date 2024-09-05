hs.application.enableSpotlightForNameSearches(true)

hyper_keys = {"⌘", "⌥", "⇧", "⌃"}

function hyper(key, fn)
    hs.hotkey.bind(hyper_keys, key, fn)
end

function open_app(app_name, menu)
    return function() _open_app(app_name, menu) end
end

function _open_app(app_name, menu)
    hs.application.launchOrFocus(app_name)
    local app = hs.appfinder.appFromName(app_name)
    if app then
        app:activate()
        if menu then
            app:selectMenuItem(menu)
        end
    end
end

function bring_to_front(app_name)
    return function() _bring_to_front(app_name) end
end

function _bring_to_front(app_name)
    local app = hs.appfinder.appFromName(app_name)
    if app and app.isRunning then
        app:activate()
    end
end

-- hyp-a, hyp-f, hyp-j are mapped to homerow app

hyper("w", open_app("Brave"))
hyper("e", open_app("Visual Studio Code"))
hyper("r", bring_to_front("Hearthstone"))
hyper("t", open_app("Ghostty"))
hyper("p", open_app("Perplexity", {"Window", "Main Window"}))
hyper("s", open_app("System Settings"))
hyper("d", open_app("Finder"))

hyper("§", hs.reload)
hs.alert.show("Hammerspoon Config Reloaded")
