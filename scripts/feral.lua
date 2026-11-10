-- Sobriety Hub  ·  made by Novulon  ·  Discord: 1z11 (suggestions and script requests only)
-- Open source and free to use: https://github.com/xNovulon/SobrietyHub
-- If you use this work to make a new script or an updated version, I'd appreciate a credit.
-- Loader: loadstring(game:HttpGet("https://raw.githubusercontent.com/xNovulon/SobrietyHub/main/hub.lua"))()

-- Sobriety Hub: FERAL Animal Survival
-- Hunts bots only (never players), eats and drinks for you, fishes, picks the amber trees, explores, does place quests,
-- claims rewards, breaks free from grabs, fights back (bite aura on T), dodges birds, gets away when low, runs from
-- players, and adds speed / endless stamina / fast swimming / no hurt slowdown, teleports, ESP and your animal's name.
-- Right Alt (or the round S button) hides / shows the window. Running it again restarts it.
local env = (typeof(getgenv) == "function" and getgenv()) or _G
local fenv = getfenv()
local function exec(name) return env[name] or fenv[name] end
if env.sobriety_feral_stop then pcall(env.sobriety_feral_stop) end
-- [[ this run's token: if another copy starts while this one is still loading, the older one quits ]] --
local RUN = {}
env.sobriety_feral_run = RUN

if not game:IsLoaded() then game.Loaded:Wait() end
local GAME_ID, PLACE_ID = 10771881861, 108901361810209
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local me = Players.LocalPlayer

local function notify(text)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Sobriety Hub", Text = text, Duration = 5 }) end)
end
if game.GameId ~= GAME_ID then
    notify("This script is for FERAL Animal Survival.")
    return
end
-- [[ the game gives you an animal once you've picked one (FeralAnimal): nothing is touched before that ]] --
do
    local t = os.clock()
    while not me:GetAttribute("FeralAnimal") and os.clock() - t < 120 do task.wait(0.25) end
end
if env.sobriety_feral_run ~= RUN then return end

---------------------------------------------------------------- state and settings

local S = {
    alive = true, conns = {}, threads = {}, auto_off = {}, status = "Ready", log = {}, log_dirty = false, session_start = os.clock(),
    ui_size = 1, boot_anim = true, hide_key = "RightAlt", saved_settings = "", settings_loaded = false,
    farm = false, hunt = true, prey = "Prey", bite_speed = 1, auto_lunge = true, latch_bite = true, auto_squeeze = true, eat_kills = true,
    auto_eat = true, eat_at = 70, auto_drink = true, drink_at = 70, food_src = "Both", drink_return = true,
    revive_free = false, flee_players = true, flee_dist = 70, flee_npcs = true, rest_heal = true,
    anti_grab = true, fight_back = true, dodge_birds = true, low_escape = false, big_hit_escape = true, low_escape_at = 25, low_escape_mode = "Both",
    aura = false, aura_bots = true, bird_bite = true, bird_reach_mult = 1.5, leap_on = true, leap_key = "V", leap_range = 40, keep_latch = true, aura_key = "T", aura_ring = true, aura_targets = "Attackers", reach_mult = 1,
    walk_mult = 1, trot_mult = 1, run_mult = 1, burst_mult = 1, escape_far = 200, speed_lock = true, snap_guard = true, escape = true, inf_stamina = true, no_hurt_slow = true, fast_swim = true, travel_speed = 1, instant_turn = true, touch_bar = true, touch_bar_always = false, slow_near = false, auto_gait = "Off", avoid_players = true, avoid_dist = 150, low_profile = true, travel_under = true, near_mode = "Under", watch_dist = 150,
    esp = false, esp_players = true, esp_predators = true, esp_gators = true, esp_prey = false, esp_mice = false, esp_range = 600, esp_highlight = true,
    rewards = true, quest_places = true, chunks = true, explore = true, anti_afk = true, auto_reload = true,
    cull = true, cull_dist = 400, hide_raids = true, event_log = true, afk = false, afk_place = "Under", hop_amber = true, amber_mode = false,
    hook_on = false, hook_url = "", hook_death = true, hook_low = true, hook_hunger = true, hook_thirst = true, hook_goal_on = true, hook_hp = 25, hook_need = 20, hook_goal = 0,
    tag_text = "",
    -- [[ this session only ]] --
    phase = "idle", kills = 0, bites = 0, hits = 0, fish = 0, drinks = 0, meals = 0, deaths = 0, claims = 0, grabs = 0, dodges = 0, quests_done = 0,
    chunk_amber = 0, bird_bites = 0, bird_hits = 0, fast_state = 0, fast_sent = 0, fast_hits = 0, norm_sent = 0, norm_hits = 0, pace_fast_now = false, cur_cd = 0.7, last_bite_t = 0,
    drink_anywhere = 0, found = {}, failed = {}, quest_tried = {}, herd_i = 0, chunk_t = -1000, toured = false, manual = false, manual_gen = 0,
    held = false, was_held = false, escaping = false, last_bitten = -1000, last_kill = "-", walk_set = false, patched_sp = false, face_m = false,
    face_until = 0, leaping = false, leap_target = false, release_ok = false, afk_up_now = false, afk_under_now = false, underground = false, speed_cap = 99, travel_cap = 999, lead_i = 1, last_input_t = 0, noclip = false, fish_bad_school = {}, self_moved_t = 0, gait_set = false, trot_press_t = 0, goal_sent = 0, starve_note_t = -100, nostam_set = false, last_sq_t = 0, clamp_prey = false, latch_sent = 0, latch_hits = 0, last_under_t = -100, last_surface = false, water_burst = false, hold_chase = false, chase_speed = 60, avoid = false, snaps = 0, snap_t = -100, last_pace = 100, trot_now = 1, hopping = false, hop_due = false, afk_pos = false, afk_name = false, afk_back = false, target = false, quests = false, rew = false, rew_t = 0, rejoining = false, last_err = "", paint_errs = {}, amber0 = 0,
}
local SETTING_KEYS = { "ui_size", "boot_anim", "hide_key",
    "farm", "hunt", "prey", "bite_speed", "auto_lunge", "latch_bite", "auto_squeeze", "eat_kills", "auto_eat", "eat_at", "auto_drink", "drink_at",
    "food_src", "drink_return", "revive_free", "flee_players", "flee_dist", "flee_npcs", "rest_heal", "anti_grab", "fight_back", "dodge_birds",
    "low_escape", "big_hit_escape", "low_escape_at", "low_escape_mode", "aura", "aura_bots", "bird_bite", "bird_reach_mult", "leap_on", "leap_key", "leap_range", "keep_latch", "aura_key", "aura_ring", "aura_targets", "reach_mult", "walk_mult", "trot_mult", "run_mult", "burst_mult", "escape_far", "speed_lock", "snap_guard", "escape",
    "inf_stamina", "no_hurt_slow", "fast_swim", "travel_speed", "instant_turn", "touch_bar", "touch_bar_always", "slow_near", "auto_gait", "avoid_players", "avoid_dist", "low_profile", "travel_under", "near_mode", "watch_dist", "esp", "esp_players", "esp_predators", "esp_gators",
    "esp_prey", "esp_mice", "esp_range", "esp_highlight", "rewards", "quest_places", "chunks", "explore", "anti_afk", "auto_reload",
    "cull", "cull_dist", "hide_raids", "event_log", "afk", "afk_place", "hop_amber", "amber_mode",
    "hook_on", "hook_url", "hook_death", "hook_low", "hook_hunger", "hook_thirst", "hook_goal_on", "hook_hp", "hook_need", "hook_goal",
    "tag_text",
}
local function track(c) table.insert(S.conns, c) return c end
-- [[ every background job is written down here, so Unload can stop each one mid-way ]] --
local function go(fn, ...)
    local th = task.spawn(fn, ...)
    if #S.threads > 40 then
        for i = #S.threads, 1, -1 do
            if coroutine.status(S.threads[i]) == "dead" then table.remove(S.threads, i) end
        end
    end
    table.insert(S.threads, th)
    return th
end
env.sobriety_feral_state = S
-- [[ a stop that works from here on, so a newer copy can always shut this one down (the full Unload replaces it) ]] --
env.sobriety_feral_stop = function()
    S.alive = false
    local here = coroutine.running()
    for _, th in ipairs(S.threads) do
        if th ~= here then pcall(task.cancel, th) end
    end
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
end

-- [[ the log: what the script did and why, kept in memory, shown in the Logs tab, saved to a file every minute ]] --
-- [[ each account has its own settings and log (named after it), so alts never overwrite each other, even running at ]] --
-- [[ the same time. An account's first run starts from the old shared settings file (OLD_SETTINGS), if there is one.  ]] --
local LOG_FILE = ("SobrietyHub_Feral_%s_Log.txt"):format(me.Name)
local SETTINGS_FILE = ("SobrietyHub_Feral_%s_Settings.json"):format(me.Name)
local OLD_SETTINGS = "SobrietyHub_Feral_Settings.json"
S.log_file = LOG_FILE
local function logf(kind, text)
    local line = ("[%s +%dm] %s: %s"):format(os.date("%H:%M:%S"), math.floor((os.clock() - S.session_start) / 60), kind, tostring(text))
    table.insert(S.log, line)
    if #S.log > 1500 then table.remove(S.log, 1) end
    S.log_dirty = true
end
logf("START", "Sobriety Hub loaded (FERAL Animal Survival)")

local function settings_json()
    local t = {}
    for _, k in ipairs(SETTING_KEYS) do t[k] = S[k] end
    -- [[ a switch that turned itself off is saved as on: it only stays off for this session ]] --
    for k in pairs(S.auto_off) do
        if t[k] == false then t[k] = true end
    end
    local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
    return ok and s or ""
end
pcall(function()
    local readfile, isfile = exec("readfile"), exec("isfile")
    if typeof(readfile) == "function" and typeof(isfile) == "function" then
        local from = isfile(SETTINGS_FILE) and SETTINGS_FILE or (isfile(OLD_SETTINGS) and OLD_SETTINGS) or nil
        if not from then return end
        local t = HttpService:JSONDecode(readfile(from))
        for _, k in ipairs(SETTING_KEYS) do
            if t[k] ~= nil and type(t[k]) == type(S[k]) then S[k] = t[k] end
        end
        S.settings_loaded = true
        logf("START", from == SETTINGS_FILE and ("settings for %s loaded"):format(me.Name)
            or ("first run on %s: started from the shared settings; from now on this account keeps its own"):format(me.Name))
    end
end)
if S.ui_size ~= 0.85 and S.ui_size ~= 1 and S.ui_size ~= 1.15 then S.ui_size = 1 end
local function one_of(v, list, default)
    for _, x in ipairs(list) do
        if v == x then return v end
    end
    return default
end
S.prey = one_of(S.prey, { "Mice", "Prey", "Big", "Any" }, "Prey")
S.bite_speed = one_of(S.bite_speed, { 1, 1.25, 1.5, 2 }, 1)
S.food_src = one_of(S.food_src, { "Both", "Fish", "Kills" }, "Both")
S.low_escape_mode = one_of(S.low_escape_mode, { "Both", "Me" }, "Both")
S.aura_targets = one_of(S.aura_targets, { "Attackers", "Everyone" }, "Attackers")
S.aura_key = one_of(S.aura_key, { "T", "V", "N", "K" }, "T")
S.eat_at = one_of(S.eat_at, { 50, 70, 85, 95 }, 70)
S.drink_at = one_of(S.drink_at, { 50, 70, 85, 95 }, 70)
S.flee_dist = one_of(S.flee_dist, { 40, 70, 120 }, 70)
S.low_escape_at = one_of(S.low_escape_at, { 15, 25, 40 }, 25)
S.reach_mult = one_of(S.reach_mult, { 1, 1.25, 1.5 }, 1)
S.bird_reach_mult = one_of(S.bird_reach_mult, { 1.5, 2, 3 }, 1.5)
S.leap_key = one_of(S.leap_key, { "V", "N", "K", "Y" }, "V")
S.leap_range = one_of(S.leap_range, { 15, 40, 80 }, 40)
S.walk_mult = one_of(S.walk_mult, { 1, 1.25, 1.5, 2, 3 }, 1)
S.trot_mult = one_of(S.trot_mult, { 1, 1.25, 1.5, 2, 3 }, 1)
S.run_mult = one_of(S.run_mult, { 1, 1.25, 1.5, 2, 3 }, 1)
S.burst_mult = one_of(S.burst_mult, { 1, 1.25, 1.5, 2, 3 }, 1)
S.escape_far = one_of(S.escape_far, { 100, 200, 400 }, 200)
-- [[ Instant is gone (the server pulls you back after any teleport): an old Instant pick becomes 400 ]] --
if S.travel_speed == 0 then S.travel_speed = 400 end
S.travel_speed = one_of(S.travel_speed, { 1, 60, 100, 160, 250, 400 }, 1)
S.auto_gait = one_of(S.auto_gait, { "Off", "Trot", "Run", "Burst" }, "Off")
S.avoid_dist = one_of(S.avoid_dist, { 100, 150, 250 }, 150)
S.esp_range = one_of(S.esp_range, { 300, 600, 1200, 3000 }, 600)
S.cull_dist = one_of(S.cull_dist, { 250, 400, 700 }, 400)
S.hook_hp = one_of(S.hook_hp, { 15, 25, 40, 60 }, 25)
S.hook_need = one_of(S.hook_need, { 10, 20, 30 }, 20)
if type(S.hook_goal) ~= "number" or S.hook_goal < 0 then S.hook_goal = 0 end
S.near_mode = one_of(S.near_mode, { "Under", "Pause" }, "Under")
S.watch_dist = one_of(S.watch_dist, { 80, 150, 250 }, 150)
S.afk_place = one_of(S.afk_place, { "Under", "Sky" }, "Under")
S.saved_settings = settings_json()

---------------------------------------------------------------- helpers

-- [[ 1234567 -> "1.23M", the way the game shortens numbers ]] --
local SUFFIX = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
local function short(n)
    n = tonumber(n) or 0
    if n ~= n then return "?" end
    local neg = n < 0
    n = math.abs(n)
    if n < 1000 then return (neg and "-" or "") .. (n == math.floor(n) and ("%d"):format(n) or ("%.1f"):format(n)) end
    local i = math.min(#SUFFIX, math.floor(math.log10(n) / 3))
    local v = n / 10 ^ (i * 3)
    return (neg and "-" or "") .. (v >= 100 and ("%.0f"):format(v) or v >= 10 and ("%.1f"):format(v) or ("%.2f"):format(v)) .. SUFFIX[i]
end
local function root_part()
    local char = me.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

---------------------------------------------------------------- the game's own pieces (from the game dump: reports/feral/*.md)

local Workspace = workspace
local CollectionService = game:GetService("CollectionService")
local VIM = (function()
    local ok, v = pcall(game.GetService, game, "VirtualInputManager")
    return ok and v or nil
end)()
local FW = RS:WaitForChild("FeralWorld", 30)
local function game_module(name)
    local m = FW and FW:FindFirstChild(name)
    if not m then return nil end
    local ok, r = pcall(require, m)
    return (ok and type(r) == "table") and r or nil
end
-- [[ the game's settings and helpers (Species stats, map spots, how it finds water, where the fish swim) ]] --
local G: any = {}
for _, n in ipairs({ "Species", "MapSpots", "FeedFinder", "FishPath", "FishConfig", "NeedsConfig", "AbilityConfig", "StatusConfig", "RewardConfig" }) do
    G[n] = game_module(n)
end
local R: any = {}
for _, n in ipairs({ "WolfActions", "FeralFishEat", "FeralRewards", "FeralQuests", "FeralDeath", "FeralPlaces", "FeralHit", "FeralLunge" }) do
    R[n] = RS:FindFirstChild(n)
end
local function now() return Workspace:GetServerTimeNow() end

-- [[ What this executor can do. Potassium has all of it; lower-level ones (Xeno, Solara...) may not: the hub then ]] --
-- [[ runs without that piece (each use is checked), and this list says what's off. Shown in Settings and the log. ]] --
local SUPPORT = {
    { "getgc", "speed / stamina / swim / turn settings (unless the game's own tables come back from require)" },
    { "hookmetamethod", "\"Stay on until I let go\"" },
    { "getcustomasset", "the animated logo (a plain S instead)" },
    { "writefile", "saving your settings and logs" },
    { "readfile", "loading your saved settings" },
    { "queue_on_teleport", "coming back after a server move or hop" },
    { "request", "Discord alerts" },
    { "setclipboard", "the copy-log buttons" },
    { "gethui", "hiding the window from the game (it still opens)" },
}
function S.support()
    local missing = {}
    for _, x in ipairs(SUPPORT) do
        local f = exec(x[1])
        if x[1] == "request" and typeof(f) ~= "function" then f = exec("http_request") end
        if x[1] == "queue_on_teleport" and typeof(f) ~= "function" then f = exec("queueonteleport") end
        if typeof(f) ~= "function" then table.insert(missing, x) end
    end
    if not VIM or S.vim_failed then table.insert(missing, { "VirtualInputManager", "pressing keys for you (auto lunge, auto trot, the mouse nudge)" }) end
    local name = "unknown"
    pcall(function()
        local idf = exec("identifyexecutor") or exec("getexecutorname")
        if typeof(idf) == "function" then name = tostring((idf())) end
    end)
    return name, missing
end
task.defer(function()
    local name, missing = S.support()
    local off = {}
    for _, x in ipairs(missing) do table.insert(off, x[1]) end
    logf("START", ("executor: %s; %s"):format(name, #off == 0 and "everything works" or ("missing: " .. table.concat(off, ", "))))
end)

---------------------------------------------------------------- the event log: everything, for reading back later
-- [[ What the server sends you (every remote), what the hub sends, your stats as they change, players coming and   ]] --
-- [[ going, the game's own errors and a snapshot each minute. Its own file (S.events_file), next to the normal log. ]] --
-- [[ Busy things are cut down: the first few of each kind in full, then every Nth, plus a count each minute.        ]] --
S.events, S.events_dirty = {}, false
S.events_file = ("SobrietyHub_Feral_%s_Events.txt"):format(me.Name)
local function ev(kind, text)
    if not S.event_log then return end
    table.insert(S.events, ("[%s +%dm] %s: %s"):format(os.date("%H:%M:%S"), math.floor((os.clock() - S.session_start) / 60), kind, tostring(text)))
    if #S.events > 5000 then table.remove(S.events, 1) end
    S.events_dirty = true
end
S.ev = ev
local function brief(v, depth)
    depth = depth or 0
    local t = typeof(v)
    if t == "Instance" then
        local pl = v:IsA("Model") and Players:GetPlayerFromCharacter(v)
        return pl and ("<" .. pl.Name .. ">") or ("<" .. v.Name .. ">")
    elseif t == "table" then
        if depth > 1 then return "{..}" end
        local parts, n = {}, 0
        for k, x in pairs(v) do
            n += 1
            if n > 10 then
                table.insert(parts, "..")
                break
            end
            table.insert(parts, tostring(k) .. "=" .. brief(x, depth + 1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif t == "number" then
        return v == math.floor(v) and tostring(v) or ("%.2f"):format(v)
    elseif t == "Vector3" then
        return ("(%.0f,%.0f,%.0f)"):format(v.X, v.Y, v.Z)
    elseif t == "string" then
        return '"' .. v:sub(1, 70) .. '"'
    end
    return tostring(v)
end
local function brief_args(...)
    local out = {}
    for i = 1, select("#", ...) do table.insert(out, brief((select(i, ...)))) end
    return table.concat(out, ", ")
end
local counts = {} -- [key] = { n, logged_n, minute_n }
local function counted(key, every)
    local c = counts[key]
    if not c then
        c = { n = 0, minute = 0 }
        counts[key] = c
    end
    c.n += 1
    c.minute += 1
    return c.n <= 4 or c.n % every == 0, c.n
end
S.ev_counts = counts
local function fire(name, ...)
    local r = R[name]
    if not r then return false end
    local first = select(1, ...)
    local show, n = counted("SEND " .. name .. " " .. (type(first) == "string" and first or typeof(first)), 25)
    if show then ev("SEND", ("%s(%s)  #%d"):format(name, brief_args(...), n)) end
    return (pcall(r.FireServer, r, ...))
end
-- [[ every server -> you message, on every remote the game has ]] --
for _, rem in ipairs(RS:GetChildren()) do
    if rem:IsA("RemoteEvent") then
        track(rem.OnClientEvent:Connect(function(...)
            local first = select(1, ...)
            local show, n = counted("GOT " .. rem.Name .. " " .. (type(first) == "string" and first:sub(1, 30) or typeof(first)), 40)
            if show then ev("GOT", ("%s(%s)  #%d"):format(rem.Name, brief_args(...), n)) end
        end))
    end
end
-- [[ the game's own errors and warnings (the same one at most once a minute) ]] --
pcall(function()
    local seen = {}
    track(game:GetService("LogService").MessageOut:Connect(function(msg, kind)
        if kind ~= Enum.MessageType.MessageError and kind ~= Enum.MessageType.MessageWarning then return end
        local key = tostring(msg):sub(1, 120)
        if seen[key] and os.clock() - seen[key] < 60 then return end
        seen[key] = os.clock()
        ev(kind == Enum.MessageType.MessageError and "GAME-ERROR" or "GAME-WARN", tostring(msg):sub(1, 300))
    end))
end)
-- [[ your stats and states as they change (numbers: when they move 5% or after a minute; busy ones skipped) ]] --
local NOISY = { Stamina = true, StaminaMax = true, StaminaOut = true, WolfBiteAt = true, FeralFaceTo = true, FeedCan = true, FeedCanPos = true,
    WolfFeed = true, WolfFeedPos = true, HudTrot = true, WalkKMul = true, FeralRewardsReady = true, FeralSurvival = true, FeralSlotPlay = true,
    FeralGoalDbg = true, FeralDbgAnim = true, HudMoveInput = true, HudSprint = true, HudBurst = true, WolfBurst = true, WolfTrot = true,
    WolfRunIntent = true, FeralChatCan = true, FeralChatOthers = true, FeralCamUnder = true, FeralGuardUntil = true }
local function watch_attrs(obj, who)
    local last = {}
    track(obj.AttributeChanged:Connect(function(name)
        if NOISY[name] then return end
        local v = obj:GetAttribute(name)
        local l = last[name]
        if type(v) == "number" and l and type(l.v) == "number" then
            local big = math.abs(v - l.v) >= math.max(1, math.abs(l.v) * 0.05)
            if not big and os.clock() - l.t < 60 then return end
        end
        last[name] = { v = v, t = os.clock() }
        ev("STAT", ("%s.%s = %s"):format(who, name, brief(v)))
    end))
end
watch_attrs(me, "you")
local function watch_char(c)
    if not c then return end
    watch_attrs(c, "animal")
    local h = c:WaitForChild("Humanoid", 10)
    if h then
        local hp = h.Health
        track(h.HealthChanged:Connect(function(v)
            if math.abs(v - hp) >= math.max(h.MaxHealth * 0.03, 0.5) then
                local by = ""
                local newest, t = nil, 0
                for m, b in pairs(S.biters or {}) do
                    if b.t > t then newest, t = b, b.t end
                end
                if v < hp and newest and os.clock() - t < 2 then by = " (by " .. newest.name .. ")" end
                ev("HEALTH", ("%.0f -> %.0f of %.0f%s"):format(hp, v, h.MaxHealth, by))
                hp = v
            end
        end))
        track(h.Died:Connect(function() ev("HEALTH", "died") end))
    end
    track(c.ChildAdded:Connect(function(x) ev("ANIMAL", "+ " .. x.ClassName .. " " .. x.Name) end))
    track(c.ChildRemoved:Connect(function(x) ev("ANIMAL", "- " .. x.ClassName .. " " .. x.Name) end))
end
task.spawn(watch_char, me.Character)
track(me.CharacterAdded:Connect(function(c)
    ev("ANIMAL", "new animal spawned")
    task.spawn(watch_char, c)
end))
track(Players.PlayerAdded:Connect(function(p) ev("PLAYER", p.Name .. " joined (" .. #Players:GetPlayers() .. " here)") end))
track(Players.PlayerRemoving:Connect(function(p) ev("PLAYER", p.Name .. " left") end))
-- [[ once a minute: where you are and how things stand, plus how busy each message kind was ]] --
go(function()
    while S.alive do
        task.wait(60)
        local r = root_part()
        local h = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        local npcs, mice = Workspace:FindFirstChild("FeralNPCs"), Workspace:FindFirstChild("FeralMice")
        ev("SNAPSHOT", ("at %s · hp %s/%s · hunger %s · thirst %s · growth %s · amber %s · phase %s · status %s · players %d · bots near %d · mice %d · fps %.0f"):format(
            r and brief(r.Position) or "?", h and ("%.0f"):format(h.Health) or "?", h and ("%.0f"):format(h.MaxHealth) or "?",
            brief(me.Character and me.Character:GetAttribute("Hunger")), brief(me.Character and me.Character:GetAttribute("Thirst")),
            brief(me.Character and me.Character:GetAttribute("Growth")), brief(me:GetAttribute("Amber")), tostring(S.phase), tostring(S.status),
            #Players:GetPlayers(), npcs and #npcs:GetChildren() or 0, mice and #mice:GetChildren() or 0, 1 / math.max(RunService.Heartbeat:Wait(), 1e-3)))
        local busy = {}
        for key, c in pairs(counts) do
            if c.minute > 0 then
                table.insert(busy, ("%s x%d"):format(key, c.minute))
                c.minute = 0
            end
        end
        table.sort(busy)
        if #busy > 0 then ev("COUNTS", table.concat(busy, " | ")) end
    end
end)

---------------------------------------------------------------- you and your animal

local function hum()
    local c = me.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
-- [[ needs and growth sit on the animal (the character); a few copies sit on the player ]] --
local function cattr(name)
    local c = me.Character
    local v = c and c:GetAttribute(name)
    if v == nil then v = me:GetAttribute(name) end
    return v
end
local function alive()
    local h = hum()
    return h ~= nil and h.Health > 0 and root_part() ~= nil
end
local function species() return tostring(cattr("Species") or me:GetAttribute("FeralAnimal") or "Wolf") end
local function growth() return tonumber(cattr("Growth")) or 0.01 end
local function hunger() return tonumber(cattr("Hunger")) or 100 end
local function thirst() return tonumber(cattr("Thirst")) or 100 end
local function health_pct()
    local h = hum()
    return (h and h.MaxHealth > 0) and h.Health / h.MaxHealth or 0
end
local function root_height()
    local h, r = hum(), root_part()
    return math.max((h and h.HipHeight or 1.4) + (r and r.Size.Y / 2 or 1), 0.2)
end
local function diet()
    local d = "carnivore"
    pcall(function() d = G.Species.get(species()).diet or d end)
    return d
end
local function can_eat(item_diet)
    local d = diet()
    if item_diet == nil or d == "omnivore" then return true end
    if d == "herbivore" then return item_diet == "plant" end
    return item_diet == "meat"
end
local function flat(v) return Vector3.new(v.X, 0, v.Z) end
local function pack_of(x)
    local v = x and x:GetAttribute("FeralPack")
    return (v ~= nil and v ~= "" and v ~= 0 and v ~= false) and v or nil
end
local function packmate(p)
    local a = pack_of(me) or pack_of(me.Character)
    local b = pack_of(p) or pack_of(p.Character)
    return a ~= nil and a == b
end
local function stage_name(g)
    g = tonumber(g) or 1
    if g < 0.34 then return "baby" elseif g < 0.67 then return "young" elseif g < 1 then return "adult" end
    return "elder"
end
S.species, S.growth, S.hunger, S.thirst, S.health_pct, S.alive_now, S.diet = species, growth, hunger, thirst, health_pct, alive, diet

-- [[ the places on the map (the game's MapSpots, or these if it can't be read) ]] --
local SPOTS = {}
do
    local fallback = {
        { "DenHollow", "Den Hollow", -510, 1116 }, { "FernCreek", "Alder Creek", -885, 1044 }, { "BisonFord", "Elk Crossing", -6, 606 },
        { "TheFlats", "Golden Plains", 717, 882 }, { "GoldenWaterhole", "Golden Waterhole", -240, 220 }, { "BeaverPonds", "Beaver Ponds", -546, 60 },
        { "LookoutRock", "Eagle Rock", 711, -105 }, { "WhisperpineWoods", "Pine Woods", -1140, 180 }, { "Frostfall", "Great Falls", 15, -504 },
        { "GlacierLake", "Frost Lake", 30, -990 }, { "HowlingRidge", "Lunar Crest", -600, -1050 }, { "GoatCliffs", "Goat Cliffs", 1215, -855 },
        { "EchoGorge", "Black Ravine", 165, 1620 }, { "LarchMeadow", "Juniper Fields", 932, -642 }, { "StoneBasin", "Granite Basin", -961, -632 },
        { "OldGrowth", "Elder Giants", -1182, 583 }, { "HoodooFlats", "Rattlebone Mesa", 1158, 621 }, { "RedCanyon", "Red Canyon", 839, 1535 },
        { "ReedMarsh", "Tall Marsh", -826, 1996 }, { "MudWallows", "Mudlands", 860, 2110 }, { "Stillwater", "Dead Lagoon", 180, 2142 },
    }
    pcall(function()
        for _, s in ipairs(G.MapSpots.WolfValley) do
            if typeof(s.pos) == "Vector2" then table.insert(SPOTS, { key = s.key, name = s.name or s.key, x = s.pos.X, z = s.pos.Y }) end
        end
    end)
    if #SPOTS == 0 then
        for _, s in ipairs(fallback) do table.insert(SPOTS, { key = s[1], name = s[2], x = s[3], z = s[4] }) end
    end
end
S.SPOTS = SPOTS
local function spot(key)
    for _, s in ipairs(SPOTS) do
        if s.key == key then return s end
    end
    return nil
end
-- [[ where deer and elk live (NPCConfig homes), to look for prey when none is close ]] --
local HERDS = {}
for _, k in ipairs({ "TheFlats", "BisonFord", "FernCreek", "BeaverPonds", "GoldenWaterhole", "EchoGorge", "LarchMeadow", "ReedMarsh" }) do
    local s = spot(k)
    if s then table.insert(HERDS, s) end
end
-- [[ water the game itself points thirsty players to, plus the small ponds (they dry up in a drought) ]] --
local WATER = {}
for _, k in ipairs({ "GoldenWaterhole", "FernCreek", "BisonFord", "BeaverPonds", "StoneBasin", "Frostfall", "GlacierLake", "Stillwater", "ReedMarsh", "MudWallows" }) do
    local s = spot(k)
    if s then table.insert(WATER, { name = s.name, p = Vector3.new(s.x, 0, s.z) }) end
end
for _, w in ipairs({ { "Pine Pool", -1095, -160 }, { "West Pool", -840, 766 }, { "Plains Pond", 720, 882 }, { "Hawk Pool", 768, -285 }, { "Badlands Waterhole", 1013, 950 } }) do
    table.insert(WATER, { name = w[1], p = Vector3.new(w[2], 0, w[3]) })
end
-- [[ animals that fight back hard, and ones not worth biting (quills) ]] --
local DANGER = { Wolf = true, Cougar = true, Bear = true, Tiger = true, Alligator = true, Python = true, Rhino = true, Komodo = true, Hippo = true,
    Elephant = true, SnowLeopard = true, Gorilla = true, Bison = true }
local SKIP = { Porcupine = true }
S.DANGER = DANGER

---------------------------------------------------------------- moving your animal

-- [[ while S.hold is set your animal is put there every frame (no falling, no sliding). A function is asked again ]] --
-- [[ each frame (to stay behind a running deer, or follow a fish)                                                   ]] --
S.hold = nil
track(RunService.Heartbeat:Connect(function(dt)
    local h = S.hold
    local r = root_part()
    if not r then return end
    if not h then
        S.last_hold_pos = nil
        S.hold_chase = false
        -- [[ just bit something beside or behind you: stay turned to it until the bite lands (moving still works). ]] --
        -- [[ Never while latched on: the game holds you then, and turning you too made you spin.                    ]] --
        local c = me.Character
        local latched = c and (c:FindFirstChild("FeralClamp") or c:FindFirstChild("FeralClampLocal"))
        local fm = S.face_m
        local fr = not latched and fm and os.clock() < S.face_until and fm.Parent and (fm:FindFirstChild("HumanoidRootPart") or fm.PrimaryPart)
        if fr then
            local at = r.Position
            local f = Vector3.new(fr.Position.X - at.X, 0, fr.Position.Z - at.Z)
            if f.Magnitude > 0.2 then r.CFrame = CFrame.lookAt(at, at + f.Unit) end
        end
        return
    end
    local ok, cf = pcall(function()
        if type(h) == "function" then return h() end
        return h
    end)
    if not ok or typeof(cf) ~= "CFrame" then return end
    -- [[ not where we put you last frame: the server pulled you back (see the snap-back guard) ]] --
    -- [[ sideways only: underground, the ground pushes you up every frame, and that isn't the server (run 7: 146 ]] --
    -- [[ false pull-backs in 7 minutes dropped the tween speed to 30)                                          ]] --
    local was_under = S.underground or os.clock() - S.last_under_t < 1
    if not was_under and S.last_hold_pos and flat(r.Position - S.last_hold_pos).Magnitude > 10 and S.on_snap then S.on_snap(true) end
    S.self_moved_t = os.clock()
    -- [[ chasing (hunting, leap, follow, attack): you run after it at a chase speed, never jump onto it ]] --
    if S.hold_chase then
        local from = S.last_hold_pos or r.Position
        local delta = cf.Position - from
        local step = math.max(S.chase_speed, 20) * math.clamp(dt, 0, 0.1)
        if delta.Magnitude > step then cf = CFrame.new(from + delta.Unit * step) * cf.Rotation end
    end
    S.last_hold_pos = cf.Position
    r.CFrame = cf
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
end))

-- [[ the ground under a point: terrain or anything solid (leaves and see-through parts are skipped) ]] --
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Exclude
local ray_t = -100
local function down(x, z, water)
    if os.clock() - ray_t > 2 then
        ray_t = os.clock()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then table.insert(list, p.Character) end
        end
        for _, n in ipairs({ "FeralNPCs", "FeralMice", "FeralLinger", "FeralAmberChunks", "FeralDens" }) do
            local f = Workspace:FindFirstChild(n)
            if f then table.insert(list, f) end
        end
        local plat = S.afk_part and S.afk_part()
        if plat then table.insert(list, plat) end
        ray.FilterDescendantsInstances = list
    end
    ray.IgnoreWater = not water
    local y = 900
    for _ = 1, 8 do
        local hit = Workspace:Raycast(Vector3.new(x, y, z), Vector3.new(0, -(y + 600), 0), ray)
        if not hit then return nil end
        local inst = hit.Instance
        if inst:IsA("Terrain") or (inst:IsA("BasePart") and inst.CanCollide and inst.Transparency < 0.9) then return hit end
        y = hit.Position.Y - 0.05
    end
    return nil
end
local function stand_cf(pos, look)
    local y = pos.Y + root_height() + 0.05
    local f = look and flat(look) or Vector3.zero
    if f.Magnitude < 0.05 then f = Vector3.new(0, 0, -1) end
    local at = Vector3.new(pos.X, y, pos.Z)
    return CFrame.lookAt(at, at + f.Unit)
end
-- [[ put your animal there for a moment, then let go (it stands on its own, the game's controller is idle) ]] --
local function place(cf)
    S.hold_chase = false
    S.hold = cf
    task.wait(0.12)
    S.hold = nil
end

local function nearest_player(pos)
    local best, bd = nil, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= me and not packmate(p) then
            local c = p.Character
            local pr = c and c:FindFirstChild("HumanoidRootPart")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if pr and h and h.Health > 0 then
                local d = (pr.Position - pos).Magnitude
                if not bd or d < bd then best, bd = p, d end
            end
        end
    end
    return best, bd
end
local function near_player(pos, dist)
    if dist <= 0 then return false end
    local _, d = nearest_player(pos)
    return d ~= nil and d < dist
end
S.nearest_player = nearest_player

-- [[ your sprint's top speed (the game's own formula), to glide at a pace that looks like running ]] --
local function top_speed(model, burst)
    local sp = model:GetAttribute("Species") or "Wolf"
    local g = tonumber(model:GetAttribute("Growth")) or 1
    local base = 40
    pcall(function() base = G.Species.scaled(sp, "speed", g) end)
    local scale = tonumber(model:GetAttribute("SpeedScale")) or tonumber(model:GetAttribute("MoveScale")) or 1
    local o = env.sobriety_feral_orig or {}
    return base * scale * (o.RUN_SPEED or 0.9) * (burst and (o.BURST or 1.68) or 1)
end
S.top_speed = top_speed

-- [[ goes to (x, z) and stands on the ground there. Gliding follows the ground at a running pace (the map streams in ]] --
-- [[ as you go). Low profile: never faster than your own sprint when another player is close, and never Instant.     ]] --
local function travel(x, z, keep, water, instant, deep)
    keep = keep or function() return S.alive end
    local r = root_part()
    if not r then return false end
    local natural = me.Character and top_speed(me.Character, true) * 1.05 or 60
    local function pace()
        if instant then return 0 end
        local sp = S.travel_speed
        if sp == 1 then sp = natural end
        if S.slow_near then
            if sp == 0 then sp = 160 end
            local rr = root_part()
            if rr and near_player(rr.Position, 250) then sp = math.min(sp, natural) end
        end
        -- [[ never faster than the server has shown it accepts (the snap-back guard lowers this) ]] --
        if sp > 0 then sp = math.min(sp, S.travel_cap) end
        S.last_pace = sp
        return sp
    end
    local goal = Vector3.new(x, 0, z)
    local look = flat(goal - r.Position)
    S.hold_chase = false
    if pace() == 0 then
        -- [[ Instant: wait above the spot until the server has sent its ground, then stand on it ]] --
        local hover = Vector3.new(x, math.max(r.Position.Y, 320), z)
        pcall(function() me:RequestStreamAroundAsync(Vector3.new(x, r.Position.Y, z), 4) end)
        S.hold = CFrame.new(hover)
        local t0, hit = os.clock(), nil
        while keep() and os.clock() - t0 < 8 do
            hit = down(x, z, water)
            if hit then break end
            task.wait(0.2)
        end
        if not hit then
            S.hold = nil
            return false
        end
        place(stand_cf(hit.Position, look))
        return true
    end
    local cur = r.Position
    local y = cur.Y
    local t0 = os.clock()
    local limit = flat(goal - cur).Magnitude / math.max(natural, 20) + 25
    local waited, paused = 0, 0
    local status0 = S.status
    while keep() and os.clock() - t0 < limit + paused do
        local f = flat(goal - cur)
        local d = f.Magnitude
        if d < 1.5 then break end
        local dt = task.wait()
        -- [[ someone close (low profile): stand still on the ground until they've gone, or keep going underground ]] --
        -- [[ (a player who stays more than 90 s gets the underground way anyway)                                    ]] --
        local seen = not instant and not deep and S.low_profile and near_player(cur, S.watch_dist)
        local under = deep or S.travel_under or (seen and (S.near_mode == "Under" or paused > 90))
        if seen and not under then
            paused += dt
            S.status = "waiting: a player is close"
            local g = down(cur.X, cur.Z, water)
            if g then S.hold = stand_cf(g.Position, f) end
            S.underground = false
            continue
        end
        if paused > 0 then S.status = status0 end
        local sp_now = pace()
        local nxt = cur + f.Unit * math.min(d, sp_now * dt)
        local hit = down(nxt.X, nxt.Z, water)
        if hit then
            waited = 0
            -- [[ deep enough that nothing above can bite you (the server allows 2.5x both legs' heights apart) ]] --
            y = under and (hit.Position.Y - root_height() - (deep and 13 or 9)) or (hit.Position.Y + root_height() + 0.05)
        else
            -- [[ the ground here hasn't streamed in yet: wait for it (a little), then carry on at the same height ]] --
            waited += dt
            if waited < 2.5 then
                S.hold = CFrame.lookAt(cur, cur + f.Unit)
                continue
            end
        end
        if under and not S.underground then ev("MOVE", "going underground (" .. (seen and "a player is close" or "always underground") .. ")") end
        S.underground = under
        if under then S.last_under_t = os.clock() end
        -- [[ up and down no faster than 1.5x the glide (a 500-stud drop in one frame is a teleport to the server) ]] --
        local vmax = math.max(sp_now, 60) * 1.5 * dt
        y = cur.Y + math.clamp(y - cur.Y, -vmax, vmax)
        cur = Vector3.new(nxt.X, y, nxt.Z)
        S.hold = CFrame.lookAt(cur, cur + f.Unit)
    end
    S.underground = false
    local hit = down(x, z, water)
    -- [[ arrived above (or below) the ground: down / up to it at the same capped rate, then stand ]] --
    if hit and flat(goal - cur).Magnitude < 3 then
        local stand_y = hit.Position.Y + root_height() + 0.05
        local f = look.Magnitude > 0.05 and look.Unit or Vector3.new(0, 0, -1)
        while keep() and math.abs(cur.Y - stand_y) > 3 do
            local dt = task.wait()
            local vmax = math.max(S.last_pace or 60, 60) * 1.5 * dt
            cur = Vector3.new(cur.X, cur.Y + math.clamp(stand_y - cur.Y, -vmax, vmax), cur.Z)
            S.hold = CFrame.lookAt(cur, cur + f)
        end
        place(stand_cf(hit.Position, look))
    else
        S.hold = nil
    end
    return keep() and flat(goal - cur).Magnitude < 3
end
S.travel = travel

-- [[ Never left in the ground, never through the map (run 4: let go while underground, you fell off the map). When ]] --
-- [[ nothing holds you and you're below the ground right after being down there (or falling fast below it, or under ]] --
-- [[ the map), you're put back on the surface above you (or the last ground you stood on).                         ]] --
go(function()
    while S.alive do
        task.wait(0.15)
        local r, h = root_part(), hum()
        if r and h and h.Health > 0 then
            if S.underground then S.last_under_t = os.clock() end
            local c = me.Character
            local ghost = S.underground or os.clock() - S.last_under_t < 0.3
            if c and ghost ~= S.noclip then
                S.noclip = ghost
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if ghost then
                            if part.CanCollide then
                                part:SetAttribute("SobrietyCollide", true)
                                part.CanCollide = false
                            end
                        elseif part:GetAttribute("SobrietyCollide") then
                            part:SetAttribute("SobrietyCollide", nil)
                            part.CanCollide = true
                        end
                    end
                end
            end
            if not S.hold then
                local g = down(r.Position.X, r.Position.Z, false)
                local below = g ~= nil and r.Position.Y < g.Position.Y - 0.5
                local recent = os.clock() - S.last_under_t < 4
                local falling = r.AssemblyLinearVelocity.Y < -60
                if (below and (recent or falling)) or r.Position.Y < -150 then
                    local spot = (g and g.Position) or S.last_surface
                    if spot then
                        place(stand_cf(spot, r.CFrame.LookVector))
                        r.AssemblyLinearVelocity = Vector3.zero
                        ev("SAFE", "brought back up out of the ground")
                    end
                elseif not below and h.FloorMaterial ~= Enum.Material.Air then
                    S.last_surface = r.Position - Vector3.new(0, root_height(), 0)
                end
            end
        end
    end
end)

---------------------------------------------------------------- speed, stamina, no slowdown when hurt
-- [[ The game's own movement settings (NeedsConfig, AbilityConfig, StatusConfig) are read by your animal's controller ]] --
-- [[ every frame, on your side only. Changing them here makes the game itself move you faster, never drain stamina, ]] --
-- [[ and ignore low health / injuries. The first values ever seen are kept in env, so a re-run never stacks.         ]] --
local PATCH = { needs = {}, ability = {}, status = {}, species = {}, ready = false }
local NO_HOBBLE = function() return false end
local function add_unique(list, t)
    if type(t) == "table" and not table.find(list, t) then table.insert(list, t) end
end
local function set_field(t, k, v)
    if rawget(t, k) == v then return end
    if not pcall(function() t[k] = v end) then
        local sro = exec("setreadonly") or exec("make_writeable")
        if typeof(sro) == "function" then
            pcall(sro, t, false)
            pcall(function() t[k] = v end)
        end
    end
end
go(function()
    add_unique(PATCH.needs, G.NeedsConfig)
    add_unique(PATCH.ability, G.AbilityConfig)
    add_unique(PATCH.status, G.StatusConfig)
    add_unique(PATCH.species, G.Species)
    -- [[ the copies the game's scripts hold (an executor's require can hand back a copy of its own) ]] --
    local gc = exec("getgc")
    if typeof(gc) == "function" then
        local ok, list = pcall(gc, true)
        if ok and type(list) == "table" then
            for i, t in ipairs(list) do
                if type(t) == "table" then
                    if rawget(t, "HURT_SLOW") ~= nil and rawget(t, "STAMINA_SPRINT_DRAIN") ~= nil then add_unique(PATCH.needs, t)
                    elseif rawget(t, "SPECIES") ~= nil and type(rawget(t, "Lunge")) == "table" then add_unique(PATCH.ability, t)
                    elseif type(rawget(t, "INJURY")) == "table" and rawget(rawget(t, "INJURY"), "SLOW_PER_POINT") ~= nil then add_unique(PATCH.status, t)
                    elseif type(rawget(t, "List")) == "table" and type(rawget(t, "biteCooldown")) == "function" then add_unique(PATCH.species, t) end
                end
                if i % 20000 == 0 then task.wait() end
            end
        end
    end
    if not env.sobriety_feral_orig then
        local o = {}
        local n, a, s = PATCH.needs[1], PATCH.ability[1], PATCH.status[1]
        if n then
            o.RUN_SPEED, o.HURT_SLOW, o.DRAIN = rawget(n, "RUN_SPEED"), rawget(n, "HURT_SLOW"), rawget(n, "STAMINA_SPRINT_DRAIN")
            o.SWIM, o.WADE = rawget(n, "SWIM_SPEED"), rawget(n, "WATER_NO_SPRINT_DEPTH")
            local b = rawget(n, "BURST")
            o.BURST = type(b) == "table" and b.SPEED or 1.68
        end
        if a then
            o.hobbled = rawget(a, "hobbled")
        end
        if s then o.INJ = rawget(rawget(s, "INJURY"), "SLOW_PER_POINT") end
        env.sobriety_feral_orig = o
    end
    PATCH.ready = true
    logf("START", ("movement settings found: %d needs, %d ability, %d status, %d species table(s)"):format(#PATCH.needs, #PATCH.ability,
        #PATCH.status, #PATCH.species))
end)
-- [[ Your four speeds, each with its own multiplier, through the game's own settings (so its controller moves you):   ]] --
-- [[   walk = 7 x WalkKMul x gait      trot (Z) = 16.8 x gait      run (Shift) = speed x RUN_SPEED      X = run x BURST ]] --
-- [[ gait is your species' own number (List[sp].gait); trot gets it, walk gets walk/trot through WalkKMul.          ]] --
-- [[ Swimming as fast as running: your species gets swim speeds like the swimmers (otters, gators) set to your run    ]] --
-- [[ and X. Everything is put back when off, on Unload, or when you switch animals.                                ]] --
local function each_entry(sp, fn)
    for _, t in ipairs(PATCH.species) do
        local list = rawget(t, "List")
        local e = type(list) == "table" and list[sp]
        if type(e) == "table" then fn(e) end
    end
end
local function patch_species(sp, on, trot, run_top, burst_top)
    local o = env.sobriety_feral_orig
    if not o then return end
    o.swim, o.gait, o.turn = o.swim or {}, o.gait or {}, o.turn or {}
    each_entry(sp, function(e)
        if o.swim[sp] == nil then o.swim[sp] = { e.swimSpeed or false, e.swimSprint or false } end
        if o.gait[sp] == nil then o.gait[sp] = e.gait or false end
        if o.turn[sp] == nil then o.turn[sp] = e.turnMul or false end
        -- [[ instant turn: the game's own turn rate for your species, 40x (you face where you go at once) ]] --
        if on and S.instant_turn then set_field(e, "turnMul", (o.turn[sp] or 1) * 40) else set_field(e, "turnMul", o.turn[sp] or nil) end
        local was, g0 = o.swim[sp], o.gait[sp]
        local base = tonumber(e.speed)
        -- [[ trot (and walk) ]] --
        if on and base and trot ~= 1 then set_field(e, "gait", (g0 or base) * trot) else set_field(e, "gait", g0 or nil) end
        -- [[ swimming at your run / X speed ]] --
        if on and base and S.fast_swim then
            set_field(e, "swimSpeed", math.max(base * run_top, was[1] or 0))
            set_field(e, "swimSprint", math.max(base * burst_top, was[2] or 0))
        else
            set_field(e, "swimSpeed", was[1] or nil)
            set_field(e, "swimSprint", was[2] or nil)
        end
    end)
end
-- [[ run and burst are multipliers over the game's run and X speeds ]] --
local function apply_patches(run_mult, burst_mult, off)
    local o = env.sobriety_feral_orig
    if not (PATCH.ready and o) then return end
    local run0, burst0 = o.RUN_SPEED or 0.9, o.BURST or 1.68
    -- [[ endless stamina, all of it (run 6: jumps, lunges and holding on still used it, and running pauses the ]] --
    -- [[ game's regen): those costs go to 0 and regen is instant. Originals kept the first time they're seen.    ]] --
    local n1, a1 = PATCH.needs[1], PATCH.ability[1]
    if n1 and o.JUMP == nil then o.JUMP, o.REGEN, o.REGEN_DELAY = rawget(n1, "STAMINA_JUMP_COST") or false, rawget(n1, "STAMINA_REGEN") or false, rawget(n1, "STAMINA_REGEN_DELAY") or false end
    -- [[ every ability's own cost fields (abilities.md 6.2): the ones a table holds itself; tables that inherit get ]] --
    -- [[ the parent's 0 through the game's own lookup, so they're left alone                                      ]] --
    if a1 and o.ab == nil then
        o.ab = {}
        for name, v in pairs(a1) do
            if type(name) == "string" and type(v) == "table" then
                for _, k in ipairs({ "STAMINA_COST", "HOLD_STAMINA", "DIG_STAMINA" }) do
                    local own = rawget(v, k)
                    if type(own) == "number" then
                        o.ab[name] = o.ab[name] or {}
                        o.ab[name][k] = own
                    end
                end
            end
        end
    end
    -- [[ the wolf's cost was already changed by an older copy this session: its real value was kept then ]] --
    if o.LUNGE_COST and o.ab and o.ab.Lunge then o.ab.Lunge.STAMINA_COST = o.LUNGE_COST end
    local inf = S.inf_stamina and not off
    for _, t in ipairs(PATCH.needs) do
        if o.JUMP then set_field(t, "STAMINA_JUMP_COST", inf and 0 or o.JUMP) end
        if o.REGEN then set_field(t, "STAMINA_REGEN", inf and o.REGEN * 100 or o.REGEN) end
        if o.REGEN_DELAY then set_field(t, "STAMINA_REGEN_DELAY", inf and 0 or o.REGEN_DELAY) end
    end
    for _, t in ipairs(PATCH.ability) do
        for name, fields in pairs(o.ab or {}) do
            local v = rawget(t, name)
            if type(v) == "table" then
                for k, orig in pairs(fields) do set_field(v, k, inf and 0 or orig) end
            end
        end
    end
    for _, t in ipairs(PATCH.needs) do
        if o.RUN_SPEED then set_field(t, "RUN_SPEED", off and run0 or run0 * run_mult) end
        local b = rawget(t, "BURST")
        if type(b) == "table" and o.BURST then set_field(b, "SPEED", off and burst0 or burst0 * burst_mult / run_mult) end
        if o.HURT_SLOW then set_field(t, "HURT_SLOW", (S.no_hurt_slow and not off) and 0 or o.HURT_SLOW) end
        if o.DRAIN then set_field(t, "STAMINA_SPRINT_DRAIN", (S.inf_stamina and not off) and 0 or o.DRAIN) end
        local swim = S.fast_swim and not off
        if o.SWIM then set_field(t, "SWIM_SPEED", swim and 1 or o.SWIM) end
        -- [[ wading: the game stops your sprint in water deeper than this; off = never ]] --
        if o.WADE then set_field(t, "WATER_NO_SPRINT_DEPTH", if swim then false else o.WADE) end
    end
    local sp = species()
    if S.patched_sp and S.patched_sp ~= sp then patch_species(S.patched_sp, false, 1, 1, 1) end
    patch_species(sp, not off, S.trot_now or S.trot_mult, run0 * run_mult, run0 * burst0 * burst_mult)
    S.patched_sp = sp
    for _, t in ipairs(PATCH.status) do
        local inj = rawget(t, "INJURY")
        if type(inj) == "table" and o.INJ then set_field(inj, "SLOW_PER_POINT", (S.no_hurt_slow and not off) and 0 or o.INJ) end
    end
    for _, t in ipairs(PATCH.ability) do
        if o.hobbled then set_field(t, "hobbled", (S.no_hurt_slow and not off) and NO_HOBBLE or o.hobbled) end
    end
end
S.apply_patches = apply_patches

-- [[ Escape: anything faster than you that bit you or is running at you locks your run and X to 20% above its top ]] --
-- [[ speed, and keeps it there until it's really far away (S.escape_far). Slower ones never lower your own picks. ]] --
S.biters, S.chasers = {}, {}
S.speed_info = { fastest = 0, name = "-", run = 0, burst = 0 }
local function alive_model(m)
    local h = m.Parent and m:FindFirstChildOfClass("Humanoid")
    return h ~= nil and h.Health > 0 and not m:GetAttribute("FeralDead")
end
go(function()
    while S.alive do
        task.wait(0.1)
        local r = root_part()
        local c = me.Character
        local fastest, name = 0, "-"
        local function follow(list, forget_after)
            for m, b in pairs(list) do
                local mr = m:FindFirstChild("HumanoidRootPart")
                local far = not (r and mr) or (mr.Position - r.Position).Magnitude > S.escape_far
                if far or not alive_model(m) or os.clock() - b.t > forget_after then
                    list[m] = nil
                else
                    local v = flat(mr.AssemblyLinearVelocity).Magnitude
                    if v > b.seen and v < b.top * 2.2 then b.seen = v end
                    local top = math.max(b.top, b.seen)
                    if top > fastest then fastest, name = top, b.name end
                end
            end
        end
        -- [[ running at you: players (not your pack) and wild hunters within 70 studs, heading your way ]] --
        if r and S.escape then
            local function check(m, pl)
                local mr = m:FindFirstChild("HumanoidRootPart")
                if not mr or m == c then return end
                local off = flat(r.Position - mr.Position)
                local v = flat(mr.AssemblyLinearVelocity)
                if off.Magnitude < 70 and off.Magnitude > 0.5 and v.Magnitude > 10 and v.Unit:Dot(off.Unit) > 0.6 then
                    local b = S.chasers[m]
                    if not b then
                        local sp = tostring(m:GetAttribute("Species") or m.Name)
                        b = { name = pl and (pl.DisplayName .. "'s " .. sp) or ("a wild " .. sp), top = top_speed(m, pl ~= nil), seen = 0, t = 0 }
                        S.chasers[m] = b
                        ev("CHASE", b.name .. " is running at you")
                    end
                    b.t = os.clock()
                end
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= me and p.Character and not packmate(p) then check(p.Character, p) end
            end
            local npcs = Workspace:FindFirstChild("FeralNPCs")
            if npcs then
                for _, m in ipairs(npcs:GetChildren()) do
                    if DANGER[tostring(m:GetAttribute("Species") or "")] then check(m, nil) end
                end
            end
        end
        follow(S.biters, 180)
        follow(S.chasers, 60)
        local run_top = c and top_speed(c, false) or 0
        local burst_top = c and top_speed(c, true) or 0
        local run_mult, burst_mult = S.run_mult, S.burst_mult
        if S.escape and fastest > 0 and run_top > 0 then
            run_mult = math.max(run_mult, fastest * 1.2 / run_top)
            burst_mult = math.max(burst_mult, fastest * 1.2 / burst_top)
        end
        -- [[ the snap-back guard's cap: the fastest the server has let you go without pulling you back ]] --
        local cap = S.speed_cap
        run_mult, burst_mult = math.min(run_mult, cap), math.min(burst_mult, cap)
        S.trot_now = math.min(S.trot_mult, cap)
        S.speed_info = { fastest = fastest, name = name, run = run_top * run_mult, burst = burst_top * burst_mult, mult = math.max(run_mult, burst_mult) }
        apply_patches(run_mult, burst_mult, false)
        -- [[ auto sprint, locked on whenever you move: Run = the game's own sprint switch (WolfDbgSprint), Burst = that ]] --
        -- [[ plus its burst switch (WolfDbgBurst), Trot = Z pressed for you when you're moving and not trotting       ]] --
        if c then
            local mode = S.auto_gait
            local sprint = (mode == "Run" or mode == "Burst") and true or nil
            local burst = mode == "Burst" and true or nil
            if sprint or S.gait_set then
                if c:GetAttribute("WolfDbgSprint") ~= sprint then pcall(c.SetAttribute, c, "WolfDbgSprint", sprint) end
                if c:GetAttribute("WolfDbgBurst") ~= burst then pcall(c.SetAttribute, c, "WolfDbgBurst", burst) end
                S.gait_set = sprint ~= nil
            end
            local h = c:FindFirstChildOfClass("Humanoid")
            if mode == "Trot" and h and flat(h.MoveDirection).Magnitude > 0.1 and c:GetAttribute("WolfTrot") ~= true and os.clock() - S.trot_press_t > 1.5 then
                S.trot_press_t = os.clock()
                if S.press then S.press(Enum.KeyCode.Z) end
            end
        end
        -- [[ the game's own "no stamina" switch (it skips the hold, flight and venom drains when it's set) ]] --
        if c then
            if S.inf_stamina then
                if c:GetAttribute("WolfDbgNoStamina") ~= true then pcall(c.SetAttribute, c, "WolfDbgNoStamina", true) end
                S.nostam_set = true
            elseif S.nostam_set then
                pcall(c.SetAttribute, c, "WolfDbgNoStamina", nil)
                S.nostam_set = false
            end
        end
        -- [[ walking: walk / trot through WalkKMul (trot is already in the gait) ]] --
        if c then
            local k = math.min(S.walk_mult, cap) / S.trot_now
            local want = math.abs(k - 1) > 0.001 and k or nil
            if want or S.walk_set then
                if c:GetAttribute("WalkKMul") ~= want then pcall(c.SetAttribute, c, "WalkKMul", want) end
                S.walk_set = want ~= nil
            end
        end
    end
end)

-- [[ Snap-back guard. The server pulls you back when you move faster than it allows. The hub notices (you land back ]] --
-- [[ where you were a moment ago), lowers your speeds (or the travel pace) 15% at a time to the fastest the server  ]] --
-- [[ accepts, and tries 5% faster again after each minute without one.                                             ]] --
function S.on_snap(travelling)
    if not S.snap_guard or os.clock() - S.snap_t < 1 then return end
    S.snap_t = os.clock()
    S.snaps += 1
    if travelling then
        local floor = math.max(45, (me.Character and top_speed(me.Character, true) or 60) * 1.15)
        S.travel_cap = math.max(floor, math.min(S.travel_cap, S.last_pace or 100) * 0.85)
        logf("MOVE", ("the server pulled you back while travelling: travel pace lowered to %.0f"):format(S.travel_cap))
    else
        S.speed_cap = math.max(1, math.min(S.speed_cap, S.speed_info.mult or 1) * 0.85)
        logf("MOVE", ("the server pulled you back: speeds held at x%.2f (its limit)"):format(S.speed_cap))
    end
    ev("SNAP", ("pulled back #%d (travelling %s, speed cap x%.2f, travel cap %.0f)"):format(S.snaps, tostring(travelling), S.speed_cap, S.travel_cap))
end
do
    local hist = {}
    local last_up = os.clock()
    track(RunService.Heartbeat:Connect(function(dt)
        local r, h = root_part(), hum()
        if not (r and h) then
            table.clear(hist)
            return
        end
        local now_t, pos = os.clock(), r.Position
        local prev = hist[#hist]
        -- [[ a jump much bigger than your speed allows, not made by the hub, landing where you were a moment ago ]] --
        if prev and not S.hold and S.snap_guard and os.clock() - S.self_moved_t > 1 then
            local jump = (pos - prev.p).Magnitude
            if jump > h.WalkSpeed * math.max(dt, 1 / 60) * 3 + 8 then
                for i = #hist - 1, 1, -1 do
                    local e = hist[i]
                    if now_t - e.t > 0.15 and (pos - e.p).Magnitude < 5 then
                        S.on_snap(false)
                        table.clear(hist)
                        break
                    end
                end
            end
        end
        table.insert(hist, { t = now_t, p = pos })
        while #hist > 0 and now_t - hist[1].t > 3 do table.remove(hist, 1) end
        if now_t - last_up > 60 then
            last_up = now_t
            if now_t - S.snap_t > 60 then
                if S.speed_cap < 99 then S.speed_cap = S.speed_cap * 1.05 >= 4 and 99 or S.speed_cap * 1.05 end
                if S.travel_cap < 999 then S.travel_cap = S.travel_cap * 1.05 >= 300 and 999 or S.travel_cap * 1.05 end
            end
        end
    end))
end

-- [[ speed lock: you always move at the speed the game's controller is aiming for (WalkSpeed, which already has ]] --
-- [[ your speed pick in it). Uphill or on sticky ground the physics falls short: the missing distance is added    ]] --
-- [[ along the slope. Never into walls (anything steeper than ~70 degrees in front stops it).                     ]] --
do
    local last_pos = nil
    local wall_ray = RaycastParams.new()
    wall_ray.FilterType = Enum.RaycastFilterType.Exclude
    track(RunService.Heartbeat:Connect(function(dt)
        local r, h = root_part(), hum()
        if not (S.speed_lock and r and h) or S.hold or dt <= 0 then
            last_pos = nil
            return
        end
        local pos = r.Position
        local md = flat(h.MoveDirection)
        local want = h.WalkSpeed
        -- [[ in water (swimming, or wading deep): the game drops your X and swims you slower; you keep your run speed, ]] --
        -- [[ or your X speed when X was on (or you press X in the water). Z in the water never slows you either.        ]] --
        local swimming = h:GetState() == Enum.HumanoidStateType.Swimming or h.FloorMaterial == Enum.Material.Water
        if swimming and S.fast_swim then
            want = math.max(want, (S.water_burst or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) and S.speed_info.burst or S.speed_info.run)
        else
            S.water_burst = me:GetAttribute("HudBurst") == true
        end
        if last_pos and md.Magnitude > 0.1 and want > 2 and (h.FloorMaterial ~= Enum.Material.Air or swimming) then
            local moved = flat(pos - last_pos).Magnitude / dt
            local missing = math.min(want - moved, want * (swimming and 0.9 or 0.6))
            if missing > 0.8 then
                local dir = md.Unit
                local step = dir * missing * dt
                wall_ray.FilterDescendantsInstances = { me.Character }
                local ahead = Workspace:Raycast(pos, dir * (r.Size.Z * 0.5 + step.Magnitude + 1), wall_ray)
                if not ahead or ahead.Normal.Y > 0.34 then
                    -- [[ the slope under the step: rise with it so the step goes up the hill, not into it ]] --
                    local under = Workspace:Raycast(pos + step + Vector3.new(0, 2, 0), Vector3.new(0, -(root_height() + 6), 0), wall_ray)
                    local rise = 0
                    if under and under.Normal.Y > 0.34 then rise = math.max(-step:Dot(under.Normal) / under.Normal.Y, 0) end
                    r.CFrame += step + Vector3.new(0, rise, 0)
                    pos = r.Position
                end
            end
        end
        last_pos = pos
    end))
end
-- [[ the game's own slows on your animal (being held or dragged, limping, slow-motion): ignored while speed is locked ]] --
go(function()
    local SLOWS = { "FeralClampSlow", "FeralDragSlow", "FeralHobbleSlow", "FeralSlowMo" }
    while S.alive do
        task.wait(0.1)
        local c = me.Character
        if c and S.speed_lock then
            for _, a in ipairs(SLOWS) do
                if c:GetAttribute(a) ~= nil then pcall(c.SetAttribute, c, a, nil) end
            end
        end
    end
end)

---------------------------------------------------------------- what the server tells you

S.feed_stop = nil
if R.WolfActions then
    track(R.WolfActions.OnClientEvent:Connect(function(kind, reason)
        if kind == "FeedStop" then S.feed_stop = tostring(reason or "stop") end
    end))
end
if R.FeralHit then
    track(R.FeralHit.OnClientEvent:Connect(function(kind, d)
        if kind ~= "hit" or type(d) ~= "table" then return end
        local c = me.Character
        if not c then return end
        local a, v = d.a, d.v
        if v == c and typeof(a) == "Instance" and a ~= c and a:IsA("Model") then
            local b = S.biters[a]
            if not b then
                local pl = Players:GetPlayerFromCharacter(a)
                local sp = tostring(a:GetAttribute("Species") or a.Name)
                b = { name = pl and (pl.DisplayName .. "'s " .. sp) or ("a wild " .. sp), top = top_speed(a, pl ~= nil), seen = 0, t = 0 }
                S.biters[a] = b
                logf("BITTEN", ("%s bit you (its top speed is about %.0f, your X now %.0f)"):format(b.name, b.top, S.speed_info.burst))
            end
            b.t = os.clock()
            S.last_bitten = os.clock()
            -- [[ found and bitten while travelling underground: away at once ]] --
            if S.underground and S.get_away then S.get_away("bitten by " .. b.name .. " while underground: getting away") end
        elseif a == c then
            S.hits += 1
            if S.pace_fast_now then S.fast_hits += 1 else S.norm_hits += 1 end
            if typeof(v) == "Instance" and S.is_bird and S.is_bird(v) then S.bird_hits += 1 end
            if v == S.clamp_prey then S.latch_hits += 1 end
        end
    end))
end
track(me:GetAttributeChangedSignal("FeralKillNote"):Connect(function()
    S.kills += 1
    local note = tostring(me:GetAttribute("FeralKillNote") or ""):gsub("#%d+$", "")
    S.last_kill = note
    logf("KILL", note .. " killed")
end))
if R.FeralPlaces then
    track(R.FeralPlaces.OnClientEvent:Connect(function(kind, name, first, amount)
        if kind ~= "place" then return end
        S.found[tostring(name)] = true
        if first then logf("AMBER", ("found %s: +%s amber"):format(tostring(name), tostring(amount or 20))) end
    end))
end
if R.FeralQuests then
    track(R.FeralQuests.OnClientEvent:Connect(function(kind, s)
        if kind == "state" and type(s) == "table" then
            S.quests = s
        elseif kind == "done" then
            S.quests_done += 1
            logf("QUEST", "quest done (the server paid it)")
        end
    end))
    task.spawn(fire, "FeralQuests", "hello")
end
if R.FeralRewards then
    track(R.FeralRewards.OnClientEvent:Connect(function(kind, t, i)
        if kind == "state" and type(t) == "table" then
            S.rew, S.rew_t = t, os.clock()
        elseif kind == "paid" then
            S.claims += 1
            logf("REWARD", ("%s reward claimed%s"):format(tostring(t), i and (" (" .. tostring(i) .. ")") or ""))
        end
    end))
end
if R.FeralDeath then
    track(R.FeralDeath.OnClientEvent:Connect(function(kind, info)
        if kind == "dead" and type(info) == "table" then
            S.deaths += 1
            S.hold = nil
            local free = info.free == true
            if S.discord then
                local killer = tostring(info.killerName or info.killer or "?")
                local by = info.cause == "killed" and ("killed by **%s** (%s)"):format(killer, tostring(info.killer or "?"))
                    or ("died of **%s**"):format(tostring(info.cause or "?"))
                S.discord("death", "You died", ("%s\nGrowth %d%%  ·  %s kills this life  ·  %s"):format(by, math.floor((tonumber(info.g) or 0) * 100),
                    tostring(info.kills or "?"), free and "your free revive is ready" or (info.canRevive and "a bought revive is ready" or "no revive")), 0xE5484D)
            end
            logf("DEATH", ("you died (%s)%s"):format(tostring(info.killerName or info.cause or "?"),
                free and ": your free revive is ready" or (info.canRevive and (": %s bought revive(s) left (never used by the hub)"):format(tostring(info.credits or 0)) or "")))
            -- [[ only the free revive, and only if you turned it on: bought revives are never spent by the hub ]] --
            if S.revive_free and free then
                task.delay(2 + math.random() * 2, function()
                    if S.alive and not alive() then
                        fire("FeralDeath", "credit")
                        logf("DEATH", "used your free revive: you keep your growth")
                    end
                end)
            end
        elseif kind == "revive" then
            logf("DEATH", "revive: " .. tostring(info))
        end
    end))
end
S.amber0 = tonumber(me:GetAttribute("Amber")) or 0
-- [[ Revive now (the button): on the death screen, uses your revive (the free one if you have it, else a bought one) ]] --
function S.revive_now()
    local h = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
    if h and h.Health > 0 and not me:GetAttribute("FeralDeathScreen") then
        notify("You're alive: Revive now works on the death screen.")
        return
    end
    fire("FeralDeath", "credit")
    logf("DEATH", "revive asked for (the button)")
end

---------------------------------------------------------------- biting

local function bite_cd()
    local cd = 0.75
    pcall(function() cd = G.Species.biteCooldown(species(), growth()) end)
    -- [[ bite speed: the game's pace divided by your pick, once 10 bites at the game's pace have set the baseline ]] --
    S.pace_fast_now = S.bite_speed > 1 and S.fast_state ~= -1 and S.norm_sent >= 10
    if S.pace_fast_now then cd /= S.bite_speed end
    S.cur_cd = cd + 0.02
    return cd + 0.02
end
S.bite_cd = bite_cd
-- [[ a faster bite speed keeps going only while it lands as often as the game's pace did (else the server caps it) ]] --
local function check_pace()
    if S.fast_state ~= 0 or S.fast_sent < 20 or S.norm_sent < 10 then return end
    local fr, nr = S.fast_hits / S.fast_sent, S.norm_hits / math.max(S.norm_sent, 1)
    -- [[ more bites a second only pay if hits a second go up: landed share x speed must beat the game's pace ]] --
    if fr * S.bite_speed < nr * 1.05 then
        S.fast_state = -1
        logf("HUNT", ("x%g bites land %.0f%% of the time vs %.0f%% at the game's pace: the server caps it, back to the game's pace"):format(S.bite_speed, fr * 100, nr * 100))
    else
        S.fast_state = 1
        logf("HUNT", ("x%g bites land (%.0f%%): keeping them"):format(S.bite_speed, fr * 100))
    end
end
-- [[ the game's bite: "Bite" with the server time, then 0.27 s later "BiteHit" naming the target (mice: "Bite" only) ]] --
local function bite(target, mouse)
    local c = me.Character
    if not c then return end
    -- [[ a porcupine with its quills up: biting it means thorns, letting go and a 4 s limp. Wait them out ]] --
    if target and (tonumber(target:GetAttribute("FeralQuillsUntil")) or 0) > now() then return end
    -- [[ one bite clock for everything (hunting, fighting back, fishing), never faster than the pace picked ]] --
    if os.clock() - S.last_bite_t < (S.cur_cd or 0.7) - 0.03 then return end
    S.last_bite_t = os.clock()
    local t = now()
    pcall(c.SetAttribute, c, "WolfBiteAt", t)
    fire("WolfActions", "Bite", t)
    S.bites += 1
    if target and not mouse then
        local fast = S.pace_fast_now
        if fast then S.fast_sent += 1 else S.norm_sent += 1 end
        task.delay(0.27, function()
            if S.alive then fire("WolfActions", "BiteHit", { t = t, m = target }) end
        end)
        check_pace()
    end
end
local function press(key)
    if not VIM or S.vim_failed then return false end
    local ok = pcall(function()
        VIM:SendKeyEvent(true, key, false, game)
        task.wait(0.06)
        VIM:SendKeyEvent(false, key, false, game)
    end)
    -- [[ this executor can't press keys: say so once, and stop trying ]] --
    if not ok then
        S.vim_failed = true
        logf("ERROR", "this executor can't press keys for you: auto lunge and auto trot are off")
    end
    return ok
end
S.press = press
-- [[ the moves that leap onto prey and grab it (abilities.md 1 and 3): the hunt uses yours (F) when it's ready. ]] --
-- [[ Not: birds (talon dive), fox (den), elephant / hippo (their own press), bear stance, red panda, rams,     ]] --
-- [[ charges and timed buffs (they don't grab).                                                              ]] --
local GRAB_MOVES = { Lunge = true, Pounce = true, Takedown = true, Drag = true, Constrict = true, Frenzy = true, VenomLunge = true }
local function ability()
    local ab = nil
    pcall(function() ab = G.AbilityConfig.SPECIES[species()] end)
    return ab
end
S.ability = ability
local function lunge_ready()
    if growth() < 0.34 then return false end
    if not GRAB_MOVES[ability() or ""] then return false end
    return (tonumber(me:GetAttribute("FeralLungeReadyAt")) or 0) <= now()
end
S.lunge_ready = lunge_ready

---------------------------------------------------------------- prey (bots only: never players)

local function target_root(m)
    return m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
end
local function prey_ok(m)
    if not m.Parent or not m:IsA("Model") or m:GetAttribute("FeralDead") then return nil end
    local owner = m:GetAttribute("TutorialOwner")
    if owner and owner ~= me.UserId then return nil end
    local h = m:FindFirstChildOfClass("Humanoid")
    if h and h.Health <= 0 then return nil end
    local r = target_root(m)
    if not r or r.Position.Y < -200 then return nil end
    return r
end
local function pick_prey()
    local r = root_part()
    if not r then return nil, false end
    local best, best_score, best_mouse = nil, nil, false
    local function consider(m, mouse)
        local tr = prey_ok(m)
        if not tr then return end
        if S.failed[m] and os.clock() - S.failed[m] < 90 then return end
        if S.avoid and os.clock() < S.avoid.until_t and (tr.Position - S.avoid.pos).Magnitude < 300 then return end
        local sp = tostring(m:GetAttribute("Species") or m.Name)
        if mouse then
            if S.prey == "Big" then return end
        else
            if SKIP[sp] or S.prey == "Mice" then return end
            if S.prey ~= "Any" and DANGER[sp] then return end
        end
        local d = (tr.Position - r.Position).Magnitude
        if d > (mouse and 1600 or 900) then return end
        -- [[ nobody watching (low profile), and nobody who'd take the kill or bite you ]] --
        if near_player(tr.Position, S.avoid_players and S.avoid_dist or (S.low_profile and 90 or 40)) then return end
        local score = d * (mouse and 1.6 or 1)
        if not best_score or score < best_score then best, best_score, best_mouse = m, score, mouse end
    end
    local mice = Workspace:FindFirstChild("FeralMice")
    if mice then
        for _, m in ipairs(mice:GetChildren()) do consider(m, true) end
    end
    local npcs = Workspace:FindFirstChild("FeralNPCs")
    if npcs then
        for _, m in ipairs(npcs:GetChildren()) do consider(m, m:GetAttribute("FeralMouse") == true) end
    end
    return best, best_mouse
end
-- [[ right behind it, facing it, nose to its tail: bites from behind do 1.25x (the game's flank bonus) ]] --
local function behind(m, extra)
    local my = root_part()
    local tr = prey_ok(m)
    if not (my and tr) then return my and my.CFrame end
    local f = flat(tr.CFrame.LookVector)
    if f.Magnitude < 0.1 then f = Vector3.new(0, 0, -1) end
    f = f.Unit
    local d = tr.Size.Z * 0.5 + my.Size.Z * 0.5 + 0.35 + (extra or 0)
    local th = m:FindFirstChildOfClass("Humanoid")
    local their_h = (th and th.HipHeight or 0.5) + tr.Size.Y / 2
    local y = tr.Position.Y - their_h + root_height()
    local p = tr.Position - f * d
    local at = Vector3.new(p.X, y, p.Z)
    return CFrame.lookAt(at, Vector3.new(tr.Position.X, y, tr.Position.Z))
end

---------------------------------------------------------------- food and water

local function food_items()
    local seen, out = {}, {}
    for _, tag in ipairs({ "FeralFood", "FeralCarcass" }) do
        for _, x in ipairs(CollectionService:GetTagged(tag)) do
            if not seen[x] then
                seen[x] = true
                table.insert(out, x)
            end
        end
    end
    local linger = Workspace:FindFirstChild("FeralLinger")
    if linger then
        for _, x in ipairs(linger:GetChildren()) do
            if not seen[x] then
                seen[x] = true
                table.insert(out, x)
            end
        end
    end
    return out
end
local function food_pos(x)
    local p = x:GetAttribute("FoodPos")
    if typeof(p) == "Vector3" then return p end
    if x:IsA("Model") then
        local cf, size = x:GetBoundingBox()
        return cf.Position + Vector3.new(0, size.Y * 0.25, 0)
    end
    if x:IsA("BasePart") then return x.Position end
    return nil
end
local function food_ok(x)
    if not x.Parent or x:GetAttribute("Consumed") or x:GetAttribute("Fading") or x:GetAttribute("CarriedBy") then return false end
    if (tonumber(x:GetAttribute("FoodLeft")) or 0) <= 0.01 then return false end
    local owner = x:GetAttribute("TutorialOwner")
    if owner and owner ~= me.UserId then return false end
    if S.failed[x] and os.clock() - S.failed[x] < 120 then return false end
    return can_eat(x:GetAttribute("Diet"))
end
local function food_near(pos, radius)
    local best, bd = nil, nil
    for _, x in ipairs(food_items()) do
        if food_ok(x) then
            local p = food_pos(x)
            if p then
                local d = (p - pos).Magnitude
                if d < radius and (not bd or d < bd) and not near_player(p, S.avoid_players and S.avoid_dist or (S.low_profile and 60 or 25)) then best, bd = x, d end
            end
        end
    end
    return best, bd
end
S.food_near = food_near

-- [[ the game's feeding: "Feed" "eat"/"drink" while standing still; the server stops it with FeedStop ]] --
-- [[ The game's own E press (FeralFeedTap): it only feeds once its own finder sees food / water in reach (FeedCan), ]] --
-- [[ walks you the last steps itself and faces it, then sends "Feed". The server refuses a bare "Feed" sent without ]] --
-- [[ that (seen in the logs: FeedStop straight away), so the hub gets you close and lets the game do the rest.      ]] --
local function feed_until(kind, keep, item)
    local get = kind == "drink" and thirst or hunger
    local c = me.Character
    if not c then return false, 0 end
    S.hold = nil
    -- [[ wait until the game itself sees it in reach ]] --
    local t0 = os.clock()
    while keep() and os.clock() - t0 < 3 and c:GetAttribute("FeedCan") ~= kind do task.wait(0.1) end
    local seen = c:GetAttribute("FeedCan") == kind
    local v0 = get()
    S.feed_stop = nil
    if seen then
        me:SetAttribute("FeralFeedTap", os.clock())
    else
        -- [[ the game doesn't see any: the bare request (works only where the server's own check agrees) ]] --
        fire("WolfActions", "Feed", kind)
    end
    local t1, best, rose = os.clock(), v0, false
    while keep() and os.clock() - t1 < 45 do
        task.wait(0.25)
        local v = get()
        if v > best + 0.05 then
            best = v
            rose = true
        end
        if v >= 99.5 then break end
        if S.feed_stop and (not rose or os.clock() - t1 > 1) then break end
        -- [[ the game may walk up to 8 s to the spot first ]] --
        if not rose and os.clock() - t1 > (seen and 10 or 3) then break end
        if item and not food_ok(item) then break end
    end
    -- [[ still feeding (stopped early): the same E press stops it ]] --
    if c:GetAttribute("WolfFeed") then
        if seen then me:SetAttribute("FeralFeedTap", os.clock()) else fire("WolfActions", "Feed", false) end
    end
    if not rose then ev("FEED", ("%s didn't start (the game %s it; server said %s)"):format(kind, seen and "saw" or "didn't see", tostring(S.feed_stop))) end
    return rose, get() - v0
end
S.feed_until = feed_until
local function eat_item(item, keep)
    local fp = food_pos(item)
    local r = root_part()
    if not (fp and r) then return false end
    local rh = root_height()
    local away = flat(r.Position - fp)
    if away.Magnitude < 0.3 then away = Vector3.new(1, 0, 0) end
    local stand = fp + away.Unit * (0.7 * rh)
    if flat(stand - r.Position).Magnitude > 30 then
        S.status = "going to food"
        if not travel(stand.X, stand.Z, keep) then return false end
    end
    local g = down(stand.X, stand.Z, false)
    local gy = g and g.Position.Y or (fp.Y - 0.5)
    place(stand_cf(Vector3.new(stand.X, gy, stand.Z), fp - stand))
    task.wait(0.3)
    S.status = "eating"
    local rose, gained = feed_until("eat", keep, item)
    if rose then
        S.meals += 1
        logf("FOOD", ("ate %s: +%.0f hunger"):format(tostring(item:GetAttribute("Species") or item.Name):lower(), gained))
    else
        S.failed[item] = os.clock()
    end
    return rose
end

-- [[ water: shore points next to water you can drink from (not swimming depth) ]] --
local function water_at(x, z)
    local hit = down(x, z, true)
    return hit, hit and hit.Material == Enum.Material.Water
end
local function find_shore(c)
    local best, best_r = nil, nil
    for i = 0, 23 do
        local a = i / 24 * math.pi * 2
        local dir = Vector3.new(math.cos(a), 0, math.sin(a))
        local prev_w = nil
        for r = 0, 150, 3 do
            local p = c + dir * r
            local hit, w = water_at(p.X, p.Z)
            if hit then
                if prev_w ~= nil and w ~= prev_w then
                    -- [[ narrow the edge down to half a stud ]] --
                    local lo, hi = r - 3, r
                    for _ = 1, 3 do
                        local mid = (lo + hi) / 2
                        local q = c + dir * mid
                        local _, mw = water_at(q.X, q.Z)
                        if mw == prev_w then lo = mid else hi = mid end
                    end
                    local ground_r = w and lo or hi
                    local gp = c + dir * ground_r
                    local gh = down(gp.X, gp.Z, true)
                    if gh and (not best_r or r < best_r) then
                        best_r = r
                        best = { pos = gh.Position, dir = w and dir or -dir }
                    end
                    break
                end
                prev_w = w
            end
        end
    end
    return best
end
-- [[ alligators (and the other water ambushers): wild ones and players. Drinking stays away from them ]] --
local WATER_HUNTERS = { Alligator = true, Hippo = true, Python = true, Komodo = true }
local function gator_near(pos, dist)
    local npcs = Workspace:FindFirstChild("FeralNPCs")
    if npcs then
        for _, m in ipairs(npcs:GetChildren()) do
            if WATER_HUNTERS[tostring(m:GetAttribute("Species") or "")] then
                local tr = prey_ok(m)
                if tr and flat(tr.Position - pos).Magnitude < dist then return tostring(m:GetAttribute("Species")) end
            end
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p ~= me and not packmate(p) and p.Character
        local tr = c and WATER_HUNTERS[tostring(c:GetAttribute("Species") or "")] and c:FindFirstChild("HumanoidRootPart")
        if tr and flat(tr.Position - pos).Magnitude < dist then return p.DisplayName .. "'s " .. tostring(c:GetAttribute("Species")) end
    end
    return nil
end
S.gator_near = gator_near
local function waters_by_distance(pos)
    local list = {}
    local ff = RS:FindFirstChild("FeralFish")
    if ff then
        for i = 1, 80 do
            local c = ff:GetAttribute("c" .. i)
            if typeof(c) == "Vector3" then table.insert(list, { name = "the fishing water", p = c }) end
        end
    end
    for _, w in ipairs(WATER) do table.insert(list, w) end
    -- [[ water with a gator near it goes to the back of the list ]] --
    for _, w in ipairs(list) do
        w.cost = flat(w.p - pos).Magnitude + (gator_near(w.p, 160) and 5000 or 0) + ((S.avoid_players and near_player(w.p, S.avoid_dist)) and 3000 or 0)
    end
    table.sort(list, function(a, b) return a.cost < b.cost end)
    return list
end
local function drink_at_shore(shore, keep)
    local rh = root_height()
    local at = shore.pos - shore.dir * (0.45 * rh)
    place(stand_cf(at, shore.dir))
    -- [[ the game's own check: is there drinkable water in front of the mouth? step closer until there is ]] --
    if G.FeedFinder and G.FeedFinder.water then
        for _ = 1, 6 do
            local c, r = me.Character, root_part()
            local ok, w = pcall(G.FeedFinder.water, c, r, nil, nil, shore.dir)
            if ok and w then break end
            at += shore.dir * 0.4
            place(stand_cf(Vector3.new(at.X, shore.pos.Y, at.Z), shore.dir))
        end
    end
    task.wait(0.3)
    -- [[ a gator comes within 45 studs while drinking: stop and go ]] --
    local function safe()
        local rr = root_part()
        local g = rr and gator_near(rr.Position, 45)
        if g then
            logf("DRINK", g .. " came close: stopped drinking")
            S.gator_seen = os.clock()
        end
        return keep() and not g
    end
    return feed_until("drink", safe)
end
local function drink(keep)
    local r = root_part()
    if not r then return false end
    -- [[ first try right where you stand: if the server doesn't check for water, there are never any trips ]] --
    if S.drink_anywhere >= 0 then
        S.status = "drinking"
        local near_water = false
        if G.FeedFinder and G.FeedFinder.waterAround then
            local ok, w = pcall(G.FeedFinder.waterAround, me.Character, r, nil)
            near_water = ok and w ~= nil
        end
        local rose, gained = feed_until("drink", keep)
        if rose then
            S.drinks += 1
            if not near_water and S.drink_anywhere == 0 then
                S.drink_anywhere = 1
                logf("DRINK", "drinking works from anywhere: no trips to water")
            end
            logf("DRINK", ("drank: +%.0f thirst"):format(gained))
            return true
        end
        if not near_water then
            if S.drink_anywhere ~= -1 then logf("DRINK", "the server wants you at water to drink: going to the nearest water (and back)") end
            S.drink_anywhere = -1
        end
    end
    local back = r.Position
    local tries = 0
    for _, w in ipairs(waters_by_distance(r.Position)) do
        if not keep() or tries >= 4 then break end
        tries += 1
        S.status = "going to drink at " .. w.name
        if travel(w.p.X, w.p.Z, keep, true) then
            local here = root_part()
            local shore = here and find_shore(here.Position)
            -- [[ one turned up there: try the next water ]] --
            local g = shore and gator_near(shore.pos, 90)
            if g then
                logf("DRINK", ("%s at %s: drinking somewhere else"):format(g, w.name))
                shore = nil
            end
            if shore then
                S.status = "drinking at " .. w.name
                local rose, gained = drink_at_shore(shore, keep)
                if rose then
                    S.drinks += 1
                    logf("DRINK", ("drank at %s: +%.0f thirst"):format(w.name, gained))
                    if S.drink_return and flat(back - shore.pos).Magnitude > 120 and keep() then
                        S.status = "going back"
                        travel(back.X, back.Z, keep)
                    end
                    return true
                end
            end
        end
    end
    logf("DRINK", "couldn't find water to drink from (a drought?)")
    return false
end
S.drink = drink

---------------------------------------------------------------- fishing (8 food a fish, no fighting)

local function mouth()
    local c = me.Character
    local r = root_part()
    if not (c and r) then return nil end
    local head = c:FindFirstChild("Head", true)
    if head and head:IsA("Bone") then return head.TransformedWorldCFrame.Position + r.CFrame.LookVector * 0.25 end
    if head and head:IsA("BasePart") then return head.Position + r.CFrame.LookVector * 0.25 end
    return r.Position + r.CFrame.LookVector * r.Size.Z * 0.5
end
local function schools()
    local ff = RS:FindFirstChild("FeralFish")
    local out = {}
    if not ff then return out end
    for i = 1, 80 do
        local c = ff:GetAttribute("c" .. i)
        if typeof(c) == "Vector3" then
            table.insert(out, { i = i, s = { c = c, r = ff:GetAttribute("r" .. i) or 5, n = ff:GetAttribute("n" .. i) or 0,
                speed = ff:GetAttribute("sp" .. i) or 3, dir = ff:GetAttribute("d" .. i) or 1, seed = ff:GetAttribute("seed" .. i) or 1 } })
        end
    end
    return out
end
local function live_fish(sc)
    local ff = RS:FindFirstChild("FeralFish")
    if not ff then return {} end
    local out, t = {}, now()
    for i = 1, sc.s.n do
        if (ff:GetAttribute("e" .. sc.i .. "_" .. i) or 0) <= t then table.insert(out, i) end
    end
    return out
end
local function fish(keep)
    if not (G.FishPath and G.FishPath.at) then return false end
    local eaters = G.FishConfig and G.FishConfig.EATERS
    if eaters and not eaters[species()] then return false end
    local r = root_part()
    if not r then return false end
    local list = schools()
    table.sort(list, function(a, b) return flat(a.s.c - r.Position).Magnitude < flat(b.s.c - r.Position).Magnitude end)
    local sc = nil
    for _, x in ipairs(list) do
        local bad = S.fish_bad_school[x.i] and os.clock() - S.fish_bad_school[x.i] < 180
        if not bad and #live_fish(x) > 0 and not near_player(x.s.c, S.avoid_players and S.avoid_dist or (S.low_profile and 80 or 0)) then
            sc = x
            break
        end
    end
    if not sc then return false end
    S.status = "going fishing"
    if not travel(sc.s.c.X, sc.s.c.Z, keep, true) then return false end
    r = root_part()
    local m0 = mouth()
    if not (r and m0) then return false end
    local rel = r.CFrame:PointToObjectSpace(m0)
    local h0, t0, last, none_t = hunger(), os.clock(), 0, os.clock()
    local ff = RS:FindFirstChild("FeralFish")
    -- [[ a fish not eaten after a bite is skipped for 20 s (run 8: the same fish was tried 75 times); 6 misses in a ]] --
    -- [[ row = this school isn't working, try another one in 3 minutes                                            ]] --
    local skip, misses = {}, 0
    S.status = "fishing"
    while keep() and os.clock() - t0 < 50 and hunger() < 97 do
        local fishes = {}
        for _, i in ipairs(live_fish(sc)) do
            if not (skip[i] and os.clock() - skip[i] < 20) then table.insert(fishes, i) end
        end
        if misses >= 6 then
            S.fish_bad_school[sc.i] = os.clock()
            ev("FISH", ("school %d: 6 bites, no fish eaten; trying elsewhere"):format(sc.i))
            break
        end
        if #fishes == 0 then
            if os.clock() - none_t > 6 then break end
            task.wait(0.3)
        else
            none_t = os.clock()
            local fi = fishes[1]
            local p = G.FishPath.at(sc.s, fi, now() + 0.06)
            local look = flat(G.FishPath.at(sc.s, fi, now() + 0.2) - p)
            if look.Magnitude < 0.05 then look = Vector3.new(0, 0, -1) end
            S.hold = CFrame.lookAt(p, p + look.Unit) * CFrame.new(-rel)
            if os.clock() - last >= bite_cd() then
                last = os.clock()
                S.last_bite_t = last
                task.wait()
                local t = now()
                -- [[ the game's own fishing runs on this too (it eats whatever fish is at your mouth) ]] --
                local c = me.Character
                if c then pcall(c.SetAttribute, c, "WolfBiteAt", t) end
                fire("WolfActions", "Bite", t)
                fire("FeralFishEat", sc.i, fi)
                local h_before = hunger()
                task.wait(0.5)
                if ff and ((ff:GetAttribute("e" .. sc.i .. "_" .. fi) or 0) > now() or hunger() > h_before + 0.5) then
                    S.fish += 1
                    misses = 0
                else
                    skip[fi] = os.clock()
                    misses += 1
                end
            end
            task.wait()
        end
    end
    S.hold = nil
    local gained = hunger() - h0
    if gained > 0.5 then logf("FOOD", ("fished: +%.0f hunger"):format(gained)) end
    return gained > 0.5
end

---------------------------------------------------------------- hunting

-- [[ Where to stand to bite it. Bots run, and the server has them a little further on than your screen shows (the ]] --
-- [[ game draws them 0.135 s late, plus your ping), so you stand behind where it really is: lead_k picks how much  ]] --
-- [[ of that to add, and changes by itself when bites stop landing. Hunting underground: below the ground under it, ]] --
-- [[ as deep as the server's height rule allows (it takes bites up to 2.5x both your legs' heights apart).          ]] --
-- [[ how fast a chase may close in: 25% faster than it runs, at least your own sprint, never past the server's limit ]] --
local function chase_speed(m)
    local tr = m and (m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart)
    local theirs = tr and flat(tr.AssemblyLinearVelocity).Magnitude or 0
    local mine = me.Character and top_speed(me.Character, true) or 60
    return math.min(math.max(theirs * 1.3, mine * 1.1, 30), math.max(S.travel_cap, theirs * 1.35, mine * 1.15))
end
S.chase_speed_of = chase_speed
local LEADS = { 1, 0.5, 0, 1.6 }
local function attack_cf(m, extra)
    local my = root_part()
    local tr = prey_ok(m)
    if not (my and tr) then return my and my.CFrame end
    local th = m:FindFirstChildOfClass("Humanoid")
    local f = flat(tr.CFrame.LookVector)
    if f.Magnitude < 0.1 then f = Vector3.new(0, 0, -1) end
    f = f.Unit
    local ping = 0.1
    pcall(function() ping = me:GetNetworkPing() end)
    local center = tr.Position + flat(tr.AssemblyLinearVelocity) * (LEADS[S.lead_i] * (0.135 + ping))
    local d = math.max(tr.Size.X, tr.Size.Z) * 0.5 + my.Size.Z * 0.5 + 0.3 + (extra or 0)
    local their_hip = th and th.HipHeight or 0.5
    local their_h = their_hip + tr.Size.Y / 2
    -- [[ on the surface at its level (run 4: bites from underground didn't reach, so hunting stays on top) ]] --
    local y = tr.Position.Y - their_h + root_height()
    local p = center - f * d
    local at = Vector3.new(p.X, y, p.Z)
    return CFrame.lookAt(at, Vector3.new(center.X, y, center.Z))
end
S.attack_cf = attack_cf
local function hunt(keep)
    local m, mouse = pick_prey()
    if not m then
        -- [[ nothing streamed in close by: go where the herds live ]] --
        if #HERDS == 0 then return end
        S.herd_i = S.herd_i % #HERDS + 1
        local h = HERDS[S.herd_i]
        S.status = "looking for prey at " .. h.name
        travel(h.x, h.z, keep)
        task.wait(1.5)
        return
    end
    local tr = prey_ok(m)
    if not tr then return end
    local sp = tostring(m:GetAttribute("Species") or m.Name)
    S.status = "hunting a " .. sp:lower()
    S.target = m
    local r = root_part()
    if r and (tr.Position - r.Position).Magnitude > 25 then
        local p = tr.Position
        travel(p.X, p.Z, function() return keep() and prey_ok(m) ~= nil end)
    end
    local note0 = me:GetAttribute("FeralKillNote")
    local start, last_bite, lunge_t = os.clock(), 0, -100
    local hits0, bites0 = S.hits, S.bites
    local tried, last_hits = 1, S.hits
    local where = tr.Position
    local got = false
    while keep() and os.clock() - start < (mouse and 15 or 150) do
        tr = prey_ok(m)
        if not tr or me:GetAttribute("FeralKillNote") ~= note0 then
            got = true
            break
        end
        where = tr.Position
        if S.danger_near() or S.held or S.escaping then break end
        -- [[ bites aren't landing: this one can't be hit from here, try another ]] --
        -- [[ 6 bites with nothing landing: aim a different amount ahead (all 4 tried: give up on this one) ]] --
        if not mouse and S.hits == hits0 and S.bites - bites0 >= 6 * tried then
            if tried >= #LEADS then break end
            tried += 1
            S.lead_i = S.lead_i % #LEADS + 1
            ev("HUNT", ("no bites landing on the %s: aiming %sx ahead now"):format(sp:lower(), tostring(LEADS[S.lead_i])))
        end
        if S.hits > last_hits then
            last_hits = S.hits
            tried = 1
        end
        if mouse and S.bites - bites0 >= 8 then break end
        local c = me.Character
        local clamped = c and c:FindFirstChild("FeralClamp")
        if clamped then
            -- [[ latched on (the game holds you on its back): the latch loop squeezes and bites ]] --
            S.hold = nil
        elseif not mouse and S.auto_lunge and lunge_ready() and os.clock() - lunge_t > 4 and VIM then
            -- [[ the game's own Lunge (F) from a few steps behind it: it leaps, latches on and slows it ]] --
            lunge_t = os.clock()
            S.hold = function() return behind(m, 5) end
            task.wait(0.2)
            S.hold = nil
            press(Enum.KeyCode.F)
            local t0 = os.clock()
            repeat task.wait() until os.clock() - t0 > 1.3 or (me.Character and me.Character:FindFirstChild("FeralClamp"))
        else
            S.chase_speed = chase_speed(m)
            S.hold_chase = true
            S.hold = function() return attack_cf(m, 0) end
            if os.clock() - last_bite >= bite_cd() then
                last_bite = os.clock()
                bite(m, mouse)
            end
        end
        task.wait()
    end
    S.hold = nil
    S.target = nil
    if not got then
        S.failed[m] = os.clock()
        return
    end
    if S.eat_kills and hunger() < 97 and keep() then
        -- [[ the kill turns into food a moment later: stand by it and let the game see it (then its own E) ]] --
        S.status = "eating the kill"
        -- [[ up out of the ground next to it first: eating only works standing on the surface ]] --
        local r0 = root_part()
        local g0 = r0 and down(r0.Position.X, r0.Position.Z, false)
        if g0 then place(stand_cf(g0.Position, flat(where - r0.Position))) end
        local c = me.Character
        local t0 = os.clock()
        while keep() and os.clock() - t0 < 3 and not (c and c:GetAttribute("FeedCan") == "eat") do task.wait(0.15) end
        local ate = false
        if c and c:GetAttribute("FeedCan") == "eat" then
            local rose, gained = feed_until("eat", keep)
            if rose then
                ate = true
                S.meals += 1
                logf("FOOD", ("ate the %s: +%.0f hunger"):format(sp:lower(), gained))
            end
        end
        if not ate then
            local item = food_near(where, 30)
            if item then eat_item(item, keep) else ev("FEED", "no food showed up where the " .. sp:lower() .. " died") end
        end
    end
end

---------------------------------------------------------------- staying alive

local function danger_near()
    local r = root_part()
    if not r then return nil end
    if S.flee_players then
        local p, d = nearest_player(r.Position)
        if p and d and d < S.flee_dist then
            local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            return p.DisplayName, pr and pr.Position or r.Position
        end
    end
    if S.flee_npcs then
        local npcs = Workspace:FindFirstChild("FeralNPCs")
        if npcs then
            for _, m in ipairs(npcs:GetChildren()) do
                if m ~= S.target and DANGER[tostring(m:GetAttribute("Species") or "")] then
                    local tr = prey_ok(m)
                    if tr and (tr.Position - r.Position).Magnitude < 32 then return "a wild " .. tostring(m:GetAttribute("Species")), tr.Position end
                end
            end
        end
    end
    return nil
end
S.danger_near = danger_near
local function flee(keep)
    local who, from = danger_near()
    if not who then return false end
    local r = root_part()
    if not r then return false end
    local best, bd = nil, nil
    for _, s in ipairs(SPOTS) do
        local p = Vector3.new(s.x, 0, s.z)
        if flat(p - from).Magnitude > 500 then
            local d = flat(p - r.Position).Magnitude
            if not bd or d < bd then best, bd = s, d end
        end
    end
    if not best then return false end
    logf("SAFE", ("%s came close: moved away to %s"):format(who, best.name))
    S.status = "moving away from " .. who
    travel(best.x, best.z, keep)
    return true
end
-- [[ Why health is going down. At 0 hunger or thirst the game takes 1% of your health a second: that's not a fight, ]] --
-- [[ so it never sends you to safety (that wouldn't help); it says so and eats or drinks. Bitten in the last 8 s     ]] --
-- [[ (or in a fight) = "bite".                                                                                     ]] --
local function hp_cause()
    if os.clock() - S.last_bitten < 8 or (tonumber(me:GetAttribute("FeralCombatUntil")) or 0) > now() then return "bite" end
    if thirst() <= 1 then return "thirst" end
    if hunger() <= 1 then return "hunger" end
    return nil
end
S.hp_cause = hp_cause
local function rest_heal(keep)
    if not S.rest_heal or health_pct() > 0.45 then return false end
    -- [[ starving or parched: resting won't help, food or water will ]] --
    local cause = hp_cause()
    if cause == "hunger" or cause == "thirst" then return false end
    if (tonumber(me:GetAttribute("FeralCombatUntil")) or 0) > now() then return false end
    if danger_near() then return false end
    fire("WolfActions", "Rest", true)
    S.status = "resting to heal"
    logf("SAFE", ("resting to heal (%d%% health)"):format(math.floor(health_pct() * 100)))
    while keep() and health_pct() < 0.9 and not danger_near() do task.wait(0.5) end
    fire("WolfActions", "Rest", false)
    return true
end

---------------------------------------------------------------- amber: chunks on the old pines, places, quests, rewards

local function chunk_round(keep)
    S.chunk_t = os.clock()
    local f = Workspace:FindFirstChild("FeralAmberChunks")
    if not f then return end
    local r = root_part()
    if not r then return end
    local amber0 = tonumber(me:GetAttribute("Amber")) or 0
    local left = {}
    for _, m in ipairs(f:GetChildren()) do
        if m:IsA("Model") then table.insert(left, m) end
    end
    local pos, visited = r.Position, 0
    while #left > 0 and keep() do
        table.sort(left, function(a, b) return (a:GetPivot().Position - pos).Magnitude < (b:GetPivot().Position - pos).Magnitude end)
        local m = table.remove(left, 1)
        local p = m:GetPivot().Position
        -- [[ someone is close: leave this one for later (low profile) ]] --
        if (S.low_profile or S.avoid_players) and near_player(p, math.max(150, S.avoid_players and S.avoid_dist or 0)) then continue end
        S.status = ("collecting amber (%d trees left)"):format(#left)
        if travel(p.X, p.Z, keep) then
            local t0, drop = os.clock(), nil
            repeat
                drop = m:FindFirstChild("Drop", true)
                if not drop then task.wait(0.2) end
            until drop or os.clock() - t0 > 2 or not keep()
            if drop and drop:IsA("BasePart") and drop.Transparency < 0.95 then
                local here = root_part()
                local rot = here and (here.CFrame - here.Position) or CFrame.identity
                local before = tonumber(me:GetAttribute("Amber")) or 0
                -- [[ from just under the ground below it first (the pickup reaches about 5 studs), then at it ]] --
                local g = S.travel_under and down(drop.Position.X, drop.Position.Z, false)
                if g then
                    S.hold = CFrame.new(drop.Position.X, g.Position.Y - 0.5, drop.Position.Z) * rot
                    task.wait(0.9 + math.random() * 0.4)
                end
                if not g or (tonumber(me:GetAttribute("Amber")) or 0) <= before then
                    S.hold = CFrame.new(drop.Position) * rot
                    task.wait(0.6 + math.random() * 0.5)
                end
                S.hold = nil
                visited += 1
            end
            pos = p
        end
        task.wait(0.2 + math.random() * 0.6)
    end
    local gained = (tonumber(me:GetAttribute("Amber")) or 0) - amber0
    S.chunk_amber += math.max(gained, 0)
    logf("AMBER", ("amber trees: %d chunks picked, +%d amber (they grow back in 10 minutes)"):format(visited, gained))
    S.chunk_t = os.clock()
    -- [[ every tree here is picked: the next server has fresh ones ]] --
    if S.amber_mode and S.hop_amber and keep() then S.hop_due = true end
end
S.chunk_round = chunk_round
local function tour(keep)
    local n = 0
    for _, s in ipairs(SPOTS) do
        if not keep() then return end
        if not (S.found[s.name] or S.found[s.key]) then
            S.status = "exploring " .. s.name
            if travel(s.x, s.z, keep) then
                n += 1
                local t0 = os.clock()
                while keep() and os.clock() - t0 < 4 and not (S.found[s.name] or S.found[s.key]) do task.wait(0.25) end
            end
        end
    end
    S.toured = true
    logf("AMBER", ("explored %d places (20 amber for each one new to you)"):format(n))
end
S.tour = tour
local function quest_spot()
    local s = S.quests
    if type(s) ~= "table" then return nil end
    for _, group in ipairs({ s.quick, s.daily }) do
        if type(group) == "table" then
            for _, q in ipairs(group) do
                if type(q) == "table" and not q.done and (q.k == "visit" or q.k == "explore" or q.k == "drinkAt") and tonumber(q.sx) and tonumber(q.sz) then
                    local id = tostring(q.id or q.t or q.k)
                    if not (S.quest_tried[id] and os.clock() - S.quest_tried[id] < 240) then return q, id end
                end
            end
        end
    end
    return nil
end
S.quest_spot = quest_spot
local function do_quest(q, id, keep)
    S.quest_tried[id] = os.clock()
    S.status = "quest: " .. tostring(q.t or q.k)
    logf("QUEST", "going for: " .. tostring(q.t or q.k))
    local water = q.k == "drinkAt"
    if not travel(q.sx, q.sz, keep, water) then return end
    if water then
        local here = root_part()
        local shore = here and find_shore(here.Position)
        if shore then drink_at_shore(shore, keep) end
    end
    task.wait(3)
    fire("FeralQuests", "hello")
end
-- [[ playtime tiers and the daily streak: claimed a little after they're ready, one at a time ]] --
local PLAY_MIN = { 1, 5, 10, 20, 30, 45, 60 }
pcall(function()
    for i, x in ipairs(G.RewardConfig.PLAYTIME) do PLAY_MIN[i] = tonumber(x.min) or PLAY_MIN[i] end
end)
S.PLAY_MIN = PLAY_MIN
go(function()
    task.wait(8 + math.random() * 6)
    while S.alive do
        if S.rewards and R.FeralRewards then
            pcall(function()
                fire("FeralRewards", "hello")
                task.wait(2 + math.random() * 3)
                local t = S.rew
                if type(t) ~= "table" then return end
                local pt = (tonumber(t.pt) or 0) + (os.clock() - (S.rew_t or os.clock()))
                local pc = type(t.pc) == "table" and t.pc or {}
                for i, m in ipairs(PLAY_MIN) do
                    if not (pc[i] or pc[tostring(i)]) and pt >= m * 60 then
                        fire("FeralRewards", "claim", "play", i)
                        task.wait(1 + math.random() * 2)
                    end
                end
                if t.dailyOn and not t.claimed then fire("FeralRewards", "claim", "daily", nil) end
            end)
        end
        task.wait(55 + math.random() * 20)
    end
end)
go(function()
    while S.alive do
        task.wait(110 + math.random() * 30)
        fire("FeralQuests", "hello")
    end
end)

---------------------------------------------------------------- defence: grabs, fighting back, birds, getting away

-- [[ grabbed (a wolf's latch, a cat riding you, a python, a gator's grip, a bird's talons): the game's own ways out, ]] --
-- [[ sent at their fastest allowed pace: "shake" (latches, holds), "flip" (talons), "getoff" (riders)              ]] --
local function held_now(c)
    local t = now()
    local flip = c:GetAttribute("FeralFlipUntil")
    local held = (tonumber(c:GetAttribute("FeralShakeNeed")) or 0) > 0 or (tonumber(c:GetAttribute("FeralClampN")) or 0) > 0
        or c:GetAttribute("FeralCarried") == true or c:GetAttribute("FeralPinned")
        or (tonumber(c:GetAttribute("FeralHoldUntil")) or 0) > t or (typeof(flip) == "number" and flip > t)
    return held and true or false, typeof(flip) == "number" and flip > t
end
local function char_hp(m)
    local h = m and m:FindFirstChildOfClass("Humanoid")
    return (h and h.MaxHealth > 0) and h.Health / h.MaxHealth or 1
end
-- [[ who is on you: the latest biter close by, else the nearest player or wild hunter within reach ]] --
local function attacker()
    local r = root_part()
    if not r then return nil end
    local best, bt = nil, nil
    for m, b in pairs(S.biters) do
        local mr = m:FindFirstChild("HumanoidRootPart")
        if mr and char_hp(m) > 0 and (mr.Position - r.Position).Magnitude < 16 and (not bt or b.t > bt) then best, bt = m, b.t end
    end
    if best then return best end
    local p, d = nearest_player(r.Position)
    if p and d and d < 9 then return p.Character end
    local npcs = Workspace:FindFirstChild("FeralNPCs")
    if npcs then
        for _, m in ipairs(npcs:GetChildren()) do
            local tr = DANGER[tostring(m:GetAttribute("Species") or "")] and prey_ok(m)
            if tr and (tr.Position - r.Position).Magnitude < 9 then return m end
        end
    end
    return nil
end
S.attacker = attacker
-- [[ the game's bite reach (CombatConfig: half your body + 1.45 legs + 1.2, x1.15), times your pick ]] --
local function bite_reach()
    local r, h = root_part(), hum()
    if not (r and h) then return 3 end
    return (r.Size.Z * 0.5 + h.HipHeight * 1.45 + 1.2) * 1.15 * S.reach_mult
end
S.bite_reach = bite_reach
local function protected(m)
    return m:FindFirstChildOfClass("ForceField") ~= nil or (tonumber(m:GetAttribute("FeralSafeUntil")) or 0) > now() or m:GetAttribute("FeralTut") ~= nil
end
-- [[ birds (eagles, falcons, anything flying): they get a longer reach of their own, all directions, up included ]] --
local function is_bird(m)
    local sp = tostring(m:GetAttribute("Species") or "")
    return sp == "Eagle" or sp == "Falcon" or m:GetAttribute("FeralFly") == true
end
S.is_bird = is_bird
function S.bird_reach() return bite_reach() / S.reach_mult * S.bird_reach_mult end
local function bird_in_reach(r)
    local br = S.bird_reach()
    local best, bd = nil, nil
    local function consider(m, tr)
        if protected(m) or char_hp(m) <= 0 then return end
        local gap = (tr.Position - r.Position).Magnitude - tr.Size.Z * 0.5
        if gap <= br and (not bd or gap < bd) then best, bd = m, gap end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p ~= me and not packmate(p) and p.Character
        local tr = c and is_bird(c) and c:FindFirstChild("HumanoidRootPart")
        -- [[ only a bird that has attacked you (in the last 30 s) ]] --
        local b = c and S.biters[c]
        if tr and b and os.clock() - b.t < 30 then consider(c, tr) end
    end
    local npcs = Workspace:FindFirstChild("FeralNPCs")
    if npcs then
        for _, m in ipairs(npcs:GetChildren()) do
            local tr = is_bird(m) and prey_ok(m)
            local b = S.biters[m]
            if tr and b and os.clock() - b.t < 30 then consider(m, tr) end
        end
    end
    return best
end
function S.aura_target(r)
    -- [[ a bird in its (longer) reach comes first: they're only there for a moment ]] --
    if S.bird_bite then
        local b = bird_in_reach(r)
        if b then return b, false end
    end
    local reach = bite_reach()
    local h = hum()
    local my_hip = h and h.HipHeight or 1
    local best, bg, best_mouse = nil, nil, false
    local function consider(m, tr, mouse)
        if m == me.Character or protected(m) then return end
        local off = tr.Position - r.Position
        local gap = flat(off).Magnitude - tr.Size.Z * 0.5
        local th = m:FindFirstChildOfClass("Humanoid")
        if math.abs(off.Y) > (my_hip + (th and th.HipHeight or 0.5)) * 2.5 then return end
        if gap <= reach and (not bg or gap < bg) then best, bg, best_mouse = m, gap, mouse end
    end
    -- [[ bots: always (prey and mice; wild hunters once they've bitten you) ]] --
    if S.aura_bots then
        for m in pairs(S.biters) do
            local tr = not Players:GetPlayerFromCharacter(m) and m:FindFirstChild("HumanoidRootPart")
            if tr and char_hp(m) > 0 then consider(m, tr, false) end
        end
        local npcs = Workspace:FindFirstChild("FeralNPCs")
        if npcs then
            for _, m in ipairs(npcs:GetChildren()) do
                local tr = prey_ok(m)
                local sp = tostring(m:GetAttribute("Species") or "")
                if tr and not SKIP[sp] and not DANGER[sp] then consider(m, tr, m:GetAttribute("FeralMouse") == true) end
            end
        end
        local mice = Workspace:FindFirstChild("FeralMice")
        if mice then
            for _, m in ipairs(mice:GetChildren()) do
                local tr = prey_ok(m)
                if tr and (tr.Position - r.Position).Magnitude < 12 then consider(m, tr, true) end
            end
        end
    end
    -- [[ players: only while you've turned it on (T): the ones biting you, or everyone if you picked that ]] --
    if S.aura then
        for _, p in ipairs(Players:GetPlayers()) do
            local c = p ~= me and not packmate(p) and p.Character
            local tr = c and c:FindFirstChild("HumanoidRootPart")
            local biting = c and S.biters[c] and os.clock() - S.biters[c].t < 20
            if tr and char_hp(c) > 0 and (biting or S.aura_targets == "Everyone") then consider(c, tr, false) end
        end
    end
    return best, best_mouse
end
-- [[ get away: dry land far from every player, away from where wolves, cats, bears and gators live, and from any ]] --
-- [[ dangerous animal you can see; straight there (no gliding past anyone)                                      ]] --
local HUNTER_HOMES = { HowlingRidge = true, LookoutRock = true, Frostfall = true, WhisperpineWoods = true, GoatCliffs = true, StoneBasin = true,
    HoodooFlats = true, RedCanyon = true, OldGrowth = true, ReedMarsh = true, MudWallows = true, Stillwater = true, BeaverPonds = true }
local function safety_score(x, z, r)
    local p = Vector3.new(x, 0, z)
    if r and flat(p - r.Position).Magnitude < 350 then return -1 end
    local closest = 2500
    for _, pl in ipairs(Players:GetPlayers()) do
        local pr = pl ~= me and not packmate(pl) and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
        if pr then closest = math.min(closest, flat(pr.Position - p).Magnitude) end
    end
    local score = closest
    local npcs = Workspace:FindFirstChild("FeralNPCs")
    if npcs then
        for _, m in ipairs(npcs:GetChildren()) do
            local tr = DANGER[tostring(m:GetAttribute("Species") or "")] and prey_ok(m)
            if tr and flat(tr.Position - p).Magnitude < 250 then score -= 400 end
        end
    end
    return score
end
-- [[ standing in water? the nearest dry ground around it ]] --
local function dry_near(x, z)
    local hit, w = water_at(x, z)
    if hit and not w then return hit.Position end
    for rad = 12, 240, 12 do
        for i = 0, 11 do
            local a = i / 12 * math.pi * 2
            local hx, hz = x + math.cos(a) * rad, z + math.sin(a) * rad
            local h2, w2 = water_at(hx, hz)
            if h2 and not w2 then return h2.Position end
        end
    end
    return nil
end
-- [[ Get away. Run 2: an instant teleport doesn't stick (the server marks you, FeralGuardUntil, and keeps you where ]] --
-- [[ it last saw you), so: straight down under the ground right where you are (out of reach of bites), then run    ]] --
-- [[ away underground, deep, at the fastest pace the server accepts, to the quietest place 300-900 studs off; heal   ]] --
-- [[ down there, then come up on dry land. The farm stays away from that fight for 2.5 minutes.                     ]] --
local function get_away(why)
    if S.escaping then return end
    S.escaping = true
    S.afk_up_now, S.afk_under_now = false, false
    logf("SAFE", why)
    local r0 = root_part()
    S.avoid = { pos = r0 and r0.Position or Vector3.zero, until_t = os.clock() + 150 }
    S.manual_run("getting away", function(keep)
        local ok, err = pcall(function()
            local r = root_part()
            if not r then return end
            local g = down(r.Position.X, r.Position.Z, false)
            if g then
                S.chase_speed = 80
                S.hold_chase = true
                S.hold = CFrame.new(r.Position.X, g.Position.Y - root_height() - 13, r.Position.Z)
                S.underground = true
                task.wait(0.35)
            end
            local list = {}
            for _, s in ipairs(SPOTS) do
                local d = flat(Vector3.new(s.x, 0, s.z) - r.Position).Magnitude
                if d > 250 then
                    table.insert(list, { name = s.name, x = s.x, z = s.z,
                        score = safety_score(s.x, s.z, nil) - (HUNTER_HOMES[s.key] and 600 or 0) - math.max(0, d - 900) * 0.6 })
                end
            end
            for _ = 1, 24 do
                local a, d = math.random() * math.pi * 2, 300 + math.random() * 600
                local x, z = r.Position.X + math.cos(a) * d, r.Position.Z + math.sin(a) * d
                table.insert(list, { name = "a quiet spot", x = x, z = z, score = safety_score(x, z, nil) })
            end
            table.sort(list, function(a, b) return a.score > b.score end)
            for i = 1, math.min(3, #list) do
                local s = list[i]
                if not keep() then return end
                S.status = "getting away underground to " .. s.name
                if travel(s.x, s.z, keep, false, false, true) then
                    -- [[ heal down there first (nobody can reach you), then up on dry land ]] --
                    local here = root_part()
                    local hg = here and down(here.Position.X, here.Position.Z, false)
                    if hg then
                        S.hold_chase = false
                        S.hold = CFrame.new(here.Position.X, hg.Position.Y - root_height() - 13, here.Position.Z)
                        S.underground = true
                        S.status = "healing underground"
                        local t0 = os.clock()
                        while keep() and health_pct() < 0.6 and os.clock() - t0 < 90 do task.wait(0.5) end
                    end
                    S.underground = false
                    local dry = dry_near(s.x, s.z)
                    if dry then place(stand_cf(dry, Vector3.new(0, 0, -1))) end
                    logf("SAFE", ("got away to %s (%d studs from the nearest player)"):format(s.name, math.floor(math.min(s.score, 2500))))
                    return
                end
            end
            logf("SAFE", "couldn't find dry, quiet ground to go to")
        end)
        S.underground = false
        S.escaping = false
        if not ok then error(err) end
    end)
end
S.get_away = get_away
-- [[ STOP FARM: somewhere safe on land. Out of the ground or the water onto dry land close by; with players or a ]] --
-- [[ gator close, first to the quietest point 250 studs away from them (the way you travel: underground, gliding) ]] --
function S.go_safe(keep)
    local r = root_part()
    if not r then return end
    local target = r.Position
    local p, d = nearest_player(r.Position)
    local gator = S.gator_near and S.gator_near(r.Position, 80)
    if (p and d and d < 120) or gator then
        local best, bs = nil, nil
        for i = 0, 11 do
            local a = i / 12 * math.pi * 2
            local x, z = r.Position.X + math.cos(a) * 250, r.Position.Z + math.sin(a) * 250
            local sc = safety_score(x, z, nil) - ((S.gator_near and S.gator_near(Vector3.new(x, 0, z), 120)) and 1000 or 0)
            if not bs or sc > bs then best, bs = Vector3.new(x, 0, z), sc end
        end
        if best then target = best end
    end
    local dry = dry_near(target.X, target.Z)
    if not dry then
        logf("SAFE", "farm stopped: no dry land found close by")
        return
    end
    local g = down(r.Position.X, r.Position.Z, false)
    local hh = hum()
    local in_ground = g and r.Position.Y < g.Position.Y - 0.5
    local in_water = hh and (hh:GetState() == Enum.HumanoidStateType.Swimming or hh.FloorMaterial == Enum.Material.Water)
    if flat(dry - r.Position).Magnitude > 6 or in_ground or in_water then
        S.status = "going somewhere safe"
        travel(dry.X, dry.Z, keep)
        local d2 = dry_near(dry.X, dry.Z)
        if d2 then place(stand_cf(d2, r.CFrame.LookVector)) end
    end
    S.status = "farm stopped: safe on land"
    logf("SAFE", "farm stopped: safe on dry land")
end
-- [[ one bite took more than half your health: away at once (whatever the low-health setting) ]] --
local function watch_big_hits(c)
    if not c then return end
    local h = c:WaitForChild("Humanoid", 10)
    if not h then return end
    local hp = h.Health
    track(h.HealthChanged:Connect(function(v)
        local drop = hp - v
        hp = v
        if S.big_hit_escape and v > 0 and h.MaxHealth > 0 and drop >= h.MaxHealth * 0.5 and hp_cause() == "bite" then
            get_away(("one bite took %d%% of your health: getting away"):format(math.floor(drop / h.MaxHealth * 100)))
        end
    end))
end
task.spawn(watch_big_hits, me.Character)
track(me.CharacterAdded:Connect(function(c) task.spawn(watch_big_hits, c) end))
go(function()
    local last_shake, last_flip, last_off, last_dodge, last_turn = 0, 0, 0, 0, 0
    while S.alive do
        task.wait(0.05)
        local c = me.Character
        local r = root_part()
        if not (c and r and alive()) then
            S.held = false
            continue
        end
        local held, flipping = held_now(c)
        S.held = held
        if held and S.anti_grab then
            if not S.was_held then
                S.was_held = true
                S.grabs += 1
                logf("SAFE", "something grabbed you: breaking free")
            end
            local t = os.clock()
            if t - last_shake > 0.17 then
                last_shake = t
                fire("FeralLunge", "shake")
            end
            if flipping and t - last_flip > 0.27 then
                last_flip = t
                fire("FeralLunge", "flip", now())
            end
            if t - last_off > 0.45 then
                last_off = t
                fire("FeralLunge", "getoff")
            end
        elseif S.was_held and not held then
            S.was_held = false
            logf("SAFE", "free again")
        end
        -- [[ Latched on with your lunge (whoever started it): the game blocks normal bites then, its damage while you ]] --
        -- [[ hold on is the squeeze (a click / Space on the tug). Squeeze at its fastest allowed pace, and still try   ]] --
        -- [[ real bites; after 8 the server ignored, stop sending them (squeezing goes on).                          ]] --
        local clamp = c:FindFirstChild("FeralClamp")
        local prey = clamp and clamp:IsA("ObjectValue") and clamp.Value
        if prey then
            if S.clamp_prey ~= prey then
                S.clamp_prey, S.latch_sent, S.latch_hits = prey, 0, 0
            end
            if S.auto_squeeze and os.clock() - S.last_sq_t > 0.15 then
                S.last_sq_t = os.clock()
                fire("FeralLunge", "squeeze")
            end
            if S.latch_bite and S.latch_bites_work ~= false and os.clock() - S.last_bite_t >= (S.cur_cd or bite_cd()) then
                bite_cd()
                bite(prey, false)
                S.latch_sent += 1
                if S.latch_sent >= 8 and S.latch_hits == 0 then
                    S.latch_bites_work = false
                    logf("HUNT", "the server doesn't take bites while you hold on: squeezing instead (that's the hold's damage)")
                elseif S.latch_hits > 0 and S.latch_bites_work ~= true then
                    S.latch_bites_work = true
                    logf("HUNT", "bites while holding on land: biting and squeezing")
                end
            end
        elseif S.clamp_prey then
            S.clamp_prey = false
        end
        -- [[ fight back: whatever bites or holds you gets bitten back, turned to face it wherever it is (a bird above, ]] --
        -- [[ a cat on your back): the server checks the bite against where you face, so you face it                 ]] --
        local ready = os.clock() - S.last_bite_t >= (S.cur_cd or bite_cd())
        if ready and S.fight_back and (held or (S.last_bitten and os.clock() - S.last_bitten < 4)) then
            local foe = attacker()
            if foe and foe:FindFirstChild("HumanoidRootPart") then
                if not S.hold and os.clock() - last_turn > 0.2 then
                    last_turn = os.clock()
                    S.face_m, S.face_until = foe, os.clock() + 0.45
                end
                bite_cd()
                bite(foe, false)
                ready = false
            end
        end
        -- [[ bite aura: anything in biting reach, any direction (you turn to it for the bite). Reach is the game's ]] --
        -- [[ own (body + legs), times your pick; the server allows about 1.5x before it ignores the bite             ]] --
        local latched = c:FindFirstChild("FeralClamp") or c:FindFirstChild("FeralClampLocal")
        if ready and (S.aura or S.aura_bots or S.bird_bite) and not S.hold and not latched then
            local m, mouse = S.aura_target(r)
            if m then
                if is_bird(m) then S.bird_bites += 1 end
                S.face_m, S.face_until = m, os.clock() + 0.45
                bite_cd()
                bite(m, mouse)
            end
        end
        -- [[ a bird diving at you: step aside before the talons close ]] --
        if S.dodge_birds and not held and not S.hold and os.clock() - last_dodge > 1.5 then
            for _, p in ipairs(Players:GetPlayers()) do
                local pc = p ~= me and not packmate(p) and p.Character
                local sp = pc and tostring(pc:GetAttribute("Species") or "")
                local pr = pc and pc:FindFirstChild("HumanoidRootPart")
                if pr and (sp == "Eagle" or sp == "Falcon") then
                    local off = r.Position - pr.Position
                    local v = pr.AssemblyLinearVelocity
                    if off.Magnitude < 45 and off.Y < -3 and v.Magnitude > 28 and v.Unit:Dot(off.Unit) > 0.75 then
                        last_dodge = os.clock()
                        local side = flat(v):Cross(Vector3.yAxis)
                        if side.Magnitude < 0.1 then side = Vector3.xAxis end
                        r.CFrame += side.Unit * 11
                        S.dodges += 1
                        logf("SAFE", p.DisplayName .. "'s " .. sp:lower() .. " dived at you: dodged")
                        break
                    end
                end
            end
        end
        -- [[ really low in a fight: teleport away (your pick: whenever you're low, or only when they're low too) ]] --
        local cause = hp_cause()
        if (cause == "hunger" or cause == "thirst") and health_pct() < 0.98 and os.clock() - S.starve_note_t > 30 then
            S.starve_note_t = os.clock()
            local what = cause == "thirst" and "thirst" or "hunger"
            local fix = cause == "thirst" and (S.auto_drink and "going to drink now" or "drink soon (Auto drink is off)")
                or (S.auto_eat and "going to eat now" or "eat soon (Auto eat is off)")
            notify(("Running out of health because of %s: %s."):format(what, fix))
            logf("SAFE", ("losing health from %s (%d%% left): %s"):format(what, math.floor(health_pct() * 100), fix))
        end
        if S.low_escape and not S.escaping and not held and cause == "bite" and health_pct() <= S.low_escape_at / 100 then
            local foe = attacker()
            local foe_hp = foe and char_hp(foe) or 1
            if S.low_escape_mode == "Me" or foe_hp <= 0.35 then
                get_away(("low health (%d%%, them %d%%): getting away"):format(math.floor(health_pct() * 100), math.floor(foe_hp * 100)))
            end
        end
    end
end)

---------------------------------------------------------------- the farm (one step at a time; ui.lua runs it with a watchdog)

local function farming() return S.alive and S.farm and not S.manual and not S.held and alive() end
function S.farm_step()
    if not S.farm or S.manual or S.held then
        task.wait(0.3)
        return
    end
    if not alive() then
        S.phase, S.status = "dead", "waiting to come back"
        task.wait(1)
        return
    end
    local keep = farming
    if not S.afk and (S.afk_up_now or S.afk_under_now) then
        S.afk_up_now, S.afk_under_now, S.underground = false, false, false
        S.hold = nil
    end
    -- [[ hidden underground: nobody can see you there (a bite sends you away at once instead) ]] --
    if not S.afk_under_now and flee(keep) then return end
    if rest_heal(keep) then return end
    if S.auto_drink and thirst() < S.drink_at then
        S.phase = "drink"
        S.afk_up_now, S.afk_under_now, S.underground = false, false, false
        S.hold = nil
        drink(keep)
        return
    end
    if S.auto_eat and hunger() < S.eat_at then
        S.phase = "eat"
        S.afk_up_now, S.afk_under_now, S.underground = false, false, false
        S.hold = nil
        local r = root_part()
        local item = r and food_near(r.Position, 160)
        if item and eat_item(item, keep) then return end
        if S.food_src ~= "Kills" and fish(keep) then return end
        if S.food_src ~= "Fish" and diet() ~= "herbivore" then
            hunt(keep)
            return
        end
        S.status = "hungry, nothing to eat close by"
        task.wait(2)
        return
    end
    -- [[ AFK farm: up on the platform (survival amber keeps paying; the anti-AFK steps keep you counted as active) ]] --
    if S.hop_due then
        S.hop_due = false
        S.phase = "hop"
        S.hop("every amber tree here is picked")
        return
    end
    if S.afk then
        S.phase = "afk"
        if S.afk_place == "Under" then
            if not S.afk_under_now then S.afk_hide(keep) end
            S.status = "AFK underground (up only to eat and drink)"
        else
            if not S.afk_up_now then S.afk_up() end
            S.status = "AFK on the sky platform (down only to eat and drink)"
        end
        task.wait(1)
        return
    end
    if S.quest_places then
        local q, id = quest_spot()
        if q then
            S.phase = "quest"
            do_quest(q, id, keep)
            return
        end
    end
    if S.chunks and os.clock() - S.chunk_t > 600 then
        S.phase = "amber"
        chunk_round(keep)
        return
    end
    if S.explore and not S.toured then
        S.phase = "explore"
        tour(keep)
        return
    end
    if S.hunt and diet() ~= "herbivore" then
        S.phase = "hunt"
        hunt(keep)
        return
    end
    -- [[ nothing to do: snack when there's free food right here (keeps the growth boost going) ]] --
    local r = root_part()
    local item = r and hunger() < 95 and food_near(r.Position, 40)
    if item then
        eat_item(item, keep)
        return
    end
    S.phase, S.status = "idle", "all fed and watered"
    task.wait(1)
end

-- [[ a button on the window (go to a place, collect now, explore): the farm waits while it runs; Stop cancels it ]] --
function S.manual_run(name, fn)
    S.manual_gen += 1
    local gen = S.manual_gen
    S.manual = true
    S.hold = nil
    go(function()
        local keep = function() return S.alive and S.manual_gen == gen and alive() end
        S.status = name
        local ok, err = pcall(fn, keep)
        if not ok then logf("ERROR", name .. ": " .. tostring(err):sub(1, 200)) end
        if S.manual_gen == gen then
            S.manual = false
            S.hold = nil
        end
    end)
end
function S.manual_stop()
    S.manual_gen += 1
    S.manual = false
    S.hold = nil
    S.status = "stopped"
end

---------------------------------------------------------------- see everything (ESP)

do
    local holder = Instance.new("Folder")
    holder.Name = HttpService:GenerateGUID(false):sub(1, 8)
    local gh = exec("gethui")
    pcall(function() holder.Parent = (typeof(gh) == "function" and gh()) or CoreGui end)
    if not holder.Parent then pcall(function() holder.Parent = CoreGui end) end
    if not holder.Parent then pcall(function() holder.Parent = me:WaitForChild("PlayerGui") end) end
    S.esp_holder = holder
    local marks = {}
    local COL = {
        player = Color3.fromRGB(255, 170, 70), mate = Color3.fromRGB(120, 230, 150), danger = Color3.fromRGB(255, 75, 75),
        gator = Color3.fromRGB(255, 60, 210), prey = Color3.fromRGB(160, 235, 170), mouse = Color3.fromRGB(185, 185, 200),
    }
    local water_cache = {}
    local function underwater(m, r)
        local e = water_cache[m]
        if e and os.clock() - e.t < 1 then return e.v end
        local ok, w = pcall(function()
            local p = r.Position + Vector3.new(0, 1.5, 0)
            local reg = Region3.new(p - Vector3.new(2, 2, 2), p + Vector3.new(2, 2, 2)):ExpandToGrid(4)
            local mats = Workspace.Terrain:ReadVoxels(reg, 4)
            return mats[1][1][1] == Enum.Material.Water
        end)
        local v = ok and w == true
        water_cache[m] = { t = os.clock(), v = v }
        return v
    end
    local function drop(m)
        local e = marks[m]
        if not e then return end
        pcall(function() e.bb:Destroy() end)
        if e.hl then pcall(function() e.hl:Destroy() end) end
        marks[m] = nil
        water_cache[m] = nil
    end
    S.esp_clear = function()
        for m in pairs(marks) do drop(m) end
    end
    go(function()
        while S.alive do
            task.wait(0.25)
            local r = root_part()
            if not (S.esp and r) then
                if next(marks) then S.esp_clear() end
                continue
            end
            local want = {}
            local function add(m, kind, title, tr)
                local d = (tr.Position - r.Position).Magnitude
                if d > S.esp_range then return end
                table.insert(want, { m = m, kind = kind, title = title, r = tr, d = d })
            end
            for _, p in ipairs(Players:GetPlayers()) do
                local c = p.Character
                local tr = c and c:FindFirstChild("HumanoidRootPart")
                if p ~= me and tr and S.esp_players then
                    local sp = tostring(c:GetAttribute("Species") or "?")
                    local kind = packmate(p) and "mate" or (sp == "Alligator" and "gator" or "player")
                    add(c, kind, ("%s · %s %s"):format(p.DisplayName, stage_name(c:GetAttribute("Growth")), sp), tr)
                end
            end
            local npcs = Workspace:FindFirstChild("FeralNPCs")
            if npcs then
                for _, m in ipairs(npcs:GetChildren()) do
                    local tr = prey_ok(m)
                    if tr then
                        local sp = tostring(m:GetAttribute("Species") or m.Name)
                        local kind = sp == "Alligator" and "gator" or (DANGER[sp] and "danger" or (m:GetAttribute("FeralMouse") and "mouse" or "prey"))
                        local show = (kind == "gator" and (S.esp_predators or S.esp_gators)) or (kind == "danger" and S.esp_predators)
                            or (kind == "prey" and S.esp_prey) or (kind == "mouse" and S.esp_mice)
                        if show then add(m, kind, ("wild %s %s"):format(stage_name(m:GetAttribute("Growth")), sp), tr) end
                    end
                end
            end
            if S.esp_mice then
                local mice = Workspace:FindFirstChild("FeralMice")
                if mice then
                    for _, m in ipairs(mice:GetChildren()) do
                        local tr = prey_ok(m)
                        if tr then add(m, "mouse", "mouse", tr) end
                    end
                end
            end
            table.sort(want, function(a, b) return a.d < b.d end)
            local keep_set, lights = {}, 0
            for _, w in ipairs(want) do
                keep_set[w.m] = true
                local e = marks[w.m]
                if not e then
                    local bb = Instance.new("BillboardGui")
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.fromOffset(200, 36)
                    bb.StudsOffsetWorldSpace = Vector3.new(0, 3.4, 0)
                    bb.LightInfluence = 0
                    bb.MaxDistance = 6000
                    local t = Instance.new("TextLabel")
                    t.BackgroundTransparency = 1
                    t.Size = UDim2.fromScale(1, 1)
                    t.Font = Enum.Font.GothamBold
                    t.TextSize = 12
                    t.TextStrokeTransparency = 0.3
                    t.TextWrapped = true
                    t.Parent = bb
                    bb.Parent = holder
                    e = { bb = bb, text = t }
                    marks[w.m] = e
                end
                e.bb.Adornee = w.r
                local col = COL[w.kind] or COL.prey
                -- [[ what it's doing: hiding (crouched, in a den, under water) or coming at you ]] --
                local tags = {}
                local m = w.m
                if w.kind ~= "mouse" and w.kind ~= "prey" then
                    if m:GetAttribute("FeralCrouch") then table.insert(tags, "CROUCHED") end
                    if m:GetAttribute("FeralHidden") then table.insert(tags, "IN A DEN") end
                    if (tonumber(m:GetAttribute("FeralQuillsUntil")) or 0) > now() then table.insert(tags, "QUILLS UP") end
                    if underwater(m, w.r) then table.insert(tags, "UNDER WATER") end
                    local v = flat(w.r.AssemblyLinearVelocity)
                    local to_me = flat(r.Position - w.r.Position)
                    if w.d < 90 and v.Magnitude > 4 and to_me.Magnitude > 0.5 and v.Unit:Dot(to_me.Unit) > 0.8 then table.insert(tags, "COMING AT YOU") end
                end
                local h = m:FindFirstChildOfClass("Humanoid")
                local hp = (h and h.MaxHealth > 0) and (" · %d%%"):format(math.floor(h.Health / h.MaxHealth * 100)) or ""
                e.text.Text = ("%s\n%dm%s%s"):format(w.title, math.floor(w.d * 0.28), hp, #tags > 0 and ("  " .. table.concat(tags, " ")) or "")
                e.text.TextColor3 = col
                -- [[ outlines through walls for players and anything dangerous (the game draws 31 at most) ]] --
                local light = S.esp_highlight and (w.kind == "player" or w.kind == "danger" or w.kind == "gator") and lights < 24
                if light then
                    lights += 1
                    if not e.hl then
                        local hl = Instance.new("Highlight")
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillTransparency = 0.78
                        hl.OutlineTransparency = 0
                        hl.Parent = holder
                        e.hl = hl
                    end
                    e.hl.Adornee = m
                    e.hl.FillColor, e.hl.OutlineColor = col, col
                elseif e.hl then
                    pcall(function() e.hl:Destroy() end)
                    e.hl = nil
                end
            end
            for m in pairs(marks) do
                if not keep_set[m] then drop(m) end
            end
        end
    end)
end

---------------------------------------------------------------- the aura key, its reach ring, your name and colour

-- [[ a key the game doesn't use (R is its Rest, which stops you biting) turns the bite aura on and off ]] --
track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp or UserInputService:GetFocusedTextBox() then return end
    if input.KeyCode.Name == S.aura_key then
        S.aura = not S.aura
        notify(S.aura and "Bite aura on players ON: bites players biting you, all around you" or "Bite aura on players OFF (bots still get bitten)")
        logf("FARM", "bite aura on players " .. (S.aura and "on" or "off") .. " (" .. S.aura_key .. ")")
    end
end))
-- [[ the reach ring on the ground: an attacker's body inside it gets bitten (it turns red when one is) ]] --
do
    local ring = Instance.new("CylinderHandleAdornment")
    ring.Height = 0.12
    ring.Transparency = 0.4
    ring.AlwaysOnTop = false
    ring.Color3 = Color3.fromRGB(217, 70, 239)
    ring.Parent = S.esp_holder
    S.aura_ring_part = ring
    go(function()
        while S.alive do
            task.wait(0.1)
            local r = root_part()
            -- [[ only while the players aura (T) is on: the bots aura is always on, a ring all the time is clutter ]] --
            local show = S.aura and S.aura_ring and r ~= nil and alive()
            ring.Visible = show and true or false
            ring.Adornee = show and r or nil
            if show and r then
                local rad = S.bite_reach()
                ring.Radius = rad
                ring.InnerRadius = math.max(rad - 0.35, 0)
                ring.CFrame = CFrame.new(0, -root_height() + 0.12, 0) * CFrame.Angles(math.rad(90), 0, 0)
                local m = S.aura_target(r)
                ring.Color3 = m and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(217, 70, 239)
            end
        end
    end)
    -- [[ the birds' reach: a see-through bubble around you (it reaches up, where they fly) ]] --
    local bubble = Instance.new("SphereHandleAdornment")
    bubble.Transparency = 0.88
    bubble.AlwaysOnTop = false
    bubble.Color3 = Color3.fromRGB(125, 211, 252)
    bubble.Parent = S.esp_holder
    go(function()
        while S.alive do
            task.wait(0.1)
            local r = root_part()
            -- [[ only when a bird is close (within 60 studs): that's when its reach matters ]] --
            local bird_near = false
            if S.bird_bite and S.aura_ring and r then
                for _, p in ipairs(Players:GetPlayers()) do
                    local pc = p ~= me and p.Character
                    local pr = pc and is_bird(pc) and pc:FindFirstChild("HumanoidRootPart")
                    if pr and (pr.Position - r.Position).Magnitude < 60 then
                        bird_near = true
                        break
                    end
                end
            end
            local show = bird_near and alive()
            bubble.Visible = show and true or false
            bubble.Adornee = show and r or nil
            if show and r then
                bubble.Radius = S.bird_reach()
                local b = S.aura_target(r)
                bubble.Color3 = (b and is_bird(b)) and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(125, 211, 252)
            end
        end
    end)
end
---------------------------------------------------------------- leap: onto any animal, any size (you do the biting)

-- [[ The leap key flies you onto the animal in front of where you're looking (bots or players, any size), in an arc ]] --
-- [[ like the game's lunge, with the lunge pose, and keeps you on its back (behind it, out of its reach) until you   ]] --
-- [[ let go: the key again or Space. Your movement goes through the server, so everyone sees the leap.             ]] --
local function leap_pick()
    local r = root_part()
    if not r then return nil end
    local cam = Workspace.CurrentCamera
    local look = flat(cam and cam.CFrame.LookVector or r.CFrame.LookVector)
    if look.Magnitude < 0.1 then look = flat(r.CFrame.LookVector) end
    local best, bs = nil, nil
    local function consider(m, tr)
        if m == me.Character or protected(m) or char_hp(m) <= 0 then return end
        local off = flat(tr.Position - r.Position)
        local d = off.Magnitude
        if d > S.leap_range or d < 0.5 then return end
        local dot = off.Unit:Dot(look.Unit)
        if dot < 0.5 then return end
        local score = d * (2 - dot)
        if not bs or score < bs then best, bs = m, score end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local c = p ~= me and not packmate(p) and p.Character
        local tr = c and c:FindFirstChild("HumanoidRootPart")
        if tr then consider(c, tr) end
    end
    local npcs = Workspace:FindFirstChild("FeralNPCs")
    if npcs then
        for _, m in ipairs(npcs:GetChildren()) do
            local tr = prey_ok(m)
            if tr then consider(m, tr) end
        end
    end
    return best
end
local function leap(force)
    if S.leaping then
        S.leaping = false
        return
    end
    local m = force or leap_pick()
    local r, c = root_part(), me.Character
    if not (m and r and c) then
        notify("Nothing in front of you to leap at (within " .. S.leap_range .. " studs).")
        return
    end
    local pl = Players:GetPlayerFromCharacter(m)
    local name = pl and (pl.DisplayName .. "'s " .. tostring(m:GetAttribute("Species") or "animal")) or ("a wild " .. tostring(m:GetAttribute("Species") or m.Name))
    S.leaping = true
    S.leap_target = m
    logf("FIGHT", "leapt onto " .. name)
    S.manual_run("on " .. name .. "'s back (leap key or Space to let go)", function(keep)
        local from = r.Position
        local dist = (from - (m:GetPivot().Position)).Magnitude
        local dur = math.clamp(dist / 70, 0.2, 0.7)
        local start = os.clock()
        -- [[ the game's own lunge pose (its animation script plays it from these) ]] --
        pcall(function()
            c:SetAttribute("FeralLeapKind", "Lunge")
            c:SetAttribute("FeralLeapLen", dur)
            c:SetAttribute("FeralLeapAt", now())
        end)
        S.hold = function()
            -- [[ the game's own latch has you: leave you to it (holding you too made you spin) ]] --
            local mc = me.Character
            if mc and mc:FindFirstChild("FeralClamp") then return nil end
            local goal = behind(m, 0)
            local tr = prey_ok(m)
            if not (goal and tr) then return nil end
            local k = math.clamp((os.clock() - start) / dur, 0, 1)
            if k >= 1 then return goal end
            local e = k * k * (3 - 2 * k)
            local p = from:Lerp(goal.Position, e) + Vector3.new(0, math.sin(k * math.pi) * math.min(dist * 0.15, 6), 0)
            return CFrame.lookAt(p, Vector3.new(tr.Position.X, p.Y, tr.Position.Z))
        end
        while keep() and S.leaping and m.Parent and char_hp(m) > 0 and prey_ok(m) do
            -- [[ after the leap: if it runs, you run after it (no jumping onto it) ]] --
            if os.clock() - start >= dur then
                S.chase_speed = chase_speed(m)
                S.hold_chase = true
            end
            task.wait(0.05)
        end
        S.hold = nil
        S.hold_chase = false
        if S.leaping then logf("FIGHT", name .. (char_hp(m) <= 0 and " is down" or " got away")) end
        S.leaping = false
    end)
end
S.leap = leap
track(UserInputService.InputBegan:Connect(function(input, gp)
    if UserInputService:GetFocusedTextBox() then return end
    if S.leaping and input.KeyCode == Enum.KeyCode.Space then
        S.leaping = false
        return
    end
    if gp or not S.leap_on or S.leap_key == S.aura_key then return end
    if input.KeyCode.Name == S.leap_key then
        -- [[ holding on with a real lunge: the same key lets go ]] --
        local c = me.Character
        if not S.leaping and c and c:FindFirstChild("FeralClamp") then
            S.let_go()
            return
        end
        leap()
    end
end))
-- [[ stay on: the game's own "let go" from your side is held back while this is on (your leap ends only when you  ]] --
-- [[ let go). The server can still end a real lunge (11 s, or the prey shakes you off: the hub squeezes against it) ]] --
do
    local hm, gnm, ncc = exec("hookmetamethod"), exec("getnamecallmethod"), exec("newcclosure")
    if typeof(hm) == "function" and typeof(gnm) == "function" and R.FeralLunge then
        local lunge_remote = R.FeralLunge
        local old
        -- [[ a let-go always goes through when it's yours (any key or click in the last 0.6 s: F, the tap button), or ]] --
        -- [[ when you're in trouble (under 50% health, or something else bit you in the last 3 s): only the game's own ]] --
        -- [[ automatic one is held back. (Run 2: it held you on a player while a rhino killed you.)                       ]] --
        local function hook(self, ...)
            if self == lunge_remote and S.alive and S.keep_latch and not S.release_ok then
                if gnm() == "FireServer" and select(1, ...) == "release" then
                    local yours = os.clock() - S.last_input_t < 0.6 or UserInputService:IsKeyDown(Enum.KeyCode.F)
                        or UserInputService:IsKeyDown(Enum.KeyCode.G) or UserInputService:IsKeyDown(Enum.KeyCode.Space)
                        or UserInputService:IsKeyDown(Enum.KeyCode.B) or UserInputService:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR1)
                    local trouble = health_pct() < 0.5 or os.clock() - S.last_bitten < 3
                    if not (yours or trouble) then
                        ev("BLOCKED", "the game tried to let go of your hold")
                        return nil
                    end
                end
            end
            return old(self, ...)
        end
        local ok = pcall(function() old = hm(game, "__namecall", typeof(ncc) == "function" and ncc(hook) or hook) end)
        if not ok then logf("ERROR", "couldn't watch the game's let-go (no namecall hook here)") end
    end
end
-- [[ your own let go of a real lunge hold (F, or the leap key, while latched): lets go and frees you to run ]] --
function S.let_go()
    S.leaping = false
    S.hold = nil
    logf("FIGHT", "let go")
    -- [[ the same "release" ends every grab (wolf, cats, tiger, gator, python, otter, eagle, cub carry); sent again ]] --
    -- [[ every 0.3 s for 2 s while the hold is still there                                                       ]] --
    task.spawn(function()
        local t0 = os.clock()
        repeat
            S.release_ok = true
            fire("FeralLunge", "release")
            S.release_ok = false
            task.wait(0.3)
            local c = me.Character
        until not (c and c:FindFirstChild("FeralClamp")) or os.clock() - t0 > 2
    end)
end
track(UserInputService.InputBegan:Connect(function(input, gp)
    -- [[ any key or click of yours (the hook above lets your own let-go through) ]] --
    if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.Gamepad1 then
        S.last_input_t = os.clock()
    end
    if UserInputService:GetFocusedTextBox() then return end
    -- [[ a click while latched: a squeeze (the hold's damage), even off the tug button ]] --
    local cc = me.Character
    if input.UserInputType == Enum.UserInputType.MouseButton1 and cc and cc:FindFirstChild("FeralClamp") and os.clock() - S.last_sq_t > 0.1 then
        S.last_sq_t = os.clock()
        fire("FeralLunge", "squeeze")
    end
    -- [[ F and X are the game's own keys (it marks them as handled), so these two are checked before that test.    ]] --
    -- [[ F while holding on (run 5: ignored because of that mark): let go                                          ]] --
    local c = me.Character
    if input.KeyCode == Enum.KeyCode.F and (S.leaping or (c and (c:FindFirstChild("FeralClamp") or c:FindFirstChild("FeralClampLocal")))) then
        S.let_go()
        return
    end
    -- [[ X in the water: the game won't burst there, the hub keeps it for you (toggles like the game's X) ]] --
    local hh = hum()
    if input.KeyCode == Enum.KeyCode.X and hh and (hh:GetState() == Enum.HumanoidStateType.Swimming or hh.FloorMaterial == Enum.Material.Water) then
        S.water_burst = not S.water_burst
    end
    if gp then return end
end))

---------------------------------------------------------------- target a player (by username or display name)

-- [[ part of a name is enough; exact names win, then names that start with it, then names containing it ]] --
function S.find_player(text)
    text = tostring(text or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if #text < 2 then return nil end
    local best, rank = nil, 9
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= me then
            for _, n in ipairs({ p.Name:lower(), p.DisplayName:lower() }) do
                local r = (n == text and 1) or (n:sub(1, #text) == text and 2) or (n:find(text, 1, true) and 3) or 9
                if r < rank then best, rank = p, r end
            end
        end
    end
    return best
end
local function target_char(p)
    local c = p and p.Parent and p.Character
    return c and c:FindFirstChild("HumanoidRootPart") and char_hp(c) > 0 and c or nil
end
-- [[ go to them (the way you picked to travel: underground, low profile and all) ]] --
function S.target_go(keep, p)
    local c = target_char(p)
    if not c then return false end
    local tr = c:FindFirstChild("HumanoidRootPart")
    S.status = "going to " .. p.DisplayName
    return travel(tr.Position.X, tr.Position.Z, keep)
end
-- [[ follow: a few steps behind them wherever they go, until Stop ]] --
function S.target_follow(keep, p)
    if not target_char(p) then return end
    S.status = "following " .. p.DisplayName
    logf("FIGHT", "following " .. p.DisplayName)
    while keep() do
        local c = target_char(p)
        if not c then break end
        local tr = c:FindFirstChild("HumanoidRootPart")
        local r = root_part()
        if r and (tr.Position - r.Position).Magnitude > 120 then
            S.hold = nil
            travel(tr.Position.X, tr.Position.Z, function() return keep() and target_char(p) ~= nil end)
        else
            S.chase_speed = chase_speed(c)
            S.hold_chase = true
            S.hold = function() return behind(c, 6) end
        end
        task.wait(0.2)
    end
    S.hold = nil
end
-- [[ attack: onto their back (behind them, out of their bite) and bite at your pace until they're down or gone ]] --
function S.target_attack(keep, p)
    local c = target_char(p)
    if not c then return end
    local r = root_part()
    local tr = c:FindFirstChild("HumanoidRootPart")
    if r and (tr.Position - r.Position).Magnitude > 40 then S.target_go(keep, p) end
    S.status = "attacking " .. p.DisplayName
    logf("FIGHT", "attacking " .. p.DisplayName)
    local hits0 = S.hits
    while keep() do
        c = target_char(p)
        if not c then break end
        S.chase_speed = chase_speed(c)
        S.hold_chase = true
        S.hold = function() return attack_cf(c, 0) end
        if os.clock() - S.last_bite_t >= bite_cd() then bite(c, false) end
        task.wait()
    end
    S.hold = nil
    local fell = p.Character and char_hp(p.Character) <= 0
    logf("FIGHT", ("%s %s (%d of your bites landed)"):format(p.DisplayName, fell and "is down" or "got away", S.hits - hits0))
end
-- [[ watch them: your camera follows them (Stop gives it back) ]] --
function S.target_watch(p)
    local c = target_char(p)
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local cam = Workspace.CurrentCamera
    if h and cam then cam.CameraSubject = h end
end
function S.target_unwatch()
    local cam, h = Workspace.CurrentCamera, hum()
    if cam and h then cam.CameraSubject = h end
end

-- [[ your animal's name over its head: the game's own rename, so everyone sees it (the server filters it) ]] --
function S.rename(text)
    local slot = me:GetAttribute("FeralSlot")
    local remote = RS:FindFirstChild("FeralSlots")
    text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if not (slot and remote) or #text < 2 or #text > 18 then return false end
    local ok = pcall(remote.FireServer, remote, "rename", slot, text)
    if ok then logf("FARM", "asked the game to rename your animal to " .. text) end
    return ok
end
-- [[ amber without fighting players: trees, rewards, places, quests, prey bots, staying alive and moving ]] --
function S.amber_farm()
    S.amber_mode = true
    S.chunks, S.rewards, S.explore, S.quest_places, S.hunt = true, true, true, true, true
    S.prey, S.low_profile, S.anti_afk, S.flee_players, S.auto_eat, S.auto_drink = "Big", true, true, true, true, true
    S.farm = true
    logf("FARM", "amber farm on: trees, rewards, places, quests, prey bots")
end

---------------------------------------------------------------- AFK farm: a platform high in the sky

-- [[ Over the quietest place on the map, higher than birds can fly (their ceiling is 280 above the ground). The    ]] --
-- [[ platform is on your screen only (others see you standing in the air); you can't fall off: step off and you're ]] --
-- [[ put back. With AFK farm on, the farm only comes down to eat and drink, then goes back up.                     ]] --
do
    local plat = nil
    local function make_platform(pos)
        if plat and plat.Parent then
            plat.Position = pos
            return plat
        end
        plat = Instance.new("Part")
        plat.Name = "SobrietyAFK"
        plat.Anchored = true
        plat.Size = Vector3.new(60, 2, 60)
        plat.Material = Enum.Material.Glass
        plat.Color = Color3.fromRGB(147, 51, 234)
        plat.Transparency = 0.35
        plat.CastShadow = false
        plat.Position = pos
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.fromOffset(220, 46)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 7, 0)
        bb.LightInfluence = 0
        bb.MaxDistance = 400
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Size = UDim2.fromScale(1, 1)
        t.Font = Enum.Font.GothamBlack
        t.TextSize = 22
        t.Text = "AFK FARM"
        t.TextColor3 = Color3.fromRGB(240, 171, 252)
        t.TextStrokeTransparency = 0.4
        t.Parent = bb
        bb.Adornee = plat
        bb.Parent = plat
        plat.Parent = Workspace
        return plat
    end
    S.afk_part = function() return plat end
    local function pick_spot()
        local best, bs = nil, nil
        for _, s in ipairs(SPOTS) do
            local sc = safety_score(s.x, s.z, nil) - (HUNTER_HOMES[s.key] and 600 or 0)
            if not bs or sc > bs then best, bs = s, sc end
        end
        best = best or SPOTS[1]
        local g = down(best.x, best.z, true)
        local base = g and g.Position.Y or 200
        return Vector3.new(best.x, math.max(base + 450, 650), best.z), best.name
    end
    function S.afk_up()
        local r = root_part()
        if not r then return false end
        if not S.afk_pos then S.afk_pos, S.afk_name = pick_spot() end
        if not S.afk_back then S.afk_back = r.Position end
        local p = make_platform(S.afk_pos)
        -- [[ glide up (an instant jump up there gets pulled back by the server) ]] --
        local top = stand_cf(p.Position + Vector3.new(0, 1, 0), r.CFrame.LookVector)
        S.chase_speed = math.min(S.travel_cap, 160)
        S.hold_chase = true
        S.hold = top
        local t0 = os.clock()
        repeat task.wait(0.1) until (r.Position - top.Position).Magnitude < 3 or os.clock() - t0 > 20
        S.hold_chase = false
        task.wait(0.2)
        S.hold = nil
        S.afk_up_now = true
        logf("AFK", "on the AFK platform above " .. tostring(S.afk_name))
        return true
    end
    -- [[ AFK underground: below the ground at the quietest place, a 5-stud step each minute (so you still count as ]] --
    -- [[ moving for the survival amber). A bite down there sends you away at once.                                 ]] --
    function S.afk_hide(keep)
        local r = root_part()
        if not r then return false end
        if not S.afk_pos then S.afk_pos, S.afk_name = pick_spot() end
        if not S.afk_back then S.afk_back = r.Position end
        local x, z = S.afk_pos.X, S.afk_pos.Z
        if not travel(x, z, keep) then return false end
        local g = down(x, z, false)
        if not g then return false end
        local base = g.Position.Y - root_height() - 10
        local t0 = os.clock()
        S.hold = function()
            local side = (math.floor((os.clock() - t0) / 60) % 2 == 0) and 0 or 5
            return CFrame.new(x + side, base, z)
        end
        S.underground = true
        S.afk_under_now = true
        logf("AFK", "hiding underground below " .. tostring(S.afk_name))
        return true
    end
    function S.afk_down(keep)
        S.afk_up_now, S.afk_under_now, S.underground = false, false, false
        S.hold = nil
        local b = S.afk_back
        if b then
            travel(b.X, b.Z, keep, true)
            logf("AFK", "back down")
        end
        S.afk_back = false
    end
    function S.afk_new_spot()
        S.afk_pos, S.afk_name = pick_spot()
        if plat and plat.Parent then plat.Position = S.afk_pos end
        return S.afk_name
    end
    -- [[ stepped off the edge: straight back on (a fall from up there would kill you) ]] --
    go(function()
        while S.alive do
            task.wait(0.1)
            if S.afk_up_now and plat and plat.Parent and not S.hold then
                local r = root_part()
                if r and r.Position.Y < plat.Position.Y - 3 and flat(r.Position - plat.Position).Magnitude < 250 then
                    place(stand_cf(plat.Position + Vector3.new(0, 1, 0), r.CFrame.LookVector))
                end
            end
        end
    end)
end

---------------------------------------------------------------- more FPS (same quality up close) and no false alarms

-- [[ Far-away small things (bushes, reeds, lily pads, clutter, water plants) stop being drawn past the distance you ]] --
-- [[ pick, and far particle effects pause; they come back as you get near. Nothing close changes, nor the graphics   ]] --
-- [[ quality. Big trees and the ground always stay, so the skyline looks the same.                                   ]] --
do
    local CULL_FOLDERS = { "FeralFoliage", "FeralClutter", "FeralMap_WaterPlants", "FeralMap_F2_Marsh", "FeralMap_Thickets", "FeralMap_Jungle",
        "FeralMap_Canyon", "FeralFX_WolfValley", "FeralCrows", "FeralBonesLive", "FeralBleedDrops" }
    local parts, set, hidden, fx = {}, {}, {}, {}
    local function take(d)
        if set[d] then return end
        if d:IsA("BasePart") then
            local s = d.Size
            if math.max(s.X, s.Y, s.Z) < 16 then
                set[d] = true
                table.insert(parts, d)
            end
        elseif d:IsA("ParticleEmitter") then
            set[d] = true
            table.insert(fx, d)
        end
    end
    local function watch(folder)
        for _, d in ipairs(folder:GetDescendants()) do take(d) end
        track(folder.DescendantAdded:Connect(take))
    end
    go(function()
        for _, n in ipairs(CULL_FOLDERS) do
            local f = Workspace:FindFirstChild(n)
            if f then watch(f) end
        end
        track(Workspace.ChildAdded:Connect(function(f)
            if table.find(CULL_FOLDERS, f.Name) then watch(f) end
        end))
        local i = 0
        while S.alive do
            local cam = Workspace.CurrentCamera
            local eye = cam and cam.CFrame.Position
            local on = S.cull and eye ~= nil
            local far = S.cull_dist
            -- [[ a slice of the list each frame, so the whole map is gone over about once a second ]] --
            local step = math.max(200, math.floor(#parts / 60))
            for _ = 1, step do
                i += 1
                if i > #parts then
                    i = 1
                    -- [[ drop parts the map streamed out ]] --
                    for k = #parts, 1, -1 do
                        if not parts[k].Parent then
                            set[parts[k]] = nil
                            hidden[parts[k]] = nil
                            table.remove(parts, k)
                        end
                    end
                    break
                end
                local p = parts[i]
                if p and p.Parent then
                    local hide = on and (p.Position - eye).Magnitude > far
                    if hide ~= (hidden[p] == true) then
                        p.LocalTransparencyModifier = hide and 1 or 0
                        hidden[p] = hide or nil
                    end
                end
            end
            for _, e in ipairs(fx) do
                if e.Parent and e.Parent:IsA("BasePart") then
                    local pause = on and (e.Parent.Position - eye).Magnitude > far * 0.7
                    if pause and e.Enabled then
                        e:SetAttribute("SobrietyCulled", true)
                        e.Enabled = false
                    elseif not pause and e:GetAttribute("SobrietyCulled") then
                        e:SetAttribute("SobrietyCulled", nil)
                        e.Enabled = true
                    end
                end
            end
            task.wait()
        end
    end)
    S.cull_restore = function()
        for p in pairs(hidden) do pcall(function() p.LocalTransparencyModifier = 0 end) end
        table.clear(hidden)
        for _, e in ipairs(fx) do
            pcall(function()
                if e:GetAttribute("SobrietyCulled") then
                    e:SetAttribute("SobrietyCulled", nil)
                    e.Enabled = true
                end
            end)
        end
    end
    S.cull_count = function()
        local n = 0
        for _ in pairs(hidden) do n += 1 end
        return n, #parts
    end
end
-- [[ the territory "UNDER ATTACK!" banner, its red screen edge and alarm (FeralTerritoryHUD) ]] --
do
    local muted = {}
    go(function()
        while S.alive do
            task.wait(0.3)
            local pg = me:FindFirstChildOfClass("PlayerGui")
            local banner = pg and pg:FindFirstChild("FeralTerritoryBanner")
            if banner and banner:IsA("ScreenGui") then
                if S.hide_raids and banner.Enabled then
                    banner.Enabled = false
                    banner:SetAttribute("SobrietyHidden", true)
                elseif not S.hide_raids and banner:GetAttribute("SobrietyHidden") then
                    banner:SetAttribute("SobrietyHidden", nil)
                    banner.Enabled = true
                end
            end
            for _, where in ipairs({ game:GetService("SoundService"), pg, Workspace.CurrentCamera }) do
                local snd = where and where:FindFirstChild("FeralTerr_Threat", true)
                if snd and snd:IsA("Sound") then
                    if S.hide_raids and not muted[snd] then
                        muted[snd] = snd.Volume
                        snd.Volume = 0
                    elseif not S.hide_raids and muted[snd] then
                        snd.Volume = muted[snd]
                        muted[snd] = nil
                    end
                end
            end
        end
        for snd, v in pairs(muted) do pcall(function() snd.Volume = v end) end
    end)
end

---------------------------------------------------------------- Discord alerts (your own webhook)

-- [[ Deaths, low health (from bites), low hunger, low thirst, and your amber goal, each with its own switch, sent  ]] --
-- [[ to the webhook you paste. Each kind waits a while before it can send again, so a fight doesn't spam you.     ]] --
local HOOK_WAIT = { death = 5, low = 60, hunger = 300, thirst = 300, goal = 5, test = 3 }
S.hook_last = {}
local function web_request()
    local f = exec("request") or exec("http_request")
    if typeof(f) == "function" then return f end
    local syn = exec("syn")
    if type(syn) == "table" and typeof(syn.request) == "function" then return syn.request end
    return nil
end
function S.hook_ok(url)
    url = tostring(url or "")
    return url:match("^https://discord%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil or url:match("^https://%a*%.?discord%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
        or url:match("^https://discordapp%.com/api/webhooks/%d+/[%w_%-]+$") ~= nil
end
function S.discord(kind, title, text, color)
    local switch = kind == "goal" and S.hook_goal_on or S["hook_" .. kind]
    if kind ~= "test" and not (S.hook_on and switch) then return end
    if not S.hook_ok(S.hook_url) then return end
    if os.clock() - (S.hook_last[kind] or -1e9) < (HOOK_WAIT[kind] or 30) then return end
    S.hook_last[kind] = os.clock()
    local req = web_request()
    if not req then
        logf("ERROR", "Discord: this executor can't send web requests")
        return
    end
    local body = HttpService:JSONEncode({
        username = "Sobriety Hub",
        embeds = { {
            title = title,
            description = text,
            color = color or 0xD946EF,
            footer = { text = ("FERAL Animal Survival  ·  %s"):format(me.DisplayName) },
            timestamp = DateTime.now():ToIsoDate(),
        } },
    })
    task.spawn(function()
        local ok, res = pcall(req, { Url = S.hook_url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
        local code = ok and type(res) == "table" and tonumber(res.StatusCode) or nil
        if not ok or (code and code >= 300) then
            logf("ERROR", ("Discord didn't take the %s alert (%s)"):format(kind, ok and ("status " .. tostring(code)) or tostring(res):sub(1, 80)))
        else
            ev("DISCORD", "sent: " .. kind)
        end
    end)
end
-- [[ low health (only bites: hunger and thirst have their own), low hunger, low thirst, amber goal ]] --
go(function()
    while S.alive do
        task.wait(2)
        if S.hook_on and S.hook_ok(S.hook_url) and alive() then
            local hp = health_pct()
            if hp <= S.hook_hp / 100 and S.hp_cause and S.hp_cause() == "bite" then
                local foe = S.attacker and S.attacker()
                local pl = foe and Players:GetPlayerFromCharacter(foe)
                S.discord("low", "Low health", ("**%d%%** health%s"):format(math.floor(hp * 100),
                    foe and (" while fighting %s"):format(pl and (pl.DisplayName .. "'s " .. tostring(foe:GetAttribute("Species") or "animal")) or ("a wild " .. tostring(foe:GetAttribute("Species") or "animal"))) or ""), 0xF5A524)
            end
            if hunger() <= S.hook_need then
                S.discord("hunger", "Hungry", ("Hunger at **%d%%**%s"):format(math.floor(hunger()), hunger() <= 1 and ": losing health" or ""), 0xF5A524)
            end
            if thirst() <= S.hook_need then
                S.discord("thirst", "Thirsty", ("Thirst at **%d%%**%s"):format(math.floor(thirst()), thirst() <= 1 and ": losing health" or ""), 0x38BDF8)
            end
            local goal = tonumber(S.hook_goal) or 0
            local amber = tonumber(me:GetAttribute("Amber")) or 0
            if goal > 0 and amber >= goal and S.goal_sent ~= goal then
                S.goal_sent = goal
                S.discord("goal", "Amber goal reached", ("**%s** amber (goal %s)"):format(short(amber), short(goal)), 0x22C55E)
            end
        end
    end
end)

---------------------------------------------------------------- staying in the server

track(me.Idled:Connect(function()
    if not S.anti_afk then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))
go(function()
    local last_pos, last_move = nil, os.clock()
    while S.alive do
        task.wait(30 + math.random() * 20)
        if S.anti_afk then
            -- [[ the game's AFK timer resets on any mouse movement ]] --
            if VIM then
                pcall(function()
                    local m = UserInputService:GetMouseLocation()
                    VIM:SendMouseMoveEvent(m.X + 1, m.Y, game)
                end)
            end
            -- [[ the survival clock and amber pause if you haven't moved 4 studs in 2 minutes: a short step when idle ]] --
            local r = root_part()
            if r and not S.hold and alive() then
                if not last_pos or (r.Position - last_pos).Magnitude >= 5 then
                    last_pos, last_move = r.Position, os.clock()
                elseif os.clock() - last_move > 80 then
                    local base = r.CFrame
                    place(base + flat(base.LookVector).Unit * 6)
                    task.wait(1.5)
                    if not S.hold then place(base) end
                    last_move = os.clock()
                end
            end
        end
    end
end)
-- [[ moved to another server (the AFK hop, a disconnect, a rejoin): the hub loads itself again there ]] --
local SELF_FILE = "feral.lua"
local function queue_self()
    if env.sobriety_feral_queued or not S.auto_reload then return end
    local q = exec("queue_on_teleport") or exec("queueonteleport")
    local isf = exec("isfile")
    if typeof(q) ~= "function" or (typeof(isf) == "function" and not isf(SELF_FILE)) then return end
    local src = ([[
if game.GameId ~= %d then return end
if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() ((getgenv and getgenv()) or _G).sobriety_quick_boot = true end)
local ok, s = pcall(readfile, %q)
local fn = ok and type(s) == "string" and loadstring(s)
if fn then task.spawn(fn) end
]]):format(GAME_ID, SELF_FILE)
    env.sobriety_feral_queued = pcall(q, src)
end
queue_self()
S.queue_self = queue_self
-- [[ server hop: to a quieter public server of this game (fewest players first). The hub is queued to load there ]] --
-- [[ and your settings are saved first, so the farm carries on. Never mid-fight (your body would stay behind).    ]] --
function S.hop(why)
    if S.hopping then return end
    local t0 = os.clock()
    while S.alive and (tonumber(me:GetAttribute("FeralCombatUntil")) or 0) > now() and os.clock() - t0 < 30 do task.wait(1) end
    S.hopping = true
    S.hold = nil
    logf("HOP", tostring(why) .. ": moving to another server")
    local wf = exec("writefile")
    if typeof(wf) == "function" then pcall(wf, SETTINGS_FILE, settings_json()) end
    local was = S.auto_reload
    S.auto_reload = true
    queue_self()
    local list = {}
    local ok, body = pcall(function()
        return (game :: any):HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PLACE_ID))
    end)
    if ok and type(body) == "string" then
        local ok2, data = pcall(HttpService.JSONDecode, HttpService, body)
        if ok2 and type(data) == "table" and type(data.data) == "table" then
            for _, sv in ipairs(data.data) do
                if type(sv) == "table" and sv.id ~= game.JobId and (tonumber(sv.playing) or 0) < (tonumber(sv.maxPlayers) or 0) - 1 then
                    table.insert(list, sv)
                end
            end
        end
    end
    table.sort(list, function(a, b) return (tonumber(a.playing) or 0) < (tonumber(b.playing) or 0) end)
    local TS = game:GetService("TeleportService")
    for i = 1, math.min(#list, 6) do
        local sv = list[i]
        logf("HOP", ("trying a server with %s/%s players"):format(tostring(sv.playing), tostring(sv.maxPlayers)))
        pcall(function() TS:TeleportToPlaceInstance(PLACE_ID, sv.id, me) end)
        task.wait(12)
        if not S.alive then return end
    end
    pcall(function() TS:Teleport(PLACE_ID, me) end)
    task.wait(15)
    S.hopping = false
    S.auto_reload = was
end
pcall(function()
    local GuiService: any = game:GetService("GuiService")
    track(GuiService.ErrorMessageChanged:Connect(function(msg)
        if not (S.auto_reload and S.alive) or S.rejoining or type(msg) ~= "string" or msg == "" then return end
        S.rejoining = true
        logf("RECONNECT", "disconnected: " .. msg:sub(1, 120))
        go(function()
            while S.alive do
                queue_self()
                pcall(function() game:GetService("TeleportService"):Teleport(PLACE_ID, me) end)
                task.wait(10)
            end
        end)
    end))
end)

-- [[ who this script is, for the shared Sobriety Hub window (reports/sobriety-ui/toolkit.lua) ]] --
S.hub = {
    game = "FERAL Animal Survival", tag = "FERAL ANIMAL SURVIVAL", stop = "sobriety_feral_stop",
    steps = { { 0, "linking executor" }, { 0.2, "hooking the game's remotes" }, { 0.45, "reading the valley, prey and water" },
        { 0.7, "building the window" }, { 0.95, "ready" } },
}

---------------------------------------------------------------- Sobriety Hub: the window
-- [[ Shared by every Sobriety Hub script (reports/sobriety-ui/toolkit.lua; each game's build joins it in). The game ]] --
-- [[ tells it who it is through S.hub = { game = "...", tag = "...", stop = "<name of its stop function in env>",     ]] --
-- [[ steps = { { 0, "..." }, ... } } before this part runs.                                                          ]] --
-- [[ Purple and black, animated, and sized to your screen: it scales with the screen and again whenever the screen   ]] --
-- [[ changes (a phone turned, the Roblox window resized); on small screens the sidebar folds into an icon rail.      ]] --
-- [[ Hidden (Right Alt or the – button), a round S button stays on screen to bring it back: on a phone that's the    ]] --
-- [[ way back. The toolkit (make_window) and the pages (build_ui) are separate functions: one function may only      ]] --
-- [[ hold 200 locals.                                                                                                ]] --
local BOOT_QUICK = env.sobriety_quick_boot == true
env.sobriety_quick_boot = nil

local function make_window()
local W = { painters = {}, current = nil }
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local GuiService: any = game:GetService("GuiService")

-- [[ The look: black glass with the logo's liquid running through it. The accent colours are the dripping S's own ]] --
-- [[ (pale pink at the top of the liquid, magenta in the middle, violet and deep purple where it pools).            ]] --
local C = {
    bg = Color3.fromRGB(8, 6, 14), bg2 = Color3.fromRGB(23, 12, 40), panel = Color3.fromRGB(13, 10, 22), side = Color3.fromRGB(13, 10, 22),
    card = Color3.fromRGB(23, 17, 38), card2 = Color3.fromRGB(34, 25, 57), stroke = Color3.fromRGB(48, 36, 78),
    text = Color3.fromRGB(246, 241, 255), dim = Color3.fromRGB(157, 144, 190), head = Color3.fromRGB(217, 194, 255),
    a1 = Color3.fromRGB(217, 70, 239), a2 = Color3.fromRGB(147, 51, 234), a3 = Color3.fromRGB(240, 171, 252), indigo = Color3.fromRGB(99, 102, 241),
    deep = Color3.fromRGB(107, 33, 168), gloss = Color3.fromRGB(253, 244, 255), ink = Color3.fromRGB(10, 7, 18),
    off = Color3.fromRGB(38, 29, 58), good = Color3.fromRGB(74, 222, 128), bad = Color3.fromRGB(248, 113, 113),
    white = Color3.new(1, 1, 1), black = Color3.new(0, 0, 0),
}
local ACCENT = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.a3), ColorSequenceKeypoint.new(0.5, C.a1), ColorSequenceKeypoint.new(1, C.a2) })
-- [[ PILL: the liquid behind white text (top to bottom); LIQUID: the full run of the logo's liquid, for drips and fills ]] --
local PILL = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.a1), ColorSequenceKeypoint.new(0.6, C.a2), ColorSequenceKeypoint.new(1, C.deep) })
local LIQUID = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.a3), ColorSequenceKeypoint.new(0.45, C.a1), ColorSequenceKeypoint.new(1, C.a2) })
local BOLD, REG, BLACK, MED = Enum.Font.GothamBold, Enum.Font.Gotham, Enum.Font.GothamBlack, Enum.Font.GothamMedium
local BRAND, MONO = Enum.Font.Michroma, Enum.Font.RobotoMono
W.C, W.ACCENT, W.BOLD, W.REG, W.BLACK, W.MED, W.BRAND, W.MONO = C, ACCENT, BOLD, REG, BLACK, MED, BRAND, MONO

local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end
local function new(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end
local function corner(p, r) return new("UICorner", { CornerRadius = r and UDim.new(0, r) or UDim.new(1, 0), Parent = p }) end
local function outline(p, color, thick, transparency)
    return new("UIStroke", { Color = color or C.stroke, Thickness = thick or 1, Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p })
end
-- [[ a UIGradient also tints its object's own text, which made selected buttons look blank. So on a gradient ]] --
-- [[ button the text moves into a plain label on top of it (children aren't tinted).                         ]] --
-- [[ A button with words on it becomes wet glass: the liquid runs top to bottom (magenta to deep purple, so white ]] --
-- [[ words read on it) under a soft highlight. Bars, beads and lines keep the pink-to-violet run.                  ]] --
local text_labels = {}
local function gradient(p, rotation)
    local g = new("UIGradient", { Color = ACCENT, Rotation = rotation or 0, Parent = p })
    if p:IsA("TextButton") and p.Text ~= "" and not text_labels[p] then
        text_labels[p] = new("TextLabel", { Name = "Label", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = p.Text,
            Font = p.Font, TextSize = p.TextSize, TextColor3 = p.TextColor3, TextTruncate = Enum.TextTruncate.AtEnd, TextWrapped = p.TextWrapped, Parent = p })
        p.Text = ""
        g.Color, g.Rotation = PILL, 90
        local c = p:FindFirstChildOfClass("UICorner")
        local shine = new("Frame", { Name = "Sheen", Size = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = C.white, BorderSizePixel = 0, ZIndex = 0, Parent = p })
        new("UICorner", { CornerRadius = c and c.CornerRadius or UDim.new(0, 8), Parent = shine })
        new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(0.76, 1), Parent = shine })
        -- [[ (pages switch the gradient off for a choice that isn't picked: then it's plain, dry glass) ]] --
        g:GetPropertyChangedSignal("Enabled"):Connect(function() shine.Visible = g.Enabled end)
    end
    return g
end
local function set_text(b, text, color)
    local l = text_labels[b] or b
    if text then l.Text = text end
    if color then l.TextColor3 = color end
end
local function label(p, text, font, size, color, props)
    local l = new("TextLabel", { BackgroundTransparency = 1, Text = text, Font = font or REG, TextSize = size or 13, TextColor3 = color or C.text,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, Parent = p })
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end
-- [[ the wet look. pill: liquid a white label reads on; sheen: the soft highlight across the top of anything wet ]] --
-- [[ (it sits under the labels); glass: a card's body, lighter at the top, with a thin bright line along its top   ]] --
local function pill(p)
    local g = gradient(p, 90)
    g.Color = PILL
    return g
end
local function sheen(p, r, strength)
    local s = new("Frame", { Name = "Sheen", Size = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = C.white, BorderSizePixel = 0, ZIndex = 0, Parent = p })
    corner(s, r)
    new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(strength or 0.74, 1), Parent = s })
    return s
end
local function glass(f, r)
    corner(f, r)
    new("UIGradient", { Rotation = 90, Color = ColorSequence.new(C.white, Color3.fromRGB(196, 190, 214)), Parent = f })
    local line = new("Frame", { Name = "Edge", Position = UDim2.fromOffset(r, 0), Size = UDim2.new(1, -2 * r, 0, 1), BackgroundColor3 = C.white,
        BorderSizePixel = 0, Parent = f })
    new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.8),
        NumberSequenceKeypoint.new(1, 1) }), Parent = line })
    return outline(f, C.stroke, 1, 0.1)
end
W.tween, W.new, W.corner, W.outline, W.gradient, W.set_text, W.label = tween, new, corner, outline, gradient, set_text, label
W.pill, W.sheen, W.glass, W.PILL, W.LIQUID = pill, sheen, glass, PILL, LIQUID

-- [[ gradients that keep turning (the border light, the logo) and UIScales that follow the screen size ]] --
local spinners, scaled = {}, {}
local function spin(g, speed) table.insert(spinners, { g, speed }) return g end
local function follow(s) table.insert(scaled, s) return s end

-- [[ the logo: the dripping S, an animated sprite sheet (25 frames in a 5x5 grid, 200 px each, played at 10 a second) ]] --
-- [[ read from the workspace with getcustomasset, so nothing is uploaded to Roblox. Without the file the drawn S stays. ]] --
local LOGO_GRID, LOGO_CELL, LOGO_FRAMES, LOGO_FPS = 5, 200, 25, 10
local function load_sheet(file)
    local ok, id = pcall(function()
        if getcustomasset and isfile and isfile(file) then return getcustomasset(file) end
        return nil
    end)
    return (ok and type(id) == "string" and id ~= "") and id or nil
end
-- [[ the dripping S for the top bar and the round button; for the boot screen, a bottle pouring onto the S forever ]] --
-- [[ (the _v number is part of the file name on purpose: Roblox keeps an image it has loaded for the whole session, ]] --
-- [[ by name, so a changed picture needs a new name to show up. reports/sobriety-logo/publish.ps1 copies them.      ]] --
local logo_id = load_sheet("SobrietyHub_Logo_v4.png")
W.boot_logo_id = load_sheet("SobrietyHub_Wet_v4.png") or logo_id
W.intro_id = load_sheet("SobrietyHub_Pour_v4.png") -- the cold open: a bottle pours out and draws the S (played once)
local sprites = {}
-- [[ the frame for a moment in time (seconds) ]] --
local function logo_frame(t)
    local f = math.floor(t * LOGO_FPS) % LOGO_FRAMES
    return Vector2.new((f % LOGO_GRID) * LOGO_CELL, math.floor(f / LOGO_GRID) * LOGO_CELL)
end
local function logo_image(parent, size, z)
    if not logo_id then return nil end
    local img = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1, Image = logo_id, ImageRectSize = Vector2.new(LOGO_CELL, LOGO_CELL), ImageRectOffset = logo_frame(0), ZIndex = z,
        Parent = parent })
    table.insert(sprites, img)
    return img
end
W.logo_id, W.logo_image, W.logo_frame, W.LOGO_CELL = logo_id, logo_image, logo_frame, LOGO_CELL
-- [[ Every picture the hub uses is loaded in the background first (the three logo sheets, your avatar). Nothing is ]] --
-- [[ shown until that's done (or 6 s have passed), so no picture pops in half-way through an animation.           ]] --
W.assets_ready = false
go(function()
    local list, seen = {}, {}
    for _, id in ipairs({ logo_id or "", W.boot_logo_id or "", W.intro_id or "",
        "rbxthumb://type=AvatarHeadShot&id=" .. me.UserId .. "&w=150&h=150" }) do
        if id ~= "" and not seen[id] then
            seen[id] = true
            table.insert(list, id)
        end
    end
    -- [[ the fonts too: a label for each one (never shown) makes them load now instead of on first use ]] --
    for _, font in ipairs({ BOLD, REG, BLACK, MED, BRAND, MONO }) do
        table.insert(list, new("TextLabel", { Font = font, Text = "SOBRIETY 0123" }))
    end
    pcall(function() game:GetService("ContentProvider"):PreloadAsync(list) end)
    W.assets_ready = true
end)
W.wait_assets = function()
    local t0 = os.clock()
    while not W.assets_ready and os.clock() - t0 < 6 do task.wait(0.05) end
end
W.spin, W.follow = spin, follow

local L = { s = 1, compact = false, w = 780, h = 520, side = 198, top = 70, inset = 0, drag = Vector2.zero }
W.L = L
local function viewport()
    if S.preview_vp then return S.preview_vp end -- (only the Studio preview sets this, to look at the phone layout)
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize
    if vp and vp.X > 50 and vp.Y > 50 then return vp end
    return Vector2.new(1280, 720)
end
W.viewport = viewport
local touch_only = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local gui = new("ScreenGui", { Name = "SobrietyHub", ResetOnSpawn = false, DisplayOrder = 100, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
-- [[ where the window lives: the executor's hidden folder, else CoreGui, else (low-level executors that may use ]] --
-- [[ neither) your own PlayerGui, so the hub always opens                                                      ]] --
local okH, hidden = pcall(function() return gethui and gethui() end)
local function try_parent(p)
    if not p then return false end
    local ok = pcall(function() gui.Parent = p end)
    return ok and gui.Parent == p
end
if not (okH and try_parent(hidden)) and not try_parent(CoreGui) then
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end
pcall(function()
    for _, g in ipairs(gui.Parent:GetChildren()) do
        if g ~= gui and (g.Name == "SobrietyHub" or g.Name == "MogHub") then g:Destroy() end
    end
end)
W.gui = gui

-- [[ the window: a soft shadow, a purple glow that turns around it, and a light running along its border ]] --
local holder = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(L.w, L.h),
    BackgroundTransparency = 1, Visible = false, Parent = gui })
local scale = new("UIScale", { Scale = 1, Parent = holder })
for i, t in ipairs({ 0.6, 0.78, 0.9 }) do
    local sh = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 3 + i * 3), Size = UDim2.new(1, i * 8, 1, i * 8),
        BackgroundColor3 = C.black, BackgroundTransparency = t, BorderSizePixel = 0, ZIndex = 0, Parent = holder })
    corner(sh, 16 + i * 4)
end
do
    local glow = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 4, 1, 4),
        BackgroundTransparency = 1, ZIndex = 0, Parent = holder })
    corner(glow, 18)
    spin(new("UIGradient", { Color = ACCENT, Parent = new("UIStroke", { Color = C.white, Thickness = 5, Transparency = 0.8, Parent = glow }) }), 45)
end
local main = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.white, ClipsDescendants = true, ZIndex = 1, Parent = holder })
corner(main, 16)
new("UIGradient", { Color = ColorSequence.new(C.bg2, C.bg), Rotation = 40, Parent = main })
spin(new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.a3), ColorSequenceKeypoint.new(0.22, C.stroke),
    ColorSequenceKeypoint.new(0.78, C.stroke), ColorSequenceKeypoint.new(1, C.a1) }),
    Parent = new("UIStroke", { Color = C.white, Thickness = 1.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = main }) }), 36)
-- [[ light inside the glass: magenta pooling in the top right corner, violet in the bottom left ]] --
for _, b in ipairs({ { Vector2.new(1, 0), 135, C.a1, 0.8 }, { Vector2.new(0, 1), 315, C.a2, 0.84 } }) do
    local bloom = new("Frame", { AnchorPoint = b[1], Position = UDim2.fromScale(b[1].X, b[1].Y), Size = UDim2.fromOffset(620, 460),
        BackgroundColor3 = b[3], BorderSizePixel = 0, Parent = main })
    -- [[ (clear from the middle of the diagonal on, so the glow has no visible edge where its frame ends) ]] --
    new("UIGradient", { Rotation = b[2], Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, b[4]), NumberSequenceKeypoint.new(0.25, 0.95),
        NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1) }), Parent = bloom })
end
W.holder, W.main, W.scale = holder, main, scale

-- [[ top bar: logo, the SOBRIETY wordmark (a light sweeps over it, and now and then it glitches), what you're   ]] --
-- [[ looking at, a live status pill (FARMING / TRAINING / IDLE), hide and unload. Its bottom edge is wet: a line ]] --
-- [[ of the logo's liquid that drips into the window (see the drips further down)                                ]] --
local top = new("Frame", { Size = UDim2.new(1, 0, 0, L.top), BackgroundColor3 = C.panel, BorderSizePixel = 0, ZIndex = 3, Parent = main })
corner(top, 16)
new("Frame", { Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0.5, 0), BackgroundColor3 = C.panel, BorderSizePixel = 0, Parent = top })
do
    local line = new("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = C.white, BorderSizePixel = 0, ZIndex = 2, Parent = top })
    new("UIGradient", { Color = ACCENT, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(0.1, 0),
        NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, 0.55) }), Parent = line })
    local shine = new("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.white, BackgroundTransparency = 0.6,
        BorderSizePixel = 0, ZIndex = 2, Parent = top })
    new("UIGradient", { Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(0.7, 0), NumberSequenceKeypoint.new(1, 1) }), Parent = shine })
    local logo = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = C.white, BackgroundTransparency = logo_id and 1 or 0, ZIndex = 2, Parent = top })
    if logo_id then
        logo_image(logo, 42, 2)
    else
        corner(logo, 10)
        spin(gradient(logo, 45), 40)
        label(logo, "S", BRAND, 16, C.white, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
        spin(new("UIGradient", { Color = ColorSequence.new(C.white, C.a3), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0) }), Parent = outline(logo, C.white, 1.5, 0) }), -110)
    end
end
local brand = new("Frame", { Position = UDim2.fromOffset(56, 10), Size = UDim2.fromOffset(220, 20), BackgroundTransparency = 1, ZIndex = 2, Parent = top })
local function brand_text(color, tr)
    return label(brand, "SOBRIETY", BRAND, 15, color, { Size = UDim2.fromOffset(160, 20), TextTransparency = tr })
end
local wm_a, wm_b = brand_text(C.a3, 1), brand_text(C.indigo, 1)
local wm = brand_text(C.white, 0)
local shimmer = new("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.a1), ColorSequenceKeypoint.new(0.42, C.head),
    ColorSequenceKeypoint.new(0.5, C.white), ColorSequenceKeypoint.new(0.58, C.head), ColorSequenceKeypoint.new(1, C.a1) }), Parent = wm })
do
    local wm_w = 118
    pcall(function() wm_w = TextService:GetTextSize("SOBRIETY", 15, BRAND, Vector2.new(400, 40)).X end)
    local badge = new("Frame", { Position = UDim2.fromOffset(math.floor(wm_w) + 8, 2), Size = UDim2.fromOffset(34, 16), BackgroundColor3 = C.white,
        Parent = brand })
    corner(badge)
    pill(badge)
    sheen(badge)
    label(badge, "HUB", BRAND, 9, C.white, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
    -- [[ the wordmark's real width once its font has loaded (the guess above can be short: HUB covered "TY") ]] --
    local function fit_badge()
        local w = wm.TextBounds.X
        if w > 10 then badge.Position = UDim2.fromOffset(math.floor(w) + 8, 2) end
    end
    wm:GetPropertyChangedSignal("TextBounds"):Connect(fit_badge)
    fit_badge()
end
local sub = label(top, S.hub.game, MED, 11, C.dim, { Position = UDim2.fromOffset(56, 31), Size = UDim2.new(1, -290, 0, 14),
    TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2 })
-- [[ the open-source loader, on the header's third line; a click copies it ]] --
local LOADER = S.hub.loader or 'loadstring(game:HttpGet("https://raw.githubusercontent.com/xNovulon/SobrietyHub/main/hub.lua"))()'
W.LOADER = LOADER
local GITHUB = "https://github.com/xNovulon/SobrietyHub"
W.GITHUB = GITHUB
local HEADER_LINE = "OPEN SOURCE  ·  github.com/xNovulon/SobrietyHub  ·  made by Novulon  ·  click to copy the GitHub link"
local loader_btn = new("TextButton", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 56, 1, -5), Size = UDim2.new(1, -70, 0, 14),
    BackgroundTransparency = 1, AutoButtonColor = false, Text = HEADER_LINE, Font = MONO, TextSize = 10, TextColor3 = C.a3, TextTransparency = 0.25,
    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 2, Parent = top })
loader_btn.MouseEnter:Connect(function() loader_btn.TextTransparency = 0 end)
loader_btn.MouseLeave:Connect(function() loader_btn.TextTransparency = 0.25 end)
loader_btn.MouseButton1Click:Connect(function()
    local sc = (getgenv and getgenv().setclipboard) or setclipboard or toclipboard
    if typeof(sc) == "function" and pcall(sc, GITHUB) then
        loader_btn.Text = "GitHub link copied: " .. GITHUB
        task.delay(2, function() loader_btn.Text = HEADER_LINE end)
    end
end)
local top_pill = { frame = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -88, 0.5, 0), Size = UDim2.fromOffset(112, 28),
    BackgroundColor3 = C.card, ZIndex = 2, Parent = top }) }
glass(top_pill.frame, 14)
top_pill.dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = C.dim, Parent = top_pill.frame })
corner(top_pill.dot)
top_pill.ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1, Parent = top_pill.dot })
corner(top_pill.ring)
top_pill.ring_stroke = outline(top_pill.ring, C.good, 1.5, 1)
top_pill.text = label(top_pill.frame, "IDLE", BOLD, 11, C.dim, { Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -32, 1, 0) })
W.top_pill = top_pill
local function top_button(text, x)
    local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0), Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = C.card, AutoButtonColor = false, Text = text, Font = BOLD, TextSize = 14, TextColor3 = C.dim, ZIndex = 2, Parent = top })
    corner(b)
    local st = outline(b, C.stroke, 1, 0)
    if not touch_only then
        b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = C.card2, TextColor3 = C.text }) tween(st, 0.15, { Color = C.a1 }) end)
        b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = C.card, TextColor3 = C.dim }) tween(st, 0.15, { Color = C.stroke }) end)
    end
    return b
end
local close = top_button("X", -14) -- (a plain X: the ✕ symbol isn't in the font and showed as a box)
local minimize = top_button("–", -50)

-- [[ sidebar: a glass dock floating inside the window. The tabs (a blob of liquid flows to the open one), then you ]] --
-- [[ at the bottom                                                                                                ]] --
local side = new("Frame", { Position = UDim2.fromOffset(10, L.top + 12), Size = UDim2.new(0, L.side - 16, 1, -L.top - 22), BackgroundColor3 = C.panel,
    BorderSizePixel = 0, ZIndex = 2, Parent = main })
glass(side, 14)
local tab_list = new("ScrollingFrame", { Position = UDim2.fromOffset(8, 10), Size = UDim2.new(1, -16, 1, -80), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 2, Parent = side })
local TAB_H, TAB_GAP = 31, 3 -- (all 11 tabs fit above your card without scrolling)
local indicator = new("Frame", { Size = UDim2.new(1, 0, 0, TAB_H), BackgroundColor3 = C.white, BorderSizePixel = 0, Visible = false, ZIndex = 1,
    Parent = tab_list })
corner(indicator, 10)
pill(indicator)
sheen(indicator, 10, 0.8)
outline(indicator, C.a3, 1, 0.6)
local tab_inner = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 2, Parent = tab_list })
new("UIListLayout", { Padding = UDim.new(0, TAB_GAP), SortOrder = Enum.SortOrder.LayoutOrder, Parent = tab_inner })
local me_card = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -8), Size = UDim2.new(1, -16, 0, 54),
    BackgroundColor3 = C.card, ZIndex = 2, Parent = side })
glass(me_card, 12)
local avatar = new("ImageLabel", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = C.card2, Image = "rbxthumb://type=AvatarHeadShot&id=" .. me.UserId .. "&w=150&h=150", Parent = me_card })
corner(avatar)
spin(new("UIGradient", { Color = ACCENT, Parent = outline(avatar, C.white, 1.5, 0) }), 70)
local me_name = label(me_card, me.DisplayName, BOLD, 13, C.text, { Position = UDim2.fromOffset(54, 9), Size = UDim2.new(1, -58, 0, 17),
    TextTruncate = Enum.TextTruncate.AtEnd })
local me_sub = label(me_card, "", REG, 11, C.dim, { Position = UDim2.fromOffset(54, 28), Size = UDim2.new(1, -58, 0, 15),
    TextTruncate = Enum.TextTruncate.AtEnd })
W.me_sub = me_sub

-- [[ pages ]] --
local content = new("Frame", { Position = UDim2.fromOffset(L.side, L.top), Size = UDim2.new(1, -L.side, 1, -L.top), BackgroundTransparency = 1,
    ClipsDescendants = true, ZIndex = 1, Parent = main })
local pages, tabs, pads = {}, {}, {}
local function tab_y(name)
    local mine, rank = tabs[name].order, 0
    for _, t in pairs(tabs) do
        if t.order < mine then rank += 1 end
    end
    return rank * (TAB_H + TAB_GAP)
end
local function select_tab(name)
    if W.current == name or not pages[name] then return end
    local first = W.current == nil
    W.current = name
    for n, t in pairs(tabs) do
        local on = n == name
        tween(t.text, 0.2, { TextColor3 = on and C.text or C.dim })
        tween(t.icon, 0.2, { TextTransparency = on and 0 or 0.4 })
        pages[n].Visible = on
    end
    local p = pages[name]
    p.Position = UDim2.fromOffset(0, 18)
    tween(p, 0.4, { Position = UDim2.fromOffset(0, 0) })
    local y = tab_y(name)
    indicator.Visible = true
    if first then
        indicator.Position = UDim2.fromOffset(0, y)
    else
        -- [[ the blob flows: it stretches from the old tab to the new one, then pulls itself together there ]] --
        local from = indicator.Position.Y.Offset
        tween(indicator, 0.16, { Position = UDim2.fromOffset(0, math.min(from, y)), Size = UDim2.new(1, 0, 0, math.abs(y - from) + TAB_H) },
            Enum.EasingStyle.Quad)
        task.delay(0.16, function()
            if W.current == name and indicator.Parent then
                tween(indicator, 0.3, { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, TAB_H) }, Enum.EasingStyle.Back)
            end
        end)
    end
    sub.Text = S.hub.game .. "  ·  " .. name
end
W.select_tab = select_tab
local function page(name, icon, order)
    local p = new("ScrollingFrame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.a1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y, Visible = false, Parent = content })
    table.insert(pads, new("UIPadding", { PaddingTop = UDim.new(0, 20), PaddingBottom = UDim.new(0, 18), PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 18), Parent = p }))
    new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = p })
    local b = new("TextButton", { Size = UDim2.new(1, 0, 0, TAB_H), BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
        LayoutOrder = order, Parent = tab_inner })
    local ic = label(b, icon, BOLD, 15, C.text, { Position = UDim2.fromOffset(10, 0), Size = UDim2.new(0, 24, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 0.4 })
    local t = label(b, name, BOLD, 13, C.dim, { Position = UDim2.fromOffset(42, 0), Size = UDim2.new(1, -46, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
    if not touch_only then
        b.MouseEnter:Connect(function()
            if W.current ~= name then tween(t, 0.15, { TextColor3 = C.text }) tween(ic, 0.15, { TextTransparency = 0.1 }) end
        end)
        b.MouseLeave:Connect(function()
            if W.current ~= name then tween(t, 0.15, { TextColor3 = C.dim }) tween(ic, 0.15, { TextTransparency = 0.4 }) end
        end)
    end
    b.MouseButton1Click:Connect(function() select_tab(name) end)
    pages[name], tabs[name] = p, { button = b, text = t, icon = ic, order = order }
    return p
end
W.page = page

-- [[ building blocks ]] --
local order = 0
local function next_order() order += 1 return order end
W.next_order = next_order
-- [[ a click ripple (mouse and touch positions don't count the top bar inset; this window's positions do) ]] --
local function ripple(b, pos)
    if not b.Parent then return end
    local s = math.max(L.s, 0.01)
    local rel = (Vector2.new(pos.X, pos.Y + L.inset) - b.AbsolutePosition) / s
    local size = math.max(b.AbsoluteSize.X, b.AbsoluteSize.Y) / s * 2.4
    local r = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(rel.X, rel.Y), Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = C.white, BackgroundTransparency = 0.78, BorderSizePixel = 0, ZIndex = 0, Parent = b })
    corner(r)
    tween(r, 0.55, { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
    task.delay(0.6, function() r:Destroy() end)
end
local function rippled(b)
    b.ClipsDescendants = true
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then ripple(b, input.Position) end
    end)
end
local function pressable(b)
    local s = new("UIScale", { Parent = b })
    b.MouseButton1Down:Connect(function() tween(s, 0.1, { Scale = 0.93 }) end)
    b.MouseButton1Up:Connect(function() tween(s, 0.25, { Scale = 1 }, Enum.EasingStyle.Back) end)
    b.MouseLeave:Connect(function() tween(s, 0.2, { Scale = 1 }) end)
    rippled(b)
    return s
end
W.rippled, W.pressable = rippled, pressable
-- [[ text that wraps grows its card to fit, so nothing is cut off however narrow the screen is ]] --
local function measure(l, font)
    local s = math.max(L.s, 0.01)
    local w = l.AbsoluteSize.X / s
    if w < 20 then return nil end
    local plain = l.Text
    if l.RichText then plain = (plain:gsub("<[^>]->", ""):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&amp;", "&")) end
    local ok, v = pcall(function() return TextService:GetTextSize(plain, l.TextSize, font or l.Font, Vector2.new(w, 10000)) end)
    return ok and v.Y or nil
end
local function fit(l, f, top_pad, bottom_pad, min_h, font)
    local function refit()
        if not f.Parent then return end
        local h = measure(l, font)
        if not h then return end
        local want = math.max(min_h, math.ceil(h) + top_pad + bottom_pad)
        if f.Size.Y.Offset ~= want then f.Size = UDim2.new(f.Size.X.Scale, f.Size.X.Offset, 0, want) end
    end
    l:GetPropertyChangedSignal("Text"):Connect(refit)
    l:GetPropertyChangedSignal("AbsoluteSize"):Connect(refit)
    task.defer(refit)
end
W.fit = fit
local function card(p, height)
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = C.card, LayoutOrder = next_order(), Parent = p })
    glass(f, 14)
    return f
end
-- [[ section headers: a bead of liquid, the title, and a line that thins out to the right ]] --
local function section(p, text)
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = next_order(), Parent = p })
    local bead = new("Frame", { Position = UDim2.fromOffset(3, 15), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = f })
    corner(bead)
    gradient(bead, 90)
    label(f, text, BOLD, 11, C.head, { Position = UDim2.fromOffset(18, 10), Size = UDim2.new(1, -20, 0, 19), TextTruncate = Enum.TextTruncate.AtEnd })
    local line = new("Frame", { Position = UDim2.new(0, 18, 1, -1), Size = UDim2.new(1, -18, 0, 1), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = f })
    new("UIGradient", { Color = ACCENT, Transparency = NumberSequence.new(0.45, 1), Parent = line })
    return f
end
-- [[ title + a description that wraps (the card grows with it); single = one line, for cards with their own layout ]] --
local function titled(f, title_text, desc, single)
    label(f, title_text, BOLD, 14, C.text, { Position = UDim2.fromOffset(16, desc and 11 or 0), Size = UDim2.new(1, -136, 0, desc and 18 or 48),
        TextTruncate = Enum.TextTruncate.AtEnd })
    if not desc then return nil end
    if single then
        return label(f, desc, REG, 12, C.dim, { Position = UDim2.fromOffset(16, 30), Size = UDim2.new(1, -32, 0, 16), TextTruncate = Enum.TextTruncate.AtEnd })
    end
    local d = label(f, desc, REG, 12, C.dim, { Position = UDim2.fromOffset(16, 31), Size = UDim2.new(1, -136, 1, -42), TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top })
    fit(d, f, 31, 12, 68)
    return d
end
local function hover(hit, f)
    if touch_only then return end
    local st = f:FindFirstChildOfClass("UIStroke")
    hit.MouseEnter:Connect(function()
        tween(f, 0.18, { BackgroundColor3 = C.card2 })
        if st then tween(st, 0.18, { Color = C.a2, Transparency = 0 }) end
    end)
    hit.MouseLeave:Connect(function()
        tween(f, 0.18, { BackgroundColor3 = C.card })
        if st then tween(st, 0.18, { Color = C.stroke, Transparency = 0.1 }) end
    end)
end
local function toggle(p, title_text, desc, get, set, off_key)
    local f = card(p, desc and 68 or 48)
    local desc_label = titled(f, title_text, desc)
    -- [[ the switch: an empty tube; switched on, liquid runs in from the left and carries the knob across ]] --
    local sw = new("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(48, 26),
        BackgroundColor3 = C.ink, Parent = f })
    corner(sw)
    local sw_stroke = outline(sw, C.stroke, 1, 0)
    local fill = new("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = sw })
    corner(fill)
    new("UIGradient", { Color = LIQUID, Parent = fill })
    sheen(fill, nil, 0.68)
    local knob = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 13, 0.5, 0), Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = C.dim, ZIndex = 2, Parent = sw })
    corner(knob)
    local state = label(f, "OFF", BOLD, 10, C.dim, { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -72, 0.5, 0),
        Size = UDim2.fromOffset(30, 14), TextXAlignment = Enum.TextXAlignment.Right })
    -- [[ a switched-on card gets a glowing edge on its left ]] --
    local edge = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 3, 0, 0),
        BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = f })
    corner(edge, 2)
    gradient(edge, 90)
    local hit = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 2, Parent = f })
    hover(hit, f)
    rippled(hit)
    local shown = nil
    local function paint()
        local on = get() == true
        local why_off = off_key and not on and S.auto_off[off_key] or nil
        local look = tostring(on) .. tostring(why_off)
        if shown == look then return end
        local t = shown == nil and 0 or 0.28
        shown = look
        if desc_label then
            desc_label.Text = why_off and ("Turned itself off: " .. why_off .. ". Turn it on to try again.") or desc
            desc_label.TextColor3 = why_off and Color3.fromRGB(255, 178, 122) or C.dim
        end
        tween(knob, t, { Position = on and UDim2.new(1, -13, 0.5, 0) or UDim2.new(0, 13, 0.5, 0), BackgroundColor3 = on and C.white or C.dim },
            Enum.EasingStyle.Back)
        if t > 0 then
            -- [[ the knob squashes as it sets off and rounds out again where it lands, like a drop ]] --
            knob.Size = UDim2.fromOffset(27, 17)
            tween(knob, 0.4, { Size = UDim2.fromOffset(20, 20) }, Enum.EasingStyle.Back)
        end
        tween(fill, t * 1.2, { Size = on and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Quad)
        tween(sw_stroke, t, { Color = on and C.a3 or C.stroke, Transparency = on and 0.4 or 0 })
        tween(edge, t, { Size = on and UDim2.new(0, 3, 0.55, 0) or UDim2.new(0, 3, 0, 0) })
        state.Text = on and "ON" or "OFF"
        state.TextColor3 = on and C.a3 or C.dim
    end
    hit.MouseButton1Click:Connect(function()
        if off_key then S.auto_off[off_key] = nil end
        set(not get())
        paint()
    end)
    table.insert(W.painters, paint)
    paint()
    return f
end
-- [[ a row of choices; the picked one sits under a gradient pill that slides between them ]] --
local function segmented(p, title_text, options, get, set)
    local f = card(p, 84)
    label(f, title_text, BOLD, 14, C.text, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 0, 18), TextTruncate = Enum.TextTruncate.AtEnd })
    local row = new("Frame", { Position = UDim2.fromOffset(16, 38), Size = UDim2.new(1, -32, 0, 34), BackgroundColor3 = C.ink, Parent = f })
    corner(row, 11)
    outline(row, C.stroke, 1, 0.2)
    local n = #options
    local slider = new("Frame", { Position = UDim2.new(0, 3, 0, 3), Size = UDim2.new(1 / n, -6, 1, -6), BackgroundColor3 = C.white,
        Visible = false, ZIndex = 1, Parent = row })
    corner(slider, 9)
    pill(slider)
    sheen(slider, 9, 0.78)
    outline(slider, C.a3, 1, 0.6)
    local buttons = {}
    local paint
    for i, opt in ipairs(options) do
        local b = new("TextButton", { Position = UDim2.new((i - 1) / n, 0, 0, 0), Size = UDim2.new(1 / n, 0, 1, 0), BackgroundTransparency = 1,
            AutoButtonColor = false, Text = opt[2], Font = BOLD, TextSize = 12, TextColor3 = C.dim, TextWrapped = true, ZIndex = 2, Parent = row })
        new("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), Parent = b })
        buttons[i] = { value = opt[1], button = b }
        b.MouseButton1Click:Connect(function()
            set(opt[1])
            paint()
        end)
    end
    local at = nil
    paint = function()
        local value, idx = get(), nil
        for i, x in ipairs(buttons) do
            local on = x.value == value
            if on then idx = i end
            x.button.TextColor3 = on and C.white or C.dim
        end
        if idx == at then return end
        local was = at
        at = idx
        if not idx then
            slider.Visible = false
            return
        end
        local pos = UDim2.new((idx - 1) / n, 3, 0, 3)
        if was == nil then
            slider.Position = pos
        else
            -- [[ the liquid stretches towards the new choice, then gathers under it ]] --
            local lo, hi = math.min(was, idx), math.max(was, idx)
            tween(slider, 0.15, { Position = UDim2.new((lo - 1) / n, 3, 0, 3), Size = UDim2.new((hi - lo + 1) / n, -6, 1, -6) }, Enum.EasingStyle.Quad)
            task.delay(0.15, function()
                if at == idx and slider.Parent then tween(slider, 0.28, { Position = pos, Size = UDim2.new(1 / n, -6, 1, -6) }) end
            end)
        end
        slider.Visible = true
    end
    table.insert(W.painters, paint)
    paint()
end
local function action(p, title_text, desc, button_text, fn)
    local f = card(p, desc and 68 or 48)
    titled(f, title_text, desc)
    local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -16, 0.5, 0), Size = UDim2.fromOffset(100, 32),
        BackgroundColor3 = C.white, AutoButtonColor = false, Text = button_text, Font = BOLD, TextSize = 12, TextColor3 = C.white, Parent = f })
    corner(b, 10)
    gradient(b, 90)
    local glow = outline(b, C.a3, 1, 0.55)
    pressable(b)
    if not touch_only then
        -- [[ pointing at it: its edge lights up and a drip gathers under it ]] --
        local stem = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(1, -40, 0.5, 14), Size = UDim2.fromOffset(4, 0),
            BackgroundColor3 = C.a2, BorderSizePixel = 0, Parent = f })
        corner(stem)
        local bulb = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -40, 0.5, 15), Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = C.a2, BorderSizePixel = 0, Parent = f })
        corner(bulb)
        b.MouseEnter:Connect(function()
            tween(glow, 0.15, { Transparency = 0.05 })
            tween(stem, 0.5, { Size = UDim2.fromOffset(4, 9) }, Enum.EasingStyle.Quad)
            tween(bulb, 0.5, { Position = UDim2.new(1, -40, 0.5, 24), Size = UDim2.fromOffset(7, 7) }, Enum.EasingStyle.Quad)
        end)
        b.MouseLeave:Connect(function()
            tween(glow, 0.15, { Transparency = 0.55 })
            tween(stem, 0.25, { Size = UDim2.fromOffset(4, 0) })
            tween(bulb, 0.25, { Position = UDim2.new(1, -40, 0.5, 15), Size = UDim2.fromOffset(0, 0) })
        end)
    end
    b.MouseButton1Click:Connect(fn)
    return f
end
local function info(p, height)
    local f = card(p, height or 48)
    f.BackgroundColor3 = Color3.fromRGB(18, 13, 30)
    local bar = new("Frame", { Position = UDim2.fromOffset(0, 10), Size = UDim2.new(0, 3, 1, -20), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = f })
    corner(bar, 2)
    gradient(bar, 90)
    local l = label(f, "", REG, 12, C.dim, { Position = UDim2.fromOffset(16, 9), Size = UDim2.new(1, -32, 1, -18), TextWrapped = true,
        RichText = true, TextYAlignment = Enum.TextYAlignment.Top })
    fit(l, f, 9, 9, 36, BOLD)
    return l
end
-- [[ number tiles: liquid stands in the bottom of each one and rocks gently; when the number changes it flashes ]] --
-- [[ and the liquid jumps                                                                                       ]] --
local pools = {}
local function stats(p, names)
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, 74), BackgroundTransparency = 1, LayoutOrder = next_order(), Parent = p })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), Parent = f })
    local values = {}
    for _, n in ipairs(names) do
        local s = new("Frame", { Size = UDim2.new(1 / #names, -10 * (#names - 1) / #names, 1, 0), BackgroundColor3 = C.card, Parent = f })
        glass(s, 14)
        local pool = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = s })
        corner(pool, 14)
        local g = new("UIGradient", { Rotation = 90, Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C.a3), ColorSequenceKeypoint.new(0.78, C.a3),
            ColorSequenceKeypoint.new(0.9, C.a1), ColorSequenceKeypoint.new(1, C.a2) }), Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.795, 1), NumberSequenceKeypoint.new(0.8, 0.45),
            NumberSequenceKeypoint.new(0.825, 0.82), NumberSequenceKeypoint.new(1, 0.68) }), Parent = pool })
        local me_pool = { g, #pools * 1.7, 0 }
        table.insert(pools, me_pool)
        label(s, n:upper(), BOLD, 10, C.dim, { Position = UDim2.fromOffset(14, 11), Size = UDim2.new(1, -20, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd })
        local v = label(s, "-", BLACK, 21, C.text, { Position = UDim2.fromOffset(14, 26), Size = UDim2.new(1, -20, 0, 28),
            TextTruncate = Enum.TextTruncate.AtEnd })
        v:GetPropertyChangedSignal("Text"):Connect(function()
            v.TextColor3 = C.a3
            tween(v, 0.7, { TextColor3 = C.text })
            me_pool[3] = 0.09
        end)
        values[n] = v
    end
    return values
end
W.card, W.section, W.titled, W.hover, W.toggle, W.segmented, W.action, W.info, W.stats = card, section, titled, hover, toggle, segmented, action, info, stats
-- [[ Credits (every hub puts this on its Settings page): who made it, that it's open source, and the loader ]] --
-- [[ Credits: its own tab in the side menu, last (every hub calls this; the page argument is from when it lived ]] --
-- [[ in Settings and is ignored now)                                                                          ]] --
-- [[ the hide / show key: Right Alt unless you picked another one in Settings (S.hide_key, saved per account) ]] --
local function key_name(k)
    local n = tostring(k or "RightAlt"):gsub("(%l)(%u)", "%1 %2")
    return n
end
W.key_name = key_name
-- [[ Settings: pick the hide / show key. Click the button, press a key (Escape cancels). Not on phones (no keys) ]] --
function W.keybind(p)
    if touch_only then return end
    section(p, "HIDE / SHOW KEY")
    local b = nil
    local f = action(p, "Hide / show key", "Click, then press the key you want (Escape cancels). On phones: the - button and the round S button", key_name(S.hide_key),
        function()
            if S.binding_key or not b then return end
            S.binding_key = true
            set_text(b, "PRESS A KEY")
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
                conn:Disconnect()
                if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode.Name ~= "Unknown" then S.hide_key = input.KeyCode.Name end
                set_text(b, key_name(S.hide_key))
                task.delay(0.3, function() S.binding_key = false end)
            end)
        end)
    for _, d in ipairs(f:GetChildren()) do
        if d:IsA("TextButton") then b = d end
    end
end
function W.credits(p)
    -- [[ called from each hub's Settings code: the key picker goes there, the credits get their own tab ]] --
    if p then W.keybind(p) end
    if W.credits_made then return end
    W.credits_made = true
    local p = page("Credits", "⭐", 99)
    local function copy(text)
        local sc = (getgenv and getgenv().setclipboard) or setclipboard or toclipboard
        if typeof(sc) == "function" then pcall(sc, text) end
    end
    section(p, "SOBRIETY HUB")
    local t = info(p, 74)
    t.Text = "<b>Sobriety Hub</b>  ·  " .. tostring(S.hub.game) .. "\nMade by <b>Novulon</b>"
        .. "\nDiscord: <b>1z11</b> (suggestions and script requests only)"
    section(p, "OPEN SOURCE")
    local o = info(p, 74)
    o.Text = "Open source and free to use: <b>github.com/xNovulon/SobrietyHub</b>"
        .. "\nIf you use this work to make a new script or an updated version, I'd appreciate a credit."
    action(p, "Copy the GitHub link", GITHUB, "COPY", function() copy(GITHUB) end)
    action(p, "Copy the loader", LOADER, "COPY", function() copy(LOADER) end)
end

-- [[ the round S button: shows while the window is hidden; tap it to open the window, drag it anywhere ]] --
local bubble = new("TextButton", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 44, 0.42, 0), Size = UDim2.fromOffset(54, 54),
    BackgroundColor3 = C.white, AutoButtonColor = false, Text = "", Visible = false, ZIndex = 20, Parent = gui })
corner(bubble)
if logo_id then
    bubble.BackgroundTransparency = 1
    logo_image(bubble, 66, 20)
else
    pill(bubble)
    sheen(bubble, nil, 0.7)
    label(bubble, "S", BRAND, 22, C.white, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
    spin(new("UIGradient", { Color = ColorSequence.new(C.white, C.a3), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0) }), Parent = outline(bubble, C.white, 2, 0) }), -140)
end
follow(new("UIScale", { Parent = bubble }))

-- [[ the drips: liquid gathers under the top bar's wet edge, swells, lets a drop go and pulls back. Each has its own ]] --
-- [[ place, thickness, reach and timing; they're drawn over the page, in the colour the edge has at that spot        ]] --
local drip_row = new("Frame", { Position = UDim2.fromOffset(0, L.top - 1), Size = UDim2.new(1, 0, 0, 90), BackgroundTransparency = 1, ZIndex = 4,
    Parent = main })
local drips = {}
for i, d in ipairs({ { 0.06, 3, 9, 0.00, 6.5 }, { 0.3, 4, 13, 0.30, 7.4 }, { 0.52, 3, 7, 0.80, 5.8 }, { 0.72, 4, 11, 0.15, 6.9 },
    { 0.93, 3, 8, 0.55, 6.1 } }) do
    local x, w = d[1], d[2]
    local col = x < 0.5 and C.a3:Lerp(C.a1, x * 2) or C.a1:Lerp(C.a2, (x - 0.5) * 2)
    -- [[ where it leaves the edge the liquid is wider (a low mound), so the drip grows out of the edge instead of ]] --
    -- [[ hanging off it like a pin                                                                                ]] --
    for _, m in ipairs({ { 2.6, 2, 3 }, { 1.7, 1, 5 } }) do
        corner(new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(x, 0, 0, -1), Size = UDim2.fromOffset(math.floor(w * m[1] + m[2]), m[3]),
            BackgroundColor3 = col, BorderSizePixel = 0, Parent = drip_row }))
    end
    local stem = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(x, 0), Size = UDim2.fromOffset(w, 3),
        BackgroundColor3 = col, BorderSizePixel = 0, Parent = drip_row })
    corner(stem)
    local bulb = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(x, 0, 0, 3), Size = UDim2.fromOffset(w + 2, w + 2),
        BackgroundColor3 = col, BorderSizePixel = 0, Parent = drip_row })
    corner(bulb)
    -- [[ a point of light on the bulb: it's wet ]] --
    local glint = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.34, 0.34), Size = UDim2.fromScale(0.3, 0.3),
        BackgroundColor3 = C.white, BackgroundTransparency = 0.25, BorderSizePixel = 0, Parent = bulb })
    corner(glint)
    local drop = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(x, 0, 0, 3), Size = UDim2.fromOffset(w, w + 2),
        BackgroundColor3 = col, BorderSizePixel = 0, Visible = false, Parent = drip_row })
    corner(drop)
    drips[i] = { stem = stem, bulb = bulb, drop = drop, x = x, w = w, len = d[3], phase = d[4], period = d[5] }
end
local function ease(k) return k * k * (3 - 2 * k) end
local function move_drips(t)
    for _, d in ipairs(drips) do
        local u = (t / d.period + d.phase) % 1
        local len
        if u < 0.72 then
            local k = ease(u / 0.72)
            len = d.len * (0.3 + 0.7 * k)
            d.bulb.Size = UDim2.fromOffset(d.w + 2 + 3 * k, d.w + 2 + 3 * k)
            d.drop.Visible = false
        else
            local v = (u - 0.72) / 0.28
            len = d.len * (1 - 0.7 * ease(math.min(1, v / 0.5)))
            d.bulb.Size = UDim2.fromOffset(d.w + 2, d.w + 2)
            d.drop.Visible = true
            d.drop.Position = UDim2.new(d.x, 0, 0, d.len + 2 + 52 * v * v)
            d.drop.Size = UDim2.fromOffset(d.w * (1 - 0.3 * v), (d.w + 2) * (1 + 0.5 * v))
            d.drop.BackgroundTransparency = v * v
        end
        d.stem.Size = UDim2.fromOffset(d.w, len)
        d.bulb.Position = UDim2.new(d.x, 0, 0, len)
    end
end
move_drips(0)

-- [[ size and place, from the screen: a big screen gets a bigger window, a small one (a phone) gets the compact ]] --
-- [[ layout; a window you dragged stays where you put it but always on the screen                              ]] --
local shown = false
local function place() return UDim2.new(0.5, L.drag.X, 0.5, L.inset / 2 + L.drag.Y) end
W.place = place
local function layout(animate)
    local vp = viewport()
    local inset = 0
    pcall(function() inset = GuiService:GetGuiInset().Y end)
    local ax, ay = vp.X, vp.Y - inset
    local compact = ax < 760 or ay < 470
    local s
    if compact then s = math.clamp(math.min(ax / 700, ay / 430), 0.6, 1) else s = math.clamp(ay / 980, 0.85, 1.3) end
    s *= tonumber(S.ui_size) or 1
    local w = math.floor(math.min(compact and 760 or 800, (ax - 16) / s))
    local h = math.floor(math.min(compact and 480 or 540, (ay - 16) / s))
    L.s, L.compact, L.w, L.h, L.inset = s, compact, w, h, inset
    L.side, L.top = compact and 60 or 198, compact and 64 or 70
    local mx, my = math.max(0, (ax - w * s) / 2 - 4), math.max(0, (ay - h * s) / 2 - 4)
    L.drag = Vector2.new(math.clamp(L.drag.X, -mx, mx), math.clamp(L.drag.Y, -my, my))
    local t = animate and 0.3 or 0
    if shown then tween(scale, t, { Scale = s }) else scale.Scale = s end
    tween(holder, t, { Size = UDim2.fromOffset(w, h), Position = place() })
    top.Size = UDim2.new(1, 0, 0, L.top)
    brand.Position = UDim2.fromOffset(56, compact and 7 or 10)
    sub.Position = UDim2.fromOffset(56, compact and 27 or 31)
    local dock = compact and 8 or 10
    tween(side, t, { Position = UDim2.fromOffset(dock, L.top + dock + 2), Size = UDim2.new(0, L.side - dock - 6, 1, -L.top - 2 * dock - 2) })
    tween(content, t, { Position = UDim2.fromOffset(L.side, L.top), Size = UDim2.new(1, -L.side, 1, -L.top) })
    drip_row.Position = UDim2.fromOffset(0, L.top - 1)
    tab_list.Position = UDim2.fromOffset(compact and 5 or 8, 10)
    tab_list.Size = UDim2.new(1, compact and -10 or -16, 1, compact and -66 or -80)
    for _, tb in pairs(tabs) do
        tb.text.Visible = not compact
        tb.icon.Position = compact and UDim2.new() or UDim2.fromOffset(10, 0)
        tb.icon.Size = compact and UDim2.fromScale(1, 1) or UDim2.new(0, 24, 1, 0)
    end
    me_name.Visible, me_sub.Visible = not compact, not compact
    me_card.Size = compact and UDim2.new(1, -10, 0, 46) or UDim2.new(1, -16, 0, 54)
    me_card.Position = compact and UDim2.new(0, 5, 1, -5) or UDim2.new(0, 8, 1, -8)
    avatar.Position = compact and UDim2.new(0.5, -16, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
    avatar.Size = compact and UDim2.fromOffset(32, 32) or UDim2.fromOffset(38, 38)
    for _, pad in ipairs(pads) do
        pad.PaddingLeft, pad.PaddingRight = UDim.new(0, compact and 6 or 10), UDim.new(0, compact and 12 or 18)
        pad.PaddingTop = UDim.new(0, compact and 16 or 20)
    end
    for i = #scaled, 1, -1 do
        if scaled[i].Parent then scaled[i].Scale = s else table.remove(scaled, i) end
    end
end
W.layout = layout
do
    local cam_conn = nil
    local function watch_camera()
        if cam_conn then cam_conn:Disconnect() end
        local cam = workspace.CurrentCamera
        if cam then cam_conn = track(cam:GetPropertyChangedSignal("ViewportSize"):Connect(function() layout(true) end)) end
    end
    watch_camera()
    track(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        watch_camera()
        layout(true)
    end))
end

-- [[ show / hide (the S button takes the window's place while it's hidden) ]] --
local function pop_bubble(on)
    if on then
        bubble.Visible = true
        bubble.Size = UDim2.fromOffset(0, 0)
        tween(bubble, 0.4, { Size = UDim2.fromOffset(54, 54) }, Enum.EasingStyle.Back)
    else
        tween(bubble, 0.2, { Size = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.2, function() if shown then bubble.Visible = false end end)
    end
end
local function show()
    if shown then return end
    shown = true
    holder.Visible = true
    scale.Scale = L.s * 0.9
    tween(scale, 0.45, { Scale = L.s }, Enum.EasingStyle.Back)
    pop_bubble(false)
end
local function hide()
    if not shown then return end
    shown = false
    tween(scale, 0.2, { Scale = L.s * 0.9 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    task.delay(0.2, function() if not shown then holder.Visible = false end end)
    pop_bubble(true)
end
W.show, W.hide = show, hide
-- [[ the first time it appears: once every picture is loaded, it eases in. (It used to flicker in by hiding its  ]] --
-- [[ contents for two frames, which left only the window's dark shadow on screen: a black flash.)                ]] --
W.reveal = function()
    go(function()
        W.wait_assets()
        if holder.Parent then
            show()
            -- [[ say which key hides it (people can't guess Right Alt) ]] --
            task.delay(4, function()
                if type(notify) == "function" then
                    pcall(notify, touch_only and "The - button hides this window; the round S button brings it back."
                        or ("%s hides / shows this window (change it in Settings). The - button does it too."):format(key_name(S.hide_key)))
                end
            end)
        end
    end)
end
minimize.MouseButton1Click:Connect(hide)
track(UserInputService.InputBegan:Connect(function(input, processed)
    if S.binding_key or processed or input.KeyCode.Name ~= (S.hide_key or "RightAlt") then return end
    if shown then hide() else show() end
end))
-- [[ X asks first (one stray tap on a phone shouldn't unload everything): tap it again within 3s to unload ]] --
do
    local armed = -100
    local tip = label(main, "Tap X again to unload", BOLD, 11, C.white, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 62),
        Size = UDim2.fromOffset(160, 26), BackgroundColor3 = C.bad, BackgroundTransparency = 0, TextXAlignment = Enum.TextXAlignment.Center,
        Visible = false, ZIndex = 10 })
    corner(tip, 8)
    close.MouseButton1Click:Connect(function()
        if os.clock() - armed < 3 then
            local stop = env[S.hub.stop]
            if stop then stop() end
            return
        end
        armed = os.clock()
        tip.Position = UDim2.new(1, -10, 0, L.top + 6)
        tip.Visible = true
        tween(close, 0.15, { BackgroundColor3 = C.bad, TextColor3 = C.white })
        task.delay(3, function()
            if tip.Parent and os.clock() - armed >= 2.95 then
                tip.Visible = false
                tween(close, 0.2, { BackgroundColor3 = C.card, TextColor3 = C.dim })
            end
        end)
    end)
end
-- [[ dragging: the window by its top bar, the S button anywhere (a short tap on it opens the window). On a ]] --
-- [[ phone only the finger that started the drag moves it, so the joystick thumb doesn't drag it along.     ]] --
local function draggable(handle, on_move, on_end)
    local down, start = nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            down, start = input, input.Position
            on_move(nil)
        end
    end)
    track(UserInputService.InputChanged:Connect(function(input)
        if not down then return end
        local touch = down.UserInputType == Enum.UserInputType.Touch
        if (touch and input == down) or (not touch and input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - start
            on_move(Vector2.new(d.X, d.Y))
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if down and (input == down or input.UserInputType == Enum.UserInputType.MouseButton1) then
            down = nil
            on_end()
        end
    end))
end
do
    local from = Vector2.zero
    draggable(top, function(d)
        if not d then from = L.drag return end
        if not shown then return end
        L.drag = from + d
        holder.Position = place()
    end, function() layout(false) end)
end
do
    local from, moved = bubble.Position, false
    draggable(bubble, function(d)
        if not d then from, moved = bubble.Position, false return end
        if d.Magnitude > 6 then moved = true end
        if moved then bubble.Position = UDim2.new(from.X.Scale, from.X.Offset + d.X, from.Y.Scale, from.Y.Offset + d.Y) end
    end, function()
        if not moved and bubble.Visible then show() end
        moved = false
    end)
end

-- [[ animation: the turning gradients and the light sweeping over the wordmark (only while something is on screen), ]] --
-- [[ the status dot's pulse, and a short glitch on SOBRIETY every few seconds                                        ]] --
do
    local t0 = os.clock()
    track(RunService.Heartbeat:Connect(function()
        if not (gui.Parent and (shown or bubble.Visible)) then return end
        local t = os.clock() - t0
        for i = #spinners, 1, -1 do
            local sp = spinners[i]
            if sp[1].Parent then sp[1].Rotation = (t * sp[2]) % 360 else table.remove(spinners, i) end
        end
        if #sprites > 0 then
            local off = logo_frame(t)
            for i = #sprites, 1, -1 do
                local sp = sprites[i]
                if sp.Parent then sp.ImageRectOffset = off else table.remove(sprites, i) end
            end
        end
        shimmer.Offset = Vector2.new(((t % 4) / 4) * 3 - 1.5, 0)
        if shown then
            move_drips(t)
            for i = #pools, 1, -1 do
                local pl = pools[i]
                if pl[1].Parent then
                    -- [[ it sloshes: the surface tips a few degrees one way, then the other ]] --
                    pl[3] *= 0.93
                    pl[1].Rotation = 90 + 3.2 * math.sin(t * 1.15 + pl[2])
                    pl[1].Offset = Vector2.new(0, -pl[3])
                else
                    table.remove(pools, i)
                end
            end
        end
    end))
end
go(function()
    local next_glitch = os.clock() + 5
    while S.alive and gui.Parent do
        if shown then
            local col = top_pill.dot.BackgroundColor3
            if col ~= C.dim then
                top_pill.ring.Size = UDim2.fromScale(1, 1)
                top_pill.ring_stroke.Color = col
                top_pill.ring_stroke.Transparency = 0.1
                tween(top_pill.ring, 1, { Size = UDim2.fromScale(3.2, 3.2) })
                tween(top_pill.ring_stroke, 1, { Transparency = 1 })
            end
            if os.clock() > next_glitch then
                next_glitch = os.clock() + 6 + math.random() * 8
                for _ = 1, 7 do
                    wm_a.TextTransparency, wm_b.TextTransparency = 0.15, 0.15
                    wm_a.Position = UDim2.fromOffset(math.random(-4, -1), math.random(-1, 1))
                    wm_b.Position = UDim2.fromOffset(math.random(1, 4), math.random(-1, 1))
                    wm.Position = UDim2.fromOffset(math.random(-1, 1), 0)
                    task.wait(0.045)
                end
                wm_a.TextTransparency, wm_b.TextTransparency = 1, 1
                wm.Position = UDim2.fromOffset(0, 0)
            end
        end
        task.wait(1.2)
    end
end)
return W
end

-- [[ The boot screen: SOBRIETY decodes out of random letters with a glitch (split colours, sliced rows, scanlines, ]] --
-- [[ noise), a loading line runs, then it shuts like an old monitor and the window flickers in. Click to skip.    ]] --
-- [[ After a server hop (the helper reloading itself) it plays a short version.                                   ]] --
local function play_boot(W, done, quick)
    local C, new, corner, tween = W.C, W.new, W.corner, W.tween
    W.wait_assets() -- (nothing on screen until every picture is loaded)
    local s = W.L.s
    local total = quick and 1.3 or 3.1
    local layer = new("TextButton", { Name = "Boot", Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.black, BackgroundTransparency = 1,
        AutoButtonColor = false, Text = "", ZIndex = 50, Parent = W.gui })
    local skipped = false
    layer.MouseButton1Click:Connect(function() skipped = true end)
    -- [[ No black screen: the boot plays on a pane of dark glass the size of the hub's window, right where the window ]] --
    -- [[ will appear, so the game stays visible around it. The pane ("screen") switches on like an old monitor: a line ]] --
    -- [[ across, then it opens. root keeps its full size inside it, so nothing moves while the screen opens.           ]] --
    local cw, ch, cr = math.floor(W.L.w * s), math.floor(W.L.h * s), math.floor(16 * s)
    local spot = W.place()
    local screen = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = spot, Size = UDim2.fromOffset(0, 2),
        BackgroundTransparency = 1, ClipsDescendants = true, Parent = layer })
    local root = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(cw - 4, ch - 4),
        BackgroundColor3 = C.bg, BackgroundTransparency = 0.02, BorderSizePixel = 0, Parent = screen })
    corner(root, cr)
    local root_stroke = new("UIStroke", { Color = C.white, Thickness = 1.4, Transparency = 0.15, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = root })
    new("UIGradient", { Color = W.ACCENT, Rotation = 30, Parent = root_stroke })
    local function power_on()
        tween(screen, 0.16, { Size = UDim2.fromOffset(cw, 2) }, Enum.EasingStyle.Quad)
        task.delay(0.16, function()
            if screen.Parent then tween(screen, 0.38, { Size = UDim2.fromOffset(cw, ch) }, Enum.EasingStyle.Quint) end
        end)
        local beam = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = spot, Size = UDim2.fromOffset(0, 2),
            BackgroundColor3 = C.a3, BorderSizePixel = 0, ZIndex = 4, Parent = layer })
        tween(beam, 0.16, { Size = UDim2.fromOffset(cw, 2) }, Enum.EasingStyle.Quad)
        task.delay(0.16, function()
            if beam.Parent then tween(beam, 0.3, { BackgroundTransparency = 1 }) end
        end)
        task.delay(0.5, function() beam:Destroy() end)
    end
    -- [[ the cold open (full boot only): over the game itself, a bottle pours out and draws the S. Its last frame is ]] --
    -- [[ the first of the endless pour, so it carries straight on into that; then the boot switches on around it    ]] --
    local intro_logo, wet_t0 = nil, nil
    if W.intro_id and not quick then
        local is = math.floor(200 * s)
        intro_logo = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(is, is),
            BackgroundTransparency = 1, Image = W.intro_id, ImageRectSize = Vector2.new(W.LOGO_CELL, W.LOGO_CELL), ImageRectOffset = W.logo_frame(0),
            ImageTransparency = 1, ZIndex = 5, Parent = layer })
        tween(intro_logo, 0.3, { ImageTransparency = 0 })
        local t0 = os.clock()
        while not skipped and layer.Parent and os.clock() - t0 < 2.85 do
            local t = os.clock() - t0
            if t < 2.5 then
                intro_logo.ImageRectOffset = W.logo_frame(t)
            elseif W.boot_logo_id then
                if not wet_t0 then
                    wet_t0 = os.clock()
                    intro_logo.Image = W.boot_logo_id
                end
                intro_logo.ImageRectOffset = W.logo_frame(os.clock() - wet_t0)
            end
            task.wait(1 / 30)
        end
    end
    -- [[ a faint grid drifting behind (kept clear of the pane's round corners), a purple bloom in the middle, dark edges ]] --
    local grid = new("Frame", { Position = UDim2.fromOffset(cr, cr), Size = UDim2.new(1, -2 * cr, 1, -2 * cr), BackgroundTransparency = 1,
        ClipsDescendants = true, Parent = root })
    local grid_in = new("Frame", { Position = UDim2.fromOffset(-48, -48), Size = UDim2.new(1, 96, 1, 96), BackgroundTransparency = 1, Parent = grid })
    for x = 0, cw + 96, 48 do
        new("Frame", { Position = UDim2.fromOffset(x, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = C.a2, BackgroundTransparency = 0.93,
            BorderSizePixel = 0, Parent = grid_in })
    end
    for y = 0, ch + 96, 48 do
        new("Frame", { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.a2, BackgroundTransparency = 0.93,
            BorderSizePixel = 0, Parent = grid_in })
    end
    tween(grid_in, total + 0.5, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Linear)
    -- [[ the bloom: ten faint pills stacked from big to small, so the glow fades out softly in every direction ]] --
    for i = 1, 10 do
        local k = 1 - (i - 1) * 0.085
        local bloom = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(math.floor(cw * 0.94 * k), math.floor(ch * 0.7 * k)), BackgroundColor3 = C.a2, BackgroundTransparency = 0.968,
            BorderSizePixel = 0, Parent = root })
        corner(bloom)
    end
    for _, v in ipairs({ { 90, 0 }, { 270, 0.6 } }) do
        local edge = new("Frame", { Position = UDim2.fromScale(0, v[2]), Size = UDim2.fromScale(1, 0.4), BackgroundColor3 = C.black, BorderSizePixel = 0, Parent = root })
        corner(edge, cr)
        new("UIGradient", { Rotation = v[1], Transparency = NumberSequence.new(0.3, 1), Parent = edge })
    end
    -- [[ the title, built from six sliced rows (each can slide on its own) over two colour-split copies ]] --
    local crt = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(math.floor(700 * s), math.floor(250 * s)), BackgroundTransparency = 1, ClipsDescendants = true, Parent = root })
    local stage = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(700, 250),
        BackgroundTransparency = 1, Parent = crt })
    new("UIScale", { Scale = s, Parent = stage })
    -- [[ the animated logo above the title: fades in, or after the cold open glides up from the middle while the screen ]] --
    -- [[ switches on around it; shakes with the glitch (not while gliding), shuts with the screen                         ]] --
    local boot_logo = nil
    local ls = math.floor(130 * s)
    local logo_pos = UDim2.new(spot.X.Scale, spot.X.Offset, spot.Y.Scale, spot.Y.Offset - math.floor(98 * s))
    local glide_until = 0
    if intro_logo then
        boot_logo = intro_logo
        boot_logo.AnchorPoint = Vector2.new(0.5, 1)
        boot_logo.Position = UDim2.new(0.5, 0, 0.5, math.floor(boot_logo.Size.X.Offset / 2))
        glide_until = os.clock() + 0.6
        tween(boot_logo, 0.6, { Position = logo_pos, Size = UDim2.fromOffset(ls, ls) }, Enum.EasingStyle.Quint)
    elseif W.boot_logo_id then
        boot_logo = new("ImageLabel", { AnchorPoint = Vector2.new(0.5, 1), Position = logo_pos, Size = UDim2.fromOffset(ls, ls),
            BackgroundTransparency = 1, Image = W.boot_logo_id, ImageRectSize = Vector2.new(W.LOGO_CELL, W.LOGO_CELL), ImageRectOffset = W.logo_frame(0),
            ImageTransparency = 1, ZIndex = 5, Parent = layer })
        tween(boot_logo, 0.5, { ImageTransparency = 0 })
    end
    power_on()
    local TITLE, TAG = "SOBRIETY", "GAME DETECTED  >  " .. S.hub.tag
    local tbox = new("Frame", { Position = UDim2.fromOffset(0, 36), Size = UDim2.fromOffset(700, 84), BackgroundTransparency = 1, Parent = stage })
    local function title_label(parent, color, tr)
        return new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.fromOffset(700, 84), Text = TITLE, Font = W.BRAND, TextSize = 64,
            TextColor3 = color, TextTransparency = tr, Parent = parent })
    end
    local split_a, split_b = title_label(tbox, C.a3, 0.25), title_label(tbox, C.indigo, 0.25)
    local slices = {}
    for i = 0, 5 do
        local clip = new("Frame", { Position = UDim2.fromOffset(0, i * 14), Size = UDim2.fromOffset(700, 14), BackgroundTransparency = 1,
            ClipsDescendants = true, Parent = tbox })
        local l = title_label(clip, C.white, 0)
        l.Position = UDim2.fromOffset(0, -i * 14)
        new("UIGradient", { Rotation = 90, Color = ColorSequence.new(C.white, Color3.fromRGB(205, 160, 255)), Parent = l })
        slices[i + 1] = { clip = clip, label = l, y = i * 14 }
    end
    local hub = new("TextLabel", { Position = UDim2.fromOffset(0, 124), Size = UDim2.fromOffset(700, 22), BackgroundTransparency = 1, Text = "H  U  B",
        Font = W.BRAND, TextSize = 16, TextColor3 = C.a1, TextTransparency = 1, Parent = stage })
    local tag = new("TextLabel", { Position = UDim2.fromOffset(0, 152), Size = UDim2.fromOffset(700, 16), BackgroundTransparency = 1, Text = "",
        Font = W.MONO, TextSize = 12, TextColor3 = C.dim, Parent = stage })
    local bar_track = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 194), Size = UDim2.fromOffset(0, 2),
        BackgroundColor3 = C.stroke, BorderSizePixel = 0, Parent = stage })
    local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = bar_track })
    new("UIGradient", { Color = W.ACCENT, Parent = fill })
    local head = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5), Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = C.a3, BorderSizePixel = 0, Parent = bar_track })
    corner(head)
    new("UIStroke", { Color = C.a3, Thickness = 4, Transparency = 0.7, Parent = head })
    local status = new("TextLabel", { Position = UDim2.fromOffset(180, 204), Size = UDim2.fromOffset(260, 16), BackgroundTransparency = 1, Text = "",
        Font = W.MONO, TextSize = 11, TextColor3 = C.dim, TextXAlignment = Enum.TextXAlignment.Left, Parent = stage })
    local pct = new("TextLabel", { Position = UDim2.fromOffset(440, 204), Size = UDim2.fromOffset(80, 16), BackgroundTransparency = 1, Text = "000%",
        Font = W.MONO, TextSize = 11, TextColor3 = C.a3, TextXAlignment = Enum.TextXAlignment.Right, Parent = stage })
    tween(bar_track, 0.5, { Size = UDim2.fromOffset(340, 2) })
    -- [[ the corners: little readouts typing themselves out ]] --
    local hs = math.max(9, math.floor(11 * s + 0.5))
    local hud = {}
    local function hud_text(anchor, pos, align, text)
        local l = new("TextLabel", { AnchorPoint = anchor, Position = pos, Size = UDim2.fromOffset(math.floor(360 * s), hs + 4), BackgroundTransparency = 1,
            Text = "", Font = W.MONO, TextSize = hs, TextColor3 = C.a2, TextXAlignment = align, Parent = root })
        table.insert(hud, { l, text })
    end
    local LEFT, RIGHT = Enum.TextXAlignment.Left, Enum.TextXAlignment.Right
    hud_text(Vector2.new(0, 0), UDim2.fromOffset(18, 16), LEFT, "SOBRIETY//BOOT  v4")
    hud_text(Vector2.new(1, 0), UDim2.new(1, -18, 0, 16), RIGHT, "PLACE " .. tostring(game.PlaceId))
    hud_text(Vector2.new(0, 1), UDim2.new(0, 18, 1, -16), LEFT, "USER @" .. me.Name)
    hud_text(Vector2.new(1, 1), UDim2.new(1, -18, 1, -16), RIGHT, os.date("%Y.%m.%d  %H:%M"))
    -- [[ scanlines, a band of light rolling down, and noise blocks for the glitch bursts ]] --
    local lines = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = root })
    for y = cr, ch - cr, 4 do
        new("Frame", { Position = UDim2.fromOffset(0, y), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.black, BackgroundTransparency = 0.55,
            BorderSizePixel = 0, Parent = lines })
    end
    local band = new("Frame", { Position = UDim2.new(0, 0, 0, -180), Size = UDim2.new(1, 0, 0, 180), BackgroundColor3 = C.a1, BorderSizePixel = 0,
        ZIndex = 2, Parent = root })
    corner(band, cr)
    new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.8, 0.94),
        NumberSequenceKeypoint.new(0.97, 0.86), NumberSequenceKeypoint.new(1, 1) }), Parent = band })
    local NOISE = { C.a1, C.a3, C.white, C.indigo }
    local blocks = {}
    for i = 1, 10 do
        blocks[i] = new("Frame", { Size = UDim2.fromOffset(60, 4), BackgroundColor3 = C.a1, BorderSizePixel = 0, Visible = false, ZIndex = 2, Parent = root })
    end
    local GLYPHS = "!<>-_/[]{}=+*^?#$%&@0123456789ABCDEFGHKLMNPRSTUVXYZ"
    local function scramble(text, n)
        local out = table.create(#text)
        for i = 1, #text do
            if i <= n then
                out[i] = text:sub(i, i)
            else
                local k = math.random(1, #GLYPHS)
                out[i] = GLYPHS:sub(k, k)
            end
        end
        return table.concat(out)
    end
    local function set_title(t)
        split_a.Text, split_b.Text = t, t
        for _, sl in ipairs(slices) do sl.label.Text = t end
    end
    local function rnd(a) return math.floor((math.random() * 2 - 1) * a + 0.5) end
    local function glitch(p)
        split_a.Position = UDim2.fromOffset(-2 - math.floor(p * 7) + rnd(p * 4), rnd(p * 3))
        split_b.Position = UDim2.fromOffset(2 + math.floor(p * 7) + rnd(p * 4), rnd(p * 3))
        for _, sl in ipairs(slices) do
            sl.clip.Position = UDim2.fromOffset(math.random() < p * 0.5 and rnd(6 + p * 30) or 0, sl.y)
        end
        for _, b in ipairs(blocks) do
            b.Visible = math.random() < p * 0.45
            if b.Visible then
                b.Position = UDim2.fromScale(math.random(), math.random())
                b.Size = UDim2.fromOffset(math.random(20, 180), math.random(2, 9))
                b.BackgroundColor3 = NOISE[math.random(1, #NOISE)]
                b.BackgroundTransparency = 0.15 + math.random() * 0.55
            end
        end
    end
    local STEPS = S.hub.steps or { { 0, "linking executor" }, { 0.2, "hooking the game's remotes" }, { 0.45, "reading the game" },
        { 0.7, "building the window" }, { 0.95, "ready" } }
    local t0 = os.clock()
    local decode_end, load_a, load_b = total * 0.42, total * 0.15, total * 0.8
    local hub_shown, step_i, step_t = false, 0, 0
    while not skipped and layer.Parent do
        local t = os.clock() - t0
        if t >= total then break end
        local n = math.floor(math.clamp(t / decode_end, 0, 1) * #TITLE)
        set_title(n >= #TITLE and TITLE or scramble(TITLE, n))
        local p = math.clamp((t - load_a) / (load_b - load_a), 0, 1)
        fill.Size = UDim2.fromScale(p, 1)
        head.Position = UDim2.fromScale(p, 0.5)
        pct.Text = ("%03d%%"):format(math.floor(p * 100 + 0.5))
        local want = 1
        for i, st in ipairs(STEPS) do
            if p >= st[1] then want = i end
        end
        if want ~= step_i then step_i, step_t = want, t end
        local msg = "> " .. STEPS[step_i][2]
        status.Text = msg:sub(1, math.floor((t - step_t) * 90) + 2)
        status.TextColor3 = step_i == #STEPS and C.a3 or C.dim
        tag.Text = TAG:sub(1, math.floor(math.clamp((t - total * 0.1) / (total * 0.5), 0, 1) * #TAG))
        local k = math.clamp(t / (total * 0.5), 0, 1)
        for _, h in ipairs(hud) do h[1].Text = h[2]:sub(1, math.floor(k * #h[2])) end
        if not hub_shown and t > decode_end * 0.7 then
            hub_shown = true
            tween(hub, 0.5, { TextTransparency = 0 })
        end
        band.Position = UDim2.new(0, 0, ((t % 1.6) / 1.6) * 1.2 - 0.2, 0)
        local g = 0.04
        if t < decode_end then g = 0.12 + 0.5 * (1 - t / decode_end) end
        if not quick and math.random() < 0.05 then g = math.max(g, 0.65) end
        if t > total * 0.86 then g = 0.95 end
        glitch(g)
        if boot_logo then
            -- [[ the endless pour keeps its own clock from the cold open, so it never skips back to its first frame ]] --
            if wet_t0 then
                boot_logo.ImageRectOffset = W.logo_frame(os.clock() - wet_t0)
            elseif intro_logo then
                boot_logo.ImageRectOffset = W.logo_frame(2.4)
            else
                boot_logo.ImageRectOffset = W.logo_frame(t)
            end
            if os.clock() > glide_until then
                boot_logo.Position = logo_pos + UDim2.fromOffset(rnd(g * 8), 0)
            end
        end
        task.wait(1 / 30)
    end
    set_title(TITLE)
    glitch(0)
    for _, b in ipairs(blocks) do b.Visible = false end
    if not skipped and layer.Parent then
        -- [[ the old-monitor shut: squeezed to a line, then the line shrinks to nothing ]] --
        local w0 = crt.Size.X.Offset
        tween(crt, 0.16, { Size = UDim2.fromOffset(w0, 2) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        if boot_logo then
            boot_logo.Position = logo_pos
            tween(boot_logo, 0.16, { Size = UDim2.fromOffset(boot_logo.Size.X.Offset, 2), ImageTransparency = 1 }, Enum.EasingStyle.Quad,
                Enum.EasingDirection.In)
        end
        task.wait(0.17)
        crt.Visible = false
        local beam = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = spot, Size = UDim2.fromOffset(w0, 2),
            BackgroundColor3 = C.white, BorderSizePixel = 0, ZIndex = 4, Parent = layer })
        new("UIStroke", { Color = C.a3, Thickness = 3, Transparency = 0.5, Parent = beam })
        tween(beam, 0.2, { Size = UDim2.fromOffset(0, 2) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.2)
    end
    if not layer.Parent then return end
    for _, d in ipairs(root:GetChildren()) do
        if d:IsA("GuiObject") then d.Visible = false end
    end
    for _, d in ipairs(layer:GetChildren()) do
        if d:IsA("GuiObject") and d ~= screen then d.Visible = false end
    end
    tween(root, 0.35, { BackgroundTransparency = 1 })
    tween(root_stroke, 0.35, { Transparency = 1 })
    pcall(done)
    task.delay(0.4, function() layer:Destroy() end)
end

local function build_ui()
local W = make_window()
local C, BOLD, REG, BLACK = W.C, W.BOLD, W.REG, W.BLACK
local tween, new, corner, gradient, set_text, label = W.tween, W.new, W.corner, W.gradient, W.set_text, W.label
local gui, painters, page, next_order = W.gui, W.painters, W.page, W.next_order
local card, section, toggle, segmented, action, info, stats = W.card, W.section, W.toggle, W.segmented, W.action, W.info, W.stats
local top_pill, me_sub = W.top_pill, W.me_sub

-- [[ phones and tablets: no keyboard, so key pickers and keyboard hints are hidden (the touch buttons do those jobs) ]] --
local touch_only = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local function pc_only(f)
    if touch_only and typeof(f) == "Instance" then (f :: any).Visible = false end
    return f
end
local home = page("Home", "⌂", 0)
local hunt_page = page("Hunt", "🐺", 1)
local survive_page = page("Survive", "💧", 2)
local fight_page = page("Fight", "⚔", 3)
local move_page = page("Move", "💨", 4)
local places_page = page("Places & Amber", "🗺", 5)
local esp_page = page("ESP", "👁", 6)
local look_page = page("Name", "🏷", 7)
local logs_page = page("Logs", "📋", 8)
local settings_page = page("Settings", "⚙", 9)

local function esc(t) return (tostring(t):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
local function pct(v) return ("%d%%"):format(math.floor((tonumber(v) or 0) + 0.5)) end
local function hours() return math.max((os.clock() - S.session_start) / 3600, 1 / 120) end
local function stage(g)
    g = tonumber(g) or 0
    if g < 0.34 then return "baby" elseif g < 0.67 then return "young" elseif g < 1 then return "adult" end
    return "elder"
end

-- [[ Home: start / stop, your animal, the numbers, what just happened ]] --
do
    local hero = card(home, 112)
    local hero_stroke = hero:FindFirstChildOfClass("UIStroke")
    local hero_glow = W.spin(new("UIGradient", { Color = W.ACCENT, Enabled = false, Parent = hero_stroke }), 90)
    local dot = new("Frame", { Position = UDim2.fromOffset(18, 22), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = C.dim, Parent = hero })
    corner(dot)
    local state = label(hero, "FARM IS OFF", BLACK, 12, C.dim, { Position = UDim2.fromOffset(38, 16), Size = UDim2.new(1, -200, 0, 24) })
    local status = label(hero, "", BOLD, 17, C.text, { Position = UDim2.fromOffset(18, 44), Size = UDim2.new(1, -200, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd })
    local sub = label(hero, "", REG, 12, C.dim, { Position = UDim2.fromOffset(18, 72), Size = UDim2.new(1, -200, 0, 30), TextWrapped = true,
        RichText = true, TextYAlignment = Enum.TextYAlignment.Top })
    local btn = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, -16), Size = UDim2.fromOffset(150, 42),
        BackgroundColor3 = C.white, AutoButtonColor = false, Text = "START FARM", Font = BLACK, TextSize = 15, TextColor3 = C.white, Parent = hero })
    corner(btn, 12)
    local grad = gradient(btn, 0)
    W.pressable(btn)
    btn.MouseButton1Click:Connect(function()
        S.farm = not S.farm
        logf("FARM", S.farm and "turned ON" or "turned OFF")
        -- [[ stopped: somewhere safe on dry land (out of the ground or the water, away from anyone close) ]] --
        if not S.farm then
            S.hold = nil
            S.manual_run("going somewhere safe", function(keep) S.go_safe(keep) end)
        end
    end)
    -- [[ OPTIONS: everything the farm does, each with its own switch, right here on Home ]] --
    local opt_btn = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 26), Size = UDim2.fromOffset(150, 28),
        BackgroundColor3 = C.bg, AutoButtonColor = false, Text = "OPTIONS", Font = BOLD, TextSize = 12, TextColor3 = C.text, Parent = hero })
    corner(opt_btn, 9)
    W.outline(opt_btn, C.stroke, 1, 0.1)
    W.pressable(opt_btn)
    local opts = {}
    local function keep_row(f) if f then table.insert(opts, f) end return f end
    keep_row(section(home, "WHAT THE FARM DOES (TURN OFF WHAT YOU DON'T NEED)"))
    keep_row(toggle(home, "Hunt bots", "Prey bots only, never players", function() return S.hunt end, function(v) S.hunt = v end))
    keep_row(toggle(home, "Eat what you kill", "Eats the carcass after a kill", function() return S.eat_kills end, function(v) S.eat_kills = v end))
    keep_row(toggle(home, "Eat when hungry", "Free food close by, fish, or a hunt", function() return S.auto_eat end, function(v) S.auto_eat = v end))
    keep_row(toggle(home, "Drink when thirsty", "At water away from gators", function() return S.auto_drink end, function(v) S.auto_drink = v end))
    keep_row(segmented(home, "Food from", { { "Both", "Kills + fish" }, { "Fish", "Fish only" }, { "Kills", "Kills only" } },
        function() return S.food_src end, function(v) S.food_src = v end))
    keep_row(toggle(home, "Amber trees", "Picks the amber chunks every 10 minutes", function() return S.chunks end, function(v) S.chunks = v end))
    keep_row(toggle(home, "Explore every place", "20 amber for each one new to you", function() return S.explore end, function(v) S.explore = v end))
    keep_row(toggle(home, "Place quests", "Goes where your visit / explore / drink-at quests point", function() return S.quest_places end, function(v) S.quest_places = v end))
    keep_row(toggle(home, "Claim rewards", "Playtime and daily", function() return S.rewards end, function(v) S.rewards = v end))
    keep_row(toggle(home, "Amber farm", "All the amber options above plus prey hunting; server hops only while this is on", function() return S.amber_mode end,
        function(v)
            if v then S.amber_farm() else S.amber_mode = false end
        end))
    keep_row(toggle(home, "Hop when the trees are picked", "Only with Amber farm on", function() return S.hop_amber end, function(v) S.hop_amber = v end))
    keep_row(toggle(home, "AFK farm", "Hides at the quietest place; out only to eat and drink", function() return S.afk end, function(v) S.afk = v end))
    keep_row(toggle(home, "Use your move on prey", "Your F move (lunge, pounce, takedown...) on big prey", function() return S.auto_lunge end, function(v) S.auto_lunge = v end))
    keep_row(toggle(home, "Avoid players", "Skips prey, amber, food and water near other players", function() return S.avoid_players end, function(v) S.avoid_players = v end))
    keep_row(toggle(home, "Run from players", "Moves away when a player comes close", function() return S.flee_players end, function(v) S.flee_players = v end))
    keep_row(toggle(home, "Run from wild hunters", "Wolves, cats, bears, gators", function() return S.flee_npcs end, function(v) S.flee_npcs = v end))
    keep_row(toggle(home, "Rest to heal", "Below 45% health, out of a fight", function() return S.rest_heal end, function(v) S.rest_heal = v end))
    keep_row(toggle(home, "Travel underground", "Out of sight between places", function() return S.travel_under end, function(v) S.travel_under = v end))
    keep_row(toggle(home, "Low profile", "Nothing odd-looking near other players", function() return S.low_profile end, function(v) S.low_profile = v end))
    local shown = false
    local function show_opts(v)
        shown = v
        for _, f in ipairs(opts) do f.Visible = v end
        set_text(opt_btn, v and "HIDE OPTIONS" or "OPTIONS")
    end
    show_opts(false)
    opt_btn.MouseButton1Click:Connect(function() show_opts(not shown) end)
    local row1 = stats(home, { "Kills", "Amber / hour", "Meals", "Drinks" })
    local row2 = stats(home, { "Fish", "Bites landed", "Grabs broken", "Deaths" })
    section(home, "WHAT JUST HAPPENED")
    local feed_card = card(home, 214)
    local feed = label(feed_card, "", REG, 12, C.text, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 1, -20), TextWrapped = true,
        RichText = true, TextYAlignment = Enum.TextYAlignment.Top, LineHeight = 1.15 })
    local KIND = { KILL = "F0ABFC", HUNT = "C4B5FD", FOOD = "8CF5B0", DRINK = "7DD3FC", AMBER = "FFD27A", REWARD = "FFD27A", QUEST = "FFD27A",
        SAFE = "8CF5B0", BITTEN = "FF8A8A", DEATH = "FF6B6B", ERROR = "FF6B6B", FARM = "C4B5FD", RECONNECT = "FFB27A", START = "AEB4C8" }
    table.insert(painters, function()
        local on = S.farm
        local col = on and C.good or C.dim
        dot.BackgroundColor3 = col
        state.Text = on and ("FARMING  ·  " .. string.upper(tostring(S.phase))) or (S.manual and "BUSY" or "FARM IS OFF")
        state.TextColor3 = col
        top_pill.dot.BackgroundColor3 = col
        top_pill.text.Text = S.held and "GRABBED" or (on and string.upper(tostring(S.phase)) or "IDLE")
        top_pill.text.TextColor3 = on and C.text or C.dim
        status.Text = tostring(S.status)
        sub.Text = ("Hunger <b>%s</b>  ·  Thirst <b>%s</b>  ·  Health <b>%s</b>  ·  Growth <b>%s</b> (%s)"):format(pct(S.hunger()), pct(S.thirst()),
            pct(S.health_pct() * 100), pct(S.growth() * 100), stage(S.growth()))
        hero_glow.Enabled = on
        if hero_stroke then hero_stroke.Color = on and C.white or C.stroke end
        set_text(btn, on and "STOP FARM" or "START FARM")
        grad.Enabled = not on
        btn.BackgroundColor3 = on and C.bad or C.white
        local amber = tonumber(me:GetAttribute("Amber")) or 0
        row1.Kills.Text = tostring(S.kills)
        row1["Amber / hour"].Text = short(math.max(amber - S.amber0, 0) / hours())
        row1.Meals.Text = tostring(S.meals)
        row1.Drinks.Text = tostring(S.drinks)
        row2.Fish.Text = tostring(S.fish)
        row2["Bites landed"].Text = tostring(S.hits)
        row2["Grabs broken"].Text = tostring(S.grabs)
        row2.Deaths.Text = tostring(S.deaths)
        local lines = {}
        for i = #S.log, math.max(1, #S.log - 11), -1 do
            local t, kind, msg = S.log[i]:match("^%[(%d+:%d+):%d+ [^%]]*%] (%u+): (.*)$")
            if t then
                table.insert(lines, ('<font color="#6E7590">%s</font>  <font color="#%s"><b>%s</b></font>  %s'):format(t, KIND[kind] or "AEB4C8", kind, esc(msg)))
            end
        end
        feed.Text = #lines > 0 and table.concat(lines, "\n") or "Nothing yet."
    end)
end

-- [[ Hunt: bots only ]] --
section(hunt_page, "HUNTING (BOTS ONLY, NEVER PLAYERS)")
toggle(hunt_page, "Auto hunt", "With the farm on: finds prey, runs in behind it (bites from behind do 1.25x) and bites at the game's pace",
    function() return S.hunt end, function(v) S.hunt = v end)
segmented(hunt_page, "What to hunt", { { "Mice", "Mice" }, { "Prey", "Mice + prey" }, { "Big", "Prey animals" }, { "Any", "Any bot" } },
    function() return S.prey end, function(v) S.prey = v end)
segmented(hunt_page, "Bite speed (tests itself: drops back if the server ignores the extra bites)", { { 1, "Game's" }, { 1.25, "x1.25" }, { 1.5, "x1.5" }, { 2, "x2" } },
    function() return S.bite_speed end, function(v)
        S.bite_speed = v
        S.fast_state, S.fast_sent, S.fast_hits = 0, 0, 0
    end)
toggle(hunt_page, "Use your move on prey", "Your F move on big prey when it's ready, if it grabs: wolf lunge, cat pounce, tiger takedown, gator drag, python constrict, otter frenzy, komodo venom lunge",
    function() return S.auto_lunge end, function(v) S.auto_lunge = v end)
toggle(hunt_page, "Bite while latched", "Tries real bites while you hold on (the game blocks them itself); stops by itself if the server ignores them",
    function() return S.latch_bite end, function(v) S.latch_bite = v end)
toggle(hunt_page, "Squeeze while latched", "The hold's own damage: squeezes at the fastest pace the game allows (your clicks squeeze too), so it can't shake you off",
    function() return S.auto_squeeze end, function(v) S.auto_squeeze = v end)
toggle(hunt_page, "Eat what you kill", "Eats the carcass right after the kill when you're not full",
    function() return S.eat_kills end, function(v) S.eat_kills = v end)
do
    local t = info(hunt_page, 78)
    table.insert(painters, function()
        local pace = S.bite_speed == 1 and "the game's pace"
            or (S.fast_state == -1 and ("x%g was capped by the server: game's pace"):format(S.bite_speed)
            or (S.fast_state == 1 and ("x%g (it lands)"):format(S.bite_speed) or ("x%g (testing)"):format(S.bite_speed)))
        local ready = S.lunge_ready() and "<b>ready</b>" or ("in %ds"):format(math.max(0, math.ceil((tonumber(me:GetAttribute("FeralLungeReadyAt")) or 0) - workspace:GetServerTimeNow())))
        t.Text = ("A bite every <b>%.2fs</b> (%s)  ·  your bite damage <b>%s</b> (set by the server from your growth)\n"
            .. "Bites <b>%d</b>, landed <b>%d</b>  ·  reach <b>%.1f</b> studs  ·  Lunge %s\nLast kill: <b>%s</b>  ·  target now: <b>%s</b>"):format(
            S.cur_cd or 0.7, pace, tostring(me.Character and me.Character:GetAttribute("Damage") or me:GetAttribute("Damage") or "?"), S.bites, S.hits,
            S.bite_reach(), growth() < 0.34 and "unlocks at 34% growth" or ready, esc(S.last_kill),
            S.target and esc(S.target:GetAttribute("Species") or S.target.Name) or "-")
    end)
end

-- [[ Survive ]] --
section(survive_page, "FOOD AND WATER")
toggle(survive_page, "Auto eat", "Eats free food close by (carcasses, corpses), fishes, or hunts for it", function() return S.auto_eat end, function(v) S.auto_eat = v end)
segmented(survive_page, "Eat when hunger is below", { { 50, "50%" }, { 70, "70%" }, { 85, "85%" }, { 95, "95%" } },
    function() return S.eat_at end, function(v) S.eat_at = v end)
segmented(survive_page, "Food from", { { "Both", "Kills + fish" }, { "Fish", "Fish only" }, { "Kills", "Kills only" } },
    function() return S.food_src end, function(v) S.food_src = v end)
toggle(survive_page, "Auto drink", "Drinks where you stand if the server allows it, else at the nearest water",
    function() return S.auto_drink end, function(v) S.auto_drink = v end)
segmented(survive_page, "Drink when thirst is below", { { 50, "50%" }, { 70, "70%" }, { 85, "85%" }, { 95, "95%" } },
    function() return S.drink_at end, function(v) S.drink_at = v end)
toggle(survive_page, "Come back after drinking", "Goes back to where you were after a trip to water",
    function() return S.drink_return end, function(v) S.drink_return = v end)
action(survive_page, "Drink now", "Drinks until full", "DRINK", function()
    S.manual_run("drinking", function(keep) S.drink(keep) end)
end)
do
    local t = info(survive_page, 62)
    table.insert(painters, function()
        local a = S.drink_anywhere == 1 and "<b>works from anywhere</b>" or (S.drink_anywhere == -1 and "<b>needs water</b> (trips there and back)" or "checked on the first drink")
        t.Text = ("Drinking: %s\nHunger and thirst are kept by the server, so they only go up when you eat and drink: the hub does both for you, "
            .. "and keeps them above 10%% (below that you stop growing)."):format(a)
    end)
end
section(survive_page, "STAYING ALIVE")
action(survive_page, "Revive now", "On the death screen: uses your revive (the free one if you have it, else one you bought)", "REVIVE",
    function() S.revive_now() end)
toggle(survive_page, "Use the free revive", "Off: you choose on the death screen. On: the moment you die it uses your free revive (once) to keep your growth. Bought revives are never used",
    function() return S.revive_free end, function(v) S.revive_free = v end)
toggle(survive_page, "Avoid players", "The farm skips prey, amber, food, water and fish near other players (not your pack)",
    function() return S.avoid_players end, function(v) S.avoid_players = v end)
segmented(survive_page, "Near means", { { 100, "100 studs" }, { 150, "150 studs" }, { 250, "250 studs" } },
    function() return S.avoid_dist end, function(v) S.avoid_dist = v end)
toggle(survive_page, "Run from players", "While farming, moves away when another player (not in your pack) comes close",
    function() return S.flee_players end, function(v) S.flee_players = v end)
segmented(survive_page, "Close means", { { 40, "40 studs" }, { 70, "70 studs" }, { 120, "120 studs" } },
    function() return S.flee_dist end, function(v) S.flee_dist = v end)
toggle(survive_page, "Run from wild hunters", "Moves away from wild wolves, cougars, bears and gators that get close",
    function() return S.flee_npcs end, function(v) S.flee_npcs = v end)
toggle(survive_page, "Rest to heal", "Below 45% health and out of a fight: rests (2x healing) until 90%",
    function() return S.rest_heal end, function(v) S.rest_heal = v end)

-- [[ Fight ]] --
section(fight_page, "TARGET A PLAYER")
do
    local f = card(fight_page, 64)
    local box = new("TextBox", { Position = UDim2.fromOffset(14, 14), Size = UDim2.new(1, -28, 0, 36), BackgroundColor3 = C.bg, Text = "",
        PlaceholderText = "username or display name (part of it is enough)", Font = BOLD, TextSize = 14, TextColor3 = C.text, PlaceholderColor3 = C.dim,
        ClearTextOnFocus = false, Parent = f })
    corner(box, 9)
    W.outline(box, C.stroke, 1, 0.1)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = box })
    local function who()
        local p = S.find_player(box.Text)
        if not p then notify("Nobody here matches \"" .. box.Text .. "\".") end
        return p
    end
    local found = info(fight_page, 30)
    table.insert(painters, function()
        local p = #box.Text >= 2 and S.find_player(box.Text)
        if not p then
            found.Text = #box.Text >= 2 and "Nobody here matches that." or "Type a name to pick someone."
            return
        end
        local c = p.Character
        local r, tr = root_part(), c and c:FindFirstChild("HumanoidRootPart")
        local h = c and c:FindFirstChildOfClass("Humanoid")
        found.Text = ("<b>%s</b> (@%s)  ·  %s %s  ·  %s  ·  health %s"):format(esc(p.DisplayName), esc(p.Name), esc(stage(c and c:GetAttribute("Growth"))),
            esc(c and c:GetAttribute("Species") or "?"), (r and tr) and ("%dm away"):format(math.floor((tr.Position - r.Position).Magnitude * 0.28)) or "far away",
            (h and h.MaxHealth > 0) and ("%d%%"):format(math.floor(h.Health / h.MaxHealth * 100)) or "?")
    end)
    action(fight_page, "Go to them", "Travels to them (your travel settings: underground, low profile)", "GO", function()
        local p = who()
        if p then S.manual_run("going to " .. p.DisplayName, function(keep) S.target_go(keep, p) end) end
    end)
    action(fight_page, "Leap onto them", "Your leap, onto them wherever they are; the leap key or Space lets go", "LEAP", function()
        local p = who()
        local c = p and p.Character
        if c then S.leap(c) end
    end)
    action(fight_page, "Attack them", "Onto their back (out of their bite) and bites at your pace until they're down or gone", "ATTACK", function()
        local p = who()
        if p then S.manual_run("attacking " .. p.DisplayName, function(keep) S.target_attack(keep, p) end) end
    end)
    action(fight_page, "Follow them", "Stays a few steps behind them wherever they go", "FOLLOW", function()
        local p = who()
        if p then S.manual_run("following " .. p.DisplayName, function(keep) S.target_follow(keep, p) end) end
    end)
    action(fight_page, "Watch them", "Your camera follows them (Stop gives it back)", "WATCH", function()
        local p = who()
        if p then S.target_watch(p) end
    end)
    action(fight_page, "Stop", "Stops going, attacking, following and watching", "STOP", function()
        S.manual_stop()
        S.target_unwatch()
    end)
end
section(fight_page, "NOTHING HOLDS YOU")
toggle(fight_page, "Break free from grabs", "Latches, riders, pythons, gator grips, bird talons: the game's own shake / flip / get-off, as fast as it allows",
    function() return S.anti_grab end, function(v) S.anti_grab = v end)
toggle(fight_page, "Fight back", "Bites whatever bites or holds you, turned to face it wherever it is (a bird above, a cat on your back)",
    function() return S.fight_back end, function(v) S.fight_back = v end)
toggle(fight_page, "Dodge diving birds", "Steps aside when an eagle or falcon dives at you", function() return S.dodge_birds end, function(v) S.dodge_birds = v end)
section(fight_page, "BITE AURA")
toggle(fight_page, "Bite aura on bots", "Always on: any bot in reach gets bitten, all around you (you turn to it for the bite); wild hunters once they bite you",
    function() return S.aura_bots end, function(v) S.aura_bots = v end)
toggle(fight_page, "Bite aura on players", touch_only and "Players in reach get bitten too, while this is on. The AURA touch button turns it on and off"
    or "Players in reach get bitten too, while this is on. The key below turns it on and off",
    function() return S.aura end, function(v) S.aura = v end)
pc_only(segmented(fight_page, "Key for players (R is the game's Rest, which stops biting)", { { "T", "T" }, { "V", "V" }, { "N", "N" }, { "K", "K" } },
    function() return S.aura_key end, function(v) S.aura_key = v end))
segmented(fight_page, "Players it bites", { { "Attackers", "Only ones biting me" }, { "Everyone", "Everyone in reach" } },
    function() return S.aura_targets end, function(v) S.aura_targets = v end)
toggle(fight_page, "Show the reach ring", "While the players aura (T) is on: a ring showing how far your bites reach. The blue bird bubble shows only when a bird is close",
    function() return S.aura_ring end, function(v) S.aura_ring = v end)
segmented(fight_page, "Bite reach", { { 1, "Game's" }, { 1.25, "1.25x" }, { 1.5, "1.5x (server's most)" } },
    function() return S.reach_mult end, function(v) S.reach_mult = v end)
section(fight_page, "LEAP (ANY ANIMAL, ANY SIZE)")
toggle(fight_page, "Leap", touch_only and "The LEAP touch button flies you onto the animal you're looking at (any size, bots or players) with the lunge pose; you stay on its back until you press LET GO. You do the biting"
    or "The key below flies you onto the animal you're looking at (any size, bots or players) with the lunge pose; you stay on its back until you let go (the key again or Space). You do the biting",
    function() return S.leap_on end, function(v) S.leap_on = v end)
pc_only(segmented(fight_page, "Leap key", { { "V", "V" }, { "N", "N" }, { "K", "K" }, { "Y", "Y" } },
    function() return S.leap_key end, function(v) S.leap_key = v end))
segmented(fight_page, "Leap range", { { 15, "15 (the lunge's)" }, { 40, "40 studs" }, { 80, "80 studs" } },
    function() return S.leap_range end, function(v) S.leap_range = v end)
toggle(fight_page, "Stay on until I let go", touch_only and "The game's own automatic let-go is held back. Yours always works (LET GO, or the game's button), and it lets go by itself if you drop under 50% or something else bites you"
    or "The game's own automatic let-go is held back. Yours always works (F, the leap key, or the game's button), and it lets go by itself if you drop under 50% or something else bites you",
    function() return S.keep_latch end, function(v) S.keep_latch = v end)
do
    local t = info(fight_page, 30)
    table.insert(painters, function()
        t.Text = S.leap_key == S.aura_key and "<b>The leap key and the aura key are the same: pick different ones.</b>"
            or (S.leaping and "<b>On its back</b>: bite away, the leap key or Space lets go." or "Everyone sees you leap (your movement goes through the server).")
    end)
end
section(fight_page, "BIRDS")
toggle(fight_page, "Auto-bite birds", "Only an eagle or falcon that attacked you: bitten the moment it's in reach, with a longer reach just for birds (up included). A blue bubble shows it when one is close",
    function() return S.bird_bite end, function(v) S.bird_bite = v end)
segmented(fight_page, "Reach on birds", { { 1.5, "1.5x (server's most)" }, { 2, "2x" }, { 3, "3x" } },
    function() return S.bird_reach_mult end, function(v) S.bird_reach_mult = v end)
do
    local t = info(fight_page, 44)
    table.insert(painters, function()
        t.Text = ("Bird reach <b>%.1f</b> studs  ·  bites at birds <b>%d</b>, landed <b>%d</b>\nIf 2x or 3x land no more than 1.5x, the server is capping it: go back to 1.5x."):format(
            S.bird_reach(), S.bird_bites, S.bird_hits)
    end)
end
section(fight_page, "GET AWAY WHEN LOW")
toggle(fight_page, "Get away after a huge bite", "One bite takes more than half your health: teleports you to safety at once",
    function() return S.big_hit_escape end, function(v) S.big_hit_escape = v end)
toggle(fight_page, "Get away when low", "In a fight with low health: teleports you to the place farthest from every player",
    function() return S.low_escape end, function(v) S.low_escape = v end)
segmented(fight_page, "When", { { "Both", "We're both low" }, { "Me", "I'm low" } },
    function() return S.low_escape_mode end, function(v) S.low_escape_mode = v end)
segmented(fight_page, "Low means", { { 15, "15%" }, { 25, "25%" }, { 40, "40%" } },
    function() return S.low_escape_at end, function(v) S.low_escape_at = v end)
do
    local t = info(fight_page, 62)
    table.insert(painters, function()
        t.Text = ("Grabs broken <b>%d</b>  ·  birds dodged <b>%d</b>  ·  %s\nHealth and damage are worked out by the server from your growth, "
            .. "so no script can give god mode: these keep you out of trouble instead."):format(S.grabs, S.dodges, S.held and "<b>held right now</b>" or "free")
    end)
end

-- [[ Move ]] --
section(move_page, "SPEED (EACH ONE ON ITS OWN)")
local MULTS = { { 1, "x1" }, { 1.25, "x1.25" }, { 1.5, "x1.5" }, { 2, "x2" }, { 3, "x3" } }
segmented(move_page, "Walk", MULTS, function() return S.walk_mult end, function(v) S.walk_mult = v end)
segmented(move_page, "Trot (Z)", MULTS, function() return S.trot_mult end, function(v) S.trot_mult = v end)
segmented(move_page, "Run (Shift)", MULTS, function() return S.run_mult end, function(v) S.run_mult = v end)
segmented(move_page, "Burst (X)", MULTS, function() return S.burst_mult end, function(v) S.burst_mult = v end)
toggle(move_page, "Escape speed", "Anything faster that bites you or runs at you: your run and X lock to 20% above its top speed until it's far away (a slower one never lowers you)",
    function() return S.escape end, function(v) S.escape = v end)
segmented(move_page, "Far away means", { { 100, "100 studs" }, { 200, "200 studs" }, { 400, "400 studs" } },
    function() return S.escape_far end, function(v) S.escape_far = v end)
toggle(move_page, "Snap-back guard", "The server pulls you back when you're faster than it allows: this lowers your speeds to the fastest it accepts (and tries faster again each minute)",
    function() return S.snap_guard end, function(v) S.snap_guard = v end)
toggle(move_page, "Instant turn", "Turns you to face where you go at once, no swinging around (the game's own turn rate, 40x)",
    function() return S.instant_turn end, function(v) S.instant_turn = v end)
segmented(move_page, "Auto sprint (locked on whenever you move)", { { "Off", "Off" }, { "Trot", "Trot (Z)" }, { "Run", "Run (Shift)" }, { "Burst", "Burst (X)" } },
    function() return S.auto_gait end, function(v) S.auto_gait = v end)
toggle(move_page, "Lock my speed", "Always your set speed: uphill, on sticky ground, and while held, dragged or limping (never through walls)",
    function() return S.speed_lock end, function(v) S.speed_lock = v end)
toggle(move_page, "Endless stamina", "Nothing uses stamina (running, X, swimming, jumping, lunging, holding on) and it refills at once", function() return S.inf_stamina end, function(v) S.inf_stamina = v end)
toggle(move_page, "No slowdown when hurt", "Low health, injuries and limping don't slow you", function() return S.no_hurt_slow end, function(v) S.no_hurt_slow = v end)
toggle(move_page, "Swim like you run", "Swims at your running speed (X too), and wading never stops your sprint",
    function() return S.fast_swim end, function(v) S.fast_swim = v end)
do
    local t = info(move_page, 44)
    table.insert(painters, function()
        local si = S.speed_info
        t.Text = ("Your run now <b>%.0f</b>, X <b>%.0f</b>  ·  fastest after you: <b>%s</b>%s\nPulled back by the server <b>%d</b> times  ·  speed limit %s  ·  travel limit %s"):format(
            si.run, si.burst, esc(si.name), si.fastest > 0 and (" (%.0f, you're locked 20%% above it)"):format(si.fastest) or "", S.snaps,
            S.speed_cap < 99 and ("<b>x%.2f</b>"):format(S.speed_cap) or "none", S.travel_cap < 999 and ("<b>%.0f</b>"):format(S.travel_cap) or "none")
    end)
end
section(move_page, "GETTING AROUND")
segmented(move_page, "Tween speed (studs a second; the snap-back guard lowers it if the server pulls you back)",
    { { 1, "Running" }, { 60, "60" }, { 100, "100" }, { 160, "160" }, { 250, "250" }, { 400, "400" } },
    function() return S.travel_speed end, function(v) S.travel_speed = v end)
toggle(move_page, "Travel underground", "Goes everywhere under the ground (nobody sees you); comes up only to eat and drink. Bitten down there: away at once",
    function() return S.travel_under end, function(v) S.travel_under = v end)
segmented(move_page, "A player close while travelling", { { "Under", "Go underground" }, { "Pause", "Stop and wait" } },
    function() return S.near_mode end, function(v) S.near_mode = v end)
segmented(move_page, "Close means", { { 80, "80 studs" }, { 150, "150 studs" }, { 250, "250 studs" } },
    function() return S.watch_dist end, function(v) S.watch_dist = v end)
toggle(move_page, "Slow down near players", "Tweens at a running pace (and never Instant) while a player is within 250 studs. Off: always your tween speed",
    function() return S.slow_near end, function(v) S.slow_near = v end)
action(move_page, "Reset speed limits", "Clears the limits the snap-back guard has learned (it learns again if the server really pulls you back)", "RESET", function()
    S.speed_cap, S.travel_cap = 99, 999
    notify("Speed limits cleared.")
end)
toggle(move_page, "Low profile", "Nothing that looks odd near others: pickups skipped while watched, underground (or a pause) when a player is close, random timings",
    function() return S.low_profile end, function(v) S.low_profile = v end)

-- [[ Places & Amber ]] --
section(places_page, "GO TO")
do
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card, LayoutOrder = next_order(), Parent = places_page })
    corner(f, 12)
    W.outline(f, C.stroke, 1, 0.1)
    new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = f })
    new("UIGridLayout", { CellSize = UDim2.fromOffset(122, 30), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
    for i, s in ipairs(S.SPOTS) do
        local b = new("TextButton", { BackgroundColor3 = C.bg, AutoButtonColor = false, Text = s.name, Font = BOLD, TextSize = 11, TextColor3 = C.dim,
            TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = i, Parent = f })
        corner(b, 7)
        W.pressable(b)
        b.MouseButton1Click:Connect(function()
            S.manual_run("going to " .. s.name, function(keep)
                if S.travel(s.x, s.z, keep) then logf("FARM", "arrived at " .. s.name) end
            end)
        end)
    end
end
action(places_page, "Stop", "Stops going somewhere (and any button below that's running)", "STOP", function() S.manual_stop() end)
section(places_page, "AFK FARM")
toggle(places_page, "AFK farm", "Hides at the quietest place (underground or on a sky platform); leaves only to eat and drink, then goes back",
    function() return S.afk end, function(v)
        S.afk = v
        if v then S.farm = true end
        logf("AFK", v and "AFK farm on" or "AFK farm off")
    end)
segmented(places_page, "AFK spot", { { "Under", "Underground" }, { "Sky", "Sky platform" } },
    function() return S.afk_place end, function(v) S.afk_place = v end)
action(places_page, "Go there now", "Straight to the AFK spot", "GO", function()
    S.manual_run("going to the AFK spot", function(keep)
        if S.afk_place == "Under" then S.afk_hide(keep) else S.afk_up() end
    end)
end)
action(places_page, "Come back", "Back to where you were before (AFK farm turns off)", "BACK", function()
    S.afk = false
    S.manual_run("coming back", function(keep) S.afk_down(keep) end)
end)
action(places_page, "Pick a new spot", "The quietest place again (players move around)", "MOVE", function()
    notify("The AFK spot is now at " .. tostring(S.afk_new_spot()) .. ".")
    if S.afk_up_now then S.manual_run("moving up there", function() S.afk_up() end) end
    if S.afk_under_now then S.manual_run("moving there", function(keep) S.afk_under_now = false S.afk_hide(keep) end) end
end)
do
    local t = info(places_page, 44)
    table.insert(painters, function()
        local where = S.afk_under_now and "<b>hidden underground</b>" or (S.afk_up_now and "<b>on the sky platform</b>" or "not there now")
        t.Text = ("AFK spot: <b>%s</b>  ·  %s\nUnderground nobody sees you; the sky platform is only on your screen (others see you in the air)."):format(
            esc(S.afk_name or "the quietest place (picked when you go)"), where)
    end)
end
section(places_page, "AMBER")
toggle(places_page, "Amber farm", "On: turns on everything below plus prey hunting, low profile and the farm (amber without fighting players). Server hops happen only while this is on",
    function() return S.amber_mode end, function(v)
        if v then
            S.amber_farm()
            notify("Amber farm is on.")
        else
            S.amber_mode = false
            logf("FARM", "amber farm off (no more server hops)")
        end
    end)
toggle(places_page, "Amber trees", "With the farm on: picks the amber chunks on the old pines (3-8 each), every 10 minutes when they grow back",
    function() return S.chunks end, function(v) S.chunks = v end)
toggle(places_page, "Hop when the trees are picked", "Only with Amber farm on: every tree in this server picked, it hops to a quieter server (fresh trees) and keeps farming there",
    function() return S.hop_amber end, function(v) S.hop_amber = v end)
action(places_page, "Hop now", "To a quieter server; the hub and the farm carry on there", "HOP", function()
    S.manual_run("hopping", function() S.hop("you asked") end)
end)
action(places_page, "Pick amber now", "One round of every tree", "GO", function() S.manual_run("picking amber", function(keep) S.chunk_round(keep) end) end)
toggle(places_page, "Explore every place", "With the farm on: visits each place once (20 amber for each one new to you)",
    function() return S.explore end, function(v) S.explore = v end)
action(places_page, "Explore now", "Visits every place you haven't found this session", "GO", function() S.manual_run("exploring", function(keep) S.tour(keep) end) end)
toggle(places_page, "Do place quests", "With the farm on: goes where your visit / explore / drink-at quests point (the server pays them)",
    function() return S.quest_places end, function(v) S.quest_places = v end)
toggle(places_page, "Claim rewards", "Playtime rewards (760 amber a day) and the daily streak, a little after each is ready",
    function() return S.rewards end, function(v) S.rewards = v end)
do
    local t = info(places_page, 96)
    table.insert(painters, function()
        local amber = tonumber(me:GetAttribute("Amber")) or 0
        local q = {}
        local s = S.quests
        if type(s) == "table" then
            for _, group in ipairs({ s.quick, s.daily }) do
                if type(group) == "table" then
                    for _, x in ipairs(group) do
                        if type(x) == "table" then
                            table.insert(q, ("%s%s %s/%s"):format(x.done and "(done) " or "", esc(x.t or x.k or "?"), tostring(x.have or 0), tostring(x.need or "?")))
                        end
                    end
                end
            end
        end
        local found = 0
        for _ in pairs(S.found) do found += 1 end
        t.Text = ("Amber <b>%s</b> (+%s this session, %s from trees)  ·  rewards claimed <b>%d</b>  ·  places found <b>%d</b>  ·  quests done <b>%d</b>\n%s"):format(
            short(amber), short(math.max(amber - S.amber0, 0)), short(S.chunk_amber), S.claims, found, S.quests_done,
            #q > 0 and ("Quests: " .. table.concat(q, "  ·  ")) or "Quests: waiting for the game")
    end)
end

-- [[ ESP ]] --
section(esp_page, "SEE EVERYTHING")
toggle(esp_page, "ESP", "Names, distance and health over animals, through walls and water", function() return S.esp end, function(v) S.esp = v end)
toggle(esp_page, "Players", "Other players' animals (orange; pack mates green)", function() return S.esp_players end, function(v) S.esp_players = v end)
toggle(esp_page, "Wild hunters", "Wolves, cougars, bears and the other bots that fight back (red)", function() return S.esp_predators end, function(v) S.esp_predators = v end)
toggle(esp_page, "Alligators", "Gators, wild or players, even under water (pink)", function() return S.esp_gators end, function(v) S.esp_gators = v end)
toggle(esp_page, "Prey", "Deer, elk and the other prey bots (green)", function() return S.esp_prey end, function(v) S.esp_prey = v end)
toggle(esp_page, "Mice", "Every mouse on the map (grey)", function() return S.esp_mice end, function(v) S.esp_mice = v end)
segmented(esp_page, "Range", { { 300, "300" }, { 600, "600" }, { 1200, "1200" }, { 3000, "Everything" } },
    function() return S.esp_range end, function(v) S.esp_range = v end)
toggle(esp_page, "Outlines", "Glowing outlines through walls on players and anything dangerous", function() return S.esp_highlight end, function(v) S.esp_highlight = v end)
do
    local t = info(esp_page, 44)
    t.Text = "Tags show what they're doing: <b>CROUCHED</b>, <b>IN A DEN</b>, <b>UNDER WATER</b> (hiding to ambush) and <b>COMING AT YOU</b>. Only you see the ESP."
end

-- [[ Name: the name over your head (the game's own rename, so everyone sees it) ]] --
section(look_page, "NAME OVER YOUR HEAD (EVERYONE SEES IT)")
do
    local f = card(look_page, 64)
    local box = new("TextBox", { Position = UDim2.fromOffset(14, 14), Size = UDim2.new(1, -150, 0, 36), BackgroundColor3 = C.bg, Text = S.tag_text,
        PlaceholderText = "2 to 18 letters", Font = BOLD, TextSize = 14, TextColor3 = C.text, PlaceholderColor3 = C.dim, ClearTextOnFocus = false, Parent = f })
    corner(box, 9)
    W.outline(box, C.stroke, 1, 0.1)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = box })
    local set = new("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 14), Size = UDim2.fromOffset(110, 36), BackgroundColor3 = C.white,
        AutoButtonColor = false, Text = "SET NAME", Font = BLACK, TextSize = 12, TextColor3 = C.white, Parent = f })
    corner(set, 9)
    gradient(set, 0)
    W.pressable(set)
    set.MouseButton1Click:Connect(function()
        S.tag_text = box.Text
        notify(S.rename(box.Text) and "Name sent: the game shows it over your head once it passes its filter."
            or "Names are 2 to 18 letters (and the game must have your save slot).")
    end)
end
do
    local t = info(look_page, 44)
    t.Text = "This is the game's own rename (the menu's Rename Your Animal), so every player sees it. Its colour is set by the game."
end
-- [[ Logs ]] --
local log_view
do
    local i = info(logs_page, 44)
    i.Text = ("Everything the hub did and why. Also saved every minute to <b>%s</b> in the workspace folder (each account has its own).")
        :format(S.log_file)
    action(logs_page, "Copy log", "Copies the whole log to paste to Claude", "COPY", function()
        local sc = exec("setclipboard")
        if typeof(sc) == "function" then
            pcall(sc, table.concat(S.log, "\n"))
            notify("Log copied.")
        end
    end)
    action(logs_page, "Clear log", "Starts the log fresh", "CLEAR", function() table.clear(S.log) end)
    section(logs_page, "EVENT LOG (EVERYTHING)")
    toggle(logs_page, "Event log", "Everything the server sends you, what the hub sends, your stats as they change, the game's errors, a snapshot each minute",
        function() return S.event_log end, function(v) S.event_log = v end)
    action(logs_page, "Copy event log", "Copies the event log to paste to Claude", "COPY", function()
        local sc = exec("setclipboard")
        if typeof(sc) == "function" then
            pcall(sc, table.concat(S.events, "\n"))
            notify("Event log copied.")
        end
    end)
    local ei = info(logs_page, 30)
    ei.Text = ("Saved every minute to <b>%s</b> in the workspace folder."):format(S.events_file)
    section(logs_page, "LATEST")
    local f = card(logs_page, 250)
    log_view = label(f, "", W.MONO, 11, C.dim, { Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 1, -16), TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd })
end

-- [[ Settings ]] --
section(settings_page, "PHONE AND TABLET")
toggle(settings_page, "Touch buttons", "On phones and tablets: AURA, LEAP, LET GO and FARM buttons on the screen (drag MOVE to put them anywhere)",
    function() return S.touch_bar end, function(v) S.touch_bar = v end)
pc_only(toggle(settings_page, "Show them with a keyboard too", "The touch buttons on a computer as well", function() return S.touch_bar_always end,
    function(v) S.touch_bar_always = v end))
section(settings_page, "YOUR EXECUTOR")
do
    local t = info(settings_page, 120)
    local last = -100
    table.insert(painters, function()
        if os.clock() - last < 5 then return end
        last = os.clock()
        local name, missing = S.support()
        if #missing == 0 then
            t.Text = ("<b>%s</b>: everything works."):format(esc(name))
            return
        end
        local lines = {}
        for _, x in ipairs(missing) do table.insert(lines, ("no <b>%s</b>: %s"):format(esc(x[1]), esc(x[2]))) end
        t.Text = ("<b>%s</b>: the rest works.\n%s"):format(esc(name), table.concat(lines, "\n"))
    end)
end
section(settings_page, "STAYING IN THE GAME")
toggle(settings_page, "Anti-AFK", "A tiny mouse nudge now and then, and a short step when idle (the game pauses your survival amber after 2 idle minutes)",
    function() return S.anti_afk end, function(v) S.anti_afk = v end)
toggle(settings_page, "Come back after a server move", "Moved (the AFK hop) or disconnected: rejoins and loads the hub again (needs feral.lua in the workspace)",
    function() return S.auto_reload end, function(v)
        S.auto_reload = v
        if v then S.queue_self() end
    end)
section(settings_page, "DISCORD ALERTS")
do
    -- [[ a text box on a card: the webhook link, and the amber goal ]] --
    local function box_card(placeholder, text, on_done)
        local f = card(settings_page, 64)
        local box = new("TextBox", { Position = UDim2.fromOffset(14, 14), Size = UDim2.new(1, -28, 0, 36), BackgroundColor3 = C.bg, Text = text,
            PlaceholderText = placeholder, Font = BOLD, TextSize = 13, TextColor3 = C.text, PlaceholderColor3 = C.dim, ClearTextOnFocus = false,
            TextTruncate = Enum.TextTruncate.AtEnd, Parent = f })
        corner(box, 9)
        W.outline(box, C.stroke, 1, 0.1)
        new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = box })
        box.FocusLost:Connect(function() on_done(box) end)
        return box
    end
    box_card("paste your Discord webhook link here", S.hook_url, function(box)
        local url = box.Text:gsub("%s", "")
        if url == "" or S.hook_ok(url) then
            S.hook_url = url
            notify(url == "" and "Webhook removed." or "Webhook saved.")
        else
            box.Text = S.hook_url
            notify("That isn't a Discord webhook link (https://discord.com/api/webhooks/...).")
        end
    end)
    toggle(settings_page, "Discord alerts", "Sends the alerts below to your webhook", function() return S.hook_on end, function(v) S.hook_on = v end)
    toggle(settings_page, "Deaths", "Who killed you, your growth, and whether a revive is ready", function() return S.hook_death end, function(v) S.hook_death = v end)
    toggle(settings_page, "Low health", "From bites only (at most once a minute)", function() return S.hook_low end, function(v) S.hook_low = v end)
    segmented(settings_page, "Low health means", { { 15, "15%" }, { 25, "25%" }, { 40, "40%" }, { 60, "60%" } },
        function() return S.hook_hp end, function(v) S.hook_hp = v end)
    toggle(settings_page, "Low hunger", "At most once every 5 minutes", function() return S.hook_hunger end, function(v) S.hook_hunger = v end)
    toggle(settings_page, "Low thirst", "At most once every 5 minutes", function() return S.hook_thirst end, function(v) S.hook_thirst = v end)
    segmented(settings_page, "Hunger / thirst low means", { { 10, "10%" }, { 20, "20%" }, { 30, "30%" } },
        function() return S.hook_need end, function(v) S.hook_need = v end)
    toggle(settings_page, "Amber goal reached", "Once, when your amber reaches the goal below", function() return S.hook_goal_on end, function(v) S.hook_goal_on = v end)
    box_card("amber goal (a number, like 5000)", S.hook_goal > 0 and tostring(S.hook_goal) or "", function(box)
        local n = tonumber((box.Text:gsub("[,%s]", "")))
        S.hook_goal = n and math.max(0, math.floor(n)) or 0
        box.Text = S.hook_goal > 0 and tostring(S.hook_goal) or ""
    end)
    action(settings_page, "Send a test", "Sends a test alert to your webhook", "TEST", function()
        if not S.hook_ok(S.hook_url) then
            notify("Paste your Discord webhook link first.")
            return
        end
        S.discord("test", "Sobriety Hub is connected", ("Alerts for **%s** will come here."):format(me.DisplayName), 0xD946EF)
        notify("Test sent.")
    end)
end
section(settings_page, "FPS AND ALERTS")
toggle(settings_page, "More FPS", "Far-away small things (bushes, reeds, lily pads, clutter) and far effects stop being drawn; up close nothing changes",
    function() return S.cull end, function(v) S.cull = v end)
segmented(settings_page, "Far means", { { 250, "250 studs" }, { 400, "400 studs" }, { 700, "700 studs" } },
    function() return S.cull_dist end, function(v) S.cull_dist = v end)
do
    local t = info(settings_page, 30)
    table.insert(painters, function()
        local hid, all = S.cull_count()
        t.Text = ("Not drawn right now: <b>%d</b> of <b>%d</b> small things"):format(hid, all)
    end)
end
toggle(settings_page, "Hide 'UNDER ATTACK' alerts", "The territory banner, its red screen edge and the alarm sound",
    function() return S.hide_raids end, function(v) S.hide_raids = v end)
section(settings_page, "WINDOW")
segmented(settings_page, "Window size", { { 0.85, "Small" }, { 1, "Normal" }, { 1.15, "Large" } },
    function() return S.ui_size end, function(v)
        S.ui_size = v
        W.layout(true)
    end)
toggle(settings_page, "Boot animation", "The pour intro when the hub loads (a short one after a server move)",
    function() return S.boot_anim end, function(v) S.boot_anim = v end)
action(settings_page, "Replay the intro", "Plays the boot animation again", "PLAY", function()
    W.hide()
    task.delay(0.25, function() pcall(play_boot, W, W.show, false) end)
end)
action(settings_page, "Unload", "Stops everything, puts the game's settings back and removes the window", "UNLOAD", function()
    if env.sobriety_feral_stop then env.sobriety_feral_stop() end
end)
W.credits(settings_page)

-- [[ toasts ]] --
local toast_area = new("Frame", { AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(300, 420),
    BackgroundTransparency = 1, ZIndex = 30, Parent = gui })
W.follow(new("UIScale", { Scale = W.L.s, Parent = toast_area }))
new("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = toast_area })
local toast_n = 0
notify = function(text)
    if not toast_area.Parent then return end
    toast_n += 1
    local kids = {}
    for _, c in ipairs(toast_area:GetChildren()) do
        if c:IsA("Frame") then table.insert(kids, c) end
    end
    if #kids >= 5 then kids[1]:Destroy() end
    local slot = new("Frame", { Size = UDim2.new(1, 0, 0, 62), BackgroundTransparency = 1, LayoutOrder = toast_n, Parent = toast_area })
    local t = new("Frame", { Position = UDim2.new(1, 30, 0, 0), Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.card, ClipsDescendants = true, Parent = slot })
    corner(t, 12)
    new("UIGradient", { Color = W.ACCENT, Parent = W.outline(t, C.white, 1, 0.35) })
    local bar = new("Frame", { Position = UDim2.fromOffset(0, 10), Size = UDim2.new(0, 3, 1, -20), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = t })
    corner(bar, 2)
    gradient(bar, 90)
    gradient(label(t, "SOBRIETY", W.BRAND, 9, C.white, { Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -20, 0, 12) }), 0)
    local body = label(t, tostring(text), REG, 12, C.text, { Position = UDim2.fromOffset(14, 22), Size = UDim2.new(1, -24, 1, -30), TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top })
    W.fit(body, slot, 22, 12, 56)
    local timer = new("Frame", { Position = UDim2.new(0, 12, 1, -3), Size = UDim2.new(1, -24, 0, 2), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = t })
    gradient(timer, 0)
    tween(t, 0.45, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Back)
    tween(timer, 4.2, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
    task.delay(4.2, function()
        if not slot.Parent then return end
        tween(t, 0.3, { Position = UDim2.new(1, 30, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.32)
        slot:Destroy()
    end)
end

-- [[ Touch buttons (phones and tablets): the keyboard-only controls as buttons on the screen: players aura (T), ]] --
-- [[ leap (V), let go (F), and the farm. Drag the top strip to move the bar; Settings can hide it.              ]] --
do
    local touch_only = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local bar = new("Frame", { AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 12, 0.42, 0), Size = UDim2.fromOffset(84, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card, BackgroundTransparency = 0.15, Visible = false, ZIndex = 25, Parent = gui })
    corner(bar, 12)
    W.outline(bar, C.stroke, 1, 0.1)
    W.follow(new("UIScale", { Scale = W.L.s, Parent = bar }))
    new("UIPadding", { PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = bar })
    new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = bar })
    -- [[ the strip to drag the bar by ]] --
    local grip = new("TextButton", { Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1, Text = "MOVE", Font = BOLD, TextSize = 9,
        TextColor3 = C.dim, AutoButtonColor = false, LayoutOrder = 0, ZIndex = 26, Parent = bar })
    local dragging, start, origin = nil, nil, nil
    grip.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, start, origin = i, i.Position, bar.Position
        end
    end)
    track(UserInputService.InputChanged:Connect(function(i)
        if dragging and (i == dragging or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = i.Position - start
            bar.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(i)
        if i == dragging or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = nil end
    end))
    local function button(order, text, fn)
        local b = new("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.bg, AutoButtonColor = false, Text = text, Font = BLACK,
            TextSize = 11, TextColor3 = C.text, LayoutOrder = order, ZIndex = 26, Parent = bar })
        corner(b, 9)
        local g = gradient(b, 0)
        g.Enabled = false
        W.pressable(b)
        b.MouseButton1Click:Connect(fn)
        return b, g
    end
    local aura_b, aura_g = button(1, "AURA", function()
        S.aura = not S.aura
        notify(S.aura and "Bite aura on players ON" or "Bite aura on players OFF (bots still get bitten)")
    end)
    button(2, "LEAP", function() S.leap() end)
    button(3, "LET GO", function() S.let_go() end)
    local farm_b, farm_g = button(4, "FARM", function()
        S.farm = not S.farm
        logf("FARM", S.farm and "turned ON" or "turned OFF")
        if not S.farm then
            S.hold = nil
            S.manual_run("going somewhere safe", function(keep) S.go_safe(keep) end)
        end
    end)
    table.insert(painters, function()
        bar.Visible = S.touch_bar and (touch_only or S.touch_bar_always)
        aura_g.Enabled = S.aura
        set_text(aura_b, nil, S.aura and C.white or C.text)
        farm_g.Enabled = S.farm
        set_text(farm_b, S.farm and "STOP" or "FARM", S.farm and C.white or C.text)
    end)
end

local function refresh()
    if not gui.Parent then return end
    for i, paint in ipairs(painters) do
        local ok, err = xpcall(paint, debug.traceback)
        if not ok and not S.paint_errs[i] then
            S.paint_errs[i] = true
            logf("ERROR", ("window part %d: %s"):format(i, tostring(err):gsub("\n", " | "):sub(1, 400)))
        end
    end
    me_sub.Text = ("%s  •  %s %s"):format(S.species(), stage(S.growth()), pct(S.growth() * 100))
    if W.current == "Logs" then
        local tail = {}
        for i = math.max(1, #S.log - 15), #S.log do table.insert(tail, S.log[i]) end
        log_view.Text = table.concat(tail, "\n")
    end
end

W.layout(false)
W.select_tab("Home")
if S.boot_anim then
    go(function()
        local ok, err = pcall(play_boot, W, W.reveal, BOOT_QUICK)
        if not ok then
            logf("ERROR", "boot animation: " .. tostring(err):sub(1, 200))
            pcall(W.reveal)
        end
    end)
else
    W.reveal()
end
    return gui, refresh
end
local gui, refresh = build_ui()

---------------------------------------------------------------- unload, loops

local function save_log()
    local wf = exec("writefile")
    if typeof(wf) ~= "function" then return end
    pcall(function() wf(LOG_FILE, table.concat(S.log, "\n")) end)
    S.log_dirty = false
    if S.events_dirty then
        pcall(function() wf(S.events_file, table.concat(S.events, "\n")) end)
        S.events_dirty = false
    end
end
env.sobriety_feral_stop = function()
    S.alive, S.farm = false, false
    S.hold = nil
    local here = coroutine.running()
    for _, th in ipairs(S.threads) do
        if th ~= here then pcall(task.cancel, th) end
    end
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
    -- [[ the game's own settings back as they were ]] --
    pcall(S.apply_patches, 1, 1, true)
    pcall(function()
        local c = me.Character
        if c and S.walk_set then c:SetAttribute("WalkKMul", nil) end
        if c and S.nostam_set then c:SetAttribute("WolfDbgNoStamina", nil) end
        if c and S.gait_set then
            c:SetAttribute("WolfDbgSprint", nil)
            c:SetAttribute("WolfDbgBurst", nil)
        end
    end)
    pcall(S.esp_clear)
    pcall(S.cull_restore)
    -- [[ the sky platform stays while you're standing on it (else you'd fall); otherwise it goes ]] --
    pcall(function()
        local p = S.afk_part()
        if p and not S.afk_up_now then p:Destroy() end
    end)
    pcall(function() S.esp_holder:Destroy() end)
    logf("FARM", "hub unloaded")
    pcall(save_log)
    pcall(function() gui:Destroy() end)
    if env.sobriety_feral_state == S then env.sobriety_feral_state = nil end
    env.sobriety_feral_stop = nil
end

-- [[ the farm on its own thread; a crash in one step is written down and the next step goes on ]] --
local function farm_loop(gen)
    while S.alive and S.farm_gen == gen do
        S.farm_beat = os.clock()
        local ok, err = pcall(S.farm_step)
        if not ok then
            S.hold = nil
            local e = tostring(err):sub(1, 300)
            if e ~= S.last_err then
                S.last_err = e
                logf("ERROR", "farm: " .. e)
            end
            task.wait(1)
        end
        task.wait()
    end
end
S.farm_gen, S.farm_beat = 1, os.clock()
go(function() farm_loop(1) end)
-- [[ the watchdog: a farm step that hasn't finished in 3 minutes is stuck on something: write down what, start fresh ]] --
go(function()
    while S.alive do
        task.wait(5)
        if os.clock() - S.farm_beat > 180 then
            local root = root_part()
            logf("ERROR", ("the farm was stuck for %ds (doing: %s, phase %s, at %s): started it again"):format(math.floor(os.clock() - S.farm_beat),
                tostring(S.status), tostring(S.phase), root and ("%.0f, %.0f, %.0f"):format(root.Position.X, root.Position.Y, root.Position.Z) or "?"))
            S.hold = nil
            S.farm_gen += 1
            S.farm_beat = os.clock()
            local g = S.farm_gen
            go(function() farm_loop(g) end)
        end
    end
end)
-- [[ the window's numbers, saved settings and the log file ]] --
go(function()
    local last_log = os.clock()
    while S.alive do
        pcall(refresh)
        local now_s = settings_json()
        local wf = exec("writefile")
        if now_s ~= S.saved_settings and now_s ~= "" and typeof(wf) == "function" then
            if pcall(wf, SETTINGS_FILE, now_s) then S.saved_settings = now_s end
        end
        if (S.log_dirty or S.events_dirty) and os.clock() - last_log > 10 then
            last_log = os.clock()
            save_log()
        end
        task.wait(0.5)
    end
end)
notify(S.settings_loaded and (S.farm and "Your settings are back and the farm is running." or "Your settings are back.") or "Sobriety Hub is on. Press START FARM.")
