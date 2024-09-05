hs.application.enableSpotlightForNameSearches(true)

hyper_keys = {"⌘", "⌥", "⇧", "⌃"}

function hyper(key, fn)
    hs.hotkey.bind(hyper_keys, key, fn)
end

function hyper_app(key, app_name, menu)
    hyper(key, function()
        hs.application.launchOrFocus(app_name)
        local app = hs.appfinder.appFromName(app_name)
        if app then
            app:activate()
            if menu then
                app:selectMenuItem(menu)
            end
        end
    end)
end

hyper_app("w", "Brave")
hyper_app("e", "Visual Studio Code")
hyper_app("p", "Perplexity", {"Window", "Main Window"})
hyper_app("s", "System Settings")
hyper_app('t', 'Ghostty')

hyper("§", hs.reload)
hs.alert.show("Hammerspoon Config Reloaded")
