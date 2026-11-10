-- Sobriety Hub  ·  made by Novulon  ·  Discord: 1z11 (suggestions and script requests only)
-- Open source and free to use: https://github.com/xNovulon/SobrietyHub
-- If you use this work to make a new script or an updated version, I'd appreciate a credit.
-- Loader: loadstring(game:HttpGet("https://raw.githubusercontent.com/xNovulon/SobrietyHub/main/hub.lua"))()

-- Game dump (works in any game): saves every script the game gives your client (decompiled), what each of the
-- game's modules holds (its configs and data), the game's objects, your stats, every remote, everything you can
-- press (prompts, click detectors) and the store (passes and products with prices), so the whole game can be read.
-- It only reads: it sends nothing to the game's server, hooks nothing and changes nothing in the game. (The store
-- list asks Roblox's public web API for this game's passes; nothing about you is sent.)
-- 1) Run it and wait for "Game dump done" at the top (a minute or two). You can keep playing meanwhile.
--    Don't press Stop unless you mean it (it asks twice): a stopped dump is missing its later parts.
-- 2) Tell Claude it's done. Everything is in your executor's workspace folder, in GameDump_<place id>.
--    The index is also copied to your clipboard.
-- In a game that only loads the map near you (streaming, the index says so), the object tree and the prompt list
-- cover what's loaded around you: for a far-away area, go there and run it again.
local env = (typeof(getgenv) == "function" and getgenv()) or _G
local fenv = getfenv()
local function exec(name) return env[name] or fenv[name] end
local decompile = exec("decompile")
local writefile, makefolder, isfolder, delfolder = exec("writefile"), exec("makefolder"), exec("isfolder"), exec("delfolder")
local setclipboard, identifyexecutor, gethui = exec("setclipboard"), exec("identifyexecutor"), exec("gethui")
local getloadedmodules, getscripts, getnilinstances = exec("getloadedmodules"), exec("getscripts"), exec("getnilinstances")
local dbg = exec("debug")
local getupvalues = exec("getupvalues") or (type(dbg) == "table" and dbg.getupvalues) or nil

if env.game_dump_running then
    warn("[Game dump] already running")
    return
end
env.game_dump_running = true

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local me = Players.LocalPlayer
local S = { alive = true, finished = false, stopped_at = "" }
local started = os.clock()

---------------------------------------------------------------- saving

local ROOT = "GameDump_" .. tostring(game.PlaceId)
local can_write = typeof(writefile) == "function" and typeof(makefolder) == "function"
if can_write then
    pcall(function()
        if typeof(isfolder) == "function" and typeof(delfolder) == "function" and isfolder(ROOT) then delfolder(ROOT) end
    end)
    for _, f in ipairs({ ROOT, ROOT .. "/scripts", ROOT .. "/data" }) do pcall(makefolder, f) end
end
local function save(path, text)
    if not can_write then return false end
    return (pcall(writefile, ROOT .. "/" .. path, text))
end
-- [[ the later parts each run on their own: if one fails (a game or executor that does something unusual), the ]] --
-- [[ others and the index are still written, and the index says which part failed and why                      ]] --
local problems = {}
local function part(what, fn)
    local ok, err = pcall(fn)
    if not ok then table.insert(problems, what .. ": " .. tostring(err)) end
end

---------------------------------------------------------------- progress bar at the top

local gui = Instance.new("ScreenGui")
gui.Name = "GameDumpProgress"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
local okH, hidden = pcall(function() return typeof(gethui) == "function" and gethui() or nil end)
pcall(function() gui.Parent = (okH and hidden) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = me:WaitForChild("PlayerGui") end
local bar = Instance.new("Frame")
bar.Size = UDim2.fromOffset(420, 40)
bar.Position = UDim2.new(0.5, -210, 0, 70)
bar.BackgroundColor3 = Color3.fromRGB(20, 28, 45)
bar.BorderSizePixel = 0
bar.Parent = gui
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)
local text = Instance.new("TextLabel")
text.BackgroundTransparency = 1
text.Position = UDim2.fromOffset(12, 0)
text.Size = UDim2.new(1, -90, 1, 0)
text.Font = Enum.Font.GothamBold
text.TextSize = 13
text.TextColor3 = Color3.fromRGB(120, 180, 255)
text.TextXAlignment = Enum.TextXAlignment.Left
text.Text = "Game dump: starting..."
text.Parent = bar
local stop = Instance.new("TextButton")
stop.Position = UDim2.new(1, -74, 0, 7)
stop.Size = UDim2.fromOffset(64, 26)
stop.BackgroundColor3 = Color3.fromRGB(45, 52, 70)
stop.BorderSizePixel = 0
stop.Font = Enum.Font.GothamBold
stop.TextSize = 12
stop.TextColor3 = Color3.fromRGB(235, 235, 240)
stop.Text = "Stop"
stop.Parent = bar
Instance.new("UICorner", stop).CornerRadius = UDim.new(0, 6)
-- [[ Stop asks twice (one stray click cut the last dump short); once the dump is done the button closes the bar ]] --
local stop_armed = -100
stop.MouseButton1Click:Connect(function()
    if S.finished then
        gui:Destroy()
        return
    end
    if not S.alive then return end
    if os.clock() - stop_armed > 3 then
        stop_armed = os.clock()
        stop.Text = "Sure?"
        task.delay(3, function()
            if S.alive and not S.finished and stop.Text == "Sure?" then stop.Text = "Stop" end
        end)
        return
    end
    S.alive = false
    S.stopped_at = text.Text
    stop.Text = "..."
end)
local function status(s) text.Text = "Game dump: " .. s end

---------------------------------------------------------------- names

