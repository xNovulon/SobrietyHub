-- Sobriety Hub  ·  made by Novulon  ·  Discord: 1z11 (suggestions and script requests only)
-- Open source and free to use: https://github.com/xNovulon/SobrietyHub
-- If you use this work to make a new script or an updated version, I'd appreciate a credit.
-- Loader: loadstring(game:HttpGet("https://raw.githubusercontent.com/xNovulon/SobrietyHub/main/hub.lua"))()

-- Sobriety Hub: Mog to Steal an Egg
-- The clicking fight runs on your own game, which then tells the server who won (Eggs.Resolve).
--   Always win:  the guard can't push your bar back and every click counts 10x, so the game's own fight is won.
--   Force win:   if a fight is lost anyway, the result sent to the server says you won, and you don't get flung.
--   Auto mog:    turns on the game's own Auto Mog on your side (auto clicks in fights, auto mogs eggs next to you).
--   Auto farm:   steals eggs (instant ones too), takes each pet that hatches, and brings it into the safe zone,
--                where the server puts it in your inventory. Event and Titanic eggs are taken first.
--                Up to 12 eggs hatch at once while it keeps stealing. Built to run overnight (no idle rejoin).
-- Right Alt (or the round S button) hides / shows the window. Running it again restarts it.
--
-- Map of the file, top to bottom:
--   state and settings  ->  the game's code and hooks  ->  helpers (moving, ground, streaming)  ->  stages and eggs
--   ->  mogging (steal)  ->  pets (hatch book, taking, banking, gifting)  ->  the farm (farm_step)  ->  treadmill,
--   ghost walk, fly  ->  protection (ragdoll, bat thieves)  ->  pets advisor, auto sell, grow babies  ->  menus
--   ->  logs and reports  ->  reconnect  ->  server hop  ->  the window (Sobriety Hub)  ->  unload, auto progress,
--   the farm loop and the watchdog.
local env = (typeof(getgenv) == "function" and getgenv()) or _G
local fenv = getfenv()
local function exec(name) return env[name] or fenv[name] end
local hookmetamethod, getnamecallmethod = exec("hookmetamethod"), exec("getnamecallmethod")
local fireproximityprompt, getconnections = exec("fireproximityprompt"), exec("getconnections")
if env.mog_helper_stop then pcall(env.mog_helper_stop) end
-- [[ this run's token: if another copy starts while this one is still loading (two queued reloads, autoexec ]] --
-- [[ plus a reload), the older one sees it isn't the newest and quits before it starts anything             ]] --
local RUN = {}
env.mog_helper_run = RUN

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local me = Players.LocalPlayer

local function notify(text)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Sobriety Hub", Text = text, Duration = 5 }) end)
end

---------------------------------------------------------------- the game's own code

local Controllers = me:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers")
local okM, MogController = pcall(require, Controllers:WaitForChild("MogController"))
local okE, EggController = pcall(require, Controllers:WaitForChild("EggController"))
if not (okM and okE and type(MogController) == "table" and type(EggController) == "table") then
    notify("Couldn't load the game's mog code, so nothing was changed.")
    return
end
local zone_module = RS:WaitForChild("Shared"):WaitForChild("Utilities"):WaitForChild("SafeZoneUtil", 10)
local okZ, SafeZoneUtil = false, nil
if zone_module then okZ, SafeZoneUtil = pcall(require, zone_module) end
if not (okZ and type(SafeZoneUtil) == "table") then SafeZoneUtil = nil end
local Remotes = RS:WaitForChild("Remotes")
local Eggs = Remotes:WaitForChild("Eggs")

local MAX_HATCHING, GLIDE_SPEED, INSTANT_RATIO = 12, 650, 2 -- the game has no hatch limit; pets last 45s on the ground
-- [[ where each stage is (the map runs along X from the safe zone), used when a stage isn't loaded around you ]] --
local STAGE_X = { Stage1 = -716, Stage2 = -830, Stage3 = -972, Stage4 = -1159, Stage5 = -1406, Stage6 = -1714, Stage7 = -2143, Stage8 = -2661, Stage9 = -3179 }
-- [[ the stage list comes from the game's own ZoneConfig plus the stage folders in the map, so new stages ]] --
-- [[ (Stage 10 and anything after) show up by themselves. Falls back to Stage 1-9 if neither can be read.  ]] --
local STAGE_NAMES = {}
do
    local seen = {}
    local function add(name)
        if type(name) == "string" and name:match("^Stage%d+$") and not seen[name] then
            seen[name] = true
            table.insert(STAGE_NAMES, name)
        end
    end
    pcall(function()
        local ok, zc = pcall(require, RS:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("ZoneConfig", 10))
        if ok and type(zc) == "table" and type(zc.Stages) == "table" then
            for name in pairs(zc.Stages) do add(name) end
        end
    end)
    pcall(function()
        for _, f in ipairs(workspace:WaitForChild("Game", 10):WaitForChild("Stages", 10):GetChildren()) do add(f.Name) end
    end)
    for i = 1, 9 do add("Stage" .. i) end
    table.sort(STAGE_NAMES, function(a, b) return tonumber(a:match("%d+")) < tonumber(b:match("%d+")) end)
end
local function stage_num(name) return tonumber(tostring(name):match("%d+")) or 0 end
local SAFE_FALLBACK = Vector3.new(-545, 8, 0)

local S = {
    alive = true, conns = {}, tried = {}, loot_fail = {}, pending = {}, hatching = {},
    always_win = true, force_win = true, auto_mog = false, farm = false, equip_best = true,
    skip_fight = true, skip_wait = 3.15, skip_fail = 0, fast_mog = true, fast_fail = 0, last_challenge = 0, parallel_mog = true, fights = 0, parallel_fail = 0, parallel_reject = 0,
    auto_mutate = false, fusing = false, last_fuse = 0, mutated = 0, fuse_fail = {}, last_mutate = nil,
    treadmill = false, on_mill = false, empty_runs = 0,
    anti_ragdoll = true, anti_void = true, carry_drop = true, carry_since = 0, void_hold = false, bat_thieves = true, my_pets = {}, won_back = {}, advised_at = 0,
    gift = false, gifted = {}, gifted_count = 0, farm_off_by = nil, gift_min = 0, carry_income = -1,
    hatched = {}, hatched_by_id = {}, hatch_dirty = false, hatch_file = "MogHub_Hatched_" .. os.date("%Y%m%d_%H%M") .. ".txt",
    loop_tick = os.clock(), logged_status = "", last_mut_err = "", last_ui_err = "", settings_loaded = false, saved_settings = "",
    menu_entries = {}, threads = {}, restart_farm = nil, auto_off = {}, stage_pos = {}, carry_rank = 0, update_note = "", last_appeal = 0, last_peek = 0, special_seen = {}, last_step_t = 0, base_mult = 0, mult_t = 0, boosted = false, boost_until = 0, spawn_logs = 0, progress_seen = {}, hit_t = 0, guard_logged = {}, guarded = {}, maxed = {}, broke = {},
    auto_sell = false, sell_ratio = 100, sell_old = true, pet_seen = {}, sell_plan = nil, sell_now = nil,
    auto_ascend = true, auto_rebirth = true, auto_pen = true, auto_coach = true, auto_index = true, decline_battles = true,
    auto_reconnect = true, rejoining = false, no_rejoin = false,
    grow_babies = true, grow_hours = 72, grow_fail = {}, grow_note = "-", grow_swaps = 0, last_grow = 0, grow_full = false,
    hop_mode = "Off", hop_note = "-", hop_min = 0.5, hop_max = 1, fly_speed = 100, walk_speed = 60,
    skip_junk = true, take_others = true, auto_daily = true, skipped = {}, skipped_count = 0, free_count = 0, sell_floor = true, wanted = {}, let_go = {}, speed_first = true,
    mill_mog = true, farm_mode = "Normal", mode_backup = {}, gate_off_since = 0, boot_anim = true, ui_size = 1,
    auto_rejoin = true, rejoin_mins = 20, rejoin_due = false, rejoin_note = "-", rejoin_going = false,
    auto_aura = true, auto_mill_upgrade = true, always_events = true, mill_tried = setmetatable({}, { __mode = "k" }), last_bank_t = 0, last_knock_t = 0,
    stages = {}, pick = "Best", travel = "Teleport", click_mult = 10, status = "Ready",
    delivered = 0, last = nil, need_equip = false, last_equip = 0, scout_i = 0, manual = false,
    resolve = Eggs:WaitForChild("Resolve"), flung = Eggs:WaitForChild("Flung"),
}
local function track(c) table.insert(S.conns, c) return c end
-- [[ every background job the helper starts is written down here, so Unload can stop each one mid-way ]] --
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
if env.mog_helper_run ~= RUN then return end
env.mog_helper_state = S
-- [[ a stop that works from here on, so a newer copy can always shut this one down (the full Unload, which ]] --
-- [[ also puts the game's code back, replaces it once everything is loaded)                                ]] --
env.mog_helper_stop = function()
    S.alive, S.farm = false, false
    local here = coroutine.running()
    for _, th in ipairs(S.threads) do
        if th ~= here then pcall(task.cancel, th) end
    end
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
end

-- [[ the recorder: everything worth knowing in the morning (errors, the farm turning on/off and why, hits,  ]] --
-- [[ falls, treadmill, banked pets...). Kept in memory, shown in the Logs tab, saved to MogHub_Log.txt.     ]] --
S.log, S.status_log, S.session_start = {}, {}, os.clock()
local function logf(kind, text)
    local line = ("[%s +%dm] %s: %s"):format(os.date("%H:%M:%S"), math.floor((os.clock() - S.session_start) / 60), kind, tostring(text))
    table.insert(S.log, line)
    if #S.log > 2000 then table.remove(S.log, 1) end
    S.log_dirty = true
end
logf("START", "Sobriety Hub loaded (Mog to Steal an Egg)")

-- [[ your settings are remembered in MogHub_Settings.json (Potassium's workspace folder) and loaded next time ]] --
local HttpService = game:GetService("HttpService")
local SETTING_KEYS = { "always_win", "force_win", "skip_fight", "fast_mog", "parallel_mog", "auto_mog", "farm", "equip_best", "auto_mutate", "treadmill",
    "anti_ragdoll", "anti_void", "carry_drop", "bat_thieves", "gift", "gift_min", "stages", "pick", "travel",
    "auto_ascend", "auto_rebirth", "auto_pen", "auto_coach", "auto_index", "decline_battles",
    "auto_aura", "auto_mill_upgrade", "always_events", "auto_sell", "sell_ratio", "sell_old", "auto_reconnect", "grow_babies", "grow_hours", "hop_mode", "hop_min", "hop_max", "fly_speed", "walk_speed",
    "skip_junk", "take_others", "auto_daily", "sell_floor", "speed_first", "mill_mog", "farm_mode", "mode_backup", "boot_anim", "ui_size",
    "auto_rejoin", "rejoin_mins" }
local function settings_json()
    local t = {}
    for _, k in ipairs(SETTING_KEYS) do t[k] = S[k] end
    -- [[ a switch that turned itself off (the server said no a few times) is saved as on: it only stays off for ]] --
    -- [[ this session, and the next one tries again                                                            ]] --
    for k in pairs(S.auto_off) do
        if t[k] == false then t[k] = true end
    end
    local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
    return ok and s or ""
end
pcall(function()
    local readfile, isfile = exec("readfile"), exec("isfile")
    if typeof(readfile) == "function" and typeof(isfile) == "function" and isfile("MogHub_Settings.json") then
        local t = HttpService:JSONDecode(readfile("MogHub_Settings.json"))
        for _, k in ipairs(SETTING_KEYS) do
            if t[k] ~= nil and type(t[k]) == type(S[k]) then S[k] = t[k] end
        end
        S.settings_loaded = true
        logf("START", "settings loaded: " .. settings_json())
    end
end)
S.saved_settings = settings_json()
if S.hop_mode ~= "Bigger" and S.hop_mode ~= "Grab" and S.hop_mode ~= "Boosts" and S.hop_mode ~= "Events" then S.hop_mode = "Off" end
if S.farm_mode ~= "Treadmill" then S.farm_mode = "Normal" end
if S.ui_size ~= 0.85 and S.ui_size ~= 1 and S.ui_size ~= 1.15 then S.ui_size = 1 end
if S.rejoin_mins ~= 10 and S.rejoin_mins ~= 20 and S.rejoin_mins ~= 30 and S.rejoin_mins ~= 60 then S.rejoin_mins = 20 end
-- [[ Farm mode. Treadmill farm saves the settings it needs to change, then sets them: farm on, Auto treadmill on, ]] --
-- [[ Speed first on, Always events on, Server hop on Event chase. Normal farm puts every one of them back.          ]] --
S.set_farm_mode = function(mode)
    if mode == S.farm_mode then return end
    local keys = { "farm", "treadmill", "speed_first", "hop_mode", "always_events" }
    if mode == "Treadmill" then
        local backup = {}
        for _, k in ipairs(keys) do backup[k] = S[k] end
        S.mode_backup = backup
        S.farm, S.treadmill, S.speed_first, S.hop_mode, S.always_events = true, true, true, "Events", true
        logf("FARM", "Treadmill farm on: training, and only event eggs in the top stage (your normal farm settings are saved)")
    else
        for _, k in ipairs(keys) do
            if S.mode_backup[k] ~= nil then S[k] = S.mode_backup[k] end
        end
        S.mode_backup = {}
        if S.chase_off then S.chase_off() end
        logf("FARM", "back to the normal farm, your settings are restored")
    end
    S.farm_mode = mode
    if S.hop_reset then S.hop_reset() end
end
S.hop_min, S.hop_max = math.min(S.hop_min, S.hop_max), math.max(S.hop_min, S.hop_max)
-- [[ while server hopping, every server would start a new hatch book file ]] --
if S.hop_mode ~= "Off" then S.hatch_file = "MogHub_Hatched_hopping.txt" end

-- [[ update check: what the game has (stages, remotes, configs, menus, map folders) is written to          ]] --
-- [[ MogHub_GameInfo.json. Next time, anything new is listed in the Logs tab (UPDATE lines) and shown when ]] --
-- [[ the helper starts. New stages are added to the window by themselves; for the rest, paste the log.     ]] --
do
    local read_f, write_f, is_f = exec("readfile"), exec("writefile"), exec("isfile")
    local now = { version = game.PlaceVersion, stages = STAGE_NAMES, remotes = {}, configs = {}, menus = {}, map = {} }
    pcall(function()
        for _, r in ipairs(Remotes:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") or r:IsA("UnreliableRemoteEvent") then
                table.insert(now.remotes, (r:GetFullName():gsub("^ReplicatedStorage%.Remotes%.", "")))
            end
        end
    end)
    pcall(function() for _, m in ipairs(RS.Shared.Configs:GetChildren()) do table.insert(now.configs, m.Name) end end)
    pcall(function()
        local frames = me:WaitForChild("PlayerGui", 5):FindFirstChild("Frames")
        for _, f in ipairs(frames and frames:GetChildren() or {}) do table.insert(now.menus, f.Name) end
    end)
    pcall(function() for _, c in ipairs(workspace:WaitForChild("Game", 5):GetChildren()) do table.insert(now.map, c.Name) end end)
    local news = {}
    pcall(function()
        if not (typeof(read_f) == "function" and typeof(is_f) == "function" and is_f("MogHub_GameInfo.json")) then return end
        local old = HttpService:JSONDecode(read_f("MogHub_GameInfo.json"))
        if old.version ~= now.version then
            table.insert(news, ("the game was updated: version %s -> %s"):format(tostring(old.version), tostring(now.version)))
        end
        local LABEL = { stages = "stage (added to the window)", remotes = "remote", configs = "config", menus = "menu (in the Menus tab)", map = "map folder" }
        for _, key in ipairs({ "stages", "remotes", "configs", "menus", "map" }) do
            local had = {}
            for _, v in ipairs(old[key] or {}) do had[v] = true end
            for _, v in ipairs(now[key]) do
                if not had[v] then table.insert(news, ("new %s: %s"):format(LABEL[key], v)) end
            end
        end
    end)
    for _, line in ipairs(news) do logf("UPDATE", line) end
    if #news > 0 then
        S.update_note = ("Game update found: %d new things. New stages are already in the window; the rest is in the Logs tab."):format(#news)
    end
    if typeof(write_f) == "function" then pcall(function() write_f("MogHub_GameInfo.json", HttpService:JSONEncode(now)) end) end
end

-- [[ Always win: the guard the game builds for each fight gets no push, and your clicks count more ]] --
local original_resolve = env.mog_helper_resolve_original or MogController.ResolveEnemy
env.mog_helper_resolve_original = original_resolve
MogController.ResolveEnemy = function(...)
    local enemy = original_resolve(...)
    if S.alive and S.always_win and type(enemy) == "table" then
        local ok, copy = pcall(table.clone, enemy)
        enemy = ok and copy or enemy
        enemy.PushRate = 0
        enemy.PushRamp = 0
        enemy.ClickScale = (tonumber(enemy.ClickScale) or 1) * S.click_mult
    end
    return enemy
end

-- [[ Skip fights: instant mog is decided by the server (egg appeal x2 must be at or below yours), so it can't be   ]] --
-- [[ forced. But a fight's result comes from your game, and the server only wants it to last 3 seconds          ]] --
-- [[ (EggConfig.Challenge.MinWinSeconds). So for egg fights the guard doesn't walk over, there's no countdown or ]] --
-- [[ clicking, and the win is reported after 3.4s. Fights against players (MogBattle) are left alone.            ]] --
local original_ready = env.mog_helper_ready_original or MogController.GetReady
local original_approach = env.mog_helper_approach_original or MogController.Approach
local original_start = env.mog_helper_start_original or MogController.Start
env.mog_helper_ready_original, env.mog_helper_approach_original, env.mog_helper_start_original = original_ready, original_approach, original_start
local function skipping() return S.alive and S.skip_fight and (EggController.IsBusy() or S.farm) end
MogController.GetReady = function(...)
    if skipping() then return function() end end
    return original_ready(...)
end
MogController.Approach = function(...)
    if skipping() then return { To = function() end, Return = function() end } end
    return original_approach(...)
end
MogController.Start = function(enemy, options, ...)
    if skipping() and options == nil then
        S.status = "Skipping the fight (the server wants 3s)"
        task.wait(S.skip_wait)
        return true
    end
    return original_start(enemy, options, ...)
end

-- [[ Force win: the fight result sent to the server always says won, and the fling for losing isn't sent. ]] --
-- [[ The hook only compares and forwards: calling any method in it would replace the call being made.     ]] --
if not env.mog_helper_hooked and typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
    env.mog_helper_hooked = true
    pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local st = env.mog_helper_state
            if st and st.alive and st.force_win and (self == st.resolve or self == st.flung) and getnamecallmethod() == "FireServer" then
                if self == st.flung then return nil end
                local id = ...
                return old(self, id, true)
            end
            return old(self, ...)
        end)
        env.mog_helper_namecall_old = old
    end)
end

-- [[ Auto mog: the game's own Auto Mog reads this attribute on your side ]] --
local auto_original = me:GetAttribute("AutoMog")
local function set_auto(on)
    S.auto_mog = on
    me:SetAttribute("AutoMog", on and true or auto_original)
end

-- [[ No idle rejoin: the game sends you to a new server after 18 minutes without input, which would stop   ]] --
-- [[ the farm. Its idle handler is paused while this runs, and a tiny click resets Roblox's own idle timer. ]] --
local paused_idle = {}
if typeof(getconnections) == "function" then
    pcall(function()
        for _, c in ipairs(getconnections(me.Idled)) do
            if pcall(function() c:Disable() end) then table.insert(paused_idle, c) end
        end
    end)
end
track(me.Idled:Connect(function(seconds)
    logf("IDLE", ("Roblox says you've been idle %ds, sent a tiny click"):format(math.floor(tonumber(seconds) or 0)))
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.zero)
    end)
end))

---------------------------------------------------------------- helpers

local SUFFIX = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }
local function short(n)
    n = tonumber(n) or 0
    local i = 1
    while math.abs(n) >= 1000 and i < #SUFFIX do
        n /= 1000
        i += 1
    end
    return i == 1 and tostring(math.floor(n)) or (("%.1f%s"):format(n, SUFFIX[i]))
end
local function root_part()
    local char = me.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function where(inst)
    local ok, pos = pcall(function()
        if inst:IsA("Model") then return inst:GetPivot().Position end
        if inst:IsA("Attachment") then return inst.WorldPosition end
        return inst.Position
    end)
    return ok and pos or nil
end
local function dist_to(pos)
    local root = root_part()
    return (root and pos) and (pos - root.Position).Magnitude or math.huge
end
local function power() return tonumber(me:GetAttribute("Power")) or 0 end
local function carrying() return me:GetAttribute("CarryingLoot") ~= nil end
local function down()
    local char = me.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return not hum or hum.Health <= 0 or char:GetAttribute("Ragdolled") == true
end
local function busy() return EggController.IsBusy() or MogController.IsFighting() end
-- [[ After a hit the server takes over your character (the game's Ragdoll.Fling: SetNetworkOwner(nil)) until it ]] --
-- [[ stands you back up, then puts you where IT thinks you are. Anti ragdoll only fixes your screen, so moves  ]] --
-- [[ made in that time never reach the server: the pet "goes home" on your screen but stays by the guard, who   ]] --
-- [[ kicks again. So after a hit, nothing moves until the server gives your character back.                    ]] --
local isnetworkowner = exec("isnetworkowner")
local function own_body()
    local root = root_part()
    if not root then return false end
    if typeof(isnetworkowner) == "function" then
        local ok, yes = pcall(isnetworkowner, root)
        if ok and type(yes) == "boolean" then return yes end
    end
    return root.ReceiveAge == 0
end
local function body_held() return os.clock() - S.hit_t < 2.5 or (os.clock() - S.hit_t < 8 and not own_body()) end
local function wait_body(why)
    if not body_held() then return end
    local t = os.clock()
    S.status = "The game is holding your character after a hit, waiting for it to let go"
    while S.alive and body_held() do task.wait(0.05) end
    logf("HIT", ("the server held your character for %.1fs after the hit (%s)"):format(os.clock() - t, why))
end

-- [[ finds the floor under a spot (only solid parts), so you stand on it instead of falling ]] --
local ray_params = RaycastParams.new()
ray_params.FilterType = Enum.RaycastFilterType.Exclude
ray_params.RespectCanCollide = true
local function ground(pos)
    ray_params.FilterDescendantsInstances = { me.Character }
    local hit = workspace:Raycast(Vector3.new(pos.X, pos.Y + 60, pos.Z), Vector3.new(0, -300, 0), ray_params)
    return hit and (hit.Position + Vector3.new(0, 3.5, 0)) or pos
end

local function floor_below(pos)
    ray_params.FilterDescendantsInstances = { me.Character }
    return workspace:Raycast(pos + Vector3.new(0, 4, 0), Vector3.new(0, -150, 0), ray_params)
end
-- [[ is there room to stand here (no wall / rock / egg inside your body)? ]] --
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Exclude
overlap.RespectCanCollide = true
local function free_spot(pos, also_ignore)
    overlap.FilterDescendantsInstances = { me.Character, also_ignore }
    local ok, parts = pcall(function() return workspace:GetPartBoundsInBox(CFrame.new(pos), Vector3.new(2.5, 4.5, 2.5), overlap) end)
    return not ok or #parts == 0
end
-- [[ the nearest spot around `pos` (up to 14 studs away, about the same height) with floor under it and room ]] --
-- [[ to stand, for when a jump lands you inside a wall or a rock                                              ]] --
local function unstick(pos)
    ray_params.FilterDescendantsInstances = { me.Character }
    for _, r in ipairs({ 0, 5, 9, 14 }) do
        for i = 0, (r == 0 and 0 or 7) do
            local a = i * math.pi / 4
            local c = pos + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
            local top = workspace:Raycast(c + Vector3.new(0, 30, 0), Vector3.new(0, -60, 0), ray_params)
            if top then
                local stand = top.Position + Vector3.new(0, 3.5, 0)
                if math.abs(stand.Y - pos.Y) < 20 and free_spot(stand) then return stand end
            end
        end
    end
    return nil
end
local function freeze(root, cf)
    root.CFrame = cf
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end
-- [[ asks the game to load the map around a spot, on the side: the jump never waits for it. Waiting here is  ]] --
-- [[ what left you standing next to the guard with a pet in your hands until he knocked it loose.           ]] --
-- [[ hold_until_ground keeps you in place at the new spot until its floor is in.                            ]] --
local function stream_around(pos, timeout)
    task.spawn(function()
        local t = os.clock()
        pcall(function() me:RequestStreamAroundAsync(pos, timeout) end)
        if os.clock() - t > timeout then
            logf("MOVE", ("map took over %ds to load around %d, %d (you were already there)"):format(timeout, pos.X, pos.Z))
        end
    end)
end

-- [[ the map only loads around where you are, so right after a long jump there's no floor yet. This holds you  ]] --
-- [[ in place (every frame, so the server sees you there and loads it) until the floor under you is in, then  ]] --
-- [[ sets you down on it. Holding by position instead of Anchored, because an anchored you stops replicating. ]] --
local function hold_until_ground(cf, max_wait)
    local start = os.clock()
    local hit = floor_below(cf.Position)
    while not hit and S.alive and os.clock() - start < max_wait do
        local root = root_part()
        if not root then return cf end
        freeze(root, cf)
        RunService.Heartbeat:Wait()
        hit = floor_below(cf.Position)
        -- [[ the map is loaded here but no floor shows under you: you're inside a rock or a wall (a ray that ]] --
        -- [[ starts inside a part can't see it), so step out to the nearest clear spot instead of waiting      ]] --
        if not hit and os.clock() - start > 0.3 then
            local okL, near = pcall(function() return workspace:GetPartBoundsInRadius(cf.Position, 30, overlap) end)
            if okL and #near > 0 then
                local spot = unstick(cf.Position)
                if spot then
                    logf("MOVE", ("landed inside something at %d, %d, %d, stepped out"):format(cf.Position.X, cf.Position.Y, cf.Position.Z))
                    cf = CFrame.new(spot) * cf.Rotation
                    hit = floor_below(spot)
                end
            end
        end
    end
    -- [[ floor found but you'd be standing inside a wall: step out too ]] --
    if hit and not free_spot(cf.Position) then
        local spot = unstick(cf.Position)
        if spot then cf = CFrame.new(spot) * cf.Rotation end
    end
    if hit then
        local y = hit.Position.Y + 3.5
        if cf.Position.Y < y or cf.Position.Y - y > 12 then cf = CFrame.new(cf.Position.X, y, cf.Position.Z) * cf.Rotation end
        S.last_good = cf.Position
    else
        logf("MOVE", ("no floor loaded under %d, %d, %d after %ds"):format(cf.Position.X, cf.Position.Y, cf.Position.Z, max_wait))
    end
    return cf
end

-- [[ moves you: Teleport is instant; Glide flies there fast in a short arc. Either way it waits for the ground. ]] --
local before_travel = nil -- set further down: steps you off the treadmill first
local mount, train_for, admin_step -- the treadmill and admin abuse, further down
local find_thief, bat_thief -- protection, further down
local function travel(pos, look)
    if not S.alive then return false end
    if before_travel then before_travel() end
    local root = root_part()
    if not root then return false end
    local from = root.Position
    local far = (pos - from).Magnitude
    if far > 150 then stream_around(pos, 4) end
    root = root_part()
    if not root then return false end
    local face = look and CFrame.lookAt(pos, Vector3.new(look.X, pos.Y, look.Z)) or (CFrame.new(pos) * root.CFrame.Rotation)
    if S.travel == "Glide" and far > 30 then
        local length, t = far / GLIDE_SPEED, 0
        while t < length and S.alive do
            t += RunService.Heartbeat:Wait()
            root = root_part()
            if not root then return false end
            local a = math.min(t / length, 1)
            root.CFrame = CFrame.new(from:Lerp(pos, a) + Vector3.new(0, math.sin(a * math.pi) * math.min(far * 0.1, 80), 0)) * face.Rotation
            root.AssemblyLinearVelocity = Vector3.zero
        end
        root = root_part()
        if not root then return false end
    end
    freeze(root, face)
    face = hold_until_ground(face, far > 300 and 10 or 3)
    root = root_part()
    if not root then return false end
    freeze(root, face)
    return true
end

-- [[ Anti void (always on unless switched off): if you drop below the map, you're held at a safe height right ]] --
-- [[ there; if the floor under you loads within 2.5s you're set down on it. If it doesn't (you were flung off  ]] --
-- [[ the map), you're taken back to your spawn, and the farm is restarted from a clean start.                 ]] --
do
    local rescue, since = nil, 0
    local function spawn_spot()
        local g = workspace:FindFirstChild("Game")
        local plots = g and g:FindFirstChild("Plots")
        local plot = plots and plots:FindFirstChild(tostring(me:GetAttribute("Plot")))
        local sp = plot and plot:FindFirstChild("SpawnPoint")
        if sp and sp:IsA("BasePart") then return sp.Position + Vector3.new(0, 4, 0) end
        return SAFE_FALLBACK
    end
    local function go_home()
        S.void_hold = true
        if S.farm_thread and S.farm_thread ~= coroutine.running() then pcall(task.cancel, S.farm_thread) end
        local spot = spawn_spot()
        task.spawn(function() pcall(function() me:RequestStreamAroundAsync(spot, 6) end) end)
        local root = root_part()
        if root then
            freeze(root, CFrame.new(spot))
            local cf = hold_until_ground(CFrame.new(spot), 10)
            root = root_part()
            if root then freeze(root, cf) end
        end
        S.void_hold = false
        logf("VOID", "back at your spawn" .. (S.farm and ", farm restarted" or ""))
        -- [[ the farm loop also runs Auto treadmill with the farm off, so it's always started again ]] --
        if S.restart_farm then S.restart_farm() end
    end
    track(RunService.Heartbeat:Connect(function()
        if not S.anti_void or S.void_hold then rescue = nil return end
        local root = root_part()
        if not root then rescue = nil return end
        if not rescue and root.Position.Y < -60 then
            local back = S.last_good
            rescue, since = CFrame.new(root.Position.X, back and back.Y + 6 or 20, root.Position.Z), os.clock()
            logf("FELL", ("fell below the map at %d, %d (status: %s), holding you until the floor loads"):format(root.Position.X, root.Position.Z, S.status))
            local at = rescue.Position
            task.spawn(function() pcall(function() me:RequestStreamAroundAsync(at, 6) end) end)
        end
        if rescue then
            local hit = floor_below(rescue.Position)
            if hit then
                freeze(root, CFrame.new(rescue.Position.X, hit.Position.Y + 3.5, rescue.Position.Z))
                rescue = nil
            elseif os.clock() - since > 2.5 then
                rescue = nil
                logf("VOID", "no floor came in under you, taking you back to your spawn")
                S.void_hold = true
                task.spawn(go_home)
            else
                freeze(root, rescue)
            end
        end
    end))
end

---------------------------------------------------------------- stages and eggs

local function game_folder(name)
    local g = workspace:FindFirstChild("Game")
    return g and g:FindFirstChild(name)
end
-- [[ where a stage is: its Hitbox when loaded; otherwise the middle of its boss's patrol (the boss model stays ]] --
-- [[ in the map even far away, so this also finds new stages); otherwise the known spots; otherwise a guess   ]] --
-- [[ past the last known stage (the map runs along -X).                                                       ]] --
local function stage_center(name)
    local stage = game_folder("Stages") and game_folder("Stages"):FindFirstChild(name)
    local box = stage and stage:FindFirstChild("Hitbox")
    if box and box:IsA("BasePart") then
        local c = Vector3.new(box.Position.X, 8, box.Position.Z)
        S.stage_pos[name] = c
        return c
    end
    for _, m in ipairs(stage and stage:GetChildren() or {}) do
        local a, b = m:GetAttribute("PatrolFrom"), m:GetAttribute("PatrolTo")
        if typeof(a) == "Vector3" and typeof(b) == "Vector3" then
            local mid = (a + b) / 2
            return Vector3.new(mid.X, 8, mid.Z)
        end
    end
    if S.stage_pos[name] then return S.stage_pos[name] end
    if STAGE_X[name] then return Vector3.new(STAGE_X[name], 8, 0) end
    local n = stage_num(name)
    if n > 9 then return Vector3.new(STAGE_X.Stage9 - (n - 9) * 650, 8, 0) end
    return nil
end

-- [[ every egg in the world, as it loads in around you ]] --
local all_eggs = setmetatable({}, { __mode = "k" })
-- [[ the game's list of normal eggs (EggConfig.Eggs). An egg that isn't on it (and isn't the Titanic egg) was ]] --
-- [[ spawned by an admin or a new event: it's treated as an event egg, so it's taken before anything else.     ]] --
local KNOWN_EGGS = {}
pcall(function()
    local ok, ec = pcall(require, RS:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("EggConfig", 10))
    if ok and type(ec) == "table" and type(ec.Eggs) == "table" then
        for name in pairs(ec.Eggs) do KNOWN_EGGS[name] = true end
    end
end)
local function is_special(egg)
    if next(KNOWN_EGGS) == nil or egg:GetAttribute("GiantEgg") == true then return false end
    return not (KNOWN_EGGS[egg.Name] or KNOWN_EGGS[tostring(egg:GetAttribute("DisplayName"))])
end
local function note_egg(d)
    if d:IsA("Model") and d:GetAttribute("EggId") ~= nil then
        all_eggs[d] = true
        local id = d:GetAttribute("EggId")
        if is_special(d) and not S.special_seen[id] then
            S.special_seen[id] = true
            logf("SPECIAL", ("egg the game doesn't normally have: %s (%s, %s appeal) at %s | %s"):format(d.Name, tostring(d:GetAttribute("Rarity")),
                tostring(d:GetAttribute("RecommendedAppeal")), tostring(where(d)), tostring(d:GetAttribute("Stage"))))
            if S.farm then notify("Special egg spawned: " .. d.Name .. ", going for it.") end
        end
    end
end
pcall(function() for _, d in ipairs(workspace:GetDescendants()) do note_egg(d) end end)
track(workspace.DescendantAdded:Connect(function(d)
    if d:IsA("Model") then task.defer(function() if d.Parent then note_egg(d) end end) end
end))
local function stage_of(egg)
    local folder = game_folder("Stages")
    local m = egg.Parent
    while m and folder and m.Parent ~= folder and m ~= workspace do m = m.Parent end
    return (m and folder and m.Parent == folder) and m.Name or nil
end
-- [[ event eggs: the Titanic egg (GiantEgg), or anything spawned outside the normal stages ]] --
local function is_event(egg) return egg:GetAttribute("GiantEgg") == true or stage_of(egg) == nil or is_special(egg) end
-- [[ the stages you picked: any mix of Events and the stages (none picked = any stage) ]] --
local function picked_stages(all_if_none)
    local list = {}
    for i = #STAGE_NAMES, 1, -1 do
        if S.stages[STAGE_NAMES[i]] or (all_if_none and next(S.stages) == nil) then table.insert(list, STAGE_NAMES[i]) end
    end
    return list
end
local function any_stage() return next(S.stages) == nil end
local function events_only() return S.stages.Events == true and #picked_stages(false) == 0 end
local function stage_ok(egg)
    if any_stage() or is_special(egg) or (S.always_events and is_event(egg)) then return true end
    if S.stages.Events and is_event(egg) then return true end
    local st = stage_of(egg)
    return st ~= nil and S.stages[st] == true
end
local function stages_text()
    if any_stage() then return "Any stage" end
    local nums = {}
    for _, name in ipairs(STAGE_NAMES) do if S.stages[name] then table.insert(nums, tostring(stage_num(name))) end end
    local text = #nums > 0 and ((#nums == 1 and "Stage " or "Stages ") .. table.concat(nums, ", ")) or ""
    if S.stages.Events then text = text ~= "" and (text .. " + Events") or "Events only" end
    return text
end
local function appeal_of(egg) return tonumber(egg:GetAttribute("RecommendedAppeal")) or 0 end
local function is_instant(egg) return not is_event(egg) and appeal_of(egg) * INSTANT_RATIO <= power() end
-- [[ how much an egg is worth going for: event eggs above everything, then the highest stage. Not appeal: in a  ]] --
-- [[ stage, appeal only follows egg size, and your logs show small eggs hatch the same pets (all 3 good pets in ]] --
-- [[ 253 eggs came from the smallest ones). So within a stage the nearest egg goes first: less travel.         ]] --
local function egg_rank(egg) return is_event(egg) and math.huge or stage_num(stage_of(egg) or egg:GetAttribute("Stage")) end
-- [[ an egg's size: EggScale is rolled from 0.5 to 1 when it spawns (big ones are rare) and a bigger egg hatches a ]] --
-- [[ bigger pet. Used for the biggest egg record and the server hop.                                              ]] --
S.egg_info = function(egg)
    return { name = tostring(egg:GetAttribute("DisplayName") or egg.Name), scale = tonumber(egg:GetAttribute("EggScale")),
        stage = stage_of(egg) or tostring(egg:GetAttribute("Stage") or "?"), rarity = tostring(egg:GetAttribute("Rarity") or "?"),
        luck = tonumber(egg:GetAttribute("Luck")), event = is_event(egg) }
end
-- [[ A fight left open (the helper was run again in the middle of one, or it broke): the server keeps you      ]] --
-- [[ "AlreadyBusy" until it gets that fight's result, so no egg can be mogged, not even with the game's own     ]] --
-- [[ prompt. Any loaded egg still "Challenged" by you while no fight runs here gets its result sent (won), the  ]] --
-- [[ same message the game sends at the end of a fight.                                                       ]] --
S.resolve_stuck = function()
    if S.fights > 0 or EggController.IsBusy() or MogController.IsFighting() then return 0 end
    local n = 0
    for egg in pairs(all_eggs) do
        if egg.Parent and egg:GetAttribute("EggHolder") == me.UserId and egg:GetAttribute("EggState") == "Challenged" then
            local id = egg:GetAttribute("EggId")
            if id then
                pcall(function() S.resolve:FireServer(id, true) end)
                n += 1
                logf("STEAL", ("the server still had you in a fight for %s, sent its result so you can mog again"):format(tostring(egg:GetAttribute("DisplayName") or egg.Name)))
            end
        end
    end
    return n
end
local waiting_rank -- further down: how good the best pet of yours lying on the ground is (-1 = none)
-- [[ eggs outside your stages (another stage, or outside the map) are taken too when they're higher than, or at ]] --
-- [[ least 80% of, the best egg you're getting (from your stages right now, or the last one stolen)              ]] --
local DETOUR_RATIO = 0.8
local function free_eggs()
    local list, others, now = {}, {}, os.clock()
    local ref = S.last_appeal
    for egg in pairs(all_eggs) do
        if egg.Parent and egg:IsDescendantOf(workspace) then
            local id, state = egg:GetAttribute("EggId"), egg:GetAttribute("EggState")
            local kind_ok = (S.pick ~= "Instant" or is_instant(egg) or is_event(egg)) and (not S.egg_ok or S.egg_ok(egg))
            if id and kind_ok and (state == nil or state == "Idle") and now >= (S.tried[id] or 0) then
                if stage_ok(egg) then
                    table.insert(list, egg)
                    if not is_event(egg) then ref = math.max(ref, appeal_of(egg)) end
                else
                    table.insert(others, egg)
                end
            end
        end
    end
    if ref > 0 then
        for _, egg in ipairs(others) do
            if appeal_of(egg) >= ref * DETOUR_RATIO then table.insert(list, egg) end
        end
    end
    return list
end
local function pick_egg()
    local root = root_part()
    local list = free_eggs()
    if not root or #list == 0 then return nil end
    local here = root.Position
    table.sort(list, function(a, b)
        local ea, eb = is_event(a), is_event(b)
        if ea ~= eb then return ea end
        if S.pick ~= "Nearest" then
            local ra, rb = egg_rank(a), egg_rank(b)
            if ra ~= rb then return ra > rb end
        end
        return (a:GetPivot().Position - here).Magnitude < (b:GetPivot().Position - here).Magnitude
    end)
    return list[1]
end

-- [[ stands you next to the egg, facing it, close enough for its MOG! prompt ]] --
local function go_to_egg(egg, prompt)
    local cf, size = egg:GetBoundingBox()
    local reach = math.max(math.min(math.max(size.X, size.Z) / 2 + 2, prompt.MaxActivationDistance - 2), 2)
    local y = cf.Position.Y - size.Y / 2 + 3
    local center = Vector3.new(cf.Position.X, y, cf.Position.Z)
    local spot = center + Vector3.new(0, 0, reach)
    for i = 0, 7 do
        local a = math.pi / 2 + i * math.pi / 4
        local c = center + Vector3.new(math.cos(a) * reach, 0, math.sin(a) * reach)
        if free_spot(c, egg) then
            spot = c
            break
        end
    end
    return travel(spot, cf.Position)
end

-- [[ one steal: goes to the egg and lets the game's own code mog it (instant, or a fight you always win) ]] --
local function steal_core(egg, forced)
    local prompt = egg:FindFirstChild("EggPrompt", true) or egg:FindFirstChildWhichIsA("ProximityPrompt", true)
    local id = egg:GetAttribute("EggId")
    local info = S.egg_info(egg)
    if id then S.tried[id] = os.clock() + 30 end
    if not (prompt and id) or busy() or carrying() then return false end
    local egg_pos = egg:GetPivot().Position
    local skipped = S.skip_fight and not is_instant(egg)
    S.last_spot = egg_pos
    S.status = ("%s %s (%s appeal)"):format(is_instant(egg) and "Instant mog:" or "Mogging", egg:GetAttribute("DisplayName") or egg.Name, short(appeal_of(egg)))
    if not go_to_egg(egg, prompt) then return false end
    -- [[ the server needs a moment to see you next to the egg after a jump, or it says you're too far ]] --
    task.wait(0.35)
    -- [[ highest first: right before mogging, if a higher egg showed up (or a good pet is lying on the ground), ]] --
    -- [[ this one is left for later and the farm goes for that instead. Never for an event egg (it's contested,  ]] --
    -- [[ and gone if you leave it) or the server hop's egg.                                                     ]] --
    if S.pick ~= "Nearest" and not forced and not is_event(egg) then
        local top = pick_egg()
        local pet_waiting = waiting_rank and waiting_rank() or -1
        if top and egg_rank(top) > egg_rank(egg) then
            S.tried[id] = 0
            logf("PRIORITY", ("left %s (%s appeal) for a higher egg: %s (%s appeal)"):format(egg.Name, short(appeal_of(egg)),
                top.Name, is_event(top) and "event" or short(appeal_of(top))))
            return false
        elseif pet_waiting > 0 then
            S.tried[id] = 0
            logf("PRIORITY", ("left %s for now: a good pet is waiting on the ground"):format(egg.Name))
            return false
        end
    end
    if not stage_ok(egg) then
        logf("DETOUR", ("%s (%s appeal) in %s is outside your stages but worth it, mogging it"):format(egg.Name,
            short(appeal_of(egg)), stage_of(egg) or "no stage (outside the map)"))
    end
    -- [[ Fast mog: asks the server directly (the same Eggs.Challenge the game uses) instead of playing the game's ]] --
    -- [[ walk-up and win animations, so you stand at the egg only as long as the server needs: no time at all for ]] --
    -- [[ an instant mog, 3.15s for a fight (the server's minimum is 3s). Falls back to the game's own mog if the  ]] --
    -- [[ server keeps saying no.                                                                                   ]] --
    local challenge_remote = Eggs:FindFirstChild("Challenge")
    if S.fast_mog and S.skip_fight and challenge_remote and challenge_remote:IsA("RemoteFunction") then
        local gap = 1.05 - (os.clock() - S.last_challenge) -- the server allows one challenge a second
        if gap > 0 then task.wait(gap) end
        S.last_challenge = os.clock()
        local ok, res = pcall(function() return challenge_remote:InvokeServer(id) end)
        local reason = ok and type(res) == "table" and tostring(res.Reason or ""):lower() or ""
        S.last_challenge_reason = reason
        if ok and type(res) == "table" and not res.Success and (reason:find("far") or reason:find("dist") or reason:find("range")
            or reason:find("close") or reason:find("near") or reason:find("rate")) then
            task.wait(0.5)
            S.last_challenge = os.clock()
            ok, res = pcall(function() return challenge_remote:InvokeServer(id) end)
            -- [[ the retry's answer is the one that counts (Mog from the treadmill reads it) ]] --
            reason = ok and type(res) == "table" and tostring(res.Reason or ""):lower() or ""
            S.last_challenge_reason = reason
        end
        if ok and type(res) == "table" and res.Success then
            S.fast_fail, S.busy_first, S.parallel_reject, S.last_challenge_reason = 0, nil, 0, ""
            -- [[ an instant mog gets finished like any other: the game sends its result (won) right after it, and ]] --
            -- [[ until that arrives the server keeps the egg "Challenged" and you "AlreadyBusy"                   ]] --
            if res.Instant then pcall(function() S.resolve:FireServer(id, true) end) end
            if not res.Instant and S.parallel_mog and not is_event(egg) then
                -- [[ Move on during fights: the 3s the server wants runs in the background and the win is sent from ]] --
                -- [[ wherever you are; the farm goes straight to the next egg. If the server doesn't accept that   ]] --
                -- [[ (2 eggs lost this way in a row), it switches itself off and waits at the egg again.            ]] --
                S.fights += 1
                local name, rank, appeal = tostring(egg:GetAttribute("DisplayName") or egg.Name), egg_rank(egg), appeal_of(egg)
                go(function()
                    task.wait(S.skip_wait)
                    pcall(function() S.resolve:FireServer(id, true) end)
                    local t = os.clock()
                    while egg.Parent and egg:GetAttribute("EggState") ~= "Hatching" and os.clock() - t < 2 do task.wait(0.05) end
                    S.fights = math.max(0, S.fights - 1)
                    if egg.Parent and egg:GetAttribute("EggState") == "Hatching" and egg:GetAttribute("EggHolder") == me.UserId then
                        S.parallel_fail = 0
                        table.insert(S.hatching, { pos = egg_pos, t = os.clock(), appeal = rank, egg = name, ap = appeal, info = info })
                        if S.note_grab then S.note_grab(info) end
                        S.last_appeal = appeal
                        logf("STEAL", ("won %s (%s appeal), already on the way to the next egg"):format(name, short(appeal)))
                    else
                        S.parallel_fail += 1
                        logf("STEAL", ("lost %s after moving on during its fight (state %s)"):format(name,
                            tostring(egg.Parent and egg:GetAttribute("EggState") or "gone")))
                        if S.parallel_fail >= 2 then
                            S.parallel_mog, S.parallel_fail = false, 0
                            S.auto_off.parallel_mog = "the server wants you at the egg for the whole fight"
                            logf("STEAL", "the server wants you at the egg for the whole fight: Move on during fights is off now")
                            notify("The server wants you at the egg during fights, so Move on during fights is off.")
                        end
                    end
                end)
                return true
            end
            if not res.Instant then
                S.status = ("Fight on %s skipped, the server wants 3s"):format(egg.Name)
                task.wait(S.skip_wait)
                pcall(function() S.resolve:FireServer(id, true) end)
            end
        elseif S.fights > 0 then
            -- [[ refused while another fight is still running: the server allows one fight at a time ]] --
            S.tried[id] = os.clock() + 2
            S.parallel_reject += 1
            logf("STEAL", ("the server wouldn't start %s while another fight runs: %s"):format(egg.Name,
                ok and (type(res) == "table" and tostring(res.Reason) or tostring(res)) or ("error " .. tostring(res))))
            if S.parallel_reject >= 2 then
                S.parallel_mog, S.parallel_reject = false, 0
                S.auto_off.parallel_mog = "the server allows only one fight at a time"
                logf("STEAL", "one fight at a time on this server: Move on during fights is off now")
            end
            return false
        else
            local why = ok and (type(res) == "table" and tostring(res.Reason) or tostring(res)) or ("error " .. tostring(res))
            if why:lower():find("busy") then
                -- [[ the server still has you in a fight (one left open): not fast mog's fault, finish that fight. ]] --
                -- [[ A gap of 15s+ since the last AlreadyBusy starts the count over (it must be a minute straight)  ]] --
                if not S.busy_first or os.clock() - (S.busy_last or 0) > 15 then S.busy_first = os.clock() end
                S.busy_last = os.clock()
                S.tried[id] = os.clock() + 2
                if S.resolve_stuck() == 0 and os.clock() - (S.busy_logged or 0) > 20 then
                    S.busy_logged = os.clock()
                    logf("STEAL", "the server says you're AlreadyBusy (a fight was left open), looking for it to finish it")
                end
                return false
            end
            S.fast_fail += 1
            logf("STEAL", ("the server said no to %s: %s"):format(egg.Name, why))
            if S.fast_fail >= 4 then
                S.fast_mog, S.fast_fail = false, 0
                S.auto_off.fast_mog = "the server refused it 4 times in a row"
                logf("STEAL", "fast mog turned off after 4 refusals in a row, using the game's own mog")
                notify("Fast mog was refused 4 times in a row, so it's off. The farm uses the game's own mog now.")
            end
            -- [[ a refusal: the egg was never challenged, so there's nothing to wait for (and it mustn't count ]] --
            -- [[ against Skip fights below)                                                                    ]] --
            return false
        end
    else
        -- [[ the game's own mog. Its fight only clicks by itself with Auto Mog on, which the farm keeps off, so ]] --
        -- [[ Auto Mog is on for this fight (S.own_fight); a fight still open after 75s is ended                  ]] --
        S.own_fight = true
        pcall(function() me:SetAttribute("AutoMog", true) end)
        task.spawn(EggController.Challenge, prompt)
        local started = os.clock()
        repeat task.wait(0.05) until EggController.IsBusy() or os.clock() - started > 2
        while S.alive and (EggController.IsBusy() or MogController.IsFighting()) and os.clock() - started < 75 do task.wait(0.1) end
        if MogController.IsFighting() and type(MogController.Abort) == "function" then
            pcall(MogController.Abort)
            logf("STEAL", ("the game's fight on %s ran over 75s, ended it"):format(egg.Name))
        end
        S.own_fight = false
    end
    -- [[ it's yours once it starts hatching; up to 12 hatch at the same time ]] --
    local wait_hatch, nudged = os.clock(), false
    while egg.Parent and egg:GetAttribute("EggState") ~= "Hatching" and os.clock() - wait_hatch < 2 do
        task.wait(0.05)
        -- [[ still "Challenged" by you a second later and no fight running: the result didn't land, send it again ]] --
        if not nudged and os.clock() - wait_hatch > 1 and egg:GetAttribute("EggState") == "Challenged" and egg:GetAttribute("EggHolder") == me.UserId
            and not (EggController.IsBusy() or MogController.IsFighting()) then
            nudged = true
            pcall(function() S.resolve:FireServer(id, true) end)
        end
    end
    if egg:GetAttribute("EggState") == "Hatching" and egg:GetAttribute("EggHolder") == me.UserId then
        table.insert(S.hatching, { pos = egg_pos, t = os.clock(), appeal = egg_rank(egg),
            egg = tostring(egg:GetAttribute("DisplayName") or egg.Name), ap = appeal_of(egg), info = info })
        if not is_event(egg) then S.last_appeal = appeal_of(egg) end
        if S.note_grab then S.note_grab(info) end
        if skipped then S.skip_fail = 0 end
        S.busy_first = nil
        logf("STEAL", ("won %s (%s appeal)%s"):format(tostring(egg:GetAttribute("DisplayName") or egg.Name), short(appeal_of(egg)), is_event(egg) and ", EVENT egg" or ""))
        -- [[ an event egg's pet can be taken by anyone, so the farm stays with it until it hatches ]] --
        if is_event(egg) then
            S.event_hatch = { pos = egg_pos, until_t = os.clock() + 60, name = egg:GetAttribute("DisplayName") or egg.Name }
            if S.event_won then pcall(S.event_won, egg) end
        end
        return true
    end
    logf("STEAL", ("didn't get %s (state %s, holder %s)"):format(egg.Name, tostring(egg.Parent and egg:GetAttribute("EggState") or "gone"),
        tostring(egg.Parent and egg:GetAttribute("EggHolder") or "-")))
    -- [[ if the server turns down skipped fights twice in a row, it goes back to real (always won) fights. Only    ]] --
    -- [[ counts when the egg is still free (nobody else took it) and isn't an event egg (those fight differently) ]] --
    local still_free = egg.Parent and (egg:GetAttribute("EggState") == nil or egg:GetAttribute("EggState") == "Idle")
        and (tonumber(egg:GetAttribute("EggHolder")) or 0) == 0
    if skipped and still_free and not is_event(egg) then
        S.skip_fail += 1
        if S.skip_fail >= 2 then
            S.skip_fight, S.skip_fail = false, 0
            S.auto_off.skip_fight = "the server didn't accept skipped fights"
            notify("The server didn't accept skipped fights, so Skip fights is off. Fights are still always won.")
        end
    end
    return false
end
-- [[ Mog from the treadmill: while the treadmill holds you it anchors your character, and moves made while     ]] --
-- [[ anchored aren't sent to the server, so to the server you're still training (speed keeps coming) while you ]] --
-- [[ mog an egg somewhere else; then you're put straight back on the treadmill. It turns itself off if the     ]] --
-- [[ treadmill stops paying while you're away, or the server says you're too far from the egg.                 ]] --
local function steal(egg, forced)
    local root = root_part()
    -- [[ only with Fast mog and Skip fights: the game's own mog (walk-up, fight screen) can't run from afar ]] --
    local desync = S.mill_mog and S.fast_mog and S.skip_fight and root and root.Anchored and S.on_treadmill and S.on_treadmill()
    if not desync then return steal_core(egg, forced) end
    local home, t0 = root.CFrame, os.clock()
    local paying = t0 - (S.last_step_t or -100) < 1 -- steps were coming in right before
    S.keep_mill, S.last_challenge_reason = true, nil
    local ok, res = pcall(steal_core, egg, forced)
    S.keep_mill = false
    root = root_part()
    if root then
        root.CFrame = home
        root.AssemblyLinearVelocity = Vector3.zero
    end
    local reason, why = tostring(S.last_challenge_reason or ""), nil
    if reason:find("far") or reason:find("dist") or reason:find("range") then
        why = "the server checks how close you are to the egg"
    elseif paying and os.clock() - t0 > 1.5 and os.clock() - (S.last_step_t or 0) > 2 then
        why = "the treadmill stopped paying while you were away"
    end
    if why then
        S.mill_mog = false
        S.auto_off.mill_mog = why
        logf("TREADMILL", "Mog from the treadmill turned itself off: " .. why)
        notify("Mog from the treadmill doesn't work here (" .. why .. "), so it's off for now.")
    elseif not S.mill_mog_logged then
        S.mill_mog_logged = true
        logf("TREADMILL", "mogged an egg without leaving the treadmill; speed kept coming in")
    end
    if not ok then error(res, 0) end
    return res
end

---------------------------------------------------------------- pets: hatching, taking, bringing home

-- [[ where your pets come out: the server tells you when your egg hatches ]] --
local function connect(path, fn)
    local remote = Remotes
    for _, name in ipairs(path) do remote = remote and remote:FindFirstChild(name) end
    if remote and remote:IsA("RemoteEvent") then track(remote.OnClientEvent:Connect(function(...) pcall(fn, ...) end)) end
end
local function its_me(name) return name == me.DisplayName or name == me.Name end
-- [[ the hatch book: every pet that comes out of your eggs (farm or by hand), with everything the game says ]] --
-- [[ about it, and what happened to it afterwards (banked, gifted, lost, taken by someone).                 ]] --
local function hatch_record(pet, how)
    local r = { time = os.date("%H:%M:%S"), how = how, outcome = "hatched, not taken yet", pet = pet }
    table.insert(S.hatched, r)
    if pet.Id then S.hatched_by_id[pet.Id] = r end
    S.hatch_dirty = true
    return r
end
local function hatch_note(id, field, value)
    local r = id and S.hatched_by_id[id]
    if not r then return end
    r[field] = value
    S.hatch_dirty = true
end
-- [[ matches a hatch to one of the eggs you stole (the nearest one, so two of your eggs hatching out of order ]] --
-- [[ don't swap their sizes in the egg book); other people's hatches are ignored                              ]] --
local function claim_hatch(pos, radius)
    local best_i, best_d = nil, radius
    for i, h in ipairs(S.hatching) do
        local d = (h.pos - pos).Magnitude
        if d < best_d then best_i, best_d = i, d end
    end
    return best_i and table.remove(S.hatching, best_i) or nil
end
-- [[ Egg book: every egg the farm wins and the pet that came out of it, one line each in MogHub_EggBook.csv (kept ]] --
-- [[ across sessions): the egg's name, rarity, stage, size (EggScale), appeal and luck, then the pet's name,      ]] --
-- [[ rarity, mutation, size, size tier, weight and luck. With enough lines it shows whether big eggs really give  ]] --
-- [[ better or bigger pets.                                                                                       ]] --
local function egg_book(info, pet, ap)
    local append, write, isf, read = exec("appendfile"), exec("writefile"), exec("isfile"), exec("readfile")
    if typeof(write) ~= "function" then return end
    local function cell(v)
        local s = tostring(v == nil and "" or v)
        return s:find("[,\"]") and ('"' .. s:gsub('"', '""') .. '"') or s
    end
    local row = table.concat({ os.date("%Y-%m-%d %H:%M:%S"), cell(info.name), cell(info.rarity), cell(info.stage),
        info.scale and ("%.3f"):format(info.scale) or "", ap and ("%.4g"):format(ap) or "", info.luck and ("%.2f"):format(info.luck) or "",
        cell(pet.Name), cell(pet.Rarity), cell(pet.Mutation), pet.Size and ("%.3f"):format(tonumber(pet.Size) or 0) or "",
        cell(pet.Tier or pet.SizeTier or "normal"), cell(pet.Weight), cell(pet.Luck), cell(pet.Id) }, ",") .. "\n"
    local file = "MogHub_EggBook.csv"
    local has = typeof(isf) == "function" and isf(file)
    if not has then
        pcall(write, file, "time,egg,egg_rarity,stage,egg_size,egg_appeal,egg_luck,pet,pet_rarity,mutation,pet_size,size_tier,weight,pet_luck,pet_id\n" .. row)
    elseif typeof(append) ~= "function" or not pcall(append, file, row) then
        pcall(function() write(file, read(file) .. row) end)
    end
end
connect({ "Eggs", "Hatch" }, function(data)
    if type(data) ~= "table" or data.Phase ~= "Hatched" or typeof(data.Position) ~= "Vector3" then return end
    local pet = type(data.Pet) == "table" and data.Pet or {}
    local by_farm = claim_hatch(data.Position, 80)
    local rec = hatch_record(pet, by_farm and "farm" or "by hand")
    if by_farm and by_farm.info then
        rec.egg, rec.egg_ap = by_farm.info, by_farm.ap
        pcall(egg_book, by_farm.info, pet, by_farm.ap)
    end
    -- [[ your event egg (not a Titanic, those have their own message) hatched: the farm stops waiting at it ]] --
    if by_farm and S.event_hatch and (S.event_hatch.pos - data.Position).Magnitude < 80 then S.event_hatch = nil end
    if by_farm then
        if pet.Id then S.my_pets[pet.Id] = true end
        table.insert(S.pending, { id = pet.Id, pos = data.Position, name = tostring(pet.Name), until_t = os.clock() + 50, misses = 0,
            appeal = by_farm.appeal or 0 })
        -- [[ which egg gave which pet (and its size), for working out which eggs are worth it ]] --
        logf("HATCHED", ("%s %s%s from %s (%s appeal)"):format(tostring(pet.Rarity or "?"), pet.Mutation and (tostring(pet.Mutation) .. " ") or "",
            tostring(pet.Name), tostring(by_farm.egg or "an egg"), by_farm.ap and short(by_farm.ap) or "?")
            .. ((pet.Tier or pet.SizeTier) and (" | " .. tostring(pet.Tier or pet.SizeTier)) or ""))
    end
end)
connect({ "Titanic", "Event" }, function(data)
    if type(data) ~= "table" then return end
    -- [[ zone: the stage ("Stage10") when the game sends it, else the zone's display name ]] --
    if data.Phase == "Spawned" and typeof(data.Position) == "Vector3" then
        S.titanic = { pos = data.Position, until_t = os.clock() + 290, zone = tostring(data.Stage or data.Zone or "") }
        logf("EVENT", "Titanic egg spawned in " .. S.titanic.zone)
        if S.farm then notify("Titanic egg spawned in " .. S.titanic.zone .. ", going for it.") end
    elseif data.Phase == "Hatching" and not its_me(data.Player) then
        if S.titanic then logf("EVENT", tostring(data.Player) .. " got the Titanic egg first") end
        S.titanic = nil
    elseif data.Phase == "Hatched" and its_me(data.Player) and typeof(data.Position) == "Vector3" then
        claim_hatch(data.Position, 200)
        S.event_hatch = nil
        S.titanic_record = hatch_record({ Name = data.Name, Rarity = data.Rarity, Zone = data.Zone, Titanic = true }, "Titanic egg")
        table.insert(S.pending, 1, { pos = data.Position, titanic = true, name = "Titanic " .. tostring(data.Name), pet_name = tostring(data.Name),
            until_t = os.clock() + 280, misses = 0 })
    elseif data.Phase == "Claimed" or data.Phase == "Expired" or data.Phase == "Despawned" or data.Phase == "Ended" then
        S.titanic = nil
    end
end)
-- [[ a Titanic egg that was already up when the helper started (after a hop, a reconnect or running it again): ]] --
-- [[ the server also writes it on the map (TitanicActive / TitanicPosition / TitanicZone), so the farm knows   ]] --
do
    local function read_titanic()
        if workspace:GetAttribute("TitanicActive") ~= true then
            -- [[ it's over (expired, or someone hatched it): stop going for it ]] --
            if S.titanic then logf("EVENT", "the Titanic egg is gone") end
            S.titanic = nil
            return
        end
        if S.titanic then return end
        local pos = workspace:GetAttribute("TitanicPosition")
        if typeof(pos) ~= "Vector3" then return end
        S.titanic = { pos = pos, until_t = os.clock() + 300, zone = tostring(workspace:GetAttribute("TitanicZone") or "") }
        logf("EVENT", "Titanic egg already up in " .. S.titanic.zone)
        if S.farm then notify("Titanic egg is up in " .. S.titanic.zone .. ", going for it.") end
    end
    pcall(read_titanic)
    track(workspace:GetAttributeChangedSignal("TitanicActive"):Connect(function() pcall(read_titanic) end))
end
connect({ "Loot", "Delivered" }, function(data)
    local pet = type(data) == "table" and type(data.Pet) == "table" and data.Pet or {}
    S.delivered += 1
    S.last_bank_t = os.clock()
    S.need_equip = true
    S.last = ("%s (%s)"):format(tostring(pet.Name), tostring(pet.Rarity))
    logf("BANKED", S.last .. (" | total %d"):format(S.delivered))
    if pet.Id and S.hatched_by_id[pet.Id] then
        hatch_note(pet.Id, "outcome", "banked (in your inventory)")
    elseif S.titanic_record and S.titanic_record.pet.Name == pet.Name then
        S.titanic_record.outcome = "banked (in your inventory)"
        S.titanic_record.pet = pet
        S.hatch_dirty = true
    else
        -- [[ any other pet that reaches your inventory gets recorded too ]] --
        hatch_record(pet, "got it").outcome = "banked (in your inventory)"
    end
    local matched = false
    for i = #S.pending, 1, -1 do
        if pet.Id and S.pending[i].id == pet.Id then
            table.remove(S.pending, i)
            matched = true
        end
    end
    if not matched then
        for i, p in ipairs(S.pending) do
            if p.titanic and (not p.pet_name or p.pet_name == tostring(pet.Name)) then table.remove(S.pending, i) break end
        end
    end
end)

local function loot_folder() return game_folder("Loot") end
-- [[ is this the pet from your Titanic egg? Near where it hatched, and (when the game said which animal it ]] --
-- [[ was) that animal, so other pets lying around there aren't treated as it                             ]] --
local function near_titanic_spot(pos, m)
    for _, p in ipairs(S.pending) do
        if p.titanic and pos and (pos - p.pos).Magnitude < 150 then
            if not (m and p.pet_name) then return true end
            local name = tostring(m:GetAttribute("AnimalName") or m.Name)
            if name == p.pet_name or m.Name == p.pet_name then return true end
        end
    end
    return false
end
-- [[ how good a pet on the ground is: event pets above all, then what it could earn on your plot (loot_value) ]] --
local function pet_rank(m, pos)
    if near_titanic_spot(pos, m) then return math.huge end
    return (S.loot_value and S.loot_value(m)) or 0
end
-- [[ pets on the ground worth taking, best first (then nearest): yours (a pet you hatched stays yours even after ]] --
-- [[ a thief carried it), and with Take others' good pets, good ones anyone dropped (the game lets anyone take    ]] --
-- [[ them). With Leave worthless pets, one that couldn't beat your weakest plot pet even as an Ancient Diamond    ]] --
-- [[ stays on the ground: that's exactly what auto sell would delete, and carrying it home took half the farm's  ]] --
-- [[ time.                                                                                                        ]] --
local function my_loot()
    local folder = loot_folder()
    local server_now = workspace:GetServerTimeNow()
    local floor = (S.skip_junk and not S.gift and S.keep_floor) and S.keep_floor() or 0
    local best, best_d, best_rank = nil, math.huge, -1
    for _, m in ipairs(folder and folder:GetChildren() or {}) do
        if m:IsA("Model") and m:GetAttribute("LootState") == "Ground" then
            local id = m:GetAttribute("LootId")
            local pos = where(m)
            local expires = tonumber(m:GetAttribute("ExpiresAt"))
            local event_pet = near_titanic_spot(pos, m)
            local own = m:GetAttribute("OwnerUserId") == me.UserId or event_pet or (id and S.my_pets[id])
            local rank = pet_rank(m, pos)
            local worth = event_pet or floor <= 0 or rank > floor
            if own and id and not event_pet then S.my_pets[id] = true end
            if own and id and not worth and not S.skipped[id] then
                S.skipped[id] = true
                S.skipped_count += 1
                hatch_note(id, "outcome", "left on the ground (couldn't beat your plot)")
                for i = #S.pending, 1, -1 do
                    if S.pending[i].id == id then table.remove(S.pending, i) end
                end
                if S.skipped_count <= 5 or S.skipped_count % 50 == 0 then
                    logf("SKIP", ("left %s on the ground (%d so far): at best $%s/s as an Ancient Diamond, your weakest plot pet makes $%s/s"):format(
                        m.Name, S.skipped_count, short(rank), short(floor)))
                end
            end
            local wanted = id and not S.gifted[id] and ((own and worth) or (S.take_others and not own and floor > 0 and rank > floor))
            if wanted and not own then S.wanted[id] = true end -- if someone grabs it first, Bat thieves goes after it
            if wanted and (not expires or expires > server_now + 0.5) and os.clock() >= (S.loot_fail[id] or 0) then
                local d = dist_to(pos)
                -- [[ one just knocked out of a thief's hands goes first, before they grab it again ]] --
                if os.clock() - (S.won_back[id] or -100) < 30 then rank = math.huge end
                if rank > best_rank or (rank == best_rank and d < best_d) then best, best_d, best_rank = m, d, rank end
            end
        end
    end
    return best, best_rank
end
waiting_rank = function()
    local loot, rank = my_loot()
    local id = loot and loot:GetAttribute("LootId")
    if id and os.clock() - (S.guarded[id] or -100) < 6 then return -1 end -- a guard is on it: mog meanwhile
    return loot and rank or -1
end
local function prune_pending()
    for i = #S.pending, 1, -1 do
        if os.clock() > S.pending[i].until_t or S.pending[i].misses > 12 then
            local r = S.pending[i].id and S.hatched_by_id[S.pending[i].id]
            if r and r.outcome == "hatched, not taken yet" then hatch_note(S.pending[i].id, "outcome", "lost: not taken in time (or someone else took it)") end
            table.remove(S.pending, i)
        end
    end
    local now = os.clock()
    for i = #S.hatching, 1, -1 do
        if now - S.hatching[i].t > 45 then table.remove(S.hatching, i) end
    end
end

-- [[ The game hides every prompt (ProximityPromptService off) while you fight, mog an egg or lie knocked down     ]] --
-- [[ (its PromptGate), and a hidden prompt can't be taken: that's how pets got skipped while a fight ran in the   ]] --
-- [[ background. There's no "take" remote (the server only listens to the prompt), so taking a pet switches the  ]] --
-- [[ prompts on for the moment it takes, then puts them back the way the game wants them.                        ]] --
local PromptService = game:GetService("ProximityPromptService")
local PromptGate = nil
pcall(function()
    local ok, m = pcall(require, RS:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("PromptGate", 5))
    if ok and type(m) == "table" and type(m.Set) == "function" then PromptGate = m end
end)
S.prompt_gate = PromptGate
local function fire(prompt, try)
    local was_on = PromptService.Enabled
    if not was_on then PromptService.Enabled = true end
    if not prompt.Enabled then pcall(function() prompt.Enabled = true end) end
    if not (try == 1 and typeof(fireproximityprompt) == "function" and pcall(fireproximityprompt, prompt)) then
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(prompt.HoldDuration + 0.05)
        pcall(function() prompt:InputHoldEnd() end)
    end
    if not was_on and PromptGate and type(PromptGate.IsBlocked) == "function" and PromptGate.IsBlocked() then
        PromptService.Enabled = false
    end
end
-- [[ the loot's prompt; a pet that just dropped (or one far away that hasn't streamed in) can be missing it for a ]] --
-- [[ moment, so it's waited for instead of skipping the pet                                                      ]] --
local function loot_prompt(loot, wait_for)
    local t = os.clock()
    repeat
        local p = loot:FindFirstChild("LootPrompt", true) or loot:FindFirstChildWhichIsA("ProximityPrompt", true)
        if p then return p end
        if not wait_for then return nil end
        task.wait(0.1)
    until not loot.Parent or os.clock() - t > wait_for
    return nil
end

-- [[ walks up to your pet and takes it (the game's own Take prompt) ]] --
-- [[ the stage guard (boss) standing next to a spot, if any. Its reach grows with its size. ]] --
local function guard_near(pos)
    local stages = game_folder("Stages")
    for _, st in ipairs(stages and stages:GetChildren() or {}) do
        for _, m in ipairs(st:GetChildren()) do
            if m:IsA("Model") and m:GetAttribute("PatrolFrom") ~= nil then
                local ok, gp, size = pcall(function() return m:GetPivot().Position, m:GetExtentsSize() end)
                if ok then
                    local reach = 14 + math.min(math.max(size.X, size.Z) / 2, 30)
                    if Vector3.new(gp.X - pos.X, 0, gp.Z - pos.Z).Magnitude < reach then return m end
                end
            end
        end
    end
    return nil
end
local function take(loot)
    local prompt = loot_prompt(loot)
    local id = loot:GetAttribute("LootId")
    local anchor = prompt and where(prompt.Parent) or where(loot)
    if not (id and anchor) then return false end
    if not prompt then
        -- [[ no prompt yet: go to the pet first (that streams it in), then give the prompt a second to show up ]] --
        travel(ground(anchor + Vector3.new(0, 0, 3)), anchor)
        prompt = loot_prompt(loot, 1.5)
        if not prompt then
            S.loot_fail[id] = os.clock() + 2
            logf("TAKE", ("%s has no Take prompt yet, trying again in 2s"):format(loot.Name))
            return false
        end
        anchor = where(prompt.Parent) or anchor
    end
    wait_body("before taking a pet")
    -- [[ the guard kicks whoever picks a pet up right next to it (it starts chasing 1.5s after a take). If it's ]] --
    -- [[ standing on the pet, wait for it to walk off (it goes back to its patrol after laughing), unless the   ]] --
    -- [[ pet is about to disappear.                                                                            ]] --
    local guard = guard_near(anchor)
    local expires = tonumber(loot:GetAttribute("ExpiresAt"))
    local left = expires and (expires - workspace:GetServerTimeNow()) or 45
    if guard and left > 5 then
        S.loot_fail[id] = os.clock() + 0.8
        S.guarded[id] = os.clock()
        local gname = tostring(guard:GetAttribute("DisplayName") or guard.Name)
        S.status = ("%s is standing at %s, waiting for it to walk off"):format(gname, loot.Name)
        if not S.guard_logged[id] then
            S.guard_logged[id] = true
            logf("GUARD", ("%s is right at %s, waiting for it to leave before taking it (%.0fs left)"):format(gname, loot.Name, left))
        end
        task.wait(0.25)
        return false
    end
    S.status = "Taking " .. loot.Name
    S.carry_is_event, S.carry_name, S.carry_id, S.carry_hand = near_titanic_spot(anchor, loot), loot.Name, id, false
    S.carry_rank = pet_rank(loot, anchor)
    local from_other = loot:GetAttribute("OwnerUserId") ~= me.UserId and not S.my_pets[id] and not S.carry_is_event
    -- [[ a pet just won back from a thief keeps its top rank in your hands too, so nothing makes you drop it ]] --
    if os.clock() - (S.won_back[id] or -100) < 30 then S.carry_rank = math.huge end
    S.carry_income = tonumber(loot:GetAttribute("IncomePerSecond")) or -1
    if S.carry_income >= 0 then hatch_note(id, "income", S.carry_income) end
    hatch_note(id, "mutation", loot:GetAttribute("Mutation"))
    travel(ground(anchor + Vector3.new(0, 0, 3)), anchor)
    task.wait(0.15)
    for try = 1, 3 do
        if carrying() or not loot.Parent then break end
        local spot = where(prompt.Parent)
        if spot and dist_to(spot) > 9 then travel(ground(spot + Vector3.new(0, 0, 3)), spot) end
        fire(prompt, try)
        local t = os.clock()
        repeat task.wait(0.05) until carrying() or os.clock() - t > 1
    end
    if not carrying() then
        -- [[ someone else grabbed it first: no long wait, so batting them and taking it back can go on right away ]] --
        local st = loot.Parent and loot:GetAttribute("LootState")
        S.loot_fail[id] = os.clock() + ((st ~= nil and st ~= "Ground") and 0.5 or 8)
        logf("TAKE", ("couldn't take %s (state %s)"):format(loot.Name, tostring(st or "gone")))
    elseif from_other then
        S.my_pets[id] = true -- yours now: Bat thieves defends it like your own
        S.free_count += 1
        logf("FREE", ("took a %s someone else left on the ground (could make $%s/s on your plot)"):format(loot.Name, short(S.carry_rank)))
    end
    return carrying()
end

-- [[ the safe zone: your plot's spawn if it's inside it, otherwise the middle of the zone ]] --
local function home_spots()
    local spots = {}
    local plot = game_folder("Plots") and game_folder("Plots"):FindFirstChild(tostring(me:GetAttribute("Plot")))
    local spawn = plot and plot:FindFirstChild("SpawnPoint")
    local zone = SafeZoneUtil and SafeZoneUtil.Get() or game_folder("SafeZone")
    local center = zone and where(zone)
    if center then S.safe_center = center end
    if spawn and spawn:IsA("BasePart") and (not SafeZoneUtil or not zone or SafeZoneUtil.ContainsPosition(spawn.Position)) then
        table.insert(spots, spawn.Position + Vector3.new(0, 3.5, 0))
    end
    table.insert(spots, S.safe_center or SAFE_FALLBACK)
    return spots
end
local function deliver()
    local started = os.clock()
    for attempt = 1, 3 do
        if not carrying() or not S.alive then break end
        local spots = home_spots()
        local spot = spots[math.min(attempt, #spots)]
        wait_body("before going home")
        if not carrying() then break end
        S.status = "Bringing the pet into the safe zone"
        travel(spot)
        if carrying() then travel(ground(spot)) end
        local t, hit_before = os.clock(), S.hit_t
        repeat task.wait(0.05) until not carrying() or os.clock() - t > 3 or S.hit_t ~= hit_before
        if carrying() and S.hit_t ~= hit_before then
            logf("HIT", "hit while bringing the pet home: waiting until the game lets go of you, then trying again")
        end
    end
    -- [[ knocked loose before reaching home: say so, and the next farm step goes straight back to take it again ]] --
    if not carrying() and S.last_knock_t >= started and S.last_bank_t < started then
        S.status = "Got hit and dropped the pet, going back for it"
        logf("LOST", ("dropped %s on the way home (hit), going back for it"):format(tostring(S.carry_name or "the pet")))
        return false
    end
    if carrying() then
        S.status = "Couldn't bank the pet, trying again"
        logf("BANK", "still carrying after 3 tries at the safe zone")
    end
    return not carrying()
end

-- [[ Gift mode: instead of banking, the pet is carried to Stage 1 and dropped there (the game's own Drop) for ]] --
-- [[ other players to take. Dropped pets are marked as gifts, so the farm never takes them back and Bat       ]] --
-- [[ thieves leaves whoever picks them up alone. Event (Titanic) pets still go home.                          ]] --
local drop_remote = Remotes:FindFirstChild("Loot") and Remotes.Loot:FindFirstChild("Drop")
-- [[ Carry timeout: banking takes about a second, so a pet held for 6s without reaching home means something ]] --
-- [[ is wrong (usually the server still has you next to the guard). The pet is dropped to break the loop; the ]] --
-- [[ farm picks it up again once the guard has walked off.                                                    ]] --
track(me:GetAttributeChangedSignal("CarryingLoot"):Connect(function()
    S.carry_since = carrying() and os.clock() or 0
end))
go(function()
    while S.alive do
        task.wait(0.25)
        -- [[ no safe-zone exception: banking takes about a second, so still holding it after 6s means the server ]] --
        -- [[ never saw you get home (usually it still has you ragdolled next to the guard), even if your screen   ]] --
        -- [[ shows you at spawn                                                                                    ]] --
        if S.carry_drop and S.farm and drop_remote and carrying() and S.carry_since > 0 and os.clock() - S.carry_since > 6 then
            local id = me:GetAttribute("CarryingLoot")
            -- [[ the game refuses Drop while you're ragdolled, so it's sent every 0.3s until the pet really leaves ]] --
            -- [[ your hands (up to 12s), the same as spamming the Drop button                                    ]] --
            local t, tries = os.clock(), 0
            repeat
                tries += 1
                pcall(function() drop_remote:FireServer() end)
                task.wait(0.3)
            until not carrying() or os.clock() - t > 12 or not S.alive
            if carrying() then
                logf("CARRY", ("held %s for 6s without it banking and the game wouldn't let go of it for 12s (%d tries)"):format(
                    tostring(S.carry_name or "the pet"), tries))
            else
                logf("CARRY", ("held %s for 6s without it banking%s; it dropped after %.1fs (%d tries), the farm takes it again once you're free"):format(
                    tostring(S.carry_name or "the pet"), os.clock() - S.hit_t < 15 and " (you were hit)" or "", os.clock() - t, tries))
                if id then S.loot_fail[id] = os.clock() + 3 end
            end
            S.carry_since = os.clock()
        end
    end
end)
local function gift_pet()
    local id = me:GetAttribute("CarryingLoot")
    local center = stage_center("Stage1")
    if not (drop_remote and center and id) then return deliver() end
    S.status = "Taking " .. tostring(S.carry_name or "the pet") .. " to Stage 1 to give away"
    travel(ground(center + Vector3.new(0, 0, 10)), center)
    S.gifted[id] = true
    for _ = 1, 3 do
        if not carrying() then break end
        pcall(function() drop_remote:FireServer() end)
        local t = os.clock()
        repeat task.wait(0.05) until not carrying() or os.clock() - t > 1.5
    end
    if carrying() then
        S.gifted[id] = nil
        logf("GIFT", "the game didn't let go of the pet, banking it instead")
        return deliver()
    end
    S.gifted_count += 1
    hatch_note(id, "outcome", "gifted (dropped at Stage 1)")
    logf("GIFT", ("dropped %s at Stage 1 | gifts so far %d"):format(tostring(S.carry_name or "a pet"), S.gifted_count))
    for i = #S.pending, 1, -1 do
        if S.pending[i].id == id then table.remove(S.pending, i) end
    end
    return true
end
-- [[ with a gift limit set, only pets earning less than it are given away; better ones (and ones whose  ]] --
-- [[ income isn't known) go home. Limit 0 = give everything away.                                       ]] --
local function finish_carry()
    -- [[ a pet you picked up yourself (not the one the farm took): what the farm knows is about another pet, so ]] --
    -- [[ it's read from the pet itself, never swapped or gifted, just banked                                   ]] --
    local carried = me:GetAttribute("CarryingLoot")
    if carried ~= S.carry_id then
        S.carry_id, S.carry_hand, S.carry_is_event, S.carry_name, S.carry_income, S.carry_rank = carried, true, false, nil, -1, math.huge
        local folder = loot_folder()
        for _, m in ipairs(folder and folder:GetChildren() or {}) do
            if m:GetAttribute("LootId") == carried then
                S.carry_name = m.Name
                S.carry_income = tonumber(m:GetAttribute("IncomePerSecond")) or -1
                break
            end
        end
    end
    -- [[ a pet from a higher egg is on the ground: this one is dropped right here (it stays yours on the ground) ]] --
    -- [[ and the better one is taken and banked first; the farm comes back for this one after                    ]] --
    local better, rank = my_loot()
    -- [[ only for a pet worth at least 1.5x this one, and at most one swap every 10s, so two pets can never keep ]] --
    -- [[ swapping places                                                                                        ]] --
    if better and drop_remote and not S.carry_is_event and rank > S.carry_rank * 1.5 and os.clock() - (S.last_carry_swap or -100) > 10 then
        S.last_carry_swap = os.clock()
        local low = tostring(S.carry_name or "the pet")
        S.status = ("Dropping %s, a better pet (%s) hatched"):format(low, better.Name)
        pcall(function() drop_remote:FireServer() end)
        local t = os.clock()
        repeat task.wait(0.05) until not carrying() or os.clock() - t > 1.5
        if not carrying() then
            logf("PRIORITY", ("dropped %s to grab %s first (worth more), coming back for it after"):format(low, better.Name))
            if take(better) then return finish_carry() end
            return false
        end
    end
    if S.gift and not S.carry_is_event and not S.carry_hand then
        local income = S.carry_income
        if S.gift_min <= 0 or (income >= 0 and income < S.gift_min) then return gift_pet() end
        logf("KEEP", ("%s earns $%s/s, at or above your gift limit $%s/s: banking it"):format(tostring(S.carry_name),
            income >= 0 and short(income) or "?", short(S.gift_min)))
    end
    return deliver()
end
-- [[ reads amounts like "50B", "1.5T", "$200M/s", "750000" ]] --
local function parse_amount(text)
    local SCALE = { [""] = 1, K = 1e3, M = 1e6, B = 1e9, T = 1e12, QA = 1e15, QI = 1e18 }
    local clean = tostring(text):upper()
    clean = clean:gsub("%$", ""):gsub(",", ""):gsub("/S$", ""):gsub("%s", "")
    local num, suffix = clean:match("^([%d%.]+)(%a*)$")
    local n = tonumber(num)
    if not n or not SCALE[suffix] then return nil end
    return n * SCALE[suffix]
end

-- [[ picks up your hatched pets one by one and banks each; goes back for ones that are far away ]] --
local function collect_once()
    prune_pending()
    if carrying() then finish_carry() return true end
    local loot = my_loot()
    -- [[ while your event egg hatches, only pets right there are taken: its pet comes out any moment and anyone ]] --
    -- [[ can take it, so the farm doesn't fly off to bank a normal pet meanwhile                                 ]] --
    local e = S.event_hatch
    if loot and e then
        local lp = where(loot)
        if not (lp and ((lp - e.pos).Magnitude < 70 or near_titanic_spot(lp, loot))) then loot = nil end
    end
    if loot then
        local t = os.clock()
        while S.fights > 0 and os.clock() - t < 4 do
            S.status = "Finishing the fight before taking " .. loot.Name
            task.wait(0.05)
        end
        if take(loot) then finish_carry() end
        return true
    end
    for _, p in ipairs(S.pending) do
        -- [[ while an event egg is still hatching, don't leave it for a normal pet somewhere else ]] --
        if S.event_hatch and not p.titanic then continue end
        if dist_to(p.pos) > 200 then
            S.status = "Going back for " .. p.name
            travel(ground(p.pos + Vector3.new(0, 0, 6)), p.pos)
            task.wait(0.6)
            return true
        end
        p.misses += 1
    end
    return false
end

---------------------------------------------------------------- the farm

-- [[ goes through your picked stages one by one (highest first) looking for free eggs ]] --
local function scout()
    local list = picked_stages(true)
    -- [[ only the highest stage's eggs can make your plot (Leave worthless on): no trips to the lower stages ]] --
    local only = S.only_stage and S.only_stage()
    if only then list = { only } end
    if #list == 0 then return end
    S.scout_i = S.scout_i % #list + 1
    local name = list[S.scout_i]
    local center = stage_center(name)
    if not center then return end
    -- [[ mogging from the treadmill: load the stage around you instead of flying there (that would get you off) ]] --
    if S.mill_hold and S.mill_hold() then
        S.status = "Loading the eggs in " .. name .. " from the treadmill"
        stream_around(center, 3)
        task.wait(1)
        return
    end
    S.status = "Looking for free eggs in " .. name
    travel(ground(center), center + Vector3.new(0, 0, -10))
    task.wait(1)
end

local function go_titanic()
    local t = S.titanic
    if not t or os.clock() > t.until_t then S.titanic = nil return false end
    -- [[ a Titanic egg in a lower stage hatches a pet that can't make your plot (Leave worthless on): skip it ]] --
    local only = (S.farm_mode == "Treadmill" and S.top_stage and S.top_stage()) or (S.only_stage and S.only_stage())
    if only and tostring(t.zone):match("^Stage%d+$") and t.zone ~= only then
        logf("SKIP", ("Titanic egg in %s skipped: pets from there can't make your plot"):format(t.zone))
        S.titanic = nil
        return false
    end
    S.resolve_stuck() -- a Titanic fight left open blocks every mog until it's finished
    for egg in pairs(all_eggs) do
        if egg.Parent and egg:GetAttribute("GiantEgg") == true and egg:GetAttribute("EggState") == "Idle" and (egg:GetPivot().Position - t.pos).Magnitude < 200 then
            local st = stage_of(egg) or egg:GetAttribute("Stage")
            if (S.egg_ok and not S.egg_ok(egg)) or (S.farm_mode == "Treadmill" and st ~= S.top_stage()) then
                S.titanic = nil
                logf("SKIP", ("Titanic egg in %s skipped: pets from there can't make your plot"):format(tostring(st)))
                return false
            end
            -- [[ forced (nothing else may pull the farm away from it), and only forgotten once it's won: a steal ]] --
            -- [[ that didn't go through tries again while the egg is still free                                    ]] --
            if steal(egg, true) then S.titanic = nil else task.wait(0.3) end
            return true
        end
    end
    if dist_to(t.pos) > 120 then
        S.status = "Going to the Titanic egg in " .. t.zone
        travel(ground(t.pos + Vector3.new(0, 0, 25)), t.pos)
        task.wait(1)
        return true
    end
    t.misses = (t.misses or 0) + 1
    if t.misses > 10 then S.titanic = nil end
    task.wait(0.3)
    return true
end

local function farm_step()
    if not root_part() or down() then S.status = "Waiting for your character" task.wait(0.5) return end
    if S.void_hold then S.status = "Fell off the map, going back to spawn" task.wait(0.2) return end
    if body_held() then
        S.status = "The game is holding your character after a hit, waiting for it to let go"
        task.wait(0.1)
        return
    end
    if busy() then task.wait(0.2) return end
    if S.hop_mode ~= "Off" and S.hop_step and S.hop_step() then return end
    -- [[ someone ran off with a pet you hatched: bat them so they drop it and take it straight back. This comes ]] --
    -- [[ before your other pets, since a thief who gets home with it keeps it                                   ]] --
    if S.bat_thieves and not carrying() then
        local thief, loot = find_thief()
        if thief and bat_thief(thief, loot) then return end
    end
    if collect_once() then return end
    -- [[ admin abuse (a spawned treadmill, or a big speed boost): train while it lasts. A Titanic or your event ]] --
    -- [[ egg hatching still comes first                                                                         ]] --
    if admin_step and not S.titanic and not S.event_hatch and admin_step() then return end
    -- [[ an event egg of yours is hatching: wait right there, take its pet first, bank it, then carry on ]] --
    local e = S.event_hatch
    if e then
        if os.clock() > e.until_t then
            S.event_hatch = nil
        else
            if dist_to(e.pos) > 70 then travel(ground(e.pos + Vector3.new(0, 0, 30)), e.pos) end
            S.status = "Waiting for the " .. tostring(e.name) .. " to hatch, its pet comes first"
            task.wait(0.2)
            return
        end
    end
    if S.titanic and (S.always_events or S.stages.Events or any_stage()) and go_titanic() then return end
    -- [[ Auto rejoin is due: no new normal eggs. Everything still hatching or on the ground is taken and banked ]] --
    -- [[ above, rare eggs (events) are still taken here, and then the rejoin goes                                ]] --
    if S.rejoin_due then
        local ev = S.rare_egg and S.rare_egg()
        if ev then
            S.empty_runs = 0
            steal(ev)
            return
        end
        S.status = "Rejoin due: " .. tostring(S.rejoin_note)
        task.wait(0.3)
        return
    end
    -- [[ Speed first: rebirths turn speed into money (+0.5x each), and the treadmill only pays while you stand on ]] --
    -- [[ it (one step every 0.3s, set by the server). So the farm trains, and only leaves the treadmill for what's ]] --
    -- [[ worth more: event eggs, good pets on the ground, thieves with your good pets, and Luck / Mutation boost   ]] --
    -- [[ windows (it mogs those). Pets still hatching from before are collected first.                             ]] --
    -- [[ With Mog from the treadmill working, it doesn't have to choose: it stands on the treadmill and farms from ]] --
    -- [[ there (speed keeps coming in). Only a pet worth taking makes it get off (picking up is checked up close); ]] --
    -- [[ it banks it and gets right back on. Treadmill farm only takes event eggs in the top stage.                ]] --
    local treadmill_farm = S.farm_mode == "Treadmill"
    local boosted = S.boost_now and S.boost_now()
    if (S.speed_first or treadmill_farm) and not S.event_hatch then
        local top = S.top_stage and S.top_stage()
        local ev = pick_egg()
        if ev and is_event(ev) and (not treadmill_farm or stage_of(ev) == top) then
            S.empty_runs = 0
            steal(ev)
            return
        end
        -- [[ (boost windows too: it mogs all out, from the treadmill) ]] --
        if S.mill_mog and not treadmill_farm then
            local root = root_part()
            if not S.on_treadmill() then
                if not carrying() then
                    S.status = "Getting on the treadmill to farm from it"
                    mount()
                    return
                end
            elseif root and not root.Anchored then
                task.wait(0.2) -- the treadmill holds you (anchors you) a moment after you step on
                return
            end
            -- [[ on the treadmill: carry on with the normal farm below, mogging from here ]] --
        elseif boosted and not treadmill_farm then
            -- [[ a boost window without Mog from the treadmill: mog all out (the normal farm below) ]] --
        elseif not carrying() then
            -- [[ pets still hatching don't hold this up: a good one stops the training as soon as it's on the ground ]] --
            train_for(10, function()
                return not (S.farm and (S.speed_first or S.farm_mode == "Treadmill")) or S.titanic ~= nil
                    or (S.boost_now and S.boost_now() ~= nil and S.farm_mode ~= "Treadmill")
                    or (waiting_rank and waiting_rank() > 0) or (S.bat_thieves and find_thief() ~= nil)
                    or (S.farm_mode == "Treadmill" and S.top_event_here and S.top_event_here())
            end, treadmill_farm and "Treadmill farm: training, waiting for an event egg in the top stage"
                or "Speed first: training (event eggs, good pets, thieves and boosts still come first)")
            return
        end
    end
    if treadmill_farm then
        S.status = "Treadmill farm: collecting"
        task.wait(0.2)
        return
    end
    local hatching = #S.hatching + S.fights
    -- [[ 12 eggs already hatching, but a free egg beats every one of them: that one is taken anyway ]] --
    if hatching >= MAX_HATCHING and S.pick ~= "Nearest" then
        local top = pick_egg()
        local best_hatching = -1
        for _, h in ipairs(S.hatching) do best_hatching = math.max(best_hatching, h.appeal or 0) end
        if top and egg_rank(top) > best_hatching then
            logf("PRIORITY", ("%s (%s appeal) beats all %d eggs hatching, going for it now"):format(top.Name,
                is_event(top) and "event" or short(appeal_of(top)), hatching))
            S.empty_runs = 0
            steal(top)
            return
        end
    end
    -- [[ every 90s, a quick look at the stages above the ones you picked: their eggs are higher, and free_eggs ]] --
    -- [[ takes them once they're loaded in                                                                      ]] --
    -- [[ (not with Leave worthless pets on: then only the top stage's eggs count, and higher ones are taken anyway) ]] --
    if hatching < MAX_HATCHING and S.pick ~= "Nearest" and not any_stage() and not carrying() and os.clock() - S.last_peek > 90
        and not (S.mill_hold and S.mill_hold()) and not (S.only_stage and S.only_stage()) then
        S.last_peek = os.clock()
        local top_picked = 0
        for name, on in pairs(S.stages) do
            if on and stage_num(name) > top_picked then top_picked = stage_num(name) end
        end
        if top_picked > 0 then
            for i = #STAGE_NAMES, 1, -1 do
                local name = STAGE_NAMES[i]
                local center = stage_num(name) > top_picked and not S.stages[name] and stage_center(name)
                if center then
                    S.status = "Peeking at " .. name .. " for higher eggs"
                    travel(ground(center), center + Vector3.new(0, 0, -10))
                    task.wait(1)
                    local egg = pick_egg()
                    if egg and not stage_ok(egg) then
                        steal(egg)
                        return
                    end
                end
            end
        end
    end
    if hatching < MAX_HATCHING then
        -- [[ on Any stage it goes back to where it last stole, instead of whatever is loaded near the safe zone ]] --
        if any_stage() and S.last_spot and dist_to(S.last_spot) > 600 and not (S.mill_hold and S.mill_hold()) then
            S.status = "Heading back to the eggs"
            travel(ground(S.last_spot + Vector3.new(0, 0, 12)), S.last_spot)
            task.wait(0.6)
            return
        end
        local egg = pick_egg()
        if egg then
            S.empty_runs = 0
            steal(egg)
            return
        end
        if not events_only() then
            S.empty_runs += 1
            -- [[ looked through every picked stage and every egg is taken: train until they respawn ]] --
            if S.treadmill and hatching == 0 and S.empty_runs > math.max(2, #picked_stages(true)) and not (S.boost_now and S.boost_now()) then
                S.empty_runs = 0
                train_for(20, function()
                    return S.titanic ~= nil or not S.farm or #S.pending > 0 or (waiting_rank and waiting_rank() > 0)
                        or (S.bat_thieves and find_thief() ~= nil) or (S.boost_now and S.boost_now() ~= nil)
                end, "No free eggs right now, training for 20s")
                return
            end
            scout()
            return
        end
    end
    if S.treadmill and events_only() and hatching == 0 and #S.pending == 0 and not carrying() and not (S.boost_now and S.boost_now()) then
        train_for(2, function() return S.titanic ~= nil or not S.farm end, "Waiting for a Titanic egg, training meanwhile")
        return
    end
    S.status = events_only() and hatching == 0 and "Waiting for an event (Titanic) egg" or ("Waiting for %d egg(s) to hatch"):format(hatching)
    task.wait(0.25)
end

local equip_remote = Remotes:FindFirstChild("Pets") and Remotes.Pets:FindFirstChild("EquipBest")
local function maybe_equip()
    if not S.equip_best then return end
    -- [[ Grow babies (further down) handles a full plot itself; the game's Equip Best would take the babies off ]] --
    if S.grow_step then
        local ok, full = pcall(S.grow_step)
        if not ok then
            if full ~= S.last_grow_err then
                S.last_grow_err = full
                logf("ERROR", "grow babies: " .. tostring(full):sub(1, 300))
            end
        elseif full then
            return
        end
    end
    if not (S.need_equip and equip_remote and os.clock() - S.last_equip > 25) then return end
    S.last_equip, S.need_equip = os.clock(), false
    task.spawn(function() pcall(function() equip_remote:InvokeServer() end) end)
end

-- [[ Auto mutate: whenever you own 3 of the same pet (not mutated yet), they go in the Mutate Machine (Mutate.Fuse). ]] --
-- [[ It picks like the game's own Auto Fill: your heaviest one (the one you keep, now Golden or Diamond) plus the  ]] --
-- [[ two lightest. The machine allows one fuse a second; this does one every 2 seconds at most.                   ]] --
local function find_module(path)
    local m = RS
    for _, name in ipairs(path) do m = m and m:FindFirstChild(name) end
    return m
end
local function load_module(path)
    local m = find_module(path)
    if not m then return nil end
    local ok, result = pcall(require, m)
    return ok and type(result) == "table" and result or nil
end
local MutateUtil = load_module({ "Shared", "Utilities", "MutateUtil" })
local PlayerData = load_module({ "Shared", "Modules", "DataReceiver", "PlayerData" })
local fuse_remote = Remotes:FindFirstChild("Mutate") and Remotes.Mutate:FindFirstChild("Fuse")
local function is_placed(rec) return type(rec.Placed) == "table" and type(rec.Placed.X) == "number" end
local function fuse_pick()
    if not (MutateUtil and PlayerData) then return nil end
    local ok, pets = pcall(PlayerData.Get, "Pets")
    if not ok or type(pets) ~= "table" then return nil end
    local ok2, groups = pcall(MutateUtil.Group, pets)
    if not ok2 or type(groups) ~= "table" then return nil end
    local pick_name, pick_list
    for name, list in pairs(groups) do
        if #list >= 3 and os.clock() >= (S.fuse_fail[name] or 0)
            and (not pick_list or (tonumber(list[1].Weight) or 0) > (tonumber(pick_list[1].Weight) or 0)) then
            pick_name, pick_list = name, list
        end
    end
    if not pick_list then return nil end
    local recs = { pick_list[1], pick_list[#pick_list], pick_list[#pick_list - 1] }
    return pick_name, { recs[1].Id, recs[2].Id, recs[3].Id }, recs
end
-- [[ pets standing on your plot (equipped) have a Placed spot in your data; the machine needs them off first ]] --
local unequip_remote = Remotes:FindFirstChild("Pets") and Remotes.Pets:FindFirstChild("Unequip")
local function maybe_mutate()
    if not (S.auto_mutate and fuse_remote) or S.fusing or os.clock() - S.last_fuse < 2 then return end
    local name, ids, recs = fuse_pick()
    if not name then return end
    S.fusing, S.last_fuse = true, os.clock()
    go(function()
        -- [[ any of the 3 standing on your plot is taken off first (the game's own Unequip), then put back after ]] --
        local placed = 0
        for _, rec in ipairs(recs) do
            if is_placed(rec) and unequip_remote then
                pcall(function() unequip_remote:InvokeServer(rec.Id) end)
                placed += 1
                task.wait(0.35)
            end
        end
        if placed > 0 then
            logf("MUTATE", ("took %d %s off your plot to mutate them"):format(placed, name))
            task.wait(0.6)
        end
        local ok, answer = pcall(function() return fuse_remote:InvokeServer(ids) end)
        if placed > 0 and S.grow_babies and S.grow_step then
            -- [[ Grow babies fills the plot itself (the game's Equip Best would take its babies off again) ]] --
            S.need_equip, S.last_grow = true, 0
            logf("MUTATE", "your plot gets refilled by Grow babies")
        elseif placed > 0 and equip_remote then
            -- [[ puts your best pets (now including the mutated one) back on your plot ]] --
            task.wait(1)
            for _ = 1, 4 do
                local okE, res = pcall(function() return equip_remote:InvokeServer() end)
                if okE and type(res) == "table" and res.Success then break end
                task.wait(2)
            end
            S.last_equip = os.clock()
            logf("MUTATE", "put your best pets back on your plot")
        end
        if ok and type(answer) == "table" and answer.Success then
            local pet = type(answer.Pet) == "table" and answer.Pet or {}
            S.mutated += 1
            S.need_equip = true
            S.last_mutate = ("%s %s"):format(tostring(pet.Mutation or "?"), tostring(pet.Name or name))
        else
            S.fuse_fail[name] = os.clock() + 30
            S.last_mutate = ("%s didn't work (%s)"):format(name, tostring(ok and type(answer) == "table" and answer.Reason or answer))
        end
        logf("MUTATE", S.last_mutate)
        S.fusing = false
    end)
end

-- [[ Auto treadmill. The probe showed the server only gives speed while you really stand on your treadmill    ]] --
-- [[ (not from far away, not faster by spamming, and it stops the moment you step off), about 40M speed a     ]] --
-- [[ second. So this stands you on it: all the time when the farm is off, and while the farm has nothing to do. ]] --
local TreadmillUtil = load_module({ "Shared", "Utilities", "TreadmillUtil" })
local okT, TreadmillCtl = pcall(require, Controllers:WaitForChild("TreadmillController", 5))
if not (okT and type(TreadmillCtl) == "table") then TreadmillCtl = nil end
local train_remote = Remotes:FindFirstChild("Treadmill") and Remotes.Treadmill:FindFirstChild("Train")
local function on_treadmill()
    local ok, active = pcall(function() return TreadmillCtl and TreadmillCtl.IsTraining() end)
    return ok and active == true
end
S.on_treadmill = on_treadmill
-- [[ on the treadmill and held by it (anchored), with Mog from the treadmill on: moves now stay on your screen ]] --
S.mill_hold = function()
    local root = root_part()
    return S.mill_mog and root ~= nil and root.Anchored and on_treadmill()
end
local function treadmill_stand()
    local plot = game_folder("Plots") and game_folder("Plots"):FindFirstChild(tostring(me:GetAttribute("Plot")))
    local spot = plot and plot:FindFirstChild("TreadmillSpot")
    local model = plot and plot:FindFirstChild("Treadmill")
    local char = me.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = root_part()
    if not (spot and spot:IsA("BasePart") and model and hum and root) then return nil end
    local deck = 1.4
    if TreadmillUtil then
        local ok, h = pcall(TreadmillUtil.GetDeckHeight, model)
        if ok and tonumber(h) then deck = h end
    end
    return spot.CFrame * CFrame.new(0, deck + hum.HipHeight + root.Size.Y / 2, 1)
end
-- [[ gets off the way you would: a Space press (the game then stops training and frees you) ]] --
local function dismount()
    S.on_mill = false
    if not on_treadmill() then return end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    local t = os.clock()
    repeat task.wait(0.05) until not on_treadmill() or os.clock() - t > 1
    logf("TREADMILL", "got off")
    if on_treadmill() and train_remote then
        logf("TREADMILL", "the treadmill didn't let go after Space, forced off")
        pcall(function() train_remote:FireServer(false) end)
        local root = root_part()
        if root then root.Anchored = false end
    end
end
before_travel = function()
    -- [[ Mog from the treadmill: stay on it (anchored) while the farm goes to mog an egg ]] --
    if S.keep_mill then
        local root = root_part()
        if root and root.Anchored then return end
    end
    if S.on_mill or on_treadmill() then dismount() end
end
-- [[ goes to your base and steps on; the game starts training by itself once you're on it ]] --
mount = function()
    if on_treadmill() then S.on_mill = true return true end
    if carrying() or busy() or down() then return false end
    local plot = game_folder("Plots") and game_folder("Plots"):FindFirstChild(tostring(me:GetAttribute("Plot")))
    if not (plot and plot:FindFirstChild("TreadmillSpot")) then
        travel(S.safe_center or SAFE_FALLBACK) -- your base loads in, then the treadmill can be found
        task.wait(0.5)
    end
    local stand = treadmill_stand()
    if not stand then S.status = "Couldn't find your treadmill" return false end
    S.status = "Going to your treadmill"
    travel(stand.Position, (stand * CFrame.new(0, 0, -5)).Position)
    local t = os.clock()
    repeat task.wait(0.1) until on_treadmill() or os.clock() - t > 3
    if not on_treadmill() and train_remote then pcall(function() train_remote:FireServer(true) end) end
    S.on_mill = true
    logf("TREADMILL", on_treadmill() and "got on, training" or "stood on it but the game didn't start training")
    return true
end
-- [[ Admin abuse. Watched all the time:                                                                        ]] --
-- [[  * a treadmill spawned outside the plots (a "4x / 10x treadmill"): the farm stands on it and trains there   ]] --
-- [[    while the server sends speed steps; if none come in 6s it's logged and left                              ]] --
-- [[  * your speed multiplier jumping 3x or more within a minute (a server-wide boost): the farm trains on your   ]] --
-- [[    own treadmill while it lasts (30 min at most)                                                            ]] --
-- [[ Pets on the ground, thieves and event / admin eggs still come first. Anything new that spawns in the map is ]] --
-- [[ written to the log (SPAWNED lines), so the exact setup can be added after the first time it happens.        ]] --
do
    local step_remote = Remotes:FindFirstChild("Treadmill") and Remotes.Treadmill:FindFirstChild("Step")
    if step_remote and step_remote:IsA("RemoteEvent") then
        track(step_remote.OnClientEvent:Connect(function(...)
            S.last_step_t = os.clock()
            -- [[ how much speed a step gives (for the speed / rebirth estimate in the Speed tab) ]] --
            for _, v in ipairs({ ... }) do
                local n = tonumber(v) or (type(v) == "table" and tonumber(v.Gain or v.Amount or v.Speed or v.Step))
                if n and n > 0 then
                    S.step_gain = n
                    break
                end
            end
        end))
    end
    local SKIP = { Loot = true, Eggs = true, Plots = true, PlayerTraps = true }
    local GAME_MILL_PARTS = { TreadmillDeck = true, TreadmillSpot = true, TreadmillRunner = true }
    local function attr_text(d)
        local ok, text = pcall(function() return HttpService:JSONEncode(d:GetAttributes()) end)
        return ok and text or ""
    end
    local function spawned(d)
        if not d.Parent or not (d:IsA("Model") or d:IsA("BasePart") or d:IsA("Folder")) or Players:GetPlayerFromCharacter(d) then return end
        local plots = game_folder("Plots")
        -- [[ only whole treadmill models; the game's own deck / spot / runner parts (it adds a TreadmillDeck to the ]] --
        -- [[ map each time you step on your own treadmill) and ones already tried are ignored                      ]] --
        if d:IsA("Model") and d.Name:lower():find("treadmill") and not GAME_MILL_PARTS[d.Name] and not (plots and d:IsDescendantOf(plots))
            and not S.mill_tried[d] then
            local pos = where(d)
            if pos and not (S.boost_mill and S.boost_mill.inst == d) then
                S.boost_mill = { inst = d, pos = pos, t = os.clock() }
                logf("ADMIN", ("a treadmill spawned outside the plots: %s at %d, %d, %d %s"):format(d:GetFullName(), pos.X, pos.Y, pos.Z, attr_text(d)))
                if S.farm then notify("A special treadmill spawned, going to train on it.") end
            end
        end
        if S.spawn_logs < 40 and (d:IsA("Model") or d:IsA("Folder")) then
            S.spawn_logs += 1
            local pos = d:IsA("Model") and where(d) or nil
            logf("SPAWNED", ("%s %s%s %s"):format(d.ClassName, d:GetFullName(),
                pos and (" at %d, %d, %d"):format(pos.X, pos.Y, pos.Z) or "", attr_text(d)))
        end
    end
    track(workspace.ChildAdded:Connect(function(d) task.defer(spawned, d) end))
    local g = workspace:FindFirstChild("Game")
    if g then
        track(g.ChildAdded:Connect(function(d) task.defer(spawned, d) end))
        for _, f in ipairs(g:GetChildren()) do
            if f:IsA("Folder") and not SKIP[f.Name] then
                track(f.ChildAdded:Connect(function(d) task.defer(spawned, d) end))
            end
        end
    end
    track(workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Model") and d.Name:lower():find("treadmill") then task.defer(spawned, d) end
    end))
end
admin_step = function()
    local m = S.boost_mill
    if m and (not m.inst.Parent or os.clock() - m.t > 1800) then
        if m.arrived then logf("ADMIN", "the special treadmill is gone") end
        S.boost_mill, m = nil, nil
    end
    if m then
        local pos = where(m.inst) or m.pos
        if dist_to(pos) > 10 then
            S.status = "Going to the special treadmill"
            local ok, cf, size = pcall(function()
                if m.inst:IsA("Model") then return m.inst:GetBoundingBox() end
                return m.inst.CFrame, m.inst.Size
            end)
            travel(ok and (cf.Position + Vector3.new(0, size.Y / 2 + 3, 0)) or (pos + Vector3.new(0, 5, 0)))
        end
        -- [[ (also when you were already standing next to it: a dead treadmill is left after 6s either way) ]] --
        m.arrived = m.arrived or os.clock()
        if train_remote and os.clock() - S.last_step_t > 1.5 then pcall(function() train_remote:FireServer(true) end) end
        if m.arrived and os.clock() - m.arrived > 6 and os.clock() - S.last_step_t > 6 then
            logf("ADMIN", "stood on the special treadmill but no speed came in, left it")
            S.mill_tried[m.inst] = true
            S.boost_mill = nil
            return false
        end
        S.status = "Training on the special treadmill"
        task.wait(0.5)
        return true
    end
    -- [[ a server-wide speed boost: the multiplier is compared with what it was about a minute ago ]] --
    local mult = tonumber(me:GetAttribute("SpeedMultiplier")) or 0
    if mult <= 0 then return false end
    if S.base_mult <= 0 or (not S.boosted and os.clock() - S.mult_t > 60) then S.base_mult, S.mult_t = mult, os.clock() end
    if not S.boosted and mult >= S.base_mult * 3 then
        S.boosted, S.boost_until = true, os.clock() + 1800
        logf("ADMIN", ("speed multiplier jumped x%.1f (%s -> %s), training while it lasts"):format(mult / S.base_mult, short(S.base_mult), short(mult)))
        notify(("Speed boost x%.0f! Training on your treadmill while it lasts."):format(mult / S.base_mult))
    end
    if S.boosted and (mult < S.base_mult * 2 or os.clock() > S.boost_until) then
        S.boosted, S.base_mult, S.mult_t = false, mult, os.clock()
        logf("ADMIN", "speed boost is over, back to farming")
    end
    if S.boosted then
        train_for(10, function() return not S.farm or #S.pending > 0 or S.titanic ~= nil or S.boost_mill ~= nil end,
            ("Speed boost x%.0f, training"):format(mult / S.base_mult))
        return true
    end
    return false
end
train_for = function(seconds, stop_if, text)
    -- [[ a reason to stop that's already true (a Titanic it can't go for, a thief it won't bat) mustn't make the ]] --
    -- [[ farm spin every frame without training: it waits a moment and the farm decides again                    ]] --
    if stop_if and stop_if() then
        task.wait(0.25)
        return
    end
    local t = os.clock()
    while S.alive and os.clock() - t < seconds and not (stop_if and stop_if()) do
        if not on_treadmill() and not mount() then
            task.wait(2)
            break
        end
        S.status = text or "Training on the treadmill"
        task.wait(0.5)
    end
end

-- [[ Walk around while training: the server only gives treadmill speed while your real character stands on it  ]] --
-- [[ (tested: 60 studs away = nothing), so your body stays on the treadmill and you walk around as a ghost copy ]] --
-- [[ only you can see; the camera follows it (WASD, Space to jump). The ghost can look around but can't mog,    ]] --
-- [[ take or bank anything. The game takes you off the treadmill on any jump (UserInputService.JumpRequest), so ]] --
-- [[ that's paused while the ghost is out. It ends by itself if your body leaves the treadmill.                ]] --
do
    local ghost, render, paused_jump = nil, nil, {}
    local function pause_jump_exit()
        if typeof(getconnections) ~= "function" then return end
        pcall(function()
            for _, c in ipairs(getconnections(UserInputService.JumpRequest)) do
                if not table.find(paused_jump, c) and pcall(function() c:Disable() end) then table.insert(paused_jump, c) end
            end
        end)
    end
    S.ghost_off = function(why)
        if render then render:Disconnect() render = nil end
        for _, c in ipairs(paused_jump) do pcall(function() c:Enable() end) end
        table.clear(paused_jump)
        if ghost then pcall(function() ghost:Destroy() end) ghost = nil end
        S.ghost_active = false
        local hum = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() workspace.CurrentCamera.CameraSubject = hum end) end
        if why then logf("TREADMILL", "walking around ended: " .. tostring(why)) end
    end
    -- [[ the on-screen joystick (phones and tablets): the game's own PlayerModule move vector, x = right, z = back ]] --
    S.stick = function()
        local ok, v = pcall(function()
            local pm: any = me:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
            S.controls = S.controls or (require(pm) :: any):GetControls()
            return S.controls:GetMoveVector()
        end)
        return (ok and typeof(v) == "Vector3") and v or Vector3.zero
    end
    S.ghost_on = function()
        local char = me.Character
        if ghost or not (char and char:FindFirstChildOfClass("Humanoid")) then return false end
        local was = char.Archivable
        char.Archivable = true
        local ok, g = pcall(function() return char:Clone() end)
        char.Archivable = was
        if not (ok and g) then return false end
        for _, d in ipairs(g:GetDescendants()) do
            if d.Parent then
                if d:IsA("LuaSourceContainer") or d:IsA("Tool") or d:IsA("ForceField") or d:IsA("BillboardGui") then
                    d:Destroy()
                elseif d:IsA("BasePart") then
                    d.Anchored = false
                    d.Transparency = math.max(d.Transparency, 0.4)
                end
            end
        end
        local ghum, groot = g:FindFirstChildOfClass("Humanoid"), g:FindFirstChild("HumanoidRootPart")
        if not (ghum and groot) then g:Destroy() return false end
        g.Name = me.Name .. "_ghost"
        ghum.WalkSpeed, ghum.UseJumpPower, ghum.JumpPower, ghum.AutoRotate, ghum.PlatformStand = 40, true, 50, true, false
        ghum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        g.Parent = workspace
        groot.CFrame = char:GetPivot() * CFrame.new(0, 2, -5) -- just in front of the treadmill
        ghost = g
        local walk = nil
        pcall(function()
            local animate = char:FindFirstChild("Animate")
            local folder = animate and (animate:FindFirstChild("run") or animate:FindFirstChild("walk"))
            local anim = folder and folder:FindFirstChildOfClass("Animation")
            local animator = ghum:FindFirstChildOfClass("Animator") or Instance.new("Animator", ghum)
            if anim then walk = animator:LoadAnimation(anim) end
        end)
        workspace.CurrentCamera.CameraSubject = ghum
        pause_jump_exit()
        S.ghost_active = true
        logf("TREADMILL", "walking around as a ghost, your body keeps training")
        local check_t, off_since, home = os.clock(), nil, groot.Position
        render = RunService.RenderStepped:Connect(function()
            if not (ghost and ghost.Parent and S.alive) then S.ghost_off() return end
            local cam = workspace.CurrentCamera
            local typing = UserInputService:GetFocusedTextBox() ~= nil
            local function key(k) return not typing and UserInputService:IsKeyDown(k) end
            local f = (key(Enum.KeyCode.W) and 1 or 0) - (key(Enum.KeyCode.S) and 1 or 0)
            local r = (key(Enum.KeyCode.D) and 1 or 0) - (key(Enum.KeyCode.A) and 1 or 0)
            if f == 0 and r == 0 then
                local mv = S.stick()
                f, r = -mv.Z, mv.X
            end
            local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            local right = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
            local dir = (look.Magnitude > 0 and look.Unit or Vector3.zero) * f + (right.Magnitude > 0 and right.Unit or Vector3.zero) * r
            ghum:Move(dir.Magnitude > 0 and dir.Unit or Vector3.zero, false)
            local real = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
            if (key(Enum.KeyCode.Space) or (real and real.Jump)) and ghum.FloorMaterial ~= Enum.Material.Air then ghum.Jump = true end
            if walk then
                if dir.Magnitude > 0 and not walk.IsPlaying then walk:Play() elseif dir.Magnitude == 0 and walk.IsPlaying then walk:Stop() end
            end
            -- [[ fell off the map: back to where it started ]] --
            if groot.Position.Y < -60 then
                groot.CFrame = CFrame.new(home)
                groot.AssemblyLinearVelocity = Vector3.zero
            end
            if os.clock() - check_t > 1 then
                check_t = os.clock()
                -- [[ the map loads around your body; this loads it around the ghost too, so it has a floor ]] --
                local at = groot.Position
                task.spawn(function() pcall(function() me:RequestStreamAroundAsync(at, 2) end) end)
                -- [[ stepping back on the treadmill reconnects its jump exit: keep it paused ]] --
                pause_jump_exit()
                if on_treadmill() then off_since = nil else off_since = off_since or os.clock() end
                if off_since and os.clock() - off_since > 4 then task.defer(S.ghost_off, "your character left the treadmill") end
            end
        end)
        return true
    end
end

-- [[ Movement, for moving around yourself: Fly (WASD where the camera looks, Space up, Ctrl or Q down) and a   ]] --
-- [[ fixed walk speed. Both pause while Auto farm runs (it moves you itself) or you're on the treadmill.       ]] --
do
    local fly_conn, att, lv, ao = nil, nil, nil, nil
    local function fly_parts_off()
        for _, x in ipairs({ lv, ao, att }) do
            if x then pcall(function() x:Destroy() end) end
        end
        lv, ao, att = nil, nil, nil
    end
    local function paused() return S.farm or S.manual or on_treadmill() end
    S.fly_set = function(on)
        S.flying = on
        if fly_conn then fly_conn:Disconnect() fly_conn = nil end
        fly_parts_off()
        local hum = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        if not on then
            if hum then hum.PlatformStand = false end
            return
        end
        fly_conn = RunService.RenderStepped:Connect(function()
            local hum2 = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
            local root = root_part()
            if not (S.alive and S.flying and hum2 and root) then return end
            if paused() then
                if att then
                    fly_parts_off()
                    hum2.PlatformStand = false
                end
                return
            end
            if not (att and att.Parent == root and lv and ao) then
                fly_parts_off()
                att = Instance.new("Attachment")
                att.Name = "MogFly"
                att.Parent = root
                lv = Instance.new("LinearVelocity")
                lv.Attachment0, lv.MaxForce, lv.RelativeTo, lv.VectorVelocity = att, math.huge, Enum.ActuatorRelativeTo.World, Vector3.zero
                lv.Parent = root
                ao = Instance.new("AlignOrientation")
                ao.Mode, ao.Attachment0, ao.MaxTorque, ao.Responsiveness = Enum.OrientationAlignmentMode.OneAttachment, att, math.huge, 60
                ao.Parent = root
            end
            hum2.PlatformStand = true
            local cam = workspace.CurrentCamera
            local typing = UserInputService:GetFocusedTextBox() ~= nil
            local function key(k) return not typing and UserInputService:IsKeyDown(k) end
            local f = (key(Enum.KeyCode.W) and 1 or 0) - (key(Enum.KeyCode.S) and 1 or 0)
            local r = (key(Enum.KeyCode.D) and 1 or 0) - (key(Enum.KeyCode.A) and 1 or 0)
            local u = (key(Enum.KeyCode.Space) and 1 or 0) - ((key(Enum.KeyCode.LeftControl) or key(Enum.KeyCode.Q)) and 1 or 0)
            if f == 0 and r == 0 then
                local mv = S.stick()
                f, r = -mv.Z, mv.X
            end
            if u == 0 and hum2.Jump then u = 1 end
            local dir = cam.CFrame.LookVector * f + cam.CFrame.RightVector * r + Vector3.yAxis * u
            lv.VectorVelocity = dir.Magnitude > 0 and dir.Unit * S.fly_speed or Vector3.zero
            local flat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            if flat.Magnitude > 0.01 then ao.CFrame = CFrame.lookAt(Vector3.zero, flat) end
        end)
    end
    local speed_conn, normal_speed = nil, nil
    S.speed_set = function(on)
        S.speed_on = on
        if speed_conn then speed_conn:Disconnect() speed_conn = nil end
        local hum = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        if not on then
            if hum and not on_treadmill() then
                hum.WalkSpeed = normal_speed or tonumber(me.Character:GetAttribute("OriginalWalkSpeed")) or 16
            end
            return
        end
        if hum and hum.WalkSpeed > 0 then normal_speed = hum.WalkSpeed end
        speed_conn = RunService.Heartbeat:Connect(function()
            local h = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
            if h and S.speed_on and not h.PlatformStand and h.WalkSpeed ~= S.walk_speed and not paused() then h.WalkSpeed = S.walk_speed end
        end)
    end
end

---------------------------------------------------------------- protection: no ragdoll, and bat whoever takes your pet

-- [[ When a bot (or anyone) bats you, the server sets FlingAt / Ragdolled on your character and swaps your     ]] --
-- [[ joints for loose ones. Your game runs your body, so this undoes it right away: joints back, standing,     ]] --
-- [[ no fling speed. (Being hit while carrying still makes the server drop the pet; the farm then re-takes it.) ]] --
local function unragdoll(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not (hum and root) then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BallSocketConstraint") and d.Name == "RagdollSocket" then
            d.Enabled = false
        elseif d:IsA("Motor6D") or d:IsA("AnimationConstraint") then
            d.Enabled = true
        elseif d:IsA("BasePart") and d.Name == "ColliderPart" then
            d.CanCollide = false
        end
    end
    hum.PlatformStand = false
    hum.AutoRotate = true
    hum.WalkSpeed = tonumber(char:GetAttribute("OriginalWalkSpeed")) or 16
    hum.JumpPower = tonumber(char:GetAttribute("OriginalJumpPower")) or 50
    hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    root.Massless = false
    root.AssemblyLinearVelocity = Vector3.zero
    char:SetAttribute("Ragdolled", nil) -- only on your side, so the game lets you mog again right away
end
local function guard_character(char)
    track(char:GetAttributeChangedSignal("Ragdolled"):Connect(function()
        if char:GetAttribute("Ragdolled") ~= true then return end
        S.hit_t = os.clock()
        logf("HIT", "ragdolled" .. (S.anti_ragdoll and ", undone right away" or " (anti ragdoll is off)") .. " | status: " .. S.status)
        if S.anti_ragdoll then task.defer(unragdoll, char) end
    end))
    track(char:GetAttributeChangedSignal("FlingAt"):Connect(function()
        S.hit_t = os.clock()
        logf("HIT", "flung by a hit" .. (S.anti_ragdoll and ", fling cancelled" or ""))
        if not S.anti_ragdoll then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local t = os.clock()
        while root and root.Parent and os.clock() - t < 0.8 do
            root.AssemblyLinearVelocity = Vector3.zero
            RunService.Heartbeat:Wait()
        end
    end))
    track(char.DescendantAdded:Connect(function(d)
        if S.anti_ragdoll and (d.Name == "FlingVelocity" or d.Name == "FlingAttachment") then
            task.defer(function() pcall(function() d:Destroy() end) end)
        end
    end))
end
local function watch_life(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        track(hum.Died:Connect(function()
            local root = char:FindFirstChild("HumanoidRootPart")
            logf("CHAR", ("you died at %s (status: %s)"):format(root and ("%d, %d, %d"):format(root.Position.X, root.Position.Y, root.Position.Z) or "?", S.status))
        end))
    end
end
if me.Character then
    guard_character(me.Character)
    task.spawn(watch_life, me.Character)
end
track(me.CharacterAdded:Connect(function(char)
    logf("CHAR", "respawned")
    guard_character(char)
    task.spawn(watch_life, char)
end))
-- [[ the knockback the game plays on your side when you're hit while carrying ]] --
local paused_knock = {}
do
    local knocked = Remotes:FindFirstChild("Loot") and Remotes.Loot:FindFirstChild("Knocked")
    if knocked and typeof(getconnections) == "function" then
        pcall(function()
            for _, c in ipairs(getconnections(knocked.OnClientEvent)) do
                if pcall(function() c:Disable() end) then table.insert(paused_knock, c) end
            end
        end)
    end
    if knocked then
        track(knocked.OnClientEvent:Connect(function()
            S.last_knock_t = os.clock()
            S.hit_t = os.clock()
            logf("HIT", "knocked while carrying a pet: the server dropped it, the farm picks it back up")
        end))
    end
end

-- [[ Bat thieves: if a bot or player runs off with a pet you hatched, you jump behind them and hit them with  ]] --
-- [[ your bat until they drop it (not inside the safe zone, the game doesn't allow hits there). The farm then  ]] --
-- [[ picks the pet back up and banks it.                                                                       ]] --
local swing_remote = Remotes:FindFirstChild("Weapon") and Remotes.Weapon:FindFirstChild("Swing")
-- [[ Only pets worth having are chased (same keep bar as the ground: could it make your plot as an Ancient      ]] --
-- [[ Diamond?): yours, and good ones others dropped that the farm was going for (but not from their own owner). ]] --
-- [[ Someone running off with your trash is left alone.                                                       ]] --
find_thief = function()
    local folder = loot_folder()
    local floor = (S.skip_junk and not S.gift and S.keep_floor) and S.keep_floor() or 0
    for _, m in ipairs(folder and folder:GetChildren() or {}) do
        local id = m:GetAttribute("LootId")
        local state = m:GetAttribute("LootState")
        if id and state ~= nil and state ~= "Ground" and not S.gifted[id] and me:GetAttribute("CarryingLoot") ~= id then
            local pos = where(m)
            local mine = S.my_pets[id] or m:GetAttribute("OwnerUserId") == me.UserId
            local value = S.loot_value and S.loot_value(m)
            local good = floor <= 0 or not value or value > floor or near_titanic_spot(pos, m)
            if mine and not good then
                if not S.let_go[id] then
                    S.let_go[id] = true
                    logf("THIEF", ("someone took your %s: not chasing, it can't make your plot (at best $%s/s)"):format(m.Name, short(value or 0)))
                end
            elseif good and (mine or S.wanted[id]) then
                local best, best_d = nil, 18
                for _, c in ipairs(workspace:GetChildren()) do
                    if c:IsA("Model") and c ~= me.Character and c.Name ~= me.Name .. "_ghost" then
                        local hum, r = c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
                        if hum and r and hum.Health > 0 and pos and (r.Position - pos).Magnitude < best_d then
                            best, best_d = c, (r.Position - pos).Magnitude
                        end
                    end
                end
                -- [[ a player picking up their own pet isn't a thief ]] --
                local who = best and Players:GetPlayerFromCharacter(best)
                if best and not (not mine and who and m:GetAttribute("OwnerUserId") == who.UserId) then return best, m end
            end
        end
    end
    return nil
end
local function equip_bat()
    local char = me.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    local function is_bat(t) return t:IsA("Tool") and (t:GetAttribute("ItemType") == "Weapon" or t.Name == "Bat") end
    for _, t in ipairs(char:GetChildren()) do if is_bat(t) then return true end end
    local bp = me:FindFirstChildOfClass("Backpack")
    for _, t in ipairs(bp and bp:GetChildren() or {}) do
        if is_bat(t) then
            hum:EquipTool(t)
            task.wait(0.2)
            return true
        end
    end
    return false
end
bat_thief = function(thief, loot)
    if not swing_remote or carrying() or busy() then return false end
    local r = thief:FindFirstChild("HumanoidRootPart")
    if not r then return false end
    if SafeZoneUtil and SafeZoneUtil.ContainsPosition(r.Position) then return false end
    -- [[ on the treadmill you're anchored: moves don't reach the server, so every swing would miss from back there ]] --
    if on_treadmill() then
        if S.ghost_off then S.ghost_off("going after a thief") end
        dismount()
    end
    if not equip_bat() then S.status = "No bat in your backpack to stop the thief" return false end
    S.status = ("Batting %s, they took your %s"):format(thief.Name, loot.Name)
    logf("THIEF", ("%s took your %s, batting them"):format(thief.Name, loot.Name))
    local id = loot:GetAttribute("LootId")
    hatch_note(id, "outcome", "taken by " .. thief.Name .. " (being won back)")
    if id then S.won_back[id] = os.clock() end -- whenever it drops, it's the first pet taken
    -- [[ stuck to them: every frame you're right behind the thief, moving with them and facing the way they run, ]] --
    -- [[ so they're always inside the bat's hitbox (a 6 x 7.5 stud box in front of you, WeaponConfig). The bat is ]] --
    -- [[ swung on its cooldown (0.8s) until the pet drops.                                                        ]] --
    local function stick()
        local tr = thief:FindFirstChild("HumanoidRootPart")
        local root = root_part()
        if not (S.alive and tr and root) then return end
        local vel = tr.AssemblyLinearVelocity
        local flat = Vector3.new(vel.X, 0, vel.Z)
        local look = flat.Magnitude > 2 and flat.Unit or Vector3.new(tr.CFrame.LookVector.X, 0, tr.CFrame.LookVector.Z)
        if look.Magnitude < 0.01 then look = Vector3.new(0, 0, -1) end
        look = look.Unit
        local spot = tr.Position - look * 1.5
        root.CFrame = CFrame.lookAt(spot, spot + look)
        root.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
        root.AssemblyAngularVelocity = Vector3.zero
    end
    -- [[ whoever is holding your pet right now (the one carrying it can change) ]] --
    local function holder()
        local pos = where(loot)
        local best, best_d = nil, 18
        for _, c in ipairs(workspace:GetChildren()) do
            if c:IsA("Model") and c ~= me.Character and c.Name ~= me.Name .. "_ghost" then
                local hum, cr = c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
                if hum and cr and hum.Health > 0 and pos and (cr.Position - pos).Magnitude < best_d then best, best_d = c, (cr.Position - pos).Magnitude end
            end
        end
        return best
    end
    -- [[ the follow lives on S, so a farm restart (or Unload) mid-chase lets go of the thief too ]] --
    local function start_follow()
        if S.thief_follow then S.thief_follow:Disconnect() end
        S.thief_follow = RunService.Heartbeat:Connect(stick)
    end
    local function stop_follow()
        if S.thief_follow then S.thief_follow:Disconnect() S.thief_follow = nil end
    end
    start_follow()
    local t0, next_swing, next_check = os.clock(), 0, os.clock() + 1
    while S.alive and os.clock() - t0 < 20 do
        if not loot.Parent then break end
        -- [[ knocked out of their hands: take it back right here, before they (or anyone) grab it again, and bank it ]] --
        if loot:GetAttribute("LootState") == "Ground" then
            stop_follow()
            if id then S.won_back[id], S.loot_fail[id] = os.clock(), nil end
            if take(loot) then
                logf("THIEF", ("got your %s back from %s"):format(loot.Name, thief.Name))
                hatch_note(id, "outcome", "taken back from " .. thief.Name)
                finish_carry()
                return true
            end
            if loot:GetAttribute("LootState") == "Ground" or not loot.Parent then break end
            -- [[ someone grabbed it again first: back on them ]] --
            thief = holder() or thief
            start_follow()
        end
        if os.clock() >= next_check then
            next_check = os.clock() + 1
            thief = holder() or thief
        end
        local tr = thief:FindFirstChild("HumanoidRootPart")
        local hum = thief:FindFirstChildOfClass("Humanoid")
        if not (thief.Parent and tr) or (hum and hum.Health <= 0) then break end
        if SafeZoneUtil and SafeZoneUtil.ContainsPosition(tr.Position) then
            logf("THIEF", ("%s made it into the safe zone with your %s, hits don't work there"):format(thief.Name, loot.Name))
            break
        end
        if os.clock() >= next_swing then
            next_swing = os.clock() + 0.85
            pcall(function() swing_remote:FireServer() end)
        end
        task.wait(0.05)
    end
    stop_follow()
    return true
end

---------------------------------------------------------------- pets advisor

-- [[ Uses the game's own income math (PetEarningUtil) on your pets: which are your best, which are worth      ]] --
-- [[ mutating, which to keep collecting, and which stay useless even if mutated (sell those later). Your plot ]] --
-- [[ holds MaxAnimals pets, so a pet only matters if it can beat the weakest one that would be on it.          ]] --
local PetEarningUtil = load_module({ "Shared", "Utilities", "PetEarningUtil" })
local function income_of(p)
    if not PetEarningUtil then return 0 end
    local ok, v = pcall(PetEarningUtil.GetRecordIncome, p)
    return ok and tonumber(v) or 0
end
local function best_mult(name)
    local m = 1
    if MutateUtil then
        local ok, opts = pcall(MutateUtil.GetOptions, name)
        for _, o in ipairs(ok and type(opts) == "table" and opts or {}) do
            m = math.max(m, tonumber(type(o.Mutation) == "table" and o.Mutation.CashMult) or 1)
        end
    end
    return m
end
local function pet_report()
    if not PlayerData then return nil end
    local ok, pets = pcall(PlayerData.Get, "Pets")
    if not ok or type(pets) ~= "table" then return nil end
    local plot = game_folder("Plots") and game_folder("Plots"):FindFirstChild(tostring(me:GetAttribute("Plot")))
    local slots = tonumber(plot and plot:GetAttribute("MaxAnimals")) or 16
    local list = {}
    for _, p in pairs(pets) do
        if type(p) == "table" and p.Name then table.insert(list, { rec = p, now = income_of(p) }) end
    end
    table.sort(list, function(a, b) return a.now > b.now end)
    local cut = list[slots] and list[slots].now or 0
    local groups = {}
    for _, x in ipairs(list) do
        local p = x.rec
        if p.Mutation == nil then
            local g = groups[p.Name] or { n = 0 }
            g.n += 1
            if not g.best or (tonumber(p.Weight) or 0) > (tonumber(g.best.Weight) or 0) then g.best = p end
            groups[p.Name] = g
        end
    end
    local mutate, collect, sell = {}, {}, {}
    for name, g in pairs(groups) do
        g.potential = income_of(g.best) * best_mult(name)
        if g.potential > cut then
            table.insert(g.n >= 3 and mutate or collect, { name = name, n = g.n, potential = g.potential })
        end
    end
    for i, x in ipairs(list) do
        local g = groups[x.rec.Name]
        local worth = x.rec.Mutation == nil and g and g.potential and g.potential > cut
        if i > slots and not worth then table.insert(sell, x) end
    end
    table.sort(mutate, function(a, b) return a.potential > b.potential end)
    table.sort(collect, function(a, b) return a.potential > b.potential end)
    local by_stage = {}
    for _, x in ipairs(list) do
        local st = x.rec.Stage
        if st then
            local s = by_stage[st] or { sum = 0, n = 0, top = 0 }
            s.sum += x.now
            s.n += 1
            s.top = math.max(s.top, x.now)
            by_stage[st] = s
        end
    end
    local best_stage, best_top = nil, -1
    for st, s in pairs(by_stage) do
        if s.top > best_top then best_stage, best_top = st, s.top end
    end
    return { list = list, slots = slots, cut = cut, mutate = mutate, collect = collect, sell = sell, best_stage = best_stage, best_top = best_top }
end

-- [[ Auto sell (OFF until you turn it on). A pet is only ever sold when ALL of these hold:                       ]] --
-- [[  * it's in your backpack, not on your plot (and not in your hand), and not locked / favourited             ]] --
-- [[  * your plot is full, so it really has no spot                                                             ]] --
-- [[  * it isn't one of your best (plot size + 10) pets                                                         ]] --
-- [[  * the advisor says it can't beat your weakest plot pet even after the best mutation                       ]] --
-- [[  * and: it earns 100x less than your weakest plot pet (the "way cheaper" rule, 20x / 100x / 1000x to pick),  ]] --
-- [[    OR it has sat unused for 24 hours and earns less than every pet on your plot                             ]] --
-- [[ Uses the game's own Sell (60s of the pet's income). Every sale is written to the log (SELL lines).          ]] --
do
    local SEEN_FILE = "MogHub_PetSeen.json"
    local DAY = 24 * 3600
    pcall(function()
        local rf, isf = exec("readfile"), exec("isfile")
        if typeof(rf) == "function" and typeof(isf) == "function" and isf(SEEN_FILE) then
            local t = HttpService:JSONDecode(rf(SEEN_FILE))
            if type(t) == "table" then S.pet_seen = t end
        end
    end)
    local function save_seen()
        local wf = exec("writefile")
        if typeof(wf) == "function" then pcall(function() wf(SEEN_FILE, HttpService:JSONEncode(S.pet_seen)) end) end
    end
    S.sell_plan = function()
        local report = pet_report()
        if not report then return {}, "couldn't read your pets" end
        local now = os.time()
        local placed, ids = 0, {}
        for _, x in ipairs(report.list) do
            local id = x.rec.Id
            if id then
                ids[tostring(id)] = true
                local seen = S.pet_seen[tostring(id)] or { first = now }
                if is_placed(x.rec) then
                    placed += 1
                    seen.placed = now
                end
                S.pet_seen[tostring(id)] = seen
            end
        end
        for id in pairs(S.pet_seen) do
            if not ids[id] then S.pet_seen[id] = nil end
        end
        save_seen()
        if placed < report.slots then
            return {}, ("your plot isn't full yet (%d/%d pets), so nothing is sold"):format(placed, report.slots)
        end
        if report.cut <= 0 then return {}, "couldn't tell what your weakest plot pet earns" end
        local keys = {}
        local bp = me:FindFirstChildOfClass("Backpack")
        for _, t in ipairs(bp and bp:GetChildren() or {}) do
            if t:IsA("Tool") and t:GetAttribute("ItemType") == "Pet" and type(t:GetAttribute("ItemKey")) == "string" then
                keys[tostring(t:GetAttribute("PetId"))] = t:GetAttribute("ItemKey")
            end
        end
        local rank = {}
        for i, x in ipairs(report.list) do rank[x] = i end
        local keep_top = report.slots + 10
        -- [[ a pet that will out-earn your weakest plot pet once both are Ancient is never sold ]] --
        local weakest_top = math.huge
        if S.ancient_of then
            for _, x in ipairs(report.list) do
                if is_placed(x.rec) then weakest_top = math.min(weakest_top, S.ancient_of(x.rec)) end
            end
        end
        local plan = {}
        local floor = S.keep_floor and S.keep_floor() or 0
        for _, x in ipairs(report.sell) do
            local r = x.rec
            local id = r.Id and tostring(r.Id)
            local seen = id and S.pet_seen[id]
            -- [[ never sold: your top pets, anything placed, locked or favourited, Titanic pets, a pet whose income ]] --
            -- [[ couldn't be read (0 or unknown), and one that could still make your plot once it's Ancient with   ]] --
            -- [[ the best mutation (the keep bar the farm uses on the ground)                                       ]] --
            local value = S.rec_value and S.rec_value(r) or nil
            local safe = (rank[x] or 0) <= keep_top or is_placed(r) or r.Locked == true or r.Favorite == true or r.Favorited == true
                or tostring(r.Tier or r.SizeTier or "") == "Titanic"
                or not (tonumber(x.now) and x.now > 0) or not (value and value > 0)
                or (S.ancient_of ~= nil and S.ancient_of(r) > weakest_top)
                or (floor > 0 and value > floor)
            local why = nil
            if not safe then
                if x.now * S.sell_ratio <= report.cut then
                    why = ("earns %sx less than your weakest plot pet"):format(short(report.cut / math.max(x.now, 1)))
                elseif S.sell_old and seen and now - (seen.first or now) >= DAY and now - (seen.placed or 0) >= DAY and x.now < report.cut then
                    why = "unused for 24h+ and worse than every pet on your plot"
                end
            end
            if why and id and keys[id] then
                table.insert(plan, { key = keys[id], id = r.Id, name = tostring(r.Name), mutation = r.Mutation, income = x.now, why = why })
            end
        end
        -- [[ Sell what can never make your plot: the same rule as pets on the ground. A backpack pet that couldn't  ]] --
        -- [[ beat your weakest plot pet even as an Ancient Diamond is sold. Kept anyway: anything on your plot or in ]] --
        -- [[ your hand, locked / favourited pets, and Titanic pets (the farm always takes those).                    ]] --
        if S.sell_floor and floor > 0 and S.rec_value then
            local listed = {}
            for _, p in ipairs(plan) do listed[tostring(p.id)] = true end
            for _, x in ipairs(report.list) do
                local r = x.rec
                local id = r.Id and tostring(r.Id)
                local value = S.rec_value(r)
                if id and keys[id] and not listed[id] and not is_placed(r) and not (r.Locked == true or r.Favorite == true or r.Favorited == true)
                    and tostring(r.Tier or r.SizeTier or "") ~= "Titanic" and value and value > 0 and value <= floor then
                    table.insert(plan, { key = keys[id], id = r.Id, name = tostring(r.Name), mutation = r.Mutation, income = x.now,
                        why = ("can't beat your weakest plot pet even as an Ancient Diamond ($%s/s vs $%s/s)"):format(short(value), short(floor)) })
                end
            end
        end
        return plan, ("plot full (%d pets), weakest plot pet earns $%s/s"):format(report.slots, short(report.cut))
    end
    S.sell_now = function(plan)
        local folder = Remotes:FindFirstChild("Backpack")
        local remote = folder and folder:FindFirstChild("Sell")
        if not (remote and remote:IsA("RemoteFunction")) or #plan == 0 then return 0 end
        local sold = 0
        for i = 1, #plan, 50 do
            local last = math.min(i + 49, #plan)
            local batch = {}
            for j = i, last do table.insert(batch, plan[j].key) end
            local ok, res = pcall(function() return remote:InvokeServer(batch) end)
            if ok and type(res) == "table" and res.Success then
                sold += #batch
                for j = i, last do
                    local x = plan[j]
                    logf("SELL", ("sold %s%s ($%s/s): %s"):format(x.mutation and (tostring(x.mutation) .. " ") or "", x.name, short(x.income), x.why))
                    hatch_note(x.id, "outcome", "sold by auto sell: " .. x.why)
                end
            else
                logf("SELL", "the server didn't sell that batch: " .. (ok and (type(res) == "table" and tostring(res.Reason) or tostring(res)) or tostring(res)))
                break
            end
            task.wait(1)
        end
        return sold
    end
    go(function()
        while S.alive do
            task.wait(300)
            if S.auto_sell then
                local ok, plan = pcall(S.sell_plan)
                if ok and type(plan) == "table" and #plan > 0 then
                    local n = S.sell_now(plan)
                    if n > 0 then notify(("Auto sell: sold %d pets you'll never use"):format(n)) end
                end
            end
        end
    end)
end

---------------------------------------------------------------- grow babies

-- [[ Pets earn more as they age (PetAgeConfig: Baby 1x, Kid 1.5x, Teen 2.25x, Adult 3.4x, Elder 5.1x, Ancient    ]] --
-- [[ 7.6x after 31h placed), but only while they're placed, and the game's Equip Best ranks by what they earn     ]] --
-- [[ now, so a baby never gets a spot on a full plot. With Grow babies on (and Equip best on), a full plot is      ]] --
-- [[ ranked by what each pet will earn as Ancient instead: the best one in your backpack takes the spot of your  ]] --
-- [[ weakest plot pet when, counting both pets' ages, it has earned more in total within your payback time.      ]] --
-- [[ The game wants you holding the pet and at most 45 studs away, so the swap is done in person: the weak one   ]] --
-- [[ is unequipped and the new one placed on the same spot (the weak one goes back if that fails). Favourited or ]] --
-- [[ locked plot pets are never taken off. With the farm off it only swaps when you're already near the spot.    ]] --
do
    local AgeConfig = load_module({ "Shared", "Configs", "PetAgeConfig" })
    local STAGES = AgeConfig and type(AgeConfig.Stages) == "table" and #AgeConfig.Stages > 0 and AgeConfig.Stages or nil
    local TOP = STAGES and tonumber(STAGES[#STAGES].Cash) or nil
    local place_remote = Remotes:FindFirstChild("Pets") and Remotes.Pets:FindFirstChild("Place")
    local CollectionService = game:GetService("CollectionService")
    local function stage_index(rec)
        local v = rec.AgeStage
        if type(v) == "number" and STAGES[v] then return v end
        if type(v) == "string" then
            for i, st in ipairs(STAGES) do
                if st.Name == v then return i end
            end
        end
        return 1 -- never placed yet: a baby
    end
    -- [[ seconds of growth so far: what was saved, plus the time placed since this server started counting ]] --
    local function age_now(rec)
        local age = tonumber(rec.AgeSeconds) or 0
        local since = tonumber(rec.AgingSince)
        if since and is_placed(rec) then age += math.max(0, workspace:GetServerTimeNow() - since) end
        return age
    end
    -- [[ what a pet will earn a second as Ancient: the game's income for it includes its age, so that's taken out ]] --
    local function ancient_income(rec)
        return income_of(rec) / (tonumber(STAGES[stage_index(rec)].Cash) or 1) * TOP
    end
    -- [[ what a placed pet earns over the next `secs`, starting `age` seconds into its growth ]] --
    local function earn(top, age, secs)
        local total, start, stop = 0, 0, age + secs
        for _, st in ipairs(STAGES) do
            local finish = st.Lasts and (start + st.Lasts) or math.huge
            local a, b = math.max(age, start), math.min(stop, finish)
            if b > a then total += (b - a) * top * (tonumber(st.Cash) or 1) / TOP end
            start = finish
            if start >= stop then break end
        end
        return total
    end
    -- [[ hours until the new pet has earned more than the one it replaces would have (nil: not within 2 weeks) ]] --
    local function payback(new, old)
        for h = 1, 24 * 14 do
            if earn(new.top, new.age, h * 3600) >= earn(old.top, old.age, h * 3600) then return h end
        end
        return nil
    end
    S.ancient_of = function(rec)
        if not (STAGES and TOP) then return income_of(rec) end
        return ancient_income(rec)
    end
    local function my_plot()
        local plots = game_folder("Plots")
        return plots and plots:FindFirstChild(tostring(me:GetAttribute("Plot")))
    end
    local function placed_model(id)
        local plot = my_plot()
        for _, m in ipairs(CollectionService:GetTagged("PlacedPet")) do
            if m:IsA("Model") and tostring(m:GetAttribute("PetId")) == tostring(id) and (not plot or m:IsDescendantOf(plot)) then return m end
        end
        local folder = plot and plot:FindFirstChild("PlacedAnimals", true)
        for _, m in ipairs(folder and folder:GetChildren() or {}) do
            if tostring(m:GetAttribute("PetId")) == tostring(id) then return m end
        end
        return nil
    end
    local function pet_tool(id)
        for _, holder in ipairs({ me:FindFirstChildOfClass("Backpack"), me.Character }) do
            for _, t in ipairs(holder and holder:GetChildren() or {}) do
                if t:IsA("Tool") and tostring(t:GetAttribute("PetId")) == tostring(id) then return t end
            end
        end
        return nil
    end
    -- [[ the game's own Place: the pet has to be in your hand ]] --
    local function place_pet(id, pos, yaw)
        local tool = pet_tool(id)
        local hum = me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        if not (tool and hum and place_remote) then return false, "the pet isn't in your backpack" end
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.35)
        local ok, res = pcall(function()
            return place_remote:InvokeServer({ Id = tool:GetAttribute("PetId"), Position = pos, Yaw = yaw })
        end)
        pcall(function() hum:UnequipTools() end)
        if ok and type(res) == "table" and res.Success then return true end
        return false, ok and (type(res) == "table" and tostring(res.Reason) or tostring(res)) or tostring(res)
    end
    local function describe(x)
        return ("%s%s (%s, $%s/s as Ancient)"):format(x.rec.Mutation and (tostring(x.rec.Mutation) .. " ") or "", tostring(x.rec.Name),
            tostring(STAGES[stage_index(x.rec)].Name), short(x.top))
    end
    local function swap(new, old, hours, can_move)
        if carrying() or busy() or down() then return false end
        local model = placed_model(old.rec.Id)
        if not model then
            S.grow_note = ("can't see %s on your plot yet (it loads when you're near your base)"):format(tostring(old.rec.Name))
            return false
        end
        local spot = model:GetPivot()
        if dist_to(spot.Position) > 35 then
            if not can_move then
                S.grow_note = ("go near your plot to swap in %s"):format(describe(new))
                return false
            end
            S.status = "Going to your plot to put a growing pet on it"
            travel(ground(spot.Position + Vector3.new(0, 0, 6)), spot.Position)
            if dist_to(spot.Position) > 40 then return false end
        end
        local _, yaw = spot:ToOrientation()
        local okU, resU = pcall(function() return unequip_remote:InvokeServer(old.rec.Id) end)
        if not okU or (type(resU) == "table" and resU.Success == false) then
            S.grow_fail[new.rec.Id] = os.clock() + 900
            logf("GROW", ("couldn't take %s off your plot: %s"):format(tostring(old.rec.Name),
                okU and tostring(type(resU) == "table" and resU.Reason or resU) or tostring(resU)))
            return false
        end
        local t = os.clock()
        repeat task.wait(0.05) until not model.Parent or os.clock() - t > 2
        local floor = floor_below(spot.Position)
        local pos = floor and floor.Position or spot.Position
        local ok, why = place_pet(new.rec.Id, pos, yaw)
        if ok then
            S.grow_swaps += 1
            S.grow_note = ("put %s on your plot"):format(describe(new))
            logf("GROW", ("put %s on your plot instead of %s: earns more in total after about %dh, then x%.2f for good"):format(
                describe(new), describe(old), hours, new.top / math.max(old.top, 1)))
            notify(("Growing %s: it out-earns %s once it's older."):format(tostring(new.rec.Name), tostring(old.rec.Name)))
            hatch_note(new.rec.Id, "outcome", "put on your plot by Grow babies, replacing " .. tostring(old.rec.Name))
            hatch_note(old.rec.Id, "outcome", "taken off your plot by Grow babies for " .. tostring(new.rec.Name))
            return true
        end
        S.grow_fail[new.rec.Id] = os.clock() + 900
        logf("GROW", ("couldn't place %s (%s), putting %s back"):format(tostring(new.rec.Name), tostring(why), tostring(old.rec.Name)))
        task.wait(0.4)
        if not place_pet(old.rec.Id, pos, yaw) and equip_remote then
            logf("GROW", "couldn't put it back on the same spot either, used the game's Equip Best")
            pcall(function() equip_remote:InvokeServer() end)
        end
        return false
    end
    -- [[ What a pet lying on the ground could be worth to you: its income without its age bonus, as Ancient, with ]] --
    -- [[ the best mutation it could still get (Diamond 6x; a Golden one can still become Diamond). It's the same    ]] --
    -- [[ yardstick as auto sell's "useless even if mutated", so the farm stops carrying home what gets deleted.     ]] --
    local MutCfg = load_module({ "Shared", "Configs", "MutationConfig" })
    local MUT, BEST_MUT = {}, 1
    for _, m in pairs(MutCfg and type(MutCfg.Mutations) == "table" and MutCfg.Mutations or {}) do
        if type(m) == "table" and type(m.Name) == "string" then
            MUT[m.Name] = tonumber(m.CashMult) or 1
            BEST_MUT = math.max(BEST_MUT, MUT[m.Name])
        end
    end
    S.value_of_income = function(income, mutation, age)
        if not (tonumber(income) and STAGES and TOP) then return nil end
        local cash = tonumber(STAGES[stage_index({ AgeStage = age })].Cash) or 1
        return tonumber(income) / cash * TOP * BEST_MUT / (MUT[tostring(mutation)] or 1)
    end
    S.loot_value = function(m)
        return S.value_of_income(m:GetAttribute("IncomePerSecond"), m:GetAttribute("Mutation"), m:GetAttribute("Age"))
    end
    S.rec_value = function(rec) return S.value_of_income(income_of(rec), rec.Mutation, rec.AgeStage) end
    -- [[ a pet's age from its growth seconds: "Elder, Ancient in 6h 12m" (name_only: just "Elder") ]] --
    S.age_info = function(rec, name_only)
        if not STAGES then return "?" end
        local age, start = age_now(rec), 0
        for i, st in ipairs(STAGES) do
            local finish = st.Lasts and (start + st.Lasts) or math.huge
            if age < finish then
                if name_only or finish == math.huge then return tostring(st.Name) end
                local left = finish - age
                local t = left >= 3600 and ("%dh %dm"):format(left // 3600, (left % 3600) // 60) or ("%dm"):format(math.max(1, left // 60))
                return ("%s, %s in %s"):format(tostring(st.Name), tostring(STAGES[i + 1] and STAGES[i + 1].Name or "?"), t)
            end
            start = finish
        end
        return tostring(STAGES[#STAGES].Name)
    end
    -- [[ the bar a pet has to clear: your weakest plot pet as Ancient. 0 while your plot isn't full (take everything) ]] --
    local floor_v, floor_t = 0, -100
    S.keep_floor = function()
        if os.clock() - floor_t < 15 then return floor_v end
        floor_t, floor_v = os.clock(), 0
        if not (PlayerData and STAGES and TOP) then return 0 end
        local okP, pets = pcall(PlayerData.Get, "Pets")
        local plot = my_plot()
        local slots = tonumber(plot and plot:GetAttribute("MaxAnimals"))
        if not (okP and type(pets) == "table" and slots) then return 0 end
        local n, low = 0, math.huge
        for _, rec in pairs(pets) do
            if type(rec) == "table" and is_placed(rec) then
                n += 1
                low = math.min(low, ancient_income(rec))
            end
        end
        if n >= slots and low < math.huge then floor_v = low end
        return floor_v
    end
    -- [[ boost windows: Golden / Diamond weather (3x that mutation, 5 minutes every 45) and admin Luck / Mutation ]] --
    -- [[ boosts (2-10x, every server). Every egg mogged then is worth more, so no treadmill or hopping meanwhile.  ]] --
    local EventUtil = load_module({ "Shared", "Utilities", "EventUtil" })
    local AdminBoostUtil = load_module({ "Shared", "Utilities", "AdminBoostUtil" })
    local boost_v, boost_t, boost_last = nil, -100, nil
    S.boost_now = function()
        if os.clock() - boost_t < 2 then return boost_v end
        boost_t = os.clock()
        local text = nil
        if EventUtil and type(EventUtil.Get) == "function" then
            local ok, _, def, state = pcall(EventUtil.Get)
            if ok and state == "Active" and type(def) == "table" and def.Mutation then
                text = ("%s (%sx %s chance)"):format(tostring(def.Name or "Weather"), tostring(def.HatchBoost or "?"), tostring(def.Mutation))
            end
        end
        if not text and AdminBoostUtil and type(AdminBoostUtil.Get) == "function" then
            for _, kind in ipairs({ "Luck", "Mutation" }) do
                local ok, mult, left = pcall(AdminBoostUtil.Get, kind)
                if ok and (tonumber(mult) or 1) > 1 and (tonumber(left) or 0) > 0 then
                    text = ("admin %s boost x%s"):format(kind, tostring(mult))
                    break
                end
            end
        end
        if text ~= boost_last then
            if text then
                logf("BOOST", text .. ": mogging all out (no treadmill, no hopping) while it lasts")
                notify("Boost on: " .. text .. ". Mogging all out.")
            elseif boost_last then
                logf("BOOST", boost_last .. " is over")
            end
            boost_last = text
        end
        boost_v = text
        return text
    end
    -- [[ eggs worth mogging: with Leave worthless on and a full plot, only the highest stage's eggs can hatch a pet ]] --
    -- [[ for your plot (each stage down earns about 10x less), so lower-stage eggs, and Titanic eggs down there,    ]] --
    -- [[ are skipped. Eggs the game doesn't normally have (admin / new events) are always taken: unknown pets.      ]] --
    local top_stage, top_t = nil, -100
    -- [[ the highest stage in the map (new stages count by themselves) ]] --
    S.top_stage = function()
        if os.clock() - top_t > 10 then
            top_t, top_stage = os.clock(), nil
            local best_n = -1
            local folder = game_folder("Stages")
            for _, f in ipairs(folder and folder:GetChildren() or {}) do
                if f.Name:match("^Stage%d+$") and stage_num(f.Name) > best_n then top_stage, best_n = f.Name, stage_num(f.Name) end
            end
            top_stage = top_stage or STAGE_NAMES[#STAGE_NAMES]
        end
        return top_stage
    end
    S.only_stage = function()
        if not (S.skip_junk and not S.gift and S.keep_floor() > 0) then return nil end
        return S.top_stage()
    end
    S.egg_ok = function(egg)
        local only = S.only_stage()
        if not only or is_special(egg) then return true end
        return (stage_of(egg) or tostring(egg:GetAttribute("Stage"))) == only
    end
    -- [[ returns true when your plot is full (so the game's Equip Best isn't used) ]] --
    S.grow_step = function()
        if not (S.grow_babies and STAGES and TOP and PlayerData and place_remote and unequip_remote) then return false end
        if os.clock() - S.last_grow < 20 and not S.need_equip then return S.grow_full end
        S.last_grow = os.clock()
        local okP, pets = pcall(PlayerData.Get, "Pets")
        local plot = my_plot()
        local slots = tonumber(plot and plot:GetAttribute("MaxAnimals"))
        if not (okP and type(pets) == "table" and slots) then return false end
        local placed, waiting, placed_n = {}, {}, 0
        for _, rec in pairs(pets) do
            if type(rec) == "table" and rec.Id and rec.Name then
                local x = { rec = rec, top = ancient_income(rec), age = age_now(rec) }
                if is_placed(rec) then
                    placed_n += 1
                    if not (rec.Locked == true or rec.Favorite == true or rec.Favorited == true) then table.insert(placed, x) end
                elseif os.clock() >= (S.grow_fail[rec.Id] or 0) then
                    table.insert(waiting, x)
                end
            end
        end
        S.grow_full = placed_n >= slots
        if not S.grow_full then
            S.grow_note = ("room on your plot (%d/%d), the game's Equip Best fills it"):format(placed_n, slots)
            return false
        end
        S.need_equip = false
        if #placed == 0 or #waiting == 0 then
            S.grow_note = "nothing in your backpack to grow"
            return true
        end
        table.sort(placed, function(a, b) return a.top < b.top end)
        table.sort(waiting, function(a, b) return a.top > b.top end)
        local old, pick, hours = placed[1], nil, nil
        for i = 1, math.min(10, #waiting) do
            local cand = waiting[i]
            if cand.top <= old.top then break end
            local h = payback(cand, old)
            if h and h <= S.grow_hours then
                pick, hours = cand, h
                break
            end
        end
        if not pick then
            local best = waiting[1]
            S.grow_note = best.top > old.top
                and ("best in your backpack: %s, but it takes over %dh to beat %s"):format(describe(best), S.grow_hours, tostring(old.rec.Name))
                or ("your plot has your best growers (weakest: %s)"):format(describe(old))
            return true
        end
        swap(pick, old, hours, S.farm and coroutine.running() == S.farm_thread)
        return true
    end
end

---------------------------------------------------------------- the game's menus and the admin bar

local UIController = load_module({ "UI", "Controller" })
local AdminUtil = load_module({ "Shared", "Utilities", "AdminUtil" })
local getupvalues = exec("getupvalues")
local function menu_names()
    local names = {}
    if UIController and typeof(getupvalues) == "function" then
        pcall(function()
            for _, f in ipairs({ UIController.Show, UIController.Register, UIController.Toggle }) do
                for _, v in pairs(getupvalues(f)) do
                    if type(v) == "table" then
                        for k, e in pairs(v) do
                            if type(k) == "string" and type(e) == "table" and typeof(rawget(e, "UI")) == "Instance" then names[k] = e end
                        end
                    end
                end
            end
        end)
    end
    if next(names) == nil then
        local frames = me:FindFirstChild("PlayerGui") and me.PlayerGui:FindFirstChild("Frames")
        for _, c in ipairs(frames and frames:GetChildren() or {}) do
            if c:IsA("GuiObject") then names[c.Name] = { UI = c } end
        end
    end
    local list = {}
    for n, e in pairs(names) do
        table.insert(list, n)
        S.menu_entries[n] = e
    end
    table.sort(list)
    return list
end
-- [[ the menu's own window: what the game registered for it, or a frame with its name ]] --
local function menu_parts(name)
    local parts = {}
    local e = S.menu_entries[name]
    if type(e) == "table" then
        for _, key in ipairs({ "UI", "Box" }) do
            local inst = rawget(e, key)
            if typeof(inst) == "Instance" then table.insert(parts, inst) end
        end
    end
    local pg = me:FindFirstChild("PlayerGui")
    local found = pg and pg:FindFirstChild(name, true)
    if found and (found:IsA("GuiObject") or found:IsA("ScreenGui")) then table.insert(parts, found) end
    return parts
end
local function menu_is_open(name)
    if UIController then
        local ok, yes = pcall(UIController.IsVisible, name)
        if ok and yes == true then return true end
    end
    for _, inst in ipairs(menu_parts(name)) do
        if inst:IsA("GuiObject") and inst.Visible then
            local sg = inst:FindFirstAncestorOfClass("ScreenGui")
            if not sg or sg.Enabled then return true end
        elseif inst:IsA("ScreenGui") and inst.Name == name and inst.Enabled then
            return true
        end
    end
    return false
end
local function open_menu(name)
    if UIController and pcall(UIController.Show, name) then return end
    local pg = me:FindFirstChild("PlayerGui")
    local frame = pg and pg:FindFirstChild(name, true)
    if frame and frame:IsA("GuiObject") then
        frame.Visible = true
        local sg = frame:FindFirstAncestorOfClass("ScreenGui")
        if sg then sg.Enabled = true end
    end
end
-- [[ closes a menu: first the game's own way, then forced (hidden on your screen) for ones that won't close ]] --
local function close_menu(name)
    if UIController then pcall(UIController.Hide, name) end
    for _, inst in ipairs(menu_parts(name)) do
        if inst:IsA("GuiObject") then
            inst.Visible = false
        elseif inst:IsA("ScreenGui") and inst.Name == name then
            inst.Enabled = false
        end
    end
    logf("MENU", "closed " .. name)
end
local function is_admin()
    if not AdminUtil then return nil end
    local ok, yes = pcall(AdminUtil.IsAdmin, me)
    return ok and yes == true
end
local admin_bar = nil
local function open_admin_bar()
    if admin_bar then pcall(function() admin_bar:Toggle() end) return end
    local admin_module = Controllers:FindFirstChild("AdminController")
    local bar_module = admin_module and admin_module:FindFirstChild("CommandBar")
    local okB, CommandBar = false, nil
    if bar_module then okB, CommandBar = pcall(require, bar_module) end
    local AdminConfig = load_module({ "Shared", "Configs", "AdminConfig" })
    local run_remote = Remotes:FindFirstChild("Commands") and Remotes.Commands:FindFirstChild("Run")
    if not (okB and type(CommandBar) == "table" and AdminConfig and run_remote) then notify("Couldn't build the admin bar.") return end
    local ok, bar = pcall(CommandBar.new, AdminConfig.Bar)
    if not ok or not bar then notify("Couldn't build the admin bar.") return end
    admin_bar = bar
    pcall(function()
        bar.Submitted:Connect(function(text)
            local ok2, res = pcall(function() return run_remote:InvokeServer(text) end)
            local good = ok2 and type(res) == "table"
            pcall(function() bar:Log(good and tostring(res.Message) or "Request failed", good and res.Success and "Success" or "Error") end)
        end)
    end)
    pcall(function() bar:Log("Commands go to the server, and the server checks if you're an admin.", "Info") end)
    pcall(function() bar:Toggle() end)
end

---------------------------------------------------------------- what's going on (for the log)

local function at(pos) return pos and ("%d, %d, %d"):format(pos.X, pos.Y, pos.Z) or "?" end
-- [[ every reason you could be standing still, checked right now ]] --
local function why_here()
    local char = me.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = root_part()
    local reasons = {}
    local function add(x) table.insert(reasons, x) end
    if not S.farm then add("farm is OFF" .. (S.farm_off_by and (" (" .. S.farm_off_by .. ")") or "")) end
    if S.manual then add("busy with a manual steal or teleport") end
    if not (char and hum) then add("no character (dead or respawning)") elseif hum.Health <= 0 then add("you're dead") end
    if root and root.Anchored then add("your character is anchored (held in place)") end
    if hum and hum.PlatformStand then add("PlatformStand is on (ragdoll or knockback)") end
    if char and char:GetAttribute("Ragdolled") then add("ragdolled") end
    if on_treadmill() then
        add(S.treadmill and "on the treadmill (Auto treadmill)" or "on the treadmill while Auto treadmill is OFF: it's holding you")
    end
    if busy() then add("in a mog (the game says busy)") end
    if carrying() then add("carrying a pet") end
    if root and root.Position.Y < -60 then add("below the map") end
    if #S.hatching > 0 then add(#S.hatching .. " egg(s) hatching") end
    if #S.pending > 0 then add(#S.pending .. " pet(s) waiting to be taken") end
    if S.event_hatch then add("waiting for an event egg to hatch") end
    local age = math.floor(os.clock() - (S.loop_tick or os.clock()))
    if age > 20 then add(("farm loop hasn't ticked for %ds"):format(age)) end
    local ok, free = pcall(function() return #free_eggs() end)
    add((ok and tostring(free) or "?") .. " free eggs loaded in your stages")
    return ("status \"%s\" | %s | at %s"):format(S.status, table.concat(reasons, "; "), at(root and root.Position))
end
local function log_report()
    local lines = {
        "Mog Hub log",
        ("saved %s | session %d min | server %s"):format(os.date("%Y-%m-%d %H:%M:%S"), math.floor((os.clock() - S.session_start) / 60), game.JobId:sub(1, 8)),
        ("farm %s | treadmill %s | gift %s (under $" .. short(S.gift_min) .. "/s) | stages %s | pick %s | travel %s | skip fights %s | anti ragdoll %s"):format(
            tostring(S.farm), tostring(S.treadmill), tostring(S.gift), stages_text(), S.pick, S.travel, tostring(S.skip_fight), tostring(S.anti_ragdoll)),
        ("banked %d | gifted %d | mutated %d | appeal %s"):format(S.delivered, S.gifted_count, S.mutated, short(power())),
        "now: " .. why_here(),
        "",
        "---- events ----",
    }
    for _, l in ipairs(S.log) do table.insert(lines, l) end
    table.insert(lines, "")
    table.insert(lines, "---- recent statuses ----")
    for i = math.max(1, #S.status_log - 200), #S.status_log do table.insert(lines, S.status_log[i]) end
    return table.concat(lines, "\n")
end
local writefile, setclipboard = exec("writefile"), exec("setclipboard")
local function save_log()
    if typeof(writefile) ~= "function" then return false end
    S.log_dirty = false
    return pcall(function() writefile("MogHub_Log.txt", log_report()) end)
end
-- [[ the hatch book as text: every pet with everything the game told us about it (unknown fields included) ]] --
local function pet_line(p)
    local known = { Name = true, Rarity = true, Weight = true, Luck = true, Size = true, Mutation = true, Stage = true, Zone = true,
        Id = true, HatchedAt = true, Titanic = true }
    local others = {}
    for k, v in pairs(p) do
        if not known[k] then table.insert(others, tostring(k) .. "=" .. tostring(v)) end
    end
    table.sort(others)
    return ("%s | %s | %skg | luck %s | size %s | %s | %s%s"):format(tostring(p.Name), tostring(p.Rarity), short(p.Weight), tostring(p.Luck),
        tostring(p.Size), p.Mutation and tostring(p.Mutation) or "no mutation", tostring(p.Stage or p.Zone or "?"),
        #others > 0 and (" | " .. table.concat(others, ", ")) or "")
end
local function hatched_report()
    local lines = { "Mog Hub hatched pets", ("saved %s | hatched this session: %d"):format(os.date("%Y-%m-%d %H:%M:%S"), #S.hatched), "",
        "---- hatched this session: time | how | name | rarity | weight | luck | size | mutation | stage | income | what happened"
            .. " | egg it came from | where it is now | why (best it could earn as Ancient + best mutation vs your weakest plot pet) ----" }
    local owned = {}
    pcall(function()
        for _, rec in pairs(PlayerData and PlayerData.Get("Pets") or {}) do
            if type(rec) == "table" and rec.Id then owned[rec.Id] = rec end
        end
    end)
    local floor = S.keep_floor and S.keep_floor() or 0
    local by_rarity, buckets = {}, {}
    for _, r in ipairs(S.hatched) do
        local rec = r.pet.Id and owned[r.pet.Id]
        local now = rec and (is_placed(rec) and "ON YOUR PLOT" or "in your backpack") or "not yours anymore"
        local value = rec and S.rec_value and S.rec_value(rec) or (S.value_of_income and S.value_of_income(r.income, r.pet.Mutation, 1))
        local why = value and ("best $%s/s vs $%s/s"):format(short(value), short(floor)) or "?"
        local egg = r.egg and ("%s %s size %.3f, %s appeal, %sx luck"):format(tostring(r.egg.name), tostring(r.egg.stage), tonumber(r.egg.scale) or 0,
            r.egg_ap and short(r.egg_ap) or "?", r.egg.luck and ("%.1f"):format(r.egg.luck) or "?") or "-"
        table.insert(lines, ("%s | %s | %s | %s | %s | egg: %s | now: %s | why: %s"):format(r.time, r.how, pet_line(r.pet),
            r.income and ("$" .. short(r.income) .. "/s") or "income ?", r.outcome, egg, now, why))
        local k = tostring(r.pet.Rarity)
        by_rarity[k] = (by_rarity[k] or 0) + 1
        -- [[ egg size groups, to see whether bigger eggs give better or bigger pets ]] --
        local sc = r.egg and tonumber(r.egg.scale)
        if sc then
            local label = sc < 0.6 and "0.50-0.60" or sc < 0.7 and "0.60-0.70" or sc < 0.8 and "0.70-0.80" or sc < 0.9 and "0.80-0.90" or "0.90+"
            local b = buckets[label] or { n = 0, rar = {}, size = 0, kept = 0 }
            b.n += 1
            b.rar[k] = (b.rar[k] or 0) + 1
            b.size += tonumber(r.pet.Size) or 0
            if rec and value and value > floor then b.kept += 1 end
            buckets[label] = b
        end
    end
    if next(buckets) then
        table.insert(lines, "")
        table.insert(lines, "---- egg size vs pet (this session): eggs | pets by rarity | average pet size | worth keeping ----")
        for _, label in ipairs({ "0.50-0.60", "0.60-0.70", "0.70-0.80", "0.80-0.90", "0.90+" }) do
            local b = buckets[label]
            if b then
                local rar = {}
                for name, n in pairs(b.rar) do table.insert(rar, name .. " " .. n) end
                table.sort(rar)
                table.insert(lines, ("egg size %s | %d eggs | %s | avg pet size %.2f | %d worth keeping"):format(label, b.n, table.concat(rar, ", "),
                    b.size / b.n, b.kept))
            end
        end
        table.insert(lines, "")
    end
    local counts = {}
    for k, n in pairs(by_rarity) do table.insert(counts, k .. " " .. n) end
    table.sort(counts)
    table.insert(lines, "by rarity: " .. (#counts > 0 and table.concat(counts, ", ") or "none yet"))
    table.insert(lines, "")
    table.insert(lines, "---- every pet you own right now, best income first ----")
    local ok, pets = pcall(function() return PlayerData and PlayerData.Get("Pets") end)
    if ok and type(pets) == "table" then
        local list = {}
        for _, p in pairs(pets) do
            if type(p) == "table" then table.insert(list, { p = p, income = income_of(p) }) end
        end
        table.sort(list, function(a, b) return a.income > b.income end)
        for i, x in ipairs(list) do table.insert(lines, ("%d. %s | $%s/s"):format(i, pet_line(x.p), short(x.income))) end
    else
        table.insert(lines, "(couldn't read your pets)")
    end
    return table.concat(lines, "\n")
end
-- [[ (an empty session, like a fresh server after a hop, doesn't overwrite the book; every hatch is also kept for ]] --
-- [[ good in MogHub_EggBook.csv)                                                                                  ]] --
local function save_hatched()
    if typeof(writefile) ~= "function" or #S.hatched == 0 then return false end
    S.hatch_dirty = false
    return pcall(function() writefile(S.hatch_file, hatched_report()) end)
end
-- [[ the stuck check: farm ON but you haven't moved 3 studs in 45 seconds -> write down every reason ]] --
go(function()
    local last_pos, still_since, reported = nil, nil, false
    while S.alive do
        task.wait(5)
        local root = root_part()
        local pos = root and root.Position
        -- [[ (standing still on the treadmill is training, not being stuck) ]] --
        if S.farm and pos and not on_treadmill() then
            if last_pos and (pos - last_pos).Magnitude < 3 then
                still_since = still_since or os.clock()
            else
                still_since, reported = nil, false
            end
            if still_since and not reported and os.clock() - still_since > 45 then
                reported = true
                logf("STUCK", ("haven't moved for %ds: %s"):format(math.floor(os.clock() - still_since), why_here()))
            end
        else
            still_since, reported = nil, false
        end
        last_pos = pos
    end
end)
-- [[ saved to the executor's workspace folder every minute, so it survives a crash or a disconnect ]] --
go(function()
    while S.alive do
        task.wait(60)
        if S.log_dirty then save_log() end
        if S.hatch_dirty then save_hatched() end
    end
end)
-- [[ Auto reconnect (Mog to Steal an Egg only): once you're really disconnected, it tries every 4 seconds until ]] --
-- [[ you're back, and the helper loads itself again there from mog_helper.lua in the executor's workspace       ]] --
-- [[ folder; your saved settings turn the farm back on. The farm pauses while you're out. Each try:              ]] --
-- [[  * presses Roblox's own Reconnect button: the only way back into a private server (a script can't join one  ]] --
-- [[    by its server id). It switches between firing the button's click and a real mouse click on it.           ]] --
-- [[  * on a public server, every 3rd try teleports you to the same server directly instead                      ]] --
-- [[  * same server gone or full, or still out after 10 minutes: any server of the game                          ]] --
-- [[ Other teleports in this game (its own idle rejoin, Roblox's Reconnect button) take the helper along too.    ]] --
do
    local MOG_PLACE, SELF_FILE = 77922212238973, "mog_helper.lua"
    local TeleportService = game:GetService("TeleportService")
    local GuiService: any = game:GetService("GuiService")
    local queue_tp = exec("queue_on_teleport") or exec("queueonteleport")
    local clear_tp = exec("clear_teleport_queue") or exec("clearqueueonteleport")
    local queue_warned = false -- (the reconnect loop asks every 4s: the reason is logged once)
    local function queue_self()
        if env.mog_helper_queued then return end
        if typeof(queue_tp) ~= "function" then
            if not queue_warned then logf("RECONNECT", "this executor has no queue_on_teleport, so the helper can't load itself after the rejoin") end
            queue_warned = true
            return
        end
        local isf = exec("isfile")
        if typeof(isf) == "function" and not isf(SELF_FILE) then
            if not queue_warned then
                logf("RECONNECT", SELF_FILE .. " isn't in the executor's workspace folder, so the helper can't load itself after the rejoin")
            end
            queue_warned = true
            return
        end
        local loader = ([[
if game.PlaceId ~= %d then return end
if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() ((getgenv and getgenv()) or _G).sobriety_quick_boot = true end)
local ok, src = pcall(readfile, %q)
local fn = ok and type(src) == "string" and loadstring(src)
if fn then task.spawn(fn) end
]]):format(MOG_PLACE, SELF_FILE)
        env.mog_helper_queued = pcall(queue_tp, loader)
    end
    S.queue_self = queue_self
    S.clear_queue = function()
        if env.mog_helper_queued and typeof(clear_tp) == "function" then pcall(clear_tp) end
        env.mog_helper_queued = nil
    end
    local ANY_AFTER = 600
    local job, private, gone = game.JobId, false, false
    pcall(function() private = game.PrivateServerId ~= "" end)
    local okV, vim = pcall(game.GetService, game, "VirtualInputManager")
    -- [[ the game's link to the server: gone once you're disconnected or kicked ]] --
    local function still_connected()
        local ok, yes = pcall(function()
            local nc = game:FindService("NetworkClient")
            return nc ~= nil and nc:FindFirstChildOfClass("ClientReplicator") ~= nil
        end)
        return ok and yes == true
    end
    local function reconnect_button()
        local root = CoreGui:FindFirstChild("RobloxPromptGui")
        local overlay = root and root:FindFirstChild("promptOverlay")
        local prompt = overlay and overlay:FindFirstChild("ErrorPrompt")
        for _, d in ipairs(prompt and prompt:GetDescendants() or {}) do
            if d:IsA("GuiButton") and d.Visible then
                local text = d.Name
                if d:IsA("TextButton") then text ..= " " .. d.Text end
                for _, l in ipairs(d:GetDescendants()) do
                    if l:IsA("TextLabel") then text ..= " " .. l.Text end
                end
                text = text:lower()
                if text:find("reconnect") or text:find("retry") then return d end
            end
        end
        return nil
    end
    local presses = 0
    local function press(btn)
        presses += 1
        if presses % 2 == 1 and typeof(getconnections) == "function" then
            local fired = false
            for _, signal in ipairs({ btn.Activated, btn.MouseButton1Click }) do
                local ok, list = pcall(getconnections, signal)
                for _, c in ipairs(ok and type(list) == "table" and list or {}) do
                    if pcall(function() c:Fire() end) then fired = true end
                end
            end
            if fired then return "pressed Reconnect (fired its click)" end
        end
        if not okV then return "couldn't press Reconnect (no VirtualInputManager)" end
        local sg = btn:FindFirstAncestorOfClass("ScreenGui")
        local inset = (sg and sg.IgnoreGuiInset) and Vector2.zero or GuiService:GetGuiInset()
        local spot = btn.AbsolutePosition + btn.AbsoluteSize / 2 + inset
        pcall(function()
            vim:SendMouseButtonEvent(spot.X, spot.Y, 0, true, game, 1)
            task.wait(0.05)
            vim:SendMouseButtonEvent(spot.X, spot.Y, 0, false, game, 1)
        end)
        return "pressed Reconnect (mouse click)"
    end
    local function rejoin(why)
        if game.PlaceId ~= MOG_PLACE or S.rejoining or S.no_rejoin or not (S.alive and S.auto_reconnect) then return end
        -- [[ kicked because this account joined somewhere else: rejoining would just kick that one ]] --
        if tostring(why):lower():find("different device") then
            S.no_rejoin = true
            logf("RECONNECT", "this account joined from another device, not rejoining")
            return
        end
        S.rejoining = true
        go(function()
            task.wait(2)
            -- [[ some error boxes (a failed teleport) show while you're still in the server: nothing to do then ]] --
            if still_connected() then
                logf("RECONNECT", "error box but you're still connected, not rejoining: " .. tostring(why))
                S.rejoining = false
                return
            end
            logf("RECONNECT", ("disconnected from this %s server, reconnecting every 4s"):format(private and "private" or "public"))
            pcall(save_log)
            pcall(save_hatched)
            -- [[ the new session writes its own MogHub_Log.txt, so this one is kept under its own name ]] --
            if typeof(writefile) == "function" then
                pcall(writefile, ("MogHub_Log_%s.txt"):format(os.date("%Y%m%d_%H%M")), log_report())
            end
            local tries, started, last_how = 0, os.clock(), ""
            while S.alive and S.auto_reconnect do
                tries += 1
                queue_self()
                local btn = reconnect_button()
                local late = os.clock() - started > ANY_AFTER
                local how
                if gone then
                    pcall(function() TeleportService:Teleport(MOG_PLACE, me) end)
                    how = "teleport to any server (your server is gone or full)"
                elseif btn and ((private and not (late and tries % 3 == 0)) or (not private and tries % 3 ~= 0)) then
                    how = press(btn)
                elseif not private and job ~= "" and not late then
                    pcall(function() TeleportService:TeleportToPlaceInstance(MOG_PLACE, job, me) end)
                    how = "teleport to the same server"
                elseif late then
                    pcall(function() TeleportService:Teleport(MOG_PLACE, me) end)
                    how = "teleport to any server (still out after 10 minutes)"
                else
                    how = "waiting for Roblox's Reconnect button (private server: any server after 10 minutes)"
                end
                -- [[ logged when the kind of try changes (button / same server / any server), not on every click ]] --
                local kind = how:find("same server") and "same" or how:find("teleport") and "any" or how:find("waiting") and "wait" or "button"
                if tries <= 3 or tries % 15 == 0 or kind ~= last_how then
                    logf("RECONNECT", ("try %d: %s"):format(tries, how))
                    pcall(save_log)
                end
                last_how = kind
                task.wait(4)
            end
            S.rejoining = false
        end)
    end
    local last_msg = ""
    pcall(function()
        track(GuiService.ErrorMessageChanged:Connect(function(message)
            if not S.alive or message == "" then return end
            if message ~= last_msg then
                last_msg = message
                logf("DISCONNECT", message)
                save_log()
                save_hatched()
            end
            rejoin(message)
        end))
    end)
    -- [[ backup trigger: Roblox's error box itself ]] --
    go(function()
        pcall(function()
            local overlay = CoreGui:WaitForChild("RobloxPromptGui", 30):WaitForChild("promptOverlay", 30)
            track(overlay.ChildAdded:Connect(function(c)
                if c.Name ~= "ErrorPrompt" then return end
                task.delay(1, function()
                    local ok, msg = pcall(function() return GuiService:GetErrorMessage() end)
                    rejoin(ok and msg ~= "" and msg or "error box shown")
                end)
            end))
        end)
    end)
    local last_fail = ""
    pcall(function()
        track(TeleportService.TeleportInitFailed:Connect(function(player, result, message)
            if player ~= me or not S.rejoining then return end
            local text = ("%s %s"):format(tostring(result), tostring(message))
            if text ~= last_fail then
                last_fail = text
                logf("RECONNECT", "rejoin failed: " .. text)
            end
            if result == Enum.TeleportResult.Unauthorized then
                private = true -- "can't join private instance through specific joins"
            elseif result == Enum.TeleportResult.GameEnded or result == Enum.TeleportResult.GameFull then
                gone = true
            end
        end))
    end)
    if game.PlaceId == MOG_PLACE then
        track(me.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.Started and S.alive and S.auto_reconnect then queue_self() end
        end))
    end
end

---------------------------------------------------------------- biggest egg record and server hop

-- [[ Record: every normal egg the farm wins in the last stage (the highest stage in the map, so new stages count  ]] --
-- [[ by themselves) is measured by its size (EggScale). The biggest is kept in MogHub_EggRecord.json, so it     ]] --
-- [[ survives hops and restarts (Reset record starts over).                                                     ]] --
-- [[ Server hop (Mog to Steal an Egg only, public servers only: a script can't join a private server):          ]] --
-- [[  * Find a bigger egg: joins servers (fewest players first, none twice within an hour), looks at the eggs in ]] --
-- [[    the last stage, and moves on unless one is bigger than your record (and inside your size range). That   ]] --
-- [[    one is mogged and its pet banked, the record goes up, and it hops on for an even bigger one.            ]] --
-- [[ Hopping stays on (across hops and restarts) until you turn it off.                                         ]] --
-- [[  * Grab one every server: takes each server's biggest last-stage egg, banks its pet, then hops on.         ]] --
-- [[ Pets still hatching or on the ground are banked before leaving. Each hop loads the helper again in the new ]] --
-- [[ server; every server it checks is written to MogHub_HopLog.txt (MogHub_Log.txt starts over each server).  ]] --
-- [[ (inside its own function: one function may only hold 200 locals, and the helper is close to that)         ]] --
;(function()
    local MOG_PLACE, RECORD_FILE, HOP_FILE, HOP_LOG = 77922212238973, "MogHub_EggRecord.json", "MogHub_Hop.json", "MogHub_HopLog.txt"
    local TeleportService = game:GetService("TeleportService")
    local read_f, write_f, is_f, append_f = exec("readfile"), exec("writefile"), exec("isfile"), exec("appendfile")
    local function load_json(name)
        local ok, t = pcall(function()
            if typeof(is_f) == "function" and typeof(read_f) == "function" and is_f(name) then return HttpService:JSONDecode(read_f(name)) end
            return nil
        end)
        return ok and type(t) == "table" and t or {}
    end
    local function save_json(name, t)
        if typeof(write_f) == "function" then pcall(function() write_f(name, HttpService:JSONEncode(t)) end) end
    end
    -- [[ the hop log keeps its newest half once it passes about 1 MB (checked once per server) ]] --
    pcall(function()
        if typeof(is_f) == "function" and typeof(read_f) == "function" and typeof(write_f) == "function" and is_f(HOP_LOG) then
            local old = read_f(HOP_LOG)
            if #old > 1000000 then
                local cut = old:find("\n", #old - 500000, true)
                write_f(HOP_LOG, cut and old:sub(cut + 1) or "")
            end
        end
    end)
    local function hop_log(text)
        local line = ("[%s] %s\n"):format(os.date("%Y-%m-%d %H:%M:%S"), text)
        local ok = typeof(append_f) == "function" and typeof(is_f) == "function" and is_f(HOP_LOG) and pcall(append_f, HOP_LOG, line)
        if not ok and typeof(write_f) == "function" then
            local old = ""
            pcall(function() if typeof(is_f) == "function" and is_f(HOP_LOG) then old = read_f(HOP_LOG) end end)
            pcall(write_f, HOP_LOG, old .. line)
        end
    end
    -- [[ the highest stage in the map right now ]] --
    local function last_stage()
        local best, best_n = nil, -1
        local folder = game_folder("Stages")
        for _, f in ipairs(folder and folder:GetChildren() or {}) do
            if f.Name:match("^Stage%d+$") and stage_num(f.Name) > best_n then best, best_n = f.Name, stage_num(f.Name) end
        end
        return best or STAGE_NAMES[#STAGE_NAMES]
    end
    S.egg_record = load_json(RECORD_FILE)
    local hops = load_json(HOP_FILE)
    hops.visited = type(hops.visited) == "table" and hops.visited or {}
    hops.count = tonumber(hops.count) or 0
    if S.hop_mode ~= "Off" then
        hops.visited[game.JobId] = os.time()
        save_json(HOP_FILE, hops)
    end
    local function record_scale()
        local r = S.egg_record
        return r.stage == last_stage() and tonumber(r.scale) or 0
    end
    local function egg_text(x)
        return ("%s in %s, size %.3f (%s%s)"):format(tostring(x.name), tostring(x.stage), tonumber(x.scale) or 0, tostring(x.rarity),
            tonumber(x.luck) and (", %.1fx luck"):format(x.luck) or "")
    end
    S.note_grab = function(info)
        if not (info and info.scale) or info.event or info.stage ~= last_stage() or info.scale <= record_scale() then return end
        S.egg_record = { stage = info.stage, scale = info.scale, name = info.name, rarity = info.rarity, luck = info.luck,
            time = os.date("%Y-%m-%d %H:%M"), server = game.JobId:sub(1, 8) }
        save_json(RECORD_FILE, S.egg_record)
        logf("RECORD", "biggest egg so far: " .. egg_text(info))
        hop_log("NEW RECORD: " .. egg_text(info))
    end
    S.reset_record = function()
        S.egg_record = {}
        save_json(RECORD_FILE, S.egg_record)
        hop_log("record reset")
        logf("RECORD", "record reset")
    end
    S.record_text = function()
        local r = S.egg_record
        if not tonumber(r.scale) then return ("none yet (win an egg in %s)"):format(last_stage()) end
        return egg_text(r) .. (r.stage ~= last_stage() and ", an older stage: the next egg in " .. last_stage() .. " replaces it" or "")
    end
    S.hop_count = function() return hops.count end

    -- [[ the game's public servers, from Roblox's server list (fewest players first). Roblox only answers that a few ]] --
    -- [[ times a minute, so the list is kept in MogHub_Hop.json for 10 minutes and shared by the next hops.         ]] --
    local function http_get(url)
        local ok, body = pcall(function() return (game :: any):HttpGet(url) end)
        if ok and type(body) == "string" then return body, nil end
        local err = tostring(body)
        local req = exec("request") or exec("http_request")
        if typeof(req) == "function" then
            local okR, res = pcall(req, { Url = url, Method = "GET" })
            if okR and type(res) == "table" then
                if type(res.Body) == "string" and (tonumber(res.StatusCode) or 200) < 400 then return res.Body, nil end
                err = ("HTTP %s %s"):format(tostring(res.StatusCode), tostring(res.Body):sub(1, 80))
            elseif not okR then
                err = tostring(res)
            end
        end
        return nil, err
    end
    local servers, list_err, retry_at, backoff = {}, nil, 0, 15
    if type(hops.list) == "table" and type(hops.list.servers) == "table" and os.time() - (tonumber(hops.list.t) or 0) < 600 then
        servers = hops.list.servers
    end
    local function refresh_servers()
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"):format(MOG_PLACE)
        local body, err = http_get(url)
        local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not (body and ok and type(data) == "table" and type(data.data) == "table") then
            local why = err or (ok and type(data) == "table" and type(data.errors) == "table" and HttpService:JSONEncode(data.errors)) or body
            list_err = tostring(why or "no answer"):sub(1, 140)
            return 0
        end
        servers = {}
        for _, s in ipairs(data.data) do
            if type(s) == "table" and type(s.id) == "string" then
                table.insert(servers, { id = s.id, playing = tonumber(s.playing) or 0, maxPlayers = tonumber(s.maxPlayers) or 0 })
            end
        end
        hops.list = { t = os.time(), servers = servers }
        save_json(HOP_FILE, hops)
        if #servers == 0 then list_err = "the list came back empty (every other server is full)" end
        return #servers
    end
    local function pick_server(forget_after)
        local now = os.time()
        for id, t in pairs(hops.visited) do
            if now - (tonumber(t) or 0) > (forget_after or 3600) then hops.visited[id] = nil end
        end
        local list = {}
        for _, s in ipairs(servers) do
            if type(s) == "table" and type(s.id) == "string" and s.id ~= game.JobId and not hops.visited[s.id]
                and (tonumber(s.playing) or 0) < (tonumber(s.maxPlayers) or 0) then
                table.insert(list, s)
            end
        end
        if #list == 0 then return nil end
        table.sort(list, function(a, b) return (tonumber(a.playing) or 0) < (tonumber(b.playing) or 0) end)
        return list[math.random(1, math.min(5, #list))]
    end
    local tp_fail = nil
    pcall(function()
        track(TeleportService.TeleportInitFailed:Connect(function(player, result, message)
            if player == me then tp_fail = ("%s %s"):format(tostring(result), tostring(message)) end
        end))
    end)
    -- [[ one try at joining the next server. false = can't hop right now (no server list): the farm farms meanwhile ]] --
    local function hop_now()
        local s = pick_server()
        if not s then
            if os.clock() < retry_at then return false end
            S.status = "Server hop: getting the server list"
            if refresh_servers() == 0 then
                retry_at = os.clock() + backoff
                S.hop_note = ("Roblox didn't give the server list (%s), farming here and trying again in %ds"):format(tostring(list_err), backoff)
                logf("HOP", S.hop_note)
                backoff = math.min(backoff * 2, 120)
                return false
            end
            backoff = 15
            -- [[ every server on the list was visited in the last hour: ones from over 10 minutes ago are fine again ]] --
            s = pick_server() or pick_server(600)
            if not s then
                retry_at = os.clock() + 60
                S.hop_note = "been to every server on the list in the last 10 minutes, farming here for a minute"
                logf("HOP", S.hop_note)
                return false
            end
        end
        -- [[ the helper has to come along: without queue_on_teleport (or the script file in the workspace) a hop ]] --
        -- [[ would land you in a new server with no farm for the rest of the night                                ]] --
        if S.queue_self then S.queue_self() end
        if not env.mog_helper_queued then
            S.hop_note = "can't hop: the helper can't load itself in the next server (needs queue_on_teleport and mog_helper.lua in the workspace)"
            if not S.hop_unqueued_logged then
                S.hop_unqueued_logged = true
                logf("HOP", S.hop_note)
            end
            retry_at = os.clock() + 120
            return false
        end
        hops.visited[s.id] = os.time()
        save_json(HOP_FILE, hops)
        pcall(save_log)
        if #S.hatched > 0 then pcall(save_hatched) end -- an empty book mustn't overwrite the last server's
        tp_fail = nil
        S.status = ("Server hop: joining a server with %s players (hop %d)"):format(tostring(s.playing), hops.count + 1)
        local started, err = pcall(function() TeleportService:TeleportToPlaceInstance(MOG_PLACE, s.id, me) end)
        if not started then
            logf("HOP", "couldn't start the teleport: " .. tostring(err):sub(1, 120))
            task.wait(1)
            return true
        end
        local t = os.clock()
        -- [[ a teleport can take a while; starting another one meanwhile would send you somewhere else ]] --
        repeat task.wait(0.25) until tp_fail or os.clock() - t > 45 or not S.alive
        if tp_fail then
            logf("HOP", "couldn't join that server: " .. tp_fail)
            task.wait(1)
        else
            -- [[ counted once the teleport went through (failed ones aren't hops) ]] --
            hops.count += 1
            save_json(HOP_FILE, hops)
        end
        return true
    end

    -- [[ the biggest free normal egg in the last stage that's loaded around you and inside your size range, plus ]] --
    -- [[ the biggest one there at all (for the hop log)                                                          ]] --
    local function biggest_here(stage)
        local best, best_info, top_info = nil, nil, nil
        for egg in pairs(all_eggs) do
            if egg.Parent and egg:IsDescendantOf(workspace) then
                local state = egg:GetAttribute("EggState")
                if (state == nil or state == "Idle") and not is_event(egg) and stage_of(egg) == stage then
                    local info = S.egg_info(egg)
                    if info.scale then
                        if not top_info or info.scale > top_info.scale then top_info = info end
                        if info.scale >= S.hop_min and info.scale <= S.hop_max and (not best_info or info.scale > best_info.scale) then
                            best, best_info = egg, info
                        end
                    end
                end
            end
        end
        return best, best_info, top_info
    end
    S.record_scale = record_scale
    local H = { phase = "look", t = os.clock(), tries = 0 }
    local function set_phase(p)
        H.phase, H.t = p, os.clock()
    end
    S.hop_reset = function()
        H = { phase = "look", t = os.clock(), tries = 0 }
        -- [[ the server you start hopping from counts as visited, so the hop doesn't come straight back ]] --
        if S.hop_mode ~= "Off" then
            hops.visited[game.JobId] = os.time()
            save_json(HOP_FILE, hops)
        end
    end
    -- [[ an event egg's pet takes longer to come out (S.event_hatch), so that counts too ]] --
    local function pets_on_the_go()
        return carrying() or #S.pending > 0 or #S.hatching > 0 or S.fights > 0
            or (S.event_hatch ~= nil and os.clock() < S.event_hatch.until_t and S.delivered == (H.banked or S.delivered))
    end
    local function idle(egg)
        local st = egg:GetAttribute("EggState")
        return st == nil or st == "Idle"
    end
    -- [[ the Titanic egg, if this server has one up: the server writes where it is on the map (TitanicPosition) ]] --
    local function titanic_egg()
        if workspace:GetAttribute("TitanicActive") ~= true then return nil end
        local pos = workspace:GetAttribute("TitanicPosition")
        if typeof(pos) ~= "Vector3" then return nil end
        -- [[ a Titanic in a lower stage can't hatch a pet for your plot (Leave worthless on): not worth the trip ]] --
        local zone = workspace:GetAttribute("TitanicZone")
        local only = (S.hop_mode == "Events" and last_stage()) or (S.only_stage and S.only_stage())
        if only and tostring(zone):match("^Stage%d+$") and zone ~= only then return nil end
        if dist_to(pos) > 120 then
            S.status = ("Server hop: going to the Titanic egg in %s"):format(tostring(workspace:GetAttribute("TitanicZone") or "?"))
            travel(ground(pos + Vector3.new(0, 0, 25)), pos)
        end
        local t = os.clock()
        repeat
            for egg in pairs(all_eggs) do
                if egg.Parent and egg:GetAttribute("GiantEgg") == true and idle(egg) and (egg:GetPivot().Position - pos).Magnitude < 200 then
                    if (S.egg_ok and not S.egg_ok(egg)) or (S.hop_mode == "Events" and stage_of(egg) ~= last_stage()) then return nil end
                    return egg
                end
            end
            task.wait(0.5)
        until os.clock() - t > 5
        return nil
    end
    -- [[ any other event egg (admin or new event eggs) loaded around you ]] --
    local function other_event_egg()
        for egg in pairs(all_eggs) do
            if egg.Parent and egg:IsDescendantOf(workspace) and idle(egg) and egg:GetAttribute("GiantEgg") ~= true and is_event(egg)
                and (not S.egg_ok or S.egg_ok(egg)) and (S.hop_mode ~= "Events" or stage_of(egg) == last_stage()) then
                return egg
            end
        end
        return nil
    end
    -- [[ an event egg up in the top stage right now: the Titanic's spot is on the map, other event eggs show once ]] --
    -- [[ loaded (Treadmill farm keeps the top stage loaded from the treadmill)                                    ]] --
    local function top_event_here()
        local top = last_stage()
        if workspace:GetAttribute("TitanicActive") == true and workspace:GetAttribute("TitanicZone") == top then return true end
        for egg in pairs(all_eggs) do
            if egg.Parent and idle(egg) and is_event(egg) and stage_of(egg) == top then return true end
        end
        return false
    end
    S.top_event_here = top_event_here
    S.chase_off = function()
        hops.chase, hops.chase_misses = false, 0
        save_json(HOP_FILE, hops)
    end
    -- [[ an event egg in the top stage won by the farm itself (Treadmill farm, a Titanic): for Event chase that's ]] --
    -- [[ the event being on, the same as one the hop took                                                          ]] --
    S.event_won = function(egg)
        if S.hop_mode ~= "Events" then return end
        local st = stage_of(egg) or egg:GetAttribute("Stage")
        if st == last_stage() or egg:GetAttribute("GiantEgg") == true then
            H.event_done = true
            hop_log(("server %s: the farm won an event egg (%s), the event is on"):format(game.JobId:sub(1, 8), tostring(st)))
        end
    end
    -- [[ a Titanic that turns up after the first look in this server gets looked at too ]] --
    track(workspace:GetAttributeChangedSignal("TitanicActive"):Connect(function()
        if workspace:GetAttribute("TitanicActive") == true then H.titanic_checked = false end
    end))
    local function start_event(egg)
        local info = S.egg_info(egg)
        hop_log(("server %s (%d players): EVENT egg %s, going for it"):format(game.JobId:sub(1, 8), #Players:GetPlayers(), egg_text(info)))
        S.hop_note = "going for an event egg: " .. egg_text(info)
        H.target, H.info, H.tries, H.event = egg, info, 0, true
        set_phase("grab")
        return true
    end
    -- [[ after an event egg (taken or lost), this server still gets its normal size check before hopping ]] --
    local function event_finished()
        H.event, H.event_done = false, true
        set_phase("look")
        return true
    end
    -- [[ one step of the hop, on the farm's own thread; false = let the farm do a normal step ]] --
    S.hop_step = function()
        if S.hop_mode == "Off" or game.PlaceId ~= MOG_PLACE then return false end
        local stage = last_stage()
        -- [[ a boost window is on here (weather, admin Luck / Mutation): every egg is worth more right now, so no ]] --
        -- [[ hopping while it lasts                                                                               ]] --
        -- [[ Event chase (Treadmill farm): train until an event egg shows up in the top stage. The top stage is kept ]] --
        -- [[ loaded from the treadmill so its event eggs show up without leaving it.                                 ]] --
        -- [[ (once an event egg was taken here, the gate is passed: the chase below hops on to the next server) ]] --
        if S.hop_mode == "Events" and H.phase == "look" and not H.event and not hops.chase and not H.event_done then
            if os.clock() < (H.quiet_until or 0) or not top_event_here() then
                if os.clock() - (H.stream_t or -100) > 20 then
                    H.stream_t = os.clock()
                    local c = stage_center(stage)
                    if c then task.spawn(function() pcall(function() me:RequestStreamAroundAsync(c, 5) end) end) end
                end
                S.hop_note = ("treadmill farm: waiting for an event egg in %s"):format(stage)
                return false
            end
        end
        local boost = (H.phase == "look" or H.phase == "hop") and not H.event and S.hop_mode ~= "Events" and S.boost_now and S.boost_now()
        if boost then
            S.hop_note = "boost on (" .. boost .. "): farming here until it ends"
            if S.hop_mode == "Boosts" and (tonumber(hops.boost_misses) or 0) ~= 0 then
                hops.boost_misses = 0
                save_json(HOP_FILE, hops)
                hop_log(("server %s: %s, farming here while it lasts"):format(game.JobId:sub(1, 8), boost))
            end
            return false
        end
        if H.phase == "look" then
            -- [[ event eggs come first in every server, whatever your size range or record. The Titanic is checked ]] --
            -- [[ once per server (it can be in any stage, the server says where)                                  ]] --
            if not H.event_done and not H.titanic_checked then
                H.titanic_checked = true
                local ev = titanic_egg()
                if ev then return start_event(ev) end
            end
            if not H.event_done then
                local ev = other_event_egg()
                if ev then return start_event(ev) end
            end
            -- [[ Event chase: took an event egg here, so the event is on: on to the next server for its event egg ]] --
            if S.hop_mode == "Events" and H.event_done then
                hops.chase, hops.chase_misses = true, 0
                save_json(HOP_FILE, hops)
                hop_log(("server %s: took the event egg, looking for it in the next server"):format(game.JobId:sub(1, 8)))
                S.hop_note = "event on: hopping to the next server for its event egg"
                set_phase("hop")
                return true
            end
            -- [[ Chase boosts: no boost in this server (checked above), so on to the next. After 10 servers in a row ]] --
            -- [[ without one (weather may run at the same time everywhere), it farms here for 5 minutes, then looks   ]] --
            -- [[ again                                                                                                ]] --
            if S.hop_mode == "Boosts" then
                if os.time() < (tonumber(hops.rest_until) or 0) then
                    S.hop_note = "no boost in the last 10 servers, farming here a few minutes before looking again"
                    return false
                end
                hops.boost_misses = (tonumber(hops.boost_misses) or 0) + 1
                if hops.boost_misses >= 10 then hops.boost_misses, hops.rest_until = 0, os.time() + 300 end
                save_json(HOP_FILE, hops)
                hop_log(("server %s (%d players): no weather or admin boost, hopping"):format(game.JobId:sub(1, 8), #Players:GetPlayers()))
                S.hop_note = "no boost in this server, hopping"
                set_phase("hop")
                return true
            end
            if S.hop_mode == "Bigger" and record_scale() <= 0 then
                S.hop_note = ("no record yet: the farm needs to win an egg in %s first"):format(stage)
                return false
            end
            if S.hop_mode == "Bigger" and S.hop_max <= record_scale() then
                S.hop_note = ("your size range ends at %.2f, under your record %.3f, so nothing can be bigger: raise it or reset the record")
                    :format(S.hop_max, record_scale())
                return false
            end
            local center = stage_center(stage)
            if not center then
                S.hop_note = "can't find " .. stage .. " in the map"
                set_phase("hop")
                return true
            end
            S.status = ("Server hop: looking at the eggs in %s"):format(stage)
            travel(ground(center), center + Vector3.new(0, 0, -10))
            task.wait(3)
            -- [[ a long stage: its two ends too, so all its eggs load ]] --
            local stages = game_folder("Stages")
            local folder = stages and stages:FindFirstChild(stage)
            local box = folder and folder:FindFirstChild("Hitbox")
            if box and box:IsA("BasePart") then
                local reach = box.Size.X >= box.Size.Z and box.CFrame.RightVector * (box.Size.X / 3) or box.CFrame.LookVector * (box.Size.Z / 3)
                for _, off in ipairs({ -reach, reach }) do
                    local spot = Vector3.new(box.Position.X + off.X, 8, box.Position.Z + off.Z)
                    travel(ground(spot), spot + Vector3.new(0, 0, -10))
                    task.wait(2)
                end
            end
            if not H.event_done then
                local ev = other_event_egg()
                if ev then return start_event(ev) end
            end
            -- [[ Event chase: no event egg in this server's top stage ]] --
            if S.hop_mode == "Events" then
                if not hops.chase then
                    H.quiet_until = os.clock() + 60 -- it was gone by the time you got there: back to the treadmill
                    S.hop_note = "the event egg was already gone, back to the treadmill"
                    return false
                end
                hops.chase_misses = (tonumber(hops.chase_misses) or 0) + 1
                if hops.chase_misses >= 3 then
                    hops.chase, hops.chase_misses = false, 0
                    save_json(HOP_FILE, hops)
                    hop_log("no event egg in the top stage of 3 servers in a row: the event is over, back to the treadmill")
                    logf("HOP", "event over: back to treadmill farming in this server")
                    notify("The event is over. Back to treadmill farming.")
                    H.quiet_until = os.clock() + 60
                    return false
                end
                save_json(HOP_FILE, hops)
                hop_log(("server %s (%d players): no event egg in %s, hopping (%d/3)"):format(game.JobId:sub(1, 8), #Players:GetPlayers(),
                    stage, hops.chase_misses))
                S.hop_note = ("no event egg here (%d/3), hopping"):format(hops.chase_misses)
                set_phase("hop")
                return true
            end
            local egg, info, top = biggest_here(stage)
            local here = ("server %s (%d players): "):format(game.JobId:sub(1, 8), #Players:GetPlayers())
                .. (top and ("biggest egg " .. egg_text(top)) or ("no free egg in " .. stage))
                .. ((top and not egg) and (" (none sized %.2f to %.2f)"):format(S.hop_min, S.hop_max) or "")
                .. ((egg and info ~= top) and (" | in your range: " .. egg_text(info)) or "")
            local rec = record_scale()
            if S.hop_mode == "Bigger" then
                if egg and info.scale > rec then
                    hop_log(here .. (" | BIGGER than your record %.3f, going for it"):format(rec))
                    H.target, H.info, H.tries = egg, info, 0
                    set_phase("grab")
                else
                    hop_log(here .. (" | record %.3f, hopping"):format(rec))
                    set_phase("hop")
                end
            elseif egg then
                hop_log(here .. " | grabbing it")
                H.target, H.info, H.tries = egg, info, 0
                set_phase("grab")
            else
                hop_log(here .. " | hopping")
                set_phase("hop")
            end
            S.hop_note = here
            return true
        end
        if H.phase == "grab" then
            local egg = H.target
            local state = egg and egg.Parent and egg:GetAttribute("EggState")
            if not (egg and egg.Parent) or (state ~= nil and state ~= "Idle") then
                hop_log("someone else got " .. egg_text(H.info) .. " first" .. (H.event and "" or ", hopping"))
                if H.event then return event_finished() end
                set_phase("hop")
                return true
            end
            H.banked = S.delivered
            if steal(egg, true) then
                S.hop_note = "won " .. egg_text(H.info) .. ", banking its pet"
                set_phase("bank")
            else
                H.tries += 1
                if H.tries >= 3 then
                    hop_log("couldn't mog " .. egg_text(H.info) .. (H.event and "" or ", hopping"))
                    if H.event then return event_finished() end
                    set_phase("hop")
                end
            end
            return true
        end
        if H.phase == "bank" then
            if pets_on_the_go() and os.clock() - H.t < (H.event and 150 or 100) then
                S.status = "Server hop: banking the pet from the " .. tostring(H.info.name)
                if not collect_once() then task.wait(0.25) end
                return true
            end
            hop_log(S.delivered > H.banked and ("banked the pet from " .. egg_text(H.info)) or "its pet didn't make it home in time")
            if H.event then return event_finished() end
            -- [[ hopping stays on until you turn it off: in Find a bigger egg the record just went up, so it looks for an ]] --
            -- [[ even bigger one next                                                                                    ]] --
            if S.hop_mode == "Bigger" then
                S.hop_note = "found a bigger egg (" .. egg_text(H.info) .. "), now looking for an even bigger one"
                logf("HOP", S.hop_note)
                notify(("Found a bigger egg: size %.3f! Looking for an even bigger one."):format(tonumber(H.info.scale) or 0))
            end
            set_phase("hop")
            return true
        end
        -- [[ hop: pets still hatching or on the ground are banked first, they'd be lost ]] --
        if pets_on_the_go() and os.clock() - H.t < 60 then
            S.status = "Server hop: banking your pets before leaving"
            if not collect_once() then task.wait(0.25) end
            return true
        end
        if hop_now() then return true end
        -- [[ no server to go to yet: a normal farm step, and the pets it gets are banked before the next try ]] --
        H.t = os.clock()
        return false
    end
end)()

-- [[ who this script is, for the shared Sobriety Hub window (reports/sobriety-ui/toolkit.lua) ]] --
S.hub = {
    game = "Mog to Steal an Egg", tag = "MOG TO STEAL AN EGG", stop = "mog_helper_stop",
    steps = { { 0, "linking executor" }, { 0.2, "hooking the game's remotes" }, { 0.45, "reading pets, eggs and stages" },
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
function W.credits(_p)
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
        if holder.Parent then show() end
    end)
end
minimize.MouseButton1Click:Connect(hide)
track(UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.KeyCode ~= Enum.KeyCode.RightAlt then return end
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
local tween, new, corner, outline, gradient, set_text, label = W.tween, W.new, W.corner, W.outline, W.gradient, W.set_text, W.label
local gui, painters, page, next_order = W.gui, W.painters, W.page, W.next_order
local card, section, titled, toggle, segmented, action, info, stats = W.card, W.section, W.titled, W.toggle, W.segmented, W.action, W.info, W.stats
local top_pill, me_sub = W.top_pill, W.me_sub

---------------------------------------------------------------- the pages

local home_page = page("Home", "⌂", 0)
local farm_page = page("Farm", "🥚", 1)
local mog_page = page("Mogging", "⚔", 2)
local pets_page = page("Pets", "🐾", 3)
local speed_page = page("Speed", "👟", 4)
local upgrades_page = page("Upgrades", "⬆", 5)
local tp_page = page("Teleport", "➜", 6)
local menus_page = page("Menus", "▤", 7)
local board_page = page("Leaderboard", "🏆", 8)
local logs_page = page("Logs", "📋", 9)
local settings_page = page("Settings", "⚙", 10)

-- [[ Home: everything worth keeping an eye on in one place: what the farm is doing right now, the numbers, ]] --
-- [[ what just happened, and where each setting lives.                                                     ]] --
do
    local hero = card(home_page, 112)
    -- [[ while the farm runs, a light runs around the hero card ]] --
    local hero_stroke = hero:FindFirstChildOfClass("UIStroke")
    local hero_glow = W.spin(new("UIGradient", { Color = W.ACCENT, Enabled = false, Parent = hero_stroke }), 90)
    local hero_dot = new("Frame", { Position = UDim2.fromOffset(18, 22), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = C.dim, Parent = hero })
    corner(hero_dot)
    local hero_state = label(hero, "FARM IS OFF", BLACK, 12, C.dim, { Position = UDim2.fromOffset(38, 16), Size = UDim2.new(1, -200, 0, 24) })
    local hero_status = label(hero, "", BOLD, 17, C.text, { Position = UDim2.fromOffset(18, 44), Size = UDim2.new(1, -200, 0, 24),
        TextTruncate = Enum.TextTruncate.AtEnd })
    local hero_next = label(hero, "", REG, 12, C.dim, { Position = UDim2.fromOffset(18, 72), Size = UDim2.new(1, -200, 0, 30), TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top })
    local farm_btn = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.fromOffset(150, 48),
        BackgroundColor3 = C.white, AutoButtonColor = false, Text = "START FARM", Font = BLACK, TextSize = 15, TextColor3 = C.white, Parent = hero })
    corner(farm_btn, 12)
    local farm_grad = gradient(farm_btn, 0)
    local farm_scale = new("UIScale", { Parent = farm_btn })
    farm_btn.MouseButton1Down:Connect(function() tween(farm_scale, 0.1, { Scale = 0.94 }) end)
    farm_btn.MouseButton1Up:Connect(function() tween(farm_scale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back) end)
    farm_btn.MouseLeave:Connect(function() tween(farm_scale, 0.2, { Scale = 1 }) end)
    farm_btn.MouseButton1Click:Connect(function()
        local v = not S.farm
        S.farm = v
        S.farm_off_by = not v and "turned off by you" or nil
        logf("FARM", v and "turned ON by you" or "turned OFF by you")
        if not v then S.status = "Ready" end
    end)

    local row1 = stats(home_page, { "Banked", "Hatching", "Pets waiting", "Appeal" })
    local row2 = stats(home_page, { "Money/s", "Mutated", "Gifted", "Running for" })

    section(home_page, "WHAT JUST HAPPENED")
    local feed_card = card(home_page, 214)
    local feed = label(feed_card, "", REG, 12, C.text, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 1, -20), TextWrapped = true,
        RichText = true, TextYAlignment = Enum.TextYAlignment.Top, LineHeight = 1.15 })

    section(home_page, "WHERE THINGS ARE")
    local guide = info(home_page, 150)
    guide.Text = "<b>Farm</b>  turn the farm on, pick stages, event eggs, gifting\n"
        .. "<b>Mogging</b>  fights, fast mog, anti ragdoll, anti void, bat thieves\n"
        .. "<b>Pets</b>  equip best, auto mutate, auto sell, advisor, hatch book\n"
        .. "<b>Speed</b>  treadmill     <b>Upgrades</b>  every auto buy, each with its own switch\n"
        .. "<b>Teleport</b>  spawn, treadmill, stages, event egg     <b>Menus</b>  game windows, leaderboards\n"
        .. "<b>Logs</b>  copy the log for Claude     <b>Settings</b>  unload, key to hide (Right Alt)"

    local KIND_COLOR = { STEAL = "8CF5B0", BANKED = "8CF5B0", HATCHED = "D8B4FE", PRIORITY = "C4B5FD", HIT = "FFB27A", LOST = "FF8F8F",
        CARRY = "FFB27A", GUARD = "FFD27A", VOID = "FF8F8F", FELL = "FF8F8F", ERROR = "FF6B6B", SELL = "FFD27A", PROGRESS = "8CF5B0",
        MUTATE = "F0ABFC", ADMIN = "FFD27A", SPECIAL = "F0ABFC", UPDATE = "C4B5FD", WATCHDOG = "FFB27A", HOP = "C4B5FD", FREE = "8CF5B0" }
    local function esc(t) return (tostring(t):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
    table.insert(painters, function()
        local on = S.farm
        local training = not on and on_treadmill()
        local col = on and C.good or (training and C.a2 or C.dim)
        hero_dot.BackgroundColor3 = col
        hero_glow.Enabled = on or training
        if hero_stroke then
            hero_stroke.Color = (on or training) and C.white or C.stroke
            hero_stroke.Thickness = (on or training) and 1.6 or 1
        end
        hero_state.Text = on and "FARMING" or (training and "TRAINING ON THE TREADMILL" or "FARM IS OFF")
        hero_state.TextColor3 = col
        top_pill.dot.BackgroundColor3 = col
        top_pill.text.Text = on and "FARMING" or (training and "TRAINING" or "IDLE")
        top_pill.text.TextColor3 = on and C.text or C.dim
        hero_status.Text = tostring(S.status)
        local ok_egg, egg = pcall(pick_egg)
        egg = ok_egg and egg or nil
        hero_next.Text = (egg and ("Next egg: %s%s, %s appeal%s"):format(is_event(egg) and "EVENT " or "", tostring(egg:GetAttribute("DisplayName") or egg.Name),
            short(appeal_of(egg)), is_instant(egg) and " (instant)" or "") or "Next egg: none loaded near you")
            .. (S.titanic and ("   ·   Titanic egg up in " .. tostring(S.titanic.zone)) or "")
        set_text(farm_btn, on and "STOP FARM" or "START FARM")
        farm_grad.Enabled = not on
        farm_btn.BackgroundColor3 = on and C.bad or C.white
        row1.Banked.Text = tostring(S.delivered)
        row1.Hatching.Text = tostring(#S.hatching + (S.fights or 0))
        row1["Pets waiting"].Text = tostring(#S.pending)
        row1.Appeal.Text = short(power())
        local ls = me:FindFirstChild("leaderstats")
        local ms = ls and ls:FindFirstChild("Money/s")
        row2["Money/s"].Text = ms and ("$" .. tostring(ms.Value)) or "-"
        row2.Mutated.Text = tostring(S.mutated)
        row2.Gifted.Text = tostring(S.gifted_count)
        local mins = math.floor((os.clock() - S.session_start) / 60)
        row2["Running for"].Text = mins >= 60 and ("%dh %dm"):format(mins // 60, mins % 60) or (mins .. " min")
        local lines = {}
        for i = #S.log, math.max(1, #S.log - 11), -1 do
            local line = S.log[i]
            local time, kind, msg = line:match("^%[(%d+:%d+):%d+ [^%]]*%] (%u+): (.*)$")
            if time then
                table.insert(lines, ('<font color="#6E7590">%s</font>  <font color="#%s"><b>%s</b></font>  %s'):format(time,
                    KIND_COLOR[kind] or "AEB4C8", kind, esc(msg)))
            else
                table.insert(lines, esc(line))
            end
            if #lines >= 11 then break end
        end
        feed.Text = #lines > 0 and table.concat(lines, "\n") or "Nothing yet."
    end)
end

-- [[ Farm ]] --
local status_card = card(farm_page, 58)
local dot = new("Frame", { Position = UDim2.fromOffset(16, 16), Size = UDim2.fromOffset(9, 9), BackgroundColor3 = C.dim, Parent = status_card })
corner(dot)
local ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1, Parent = dot })
corner(ring)
local ring_stroke = outline(ring, C.good, 1.5, 1)
local status_text = label(status_card, "", BOLD, 13, C.text, { Position = UDim2.fromOffset(34, 8), Size = UDim2.new(1, -46, 0, 18),
    TextTruncate = Enum.TextTruncate.AtEnd })
local next_text = label(status_card, "", REG, 11, C.dim, { Position = UDim2.fromOffset(34, 30), Size = UDim2.new(1, -46, 0, 16),
    TextTruncate = Enum.TextTruncate.AtEnd })
go(function()
    while S.alive and gui.Parent do
        if S.farm or S.treadmill then
            ring.Size = UDim2.fromScale(1, 1)
            ring_stroke.Transparency = 0.1
            tween(ring, 1, { Size = UDim2.fromScale(3, 3) })
            tween(ring_stroke, 1, { Transparency = 1 })
        end
        task.wait(1.1)
    end
end)
local farm_stats = stats(farm_page, { "Banked", "Hatching", "Mutated", "Appeal" })
section(farm_page, "AUTO FARM")
toggle(farm_page, "Auto farm", "Steal eggs, take each pet, bank it in the safe zone", function() return S.farm end, function(v)
    S.farm = v
    S.farm_off_by = not v and "turned off by you" or nil
    logf("FARM", v and "turned ON by you" or "turned OFF by you")
    if not v then S.status = "Ready" end
end)
segmented(farm_page, "Farm mode (Treadmill farm: trains, takes only top-stage event eggs and chases them across servers)",
    { { "Normal", "Normal farm" }, { "Treadmill", "Treadmill farm" } },
    function() return S.farm_mode end, function(v) S.set_farm_mode(v) end)
toggle(farm_page, "Gift pets at Stage 1", "Weak pets are dropped at Stage 1 for others; Titanic pets always go home",
    function() return S.gift end, function(v)
        S.gift = v
        logf("GIFT", v and "gift mode ON" or "gift mode OFF")
    end)
-- [[ the gift limit writer: type a plain number, pick the size (Thousand ... Quadrillion), and it shows in   ]] --
-- [[ words and in full digits what that is, as you type. Typing "50B" or all the zeroes works too.          ]] --
do
    local UNITS = { { "", 1, "" }, { "K", 1e3, "Thousand" }, { "M", 1e6, "Million" }, { "B", 1e9, "Billion" },
        { "T", 1e12, "Trillion" }, { "Qa", 1e15, "Quadrillion" } }
    local function split(v)
        local pick = UNITS[1]
        for _, u in ipairs(UNITS) do if v >= u[2] then pick = u end end
        return v / pick[2], pick
    end
    local function trim(x) return (("%.2f"):format(x):gsub("%.?0+$", "")) end
    local function words(v)
        if v <= 0 then return "nothing: every pet is gifted" end
        local n, u = split(v)
        return trim(n) .. (u[3] ~= "" and (" " .. u[3]) or "")
    end
    local function digits(v)
        local s = ("%.0f"):format(v):reverse():gsub("(%d%d%d)", "%1,"):reverse()
        return (s:gsub("^,", ""))
    end

    local f = card(farm_page, 150)
    titled(f, "Gift only pets under", "Earning less than this per second go to Stage 1, more go home", true)
    local box = new("TextBox", { Position = UDim2.fromOffset(14, 52), Size = UDim2.fromOffset(86, 30), BackgroundColor3 = C.bg, Text = "",
        PlaceholderText = "50", PlaceholderColor3 = C.dim, Font = BOLD, TextSize = 14, TextColor3 = C.text, ClearTextOnFocus = false, Parent = f })
    corner(box, 8)
    local box_stroke = outline(box, C.stroke, 1, 0)
    local unit_row = new("Frame", { Position = UDim2.fromOffset(108, 52), Size = UDim2.new(1, -122, 0, 30), BackgroundTransparency = 1, Parent = f })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = unit_row })
    local preview = label(f, "", REG, 12, C.dim, { Position = UDim2.fromOffset(14, 88), Size = UDim2.new(1, -28, 0, 18), RichText = true,
        TextTruncate = Enum.TextTruncate.AtEnd })
    local preset_row = new("Frame", { Position = UDim2.fromOffset(14, 112), Size = UDim2.new(1, -28, 0, 26), BackgroundTransparency = 1, Parent = f })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4), Parent = preset_row })

    local unit = UNITS[4]
    local chips = {}
    local function paint_units()
        for u, x in pairs(chips) do
            local on = u == unit
            x.grad.Enabled = on
            x.button.BackgroundColor3 = on and C.white or C.bg
            set_text(x.button, nil, on and C.white or C.dim)
        end
    end
    -- [[ what's in the box right now: a plain number times the picked size, or a full "50B" / "50000000000" ]] --
    local function typed_value()
        local text = box.Text:gsub(",", ""):gsub("%s", "")
        local n = tonumber(text)
        if n then return n * unit[2] end
        return parse_amount(text)
    end
    local function show_preview()
        local v = typed_value()
        preview.Text = v and ("= <b>%s</b> per second   •   $%s/s   •   %s"):format(words(v), short(v), digits(v))
            or "Type a number like <b>50</b>, then pick <b>B</b> for Billion"
    end
    local function apply(v, quiet)
        S.gift_min = math.max(0, v)
        local n, u = split(S.gift_min)
        unit = S.gift_min > 0 and u or unit
        box.Text = S.gift_min > 0 and trim(n) or "0"
        paint_units()
        show_preview()
        logf("GIFT", S.gift_min > 0 and ("gift limit set: pets under %s/s go to Stage 1"):format(words(S.gift_min)) or "gift limit off: every pet is gifted")
        if not quiet then
            notify(S.gift_min > 0 and ("Pets earning under %s a second go to Stage 1, better ones go home."):format(words(S.gift_min))
                or "Every pet the farm takes is gifted.")
        end
    end
    for _, u in ipairs(UNITS) do
        local b = new("TextButton", { Size = UDim2.new(1 / #UNITS, -4, 1, 0), BackgroundColor3 = C.bg, AutoButtonColor = false,
            Text = u[1] == "" and "×1" or u[1], Font = BOLD, TextSize = 12, TextColor3 = C.dim, Parent = unit_row })
        corner(b, 7)
        outline(b, C.stroke, 1, 0)
        local g = gradient(b, 0)
        g.Enabled = false
        chips[u] = { button = b, grad = g }
        b.MouseButton1Click:Connect(function()
            unit = u
            local n = tonumber((box.Text:gsub(",", "")))
            if n then apply(n * u[2]) else paint_units() show_preview() end
        end)
    end
    for _, p in ipairs({ { "Gift all", 0 }, { "1B", 1e9 }, { "10B", 1e10 }, { "50B", 5e10 }, { "100B", 1e11 }, { "1T", 1e12 } }) do
        local b = new("TextButton", { Size = UDim2.new(1 / 6, -4, 1, 0), BackgroundColor3 = C.card2, AutoButtonColor = true, Text = p[1],
            Font = BOLD, TextSize = 11, TextColor3 = C.text, Parent = preset_row })
        corner(b, 7)
        b.MouseButton1Click:Connect(function() apply(p[2]) end)
    end
    box:GetPropertyChangedSignal("Text"):Connect(show_preview)
    box.Focused:Connect(function() box_stroke.Color = C.a2 end)
    box.FocusLost:Connect(function()
        box_stroke.Color = C.stroke
        local v = typed_value()
        if v then
            apply(v)
        else
            notify("Couldn't read that. Type a number like 50 and pick B, or write 50B.")
            apply(S.gift_min, true)
        end
    end)
    apply(S.gift_min, true)
end
action(farm_page, "Steal one egg", "One steal, then it brings the pet home", "STEAL", function()
    if S.farm or S.manual then notify("The farm is already running.") return end
    local egg = pick_egg()
    if not egg then notify("No free egg loaded nearby in your stages.") return end
    S.manual = true
    go(function()
        pcall(steal, egg)
        local t = os.clock()
        while S.alive and os.clock() - t < 60 and (#S.hatching > 0 or #S.pending > 0 or carrying()) do
            local ok, did = pcall(collect_once)
            if not (ok and did) then task.wait(0.25) end
            task.wait()
        end
        S.manual = false
        S.status = "Ready"
    end)
end)
section(farm_page, "WHERE AND WHAT")
do
    local f = card(farm_page, 138)
    label(f, "Stages", BOLD, 14, C.text, { Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 18) })
    local stage_sub = label(f, "", REG, 11, C.dim, { Position = UDim2.fromOffset(70, 8), Size = UDim2.new(1, -84, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Right })
    local grid = new("Frame", { Position = UDim2.fromOffset(14, 34), Size = UDim2.new(1, -28, 1, -44), BackgroundTransparency = 1, Parent = f })
    new("UIGridLayout", { CellSize = UDim2.fromOffset(68, 26), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = grid })
    local chips = {}
    local keys = { { "Any", "Any" }, { "Events", "Events" } }
    for _, name in ipairs(STAGE_NAMES) do table.insert(keys, { name, "Stage " .. stage_num(name) }) end
    -- [[ the card grows when the game adds stages (5 chips a row) ]] --
    f.Size = UDim2.new(f.Size.X.Scale, f.Size.X.Offset, 0, math.max(138, 44 + math.ceil(#keys / 5) * 32))
    for i, k in ipairs(keys) do
        local b = new("TextButton", { BackgroundColor3 = C.bg, AutoButtonColor = false, Text = k[2], Font = BOLD, TextSize = 12, TextColor3 = C.dim,
            LayoutOrder = i, Parent = grid })
        corner(b, 7)
        local st = outline(b, C.stroke, 1, 0)
        local g = gradient(b, 0)
        g.Enabled = false
        chips[k[1]] = { button = b, stroke = st, grad = g }
        b.MouseButton1Click:Connect(function()
            if k[1] == "Any" then table.clear(S.stages) else S.stages[k[1]] = not S.stages[k[1]] or nil end
            S.scout_i, S.empty_runs = 0, 0
        end)
    end
    table.insert(painters, function()
        for key, x in pairs(chips) do
            local on = (key == "Any" and any_stage()) or S.stages[key] == true
            x.grad.Enabled = on
            x.button.BackgroundColor3 = on and C.white or C.bg
            set_text(x.button, nil, on and C.white or C.dim)
            x.stroke.Transparency = on and 1 or 0
        end
        stage_sub.Text = stages_text()
    end)
end
toggle(farm_page, "Always get event eggs", "Titanic, admin and other event eggs are taken first, whatever stages you picked",
    function() return S.always_events end, function(v) S.always_events = v end)
segmented(farm_page, "Pick eggs", { { "Best", "Best (events, top stage)" }, { "Nearest", "Nearest" }, { "Instant", "Instant only" } },
    function() return S.pick end, function(v) S.pick = v end)
segmented(farm_page, "Travel", { { "Teleport", "Teleport" }, { "Glide", "Glide" } }, function() return S.travel end, function(v) S.travel = v end)
section(farm_page, "SERVER HOP (needs Auto farm on; public servers only, it can't come back to a private one)")
local hop_info = info(farm_page, 76)
table.insert(painters, function()
    hop_info.Text = ("Biggest egg so far: <b>%s</b>\nGrabbing sizes <b>%.2f to %.2f</b>   |   Hops: <b>%d</b>   |   %s"):format(
        S.record_text and S.record_text() or "-", S.hop_min, S.hop_max, S.hop_count and S.hop_count() or 0, tostring(S.hop_note))
end)
-- [[ size range: the hop only grabs eggs from this size to that size (normal eggs are 0.50 to 1.00) ]] --
do
    local f = card(farm_page, 126)
    titled(f, "Only grab eggs sized", "Normal eggs are 0.50 to 1.00 and big ones are rare; others are skipped", true)
    local boxes = {}
    local function set_range(lo, hi)
        lo, hi = math.clamp(tonumber(lo) or 0.5, 0, 5), math.clamp(tonumber(hi) or 1, 0, 5)
        S.hop_min, S.hop_max = math.min(lo, hi), math.max(lo, hi)
        for _, b in ipairs(boxes) do b.box.Text = ("%.2f"):format(b.get()) end
    end
    local function size_box(x, get, set)
        local box = new("TextBox", { Position = UDim2.fromOffset(x, 52), Size = UDim2.fromOffset(70, 30), BackgroundColor3 = C.bg,
            Text = ("%.2f"):format(get()), Font = BOLD, TextSize = 14, TextColor3 = C.text, ClearTextOnFocus = false, Parent = f })
        corner(box, 8)
        outline(box, C.stroke, 1, 0)
        box.FocusLost:Connect(function()
            local n = tonumber((box.Text:gsub(",", ".")))
            if n then set(n) else box.Text = ("%.2f"):format(get()) end
        end)
        table.insert(boxes, { box = box, get = get })
        return box
    end
    size_box(14, function() return S.hop_min end, function(v) set_range(v, S.hop_max) end)
    label(f, "to", BOLD, 13, C.dim, { Position = UDim2.fromOffset(88, 52), Size = UDim2.fromOffset(28, 30),
        TextXAlignment = Enum.TextXAlignment.Center })
    size_box(118, function() return S.hop_max end, function(v) set_range(S.hop_min, v) end)
    local row = new("Frame", { Position = UDim2.fromOffset(14, 90), Size = UDim2.new(1, -28, 0, 26), BackgroundTransparency = 1, Parent = f })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = row })
    local presets = {
        { "All", function() set_range(0.5, 1) end },
        { "0.80+", function() set_range(0.8, 1) end },
        { "0.90+", function() set_range(0.9, 1) end },
        { "0.95+", function() set_range(0.95, 1) end },
        { "Above record", function()
            local rec = S.record_scale and S.record_scale() or 0
            if rec <= 0 then notify("No record yet: let the farm win an egg in the last stage first.") return end
            set_range(math.ceil(rec * 100 + 0.0001) / 100, 1)
        end },
    }
    for _, p in ipairs(presets) do
        local b = new("TextButton", { Size = UDim2.fromOffset(p[1] == "Above record" and 104 or 58, 26), BackgroundColor3 = C.bg, AutoButtonColor = false,
            Text = p[1], Font = BOLD, TextSize = 12, TextColor3 = C.dim, Parent = row })
        corner(b, 7)
        outline(b, C.stroke, 1, 0)
        b.MouseButton1Click:Connect(function()
            p[2]()
            logf("HOP", ("size range: %.2f to %.2f"):format(S.hop_min, S.hop_max))
        end)
    end
end
segmented(farm_page, "Server hop (event eggs like the Titanic are always taken first)", { { "Off", "Off" }, { "Events", "Event chase" },
    { "Boosts", "Chase boosts" }, { "Bigger", "Find a bigger egg" }, { "Grab", "Grab one every server" } },
    function() return S.hop_mode end, function(v)
        S.hop_mode = v
        if S.hop_reset then S.hop_reset() end
        if S.chase_off then S.chase_off() end -- an event chase left on from before mustn't carry over
        logf("HOP", "server hop: " .. v)
    end)
action(farm_page, "Reset record", "Forgets the biggest egg so far; the next one the farm wins in the last stage sets it", "RESET", function()
    if S.reset_record then S.reset_record() end
    notify("Biggest egg record reset.")
end)

-- [[ Mogging ]] --
local mog_info = info(mog_page, 52)
section(mog_page, "FIGHTS")
toggle(mog_page, "Always win", "The guard can't push back and your clicks count 10x", function() return S.always_win end, function(v) S.always_win = v end)
toggle(mog_page, "Move on during fights", "Goes to the next egg while the server's 3s run; turns itself off if the server says no",
    function() return S.parallel_mog end, function(v) S.parallel_mog = v S.parallel_fail, S.parallel_reject = 0, 0 end, "parallel_mog")
toggle(mog_page, "Fast mog", "Mogs eggs straight with the server: no animations, moves on the moment the egg is yours",
    function() return S.fast_mog end, function(v) S.fast_mog = v S.fast_fail = 0 end, "fast_mog")
toggle(mog_page, "Skip fights", "Win sent after 3.15s (server minimum 3s), no walk-up, countdown or clicking", function() return S.skip_fight end, function(v)
    S.skip_fight, S.skip_fail = v, 0
end, "skip_fight")
toggle(mog_page, "Force win", "A lost fight is still sent as won, and you don't get flung", function() return S.force_win end, function(v) S.force_win = v end)
section(mog_page, "GAME FEATURES")
toggle(mog_page, "Auto mog (unlocked)", "The game's own Auto Mog, without the gamepass", function() return S.auto_mog end, function(v) set_auto(v) end)
section(mog_page, "PROTECTION")
toggle(mog_page, "Anti void", "Fall off the map: held until the floor loads, or sent back to spawn and the farm restarts",
    function() return S.anti_void end, function(v) S.anti_void = v end)
toggle(mog_page, "Drop stuck pets", "A pet held 6s without banking is dropped (breaks the guard hit loop)",
    function() return S.carry_drop end, function(v) S.carry_drop = v end)
toggle(mog_page, "Anti ragdoll", "Bat hits and flings don't knock you over or send you flying",
    function() return S.anti_ragdoll end, function(v) S.anti_ragdoll = v end)
toggle(mog_page, "Bat thieves", "Someone runs off with a pet you hatched: hit them, take it back",
    function() return S.bat_thieves end, function(v) S.bat_thieves = v end)
toggle(mog_page, "Auto reconnect", "Disconnected or kicked: rejoins the same server (or a new one) and loads the helper again",
    function() return S.auto_reconnect end, function(v) S.auto_reconnect = v end)
section(mog_page, "SAVE YOUR PETS' GROWTH")
toggle(mog_page, "Auto rejoin", "The game only saves how grown your pets are when you leave. Rejoins this server on a timer; first it banks every pet and waits out event eggs, Titanics and boosts",
    function() return S.auto_rejoin end, function(v) S.auto_rejoin = v end)
segmented(mog_page, "Rejoin every", { { 10, "10 min" }, { 20, "20 min" }, { 30, "30 min" }, { 60, "1 hour" } },
    function() return S.rejoin_mins end, function(v) S.rejoin_mins = v end)
do
    local rejoin_info = info(mog_page, 36)
    table.insert(painters, function()
        rejoin_info.Text = "Auto rejoin: <b>" .. tostring(S.rejoin_note or "-") .. "</b>"
    end)
end

-- [[ Pets ]] --
local pet_stats = stats(pets_page, { "Banked", "Mutated", "Last pet" })
section(pets_page, "INVENTORY")
toggle(pets_page, "Equip best", "Puts your best pets on your plot after new ones arrive", function() return S.equip_best end, function(v) S.equip_best = v end)
toggle(pets_page, "Leave worthless pets & eggs", "Full plot: pets that couldn't beat your weakest plot pet even as an Ancient Diamond stay on the ground (what auto sell deletes), and lower-stage eggs are skipped",
    function() return S.skip_junk end, function(v) S.skip_junk = v end)
toggle(pets_page, "Take others' good pets", "Picks up good pets other players left on the ground (the game lets anyone take them)",
    function() return S.take_others end, function(v) S.take_others = v end)
toggle(pets_page, "Grow babies", "Full plot: ranks pets by what they'll earn as Ancient, so a baby that will out-earn your weakest plot pet takes its spot",
    function() return S.grow_babies end, function(v) S.grow_babies, S.last_grow = v, 0 end)
segmented(pets_page, "Swap only when the new pet has earned more within", { { 24, "1 day" }, { 72, "3 days" }, { 168, "1 week" } },
    function() return S.grow_hours end, function(v) S.grow_hours, S.last_grow = v, 0 end)
toggle(pets_page, "Auto mutate", "3 of the same pet become 1 Golden or Diamond (keeps your heaviest)",
    function() return S.auto_mutate end, function(v)
        S.auto_mutate = v
        table.clear(S.fuse_fail)
    end)
action(pets_page, "Equip best now", "Same as the game's Equip Best button", "EQUIP", function()
    if not equip_remote then notify("Equip best isn't available.") return end
    task.spawn(function()
        local ok, answer = pcall(function() return equip_remote:InvokeServer() end)
        notify(ok and type(answer) == "table" and answer.Success and "Equipped your best pets." or "Equip best is on cooldown, try again in a moment.")
    end)
end)
local pet_info = info(pets_page, 96)
action(pets_page, "Copy hatched pets", "Every pet you hatched this session and what happened to it, plus all you own", "COPY", function()
    if typeof(setclipboard) ~= "function" then notify("This executor can't copy to the clipboard.") return end
    setclipboard(hatched_report())
    save_hatched()
    notify(("Copied %d hatched pets and your whole inventory. Paste it to Claude."):format(#S.hatched))
end)

-- [[ advisor lists: rebuilt every few seconds from your pet data ]] --
local function list_card(p, title_text, desc)
    section(p, title_text)
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card,
        LayoutOrder = next_order(), Parent = p })
    corner(f, 10)
    outline(f, C.stroke, 1, 0.35)
    new("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14), Parent = f })
    new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
    if desc then label(f, desc, REG, 11, C.dim, { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 0, TextTruncate = Enum.TextTruncate.AtEnd }) end
    local rows = {}
    return function(items)
        for _, r in ipairs(rows) do r:Destroy() end
        table.clear(rows)
        if #items == 0 then items = { { "Nothing here right now", "" } } end
        for i, it in ipairs(items) do
            local row = new("Frame", { Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = i, Parent = f })
            label(row, it[1], BOLD, 12, C.text, { Size = UDim2.new(0.62, 0, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
            local v = label(row, it[2], BOLD, 12, C.white, { Position = UDim2.fromScale(0.62, 0), Size = UDim2.new(0.38, 0, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Right })
            gradient(v, 0)
            table.insert(rows, row)
        end
    end
end
local farm_advice = info(pets_page, 62)
local set_best = list_card(pets_page, "YOUR PLOT", "Every pet on it, best first: age (and when it grows), money now -> as Ancient, with your money bonus")
local set_bag = list_card(pets_page, "YOUR BACKPACK (best 15)", "Not placed, so not growing: money now -> the most it could ever make (Ancient + best mutation)")
local set_mutate = list_card(pets_page, "WORTH MUTATING NOW", "You have 3+, and mutated it would make your plot")
local set_collect = list_card(pets_page, "FARM MORE OF THESE", "1-2 copies; with 3 they'd be worth mutating")
local set_sell = list_card(pets_page, "USELESS EVEN IF MUTATED", "Sell these later: they can never make your plot")
local set_hatched = list_card(pets_page, "HATCHED THIS SESSION", "Newest first, and what happened to each one")
local function update_hatched()
    local rows = {}
    for i = #S.hatched, math.max(1, #S.hatched - 9), -1 do
        local r = S.hatched[i]
        local mutation = r.pet.Mutation and (tostring(r.pet.Mutation) .. " ") or ""
        table.insert(rows, { ("%s  %s%s  •  %s"):format(r.time, mutation, tostring(r.pet.Name), tostring(r.pet.Rarity)),
            (r.outcome:match("^(%a+)") or r.outcome) .. (r.income and ("  $" .. short(r.income) .. "/s") or "") })
    end
    set_hatched(rows)
end
local function pet_name(p)
    local mutation = p.Mutation and (tostring(p.Mutation) .. " ") or ""
    return ("%s%s  •  %s  •  %skg"):format(mutation, tostring(p.Name), tostring(p.Rarity or "?"), short(p.Weight))
end
-- [[ Leaderboard: the game's own Top Money and Top Speed boards are global (every server) and keep their whole ]] --
-- [[ top 100 on the board model (Entries: user id, name, value), so all of it is listed here, with where you   ]] --
-- [[ stand. Plus every player in this server: their plot income and best pets (from their plot, so only this  ]] --
-- [[ server; nobody's inventory can be seen from outside). Refreshed every 5s while this tab is open.          ]] --
do
    local AgeCfg = load_module({ "Shared", "Configs", "PetAgeConfig" })
    local STAGES = AgeCfg and type(AgeCfg.Stages) == "table" and AgeCfg.Stages or {}
    local standing = info(board_page, 60)
    local set_money = list_card(board_page, "TOP MONEY (ALL SERVERS, TOP 100)", "The game's own board; Roblox updates it every few minutes")
    local set_speed = list_card(board_page, "TOP SPEED (ALL SERVERS, TOP 100)", "The game's own board")
    local set_here = list_card(board_page, "PLAYERS IN THIS SERVER", "Plot income, and the best 3 pets on each plot (plots far away may not be loaded)")
    local function entries(model_name)
        local folder = workspace:FindFirstChild("Leaderboards")
        local m = folder and folder:FindFirstChild(model_name)
        local raw = m and m:GetAttribute("Entries")
        if type(raw) ~= "string" then return {}, nil end
        local ok, list = pcall(function() return HttpService:JSONDecode(raw) end)
        return ok and type(list) == "table" and list or {}, raw
    end
    local function my_stat(name)
        local ok, v = pcall(function() return PlayerData and PlayerData.Get(name) end)
        if ok and tonumber(v) then return tonumber(v) end
        return tonumber(me:GetAttribute(name))
    end
    local function plot_of(p)
        local plots = game_folder("Plots")
        return plots and plots:FindFirstChild(tostring(p:GetAttribute("Plot")))
    end
    local function age_name(v)
        if type(v) == "number" and STAGES[v] then return tostring(STAGES[v].Name) end
        if type(v) == "string" then return v end
        return "Baby"
    end
    local function cash(v) return "$" .. short(v) .. "/s" end
    local function standing_text(list, mine, fmt, title_text)
        if not mine then return title_text .. ": <b>?</b>" end
        for i, e in ipairs(list) do
            if tonumber(e.u) == me.UserId then return ("%s: <b>#%d</b> with %s"):format(title_text, i, fmt(mine)) end
        end
        if #list == 0 then return ("%s: %s (board not loaded yet)"):format(title_text, fmt(mine)) end
        local above = 0
        for _, e in ipairs(list) do
            if (tonumber(e.v) or 0) > mine then above += 1 end
        end
        if above < #list then
            return ("%s: %s, that's about <b>#%d</b> (the board catches up every few minutes)"):format(title_text, fmt(mine), above + 1)
        end
        local last = tonumber(list[#list].v) or 0
        return ("%s: %s, not in the top %d yet: #%d has %s (<b>%.1fx</b> yours)"):format(title_text, fmt(mine), #list, #list, fmt(last),
            last / math.max(mine, 1))
    end
    local function board_rows(list, fmt)
        local rows = {}
        for i, e in ipairs(list) do
            table.insert(rows, { ("#%d  @%s%s"):format(i, tostring(e.n), tonumber(e.u) == me.UserId and "   <- you" or ""), fmt(tonumber(e.v) or 0) })
        end
        return rows
    end
    local function here_rows()
        local list = {}
        for _, p in ipairs(Players:GetPlayers()) do
            local plot = plot_of(p)
            local pets = {}
            local folder = plot and plot:FindFirstChild("PlacedAnimals", true)
            for _, m in ipairs(folder and folder:GetChildren() or {}) do
                if m:IsA("Model") then
                    table.insert(pets, { name = tostring(m:GetAttribute("AnimalName") or m.Name), rarity = tostring(m:GetAttribute("Rarity") or "?"),
                        mutation = m:GetAttribute("Mutation"), tier = m:GetAttribute("SizeTier"), age = age_name(m:GetAttribute("Age")),
                        income = tonumber(m:GetAttribute("IncomePerSecond")) or 0 })
                end
            end
            table.sort(pets, function(a, b) return a.income > b.income end)
            local sum = 0
            for _, x in ipairs(pets) do sum += x.income end
            table.insert(list, { p = p, income = tonumber(plot and plot:GetAttribute("CashPerSecond")) or sum, pets = pets })
        end
        table.sort(list, function(a, b) return a.income > b.income end)
        local rows = {}
        for _, x in ipairs(list) do
            table.insert(rows, { ("@%s%s  •  %s  •  %s appeal"):format(x.p.Name, x.p == me and " (you)" or "",
                #x.pets > 0 and (#x.pets .. " pets placed") or "plot not loaded", short(tonumber(x.p:GetAttribute("Power")) or 0)), cash(x.income) })
            for i = 1, math.min(3, #x.pets) do
                local pet = x.pets[i]
                table.insert(rows, { ("      %s%s  •  %s  •  %s%s"):format(pet.mutation and (tostring(pet.mutation) .. " ") or "", pet.name, pet.rarity,
                    pet.age, pet.tier and ("  •  " .. tostring(pet.tier)) or ""), cash(pet.income) })
            end
        end
        return rows
    end
    local money_raw, speed_raw, last_t = nil, nil, -100
    table.insert(painters, function()
        if W.current ~= "Leaderboard" or os.clock() - last_t < 5 then return end
        last_t = os.clock()
        local money_list, m_raw = entries("Top Money")
        local speed_list, s_raw = entries("Top Speed")
        local plot = plot_of(me)
        local my_income = my_stat("Income") or tonumber(plot and plot:GetAttribute("CashPerSecond"))
        standing.Text = standing_text(money_list, my_income, cash, "Top Money") .. "\n" .. standing_text(speed_list, my_stat("Speed"), short, "Top Speed")
        if m_raw ~= money_raw then
            money_raw = m_raw
            set_money(board_rows(money_list, cash))
        end
        if s_raw ~= speed_raw then
            speed_raw = s_raw
            set_speed(board_rows(speed_list, short))
        end
        set_here(here_rows())
    end)
end
-- [[ every amount here is shown with your money bonus (rebirths +0.5x each, friends, passes) so it matches the game: ]] --
-- [[ the bonus is the game's own plot total (CashPerSecond) divided by what the pets on it earn on their own        ]] --
local bonus = 1
local function money(n) return "$" .. short((tonumber(n) or 0) * bonus) .. "/s" end
local function refresh_advisor()
    local r = pet_report()
    if not r then
        farm_advice.Text = "Couldn't read your pets yet."
        return
    end
    local placed, bag = {}, {}
    for _, x in ipairs(r.list) do table.insert(is_placed(x.rec) and placed or bag, x) end
    local raw = 0
    for _, x in ipairs(placed) do raw += x.now end
    local plots = game_folder("Plots")
    local plot = plots and plots:FindFirstChild(tostring(me:GetAttribute("Plot")))
    local cps = tonumber(plot and plot:GetAttribute("CashPerSecond"))
    local ratio = cps and raw > 0 and cps / raw or nil
    bonus = (ratio and ratio > 0.99 and ratio < 1000) and ratio or (1 + 0.5 * (tonumber(me:GetAttribute("Rebirths")) or 0))
    local plot_rows, top = {}, 0
    for _, x in ipairs(placed) do
        local anc = S.ancient_of and S.ancient_of(x.rec) or x.now
        top += anc
        table.insert(plot_rows, { ("%s  •  %s"):format(pet_name(x.rec), S.age_info and S.age_info(x.rec) or "?"), ("%s -> %s"):format(money(x.now), money(anc)) })
    end
    set_best(plot_rows)
    table.sort(bag, function(a, b) return (S.rec_value and S.rec_value(a.rec) or a.now) > (S.rec_value and S.rec_value(b.rec) or b.now) end)
    local bag_rows = {}
    for i = 1, math.min(15, #bag) do
        local x = bag[i]
        table.insert(bag_rows, { ("%s  •  %s"):format(pet_name(x.rec), S.age_info and S.age_info(x.rec, true) or "?"),
            ("%s -> %s"):format(money(x.now), money(S.rec_value and S.rec_value(x.rec) or x.now)) })
    end
    if #bag > 15 then table.insert(bag_rows, { ("...and %d more in your backpack"):format(#bag - 15), "" }) end
    set_bag(bag_rows)
    local m = {}
    for i = 1, math.min(6, #r.mutate) do table.insert(m, { ("%s  x%d"):format(r.mutate[i].name, r.mutate[i].n), "up to " .. money(r.mutate[i].potential) }) end
    set_mutate(m)
    local c = {}
    for i = 1, math.min(6, #r.collect) do table.insert(c, { ("%s  x%d"):format(r.collect[i].name, r.collect[i].n), "up to " .. money(r.collect[i].potential) }) end
    set_collect(c)
    local s = {}
    for i = 1, math.min(8, #r.sell) do table.insert(s, { pet_name(r.sell[i].rec), money(r.sell[i].now) }) end
    if #r.sell > 8 then table.insert(s, { ("...and %d more"):format(#r.sell - 8), "" }) end
    set_sell(s)
    farm_advice.Text = ("Your plot: <b>%d</b> pets making <b>%s</b> now, <b>%s</b> once all are Ancient (money bonus x%.2f).\n"
        .. "You own <b>%d</b> pets (%d in your backpack); a pet must beat <b>%s</b> to be on your plot.%s"):format(#placed, money(raw), money(top), bonus,
        #r.list, #bag, money(r.cut), r.best_stage and ("  Best stage to farm: <b>%s</b>."):format(tostring(r.best_stage)) or "")
end

-- [[ Menus: every menu the game has, openable from anywhere ]] --
section(menus_page, "GAME MENUS")
local menu_grid_card = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card,
    LayoutOrder = next_order(), Parent = menus_page })
corner(menu_grid_card, 10)
outline(menu_grid_card, C.stroke, 1, 0.35)
new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = menu_grid_card })
new("UIGridLayout", { CellSize = UDim2.fromOffset(132, 30), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.Name, Parent = menu_grid_card })
-- [[ click a menu to open it, click it again to close it (forced, for the ones that won't close). ]] --
-- [[ An open menu's button gets a glowing outline.                                                 ]] --
local menu_buttons = {}
local function paint_menus()
    for name, x in pairs(menu_buttons) do
        local open = menu_is_open(name)
        x.stroke.Color = open and C.a2 or C.stroke
        x.stroke.Thickness = open and 1.6 or 1
    end
end
local function build_menus()
    for _, c in ipairs(menu_grid_card:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    table.clear(menu_buttons)
    for _, name in ipairs(menu_names()) do
        local b = new("TextButton", { Name = name, BackgroundColor3 = C.bg, AutoButtonColor = false, Text = name, Font = BOLD, TextSize = 12,
            TextColor3 = C.text, TextTruncate = Enum.TextTruncate.AtEnd, Parent = menu_grid_card })
        corner(b, 7)
        menu_buttons[name] = { button = b, stroke = outline(b, C.stroke, 1, 0) }
        b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = C.card2 }) end)
        b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = C.bg }) end)
        b.MouseButton1Click:Connect(function()
            if menu_is_open(name) then close_menu(name) else open_menu(name) end
            task.delay(0.3, paint_menus)
        end)
    end
    paint_menus()
end
action(menus_page, "Refresh the list", "If a menu is missing, the game may not have loaded it yet", "REFRESH", build_menus)
action(menus_page, "Close every menu", "Forces all of the game's menus shut", "CLOSE ALL", function()
    for name in pairs(menu_buttons) do
        if menu_is_open(name) then close_menu(name) end
    end
    task.delay(0.3, paint_menus)
end)
section(menus_page, "ADMIN")
local admin_info = info(menus_page, 58)
action(menus_page, "Admin command bar", "Opens the game's admin bar; the server decides if commands run", "OPEN", open_admin_bar)
-- [[ Leaderboards: the boards at spawn (Workspace.Leaderboards, top 100 kept in each board's Entries attribute) ]] --
-- [[ shown in a window on your screen, updating live. Click the same board again (or the X) to close it.        ]] --
section(menus_page, "LEADERBOARDS")
do
    local formats = { ["Top Money"] = "$%s/s", ["Top Speed"] = "%s" }
    pcall(function()
        local ok, lc = pcall(require, RS:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild("LeaderboardConfig", 3))
        if ok and type(lc) == "table" and type(lc.Boards) == "table" then
            for _, b in ipairs(lc.Boards) do
                if type(b) == "table" and b.Model then formats[b.Model] = b.Format or "%s" end
            end
        end
    end)
    local board = { panel = nil, name = nil, conn = nil }
    local function close_board()
        if board.conn then board.conn:Disconnect() end
        if board.panel then board.panel:Destroy() end
        board.panel, board.name, board.conn = nil, nil, nil
    end
    local function open_board(name)
        if board.name == name then close_board() return end
        close_board()
        local folder = workspace:FindFirstChild("Leaderboards")
        local model = folder and folder:FindFirstChild(name)
        if not model then notify("The " .. name .. " board isn't loaded yet, try again in a moment.") return end
        board.name = name
        local panel = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(360, math.min(470, W.L.h)), BackgroundColor3 = C.card, ZIndex = 25, Parent = gui })
        board.panel = panel
        W.follow(new("UIScale", { Scale = W.L.s, Parent = panel }))
        corner(panel, 12)
        new("UIGradient", { Color = W.ACCENT, Parent = outline(panel, C.white, 1.2, 0.2) })
        label(panel, name, BOLD, 16, C.text, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -60, 0, 24) })
        local sub = label(panel, "", REG, 11, C.dim, { Position = UDim2.fromOffset(16, 34), Size = UDim2.new(1, -32, 0, 16) })
        local x = new("TextButton", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 10), Size = UDim2.fromOffset(28, 28),
            BackgroundColor3 = C.bg, AutoButtonColor = false, Text = "X", Font = BOLD, TextSize = 13, TextColor3 = C.dim, Parent = panel })
        corner(x, 7)
        x.MouseButton1Click:Connect(close_board)
        local list = new("ScrollingFrame", { Position = UDim2.fromOffset(10, 58), Size = UDim2.new(1, -20, 1, -68), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 4, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = panel })
        new("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
        local function fill()
            for _, c in ipairs(list:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            local ok, entries = pcall(function() return HttpService:JSONDecode(model:GetAttribute("Entries") or "[]") end)
            if not ok or type(entries) ~= "table" then entries = {} end
            local mine = nil
            for i, e in ipairs(entries) do
                local me_row = tonumber(e.u) == me.UserId
                if me_row then mine = i end
                local row = new("Frame", { Size = UDim2.new(1, -6, 0, 26), BackgroundColor3 = me_row and C.white or C.bg,
                    BackgroundTransparency = me_row and 0.8 or 0, LayoutOrder = i, Parent = list })
                corner(row, 6)
                label(row, "#" .. i, BOLD, 12, i <= 3 and C.text or C.dim, { Position = UDim2.fromOffset(8, 0), Size = UDim2.new(0, 40, 1, 0) })
                label(row, "@" .. tostring(e.n), REG, 12, C.text, { Position = UDim2.fromOffset(48, 0), Size = UDim2.new(1, -160, 1, 0),
                    TextTruncate = Enum.TextTruncate.AtEnd })
                label(row, (formats[name] or "%s"):format(short(tonumber(e.v) or 0)), BOLD, 12, C.text, { AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -8, 0, 0), Size = UDim2.new(0, 110, 1, 0), TextXAlignment = Enum.TextXAlignment.Right })
            end
            sub.Text = #entries == 0 and "Nobody yet"
                or mine and ("You're #%d of the top %d"):format(mine, #entries)
                or ("Top %d (you're not on it yet)"):format(#entries)
        end
        pcall(fill)
        board.conn = track(model:GetAttributeChangedSignal("Entries"):Connect(function() pcall(fill) end))
    end
    local names = {}
    local folder = workspace:FindFirstChild("Leaderboards")
    for _, m in ipairs(folder and folder:GetChildren() or {}) do
        if m:GetAttribute("Entries") ~= nil then table.insert(names, m.Name) end
    end
    if #names == 0 then names = { "Top Money", "Top Speed" } end
    table.sort(names)
    for _, name in ipairs(names) do
        action(menus_page, name, "The " .. name .. " board from spawn, on your screen (click again to close)", "OPEN", function() open_board(name) end)
    end
end
task.defer(build_menus)
task.spawn(function()
    local yes = is_admin()
    admin_info.Text = yes == nil and "Couldn't check your admin status."
        or yes and "The game says you <b>are</b> an admin: the bar's commands should work."
        or "The game has an admin bar (opened with its own key for admins). You're <b>not</b> on its admin list, and every command "
            .. "is checked on the server, so commands from the bar will be refused."
end)

section(pets_page, "AUTO SELL (off until you turn it on)")
toggle(pets_page, "Auto sell useless pets", "Every 5 min. Never pets on your plot, your top ones, or ones a mutation could make good",
    function() return S.auto_sell end, function(v)
        S.auto_sell = v
        logf("SELL", "auto sell turned " .. (v and "ON" or "OFF"))
    end)
toggle(pets_page, "Sell what can never make your plot", "Same rule as pets left on the ground: can't beat your weakest plot pet even as an Ancient Diamond (Titanic, locked and favourited pets kept)",
    function() return S.sell_floor end, function(v) S.sell_floor = v end)
segmented(pets_page, "Sell when it earns this much less than your weakest plot pet", { { 20, "20x less" }, { 100, "100x less" }, { 1000, "1000x less" } },
    function() return S.sell_ratio end, function(v) S.sell_ratio = v end)
toggle(pets_page, "Also sell pets unused for 24h", "Only if it's worse than every pet on your plot and a mutation can't fix that",
    function() return S.sell_old end, function(v) S.sell_old = v end)
action(pets_page, "Preview auto sell", "Lists what would be sold right now (Logs tab + clipboard), sells nothing", "PREVIEW", function()
    task.spawn(function()
        local ok, plan, info = pcall(S.sell_plan)
        if not ok then notify("Preview failed: " .. tostring(plan):sub(1, 60)) return end
        local lines = { ("Auto sell preview: %d pets | %s"):format(#plan, tostring(info)) }
        for _, x in ipairs(plan) do
            table.insert(lines, ("  %s%s  $%s/s  (%s)"):format(x.mutation and (tostring(x.mutation) .. " ") or "", x.name, short(x.income), x.why))
        end
        for _, l in ipairs(lines) do logf("SELL", "preview: " .. l) end
        if typeof(setclipboard) == "function" then pcall(setclipboard, table.concat(lines, "\n")) end
        notify(#plan == 0 and ("Nothing to sell: " .. tostring(info)) or ("%d pets would be sold, list copied and in the Logs tab"):format(#plan))
    end)
end)
action(pets_page, "Sell them now", "Sells exactly what Preview lists, once", "SELL", function()
    task.spawn(function()
        local ok, plan, info = pcall(S.sell_plan)
        if not ok or type(plan) ~= "table" or #plan == 0 then notify("Nothing to sell: " .. tostring(ok and info or plan)) return end
        local n = S.sell_now(plan)
        notify(("Sold %d pets (details in the Logs tab)"):format(n))
    end)
end)

-- [[ Speed ]] --
local speed_stats = stats(speed_page, { "Speed", "Per step", "Training" })
section(speed_page, "TREADMILL")
toggle(speed_page, "Speed first", "With Auto farm on: trains on your treadmill and only leaves for event eggs, good pets, thieves and Luck / Mutation boosts",
    function() return S.speed_first end, function(v) S.speed_first = v end)
toggle(speed_page, "Mog from the treadmill", "Stays on the treadmill (speed keeps coming) while it click-TPs to eggs; gets off only to pick up a good pet",
    function() return S.mill_mog end, function(v)
        S.mill_mog = v
        S.mill_mog_logged = nil
    end, "mill_mog")
toggle(speed_page, "Auto treadmill", "Stand on your treadmill whenever the farm doesn't need you",
    function() return S.treadmill end, function(v)
        S.treadmill = v
        if not v and on_treadmill() and not S.farm then task.spawn(dismount) end
    end)
toggle(speed_page, "Walk around while training", "Your body stays on the treadmill training; you walk as a ghost only you see (WASD, Space). Farm must be off",
    function() return S.ghost_active == true end, function(v)
        if not v then
            if S.ghost_off then S.ghost_off("you turned it off") end
            return
        end
        if S.farm then notify("Turn Auto farm off first: the farm moves your body off the treadmill.") return end
        go(function()
            if not on_treadmill() then
                S.status = "Getting on your treadmill"
                if not mount() then notify("Couldn't get on your treadmill.") return end
                task.wait(0.5)
            end
            if not (S.ghost_on and S.ghost_on()) then notify("Couldn't make the ghost to walk around with.") end
        end)
    end)
local speed_info = info(speed_page, 80)
-- [[ live: your speed, what a step gives (one every 0.3s on the treadmill), and how long until the next rebirth ]] --
-- [[ (needs 1M x 10^rebirths speed, gives +0.5x money)                                                        ]] --
table.insert(painters, function()
    local ok, v = pcall(function() return PlayerData and PlayerData.Get("Speed") end)
    local speed = (ok and tonumber(v)) or tonumber(me:GetAttribute("Speed")) or 0
    local reb = tonumber(me:GetAttribute("Rebirths")) or 0
    local need = 1e6 * 10 ^ reb
    local gain = tonumber(S.step_gain) or tonumber(me:GetAttribute("SpeedMultiplier")) or 0
    local rate = gain / 0.3
    local eta = "-"
    if speed >= need then
        eta = "<b>ready now</b>"
    elseif rate > 0 then
        local s = (need - speed) / rate
        eta = s >= 86400 and ("about <b>%.1f days</b> on the treadmill"):format(s / 86400)
            or ("about <b>%dh %dm</b> on the treadmill"):format(s // 3600, (s % 3600) // 60)
    end
    speed_info.Text = ("Speed <b>%s</b>   |   each step <b>+%s</b> (about <b>%s/s</b> while on the treadmill)\n"
        .. "Next rebirth at <b>%s</b> speed (money x%.1f -> x%.1f): %s\n"
        .. "Speed only comes while you stand on your treadmill: the server gives one step every 0.3s, spamming adds nothing.")
        :format(short(speed), short(gain), short(rate), short(need), 1 + 0.5 * reb, 1.5 + 0.5 * reb, eta)
end)

-- [[ Upgrades: every automatic purchase / claim, each with its own switch ]] --
section(upgrades_page, "AUTO UPGRADES (in-game cash only, checked every 20s; switch any off)")
toggle(upgrades_page, "Auto ascend", "Buys your next body when you can afford it: more appeal, more instant mogs",
    function() return S.auto_ascend end, function(v) S.auto_ascend = v end)
toggle(upgrades_page, "Auto rebirth", "Rebirths as soon as your speed is enough: +0.5x money, +0.1x luck (resets speed only)",
    function() return S.auto_rebirth end, function(v) S.auto_rebirth = v end)
toggle(upgrades_page, "Auto pen upgrade", "One more pet earning on your plot per level, up to level 9",
    function() return S.auto_pen end, function(v) S.auto_pen = v end)
toggle(upgrades_page, "Auto coach", "Buys the best coach you can afford (more speed per step)",
    function() return S.auto_coach end, function(v) S.auto_coach = v end)
toggle(upgrades_page, "Auto aura", "Buys the best aura you can afford (speed multiplier)",
    function() return S.auto_aura end, function(v) S.auto_aura = v end)
toggle(upgrades_page, "Auto treadmill upgrade", "Levels up your treadmill whenever you can afford the next level",
    function() return S.auto_mill_upgrade end, function(v) S.auto_mill_upgrade = v end)
toggle(upgrades_page, "Claim index rewards", "Free cash and speed for every new animal you hatch",
    function() return S.auto_index end, function(v) S.auto_index = v end)
toggle(upgrades_page, "Claim daily reward", "Claims it when it's due: pets from day 2, a Diamond Big pet on days 6 and 7",
    function() return S.auto_daily end, function(v) S.auto_daily = v end)
toggle(upgrades_page, "Decline mog battles", "Says no to battle invites while the farm runs, so it isn't stopped",
    function() return S.decline_battles end, function(v) S.decline_battles = v end)

-- [[ Teleport: same safe moves as the farm (it waits for the ground to load, so you don't fall through) ]] --
local function manual_teleport(fn)
    if S.manual then notify("Busy with a steal, try again in a moment.") return end
    if S.farm or S.treadmill then
        S.farm, S.treadmill = false, false
        S.farm_off_by = "turned off because you used a teleport button"
        logf("FARM", "turned OFF because you used a teleport button")
        notify("Auto farm and Auto treadmill are off while you move around yourself.")
    end
    S.manual = true
    go(function()
        local ok, err = pcall(fn)
        if not ok then notify("Teleport failed: " .. tostring(err):sub(1, 60)) end
        S.manual = false
        S.status = "Ready"
    end)
end
local function event_target()
    if S.titanic and os.clock() < S.titanic.until_t then return S.titanic.pos, "Titanic egg in " .. S.titanic.zone end
    for egg in pairs(all_eggs) do
        if egg.Parent and is_event(egg) and egg:GetAttribute("EggState") == "Idle" then
            return egg:GetPivot().Position, tostring(egg:GetAttribute("DisplayName") or egg.Name)
        end
    end
    return nil
end
section(tp_page, "QUICK")
action(tp_page, "Spawn", "Back to your base in the safe zone (banks a pet you're carrying)", "GO", function()
    manual_teleport(function()
        local spot = home_spots()[1]
        S.status = "Going to spawn"
        travel(spot)
        travel(ground(spot))
    end)
end)
action(tp_page, "Treadmill", "Onto your treadmill, training starts by itself (Space gets off)", "GO", function()
    manual_teleport(function() mount() end)
end)
section(tp_page, "MOVEMENT (pauses while Auto farm runs or you're on the treadmill)")
toggle(tp_page, "Fly", "WASD moves where the camera looks, Space up, Ctrl or Q down",
    function() return S.flying == true end, function(v) if S.fly_set then S.fly_set(v) end end)
segmented(tp_page, "Fly speed", { { 50, "50" }, { 100, "100" }, { 200, "200" }, { 400, "400" } },
    function() return S.fly_speed end, function(v) S.fly_speed = v end)
toggle(tp_page, "Walk speed", "Keeps your walk speed at the speed below; turning it off puts your normal speed back",
    function() return S.speed_on == true end, function(v) if S.speed_set then S.speed_set(v) end end)
segmented(tp_page, "Walk speed", { { 32, "32" }, { 60, "60" }, { 100, "100" }, { 200, "200" } },
    function() return S.walk_speed end, function(v) S.walk_speed = v end)
section(tp_page, "STAGES")
do
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card,
        LayoutOrder = next_order(), Parent = tp_page })
    corner(f, 10)
    outline(f, C.stroke, 1, 0.35)
    new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = f })
    new("UIGridLayout", { CellSize = UDim2.fromOffset(76, 34), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
    for i, name in ipairs(STAGE_NAMES) do
        local b = new("TextButton", { BackgroundColor3 = C.bg, AutoButtonColor = false, Text = "Stage " .. stage_num(name), Font = BOLD, TextSize = 12,
            TextColor3 = C.text, LayoutOrder = i, Parent = f })
        corner(b, 8)
        outline(b, C.stroke, 1, 0)
        local g = gradient(b, 0)
        g.Enabled = false
        b.MouseEnter:Connect(function() g.Enabled = true b.BackgroundColor3 = C.white end)
        b.MouseLeave:Connect(function() g.Enabled = false b.BackgroundColor3 = C.bg end)
        b.MouseButton1Click:Connect(function()
            manual_teleport(function()
                local center = stage_center(name)
                if not center then return end
                S.status = "Going to " .. name
                travel(ground(center), center + Vector3.new(0, 0, -10))
            end)
        end)
    end
end
section(tp_page, "EVENT")
do
    local f = card(tp_page, 56)
    label(f, "Event egg", BOLD, 14, C.text, { Position = UDim2.fromOffset(14, 9), Size = UDim2.new(1, -120, 0, 18) })
    local desc = label(f, "", REG, 11, C.dim, { Position = UDim2.fromOffset(14, 28), Size = UDim2.new(1, -120, 0, 16),
        TextTruncate = Enum.TextTruncate.AtEnd })
    local b = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.fromOffset(92, 30),
        BackgroundColor3 = C.off, AutoButtonColor = false, Text = "LOCKED", Font = BOLD, TextSize = 12, TextColor3 = C.dim, Parent = f })
    corner(b, 8)
    local g = gradient(b, 0)
    g.Enabled = false
    b.MouseButton1Click:Connect(function()
        if not event_target() then notify("No event egg right now. Titanic eggs come every 30 minutes.") return end
        manual_teleport(function()
            local pos, name = event_target()
            if not pos then return end
            S.status = "Going to the " .. name
            travel(ground(pos + Vector3.new(0, 0, 25)), pos)
        end)
    end)
    table.insert(painters, function()
        local pos, name = event_target()
        g.Enabled = pos ~= nil
        b.BackgroundColor3 = pos and C.white or C.off
        set_text(b, pos and "GO" or "LOCKED", pos and C.white or C.dim)
        desc.Text = pos and name or "Unlocks when an event egg spawns (Titanic every 30 min)"
    end)
end

-- [[ Logs ]] --
local log_info = info(logs_page, 58)
log_info.Text = "Everything that happens is written down here: errors, the farm stopping and why, hits, falls, the treadmill, "
    .. "banked pets. It's also saved every minute to <b>MogHub_Log.txt</b> in Potassium's workspace folder."
action(logs_page, "Copy log", "Copies the whole log to paste to Claude", "COPY", function()
    if typeof(setclipboard) ~= "function" then notify("This executor can't copy to the clipboard.") return end
    setclipboard(log_report())
    save_log()
    notify("Log copied. Paste it to Claude.")
end)
action(logs_page, "Check now", "Writes down right now why you're standing where you are", "CHECK", function()
    logf("CHECK", why_here())
    notify("Written to the log.")
end)
action(logs_page, "Clear log", "Starts the log fresh", "CLEAR", function()
    table.clear(S.log)
    table.clear(S.status_log)
    logf("START", "log cleared")
end)
section(logs_page, "LATEST")
local log_view
do
    local f = card(logs_page, 250)
    log_view = label(f, "", W.MONO, 11, C.dim, { Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 1, -16),
        TextYAlignment = Enum.TextYAlignment.Top, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd })
end

-- [[ Settings ]] --
section(settings_page, "WINDOW")
local keys_info = info(settings_page, 44)
keys_info.Text = "<b>Right Alt</b> or the <b>–</b> button hides the window. While it's hidden, the round <b>S</b> button brings it back "
    .. "(drag it anywhere; on a phone that's the way back). The window sizes itself to your screen and follows it when the screen changes."
segmented(settings_page, "Window size", { { 0.85, "Small" }, { 1, "Normal" }, { 1.15, "Large" } },
    function() return S.ui_size end, function(v)
        S.ui_size = v
        W.layout(true)
    end)
toggle(settings_page, "Boot animation", "The glitch intro when the hub loads (a short one after a server hop)",
    function() return S.boot_anim end, function(v) S.boot_anim = v end)
action(settings_page, "Replay the intro", "Plays the boot animation again", "PLAY", function()
    W.hide()
    task.delay(0.25, function() pcall(play_boot, W, W.show, false) end)
end)
action(settings_page, "Unload", "Turns everything off and removes the window", "UNLOAD", function() if env.mog_helper_stop then env.mog_helper_stop() end end)
W.credits(settings_page)

---------------------------------------------------------------- toasts

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
    new("UIGradient", { Color = W.ACCENT, Parent = outline(t, C.white, 1, 0.35) })
    local bar = new("Frame", { Position = UDim2.fromOffset(0, 10), Size = UDim2.new(0, 3, 1, -20), BackgroundColor3 = C.white, BorderSizePixel = 0, Parent = t })
    corner(bar, 2)
    gradient(bar, 90)
    local head = label(t, "SOBRIETY", W.BRAND, 9, C.white, { Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -20, 0, 12) })
    gradient(head, 0)
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

---------------------------------------------------------------- live numbers

local function speed_text()
    local ls = me:FindFirstChild("leaderstats")
    local v = ls and ls:FindFirstChild("Speed")
    return v and tostring(v.Value) or "-"
end
local function refresh()
    if not gui.Parent then return end
    for _, paint in ipairs(painters) do pcall(paint) end
    local egg = pick_egg()
    status_text.Text = S.status
    next_text.Text = "Next: " .. (egg and ("%s%s  •  %s appeal%s"):format(is_event(egg) and "EVENT " or "", egg:GetAttribute("DisplayName") or egg.Name,
        short(appeal_of(egg)), is_instant(egg) and "  •  instant" or "") or "no free egg loaded nearby")
        .. (S.titanic and ("   |   Titanic up in " .. S.titanic.zone) or "")
    dot.BackgroundColor3 = (S.farm or S.treadmill) and C.good or C.dim
    farm_stats.Banked.Text = tostring(S.delivered)
    farm_stats.Hatching.Text = tostring(#S.hatching)
    farm_stats.Mutated.Text = tostring(S.mutated)
    farm_stats.Appeal.Text = short(power())
    pet_stats.Banked.Text = tostring(S.delivered)
    pet_stats.Mutated.Text = tostring(S.mutated)
    pet_stats["Last pet"].Text = S.last and S.last:match("^(%S+)") or "-"
    pet_info.Text = ("Last banked: <b>%s</b>   |   Last mutate: <b>%s</b>   |   Gifted: <b>%d</b>\nGrowing (%d swapped): <b>%s</b>\n"
        .. "Left on the ground: <b>%d</b>   |   Taken from others: <b>%d</b>   |   Keep bar: <b>$%s/s</b>"):format(
        S.last or "-", S.last_mutate or "-", S.gifted_count, S.grow_swaps, S.grow_babies and S.grow_note or "off",
        S.skipped_count, S.free_count, short(S.keep_floor and S.keep_floor() or 0))
    if S.status ~= S.logged_status then
        S.logged_status = S.status
        table.insert(S.status_log, os.date("%H:%M:%S") .. "  " .. S.status)
        if #S.status_log > 400 then table.remove(S.status_log, 1) end
    end
    if W.current == "Menus" then pcall(paint_menus) end
    if W.current == "Logs" then
        local tail = {}
        for i = math.max(1, #S.log - 15), #S.log do table.insert(tail, S.log[i]) end
        log_view.Text = table.concat(tail, "\n")
    end
    mog_info.Text = ("Instant mog works on eggs up to <b>%s</b> appeal (yours is %s, the server allows half). Bigger eggs are fights, "
        .. "which Always win and Skip fights handle."):format(short(power() / INSTANT_RATIO), short(power()))
    speed_stats.Speed.Text = speed_text()
    speed_stats["Per step"].Text = short(me:GetAttribute("SpeedMultiplier"))
    speed_stats.Training.Text = on_treadmill() and "YES" or "NO"
    me_sub.Text = short(power()) .. " appeal  •  " .. S.delivered .. " banked"
    if W.current == "Pets" and os.clock() - (S.advised_at or 0) > 4 then
        S.advised_at = os.clock()
        pcall(refresh_advisor)
        pcall(update_hatched)
    end
end

---------------------------------------------------------------- window start

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

-- [[ Unload: stops every job right where it is (the farm included, even mid-jump or mid-take), then puts the ]] --
-- [[ game back exactly as it was: its fight code, the call hook, Auto Mog, the idle kick and knock handlers.  ]] --
-- [[ Your saved settings, log and hatch book files stay.                                                      ]] --
env.mog_helper_stop = function()
    S.alive, S.farm, S.manual = false, false, false
    local here = coroutine.running()
    for _, th in ipairs(S.threads) do
        if th ~= here then pcall(task.cancel, th) end
    end
    if S.farm_thread and S.farm_thread ~= here then pcall(task.cancel, S.farm_thread) end
    logf("FARM", "helper unloaded")
    pcall(save_log)
    pcall(save_hatched)
    if S.clear_queue then pcall(S.clear_queue) end
    if S.ghost_off then pcall(S.ghost_off) end
    if S.thief_follow then pcall(function() S.thief_follow:Disconnect() end) S.thief_follow = nil end
    -- [[ a fight cut off mid-way never sent its result: finish it now, or the server keeps you AlreadyBusy and ]] --
    -- [[ the game's own MOG prompts fail for a minute and a half                                                ]] --
    pcall(function()
        for egg in pairs(all_eggs) do
            if egg.Parent and egg:GetAttribute("EggState") == "Challenged" and egg:GetAttribute("EggHolder") == me.UserId then
                local eid = egg:GetAttribute("EggId")
                if eid then S.resolve:FireServer(eid, true) end
            end
        end
    end)
    if PromptService and not PromptService.Enabled and S.prompt_gate and not S.prompt_gate.IsBlocked() then PromptService.Enabled = true end
    if S.fly_set then pcall(S.fly_set, false) end
    if S.speed_set then pcall(S.speed_set, false) end
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
    for _, c in ipairs(paused_idle) do pcall(function() c:Enable() end) end
    for _, c in ipairs(paused_knock) do pcall(function() c:Enable() end) end
    MogController.ResolveEnemy = original_resolve
    MogController.GetReady, MogController.Approach, MogController.Start = original_ready, original_approach, original_start
    env.mog_helper_resolve_original, env.mog_helper_ready_original = nil, nil
    env.mog_helper_approach_original, env.mog_helper_start_original = nil, nil
    pcall(function() me:SetAttribute("AutoMog", auto_original) end)
    -- [[ the call hook goes back to the game's own one ]] --
    local old_namecall = env.mog_helper_namecall_old
    if old_namecall and typeof(hookmetamethod) == "function" and pcall(hookmetamethod, game, "__namecall", old_namecall) then
        env.mog_helper_namecall_old, env.mog_helper_hooked = nil, nil
    end
    local root = root_part()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        if not on_treadmill() then root.Anchored = false end
    end
    if env.mog_helper_state == S then env.mog_helper_state = nil end
    pcall(function() gui:Destroy() end)
    env.mog_helper_stop = nil
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Sobriety Hub",
            Text = "Unloaded: everything it changed is back to normal.", Duration = 5 })
    end)
end

-- [[ Auto progress (in-game cash and free things only), checked every 20 seconds:                               ]] --
-- [[  * Ascend: buys the next body when you can afford it (more appeal = more instant mogs and higher eggs)      ]] --
-- [[  * Rebirth: as soon as your speed reaches the next one (+0.5x money, +0.1x luck each; it only resets speed) ]] --
-- [[  * Pen upgrade: one more pet earning on your plot per level, up to level 9                                  ]] --
-- [[  * Coach: the best coach you can afford (more speed per treadmill step, so faster rebirths)                 ]] --
-- [[  * Index: claims the free cash / speed rewards for every new animal you've hatched                          ]] --
-- [[ Also: offline earnings are claimed once when it loads, and mog battle invites are declined while farming.   ]] --
do
    local function invoke(ns, name, ...)
        local folder = Remotes:FindFirstChild(ns)
        local r = folder and folder:FindFirstChild(name)
        if not (r and r:IsA("RemoteFunction")) then return false, "missing" end
        local args = table.pack(...)
        return pcall(function() return r:InvokeServer(table.unpack(args, 1, args.n)) end)
    end
    local function worked(res) return type(res) == "table" and res.Success == true end
    local function why(res)
        if type(res) == "table" then return tostring(res.Reason or res.Message or "?") end
        return tostring(res)
    end
    -- [[ the first answer of each kind goes in the log, so a change on the game's side shows up there ]] --
    local function note(name, ok, res)
        if S.progress_seen[name] then return end
        S.progress_seen[name] = true
        local text = ok and type(res) == "table" and (pcall(function() return HttpService:JSONEncode(res) end) and HttpService:JSONEncode(res)) or tostring(res)
        logf("PROGRESS", ("%s first answer: %s"):format(name, tostring(text):sub(1, 200)))
    end
    -- [[ shops that sell one item at a time for Cash, read from the game's own configs (best first) ]] --
    local SHOPS = {
        { name = "coach", ns = "Coaches", config = "CoachConfig", list = "Coaches", value = "Boost", attr = "EquippedCoach", setting = "auto_coach" },
        { name = "aura", ns = "Auras", config = "AuraConfig", list = "Auras", value = "Multiplier", attr = "EquippedAura", setting = "auto_aura" },
    }
    for _, shop in ipairs(SHOPS) do
        shop.items = {}
        pcall(function()
            local ok, cfg = pcall(require, RS:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild(shop.config, 5))
            if ok and type(cfg) == "table" and type(cfg[shop.list]) == "table" then
                for _, c in ipairs(cfg[shop.list]) do
                    if type(c) == "table" and c.Id and tonumber(c[shop.value]) then table.insert(shop.items, c) end
                end
                table.sort(shop.items, function(a, b) return a[shop.value] > b[shop.value] end)
            end
        end)
    end
    -- [[ buys the best item better than the one you have; one you already own gets equipped instead ]] --
    local function buy_best(shop)
        local equipped, current = me:GetAttribute(shop.attr), -1
        for _, c in ipairs(shop.items) do
            if c.Id == equipped then current = c[shop.value] end
        end
        local okC, cash = false, nil
        if PlayerData then okC, cash = pcall(PlayerData.Get, "Cash") end
        cash = okC and tonumber(cash) or nil
        for _, c in ipairs(shop.items) do
            if c[shop.value] <= current then return end
            if cash and tonumber(c.Price) and tonumber(c.Price) > cash then continue end
            local ok, res = invoke(shop.ns, "Purchase", c.Id)
            note("Buy " .. shop.name, ok, res)
            if ok and worked(res) then
                logf("PROGRESS", ("bought %s %s (x%s)"):format(shop.name, tostring(c.Name or c.Id), tostring(c[shop.value])))
                notify(("Bought %s %s"):format(shop.name, tostring(c.Name or c.Id)))
                return
            end
            if ok and why(res):lower():find("own") then
                local okE, resE = invoke(shop.ns, "Equip", c.Id)
                if okE and worked(resE) then
                    logf("PROGRESS", ("equipped your best %s: %s"):format(shop.name, tostring(c.Name or c.Id)))
                    return
                end
            end
            task.wait(0.4)
        end
    end

    go(function()
        task.wait(4)
        local ok, res = invoke("Offline", "Claim")
        note("Offline earnings", ok, res)
        if ok and worked(res) then logf("PROGRESS", "claimed your offline earnings") end
    end)

    local battle = Remotes:FindFirstChild("MogBattle")
    local invite = battle and battle:FindFirstChild("Invite")
    local respond = battle and battle:FindFirstChild("Respond")
    if invite and respond and invite:IsA("RemoteEvent") and respond:IsA("RemoteEvent") then
        track(invite.OnClientEvent:Connect(function(from)
            if not (S.decline_battles and (S.farm or S.manual)) then return end
            task.defer(function() pcall(function() respond:FireServer(false) end) end)
            logf("BATTLE", "declined a mog battle invite from " .. tostring(typeof(from) == "Instance" and from.Name or from))
        end))
    end

    -- [[ max levels come from the game's own configs, so new levels added in an update are picked up; and any ]] --
    -- [[ upgrade the server calls maxed is paused for 30 minutes instead of being asked every 20 seconds       ]] --
    local function config(name)
        local ok, cfg = pcall(require, RS:WaitForChild("Shared"):WaitForChild("Configs"):WaitForChild(name, 5))
        return ok and type(cfg) == "table" and cfg or {}
    end
    local mill_cfg, pen_cfg = config("TreadmillConfig"), config("PlotUpgradeConfig")
    local MILL_MAX = type(mill_cfg.Levels) == "table" and #mill_cfg.Levels or nil
    local PEN_MAX = tonumber(pen_cfg.MaxLevel) or 9
    -- [[ can't afford it yet: paused until you have the amount (when the game says how much), otherwise until ]] --
    -- [[ your cash has grown by a quarter (or 10 minutes passed); coaches, auras and the pen use their prices  ]] --
    local function stat(name)
        if not PlayerData then return nil end
        local ok, v = pcall(PlayerData.Get, name)
        return ok and tonumber(v) or nil
    end
    local function broke(name)
        local w = S.broke[name]
        if not w then return false end
        local have = stat(w.stat)
        if (w.need and have and have >= w.need) or (not w.need and have and w.had and have >= w.had * 1.25) or os.clock() > w.until_t then
            S.broke[name] = nil
            logf("PROGRESS", name .. ": you can afford it now, trying again")
            return false
        end
        return true
    end
    local function check_money(name, ok, res, what)
        if not ok or worked(res) then return end
        local r = why(res):lower()
        if r:find("cash") or r:find("money") or r:find("afford") or r:find("enough") or r:find("slow") then
            local need = type(res) == "table" and tonumber(res.Requirement or res.Cost or res.Price) or nil
            if not S.broke[name] then
                logf("PROGRESS", ("%s: not enough %s yet%s, paused until you have it"):format(name, what:lower(),
                    need and (" (needs " .. short(need) .. ")") or ""))
            end
            S.broke[name] = { need = need, had = stat(what), stat = what, until_t = os.clock() + (need and 3600 or 600) }
        end
    end
    local function paused(name) return os.clock() < (S.maxed[name] or 0) or broke(name) end
    local function check_max(name, ok, res)
        if ok and not worked(res) and why(res):lower():find("max") then
            if not paused(name) then logf("PROGRESS", name .. " is at max level, paused (checked again in 30 min)") end
            S.maxed[name] = os.clock() + 1800
        end
    end

    go(function()
        while S.alive do
            task.wait(20)
            if S.auto_ascend and not paused("Ascend") then
                local before = power()
                local ok, res = invoke("Upgrades", "Ascend")
                note("Ascend", ok, res)
                check_max("Ascend", ok, res)
                check_money("Ascend", ok, res, "Cash")
                if ok and worked(res) then
                    task.wait(1)
                    logf("PROGRESS", ("ascended to a new body: appeal %s -> %s"):format(short(before), short(power())))
                    notify("Ascended! Appeal is now " .. short(power()))
                end
            end
            if S.auto_rebirth and not paused("Rebirth") then
                local ok, res = invoke("Rebirth", "Request")
                note("Rebirth", ok, res)
                check_money("Rebirth", ok, res, "Speed")
                if ok and worked(res) then
                    task.wait(1)
                    logf("PROGRESS", ("rebirthed: %s rebirths now"):format(tostring(me:GetAttribute("Rebirths"))))
                    notify("Rebirthed! " .. tostring(me:GetAttribute("Rebirths")) .. " rebirths.")
                end
            end
            local pen_level = tonumber(me:GetAttribute("PlotUpgradeLevel")) or 0
            local pen_cost = type(pen_cfg.Cost) == "table" and type(pen_cfg.Cost.Levels) == "table" and tonumber(pen_cfg.Cost.Levels[pen_level + 1]) or nil
            local cash_now = stat("Cash")
            if S.auto_pen and not paused("Pen") and pen_level < PEN_MAX and not (pen_cost and cash_now and cash_now < pen_cost) then
                local plots = game_folder("Plots")
                local plot = plots and plots:FindFirstChild(tostring(me:GetAttribute("Plot")))
                if plot then
                    local ok, res = invoke("PlotUpgrade", "Purchase", plot)
                    note("Pen upgrade", ok, res)
                    check_max("Pen", ok, res)
                    check_money("Pen", ok, res, "Cash")
                    if ok and worked(res) then
                        S.need_equip = true
                        task.wait(1)
                        logf("PROGRESS", ("upgraded your pen to level %s (one more pet on your plot)"):format(tostring(me:GetAttribute("PlotUpgradeLevel"))))
                    end
                end
            end
            for _, shop in ipairs(SHOPS) do
                if S[shop.setting] and #shop.items > 0 then pcall(buy_best, shop) end
            end
            -- [[ treadmill level: the game's own Upgrade sign (the server says no when it's maxed or too pricey) ]] --
            if S.auto_mill_upgrade and not paused("Treadmill") then
                local plots = game_folder("Plots")
                local plot = plots and plots:FindFirstChild(tostring(me:GetAttribute("Plot")))
                local mill = plot and plot:FindFirstChild("Treadmill")
                local before = mill and mill:GetAttribute("TreadmillLevel") or me:GetAttribute("TreadmillLevel")
                local at_max = MILL_MAX and tonumber(before) and tonumber(before) >= MILL_MAX
                if plot and not at_max then
                    local ok, res = invoke("Treadmill", "Upgrade", plot)
                    note("Treadmill upgrade", ok, res)
                    check_max("Treadmill", ok, res)
                    check_money("Treadmill", ok, res, "Cash")
                    if ok and worked(res) then
                        task.wait(1)
                        logf("PROGRESS", ("upgraded your treadmill: level %s -> %s"):format(tostring(before), tostring(mill and mill:GetAttribute("TreadmillLevel"))))
                    end
                end
            end
            if S.auto_index then
                local ok, res = invoke("Index", "ClaimAll")
                note("Index", ok, res)
                if ok and worked(res) then logf("PROGRESS", "claimed index rewards") end
            end
            -- [[ daily reward (pets from day 2, a Diamond Big one on days 6 and 7): claimed once it's due (24h after ]] --
            -- [[ the last claim, from your saved data), tried at most every 10 minutes                              ]] --
            if S.auto_daily and os.clock() - (S.daily_try or -1e9) > 600 then
                local last = stat("DailyLastClaim")
                if not last or workspace:GetServerTimeNow() - last >= 86400 then
                    S.daily_try = os.clock()
                    local ok, res = invoke("DailyRewards", "Claim")
                    note("Daily reward", ok, res)
                    if ok and worked(res) then
                        logf("PROGRESS", ("claimed the daily reward (day %s)"):format(tostring(stat("DailyDay") or "?")))
                        notify("Daily reward claimed!")
                    end
                end
            end
        end
    end)
end

-- [[ the farm runs on its own thread; the window and Auto Mog update on another ]] --
local function farm_loop()
    while S.alive do
        S.loop_tick = os.clock()
        if S.rejoining then
            S.status = "Disconnected, reconnecting"
            task.wait(0.5)
            continue
        end
        if S.farm and not S.manual then
            local ok, err = xpcall(farm_step, debug.traceback)
            if not ok then
                S.status = "Farm hiccup: " .. tostring(err):sub(1, 80)
                logf("ERROR", tostring(err):sub(1, 600))
                task.wait(1)
            end
            pcall(maybe_equip)
        elseif S.treadmill and not S.manual then
            -- [[ farm off: stay on the treadmill all the time (steps back on if you get knocked off) ]] --
            local ok, err = xpcall(train_for, debug.traceback, 5, function() return S.farm or not S.treadmill end, "Training on the treadmill")
            if not ok then
                logf("ERROR", "treadmill: " .. tostring(err):sub(1, 400))
                task.wait(1)
            end
        else
            task.wait(0.3)
        end
        task.wait()
    end
end
S.farm_thread = go(farm_loop)
S.restart_farm = function()
    if S.farm_thread and S.farm_thread ~= coroutine.running() then pcall(task.cancel, S.farm_thread) end
    -- [[ a step cut off mid-way can't clean up after itself: stay-on-the-treadmill and thief chases end here ]] --
    S.keep_mill = false
    if S.thief_follow then pcall(function() S.thief_follow:Disconnect() end) S.thief_follow = nil end
    S.farm_thread = go(farm_loop)
end

-- [[ watchdog: restarts the farm if it ever stops ticking, and frees the game's mog lock if a challenge got  ]] --
-- [[ stuck (a stuck lock blocks the farm and your own MOG! prompts too, until you rejoin)                    ]] --
local setupvalue = exec("setupvalue")
go(function()
    local busy_since, last_err = nil, nil
    while S.alive do
        task.wait(5)
        -- [[ one bad check (a game update renaming something) mustn't kill the watchdog for the rest of the night ]] --
        local okW, errW = pcall(function()
        if os.clock() - (S.loop_tick or os.clock()) > 100 then
            logf("WATCHDOG", "the farm stopped ticking for 100s, restarting it | " .. why_here())
            S.restart_farm()
            S.status = "Farm restarted after it got stuck"
            notify("The farm got stuck and was restarted.")
        end
        -- [[ the server has said AlreadyBusy for a minute straight and no open fight was found to finish: rejoining ]] --
        -- [[ this server resets it (once every 5 minutes at most; a private server can't be rejoined by a script).    ]] --
        -- [[ Not while pets are hatching, on the ground or in your hands, and only if the helper can reload itself.   ]] --
        local pets_out = #S.hatching > 0 or #S.pending > 0 or carrying() or S.event_hatch ~= nil
        if S.busy_first and os.clock() - (S.busy_last or 0) < 15 and os.clock() - S.busy_first > 60 and not pets_out
            and os.clock() - (S.busy_rejoin or -1e9) > 300 then
            S.busy_rejoin = os.clock()
            if S.queue_self then S.queue_self() end
            if not env.mog_helper_queued then
                logf("WATCHDOG", "the server says AlreadyBusy, but the helper couldn't queue itself to reload, so no rejoin")
            else
                logf("WATCHDOG", "the server has said AlreadyBusy for over a minute and no open fight was found: rejoining this server to reset it")
                notify("The server is stuck thinking you're mid-fight. Rejoining this server to reset it (in a private server, rejoin it yourself).")
                pcall(save_log)
                pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, me) end)
            end
        end
        local stuck = EggController.IsBusy() or MogController.IsFighting()
        busy_since = stuck and (busy_since or os.clock()) or nil
        if busy_since and os.clock() - busy_since > 100 then
            if typeof(getupvalues) == "function" and typeof(setupvalue) == "function" then
                pcall(function()
                    for i, v in pairs(getupvalues(EggController.IsBusy)) do
                        if v == true then setupvalue(EggController.IsBusy, i, false) end
                    end
                end)
            end
            if MogController.IsFighting() and type(MogController.Abort) == "function" then pcall(MogController.Abort) end
            busy_since = nil
            logf("WATCHDOG", "the game's mog lock was stuck for 100s, freed it")
            S.status = "Freed a stuck mog"
            notify("A mog got stuck in the game's code, it's been freed.")
        end
        -- [[ prompts left hidden after a fight or egg mog that was cut short (the game only turns them back on at ]] --
        -- [[ the very end of its own fight code): nothing is running, so its gate is cleared and they come back    ]] --
        local gate = S.prompt_gate
        if gate and PromptService.Enabled == false and not stuck and not down() then
            if S.gate_off_since == 0 then S.gate_off_since = os.clock() end
            if os.clock() - S.gate_off_since > 8 then
                for _, key in ipairs({ "Fight", "Egg", "Down" }) do pcall(gate.Set, key, false) end
                if not PromptService.Enabled then PromptService.Enabled = true end
                S.gate_off_since = 0
                logf("WATCHDOG", "the game's prompts were stuck hidden (a fight or egg mog was cut short), turned them back on")
            end
        else
            S.gate_off_since = 0
        end
        end)
        if not okW and errW ~= last_err then
            last_err = errW
            logf("ERROR", "watchdog: " .. tostring(errW):sub(1, 300))
        end
    end
end)
-- [[ Auto rejoin (every 20 minutes by default). Why: a pet only keeps its growth once the game writes it down,   ]] --
-- [[ and it does that when the pet leaves your plot or when you leave the server. Until then the growth is just   ]] --
-- [[ "aging since" in the server's memory, and a reset in between throws all of it away: a 12-hour night went    ]] --
-- [[ back to Baby (the hatch books show it: +51 seconds credited for 12 hours, while a clean leave credited every ]] --
-- [[ second). A clean rejoin writes it down, so the most that can ever be lost is the last 20 minutes.           ]] --
-- [[ When it's due, the farm stops starting new eggs, takes and banks everything still hatching or on the ground, ]] --
-- [[ and waits out anything rare that's gone after a rejoin (event and Titanic eggs, a boost, an admin treadmill, ]] --
-- [[ someone running off with your pet; at most 30 minutes). Then it rejoins this same server (another one if    ]] --
-- [[ it's full) and loads itself again. Not in a private server: a script can't rejoin one.                      ]] --
;(function()
    local TeleportService = game:GetService("TeleportService")
    local private = false
    pcall(function() private = game.PrivateServerId ~= "" end)
    local fail, base = nil, S.session_start
    track(TeleportService.TeleportInitFailed:Connect(function(player, result, message)
        if player == me and S.rejoin_going then fail = ("%s %s"):format(tostring(result), tostring(message)) end
    end))
    -- [[ an event egg the farm would take (Treadmill farm: only the top stage's) ]] --
    local function rare_egg()
        local ok, ev = pcall(pick_egg)
        if not (ok and ev and is_event(ev)) then return nil end
        if S.farm_mode == "Treadmill" and (stage_of(ev) or ev:GetAttribute("Stage")) ~= (S.top_stage and S.top_stage()) then return nil end
        if S.egg_ok and not S.egg_ok(ev) then return nil end
        return ev
    end
    S.rare_egg = rare_egg
    -- [[ what still has to happen here before leaving; nil = nothing, rejoin now ]] --
    local function blocker(waited)
        if carrying() then return "a pet in your hands" end
        if S.fights > 0 or #S.hatching > 0 then return "eggs still hatching" end
        if #S.pending > 0 then return "pets waiting to be taken" end
        if S.event_hatch then return "your event egg is hatching" end
        if busy() then return "a fight is on" end
        if S.manual then return "a button you pressed is still running" end
        local okL, loot = pcall(my_loot)
        if okL and loot then return "a good pet on the ground" end
        if waited < 1800 then
            if S.titanic then return "a Titanic egg is up" end
            if rare_egg() then return "an event egg is up" end
            local boost = S.boost_now and S.boost_now()
            if boost then return "a boost is on (" .. tostring(boost) .. ")" end
            if S.boost_mill then return "an admin treadmill is up" end
            if S.bat_thieves and find_thief() ~= nil then return "someone has your pet" end
        end
        return nil
    end
    S.rejoin_left = function() return math.max(0, (tonumber(S.rejoin_mins) or 20) * 60 - (os.clock() - base)) end
    -- [[ growth watch: once a minute, a placed pet whose "aging since" restarted without its time being added is ]] --
    -- [[ written to the log (with whether Equip Best ran just before), so whatever resets growth can be found     ]] --
    go(function()
        local seen = {}
        while S.alive do
            task.wait(60)
            pcall(function()
                if not PlayerData then return end
                local okP, pets = pcall(PlayerData.Get, "Pets")
                if not okP or type(pets) ~= "table" then return end
                local now_seen, n, lost = {}, 0, 0
                for key, rec in pairs(pets) do
                    if type(rec) == "table" then
                        local id = tostring(rec.Id or key)
                        local since, secs = tonumber(rec.AgingSince), tonumber(rec.AgeSeconds) or 0
                        now_seen[id] = { since = since, secs = secs }
                        local old = seen[id]
                        -- [[ placed a minute ago and placed again since: at least the time up to a minute ago must be in ]] --
                        if old and old.since and since and since > old.since then
                            local should = old.secs + math.max(0, since - old.since - 60)
                            if secs < should - 30 then
                                n += 1
                                lost += should - secs
                            end
                        end
                    end
                end
                seen = now_seen
                if n > 0 then
                    logf("GROW", ("%d pet(s) just lost growth (%d min in total): the game restarted their aging without saving it%s"):format(
                        n, math.floor(lost / 60), os.clock() - (S.last_equip or -1e9) < 90 and " | Equip Best ran in the last 90s" or ""))
                end
            end)
        end
    end)
    go(function()
        local warned, due_t = false, 0
        while S.alive do
            task.wait(3)
            local ok, err = pcall(function()
                if not (S.auto_rejoin and S.farm) or S.rejoining or game.PlaceId ~= 77922212238973 then
                    S.rejoin_due = false
                    S.rejoin_note = S.auto_rejoin and "waits for Auto farm" or "off"
                    return
                end
                if private then
                    S.rejoin_due = false
                    S.rejoin_note = "off in a private server (a script can't rejoin one)"
                    if not warned then
                        warned = true
                        logf("REJOIN", "private server: a script can't rejoin it, so Auto rejoin doesn't run here")
                    end
                    return
                end
                local left = S.rejoin_left()
                if left > 0 then
                    S.rejoin_due = false
                    S.rejoin_note = ("next rejoin in %d min"):format(math.ceil(left / 60))
                    return
                end
                if not S.rejoin_due then
                    S.rejoin_due, due_t = true, os.clock()
                    logf("REJOIN", "rejoin due: no new eggs now, banking everything first")
                end
                local why = blocker(os.clock() - due_t)
                if why then
                    S.rejoin_note = "due, waiting: " .. why
                    return
                end
                if S.queue_self then S.queue_self() end
                if not env.mog_helper_queued then
                    S.rejoin_due, base = false, os.clock()
                    S.rejoin_note = "can't rejoin: the helper couldn't queue itself to load again"
                    if not warned then
                        warned = true
                        logf("REJOIN", S.rejoin_note)
                    end
                    return
                end
                S.rejoin_note = "rejoining now"
                logf("REJOIN", ("everything's banked, rejoining this server to save your pets' growth (%d min here)"):format(
                    math.floor((os.clock() - base) / 60)))
                notify("Rejoining to save your pets' growth, back in a moment.")
                pcall(save_log)
                pcall(save_hatched)
                S.rejoin_going, fail = true, nil
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, me) end)
                local t = os.clock()
                repeat task.wait(0.25) until fail or os.clock() - t > 40 or not S.alive
                if fail then
                    logf("REJOIN", "couldn't rejoin this server (" .. fail .. "), joining another one")
                    fail = nil
                    pcall(function() TeleportService:Teleport(game.PlaceId, me) end)
                    t = os.clock()
                    repeat task.wait(0.25) until fail or os.clock() - t > 40 or not S.alive
                end
                -- [[ still here: try again in 3 minutes, the farm carries on meanwhile ]] --
                logf("REJOIN", "the rejoin didn't go through" .. (fail and (": " .. fail) or "") .. ", trying again in 3 minutes")
                S.rejoin_going, S.rejoin_due = false, false
                base = os.clock() - math.max(0, (tonumber(S.rejoin_mins) or 20) * 60 - 180)
            end)
            if not ok then
                S.rejoin_due, S.rejoin_going = false, false
                logf("ERROR", "auto rejoin: " .. tostring(err):sub(1, 200))
                task.wait(30)
            end
        end
    end)
end)()

go(function()
    while S.alive do
        -- [[ the game's own Auto Mog mogs any egg within reach its own way (with the "get ready for battle" fight ]] --
        -- [[ screen) and gets in the farm's way, so it's paused while the farm runs and comes back when it stops  ]] --
        local want_auto = (S.auto_mog and not S.farm) or S.own_fight == true
        if want_auto and me:GetAttribute("AutoMog") ~= true then
            me:SetAttribute("AutoMog", true)
        elseif not want_auto and me:GetAttribute("AutoMog") == true and (S.farm or not S.auto_mog) then
            me:SetAttribute("AutoMog", false)
        end
        local okm, errm = pcall(maybe_mutate)
        if not okm and errm ~= S.last_mut_err then
            S.last_mut_err = errm
            logf("ERROR", "auto mutate: " .. tostring(errm):sub(1, 300))
        end
        if not S.farm then pcall(maybe_equip) end
        local okr, errr = pcall(refresh)
        if not okr and errr ~= S.last_ui_err then
            S.last_ui_err = errr
            logf("ERROR", "window: " .. tostring(errr):sub(1, 300))
        end
        -- [[ save the settings as soon as anything changes ]] --
        local now_settings = settings_json()
        if now_settings ~= S.saved_settings and now_settings ~= "" and typeof(writefile) == "function" then
            if pcall(writefile, "MogHub_Settings.json", now_settings) then S.saved_settings = now_settings end
        end
        task.wait(0.4)
    end
end)

refresh()
if S.settings_loaded then
    notify("Your settings are back." .. (S.farm and " Auto farm was on, so it's running again." or ""))
else
    notify("Sobriety Hub is on. Turn on Auto farm to start.")
end
if S.update_note ~= "" then task.delay(6, notify, S.update_note) end
