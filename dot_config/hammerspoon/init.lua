local keys = require("keys")

-- hyp-m, hyp-f, hyp-j are mapped to homerow app

keys.hyp "§" :bind(hs.reload)

keys.hyp "w" :open "Brave"
keys.hyp "e" :open "Visual Studio Code"
keys.hyp "r" :show "Hearthstone"
keys.hyp "t" :open "Ghostty"
keys.hyp "p" :open "Perplexity"
keys.hyp "s" :open "System Settings"
keys.hyp "d" :open "Finder"
keys.hyp "z" :open "Zed"

keys.opt "[" :app "Brave" :menu {"History", "Back"}
keys.opt "]" :app "Brave" :menu {"History", "Forward"}

hs.alert.show("Hammerspoon Config Reloaded")