-- [[ paths use LocalPlayer / LocalCharacter instead of your name, so files keep the same names on any account ]] --
local function path_of(inst)
    local ok, full = pcall(function() return inst:GetFullName() end)
    if not ok then return tostring(inst) end
    local inside = pcall(function() assert(inst:IsDescendantOf(game)) end)
    if not inside then full = "nil." .. full end
    for _, pair in ipairs({ { "Players." .. me.Name, "Players.LocalPlayer" }, { "Workspace." .. me.Name, "Workspace.LocalCharacter" } }) do
        local pre = pair[1]
        if full == pre or full:sub(1, #pre + 1) == pre .. "." then full = pair[2] .. full:sub(#pre + 1) end
    end
    return full
end

local used = {}
local function file_name(full, ext)
    local base = (full:gsub("[^%w%._%-]", "_"))
    if #base > 140 then base = base:sub(1, 110) .. "_" .. tostring(#full) .. "_" .. base:sub(-24) end
    local name, n = base, 1
    while used[(name .. ext):lower()] do
        n += 1
        name = base .. "_" .. n
    end
    used[(name .. ext):lower()] = true
    return name .. ext
end

-- [[ what's left out: Roblox's own scripts, copies of scripts that also live in your PlayerGui / PlayerScripts, libraries ]] --
local ROBLOX_ROOTS = { "CoreGui", "CorePackages", "RobloxReplicatedStorage", "RobloxPluginGuiService" }
local COPY_ROOTS = { "StarterGui.", "StarterPlayer.", "StarterPack." }
local ROBLOX_PARTS = { ".PlayerModule", "RbxCharacterSounds", ".ChatScript", ".BubbleChat", ".ChatMain" }
local packages, skipped = {}, { roblox = 0, copy = 0, package = 0, other_player = 0 }
local function skip_reason(inst, full)
    for _, r in ipairs(ROBLOX_ROOTS) do if full:sub(1, #r) == r then return "roblox" end end
    for _, r in ipairs(COPY_ROOTS) do if full:sub(1, #r) == r then return "copy" end end
    for _, r in ipairs(ROBLOX_PARTS) do if full:find(r, 1, true) then return "roblox" end end
    local pkg = full:match("%._Index%.([^%.]+)")
    if pkg then
        packages[pkg] = (packages[pkg] or 0) + 1
        return "package"
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= me and p.Character and inst:IsDescendantOf(p.Character) then return "other_player" end
    end
    return nil
end

---------------------------------------------------------------- turning values into text

local function scalar(v)
    local t = typeof(v)
    if t == "string" then
        if #v > 3000 then v = v:sub(1, 3000) .. "...(cut)" end
        return ("%q"):format(v)
    elseif t == "number" then
        if v == math.floor(v) and math.abs(v) < 2 ^ 53 then return ("%d"):format(v) end
        return tostring(v)
    elseif t == "boolean" or t == "nil" then
        return tostring(v)
    elseif t == "Instance" then
        return "Instance<" .. path_of(v) .. ">"
    elseif t == "function" then
        local fn: (...any) -> ...any = v
        local ok, name, line = pcall(function() return debug.info(fn, "nl") end)
        if not ok then return "<function>" end
        return ("<function %s:%s>"):format((name and name ~= "") and name or "anon", tostring(line))
    elseif t == "Vector3" then
        return ("Vector3(%.3f, %.3f, %.3f)"):format(v.X, v.Y, v.Z)
    elseif t == "Vector2" then
        return ("Vector2(%.3f, %.3f)"):format(v.X, v.Y)
    elseif t == "Color3" then
        return ("RGB(%d, %d, %d)"):format(math.round(v.R * 255), math.round(v.G * 255), math.round(v.B * 255))
    elseif t == "EnumItem" then
        return tostring(v)
    elseif t == "table" then
        return "<table>"
    end
    return t .. "(" .. tostring(v) .. ")"
end

local TYPE_ORDER = { number = 1, string = 2, boolean = 3 }
local function key_less(a, b)
    local ta, tb = type(a), type(b)
    if ta ~= tb then
        local oa, ob = TYPE_ORDER[ta] or 9, TYPE_ORDER[tb] or 9
        if oa ~= ob then return oa < ob end
        return ta < tb
    end
    if ta == "number" or ta == "string" then return a < b end
    return tostring(a) < tostring(b)
end

-- [[ writes a table as readable Lua; tables met again are marked instead of repeated ]] --
local function serialize(value, max_depth, budget)
    local out, size, cut, visited, count = {}, 0, false, {}, 0
    local function emit(s)
        if cut then return end
        size += #s
        if size > budget then
            cut = true
            table.insert(out, "\n... (cut, too big)")
            return
        end
        table.insert(out, s)
    end
    local function key_text(k)
        if type(k) == "string" and k:match("^[%a_][%w_]*$") then return k end
        return "[" .. scalar(k) .. "]"
    end
    local function walk(v, indent, depth)
        if cut then return end
        if type(v) ~= "table" then
            emit(scalar(v))
            return
        end
        if visited[v] then
            emit("<table shown above>")
            return
        end
        if depth >= max_depth then
            emit("{...}")
            return
        end
        visited[v] = true
        count += 1
        if count % 400 == 0 then task.wait() end
        local keys, n = {}, 0
        for k in pairs(v) do
            n += 1
            if n <= 2000 then table.insert(keys, k) end
        end
        if n == 0 then
            emit("{}")
            return
        end
        local array = rawlen(v) == n
        if not array then table.sort(keys, key_less) end
        emit("{\n")
        local limit = math.min(#keys, 600)
        for i = 1, limit do
            local k = array and i or keys[i]
            emit(indent .. "  ")
            if not array then emit(key_text(k) .. " = ") end
            walk(rawget(v, k), indent .. "  ", depth + 1)
            emit(",\n")
            if cut then return end
        end
        if n > limit then emit(indent .. ("  -- ... %d more entries\n"):format(n - limit)) end
        emit(indent .. "}")
    end
    walk(value, "", 0)
    return table.concat(out)
end

---------------------------------------------------------------- 1) every client script, decompiled

local found, list = {}, {}
local function is_client_code(d)
    if d:IsA("ModuleScript") or d:IsA("LocalScript") then return true end
    if d:IsA("Script") then
        local ok, rc = pcall(function() return d.RunContext end)
        return ok and rc == Enum.RunContext.Client
    end
    return false
end
local function consider(d)
    if typeof(d) ~= "Instance" or found[d] then return end
    local ok, code = pcall(is_client_code, d)
    if not (ok and code) then return end
    found[d] = true
    local full = path_of(d)
    local why = skip_reason(d, full)
    if why then
        skipped[why] += 1
        return
    end
    table.insert(list, { inst = d, path = full })
end

status("finding scripts...")
local roots = { RS, workspace, me }
for _, name in ipairs({ "ReplicatedFirst", "Lighting", "SoundService", "Chat", "Teams" }) do
    local ok, svc = pcall(game.GetService, game, name)
    if ok and svc then table.insert(roots, svc) end
end
for _, root in ipairs(roots) do
    for i, d in ipairs(root:GetDescendants()) do
        consider(d)
        if i % 3000 == 0 then task.wait() end
    end
end
for _, getter in ipairs({ getscripts, getnilinstances }) do
    if typeof(getter) == "function" then
        local ok, extra = pcall(getter)
        if ok and type(extra) == "table" then
            for _, d in ipairs(extra) do consider(d) end
        end
    end
end
table.sort(list, function(a, b) return a.path < b.path end)

local by_inst, failed, total_chars, written = {}, {}, 0, 0
if typeof(decompile) == "function" then
    for i, item in ipairs(list) do
        if not S.alive then break end
        status(("reading scripts %d / %d"):format(i, #list))
        local ok, src = pcall(decompile, item.inst)
        if ok and type(src) == "string" and #src > 0 then
            item.file = file_name(item.path, ".lua")
            item.size = #src
            total_chars += #src
            by_inst[item.inst] = item.file
            if save("scripts/" .. item.file, ("-- %s (%s)\n"):format(item.path, item.inst.ClassName) .. src) then written += 1 end
        else
            item.err = ok and "came back empty" or tostring(src)
            table.insert(failed, item)
        end
        task.wait()
    end
end

---------------------------------------------------------------- 2) what each module holds (configs, data, functions)

local CONFIG_WORDS = { config = true, configs = true, constants = true, settings = true, data = true }
local DATA_WORDS = { "data", "replica", "store", "state", "cache", "profile", "session", "inventory", "receiver" }
local modules, seen_m = {}, {}
local function add_module(m)
    if typeof(m) ~= "Instance" or seen_m[m] then return end
    if not m:IsA("ModuleScript") then return end
    seen_m[m] = true
    local full = path_of(m)
    if skip_reason(m, full) then return end
    table.insert(modules, { inst = m, path = full })
end
-- [[ the ones the game already loaded, so reading them runs nothing new ]] --
local loaded_count = 0
if typeof(getloadedmodules) == "function" then
    local ok, l = pcall(getloadedmodules)
    if ok and type(l) == "table" then
        for _, m in ipairs(l) do
            add_module(m)
        end
        loaded_count = #modules
    end
end
-- [[ plus every module inside a config / settings / data folder (these only hold values) ]] --
for _, d in ipairs(RS:GetDescendants()) do
    if d:IsA("ModuleScript") then
        local p = d.Parent
        while p and p ~= RS do
            if CONFIG_WORDS[p.Name:lower()] then
                add_module(d)
                break
            end
            p = p.Parent
        end
    end
end
table.sort(modules, function(a, b) return a.path < b.path end)

local function safe_require(m)
    local done, ok, res = false, false, nil
    task.spawn(function()
        ok, res = pcall(require, m)
        done = true
    end)
    local t = os.clock()
    while not done and os.clock() - t < 3 do task.wait() end
    if not done then return false, "took too long" end
    return ok, res
end
local function data_ish(full)
    local low = full:lower()
    for _, w in ipairs(DATA_WORDS) do if low:find(w, 1, true) then return true end end
    return false
end

local data_files, with_upvalues = {}, 0
for i, item in ipairs(modules) do
    if not S.alive then break end
    status(("reading module data %d / %d"):format(i, #modules))
    local ok, value = safe_require(item.inst)
    local body
    if ok then
        body = "return " .. serialize(value, 9, 400000)
    else
        body = "-- couldn't read it: " .. tostring(value)
    end
    -- [[ data modules keep the real values (like your saved data) in hidden variables of their functions ]] --
    if ok and type(value) == "table" and typeof(getupvalues) == "function" and data_ish(item.path) then
        local found_ups, any = {}, false
        for k, f in pairs(value) do
            if type(f) == "function" then
                local got, ups = pcall(getupvalues, f)
                if got and type(ups) == "table" and next(ups) then
                    found_ups[tostring(k)] = ups
                    any = true
                end
            end
        end
        if any then
            with_upvalues += 1
            body ..= "\n\n-- hidden values used by its functions:\nlocal hidden = " .. serialize(found_ups, 8, 600000)
        end
    end
    item.file = file_name(item.path, ".txt")
    save("data/" .. item.file, ("-- %s (what this module holds)\n"):format(item.path) .. body)
    table.insert(data_files, item)
    task.wait()
end

---------------------------------------------------------------- 3) the game's objects

status("writing the object tree...")
local tree, tree_cut = {}, false
local function tline(s)
    if #tree >= 90000 then
        tree_cut = true
        return
    end
    table.insert(tree, s)
    if #tree % 3000 == 0 then task.wait() end
end
local function extras(d)
    local bits = {}
    pcall(function()
        if d:IsA("ValueBase") then table.insert(bits, "= " .. scalar((d :: any).Value)) end
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            local t = (d :: any).Text
            if t ~= "" then table.insert(bits, "text=" .. scalar(t:sub(1, 80))) end
        end
        if d:IsA("Sound") then table.insert(bits, "id=" .. (d :: any).SoundId) end
        if d:IsA("Animation") then table.insert(bits, "anim=" .. (d :: any).AnimationId) end
        if d:IsA("ProximityPrompt") then
            local p = d :: any
            table.insert(bits, ("action=%q object=%q hold=%.2f range=%d"):format(p.ActionText, p.ObjectText, p.HoldDuration, p.MaxActivationDistance))
        end
        if d:IsA("GuiObject") and not (d :: any).Visible then table.insert(bits, "(hidden)") end
        if by_inst[d] then table.insert(bits, "-> scripts/" .. by_inst[d]) end
        local attrs = d:GetAttributes()
        if next(attrs) then
            local a = {}
            for k, v in pairs(attrs) do table.insert(a, k .. "=" .. scalar(v)) end
            table.sort(a)
            local s = table.concat(a, ", ")
            if #s > 700 then s = s:sub(1, 700) .. "..." end
            table.insert(bits, "{" .. s .. "}")
        end
    end)
    return #bits > 0 and (" " .. table.concat(bits, " ")) or ""
end
local function walk_tree(d, depth, max_depth, per_parent)
    if tree_cut or not S.alive then return end
    local pad = string.rep("  ", depth)
    local other = d:IsA("Model") and Players:GetPlayerFromCharacter(d)
    if other and other ~= me then
        tline(pad .. "Model " .. d.Name .. " (another player's character)")
        return
    end
    tline(pad .. d.ClassName .. " " .. d.Name .. extras(d))
    local kids = d:GetChildren()
    if #kids == 0 then return end
    if depth >= max_depth then
        tline(pad .. ("  (%d children not shown)"):format(#kids))
        return
    end
    -- [[ many children with the same name and class are shown twice, then counted ]] --
    local groups, order = {}, {}
    for _, c in ipairs(kids) do
        local key = c.ClassName .. "|" .. c.Name
        if not groups[key] then
            groups[key] = {}
            table.insert(order, key)
        end
        table.insert(groups[key], c)
    end
    local shown, left = 0, #kids
    for _, key in ipairs(order) do
        local g = groups[key]
        for i, c in ipairs(g) do
            if i > 2 then
                tline(pad .. ("  ... and %d more %s %q"):format(#g - 2, c.ClassName, c.Name))
                left -= #g - 2
                break
            end
            if shown >= per_parent then break end
            shown += 1
            left -= 1
            walk_tree(c, depth + 1, max_depth, per_parent)
        end
        if shown >= per_parent then break end
    end
    if shown >= per_parent and left > 0 then tline(pad .. ("  ... and %d more children"):format(left)) end
end
local TREE_ROOTS = { { RS, 16, 80 }, { me, 16, 60 }, { workspace, 6, 40 } }
for _, name in ipairs({ "ReplicatedFirst", "Lighting", "SoundService", "Teams" }) do
    local ok, svc = pcall(game.GetService, game, name)
    if ok and svc then table.insert(TREE_ROOTS, { svc, 5, 40 }) end
end
for _, r in ipairs(TREE_ROOTS) do
    tline("")
    tline("==== " .. path_of(r[1]) .. " ====")
    pcall(walk_tree, r[1], 0, r[2], r[3])
end
if tree_cut then table.insert(tree, "... (cut, too big)") end
save("tree.txt", table.concat(tree, "\n"))

---------------------------------------------------------------- 3b) the map: every part with its shape, place and look
-- [[ map.txt     every part in the world (and the models kept in ReplicatedStorage, like pets and eggs): where it is, ]] --
-- [[             how big, turned how, colour, material, see-through, collides/anchored, mesh and texture ids         ]] --
-- [[ models.txt  every model: where it is and how big it is overall (its bounding box), how many parts it has         ]] --
-- [[ assets.txt  every mesh, texture, decal, sound, animation and image id the game uses, with how often               ]] --
-- [[ world.txt   lighting, sky, atmosphere, post effects, terrain water and the camera/gravity settings               ]] --
local map_n, model_n, asset_n = 0, 0, 0
part("map", function()
    status("reading the map...")
    local lines, models, assets = {}, {}, {}
    local cut = false
    local function v3(v) return ("%.2f,%.2f,%.2f"):format(v.X, v.Y, v.Z) end
    local function hex(c) return ("#%02X%02X%02X"):format(math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)) end
    local function asset(kind, id, where)
        if typeof(id) ~= "string" or id == "" then return end
        local a = assets[id]
        if not a then
            a = { kind = kind, n = 0, where = where }
            assets[id] = a
        end
        a.n += 1
    end
    local function add_line(s)
        if #lines >= 150000 then cut = true return end
        table.insert(lines, s)
        if #lines % 2500 == 0 then task.wait() end
    end
    local function describe(d, full)
        local ok, s = pcall(function()
            if d:IsA("BasePart") then
                local p = d :: any
                local bits = { ("%-14s %s | pos %s | size %s | rot %s | %s %s"):format(d.ClassName, full, v3(p.Position), v3(p.Size),
                    v3(p.Orientation), hex(p.Color), tostring(p.Material.Name)) }
                if p.Transparency > 0 then table.insert(bits, ("see-through %.2f"):format(p.Transparency)) end
                if not p.CanCollide then table.insert(bits, "no-collide") end
                if not p.Anchored then table.insert(bits, "loose") end
                if p.Reflectance > 0 then table.insert(bits, ("shiny %.2f"):format(p.Reflectance)) end
                if d:IsA("Part") then table.insert(bits, "shape " .. tostring(p.Shape.Name)) end
                if d:IsA("MeshPart") then
                    table.insert(bits, "mesh " .. p.MeshId .. (p.TextureID ~= "" and (" tex " .. p.TextureID) or ""))
                    asset("mesh", p.MeshId, full)
                    asset("texture", p.TextureID, full)
                end
                return table.concat(bits, " | ")
            elseif d:IsA("Decal") then
                local x = d :: any
                asset(d:IsA("Texture") and "texture" or "decal", x.Texture, full)
                return ("%-14s %s | %s on %s | %s see-through %.2f"):format(d.ClassName, full, x.Texture, tostring(x.Face.Name), hex(x.Color3), x.Transparency)
            elseif d:IsA("SpecialMesh") then
                local x = d :: any
                asset("mesh", x.MeshId, full)
                asset("texture", x.TextureId, full)
                return ("%-14s %s | %s %s tex %s scale %s"):format(d.ClassName, full, tostring(x.MeshType.Name), x.MeshId, x.TextureId, v3(x.Scale))
            elseif d:IsA("Light") then
                local x = d :: any
                return ("%-14s %s | %s brightness %.2f range %s"):format(d.ClassName, full, hex(x.Color), x.Brightness,
                    tostring((x :: any).Range or "-"))
            elseif d:IsA("ParticleEmitter") then
                local x = d :: any
                asset("particle", x.Texture, full)
                return ("%-14s %s | %s rate %.1f life %s speed %s"):format(d.ClassName, full, x.Texture, x.Rate, tostring(x.Lifetime), tostring(x.Speed))
            elseif d:IsA("Beam") or d:IsA("Trail") then
                local x = d :: any
                asset("texture", x.Texture, full)
                return ("%-14s %s | %s"):format(d.ClassName, full, x.Texture)
            elseif d:IsA("SurfaceGui") or d:IsA("BillboardGui") then
                local texts = {}
                for _, t in ipairs(d:GetDescendants()) do
                    if (t:IsA("TextLabel") or t:IsA("TextButton")) and (t :: any).Text ~= "" and #texts < 4 then table.insert(texts, (t :: any).Text:sub(1, 40)) end
                    if t:IsA("ImageLabel") or t:IsA("ImageButton") then asset("image", (t :: any).Image, full) end
                end
                return ("%-14s %s | %s"):format(d.ClassName, full, table.concat(texts, " / "))
            elseif d:IsA("Sound") then
                asset("sound", (d :: any).SoundId, full)
            elseif d:IsA("Animation") then
                asset("animation", (d :: any).AnimationId, full)
            elseif d:IsA("Model") then
                local cf, size = (d :: any):GetBoundingBox()
                local count = 0
                for _, x in ipairs(d:GetDescendants()) do if x:IsA("BasePart") then count += 1 end end
                model_n += 1
                table.insert(models, ("%s | center %s | size %s | %d parts"):format(full, v3(cf.Position), v3(size), count))
            end
            return nil
        end)
        return ok and s or nil
    end
    local function walk(d, full)
        if cut or not S.alive then return end
        local other = d:IsA("Model") and Players:GetPlayerFromCharacter(d)
        if other and other ~= me then return end
        local s = describe(d, full)
        if s then
            map_n += 1
            add_line(s)
        end
        for _, c in ipairs(d:GetChildren()) do walk(c, full .. "." .. c.Name) end
    end
    for _, root in ipairs({ workspace, RS }) do
        add_line("==== " .. root.Name .. " ====")
        walk(root, root.Name)
    end
    -- [[ the images in the game's own screens too (icons, buttons, backgrounds) ]] --
    pcall(function()
        for _, t in ipairs(me.PlayerGui:GetDescendants()) do
            if t:IsA("ImageLabel") or t:IsA("ImageButton") then asset("image", (t :: any).Image, "PlayerGui") end
        end
    end)
    if cut then table.insert(lines, "... (cut at 150000 lines)") end
    save("map.txt", "positions and sizes in studs, rot = orientation in degrees, colours as #RRGGBB\n" .. table.concat(lines, "\n"))
    table.sort(models)
    save("models.txt", "center and size = the model's bounding box in studs\n" .. table.concat(models, "\n"))
    local list = {}
    for id, a in pairs(assets) do table.insert(list, a) ; a.id = id end
    table.sort(list, function(a, b) if a.kind ~= b.kind then return a.kind < b.kind end return a.n > b.n end)
    local out = {}
    for _, a in ipairs(list) do table.insert(out, ("%-10s %5dx  %s   (first at %s)"):format(a.kind, a.n, a.id, a.where)) end
    asset_n = #list
    save("assets.txt", table.concat(out, "\n"))
end)
part("world", function()
    status("reading lighting and terrain...")
    local w = {}
    local function props(inst, names)
        local bits = {}
        for _, n in ipairs(names) do
            local ok, v = pcall(function() return (inst :: any)[n] end)
            if ok then table.insert(bits, n .. "=" .. scalar(v)) end
        end
        return table.concat(bits, "  ")
    end
    local L = game:GetService("Lighting")
    table.insert(w, "Lighting: " .. props(L, { "Technology", "Ambient", "OutdoorAmbient", "Brightness", "ClockTime", "GeographicLatitude",
        "ColorShift_Top", "ColorShift_Bottom", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GlobalShadows", "ShadowSoftness",
        "ExposureCompensation", "FogColor", "FogStart", "FogEnd" }))
    for _, c in ipairs(L:GetChildren()) do
        table.insert(w, ("  %s %s: %s"):format(c.ClassName, c.Name, props(c, { "Enabled", "Density", "Offset", "Color", "Decay", "Glare", "Haze",
            "Intensity", "Size", "Threshold", "Brightness", "Contrast", "Saturation", "TintColor", "SkyboxBk", "SkyboxUp", "SunTextureId",
            "MoonTextureId", "StarCount", "CelestialBodiesShown" })))
    end
    local T = workspace:FindFirstChildOfClass("Terrain")
    if T then
        table.insert(w, "Terrain: " .. props(T, { "WaterColor", "WaterReflectance", "WaterTransparency", "WaterWaveSize", "WaterWaveSpeed", "Decoration" }))
        pcall(function()
            local r = T:CountCellsAsync()
            table.insert(w, "  terrain cells: " .. tostring(r))
        end)
    end
    table.insert(w, "Workspace: " .. props(workspace, { "Gravity", "FallenPartsDestroyHeight", "StreamingEnabled", "StreamingMinRadius",
        "StreamingTargetRadius", "GlobalWind" }))
    local cam = workspace.CurrentCamera
    if cam then table.insert(w, "Camera: " .. props(cam, { "FieldOfView", "CameraType" })) end
    table.insert(w, "Players: " .. props(Players, { "RespawnTime", "CharacterAutoLoads", "MaxPlayers" }))
    pcall(function()
        local sp = game:GetService("StarterPlayer")
        table.insert(w, "StarterPlayer: " .. props(sp, { "CharacterWalkSpeed", "CharacterJumpPower", "CharacterJumpHeight", "CameraMaxZoomDistance",
            "CameraMinZoomDistance", "CameraMode", "DevComputerMovementMode", "AutoJumpEnabled" }))
    end)
    for _, s in ipairs(workspace:GetDescendants()) do
        if s:IsA("SpawnLocation") then table.insert(w, ("SpawnLocation %s at %s"):format(path_of(s), tostring((s :: any).Position))) end
    end
    save("world.txt", table.concat(w, "\n"))
end)

---------------------------------------------------------------- 3c) the screens and how they're styled
-- [[ ui.txt   every screen element: size and place, colours, see-through, fonts, text size and colour, rounded  ]] --
-- [[          corners, outlines, gradients, padding, layouts, images; hidden ones too (shops and popups wait     ]] --
-- [[          hidden until opened). palette.txt: every colour and font used on screen, most used first.          ]] --
local ui_n = 0
part("ui", function()
    status("reading the screens and their style...")
    local lines, colors, fonts = {}, {}, {}
    local function hex(c) return ("#%02X%02X%02X"):format(math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)) end
    local function ud(u) return ("{%.2f,%d,%.2f,%d}"):format(u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset) end
    local function count(t, k) t[k] = (t[k] or 0) + 1 end
    local function style(d)
        local x, b = d :: any, {}
        if d:IsA("GuiObject") then
            table.insert(b, "size " .. ud(x.Size) .. " pos " .. ud(x.Position))
            if x.AnchorPoint ~= Vector2.zero then table.insert(b, ("anchor %.2f,%.2f"):format(x.AnchorPoint.X, x.AnchorPoint.Y)) end
            if x.BackgroundTransparency < 1 then
                table.insert(b, ("bg %s %.2f"):format(hex(x.BackgroundColor3), x.BackgroundTransparency))
                count(colors, hex(x.BackgroundColor3) .. " (background)")
            end
            if x.Rotation ~= 0 then table.insert(b, "rot " .. x.Rotation) end
            if x.ZIndex ~= 1 then table.insert(b, "z " .. x.ZIndex) end
            if not x.Visible then table.insert(b, "(hidden)") end
        end
        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
            local font = tostring(x.Font.Name)
            pcall(function() font = x.FontFace.Family:match("([^/]+)%.json$") or font; font ..= " " .. tostring(x.FontFace.Weight.Name) end)
            table.insert(b, ("text %q %s %dpx %s"):format(x.Text:sub(1, 50), font, x.TextSize, hex(x.TextColor3)))
            if x.TextScaled then table.insert(b, "scaled") end
            if x.TextStrokeTransparency < 1 then table.insert(b, "text-outline " .. hex(x.TextStrokeColor3)) end
            count(fonts, font)
            count(colors, hex(x.TextColor3) .. " (text)")
        end
        if d:IsA("ImageLabel") or d:IsA("ImageButton") then
            table.insert(b, "image " .. x.Image .. (x.ImageColor3 ~= Color3.new(1, 1, 1) and (" tint " .. hex(x.ImageColor3)) or ""))
            if x.ScaleType ~= Enum.ScaleType.Stretch then table.insert(b, "scale " .. x.ScaleType.Name) end
            if x.SliceCenter ~= Rect.new(0, 0, 0, 0) then table.insert(b, "9-slice") end
        end
        if d:IsA("UICorner") then table.insert(b, ("radius %.2f,%d"):format(x.CornerRadius.Scale, x.CornerRadius.Offset)) end
        if d:IsA("UIStroke") then
            table.insert(b, ("outline %s %.1fpx %.2f %s"):format(hex(x.Color), x.Thickness, x.Transparency, x.ApplyStrokeMode.Name))
            count(colors, hex(x.Color) .. " (outline)")
        end
        if d:IsA("UIGradient") then
            local ks = {}
            for _, k in ipairs(x.Color.Keypoints) do table.insert(ks, ("%s@%.2f"):format(hex(k.Value), k.Time)) end
            table.insert(b, "gradient " .. table.concat(ks, " ") .. " rot " .. x.Rotation)
        end
        if d:IsA("UIPadding") then
            table.insert(b, ("padding %d %d %d %d"):format(x.PaddingTop.Offset, x.PaddingRight.Offset, x.PaddingBottom.Offset, x.PaddingLeft.Offset))
        end
        if d:IsA("UIListLayout") then table.insert(b, ("list %s gap %d"):format(x.FillDirection.Name, x.Padding.Offset)) end
        if d:IsA("UIGridLayout") then table.insert(b, "grid cell " .. ud(x.CellSize) .. " gap " .. ud(x.CellPadding)) end
        if d:IsA("UIAspectRatioConstraint") then table.insert(b, ("aspect %.2f"):format(x.AspectRatio)) end
        if d:IsA("UIScale") then table.insert(b, ("scale %.2f"):format(x.Scale)) end
        if d:IsA("ScreenGui") then table.insert(b, ("order %d %s"):format(x.DisplayOrder, x.IgnoreGuiInset and "full-screen" or "")) end
        return table.concat(b, " | ")
    end
    local function walk(d, depth)
        if not S.alive or #lines >= 120000 then return end
        local ok, s = pcall(style, d)
        table.insert(lines, string.rep("  ", depth) .. d.ClassName .. " " .. d.Name .. (ok and s ~= "" and (" | " .. s) or ""))
        ui_n += 1
        if #lines % 2500 == 0 then task.wait() end
        for _, c in ipairs(d:GetChildren()) do walk(c, depth + 1) end
    end
    for _, g in ipairs(me.PlayerGui:GetChildren()) do
        if g ~= gui then walk(g, 0) end
    end
    pcall(function()
        for _, g in ipairs(game:GetService("StarterGui"):GetChildren()) do
            if not me.PlayerGui:FindFirstChild(g.Name) then walk(g, 0) end
        end
    end)
    save("ui.txt", "sizes and places as {xScale,xOffset,yScale,yOffset}; colours as #RRGGBB with see-through 0..1\n" .. table.concat(lines, "\n"))
    local function top(t)
        local l = {}
        for k, n in pairs(t) do table.insert(l, { k, n }) end
        table.sort(l, function(a, b) return a[2] > b[2] end)
        local out = {}
        for i = 1, math.min(#l, 80) do table.insert(out, ("%5dx  %s"):format(l[i][2], l[i][1])) end
        return table.concat(out, "\n")
    end
    save("palette.txt", "---- colours ----\n" .. top(colors) .. "\n\n---- fonts ----\n" .. top(fonts))
end)

---------------------------------------------------------------- 4) you and the other players

status("writing your stats...")
local p = {}
local function attrs_of(inst)
    local a = {}
    for k, v in pairs(inst:GetAttributes()) do table.insert(a, ("  %s = %s"):format(k, scalar(v))) end
    table.sort(a)
    return a
end
table.insert(p, ("me: %s (%d), display %q, account age %d days"):format(me.Name, me.UserId, me.DisplayName, me.AccountAge))
table.insert(p, "")
table.insert(p, "---- your attributes ----")
for _, l in ipairs(attrs_of(me)) do table.insert(p, l) end
table.insert(p, "")
table.insert(p, "---- leaderstats ----")
local ls = me:FindFirstChild("leaderstats")
for _, v in ipairs(ls and ls:GetChildren() or {}) do
    table.insert(p, ("  %s = %s"):format(v.Name, v:IsA("ValueBase") and scalar((v :: any).Value) or v.ClassName))
end
table.insert(p, "")
table.insert(p, "---- what's inside your player ----")
for _, c in ipairs(me:GetChildren()) do table.insert(p, ("  %s %s"):format(c.ClassName, c.Name)) end
local char = me.Character
if char then
    table.insert(p, "")
    table.insert(p, "---- your character ----")
    for _, l in ipairs(attrs_of(char)) do table.insert(p, l) end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        table.insert(p, ("  Humanoid: WalkSpeed=%s JumpPower=%s JumpHeight=%s HipHeight=%s Health=%s/%s RigType=%s"):format(
            tostring(hum.WalkSpeed), tostring(hum.JumpPower), tostring(hum.JumpHeight), tostring(hum.HipHeight),
            tostring(hum.Health), tostring(hum.MaxHealth), tostring(hum.RigType)))
    end
    for _, c in ipairs(char:GetChildren()) do
        if not c:IsA("BasePart") and not c:IsA("Accessory") then table.insert(p, ("  %s %s%s"):format(c.ClassName, c.Name, extras(c))) end
    end
end
table.insert(p, "")
table.insert(p, "---- other players ----")
for _, other in ipairs(Players:GetPlayers()) do
    if other ~= me then
        local a = attrs_of(other)
        local stats = {}
        local ols = other:FindFirstChild("leaderstats")
        for _, v in ipairs(ols and ols:GetChildren() or {}) do
            if v:IsA("ValueBase") then table.insert(stats, v.Name .. "=" .. scalar((v :: any).Value)) end
        end
        table.insert(p, ("  %s | %s"):format(other.Name, table.concat(stats, ", ")))
        for i = 1, math.min(#a, 40) do table.insert(p, "  " .. a[i]) end
    end
end
save("player.txt", table.concat(p, "\n"))

---------------------------------------------------------------- 5) every remote, wherever the client can see it

status("listing remotes...")
local r = {}
part("remotes", function()
    local seen, count, order = {}, {}, {}
    for _, root in ipairs(roots) do
        for i, d in ipairs(root:GetDescendants()) do
            if not seen[d] and (d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("UnreliableRemoteEvent")
                or d:IsA("BindableEvent") or d:IsA("BindableFunction")) then
                seen[d] = true
                local full = path_of(d)
                if skip_reason(d, full) ~= "other_player" then
                    local line = ("%-22s %s%s"):format(d.ClassName, full, extras(d))
                    if not count[line] then
                        count[line] = 0
                        table.insert(order, line)
                    end
                    count[line] += 1
                end
            end
            if i % 3000 == 0 then task.wait() end
        end
    end
    table.sort(order)
    for _, line in ipairs(order) do
        table.insert(r, line .. (count[line] > 1 and ("   x%d"):format(count[line]) or ""))
    end
end)
save("remotes.txt", table.concat(r, "\n"))

---------------------------------------------------------------- 6) everything you can press: prompts and click detectors

-- [[ the tree only goes so deep, so these get their own full list: what it says, how long to hold, from how far, ]] --
-- [[ and where the first three of each are (many of the same are counted)                                        ]] --
status("listing prompts and click detectors...")
local press, press_n = {}, 0
part("prompts", function()
    local groups, order = {}, {}
    local function spot(d)
        local ok, pos = pcall(function()
            local at = d.Parent
            if at:IsA("BasePart") then return at.Position end
            if at:IsA("Attachment") then return (at :: any).WorldPosition end
            if at:IsA("Model") then return at:GetPivot().Position end
            local m = at:FindFirstAncestorWhichIsA("Model")
            return m and m:GetPivot().Position or nil
        end)
        return ok and pos and (" at %d, %d, %d"):format(pos.X, pos.Y, pos.Z) or " at ?"
    end
    for i, d in ipairs(workspace:GetDescendants()) do
        local line = nil
        if d:IsA("ProximityPrompt") then
            local q = d :: any
            line = ("ProximityPrompt  %s  action=%q object=%q hold=%.2f range=%d%s"):format(path_of(d), q.ActionText, q.ObjectText,
                q.HoldDuration, q.MaxActivationDistance, q.Enabled and "" or " (off)")
        elseif d:IsA("ClickDetector") then
            line = ("ClickDetector    %s  range=%d"):format(path_of(d), (d :: any).MaxActivationDistance)
        end
        if line then
            press_n += 1
            local g = groups[line]
            if not g then
                g = { n = 0, spots = {} }
                groups[line] = g
                table.insert(order, line)
            end
            g.n += 1
            if g.n <= 3 then table.insert(g.spots, spot(d)) end
        end
        if i % 3000 == 0 then task.wait() end
    end
    table.sort(order)
    for _, line in ipairs(order) do
        local g = groups[line]
        table.insert(press, line .. (g.n > 1 and ("   x%d"):format(g.n) or "") .. "  |" .. table.concat(g.spots, " |"))
    end
end)
save("prompts.txt", table.concat(press, "\n"))

---------------------------------------------------------------- 7) the store: places, developer products, game passes

-- [[ public info only: what the game sells and for how much, and the other places it has ]] --
status("reading the store...")
local store = {}
part("store", function()
    local function timed(fn, secs)
        local done, ok, res = false, false, nil
        task.spawn(function()
            ok, res = pcall(fn)
            done = true
        end)
        local t = os.clock()
        while not done and os.clock() - t < secs do task.wait() end
        if not done then return false, "took too long" end
        return ok, res
    end
    local function row(t)
        local keys = {}
        for k in pairs(t) do table.insert(keys, k) end
        table.sort(keys, key_less)
        local bits = {}
        for _, k in ipairs(keys) do
            local v = t[k]
            if type(v) ~= "table" then
                local s = scalar(v)
                if #s > 90 then s = s:sub(1, 90) .. "..." end
                table.insert(bits, tostring(k) .. "=" .. s)
            end
        end
        return "  " .. table.concat(bits, " | ")
    end
    local function pages_into(title, getter)
        table.insert(store, "---- " .. title .. " ----")
        local ok, pages: any = timed(getter, 8)
        if not (ok and pages) then
            table.insert(store, "  couldn't read: " .. tostring(pages))
            table.insert(store, "")
            return
        end
        local n = 0
        while S.alive do
            local okP, page = pcall(function() return pages:GetCurrentPage() end)
            if not okP or type(page) ~= "table" then break end
            for _, it in ipairs(page) do
                n += 1
                table.insert(store, type(it) == "table" and row(it) or ("  " .. scalar(it)))
            end
            if pages.IsFinished or n >= 600 then break end
            if not timed(function()
                pages:AdvanceToNextPageAsync()
                return true
            end, 8) then break end
        end
        if n == 0 then table.insert(store, "  (none)") end
        table.insert(store, "")
    end
    pages_into("places in this game", function() return game:GetService("AssetService"):GetGamePlacesAsync() end)
    pages_into("developer products (bought with Robux, as often as you like)", function()
        return game:GetService("MarketplaceService"):GetDeveloperProductsAsync()
    end)
    table.insert(store, "---- game passes ----")
    local request = exec("request") or exec("http_request")
    local HttpService = game:GetService("HttpService")
    local function http_get(url)
        if typeof(request) == "function" then
            local ok, res = pcall(request, { Url = url, Method = "GET" })
            if ok and type(res) == "table" and type(res.Body) == "string" and (res.StatusCode == nil or res.StatusCode == 200) then return res.Body end
        end
        local ok, body = pcall(function() return (game :: any):HttpGet(url) end)
        return ok and type(body) == "string" and body or nil
    end
    local got = false
    for _, url in ipairs({
        ("https://apis.roblox.com/game-passes/v1/universes/%d/game-passes?passView=Full&pageSize=100"):format(game.GameId),
        ("https://games.roblox.com/v1/games/%d/game-passes?limit=100&sortOrder=Asc"):format(game.GameId),
    }) do
        local ok, body = timed(function() return http_get(url) end, 8)
        local okJ, data = pcall(function() return HttpService:JSONDecode(body) end)
        local arr = ok and okJ and type(data) == "table" and (data.gamePasses or data.data) or nil
        if type(arr) == "table" then
            for _, it in ipairs(arr) do
                if type(it) == "table" then table.insert(store, row(it)) end
            end
            if #arr == 0 then table.insert(store, "  (none)") end
            got = true
            break
        end
    end
    if not got then table.insert(store, "  couldn't read the list (Roblox's web API didn't answer)") end
end)
save("store.txt", table.concat(store, "\n"))

---------------------------------------------------------------- 8) the index

local name, creator = "?", "?"
pcall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    name = info.Name
    creator = tostring(type(info.Creator) == "table" and info.Creator.Name or "?")
end)
local exec_name = "?"
pcall(function() exec_name = tostring((identifyexecutor())) end)
local idx = {}
local function add(s) table.insert(idx, s) end
add(S.alive and "Game dump" or ("Game dump (STOPPED EARLY at: " .. tostring(S.stopped_at) .. "; the parts after that are missing)"))
add(("game: %s | by %s | place %d | game %d | version %d"):format(name, creator, game.PlaceId, game.GameId, game.PlaceVersion))
add(("me: %s (%d) | executor: %s | made %s | took %ds"):format(me.Name, me.UserId, exec_name, os.date("%Y-%m-%d %H:%M"), math.floor(os.clock() - started)))
part("server line", function()
    local private, streaming = false, false
    pcall(function() private = game.PrivateServerId ~= "" end)
    pcall(function() streaming = workspace.StreamingEnabled end)
    add(("server: %d / %d players | %s | streaming %s"):format(#Players:GetPlayers(), Players.MaxPlayers, private and "private server" or "public server",
        streaming and "ON (only the map near you is loaded: the tree and prompts cover what was around you)" or "off (the whole map is loaded)"))
end)
add(("folder: your executor's workspace folder, %s%s"):format(ROOT, can_write and "" or " (NOT SAVED: this executor can't write files)"))
add("")
add("files:")
add(("  scripts/     %d decompiled scripts, %d chars in all%s"):format(written, total_chars, typeof(decompile) == "function" and "" or " (no decompile in this executor)"))
add(("  data/        %d modules: what each one holds (%d were already loaded by the game), %d with their hidden values"):format(#data_files, loaded_count, with_upvalues))
add(("  tree.txt     the game's objects (%d lines)"):format(#tree))
add(("  map.txt      %d parts, decals, meshes, lights and effects with position, size, rotation, colour, material"):format(map_n))
add(("  models.txt   %d models with where they are and how big"):format(model_n))
add(("  assets.txt   %d mesh / texture / image / sound / animation ids, with how often each is used"):format(asset_n))
add(("  world.txt    lighting, sky, atmosphere, terrain, gravity, spawn, walk speed and camera settings"))
add(("  ui.txt       %d screen elements with size, colours, fonts, corners, outlines, gradients, images"):format(ui_n))
add(("  palette.txt  every colour and font on screen, most used first"))
add(("  player.txt   your stats and attributes, and other players'"))
add(("  remotes.txt  %d remotes"):format(#r))
add(("  prompts.txt  %d prompts and click detectors in the map"):format(press_n))
add(("  store.txt    the game's places, developer products and game passes with prices (%d lines)"):format(#store))
add("")
-- [[ what this executor can do, so scripts for this game are written with what's really there ]] --
part("executor list", function()
    local has, missing = {}, {}
    for _, n in ipairs({ "decompile", "getgc", "getgenv", "getrenv", "getsenv", "getconnections", "firesignal", "fireproximityprompt",
        "fireclickdetector", "firetouchinterest", "hookfunction", "hookmetamethod", "getnamecallmethod", "getrawmetatable", "setreadonly",
        "newcclosure", "checkcaller", "getcallingscript", "getscriptclosure", "getscriptbytecode", "getupvalues", "setupvalue", "getconstants",
        "getloadedmodules", "getnilinstances", "getinstances", "cloneref", "gethui", "queue_on_teleport", "request", "readfile", "writefile",
        "appendfile", "isfile", "listfiles", "makefolder", "delfolder", "setclipboard", "setfpscap", "isrbxactive", "mouse1click", "keypress",
        "Drawing", "WebSocket" }) do
        table.insert(exec(n) ~= nil and has or missing, n)
    end
    add("executor has: " .. table.concat(has, ", "))
    add("executor is missing: " .. (#missing > 0 and table.concat(missing, ", ") or "nothing on the list"))
end)
if #problems > 0 then
    add("")
    add("---- parts that failed (the rest is complete) ----")
    for _, s in ipairs(problems) do add("  " .. s:sub(1, 300)) end
end
add("")
add(("left out: %d Roblox scripts, %d copies (the live ones in your PlayerGui / PlayerScripts are kept), %d library scripts, %d in other players' characters"):format(
    skipped.roblox, skipped.copy, skipped.package, skipped.other_player))
local pk = {}
for k, v in pairs(packages) do table.insert(pk, ("%s (%d)"):format(k, v)) end
table.sort(pk)
if #pk > 0 then add("libraries left out: " .. table.concat(pk, ", ")) end
add("")
add("---- scripts ----")
for _, item in ipairs(list) do
    if item.file then add(("  %-14s %7d  %s"):format(item.inst.ClassName, item.size, item.path)) end
end
if #failed > 0 then
    add("")
    add("---- couldn't decompile ----")
    for _, item in ipairs(failed) do add(("  %s %s: %s"):format(item.inst.ClassName, item.path, item.err)) end
end
add("")
add("---- module data ----")
for _, item in ipairs(data_files) do add("  " .. item.path) end
local index = table.concat(idx, "\n")
save("README.txt", index)
if typeof(setclipboard) == "function" then pcall(setclipboard, index) end

env.game_dump_running = nil
status(("%s: %d scripts, %d modules. Tell Claude."):format(S.alive and "done" or "stopped early", written, #data_files))
S.finished = true
stop.Text = "Close"
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Game dump done", Text = "Saved in " .. ROOT .. ". Tell Claude it's done.", Duration = 8 })
end)
task.delay(20, function() pcall(function() gui:Destroy() end) end)
