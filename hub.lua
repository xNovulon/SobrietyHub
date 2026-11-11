-- Sobriety Hub  ·  made by Novulon  ·  Discord: 1z11 (suggestions and script requests only)
-- Open source and free to use: https://github.com/xNovulon/SobrietyHub
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/xNovulon/SobrietyHub/main/hub.lua"))()

local env = (typeof(getgenv) == "function" and getgenv()) or _G
local BASE = "https://raw.githubusercontent.com/xNovulon/SobrietyHub/main/"
env.sobriety_hub_base = BASE

local GAMES = {
    { name = "FERAL Animal Survival",  path = "scripts/feral.lua",       file = "feral.lua",      game = 10771881861, places = { 108901361810209 } },
    { name = "Throw Food For Animals", path = "scripts/throw_food.lua",  file = "throw_food.lua",  game = 10766972131, places = { 120219252362013 } },
    { name = "Mog to Steal an Egg",    path = "scripts/mog_helper.lua",  file = "mog_helper.lua",  game = 10769299214, places = { 77922212238973 } },
    { name = "Life Together RP",      path = "scripts/life_together.lua", file = "life_together.lua", places = { 13967668166, 99644611200703, 99154507657228 } },
}

local function notify(text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Sobriety Hub", Text = text, Duration = 6 })
    end)
end

local function fetch(path, cache)
    local ok, body = pcall(function() return (game :: any):HttpGet(BASE .. path, true) end)
    if not ok or type(body) ~= "string" or #body < 100 or body:find("404: Not Found", 1, true) then
        body = nil
    end
    local writefile = env.writefile or writefile
    local readfile, isfile = env.readfile or readfile, env.isfile or isfile
    if body then
        if typeof(writefile) == "function" then pcall(writefile, cache, body) end
        return body
    end
    if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile(cache) then
        return (select(2, pcall(readfile, cache)))
    end
    return nil
end

if not game:IsLoaded() then game.Loaded:Wait() end

local pick
for _, g in ipairs(GAMES) do
    if game.GameId == g.game then pick = g break end
    for _, pid in ipairs(g.places) do
        if game.PlaceId == pid then pick = g break end
    end
    if pick then break end
end

if not pick then
    notify("wrong game gng")
    return
end

notify("Loading " .. pick.name .. "...")
local src = fetch(pick.path, pick.file)
if not src then
    notify("Couldn't load the hub for " .. pick.name .. " (no internet, and no saved copy).")
    return
end
local fn, err = loadstring(src, "=SobrietyHub/" .. pick.file)
if not fn then
    notify("The hub for " .. pick.name .. " wouldn't compile.")
    warn("[Sobriety Hub] " .. tostring(err))
    return
end
return fn()
