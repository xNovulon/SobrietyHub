-- Sobriety Hub: Throw Food For Animals
-- Throws food by itself (no flight, no cutscene, perfect meter), aims where your best food pays the most, trains on the
-- pull-up bar in between (or at the same time when the server allows it), presses x2, equips your best animals, sells the
-- rest, buys food / bar / fence upgrades, runs Ring Rush, accepts gifts, stays in the game, and shows you against the
-- lobby leaderboards. Right Alt (or the round S button) hides / shows the window. Running it again restarts it.
local env = (typeof(getgenv) == "function" and getgenv()) or _G
local fenv = getfenv()
local function exec(name) return env[name] or fenv[name] end
if env.sobriety_tfa_stop then pcall(env.sobriety_tfa_stop) end
-- [[ this run's token: if another copy starts while this one is still loading, the older one quits ]] --
local RUN = {}
env.sobriety_tfa_run = RUN

if not game:IsLoaded() then game.Loaded:Wait() end
local GAME_ID, PLACE_ID = 10766972131, 120219252362013
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
    notify("This script is for Throw Food For Animals.")
    return
end
-- [[ the game marks you DataLoaded once your save is in: nothing is touched before that ]] --
do
    local t = os.clock()
    while me:GetAttribute("DataLoaded") ~= true and os.clock() - t < 60 do task.wait(0.25) end
    if me:GetAttribute("DataLoaded") ~= true then
        notify("Your data didn't load in a minute, so nothing was started. Run it again in a moment.")
        return
    end
end
if env.sobriety_tfa_run ~= RUN then return end

---------------------------------------------------------------- state and settings

local S = {
    alive = true, conns = {}, threads = {}, auto_off = {}, status = "Ready", log = {}, log_dirty = false, session_start = os.clock(),
    ui_size = 1, boot_anim = true, saved_settings = "", settings_loaded = false,
    farm = false, speed = "Instant", target = "Money", target_area = 1, use_super = "Always", ring_rush = true, ring_cap = 100,
    train_mode = "Both", train_share = 25, smart_boosts = true, tap_bonus = true,
    equip_best = true, auto_sell = true, keep_rare = false, buy_food = true, buy_bar = true, buy_fence = true, best_food = true,
    gifts = true, anti_afk = true, auto_reload = true, hide_pets = false, overdrive = true, rush = true,
    -- [[ this session only ]] --
    phase = "idle", throws = 0, catches = 0, rings = 0, taps = 0, gifts_got = 0, sold = 0, bought = 0, supers = 0, new_catches = 0,
    last_catch = "-", best_catch = "-", best_income = 0, gap_extra = 0, complete_extra = 0, meter_extra = 0, ok_streak = 0, start_fails = 0,
    meter_free = false, meter_probed = false, both_ok = 0, use_line = true, walk_line = false, power_free = 0, meter_over = 0, want_d = 0, xp_need_now = 0, xp_need_level = 0, goal_t = -100, goal_level = 0, goal_xp = 0, train_rate = 0, fence_due = false, last_start_t = -100, cooldown = 1.5, aim_area = "", recent = {}, paint_errs = {}, event_boost = { 1, 1, 1 }, buy_warn_t = -100, equip_warn_t = -100, train_since = 0, xp_gain_t = 0, in_throw = false, started_training = false,
    cycle0 = 0, power_set = -1, target_note = "-", target_t = -100, target_key = "", last_equip_t = 0, buy_fail_t = -100,
    train_fail_t = -100, train_warn_t = -100, xp_gained = 0, levels_gained = 0, level_log_t = -100,
    prev_phase = "", phase_since = 0, phase_xp = 0, phase_throws = 0, stat0 = {}, rejoining = false, last_err = "",
}
local SETTING_KEYS = { "ui_size", "boot_anim",
    "farm", "speed", "target", "target_area", "use_super", "ring_rush", "ring_cap", "train_mode", "train_share", "smart_boosts", "tap_bonus",
    "equip_best", "auto_sell", "keep_rare", "buy_food", "buy_bar", "buy_fence", "best_food", "gifts", "anti_afk", "auto_reload", "hide_pets", "overdrive", "rush",
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
env.sobriety_tfa_state = S
-- [[ a stop that works from here on, so a newer copy can always shut this one down (the full Unload replaces it) ]] --
env.sobriety_tfa_stop = function()
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
local LOG_FILE = ("SobrietyHub_ThrowFood_%s_Log.txt"):format(me.Name)
local SETTINGS_FILE = ("SobrietyHub_ThrowFood_%s_Settings.json"):format(me.Name)
local OLD_SETTINGS = "SobrietyHub_ThrowFood_Settings.json"
S.log_file = LOG_FILE
local function logf(kind, text)
    local line = ("[%s +%dm] %s: %s"):format(os.date("%H:%M:%S"), math.floor((os.clock() - S.session_start) / 60), kind, tostring(text))
    table.insert(S.log, line)
    if #S.log > 1500 then table.remove(S.log, 1) end
    S.log_dirty = true
end
logf("START", "Sobriety Hub loaded (Throw Food For Animals)")

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
if S.speed ~= "Safe" and S.speed ~= "Fast" then S.speed = "Instant" end
if S.target ~= "Farthest" and S.target ~= "Area" then S.target = "Money" end
if S.use_super ~= "Never" and S.use_super ~= "Boosts" then S.use_super = "Always" end
if S.train_mode ~= "Off" and S.train_mode ~= "Only" then S.train_mode = "Both" end
if S.train_share ~= 10 and S.train_share ~= 50 and S.train_share ~= 75 then S.train_share = 25 end
if S.ring_cap ~= 50 and S.ring_cap ~= 200 and S.ring_cap ~= 0 then S.ring_cap = 100 end
if S.target_area < 1 then S.target_area = 1 end
S.saved_settings = settings_json()

---------------------------------------------------------------- helpers

-- [[ 1234567 -> "1.23M", the way the game shortens numbers ]] --
local SUFFIX = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg" }
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

---------------------------------------------------------------- the game's own code

-- [[ the game's modules are already loaded by the game, so requiring them hands back the same tables it uses ]] --
local Shared = RS:WaitForChild("Shared", 20)
local Config = RS:WaitForChild("Config", 20)
local RemoteFolder = RS:WaitForChild("Remotes", 20)
local Controllers = me:WaitForChild("PlayerScripts"):WaitForChild("Client"):WaitForChild("Controllers", 20)
local function req(parent, name)
    local inst = parent and parent:WaitForChild(name, 10)
    if not inst then return nil end
    local ok, m = pcall(require, inst)
    return ok and m or nil
end
local G: any = {
    Remotes = req(Shared, "Remotes"), DC = req(Controllers, "DataController"), ClientState = req(Controllers, "ClientState"),
    Meter = req(Shared, "ThrowMeterMath"), AreaUtil = req(Shared, "AreaUtil"), AnimalRoll = req(Shared, "AnimalRoll"),
    Course = req(Shared, "RingRushCourse"), Balance = req(Shared, "BalanceCurve"), AdminAbuse = req(Shared, "AdminAbuse"),
    Areas = req(Config, "AreasConfig"), Foods = req(Config, "FoodsConfig"), Stands = req(Config, "StandsConfig"),
    Fence = req(Config, "FenceConfig"), Levels = req(Config, "LevelConfig"), Economy = req(Config, "AnimalEconomy"),
    GameConfig = req(Config, "GameConfig"), AnimalsData = req(RS, "AnimalsData"),
}
if not (G.Remotes and G.DC and G.Meter and G.AreaUtil and RemoteFolder) then
    notify("Couldn't load the game's code, so nothing was started.")
    return
end
pcall(function() G.DC:WaitForReady() end)

-- [[ remotes go through the game's own wrapper (a pcall'd InvokeServer that always answers with a table). It has no ]] --
-- [[ time limit, and a server that never answers left the whole farm standing still (run 8: 13 minutes). So the    ]] --
-- [[ call runs on its own thread and the farm stops waiting after 10 s ("Timeout"); a late answer is thrown away.   ]] --
local CALL_TIMEOUT = 10
local function call(name, ...)
    local args = table.pack(...)
    local done, ok, r = false, false, nil
    task.spawn(function()
        ok, r = pcall(G.Remotes.Invoke, name, table.unpack(args, 1, args.n))
        done = true
    end)
    local t = os.clock()
    while not done do
        if os.clock() - t > CALL_TIMEOUT then
            S.timeouts = (S.timeouts or 0) + 1
            if os.clock() - (S.timeout_log_t or -100) > 30 then
                S.timeout_log_t = os.clock()
                logf("ERROR", ("the server didn't answer %s within %ds (%d times this session): carrying on without it"):format(name,
                    CALL_TIMEOUT, S.timeouts))
            end
            return { Ok = false, Reason = "Timeout" }
        end
        task.wait()
    end
    if ok and type(r) == "table" then return r end
    return { Ok = false, Reason = ok and "BadResponse" or "Error" }
end
local function fire(name, ...)
    local ev = RemoteFolder:FindFirstChild(name)
    if ev and ev:IsA("RemoteEvent") then pcall(ev.FireServer, ev, ...) end
end
local function on_event(name, fn)
    local ev = RemoteFolder:FindFirstChild(name)
    if ev and ev:IsA("RemoteEvent") then track(ev.OnClientEvent:Connect(function(...) pcall(fn, ...) end)) end
end
-- [[ your saved data, read the way the game reads it (copies, never written to) ]] --
local function get(key)
    local ok, v = pcall(G.DC.Get, G.DC, key)
    if ok then return v end
    return nil
end
local function get_path(p)
    local ok, v = pcall(G.DC.GetPath, G.DC, p)
    if ok then return v end
    return nil
end
local function num(v) return tonumber(v) or 0 end
-- [[ Some of the game's functions (the XP and price curves) wait on the game's own threads, and a thread they wake ]] --
-- [[ up comes back without the rights to touch the hub's window ("lacking capability Plugin"), so everything after ]] --
-- [[ it failed. They run here on a throwaway thread; the caller just waits for the answer (at most 3 s).           ]] --
local function iso(fn, ...)
    local args = table.pack(...)
    local done, res = false, nil
    task.spawn(function()
        local ok, v = pcall(fn, table.unpack(args, 1, args.n))
        res = ok and v or nil
        done = true
    end)
    local t = os.clock()
    while not done and os.clock() - t < 3 do task.wait() end
    return res
end
local function busy(on)
    pcall(function()
        if on then
            G.ClientState.Busy = "Throw"
        elseif G.ClientState.Busy == "Throw" then
            G.ClientState.Busy = nil
        end
    end)
end

---------------------------------------------------------------- where things are

local function my_plot()
    local plots = workspace:FindFirstChild("Plots")
    return plots and plots:FindFirstChild(tostring(me:GetAttribute("PlotIndex")))
end
local PLOT_CFG = (G.GameConfig and G.GameConfig.Plot) or {}
local TRAIN_OFF = PLOT_CFG.TrainingSpotOffset or Vector3.new(-16, 0.5, -30.5)
local SHOP_OFF = PLOT_CFG.ShopCircleOffset or Vector3.new(10.53, 0.51, -30.8)
local SIGN_OFF = Vector3.new(-8.5, 0.5, -20)
local function plot_point(offset)
    local p = my_plot()
    return p and (p.Position + offset) or nil
end
local function training() return me:GetAttribute("Training") == true end
-- [[ a caught animal comes to your hand as a tool, and Equip Best leaves a held one alone: put it back in the ]] --
-- [[ backpack (Roblox's own unequip) so it can go on your plot                                              ]] --
local function put_away()
    local char = me.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not char:FindFirstChildWhichIsA("Tool") then return false end
    pcall(function() hum:UnequipTools() end)
    return true
end
-- [[ a short hop to a spot on your plot (the game itself moves you onto your plot after every throw) ]] --
local function stand_at(pos)
    local root = root_part()
    if not (root and pos) or training() then return false end
    if (root.Position - pos).Magnitude > 5 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        task.wait(0.25)
    end
    return true
end
-- [[ just outside the food shop's circle: standing in it opens the shop window (UIZonePad), next to it doesn't ]] --
local function beside_shop()
    local props = workspace:FindFirstChild("LocalPlotProps")
    local shop = props and props:FindFirstChild("FoodShop")
    local pad = shop and shop:FindFirstChild("ZonePad")
    if not (pad and pad:IsA("BasePart")) then return plot_point(SHOP_OFF + Vector3.new(0, 0, 14)) end
    local margin = tonumber(pad:GetAttribute("CloseMargin")) or 3
    local reach = math.max(pad.Size.X, pad.Size.Y, pad.Size.Z) / 2 + margin + 3
    local plot = my_plot()
    local dir = plot and (plot.Position - pad.Position) or Vector3.new(0, 0, 1)
    dir = Vector3.new(dir.X, 0, dir.Z)
    dir = dir.Magnitude > 0.1 and dir.Unit or Vector3.new(0, 0, 1)
    return pad.Position + dir * reach
end
local function line_spot()
    local area = workspace:FindFirstChild("StarterArea")
    local line = area and area:FindFirstChild("CrossLine")
    return line and (line.Position + Vector3.new(0, 0, 6)) or nil
end
-- [[ walking (when a hop doesn't reach the server): a path around the fence if Roblox can find one, else straight ]] --
local function walk_to(pos, timeout)
    local char = me.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = root_part()
    if not (hum and root and pos) then return false end
    if hum.WalkSpeed < 16 then hum.WalkSpeed = 16 end
    local points = { pos }
    pcall(function()
        local path = game:GetService("PathfindingService"):CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true })
        path:ComputeAsync(root.Position, pos)
        if path.Status == Enum.PathStatus.Success then
            points = {}
            for _, w in ipairs(path:GetWaypoints()) do table.insert(points, w.Position) end
        end
    end)
    local t = os.clock()
    for _, p in ipairs(points) do
        while os.clock() - t < timeout and S.alive do
            hum:MoveTo(p)
            if (Vector3.new(root.Position.X, p.Y, root.Position.Z) - p).Magnitude < 4 then break end
            task.wait(0.2)
        end
    end
    return (root.Position - pos).Magnitude < 8
end
-- [[ the bar holds your character on the server: a hop made while on it (or right after) never reaches the  ]] --
-- [[ server. So training is stopped and the script waits until the bar model is gone and you're free first   ]] --
local function leave_bar()
    if training() then call("Training_Stop") end
    local t = os.clock()
    while os.clock() - t < 2.5 do
        local root = root_part()
        -- [[ free = not anchored any more; the flag alone can lag behind (or stay on), so after 0.6 s it's ignored ]] --
        if root and not root.Anchored and (not training() or os.clock() - t > 0.6) then break end
        task.wait(0.05)
    end
    task.wait(0.15)
end
local function go_to_line()
    local spot, root = line_spot(), root_part()
    if not (spot and root) or (root.Position - spot).Magnitude <= 8 then return end
    if S.walk_line then
        S.status = "Walking to the throw line"
        walk_to(spot, 20)
    else
        stand_at(spot)
    end
end

---------------------------------------------------------------- levels, foods, prices

local function level() return num(get("Level")) end
local function max_power()
    local L = level()
    local ok, p = pcall(function() return G.Levels.ThrowPowerForLevel(L) end)
    return (ok and tonumber(p)) or (18 + 5 * math.max(0, L - 1))
end
local function food_count()
    local ok, n = pcall(function() return G.Foods.Count() end)
    return (ok and tonumber(n)) or 50
end
local function food_info(i)
    local ok, f = pcall(function() return G.Foods.Get(i) end)
    return ok and f or nil
end
local function food_locked(i)
    local ok, y = pcall(function() return G.Foods.IsLocked(i) end)
    return ok and y == true
end
local function best_food_owned()
    local owned = get("OwnedFoods") or {}
    for i = food_count(), 1, -1 do
        if owned[i] == true or owned[tostring(i)] == true then return i end
    end
    return 1
end
local function price_of(item)
    if type(item) ~= "table" then return nil end
    local p = iso(function() return G.Balance.GetItemPrice(me, item) end)
    return tonumber(p) or tonumber(item.Price)
end

---------------------------------------------------------------- boosts (admin commands and the Admin Abuse show)

local function attr_boost(name)
    local m = tonumber(workspace:GetAttribute(name)) or 1
    local e = tonumber(workspace:GetAttribute(name .. "End")) or 0
    local now = workspace:GetServerTimeNow()
    if m > 1 and now < e then return m, e - now end
    return 1, 0
end
local function event_mult(fn)
    if type(fn) ~= "function" then return 1 end
    local ok, v = pcall(fn)
    return (ok and tonumber(v)) or 1
end
-- [[ The Admin Abuse show's multipliers come from the game's AdminAbuse module, which can wait 10 s for a        ]] --
-- [[ server-only folder each time (it froze the window and slowed the farm in the first run). So they're read on ]] --
-- [[ a side thread once a minute, and given up on for the session if they don't answer within 2 s.             ]] --
go(function()
    local A = G.AdminAbuse
    if not A then return end
    while S.alive do
        local done = false
        task.spawn(function()
            S.event_boost = { event_mult(A.TrainingMultiplier), event_mult(A.MoneyMultiplier), event_mult(A.LuckMultiplier) }
            done = true
        end)
        local t = os.clock()
        while not done and os.clock() - t < 2 do task.wait(0.1) end
        if not done then
            S.event_boost = { 1, 1, 1 }
            logf("BOOST", "the game's Admin Abuse check is slow here, so only the map's boost signs are read")
            return
        end
        task.wait(60)
    end
end)
-- [[ training, money and luck multipliers active right now (1 = none); never waits ]] --
local function boosts()
    local tm, mm, lm = attr_boost("AdminTraining"), attr_boost("AdminMoney"), attr_boost("AdminLuck")
    lm = math.max(lm, (attr_boost("ServerLuck")))
    local e = S.event_boost
    return math.max(tm, e[1] or 1), math.max(mm, e[2] or 1), math.max(lm, e[3] or 1)
end
S.boosts = boosts

---------------------------------------------------------------- where to throw

local function launch_z()
    local ok, p = pcall(function() return G.AreaUtil.GetLaunchPosition() end)
    return (ok and typeof(p) == "Vector3") and p.Z or -45
end
local function area_info(i)
    local ok, a = pcall(function() return G.AreaUtil.Get(i) end)
    return ok and a or nil
end
local function area_count()
    local ok, n = pcall(function() return G.AreaUtil.Count() end)
    return (ok and tonumber(n)) or 19
end
local function area_name(i)
    local ok, a = pcall(function() return G.Areas.Get(i) end)
    return ok and a and tostring(a.Name or a.Key) or ("Area " .. i)
end
local function area_playable(i)
    local ok, y = pcall(function() return G.Areas.IsPlayable(i) end)
    return not ok or y ~= false
end
local function income_of(model)
    local list = G.Economy and G.Economy.List
    local e = list and list[model]
    return e and tonumber(e.Income) or 0
end
-- [[ what one catch is worth on average (base income, before mutation and size) when the food lands this far, ]] --
-- [[ from the game's own odds: AnimalRoll.Weights gives each animal's chance for that food, area and depth     ]] --
local function value_at(d, bait)
    local z = launch_z() - d
    local okI, i = pcall(function() return G.AreaUtil.GetAreaIndexForZ(z) end)
    if not okI or not i or not area_playable(i) then return 0, nil end
    local a = area_info(i)
    if not a then return 0, nil end
    local depth = math.clamp((a.ZStart - z) / math.max(a.ZStart - a.ZEnd, 1), 0, 0.999)
    local okW, w = pcall(function() return G.AnimalRoll.Weights(bait, i, depth) end)
    local okK, key = pcall(function() return G.Areas.Get(i).Key end)
    local list = okK and G.AnimalsData and G.AnimalsData[key]
    if not (okW and type(w) == "table" and list) then return 0, i end
    local sum = 0
    for r, wt in ipairs(w) do
        local animal = list[r]
        if animal then sum += wt * income_of(animal.ModelName) end
    end
    return sum, i
end
-- [[ Reaching further. A throw lands at power + meter x 20 studs, and the server works that out from what the ]] --
-- [[ client sends: the power setting and the meter value. The game caps power at what your level gives        ]] --
-- [[ (LevelConfig.EffectiveThrowPower) and the meter tops out at 1, but whether the SERVER enforces those caps ]] --
-- [[ is checked once each: if one isn't enforced, every stage is in reach. Each check turns itself off if the ]] --
-- [[ server caps it or says no.                                                                                ]] --
-- [[ the meter: its top after PEAK seconds, and where it is t seconds after it starts (the game's own maths) ]] --
local PEAK = 1.0858
pcall(function() PEAK = G.Meter.HalfPeriod() end)
local function meter_at(t)
    local ok, v = pcall(function() return G.Meter.Position(t) end)
    return (ok and tonumber(v)) or 1
end
local function total_distance()
    local ok, n = pcall(function() return G.Areas.TotalDistance end)
    return (ok and tonumber(n)) or 11429
end
local function can_reach_far()
    return S.overdrive and (S.power_free ~= -1 or S.meter_over ~= -1)
end
-- [[ how far to throw (in studs) and what it aims at; worked out again when your level, food or the aim changes ]] --
local function work_out_target()
    local maxp = max_power()
    local food = best_food_owned()
    local f = food_info(food)
    local bait = f and tonumber(f.Bait) or food
    local reach = maxp + 20
    local far = can_reach_far()
    local top = far and (total_distance() - 10) or reach
    if S.target == "Farthest" then
        return top, far and "the far end of the last stage" or ("as far as you can throw (%d studs)"):format(reach)
    end
    if S.target == "Area" then
        local a = area_info(S.target_area)
        if not a then return reach, "that area isn't in the map" end
        local d = launch_z() - (a.ZEnd + (a.ZStart - a.ZEnd) * 0.12)
        if d > top then
            return reach, ("%s is out of reach (it starts near %d studs, you reach %d): as far as you can"):format(area_name(S.target_area), math.floor(d), reach)
        end
        return d, ("%s, its deepest part (%d studs)"):format(area_name(S.target_area), math.floor(d))
    end
    local step = math.max(2, (top - 38) / 700)
    local best_d, best_v, best_i = top, -1, nil
    local d = 38
    while d <= top do
        local v, i = value_at(d, bait)
        if v >= best_v then best_d, best_v, best_i = d, v, i end
        d += step
    end
    local where = best_i and area_name(best_i) or "?"
    return best_d, ("%s at %d studs: about $%s/s a catch with %s"):format(where, math.floor(best_d), short(best_v), f and tostring(f.Name) or "your food")
end
local function update_target(force)
    local key = ("%s|%d|%d|%d|%s|%s|%s|%s|%s"):format(S.target, S.target_area, level(), best_food_owned(), tostring(S.overdrive), S.power_free, S.meter_over,
        S.speed, tostring(S.meter_free))
    if not force and key == S.target_key and os.clock() - S.target_t < 120 then return end
    local ok, want, note = pcall(work_out_target)
    if not ok then return end
    S.target_key, S.target_t, S.target_note, S.want_d = key, os.clock(), tostring(note), want
    local maxp = max_power()
    -- [[ the meter's share of the distance: a full meter, or (Instant, timed meter) what it shows at 0.37 s ]] --
    local meter_part = (S.speed == "Instant" and not S.meter_free) and meter_at(0.37) or 1
    local p = math.floor(want - 20 * meter_part + 0.5)
    local power
    if p > maxp and S.overdrive and S.power_free ~= -1 then
        power = p -- more than your level allows: checked on the next throw
    elseif p >= maxp then
        power = 0 -- the most you have
    else
        power = math.max(18, p)
    end
    if power ~= S.power_set then
        local r = call("Player_SetThrowPower", power)
        if r.Ok then
            -- [[ written down when the aim really moves (a new area, or 50+ studs), not on every level ]] --
            local area = S.target_note:match("^(.-) at ") or S.target_note
            if area ~= S.aim_area or math.abs(power - S.power_set) > 50 or (power == 0) ~= (S.power_set == 0) then
                logf("AIM", ("power %s: %s"):format(power == 0 and "max" or tostring(power), S.target_note))
            end
            S.aim_area = area
            S.power_set = power
        elseif power > maxp then
            S.power_free = -1
            logf("AIM", "the server won't take more power than your level gives (" .. tostring(r.Reason) .. ")")
            S.target_t = -100
        end
    end
end
S.update_target = update_target

---------------------------------------------------------------- one throw

local function want_super(saved)
    if num(saved) <= 0 or S.use_super == "Never" then return false end
    if S.use_super == "Always" then return true end
    local _, _, luck = boosts()
    return luck > 1
end
-- [[ Ring Rush: the run is a flight through rings on a course the server seeds. The course is rebuilt from the ]] --
-- [[ seed with the game's own code and each ring is reported at the moment the real flight would cross it      ]] --
-- [[ (never sooner), slightly off-centre like a person steering                                                ]] --
local function ring_rush()
    if not (G.Course and S.ring_rush) then
        call("Throw_Cancel")
        S.status = "Ring Rush is on but switched off here, waiting"
        task.wait(20)
        return
    end
    S.status = "Ring Rush: taking off"
    task.wait(0.4)
    fire("Throw_MeterStarted")
    task.wait(PEAK)
    local b = call("RingRush_Begin")
    if not (b.Ok and b.Seed) then
        call("Throw_Cancel")
        return
    end
    local begin_t = os.clock()
    local launch = Vector3.new(0, 0, launch_z())
    pcall(function() launch = G.AreaUtil.GetLaunchPosition() end)
    local okC, course = pcall(function() return G.Course.new(b.Seed, launch) end)
    local passes, t, prev_d, got = 0, 0, 0, 0
    local cap = S.ring_cap > 0 and S.ring_cap or 100000
    if okC and course then
        for i = 1, cap do
            if not (S.alive and S.farm) then break end
            local okR, ring = pcall(function() return G.Course.GetRing(course, i) end)
            if not (okR and type(ring) == "table") then break end
            local d = tonumber(ring.Distance) or (prev_d + 100)
            local okS, speed = pcall(function() return G.Course.GetSpeed(passes, 0) end)
            speed = (okS and tonumber(speed)) or 46
            t += (d - prev_d) / speed + 0.01
            prev_d = d
            local okO, off = pcall(function() return G.Course.GetRingOffset(course, ring, t) end)
            local ox, oy = 0, 0
            if okO and off then ox, oy = num(off.X), num(off.Y) end
            local r = (tonumber(ring.Radius) or 6) * 0.35
            local due = begin_t + 1.25 + t
            while os.clock() < due and S.alive do task.wait() end
            local rep = call("RingRush_Report", i, true, ox + (math.random() * 2 - 1) * r, oy + (math.random() * 2 - 1) * r, t)
            if not rep.Ok then
                logf("RING", ("ring %d not counted: %s"):format(i, tostring(rep.Reason)))
                break
            end
            passes += 1
            got += 1
            S.rings += 1
            S.status = ("Ring Rush: %d rings"):format(got)
            if rep.Ended then break end
        end
    end
    call("RingRush_End")
    call("Throw_Cancel")
    logf("RING", ("Ring Rush run done: %d rings (%d this session)"):format(got, S.rings))
end
-- [[ a catch, written down (and a lucky one shown) ]] --
local function note_catch(r)
    S.catches += 1
    S.new_catches += 1
    local bits = {}
    if r.Mutation then table.insert(bits, tostring(r.Mutation)) end
    if num(r.Size) > 1.01 then table.insert(bits, ("size x%.2f"):format(num(r.Size))) end
    local text = ("%s %s%s"):format(tostring(r.Rarity or "?"), tostring(r.DisplayName or r.ModelName or "?"), #bits > 0 and (" (" .. table.concat(bits, ", ") .. ")") or "")
    S.last_catch = text
    local income = num(r.Income)
    if income > S.best_income then
        S.best_income = income
        S.best_catch = text .. " $" .. short(income) .. "/s"
    end
    if type(r.Lucky) == "table" then
        local tier = tostring(r.Lucky.Tier or "LUCKY")
        logf("LUCKY", ("%s: %s, 1 in %s"):format(tier, text, short(num(r.Lucky.OneIn))))
        notify(("%s %s"):format(tier, text))
    elseif r.IsNew or r.Mutation or num(r.Size) > 1.5 then
        logf("CATCH", text .. (r.IsNew and " | NEW" or "") .. " | $" .. short(income) .. "/s")
    end
end
-- [[ the speed profiles: wait before the meter starts, wait from the result to "done", gap before the next throw ]] --
local function waits(r)
    if S.speed == "Safe" then
        return 0.65, 0.35 + 1.15 + (tonumber(r and r.FlightTime) or 1.6) + 0.75 + ((r and r.CanSkip) and 2.6 or 8.5), 1.6
    elseif S.speed == "Fast" then
        return 0.3, 1.2, 1.5
    end
    return 0, 0, 0
end
local function throw_once()
    S.in_throw = true
    busy(true)
    local pre = waits(nil)
    -- [[ the server wants a gap between throws (GameConfig.Throw.Cooldown, 1.5 s; it says "Cooldown" when it's too   ]] --
    -- [[ soon): the next throw starts the moment the gap is over, no sooner. The gap learns from the server's answers ]] --
    local wait_for = S.last_start_t + S.cooldown - os.clock()
    if wait_for > 0 then task.wait(wait_for) end
    S.last_start_t = os.clock()
    local r = call("Throw_Start")
    if not r.Ok then
        busy(false)
        S.in_throw = false
        local why = tostring(r.Reason or "?")
        if why == "Timeout" then call("Throw_Cancel") end
        if why == "Training" then return "training" end
        if why == "Cooldown" then
            S.cooldown = math.min(S.cooldown + 0.1, 4)
            return "cooldown"
        end
        -- [[ the server only starts a throw near the throw line (seen in the first run): go there and try again ]] --
        if why == "TooFar" then
            -- [[ write down where you were (once a minute), so a farm that keeps getting this shows why in the log ]] --
            S.toofar_n = (S.toofar_n or 0) + 1
            if os.clock() - (S.toofar_log_t or -100) > 60 then
                S.toofar_log_t = os.clock()
                local root, spot = root_part(), line_spot()
                local area = workspace:FindFirstChild("StarterArea")
                local line = area and area:FindFirstChild("CrossLine")
                logf("THROW", ("throws refused as too far from the line (%d in a row): you're %s studs from the throw spot, %s the line")
                    :format(S.toofar_n, (root and spot) and ("%.0f"):format((root.Position - spot).Magnitude) or "?",
                    (root and line) and (root.Position.Z < line.Position.Z and "past" or "behind") or "? of"))
            end
            -- [[ standing right at the spot and still refused 6 times: walk onto it properly instead of hopping ]] --
            if S.toofar_n >= 6 and S.toofar_n % 6 == 0 then
                local spot = line_spot()
                if spot then walk_to(spot, 8) end
            end
            if not S.use_line then
                logf("THROW", "the server wants you at the throw line, throwing from there")
            elseif not S.walk_line then
                -- [[ already "at" the line, so the hop didn't reach the server: walk there from now on ]] --
                S.walk_line = true
                logf("THROW", "hopping to the throw line didn't reach the server, walking there instead")
            end
            S.use_line = true
            return "toofar"
        end
        S.start_fails += 1
        S.ok_streak = 0
        S.gap_extra = math.min(S.gap_extra + 0.25, 4)
        if S.start_fails == 1 or S.start_fails % 20 == 0 then logf("THROW", ("the server didn't start a throw (%s), slowing down a little"):format(why)) end
        -- [[ still refused after slowing all the way down: maybe the server wants you at the throw line, try from there ]] --
        if S.start_fails == 20 and not S.use_line then
            S.use_line = true
            logf("THROW", "trying from the throw line instead of your plot")
        end
        task.wait(1 + S.gap_extra)
        return "refused"
    end
    S.start_fails, S.toofar_n = 0, 0
    -- [[ did the server take more power than your level gives? (Throw_Start says which power it uses) ]] --
    if S.power_set > max_power() and S.power_free == 0 then
        if num(r.Power) > max_power() + 1 then
            S.power_free = 1
            logf("AIM", ("the server took power %d (your level gives %d): every stage is in reach"):format(num(r.Power), max_power()))
        else
            S.power_free = -1
            S.target_t = -100
            logf("AIM", ("the server caps power at what your level gives (%d): trying the meter next"):format(num(r.Power)))
        end
    end
    if r.RingRush then
        busy(false)
        ring_rush()
        S.in_throw = false
        return "ring"
    end
    task.wait(pre + S.meter_extra)
    local t0 = os.clock()
    fire("Throw_MeterStarted")
    local super = false
    if want_super(r.Saved) then
        local s = call("Throw_UseSuper")
        super = s.Ok == true
        if super then S.supers += 1 end
    end
    -- [[ the meter: the first Instant throw checks whether the server compares the meter with the clock; if it ]] --
    -- [[ doesn't, later throws are sent at once, otherwise each one is sent at the top of the meter             ]] --
    local probe = S.speed == "Instant" and not S.meter_probed and not super
    -- [[ the meter past its top: only when the aim is further than power + a full meter reaches ]] --
    local over = 0
    if S.overdrive and S.meter_over ~= -1 and not super and S.want_d > num(r.Power) + 21 then
        over = math.min((S.want_d - num(r.Power)) / 20, 800)
    end
    local value
    if over > 1 then
        local at = PEAK + (math.random() * 2 - 1) * 0.012
        while os.clock() - t0 < at do task.wait() end
        value = over
        probe = false
    elseif super then
        task.wait(0.4)
        value = 1
    elseif probe or (S.meter_free and S.speed == "Instant") then
        task.wait(0.37 - (os.clock() - t0))
        value = 0.999
    else
        -- [[ Instant with a timed meter: the true meter value as soon as the meter takes taps (0.37 s, about 0.24 full) ]] --
        -- [[ instead of waiting 1.1 s for the top; the ~15 studs it gives up are added to your power (see update_target) ]] --
        local at = S.speed == "Instant" and 0.37 or (PEAK + (math.random() * 2 - 1) * 0.012)
        while os.clock() - t0 < at do task.wait() end
        value = meter_at(os.clock() - t0)
    end
    local res = call("Throw_Resolve", value)
    -- [[ the meter past its top: did the food fly further? ]] --
    if over > 1 and S.meter_over ~= 1 then
        local dist = num(res.Distance)
        if res.Ok and dist > num(r.Power) + 25 then
            S.meter_over = 1
            logf("AIM", ("the server took a meter past its top: %d studs (power %d), every stage is in reach"):format(dist, num(r.Power)))
        else
            S.meter_over = -1
            S.target_t = -100
            logf("AIM", res.Ok and ("the server caps the meter (%d studs): further stages need more levels"):format(dist)
                or ("the server refused a meter past its top (%s): further stages need more levels"):format(tostring(res.Reason)))
        end
    end
    if not res.Ok then
        logf("THROW", "the throw wasn't accepted: " .. tostring(res.Reason))
        if probe then
            S.meter_probed, S.meter_free = true, false
            logf("THROW", "the server checks the meter against the clock: every throw now waits for the top of the meter")
        elseif res.Reason ~= "Timeout" then
            -- [[ maybe the meter started too soon after the throw: wait a little longer before it next time ]] --
            S.meter_extra = math.min(S.meter_extra + 0.15, 0.8)
            S.ok_streak = 0
        end
        call("Throw_Cancel")
        busy(false)
        S.in_throw = false
        task.wait(1)
        return "failed"
    end
    if probe then
        S.meter_probed = true
        local power = num(r.Power)
        local dist = num(res.Distance)
        S.meter_free = power > 0 and dist > 0 and math.abs(dist - (power + 19.98)) < 2
        logf("THROW", S.meter_free and "the server doesn't time the meter: throws no longer wait for it"
            or ("the server times the meter (%d studs instead of %d): throws wait for the top of the meter"):format(dist, power + 20))
    end
    S.throws += 1
    -- [[ throws per minute: the last 20 throw starts ]] --
    table.insert(S.recent, os.clock())
    if #S.recent > 20 then table.remove(S.recent, 1) end
    note_catch(res)
    local _, done_wait, gap = waits(res)
    task.wait(done_wait + S.complete_extra)
    local c = call("Throw_Complete")
    local tries = 0
    -- [[ NoSession: the server already closed this throw (the animal came with the result), nothing left to finish ]] --
    if c.Ok == false and c.Reason == "NoSession" then c = { Ok = true } end
    -- [[ no answer at all: don't wait around for it, tidy the throw up and go on ]] --
    if c.Ok == false and c.Reason == "Timeout" then tries = 4 end
    while c.Ok == false and tries < 4 and S.alive do
        tries += 1
        S.complete_extra = math.min(S.complete_extra + 0.5, 8)
        if tries == 1 then logf("THROW", ("finishing the throw was refused (%s), waiting a bit longer"):format(tostring(c.Reason))) end
        task.wait(0.5 + S.complete_extra)
        c = call("Throw_Complete")
    end
    if c.Ok == false then call("Throw_Cancel") end
    -- [[ the new animal lands in your hand a moment after the throw: back to the backpack with it ]] --
    task.delay(0.6, put_away)
    busy(false)
    S.in_throw = false
    S.ok_streak += 1
    -- [[ 25 clean throws in a row: try going a little faster again ]] --
    if S.ok_streak % 25 == 0 then
        S.gap_extra = math.max(0, S.gap_extra - 0.25)
        S.complete_extra = math.max(0, S.complete_extra - 0.25)
        S.meter_extra = math.max(0, S.meter_extra - 0.05)
        S.cooldown = math.max(1.5, S.cooldown - 0.05)
    end
    task.wait(gap + S.gap_extra)
    return "ok"
end

---------------------------------------------------------------- training

local function start_training()
    if training() then return true end
    if num(get("Stand")) < 1 then return false end
    if os.clock() - S.train_fail_t < 1.5 then return false end
    local spot = plot_point(TRAIN_OFF)
    stand_at(spot)
    -- [[ a bar upgrade the server only sells you standing at the bar: you're there now ]] --
    if S.bar_due then
        S.bar_due = false
        local u = call("Stand_Upgrade")
        if not u.Ok and u.Reason == "TooFar" and spot then
            walk_to(spot, 10)
            u = call("Stand_Upgrade")
        end
        if u.Ok then
            S.bought += 1
            S.target_t = -100
            logf("BUY", "upgraded your pull-up bar at the bar")
        else
            logf("BUY", "the bar upgrade at the bar was refused: " .. tostring(u.Reason))
        end
    end
    local r = call("Training_Start")
    -- [[ the hop back from the throw line didn't reach the server yet: walk onto the bar's circle and try again ]] --
    if not r.Ok and r.Reason == "TooFar" and spot then
        walk_to(spot, 10)
        r = call("Training_Start")
    end
    if not r.Ok then
        S.train_fail_t = os.clock()
        if os.clock() - S.train_warn_t > 60 then
            S.train_warn_t = os.clock()
            logf("TRAIN", "the bar didn't start: " .. tostring(r.Reason))
        end
        return false
    end
    S.started_training = true
    S.train_since, S.xp_gain_t = os.clock(), os.clock()
    return true
end
local function stop_training()
    if not training() then return end
    call("Training_Stop")
    local t = os.clock()
    repeat task.wait(0.05) until not training() or os.clock() - t > 2
end
-- [[ the x2 button: the server offers one every 4-6 s and it lasts 5 s; it's taken after a human-like moment ]] --
on_event("Training_Bonus", function(id)
    if not (S.alive and S.tap_bonus) then return end
    task.delay(0.15 + math.random() * 0.4, function()
        if not S.alive then return end
        local r = call("Training_TapBonus", id)
        if r.Ok then S.taps += 1 end
    end)
end)
-- [[ XP watch: what training really gives (XP this session, levels), checked every 2 s from your saved data ]] --
local function xp_need(L)
    return tonumber(iso(function() return G.Balance.GetXpForLevel(me, L) end)) or 0
end
go(function()
    local lastL, lastX = level(), num(get("Xp"))
    while S.alive do
        task.wait(2)
        local L, X = level(), num(get("Xp"))
        -- [[ the window reads this instead of asking the game itself (see iso) ]] --
        if L ~= S.xp_need_level or S.xp_need_now <= 0 then
            S.xp_need_now, S.xp_need_level = xp_need(L), L
        end
        -- [[ XP still needed to reach the last stage, from the game's own XP curve (every 25th level, once a minute) ]] --
        if os.clock() - S.goal_t > 60 then
            S.goal_t = os.clock()
            pcall(function()
                local a = area_info(area_count())
                local d = a and (launch_z() - a.ZStart + 8) or 9709
                local goal = tonumber(iso(function() return G.Levels.LevelForDistance(d - 20) end)) or math.ceil((d - 20 - 18) / 5) + 1
                local left = 0
                local lv = L
                while lv < goal do
                    local n = math.min(25, goal - lv)
                    left += xp_need(lv) * n
                    lv += n
                end
                S.goal_level, S.goal_xp = goal, math.max(0, left - X)
            end)
        end
        if L ~= lastL or X > lastX then S.xp_gain_t = os.clock() end
        -- [[ on the bar 20 s and no XP: write down why (the game's flag, its rig, your bar, where you are) and ]] --
        -- [[ start training again                                                                             ]] --
        if S.phase == "train" and training() and os.clock() - S.train_since > 20 and os.clock() - S.xp_gain_t > 20 then
            local plot = my_plot()
            local server = plot and plot:FindFirstChild("Server")
            local rig = server and server:FindFirstChild("TrainingRig_" .. me.Name)
            local root, spot = root_part(), plot_point(TRAIN_OFF)
            local away = (root and spot) and (root.Position - spot).Magnitude or -1
            logf("TRAIN", ("on the bar %ds but no XP came in (training flag %s, bar model %s, bar tier %d, %.0f studs from the spot): starting it again")
                :format(math.floor(os.clock() - S.train_since), tostring(me:GetAttribute("Training")), rig and "there" or "missing", num(get("Stand")), away))
            call("Training_Stop")
            S.train_since, S.xp_gain_t = os.clock(), os.clock()
        end
        if L == lastL then
            if X > lastX then S.xp_gained += X - lastX end
        elseif L > lastL then
            S.xp_gained += math.max(0, xp_need(lastL) - lastX) + X
            S.levels_gained += L - lastL
            if os.clock() - S.level_log_t > 30 then
                S.level_log_t = os.clock()
                logf("LEVEL", ("level %d, throw power %d (%d levels this session)"):format(L, max_power(), S.levels_gained))
            end
        end
        lastL, lastX = L, X
    end
end)
-- [[ what the farm does right now: throw, train, or both at once (when the server allows it) ]] --
local function phase()
    if not S.farm then return "idle" end
    local tm, mm, lm = boosts()
    if S.smart_boosts then
        if tm > 1 and mm <= 1 and lm <= 1 then return "train" end
        if mm > 1 or lm > 1 then return "throw" end
    end
    if S.train_mode == "Only" then return "train" end
    if S.train_mode == "Off" then return "throw" end
    -- [[ 3-minute blocks: every switch between the bar and the line costs a few seconds, so fewer, longer turns ]] --
    local cyc = (os.clock() - S.cycle0) % 180
    return cyc < 180 * S.share_now() / 100 and "train" or "throw"
end
-- [[ the share of each minute on the bar: Rush keeps you there 85% of the time (the bar gave 26x the XP of ]] --
-- [[ throwing in the third run); throws in the other 15% keep money coming for the next bar                ]] --
S.share_now = function()
    if S.train_mode == "Only" then return 100 end
    if S.train_mode == "Off" then return 0 end
    return S.rush and 85 or S.train_share
end

local function farm_step()
    local ph = phase()
    S.phase = ph
    -- [[ each switch between the bar and throwing writes down what the last stretch gave ]] --
    if ph ~= S.prev_phase then
        local secs = math.floor(os.clock() - S.phase_since)
        if S.prev_phase == "train" then
            local got = S.xp_gained - S.phase_xp
            logf("TRAIN", ("%ds on the bar: +%s XP"):format(secs, short(got)))
            -- [[ XP a second on the bar, for the time to the last stage (a stretch under 5 s says too little) ]] --
            if secs >= 5 and got > 0 then
                local rate = got / secs
                S.train_rate = S.train_rate > 0 and (S.train_rate * 0.6 + rate * 0.4) or rate
            end
        elseif S.prev_phase == "throw" or S.prev_phase == "both" then
            logf("THROW", ("%ds of throwing: %d throws, +%s XP"):format(secs, S.throws - S.phase_throws, short(S.xp_gained - S.phase_xp)))
        end
        S.prev_phase, S.phase_since, S.phase_xp, S.phase_throws = ph, os.clock(), S.xp_gained, S.throws
    end
    if ph == "idle" then
        if S.started_training and training() then stop_training() end
        S.started_training = false
        S.status = "Ready"
        task.wait(0.4)
        return
    end
    pcall(update_target)
    if ph == "train" then
        if start_training() then
            S.status = "Training on the pull-up bar"
            task.wait(0.5)
            return
        end
        -- no bar yet: throw instead
    end
    -- [[ throwing needs the throw line and training needs the bar, so they take turns: off the bar first, once per ]] --
    -- [[ turn. The game's Training flag can stay on after you're off the bar, so later throws trust the server:    ]] --
    -- [[ it answers "Training" when you really are still on it                                                    ]] --
    if S.left_bar_phase ~= S.phase_since then
        S.left_bar_phase = S.phase_since
        if training() then leave_bar() end
    end
    -- [[ a fence upgrade waiting for you to be at its sign ]] --
    if S.fence_due and S.buy_fence then
        S.fence_due = false
        local sign = plot_point(SIGN_OFF)
        stand_at(sign)
        local r = call("Plot_UpgradeFence")
        if not r.Ok and r.Reason == "TooFar" then
            walk_to(sign, 12)
            r = call("Plot_UpgradeFence")
        end
        if r.Ok then
            S.bought += 1
            logf("BUY", ("upgraded your fence: %s animals on your plot now"):format(tostring(r.Slots or "more")))
        else
            logf("BUY", "the fence upgrade at its sign was refused: " .. tostring(r.Reason))
        end
    end
    if S.use_line then go_to_line() end
    S.status = ("Throwing (%s)"):format(S.speed)
    local res = throw_once()
    if res == "training" then leave_bar() end
end
S.farm_step = farm_step
S.set_busy = busy

---------------------------------------------------------------- plot, shop, upgrades

local function buy_one()
    local money = num(get("Money"))
    local list = {}
    if S.buy_food then
        local nf = best_food_owned() + 1
        local f = food_info(nf)
        if f and not food_locked(nf) then
            table.insert(list, { kind = "food", id = nf, price = price_of(f), name = tostring(f.Name or nf) })
        end
    end
    if S.buy_bar and G.Stands then
        local okS, s = pcall(function() return G.Stands.Get(num(get("Stand")) + 1) end)
        if okS and s then table.insert(list, { kind = "bar", price = price_of(s), name = tostring(s.Name or "bar") }) end
    end
    if S.buy_fence and G.Fence then
        local fl = num(get("FenceLevel"))
        local okF, f = pcall(function() return G.Fence.Get(fl + 1) end)
        if okF and type(f) == "table" then table.insert(list, { kind = "fence", price = price_of(f), name = "fence level " .. (fl + 1) }) end
    end
    -- [[ cheapest first, or with Rush: the bar first (it decides how fast you level), then food, then fence ]] --
    local RANK = { bar = 1, food = 2, fence = 3 }
    if S.rush then
        table.sort(list, function(a, b) return RANK[a.kind] < RANK[b.kind] end)
    else
        table.sort(list, function(a, b) return num(a.price) < num(b.price) end)
    end
    -- [[ Rush saves up for the next bar, but food and fence still get bought while they cost at most a quarter of it: ]] --
    -- [[ better food means better animals and more money, which pays for the bar sooner                               ]] --
    local item, saving = nil, nil
    for _, it in ipairs(list) do
        if it.price and money >= it.price and (not saving or it.price <= saving.price * 0.25) then
            item = it
            break
        end
        if S.rush and it.kind == "bar" and it.price then saving = it end
    end
    if saving and not item and S.saving_for ~= saving.name then
        S.saving_for = saving.name
        logf("BUY", ("saving for %s ($%s); food and fence get bought meanwhile when they cost under a quarter of it"):format(saving.name,
            short(saving.price)))
    end
    if not item then return false end
    local r
    if item.kind == "food" then
        -- [[ bought in the background: from wherever you are, or (if the server wants you closer) from right next ]] --
        -- [[ to the shop's circle, never inside it, so the shop window never opens                                ]] --
        r = call("Shop_Buy", item.id)
        if not r.Ok and not training() then
            stand_at(beside_shop())
            r = call("Shop_Buy", item.id)
        end
    elseif item.kind == "bar" then
        if S.bar_due then return false end -- (already waiting to be bought at the bar; the money stays put for it)
        r = call("Stand_Upgrade")
        if not r.Ok and r.Reason == "TooFar" then
            -- [[ the server wants you at the bar for this one: it's bought there the next time the farm goes to the bar ]] --
            if not S.bar_due then logf("BUY", ("%s has to be bought at the bar: buying it there on the next training turn"):format(item.name)) end
            S.bar_due = true
            return false
        end
    else
        r = call("Plot_UpgradeFence")
        if not r.Ok and r.Reason == "TooFar" then
            -- [[ the fence needs you at its sign: the farm does it there the next time you're off the bar ]] --
            S.fence_due = true
            return false
        end
    end
    if r.Ok then
        S.bought += 1
        logf("BUY", ("bought %s for $%s"):format(item.name, short(item.price)))
        S.target_t = -100
        return true
    end
    S.buy_fail_t = os.clock()
    if os.clock() - S.buy_warn_t > 120 then
        S.buy_warn_t = os.clock()
        logf("BUY", ("couldn't buy %s ($%s): %s"):format(item.name, short(item.price), tostring(r.Reason)))
    end
    return false
end
local function sell_extras()
    if not S.keep_rare then
        local r = call("Plot_SellAll")
        if r.Ok and num(r.Count) > 0 then
            S.sold += num(r.Count)
            logf("SELL", ("sold %d extra animals for $%s"):format(num(r.Count), short(num(r.Money))))
        end
        return
    end
    -- [[ keeping Ruby and Rainbow ones: everything else that isn't on the plot (and wasn't bought) is sold one by one ]] --
    local animals = get("Animals") or {}
    local n, money = 0, 0
    for id, a in pairs(animals) do
        if type(a) == "table" and not a.Placed and not a.Bought and a.Mutation ~= "Ruby" and a.Mutation ~= "Rainbow" then
            local r = call("Plot_SellAnimal", id)
            if r.Ok then
                n += 1
                money += num(r.Money)
            end
            task.wait(0.15)
            if n >= 40 then break end
        end
    end
    if n > 0 then
        S.sold += n
        logf("SELL", ("sold %d extra animals for $%s (kept Ruby and Rainbow)"):format(n, short(money)))
    end
end
local function upkeep()
    if S.best_food then
        local best = best_food_owned()
        if num(get("EquippedFood")) ~= best then
            local r = call("Shop_Equip", best)
            if r.Ok then logf("FOOD", "equipped your best food: " .. tostring((food_info(best) or {}).Name or best)) end
        end
    end
    -- [[ Equip Best: right after start, after new catches (at most every 15 s), and once a minute and a half anyway ]] --
    local due = S.new_catches > 0 or os.clock() - S.last_equip_t > 90
    if due and os.clock() - S.last_equip_t > 15 then
        local had = S.new_catches
        S.last_equip_t = os.clock()
        S.new_catches = 0
        if S.equip_best then
            if put_away() then task.wait(0.3) end
            local r = call("Plot_EquipBest")
            if r.Ok then
                if num(r.Placed) > 0 or num(r.Removed) > 0 then
                    logf("EQUIP", ("best animals on your plot: %d put down, %d taken off, %d there now"):format(num(r.Placed), num(r.Removed), num(r.Count)))
                end
            elseif os.clock() - S.equip_warn_t > 120 then
                S.equip_warn_t = os.clock()
                logf("EQUIP", "Equip Best was refused: " .. tostring(r.Reason))
            end
        end
        if S.auto_sell and had > 0 then
            task.wait(0.3)
            sell_extras()
        end
    end
    if (S.buy_food or S.buy_bar or S.buy_fence) and os.clock() - S.buy_fail_t > 20 then
        for _ = 1, 3 do
            if not buy_one() then break end
            task.wait(0.4)
        end
    end
end
S.upkeep = upkeep
S.call = call

---------------------------------------------------------------- free things, gifts, staying in the game

go(function()
    task.wait(3)
    if num(get_path("OfflinePending.Base")) > 0 then
        local r = call("Offline_Claim")
        if r.Ok then logf("FREE", "claimed your offline earnings") end
    end
    if get("FreeAnimalClaimed") ~= true then
        local r = call("Shop_ClaimFree")
        if r.Ok then logf("FREE", "claimed the free animal") end
    end
end)
-- [[ gifts are Robux items another player pays for: accepting one costs you nothing ]] --
on_event("Gift_Update", function(d)
    if type(d) ~= "table" or d.Type ~= "Incoming" or not S.gifts then return end
    logf("GIFT", ("%s is sending you %s, accepting"):format(tostring(d.SenderName), tostring(d.ItemName)))
    task.delay(1 + math.random(), function()
        if not S.alive then return end
        local r = call("Gift_Respond", d.RequestId, true)
        if r.Ok then S.gifts_got += 1 end
    end)
end)
-- [[ the game moves you to another server after 18 minutes without any input, and Roblox kicks you after 20: ]] --
-- [[ a tiny mouse nudge every minute counts as input for both                                               ]] --
go(function()
    local okV, vim = pcall(function() return game:GetService("VirtualInputManager") end)
    while S.alive do
        task.wait(50 + math.random() * 20)
        if S.anti_afk and okV and vim then
            pcall(function()
                local p = UserInputService:GetMouseLocation()
                vim:SendMouseMoveEvent(p.X + 1, p.Y, game)
                task.wait(0.05)
                vim:SendMouseMoveEvent(p.X, p.Y, game)
            end)
        end
    end
end)
track(me.Idled:Connect(function()
    if not S.anti_afk then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))
-- [[ moved to another server (AFK move, a disconnect, a rejoin): the hub loads itself again there ]] --
local SELF_FILE = "throw_food.lua"
local function queue_self()
    if env.sobriety_tfa_queued or not S.auto_reload then return end
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
    env.sobriety_tfa_queued = pcall(q, src)
end
queue_self()
S.queue_self = queue_self
-- [[ disconnected: rejoin the game (the hub comes back with it) ]] --
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

---------------------------------------------------------------- the leaderboards in the lobby

local SUF = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg" }
local function parse_amount(s)
    s = tostring(s):gsub("SCORE", ""):gsub("[%$,%s]", "")
    local n, suf = s:match("^([%d%.]+)(%a*)$")
    local v = tonumber(n)
    if not v then return nil end
    if suf == "" then return v end
    for i, x in ipairs(SUF) do
        if x == suf then return v * 1000 ^ i end
    end
    return nil
end
-- [[ the value shown on a board's row (the biggest number among its labels; the rank number is smaller) ]] --
local function board_value(part, row)
    local lb = workspace:FindFirstChild("Leaderboards")
    local p = lb and lb:FindFirstChild(part)
    local rows = p and p:FindFirstChild("Rows", true)
    local r = rows and rows:FindFirstChild("Row" .. row)
    if not r then return nil end
    local best = nil
    for _, d in ipairs(r:GetDescendants()) do
        if d:IsA("TextLabel") then
            local v = parse_amount(d.Text)
            if v and (not best or v > best) then best = v end
        end
    end
    return best
end
S.BOARDS = {
    { part = "MostAnimals", stat = "Stats.TotalCaught", name = "Most Animals", money = false },
    { part = "TotalMoney", stat = "Stats.TotalEarned", name = "Top Money", money = true },
    { part = "LuckiestCatch", stat = "Stats.LuckiestCatch", name = "Luckiest Catch", money = false },
}
for _, b in ipairs(S.BOARDS) do S.stat0[b.stat] = num(get_path(b.stat)) end
S.board_value = board_value
S.get_path = get_path
S.get = get
S.max_power = max_power
S.level = level
S.best_food_owned = best_food_owned
S.food_info = food_info
S.area_count = area_count
S.area_name = area_name
S.area_playable = area_playable
S.training = training
S.stop_training = stop_training
S.busy = busy

-- [[ who this script is, for the shared Sobriety Hub window (reports/sobriety-ui/toolkit.lua) ]] --
S.hub = {
    game = "Throw Food For Animals", tag = "THROW FOOD FOR ANIMALS", stop = "sobriety_tfa_stop",
    steps = { { 0, "linking executor" }, { 0.2, "hooking the game's remotes" }, { 0.45, "reading foods, stages and your plot" },
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

local L = { s = 1, compact = false, w = 780, h = 520, side = 198, top = 56, inset = 0, drag = Vector2.zero }
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
local okH, hidden = pcall(function() return gethui and gethui() end)
gui.Parent = (okH and hidden) or CoreGui
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
    L.side, L.top = compact and 60 or 198, compact and 48 or 56
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
local tween, new, corner, gradient, set_text, label = W.tween, W.new, W.corner, W.gradient, W.set_text, W.label
local gui, painters, page, next_order = W.gui, W.painters, W.page, W.next_order
local card, section, toggle, segmented, action, info, stats = W.card, W.section, W.toggle, W.segmented, W.action, W.info, W.stats
local top_pill, me_sub = W.top_pill, W.me_sub
local get, get_path = S.get, S.get_path

local home = page("Home", "⌂", 0)
local throw_page = page("Throw", "🥕", 1)
local train_page = page("Training", "💪", 2)
local plot_page = page("Plot & Shop", "🐾", 3)
local boards_page = page("Leaderboards", "🏆", 4)
local extras_page = page("Extras", "✨", 5)
local logs_page = page("Logs", "📋", 6)
local settings_page = page("Settings", "⚙", 7)

local function per_hour(stat)
    local hours = math.max((os.clock() - S.session_start) / 3600, 1 / 120)
    return (tonumber(get_path(stat)) or 0) - (S.stat0[stat] or 0), hours
end

-- [[ Home: start / stop, the numbers, boosts, where it's throwing, what just happened ]] --
do
    local hero = card(home, 112)
    local hero_stroke = hero:FindFirstChildOfClass("UIStroke")
    local hero_glow = W.spin(new("UIGradient", { Color = W.ACCENT, Enabled = false, Parent = hero_stroke }), 90)
    local dot = new("Frame", { Position = UDim2.fromOffset(18, 22), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = C.dim, Parent = hero })
    corner(dot)
    local state = label(hero, "FARM IS OFF", BLACK, 12, C.dim, { Position = UDim2.fromOffset(38, 16), Size = UDim2.new(1, -200, 0, 24) })
    local status = label(hero, "", BOLD, 17, C.text, { Position = UDim2.fromOffset(18, 44), Size = UDim2.new(1, -200, 0, 24), TextTruncate = Enum.TextTruncate.AtEnd })
    local sub = label(hero, "", REG, 12, C.dim, { Position = UDim2.fromOffset(18, 72), Size = UDim2.new(1, -200, 0, 30), TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top })
    local btn = new("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0), Size = UDim2.fromOffset(150, 48),
        BackgroundColor3 = C.white, AutoButtonColor = false, Text = "START FARM", Font = BLACK, TextSize = 15, TextColor3 = C.white, Parent = hero })
    corner(btn, 12)
    local grad = gradient(btn, 0)
    W.pressable(btn)
    btn.MouseButton1Click:Connect(function()
        S.farm = not S.farm
        S.cycle0 = os.clock()
        logf("FARM", S.farm and "turned ON" or "turned OFF")
    end)
    local row1 = stats(home, { "Throws", "Catches / hour", "Money / s", "Level" })
    local row2 = stats(home, { "Throws / min", "Rings", "x2 taps", "Sold" })
    section(home, "BOOSTS AND AIM")
    local aim = info(home, 52)
    section(home, "WHAT JUST HAPPENED")
    local feed_card = card(home, 214)
    local feed = label(feed_card, "", REG, 12, C.text, { Position = UDim2.fromOffset(16, 10), Size = UDim2.new(1, -32, 1, -20), TextWrapped = true,
        RichText = true, TextYAlignment = Enum.TextYAlignment.Top, LineHeight = 1.15 })
    local KIND = { CATCH = "D8B4FE", LUCKY = "F0ABFC", BUY = "8CF5B0", SELL = "FFD27A", THROW = "FFB27A", TRAIN = "C4B5FD", RING = "F0ABFC",
        AIM = "C4B5FD", GIFT = "8CF5B0", FREE = "8CF5B0", ERROR = "FF6B6B", FARM = "C4B5FD", RECONNECT = "FFB27A", FOOD = "8CF5B0",
        EQUIP = "8CF5B0", LEVEL = "C4B5FD", BOOST = "FFD27A" }
    local function esc(t) return (tostring(t):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
    table.insert(painters, function()
        local on = S.farm
        local col = on and C.good or C.dim
        dot.BackgroundColor3 = col
        state.Text = on and ("FARMING  ·  " .. string.upper(tostring(S.phase))) or "FARM IS OFF"
        state.TextColor3 = col
        top_pill.dot.BackgroundColor3 = col
        top_pill.text.Text = on and (S.phase == "train" and "TRAINING" or "FARMING") or "IDLE"
        top_pill.text.TextColor3 = on and C.text or C.dim
        status.Text = tostring(S.status)
        sub.Text = "Last catch: " .. tostring(S.last_catch) .. "   ·   best: " .. tostring(S.best_catch)
        hero_glow.Enabled = on
        if hero_stroke then hero_stroke.Color = on and C.white or C.stroke end
        set_text(btn, on and "STOP FARM" or "START FARM")
        grad.Enabled = not on
        btn.BackgroundColor3 = on and C.bad or C.white
        local caught, hours = per_hour("Stats.TotalCaught")
        row1.Throws.Text = tostring(S.throws)
        row1["Catches / hour"].Text = short(caught / hours)
        local ls = me:FindFirstChild("leaderstats")
        local ms = ls and ls:FindFirstChild("Money/s")
        row1["Money / s"].Text = ms and tostring(ms.Value) or "-"
        row1.Level.Text = tostring(S.level())
        local rec = S.recent
        local per_min = (#rec >= 2 and os.clock() - rec[#rec] < 10) and (#rec - 1) / math.max(rec[#rec] - rec[1], 0.1) * 60 or 0
        row2["Throws / min"].Text = ("%.0f"):format(per_min)
        row2.Rings.Text = tostring(S.rings)
        row2["x2 taps"].Text = tostring(S.taps)
        row2.Sold.Text = tostring(S.sold)
        local tm, mm, lm = S.boosts()
        local b = {}
        if tm > 1 then table.insert(b, ("training x%g"):format(tm)) end
        if mm > 1 then table.insert(b, ("money x%g"):format(mm)) end
        if lm > 1 then table.insert(b, ("luck x%g"):format(lm)) end
        aim.Text = ("Boosts: <b>%s</b>\nAim: <b>%s</b>"):format(#b > 0 and table.concat(b, ", ") or "none right now", esc(S.target_note))
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

-- [[ Throw ]] --
section(throw_page, "THROWING")
toggle(throw_page, "Auto farm", "Throws (and trains, see Training) by itself: no flight, no cutscene, a perfect meter every time",
    function() return S.farm end, function(v)
        S.farm = v
        S.cycle0 = os.clock()
        logf("FARM", v and "turned ON" or "turned OFF")
    end)
segmented(throw_page, "Speed (Instant backs off by itself if the server says no)", { { "Safe", "Slow (game's pace)" }, { "Fast", "Fast" }, { "Instant", "Instant" } },
    function() return S.speed end, function(v) S.speed = v end)
segmented(throw_page, "Aim", { { "Money", "Best money" }, { "Farthest", "Farthest" }, { "Area", "Pick an area" } },
    function() return S.target end, function(v)
        S.target = v
        S.update_target(true)
    end)
toggle(throw_page, "Reach further than your level", "Tries more power than your level gives, then a meter past its top, once each. Turns itself off if the server caps it",
    function() return S.overdrive end, function(v)
        S.overdrive = v
        S.update_target(true)
    end)
do
    local f = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card, LayoutOrder = next_order(), Parent = throw_page })
    corner(f, 12)
    W.outline(f, C.stroke, 1, 0.1)
    new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = f })
    new("UIGridLayout", { CellSize = UDim2.fromOffset(112, 30), CellPadding = UDim2.fromOffset(6, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = f })
    local chips = {}
    for i = 1, S.area_count() do
        local b = new("TextButton", { BackgroundColor3 = C.bg, AutoButtonColor = false, Text = S.area_name(i), Font = BOLD, TextSize = 11, TextColor3 = C.dim,
            TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = i, Parent = f })
        corner(b, 7)
        local g = gradient(b, 0)
        g.Enabled = false
        chips[i] = { button = b, grad = g }
        b.MouseButton1Click:Connect(function()
            S.target, S.target_area = "Area", i
            S.update_target(true)
        end)
    end
    table.insert(painters, function()
        for i, x in pairs(chips) do
            local on = S.target == "Area" and S.target_area == i
            x.grad.Enabled = on
            x.button.BackgroundColor3 = on and C.white or C.bg
            set_text(x.button, nil, on and C.white or (S.area_playable(i) and C.dim or C.off))
        end
    end)
end
section(throw_page, "LUCKY THROWS AND RING RUSH")
segmented(throw_page, "Use saved Lucky Throws (100 luck rolls each)", { { "Never", "Never" }, { "Boosts", "In luck boosts" }, { "Always", "Always" } },
    function() return S.use_super end, function(v) S.use_super = v end)
toggle(throw_page, "Ring Rush", "When the event is on, flies through the rings by itself (cash per ring, Lucky Throws at 25 / 75, a Champion pet at 100)",
    function() return S.ring_rush end, function(v) S.ring_rush = v end)
segmented(throw_page, "Rings per run", { { 50, "50" }, { 100, "100" }, { 200, "200" }, { 0, "No limit" } },
    function() return S.ring_cap end, function(v) S.ring_cap = v end)
do
    local meter = info(throw_page, 44)
    table.insert(painters, function()
        local function state(v, yes, no) return v == 1 and yes or (v == -1 and no or "not checked yet") end
        meter.Text = ("Meter: <b>%s</b>   ·   lucky throws used: <b>%d</b>   ·   extra wait the server asked for: <b>%.2fs</b>\n"
            .. "More power than your level: <b>%s</b>   ·   meter past its top: <b>%s</b>"):format(
            not S.meter_probed and "checked on the first Instant throw" or (S.meter_free and "not timed by the server, sent at once" or "timed, sent at the top"),
            S.supers, S.gap_extra + S.complete_extra, state(S.power_free, "works", "capped by the server"), state(S.meter_over, "works", "capped by the server"))
    end)
end

-- [[ Training ]] --
section(train_page, "PULL-UP BAR")
toggle(train_page, "Rush to the last stage", "85% of each minute on the bar, the next bar bought before anything else, throws aimed at the best spot you can reach",
    function() return S.rush end, function(v)
        S.rush = v
        S.cycle0 = os.clock()
    end)
segmented(train_page, "Training", { { "Off", "Throw only" }, { "Both", "Both" }, { "Only", "Train only" } },
    function() return S.train_mode end, function(v)
        S.train_mode = v
        S.cycle0 = os.clock()
    end)
segmented(train_page, "With Both: share of each minute on the bar (the rest is throwing)", { { 10, "10%" }, { 25, "25%" }, { 50, "50%" }, { 75, "75%" } },
    function() return S.train_share end, function(v) S.train_share = v end)
toggle(train_page, "Smart boosts", "Trains during training boosts, throws during money and luck boosts",
    function() return S.smart_boosts end, function(v) S.smart_boosts = v end)
toggle(train_page, "Press x2 by itself", "Takes the x2 button the moment it shows up (an extra rep each time)",
    function() return S.tap_bonus end, function(v) S.tap_bonus = v end)
do
    local t = info(train_page, 60)
    table.insert(painters, function()
        local stand = tonumber(get("Stand")) or 0
        local L = S.level()
        local xp, need = tonumber(get("Xp")) or 0, S.xp_need_now
        local mins = math.max((os.clock() - S.session_start) / 60, 0.5)
        t.Text = ("Level <b>%d</b>  ·  XP <b>%s / %s</b> (%d%%)  ·  throw power <b>%d</b> (the last area starts near 9,700 studs)\n"
            .. "This session: <b>+%s XP</b>, <b>%d levels</b> (%s XP a minute)\nBar tier <b>%d</b>  ·  %s"):format(math.floor(L), short(xp), short(need),
            need > 0 and math.floor(xp / need * 100) or 0, math.floor(S.max_power()), short(S.xp_gained), S.levels_gained, short(S.xp_gained / mins), stand,
            "throws need the throw line and training needs the bar, so with Both they take turns")
        -- [[ how long to the last stage at your XP rate and share of time on the bar ]] --
        local eta = "worked out after your first stretch on the bar"
        local share = S.share_now() / 100
        if S.goal_level > 0 and L >= S.goal_level then
            eta = "<b>you can reach it</b>"
        elseif S.goal_level > 0 and S.train_rate > 0 and share > 0 then
            local secs = S.goal_xp / (S.train_rate * share)
            eta = secs > 172800 and ("about <b>%.0f days</b>"):format(secs / 86400) or ("about <b>%.1f hours</b>"):format(secs / 3600)
            eta ..= " at this bar (each new bar halves it)"
        end
        t.Text ..= ("\nLast stage: level <b>%d</b> (%s XP to go)  ·  %s"):format(S.goal_level, short(S.goal_xp), eta)
    end)
end

-- [[ Plot & Shop ]] --
section(plot_page, "ANIMALS")
toggle(plot_page, "Equip best", "Puts your best animals on your plot after new catches", function() return S.equip_best end, function(v) S.equip_best = v end)
toggle(plot_page, "Sell extras", "Sells every animal that isn't on your plot (bought ones are never sold)", function() return S.auto_sell end, function(v) S.auto_sell = v end)
toggle(plot_page, "Keep Ruby and Rainbow", "Sells the others one by one and keeps those two mutations", function() return S.keep_rare end, function(v) S.keep_rare = v end)
section(plot_page, "BUYING (in-game money only, cheapest next upgrade first)")
toggle(plot_page, "Buy better food", "Better food brings better animals", function() return S.buy_food end, function(v) S.buy_food = v end)
toggle(plot_page, "Buy bar upgrades", "Each bar tier doubles the XP per rep", function() return S.buy_bar end, function(v) S.buy_bar = v end)
toggle(plot_page, "Buy fence upgrades", "More animals on your plot (10 up to 20)", function() return S.buy_fence end, function(v) S.buy_fence = v end)
toggle(plot_page, "Use your best food", "Equips the best food you own", function() return S.best_food end, function(v) S.best_food = v end)
action(plot_page, "Equip best now", "Same as the game's Equip Best", "EQUIP", function() task.spawn(S.call, "Plot_EquipBest") end)
action(plot_page, "Sell extras now", "Sells what isn't on your plot", "SELL", function()
    task.spawn(function()
        local r = S.call("Plot_SellAll")
        notify(r.Ok and ("Sold %s animals."):format(tostring(r.Count or 0)) or "Nothing to sell.")
    end)
end)

-- [[ Leaderboards: you against the boards in the lobby (they update every minute) ]] --
section(boards_page, "YOU AGAINST THE LOBBY BOARDS")
for _, b in ipairs(S.BOARDS) do
    local t = info(boards_page, 70)
    local last = -100
    table.insert(painters, function()
        if os.clock() - last < 5 then return end
        last = os.clock()
        local mine = tonumber(get_path(b.stat)) or 0
        local top, tenth = S.board_value(b.part, 1), S.board_value(b.part, 10)
        local gained, hours = per_hour(b.stat)
        local rate = gained / hours
        local pre = b.money and "$" or ""
        local eta = "-"
        if tenth and mine >= tenth then
            eta = "<b>you're on the board</b>"
        elseif tenth and rate > 0 then
            local h = (tenth - mine) / rate
            eta = h > 72 and ("about <b>%.0f days</b>"):format(h / 24) or ("about <b>%.1f hours</b>"):format(h)
        end
        t.Text = ("<b>%s</b>\nYou: <b>%s%s</b>   ·   #10: %s%s   ·   #1: %s%s\nThis session: +%s%s an hour   ·   to #10: %s"):format(b.name, pre, short(mine), pre,
            tenth and short(tenth) or "?", pre, top and short(top) or "?", pre, short(rate), eta)
    end)
end

-- [[ Extras ]] --
section(extras_page, "QUALITY OF LIFE")
toggle(extras_page, "Accept gifts", "Accepts gifts other players send you (they pay)", function() return S.gifts end, function(v) S.gifts = v end)
toggle(extras_page, "Anti-AFK", "A tiny mouse nudge every minute, so the game doesn't move you to another server", function() return S.anti_afk end, function(v) S.anti_afk = v end)
toggle(extras_page, "Come back after a server move", "Moved or disconnected: rejoins and loads the hub again (needs throw_food.lua in the workspace)",
    function() return S.auto_reload end, function(v)
        S.auto_reload = v
        if v then S.queue_self() end
    end)
toggle(extras_page, "Hide other players' pets", "Less to draw, more FPS", function() return S.hide_pets end, function(v)
    S.hide_pets = v
    task.spawn(S.call, "Player_SetSetting", "ShowOtherPets", not v)
end)

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
    section(logs_page, "LATEST")
    local f = card(logs_page, 250)
    log_view = label(f, "", W.MONO, 11, C.dim, { Position = UDim2.fromOffset(12, 8), Size = UDim2.new(1, -24, 1, -16), TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd })
end

-- [[ Settings ]] --
section(settings_page, "WINDOW")
segmented(settings_page, "Window size", { { 0.85, "Small" }, { 1, "Normal" }, { 1.15, "Large" } },
    function() return S.ui_size end, function(v)
        S.ui_size = v
        W.layout(true)
    end)
toggle(settings_page, "Boot animation", "The glitch intro when the hub loads (a short one after a server move)",
    function() return S.boot_anim end, function(v) S.boot_anim = v end)
action(settings_page, "Replay the intro", "Plays the boot animation again", "PLAY", function()
    W.hide()
    task.delay(0.25, function() pcall(play_boot, W, W.show, false) end)
end)
action(settings_page, "Unload", "Stops everything and removes the window", "UNLOAD", function() if env.sobriety_tfa_stop then env.sobriety_tfa_stop() end end)
do
    local about = info(settings_page, 44)
    about.Text = "<b>Sobriety Hub</b>  •  Throw Food For Animals  •  made for " .. me.DisplayName
end

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

local function refresh()
    if not gui.Parent then return end
    for i, paint in ipairs(painters) do
        local ok, err = xpcall(paint, debug.traceback)
        if not ok and not S.paint_errs[i] then
            S.paint_errs[i] = true
            logf("ERROR", ("window part %d: %s"):format(i, tostring(err):gsub("\n", " | "):sub(1, 400)))
        end
    end
    me_sub.Text = ("Level %d  •  %d caught"):format(S.level(), S.catches)
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
end
env.sobriety_tfa_stop = function()
    S.alive, S.farm = false, false
    local here = coroutine.running()
    for _, th in ipairs(S.threads) do
        if th ~= here then pcall(task.cancel, th) end
    end
    for _, c in ipairs(S.conns) do pcall(function() c:Disconnect() end) end
    if S.in_throw then pcall(S.call, "Throw_Cancel") end
    pcall(function()
        if S.started_training and S.training() then S.call("Training_Stop") end
    end)
    pcall(S.busy, false)
    logf("FARM", "hub unloaded")
    pcall(save_log)
    pcall(function() gui:Destroy() end)
    if env.sobriety_tfa_state == S then env.sobriety_tfa_state = nil end
    env.sobriety_tfa_stop = nil
end

-- [[ the farm on its own thread; a crash in one step is written down and the next step goes on ]] --
local function farm_loop(gen)
    while S.alive and S.farm_gen == gen do
        S.farm_beat = os.clock()
        local ok, err = pcall(S.farm_step)
        if not ok then
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
S.cycle0 = os.clock()
go(function() farm_loop(1) end)
-- [[ the watchdog: if one farm step hasn't finished in 60 s, it's stuck on something. Write down what it was doing ]] --
-- [[ and where you are, and start a fresh farm (the stuck one stops the moment it wakes up)                         ]] --
go(function()
    while S.alive do
        task.wait(5)
        if os.clock() - S.farm_beat > 60 then
            local root = root_part()
            logf("ERROR", ("the farm was stuck for %ds (doing: %s, phase %s, on the bar %s, at %s): started it again"):format(
                math.floor(os.clock() - S.farm_beat), tostring(S.status), tostring(S.phase), tostring(me:GetAttribute("Training") == true),
                root and ("%.0f, %.0f, %.0f"):format(root.Position.X, root.Position.Y, root.Position.Z) or "?"))
            pcall(S.set_busy, false)
            S.in_throw = false
            S.farm_gen += 1
            S.farm_beat = os.clock()
            local g = S.farm_gen
            go(function() farm_loop(g) end)
        end
    end
end)
-- [[ plot, shop and food every few seconds (each part has its own switch, so it runs with the farm off too) ]] --
go(function()
    task.wait(2)
    while S.alive do
        local ok, err = pcall(S.upkeep)
        if not ok then logf("ERROR", "upkeep: " .. tostring(err):sub(1, 200)) end
        task.wait(5)
    end
end)
-- [[ the window's numbers, saved settings and the log file ]] --
go(function()
    local last_log = os.clock()
    while S.alive do
        pcall(refresh)
        local now = settings_json()
        local wf = exec("writefile")
        if now ~= S.saved_settings and now ~= "" and typeof(wf) == "function" then
            if pcall(wf, SETTINGS_FILE, now) then S.saved_settings = now end
        end
        if S.log_dirty and os.clock() - last_log > 10 then
            last_log = os.clock()
            save_log()
        end
        task.wait(0.5)
    end
end)
if S.hide_pets then task.spawn(S.call, "Player_SetSetting", "ShowOtherPets", false) end
notify(S.settings_loaded and (S.farm and "Your settings are back and the farm is running." or "Your settings are back.") or "Sobriety Hub is on. Press START FARM.")
