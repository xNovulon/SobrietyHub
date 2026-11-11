if not game:IsLoaded() then
    local msg_instance = Instance.new("Message")
    local hint_instance = Instance.new("Hint")
    msg_instance.Text = "Flames Hub is waiting for the current experience to load fully."
    hint_instance.Text = "Flames Hub is currently waiting for the game to load."
    msg_instance.Parent = workspace
    hint_instance.Parent = workspace
    game.Loaded:Wait()
    task.wait(0.1)
    msg_instance:Destroy()
    hint_instance:Destroy()
end
local In_Studio = false
local g
if game:GetService("RunService"):IsStudio() then
    g = _G
    In_Studio = true
else
    g = getgenv()
end
task.wait()
if game:GetService("RunService"):IsServer() then warn("This script can only be run on the client."); return end
if game.PlaceId ~= 13967668166 and game.PlaceId ~= 99644611200703 and game.PlaceId ~= 99154507657228 then
    if g.notify and typeof(g.notify) == "function" then
        return g.notify("Error", "This game isn't allowed to run with this script (only: Life Together RP (main), Ski Resort, and Bora Bora).", 30)
    else
        return warn("This game isn't allowed to run with this script (only: Life Together RP (main), Ski Resort, and Bora Bora).")
    end
end
task.wait()
local blank_F = g.blank_function or g.blankfunction or function(...) return ... end
local cloneref = typeof(cloneref) == "function" and cloneref or function(instance) return instance end
local http_game
if In_Studio then
    http_game = blank_F
else
    http_game = (g["game"] or game)["HttpGet"]
    g.http_get = function(url) return http_game(game, url) end
end
task.wait()
local StarterGui = g.StarterGui or cloneref and cloneref(game:GetService("StarterGui")) or game:GetService("StarterGui")
local Raw_Version = "V9.4.5"
g.Script_Version = tostring(Raw_Version).."-LifeHub"
g.safe_require = function(module)
    if typeof(module) ~= "Instance" or not module:IsA("ModuleScript") then return nil end
    local ok, result = pcall(require, module)
    if ok then return result end
    warn("[Flames] couldn't load " .. module:GetFullName() .. ": " .. tostring(result))
    return nil
end
local Players = g.Players or cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local localPlayer = g.LocalPlayer or Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local speaker = localPlayer
if In_Studio and script.Parent ~= StarterGui then script.Parent = StarterGui end
g.Keybind_Input_Disabled_For_Mini_Game = g.Keybind_Input_Disabled_For_Mini_Game or false
g.SideGlitch_Enabled = g.SideGlitch_Enabled or true
g.SideGlitch_Speed = g.SideGlitch_Speed or 5
g.SideGlitch_Distance = g.SideGlitch_Distance or 5
g.SideGlitch_Smooth = g.SideGlitch_Smooth or 0.18
g.colors = g.colors or {
    Color3.fromRGB(255,255,255),
    Color3.fromRGB(128,128,128),
    Color3.fromRGB(0,0,0),
    Color3.fromRGB(0,0,255),
    Color3.fromRGB(0,255,0),
    Color3.fromRGB(0,255,255),
    Color3.fromRGB(255,165,0),
    Color3.fromRGB(139,69,19),
    Color3.fromRGB(255,255,0),
    Color3.fromRGB(50,205,50),
    Color3.fromRGB(255,0,0),
    Color3.fromRGB(255,155,172),
    Color3.fromRGB(128,0,128),
}
g.LocalPlayer = g.LocalPlayer or localPlayer
if not In_Studio then
    if not g.GlobalEnvironmentFramework_Initialized then
        loadstring(g.http_get("https://pastebin.com/raw/T25mDhBZ"))()
        wait(0.1)
        g.GlobalEnvironmentFramework_Initialized = true
    end
end
task.wait()
if not g.LifeTogether_Actual_Flames_Hub_Running_Functioning_Currently_On_Client then if g.notify and typeof(g.notify) == "function" then g.notify("Success", "Got LocalPlayer: "..tostring(g.LocalPlayer), 5) end end
local has_gethui = (typeof(gethui) == "function") or (typeof(g.gethui) == "function")
local has_gethidden = (typeof(get_hidden_gui) == "function") or (typeof(g.get_hidden_gui) == "function")
local RunService = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local CoreGui = g.CoreGui or cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local Workspace = g.Workspace or cloneref and cloneref(game:GetService("Workspace")) or game:GetService("Workspace")
local RobloxReplicatedStorage = g.RobloxReplicatedStorage or cloneref and cloneref(game:GetService("RobloxReplicatedStorage")) or game:GetService("RobloxReplicatedStorage")
local ReplicatedStorage = g.ReplicatedStorage or cloneref and cloneref(game:GetService("ReplicatedStorage")) or game:GetService("ReplicatedStorage")
local HttpService = g.HttpService or cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")
local LocalPlayer = g.LocalPlayer or Players.LocalPlayer
local UserInputService = g.UserInputService or cloneref and cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")
local TweenService = g.TweenService or cloneref and cloneref(game:GetService("TweenService")) or game:GetService("TweenService")
local Debris = g.Debris or cloneref and cloneref(game:GetService("Debris")) or game:GetService("Debris")
local Chat = g.Chat or cloneref and cloneref(game:GetService("Chat")) or game:GetService("Chat")
local me = LocalPlayer or speaker or g.LocalPlayer or Players.LocalPlayer
local plr = me
local TextChatService = g.TextChatService or cloneref and cloneref(game:GetService("TextChatService")) or game:GetService("TextChatService")
local Lighting = g.Lighting or cloneref and cloneref(game:GetService("Lighting")) or game:GetService("Lighting")
local lighting = Lighting
local work = Workspace
local player_gui = g.PlayerGui or LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
local uis = UserInputService
local UIS = uis
local ts  = TweenService
local rs  = RunService
local IsMobile = UserInputService.TouchEnabled
local http = HttpService
if not has_gethui and not has_gethidden and not g.roblox_hidden_gui_location then
    if In_Studio then
        g.roblox_hidden_gui_location = player_gui
    else
        for _, v in ipairs(CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") and v.Name == "RobloxGui" then
                g.roblox_hidden_gui_location = v
                break
            end
        end
    end
    local function resolve_gui()
        if In_Studio then return player_gui end
        if g.roblox_hidden_gui_location and g.roblox_hidden_gui_location.Parent and g.roblox_hidden_gui_location:IsA("ScreenGui") then return g.roblox_hidden_gui_location end
        return CoreGui
    end
    g.get_hui = resolve_gui
    g.get_hidden_gui = resolve_gui
end
local verify_file = "is_verified_in_Flames_Hub.txt"
local Insert = table.insert
g.Is_Integer_In_Str = g.Is_Integer_In_Str or function(str)
    if type(str) == "number" then return str % 1 == 0 end
    if type(str) == "string" then return str:match("^-?%d+$") ~= nil end
    return false
end
g._attr_cache = g._attr_cache or {}
g.attr_cached_fuzzy = g.attr_cached_fuzzy or function(obj, search)
    if not obj or not obj.Parent then return nil end
    local cache = g._attr_cache[obj]
    if cache then
        for name, value in pairs(cache) do
            if name:lower():find(search:lower(), 1, true) then
                return value
            end
        end
        return nil
    end
    local ok, attrs = pcall(function() return obj:GetAttributes() end)
    if not ok or not attrs then return nil end
    g._attr_cache[obj] = attrs
    for name, value in pairs(attrs) do
        if name:lower():find(search:lower(), 1, true) then
            return value
        end
    end
    return nil
end
g.attr_main_checker = g.attr_main_checker or function(obj, attr, expected)
    local ok, result = pcall(function() return obj:GetAttribute(attr) end)
    return ok and result == expected
end
g.isProperty = g.isProperty or function(inst, prop)
    local s, r = pcall(function() return inst[prop] end)
    if not s then return nil end
    return r
end
g.hasProp = g.hasProp or function(inst, prop)
    return inst and g.isProperty(inst, prop) ~= nil
end
g.setProperty = g.setProperty or function(inst, prop, v)
    local s, _ = pcall(function() inst[prop] = v end)
    return s
end
g.safeSet = g.safeSet or function(inst, prop, val)
    if inst and g.hasProp(inst, prop) then g.setProperty(inst, prop, val) end
end
local locale_ids = {
    "en-us", "en-gb", "en-au", "en-ca", "en-za", "en-nz", "en-ie",
    "pt-br", "pt-pt",
    "es-es", "es-mx", "es-ar", "es-co", "es-cl", "es-pe", "es-ve",
    "fr-fr", "fr-ca", "fr-be", "fr-ch",
    "de-de", "de-at", "de-ch",
    "it-it", "it-ch",
    "nl-nl", "nl-be",
    "pl-pl",
    "ru-ru",
    "tr-tr",
    "sv-se",
    "no-no",
    "da-dk",
    "fi-fi",
    "cs-cz",
    "sk-sk",
    "hu-hu",
    "ro-ro",
    "bg-bg",
    "hr-hr",
    "uk-ua",
    "el-gr",
    "ja-jp",
    "ko-kr",
    "zh-cn",
    "zh-tw",
    "id-id",
    "ms-my",
    "th-th",
    "vi-vn",
    "ar-sa",
}
local matrix_ids = {
    "1865-6-19-matrix",
    "1923-4-7-matrix",
    "1947-8-15-matrix",
    "1955-12-1-matrix",
    "1961-4-12-matrix",
    "1963-11-22-matrix",
    "1969-7-20-matrix",
    "1971-3-8-matrix",
    "1975-4-30-matrix",
    "1977-5-25-matrix",
    "1981-1-20-matrix",
    "1983-9-1-matrix",
    "1986-4-26-matrix",
    "1989-11-9-matrix",
    "1991-8-6-matrix",
    "1994-4-27-matrix",
    "1997-7-1-matrix",
    "1999-3-31-matrix",
    "2001-9-11-matrix",
    "2003-3-20-matrix",
    "2004-8-4-matrix",
    "2005-7-7-matrix",
    "2007-6-29-matrix",
    "2008-9-15-matrix",
    "2009-1-15-matrix",
    "2010-4-20-matrix",
    "2011-3-11-matrix",
    "2012-7-20-matrix",
    "2013-4-15-matrix",
    "2014-6-5-matrix",
    "2015-11-13-matrix",
    "2016-6-12-matrix",
    "2017-8-21-matrix",
    "2018-3-14-matrix",
    "2019-4-15-matrix",
    "2020-1-26-matrix",
    "2020-3-11-matrix",
    "2021-1-6-matrix",
    "2021-8-30-matrix",
    "2022-2-24-matrix",
    "2022-9-8-matrix",
    "2023-1-30-matrix",
    "2023-4-4-matrix",
    "2023-7-8-matrix",
    "2023-9-22-matrix",
    "2024-2-29-matrix",
    "2024-5-17-matrix",
    "2024-8-3-matrix",
    "2024-11-5-matrix",
    "2025-1-1-matrix",
}
local spoofed_platforms = {
    "Adopt Me!",
    "Brookhaven RP",
    "Blox Fruits",
    "Pet Simulator X",
    "Murder Mystery 2",
    "Royale High",
    "Tower of Hell",
    "Arsenal",
    "Jailbreak",
    "Piggy",
    "Natural Disaster Survival",
    "Work at a Pizza Place",
    "Flee the Facility",
    "Phantom Forces",
    "Shindo Life",
    "Anime Fighting Simulator",
    "Bedwars",
    "Doors",
    "Brookhaven",
    "Anime Dimensions",
    "Skywars",
    "Funky Friday",
    "Dragon Ball Z Final Stand",
    "Ro-Ghoul",
    "Islands",
    "Anime Battle Arena",
    "Build a Boat for Treasure",
    "The Mimic",
    "Livetopia",
    "Starving Artists",
    "A Universal Time",
    "Creatures of Sonaria",
    "My Hello Kitty Cafe",
    "Wacky Wizards",
    "Dress to Impress",
    "Frontlines",
    "Sword Burst 2",
    "Super Golf",
    "Mad City",
    "Theme Park Tycoon 2",
    "Car Dealership Tycoon",
    "MeepCity",
    "Ragdoll Engine",
    "Obby But Youre On A Bike",
    "Saber Simulator",
    "Dungeon Quest",
    "Epic Minigames",
    "Weight Lifting Simulator",
    "Scuba Diving at Quill Lake",
    "Survive the Killer",
}
local function isVerified()
    if not isfile then return false end
    if not isfile(verify_file) then return false end
    local content = readfile(verify_file)
    return type(content) == "string" and content:lower():find("true") ~= nil
end
local function setVerified()
    if In_Studio then return true end
    if typeof(writefile) ~= "function" or type(verify_file) ~= "string" then return false end
    local ok = pcall(writefile, verify_file, "true")
    return ok
end
local function waitForGuiGone()
    local container = CoreGui
    if In_Studio then
        container = player_gui or speaker:FindFirstChildOfClass("PlayerGui")
        if not container or not container:IsA("PlayerGui") then return end
    end
    wait(0.1)
    while true do
        local ok, found = pcall(function() return container:FindFirstChild("MemoryMinigameGUI") end)
        if not ok or not found then break end
        task.wait()
    end
end
g.disabled_global_value_correctly = g.disabled_global_value_correctly or function(input)
    local ok, result = pcall(function() return input end)
    if not ok then return true end
    return not result
end
g.LifeTogether_Actual_Flames_Hub_Running_Functioning_Currently_On_Client = true
local userid = localPlayer.UserId
local lib = g.FlamesLibrary
g.lib = g.FlamesLibrary
local lib_attempts = 0
local lib_max_attempts = 15
while (not lib or type(lib) ~= "table") and lib_attempts < lib_max_attempts do
    task.wait(0.5)
    lib_attempts = lib_attempts + 1
    lib = g.FlamesLibrary
end
if not lib or type(lib) ~= "table" then
    if g.notify and typeof(g.notify) == "function" then g.notify("Error", "FlamesLibrary failed to load, the system cannot continue without it.", 15) else warn("FlamesLibrary failed to load, the system cannot continue without it.") end
    return
end
local function mask_unique_id(id)
    if not id then return nil end
    local parts = string.split(id, "-")
    local out = {}
    for i = 1, #parts do
        if i <= 2 then
            out[i] = parts[i]
        else
            out[i] = string.rep("*", #parts[i])
        end
    end
    return table.concat(out, "-")
end
function create_flames_hub_unique_id(target_user_id)
    local file_name = "flames_hub_unique_ID.txt"
    if userid ~= target_user_id then return nil end
    if In_Studio then
        g.flames_hub_unique_id = g.flames_hub_unique_id or HttpService:GenerateGUID(false)
        return g.flames_hub_unique_id
    end
    if isfile and readfile and typeof(isfile) == "function" and typeof(readfile) == "function" and isfile(file_name) then
        local ok, id = pcall(readfile, file_name)
        if ok and id and id ~= "" then return id end
    end
    local new_id = HttpService:GenerateGUID(false)
    if writefile and typeof(writefile) == "function" then pcall(writefile, file_name, new_id) end
    return new_id
end
function get_flames_hub_unique_id()
    local file_name = "flames_hub_unique_ID.txt"
    if isfile and isfile(file_name) then
        local id = readfile and readfile(file_name)
        if id and id ~= "" then return id end
    end
    return nil
end
function get_masked_flames_hub_unique_id()
    local raw = get_flames_hub_unique_id()
    return mask_unique_id(raw)
end
local FlamesLibrary = g.lib or g.FlamesLibrary
g.will_tag = function(text)
    local max_attempts = 5
    for attempt = 1, max_attempts do
        local ok, filtered = pcall(function() return Chat:FilterStringForBroadcast(text, g.LocalPlayer) end)
        if not ok then return true end
        if type(filtered) == "string" and not filtered:match("^#+$") then return filtered ~= text end
        task.wait(0.5)
    end
    return true
end
g.chat_shield_enabled = g.chat_shield_enabled or false
g.chat_shield_active = g.chat_shield_active or false
g.toggle_chat_shield = function(force)
    if force ~= nil then
        g.chat_shield_enabled = force
    else
        g.chat_shield_enabled = not g.chat_shield_enabled
    end
    if not g.chat_shield_enabled then
        g.chat_shield_active = false
        FlamesLibrary.disconnect("chat_shield_loop")
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)
        g.notify("Success", "Flames Hub | HashTag Protection disabled.", 3)
        return
    end
    FlamesLibrary.spawn("chat_shield_loop", "defer", function()
        while g.chat_shield_enabled do
            local ok, filtered = pcall(function() return Chat:FilterStringForBroadcast("hello", speaker) end)
            local is_hashing = not ok or type(filtered) ~= "string" or filtered:match("^#+$")
            if is_hashing and not g.chat_shield_active then
                g.chat_shield_active = true
                pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false) end)
                g.notify("Warning", "HASHTAG PROTECTION HAS BEEN ENABLED! HASHTAGS (#) DETECTED IN YOUR FILTER (AUTOMATIC), THIS MEANS YOU'RE GETTING AUTOMATICALLY FILTERED (#) FOR NO REASON BY ROBLOX, WE'VE SAVED YOU.", 20)
            elseif not is_hashing and g.chat_shield_active then
                g.chat_shield_active = false
                pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true) end)
                g.notify("Success", "Flames Hub | Shield going idle. No hashtags have been detected in your filter.", 7)
            end
            task.wait(0.5)
        end
    end)
end
create_flames_hub_unique_id(Players.LocalPlayer.UserId)
task.wait()
local masked_flames_hub_server_ID = get_masked_flames_hub_unique_id()
local Lib = g.FlamesLibrary
g.masked_flames_hub_server_ID = masked_flames_hub_server_ID
task.wait()
if not isVerified() then
    if g.notify then g.notify("Warning", "Please complete this one time verification to boot into Flames Hub | Script Hub!", 30) end
    g.Memory_Mini_Game_GUI()
    waitForGuiGone()
    setVerified()
    if g.notify then
        g.notify("Success", "You have been verified in Flames Hub successfully.", 15)
        g.notify("Success", "Your special Flames Hub GUID: "..tostring(masked_flames_hub_server_ID), 11)
    end
else
    if g.notify then g.notify("Success", "We have verified you in our system | has already completed verification.", 20) end
    if g.notify then g.notify("Success", "Your special Flames Hub GUID: "..tostring(masked_flames_hub_server_ID), 10) end
end
task.wait()
g.safe_wrapper = g.safe_wrapper or function(service)
    if cloneref then
        return cloneref(game:GetService(service))
    else
        return game:GetService(service)
    end
end
g.originalIO = g.originalIO or {}
g.spectateConns = g.spectateConns or {}
local fw = lib.wait
g.originalIO.ensureCam = function(spectate_target)
    if not spectate_target then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if g.isProperty(cam, "CameraSubject") == nil then return end
    if cam.CameraSubject ~= spectate_target then g.setProperty(cam, "CameraSubject", spectate_target) end
end
g.originalIO.hookCameraGuard = function(spectate_target)
    if not workspace then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if g.spectateConns.cam then
        g.spectateConns.cam:Disconnect()
        g.spectateConns.cam = nil
    end
    wait(0.25)
    if g.isProperty(cam, "CameraSubject") ~= nil then
        g.spectateConns.cam = g.FlamesLibrary.connect("spectate_cam", cam:GetPropertyChangedSignal("CameraSubject"):Connect(function()
            if not spectate_target then return end
            g.originalIO.ensureCam()
        end))
    end
    if not g.spectateConns.camW and g.isProperty(workspace, "CurrentCamera") ~= nil then
        g.spectateConns.camW = g.FlamesLibrary.connect("spectate_camW", workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            if not spectate_target then return end
            g.originalIO.hookCameraGuard()
            g.originalIO.ensureCam()
        end))
    end
end
g.originalIO.captureIO = function(name)
    local fn
    if rawget and typeof(rawget) == "function" then fn = rawget(_G, name) end
    if type(fn) ~= "function" then fn = _G[name] end
    if type(fn) == "function" then g.originalIO[name] = fn end
end
task.wait()
if not g.originalIO.__captured then
    g.originalIO.__captured = true
    g.originalIO.captureIO('readfile')
    g.originalIO.captureIO('writefile')
    g.originalIO.captureIO('appendfile')
    g.originalIO.captureIO('listfiles')
    g.originalIO.captureIO('makefolder')
    g.originalIO.captureIO('delfile')
    g.originalIO.captureIO('delfolder')
    g.originalIO.captureIO('isfile')
    g.originalIO.captureIO('isfolder')
end
g.originalIO.pathVariants = function(path)
    if type(path) ~= "string" then return { path } end
    if path:match('^[%w_]+://') then return { path } end
    local variants, seen = {}, {}
    local function add(value)
        if type(value) == "string" and value ~= "" and not seen[value] then
            seen[value] = true
            Insert(variants, value)
        end
    end
    add(path)
    add((path:gsub('\\+', '\\')))
    add((path:gsub('//+', '/')))
    add((path:gsub('/', '\\')))
    add((path:gsub('\\', '/')))
    local trimmed = path:gsub('^%.[/\\]+', '')
    if trimmed ~= path then
        add(trimmed)
        add(trimmed:gsub('/', '\\'))
        add(trimmed:gsub('\\', '/'))
    end
    return variants
end
g.originalIO.resolveWithListfiles = function(target)
    local lf = g.originalIO.listfiles
    if type(lf) ~= "function" then
        return nil
    end
    local dir, filename = target:match('^(.*)[/\\]([^/\\]+)$')
    if not dir or filename == '' then
        return nil
    end
    local dirVariants = g.originalIO.pathVariants(dir)
    local results = {}
    local lowered = filename:lower()
    for _, candidateDir in ipairs(dirVariants) do
        local ok, entries = pcall(lf, candidateDir)
        if ok and type(entries) == "table" then
            for _, entry in ipairs(entries) do
                local name = entry:match('([^/\\]+)$')
                if name and name:lower() == lowered then
                    Insert(results, entry)
                end
            end
        end
    end
    if #results > 0 then
        return results
    end
    return nil
end
g.input_to_String = g.input_to_String or function(input_value) return typeof(input_value) == "string" and input_value or tostring(input_value) end
if g.notify and typeof(g.notify) == "function" then g.notify("Info", "Booting up Life Together RP Hub, please wait a few moments while we initialize everything...", 8) end
g.service_cache = g.service_cache or {}
g.Sound_ID_Windows = g.Sound_ID_Windows or "rbxassetid://8183296024"
g.Sound_ID_iPhone = g.Sound_ID_iPhone or "rbxassetid://73722479618078"
g.Sound_ID_Android = g.Sound_ID_Android or "rbxassetid://17582299860"
g.Sound_ID_Universal = g.Sound_ID_Universal or "rbxassetid://18595195017"
local aliases = {
    rs = "ReplicatedStorage",
    rf = "ReplicatedFirst",
    ws = "Workspace",
    works = "Workspace",
    player = "Players",
    plr = "Players",
    plrs = "Players",
    ts = "TweenService",
    uis = "UserInputService"
}
local virtuals = {
    lp = true,
    localplayer = true,
    localplr = true
}
local function resolve_service(input)
    if not input then return nil end
    local lowered = tostring(input):lower()
    if aliases[lowered] then return aliases[lowered] end
    local children = game:GetChildren()
    for _, svc in ipairs(children) do
        if svc.Name:lower() == lowered then
            return svc.Name
        end
    end
    for _, svc in ipairs(children) do
        if svc.Name:lower():find(lowered, 1, true) then
            return svc.Name
        end
    end
    local best_name
    local best_score = math.huge
    for _, svc in ipairs(children) do
        local score = g.levenshtein(lowered, svc.Name:lower())
        if score < best_score then
            best_score = score
            best_name = svc.Name
        end
    end
    if best_score <= 4 then
        return best_name
    end
    return nil
end
local function fetch_value(name)
    if not name then return nil end
    local lowered = tostring(name):lower()
    if virtuals[lowered] then
        local ok, speaker = pcall(function()
            local Players = g.service_cache["Players"] or (Players)
            return Players.LocalPlayer
        end)
        if not ok or not speaker then return nil end
        return lowered, speaker
    end
    local resolved = resolve_service(name)
    if not resolved then return nil end
    local ok, svc = pcall(function()
        local service = game:GetService(resolved)
        if cloneref and typeof(cloneref) == "function" then return cloneref(service) end
        return service
    end)
    if not ok or not svc then return nil end
    return resolved, svc
end
if setmetatable and getmetatable and rawget and rawset and typeof(setmetatable) == "function" and typeof(getmetatable) == "function" and typeof(rawget) == "function" and typeof(rawset) == "function" then
    if not getmetatable(g.service_cache) then
        setmetatable(g.service_cache, {
            __index = function(self, key)
                local existing = rawget(self, key)
                if existing then return existing end
                local resolved_key, value = fetch_value(key)
                if not value then return nil end
                rawset(self, key, value)
                if resolved_key and resolved_key ~= key then rawset(self, resolved_key, value) end
                return value
            end
        })
    end
    g.safe_wrapper = function(name)
        if not name then return nil end
        return g.service_cache[name]
    end
else
    g.safe_wrapper = function(name)
        if not name then return nil end
        if g.service_cache[name] then return g.service_cache[name] end
        local resolved_key, value = fetch_value(name)
        if not value then return nil end
        g.service_cache[name] = value
        if resolved_key and resolved_key ~= name then g.service_cache[resolved_key] = value end
        return value
    end
end
task.wait()
g.type = typeof or type
g.string_contains_plain = g.string_contains_plain or function(source, needle)
    if typeof(source) ~= "string" or typeof(needle) ~= "string" then return false end
    return source:lower():find(needle:lower(), 1, true) ~= nil
end
g.load_youtube_music_player_func = g.load_youtube_music_player_func or function()
    if g.You_Tube_Music_Player_Loaded then return g.notify("Warning", "YouTube Music Player is already loaded.", 5) end
    g.You_Tube_Music_Player_Loaded = true
    loadstring(g.http_get("https://raw.githubusercontent.com/Dan41/Roblox-Scripts/refs/heads/main/Youtube%20Music%20Player/YoutubeMusicPlayer.lua"))()
    local asset_id = "76673896881913"
    local target_image = "rbxassetid://" .. asset_id
    task.spawn(function()
        local screen_gui
        repeat
            task.wait(0.1)
            for _, v in ipairs(CoreGui:GetChildren()) do
                if v:IsA("ScreenGui") then
                    for _, child in ipairs(v:GetDescendants()) do
                        if child:IsA("ImageButton") and child.Image == target_image then
                            screen_gui = v
                            break
                        end
                    end
                end
                if screen_gui then break end
            end
        until screen_gui
        local target_button
        for _, child in ipairs(screen_gui:GetDescendants()) do
            if child:IsA("ImageButton") and child.Image == target_image then
                target_button = child
                break
            end
        end
        if not target_button then return end
        local target_frame
        for _, child in ipairs(screen_gui:GetDescendants()) do
            if child:IsA("Frame") then
                local size = child.AbsoluteSize
                if math.abs(size.X - 587) < 1 and math.abs(size.Y - 300) < 1 then
                    target_frame = child
                    break
                end
            end
        end
        if target_frame then
            target_frame.Draggable = true
        end
        return
    end)
    return
end
if g.notify then g.notify("Info", "One moment, we're initializing basic services...", 5) end
local executor_string = nil
local function executor_contains(substr)
    if type(executor_string) ~= "string" then
        return false
    end
    return string.find(string.lower(executor_string), string.lower(substr), 1, true) ~= nil
end
local function retrieve_executor()
    local name
    if identifyexecutor then
        name = identifyexecutor()
    end
    return { Name = name or "Unknown Executor" }
end
local function identify_executor()
    local executorinfo = retrieve_executor()
    return tostring(executorinfo.Name)
end
executor_string = identify_executor()
function low_level_executor()
    return false
end
g.low_level_executor = low_level_executor
task.wait()
g.randomString = g.randomString or function()
    local length = math.random(10,20)
    local array = {}
    for i = 1, length do array[i] = string.char(math.random(32, 126)) end
    return table.concat(array)
end
g.blankfunction = g.blankfunction or function(...) return ... end
if g.LifeTogether_RP_ScriptHub_Loaded then
    if g.notify then
        return g.notify("Warning", "Life Together RP Hub has already been loaded.", 8)
    else
        return
    end
end
if g.LifeTogetherRP_Admin and g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub == false then
    if g.notify then
        return g.notify("Warning", "Life Together RP admin has already been loaded.", 6)
    else
        return
    end
elseif g.LifeTogetherRP_Admin and g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub then
    return
end
if g.notify and typeof(g.notify) == "function" then g.notify("Info", "Now checking for Flames Hub files...", 5) end
g.ConstantUpdate_Checker_Live = true
if isfile and not isfile("flames_hub_agreement_COPY.txt") then
    pcall(function()
        writefile("flames_hub_agreement_COPY.txt", "has not decided")
    end)
end
if isfile and typeof(isfile) == "function" and not isfile("LifeTogether_RP_Admin_Custom_Name.txt") then
    pcall(function()
        writefile("LifeTogether_RP_Admin_Custom_Name.txt", speaker.DisplayName)
    end)
end
task.wait()
if isfile and typeof(isfile) == "function" and not isfile("LifeTogether_RP_Admin_Custom_Bio.txt") then
    pcall(function()
        writefile("LifeTogether_RP_Admin_Custom_Bio.txt", "🔥 Flames Hub 🔥")
    end)
end
if not g.dragify then
    do
        local active_frame     = nil
        local active_drag_start = nil
        local active_start_pos  = nil
        local last_input_pos    = nil
        local active_tween      = nil
        local GLOBAL_KEY = "dragify_global"
        local TWEEN_INFO = TweenInfo.new(0.05, Enum.EasingStyle.Linear)
        local MIN_DELTA  = 2
        local function cancel_tween()
            if active_tween then
                pcall(function() active_tween:Cancel() end)
                active_tween = nil
            end
        end
        local function stop_drag()
            active_frame      = nil
            active_drag_start = nil
            active_start_pos  = nil
            last_input_pos    = nil
            cancel_tween()
        end
        local function frame_valid(f)
            local ok, res = pcall(function()
                return f and f.Parent and f:IsDescendantOf(game)
            end)
            return ok and res
        end
        g.FlamesLibrary.connect(GLOBAL_KEY .. "_heartbeat", rs.Heartbeat:Connect(function()
            if not active_frame or not last_input_pos then return end
            if not frame_valid(active_frame) then
                stop_drag()
                return
            end
            local delta = last_input_pos - active_drag_start
            if delta.Magnitude < MIN_DELTA then return end
            local sp  = active_start_pos
            local pos = UDim2.new(
                sp.X.Scale,
                sp.X.Offset + delta.X,
                sp.Y.Scale,
                sp.Y.Offset + delta.Y
            )
            cancel_tween()
            active_tween = ts:Create(active_frame, TWEEN_INFO, { Position = pos })
            active_tween:Play()
        end))
        g.FlamesLibrary.connect(GLOBAL_KEY .. "_changed", uis.InputChanged:Connect(function(input)
            if not active_frame then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
                last_input_pos = input.Position
            end
        end))
        g.FlamesLibrary.connect(GLOBAL_KEY .. "_ended", uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                stop_drag()
            end
        end))
        g.dragify = function(frame)
            if not frame then return end
            task.spawn(function()
                local waited = 0
                while not frame_valid(frame) do
                    task.wait(0.1)
                    waited = waited + 0.1
                    if waited >= 10 then return end
                end
                local frame_key = "dragify_" .. tostring(frame:GetDebugId())
                g.FlamesLibrary.connect(frame_key .. "_began", frame.InputBegan:Connect(function(input)
                    if not frame_valid(frame) then return end
                    if uis:GetFocusedTextBox() then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if active_frame and active_frame ~= frame then
                            stop_drag()
                        end
                        active_frame      = frame
                        active_drag_start = input.Position
                        active_start_pos  = frame.Position
                        last_input_pos    = input.Position
                    end
                end))
                g.FlamesLibrary.connect(frame_key .. "_ancestry", frame.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        if active_frame == frame then stop_drag() end
                        g.FlamesLibrary.disconnect(frame_key .. "_began")
                        g.FlamesLibrary.disconnect(frame_key .. "_ancestry")
                    end
                end))
            end)
        end
    end
end
local http_requesting = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
g.http_requesting = g.http_requesting or http_requesting
local function normalize_response(res)
   local status = res.StatusCode or res.statusCode or res.status or res.Status
   local body = res.Body or res.body or res.Response or res.response or ""
   return status, body
end
g.try_load = g.try_load or function(urls)
    for i = 1, #urls do
        local url = urls[i]
        local ok, res = pcall(function() return http_requesting({ Url = url, Method = "GET" }) end)
        if ok and res then
            local status, body = normalize_response(res)
            if status == 200 and body ~= "" and not tostring(body):find("404: Not Found") then
                local f, err = loadstring(body)
                if f then
                    local s_ok, s_res = pcall(f)
                    if s_ok then
                        return s_res
                    else
                        return { failed = true, status = "load-error", url = url, body = tostring(s_res) }
                    end
                else
                    return { failed = true, status = "compile-error", url = url, body = tostring(err) }
                end
            end
        end
    end
    return { failed = true, status = "no-response", url = urls[#urls] }
end
local GITHUB   = "https://raw.githubusercontent.com/EnterpriseExperience/Flames_Hub_Games/main/"
local GITLAB   = "https://gitlab.com/flames2431233/Starter/-/raw/main/"
local CODEBERG = "https://codeberg.org/talkinboutlol/FlamesHub/raw/branch/main/"
local function mirror(path, paste_a, paste_b)
    return {
        GITHUB   .. path,
        GITLAB   .. path .. "?ref_type=heads",
        CODEBERG .. path,
        paste_a,
        paste_b,
    }
end
local github_urls = {
    GlobalEnv_Framework = {
        "https://gitlab.com/flames2431233/Starter/-/raw/main/Assets/Global_Environment.lua?ref_type=heads"
    },
    Functions_API_LifeTogether = {
        "https://gitlab.com/flames2431233/Starter/-/raw/main/Life_Together_Framework/Life_Together_Functions_API.lua?ref_type=heads"
    },
    Life_Together_Network = {
        "https://gitlab.com/flames2431233/Starter/-/raw/main/Life_Together_Framework/Life_Together_Network.lua?ref_type=heads"
    },
}
local fallback_urls = {
    GlobalEnv_Framework = mirror(
        "Assets/Global_Environment.lua",
        "https://pastebin.com/raw/T25mDhBZ",
        "https://pastefy.app/MAylpl1S/raw"
    ),
    Functions_API_LifeTogether = mirror(
        "Life_Together_Framework/Life_Together_Functions_API.lua",
        "https://pastebin.com/raw/ksfZM2C4",
        "https://pastefy.app/kQzNQxn0/raw"
    ),
    Life_Together_Network = mirror(
        "Life_Together_Framework/Life_Together_Network.lua",
        "https://pastebin.com/raw/GiEmv8Qf",
        "https://pastefy.app/FT5eU1HK/raw"
    ),
    LifeTogether_Anti_Staff = mirror(
        "Life_Together_Framework/LifeTogether_Anti_Staff.lua",
        "https://pastebin.com/raw/UiQfWWwY",
        "https://pastefy.app/Se7QQ0KH/raw"
    ),
    Vehicle_Mapper = mirror(
        "Extra/Vehicle_Mapper.lua",
        "https://pastebin.com/raw/PqLNjqSs",
        "https://pastefy.app/BuZybou2/raw"
    ),
    LifeTogether_Framework_Base_1 = mirror(
        "Life_Together_Framework/LifeTogether_Framework_Base_1.lua",
        "https://pastebin.com/raw/Pq9cUCXi",
        "https://pastefy.app/UgnGF0pZ/raw"
    ),
    LifeTogether_Framework_Base_2 = mirror(
        "Life_Together_Framework/LifeTogether_Framework_Base_2.lua",
        "https://pastebin.com/raw/KR05npwT",
        "https://pastefy.app/sjjbUhBl/raw"
    ),
    Life_Together_Admin = mirror(
        "Life_Together_Framework/Life_Together_Admin.lua",
        "https://pastebin.com/raw/azPSzEjH",
        "https://pastefy.app/SiDMhe47/raw"
    ),
    grab_file_performance = mirror(
        "Assets/grab_file_performance.lua",
        "https://pastebin.com/raw/DuG2RmjF",
        "https://pastefy.app/nq0BT17K/raw"
    ),
    Configuration_API = mirror(
        "Assets/Configuration_API.lua",
        "https://pastebin.com/raw/9qkZEvjw",
        "https://pastefy.app/JPSCgeB4/raw"
    )
}
g.get_script_text = g.get_script_text or function(name)
    local gh = github_urls[name] or {}
    local fb = fallback_urls[name] or {}
    for i = 1, #gh do
        local res = http_requesting({ Url = gh[i], Method = "GET" })
        if res and res.StatusCode == 200 and res.Body ~= "" then
            return res.Body
        end
    end
    for i = 1, #fb do
        local res = http_requesting({ Url = fb[i], Method = "GET" })
        if res and res.StatusCode == 200 and res.Body ~= "" then
            return res.Body
        end
    end
    return ""
end
g.load_script = g.load_script or function(name)
    local github_list = github_urls[name] or {}
    local fallback_list = fallback_urls[name] or {}
    local result = g.try_load(github_list)
    if type(result) == "table" and result.failed then result = g.try_load(fallback_list) end
    return result
end
g.pick_script = g.pick_script or function(name)
    local gh = github_urls[name] or {}
    local fb = fallback_urls[name] or {}
    local r = g.try_load(gh)
    if type(r) == "table" and r.failed then r = g.try_load(fb) end
    if type(r) == "table" and r.failed then
        g[name] = nil
        return nil
    end
    g[name] = r
    return r
end
local allowed = {
    ["CIippedByAura"] = true,
    ["imjustbeter100"] = true,
    ["L0CKED_1N1"] = true,
    ["imbetter100062"] = true,
    ["jdot7580"] = true,
    ["ddosama136703"] = true,
    ["AuraWithClipFarmin"] = true,
    ["ActuallyMasterInIt"] = true
}
local title_allowed_list_tbl = {
    ["CIippedByAura"] = "Owner",
    ["imjustbeter100"] = "Staff",
    ["L0CKED_1N1"] = "Owner",
    ["imbetter100062"] = "Staff",
    ["jdot7580"] = "Staff",
    ["ddosama136703"] = "Staff",
    ["AuraWithClipFarmin"] = "Owner",
    ["ActuallyMasterInIt"] = "Owner"
}
local prefetched = {
    config_gui_url = "https://pastebin.com/raw/9qkZEvjw",
    atlas_url = "https://gitlab.com/flames2431233/Starter/-/raw/main/UIs/Atlas.lua?ref_type=heads",
}
do
    local jobs = {}
    for _, name in ipairs({
        "GlobalEnv_Framework", "Life_Together_Network", "Functions_API_LifeTogether", "TextChatService_MessageConnection",
        "LifeTogether_Anti_Staff", "TextChatService_Unsuspension_Framework", "Vehicle_Mapper",
        "LifeTogether_Framework_Base_1", "LifeTogether_Framework_Base_2", "Dex_Explorer_Checker",
    }) do
        local urls = {}
        for _, u in ipairs(github_urls[name] or {}) do table.insert(urls, u) end
        for _, u in ipairs(fallback_urls[name] or {}) do table.insert(urls, u) end
        if #urls > 0 then jobs[name] = urls end
    end
    jobs.__config_gui = { prefetched.config_gui_url }
    jobs.__atlas = { prefetched.atlas_url }
    local pending = 0
    for name, urls in pairs(jobs) do
        pending += 1
        task.spawn(function()
            for _, url in ipairs(urls) do
                local ok, res = pcall(function() return http_requesting({ Url = url, Method = "GET" }) end)
                if ok and res then
                    local status, body = normalize_response(res)
                    if status == 200 and body ~= "" and not tostring(body):find("404: Not Found") then
                        prefetched[name] = body
                        break
                    end
                end
            end
            pending -= 1
        end)
    end
    local started = os.clock()
    while pending > 0 and os.clock() - started < 20 do task.wait() end
end
function prefetched.load(name)
    local body = prefetched[name]
    if body then
        local f = loadstring(body)
        if f then
            local ok, res = pcall(f)
            if ok then return res end
        end
    end
    return g.load_script(name)
end
local GlobalEnv_Framework = prefetched.load("GlobalEnv_Framework")
local Life_Together_Network = prefetched.load("Life_Together_Network")
local Functions_API_LifeTogether = prefetched.load("Functions_API_LifeTogether")
local TextChatService_MessageConnection = prefetched.load("TextChatService_MessageConnection")
local LifeTogether_Anti_Staff = prefetched.load("LifeTogether_Anti_Staff")
local TextChatService_Unsuspension_Framework = prefetched.load("TextChatService_Unsuspension_Framework")
local Vehicle_Mapper = prefetched.load("Vehicle_Mapper")
local LifeTogether_Framework_Base_1 = prefetched.load("LifeTogether_Framework_Base_1")
local LifeTogether_Framework_Base_2 = prefetched.load("LifeTogether_Framework_Base_2")
local Dex_Explorer_Checker = prefetched.load("Dex_Explorer_Checker")
g.LifeTogetherRP_Admin = true
g.make_round = g.make_round or function(obj, radius)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, radius)
    uic.Parent = obj
end
if type(GlobalEnv_Framework) == "function" then GlobalEnv_Framework() end
if not g.notify then repeat task.wait() until g.notify end
if type(Life_Together_Network) == "function" then Life_Together_Network() end
if type(Functions_API_LifeTogether) == "function" then Functions_API_LifeTogether() end
if type(TextChatService_MessageConnection) == "function" then TextChatService_MessageConnection() end
if type(LifeTogether_Anti_Staff) == "function" then LifeTogether_Anti_Staff() end
if type(TextChatService_Unsuspension_Framework) == "function" then TextChatService_Unsuspension_Framework() end
if type(Vehicle_Mapper) == "function" then Vehicle_Mapper() end
if type(LifeTogether_Framework_Base_1) == "function" then LifeTogether_Framework_Base_1() end
if type(LifeTogether_Framework_Base_2) == "function" then LifeTogether_Framework_Base_2() end
if type(Dex_Explorer_Checker) == "function" then Dex_Explorer_Checker() end
if g.ConstantUpdate_Checker_Live then g.notify("Success", "Enabled/Re-Enabled LIVE update checker.", 5) end
g.all_saved_Life_Together_RP_Outfit_IDs = {}
g.get_all_current_outfits_and_their_IDs = function()
    local Data = g.safe_require(ReplicatedStorage:FindFirstChild("Data", true))
    if typeof(Data) ~= "table" then return end
    local Outfits = Data.outfits
    if typeof(Outfits) ~= "table" then return end
    for i, outfit in pairs(Outfits) do
        if outfit.id then
            table.insert(g.all_saved_Life_Together_RP_Outfit_IDs, outfit.id)
        end
    end
    return g.all_saved_Life_Together_RP_Outfit_IDs
end
g.find_nba_props_map_folder = function()
    local cache = g.nba_props_kept_folder_inst
    if cache and cache:IsA("Folder") then return cache end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Folder") and v.Name:lower():find("map") and v.Name:lower():find("props") and v.Parent.Name:lower():find("nba") then
            g.nba_props_kept_folder_inst = v
            return v
        end
    end
    return nil
end
g.collect_all_nba_props = function()
    local char = g.Character or g.LocalPlayer.Character or g.get_char(LocalPlayer, 10) or g.Char and g.Char:get()
    if not char then return end
    local attr = g.LocalPlayer:GetAttribute("NBA_HUNT_PROGRESS")
    if not attr then return end
    local folder = g.nba_props_kept_folder_inst or g.find_nba_props_map_folder()
    if not folder then return end
    if char and attr == "PLAYING" then
        for _, v in ipairs(folder:GetChildren()) do
            if g.LocalPlayer:GetAttribute("NBA_HUNT_PROGRESS") ~= "PLAYING" then break end
            if v:IsA("Model") then
                char:PivotTo(v:GetPivot() + Vector3.new(0, 2.5, 0))
                task.wait(0.35)
            end
        end
    end
end
local parent_gui = (get_hidden_gui and get_hidden_gui()) or (gethui and gethui()) or g.CoreGui or g.PlayerGui
g.find_delta_icon_image_button = g.find_delta_icon_image_button or function()
    local cached = g.deltas_icon_image_button_descendant_flames_hub_value
    if cached and cached:IsA("ImageButton") and cached.Parent then return cached end
    for _, v in ipairs(parent_gui:GetDescendants()) do
        if v:IsA("ImageButton")
            and v.Size == UDim2.new(0,45,0,45)
            and v.ZIndex == 1
            and v.AutoButtonColor
            and v.Image ~= ""
            and v.ImageColor3 == Color3.fromRGB(255,255,255)
            and v.BackgroundColor3 == Color3.fromRGB(48,50,59)
            and v.BorderColor3 == Color3.fromRGB(27,42,53)
        then
            g.deltas_icon_image_button_descendant_flames_hub_value = v
            return v
        end
    end
    return nil
end
g.toggle_delta_image_button_flames_hub = g.toggle_delta_image_button_flames_hub or function(state)
    if typeof(state) ~= "boolean" then return end
    if not executor_contains("delta") then g.notify("Error", "You're not using Delta, this feature will not work for you.", 7); return end
    local btn = g.find_delta_icon_image_button()
    if btn and btn:IsA("ImageButton") then
        g.Is_Deltas_Icon_Currently_Toggled = state
        btn.Visible = state
    end
end
g.levenshtein = g.levenshtein or function(s, t)
    if s == t then return 0 end
    local len_s, len_t = #s, #t
    if len_s == 0 then return len_t end
    if len_t == 0 then return len_s end
    local d = {}
    for i = 0, len_s do d[i] = {[0] = i} end
    for j = 0, len_t do d[0][j] = j end
    for i = 1, len_s do
        for j = 1, len_t do
            local cost = (s:sub(i,i) == t:sub(j,j)) and 0 or 1
            d[i][j] = math.min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + cost)
        end
    end
    return d[len_s][len_t]
end
g.ToUserId = function(x)
    if typeof(x) == "number" then
        return x
    elseif typeof(x) == "string" then
        local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(x) end)
        return ok and uid or nil
    elseif typeof(x) == "Instance" and x:IsA("Player") then
        return x.UserId
    end
    return nil
end
g.GetUserId = g.GetUserId or function(target)
    if typeof(target) == "Instance" then
        if target:IsA("Player") then return target.UserId end
        local plr = Players:GetPlayerFromCharacter(target)
        if plr then return plr.UserId end
        return nil
    end
    if typeof(target) == "string" then
        local plr = Players:FindFirstChild(target)
        if plr and plr:IsA("Player") then return plr.UserId end
        return nil
    end
    if typeof(target) == "number" then return target end
    return nil
end
local function FindPlayer(query)
    if not query then
        if g.notify and typeof(g.notify) then g.notify("Error", "Something unexpected happened while trying to find: "..tostring(query), 6) end
        return nil
    end
    query = tostring(query):lower()
    local best_match = nil
    local best_score = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        local username = plr.Name:lower()
        local display = plr.DisplayName:lower()
        local userid = tostring(plr.UserId)
        local function substring_score(target)
            local i = target:find(query, 1, true)
            if i then
                return i
            end
            return nil
        end
        local function fuzzy_score(target)
            return g.levenshtein(query, target)
        end
        if query == userid then
            return plr
        end
        local candidates = {
            username,
            display,
            userid
        }
        for _, target in ipairs(candidates) do
            local sub = substring_score(target)
            if sub and sub < best_score then
                best_score = sub
                best_match = plr
            else
                local fuzzy = fuzzy_score(target)
                if fuzzy < best_score then
                    best_score = fuzzy
                    best_match = plr
                end
            end
        end
    end
    return best_match
end
g.FindPlayer = g.FindPlayer or FindPlayer
pcall(function()
    local old_config_path = "Flames_Admin_Config.json"
    if isfile and isfile(old_config_path) then
        local old_config = HttpService:JSONDecode(readfile(old_config_path))
        if type(old_config) == "table" and old_config.Enrolled ~= "disabled" then
            old_config.Enrolled = "disabled"
            writefile(old_config_path, HttpService:JSONEncode(old_config))
        end
    end
end)
if not CoreGui:FindFirstChild("FlamesAdminGUI", true) then
    local ok_old_gui, err_old_gui = pcall(function() loadstring(prefetched.__config_gui or g.http_get(prefetched.config_gui_url))() end)
    if not ok_old_gui then warn("[Flames] old helper GUI skipped: " .. tostring(err_old_gui)) end
end
pcall(function()
    local old_config_gui = CoreGui:FindFirstChild("FlamesAdminGUI", true)
    if old_config_gui then old_config_gui:Destroy() end
end)
g._rgb_conns = g._rgb_conns or {}
g._rgb_global_conn = g._rgb_global_conn or nil
g.rgb_color_map = g.rgb_color_map or {
    red = Color3.fromRGB(255,0,0),
    darkred = Color3.fromRGB(139,0,0),
    green = Color3.fromRGB(0,255,0),
    darkgreen = Color3.fromRGB(0,100,0),
    lime = Color3.fromRGB(50,205,50),
    blue = Color3.fromRGB(0,0,255),
    darkblue = Color3.fromRGB(0,0,139),
    lightblue = Color3.fromRGB(173,216,230),
    skyblue = Color3.fromRGB(135,206,235),
    white = Color3.fromRGB(255,255,255),
    black = Color3.fromRGB(0,0,0),
    gray = Color3.fromRGB(128,128,128),
    lightgray = Color3.fromRGB(211,211,211),
    darkgray = Color3.fromRGB(64,64,64),
    yellow = Color3.fromRGB(255,255,0),
    gold = Color3.fromRGB(255,215,0),
    orange = Color3.fromRGB(255,165,0),
    darkorange = Color3.fromRGB(255,140,0),
    purple = Color3.fromRGB(128,0,128),
    violet = Color3.fromRGB(238,130,238),
    indigo = Color3.fromRGB(75,0,130),
    pink = Color3.fromRGB(255,105,180),
    hotpink = Color3.fromRGB(255,20,147),
    cyan = Color3.fromRGB(0,255,255),
    teal = Color3.fromRGB(0,128,128),
    brown = Color3.fromRGB(139,69,19),
    tan = Color3.fromRGB(210,180,140),
    magenta = Color3.fromRGB(255,0,255),
    coral = Color3.fromRGB(255,127,80),
    salmon = Color3.fromRGB(250,128,114)
}
g.rgb_color_index = {}
do
    local i = 1
    for name in pairs(g.rgb_color_map) do
        g.rgb_color_index[i] = name
        i = i + 1
    end
end
local function ensure_global_loop()
    if g._rgb_global_conn then return end
    local conn = rs.RenderStepped:Connect(function(dt)
        local conns = g._rgb_conns
        local any = false
        for _, data in pairs(conns) do
            if data and data.obj then
                any = true
                if not data.paused then
                    data.hue = (data.hue + (dt * data.speed)) % 1
                    data.obj.BackgroundColor3 = Color3.fromHSV(data.hue, 1, 1)
                end
            end
        end
        if not any then
            g._rgb_global_conn:Disconnect()
            g._rgb_global_conn = nil
        end
    end)
    g._rgb_global_conn = conn
end
g.flowrgb = g.flowrgb or function(name, speed, obj, toggle)
    local conns = g._rgb_conns
    if toggle == false then
        conns[name] = nil
        return
    end
    conns[name] = {
        obj = obj,
        speed = speed,
        hue = 0,
        paused = false
    }
    ensure_global_loop()
end
g.toggle_rgb = g.toggle_rgb or function(name, state)
    local data = g._rgb_conns[name]
    if data then
        data.paused = state
    end
end
g.toggle_all_rgb = g.toggle_all_rgb or function(state)
    for _, data in pairs(g._rgb_conns) do
        if data then
            data.paused = state
        end
    end
end
g.set_rgb_color_smart = g.set_rgb_color_smart or function(name, input)
    local data = g._rgb_conns[name]
    if not data or not data.obj then return end
    local color
    if typeof(input) == "string" then
        color = g.rgb_color_map[input:lower()]
    elseif typeof(input) == "number" then
        local cname = g.rgb_color_index[input]
        if cname then color = g.rgb_color_map[cname] end
    elseif typeof(input) == "Color3" then
        color = input
    end
    if not color then
        local keys = {}
        for k in pairs(g.rgb_color_map) do keys[#keys+1] = k end
        color = g.rgb_color_map[keys[math.random(1, #keys)]]
    end
    data.obj.BackgroundColor3 = color
end
g.set_all_rgb_color_smart = g.set_all_rgb_color_smart or function(input)
    local color
    if typeof(input) == "string" then
        color = g.rgb_color_map[input:lower()]
    elseif typeof(input) == "number" then
        local cname = g.rgb_color_index[input]
        if cname then color = g.rgb_color_map[cname] end
    elseif typeof(input) == "Color3" then
        color = input
    end
    if not color then
        local keys = {}
        for k in pairs(g.rgb_color_map) do keys[#keys+1] = k end
        color = g.rgb_color_map[keys[math.random(1, #keys)]]
    end
    for _, data in pairs(g._rgb_conns) do
        if data and data.obj then
            data.obj.BackgroundColor3 = color
        end
    end
end
g.set_all_rgb_color = g.set_all_rgb_color or function(color)
    for _, data in pairs(g._rgb_conns) do
        if data and data.obj then
            data.obj.BackgroundColor3 = color
        end
    end
end
g.get_player_list = function()
    local players = Players:GetPlayers()
    local parts = {}
    for i, plr in ipairs(players) do table.insert(parts, "[" .. i .. ']: "' .. plr.Name .. '"') end
    return table.concat(parts, ", ")
end
g.is_server_full = g.is_server_full or function()
    local current = #Players:GetPlayers()
    local max = Players.MaxPlayers
    return current >= max
end
g.Device_Detector = g.Device_Detector or function()
    local platform = UserInputService:GetPlatform()
    local platform_map = {
        [Enum.Platform.Windows] = "Windows",
        [Enum.Platform.OSX] = "OSX",
        [Enum.Platform.IOS] = "iOS",
        [Enum.Platform.Android] = "Android",
        [Enum.Platform.XBoxOne] = "Xbox One (Console)",
        [Enum.Platform.PS4] = "PS4 (Console)",
        [Enum.Platform.XBox360] = "Xbox 360 (Console)",
        [Enum.Platform.WiiU] = "Wii-U (Console)",
        [Enum.Platform.NX] = "Cisco Nexus",
        [Enum.Platform.Ouya] = "Ouya (Android-Based)",
        [Enum.Platform.AndroidTV] = "Android TV",
        [Enum.Platform.Chromecast] = "Chromecast",
        [Enum.Platform.Linux] = "Linux (Desktop)",
        [Enum.Platform.SteamOS] = "Steam Client",
        [Enum.Platform.WebOS] = "Web-OS",
        [Enum.Platform.DOS] = "DOS",
        [Enum.Platform.BeOS] = "BeOS",
        [Enum.Platform.UWP] = "UWP (bruh)",
        [Enum.Platform.PS5] = "PS5 (Console)",
        [Enum.Platform.MetaOS] = "MetaOS",
        [Enum.Platform.None] = "Unknown Device"
    }
    return platform_map[platform] or "Unknown Device"
end
g.count_all_flames_hub_commands = g.count_all_flames_hub_commands or function()
    local cmds = g.cmdsString
    if type(cmds) ~= "string" then return 0 end
    local total = 0
    for line in cmds:gmatch("[^\r\n]+") do
        local cleaned = line:match("^%s*(.-)%s*$")
        if cleaned and cleaned ~= "" then
            if cleaned:find("{prefix}",1,true) then
                local valid = cleaned:match("{prefix}%S+")
                if valid then
                    total = total + 1
                end
            end
        end
    end
    return total
end
local holiday = g.getholiday() or ""
local Announcement_Message = "Made Height & Width scale sliders (+ Added Width slider) + re-worked and improved some internal code."
g.displayTimeMax = 60
g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub = g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub or false
g.Script_Version_GlobalGenv = g.Script_Version
if not g.Flames_Hub_Owner_Title_Animated_Initialized then
    g.Flames_Hub_Owner_Title_Animated_Initialized = true
    local title_name = "unique_title_billboard"
    local OWNER_KEY = "owner_title"
    g.activeowner_title_billboards = setmetatable({}, { __mode = "k" })
    local role_to_tag = {
        ["Owner"] = "Owner_Chat_Tag",
        ["Staff"] = "Staff_Chat_Tag",
        ["Wifey"] = "Wifey_Chat_Tag",
        ["Client"] = "Client_Chat_Tag"
    }
    local function resolve_title(player)
        local role = title_allowed_list_tbl[player.Name]
        if not role then return nil end
        local tag_key = role_to_tag[role]
        if not tag_key then return nil end
        local tags = g.Chat_UI_Table_Stuff or {}
        return tags[tag_key] or role
    end
    local function animate_label(label)
        local key = OWNER_KEY .. "_label_" .. tostring(label)
        lib.spawn(key, "spawn", function()
            local index = 1
            while label and label.Parent do
                local tween = g.TweenService:Create(
                    label,
                    TweenInfo.new(0.4, Enum.EasingStyle.Linear),
                    { TextColor3 = g.colors[index] }
                )
                tween:Play()
                tween.Completed:Wait()
                index = (index % #g.colors) + 1
            end
            lib.disconnect(key)
        end)
    end
    local function animate_float(billboard)
        local key = OWNER_KEY .. "_float_" .. tostring(billboard)
        local going_up = true
        lib.spawn(key, "spawn", function()
            while billboard and billboard.Parent do
                local goal = going_up and { StudsOffset = Vector3.new(0, 3, 0) } or { StudsOffset = Vector3.new(0, 2.5, 0) }
                local tween = g.TweenService:Create(
                    billboard,
                    TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    goal
                )
                tween:Play()
                tween.Completed:Wait()
                going_up = not going_up
            end
            lib.disconnect(key)
        end)
    end
    local function create_billboard(character, title_text)
        if not character then return end
        local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 10)
        if not head then return end
        if head:FindFirstChild(title_name) then return end
        local billboard = Instance.new("BillboardGui")
        billboard.Name = title_name
        billboard.Size = UDim2.new(0, 220, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = billboard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 140, 0)
        stroke.Parent = frame
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.Text = title_text
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.TextStrokeTransparency = 0
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Parent = frame
        animate_label(label)
        animate_float(billboard)
        g.activeowner_title_billboards[character] = billboard
    end
    local function cleanup_character(character)
        local billboard = g.activeowner_title_billboards[character]
        if billboard then
            lib.disconnect(OWNER_KEY .. "_float_" .. tostring(billboard))
            local label = billboard:FindFirstChildWhichIsA("TextLabel", true)
            if label then
                lib.disconnect(OWNER_KEY .. "_label_" .. tostring(label))
            end
            pcall(function() billboard:Destroy() end)
            g.activeowner_title_billboards[character] = nil
        end
    end
    local function watch_owners_character(player)
        local title_text = resolve_title(player)
        if not title_text then return end
        local char_key = OWNER_KEY .. "_charadded_" .. tostring(player.UserId)
        local prev_char = player.Character
        local function attach_to_head(char)
            local head = char:FindFirstChild("Head")
            if not head then return end
            if head:FindFirstChild(title_name) then return end
            create_billboard(char, title_text)
        end
        local function on_char(char)
            if prev_char then
                cleanup_character(prev_char)
            end
            prev_char = char
            lib.disconnect(char_key .. "_spawn")
            lib.spawn(char_key .. "_spawn", "spawn", function()
                if not char:IsDescendantOf(workspace) then
                    local conn
                    local done = false
                    conn = char.AncestryChanged:Connect(function()
                        done = true
                        conn:Disconnect()
                    end)
                    local timeout = 10
                    local elapsed = 0
                    while not done and elapsed < timeout do
                        task.wait(0.1)
                        elapsed += 0.1
                    end
                    if not done then return end
                end
                task.wait(0.1)
                attach_to_head(char)
            end)
            local head_watch_key = char_key .. "_headwatch"
            lib.connect(head_watch_key, char.ChildAdded:Connect(function(child)
                if child.Name == "Head" then
                    task.wait(0.1)
                    g.activeowner_title_billboards[char] = nil
                    attach_to_head(char)
                end
            end))
        end
        lib.connect(char_key, player.CharacterAdded:Connect(function(char)
            lib.disconnect(char_key .. "_headwatch")
            lib.disconnect(char_key .. "_spawn")
            on_char(char)
        end))
        if player.Character then on_char(player.Character) end
    end
    local function unwatch_player(player)
        if not title_allowed_list_tbl[player.Name] then return end
        local char_key = OWNER_KEY .. "_charadded_" .. tostring(player.UserId)
        lib.disconnect(char_key)
        lib.disconnect(char_key .. "_spawn")
        lib.disconnect(char_key .. "_headwatch")
        if player.Character then cleanup_character(player.Character) end
    end
    for _, player in ipairs(Players:GetPlayers()) do watch_owners_character(player) end
    if not g.Flames_Title_Owner_Added_And_Removing_Checks then
        g.Flames_Title_Owner_Added_And_Removing_Checks = true
        lib.connect(OWNER_KEY .. "_player_added", Players.PlayerAdded:Connect(function(player)
            lib.spawn(OWNER_KEY .. "_watch_" .. tostring(player.UserId), "spawn", function()
                watch_owners_character(player)
            end)
        end))
        lib.connect(OWNER_KEY .. "_player_removing", Players.PlayerRemoving:Connect(function(player)
            unwatch_player(player)
        end))
    end
end
    g.Flames_Hub_Client_Title_Initialized = true
    local client_billboard_name = "unique_client_title_billboard"
    local CLIENT_KEY = "client_title"
    local client_whitelist = {
        ["Theoneandonlymymy75"] = true,
        ["YYY_Jayce"] = true,
        ["pay2pretty4"] = true,
        ["theyadoree_nunu07"] = true,
        ["Alexouulc"] = true,
        ["DIExBRE"] = true,
        ["D1ExBRE1"] = true,
        ["unemploymenttz"] = true,
        ["CBWxOWNERxJULIOOOO"] = true
    }
    g.active_client_title_billboards = setmetatable({}, { __mode = "k" })
    local function build_client_billboard(character)
        if not character then return end
        local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 10)
        if not head then return end
        if head:FindFirstChild(client_billboard_name) then return end
        local billboard = Instance.new("BillboardGui")
        billboard.Name = client_billboard_name
        billboard.Size = UDim2.new(0, 220, 0, 60)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = billboard
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Parent = frame
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.Text = "💨 Flames Hub | Client 🔥"
        label.Font = Enum.Font.GothamBlack
        label.TextScaled = true
        label.TextStrokeTransparency = 0
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Parent = frame
        g.active_client_title_billboards[character] = billboard
    end
    local function destroy_client_billboard(character)
        local billboard = g.active_client_title_billboards[character]
        if billboard then
            pcall(function() billboard:Destroy() end)
            g.active_client_title_billboards[character] = nil
        end
    end
    local function client_is_whitelisted(player) return client_whitelist[player.Name] == true end
    local function attach_client_billboard(char)
        local head = char:FindFirstChild("Head")
        if not head then return end
        if head:FindFirstChild(client_billboard_name) then return end
        build_client_billboard(char)
    end
    local function on_client_char_added(player, char, prev_char_ref)
        if prev_char_ref[1] then destroy_client_billboard(prev_char_ref[1]) end
        prev_char_ref[1] = char
        local char_key = CLIENT_KEY .. "_charadded_" .. tostring(player.UserId)
        lib.disconnect(char_key .. "_spawn")
        lib.spawn(char_key .. "_spawn", "spawn", function()
            if not char:IsDescendantOf(workspace) then
                local done = false
                local conn
                conn = char.AncestryChanged:Connect(function()
                    done = true
                    conn:Disconnect()
                end)
                local elapsed = 0
                while not done and elapsed < 10 do
                    task.wait(0.1)
                    elapsed += 0.1
                end
                if not done then return end
            end
            task.wait(0.1)
            attach_client_billboard(char)
        end)
        local head_watch_key = char_key .. "_headwatch"
        lib.connect(head_watch_key, char.ChildAdded:Connect(function(child)
            if child.Name == "Head" then
                task.wait(0.1)
                g.active_client_title_billboards[char] = nil
                attach_client_billboard(char)
            end
        end))
    end
    local function start_client_watcher(player)
        if not client_is_whitelisted(player) then return end
        local char_key = CLIENT_KEY .. "_charadded_" .. tostring(player.UserId)
        local prev_char_ref = { player.Character }
        lib.connect(char_key, player.CharacterAdded:Connect(function(char)
            lib.disconnect(char_key .. "_headwatch")
            lib.disconnect(char_key .. "_spawn")
            on_client_char_added(player, char, prev_char_ref)
        end))
        if player.Character then on_client_char_added(player, player.Character, prev_char_ref) end
    end
    local function stop_client_watcher(player)
        if not client_is_whitelisted(player) then return end
        local char_key = CLIENT_KEY .. "_charadded_" .. tostring(player.UserId)
        lib.disconnect(char_key)
        lib.disconnect(char_key .. "_spawn")
        lib.disconnect(char_key .. "_headwatch")
        if player.Character then destroy_client_billboard(player.Character) end
    end
    for _, player in ipairs(Players:GetPlayers()) do start_client_watcher(player) end
    if not g.Flames_Client_Title_Player_Checks then
        g.Flames_Client_Title_Player_Checks = true
        lib.connect(CLIENT_KEY .. "_player_added", Players.PlayerAdded:Connect(function(player)
            lib.spawn(CLIENT_KEY .. "_watch_" .. tostring(player.UserId), "spawn", function()
                start_client_watcher(player)
            end)
        end))
        lib.connect(CLIENT_KEY .. "_player_removing", Players.PlayerRemoving:Connect(function(player)
            stop_client_watcher(player)
        end))
    end
end
local Local_Player = Players.LocalPlayer
g.Delete_Bad_Accessories = g.Delete_Bad_Accessories or function(Target_Char)
	for _, v in ipairs(Target_Char:GetDescendants()) do
		if v:IsA("Accessory") and v.AccessoryType == Enum.AccessoryType.Jacket and v.Name:lower():find("aura") then
			v:Destroy()
		end
	end
end
local function Setup_Player(Player)
	if Player == Local_Player then return end
	if Player.Character then
		g.Delete_Bad_Accessories(Player.Character)
	end
	Lib.connect("bad_accessories_" .. Player.UserId, Player.CharacterAdded:Connect(function(New_Char)
		if not New_Char or not New_Char.Parent then
			repeat task.wait() until New_Char and New_Char:FindFirstChild("Humanoid")
		end
		g.Delete_Bad_Accessories(New_Char)
	end))
end
for _, Player in ipairs(Players:GetPlayers()) do Setup_Player(Player) end
Lib.connect("bad_accessories_player_added", Players.PlayerAdded:Connect(Setup_Player))
Lib.connect("bad_accessories_player_removing", Players.PlayerRemoving:Connect(function(Player)
	Lib.disconnect("bad_accessories_" .. Player.UserId)
end))
g.is_streamed_in = g.is_streamed_in or function(plr)
    if not plr or not plr:IsA("Player") then return false end
    local char = plr.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    return root:IsDescendantOf(workspace)
end
g.is_streamed_out_checker = g.is_streamed_out_checker or function(char)
    if not char or not char:IsA("Player") then return false end
    char = char or char.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 1)
    if not root then return false end
    if not root:IsDescendantOf(workspace) then return false end
    return true
end
g.LoadPerformanceStatsGUI = function()
    if g.performance_stats then
        g.notify("Info", "Performance Statistics GUI is already loaded.", 5)
        return
    end
    g.notify("Info", "Loading Performance Statistics GUI...", 5)
    local success, err = pcall(function()
        local src = g.get_script_text("grab_file_performance")
        if src == "" then
            g.notify("Error", "no valid source", 5)
        end
        loadstring(src)()
    end)
    if not success then
        g.notify("Error", "Failed to load Performance Statistics GUI: "..tostring(err), 8)
        return
    end
    local timeout = 10
    repeat
        task.wait(0.5)
        timeout = timeout - 0.5
    until g.performance_stats or timeout <= 0
    if g.performance_stats then
        g.notify("Success", "Loaded Performance Statistics GUI.", 5)
    else
        g.notify("Warning", "Failed to confirm Performance Statistics GUI load.", 8)
    end
end
g.fileName = "LifeTogether_Admin_Configuration.json"
g.make_stroke = g.make_stroke or function(obj, thickness, trans)
    local ui_stroke = Instance.new("UIStroke")
    ui_stroke.Thickness = tonumber(thickness) or 1
    ui_stroke.Transparency = tonumber(trans) or 0.3
    ui_stroke.Parent = obj
end
g.find_module_s = function(module_name)
    if not module_name then return nil end
    local base = g.Modules or g.ReplicatedStorage:FindFirstChild("Modules", true)
    local Modules = g.safe_require(base)
    local ok, Module_Found = pcall(function() return Modules and Modules[module_name:lower()] end)
    if ok and Module_Found then return Module_Found end
    local wanted = module_name:lower()
    for _, d in ipairs(base and base:GetDescendants() or {}) do
        if d:IsA("ModuleScript") and d.Name:lower() == wanted then return g.safe_require(d) end
    end
    return nil
end
g.NightVisionEnabled = g.NightVisionEnabled or false
g.ensureColorCorrection = function(name, props)
    local effect = g.Lighting:FindFirstChild(name)
    if not effect then
        effect = Instance.new("ColorCorrectionEffect")
        effect.Name = name
        effect.Parent = g.Lighting or cloneref and cloneref(game:GetService("Lighting")) or game:GetService("Lighting")
    end
    for prop, value in pairs(props) do
        effect[prop] = value
    end
    return effect
end
local ccEffects = {
    NightVisionColorCorrection = g.ensureColorCorrection("NightVisionColorCorrection", {
        Enabled = false,
        Brightness = 0,
        Contrast = -0.1,
        Saturation = -1,
        TintColor = Color3.new(0.6, 1, 0.815686)
    })
}
local vignetteGui = CoreGui:FindFirstChild("VignetteEffect") or g.PlayerGui:FindFirstChild("VignetteEffect")
if not vignetteGui then
    vignetteGui = Instance.new("ScreenGui")
    vignetteGui.Name = "VignetteEffect"
    vignetteGui.IgnoreGuiInset = true
    vignetteGui.Enabled = false
    vignetteGui.ResetOnSpawn = false
    vignetteGui.Parent = CoreGui
end
local vignetteImage = vignetteGui:FindFirstChildOfClass("ImageLabel")
if not vignetteImage then
    vignetteImage = Instance.new("ImageLabel")
    vignetteImage.Name = "ImageLabel"
    vignetteImage.Active = false
    vignetteImage.BackgroundColor3 = Color3.new(1, 1, 1)
    vignetteImage.BackgroundTransparency = 1
    vignetteImage.BorderColor3 = Color3.new(0, 0, 0)
    vignetteImage.BorderSizePixel = 0
    vignetteImage.Position = UDim2.new(0, 0, 0, 0)
    vignetteImage.Size = UDim2.new(1, 0, 1, 0)
    vignetteImage.Visible = true
    vignetteImage.Image = "rbxassetid://123500368394738"
    vignetteImage.ImageColor3 = Color3.new(1, 1, 1)
    vignetteImage.ImageTransparency = 0
    vignetteImage.ImageRectOffset = Vector2.new(0, 0)
    vignetteImage.ImageRectSize = Vector2.new(0, 0)
    vignetteImage.TileSize = UDim2.new(1, 0, 1, 0)
    vignetteImage.SliceScale = 1
    vignetteImage.SliceCenter = Rect.new(0, 0, 0, 0)
    vignetteImage.ScaleType = Enum.ScaleType.Stretch
    vignetteImage.Parent = vignetteGui
end
g.ToggleNightVision = function(state)
    g.NightVisionEnabled = state
    for _, effect in pairs(ccEffects) do
        effect.Enabled = state
    end
    vignetteGui.Enabled = state
end
g.night_vision = function(toggle)
    if toggle == true then
        if g.NightVisionEnabled then g.notify("Warning", "Night Vision is already enabled.", 5); return end
        g.ToggleNightVision(true)
        g.notify("Success", "Night Vision has been enabled.", 5)
    elseif toggle == false then
        if not g.NightVisionEnabled then g.notify("Warning", "Night Vision is already enabled.", 5); return end
        g.ToggleNightVision(false)
        g.notify("Success", "Night Vision has been disabled.", 5)
    else
        return
    end
end
g.create_message_instance = function(inst_name, message, duration)
    message = tostring(message)
    inst_name = tostring(inst_name)
    if not duration or typeof(duration) ~= "number" then duration = 10 end
    local new_msg = Instance.new("Hint")
    new_msg.Name = inst_name
    new_msg.Text = message
    new_msg.Parent = workspace
    task.wait(duration)
    if new_msg and new_msg:IsA("Hint") and new_msg.Parent ~= nil then new_msg:Destroy() end
end
g.Net = g.Net or g.find_module_s("Net") or g.safe_require(g.Core:FindFirstChild("Net"))
g.owner_joined = function(Name)
   local owner_text_content = "Flames Hub | Owner has joined this server ("..tostring(Name).."), this is my current and only account right now, so come to me if you need help/assistance."
   if g.notify and typeof(g.notify) == "function" then g.notify("Success", owner_text_content, 15) else print("Success: "..tostring(owner_text_content)) end
end
if g.Teleport_Checker_For_Script then
    pcall(function() g.Teleport_Checker_For_Script:Disconnect() end)
    g.Teleport_Checker_For_Script = nil
end
task.wait()
local TeleportCheck = false
g.Teleport_Checker_For_Script = g.LocalPlayer.OnTeleport:Connect(function(State)
	if not TeleportCheck and queueteleport and typeof(queueteleport) == "function" then
		TeleportCheck = true
		queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/EnterpriseExperience/Flames_Hub_Games/refs/heads/main/Experiences/13967668166.lua'))()")
	end
end)
g.LocalPlayer = g.LocalPlayer or g.safe_wrapper("LocalPlayer")
local some_vehicles = {
    "Monster Truck",
    "SVJ",
    "SF90",
    "Charger SRT",
    "Smart Car",
    "SWAT Van",
    "FireTruck",
    "Tank",
    "MiniCooper",
    "TrackHawk",
    "GClass",
    "Chiron",
    "Humvee",
    "Tesla",
    "Cayenne",
    "F150",
    "Police SUV",
}
task.wait()
print("[Flames] loading: vehicle check")
if not g.Spawned_Vehicle_Checker then
    local Net = g.find_module_s("Net") or g.safe_require(g.Core:FindFirstChild("Net"))
    g.notify("Success", "Spoofing Vehicle spawner...", 10)
    for _, car in ipairs(some_vehicles) do
        fw(0.2)
        Net.get("spawn_vehicle", tostring(car))
    end
end
task.wait()
g.find_placed_models_folder = function()
    local cached_folder = g.cached_placed_models_folder
    if cached_folder and cached_folder.Parent and cached_folder:IsDescendantOf(workspace) then return cached_folder end
    for _, v in ipairs(g.Workspace:GetDescendants()) do
        local n = v.Name:lower()
        if v:IsA("Folder") and (n:find("placedmodels", 1, true) or n:find("modelsplaced", 1, true)) then
            g.cached_placed_models_folder = v
            return v
        end
    end
    return nil
end
if not g.cached_placed_models_folder then pcall(function() g.find_placed_models_folder() end) end
local Placed_Models = g.cached_placed_models_folder or Workspace:FindFirstChild("PlacedModels") or Workspace:WaitForChild("PlacedModels", 1) or g.find_placed_models_folder()
g.workspace_editor_script_GUI = function()
    if g.CoreGui:FindFirstChild("Workspace_Editor_GUI_Flames_Hub") and g.CoreGui:FindFirstChild("Workspace_Editor_GUI_Flames_Hub"):IsA("ScreenGui") then
        g.CoreGui:FindFirstChild("Workspace_Editor_GUI_Flames_Hub").Enabled = true
        return
    end
    fw(0.1)
    loadstring(g.http_get('https://pastebin.com/raw/bdiufqqx'))()
end
g.is_in_private_server = function()
    local Remote = RobloxReplicatedStorage:FindFirstChild("GetServerType")
    if not Remote then return g.notify("Error", "RemoteFunction: GetServerType does not exist under: RobloxReplicatedStorage, probably patched.", 3) end
    local Result = Remote:InvokeServer()
    local IsPrivateServer = Result == "VIPServer" and true or false
    if IsPrivateServer then
        return true
    else
        g.notify("Info", "You are in a public server.", 3)
        return false
    end
end
g.has_server_admin = function()
    local is_priv_server = g.is_in_private_server()
    if not is_priv_server then return false end
    for _, player in ipairs(Players:GetPlayers()) do
        local hrp = g.get_root(player, Players.RespawnTime + 0.5)
        if hrp and hrp.Parent and hrp:IsDescendantOf(game) then
            local billboard = hrp:FindFirstChild("CharacterBillboardGui")
            if billboard then
                local label = billboard:FindFirstChild("ServerAdmin")
                if label and label:IsA("TextLabel") and label.Visible then
                return true
                end
            end
        end
    end
    return false
end
g.get_server_admin_player = function()
    local function check_player(player)
        local hrp = g.get_root(player, Players.RespawnTime + 0.5)
        if not hrp then return false end
        local billboard = hrp:FindFirstChild("CharacterBillboardGui")
        if not billboard then return false end
        local label = billboard:FindFirstChild("ServerAdmin")
        return label and label:IsA("TextLabel") and label.Visible
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if check_player(player) then
            return player
        end
    end
    if check_player(g.LocalPlayer or Players.LocalPlayer) then return g.LocalPlayer or Players.LocalPlayer end
    return nil
end
g.is_localplayer_server_owner = function()
    if not g.has_server_admin() then return false end
    local admin_player = g.get_server_admin_player()
    local local_player = g.LocalPlayer
    return admin_player and local_player and admin_player == local_player
end
g.notify_priv_server_owner = function()
    local is_priv = g.is_in_private_server()
    if is_priv == nil then return end
    if not is_priv then g.notify("Info", "You're in a public server.", 3); return end
    if not g.has_server_admin() then g.notify("Info", "This is a private server but the owner is not present.", 10); return end
    if g.is_localplayer_server_owner() then g.notify("Info", "You are the private server owner.", 5); return end
    local admin_player = g.get_server_admin_player()
    if admin_player and admin_player:IsA("Player") then
        g.notify("Info", "This is a private server owned by: " .. tostring(admin_player.Name), 7)
    else
        g.notify("Info", "This is a private server owned by: " .. tostring(admin_player), 7)
    end
end
g.server_admin_tp = function(Player)
    local check_is_localplr_priv_server_owner = g.is_localplayer_server_owner()
    if not check_is_localplr_priv_server_owner then g.notify("Warning", "You do not own this Private Server!", 5); return end
    if typeof(Player) ~= "Instance" or not Player:IsA("Player") then g.notify("Error", "That player doesn't exist or is not a Player.", 5); return end
    g.Send("server_admin_teleport_to_player", Player.UserId)
end
g.disable_emote_func = function()
    local Humanoid = g.Humanoid or g.get_human(LocalPlayer, Players.RespawnTime + 1)
    if not Humanoid then g.notify("Error", "Humanoid not found, try resetting.", 5); return end
    pcall(function() for _, v in ipairs(Humanoid:GetPlayingAnimationTracks()) do v:Stop() end end)
    if g.Is_Currently_Emoting then g.Is_Currently_Emoting = false end
end
if not g.Spawned_Vehicle_Checker then
    local Net = g.Net or g.safe_require(g.Core:FindFirstChild("Net"))
    local success, response = pcall(function()
        Net.get("spawn_vehicle", "Monster Truck")
        wait(3)
        return g.get_vehicle()
    end)
    if success and response then
        fw(0.1)
        if g.get_vehicle() and g.Humanoid.Sit or g.Humanoid.Sit == true then
            g.Humanoid:ChangeState(3)
            fw(0.2)
            Net.get("spawn_vehicle", g.get_vehicle().Name or "Monster Truck")
        elseif g.get_vehicle() and g.Humanoid.Sit == false then
            Net.get("spawn_vehicle", g.get_vehicle().Name or "Monster Truck")
        elseif not g.get_vehicle() then
            g.notify("Warning", "We did spawn the Vehicle it seems, but it seems like you despawned the Vehicle.", 10)
        elseif not g.get_vehicle() and g.Humanoid.Sit == true then
            pcall(function() g.Humanoid:ChangeState(3) end)
            g.notify("Warning", "We did not find your Vehicle, but it seems like it worked.", 5)
        end
    else
        if not success then
            g.notify("Warning", "Couldn't spawn the test vehicle, carrying on anyway.", 5)
        end
    end
    g.Spawned_Vehicle_Checker = true
end
local Char = g.Char or g.safe_require(ReplicatedStorage:FindFirstChild("Char", true))
g.get_current_character_life_together_rp = function() return Char.get() end
g.get_hrp_life_together_rp = function() return Char.get_hrp() end
g.get_human_life_together_rp = function() return Char.get_hum() end
if g.invisible_toggle_connections then
    for _, conn in pairs(g.invisible_toggle_connections) do pcall(function() conn:Disconnect() end) end
    fw(0.1)
    g.invisible_toggle_connections = nil
end
local player = g.LocalPlayer or Players.LocalPlayer
local character, humanoid, rootPart
g.is_invisible_script_toggled = false
g.invisible_body_parts = g.invisible_body_parts or {}
g.invis_main_FE_connections = g.invis_main_FE_connections or {}
g.setupCharacter = function()
    character = g.Character or player.Character or player.CharacterAdded:Wait()
    humanoid = g.Humanoid or character:WaitForChild("Humanoid", 5)
    rootPart = g.HumanoidRootPart or character:WaitForChild("HumanoidRootPart", 5)
    g.invisible_body_parts = {}
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            g.invisible_body_parts[obj] = obj.Transparency
        end
    end
end
g.createUI = function()
    local gui = CoreGui:FindFirstChild("InvisibleUI")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "InvisibleUI"
        gui.ResetOnSpawn = false
        gui.Parent = CoreGui
    end
    gui.Enabled = false
    gui:ClearAllChildren()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 90)
    frame.Position = UDim2.new(0.5, -110, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 2
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui
    frame.Visible = false
    local invisBtn = Instance.new("TextButton")
    invisBtn.Size = UDim2.new(0, 100, 0, 40)
    invisBtn.Position = UDim2.new(0, 10, 0, 25)
    invisBtn.Text = "Invisible"
    invisBtn.TextScaled = true
    invisBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    invisBtn.Parent = frame
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 80, 0, 30)
    toggleBtn.Position = UDim2.new(0, 130, 0, 30)
    toggleBtn.Text = "Hide"
    toggleBtn.TextScaled = true
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 160, 240)
    toggleBtn.Parent = frame
    invisBtn.MouseButton1Click:Connect(function()
        g.is_invisible_script_toggled = not g.is_invisible_script_toggled
        for part, original in pairs(g.invisible_body_parts) do
            if part and part.Parent then
                part.Transparency = g.is_invisible_script_toggled and 0.5 or original
            end
        end
    end)
    toggleBtn.MouseButton1Click:Connect(function()
        if toggleBtn.Text == "Hide" then
            invisBtn.Visible = false
            toggleBtn.Text = "Show"
            frame.Size = UDim2.new(0, 100, 0, 40)
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.Position = UDim2.new(0, 0, 0, 0)
        else
            invisBtn.Visible = true
            toggleBtn.Text = "Hide"
            frame.Size = UDim2.new(0, 220, 0, 90)
            invisBtn.Size = UDim2.new(0, 100, 0, 40)
            invisBtn.Position = UDim2.new(0, 10, 0, 25)
            toggleBtn.Size = UDim2.new(0, 80, 0, 30)
            toggleBtn.Position = UDim2.new(0, 130, 0, 30)
        end
    end)
end
g.setupCharacter()
g.createUI()
if g.invis_main_FE_connections.Heartbeat then
    pcall(function() g.invis_main_FE_connections.Heartbeat:Disconnect() end)
    g.invis_main_FE_connections.Heartbeat = nil
end
task.wait()
g.invis_main_FE_connections.Heartbeat = RunService.Heartbeat:Connect(function()
    if g.is_invisible_script_toggled and rootPart and humanoid then
        local cf = rootPart.CFrame
        local camOffset = humanoid.CameraOffset
        local hidden = cf * CFrame.new(0, -200000, 0)
        rootPart.CFrame = hidden
        humanoid.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
        RunService.RenderStepped:Wait()
        rootPart.CFrame = cf
        humanoid.CameraOffset = camOffset
    end
end)
if g.invis_main_FE_connections.CharacterAdded then
    pcall(function() g.invis_main_FE_connections.CharacterAdded:Disconnect() end)
    g.invis_main_FE_connections.CharacterAdded = nil
end
task.wait()
g.invis_main_FE_connections.CharacterAdded = player.CharacterAdded:Connect(function()
    g.is_invisible_script_toggled = false
    g.setupCharacter()
    g.createUI()
end)
g.invisible_toggle_connections = g.invis_main_FE_connections
g.set_invisible = g.set_invisible or function(state)
    g.is_invisible_script_toggled = state and true or false
    if g.is_invisible_script_toggled then
        g.notify("Info", "You can still use the chat, but people won't be able to see it directly above your head.", 10)
    end
    for part, original in pairs(g.invisible_body_parts) do
        if part and part.Parent then
            part.Transparency = g.is_invisible_script_toggled and 0.5 or original
        end
    end
end
g.AllCars = {
    "Magic Carpet", "EClass", "TowTruck", "Bicycle", "Fiat500", "Cayenne", "Jetski", "LuggageScooter",
    "MiniCooper", "GarbageTruck", "EScooter", "Monster Truck", "Yacht", "Stingray", "FireTruck", "VespaPizza",
    "VespaPolice", "F150", "Police SUV", "Chiron", "Humvee", "Wrangler", "Box Van", "Ambulance", "Urus", "Tesla",
    "Cybertruck", "RollsRoyce", "GClass", "SVJ", "MX5", "SF90", "Charger SRT", "Evoque", "IceCream Truck",
    "Vespa", "ATV", "Limo", "Tank", "Smart Car", "Beauford", "SchoolBus", "Sprinter", "GolfKart", "TrackHawk",
    "Helicopter", "SnowPlow", "Camper Van", "SWAT Van", "Magic Carpett"
}
local CarMap = {}
g.kick_plr = g.kick_plr or function(player)
    if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 5); return end
    local name
    if typeof(player) == "Instance" then name = player.Name else name = tostring(player) end
    if not allowed[player.Name] then
        local args = {
            "server_admin_kick_player",
            tostring(name)
        }
        g.Get(unpack(args))
    end
end
    wait(0.15)
    local connector = (syn and syn.websocket and syn.websocket.connect) or (WebSocket and WebSocket.connect) or (websocket and websocket.connect)
    if not connector or typeof(connector) ~= "function" then g.notify("Error", "[Flames Hub - Chat]: No WebSocket support, unable to use Flames Hub | Custom Chat script.", 10); return end
    pcall(function() loadstring(g.http_get("https://pastefy.app/108vjy8A/raw"))() end)
end
if Workspace:FindFirstChild("WildwoodIntegration") then
    local wild_wood = Workspace:FindFirstChild("WildwoodIntegration")
    for _, v in ipairs(wild_wood:GetDescendants()) do
        if v:IsA("TouchTransmitter") then
            pcall(function() v:Destroy() end)
        elseif v:IsA("Seat") then
            pcall(function()
                v.Disabled = true
                wait(0.15)
                v:Destroy()
            end)
        end
    end
end
g.server_lock_whitelist_gui = g.server_lock_whitelist_gui or function()
    if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 5); return end
    if g.ServerLockWhitelistManagerGUI then g.notify("Warning", "Server-Lock whitelist manager is already running!", 5); return end
    g.ServerLockWhitelistManagerGUI = true
    g.server_whitelist = g.server_whitelist or {}
    if not g.server_whitelist["CIippedByAura"] then g.server_whitelist["CIippedByAura"] = true end
    if not g.server_whitelist["L0CKED_1N1"] then g.server_whitelist["L0CKED_1N1"] = true end
    if not g.server_whitelist["AuraWithClipFarmin"] then g.server_whitelist["AuraWithClipFarmin"] = true end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = tostring(g.randomString())
    ScreenGui.Parent = parent_gui
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 300, 0, 350)
    Main.Position = UDim2.new(0.5, -150, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    if g.dragify and typeof(g.dragify) == "function" then g.dragify(Main) end
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Main
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TitleBar.Parent = Main
    local UI_Corner = Instance.new("UICorner")
    UI_Corner.CornerRadius = UDim.new(0, 8)
    UI_Corner.Parent = TitleBar
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.970000029, -30, 1, 0)
    Title.Position = UDim2.new(0, 5, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Server-Lock Whitelist Manager"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextScaled = true
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar
    local UICorner_ = Instance.new("UICorner")
    UICorner_.CornerRadius = UDim.new(0, 8)
    UICorner_.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function()
        g.TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 0), Transparency = 1}):Play()
        wait(0.25)
        g.ServerLockWhitelistManagerGUI = false
        ScreenGui:Destroy()
    end)
    local Input = Instance.new("TextBox")
    Input.PlaceholderText = "Enter username..."
    Input.Size = UDim2.new(1, -20, 0, 25)
    Input.Position = UDim2.new(0, 10, 0, 35)
    Input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.Text = ""
    Input.Font = Enum.Font.Gotham
    Input.TextSize = 14
    Input.Parent = Main
    local UICorner_2 = Instance.new("UICorner")
    UICorner_2.CornerRadius = UDim.new(0, 8)
    UICorner_2.Parent = Input
    local AddButton = Instance.new("TextButton")
    AddButton.Size = UDim2.new(0.5, -15, 0, 25)
    AddButton.Position = UDim2.new(0, 10, 0, 68)
    AddButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AddButton.Text = "Add to server-lock whitelist"
    AddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AddButton.Font = Enum.Font.Gotham
    AddButton.TextSize = 14
    AddButton.TextScaled = true
    AddButton.Parent = Main
    local RemoveButton = Instance.new("TextButton")
    RemoveButton.Size = UDim2.new(0.5, -15, 0, 25)
    RemoveButton.Position = UDim2.new(0, 150, 0, 68)
    RemoveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    RemoveButton.Text = "Remove from server-lock whitelist"
    RemoveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RemoveButton.Font = Enum.Font.Gotham
    RemoveButton.TextSize = 14
    RemoveButton.TextScaled = true
    RemoveButton.Parent = Main
    local UICorner_3 = Instance.new("UICorner")
    UICorner_3.CornerRadius = UDim.new(0, 8)
    UICorner_3.Parent = AddButton
    local UICorner_4 = Instance.new("UICorner")
    UICorner_4.CornerRadius = UDim.new(0, 8)
    UICorner_4.Parent = RemoveButton
    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -20, 1, -110)
    PlayerList.Position = UDim2.new(0, 10, 0, 100)
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    PlayerList.ScrollBarThickness = 5
    PlayerList.Parent = Main
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.Parent = PlayerList
    local function refresh_list()
        for _, child in ipairs(PlayerList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= g.LocalPlayer then
                if plr.Name ~= "CIippedByAura" and plr.Name ~= "L0CKED_1N1" and plr.Name ~= "AuraWithClipFarmin" then
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 0, 30)
                    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    frame.Parent = PlayerList
                    local name_label = Instance.new("TextLabel")
                    name_label.Size = UDim2.new(1, -60, 1, 0)
                    name_label.Position = UDim2.new(0, 5, 0, 0)
                    name_label.BackgroundTransparency = 1
                    name_label.Text = plr.Name
                    name_label.TextScaled = true
                    name_label.TextColor3 = g.server_whitelist[plr.Name] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 255)
                    name_label.Font = Enum.Font.Gotham
                    name_label.TextSize = 14
                    name_label.TextXAlignment = Enum.TextXAlignment.Left
                    name_label.Parent = frame
                    local button = Instance.new("TextButton")
                    button.Size = UDim2.new(0, 50, 1, -6)
                    button.Position = UDim2.new(1, -55, 0, 3)
                    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    button.Text = g.server_whitelist[plr.Name] and "Remove" or "Add"
                    button.TextScaled = true
                    button.TextColor3 = Color3.fromRGB(255, 255, 255)
                    button.Font = Enum.Font.Gotham
                    button.TextSize = 13
                    button.Parent = frame
                    local UICorner = Instance.new("UICorner")
                    UICorner.CornerRadius = UDim.new(0, 8)
                    UICorner.Parent = frame
                    local UICorner_5 = Instance.new("UICorner")
                    UICorner_5.CornerRadius = UDim.new(0, 8)
                    UICorner_5.Parent = name_label
                    local UICorner_6 = Instance.new("UICorner")
                    UICorner_6.CornerRadius = UDim.new(0, 8)
                    UICorner_6.Parent = button
                    button.MouseButton1Click:Connect(function()
                        if g.server_whitelist[plr.Name] then
                            g.server_whitelist[plr.Name] = nil
                        else
                            g.server_whitelist[plr.Name] = true
                        end
                        refresh_list()
                    end)
                end
            end
        end
        PlayerList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    end
    AddButton.MouseButton1Click:Connect(function()
        local name = Input.Text
        if name ~= "" then
            if g.server_whitelist[name] then g.notify("Warning", tostring(name).." is already in the server-lock whitelist!", 5); return end
            g.server_whitelist[name] = true
            Input.Text = ""
            wait(0.3)
            if g.server_whitelist[name] then g.notify("Success", tostring(name).." was added to server-lock whitelist! (they won't get kicked by server-lock).", 15) end
            refresh_list()
        end
    end)
    RemoveButton.MouseButton1Click:Connect(function()
        local name = Input.Text
        if name ~= "" then
            if not g.server_whitelist[name] then g.notify("Warning", tostring(name).." is not in the server-lock whitelist!", 5); return end
            g.server_whitelist[name] = nil
            Input.Text = ""
            wait(0.3)
            if not g.server_whitelist[name] then g.notify("Success", tostring(name).." was removed from the server-lock whitelist! (they WILL get kicked by server-lock).", 15) end
            refresh_list()
        end
    end)
    if not g.Player_Added_Removed_Conn_Whitelist_Manager_Check then
        g.Player_Added_Removed_Conn_Whitelist_Manager_Check = true
        Players.PlayerAdded:Connect(function()
            task.wait(0.5)
            refresh_list()
        end)
        Players.PlayerRemoving:Connect(refresh_list)
    end
    refresh_list()
end
g.friend_user_async_function = g.friend_user_async_function or function(player)
    local target = player
    if not target then g.notify("Error", "Player does not exist or has left the game.", 5); return end
    if g.LocalPlayer:IsFriendsWith(target.UserId) then g.notify("Warning", "You're already friends with this person.", 5); return end
    local ok, response = pcall(function() g.LocalPlayer:RequestFriendship(target) end)
    if not ok then
        g.notify("Warning", "An unexpected error happened while friending: "..tostring(target), 10)
        g.notify("Error", "Error: "..tostring(response), 10)
        return
    else
        g.notify("Success", "Sent friend request to: "..tostring(target).." successfully!", 5)
    end
end
g.unfriend_user_async = g.unfriend_user_async or function(player)
    local target = player
    if not target then g.notify("Error", "Player does not exist or has left the game.", 5); return end
    if not g.LocalPlayer:IsFriendsWith(target.UserId) then g.notify("Warning", "You're not friends with this person.", 5); return end
    local ok, response = pcall(function() g.LocalPlayer:RevokeFriendship(target) end)
    if not ok then
        g.notify("Warning", "An unexpected error happened while unadding: "..tostring(target), 10)
        g.notify("Error", "Error: "..tostring(response), 10)
        return
    else
        g.notify("Success", "Unfriended target player: "..tostring(target).." successfully.", 5)
    end
end
g.prompt_game_invite_func = g.prompt_game_invite_func or function(args)
    local options = Instance.new("ExperienceInviteOptions")
    options.InviteMessageId = tostring(args) or "join me bruh"
    local player = g.LocalPlayer or Players.LocalPlayer
    local SocialService = g.SocialService or cloneref and cloneref(game:GetService("SocialService")) or game:GetService("SocialService")
    local ok, response = pcall(function() SocialService:PromptGameInvite(player, options) end)
    if ok and response ~= nil then
        g.notify("Success", "Sent invite to person: "..tostring(player), 3)
    else
        g.notify("Warning", "Apparently something went wrong trying to invite: "..tostring(player)..", got response: "..tostring(response), 10)
    end
end
g.server_lock_toggle = g.server_lock_toggle or function(toggle)
    if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 5); return end
    g.server_whitelist = g.server_whitelist or {}
    if not g.server_whitelist["CIippedByAura"] then g.server_whitelist["CIippedByAura"] = true end
    local function should_kick(v)
        if v == g.LocalPlayer then return false end
        if g.server_whitelist[v.Name] then return false end
        return true
    end
    if toggle == true then
        if g.server_lock_enabled then g.notify("Warning", "Server-Lock is already enabled!", 5); return end
        if not workspace:FindFirstChildOfClass("Hint") then
            local hint_instance = Instance.new("Hint")
            hint_instance.Text = "Flames Hub - ServerLock V2 is now enabled."
            if typeof(workspace) == "Instance" and workspace:IsDescendantOf(game) then hint_instance.Parent = workspace end
        end
        g.server_lock_enabled = true
        for _, v in ipairs(g.Players:GetPlayers()) do
            if should_kick(v) then
                pcall(g.kick_plr, v)
            end
        end
        if not g.server_lock_playeradded_conn then
            g.server_lock_playeradded_conn = Players.PlayerAdded:Connect(function(v)
                if not g.server_lock_enabled then return end
                if should_kick(v) then
                    task.wait(0.5)
                    pcall(g.kick_plr, v)
                end
            end)
        end
    elseif toggle == false then
        if not g.server_lock_enabled then g.notify("Warning", "Server-Lock is not enabled!", 5); return end
        local hint = workspace:FindFirstChildOfClass("Hint")
        if hint then pcall(function() hint:Destroy() end) end
        g.server_lock_enabled = false
        if g.server_lock_playeradded_conn then
            g.server_lock_playeradded_conn:Disconnect()
            g.server_lock_playeradded_conn = nil
        end
        g.notify("Success", "Server-Lock is now disabled.", 5)
    end
end
g.stop_time_toggle = g.stop_time_toggle or function(toggle)
    if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 5); return end
    if toggle == true then
        g.Send("time_toggle", true)
        g.is_time_currently_stopped_priv_server = true
        g.notify("Success", "Time has been stopped.", 3)
    elseif toggle == false then
        g.Send("time_toggle", false)
        g.is_time_currently_stopped_priv_server = false
        g.notify("Success", "Time is now resumed.", 3)
    else
        return
    end
end
g.change_time_num = g.change_time_num or function(number_input)
    if typeof(number_input) ~= "number" then g.notify("Error", "That is not a number!", 3); return end
    if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 3); return end
    local main_conv = tonumber(number_input) or number_input
    g.Send("change_time", main_conv)
end
g.flash_time_toggle = g.flash_time_toggle or function(toggled)
    if not g.is_localplayer_server_owner() then
        g.flashing_time_fe_toggle = false
        g.notify("Error", "You are not the private server owner!", 5)
        return
    end
    if toggled then
        if g.flashing_time_fe_toggle then g.notify("Warning", "Time Flasher is already enabled!", 5); return end
        if UserInputService.TouchEnabled then
            g.flashing_time_fe_toggle = true
            g.notify("Success", "Time Flasher is now enabled.", 5)
            g.Flashing_Time_FE_Toggle_Task = task.spawn(function()
                while g.flashing_time_fe_toggle == true do
                fw(0.1)
                    g.change_time_num(4.5)
                    fw(0)
                    g.change_time_num(12)
                    fw(.1)
                    g.change_time_num(23)
                end
            end)
        else
            g.flashing_time_fe_toggle = true
            g.notify("Success", "Time Flasher is now enabled.", 5)
            g.Flashing_Time_FE_Toggle_Task = task.spawn(function()
                while g.flashing_time_fe_toggle == true do
                fw(0)
                    g.change_time_num(4.5)
                    fw(0)
                    g.change_time_num(12)
                    fw(0)
                    g.change_time_num(23)
                end
            end)
        end
    else
        if not g.flashing_time_fe_toggle then g.notify("Warning", "Time Flasher is not enabled!", 3); return end
        g.flashing_time_fe_toggle = false
        if g.Flashing_Time_FE_Toggle_Task then
            task.cancel(g.Flashing_Time_FE_Toggle_Task)
            g.Flashing_Time_FE_Toggle_Task = nil
        end
        g.notify("Success", "Time Flasher has been disabled.", 5)
    end
end
g.pick_new_weather = g.pick_new_weather or function(weather_set)
    local weather_args
    if weather_set:lower():find("snow") then
        weather_args = {
            "change_weather",
            {
                humidity = 1,
                wind = 0.55,
                temperature = 0
            }
        }
    elseif weather_set:lower():find("sun") then
        weather_args = {
            "change_weather",
            {
                humidity = 0.5,
                wind = 0.3,
                temperature = 1
            }
        }
    elseif weather_set:lower():find("rain") then
        weather_args = {
            "change_weather",
            {
                humidity = 1,
                wind = 0.7,
                temperature = 0.6
            }
        }
    end
    return weather_args
end
g.set_new_weather = g.set_new_weather or function(new_weather_input)
    if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 5); return end
    local changed_weather = g.pick_new_weather(new_weather_input)
    if not changed_weather then g.notify("Error", "Invalid weather type: " .. tostring(new_weather_input), 5); return end
    g.Send(unpack(changed_weather))
end
g.weather_flasher_loop = g.weather_flasher_loop or function(toggle)
    if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 3); return end
    local fw = g.FlamesLibrary.wait
    if toggle == true then
        if g.changing_weather_on_repeat then g.notify("Warning", "Flames Hub - Weather Flasher is already enabled!", 5); return end
        g.changing_weather_on_repeat = true
        g.notify("Success", "Flames Hub - Weather Flasher is now enabled.", 5)
        g.FlamesLibrary.spawn("weather_loop_repeater", "spawn", function()
            while g.changing_weather_on_repeat == true do
            fw(0)
                g.set_new_weather("snow")
                fw(.1)
                g.set_new_weather("rain")
                fw(0)
                g.set_new_weather("sun")
            end
        end)
    elseif toggle == false then
        if not g.changing_weather_on_repeat then g.notify("Warning", "Flames Hub - Weather Flasher is not enabled!", 5); return end
        g.changing_weather_on_repeat = false
        g.FlamesLibrary.disconnect("weather_loop_repeater")
        g.notify("Success", "Flames Hub - Weather Flasher is now disabled.", 5)
    else
        return
    end
end
for _, name in ipairs(g.AllCars) do CarMap[name:lower()] = name end
g.car_listing_gui = function()
    if g.CarListingGUIValue then return end
    g.CarListingGUIValue = true
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = tostring(g.randomString())
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = parent_gui
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = IsMobile and UDim2.new(0, 280, 0, 350) or UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset/2, 0.5, -MainFrame.Size.Y.Offset/2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = MainFrame
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Made by: "..tostring(g.Script_Creator)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Parent = MainFrame
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        g.CarListingGUIValue = false
    end)
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
    ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.Parent = MainFrame
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = ScrollingFrame
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingTop = UDim.new(0, 5)
    for _, name in ipairs(g.AllCars) do
        local CarButton = Instance.new("TextButton")
        CarButton.Size = UDim2.new(1, -10, 0, 30)
        CarButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        CarButton.Text = name
        CarButton.Font = Enum.Font.Gotham
        CarButton.TextSize = 16
        CarButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        CarButton.Parent = ScrollingFrame
        local CarCorner = Instance.new("UICorner")
        CarCorner.CornerRadius = UDim.new(0, 10)
        CarCorner.Parent = CarButton
        CarButton.MouseButton1Click:Connect(function()
            if not g.Get then return end
            g.Get("spawn_vehicle", name)
        end)
    end
    if g.dragify and typeof(g.dragify) == "function" then g.dragify(MainFrame) end
end
g.stop_all_anims = g.stop_all_anims or function()
    local Hum = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
    if not Hum then return end
    for i,v in next, Hum:GetPlayingAnimationTracks() do v:Stop() end
end
g.isTrackPlaying = g.isTrackPlaying or function(humanoid)
    if not humanoid or not humanoid:IsDescendantOf(game) then g.notify("Error", "Humanoid does not exist / was not found.", 1); return false end
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do if track.IsPlaying or (track.TimePosition > 0 and track.Length > 0) then return true end end
    return false
end
task.wait()
g.main_emote_ID = 72074295131591
g.play_anim_on_local_plr = function(anim_selector)
    if g.isTrackPlaying(g.Humanoid) then g.stop_all_anims() end
    wait(0.25)
    if anim_selector == "1" then
        local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://134313829527772"
        fw(0.1)
        local track = Humanoid:LoadAnimation(anim)
        track:Play(0, 1, 1)
        track.TimePosition = 3.2708375453948975
        track:AdjustSpeed(0)
        for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do v:AdjustSpeed(0) end
    elseif anim_selector == "2" then
        local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://124771204189379"
        fw(0.1)
        local track = Humanoid:LoadAnimation(anim)
        repeat task.wait() until track.Length > 0
        track:Play(0, 1, 1)
        repeat task.wait() until track.IsPlaying and track.Speed >= 0.5
        if not track.IsPlaying then return end
        for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do v:AdjustSpeed(0) end
    elseif anim_selector == "3" then
        local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://137126647656632"
        fw(0.1)
        local track = Humanoid:LoadAnimation(anim)
        track:Play(0, 1, 1)
        track:AdjustSpeed(0)
        for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do v:AdjustSpeed(0) end
    elseif anim_selector == "4" then
        local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://85233258054867"
        fw(0.1)
        local track = Humanoid:LoadAnimation(anim)
        track:Play(0, 1, 1)
        track:AdjustSpeed(0)
        for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do v:AdjustSpeed(0) end
    elseif anim_selector == "5" then
        local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://101847197011911"
        fw(0.1)
        local track = Humanoid:LoadAnimation(anim)
        track:Play(0, 1, 1)
        track:AdjustSpeed(2)
        for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do v:AdjustSpeed(2) end
    elseif anim_selector == "6" then
        local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://138990462417721"
        fw(0.1)
        local track = Humanoid:LoadAnimation(anim)
        track:Play(0, 1, 1)
        track:AdjustSpeed(0)
        track.TimePosition = 2.49
        fw(0.1)
        for _, v in pairs(Humanoid:GetPlayingAnimationTracks()) do v:AdjustSpeed(0) end
    else
        g.notify("Error", "Invalid Animation argument provided, pick between either 1 or 2.", 7)
        return
    end
end
g.create_bindable = g.create_bindable or function()
    if g._localBindable then return g._localBindable end
    local b = Instance.new("BindableEvent")
    g._localBindable = b
    return b
end
g.is_me = g.is_me or function(input)
    if type(input) ~= "string" then return false end
    input = string.lower(input)
    local name = string.lower(LocalPlayer.Name)
    local display = string.lower(LocalPlayer.DisplayName)
    return name:sub(1, #input) == input or display:sub(1, #input) == input
end
local Bindable
if not allowed[LocalPlayer.Name] then Bindable = g.create_bindable() end
if allowed[LocalPlayer.Name] then g.notify("Success", "You're an Administrator/Staff in Flames Hub, you can do our PRIVATE commands by doing: ?flamescmds in the chat.", 15) end
g.current_worn_cached_clothing_items = g.current_worn_cached_clothing_items or {}
g.GetWornAssetId = g.GetWornAssetId or function(AssetType)
    local Humanoid = g.LocalPlayer.Character and g.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return nil end
    local Desc = Humanoid:FindFirstChildOfClass("HumanoidDescription")
    if not Desc then Desc = Humanoid:GetAppliedDescription() end
    if not Desc then return nil end
    if AssetType:lower() == "shirt" then
        return Desc.Shirt ~= 0 and Desc.Shirt or nil
    elseif AssetType:lower() == "pants" then
        return Desc.Pants ~= 0 and Desc.Pants or nil
    end
    return nil
end
task.wait()
g.LayeredTypes = {
    [Enum.AccessoryType.TShirt] = true,
    [Enum.AccessoryType.Shirt] = true,
    [Enum.AccessoryType.Pants] = true,
    [Enum.AccessoryType.Jacket] = true,
    [Enum.AccessoryType.Sweater] = true,
    [Enum.AccessoryType.Shorts] = true,
    [Enum.AccessoryType.LeftShoe] = true,
    [Enum.AccessoryType.RightShoe] = true,
    [Enum.AccessoryType.DressSkirt] = true,
}
g.CacheWornClothing = g.CacheWornClothing or function()
    g.current_worn_cached_clothing_items["shirt"] = g.GetWornAssetId("shirt")
    g.current_worn_cached_clothing_items["pants"] = g.GetWornAssetId("pants")
    g.current_worn_cached_clothing_items["layered"] = {}
    local Character = g.Character or g.LocalPlayer.Character or g.get_char(LocalPlayer, 3) or g.Char:get()
    if not Character then return end
    local hum = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("Humanoid") or g.get_human(LocalPlayer, 3) or g.Char:get_hum()
    if not hum then return end
    local desc = hum:GetAppliedDescription()
    for _, info in ipairs(desc:GetAccessories(true)) do
        if info.IsLayered then
            table.insert(g.current_worn_cached_clothing_items["layered"], {
                AssetId = info.AssetId,
                AccessoryType = info.AccessoryType.Name,
            })
        end
    end
end
g.GetCachedClothingId = g.GetCachedClothingId or function(AssetType) AssetType = AssetType:lower(); return g.current_worn_cached_clothing_items[AssetType] end
g.GetCachedLayered = g.GetCachedLayered or function() return g.current_worn_cached_clothing_items["layered"] or {} end
task.wait()
g.CacheWornClothing()
local function GetControlModule()
    local PlayerScripts = g.LocalPlayer:WaitForChild("PlayerScripts")
    local PlayerModule = g.safe_require(PlayerScripts:WaitForChild("PlayerModule"))
    return PlayerModule:GetControls()
end
local commands = {
    ["!anim"] = {
        display = "!anim [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.play_anim_on_local_plr("1")
        end
    },
    ["!reset"] = {
        display = "!reset [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.Humanoid then
                pcall(function() g.Humanoid.Health = 0 end)
            elseif not g.Humanoid or not g.Humanoid.Parent then
                repeat task.wait(10) until g.Character:FindFirstChildOfClass("Humanoid")
                wait(1)
                if g.Character:FindFirstChildOfClass("Humanoid") then
                g.Character:FindFirstChildOfClass("Humanoid").Health = 0
                end
            end
        end
    },
    ["!speed"] = {
        display = "!speed [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.Humanoid then pcall(function() g.Humanoid.WalkSpeed = 100 end) end
        end
    },
    ["!anim2"] = {
        display = "!anim2 [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.play_anim_on_local_plr("2")
        end
    },
    ["!anim3"] = {
        display = "!anim3 [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.play_anim_on_local_plr("3")
        end
    },
    ["!anim4"] = {
        display = "!anim4 [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.play_anim_on_local_plr("4")
        end
    },
    ["!anim5"] = {
        display = "!anim5 [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.play_anim_on_local_plr("5")
        end
    },
    ["!anim6"] = {
        display = "!anim6 [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.play_anim_on_local_plr("6")
        end
    },
    ["!jump"] = {
        display = "!jump [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.Humanoid and g.HumanoidRootPart then
                pcall(function()
                    g.HumanoidRootPart.Anchored = true
                    wait(0.3)
                    g.Humanoid:ChangeState(3)
                    wait(0.3)
                    g.HumanoidRootPart.Anchored = false
                end)
            end
        end
    },
    ["!freeze"] = {
        display = "!freeze [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.Humanoid then pcall(function() g.Humanoid.WalkSpeed = 0 end) end
            if g.HumanoidRootPart then pcall(function() g.HumanoidRootPart.Anchored = true end) end
            local Controls = GetControlModule()
            if Controls then Controls:Disable() end
        end
    },
    ["!unfreeze"] = {
        display = "!unfreeze [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.HumanoidRootPart then pcall(function() g.HumanoidRootPart.Anchored = false end) end
            if g.Humanoid then pcall(function() g.Humanoid.WalkSpeed = 16 end) end
            local Controls = GetControlModule()
            if Controls then Controls:Enable() end
        end
    },
    ["!kick"] = {
        display = "!kick [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            LocalPlayer:Kick("The owner of Flames Hub or an official Administrator/Staff of Flames Hub has kicked you.")
            wait(3)
            while true do end
        end
    },
    ["!bring"] = {
        display = "!bring [player]",
        run = function(args, sender)
            local target = args[2]
            if not g.is_me(target) then return end
            if not sender then return end
            local sender_char = sender.Character
            local sender_hrp = sender_char:WaitForChild("HumanoidRootPart")
            if sender_char and sender_char:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    if g.HumanoidRootPart and g.Character:FindFirstChild("HumanoidRootPart") then
                        g.HumanoidRootPart.CFrame = CFrame.new(sender_hrp.Position + Vector3.new(0, 3, 0))
                        g.Character:FindFirstChild("HumanoidRootPart").CFrame = CFrame.new(sender_hrp.Position + Vector3.new(0, 3, 0))
                    else
                        g.Character:PivotTo(sender_char:GetPivot() + Vector3.new(0, 3, 0))
                    end
                end)
            end
        end
    },
    ["!unanim"] = {
        display = "!unanim [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.stop_all_anims()
        end
    },
    ["!unemote"] = {
        display = "!unemote [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.stop_all_anims()
        end
    },
    ["!stopanims"] = {
        display = "!stopanims [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            g.stop_all_anims()
        end
    },
    ["!vis"] = {
        display = "!vis [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.LocalPlayer:GetAttribute("is_verified") == false then return end
            if not g.InvisibleMode then return end
            if g.InvisibleMode.enabled.get() then
                g.InvisibleMode.enabled.set(false)
            end
        end
    },
    ["!visible"] = {
        display = "!visible [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.LocalPlayer:GetAttribute("is_verified") == false then return end
            if not g.InvisibleMode then return end
            if g.InvisibleMode.enabled.get() then
                g.InvisibleMode.enabled.set(false)
            end
        end
    },
    ["!invis"] = {
        display = "!invis [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.LocalPlayer:GetAttribute("is_verified") == false then return end
            if not g.InvisibleMode then return end
            if not g.InvisibleMode.enabled.get() then
                g.InvisibleMode.enabled.set(true)
            end
        end
    },
    ["!invisible"] = {
        display = "!invisible [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.LocalPlayer:GetAttribute("is_verified") == false then return end
            if not g.InvisibleMode then return end
            if not g.InvisibleMode.enabled.get() then
                g.InvisibleMode.enabled.set(true)
            end
        end
    },
    ["!remove"] = {
        display = "!remove [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            local blank_pants = 15885405395
            local blank_shirt = 15821796333
            local current_pants = g.GetWornAssetId("pants")
            local current_shirt = g.GetWornAssetId("shirt")
            if current_pants ~= blank_pants or current_shirt ~= blank_shirt then g.CacheWornClothing() end
            local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
            if Humanoid and Humanoid.Parent and Humanoid:IsDescendantOf(game) then
                local desc = Humanoid:GetAppliedDescription()
                for _, info in ipairs(desc:GetAccessories(true)) do
                    if info.IsLayered then
                        g.Get("wear", info.AssetId, info.AccessoryType.Name .. "Accessory")
                        task.wait(0.45)
                    end
                end
            end
            task.wait(0.25)
            if current_shirt and current_shirt ~= blank_shirt then g.Get("wear", current_shirt, "Shirt") end
            if current_pants and current_pants ~= blank_pants then g.Get("wear", current_pants, "Pants") end
            g.Get("wear", blank_shirt, "Shirt")
            g.Get("wear", blank_pants, "Pants")
        end
    },
    ["!erase"] = {
        display = "!erase [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            local blank_pants = 15885405395
            local blank_shirt = 15821796333
            local current_pants = g.GetWornAssetId("pants")
            local current_shirt = g.GetWornAssetId("shirt")
            if current_pants ~= blank_pants or current_shirt ~= blank_shirt then g.CacheWornClothing() end
            local Humanoid = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("AnimationController") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
            if Humanoid and Humanoid.Parent and Humanoid:IsDescendantOf(game) then
                local desc = Humanoid:GetAppliedDescription()
                for _, info in ipairs(desc:GetAccessories(true)) do
                    if info.IsLayered then
                        g.Get("wear", info.AssetId, info.AccessoryType.Name .. "Accessory")
                        task.wait(0.45)
                    end
                end
            end
            task.wait(0.25)
            if current_shirt and current_shirt ~= blank_shirt then
                g.Get("wear", current_shirt, "Shirt")
            end
            if current_pants and current_pants ~= blank_pants then
                g.Get("wear", current_pants, "Pants")
            end
            g.Get("wear", blank_shirt, "Shirt")
            g.Get("wear", blank_pants, "Pants")
        end
    },
    ["!restore"] = {
        display = "!restore [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            local blank_pants = 15885405395
            local blank_shirt = 15821796333
            local cached_pants = g.GetCachedClothingId("pants")
            local cached_shirt = g.GetCachedClothingId("shirt")
            local current_pants = g.GetWornAssetId("pants")
            local current_shirt = g.GetWornAssetId("shirt")
            if current_shirt == blank_shirt and cached_shirt then g.Get("wear", cached_shirt, "Shirt") end
            if current_pants == blank_pants and cached_pants then g.Get("wear", cached_pants, "Pants") end
            for _, item in ipairs(g.GetCachedLayered()) do
                g.Get("wear", item.AssetId, item.AccessoryType .. "Accessory")
                task.wait(0.45)
            end
        end
    },
    ["!fix"] = {
        display = "!fix [player]",
        run = function(args)
            local target = args[2]
            if not g.is_me(target) then return end
            if g.Fix_Camera_Head_Cooldown_Plr_Active then return end
            g.Fix_Camera_Head_Cooldown_Plr_Active = true
            local head = g.Head or g.Character and g.Character:FindFirstChild("Head") or g.get_head(LocalPlayer) or g.Char:get_head()
            if not head or not head.Parent then return end
            local hum = g.Humanoid or g.Character and g.Character:FindFirstChildWhichIsA("Humanoid") or g.get_human(LocalPlayer)
            if not hum or not hum.Parent or not hum:IsDescendantOf(game) then return end
            local root = g.HumanoidRootPart or g.Character and g.Character:FindFirstChild("HumanoidRootPart") or g.get_root(LocalPlayer)
            if not root or not root.Parent then return end
            workspace.CurrentCamera:Destroy()
            wait(.1)
            repeat wait() until LocalPlayer.Character ~= nil
            workspace.CurrentCamera.CameraSubject = g.Humanoid or g.Character and g.Character:FindFirstChildWhichIsA("Humanoid") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 99999
            LocalPlayer.CameraMode = "Classic"
            head.Anchored = false
            if hum and hum.Parent and hum:IsDescendantOf(game) then pcall(function() hum.WalkSpeed = 16 end) end
            if root and root.Parent then pcall(function() root.Anchored = false end) end
            task.delay(5, function() g.Fix_Camera_Head_Cooldown_Plr_Active = false end)
        end
    }
}
g.run_command = function(cmdName, args, sender)
    local data = commands[cmdName]
    if data then data.run(args, sender) end
end
g.commands_menu_for_administrators_and_staffs = g.commands_menu_for_administrators_and_staffs or function()
    if g.CommandsMenuGui and g.CommandsMenuGui:IsA("ScreenGui") then
        g.CoreGui:FindFirstChild("CommandsMenu").Enabled = true
        return
    end
    local Commands_Menu_For_Administration_Listing = Instance.new("ScreenGui")
    Commands_Menu_For_Administration_Listing.Name = "CommandsMenu"
    Commands_Menu_For_Administration_Listing.ResetOnSpawn = false
    Commands_Menu_For_Administration_Listing.Parent = CoreGui or g.CoreGui
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = Commands_Menu_For_Administration_Listing
    wait(0.45)
    if g.dragify and typeof(g.dragify) == "function" then g.dragify(MainFrame) end
    g.CommandsMenuGui = Commands_Menu_For_Administration_Listing
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(1, -10, 0, 20)
    Subtitle.Position = UDim2.new(0, 5, 0, 35)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Commands only work on other Flames Hub users."
    Subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    Subtitle.TextScaled = true
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextWrapped = true
    Subtitle.Parent = MainFrame
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -10, 0, 30)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Commands Menu"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextScaled = true
    CloseButton.Parent = MainFrame
    CloseButton.MouseButton1Click:Connect(function()
        Commands_Menu_For_Administration_Listing.Enabled = false
    end)
    wait(0.5)
    g.make_round(CloseButton)
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Position = UDim2.new(0, 5, 0, 65)
    ScrollFrame.Size = UDim2.new(1, -10, 1, -75)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.Parent = MainFrame
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollFrame
    for _, data in pairs(commands) do
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -10, 0, 30)
        Label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Text = data.display
        Label.Font = Enum.Font.Gotham
        Label.TextScaled = true
        Label.TextWrapped = true
        Label.Parent = ScrollFrame
        local LabelCorner = Instance.new("UICorner")
        LabelCorner.CornerRadius = UDim.new(0, 5)
        LabelCorner.Parent = Label
    end
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 5)
    end)
end
if g.Message_Received_Conn_Owner_Commands_Setup then
    pcall(function() g.Message_Received_Conn_Owner_Commands_Setup:Disconnect() end)
    g.Message_Received_Conn_Owner_Commands_Setup = nil
end
task.wait()
g.Message_Received_Conn_Owner_Commands_Setup = TextChatService.MessageReceived:Connect(function(message)
    local source = message.TextSource
    if not source then return end
    local sender = Players:GetPlayerByUserId(source.UserId)
    if not sender or not allowed[sender.Name] then return end
    local text = message.Text
    if type(text) ~= "string" or text == "" then return end
    local args = text:split(" ")
    local cmdName = string.lower(args[1])
    local data = commands[cmdName]
    if data then
        data.run(args, sender)
    end
end)
if g.Administrator_Staff_Message_Received_Commands_Section then
    pcall(function() g.Administrator_Staff_Message_Received_Commands_Section:Disconnect() end)
    g.Administrator_Staff_Message_Received_Commands_Section = nil
end
task.wait()
g.Administrator_Staff_Message_Received_Commands_Section = TextChatService.MessageReceived:Connect(function(message)
    local source = message.TextSource
    if not source then return end
    local sender = Players:GetPlayerByUserId(source.UserId)
    if not sender then return end
    if sender ~= LocalPlayer then return end
    if not allowed[sender.Name] then return end
    local text = message.Text
    if type(text) ~= "string" or text == "" then return end
    if text == "?flamescmds" then
        g.commands_menu_for_administrators_and_staffs()
    end
end)
if g.Copy_Outfit_Chat_Command_Conn then
    pcall(function() g.Copy_Outfit_Chat_Command_Conn:Disconnect() end)
    g.Copy_Outfit_Chat_Command_Conn = nil
end
task.wait()
g.Copy_Outfit_Chat_Command_Conn = TextChatService.MessageReceived:Connect(function(message)
    local source = message.TextSource
    if not source or source.UserId ~= LocalPlayer.UserId then return end
    local text = message.Text
    if type(text) ~= "string" then return end
    local cmd, name = text:match("^%s*(%S+)%s+(%S+)")
    if not cmd or cmd:lower() ~= "!copy" then return end
    local Target = g.findplr(name)
    if not Target then g.notify("Error", "No player matches: " .. tostring(name), 5); return end
    if Target == LocalPlayer then g.notify("Error", "That's you!", 3); return end
    if g.is_copying_avatar_already_flames then g.notify("Warning", "Copy avatar is already running!, wait a moment, until it's done.", 5); return end
    task.spawn(g.copy_plr_avatar, Target)
end)
if Bindable and Bindable:IsA("BindableEvent") then
    if g.Bindable_Event_Run_Command_LocalPlayer_Connection then
        pcall(function() g.Bindable_Event_Run_Command_LocalPlayer_Connection:Disconnect() end)
        g.Bindable_Event_Run_Command_LocalPlayer_Connection = nil
    end
    wait(0.25)
    g.Bindable_Event_Run_Command_LocalPlayer_Connection = Bindable.Event:Connect(function(cmdName, args)
        if type(cmdName) ~= "string" or type(args) ~= "table" then return end
        g.run_command(cmdName, args, nil)
    end)
end
print("[Flames] loading: enrolled state")
if g.get_enrolled_state == nil and not CoreGui:FindFirstChild("FlamesAdminGUI", true) then
    local enrolled_file = "Flames_Admin_Config.json"
    g.get_enrolled_state = function()
        local ok, config = pcall(function() return HttpService:JSONDecode(readfile(enrolled_file)) end)
        return ok and type(config) == "table" and config.Enrolled or "disabled"
    end
    g.set_enrolled_state = g.set_enrolled_state or function(state)
        if state ~= "enabled" and state ~= "disabled" then return end
        local ok, config = pcall(function() return HttpService:JSONDecode(readfile(enrolled_file)) end)
        config = ok and type(config) == "table" and config or {}
        config.Enrolled = state
        pcall(writefile, enrolled_file, HttpService:JSONEncode(config))
    end
end
if g.get_enrolled_state == nil then
    g.notify("Info", "Waiting until 'get_enrolled_state' exists...", 5)
    local attempts = 0
    local max_attempts = 15
    repeat
        task.wait()
        attempts = attempts + 1
    until (g.get_enrolled_state and g.get_enrolled_state ~= nil) or attempts >= max_attempts
    if g.get_enrolled_state then
        g.notify("Success", "Found get_enrolled_state correctly.", 5)
    else
        g.notify("Error", "get_enrolled_state not found after "..tostring(max_attempts).." attempts.", 5)
    end
end
g.get_other_vehicle = g.get_other_vehicle or function(Player)
    for _, v in pairs(g.Workspace:FindFirstChild("Vehicles"):GetChildren()) do
        local owner_object = v:FindFirstChild("owner") or v:FindFirstChild("owner", true)
        if owner_object and owner_object.Value == Player then return v end
    end
    return nil
end
local RGB_KEY = "rgb_phone_loop"
g.change_phone_color = g.change_phone_color or function(New_Color) g.Send("phone_color", New_Color) end
g.RGB_Phone = g.RGB_Phone or function(Boolean)
    local lib = g.FlamesLibrary
    if Boolean == true then
        if g.RGB_Rainbow_Phone then g.notify("Warning", "RGB/Rainbow Phone is already enabled.", 3); return end
        g.RGB_Rainbow_Phone = true
        g.notify("Success", "Started RGB/Rainbow Phone.", 3)
        lib.spawn(RGB_KEY, "spawn", function()
            while g.RGB_Rainbow_Phone == true do
                for _, color in ipairs(g.colors) do
                    if g.RGB_Rainbow_Phone ~= true then return end
                    g.change_phone_color(color)
                    fw(0)
                end
            end
        end)
    elseif Boolean == false then
        if not g.RGB_Rainbow_Phone then g.notify("Warning", "RGB/Rainbow Phone is not enabled.", 3); return end
        g.RGB_Rainbow_Phone = false
        lib.disconnect(RGB_KEY)
        g.notify("Success", "Stopped RGB/Rainbow Phone.", 3)
        fw(0.1)
        g.change_phone_color(Color3.fromRGB(255, 255, 255))
    end
end
g.Find_DAISE_Integration_Folder = function()
    local cache = g.DAISE_Integration_Folder_Main_WS
    if cache and cache:IsA("Folder") then return cache end
    for _, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:lower():find("daise") then
            g.DAISE_Integration_Folder_Main_WS = v
            return v
        end
    end
    return nil
end
task.wait()
if not g.DAISE_Integration_Folder_Main_WS then pcall(function() g.Find_DAISE_Integration_Folder() end) end
g.Find_DAISE_Main_NPC_Model = function()
    local cache = g.DAISE_NPC_Model_Found
    if cache and cache.Parent and cache:IsA("Model") then return cache end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("npc") and v.Parent.Name:lower():find("daise") then
            g.DAISE_NPC_Model_Found = v
            return v
        end
    end
    return nil
end
task.wait()
if not g.DAISE_NPC_Model_Found then pcall(function() g.Find_DAISE_Main_NPC_Model() end) end
g.Find_Persistent_Model_For_DAISE = function()
    local cache = g.DAISE_Persistent_Model_Found
    if cache and cache.Parent and cache:IsA("Model") then return cache end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("persistent") and v.Parent.Name:lower():find("challenge") then
            g.DAISE_Persistent_Model_Found = v
            return v
        end
    end
    return nil
end
task.wait()
if not g.DAISE_Persistent_Model_Found then pcall(function() g.Find_Persistent_Model_For_DAISE() end) end
g.Hide_DAISE_Area = function(state)
    if g.DAISE_Area_Hidden == state then g.notify("Warning", state and "DAISE Area is already hidden." or "DAISE Area is already visible.", 3); return end
    local folder = g.DAISE_Integration_Folder_Main_WS or g.Find_DAISE_Integration_Folder()
    if not folder or not folder:IsA("Folder") then g.notify("Error", "DAISE Integration folder not found.", 3); return end
    local npc = g.DAISE_NPC_Model_Found or g.Find_DAISE_Main_NPC_Model()
    if not npc or not npc:IsA("Model") then g.notify("Error", "DAISE NPC Model not found.", 3); return end
    local persistent = g.DAISE_Persistent_Model_Found or g.Find_Persistent_Model_For_DAISE()
    if persistent then
        for _, v in ipairs(persistent:GetChildren()) do
            if v:IsA("Folder") and v.Name:lower():find("display") then
                v:Destroy()
            end
        end
    end
    for _, v in ipairs(npc:GetDescendants()) do
        if v.Name == "TouchPart" then
            v.Transparency = 1
            v.CanCollide = false
            for _, child in ipairs(v:GetChildren()) do
                if child:IsA("TouchTransmitter") then
                    child:Destroy()
                end
            end
        elseif v.Name == "HumanoidRootPart" then
            v.CanCollide = false
        end
    end
    for _, v in ipairs(folder:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "TouchPart" and v.Name ~= "DAISESlogan" and v.Name ~= "DAISEBeautyArea" then
            local has_banner_decal = false
            for _, child in ipairs(v:GetChildren()) do
                if child:IsA("Decal") and child.Texture == "rbxassetid://133336087393319" then
                    has_banner_decal = true
                    break
                end
            end
            if has_banner_decal then
                v.Transparency = 1
                v.CanCollide = false
            else
                v.Transparency = state and 1 or 0
                v.CanCollide = not state
            end
        elseif v:IsA("Decal") then
            v.Transparency = state and 1 or 0
        elseif v:IsA("SurfaceGui") then
            v.Enabled = not state
        end
    end
    g.DAISE_Area_Hidden = state
    g.notify("Success", state and "DAISE Area Hidden" or "DAISE Area Shown", 3)
end
g.steal_car_functionality = function(target_plr)
    local selected_player = nil
    if typeof(target_plr) == "Instance" and target_plr:IsA("Player") then
        selected_player = target_plr
    elseif typeof(target_plr) == "string" then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Name == target_plr then
                selected_player = plr
                break
            end
        end
    end
    if not selected_player then return end
    for _, vehicle in pairs(Workspace:FindFirstChild("Vehicles"):GetChildren()) do
        local seat = vehicle:FindFirstChild("VehicleSeat") or vehicle:FindFirstChild("VehicleSeat", true)
        if not seat then g.notify("Error", "We could not find VehicleSeat in this Vehicle.", 3); return end
        local owner_object = vehicle:FindFirstChild("owner")
        if not owner_object or not owner_object:IsA("ObjectValue") then g.notify("Error", "ObjectValue: owner not found or does not exist.", 3); return end
        if owner_object.Value == selected_player then
            if seat.Occupant == nil and vehicle:GetAttribute("locked") == false then
                local ok, response = pcall(function() g.Get("sit", seat) end)
                if not ok and g.notify then g.notify("Error", tostring(response), 15) end
                break
            else
                g.notify("Error", "Someone is already in this Vehicle, try again when they are not sitting in it.", 8)
                break
            end
        end
    end
end
g.save_outfits_GUI = function()
    if parent_gui:FindFirstChild("OutfitManagerUI", true) and parent_gui:FindFirstChild("OutfitManagerUI", true):IsA("ScreenGui") then
        parent_gui:FindFirstChild("OutfitManagerUI", true).Enabled = true
        g.notify("Warning", "You're already running Outfits Manager!", 5)
        return
    end
    if g.LoadedOutfit_Manager_GUI then g.notify("Warning", "You're already running Outfits Manager!", 5);  end
    local cached_outfits = {}
    g.ui_refs = {}
    local Send, Get = g.Send, g.Get
    local FolderName = "lifetogether_admin_savedoutfits"
    local function save_outfit(name, outfit, callback)
        if not isfolder(FolderName) then makefolder(FolderName) end
        local filePath = FolderName .. "/" .. name .. ".json"
        if isfile(filePath) then
            cached_outfits[name] = outfit
            if callback then callback(true) end
            return
        end
        local ok = pcall(function() writefile(filePath, HttpService:JSONEncode(outfit)) end)
        cached_outfits[name] = outfit
        if callback then callback(ok) end
    end
    local function delete_outfit(name, callback)
        local ok = pcall(function() if isfile(FolderName .. "/" .. name .. ".json") then delfile(FolderName .. "/" .. name .. ".json") end end)
        cached_outfits[name] = nil
        if callback then callback(ok) end
    end
    local function rename_outfit(old_name, new_name, callback)
        if not cached_outfits[old_name] then
            if callback then callback(false, "Outfit not found") end
            return
        end
        if cached_outfits[new_name] then
            if callback then callback(false, "Name already taken") end
            return
        end
        local outfit = cached_outfits[old_name]
        if not isfolder(FolderName) then makefolder(FolderName) end
        local ok = pcall(function()
            writefile(FolderName .. "/" .. new_name .. ".json", HttpService:JSONEncode(outfit))
            if isfile(FolderName .. "/" .. old_name .. ".json") then
                delfile(FolderName .. "/" .. old_name .. ".json")
            end
        end)
        if ok then
            cached_outfits[new_name] = outfit
            cached_outfits[old_name] = nil
        end
        if callback then callback(ok) end
    end
    local function fetch_outfit_list(callback)
        cached_outfits = {}
        if not isfolder(FolderName) then
            if callback then callback(true) end
            return
        end
        for _, f in ipairs(listfiles(FolderName)) do
            if f:match("%.json$") then
                local name = f:match("([^/\\]+)%.json$")
                local ok, content = pcall(readfile, f)
                if ok and content and #content > 0 then
                    local success, data = pcall(function() return HttpService:JSONDecode(content) end)
                    if success and type(data) == "table" then cached_outfits[name] = data end
                end
            end
        end
        if callback then callback(true) end
    end
    local function buildBatchPayload(data)
        local accessories = {}
        local order = 1
        if data.Accessories then
            for _, acc in ipairs(data.Accessories) do
                local isLayered = acc.IsLayered == true
                table.insert(accessories, {
                    AssetId = acc.AssetId,
                    AccessoryType = acc.AccessoryType,
                    IsLayered = isLayered,
                    Rotation = type(acc.Rotation) == "table" and g.lt_encode_v3(Vector3.new(unpack(acc.Rotation))) or "  ",
                    Position = type(acc.Position) == "table" and g.lt_encode_v3(Vector3.new(unpack(acc.Position))) or "  ",
                    Scale = type(acc.Scale) == "table" and g.lt_encode_v3(Vector3.new(unpack(acc.Scale))) or "1 1 1",
                    Order = isLayered and (tonumber(acc.Order) or order) or nil,
                    Puffiness = isLayered and (tonumber(acc.Puffiness) or 0) or nil
                })
                if isLayered then order = order + 1 end
            end
        end
        return {
            accessories = accessories,
            properties = {
                Head = data.Head or 0,
                Torso = data.Torso or 0,
                LeftArm = data.LeftArm or 0,
                RightArm = data.RightArm or 0,
                LeftLeg = data.LeftLeg or 0,
                RightLeg = data.RightLeg or 0,
                Face = data.Face or 0,
                Shirt = data.Shirt or 0,
                Pants = data.Pants or 0,
                GraphicTShirt = data.GraphicTShirt or 0,
                RunAnimation = data.RunAnimation or 0,
                WalkAnimation = data.WalkAnimation or 0,
                JumpAnimation = data.JumpAnimation or 0,
                FallAnimation = data.FallAnimation or 0,
                ClimbAnimation = data.ClimbAnimation or 0,
                IdleAnimation = data.IdleAnimation or 0,
                SwimAnimation = data.SwimAnimation or 0,
                HeightScale = data.HeightScale or 1,
                WidthScale = data.WidthScale or 1,
                DepthScale = 1,
                HeadScale = 1,
                BodyTypeScale = 0,
                ProportionScale = 0,
                HeadColor = ";<,#",
                TorsoColor = ";<,#",
                LeftArmColor = ";<,#",
                RightArmColor = ";<,#",
                LeftLegColor = ";<,#",
                RightLegColor = ";<,#",
            }
        }
    end
    local function promptOutfitName(callback)
        local popup = Instance.new("ScreenGui")
        popup.Name = "OutfitNamePrompt"
        popup.IgnoreGuiInset = true
        popup.ResetOnSpawn = false
        popup.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        popup.Parent = parent_gui
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 130)
        frame.Position = UDim2.new(0.5, -125, 0.5, -65)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.Parent = popup
        Instance.new("UICorner", frame)
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -10, 0, 30)
        title.Position = UDim2.new(0, 5, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = "Enter Outfit Name"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.GothamBold
        title.TextScaled = true
        title.Parent = frame
        local txt = Instance.new("TextBox")
        txt.PlaceholderText = "Outfit Name"
        txt.Size = UDim2.new(1, -20, 0, 35)
        txt.Position = UDim2.new(0, 10, 0, 40)
        txt.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.Font = Enum.Font.Gotham
        txt.TextScaled = true
        txt.ClearTextOnFocus = true
        txt.Text = ""
        txt.Parent = frame
        Instance.new("UICorner", txt)
        local save_btn = Instance.new("TextButton")
        save_btn.Size = UDim2.new(1, -20, 0, 35)
        save_btn.Position = UDim2.new(0, 10, 0, 85)
        save_btn.Text = "Save"
        save_btn.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
        save_btn.TextColor3 = Color3.new(1, 1, 1)
        save_btn.Font = Enum.Font.GothamBold
        save_btn.TextScaled = true
        save_btn.Parent = frame
        Instance.new("UICorner", save_btn)
        save_btn.MouseButton1Click:Connect(function()
            local name = txt.Text:gsub("%s+", "")
            if name ~= "" then
                popup:Destroy()
                task.wait()
                callback(name)
            else
                g.notify("Error", "Enter a valid outfit name.", 5)
            end
        end)
    end
    local function fuzzy_match(name, query)
        local j = 1
        local qlen = #query
        for i = 1, #name do
            if name:sub(i, i) == query:sub(j, j) then
                j = j + 1
                if j > qlen then return true end
            end
        end
        return false
    end
    local function refreshOutfitList()
        local scroller = g.ui_refs.scroller
        if not scroller then g.notify("Warning", "Scroller missing from UI.", 3); return end
        local query = ""
        if g.ui_refs.searchbox then query = string.lower(g.ui_refs.searchbox.Text or "") end
        for _, child in ipairs(scroller:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
        local visible_count = 0
        for name, outfitData in pairs(cached_outfits) do
            local lowered_name = string.lower(name)
            if query ~= "" then
                local exact_match = string.find(lowered_name, query, 1, true)
                local fuzzy_result = fuzzy_match(lowered_name, query)
                if not exact_match and not fuzzy_result then continue end
            end
            visible_count = visible_count + 1
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -5, 0, 35)
            entry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            entry.Parent = scroller
            Instance.new("UICorner", entry)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.35, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = name
            label.TextColor3 = Color3.new(1, 1, 1)
            label.Font = Enum.Font.Gotham
            label.TextScaled = true
            label.Parent = entry
            local wearBtn = Instance.new("TextButton")
            wearBtn.Size = UDim2.new(0.25, -30, 1, -10)
            wearBtn.Position = UDim2.new(0.5, 40, 0, 7)
            wearBtn.Text = "Wear"
            wearBtn.BackgroundColor3 = Color3.fromRGB(249, 232, 0)
            wearBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            wearBtn.Font = Enum.Font.Gotham
            wearBtn.TextScaled = true
            wearBtn.Parent = entry
            Instance.new("UICorner", wearBtn)
            local renameBtn = Instance.new("TextButton")
            renameBtn.Size = UDim2.new(0.25, -30, 1, -8)
            renameBtn.Position = UDim2.new(0, 180, 0, 7)
            renameBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
            renameBtn.TextColor3 = Color3.new(1, 1, 1)
            renameBtn.Font = Enum.Font.SourceSansBold
            renameBtn.TextScaled = true
            renameBtn.Text = "Rename"
            renameBtn.Parent = entry
            Instance.new("UICorner", renameBtn)
            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0.25, -30, 1, -10)
            delBtn.Position = UDim2.new(0, 380, 0.2, 0)
            delBtn.Text = "Delete"
            delBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            delBtn.TextColor3 = Color3.new(1, 1, 1)
            delBtn.Font = Enum.Font.Gotham
            delBtn.TextScaled = true
            delBtn.Parent = entry
            Instance.new("UICorner", delBtn)
            wearBtn.MouseButton1Click:Connect(function()
                if g.is_busy_outfit_manager then g.notify("Warning", "Busy, wait!", 3); return end
                g.is_busy_outfit_manager = true
                local data = outfitData
                if not data or type(data) ~= "table" then
                    g.is_busy_outfit_manager = false
                    g.notify("Error", "Invalid outfit data!", 3)
                    return
                end
                if type(data.Desc) == "table" then
                    local skin = data.SkinTone and Color3.new(data.SkinTone[1], data.SkinTone[2], data.SkinTone[3]) or nil
                    local ok, err = pcall(g.lt_apply_look, {
                        payload = HttpService:JSONDecode(HttpService:JSONEncode(data.Desc)),
                        age = data.Age,
                        skin = skin,
                    })
                    g.is_busy_outfit_manager = false
                    if ok then g.notify("Success", "Outfit applied successfully!", 5) else g.notify("Error", "Couldn't wear outfit: " .. tostring(err), 5) end
                    return
                end
                g.clear_avatar()
                task.wait(1)
                local payload = buildBatchPayload(data)
                for i = 1, math.random(1, 6) do
                    Send("wear_outfit_from_desc", payload)
                    task.wait(0.1)
                end
                task.wait(0.2)
                if data.SkinTone then
                    pcall(function()
                        local c = Color3.new(data.SkinTone[1], data.SkinTone[2], data.SkinTone[3])
                        for i = 1, 3 do Send("skin_tone", c); task.wait(0.1) end
                    end)
                    task.wait(0.3)
                end
                if data.Age then
                    pcall(function()
                        Get("age", tostring(data.Age))
                        task.wait(0.3)
                        Get("age", tostring(data.Age))
                    end)
                    task.wait(0.3)
                end
                task.wait(0.1)
                if data.HeightScale then
                    pcall(function()
                        for i = 1, 3 do Send("body_scale", "HeightScale", data.HeightScale * 100); task.wait(0.15) end
                    end)
                end
                task.wait(0.1)
                if data.WidthScale then
                    pcall(function()
                        for i = 1, 3 do Send("body_scale", "WidthScale", data.WidthScale * 100); task.wait(0.15) end
                    end)
                end
                task.wait(0.2)
                g.is_busy_outfit_manager = false
                g.notify("Success", "Outfit applied successfully!", 5)
            end)
            renameBtn.MouseButton1Click:Connect(function()
                if g.is_busy_outfit_manager then g.notify("Warning", "Busy, wait!", 3); return end
                g.is_busy_outfit_manager = true
                promptOutfitName(function(newName)
                    if not newName or newName == "" then
                        g.is_busy_outfit_manager = false
                        g.notify("Error", "Invalid new name!", 3)
                        return
                    end
                    if cached_outfits[newName] then
                        g.is_busy_outfit_manager = false
                        g.notify("Error", "An outfit with that name already exists!", 3)
                        return
                    end
                    rename_outfit(name, newName, function(success, reason)
                        g.is_busy_outfit_manager = false
                        if success then
                            g.notify("Success", "Outfit renamed to: "..tostring(newName), 3)
                            refreshOutfitList()
                        else
                            g.notify("Error", "Failed to rename: " .. (reason or "unknown error"), 3)
                        end
                    end)
                end)
            end)
            local delete_armed = false
            delBtn.MouseButton1Click:Connect(function()
                if not delete_armed then
                    delete_armed = true
                    g.notify("Warning", "Click again to confirm delete: " .. name, 5)
                    task.delay(5, function() delete_armed = false end)
                else
                    delete_outfit(name, function(success)
                        if success then
                            g.notify("Success", "Deleted outfit: " .. name, 5)
                            refreshOutfitList()
                        else
                            g.notify("Error", "Failed to delete outfit.", 4)
                        end
                    end)
                end
            end)
        end
        if g.ui_refs.noOutfitsLabel then g.ui_refs.noOutfitsLabel.Visible = visible_count == 0 end
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OutfitManagerUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = parent_gui
    g.LoadedOutfit_Manager_GUI = true
    local OutfitManagerFrameMain = Instance.new("Frame")
    OutfitManagerFrameMain.Size = UDim2.new(0, 500, 0, 400)
    OutfitManagerFrameMain.Position = UDim2.new(0.5, -250, 0.5, -200)
    OutfitManagerFrameMain.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    OutfitManagerFrameMain.BorderSizePixel = 0
    OutfitManagerFrameMain.Parent = ScreenGui
    Instance.new("UICorner", OutfitManagerFrameMain)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundTransparency = 1
    Title.Text = "Outfits Manager V2"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextScaled = true
    Title.TextSize = 18
    Title.Parent = OutfitManagerFrameMain
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextScaled = true
    CloseButton.Parent = OutfitManagerFrameMain
    Instance.new("UICorner", CloseButton)
    CloseButton.MouseButton1Click:Connect(function()
        g.is_busy_outfit_manager = false
        ScreenGui:Destroy()
        g.LoadedOutfit_Manager_GUI = false
    end)
    local SaveButton = Instance.new("TextButton")
    SaveButton.Size = UDim2.new(0.5, -5, 0, 35)
    SaveButton.Position = UDim2.new(0, 5, 0, 40)
    SaveButton.Text = "Save Outfit"
    SaveButton.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
    SaveButton.TextColor3 = Color3.new(1, 1, 1)
    SaveButton.Font = Enum.Font.Gotham
    SaveButton.TextScaled = true
    SaveButton.TextSize = 16
    SaveButton.Parent = OutfitManagerFrameMain
    Instance.new("UICorner", SaveButton)
    local RefreshButton = Instance.new("TextButton")
    RefreshButton.Size = UDim2.new(0.5, -5, 0, 35)
    RefreshButton.Position = UDim2.new(0.5, 0, 0, 40)
    RefreshButton.Text = "Refresh"
    RefreshButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    RefreshButton.TextColor3 = Color3.new(1, 1, 1)
    RefreshButton.Font = Enum.Font.Gotham
    RefreshButton.TextScaled = true
    RefreshButton.TextSize = 16
    RefreshButton.Parent = OutfitManagerFrameMain
    Instance.new("UICorner", RefreshButton)
    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -10, 0, 30)
    SearchBox.Position = UDim2.new(0, 5, 0, 75)
    SearchBox.PlaceholderText = "Search outfits..."
    SearchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SearchBox.TextColor3 = Color3.new(1, 1, 1)
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextScaled = true
    SearchBox.ClearTextOnFocus = false
    SearchBox.Text = ""
    SearchBox.Parent = OutfitManagerFrameMain
    Instance.new("UICorner", SearchBox)
    g.ui_refs.searchbox = SearchBox
    g.ui_refs.frame = OutfitManagerFrameMain
    if g.dragify and typeof(g.dragify) == "function" then g.dragify(OutfitManagerFrameMain) end
    SearchBox:GetPropertyChangedSignal("Text"):Connect(refreshOutfitList)
    local scroller = Instance.new("ScrollingFrame")
    scroller.Position = UDim2.new(0, 5, 0, 110)
    scroller.Size = UDim2.new(1, -10, 1, -120)
    scroller.BackgroundTransparency = 1
    scroller.BorderSizePixel = 0
    scroller.ScrollBarThickness = 6
    scroller.ScrollingDirection = Enum.ScrollingDirection.Y
    scroller.Parent = OutfitManagerFrameMain
    g.ui_refs.scroller = scroller
    local noOutfitsLabel = Instance.new("TextLabel")
    noOutfitsLabel.Size = UDim2.new(1, 0, 0, 40)
    noOutfitsLabel.Position = UDim2.new(0, 0, 0, 10)
    noOutfitsLabel.BackgroundTransparency = 1
    noOutfitsLabel.Text = "No saved outfits."
    noOutfitsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    noOutfitsLabel.Font = Enum.Font.Gotham
    noOutfitsLabel.TextScaled = true
    noOutfitsLabel.Visible = false
    noOutfitsLabel.Parent = scroller
    g.ui_refs.noOutfitsLabel = noOutfitsLabel
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.Parent = scroller
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scroller.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10) end)
    if g.ui_refs.noOutfitsLabel then
        local has_visible = false
        for _, child in ipairs(scroller:GetChildren()) do
            if child:IsA("Frame") then
                has_visible = true
                break
            end
        end
        noOutfitsLabel.Visible = not has_visible
    end
    SaveButton.MouseButton1Click:Connect(function()
        if g.is_busy_outfit_manager then g.notify("Warning", "Busy, wait!", 3); return end
        g.is_busy_outfit_manager = true
        promptOutfitName(function(name)
            local char = g.Character or g.LocalPlayer.Character or g.get_char(g.LocalPlayer or Players.LocalPlayer, 3) or g.Char:get()
            if not char or not char:FindFirstChildOfClass("Humanoid") then
                g.is_busy_outfit_manager = false
                g.notify("Error", "Character or Humanoid missing!", 3)
                return
            end
            local humanoid = char and char:FindFirstChildOfClass("Humanoid") or g.get_human(Players:GetPlayerFromCharacter(char), Players.RespawnTime + 1)
            local desc = humanoid and humanoid:GetAppliedDescription()
            if not desc then
                g.is_busy_outfit_manager = false
                g.notify("Error", "Failed to get HumanoidDescription!", 3)
                return
            end
            local outfit = {}
            outfit.Accessories = {}
            for _, info in ipairs(desc:GetAccessories(true)) do
                local p, r, s = info.Position or Vector3.zero, info.Rotation or Vector3.zero, info.Scale or Vector3.one
                table.insert(outfit.Accessories, {
                    AssetId = info.AssetId,
                    AccessoryType = info.AccessoryType.Name,
                    IsLayered = info.IsLayered,
                    Order = info.IsLayered and info.Order or nil,
                    Puffiness = info.IsLayered and info.Puffiness or nil,
                    Position = { p.X, p.Y, p.Z },
                    Rotation = { r.X, r.Y, r.Z },
                    Scale = { s.X, s.Y, s.Z }
                })
            end
            local desc_ok, exact = pcall(g.lt_serialise, desc)
            if desc_ok and type(exact) == "table" then outfit.Desc = exact end
            outfit.Shirt = desc.Shirt
            outfit.Pants = desc.Pants
            outfit.GraphicTShirt = desc.GraphicTShirt
            outfit.Face = desc.Face
            outfit.Head = desc.Head
            outfit.Torso = desc.Torso
            outfit.LeftArm = desc.LeftArm
            outfit.RightArm = desc.RightArm
            outfit.LeftLeg = desc.LeftLeg
            outfit.RightLeg = desc.RightLeg
            outfit.ClimbAnimation = desc.ClimbAnimation
            outfit.FallAnimation = desc.FallAnimation
            outfit.IdleAnimation = desc.IdleAnimation
            outfit.JumpAnimation = desc.JumpAnimation
            outfit.RunAnimation = desc.RunAnimation
            outfit.SwimAnimation = desc.SwimAnimation
            outfit.WalkAnimation = desc.WalkAnimation
            outfit.HeightScale = desc.HeightScale
            outfit.WidthScale = desc.WidthScale
            local hc = desc.HeadColor
            outfit.SkinTone = { hc.R, hc.G, hc.B }
            local age = LocalPlayer:GetAttribute("age")
            if age then outfit.Age = tostring(age) end
            save_outfit(name, outfit, function(success)
                g.is_busy_outfit_manager = false
                if success then
                    g.notify("Success", "Saved outfit: " .. name, 5)
                    refreshOutfitList()
                else
                    g.notify("Error", "Failed to save outfit.", 4)
                end
            end)
        end)
    end)
    RefreshButton.MouseButton1Click:Connect(function()
        fetch_outfit_list(function(success)
            if success then
                refreshOutfitList()
                g.notify("Success", "Outfits refreshed!", 3)
            else
                g.notify("Error", "Failed to fetch outfits.", 4)
            end
        end)
    end)
    fetch_outfit_list(function(success)
        if not success then
            g.notify("Error", "Could not load outfits.", 3)
            return
        end
        refreshOutfitList()
    end)
end
g.already_loaded_workaround_script_flames_hub = g.already_loaded_workaround_script_flames_hub or false
g.already_patched_discord_button = g.already_patched_discord_button or false
g.load_workaround_script = g.load_workaround_script or function()
	if g.already_loaded_workaround_script_flames_hub then g.notify("Warning", "Chat Workaround has already been loaded.", 5); return end
	local hidden_gui_main = gethui and gethui() or get_hidden_gui and get_hidden_gui() or g.CoreGui or g.PlayerGui
	g.already_loaded_workaround_script_flames_hub = true
	loadstring(g.http_get('https://raw.githubusercontent.com/EnterpriseExperience/MicUpSource/refs/heads/main/Deadly_Chat_Backup_Script.lua'))()
    local function patch_button(frame)
        if g.already_patched_discord_button then return end
        for _, desc in ipairs(frame:GetDescendants()) do
            if desc:IsA("ImageButton") and desc.Name == "Discord" and desc.Image == "rbxassetid://7552532178" then
                g.already_patched_discord_button = true
                lib.disconnect("discord_button_activated")
                lib.connect("discord_button_activated", desc.Activated:Connect(function()
                    if http_requesting and typeof(http_requesting) then
                        http_requesting({
                            Url = 'http://127.0.0.1:6463/rpc?v=1',
                            Method = 'POST',
                            Headers = {
                                ['Content-Type'] = 'application/json',
                                Origin = 'https://discord.com'
                            },
                            Body = HttpService:JSONEncode({
                                cmd = 'INVITE_BROWSER',
                                nonce = HttpService:GenerateGUID(false),
                                args = {code = 'MTYKxQfpNJ'}
                            })
                        })
                    else
                        if g.AllClipboards and typeof(g.AllClipboards) == "function" then g.AllClipboards("https://discord.gg/MTYKxQfpNJ") end
                        if g.notify and typeof(g.notify) == "function" then g.notify("Success", "Successfully copied Discord link to Clipboard.", 3) end
                    end
                end))
                break
            end
        end
    end
	local function find_chat_frame()
		for _, gui in ipairs(hidden_gui_main:GetChildren()) do
			if gui:IsA("ScreenGui") then
				local frame = gui:FindFirstChild("Chat System")
				if frame and frame:IsA("Frame") then
                    frame.Draggable = true
                    frame.Position = UDim2.new(0.00741000008, 498, 0.0585100017, -8)
                    if g.dragify and typeof(g.dragify) == "function" then g.dragify(frame) end
					return frame
				end
			end
		end
		return nil
	end
	local chat_frame = find_chat_frame()
	if chat_frame and chat_frame:IsA("Frame") then
		patch_button(chat_frame)
	else
		local conn
		conn = lib.connect(hidden_gui_main, "ChildAdded", function(child)
			if child and child:IsA("ScreenGui") then
				local frame = child:FindFirstChild("Chat System")
				if frame and frame:IsA("Frame") then
					lib.disconnect(conn)
					patch_button(frame)
					return
				end
				lib.connect(child, "ChildAdded", function(grandchild)
					if grandchild.Name == "Chat System" and grandchild:IsA("Frame") then
						lib.disconnect(conn)
						patch_button(grandchild)
					end
				end)
			end
		end)
	end
end
g.Get_WildWood_Mansion = function()
    local cache = g.WildWood_Integration_Mansion_Found
    if cache and cache:IsA("Folder") and cache.Parent then return cache end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Folder") and v.Name:lower():find("pittock") and v.Name:lower():find("mansion") then
            g.WildWood_Integration_Mansion_Found = v
            return v
        end
    end
    return nil
end
task.wait()
if not g.WildWood_Integration_Mansion_Found then pcall(function() g.Get_WildWood_Mansion() end) end
g.Get_Activation_WildWood_Portal = function()
    local cache = g.WildwoodPortal_Found_Main
    if cache and cache:IsA("Model") and cache.Parent then return cache end
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("wildwood") and v.Name:lower():find("portal") then
            local attr = v:GetAttribute("portal_color")
            if attr ~= nil and attr == Color3.fromRGB(151, 126, 91) then
                g.WildwoodPortal_Found_Main = v
                return v
            end
        end
    end
    return nil
end
task.wait()
if not g.WildwoodPortal_Found_Main then pcall(function() g.Get_Activation_WildWood_Portal() end) end
g.Find_Paper_To_Collect = function()
    local get_mansion = g.WildWood_Integration_Mansion_Found or g.Get_WildWood_Mansion()
    if not get_mansion or not get_mansion:IsA("Folder") then return end
    for _, v in ipairs(get_mansion:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("pig") and v.Name:lower():find("paper") and v.Parent.Name:lower():find("paper") then
            return v
        end
    end
    return nil
end
g.Automatically_Complete_WildWood_Event = function()
    local hrp = g.HumanoidRootPart or g.get_root(speaker)
    if not hrp or not hrp.Parent or not hrp:IsDescendantOf(game) then g.notify("Error", "Your HumanoidRootPart is missing! (please reset).", 3); return end
    local get_current_zone = g.LocalPlayer:GetAttribute("current_quest_zone")
    if get_current_zone ~= nil and get_current_zone ~= "pittock_mansion_lobby" then
        pcall(function() hrp.CFrame = CFrame.new(-27.607975, 9.29240894, -37.3550339) end)
        wait(0.1)
        local wild_wood_start_convo = {
            "wildwood_track",
            "npc_convo_started",
            {
                quest_id = "none",
                npc_id = "prue",
                dialogue_variant = "default",
                first_time = false
            }
        }
        g.Send(unpack(wild_wood_start_convo))
        wait(0.15)
        g.Send("spoke_to_prue")
        wait(0.15)
        local convo_ended_main = {
            "wildwood_track",
            "npc_convo_ended",
            {
                completed = true,
                duration_s = 103.52,
                lines_shown = 1,
                npc_id = "prue",
                lines_total = 1
            }
        }
        g.Send(unpack(convo_ended_main))
        wait(0.1)
        g.Send("viewed_mac_abduction")
        wait(0.1)
        g.Send("teleport_to_quest", -1)
        pcall(function() hrp.CFrame = CFrame.new(-0.998277366, 8.96803665, -164.726166) end)
        wait(0.15)
        local portal = g.WildwoodPortal_Found_Main or g.Get_Activation_WildWood_Portal()
        if portal and portal:IsA("Model") and portal:IsDescendantOf(game) then pcall(function() g.Character:PivotTo(portal:GetPivot() + Vector3.new(0, 3, 0)) end) end
        g.notify("Error", "Please start the quest or go to the Pittock Mansion!")
    end
    g.Send("set_wildwood_faction", 3)
    wait(0.1)
    g.Send("start_quest", 1)
    wait(0.1)
    g.Send("teleport_to_quest", 1)
    wait(0.1)
    g.Send("wildwood_track", "npc_convo_started", {
        quest_id = "q1_pittock_mansion",
        npc_id = "pig_clerk",
        dialogue_variant = "default",
        first_time = true
    })
    wait(0.35)
    g.Send("wildwood_track", "npc_convo_ended", {
        completed = true,
        duration_s = 30.23,
        lines_shown = 3,
        npc_id = "pig_clerk",
        lines_total = 3
    })
    wait(0.15)
    g.Send("progress_quest", 1, "meet_pig_clerk")
    wait(0.1)
    local paper = g.Find_Paper_To_Collect()
    if not paper or not paper:IsA("Model") then g.notify("Error", "There appears to be no papers left to collect!", 3); return end
    local pivot_offset = Vector3.new(0, 3, 0)
    local function fire_prompts()
        for _, descendant in ipairs(paper:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                pcall(function()
                    fireproximityprompt(descendant)
                end)
            end
        end
    end
    for _ = 1, 10 do
        pcall(function() g.Character:PivotTo(paper:GetPivot() + pivot_offset) end)
        wait(0.25)
        fire_prompts()
        wait(0.1)
        g.Get("collect_wildwood_item", paper)
        wait(0.35)
    end
end
g.vehicle_fly = g.vehicle_fly or false
g.vehicle_fly_speed = g.vehicle_fly_speed or 3
g.vehiclefly_conns = g.vehiclefly_conns or {}
g.vehiclefly_control = {f=0,b=0,l=0,r=0,q=0,e=0}
g.vehiclefly_noclip = g.vehiclefly_noclip or false
g.vehiclefly_collisions = g.vehiclefly_collisions or {}
local controlModule
if UserInputService.TouchEnabled then controlModule = g.safe_require(g.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule")) end
g.cleanup = g.cleanup or function()
    for _, c in pairs(g.vehiclefly_conns) do
        pcall(function() c:Disconnect() end)
    end
    g.vehiclefly_conns = {}
    if g.vehiclefly_bv then
        g.vehiclefly_bv.Velocity = Vector3.zero
        g.vehiclefly_bv:Destroy()
        g.vehiclefly_bv = nil
    end
    if g.vehiclefly_bg then
        g.vehiclefly_bg:Destroy()
        g.vehiclefly_bg = nil
    end
end
g.enable_vehicle_noclip = g.enable_vehicle_noclip or function()
    if g.vehiclefly_noclip then return end
    g.vehiclefly_noclip = true
    g.vehiclefly_collisions = {}
    local car = g.get_vehicle()
    if not car then return end
    if g.ToggleNoclip and typeof(g.ToggleNoclip) == "function" then g.ToggleNoclip(true) end
    for _, v in ipairs(car:GetDescendants()) do
        if v:IsA("BasePart") then
            g.vehiclefly_collisions[v] = v.CanCollide
            v.CanCollide = false
        end
    end
end
g.disable_vehicle_noclip = g.disable_vehicle_noclip or function()
    if not g.vehiclefly_noclip then return end
    g.vehiclefly_noclip = false
    if g.ToggleNoclip and typeof(g.ToggleNoclip) == "function" then g.ToggleNoclip(false) end
    for part, state in pairs(g.vehiclefly_collisions) do if part and part.Parent then part.CanCollide = state end end
    g.vehiclefly_collisions = {}
end
g.start_vehicle_fly = g.start_vehicle_fly or function()
    if g.vehiclefly_bg or g.vehiclefly_bv then return end
    local car = g.get_vehicle()
    if not car then
        g.disable_vehicle_noclip()
        task.wait()
        g.cleanup()
        pcall(function() g.notify("Error", "You do not have a Vehicle spawned.", 3) end)
        return
    end
    local base = car.Base or car:FindFirstChild("Base")
    local bg = Instance.new("BodyGyro")
    bg.P = 3e4
    bg.D = 1e3
    bg.MaxTorque = Vector3.new(0, 9e9, 0)
    bg.CFrame = base.CFrame
    bg.Parent = base
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    bv.Parent = base
    g.vehiclefly_bg = bg
    g.vehiclefly_bv = bv
    g.vehiclefly_conns.render = RunService.Heartbeat:Connect(function()
        if not g.vehicle_fly or not base.Parent then
            bv.Velocity = Vector3.zero
            g.vehiclefly_control = {f=0,b=0,l=0,r=0,q=0,e=0}
            if not base.Parent then
                if g.main_vehicle_fly_UI_toggle then g.main_vehicle_fly_UI_toggle:Set(false, false) end
                if g.stop_vehicle_fly then
                    g.stop_vehicle_fly()
                else
                    g.cleanup()
                end
            end
            return
        end
        base.AssemblyAngularVelocity = Vector3.zero
        local cam = workspace.CurrentCamera
        if IsMobile then
            bg.CFrame = cam.CFrame
            local mv = controlModule:GetMoveVector()
            local vel = Vector3.zero
            if mv.X ~= 0 then vel = vel + cam.CFrame.RightVector * (mv.X * (45 * g.vehicle_fly_speed)) end
            if mv.Z ~= 0 then vel = vel - cam.CFrame.LookVector * (mv.Z * (45 * g.vehicle_fly_speed)) end
            bv.Velocity = vel
        else
            local look = cam.CFrame.LookVector
            local yaw = math.atan2(-look.X, -look.Z)
            bg.CFrame = CFrame.new(base.Position) * CFrame.Angles(0, yaw, 0)
            local c = g.vehiclefly_control
            local forward = (c.f or 0) + (c.b or 0)
            local right = (c.l or 0) + (c.r or 0)
            local up = (c.q or 0) + (c.e or 0)
            bv.Velocity = (cam.CFrame.LookVector * forward + cam.CFrame.RightVector * right + Vector3.new(0, up, 0)) * (45 * g.vehicle_fly_speed)
        end
    end)
    if not IsMobile then
        g.vehiclefly_conns.down = UserInputService.InputBegan:Connect(function(i, game_processed)
            if game_processed then return end
            if i.KeyCode == Enum.KeyCode.W then g.vehiclefly_control.f = 1  end
            if i.KeyCode == Enum.KeyCode.S then g.vehiclefly_control.b = -1 end
            if i.KeyCode == Enum.KeyCode.A then g.vehiclefly_control.l = -1 end
            if i.KeyCode == Enum.KeyCode.D then g.vehiclefly_control.r = 1  end
            if i.KeyCode == Enum.KeyCode.E then g.vehiclefly_control.q = 1  end
            if i.KeyCode == Enum.KeyCode.Q then g.vehiclefly_control.e = -1 end
        end)
        g.vehiclefly_conns.up = UserInputService.InputEnded:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.W then g.vehiclefly_control.f = 0 end
            if i.KeyCode == Enum.KeyCode.S then g.vehiclefly_control.b = 0 end
            if i.KeyCode == Enum.KeyCode.A then g.vehiclefly_control.l = 0 end
            if i.KeyCode == Enum.KeyCode.D then g.vehiclefly_control.r = 0 end
            if i.KeyCode == Enum.KeyCode.E then g.vehiclefly_control.q = 0 end
            if i.KeyCode == Enum.KeyCode.Q then g.vehiclefly_control.e = 0 end
        end)
    end
end
g.stop_vehicle_fly = g.stop_vehicle_fly or function()
    g.vehicle_fly = false
    g.disable_vehicle_noclip()
    g.cleanup()
    g.vehiclefly_control = {f=0,b=0,l=0,r=0,q=0,e=0}
end
g.toggle_vehicle_fly = g.toggle_vehicle_fly or function()
    if g.vehicle_fly then
        g.stop_vehicle_fly()
    else
        g.vehicle_fly = true
        g.enable_vehicle_noclip()
        g.start_vehicle_fly()
    end
end
g.owner_in_game = g.owner_in_game or function(user)
    local target = tostring(user):lower()
    for _, v in ipairs(Players:GetPlayers()) do
        if v.Name:lower() == target then
            return true
        end
    end
    return false
end
g.streamer_mode_script = g.streamer_mode_script or function()
    if g.hidden_loaded then g.notify("Warning", "Streamer Mode script is already loaded.", 3); return end
    loadstring(g.http_get("https://pastebin.com/raw/kVYwGVcy"))()
end
g.unload_streamer_mode_script = g.unload_streamer_mode_script or function()
    if g.hidden_settings then
        local h = g.hidden_settings
        if h.Enabled then h.Enabled = false end
        for _, c in pairs(h.conns) do
            pcall(function()
                c:Disconnect()
                c = nil
            end)
        end
        h.conns = {}
    end
    if g.hidden_person then
        for _, c in pairs(g.hidden_person.conns or {}) do
            pcall(function()
                c:Disconnect()
                c = nil
            end)
        end
        g.hidden_person.conns = {}
    end
    g.hidden_loaded = false
    g.hidden_settings = {enabled = false, conns = {}}
    g.hidden_person = {conns = {}}
    for _, v in ipairs(parent_gui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:lower():find("streamermode") then
            v:Destroy()
        end
    end
    for _, v in ipairs(CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:lower():find("streamermode") then
            v:Destroy()
        end
    end
end
g.Pick_Vehicle_Color_Func = g.Pick_Vehicle_Color_Func or function(input)
    if not input then return end
    local str = tostring(input):lower():match("^%s*(.-)%s*$")
    local chosen
    local r, g, b = str:match("(%d+)[,%s]+(%d+)[,%s]+(%d+)")
    if r and g and b then chosen = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b)) end
    if not chosen then
        local hex = str:match("^#?(%x%x%x%x%x%x)$")
        if hex then
            chosen = Color3.fromRGB(
                tonumber(hex:sub(1,2), 16),
                tonumber(hex:sub(3,4), 16),
                tonumber(hex:sub(5,6), 16)
            )
        end
    end
    if not chosen then
        local color_mapper = {
            red = Color3.fromRGB(255,0,0),
            darkred = Color3.fromRGB(139,0,0),
            crimson = Color3.fromRGB(220,20,60),
            firebrick = Color3.fromRGB(178,34,34),
            indianred = Color3.fromRGB(205,92,92),
            lightcoral = Color3.fromRGB(240,128,128),
            salmon = Color3.fromRGB(250,128,114),
            darksalmon = Color3.fromRGB(233,150,122),
            lightsalmon = Color3.fromRGB(255,160,122),
            tomato = Color3.fromRGB(255,99,71),
            orangered = Color3.fromRGB(255,69,0),
            orange = Color3.fromRGB(255,165,0),
            darkorange = Color3.fromRGB(255,140,0),
            coral = Color3.fromRGB(255,127,80),
            yellow = Color3.fromRGB(255,255,0),
            lightyellow = Color3.fromRGB(255,255,224),
            gold = Color3.fromRGB(255,215,0),
            goldenrod = Color3.fromRGB(218,165,32),
            darkgoldenrod = Color3.fromRGB(184,134,11),
            palegoldenrod = Color3.fromRGB(238,232,170),
            khaki = Color3.fromRGB(240,230,140),
            darkkhaki = Color3.fromRGB(189,183,107),
            lemonchiffon = Color3.fromRGB(255,250,205),
            green = Color3.fromRGB(0,128,0),
            lime = Color3.fromRGB(0,255,0),
            limegreen = Color3.fromRGB(50,205,50),
            forestgreen = Color3.fromRGB(34,139,34),
            darkgreen = Color3.fromRGB(0,100,0),
            seagreen = Color3.fromRGB(46,139,87),
            mediumseagreen = Color3.fromRGB(60,179,113),
            lightseagreen = Color3.fromRGB(32,178,170),
            springgreen = Color3.fromRGB(0,255,127),
            mediumspringgreen = Color3.fromRGB(0,250,154),
            palegreen = Color3.fromRGB(152,251,152),
            lightgreen = Color3.fromRGB(144,238,144),
            olivedrab = Color3.fromRGB(107,142,35),
            darkolivegreen = Color3.fromRGB(85,107,47),
            olive = Color3.fromRGB(128,128,0),
            chartreuse = Color3.fromRGB(127,255,0),
            lawngreen = Color3.fromRGB(124,252,0),
            greenyellow = Color3.fromRGB(173,255,47),
            yellowgreen = Color3.fromRGB(154,205,50),
            blue = Color3.fromRGB(0,0,255),
            navy = Color3.fromRGB(0,0,128),
            darkblue = Color3.fromRGB(0,0,139),
            mediumblue = Color3.fromRGB(0,0,205),
            royalblue = Color3.fromRGB(65,105,225),
            steelblue = Color3.fromRGB(70,130,180),
            lightsteelblue = Color3.fromRGB(176,196,222),
            dodgerblue = Color3.fromRGB(30,144,255),
            deepskyblue = Color3.fromRGB(0,191,255),
            skyblue = Color3.fromRGB(135,206,235),
            lightskyblue = Color3.fromRGB(135,206,250),
            cornflowerblue = Color3.fromRGB(100,149,237),
            cadetblue = Color3.fromRGB(95,158,160),
            midnightblue = Color3.fromRGB(25,25,112),
            slateblue = Color3.fromRGB(106,90,205),
            mediumslateblue = Color3.fromRGB(123,104,238),
            darkslateblue = Color3.fromRGB(72,61,139),
            powderblue = Color3.fromRGB(176,224,230),
            lightblue = Color3.fromRGB(173,216,230),
            purple = Color3.fromRGB(128,0,128),
            darkpurple = Color3.fromRGB(75,0,100),
            rebeccapurple = Color3.fromRGB(102,51,153),
            indigo = Color3.fromRGB(75,0,130),
            violet = Color3.fromRGB(238,130,238),
            darkviolet = Color3.fromRGB(148,0,211),
            blueviolet = Color3.fromRGB(138,43,226),
            mediumpurple = Color3.fromRGB(147,112,219),
            mediumorchid = Color3.fromRGB(186,85,211),
            darkorchid = Color3.fromRGB(153,50,204),
            orchid = Color3.fromRGB(218,112,214),
            plum = Color3.fromRGB(221,160,221),
            thistle = Color3.fromRGB(216,191,216),
            lavender = Color3.fromRGB(230,230,250),
            magenta = Color3.fromRGB(255,0,255),
            fuchsia = Color3.fromRGB(255,0,255),
            darkmagenta = Color3.fromRGB(139,0,139),
            pink = Color3.fromRGB(255,192,203),
            lightpink = Color3.fromRGB(255,182,193),
            hotpink = Color3.fromRGB(255,105,180),
            deeppink = Color3.fromRGB(255,20,147),
            mediumvioletred = Color3.fromRGB(199,21,133),
            palevioletred = Color3.fromRGB(219,112,147),
            cyan = Color3.fromRGB(0,255,255),
            aqua = Color3.fromRGB(0,255,255),
            teal = Color3.fromRGB(0,128,128),
            darkcyan = Color3.fromRGB(0,139,139),
            darkturquoise = Color3.fromRGB(0,206,209),
            mediumturquoise = Color3.fromRGB(72,209,204),
            turquoise = Color3.fromRGB(64,224,208),
            paleturquoise = Color3.fromRGB(175,238,238),
            aquamarine = Color3.fromRGB(127,255,212),
            mediumaquamarine = Color3.fromRGB(102,205,170),
            brown = Color3.fromRGB(165,42,42),
            darkbrown = Color3.fromRGB(101,67,33),
            saddlebrown = Color3.fromRGB(139,69,19),
            sienna = Color3.fromRGB(160,82,45),
            chocolate = Color3.fromRGB(210,105,30),
            peru = Color3.fromRGB(205,133,63),
            tan = Color3.fromRGB(210,180,140),
            burlywood = Color3.fromRGB(222,184,135),
            wheat = Color3.fromRGB(245,222,179),
            sandybrown = Color3.fromRGB(244,164,96),
            rosybrown = Color3.fromRGB(188,143,143),
            maroon = Color3.fromRGB(128,0,0),
            white = Color3.fromRGB(255,255,255),
            black = Color3.fromRGB(0,0,0),
            gray = Color3.fromRGB(128,128,128),
            grey = Color3.fromRGB(128,128,128),
            lightgray = Color3.fromRGB(211,211,211),
            lightgrey = Color3.fromRGB(211,211,211),
            darkgray = Color3.fromRGB(169,169,169),
            darkgrey = Color3.fromRGB(169,169,169),
            silver = Color3.fromRGB(192,192,192),
            dimgray = Color3.fromRGB(105,105,105),
            dimgrey = Color3.fromRGB(105,105,105),
            slategray = Color3.fromRGB(112,128,144),
            slategrey = Color3.fromRGB(112,128,144),
            lightslategray = Color3.fromRGB(119,136,153),
            lightslategrey = Color3.fromRGB(119,136,153),
            darkslategray = Color3.fromRGB(47,79,79),
            darkslategrey = Color3.fromRGB(47,79,79),
            gainsboro = Color3.fromRGB(220,220,220),
            whitesmoke = Color3.fromRGB(245,245,245),
            beige = Color3.fromRGB(245,245,220),
            ivory = Color3.fromRGB(255,255,240),
            snow = Color3.fromRGB(255,250,250),
            honeydew = Color3.fromRGB(240,255,240),
            mintcream = Color3.fromRGB(245,255,250),
            azure = Color3.fromRGB(240,255,255),
            aliceblue = Color3.fromRGB(240,248,255),
            ghostwhite = Color3.fromRGB(248,248,255),
            linen = Color3.fromRGB(250,240,230),
            antiquewhite = Color3.fromRGB(250,235,215),
            bisque = Color3.fromRGB(255,228,196),
            moccasin = Color3.fromRGB(255,228,181),
            peachpuff = Color3.fromRGB(255,218,185),
            mistyrose = Color3.fromRGB(255,228,225),
            lavenderblush = Color3.fromRGB(255,240,245),
            seashell = Color3.fromRGB(255,245,238),
            oldlace = Color3.fromRGB(253,245,230),
            floralwhite = Color3.fromRGB(255,250,240),
            cornsilk = Color3.fromRGB(255,248,220),
            blanchedalmond = Color3.fromRGB(255,235,205),
            navajowhite = Color3.fromRGB(255,222,173),
            papayawhip = Color3.fromRGB(255,239,213),
        }
        local normalized = str:gsub("%s+", "")
        chosen = color_mapper[normalized] or color_mapper[str]
    end
    if not chosen then g.notify("Error", "Invalid color: "..tostring(input), 3); return end
    g.change_vehicle_color(chosen, g.get_vehicle())
end
g.RGB_Vehicle = g.RGB_Vehicle or function(state)
    if state == true then
        if g.Rainbow_Vehicle then g.notify("Warning", "Flames Hub | Rainbow Vehicle is already enabled.", 5); return end
        g.Rainbow_Vehicle = true
        g.notify("Success", "Flames Hub | Rainbow Vehicle is now enabled.", 5)
        lib.spawn("rgb_vehicle", "spawn", function()
            while g.Rainbow_Vehicle == true do
                for _, color in ipairs(g.colors) do
                    g.change_vehicle_color(color, g.get_vehicle())
                    fw(0)
                end
                RunService.Heartbeat:Wait()
            end
        end)
    elseif state == false then
        if not g.Rainbow_Vehicle then
            if g.notify and typeof(g.notify) == "function" then g.notify("Warning", "Flames Hub | Rainbow Vehicle is not enabled.", 5) end
            return
        end
        g.Rainbow_Vehicle = false
        lib.disconnect("rgb_vehicle")
        g.notify("Success", "Flames Hub | Rainbow Vehicle is now disabled.", 5)
    else
        return
    end
end
g.two_color_switcher_FE_func = g.two_color_switcher_FE_func or function(state)
    local lib = g.FlamesLibrary
    if state == true then
        if g.two_tone_vehicle_colors_changing then g.notify("Warning", "Two Color Switcher already enabled.", 5); return end
        g.two_tone_vehicle_colors_changing = true
        local c1 = g.colors[math.random(1,#g.colors)]
        local c2 = g.colors[math.random(1,#g.colors)]
        while c1 == c2 do c2 = g.colors[math.random(1,#g.colors)] end
        g.notify("Success", "Flames Hub | Two Tone Vehicle is now enabled.", 5)
        lib.spawn("two_color_vehicle","spawn",function()
            while g.two_tone_vehicle_colors_changing == true do
                fw(0.1)
                g.change_vehicle_color(c1, g.get_vehicle())
                wait(.1)
                g.change_vehicle_color(c2, g.get_vehicle())
                wait(.1)
                RunService.Heartbeat:Wait()
            end
        end)
    elseif state == false then
        if not g.two_tone_vehicle_colors_changing then g.notify("Warning", "Two Color Switcher not enabled.", 5); return end
        g.two_tone_vehicle_colors_changing = false
        lib.disconnect("two_color_vehicle")
        g.notify("Success", "Flames Hub | Two Tone Vehicle is now disabled.", 5)
    end
end
g.find_vehicles_folder_Life_Together_RP = g.find_vehicles_folder_Life_Together_RP or function()
    local cached = g.vehicles_folder_instance_Life_Together_RP
    if cached and cached.Parent and cached:IsA("Folder") then return cached end
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:lower():find("vehicles") then
            g.vehicles_folder_instance_Life_Together_RP = v
            return v
        end
    end
    return nil
end
if not g.vehicles_folder_instance_Life_Together_RP then pcall(function() g.find_vehicles_folder_Life_Together_RP() end) end
local function init_vehicle_esp()
    g.vehicle_esp_highlights = g.vehicle_esp_highlights or {}
    g.vehicle_esp_connections = g.vehicle_esp_connections or {}
    local highlights = g.vehicle_esp_highlights
    local connections = g.vehicle_esp_connections
    local vehiclesFolder = g.vehicles_folder_instance_Life_Together_RP or workspace:FindFirstChild("Vehicles")
    local function clearESP(model)
        local hl = highlights[model]
        if hl then
            pcall(function()
                hl:Destroy()
            end)
            highlights[model] = nil
        end
        local conn = connections[model]
        if conn then
            pcall(function()
                conn:Disconnect()
            end)
            connections[model] = nil
        end
    end
    local function applyESP(model)
        if not model or not model:IsA("Model") then return end
        if highlights[model] then return end
        local hl = Instance.new("Highlight")
        hl.Adornee = model
        hl.FillTransparency = 0.6
        hl.OutlineTransparency = 0
        hl.Parent = model
        highlights[model] = hl
        connections[model] = model.AncestryChanged:Connect(function(_, parent)
            if not parent then
                clearESP(model)
            end
        end)
    end
    g.vehicle_esp_toggle = g.vehicle_esp_toggle or function(toggled)
        if not vehiclesFolder then return end
        if toggled == true then
            if g.vehicle_esp_is_enabled then g.notify("Warning", "Vehicle ESP is already enabled.", 5); return end
            g.vehicle_esp_is_enabled = true
            for _, v in ipairs(vehiclesFolder:GetChildren()) do applyESP(v) end
            if g.vehicle_esp_folderAdded then
                g.vehicle_esp_folderAdded:Disconnect()
                g.vehicle_esp_folderAdded = nil
            end
            if g.vehicle_esp_folderRemoved then
                g.vehicle_esp_folderRemoved:Disconnect()
                g.vehicle_esp_folderRemoved = nil
            end
            g.vehicle_esp_folderAdded = vehiclesFolder.ChildAdded:Connect(function(child) applyESP(child) end)
            g.vehicle_esp_folderRemoved = vehiclesFolder.ChildRemoved:Connect(function(child) clearESP(child) end)
        elseif toggled == false then
            if not g.vehicle_esp_is_enabled then g.notify("Warning", "Vehicle ESP is not enabled.", 5); return end
            g.vehicle_esp_is_enabled = false
            for model in pairs(highlights) do clearESP(model) end
            if g.vehicle_esp_folderAdded then
                pcall(function()  g.vehicle_esp_folderAdded:Disconnect() end)
                g.vehicle_esp_folderAdded = nil
            end
            if g.vehicle_esp_folderRemoved then
                pcall(function() g.vehicle_esp_folderRemoved:Disconnect() end)
                g.vehicle_esp_folderRemoved = nil
            end
        end
    end
end
task.wait()
init_vehicle_esp()
g.RGB_Vehicle_Others = g.RGB_Vehicle_Others or function(Player, state)
    local lib = g.FlamesLibrary
    if not Player then return end
    local name = "rgb_other_"..Player.UserId
    local PlayersName = Player.Name
    if state == true then
        if lib.is_alive(name) then g.notify("Warning", "RGB Vehicle is already enabled for: "..tostring(PlayersName), 5); return end
        g.notify("Success", "Enabled Rainbow Vehicle for: "..tostring(PlayersName), 5)
        lib.spawn(name,"spawn", function()
            while true do
                if not Player or not Player.Parent then
                    lib.disconnect(name)
                    g.notify("Error", PlayersName.." has left the game.", 5)
                    return
                end
                local vehicle = g.get_other_vehicle(Player)
                if not vehicle then wait(.2) end
                if vehicle:GetAttribute("locked") == true then lib.disconnect(name); return end
                for _, color in ipairs(g.colors) do g.change_vehicle_color(color, Player); wait(.2) end
            end
        end)
    elseif state == false then
        if not lib.is_alive(name) then return end
        lib.disconnect(name)
    end
end
g.copy_emote_plr = g.copy_emote_plr or function(player)
    local targetChar = player.Character or g.get_char(player)
    local targetHum = targetChar and targetChar:FindFirstChildWhichIsA("Humanoid") or g.get_human(player, Players.RespawnTime + 1)
    local myChar = g.Character or g.LocalPlayer.Character or g.get_char(LocalPlayer, Players.RespawnTime + 1)
    local myHum = g.Humanoid or myChar and myChar:FindFirstChildWhichIsA("Humanoid") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
    if not (targetHum and myHum) then return end
    for _, track in ipairs(myHum:GetPlayingAnimationTracks()) do pcall(function() track:Stop() end) end
    wait(0.05)
    for _, tTrack in ipairs(targetHum:GetPlayingAnimationTracks()) do
        local animObj = tTrack.Animation
        if animObj and animObj:IsA("Animation") then
            local id = tostring(animObj.AnimationId)
            if id and id ~= "" and id ~= "0" and not id:find("507768375") then
                local newAnim = Instance.new("Animation")
                newAnim.AnimationId = id
                local myTrack = nil
                pcall(function() myTrack = myHum:LoadAnimation(newAnim) end)
                if myTrack and myTrack:IsA("Animation") then
                    myTrack:Play(0.1, 1, tTrack.Speed)
                    myTrack.TimePosition = tTrack.TimePosition
                    g.TrackHasBeenStopped_Watcher_Task = g.TrackHasBeenStopped_Watcher_Task or task.spawn(function()
                        tTrack.Stopped:Wait()
                        pcall(function() myTrack:Stop() end)
                        pcall(function() myTrack:Destroy() end)
                        pcall(function() newAnim:Destroy() end)
                    end)
                else
                    newAnim:Destroy()
                end
            end
        end
    end
end
g.get_emote_properties_and_insert_properties = g.get_emote_properties_and_insert_properties or function()
    local hum = g.Humanoid or g.Character and g.Character:FindFirstChildWhichIsA("Humanoid") or g.get_human(LocalPlayer, Players.RespawnTime + 1)
    if not hum then return end
    local tracks = hum:GetPlayingAnimationTracks()
    if #tracks == 0 then g.notify("Error", "You're not playing an Animation.", 5); return end
    local track = tracks[1]
    local anim = track.Animation
    if not anim then g.notify("Error", "Your animation unexpectedly disappeared?", 5); return end
    local animId = tostring(anim.AnimationId)
    local realId = tonumber(animId:match("%d+"))
    if not realId then return end
    table.insert(g.currently_saved_emotes_list, {
        Id = realId,
        AssetId = realId,
        Name = track.Name ~= "" and track.Name or "Unknown",
        AnimationId = "rbxassetid://" .. realId,
        Favorite = false
    })
end
g.save_copied_plrs_emote = g.save_copied_plrs_emote or function()
    if g.currently_saved_emotes_list and g.saveEmotesToData then
        g.notify("Info", "Saving currently playing emote, please wait.", 2.5)
        g.get_emote_properties_and_insert_properties()
        fw(0.1)
        g.saveEmotesToData()
        wait()
        g.notify("Success", "Saved currently playing emote.", 3)
    else
        if g.FreeEmotes_Enabled then g.notify("Warning", "You already have Flames Emoting GUI loaded!", 5); return end
        if CoreGui:FindFirstChild("FlamesEmoteGUI") then g.notify("Warning", "You already have Flames Emoting GUI loaded!", 5); return end
        g.FreeEmotes_Enabled = true
        loadstring(g.http_get("https://pastebin.com/raw/RCj6RJtc"))()
        wait(1)
        g.notify("Info", "Try the command again, you did not have our Free Emotes GUI loaded.", 15)
        wait(1)
        while not CoreGui:FindFirstChild("FlamesEmoteGUI", true) do task.wait(0.1) end
        local gui = CoreGui:FindFirstChild("FlamesEmoteGUI", true)
        if gui and gui:IsA("ScreenGui") then
            local Frame_Find = gui:FindFirstChildOfClass("Frame")
            if Frame_Find and Frame_Find.Parent then Frame_Find.Visible = false end
        end
    end
end
g.mutesounds = g.mutesounds or function()
    for _,v in ipairs(Placed_Models:GetDescendants()) do
        if v:IsA("Sound") then
            local n = v.Name
            if n == "SoundDefault" or n == "Music" or n == "Airhorn" then
                v.Volume = 0
            elseif n == "Sound" and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == "BoomBox" then
                v.Volume = 0
            end
        end
    end
    for _,p in ipairs(g.Players:GetPlayers()) do
        local c = p.Character or g.get_char(p, Players.RespawnTime + 0.5)
        if c and c:IsDescendantOf(game) then
            for _,v in ipairs(c:GetDescendants()) do
                if v:IsA("Sound") then
                    if v.Name == "Sound" and v.Parent and v.Parent.Parent and v.Parent.Parent:IsA("Tool") and v.Parent.Parent.Name == "BoomBox" then
                        v.Volume = 0
                    end
                end
            end
        end
    end
end
g.unmutesounds = g.unmutesounds or function()
    for _,v in ipairs(Placed_Models:GetDescendants()) do
        if v:IsA("Sound") then
            local n = v.Name
            if n == "SoundDefault" or n == "Music" or n == "Airhorn" then
                v.Volume = 1
            elseif n == "Sound" and v.Parent and v.Parent.Parent and v.Parent.Parent.Name == "BoomBox" then
                v.Volume = 0.5
            end
        end
    end
    for _,p in ipairs(g.Players:GetPlayers()) do
        local c = p.Character or g.get_char(p, 3)
        if c and c:IsDescendantOf(game) then
            for _,v in ipairs(c:GetDescendants()) do
                if v:IsA("Sound") then
                    if v.Name == "Sound" and v.Parent and v.Parent.Parent and v.Parent.Parent:IsA("Tool") and v.Parent.Parent.Name == "BoomBox" then
                        v.Volume = 0.5
                    end
                end
            end
        end
    end
    g.notify("Success", "Unmuted all tools.", 5)
end
g.mute_all_tools = g.mute_all_tools or function(toggle)
    if toggle == true then
        if g.autosilence then g.notify("Warning", "Tool muter is already enabled.", 5); return end
        g.autosilence = true
        g.notify("Success", "Tool muter is enabled.", 5)
        g.Muting_All_Tool_Sounds_Task = task.spawn(function()
            while g.autosilence == true do
                wait(1)
                g.mutesounds()
            end
        end)
    elseif toggle == false then
        if not g.autosilence then g.notify("Warning", "Tools muter is not enabled.", 5); return end
        if g.Muting_All_Tool_Sounds_Task then
            task.cancel(g.Muting_All_Tool_Sounds_Task)
            g.Muting_All_Tool_Sounds_Task = nil
        end
        g.autosilence = false
        wait(1)
        if not g.autosilence then
            g.notify("Info", "Making all the tools Volume: 1...", 5)
            g.unmutesounds()
        else
            g.g.notify("Warning", "Tools muter is not disabled yet, hold on...", 3)
            repeat task.wait() until not g.autosilence or g.autosilence == false
            wait(1.5)
            if not g.autosilence then
                g.notify("Success", "Unmuting all Tools...", 5)
                wait(0.5)
                g.unmutesounds()
                wait(0.5)
                g.notify("Success", "Unmuted all Tools.", 5)
            end
        end
    else
        return
    end
end
g.find_skin_body_colors_in_char = g.find_skin_body_colors_in_char or function(char)
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BodyColors") then return v end
        local name = v.Name:lower()
        if name:find("body") and name:find("color") then return v end
    end
    return nil
end
g.original_skintone = g.original_skintone or nil
g.rainbow_skin = g.rainbow_skin or function(state)
    local lib = g.FlamesLibrary
    local name = "rainbow_skin"
    local char = g.Character or g.LocalPlayer.Character or g.get_char(LocalPlayer, Players.RespawnTime + 1)
    if not char or not char:IsDescendantOf(game) then return end
    local bodycolors = char and char:FindFirstChildOfClass("BodyColors")
    if not bodycolors then return end
    if state == true then
        if g.rainbow_skintone_currently_enabled then g.notify("Warning", "Flames Hub - Rainbow Skin is already enabled.", 5); return end
        g.original_skintone = {
            HeadColor3 = bodycolors.HeadColor3,
            LeftArmColor3 = bodycolors.LeftArmColor3,
            RightArmColor3 = bodycolors.RightArmColor3,
            LeftLegColor3 = bodycolors.LeftLegColor3,
            RightLegColor3 = bodycolors.RightLegColor3,
            TorsoColor3 = bodycolors.TorsoColor3
        }
        g.notify("Success", "Flames Hub | Rainbow Skin is now enabled.", 5)
        lib.spawn(name, "spawn", function()
            while true do
                for _, c in ipairs(g.colors) do
                    g.send_remote("skin_tone", c)
                    wait(.1)
                end
            end
        end)
    elseif state == false then
        if not lib.is_alive(name) then return end
        lib.disconnect(name)
        fw(0.2)
        if g.original_skintone then
            local old = g.original_skintone
            g.send_remote("skin_tone", old.HeadColor3)
            wait()
            g.send_remote("skin_tone", old.LeftArmColor3)
            wait()
            g.send_remote("skin_tone", old.RightArmColor3)
            wait()
            g.send_remote("skin_tone", old.LeftLegColor3)
            wait()
            g.send_remote("skin_tone", old.RightLegColor3)
            wait()
            g.send_remote("skin_tone", old.TorsoColor3)
            g.notify("Success", "Reset SkinTone back to your old SkinTone.", 3)
        end
        g.notify("Success", "Flames Hub | Rainbow Skin is now disabled.", 5)
    end
end
g.two_tone_skin = g.two_tone_skin or function(state)
    local lib = g.FlamesLibrary
    local fw = lib.wait
    local name = "two_tone_skin"
    local char = g.Character or g.LocalPlayer or g.get_char(LocalPlayer, Players.RespawnTime + 1)
    if not char or not char:IsDescendantOf(game) then return end
    local bodycolors = char and char:FindFirstChildOfClass("BodyColors")
    if not bodycolors then return end
    if state == true then
        if g.Two_Tone_Skin_Tone_Loop_Toggled then g.notify("Warning", "Two Tone Skin is already enabled.", 5); return end
        g.original_skintone = {
            HeadColor3 = bodycolors.HeadColor3,
            LeftArmColor3 = bodycolors.LeftArmColor3,
            RightArmColor3 = bodycolors.RightArmColor3,
            LeftLegColor3 = bodycolors.LeftLegColor3,
            RightLegColor3 = bodycolors.RightLegColor3,
            TorsoColor3 = bodycolors.TorsoColor3
        }
        local c1 = g.colors[math.random(1, #g.colors)]
        local c2 = g.colors[math.random(1, #g.colors)]
        while c2 == c1 do c2 = g.colors[math.random(1, #g.colors)] end
        g.notify("Success", "Flames Hub | Two Tone Skin is now enabled.", 5)
        g.Two_Tone_Skin_Tone_Loop_Toggled = true
        lib.spawn(name, "spawn", function()
            while g.Two_Tone_Skin_Tone_Loop_Toggled == true do
                fw(0.1)
                g.Send("skin_tone", c1)
                fw(0.1)
                g.Send("skin_tone", c2)
            end
        end)
    elseif state == false then
        if not g.Two_Tone_Skin_Tone_Loop_Toggled then g.notify("WArning", "Two Tone Skin is not enabled.", 5); return end
        lib.disconnect(name)
        wait(0.25)
        if g.original_skintone then
            local old = g.original_skintone
            g.Send("skin_tone", old.HeadColor3)
            wait()
            g.Send("skin_tone", old.LeftArmColor3)
            wait()
            g.Send("skin_tone", old.RightArmColor3)
            wait()
            g.Send("skin_tone", old.LeftLegColor3)
            wait()
            g.Send("skin_tone", old.RightLegColor3)
            wait()
            g.Send("skin_tone", old.TorsoColor3)
            g.notify("Success", "Reset skintone back to original.", 3)
        end
        g.notify("Success", "Flames Hub | Two Tone Skin is now disabled.", 5)
    end
end
g.Amount_Input = 5
g.set_fire_amount_FE = g.set_fire_amount_FE or function(amount)
    amount = tonumber(amount)
    if not amount then g.Amount_Input = 5; return end
    g.Amount_Input = amount
end
local Old_Name_From_Name_Spammer
g.name_changer_premium = g.name_changer_premium or function(state)
    local lib = g.FlamesLibrary
    local name = "name_spammer"
    local words = {
        "root_access","packet_inject","xor_key","decrypting",
        "init_stealth","spoof_id","kernel_hook","bruteforce",
        "sys_reboot","net_breach","ghost_mode","backdoor_init"
    }
    if state == true then
        if g.Name_Spammer_Currently_Enabled then g.notify("Warning", "Flames Hub | Name Spammer is already enabled.", 5); return end
        g.Name_Spammer_Currently_Enabled = true
        Old_Name_From_Name_Spammer = g.LocalPlayer:GetAttribute("roleplay_name") or "SERVER"
        local index = 1
        local count = #words
        lib.spawn(name, "spawn", function()
            while g.Name_Spammer_Currently_Enabled == true do
                g.Send("roleplay_name", words[index])
                index = index + 1
                if index > count then index = 1 end
                fw(61)
            end
        end)
        g.notify("Success", "Name Spammer is now enabled.", 3)
    elseif state == false then
        if not g.Name_Spammer_Currently_Enabled then g.notify("Warning", "Flames Hub | Name Spammer is not enabled.", 5); return end
        g.Name_Spammer_Currently_Enabled = false
        lib.disconnect(name)
        fw(0.1)
        g.Send("roleplay_name", tostring(Old_Name_From_Name_Spammer))
        g.notify("Success", "Name Spammer is now disabled.", 3)
    end
end
g.spectate_plr_without_distance_limits = g.spectate_plr_without_distance_limits or function(plr)
    g.spectatePlayer = function(target_player)
        if not target_player then return end
        local spectate_target = target_player
        local spectate_subject = nil
        g.originalIO.disconnectSpectateConns()
        local function setCamToCharacter(character)
            if spectate_target ~= target_player or not character then return end
            local hum = g.getPlrHum(character) or g.getHum(character, 5)
            local subj = hum or g.getRoot(character)
            if not subj then return end
            spectate_subject = subj
            g.originalIO.ensureCam()
            g.originalIO.hookCameraGuard()
        end
        setCamToCharacter(target_player.Character)
        g.spectateConns.char = g.FlamesLibrary.connect("spectate_char", target_player.CharacterAdded:Connect(function(character)
            if spectate_target ~= target_player then return end
            setCamToCharacter(character)
        end))
        g.spectateConns.leave = g.NAlib.connect("spectate_leave", Players.PlayerRemoving:Connect(function(player)
            if player == target_player and spectate_target == target_player then g.cleanup(true) end
        end))
        g.spectateConns.loop = g.NAlib.connect("spectate_loop", RunService.RenderStepped:Connect(function()
            if spectate_target ~= target_player then return end
            local char = target_player.Character
            if not char or not char.Parent then return end
            if not spectate_subject or spectate_subject.Parent ~= char then
                setCamToCharacter(char)
            else
                g.originalIO.ensureCam()
            end
        end))
    end
    g.spectatePlayer(plr)
end
g.Anti_Stealer_Bio = "`~ Flames Hub Anti Stealer Is Enabled ~`"
g.anti_outfit_copier = function(toggle)
    if toggle == true then
        if g.anti_outfit_stealer then g.notify("Error", "Anti Outfit Stealer is already enabled!", 5); return end
        if g.FlamesLibrary.is_alive("AntiFitStealerConn") then g.notify("Error", "Anti Outfit Stealer is already enabled! [connection].", 5); return end
        g.notify("Success", "Flames Hub | Anti Outfit Stealer is now active.", 7)
        local lib = g.FlamesLibrary
        g.ToggleAntiFit_Stealer = function(state)
            if not state then
                g.anti_outfit_stealer = false
                lib.disconnect("AntiFitStealerConn")
                return
            end
            g.anti_outfit_stealer = true
            g.Send("bio", g.Anti_Stealer_Bio)
            local last_check = 0
            local target_bio = g.Anti_Stealer_Bio
            lib.connect("AntiFitStealerConn", g.RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - last_check < 0.4 then return end
                last_check = now
                local hide_outfit_toggle = g.LocalPlayer:GetAttribute("hide_view_outfit")
                if hide_outfit_toggle == false then
                    g.Send("hide_view_outfit", true)
                    g.notify("Success", "hide_view_outfit setting changed, reverted change (keep it on).", 3)
                end
                if g.anti_outfit_stealer then
                    local current_bio = g.LocalPlayer:GetAttribute("bio")
                    if current_bio ~= target_bio then
                        g.Send("bio", target_bio)
                        g.notify("Success", "Bio was changed, reverted back.", 3)
                    end
                end
            end))
        end
        fw(0.1)
        g.ToggleAntiFit_Stealer(true)
    elseif toggle == false then
        if not g.anti_outfit_stealer then g.notify("Error", "Anti Outfit Copier is not enabled!", 5); return end
        g.anti_outfit_stealer = false
        g.FlamesLibrary.disconnect("AntiFitStealerConn")
        g.ToggleAntiFit_Stealer(false)
        g.notify("Success", "Disabled Anti Outfit Stealer.", 5)
    else
        return
    end
end
g.Delete_House = function()
    local s = g.Get
    if s and typeof(s) == "function" then s("request_delete_house") end
end
local upvalues_func_main = getupvalue or getupvalues or rawget and rawget(debug, "getupvalues")
local get_proto_func = getproto or rawget and rawget(debug, "getproto") or getprotos
g.hook_meta_main = g.hook_meta_main or function(obj, metamethod, func)
    if not getrawmetatable or typeof(getrawmetatable) ~= "function" then return end
    local old = getrawmetatable and getrawmetatable(obj)
    if hookfunction and typeof(hookfunction) == "function" then
        return hookfunction(old[metamethod],func)
    else
        local oldmetamethod = old[metamethod]
        if makewriteable and typeof(makewriteable) == "function" then makewriteable(old) end
        old[metamethod] = func
        if makereadonly and typeof(makereadonly) == "function" then makereadonly(old) end
        return oldmetamethod
    end
end
g.find_messages_modulescript = g.find_messages_modulescript or function()
    if g.Messages_Module_Found_Loc then return g.Messages_Module_Found_Loc end
    local found = ReplicatedStorage:FindFirstChild("Messages", true)
    if found and found:IsA("ModuleScript") then g.Messages_Module_Found_Loc = found end
    return g.Messages_Module_Found_Loc
end
g.find_UI_modulescript = g.find_UI_modulescript or function()
    if g.UI_Module_Main then return g.UI_Module_Main end
    local found = ReplicatedStorage:FindFirstChild("UI", true)
    if found and found:IsA("ModuleScript") then g.UI_Module_Main = found end
    return g.UI_Module_Main
end
g.find_RateLimiter_modulescript = g.find_RateLimiter_modulescript or function()
    if g.RateLimiter_Module_Main then return g.RateLimiter_Module_Main end
    local found = ReplicatedStorage:FindFirstChild("RateLimiter", true)
    if found and found:IsA("ModuleScript") then g.RateLimiter_Module_Main = found end
    return g.RateLimiter_Module_Main
end
if not g.RateLimiter_Bypass_Applied then
    if get_proto_func and upvalues_func_main and require then
        local ok = pcall(function()
            local message_module = g.Messages_Module_Found_Loc and g.safe_require(g.Messages_Module_Found_Loc) or g.safe_require(g.find_messages_modulescript())
            local rate_limiter = upvalues_func_main(get_proto_func(message_module.loaded, 4, true)[1], 5)
            if typeof(rate_limiter) == "table" and rate_limiter.is_limited then
                rate_limiter.is_limited = function() return false end
                g.RateLimiter_Bypass_Applied = true
                g.RateLimiter_Bypass_Applied_Method_2 = true
            end
        end)
        if not ok then
            warn("RateLimiter bypass method failed unexpectedly.")
        end
    end
end
g.Spam_Survey_Completions = function(state)
    if state == true then
        g.Spam_And_Spoof_Survey_Submissions = true
        g.notify("Success", "Flames Hub | Life Together RP survey spammer is now active.", 3)
        FlamesLibrary.spawn("spam_survey_completions", "spawn", function()
            while g.Spam_And_Spoof_Survey_Submissions == true do
            task.wait(0)
                local Survey_Args = {
                    "survey_completed",
                    "5",
                    {
                        {
                            questionKey = "question_1",
                            answerKeys = {"question_5"}
                        },
                        {
                            answerKey = "question_2",
                            questionKey = "question_2"
                        },
                        {
                            questionKey = "question_3",
                            answerKeys = {"question_2"}
                        },
                        {
                            answerKey = "answer_2",
                            questionKey = "question_4"
                        },
                        {
                            answerKey = "answer_1",
                            questionKey = "question_5"
                        }
                    },
                    {
                        platform = spoofed_platforms[math.random(1, #spoofed_platforms)],
                        localeId = locale_ids[math.random(1, #locale_ids)],
                        sdkVersion = matrix_ids[math.random(1, #matrix_ids)]
                    }
                }
                g.Send(unpack(Survey_Args))
            end
        end)
    elseif state == false then
        g.Spam_And_Spoof_Survey_Submissions = false
        FlamesLibrary.disconnect("spam_survey_completions")
        g.notify("Success", "Flames Hub | Life Together RP survey spammer is now disabled.", 3)
    else
        return
    end
end
g.spam_sign_text = g.spam_sign_text or function(toggle)
    local Character = g.Character
    local PlacedModels = workspace:WaitForChild("PlacedModels")
    local random_words = {"yo","wsg bro","aye","lit","fire"}
    local function find_tool_partial(tool_name)
        if not tool_name then return nil end
        local query = tool_name:lower()
        for _, v in ipairs(PlacedModels:GetChildren()) do
            if v:IsA("Model") and v.Name:lower() == query then
                local owner_attr = v:GetAttribute("owner_id")
                if owner_attr and tostring(owner_attr) == tostring(LocalPlayer.UserId) then
                    return v
                end
            end
        end
        for _, v in ipairs(Character:GetChildren()) do if v.Name:lower() == query then return v end end
        return nil
    end
    if toggle == true then
        if g.ToolChanger_FE then g.notify("Warning", "Sign Spammer is already enabled!", 3); return end
        g.ToolChanger_FE = true
        g.Sign_ChangeText_Fast_Loop_Task = task.spawn(function()
            while g.ToolChanger_FE == true do
                local tool = find_tool_partial("sign")
                if not tool then
                    g.Send("get_tool", "Sign")
                    fw(0.1)
                else
                    for _, word in ipairs(random_words) do
                        if not g.ToolChanger_FE then break end
                        g.Send("change_sign", tool, tostring(word))
                        fw(0)
                    end
                end
                fw(0.1)
            end
        end)
    elseif toggle == false then
        if g.Sign_ChangeText_Fast_Loop_Task then
            task.cancel(g.Sign_ChangeText_Fast_Loop_Task)
            g.Sign_ChangeText_Fast_Loop_Task = nil
        end
        g.ToolChanger_FE = false
    else
        return
    end
end
g.AutoLockConnection = g.AutoLockConnection or nil
g.ToggleAutoLock = g.AutoLockConnection or function(state)
    if not state then
        g.AutoLockOn = false
        if g.AutoLockConnection then
            g.AutoLockConnection:Disconnect()
            g.AutoLockConnection = nil
        end
        local car = g.get_vehicle()
        if car and car:GetAttribute("locked") == true then
            g.lock_vehicle(car)
            g.notify("Success", "Flames Hub | Auto Lock Vehicle is now disabled.", 5)
        else
            g.notify("Warning", "Flames Hub | Auto Lock Vehicle is now disabled, vehicle not found.", 5)
        end
        return
    else
        local car = g.get_vehicle()
        if not car then g.notify("Error", "Vehicle not found, spawn one!", 5); return end
        g.AutoLockOn = true
    end
    g.notify("Success", "Flames Hub | Auto Lock Vehicle is now enabled.", 5)
    g.AutoLockConnection = g.RunService.Heartbeat:Connect(function()
        if tick() - (g._lastLockCheck or 0) < 1 then return end
        g._lastLockCheck = tick()
        local car = g.get_vehicle()
        if car and car:GetAttribute("locked") ~= true then g.lock_vehicle(car) end
    end)
end
if not g.player_esp_core then
    g.player_esp_core = true
    local localplayer = g.LocalPlayer
    local esp_objects = {}
    g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled = false
    local function wait_character(plr)
        local character = plr.Character
        while g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled and plr.Parent and (not character or not character.Parent) do
            character = plr.Character
            g.heartbeat_wait_function(6)
        end
        return character
    end
    local function remove_esp(plr)
        if esp_objects[plr] then
            esp_objects[plr]:Destroy()
            esp_objects[plr] = nil
        end
    end
    local function apply_esp(plr)
        if not g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled then return end
        if plr == localplayer then return end
        task.spawn(function()
            local character = wait_character(plr)
            if not g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled or not character then return end
            remove_esp(plr)
            local highlight = Instance.new("Highlight")
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = character
            highlight.Parent = character
            esp_objects[plr] = highlight
        end)
    end
    local function track_player(plr)
        apply_esp(plr)
        FlamesLibrary.connect("esp_char_" .. tostring(plr.UserId), plr.CharacterAdded:Connect(function(new_char)
            if plr == localplayer then return end
            while g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled and new_char and not new_char.Parent do task.wait() end
            apply_esp(plr)
        end))
    end
    local function untrack_player(plr) remove_esp(plr); FlamesLibrary.disconnect("esp_char_" .. tostring(plr.UserId)) end
    g.enable_player_esp = function()
        if g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled then g.notify("Warning", "Flames Hub Player ESP is already enabled.", 5); return end
        g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled = true
        for _, plr in ipairs(Players:GetPlayers()) do track_player(plr) end
        FlamesLibrary.connect("esp_playeradded", Players.PlayerAdded:Connect(track_player))
        FlamesLibrary.connect("esp_playerremoving", Players.PlayerRemoving:Connect(untrack_player))
    end
    g.disable_player_esp = function()
        if not g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled then g.notify("Warning", "Flames Hub Player ESP is not enabled.", 5); return end
        g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled = false
        for plr in pairs(esp_objects) do remove_esp(plr) end
        FlamesLibrary.disconnect("esp_playeradded")
        FlamesLibrary.disconnect("esp_playerremoving")
    end
end
if Drawing and not g.tracer_core_initialized then
    g.tracer_core_initialized = true
    local camera = workspace.CurrentCamera
    local localplayer = g.LocalPlayer or Players.LocalPlayer
    local tracer_objects = {}
    g.tracer_esp_currently_running_flag_Flames_Hub = false
    if g.disable_tracers and typeof(g.disable_tracers) == "function" then pcall(function() g.disable_tracers() end) end
    local function remove_tracer(plr)
        if tracer_objects[plr] then
            tracer_objects[plr]:Remove()
            tracer_objects[plr] = nil
        end
    end
    local function create_tracer(plr)
        if plr == localplayer then return end
        while g.tracer_esp_currently_running_flag_Flames_Hub and not plr.Parent do task.wait() end
        if not g.tracer_esp_currently_running_flag_Flames_Hub then return end
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Transparency = 1
        line.Visible = false
        tracer_objects[plr] = line
    end
    local function update_tracers()
        if not g.tracer_esp_currently_running_flag_Flames_Hub then pcall(function() g.disable_tracers() end); return end
        local view = camera.ViewportSize
        for plr, line in pairs(tracer_objects) do
            local character = plr.Character or g.get_char(plr, 1)
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local pos, onscreen = camera:WorldToViewportPoint(root.Position)
                if onscreen then
                    line.Visible = true
                    line.From = Vector2.new(view.X / 2, view.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
    g.enable_tracers = function()
        if g.tracer_esp_currently_running_flag_Flames_Hub then g.notify("Warning", "Tracer ESP is already enabled!", 3); return end
        g.tracer_esp_currently_running_flag_Flames_Hub = true
        for _, plr in ipairs(Players:GetPlayers()) do create_tracer(plr) end
        FlamesLibrary.connect("tracer_render", RunService.RenderStepped:Connect(update_tracers))
        FlamesLibrary.connect("tracer_playeradded", Players.PlayerAdded:Connect(create_tracer))
        FlamesLibrary.connect("tracer_playerremoving", Players.PlayerRemoving:Connect(remove_tracer))
    end
    g.disable_tracers = function()
        if not g.tracer_esp_currently_running_flag_Flames_Hub then g.notify("Warning", "Tracer ESP is not enabled!", 3); return end
        g.tracer_esp_currently_running_flag_Flames_Hub = false
        for plr in pairs(tracer_objects) do remove_tracer(plr) end
        FlamesLibrary.disconnect("tracer_render")
        FlamesLibrary.disconnect("tracer_playeradded")
        FlamesLibrary.disconnect("tracer_playerremoving")
    end
end
task.wait()
if not g.RateLimiter_Notified then
    g.RateLimiter_Notified = true
    if g.RateLimiter_Bypass_Applied then
        if g.RateLimiter_Bypass_Applied_Method_1 then
            g.notify("Success", "RateLimiter bypass applied with method 1.", 10)
        elseif g.RateLimiter_Bypass_Applied_Method_2 then
            g.notify("Success", "RateLimiter bypass applied with method 2.", 10)
        elseif g.RateLimiter_Bypass_Applied_Method_3 then
            g.notify("Success", "RateLimiter bypass applied with method 3.", 10)
        else
            g.notify("Warning", "We we're unable to apply any RateLimiter bypass.", 10)
        end
    else
        g.notify("Warning", "Not sure if RateLimiter bypass was applied or not.", 10)
    end
end
g.WalkFlingWhitelist = g.WalkFlingWhitelist or {}
g.walkflinging = g.walkflinging or false
g.WalkFlingConnections = g.WalkFlingConnections or {}
g.TouchingWhitelisted = g.TouchingWhitelisted or {}
g.AddToWalkFlingWhitelist = g.AddToWalkFlingWhitelist or function(user)
    local userid = g.ToUserId(user)
    if not userid then return g.notify("Warning", "That player is invalid or has left the game.", 5) end
    if g.WalkFlingWhitelist[userid] then return g.notify("Warning", "That player is already in the WalkFling Whitelist.", 5) end
    g.WalkFlingWhitelist[userid] = true
    return g.notify("Success", "Added to WalkFling Whitelist.", 5)
end
g.RemoveFromWalkFlingWhitelist = g.RemoveFromWalkFlingWhitelist or function(user)
    local userid = g.ToUserId(user)
    if not userid then return g.notify("Warning", "That player is invalid or has left the game.", 5) end
    if not g.WalkFlingWhitelist[userid] then return g.notify("Warning", "That player is not in the WalkFling Whitelist.", 5) end
    g.WalkFlingWhitelist[userid] = nil
    return g.notify("Success", "Removed from WalkFling Whitelist.", 5)
end
g.is_whitelisted = g.is_whitelisted or function(plr)
    if not plr then return false end
    return g.WalkFlingWhitelist[plr.UserId] == true
end
g.stop_walkfling = g.stop_walkfling or function()
    if not g.walkflinging then g.notify("Error", "Flames Hub | WalkFling-V3.5 is not enabled.", 5); return end
    g.walkflinging = false
    g.TouchingWhitelisted = {}
    g.FlamesLibrary.disconnect("walkflinger")
    for _, conn in pairs(g.WalkFlingConnections) do conn:Disconnect() end
    g.WalkFlingConnections = {}
    if g.WalkFlingRespawnConn then
        g.WalkFlingRespawnConn:Disconnect()
        g.WalkFlingRespawnConn = nil
    end
    if g.Noclip_Enabled then g.Toggleable_Noclip(false) end
    local root = g.HumanoidRootPart
    if root then root.Velocity = Vector3.zero end
    local hum = g.Humanoid or g.Character:FindFirstChildOfClass("Humanoid") or g.get_human(LocalPlayer or Players.LocalPlayer)
    if hum then hum.PlatformStand = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
    g.notify("Success", "Flames Hub | WalkFling-V3.5 has been stopped/disabled.", 5)
end
g.start_walkfling = g.start_walkfling or function()
    if g.walkflinging then g.notify("Warning", "Flames Hub | WalkFling-V3.5 is already enabled!", 5); return end
    g.walkflinging = true
    g.TouchingWhitelisted = {}
    if not g.Noclip_Enabled then g.Toggleable_Noclip(true) end
    g.notify("Success", "Flames Hub | WalkFling-V3.5 is now enabled.", 5)
    local function connect_touch_fling(character)
        for _, conn in pairs(g.WalkFlingConnections) do conn:Disconnect() end
        g.WalkFlingConnections = {}
        g.TouchingWhitelisted = {}
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                local touch_conn = part.Touched:Connect(function(hit)
                    if not g.walkflinging then return end
                    local hit_char = hit.Parent
                    while hit_char and not Players:GetPlayerFromCharacter(hit_char) and hit_char.Parent ~= workspace do hit_char = hit_char.Parent end
                    local hit_player = Players:GetPlayerFromCharacter(hit_char)
                    if not hit_player or hit_player == speaker then return end
                    if g.is_whitelisted(hit_player) then
                        g.TouchingWhitelisted[hit_player.UserId] = true
                        return
                    end
                    if next(g.TouchingWhitelisted) then return end
                    local hit_root = hit_char:FindFirstChild("HumanoidRootPart")
                    if not hit_root then return end
                    local root = g.HumanoidRootPart
                    local v = root and root.CFrame.LookVector or Vector3.zero
                    local power = 10000
                    hit_root.Velocity = v * power + Vector3.new(0, power, 0)
                    RunService.RenderStepped:Wait()
                    if hit_root then hit_root.Velocity = v * power end
                    RunService.RenderStepped:Wait()
                    if hit_root then hit_root.Velocity = v * power + Vector3.new(0, 0.1, 0) end
                end)
                local untouch_conn = part.TouchEnded:Connect(function(hit)
                    local hit_char = hit.Parent
                    while hit_char and not Players:GetPlayerFromCharacter(hit_char) and hit_char.Parent ~= workspace do hit_char = hit_char.Parent end
                    local hit_player = Players:GetPlayerFromCharacter(hit_char)
                    if hit_player and g.is_whitelisted(hit_player) then g.TouchingWhitelisted[hit_player.UserId] = nil end
                end)
                table.insert(g.WalkFlingConnections, touch_conn)
                table.insert(g.WalkFlingConnections, untouch_conn)
            end
        end
    end
    local char = g.Character or g.LocalPlayer.Character or g.get_char(speaker, 3)
    if char then connect_touch_fling(char) end
    if g.WalkFlingRespawnConn then
        g.WalkFlingRespawnConn:Disconnect()
        g.WalkFlingRespawnConn = nil
    end
    wait(0.25)
    g.WalkFlingRespawnConn = speaker.CharacterAdded:Connect(function(new_char) if g.walkflinging then connect_touch_fling(new_char) end end)
    g.FlamesLibrary.disconnect("walkflinger")
    g.FlamesLibrary.connect("walkflinger", RunService.Heartbeat:Connect(function()
        if not g.walkflinging then return end
        local m = g.Character or g.get_char(speaker, 3)
        local r = m and (g.HumanoidRootPart or m:FindFirstChild("HumanoidRootPart"))
        if not r then return end
        local v = r.Velocity
        r.Velocity = v * 10000 + Vector3.new(0, 10000, 0)
        RunService.RenderStepped:Wait()
        if r then r.Velocity = v end
        RunService.RenderStepped:Wait()
        if r then r.Velocity = v + Vector3.new(0, 0.1, 0) end
    end))
end
g.StartWalkFling = g.start_walkfling
g.StopWalkFling = g.stop_walkfling
g.getcharsize = g.getcharsize or function()
    local hum = g.Humanoid
    if not hum then return 5,2 end
    local d = hum:GetAppliedDescription()
    local h = 5 * (d.HeightScale or 1)
    local w = 2 * (d.WidthScale or 1)
    return h,w
end
g.autospinspeed = g.autospinspeed or function(base) local h = g.getcharsize(); return base / h end
g.change_spin_speed = g.change_spin_speed or function(speed)
    if g.walkflinging then g.notify("Error", "Turn off walkfling first for this to work properly.", 5); return end
    for _, v in ipairs(g.HumanoidRootPart:GetChildren()) do if v.Name == "FlamesHub_Spin" then v.AngularVelocity = Vector3.new(0, speed, 0) end end
end
g.LockHouse_LastState = g.LockHouse_LastState or {}
g.LockHomeLoop = g.LockHomeLoop or false
g.get_plot_of_player = g.get_plot_of_player or function(player)
    if not player then return nil, "No player provided" end
    local plotList = g.PlotMarker and g.PlotMarker.class and g.PlotMarker.class.objects
    if type(plotList) ~= "table" then return nil, "Plots not available" end
    for _, plot in pairs(plotList) do
        if plot and plot.states and plot.states.owner and typeof(plot.states.owner.get) == "function" and plot.instance then
            local ok, owner = pcall(function() return plot.states.owner.get() end)
            if ok and owner == player then  return plot.instance, plot end
        end
    end
    return nil, "Player has no plot"
end
g.toggle_house_lock = g.toggle_house_lock or function(player)
    local plotInstance = select(1, g.get_plot_of_player(player))
    if not plotInstance then return end
    g.Send("lock_home", plotInstance)
end
g.is_home_locked = g.is_home_locked or function(player)
    local plotObject = g.get_plot_of_player(player)
    if not plotObject then return nil, "Player has no plot" end
    if not plotObject.states or not plotObject.states.locked or typeof(plotObject.states.locked.get) ~= "function" then return nil, "Locked state unavailable" end
    local ok, locked = pcall(function() return plotObject.states.locked.get() end)
    if not ok then return nil, "Failed to read lock state" end
    return locked
end
g.LockHouse_LastState = g.LockHouse_LastState or {}
g.LockHomeLoop = g.LockHomeLoop or false
g.LockHomeToken = g.LockHomeToken or 0
g.keep_home_locked = g.keep_home_locked or function(toggle)
    if toggle then
        if g.LockHomeLoop then g.notify("Warning", "Flames Hub | Auto Lock Home is already enabled.", 5); return end
        g.LockHomeLoop = true
        g.LockHomeToken = (g.LockHomeToken or 0) + 1
        local myToken = g.LockHomeToken
        g.notify("Success", "Flames Hub | Auto Lock Home is now enabled.", 5)
        task.spawn(function()
            while g.LockHomeLoop and myToken == g.LockHomeToken do
                fw(0.2)
                local plot_list = g.PlotMarker and g.PlotMarker.class and g.PlotMarker.class.objects
                if plot_list then
                    for _, plot in pairs(plot_list) do
                        if myToken ~= g.LockHomeToken then return end
                        local okOwner, owner = pcall(function() return plot.states.owner.get() end)
                        if okOwner and owner == g.LocalPlayer then
                            local id = plot.instance:GetDebugId()
                            if g.LockHouse_LastState[id] == nil then g.LockHouse_LastState[id] = plot.states.locked.get() end
                            local locked = plot.states.locked.get()
                            local last = g.LockHouse_LastState[id]
                            if locked == false and last == true then
                                g.toggle_house_lock(g.LocalPlayer)
                                g.LockHouse_LastState[id] = true
                            else
                                g.LockHouse_LastState[id] = locked
                            end
                        end
                    end
                end
            end
        end)
    else
        if not g.LockHomeLoop then g.notify("Warning", "Flames Hub | Auto Lock Home is not enabled.", 5); return end
        g.LockHomeLoop = false
        g.LockHomeToken = (g.LockHomeToken or 0) + 1
        table.clear(g.LockHouse_LastState)
        g.notify("Success", "Flames Hub | Auto Lock Home is now disabled.", 5)
    end
end
g.spin_plr = g.spin_plr or function(toggle, speed)
    local hrp = g.HumanoidRootPart or g.Character and g.Character:FindFirstChild("HumanoidRootPart") or g.get_root(g.LocalPlayer, Players.RespawnTime + 1)
    if toggle == true then
        if g.already_spinning_localplr then g.notify("Warning", "You are already spinning, changing speed.", 5); return end
        if typeof(speed) ~= "number" then g.notify("Error", "That wasn't a number! Input a number.", 5); return end
        if g.walkflinging then g.notify("Error", "Turn off walkfling first for this to work properly.", 5); return end
        g.already_spinning_localplr = true
        for _, v in pairs(hrp:GetChildren()) do
            if v.Name == "FlamesHub_Spin" then
                v:Destroy()
            end
        end
        wait(.1)
        local Spin = Instance.new("BodyAngularVelocity")
        Spin.Name = "FlamesHub_Spin"
        Spin.MaxTorque = Vector3.new(0, math.huge, 0)
        Spin.AngularVelocity = Vector3.new(0, g.autospinspeed(speed), 0)
        Spin.Parent = hrp
    elseif toggle == false then
        if not g.already_spinning_localplr then g.notify("Error", "You are not using Spin.", 3); return end
        for _, v in ipairs(hrp:GetChildren()) do if v:IsA("BodyAngularVelocity") and v.Name == "FlamesHub_Spin" then v:Destroy() end end
        g.already_spinning_localplr = false
    else
        return
    end
end
g.OrbitConnections = g.OrbitConnections or {}
g.Is_Orbiting = g.Is_Orbiting or false
g.OrbitSpeed = g.OrbitSpeed or 1
g.set_orbit_speed = g.set_orbit_speed or function(new_speed)
    if type(new_speed) == "number" then
        g.OrbitSpeed = new_speed
        g.notify("Info", "Orbit speed set to "..tostring(new_speed), 4)
    else
        g.notify("Error", "Invalid speed value.", 3)
    end
end
g.stop_orbit = g.stop_orbit or function()
    if not g.Is_Orbiting then g.notify("Warning", "You're not orbiting anyone.", 3); return end
    for _, conn in pairs(g.OrbitConnections) do if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end end
    table.clear(g.OrbitConnections)
    g.Is_Orbiting = false
    g.notify("Success", "Stopped orbiting Player.", 3)
end
g.start_orbit_plr = g.start_orbit_plr or function(target, speed, distance)
    if g.Is_Orbiting then g.notify("Warning", "Already orbiting someone!", 3); return end
    if not target or not target.Character then g.notify("Error", "Target invalid or they're missing their Character.", 5); return end
    local target_char = target.Character or g.get_char(target)
    local root = g.HumanoidRootPart or g.get_root(LocalPlayer, 3)
    local humanoid = g.Humanoid or g.Character:FindFirstChildWhichIsA("Humanoid") or g.get_human(LocalPlayer)
    local targetRoot = target_char:FindFirstChild("HumanoidRootPart") or g.get_root(target, 1)
    if not root or not humanoid or not targetRoot then
        g.Is_Orbiting = false
        g.notify("Error", "Missing root or humanoid, cannot orbit this player.", 5)
        return
    end
    speed = tonumber(speed) or g.OrbitSpeed or 1
    distance = tonumber(distance) or 3
    g.OrbitSpeed = speed
    g.Is_Orbiting = true
    local rotation = 0
    g.OrbitConnections.Heartbeat = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not g.Is_Orbiting or not target_char or not targetRoot or not root then return  end
            rotation = rotation + (g.OrbitSpeed or 0)
            root.CFrame = CFrame.new(targetRoot.Position) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(distance, 0, 0)
        end)
    end)
    g.OrbitConnections.RenderStepped = RunService.RenderStepped:Connect(function()
        pcall(function()
            if root and root.Parent and targetRoot and targetRoot.Parent then root.CFrame = CFrame.new(root.Position, targetRoot.Position) end
        end)
    end)
    g.OrbitConnections.Died = humanoid.Died:Connect(g.stop_orbit)
    g.OrbitConnections.Seated = humanoid.Seated:Connect(function(isSeated) if isSeated then g.stop_orbit() end end)
    g.notify("Success", "Started orbiting: "..tostring(target)..", with speed: "..tostring(speed)..", and with distance: "..tostring(distance), 5)
end
g.water_skie_trailer = g.water_skie_trailer or function(Bool, Vehicle)
    if not Vehicle then g.notify("Warning", "You do not have a Vehicle spawned!", 5); return end
    local HasTrailer = Vehicle:FindFirstChild("WaterSkies")
    if Bool == true then
        if HasTrailer then
            g.notify("Error", "You already have the WaterSkies trailer.", 5)
            return
        else
            g.Get("add_trailer", Vehicle, "WaterSkies")
        end
    elseif Bool == false then
        if HasTrailer then
            g.Get("add_trailer", Vehicle, "WaterSkies")
        else
            g.notify("Warning", "You do not have the WaterSkies trailer to take it off!", 5)
            return
        end
    else
        g.notify("Error", "Invalid toggle value (expected: true/false).", 5)
        return
    end
end
g.FlyEnabled = g.FlyEnabled or false
g.FlySpeed = g.FlySpeed or 1
g.QEfly = (g.QEfly == nil) and true or g.QEfly
g.flyKeyDown = g.flyKeyDown or nil
g.flyKeyUp = g.flyKeyUp or nil
g.mobileFlyConn = g.mobileFlyConn or nil
g.pcFlyConn = g.pcFlyConn or nil
g.EnableFly = g.EnableFly or function(state, speed, vfly)
    if g.FlyEnabled then
        if speed and tonumber(speed) then
            g.FlySpeed = tonumber(speed)
            g.notify("Success", "Fly speed updated to: "..tostring(g.FlySpeed), 3)
            return
        end
        g.notify("Warning", "Fly is already enabled! Provide a speed to update it.", 5)
        return
    end
    local char = g.Character or plr.Character or g.get_char(plr, Players.RespawnTime + 1)
    local hrp = g.HumanoidRootPart or char and char:FindFirstChild("HumanoidRootPart") or g.get_root(plr, Players.RespawnTime + 1)
    local hum = g.Humanoid or char and char:FindFirstChildOfClass("Humanoid") or g.get_human(plr, Players.RespawnTime + 1)
    local cam = workspace.CurrentCamera
    if not hrp or not hum then g.notify("Error", "Character is not ready or Humanoid doesn't exist.", 5); return end
    if not state then
        g.DisableFly()
        return
    end
    if speed and tonumber(speed) then g.FlySpeed = tonumber(speed) end
    g.FlyEnabled = true
    if g.flyKeyDown then g.flyKeyDown:Disconnect(); g.flyKeyDown = nil end
    if g.flyKeyUp then g.flyKeyUp:Disconnect(); g.flyKeyUp = nil end
    if g.pcFlyConn then g.pcFlyConn:Disconnect(); g.pcFlyConn = nil end
    if g.mobileFlyConn then g.mobileFlyConn:Disconnect(); g.mobileFlyConn = nil end
    if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
    if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
    local BG = Instance.new("BodyGyro")
    BG.P = 9e4
    BG.MaxTorque = Vector3.new(9e9,9e9,9e9)
    BG.CFrame = hrp.CFrame
    BG.Name = "FlyGyro"
    BG.Parent = hrp
    local BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(9e9,9e9,9e9)
    BV.Velocity = Vector3.zero
    BV.Name = "FlyVelocity"
    BV.Parent = hrp
    hum.PlatformStand = true
    if not IsMobile then
        local CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
        g.pcFlyConn = RunService.RenderStepped:Connect(function(dt)
            if not g.FlyEnabled then return end
            if not cam or not hrp or not hum then return end
            local speedNow = ((vfly and (g.VehicleFlySpeed or g.FlySpeed)) or g.FlySpeed) * 50
            local look = cam.CFrame
            local move_vec = ((look.LookVector * (CONTROL.F + CONTROL.B)) + ((look * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.Q + CONTROL.E) * 0.2, 0)).Position - look.Position))
            if move_vec.Magnitude > 0 then
                move_vec = move_vec.Unit
                BV.Velocity = move_vec * speedNow
            else
                BV.Velocity = BV.Velocity * 0.9
            end
            BG.CFrame = cam.CFrame
        end)
        g.flyKeyDown = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 1 end
            if input.KeyCode == Enum.KeyCode.S then CONTROL.B = -1 end
            if input.KeyCode == Enum.KeyCode.A then CONTROL.L = -1 end
            if input.KeyCode == Enum.KeyCode.D then CONTROL.R = 1 end
            if g.QEfly then
                if input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 1 end
                if input.KeyCode == Enum.KeyCode.Q then CONTROL.E = -1 end
            end
            pcall(function() cam.CameraType = Enum.CameraType.Track end)
        end)
        g.flyKeyUp = UIS.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0 end
            if input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0 end
            if input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0 end
            if input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0 end
            if input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0 end
            if input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0 end
        end)
        g.notify("Success", "Fly enabled (PC) | Speed: "..tostring(g.FlySpeed), 5)
        return
    end
    local ok, controlModule = pcall(function()
        return g.safe_require(plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    end)
    if not ok or not controlModule then
        g.notify("Warning", "ControlModule unavailable; using simple touch fallback.", 5)
        g.mobileFlyConn = RunService.RenderStepped:Connect(function()
            if not g.FlyEnabled then return end
            BG.CFrame = cam.CFrame
            BV.Velocity = Vector3.zero
        end)
        return
    end
    g.mobileFlyConn = RunService.RenderStepped:Connect(function()
        if not g.FlyEnabled then return end
        if not hrp or not hum or not cam then return end
        BG.CFrame = cam.CFrame
        local direction = controlModule:GetMoveVector()
        local speedScaled = ((vfly and (g.VehicleFlySpeed or g.FlySpeed)) or g.FlySpeed) * 50
        if direction.Magnitude > 0 then
            BV.Velocity = (cam.CFrame.LookVector * -direction.Z + cam.CFrame.RightVector * direction.X) * speedScaled
        else
            BV.Velocity = Vector3.zero
        end
    end)
    g.notify("Success", "Fly enabled (Mobile) | Speed: "..tostring(g.FlySpeed), 5)
end
print("[Flames] loading: movement")
g.DisableFly = g.DisableFly or function()
    if not g.FlyEnabled then g.notify("Warning", "Fly is not enabled!", 3); return end
    g.FlyEnabled = false
    if g.flyKeyDown then g.flyKeyDown:Disconnect(); g.flyKeyDown = nil end
    if g.flyKeyUp then g.flyKeyUp:Disconnect(); g.flyKeyUp = nil end
    if g.pcFlyConn then g.pcFlyConn:Disconnect(); g.pcFlyConn = nil end
    if g.mobileFlyConn then g.mobileFlyConn:Disconnect(); g.mobileFlyConn = nil end
    local char = g.Character or plr.Character or g.get_char(plr, 3)
    local hrp = g.HumanoidRootPart or char:FindFirstChild("HumanoidRootPart") or g.get_root(plr, 3)
    local hum = g.Humanoid or char:FindFirstChildWhichIsA("Humanoid") or g.get_human(plr, 3)
    if hrp then
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
    end
    if hum then hum.PlatformStand = false end
    g.notify("Success", "Fly is now disabled.", 3)
end
g.VehicleStates = g.VehicleStates or {}
if not g.VehicleStates[g.LocalPlayer.Name] then g.VehicleStates[g.LocalPlayer.Name] = g.LocalPlayer end
g.find_core_folder = g.find_core_folder or function()
    for _, v in ipairs(g.ReplicatedStorage:GetDescendants()) do
        if v:IsA("Folder") and v.Name == "Core" and v.Parent.Name == "Modules" then
            return v
        end
    end
    return nil
end
g.send_msg_phone = g.send_msg_phone or function(player, msg)
    local Core_Folder = g.find_core_folder()
    if not Core_Folder then g.notify("Error", "Core Folder not found (patched?).", 5); return end
    local Privacy = g.safe_require(Core_Folder:FindFirstChild("Privacy"))
    if not Privacy then g.notify("Error", "Privacy ModuleScript not found (patched?).", 5); return end
    local function get_dm_hash(id)
        local my = LocalPlayer.UserId
        if not id then return nil end
        local a, b = (id < my) and id or my, (id < my) and my or id
        return tostring(a) .. " " .. tostring(b)
    end
    local function send_dm(target, text)
        local targetId = target.UserId
        local hash = get_dm_hash(targetId)
        if not hash then return false end
        local ok, res = pcall(function() return Privacy.send_message("messages", hash, text) end)
        if not ok or res == false then
            g.Sending_DMs_Main_Non_Loop_Task = g.Sending_DMs_Main_Non_Loop_Task or task.spawn(function()
                g.notify("Error", "Send message failed: "..tostring(res), 5)
            end)
            return false
        end
        return true
    end
    local text_to_send = msg
    if not text_to_send or text_to_send == "" then g.notify("Error", "Please input a valid message to send!", 5); return end
    send_dm(player, text_to_send)
end
local data_mod = require and g.safe_require(g.ReplicatedStorage.Modules.Core:FindFirstChild("Data", true))
local messages_mod = require and g.safe_require(g.ReplicatedStorage:FindFirstChild("Messages", true))
local function get_other_from_hash(hash, known_id)
    local id1, id2 = hash:match("(%-?%d+) (%-?%d+)")
    id1, id2 = tonumber(id1), tonumber(id2)
    if not id1 or not id2 then return nil end
    if id1 == known_id then return id2 end
    if id2 == known_id then return id1 end
    return nil
end
local function get_recipient_id()
    local convo = messages_mod.active_conversation
    if not convo then return nil end
    return get_other_from_hash(convo.hash, Players.LocalPlayer.UserId)
end
local function get_recipient_from_message(msg_id, sender_id)
    for _, convo in ipairs(data_mod.conversations or {}) do
        if convo.messages then
            for _, msg in ipairs(convo.messages) do
                if msg.id == msg_id then
                    return get_other_from_hash(convo.hash, sender_id)
                end
            end
        end
    end
    return nil
end
local function get_sender_id(msg_id)
    for _, convo in ipairs(data_mod.conversations or {}) do
        if convo.messages then
            for _, msg in ipairs(convo.messages) do
                if msg.id == msg_id then
                    return msg.sender_id, convo.hash
                end
            end
        end
    end
    return nil, nil
end
g.chat_logged_ids = g.chat_logged_ids or {}
g.chat_frame_locks = g.chat_frame_locks or {}
g.chat_text_conns = g.chat_text_conns or {}
g.chat_send_queue = g.chat_send_queue or {}
g.chat_sending = g.chat_sending or false
local function resolve_name(uid)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId == uid then
            return p.Name
        end
    end
    return "User_" .. uid
end
local function enqueue_message(msg) table.insert(g.chat_send_queue, msg) end
local function log_message(frame, txt, msg_id, sender_id)
    local unique_id = msg_id .. "|" .. txt.Text
    if g.chat_logged_ids[unique_id] then return end
    g.chat_logged_ids[unique_id] = true
    local sender_name = resolve_name(sender_id)
    local recipient_id = tonumber(frame:GetAttribute("recipient_id"))
        or get_recipient_from_message(msg_id, sender_id)
        or get_recipient_id()
    local recipient_name = recipient_id and resolve_name(recipient_id) or "unknown"
    local recipient_str  = recipient_id
        and (recipient_name .. " (" .. recipient_id .. ")")
        or "unknown"
    enqueue_message(
        sender_name .. " (" .. sender_id .. " to " .. recipient_str .. "): " .. txt.Text
    )
end
g.process_message_frame = function(frame)
    if frame.Name ~= "Message" then return end
    local msg_id = frame:GetAttribute("id")
    if type(msg_id) ~= "string" then return end
    local sender_id, hash = get_sender_id(msg_id)
    if not sender_id then return end
    local recipient_id = get_other_from_hash(hash, sender_id)
    if recipient_id then frame:SetAttribute("recipient_id", recipient_id) end
    local txt = frame:FindFirstChildWhichIsA("TextLabel", true)
    if not txt then return end
    if not g.chat_text_conns[txt] then
        g.chat_text_conns[txt] = txt:GetPropertyChangedSignal("Text"):Connect(function()
            if txt.Text == "" then return end
            task.delay(0.02, function()
                if txt.Text ~= "" then
                    log_message(frame, txt, msg_id, sender_id)
                end
            end)
        end)
    end
    task.delay(0.05, function()
        if txt and txt.Text ~= "" then
            log_message(frame, txt, msg_id, sender_id)
        end
    end)
end
g.toggle_rgb_streetlights = g.toggle_rgb_streetlights or function(toggle)
    local genv = g
    if toggle == true then
        if genv.RGB_Street_Lights_NightTime_Loop or genv.StreetLightRainbowConnection then genv.notify("Warning", "RGB/Rainbow StreetLights is already running!", 5); return end
        local Map = workspace:FindFirstChild("Map", true)
        if not Map then genv.notify("Error", "Map Folder not found inside of Workspace!", 5); return end
        local StreetLs = Map:FindFirstChild("StreetLights", true)
        if not StreetLs then genv.notify("Error", "StreetLights not found inside of Map Folder!", 5); return end
        if typeof(genv.all_street_lights) ~= "table" then genv.all_street_lights = {} end
        if next(genv.all_street_lights) == nil then
            for _, v in ipairs(StreetLs:GetDescendants()) do
                if v:IsA("PointLight") then
                table.insert(genv.all_street_lights, v)
                end
            end
        end
        local hue = 0
        genv.RGB_Street_Lights_NightTime_Loop = true
        genv.notify("Success", "RGB/Rainbow StreetLights enabled, they will only animate at night.", 10)
        genv.StreetLightRainbowConnection = RunService.Heartbeat:Connect(function(dt)
            local clock_time = g.Lighting.ClockTime
            if clock_time < 18.5 and clock_time > 7.5 then return end
            hue = (hue + dt * 0.0833) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            for i = #genv.all_street_lights, 1, -1 do
                local light = genv.all_street_lights[i]
                if not light or not light.Parent then
                    table.remove(genv.all_street_lights, i)
                else
                    light.Color = color
                end
            end
        end)
    elseif toggle == false then
        if not genv.RGB_Street_Lights_NightTime_Loop then genv.notify("Warning", "RGB/Rainbow StreetLights is not enabled!", 5); return end
        genv.RGB_Street_Lights_NightTime_Loop = false
        if genv.StreetLightRainbowConnection then
            genv.StreetLightRainbowConnection:Disconnect()
            genv.StreetLightRainbowConnection = nil
        end
        genv.notify("Success", "RGB/Rainbow StreetLights disabled.", 10)
    end
end
local excluded_functions = {
    HttpGet = true,
    appendfile = true,
    base64_decode = true,
    base64_encode = true,
    base64decode = true,
    base64encode = true,
    cansignalreplicate = true,
    checkcaller = true,
    checkclosure = true,
    clear_teleport_queue = true,
    cleardrawcache = true,
    clearqueueonteleport = true,
    clearteleportqueue = true,
    clonefunction = true,
    cloneref = true,
    clonereference = true,
    compareinstances = true,
    consoleclear = true,
    consolecreate = true,
    consoledestroy = true,
    consoleerror = true,
    consoleinput = true,
    consoleprint = true,
    consolesettitle = true,
    consolewarn = true,
    create_comm_channel = true,
    createrenderobj = true,
    createrenderobject = true,
    decompile = true,
    delfile = true,
    delfolder = true,
    dofile = true,
    dumpstring = true,
    disable_emote_func = true,
    filtergc = true,
    fireclickdetector = true,
    fireproximityprompt = true,
    firesignal = true,
    firetouchinterest = true,
    get_actor_threads = true,
    get_actors = true,
    get_comm_channel = true,
    get_deleted_actors = true,
    get_hidden_gui = true,
    get_hwid = true,
    get_internal_parent = true,
    get_namecall_method = true,
    get_thread_identity = true,
    get_user_identifier = true,
    getactors = true,
    getactorthreads = true,
    getallthreads = true,
    getbspval = true,
    getcallbackmember = true,
    getcallbackvalue = true,
    getcallingscript = true,
    getcaps = true,
    getclosurecaps = true,
    getconnection = true,
    getconnections = true,
    getconstant = true,
    getconstants = true,
    getcustomasset = true,
    getdeletedactors = true,
    getexecutorname = true,
    getfenv = true,
    getfflag = true,
    getfpscap = true,
    getfunctionhash = true,
    getgc = true,
    getgenv = true,
    gethiddenprop = true,
    gethiddenproperty = true,
    gethui = true,
    gethwid = true,
    getidentity = true,
    getinfo = true,
    getinstances = true,
    getinternalparent = true,
    getloadedmodules = true,
    getnamecallmethod = true,
    getnilinstances = true,
    getobjects = true,
    getpcd = true,
    getproto = true,
    getprotos = true,
    getproximitypromptduration = true,
    getrawmetatable = true,
    getreg = true,
    getregistry = true,
    getrenderproperty = true,
    getrendersteppedlist = true,
    getrenv = true,
    getrunningscripts = true,
    getsafeenv = true,
    getscriptbytecode = true,
    getscriptclosure = true,
    getscriptfromthread = true,
    getscriptfunction = true,
    getscripthash = true,
    getscripts = true,
    getscriptthread = true,
    getsenv = true,
    getsimulationradius = true,
    getstack = true,
    getsynasset = true,
    gettenv = true,
    getthreadcontext = true,
    getthreadidentity = true,
    getupvalue = true,
    getupvalues = true,
    hookfunc = true,
    hookfunction = true,
    hookmetamethod = true,
    http_request = true,
    httpget = true,
    identifyexecutor = true,
    is_parallel = true,
    is_readonly = true,
    iscclosure = true,
    isexecutorclosure = true,
    isfile = true,
    isfolder = true,
    isfunctionhooked = true,
    isgameactive = true,
    islclosure = true,
    isnetworkowner = true,
    isnewcclosure = true,
    isourclosure = true,
    isourthread = true,
    isparallel = true,
    isrbxactive = true,
    isreadonly = true,
    isrenderobj = true,
    isscriptable = true,
    isuntouched = true,
    isvalidlevel = true,
    iswindowactive = true,
    keyclick = true,
    keypress = true,
    keyrelease = true,
    keytap = true,
    listfiles = true,
    loadfile = true,
    loadstring = true,
    lz4compress = true,
    lz4decompress = true,
    makefolder = true,
    makereadonly = true,
    makewritable = true,
    messagebox = true,
    messageboxasync = true,
    mouse1click = true,
    mouse1press = true,
    mouse1release = true,
    mouse2click = true,
    mouse2press = true,
    mouse2release = true,
    mousemoveabs = true,
    mousemoverel = true,
    mousescroll = true,
    newcclosure = true,
    newlclosure = true,
    queue_on_teleport = true,
    queueonteleport = true,
    rconsoleclear = true,
    rconsolecreate = true,
    rconsoledestroy = true,
    rconsoleerr = true,
    rconsoleerror = true,
    rconsolehide = true,
    rconsoleinfo = true,
    rconsoleinput = true,
    rconsolename = true,
    rconsoleprint = true,
    rconsolesettitle = true,
    rconsoleshow = true,
    rconsolewarn = true,
    readfile = true,
    replaceclosure = true,
    replicatesignal = true,
    request = true,
    require = true,
    restorefunc = true,
    restorefunction = true,
    run_on_actor = true,
    run_on_thread = true,
    saveinstance = true,
    set_internal_parent = true,
    set_namecall_method = true,
    set_readonly = true,
    set_thread_identity = true,
    setcaps = true,
    setclipboard = true,
    setclosurecaps = true,
    setconstant = true,
    setfflag = true,
    setfpscap = true,
    sethiddenprop = true,
    sethiddenproperty = true,
    setidentity = true,
    setinternalparent = true,
    setname = true,
    setnamecallmethod = true,
    setproximitypromptduration = true,
    setrawmetatable = true,
    setrbxclipboard = true,
    setreadonly = true,
    setrenderproperty = true,
    setsafeenv = true,
    setscriptable = true,
    setsimulationradius = true,
    setstack = true,
    setstackhidden = true,
    setthreadcontext = true,
    setthreadidentity = true,
    setuntouched = true,
    setupvalue = true,
    setwindowtitle = true,
    toclipboard = true,
    validlevel = true,
    writefile = true,
    playemote = true,
    try_load = true,
    change_gravity_val = true,
    execCmd = true,
    disabled_global_value_correctly = true,
    name_changer_premium = true,
    Flames_Debugger_Function_Tester_GUI = true,
    notify = true,
    start_scan = true,
    SetFPSCap = true,
    low_level_executor = true,
    getcallstack = true,
    getfastflag = true,
    getfastflagtype = true,
    getfflagtype = true,
    gethiddenproperties = true,
    getpcdprop = true,
    getproperties = true,
    getsignalarguments = true,
    getsignalargumentsinfo = true,
    getsignalwhitelist = true,
    getthreadcaps = true,
    info = true,
    makewriteable = true,
    setfastflag = true,
    setinfo = true,
    dumpbytecode = true,
}
g.Flames_Debugger_Function_Tester_GUI = g.Flames_Debugger_Function_Tester_GUI or function()
    local genv = g
    local start_scan
    if genv.__flames_debugger_running then
        if g.notify then
            g.notify("Warning", "Flames Debugger is already running!", 5)
            return
        else
            warn("Flames Debugger is already running.")
            return
        end
    end
    if CoreGui:FindFirstChild("FlamesDebugger") then
        CoreGui.FlamesDebugger.Enabled = true
        genv.__flames_debugger_running = false
        g.dont_receive_any_notifications_flames_hub = false
        return
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "FlamesDebugger"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(400,300)
    frame.Position = UDim2.fromScale(0.4,0.3)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-150,0,30)
    title.Position = UDim2.new(0,10,0,5)
    title.BackgroundTransparency = 1
    title.Text = "Flames Hub | Debugger"
    title.TextScaled = true
    title.TextColor3 = Color3.new(1,1,1)
    title.Parent = frame
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(26,26)
    close.Position = UDim2.new(1,-32,0,4)
    close.Text = "X"
    close.TextScaled = true
    close.BackgroundColor3 = Color3.fromRGB(120,40,40)
    close.TextColor3 = Color3.new(1,1,1)
    close.Parent = frame
    Instance.new("UICorner", close).CornerRadius = UDim.new(1,0)
    close.MouseButton1Click:Connect(function() gui.Enabled = false end)
    local rescan = Instance.new("TextButton")
    rescan.Size = UDim2.fromOffset(90,24)
    rescan.Position = UDim2.new(1,-130,0,6)
    rescan.Text = "Start Scan"
    rescan.TextScaled = true
    rescan.BackgroundColor3 = Color3.fromRGB(40,90,140)
    rescan.TextColor3 = Color3.new(1,1,1)
    rescan.Parent = frame
    rescan.MouseButton1Click:Connect(function()
        if not genv.__flames_debugger_running then
            genv.__flames_debugger_running = true
            g.dont_receive_any_notifications_flames_hub = true
            start_scan()
        end
    end)
    Instance.new("UICorner", rescan).CornerRadius = UDim.new(0,6)
    local list = Instance.new("ScrollingFrame")
    list.Position = UDim2.new(0,10,0,40)
    list.Size = UDim2.new(1,-20,1,-50)
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.ScrollBarImageTransparency = 0.2
    list.Parent = frame
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,4)
    layout.Parent = list
    local function update_canvas() list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 6) end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_canvas)
    local function add_row(text, success)
        local row = Instance.new("TextLabel")
        row.Size = UDim2.new(1,-6,0,24)
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextScaled = true
        row.TextColor3 = Color3.new(1,1,1)
        row.BackgroundColor3 = success and Color3.fromRGB(30,80,30) or Color3.fromRGB(90,30,30)
        row.Text = (success and "  ?  " or "  ?  ") .. text
        row.Parent = list
    end
    local function snapshot_guis()
        local snap = {}
        for _,v in ipairs(CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") then
                snap[v] = true
            end
        end
        return snap
    end
    local function cleanup_guis(before)
        for _,v in ipairs(CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") and not before[v] and v ~= gui then
                pcall(function()
                v:Destroy()
                end)
            end
        end
    end
    local function clear_list()
        for _,v in ipairs(list:GetChildren()) do
            if v:IsA("TextLabel") then
                v:Destroy()
            end
        end
    end
    if rescan and rescan:IsA("TextButton") then
        task.spawn(function()
            while true do
                wait(0.5)
                if g.button_text_changing_for_debug_scanner then
                    wait(0.5)
                    rescan.Text = "Scan Running."
                    wait(0.6)
                    if not g.button_text_changing_for_debug_scanner then continue end
                    rescan.Text = "Scan Running.."
                    wait(0.6)
                    if not g.button_text_changing_for_debug_scanner then continue end
                    rescan.Text = "Scan Running..."
                    wait(0.6)
                else
                    wait(0.6)
                end
            end
        end)
    end
    start_scan = function()
        task.spawn(function()
            g.button_text_changing_for_debug_scanner = true
            local function run_scan()
                clear_list()
                local tested = 0
                for name,value in next,genv do
                    if tested >= 25 then break end
                    if typeof(value) == "function" and not excluded_functions[name] then
                        tested = tested + 1
                        local before = snapshot_guis()
                        local ok, err = pcall(value)
                        cleanup_guis(before)
                        if ok then
                            add_row(name.."()", true)
                        else
                            if typeof(err) == "string" then
                                local lower = err:lower()
                                if lower:find("nil") or lower:find("argument") or lower:find("index") then
                                    add_row(name.."() - ignore", false)
                                else
                                    add_row(name.."() - runtime error", false)
                                end
                            else
                                add_row(name.."()", false)
                            end
                        end
                        wait(0.5)
                    end
                end
                if tested == 0 then
                    add_row("No functions found to test", false)
                    g.dont_receive_any_notifications_flames_hub = false
                else
                    add_row("Completed testing "..tested.." functions", true)
                    g.dont_receive_any_notifications_flames_hub = false
                end
            end
            pcall(function() run_scan() end)
            task.wait(0.15)
            g.button_text_changing_for_debug_scanner = false
            genv.__flames_debugger_running = false
            g.dont_receive_any_notifications_flames_hub = false
            if rescan and rescan:IsA("TextButton") then rescan.Text = "Start Scan" end
        end)
    end
    local dragging = false
    local drag_start
    local start_pos
    local drag_input
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            drag_start = input.Position
            start_pos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            drag_input = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == drag_input and dragging then
            local delta = input.Position - drag_start
            frame.Position = UDim2.new(
                start_pos.X.Scale,
                start_pos.X.Offset + delta.X,
                start_pos.Y.Scale,
                start_pos.Y.Offset + delta.Y
            )
        end
    end)
end
g.CreateCreditsLabel = function()
    if g.CreditsLabelGui then g.CreditsLabelGui:Destroy() end
    local creditsGui = Instance.new("ScreenGui")
    creditsGui.Name = "PrefixCreditsGui_LifeTogether"
    creditsGui.ResetOnSpawn = false
    creditsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    creditsGui.Parent = CoreGui
    local label = Instance.new("TextLabel")
    label.Name = "CreditsLabel"
    g.MainCreditsLabel_WithPrefix = label
    label.AnchorPoint = Vector2.new(0.5, 1)
    if IsMobile then
        label.Position = UDim2.new(0.5, 0, 0.95, -10)
        label.Size = UDim2.new(0.3, 0, 0, 28)
    else
        label.Position = UDim2.new(0.5, 0, 0.949999988, 25)
        label.Size = UDim2.new(0.6, 0, 0, 28)
    end
    label.BackgroundColor3 = Color3.fromRGB(151, 0, 0)
    label.TextColor3 = Color3.fromRGB(0, 0, 0)
    g.flowrgb("PrefixCreditsLabelConn", 1, label, true)
    local parts = {tostring(g.Script_Version)}
    if holiday ~= "" then table.insert(parts, holiday) end
    table.insert(parts, "Made By: " .. tostring(g.Script_Creator))
    if masked_flames_hub_server_ID then table.insert(parts, "Your Flames-Hub UUID: " .. tostring(masked_flames_hub_server_ID)) end
    label.Text = table.concat(parts, " | ")
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.RichText = false
    label.TextStrokeTransparency = 1
    label.BackgroundTransparency = 0
    label.ZIndex = 10
    label.Parent = creditsGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = label
    g.CreditsLabelGui = creditsGui
    g.CreditsLabelText = label
    if g._PrefixUpdateConnection then g._PrefixUpdateConnection:Disconnect() end
    local holiday_parts = {tostring(g.Script_Version)}
    if holiday ~= "" then table.insert(holiday_parts, holiday) end
    table.insert(holiday_parts, "Made By: " .. tostring(g.Script_Creator))
    if masked_flames_hub_server_ID then table.insert(holiday_parts, "Your Flames-Hub UUID: " .. tostring(masked_flames_hub_server_ID)) end
    label.Text = table.concat(holiday_parts, " | ")
end
g.CreateCreditsLabel()
if g.CreditsLabelGui then g.CreditsLabelGui.Enabled = false end
g.hidden_pcm = setmetatable({}, { __mode = "k" })
g.HidePhoneModels = g.HidePhoneModels or false
g.phone_model_anti_rgb_phone_hider_values = setmetatable({}, { __mode = "k" })
g._pcm_registry = setmetatable({}, { __mode = "k" })
local SavedValues = g.phone_model_anti_rgb_phone_hider_values
g.hide_pcm = g.hide_pcm or function(pcm)
    if not pcm or not pcm:IsA("Model") then return end
    if g.hidden_pcm[pcm] then return end
    SavedValues[pcm] = SavedValues[pcm] or {}
    for _, v in ipairs(pcm:GetDescendants()) do
        if v:IsA("BasePart") then
            SavedValues[pcm][v] = {
                LocalTransparencyModifier = v.LocalTransparencyModifier,
                CanCollide = v.CanCollide,
                CanQuery = v.CanQuery,
                CanTouch = v.CanTouch
            }
            v.LocalTransparencyModifier = 1
            v.CanCollide = false
            v.CanQuery = false
            v.CanTouch = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            SavedValues[pcm][v] = { Transparency = v.Transparency }
            v.Transparency = 1
        elseif v:IsA("Sound") then
            SavedValues[pcm][v] = { Volume = v.Volume }
            v.Volume = 0
        end
    end
    local desc_conn = pcm.DescendantAdded:Connect(function(v)
        if not g.HidePhoneModels then return end
        SavedValues[pcm] = SavedValues[pcm] or {}
        if v:IsA("BasePart") then
            SavedValues[pcm][v] = {
                LocalTransparencyModifier = v.LocalTransparencyModifier,
                CanCollide = v.CanCollide,
                CanQuery = v.CanQuery,
                CanTouch = v.CanTouch
            }
            v.LocalTransparencyModifier = 1
            v.CanCollide = false
            v.CanQuery = false
            v.CanTouch = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            SavedValues[pcm][v] = { Transparency = v.Transparency }
            v.Transparency = 1
        elseif v:IsA("Sound") then
            SavedValues[pcm][v] = { Volume = v.Volume }
            v.Volume = 0
        end
    end)
    g.hidden_pcm[pcm] = { conn = desc_conn }
end
g.show_pcm = g.show_pcm or function(pcm)
    if not pcm or not pcm:IsA("Model") then return end
    local entry = g.hidden_pcm[pcm]
    if not entry then return end
    if entry.conn and entry.conn.Connected then entry.conn:Disconnect() end
    local pcm_saved = SavedValues[pcm]
    if pcm_saved then
        for _, v in ipairs(pcm:GetDescendants()) do
            local orig = pcm_saved[v]
            if not orig then continue end
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = orig.LocalTransparencyModifier
                v.CanCollide = orig.CanCollide
                v.CanQuery = orig.CanQuery
                v.CanTouch = orig.CanTouch
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = orig.Transparency
            elseif v:IsA("Sound") then
                v.Volume = orig.Volume
            end
        end
        SavedValues[pcm] = nil
    end
    g.hidden_pcm[pcm] = nil
end
g.try_hide_pcm = g.try_hide_pcm or function(character)
    if not g.HidePhoneModels then return end
    if not character then return end
    local plr = Players:GetPlayerFromCharacter(character)
    if not plr or plr == LocalPlayer then return end
    local pcm = character:FindFirstChild("PhoneCharacterModel")
    if not pcm then return end
    g.hide_pcm(pcm)
end
g.scan_character = g.scan_character or function(character)
    if not character then return end
    task.defer(function() g.try_hide_pcm(character) end)
    local char_id = tostring(character) .. "_childadded"
    local cleanup_id = tostring(character) .. "_ancestry"
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Model") and child.Name == "PhoneCharacterModel" then
            g._pcm_registry[child] = true
        end
    end
    FlamesLibrary.connect(char_id, character.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name == "PhoneCharacterModel" then
            g._pcm_registry[child] = true
            task.defer(function() if g.HidePhoneModels then g.hide_pcm(child) end end)
        end
    end))
    FlamesLibrary.connect(cleanup_id, character.AncestryChanged:Connect(function(_, parent)
        if not parent then
            FlamesLibrary.disconnect(char_id)
            FlamesLibrary.disconnect(cleanup_id)
        end
    end))
end
g.hook_player = function(plr)
    if plr == Players.LocalPlayer then return end
    local plr_id = tostring(plr.UserId)
    FlamesLibrary.connect(plr_id .. "_charwait", plr.CharacterAdded:Connect(function(char) g.scan_character(char) end))
    local char = plr.Character or g.get_char(plr)
    if char then g.scan_character(char) end
end
FlamesLibrary.disconnect("pmh_playeradded")
FlamesLibrary.disconnect("pmh_playerremoving")
FlamesLibrary.connect("pmh_playeradded", Players.PlayerAdded:Connect(g.hook_player))
FlamesLibrary.connect("pmh_playerremoving", Players.PlayerRemoving:Connect(function(plr)
    local plr_id = tostring(plr.UserId)
    FlamesLibrary.disconnect(plr_id .. "_charadded")
    FlamesLibrary.disconnect(plr_id .. "_charwait")
end))
g.run_hooking_players = function()
    for _, player in ipairs(Players:GetPlayers()) do if player ~= Players.LocalPlayer then g.hook_player(player) end end
end
task.wait()
pcall(function() g.run_hooking_players() end)
g.rescan_all_pcms = g.rescan_all_pcms or function()
    for pcm in pairs(g._pcm_registry) do
        if not pcm.Parent then
            g._pcm_registry[pcm] = nil
            continue
        end
        local char = pcm.Parent
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            if g.HidePhoneModels then
                g.hide_pcm(pcm)
            else
                g.show_pcm(pcm)
            end
        end
    end
end
g.TogglePhoneModelHider = g.TogglePhoneModelHider or function(state)
    if type(state) == "boolean" then
        g.HidePhoneModels = state
    else
        g.HidePhoneModels = not g.HidePhoneModels
    end
    if g.HidePhoneModels then
        g.rescan_all_pcms()
    else
        for pcm in pairs(g.hidden_pcm) do
            g.show_pcm(pcm)
        end
    end
end
g.ShutdownPhoneModelHider = g.ShutdownPhoneModelHider or function()
    for pcm in pairs(g.hidden_pcm) do g.show_pcm(pcm) end
    FlamesLibrary.disconnect("pmh_playeradded")
    FlamesLibrary.disconnect("pmh_playerremoving")
    for _, plr in ipairs(Players:GetPlayers()) do
        local plr_id = tostring(plr.UserId)
        FlamesLibrary.disconnect(plr_id .. "_charadded")
        FlamesLibrary.disconnect(plr_id .. "_charwait")
    end
    table.clear(g.hidden_pcm)
    table.clear(SavedValues)
    table.clear(g._pcm_registry)
end
if not g.FlamesHub_CharacterAdded_Initialized then
    g.FlamesHub_CharacterAdded_Initialized = true
    local function character_added_jump_height_changer_Life_Together_RP(Character)
        Character = g.Character or Character
        if not Character or not Character.Parent then Character = LocalPlayer.Character or g.get_char(LocalPlayer, Players.RespawnTime + 0.75) end
        if not Character or not Character.Parent then return end
        local Humanoid = g.Humanoid
        if not Humanoid or not Humanoid.Parent then Humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid", 10) or g.get_human(LocalPlayer, Players.RespawnTime + 0.75) end
        if Humanoid and Humanoid.Parent then Humanoid.JumpHeight = 7 end
    end
    if g.Character or LocalPlayer.Character then character_added_jump_height_changer_Life_Together_RP(g.Character or LocalPlayer.Character) end
    LocalPlayer.CharacterAdded:Connect(character_added_jump_height_changer_Life_Together_RP)
end
print("[Flames] loading: titles")
g.always_show_title_of_player_regardless_of_chats = g.always_show_title_of_player_regardless_of_chats or function(toggled)
    local lib = g.FlamesLibrary
    local fw = lib.wait
    local key = "showing_billboard_titles_above_heads_anyways"
    if toggled == true then
        if g.always_show_title_above_head then g.notify("Warning", "Flames Hub | Anti-Title_Hider is already enabled!", 5); return end
        g.notify("Success", "Flames Hub | Anti-Title_Hider is now enabled.", 5)
        g.always_show_title_above_head = true
        lib.spawn(key, "spawn", function()
            while g.always_show_title_above_head == true do
            fw(0)
                for _, v in ipairs(Players:GetPlayers()) do
                    if v ~= Players.LocalPlayer then
                        if not v:GetAttribute("chatting") then lib.disconnect("showing_billboard_titles_above_heads_anyways") end
                        v:SetAttribute("chatting", false)
                    end
                end
            end
        end)
    elseif toggled == false then
        if not g.always_show_title_above_head then g.notify("Warning", "Flames Hub | Anti-Title_Hider is not enabled!", 5); return end
        g.always_show_title_above_head = false
        lib.disconnect(key)
        g.notify("Success", "Flames Hub | Anti-Title_Hider is now disabled.", 5)
    else
        return
    end
end
g.change_RP_Name = g.change_RP_Name or function(New_Name) g.Send("roleplay_name", tostring(New_Name)) end
g.change_bio = g.change_bio or function(New_Bio) g.Send("bio", tostring(New_Bio)) end
task.wait()
g.WaitForAttribute = g.WaitForAttribute or function(Instance, Attribute, Timeout)
    local Existing = Instance:GetAttribute(Attribute)
    if Existing ~= nil then return Existing end
    local Start = tick()
    while tick() - Start < (Timeout or 10) do
        local Val = Instance:GetAttribute(Attribute)
        if Val ~= nil then return Val end
        task.wait(0.1)
    end
    return nil
end
g.SafeRead = g.SafeRead or function(File, Fallback)
    if not (isfile and isfile(File)) then return Fallback end
    local Val = readfile(File)
    if not Val or #Val == 0 or Val == "nil" then return Fallback end
    return Val
end
g.SafeAttr = g.SafeAttr or function(Attribute)
    local Val = g.WaitForAttribute(g.LocalPlayer, Attribute, 10)
    if Val == nil then return nil end
    local Str = tostring(Val)
    return (#Str > 0 and Str ~= "nil") and Str or nil
end
if isfile and readfile and writefile and makefolder then
    local Folder = "Life_Together_Custom_Name_Configuration"
    local ConfigPath = Folder .. "/config_" .. tostring(LocalPlayer.UserId) .. ".json"
    if not isfolder(Folder) then makefolder(Folder) end
    local Config = { Name = "DEFAULT", Bio = "DEFAULT" }
    local function sanitize(val)
        if val == nil or tostring(val) == "nil" or tostring(val) == "" then return "DEFAULT" end
        return tostring(val)
    end
    local Existing = g.SafeRead(ConfigPath, nil)
    if Existing then
        local Decoded = HttpService:JSONDecode(Existing)
        if Decoded then
            Config.Name = sanitize(Decoded.Name)
            Config.Bio = sanitize(Decoded.Bio)
        end
    else
        writefile(ConfigPath, HttpService:JSONEncode(Config))
        g.notify("Success", "Creating config file for you (it didn't exist)...", 10)
    end
    if Config.Name ~= "DEFAULT" then
        g.notify("Success", "Got your last RP name (it was erased by Life Together RP), but we're setting it back!", 15)
        g.change_RP_Name(Config.Name)
    else
        local Name_To_Write = sanitize(g.SafeAttr("roleplay_name"))
        local ok_old, old_shared = pcall(function() return HttpService:JSONDecode(g.SafeRead(Folder .. "/config.json", "{}")) end)
        local other_name = ok_old and type(old_shared) == "table" and old_shared.Name or nil
        if Name_To_Write ~= "DEFAULT" and Name_To_Write ~= other_name then
            g.change_RP_Name(Name_To_Write)
            Config.Name = Name_To_Write
        end
    end
    local bio_config = Config
    local bio_config_path = ConfigPath
    lib.spawn("lt_bio_delay", "delay", 61, function()
        if bio_config.Bio ~= "DEFAULT" then
            g.notify("Success", "Got your last RP bio (it was erased by Life Together RP), but we're setting it back!", 15)
            local sanitized_bio = sanitize(bio_config.Bio)
            if sanitized_bio == "DEFAULT" then
                g.change_bio("DEFAULT")
                bio_config.Bio = "DEFAULT"
            else
                g.change_bio(sanitized_bio)
                bio_config.Bio = sanitized_bio
            end
        else
            local Bio_To_Write = sanitize(g.SafeAttr("bio"))
            if Bio_To_Write ~= "DEFAULT" then
                g.change_bio(Bio_To_Write)
                bio_config.Bio = Bio_To_Write
            else
                g.change_bio("DEFAULT")
                bio_config.Bio = "DEFAULT"
            end
        end
        writefile(bio_config_path, HttpService:JSONEncode(bio_config))
    end)
    writefile(ConfigPath, HttpService:JSONEncode(Config))
    if g.lt_rp_name_conn then pcall(function() g.lt_rp_name_conn:Disconnect() end) end
    g.lt_rp_name_conn = LocalPlayer:GetAttributeChangedSignal("roleplay_name"):Connect(function()
        local name = sanitize(LocalPlayer:GetAttribute("roleplay_name"))
        if name == "DEFAULT" or name == Config.Name then return end
        Config.Name = name
        pcall(writefile, ConfigPath, HttpService:JSONEncode(Config))
    end)
end
g.job_spammer = g.job_spammer or function(toggle)
    local lib = g.FlamesLibrary
    local key = "job_spammer_loop"
    local fw = lib.wait
    if toggle == true then
        if g.Every_Job then g.notify("Warning", "Job spammer is already enabled! disable it first.", 5); return end
        g.Every_Job = true
        g.notify("Success", "Job Spammer has been enabled.", 5)
        lib.spawn(key, "spawn", function()
            while g.Every_Job == true do
            fw(0)
                g.Send("job", "Police")
                fw(0)
                g.Send("job", "Firefighter")
                fw(0)
                g.Send("job", "Baker")
                fw(0)
                g.Send("job", "Pizza Worker")
                fw(0)
                g.Send("job", "Barista")
                fw(0)
                g.Send("job", "Doctor")
                fw(0)
            end
            lib.disconnect(key)
        end)
    elseif toggle == false then
        if not g.Every_Job then g.notify("Warning", "Job spammer is not enabled! enable it first.", 5); return end
        g.Every_Job = false
        lib.disconnect(key)
        g.notify("Success", "Job Spammer has been disabled.", 5)
    end
end
g.stored_effects_main_tbl = g.stored_effects_main_tbl or {}
g.stored_parts_main_tbl = g.stored_parts_main_tbl or {}
g.parts_seen = g.parts_seen or {}
g.validWorkspacePart = g.validWorkspacePart or function(inst)
    if not inst or not inst.Parent then return false end
    if inst:IsDescendantOf(lighting) then return false end
    if inst:IsDescendantOf(LocalPlayer.Character or Instance.new("Folder")) then return false end
    return true
end
g.saveAndModify = g.saveAndModify or function(inst)
    if g.parts_seen[inst] then return end
    g.parts_seen[inst] = true
    if inst:IsA("BasePart") then
        table.insert(g.stored_parts_main_tbl, {inst = inst, prop = "cast", val = inst.CastShadow})
        inst.CastShadow = false
    elseif inst:IsA("Decal") then
        table.insert(g.stored_parts_main_tbl, {inst = inst, prop = "decal", tex = inst.Texture, transp = inst.Transparency})
        inst.Transparency = 1
        inst.Texture = ""
    elseif inst:IsA("ParticleEmitter") then
        table.insert(g.stored_parts_main_tbl, {inst = inst, prop = "particle", enabled = inst.Enabled, rate = inst.Rate})
        inst.Enabled = false
        inst.Rate = 0
    elseif inst:IsA("Trail") then
        table.insert(g.stored_parts_main_tbl, {inst = inst, prop = "trail", enabled = inst.Enabled})
        inst.Enabled = false
    end
end
g.posteffparts = g.posteffparts or function(toggle)
    local genv = g
    if toggle then
        if genv.post_effects_off_main then return end
        genv.post_effects_off_main = true
        table.clear(genv.stored_effects_main_tbl)
        table.clear(genv.stored_parts_main_tbl)
        table.clear(genv.parts_seen)
        for _, v in ipairs(lighting:GetDescendants()) do
            if v:IsA("PostEffect") then
                table.insert(genv.stored_effects_main_tbl, {inst = v, enabled = v.Enabled})
                v.Enabled = false
            end
        end
        for _, v in ipairs(work:GetDescendants()) do
            if g.validWorkspacePart(v) then
                g.saveAndModify(v)
            end
        end
        genv._saved_fog_start = lighting.FogStart
        genv._saved_fog_end = lighting.FogEnd
        lighting.FogStart = 1e5
        lighting.FogEnd = 1e5
        if genv.parts_disabler_conn then genv.parts_disabler_conn:Disconnect() end
        genv.parts_disabler_conn = work.DescendantAdded:Connect(function(child)
            if not genv.post_effects_off_main then return end
            if not g.validWorkspacePart(child) then return end
            task.defer(function()
                if child.Parent then
                    g.saveAndModify(child)
                end
            end)
        end)
    else
        if not genv.post_effects_off_main then return end
        genv.post_effects_off_main = false
        for _, v in ipairs(genv.stored_effects_main_tbl) do
            if v.inst and v.inst.Parent then
                v.inst.Enabled = v.enabled
            end
        end
        for _, data in ipairs(genv.stored_parts_main_tbl) do
            if data.inst and data.inst.Parent then
                if data.prop == "cast" then
                    data.inst.CastShadow = data.val
                elseif data.prop == "decal" then
                    data.inst.Transparency = data.transp
                    data.inst.Texture = data.tex
                elseif data.prop == "particle" then
                    data.inst.Enabled = data.enabled
                    data.inst.Rate = data.rate
                elseif data.prop == "trail" then
                    data.inst.Enabled = data.enabled
                end
            end
        end
        if genv.parts_disabler_conn then
            genv.parts_disabler_conn:Disconnect()
            genv.parts_disabler_conn = nil
        end
        if genv._saved_fog_start then lighting.FogStart = genv._saved_fog_start end
        if genv._saved_fog_end then lighting.FogEnd = genv._saved_fog_end end
        table.clear(genv.stored_effects_main_tbl)
        table.clear(genv.stored_parts_main_tbl)
        table.clear(genv.parts_seen)
    end
end
g.TogglePostEffectsParts = g.posteffparts
g.FlamesLagReducerFunc = g.FlamesLagReducerFunc or function(toggle)
    if toggle then
        if g.ultimate_lag_reducer then g.notify("Warning", "Flames Hub | Lag Reducer : is already enabled.", 3); return end
        g.ultimate_lag_reducer = true
        g.notify("Success", "Flames Hub | Lag Reducer : is now enabled.", 5)
        pcall(function() g.Send("hide_other_names", true) end)
        pcall(function() g.Send("hide_map_icon", true) end)
        if g.togglergbflows and typeof(g.togglergbflows) == "function" then pcall(g.togglergbflows, false) end
        g.posteffparts(true)
    else
        if not g.ultimate_lag_reducer then g.notify("Warning", "Flames Hub | Lag Reducer : is not enabled.", 3); return end
        g.ultimate_lag_reducer = false
        g.notify("Success", "Flames Hub | Lag Reducer : is now disabled.", 5)
        pcall(function() g.Send("hide_other_names", false) end)
        pcall(function() g.Send("hide_map_icon", false) end)
        g.posteffparts(false)
    end
end
g.DefaultSpeed = g.StarterPlayer.CharacterWalkSpeed
g.DefaultJP = g.StarterPlayer.CharacterJumpHeight
g.Old_Workspace_Gravity = g.Workspace.Gravity
g.change_property = g.change_property or function(property, new_property_value)
    local properties_allowed_to_be_changed = {
        WalkSpeed = true,
        JumpHeight = true,
        HipHeight = true
    }
    if properties_allowed_to_be_changed[property] and g.Humanoid then g.Humanoid[property] = new_property_value end
end
g.change_gravity_val = g.change_gravity_val or function(new_val)
    if new_val > 300 then new_val = 196 end
    g.Workspace.Gravity = tonumber(new_val) or 196
end
g.reset_properties = g.reset_properties or function()
   if not g.Humanoid then return end
   g.Humanoid.WalkSpeed = g.DefaultSpeed or 16
   g.Humanoid.JumpHeight = g.DefaultJP or 7
   g.Workspace.Gravity = g.Old_Workspace_Gravity or 196
end
g.rainbow_car = g.rainbow_car or function()
    g.RGB_Vehicle(true)
end
g.stop_rainbow_car = g.stop_rainbow_car or function()
    g.RGB_Vehicle(false)
end
g.rainbow_others_car = g.rainbow_others_car or function(Player)
    g.RGB_Vehicle_Others(Player, true)
end
g.stop_rainbow_others_car = g.stop_rainbow_others_car or function(Player)
    g.RGB_Vehicle_Others(Player, false)
end
local camera = Workspace.CurrentCamera or g.Workspace.CurrentCamera or workspace.CurrentCamera
g.AdonisAdminFlyEnabled = g.AdonisAdminFlyEnabled or false
g.AdonisAdminFlySpeed = g.AdonisAdminFlySpeed or 15
g.FlyConnections = g.FlyConnections or {}
g.FlyPart = g.FlyPart or nil
g.SetAdonisFlySpeed = g.SetAdonisFlySpeed or function(v)
    v = tonumber(v)
    if not v then return end
    g.AdonisAdminFlySpeed = math.clamp(v, 1, 300)
end
g.StartAdonisAdminFlyScript = g.StartAdonisAdminFlyScript or function()
    if g.AdonisAdminFlyEnabled then return end
    g.AdonisAdminFlyEnabled = true
    local dir = {w = false, a = false, s = false, d = false, q = false, e = false}
    local cf = Instance.new("CFrameValue")
    if not g.FlyPart then
        g.FlyPart = Instance.new("Part")
        g.FlyPart.Name = "PART_SURFER"
        g.FlyPart.Anchored = true
        g.FlyPart.Parent = g.StarterPack or cloneref and cloneref(game:GetService("StarterPack")) or game:GetService("StarterPack")
        g.FlyPart.CFrame = g.HumanoidRootPart and g.HumanoidRootPart.CFrame or CFrame.new()
    end
    g.FlyConnections.render = RunService.RenderStepped:Connect(function()
        if not g.AdonisAdminFlyEnabled or not g.HumanoidRootPart then return end
        local speed = tonumber(g.AdonisAdminFlySpeed) or 15
        speed = math.clamp(speed, 1, 300)
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Velocity = Vector3.zero
                v.RotVelocity = Vector3.zero
            end
        end
        g.FlyPart.CFrame = CFrame.new(
            g.FlyPart.CFrame.Position,
            (camera.CFrame * CFrame.new(0, 0, -100)).Position
        )
        local offset = Vector3.zero
        if IsMobile and controlModule then
            local mv = controlModule:GetMoveVector()
            if mv.Magnitude > 0 then offset = (camera.CFrame.LookVector * -mv.Z + camera.CFrame.RightVector * mv.X) * speed end
        else
            local x, y, z = 0, 0, 0
            if dir.w then z = -speed end
            if dir.s then z = speed end
            if dir.a then x = -speed end
            if dir.d then x = speed end
            if dir.q then y = speed end
            if dir.e then y = -speed end
            offset = Vector3.new(x, y, z)
        end
        local moveCF = CFrame.new(offset)
        cf.Value = cf.Value:Lerp(moveCF, 0.2)
        g.FlyPart.CFrame = g.FlyPart.CFrame:Lerp(g.FlyPart.CFrame * cf.Value, 0.2)
        g.HumanoidRootPart.CFrame = g.FlyPart.CFrame
        humanoid.PlatformStand = true
    end)
    g.FlyConnections.inputBegan = UserInputService.InputBegan:Connect(function(input, event)
        if event or not g.AdonisAdminFlyEnabled then return end
        local code, codes = input.KeyCode, Enum.KeyCode
        if code == codes.W then
            dir.w = true
        elseif code == codes.A then dir.a = true
        elseif code == codes.S then dir.s = true
        elseif code == codes.D then dir.d = true
        elseif code == codes.Q then dir.q = true
        elseif code == codes.E then dir.e = true
        elseif code == codes.Space then
            dir.q = true
        end
    end)
    g.FlyConnections.inputEnded = UserInputService.InputEnded:Connect(function(input, event)
        if event or not g.AdonisAdminFlyEnabled then return end
        local code, codes = input.KeyCode, Enum.KeyCode
        if code == codes.W then
            dir.w = false
        elseif code == codes.A then dir.a = false
        elseif code == codes.S then dir.s = false
        elseif code == codes.D then dir.d = false
        elseif code == codes.Q then dir.q = false
        elseif code == codes.E then dir.e = false
        elseif code == codes.Space then
            dir.q = false
        end
    end)
    fw(0.1)
    g.notify("Success", "Fly-3 has been enabled with speed: "..tostring(g.AdonisAdminFlySpeed), 6)
end
g.Stop_Fly_3_Function = g.Stop_Fly_3_Function or function()
    if not g.AdonisAdminFlyEnabled then g.notify("Warning", "Fly-3 is not enabled.", 3); return end
    g.AdonisAdminFlyEnabled = false
    for _, conn in pairs(g.FlyConnections) do if conn then conn:Disconnect() end end
    if next(g.FlyConnections) then g.FlyConnections = {} end
    if g.FlyPart then
        g.FlyPart:Destroy()
        g.FlyPart = nil
    end
    if humanoid and humanoid.Parent and humanoid:IsDescendantOf(game) then humanoid.PlatformStand = false end
end
g.Enabled_Flying = g.Enabled_Flying or false
g.Fly2Speed = g.Fly2Speed or 45
g.Fly2Control = nil
g.fly2InputBegan = nil
g.fly2InputEnded = nil
g.fly2Heartbeat = nil
g.fly2MobileConn = nil
g.EnableFly2 = g.EnableFly2 or function(speed)
    if g.Enabled_Flying then g.notify("Warning", "Fly-2 is already enabled!", 3); return end
    local char = g.Character or plr.Character or g.get_char(plr, 3)
    local HRP = g.HumanoidRootPart or char and char:FindFirstChild("HumanoidRootPart") or g.get_root(plr, 3)
    local Humanoid = g.Humanoid or char and char:FindFirstChildOfClass("Humanoid") or g.get_human(plr, 3)
    if not HRP or not Humanoid then g.notify("Error", "Character is not ready or Humanoid is missing.", 5); return end
    g.Enabled_Flying = true
    g.Fly2Speed = tonumber(speed) or 10
    g.Fly2Control = {F=0,B=0,L=0,R=0}
    local flyY, lastPos = 0, nil
    local gyro = Instance.new("BodyGyro")
    gyro.P = 9e4
    gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.CFrame = HRP.CFrame
    gyro.Name = "Fly2Gyro"
    gyro.Parent = HRP
    local vel = Instance.new("BodyVelocity")
    vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    vel.Velocity = Vector3.zero
    vel.Name = "Fly2Velocity"
    vel.Parent = HRP
    if Humanoid and Humanoid.Parent and Humanoid:IsDescendantOf(game) then Humanoid.PlatformStand = true end
    if not IsMobile then
        if g.fly2InputBegan then g.fly2InputBegan:Disconnect() end
        if g.fly2InputEnded then g.fly2InputEnded:Disconnect() end
        if g.fly2Heartbeat then g.fly2Heartbeat:Disconnect() end
        g.fly2InputBegan = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            local s = g.Fly2Speed
            if input.KeyCode == Enum.KeyCode.W then g.Fly2Control.F = s end
            if input.KeyCode == Enum.KeyCode.S then g.Fly2Control.B = -s end
            if input.KeyCode == Enum.KeyCode.A then g.Fly2Control.L = -s end
            if input.KeyCode == Enum.KeyCode.D then g.Fly2Control.R = s end
            if input.KeyCode == Enum.KeyCode.Space then flyY = s end
            if input.KeyCode == Enum.KeyCode.LeftShift then flyY = -s end
        end)
        g.fly2InputEnded = UIS.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then g.Fly2Control.F = 0 end
            if input.KeyCode == Enum.KeyCode.S then g.Fly2Control.B = 0 end
            if input.KeyCode == Enum.KeyCode.A then g.Fly2Control.L = 0 end
            if input.KeyCode == Enum.KeyCode.D then g.Fly2Control.R = 0 end
            if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then flyY = 0 end
        end)
        g.fly2Heartbeat = RunService.RenderStepped:Connect(function()
            if not g.Enabled_Flying then return end
            local C, cam, SPEED = g.Fly2Control, Workspace.CurrentCamera, g.Fly2Speed * 50
            if C.F~=0 or C.B~=0 or C.L~=0 or C.R~=0 or flyY~=0 then
                local move_vec = ((cam.CFrame.LookVector * (C.F + C.B)) + ((cam.CFrame * CFrame.new(C.L + C.R, flyY * 0.5, 0)).Position - cam.CFrame.Position))
                if move_vec.Magnitude > 0 then vel.Velocity = move_vec.Unit * SPEED end
            else
                vel.Velocity = vel.Velocity * 0.9
            end
            gyro.CFrame = cam.CFrame
            local pos = HRP.Position
            if not lastPos or (pos - lastPos).Magnitude > 1 then
                local part = Instance.new("Part")
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.Size = Vector3.new(1,1,(pos - (lastPos or pos)).Magnitude + 2)
                part.CFrame = CFrame.new((lastPos or pos) + ((pos - (lastPos or pos)) / 2), pos)
                part.Color = g.colors[math.random(1, #g.colors)]
                part.Parent = Workspace
                Debris:AddItem(part, 1)
                lastPos = pos
            end
        end)
        g.notify("Success", "Fly-2 enabled (PC) | Speed: " .. tostring(g.Fly2Speed), 5)
        return
    end
    local controlModule
    local ok, result = pcall(function()
        return g.safe_require(plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    end)
    if ok then controlModule = result end
    g.fly2MobileConn = RunService.RenderStepped:Connect(function()
        if not g.Enabled_Flying then return end
        local cam = Workspace.CurrentCamera
        local s = g.Fly2Speed * 50
        local move = controlModule and controlModule:GetMoveVector() or Vector3.zero
        if move.Magnitude > 0 then
            vel.Velocity = (cam.CFrame.LookVector * -move.Z + cam.CFrame.RightVector * move.X) * s
        else
            vel.Velocity = Vector3.zero
        end
        gyro.CFrame = cam.CFrame
        local pos = HRP.Position
        if not lastPos or (pos - lastPos).Magnitude > 1 then
            local part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = false
            part.Material = Enum.Material.Neon
            part.Size = Vector3.new(1,1,(pos - (lastPos or pos)).Magnitude + 2)
            part.CFrame = CFrame.new((lastPos or pos) + ((pos - (lastPos or pos)) / 2), pos)
            part.Color = g.colors[math.random(1, #g.colors)]
            part.Parent = Workspace
            Debris:AddItem(part, 1)
            lastPos = pos
        end
    end)
    g.notify("Success", "Fly-2 enabled (Mobile) | Speed: " .. tostring(g.Fly2Speed), 5)
end
g.DisableFly2 = g.DisableFly2 or function()
    if not g.Enabled_Flying then g.notify("Warning", "Fly-2 is not enabled, enable it first!", 5); return end
    g.Enabled_Flying = false
    if g.fly2InputBegan then g.fly2InputBegan:Disconnect() end
    if g.fly2InputEnded then g.fly2InputEnded:Disconnect() end
    if g.fly2Heartbeat then g.fly2Heartbeat:Disconnect() end
    if g.fly2MobileConn then g.fly2MobileConn:Disconnect() end
    local HRP = g.HumanoidRootPart or g.Character:FindFirstChild("HumanoidRootPart") or g.get_root(g.LocalPlayer, 3)
    local Humanoid = g.Humanoid or g.Character:FindFirstChildOfClass("Humanoid") or g.get_human(g.LocalPlayer, 3)
    if HRP then for _, v in ipairs(HRP:GetChildren()) do if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end end end
    if Humanoid then Humanoid.PlatformStand = false end
    g.notify("Success", "Fly-2 is now disabled.", 5)
end
g.vehicle_stats_viewer_GUI = g.vehicle_stats_viewer_GUI or function()
    local Vehicles = Workspace:FindFirstChild("Vehicles")
    if not Vehicles or not Vehicles:IsA("Folder") then g.notify("Error", "Vehicles Folder not found!", 3); return end
    if g.Vehicle_Stats_GUI_Active then g.notify("Error", "Vehicle Stats Viewer already running!", 5); return end
    g.Vehicle_Stats_GUI_Active = true
    g.VehicleUI = {}
    g.vehicle_attr_conns = {}
    g.Vehicle_Added_And_Removed_Conns = {}
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VehicleStatsGUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent_gui
    g.VehicleStatsGUI = ScreenGui
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0,300,0,400)
    MainFrame.Position = UDim2.new(0,20,0,100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,12)
    repeat task.wait(1) until MainFrame and MainFrame:IsA("Frame") and ScreenGui:FindFirstChildOfClass("Frame")
    wait(0.5)
    if g.dragify and typeof(g.dragify) == "function" then g.dragify(MainFrame) end
    g.notify("Info", "Loading Vehicle Stats viewer.", 3)
    g.Unhook = function(vehicle)
        local ui = g.VehicleUI[vehicle]
        if not ui then return end
        local conns = g.vehicle_attr_conns[vehicle]
        if conns then for _,c in ipairs(conns) do if c then pcall(function() c:Disconnect() end) end end end
        if ui.Frame then pcall(function() ui.Frame:Destroy() end) end
        g.vehicle_attr_conns[vehicle] = nil
        g.VehicleUI[vehicle] = nil
    end
    g.Hook = function(vehicle)
        if g.VehicleUI[vehicle] then return end
        local ui = g.CreateEntry(vehicle)
        g.VehicleUI[vehicle] = ui
        local conns = {}
        g.vehicle_attr_conns[vehicle] = conns
        table.insert(conns, vehicle:GetAttributeChangedSignal("speed"):Connect(function() ui.Speed.Text = tostring(vehicle:GetAttribute("speed") or 0) end))
        table.insert(conns, vehicle:GetAttributeChangedSignal("acceleration"):Connect(function() ui.Accel.Text = tostring(vehicle:GetAttribute("acceleration") or 0) end))
        table.insert(conns, vehicle:GetAttributeChangedSignal("handling"):Connect(function() ui.Handling.Text = tostring(vehicle:GetAttribute("handling") or 0) end))
        table.insert(conns, vehicle:GetAttributeChangedSignal("color"):Connect(function()
            local c = vehicle:GetAttribute("color")
            if typeof(c) == "Color3" then ui.Color.BackgroundColor3 = c end
        end))
        table.insert(conns, vehicle.AncestryChanged:Connect(function(_, parent) if not parent then g.Unhook(vehicle) end end))
    end
    local Title = Instance.new("TextLabel")
    Title.Text = "Vehicle Stats Viewer"
    Title.Size = UDim2.new(1,-40,0,30)
    Title.Position = UDim2.new(0,10,0,5)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255,255,255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame
    local Close = Instance.new("TextButton")
    Close.Text = "X"
    Close.Size = UDim2.new(0,30,0,30)
    Close.Position = UDim2.new(1,-35,0,5)
    Close.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Close.TextColor3 = Color3.fromRGB(255,255,255)
    Close.Parent = MainFrame
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)
    Close.MouseButton1Click:Connect(function()
        g.Vehicle_Stats_GUI_Active = false
        if g.Vehicle_Added_And_Removed_Conns then
            for _, conn in pairs(g.Vehicle_Added_And_Removed_Conns) do
                pcall(function() conn:Disconnect() end)
            end
            table.clear(g.Vehicle_Added_And_Removed_Conns)
        end
        for v in pairs(g.VehicleUI) do g.Unhook(v) end
        ScreenGui:Destroy()
    end)
    local Scroller = Instance.new("ScrollingFrame")
    Scroller.Size = UDim2.new(1,-20,1,-90)
    Scroller.Position = UDim2.new(0,10,0,40)
    Scroller.CanvasSize = UDim2.new(0,0,0,0)
    Scroller.ScrollBarThickness = 6
    Scroller.BackgroundTransparency = 1
    Scroller.Parent = MainFrame
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0,10)
    Layout.Parent = Scroller
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroller.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
    end)
    local function Validate_Model(v)
        if not v:IsA("Model") then return false end
        if v:FindFirstChild("Base") then return true end
        v:WaitForChild("Base", 3)
        return v:FindFirstChild("Base") ~= nil
    end
    g.get_color_name = function(color)
        if not color or typeof(color) ~= "Color3" then return "Unknown" end
        local get_color_name_colors = {
            {"White",1,242,243,243},
            {"Grey",2,161,165,162},
            {"Light yellow",3,249,233,153},
            {"Brick yellow",5,215,197,154},
            {"Light green (Mint)",6,194,218,184},
            {"Light reddish violet",9,232,186,200},
            {"Pastel Blue",11,128,187,219},
            {"Light orange brown",12,203,132,66},
            {"Nougat",18,204,142,105},
            {"Bright red",21,196,40,28},
            {"Med. reddish violet",22,196,112,160},
            {"Bright blue",23,13,105,172},
            {"Bright yellow",24,245,205,48},
            {"Earth orange",25,98,71,50},
            {"Black",26,27,42,53},
            {"Dark grey",27,109,110,108},
            {"Dark green",28,40,127,71},
            {"Medium green",29,161,196,140},
            {"Lig. Yellowich orange",36,243,207,155},
            {"Bright green",37,75,151,75},
            {"Dark orange",38,160,95,53},
            {"Light bluish violet",39,193,202,222},
            {"Transparent",40,236,236,236},
            {"Tr. Red",41,205,84,75},
            {"Tr. Lg blue",42,193,223,240},
            {"Tr. Blue",43,123,182,232},
            {"Tr. Yellow",44,247,241,141},
            {"Light blue",45,180,210,228},
            {"Tr. Flu. Reddish orange",47,217,133,108},
            {"Tr. Green",48,132,182,141},
            {"Tr. Flu. Green",49,248,241,132},
            {"Phosph. White",50,236,232,222},
            {"Light red",100,238,196,182},
            {"Medium red",101,218,134,122},
            {"Medium blue",102,110,153,202},
            {"Light grey",103,199,193,183},
            {"Bright violet",104,107,50,124},
            {"Br. yellowish orange",105,226,155,64},
            {"Bright orange",106,218,133,65},
            {"Bright bluish green",107,0,143,156},
            {"Earth yellow",108,104,92,67},
            {"Bright bluish violet",110,67,84,147},
            {"Tr. Brown",111,191,183,177},
            {"Medium bluish violet",112,104,116,172},
            {"Tr. Medi. reddish violet",113,229,173,200},
            {"Med. yellowish green",115,199,210,60},
            {"Med. bluish green",116,85,165,175},
            {"Light bluish green",118,183,215,213},
            {"Br. yellowish green",119,164,189,71},
            {"Lig. yellowish green",120,217,228,167},
            {"Med. yellowish orange",121,231,172,88},
            {"Br. reddish orange",123,211,111,76},
            {"Bright reddish violet",124,146,57,120},
            {"Light orange",125,234,184,146},
            {"Tr. Bright bluish violet",126,165,165,203},
            {"Gold",127,220,188,129},
            {"Dark nougat",128,174,122,89},
            {"Silver",131,156,163,168},
            {"Neon orange",133,213,115,61},
            {"Neon green",134,216,221,86},
            {"Sand blue",135,116,134,157},
            {"Sand violet",136,135,124,144},
            {"Medium orange",137,224,152,100},
            {"Sand yellow",138,149,138,115},
            {"Earth blue",140,32,58,86},
            {"Earth green",141,39,70,45},
            {"Tr. Flu. Blue",143,207,226,247},
            {"Sand blue metallic",145,121,136,161},
            {"Sand violet metallic",146,149,142,163},
            {"Sand yellow metallic",147,147,135,103},
            {"Dark grey metallic",148,87,88,87},
            {"Black metallic",149,22,29,50},
            {"Light grey metallic",150,171,173,172},
            {"Sand green",151,120,144,130},
            {"Sand red",153,149,121,119},
            {"Dark red",154,123,46,47},
            {"Tr. Flu. Yellow",157,255,246,123},
            {"Tr. Flu. Red",158,225,164,194},
            {"Gun metallic",168,117,108,98},
            {"Dark stone grey",199,99,95,98},
            {"Medium stone grey",194,163,162,165},
            {"Light stone grey",208,229,228,223},
            {"Really black",1003,17,17,17},
            {"Really red",1004,255,0,0},
            {"Deep orange",1005,255,176,0},
            {"Alder",1006,180,128,255},
            {"Dusty Rose",1007,163,75,75},
            {"Olive",1008,193,190,66},
            {"New Yeller",1009,255,255,0},
            {"Really blue",1010,0,0,255},
            {"Navy blue",1011,0,32,96},
            {"Deep blue",1012,33,84,185},
            {"Cyan",1013,4,175,236},
            {"CGA brown",1014,170,85,0},
            {"Magenta",1015,170,0,170},
            {"Pink",1016,255,102,204},
            {"Deep orange",1017,255,175,0},
            {"Teal",1018,18,238,212},
            {"Toothpaste",1019,0,255,255},
            {"Lime green",1020,0,255,0},
            {"Camo",1021,58,125,21},
            {"Grime",1022,127,142,100},
            {"Lavender",1023,140,91,159},
            {"Pastel light blue",1024,175,221,255},
            {"Pastel orange",1025,255,201,201},
            {"Pastel violet",1026,177,167,255},
            {"Pastel blue-green",1027,159,243,233},
            {"Pastel green",1028,204,255,204},
            {"Pastel yellow",1029,255,255,204},
            {"Pastel brown",1030,255,204,153},
            {"Royal purple",1031,98,37,209},
            {"Hot pink",1032,255,0,191},
        }
        local closest, closestDist = "Unknown", math.huge
        local r, g, b = color.R * 255, color.G * 255, color.B * 255
        for _, c in ipairs(get_color_name_colors) do
            local _, _, R, G, B = unpack(c)
            local dist = (R - r)^2 + (G - g)^2 + (B - b)^2
            if dist < closestDist then
                closestDist = dist
                closest = c[1]
            end
        end
        return closest
    end
    local function CreateEntry(vehicle)
        local Holder = Instance.new("Frame")
        Holder.Size = UDim2.new(1,0,0,220)
        Holder.BackgroundColor3 = Color3.fromRGB(35,35,35)
        Holder.Parent = Scroller
        Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,10)
        local Click = Instance.new("TextButton")
        Click.Size = UDim2.new(1,0,1,0)
        Click.BackgroundTransparency = 1
        Click.Text = ""
        Click.Parent = Holder
        Click.Activated:Connect(function()
            g.SelectedVehicle = vehicle.Name
        end)
        local spawn = Instance.new("TextButton")
        spawn.Size = UDim2.new(1,-20,0,28)
        spawn.Position = UDim2.new(0,10,1,-34)
        spawn.Text = "Spawn"
        spawn.BackgroundColor3 = Color3.fromRGB(45,45,45)
        spawn.TextColor3 = Color3.fromRGB(255,255,255)
        spawn.Font = Enum.Font.GothamMedium
        spawn.TextSize = 14
        spawn.Parent = Holder
        Instance.new("UICorner", spawn).CornerRadius = UDim.new(0,8)
        spawn.Activated:Connect(function()
            g.SelectedVehicle = vehicle.Name
            g.Send("spawn_vehicle", vehicle.Name)
            local my_vehicle
            local t = tick()
            repeat
                my_vehicle = g.get_vehicle()
                task.wait()
            until my_vehicle or tick() - t > 6
            if not my_vehicle then return end
            local col = vehicle:GetAttribute("color")
            if typeof(col) == "Color3" then
                g.Send("vehicle_color", col, my_vehicle)
            end
        end)
        local function label(txt,y)
            local l = Instance.new("TextLabel")
            l.Text = txt
            l.Size = UDim2.new(1,-10,0,18)
            l.Position = UDim2.new(0,5,0,y)
            l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(180,180,180)
            l.Font = Enum.Font.Gotham
            l.TextSize = 13
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Parent = Holder
            return l
        end
        local name = label("Vehicle: "..vehicle.Name,5)
        name.TextColor3 = Color3.fromRGB(255,255,255)
        name.Font = Enum.Font.GothamMedium
        local owner = label("Owner: N/A",24)
        local maxAcc = label("Max Acceleration: N/A",44)
        local maxSpeed = label("Max Speed: N/A",64)
        local acc60 = label("Acceleration (0 To 60): N/A",84)
        local turn = label("Turn Angle: N/A",104)
        local locked = label("Locked: N/A",124)
        local color = label("Color: N/A",144)
        g.VehicleUI[vehicle] = {
            Frame = Holder,
            Owner = owner,
            MaxAcc = maxAcc,
            MaxSpeed = maxSpeed,
            Acc60 = acc60,
            TurnAngle = turn,
            LockedStatus = locked,
            ColorLabel = color
        }
    end
    local function Update(vehicle)
        local ui = g.VehicleUI[vehicle]
        if not ui then return end
        ui.MaxAcc.Text = "Max Acceleration: "..math.floor(vehicle:GetAttribute("max_acc") or 0)
        ui.MaxSpeed.Text = "Max Speed: "..math.floor(vehicle:GetAttribute("max_speed") or 0)
        ui.Acc60.Text = "Acceleration (0 To 60): "..math.floor(vehicle:GetAttribute("acc_0_60") or 0)
        ui.TurnAngle.Text = "Turn Angle: "..math.floor(vehicle:GetAttribute("turn_angle") or 0)
        ui.LockedStatus.Text = "Locked: "..tostring(vehicle:GetAttribute("locked"))
        local c = vehicle:GetAttribute("color")
        if typeof(c) ~= "Color3" then
            c = g.WaitForAttribute(vehicle, "color", 5)
        end
        if typeof(c) == "Color3" then
            ui.ColorLabel.Text = "Color: "..g.get_color_name(c)
        else
            ui.ColorLabel.Text = "Color: Unknown"
        end
        local owner = vehicle:GetAttribute("OwnerName")
        ui.Owner.Text = "Owner: "..(owner or "Server Spawned")
    end
    local function Hook(vehicle)
        if g.VehicleUI[vehicle] then return end
        if not Validate_Model(vehicle) then return end
        CreateEntry(vehicle)
        Update(vehicle)
        g.vehicle_attr_conns[vehicle] = {}
        for _,a in ipairs({"OwnerName","max_acc","max_speed","acc_0_60","turn_angle","locked","color"}) do
            table.insert(g.vehicle_attr_conns[vehicle], vehicle:GetAttributeChangedSignal(a):Connect(function()
                Update(vehicle)
            end))
        end
    end
    for _,v in ipairs(Vehicles:GetChildren()) do Hook(v) end
    if g.Vehicle_Added_And_Removed_Conns.Child_Added_Watcher then
        pcall(function() g.Vehicle_Added_And_Removed_Conns.Child_Added_Watcher:Disconnect() end)
    end
    if g.Vehicle_Added_And_Removed_Conns.Child_Removed_Watcher then
        pcall(function() g.Vehicle_Added_And_Removed_Conns.Child_Removed_Watcher:Disconnect() end)
    end
    wait(0.25)
    g.Vehicle_Added_And_Removed_Conns.Child_Added_Watcher = Vehicles.ChildAdded:Connect(function(v)
        task.defer(function() Hook(v) end)
    end)
    g.Vehicle_Added_And_Removed_Conns.Child_Removed_Watcher = Vehicles.ChildRemoved:Connect(function(v)
        task.defer(function() g.Unhook(v) end)
    end)
end
g.check_premium_player = g.check_premium_player or function(plr)
    if plr then
        if plr:GetAttribute("is_verified") == true then
            return true
        else
            return false
        end
    else
        return false
    end
end
print("[Flames] loading: ban system")
g.bansystem = g.bansystem or {
    enabled = false,
    list = {},
    connection = nil
}
function addban(input)
    if not input then return nil end
    if typeof(input) == "Instance" and input.Name then
        local n = input.Name:lower()
        g.bansystem.list[n] = true
        return n
    end
    local q = tostring(input):lower()
    if q == "" then return nil end
    for _,v in pairs(Players:GetPlayers()) do
        local ln = v.Name:lower()
        local ld = v.DisplayName:lower()
        if ln:find(q, 1, true) or ld:find(q, 1, true) then
            g.bansystem.list[ln] = true
            g.kick_plr(v)
            return ln
        end
    end
    g.bansystem.list[q] = true
    return q
end
function removeban(input)
    if not input then return nil end
    local q = tostring(input):lower()
    if q == "" then return nil end
    if g.bansystem.list[q] then
        g.bansystem.list[q] = nil
        return q
    end
    for name,_ in pairs(g.bansystem.list) do
        if name:find(q, 1, true) then
            g.bansystem.list[name] = nil
            return name
        end
    end
    return nil
end
function checkban(player)
    local n = player.Name:lower()
    if g.bansystem.list[n] then
        if g.bansystem.enabled then
            g.kick_plr(player)
        end
    end
end
g.start_bansystem = g.start_bansystem or function()
    if g.bansystem.enabled then return end
    if g.bansystem.starting then return end
    g.bansystem.starting = true
    FlamesLibrary.spawn("bansystem_init", "spawn", function()
        local confirmed_owner = false
        for i = 1, 5 do
            if g.is_localplayer_server_owner() then
                confirmed_owner = true
                break
            end
            FlamesLibrary.wait(1)
        end
        if not confirmed_owner then
            g.bansystem.starting = false
            local is_priv = g.is_in_private_server()
            if is_priv == false then
                g.notify("Info", "You're in a public server.", 3)
            else
                g.notify_priv_server_owner()
            end
            return
        end
        g.bansystem.enabled = true
        g.bansystem.starting = false
        for _, p in ipairs(Players:GetPlayers()) do
            FlamesLibrary.spawn("bansystem_check_" .. p.UserId, "spawn", function()
                FlamesLibrary.wait(0.2)
                checkban(p)
            end)
        end
        FlamesLibrary.connect("bansystem_player_added", Players.PlayerAdded:Connect(checkban))
        g.notify("Success", "Ban system enabled.", 5)
    end)
end
task.wait()
if not g.Ban_System_In_Flames_Hub_Has_Been_Started_Already then
    g.Ban_System_In_Flames_Hub_Has_Been_Started_Already = true
    pcall(function() g.start_bansystem() end)
end
g.get_server_admin_title_player = g.get_server_admin_title_player or function()
    for _, obj in g.Character:GetDescendants() do
        if obj.Name:lower():find("server") and obj.Name:lower():find("admin") and obj:IsA("TextLabel") then
            return obj
        end
    end
    return
end
g.flash_server_admin_title_client_sided = g.flash_server_admin_title_client_sided or function(toggle)
    local localplayer_admin_of_priv_server = g.get_server_admin_title_player()
    if not localplayer_admin_of_priv_server then return end
    local fw = g.FlamesLibrary.wait
    local preset_texts = {"Flames Admin", "Server Admin", "Destroyer Admin", "Owner Admin", "Demon Admin", "Straight Crime", "Powerful Admin", "Creator Admin", "fLaMeS rUlEs", "FLAMES ADMIN"}
    if toggle == true then
        if g.Server_Admin_Text_Title_Changer then g.notify("Warning", "Server Admin Title Text changer is already enabled!", 5); return end
        g.Server_Admin_Text_Title_Changer = true
        g.FlamesLibrary.spawn("server_admin_title_text_changer_main_loop", "spawn", function()
            while g.Server_Admin_Text_Title_Changer == true do
            fw(0)
                for _, text in ipairs(preset_texts) do
                    localplayer_admin_of_priv_server.Text = text
                    fw(0)
                end
            end
        end)
    elseif toggle == false then
        if not g.Server_Admin_Text_Title_Changer then g.notify("Warning", "Server Admin Title Text changer is not enabled!", 5); return end
        g.Server_Admin_Text_Title_Changer = false
        g.FlamesLibrary.disconnect("server_admin_title_text_changer_main_loop")
    else
        return
    end
end
local PANTS_ID = 72466003952524
local SHIRT_ID = 119513877062851
local CLOTHING_IDS = {Pants = PANTS_ID, Shirt = SHIRT_ID}
local MODESTY_ITEMS = {
    __modesty_pants = {class = "Pants", property = "PantsTemplate", template_id = "4667236106"},
    __modesty_shirt = {class = "Shirt", property = "ShirtTemplate", template_id = "121149625778724"},
}
local CONNECTION_NAMES = {"clothing_child_added", "clothing_child_removed", "clothing_char_added"}
g.anti_clothing_ban_enabled = g.anti_clothing_ban_enabled or false
g.is_applying = g.is_applying or false
g.pending_clothing = g.pending_clothing or {}
g.apply_clothing = function(classes)
    if not g.Get or typeof(g.Get) ~= "function" then g.notify("Error", "g.Get is not available or does not exist (patched?).", 3); return end
    for _, class_name in ipairs(classes) do g.Get("wear", CLOTHING_IDS[class_name], class_name) end
end
g.safe_apply_clothing = function(classes)
    if g.is_applying then return end
    g.is_applying = true
    g.notify("Success", "Flames Hub | Applying Safe Clothing (Anti-Clothing-Ban).", 1.5)
    local success, reason = pcall(g.apply_clothing, classes)
    if not success then g.notify("Error", tostring(reason), 5) end
    task.delay(0.5, function() g.is_applying = false end)
end
g.is_valid_character = function(c) return c and c:FindFirstChild("HumanoidRootPart") and c:IsDescendantOf(workspace) end
g.get_clothing_class = function(child)
    if child:IsA("Shirt") then return "Shirt" end
    if child:IsA("Pants") then return "Pants" end
    return nil
end
g.get_modesty_class = function(child)
    local entry = MODESTY_ITEMS[child.Name]
    if entry and child:IsA(entry.class) then return entry.class end
    for _, item in pairs(MODESTY_ITEMS) do
        if child:IsA(item.class) then
            local ok, template = pcall(function() return child[item.property] end)
            if ok and type(template) == "string" and string.find(template, item.template_id, 1, true) then return item.class end
        end
    end
    return nil
end
g.needs_restore = function(character, class_name)
    for _, child in ipairs(character:GetChildren()) do if child:IsA(class_name) and not g.get_modesty_class(child) then return false end end
    return true
end
g.flush_clothing = function(character)
    if not g.anti_clothing_ban_enabled then
        table.clear(g.pending_clothing)
        return
    end
    if g.is_applying then
        task.delay(0.3, g.flush_clothing, character)
        return
    end
    local classes = {}
    for class_name in pairs(g.pending_clothing) do
        g.pending_clothing[class_name] = nil
        if g.is_valid_character(character) and g.needs_restore(character, class_name) then table.insert(classes, class_name) end
    end
    if #classes == 0 then return end
    g.safe_apply_clothing(classes)
end
g.queue_clothing = function(character, class_name)
    if not g.anti_clothing_ban_enabled then return end
    g.pending_clothing[class_name] = true
    task.delay(0.25, g.flush_clothing, character)
end
g.watch_clothing = function(character)
    if not g.anti_clothing_ban_enabled then return end
    if not g.is_valid_character(character) then return end
    table.clear(g.pending_clothing)
    FlamesLibrary.connect("clothing_child_added", character.ChildAdded:Connect(function(child)
        if not g.anti_clothing_ban_enabled then return end
        local class_name = g.get_modesty_class(child)
        if not class_name then return end
        if not g.is_valid_character(g.get_char(speaker)) then return end
        g.queue_clothing(character, class_name)
    end))
    FlamesLibrary.connect("clothing_child_removed", character.ChildRemoved:Connect(function(child)
        if not g.anti_clothing_ban_enabled then return end
        local class_name = g.get_clothing_class(child)
        if not class_name then return end
        if not g.is_valid_character(g.get_char(speaker)) then return end
        g.queue_clothing(character, class_name)
    end))
    for _, child in ipairs(character:GetChildren()) do
        local class_name = g.get_modesty_class(child)
        if class_name then g.queue_clothing(character, class_name) end
    end
end
g.toggle_anti_clothing_ban_system = function(state)
    if state == true then
        if g.anti_clothing_ban_enabled then return end
        g.anti_clothing_ban_enabled = true
        local char = g.Character or speaker.Character or g.get_char(speaker)
        if g.is_valid_character(char) then g.watch_clothing(char) end
        FlamesLibrary.connect("clothing_char_added", speaker.CharacterAdded:Connect(function(new_char)
            if not g.anti_clothing_ban_enabled then return end
            if not g.is_valid_character(new_char) then return end
            g.watch_clothing(new_char)
        end))
        g.notify("Success", "Flames Hub | Anti-Clothing-Ban enabled.", 3)
    elseif state == false then
        if not g.anti_clothing_ban_enabled then return end
        g.anti_clothing_ban_enabled = false
        for _, connection_name in ipairs(CONNECTION_NAMES) do FlamesLibrary.disconnect(connection_name) end
        table.clear(g.pending_clothing)
        g.is_applying = false
        g.notify("Success", "Flames Hub | Anti-Clothing-Ban disabled.", 3)
    else
        return
    end
end
g.is_tool_colorable = g.is_tool_colorable or function(tool)
    if tool:IsA("Tool") and (tool:GetAttribute("color1") or tool:GetAttribute("Color1")) then
        return true
    else
        return false
    end
end
g.find_backpack_tool = g.find_backpack_tool or function()
    for _, v in ipairs(g.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v:GetAttribute("color1") or v:GetAttribute("Color1")) then
            return v
        end
    end
    return nil
end
g.find_character_tool = g.find_character_tool or function()
    for _, v in ipairs(g.Character:GetChildren()) do
        if v:IsA("Tool") and (v:GetAttribute("color1") or v:GetAttribute("Color1")) then
            return v
        end
    end
    return nil
end
g.find_placed_models_tool = g.find_placed_models_tool or function()
    for _, v in ipairs(g.Workspace:FindFirstChild("PlacedModels"):GetChildren()) do
        if v:IsA("Model") and (v:GetAttribute("color1") or v:GetAttribute("Color1")) then
            if v:GetAttribute("owner_id") == g.LocalPlayer.UserId then
                return v
            end
        end
    end
    return nil
end
g.find_owned_model = g.find_owned_model or function()
    local folder = Workspace:FindFirstChild("PlacedModels")
    if not folder or not folder:IsA("Folder") then return nil end
    local uid = speaker.UserId
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") and model:GetAttribute("owner_id") == uid then
            return model
        end
    end
    return nil
end
g.rainbow_tool = g.rainbow_tool or function(toggled)
    if toggled then
        g.notify("Success", "Flames Hub | RGB Tools is now enabled.", 5)
        local tool = g.find_character_tool() or g.find_backpack_tool() or g.find_placed_models_tool()
        if not tool then
            g.Send("get_tool", "Gift")
            g.notify("Warning", "Wait! We're giving you a colorable Tool...", 5)
            fw(0.2)
            tool = g.find_character_tool() or g.find_backpack_tool() or g.find_placed_models_tool()
            if not tool then g.notify("Error", "Tool still not found after giving you the Gift Tool.", 5); return end
            if tool.Parent == g.Backpack then
                fw(0.1)
                tool.Parent = g.Character
            end
            for _, color in ipairs(g.colors) do
                g.Send("tool_color", tool, "color1", color)
                wait()
            end
        end
        if tool.Parent == g.Backpack then
            fw(0.1)
            tool.Parent = g.Character
        end
        g.Rainbow_Tools_FE = true
        while g.Rainbow_Tools_FE do
            tool = g.find_character_tool() or g.find_backpack_tool() or g.find_placed_models_tool()
            if not tool then
                g.Rainbow_Tools_FE = false
                g.notify("Error", "Tool unexpectedly disappeared or was destroyed.", 5)
                return
            end
            if tool.Parent == g.Backpack then
                fw(0.1)
                tool.Parent = g.Character
            end
            for _, color in ipairs(g.colors) do
                if not g.Rainbow_Tools_FE then break end
                g.Send("tool_color", tool, "color1", color)
                wait()
            end
        end
    else
        if not g.Rainbow_Tools_FE then g.notify("Warning", "Flames Hub | RGB Tools is not enabled!", 5); return end
        g.Rainbow_Tools_FE = false
        g.notify("Success", "Flames Hub | RGB Tools is now disabled.", 5)
    end
end
g.toggle_name_func = g.toggle_name_func or function(boolean)
    if boolean == true then
        g.Send("hide_name", true)
    elseif boolean == false then
        g.Send("hide_name", false)
    else
        return
    end
end
g.flashy_name = g.flashy_name or function(Toggle)
    local FL = g.FlamesLibrary
    if Toggle == true then
        if g.Flashing_Name_Title then g.notify("Warning", "Name-Flasher is already enabled.", 5); return end
        g.Flashing_Name_Title = true
        FL.spawn("flashy_name_loop", "spawn", function()
            while g.Flashing_Name_Title == true do
                g.toggle_name_func(true)
                fw(0)
                g.toggle_name_func(false)
                fw(0)
            end
        end)
    elseif Toggle == false then
        if not g.Flashing_Name_Title then g.notify("Warning", "Name-Flasher is not enabled.", 5); return end
        g.Flashing_Name_Title = false
        FL.disconnect("flashy_name_loop")
        fw(1.5)
        g.toggle_name_func(false)
    else
        g.notify("Error", "Invalid argument(s) provided.", 5)
        return
    end
end
g.flames_nameless_admin_ver = g.flames_nameless_admin_ver or function()
    if g.RealNamelessLoaded then g.notify("Warning", "Nameless Admin (or the Flames Hub version) has already been loaded.", 11); return  end
    loadstring(g.http_get('https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/main/Source.lua'))()
end
g.infinite_premium = g.infinite_premium or function()
    if g.GET_LOADED_IY then g.notify("Warning", "You already have Infinite Premium running.", 5); return end
    if g.IY_LOADED then g.notify("Warning", "You already have Infinite Yield running! You cannot and should NOT run both at the same time.", 10); return end
    loadstring(g.http_get('https://pastefy.app/b052AUgc/raw'))()
end
g.infinite_yield = g.infinite_yield or function()
    if g.IY_LOADED then g.notify("Warning", "You already have Infinite Yield running.", 10); return end
    if g.GET_LOADED_IY then g.notify("Warning", "You already have Infinite Premium running! You cannot and should NOT run both at the same time.", 15); return end
    loadstring(g.http_get("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end
g.send_msg_menu = g.send_msg_menu or function()
    if g.sendmsgmenu_loaded then g.notify("Warning", "Send message menu is already loaded!", 5); return end
    g.sendmsgmenu_loaded = true
    local tween = g.TweenService
    local players = g.Players
    local gui = Instance.new("ScreenGui")
    gui.Name = tostring(g.randomString())
    gui.ResetOnSpawn = false
    gui.Parent = parent_gui
    gui.IgnoreGuiInset = true
    local message_menu_frame = Instance.new("Frame")
    message_menu_frame.Parent = gui
    message_menu_frame.AnchorPoint = Vector2.new(0.5,0.5)
    message_menu_frame.Position = UDim2.new(0.5,0,0.5,0)
    message_menu_frame.Size = UDim2.new(0,350,0,0)
    message_menu_frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
    message_menu_frame.BackgroundTransparency = 1
    message_menu_frame.BorderSizePixel = 0
    Instance.new("UICorner",message_menu_frame).CornerRadius = UDim.new(0,15)
    tween:Create(message_menu_frame,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
        Size = UDim2.new(0,350,0,360),
        BackgroundTransparency = 0
    }):Play()
    local title = Instance.new("TextLabel")
    title.Parent = message_menu_frame
    title.Size = UDim2.new(1, -110, 0, 35)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "> Life Together RP - Message Sender <"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(0, 0, 255)
    title.TextTransparency = 1
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    tween:Create(title,TweenInfo.new(0.3),{TextTransparency = 0}):Play()
    local refreshbtn = Instance.new("TextButton")
    refreshbtn.Parent = message_menu_frame
    refreshbtn.Size = UDim2.new(0,70,0,26)
    refreshbtn.Position = UDim2.new(1, -110, 0, 5)
    refreshbtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    refreshbtn.TextColor3 = Color3.fromRGB(255,255,255)
    refreshbtn.Text = "Refresh"
    refreshbtn.Font = Enum.Font.Gotham
    refreshbtn.TextScaled = true
    refreshbtn.BorderSizePixel = 0
    Instance.new("UICorner",refreshbtn).CornerRadius = UDim.new(0,6)
    refreshbtn.BackgroundTransparency = 1
    refreshbtn.TextTransparency = 1
    tween:Create(refreshbtn,TweenInfo.new(0.25),{BackgroundTransparency = 0, TextTransparency = 0}):Play()
    local closebtn = Instance.new("TextButton")
    closebtn.Parent = message_menu_frame
    closebtn.Size = UDim2.new(0, 30, 0, 30)
    closebtn.Position = UDim2.new(1, -30, 0, 0)
    closebtn.BackgroundColor3 = Color3.fromRGB(220,50,50)
    closebtn.TextColor3 = Color3.fromRGB(255,255,255)
    closebtn.Text = "X"
    closebtn.Font = Enum.Font.GothamBold
    closebtn.TextScaled = true
    closebtn.BorderSizePixel = 0
    Instance.new("UICorner",closebtn).CornerRadius = UDim.new(0,8)
    closebtn.BackgroundTransparency = 1
    closebtn.TextTransparency = 1
    tween:Create(closebtn,TweenInfo.new(0.25),{BackgroundTransparency = 0, TextTransparency = 0}):Play()
    local search = Instance.new("TextBox")
    search.Parent = message_menu_frame
    search.Size = UDim2.new(1,-20,0,30)
    search.Position = UDim2.new(0,10,0,50)
    search.BackgroundColor3 = Color3.fromRGB(45,45,45)
    search.TextColor3 = Color3.fromRGB(255,255,255)
    search.Text = ""
    search.PlaceholderText = "Search players..."
    search.Font = Enum.Font.Gotham
    search.TextScaled = true
    search.BackgroundTransparency = 1
    search.TextTransparency = 1
    Instance.new("UICorner",search).CornerRadius = UDim.new(0,8)
    tween:Create(search,TweenInfo.new(0.25),{BackgroundTransparency = 0, TextTransparency = 0}):Play()
    local playerscroll = Instance.new("ScrollingFrame")
    playerscroll.Parent = message_menu_frame
    playerscroll.Size = UDim2.new(1,-20,0,140)
    playerscroll.Position = UDim2.new(0,10,0,90)
    playerscroll.CanvasSize = UDim2.new(0,0,0,0)
    playerscroll.ScrollBarThickness = 5
    playerscroll.BackgroundColor3 = Color3.fromRGB(40,40,40)
    playerscroll.BorderSizePixel = 0
    playerscroll.BackgroundTransparency = 1
    Instance.new("UICorner",playerscroll).CornerRadius = UDim.new(0,10)
    tween:Create(playerscroll,TweenInfo.new(0.25),{BackgroundTransparency = 0}):Play()
    local layout = Instance.new("UIListLayout",playerscroll)
    layout.Padding = UDim.new(0,5)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    if g.dragify and typeof(g.dragify) == "function" then g.dragify(message_menu_frame) end
    local selected = nil
    local function refresh()
        for _,v in ipairs(playerscroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        selected = nil
        local filter = string.lower(search.Text or "")
        for _,plr in ipairs(players:GetPlayers()) do
            if plr ~= players.LocalPlayer then
                if filter == "" or string.find(string.lower(plr.Name), filter, 1, true) then
                    local b = Instance.new("TextButton")
                    b.Parent = playerscroll
                    b.Size = UDim2.new(1,-10,0,30)
                    b.BackgroundColor3 = Color3.fromRGB(55,55,55)
                    b.TextColor3 = Color3.fromRGB(255,255,255)
                    b.Text = plr.Name
                    b.Font = Enum.Font.Gotham
                    b.TextScaled = true
                    b.BorderSizePixel = 0
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
                    b.MouseButton1Click:Connect(function()
                        if selected == b then
                            b.BackgroundColor3 = Color3.fromRGB(55,55,55)
                            selected = nil
                            return
                        end
                        if selected then
                            selected.BackgroundColor3 = Color3.fromRGB(55,55,55)
                        end
                        selected = b
                        b.BackgroundColor3 = Color3.fromRGB(30,200,80)
                    end)
                end
            end
        end
        playerscroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end
    search:GetPropertyChangedSignal("Text"):Connect(refresh)
    refreshbtn.MouseButton1Click:Connect(refresh)
    if not g._msgmenu_connections then
        g._msgmenu_connections = true
        players.PlayerAdded:Connect(refresh)
        players.PlayerRemoving:Connect(refresh)
    end
    task.delay(0.1, refresh)
    local amount = Instance.new("TextBox")
    amount.Parent = message_menu_frame
    amount.Size = UDim2.new(1,-20,0,30)
    amount.Position = UDim2.new(0,10,0,235)
    amount.BackgroundColor3 = Color3.fromRGB(45,45,45)
    amount.TextColor3 = Color3.fromRGB(255,255,255)
    amount.Text = "1"
    amount.PlaceholderText = "Number of messages (max 15)."
    amount.Font = Enum.Font.Gotham
    amount.TextScaled = true
    amount.BackgroundTransparency = 1
    amount.TextTransparency = 1
    Instance.new("UICorner",amount).CornerRadius = UDim.new(0,10)
    tween:Create(amount,TweenInfo.new(0.25),{BackgroundTransparency = 0, TextTransparency = 0}):Play()
    local msgbox = Instance.new("TextBox")
    msgbox.Parent = message_menu_frame
    msgbox.Size = UDim2.new(1,-20,0,40)
    msgbox.Position = UDim2.new(0,10,0,275)
    msgbox.BackgroundColor3 = Color3.fromRGB(45,45,45)
    msgbox.TextColor3 = Color3.fromRGB(255,255,255)
    msgbox.Text = ""
    msgbox.PlaceholderText = "Enter message..."
    msgbox.Font = Enum.Font.Gotham
    msgbox.TextScaled = true
    msgbox.BackgroundTransparency = 1
    msgbox.TextTransparency = 1
    Instance.new("UICorner",msgbox).CornerRadius = UDim.new(0,10)
    tween:Create(msgbox,TweenInfo.new(0.25),{BackgroundTransparency = 0, TextTransparency = 0}):Play()
    local sendbtn = Instance.new("TextButton")
    sendbtn.Parent = message_menu_frame
    sendbtn.Size = UDim2.new(1,-20,0,35)
    sendbtn.Position = UDim2.new(0,10,0,320)
    sendbtn.BackgroundColor3 = Color3.fromRGB(60,120,255)
    sendbtn.TextColor3 = Color3.fromRGB(255,255,255)
    sendbtn.Text = "Send Message"
    sendbtn.Font = Enum.Font.GothamBold
    sendbtn.TextScaled = true
    sendbtn.BorderSizePixel = 0
    sendbtn.BackgroundTransparency = 1
    sendbtn.TextTransparency = 1
    Instance.new("UICorner",sendbtn).CornerRadius = UDim.new(0,10)
    tween:Create(sendbtn,TweenInfo.new(0.25),{BackgroundTransparency = 0, TextTransparency = 0}):Play()
    closebtn.MouseButton1Click:Connect(function()
        tween:Create(message_menu_frame,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
            Size = UDim2.new(0,350,0,0),
            BackgroundTransparency = 1
        }):Play()
        wait(0.25)
        gui:Destroy()
        g.sendmsgmenu_loaded = false
    end)
    sendbtn.MouseButton1Click:Connect(function()
        if not selected then g.notify("Warning", "Select a player first!", 3); return end
        local target = players:FindFirstChild(selected.Text)
        if not target then g.notify("Warning", "Player not found!", 3); return end
        local num = tonumber(amount.Text) or 1
        num = math.clamp(num,1,30)
        local raw = msgbox.Text or ""
        if raw == "" then g.notify("Warning", "Message cannot be empty.", 3); return end
        local msgs = {}
        if raw:find("||",1,true) then
            for part in string.gmatch(raw,"([^|]+)") do
                part = part:gsub("^%s+",""):gsub("%s+$","")
                if part ~= "" then table.insert(msgs,part) end
            end
        else
            table.insert(msgs,raw)
        end
        g.Send_Message_Main_Phone_Messages_Module_Task = g.FlamesLibrary.spawn("send_message_phone_task", "spawn", function()
            for i = 1, num do
                local text = msgs[((i - 1) % #msgs) + 1]
                pcall(function() g.send_msg_phone(target, text) end)
                fw(0.02)
            end
        end)
    end)
end
g.lock_vehicle = g.lock_vehicle or function(Vehicle) g.Get("lock_vehicle", Vehicle) end
g.HasSeen_Loading_Screen = true
g.player_admins = g.player_admins or {}
g.friend_checked = g.friend_checked or {}
g.cmds_loaded_plr = g.cmds_loaded_plr or {}
g.Rainbow_Vehicles = g.Rainbow_Vehicles or {}
g.Locked_Vehicles = g.Locked_Vehicles or {}
g.Unlocked_Vehicles = g.Unlocked_Vehicles or {}
g.Rainbow_Tasks = g.Rainbow_Tasks or {}
g.Rainbow_Delays         = g.Rainbow_Delays         or {}
g.Rainbow_Indices        = g.Rainbow_Indices        or {}
g.Rainbow_Next           = g.Rainbow_Next           or {}
g.Rainbow_CachedVehicle  = g.Rainbow_CachedVehicle  or {}
g.Rainbow_ActiveCount    = g.Rainbow_ActiveCount    or 0
g.Rainbow_MIN_DELAY      = g.Rainbow_MIN_DELAY      or 0.04
g.Rainbow_Colors = g.Rainbow_Colors or {
    Color3.fromRGB(255,255,255), Color3.fromRGB(128,128,128), Color3.fromRGB(0,0,0),
    Color3.fromRGB(0,0,255),     Color3.fromRGB(0,255,0),     Color3.fromRGB(0,255,255),
    Color3.fromRGB(255,165,0),   Color3.fromRGB(139,69,19),   Color3.fromRGB(255,255,0),
    Color3.fromRGB(50,205,50),   Color3.fromRGB(255,0,0),     Color3.fromRGB(255,155,172),
    Color3.fromRGB(128,0,128),
}
g.alreadyCheckedUser = function(player)
    if not g.friend_checked[player.Name] then
        g.player_admins[player.Name] = player
    end
    if not g.friend_checked[player.Name] then
        g.friend_checked[player.Name] = player
    end
    if not g.cmds_loaded_plr[player.Name] then
        g.cmds_loaded_plr[player.Name] = player
    end
end
g.disable_rgb_for = function(plr)
    if not plr then g.notify("Error", "Player was not found when trying to disable RGB vehicle!", 5); return end
    local name = plr.Name
    local state = g.VehicleStates[name]
    if not state then
        if g.Rainbow_Tasks[name] then g.Rainbow_Tasks[name] = nil end
        if g.Rainbow_Indices[name] then g.Rainbow_Indices[name] = nil end
        return
    end
    local handle = g.Rainbow_Tasks[name]
    if handle then pcall(function() task.cancel(handle) end) end
    if g.Rainbow_Tasks[name] then g.Rainbow_Tasks[name] = nil end
    if g.Rainbow_Indices[name] then g.Rainbow_Indices[name] = nil end
    state.rainbow = false
    state.rainbowIndex = nil
    g.notify("Success", "Disabled Rainbow Vehicle for: "..tostring(name), 5)
end
if not g.fully_disable_rgb_plr then g.fully_disable_rgb_plr = g.disable_rgb_for end
task.wait()
g.enable_rgb_for = function(plr)
    if not plr then return end
    local name = plr.Name
    g.VehicleStates[name] = g.VehicleStates[name] or {}
    local state = g.VehicleStates[name]
    local vehicle = g.get_other_vehicle(plr)
    if not vehicle then
        state.rainbow = false
        state.rainbowIndex = nil
        g.Rainbow_Tasks[name] = nil
        g.Rainbow_Indices[name] = nil
        return false, "you don't have a vehicle"
    end
    if g.Rainbow_Tasks[name] then g.disable_rgb_for(plr) end
    state.rainbow = true
    state.rainbowIndex = 0
    g.Rainbow_Indices[name] = 0
    g.Rainbow_Tasks[name] = task.spawn(function()
        while state.rainbow do
            local v = g.get_other_vehicle(plr)
            if not v then
                state.rainbow = false
                state.rainbowIndex = nil
                g.Rainbow_Tasks[name] = nil
                g.Rainbow_Indices[name] = nil
                break
            end
            local i = (state.rainbowIndex or 0) + 1
            state.rainbowIndex = i
            local color = g.Rainbow_Colors[(i % #g.Rainbow_Colors) + 1]
            g.change_vehicle_color(color, v)
            fw(0.2)
        end
        return
    end)
    return true
end
g.find_configuration_manager_GUI = function()
    local find_GUI_main = CoreGui:FindFirstChild("FlamesAdminGUI", true)
    if find_GUI_main and find_GUI_main:IsA("ScreenGui") then return find_GUI_main end
    for _, v in ipairs(CoreGui:GetDescendants()) do
        if v:IsA("ScreenGui") and v.Name:lower():find("flames") and v.Name:lower():find("admin") then
            return v
        end
    end
    return nil
end
g.toggle_config_manager = function(state)
    if state == true then
        if not CoreGui:FindFirstChild("FlamesAdminGUI", true) then g.notify("Error", "Configuration Manager GUI was not found.", 5); return end
        if CoreGui:FindFirstChild("FlamesAdminGUI", true) then
            CoreGui:FindFirstChild("FlamesAdminGUI", true).Enabled = true
        elseif CoreGui:FindFirstChild("FlamesAdminGUI", true) and CoreGui:FindFirstChild("FlamesAdminGUI", true).Enabled then
            return
        end
    elseif state == false then
        if not CoreGui:FindFirstChild("FlamesAdminGUI", true) then g.notify("Error", "Configuration Manager GUI was not found.", 5); return end
        if CoreGui:FindFirstChild("FlamesAdminGUI", true) then
            CoreGui:FindFirstChild("FlamesAdminGUI", true).Enabled = false
        elseif CoreGui:FindFirstChild("FlamesAdminGUI", true) and CoreGui:FindFirstChild("FlamesAdminGUI", true).Enabled then
            return
        end
    else
        return
    end
end
g.set_rgb_delay = function(name, newDelay)
   if type(newDelay) ~= "number" then return false, "invalid time value" end
   if newDelay < g.Rainbow_MIN_DELAY then newDelay = g.Rainbow_MIN_DELAY end
   g.Rainbow_Delays[name] = newDelay
   g.Rainbow_Next[name] = 0
   return true
end
g.VehicleStates = g.VehicleStates or {}
g.setup_cmd_handler_plr = function(player)
    local FL = getgenv().FlamesLibrary
    local prefix = ";"
    local localPlayerName = g.LocalPlayer.Name
    local channel = TextChatService:FindFirstChild("RBXGeneral", true)
    if not player:IsFriendsWith(g.LocalPlayer.UserId) then return end
    local function trim(str) return str:match("^%s*(.-)%s*$") end
    FL.disconnect("cmd_handler_other_players")
    FL.wait(0.5)
    FL.connect("cmd_handler_other_players", TextChatService.MessageReceived:Connect(function(chatMessage)
        local speaker = chatMessage.TextSource
        if not (speaker and speaker.Name ~= localPlayerName and g.player_admins[speaker.Name]) then return end
        local normalizedMessage = trim(chatMessage.Text:lower())
        if normalizedMessage:sub(1, #prefix) ~= prefix then return end
        local speakerPlayer = g.Players[speaker.Name]
        if not speakerPlayer or not speakerPlayer:IsFriendsWith(g.LocalPlayer.UserId) then return end
        local command = normalizedMessage:sub(#prefix + 1)
        local parts = command:split(" ")
        local cmd = parts[1]
        local Name = speaker.Name
        local playerVehicle = g.get_other_vehicle(speakerPlayer)
        g.VehicleStates[Name] = g.VehicleStates[Name] or {
            locked = false,
            unlocked = false,
            rainbow = false,
        }
        local function lev(a, b) return g.levenshtein(a, b) end
        if lev(cmd, "rgbcar") <= 1 then
            if not speakerPlayer then g.notify("Error", "This player does not exist!", 5); return end
            local vehicle = g.get_other_vehicle(speakerPlayer)
            if not vehicle then
                g.Rainbow_Vehicles[Name] = nil
                g.notify("Error", "The player doesn't have a car spawned!", 5)
                return
            end
            g.enable_rgb_for(speakerPlayer)
        elseif lev(cmd, "rgbtime") <= 2 then
            local newDelay = tonumber(parts[2])
            if not newDelay then return end
            if newDelay < 0.1 then newDelay = 0.1 end
            g.Rainbow_Delays[Name] = newDelay
            g.Rainbow_Next[Name] = time()
        elseif lev(cmd, "norgbcar") <= 2 then
            g.disable_rgb_for(speakerPlayer)
        elseif lev(cmd, "lockcar") <= 2 then
            if not playerVehicle then g.LockLoop_Vehicles[Name] = false; return end
            if g.Locked_Vehicles[Name] then return end
            g.Unlocked_Vehicles[Name] = false
            FL.wait(0.1)
            g.Locked_Vehicles[Name] = true
            local v = g.get_other_vehicle(speakerPlayer)
            if v and not v:GetAttribute("locked") then
                g.Get("lock_vehicle", v)
            elseif not v then
                g.Locked_Vehicles[Name] = false
            end
        elseif lev(cmd, "unlockcar") <= 2 then
            if not playerVehicle then g.Unlocked_Vehicles[Name] = false; return end
            if g.Unlocked_Vehicles[Name] then return end
            g.Locked_Vehicles[Name] = false
            FL.wait(0.1)
            g.Unlocked_Vehicles[Name] = true
            local v = g.get_other_vehicle(speakerPlayer)
            if v and v:GetAttribute("locked") then
                g.Get("lock_vehicle", v)
            elseif not v then
                g.Unlocked_Vehicles[Name] = false
            end
        elseif lev(cmd, "trailer") <= 2 then
            if not playerVehicle then g.Unlocked_Vehicles[Name] = false; return end
            local vehicle = g.get_other_vehicle(speakerPlayer)
            if not vehicle or vehicle:FindFirstChild("WaterSkies") then return end
            FL.wait(0.1)
            g.water_skie_trailer(true, vehicle)
        elseif lev(cmd, "notrailer") <= 2 then
            if not playerVehicle then g.Unlocked_Vehicles[Name] = false; return end
            local vehicle = g.get_other_vehicle(speakerPlayer)
            if not vehicle or not vehicle:FindFirstChild("WaterSkies") then return end
            g.water_skie_trailer(false, vehicle)
        elseif cmd:sub(1, 5) == "check" then
            if g.Check_Cooldown then return end
            g.Check_Cooldown = true
            FL.spawn("check_cooldown_reset", "delay", 15, function() g.Check_Cooldown = false end)
            local checkTargetName = parts[2]
            if not checkTargetName or #checkTargetName <= 0 then
                g.notify("Warning", "Target player invalid: " .. tostring(checkTargetName), 1); return
            end
            local target = g.findplr(checkTargetName)
            if not target then
                g.notify("Warning", "Could not find: " .. tostring(checkTargetName), 1); return
            end
            local isVerified = target:GetAttribute("is_verified")
            local general_channel = TextChatService:FindFirstChild("RBXGeneral", true)
                or TextChatService:FindFirstChild("TextChannels") and TextChatService:FindFirstChild("TextChannels"):FindFirstChild("RBXGeneral")
            if general_channel then
                local msg = isVerified == true
                    and "Player: " .. tostring(target.DisplayName) .. " has premium."
                    or  "Player: " .. tostring(target.DisplayName) .. " does not have premium."
                general_channel:SendAsync(msg)
            end
        elseif lev(cmd, "lambo") <= 2 or lev(cmd, "lamborghini") <= 3 then
            g.spawn_any_vehicle("svj")
        elseif lev(cmd, "ferrari") <= 2 or lev(cmd, "sf90") <= 2 or lev(cmd, "corvette") <= 2 then
            g.spawn_any_vehicle("sf90")
        elseif lev(cmd, "bugatti") <= 2 or lev(cmd, "chiron") <= 2 then
            g.spawn_any_vehicle("chiron")
        elseif lev(cmd, "charger") <= 2 or lev(cmd, "chargersrt") <= 3 or lev(cmd, "srtcharger") <= 3 or lev(cmd, "srt") <= 1 then
            g.spawn_any_vehicle("charger")
        elseif lev(cmd, "cmds") <= 2 then
            if g.Is_OnCooldown then return end
            g.Is_OnCooldown = true
            g.Wait_Time_Cooldown = 45
            channel:SendAsync(";lockcar | ;rgbcar | ;norgbcar | ;unlockcar | ;check Player | ;trailer | ;notrailer | ;lambo | ;sf90 | ;charger | ;bugatti")
            FL.spawn("cmd_list_cooldown_reset", "delay", g.Wait_Time_Cooldown, function() g.Is_OnCooldown = false end)
        end
    end))
end
g.addPlayerToScriptWhitelistTable = g.addPlayerToScriptWhitelistTable or function(player)
    if not g.player_admins[player.Name] then
        g.player_admins[player.Name] = player
        fw(0.2)
        if g.player_admins[player.Name] then g.notify("Success", tostring(player.Name)..", was added to Admins Whitelist.", 3) end
    end
end
g.removePlayerFromScriptWhitelistTable = g.removePlayerFromScriptWhitelistTable or function(player)
    if g.player_admins[player.Name] then
        g.player_admins[player.Name] = nil
        fw(0.15)
        if g.player_admins[player.Name] == nil then
            g.notify("Success", tostring(player.Name).." was removed from the Admins Whitelist!", 3)
        else
            g.notify("Error", tostring(player)..", does not exist.", 3)
            return
        end
    end
end
g.start_glitch_script = function()
    if g.SideGlitch_Enabled and FlamesLibrary._connections["SideGlitch_Loop"] and #FlamesLibrary._connections["SideGlitch_Loop"] > 0 then g.notify("Warning", "Flames Hub | Glitch Script is already enabled!", 3); return end
    local char = g.Character or speaker.Character or g.get_char(speaker)
    if not char or not char:IsDescendantOf(game) then return end
    local root  = g.HumanoidRootPart or char and char:FindFirstChild("HumanoidRootPart") or g.get_root(speaker)
    if not root or not root.Parent or not root:IsDescendantOf(game) then return end
    local human = g.Humanoid or char and char:FindFirstChildOfClass("Humanoid")  or g.get_human(speaker)
    if not human or not human.Parent or not human:IsDescendantOf(game) then return end
    if not root or not human or human.Health <= 0 then return end
    local locked_origin = root.CFrame
    local last_flip = 0
    local dir = 1
    g.SideGlitch_Enabled = true
    FlamesLibrary.connect("SideGlitch_Loop", RunService.RenderStepped:Connect(function()
        if not g.SideGlitch_Enabled then return end
        local now      = tick()
        local speed    = math.clamp(g.SideGlitch_Speed or 10, 1, 100)
        local distance = g.SideGlitch_Distance or 1
        local interval = 1 / speed
        if now - last_flip >= interval then
            dir       = -dir
            last_flip = now
        end
        local right = locked_origin.RightVector
        root.CFrame = CFrame.new(locked_origin.Position + right * (dir * distance)) * (locked_origin - locked_origin.Position)
    end))
    FlamesLibrary.connect("SideGlitch_Restore", RunService.RenderStepped:Connect(function()
        if g.SideGlitch_Enabled then return end
        if root.CFrame.Position ~= locked_origin.Position then
            root.CFrame = locked_origin
        else
            FlamesLibrary.disconnect("SideGlitch_Restore")
        end
    end))
end
g.start_smooth_glitch_script = function()
    local char = g.Character or speaker.Character or g.get_char(speaker)
    if not char or not char:IsDescendantOf(game) then return end
    local root  = g.HumanoidRootPart or char and char:FindFirstChild("HumanoidRootPart") or g.get_root(speaker)
    local human = g.Humanoid or char and char:FindFirstChildOfClass("Humanoid") or g.get_human(speaker)
    if not root or not human or human.Health <= 0 then return end
    local locked_origin  = root.CFrame
    local last_flip      = 0
    local dir            = 1
    local current_offset = 0
    local target_offset  = 0
    g.SideGlitch_Enabled  = true
    FlamesLibrary.connect("SideGlitch_Loop", RunService.RenderStepped:Connect(function(dt)
        if not g.SideGlitch_Enabled then return end
        local now      = tick()
        local speed    = math.clamp(g.SideGlitch_Speed    or 5,    1, 100)
        local distance = math.clamp(g.SideGlitch_Distance or 5,    0,  50)
        local smooth   = math.clamp(g.SideGlitch_Smooth   or 0.18, 0,   1)
        local interval = 1 / speed
        if now - last_flip >= interval then
            dir           = -dir
            target_offset = dir * distance
            last_flip     = now
        end
        local alpha   = 1 - (1 - smooth) ^ (dt * 60)
        current_offset = current_offset + (target_offset - current_offset) * alpha
        local rotation_only = locked_origin - locked_origin.Position
        local right          = locked_origin.RightVector
        root.CFrame = CFrame.new(locked_origin.Position + right * current_offset) * rotation_only
    end))
    FlamesLibrary.connect("SideGlitch_Restore", RunService.RenderStepped:Connect(function(dt)
        if g.SideGlitch_Enabled then return end
        local smooth  = math.clamp(g.SideGlitch_Smooth or 0.18, 0, 1)
        local alpha   = 1 - (1 - smooth) ^ (dt * 60)
        current_offset = current_offset + (0 - current_offset) * alpha
        local rotation_only = locked_origin - locked_origin.Position
        local right          = locked_origin.RightVector
        root.CFrame = CFrame.new(locked_origin.Position + right * current_offset) * rotation_only
        if math.abs(current_offset) < 0.01 then
            root.CFrame = locked_origin
            FlamesLibrary.disconnect("SideGlitch_Restore")
        end
    end))
end
print("[Flames] loading: glitch")
g.stop_glitch_script = function()
    g.SideGlitch_Enabled = false
    g.FlamesLibrary.disconnect("SideGlitch_Loop")
end
g.avgSkin = g.avgSkin or function(bc)
    local skin_tone_colors = {
        bc.HeadColor3,
        bc.LeftArmColor3,
        bc.RightArmColor3,
        bc.TorsoColor3,
        bc.LeftLegColor3,
        bc.RightLegColor3
    }
    local r,g,b = 0,0,0
    for _,c in ipairs(skin_tone_colors) do
        r = r + c.R
        g = g + c.G
        b = b + c.B
    end
    return Color3.new(r/6,g/6,b/6)
end
g.clear_avatar = g.clear_avatar or function()
    local args = {
        "wear_outfit_from_desc",
        {
            accessories = {
                {
                    Rotation = "  ",
                    AccessoryType = "Hair",
                    Position = "  ",
                    Scale = "1 1 1",
                    IsLayered = false,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "Face",
                    Position = "  ",
                    Scale = "1 1 1",
                    IsLayered = false,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "Face",
                    Position = "  ",
                    Scale = "1 1 1",
                    IsLayered = false,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "Hat",
                    Position = "  ",
                    Scale = "1 1 1",
                    IsLayered = false,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "Face",
                    Position = "  ",
                    Scale = "1 1 1",
                    IsLayered = false,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "Shirt",
                    Scale = "1 1 1",
                    Position = "  ",
                    Order = 1,
                    IsLayered = true,
                    Puffiness = 0,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "DressSkirt",
                    Scale = "1 1 1",
                    Position = "  ",
                    Order = 2,
                    IsLayered = true,
                    Puffiness = 0,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "RightShoe",
                    Scale = "1 1 1",
                    Position = "  ",
                    Order = 3,
                    IsLayered = true,
                    Puffiness = 0,
                    AssetId = 0
                },
                {
                    Rotation = "  ",
                    AccessoryType = "LeftShoe",
                    Scale = "1 1 1",
                    Position = "  ",
                    Order = 4,
                    IsLayered = true,
                    Puffiness = 0,
                    AssetId = 0
                }
            },
            properties = {
                SwimAnimation = 0,
                RightLegColor = "^zH;",
                MoodAnimation = 0,
                Torso = 0,
                WidthScale = 1,
                BodyTypeScale = 0.25,
                ClimbAnimation = 0,
                LeftArmColor = "^zH;",
                Shirt = 0,
                GraphicTShirt = 0,
                RightArmColor = "^zH;",
                LeftArm = 0,
                RunAnimation = 0,
                JumpAnimation = 0,
                RightArm = 0,
                Face = 0,
                Head = 0,
                DepthScale = 1,
                LeftLegColor = "^zH;",
                FallAnimation = 0,
                Pants = 0,
                HeadColor = "^zH;",
                TorsoColor = "^zH;",
                IdleAnimation = 0,
                RightLeg = 0,
                HeadScale = 1,
                HeightScale = 1,
                ProportionScale = 0,
                LeftLeg = 0
            }
        }
    }
    pcall(function() g.Send(unpack(args)) end)
end
task.wait()
g.height_setter_busy = g.height_setter_busy or false
g.session_original_height = g.session_original_height or nil
g.session_original_width = g.session_original_width or nil
g.session_original_skin = g.session_original_skin or nil
g.session_active = g.session_active or false
g.last_height_scale = g.last_height_scale or nil
g.prev_height_scale = g.prev_height_scale or nil
g.last_skin_tone = g.last_skin_tone or nil
g.prev_skin_tone = g.prev_skin_tone or nil
g.size_setter_busy = g.size_setter_busy or false
g.session_original_width = g.session_original_width or nil
g.session_original_depth = g.session_original_depth or nil
g.session_original_skin = g.session_original_skin or nil
g.session_size_active = g.session_size_active or false
g.last_width_scale = g.last_width_scale or nil
g.last_depth_scale = g.last_depth_scale or nil
g.prev_width_scale = g.prev_width_scale or nil
g.prev_depth_scale = g.prev_depth_scale or nil
g.last_skin_tone_s = g.last_skin_tone_s or nil
g.prev_skin_tone_s = g.prev_skin_tone_s or nil
g.apply_skin_tone = function(color) if not color then return end; pcall(function() g.Send("skin_tone", color) end) end
g.copy_plr_avatar = function(Player)
    if g.is_copying_avatar_already_flames then g.notify("Warning","Avatar copier already in progress!", 3); return end
    g.is_copying_avatar_already_flames = true
    if not Player or not Player.Character then
        g.is_copying_avatar_already_flames = false
        g.notify("Warning","Target not found!",3)
        return
    end
    local hum = Player.Character:FindFirstChildWhichIsA("Humanoid") or g.get_human(Player, Players.RespawnTime + 1)
    if not hum then
        g.is_copying_avatar_already_flames = false
        g.notify("Warning","No humanoid!",3)
        return
    end
    local desc = hum:GetAppliedDescription()
    if not desc then
        g.is_copying_avatar_already_flames = false
        g.notify("Warning","No description!",3)
        return
    end
    if Player.Name == "CIippedByAura" or Player.Name == "L0CKED_1N1" or Player.Name == "AuraWithClipFarmin" then
        g.is_copying_avatar_already_flames = false
        g.notify("Warning", "Do not copy the owner of Flames Hub's avatar!", 10)
        return
    end
    g.notify("Info", "Copying " .. Player.Name .. "'s outfit...", 4)
    local ok, err = pcall(g.lt_copy_outfit, Player)
    if ok then g.notify("Success","Copied avatar from "..Player.Name,5) else g.notify("Error", "Copy failed: " .. tostring(err), 6) end
    g.is_copying_avatar_already_flames = false
end
g.height_func_setter = g.height_func_setter or function(height_input)
    if g.height_setter_busy then return end
    g.height_setter_busy = true
    local player = g.LocalPlayer
    local char = g.Character or player and player.Character
    local hum = g.Humanoid or char and char:FindFirstChildOfClass("Humanoid")
    if not hum then
        g.height_setter_busy = false
        return
    end
    local desc = hum:GetAppliedDescription()
    if not desc then
        g.height_setter_busy = false
        g.notify("Error", "Failed to grab HumanoidDescription.", 3)
        return
    end
    local bodyColors = char and char:FindFirstChildOfClass("BodyColors")
    local current_skin = bodyColors and g.avgSkin(bodyColors)
    if not g.session_active then
        g.session_original_height = desc.HeightScale or 1
        g.session_original_width = desc.WidthScale or 1
        g.session_original_skin = current_skin
        g.session_active = true
    end
    if current_skin then
        g.prev_skin_tone = g.last_skin_tone or current_skin
        g.last_skin_tone = current_skin
    end
    local height = tonumber(height_input) or desc.HeightScale or 1
    g.prev_height_scale = g.last_height_scale or desc.HeightScale or 1
    g.last_height_scale = height
    local properties = {
        Head = desc.Head or 0,
        Torso = desc.Torso or 0,
        LeftArm = desc.LeftArm or 0,
        RightArm = desc.RightArm or 0,
        LeftLeg = desc.LeftLeg or 0,
        RightLeg = desc.RightLeg or 0,
        Face = desc.Face or 0,
        Shirt = desc.Shirt or 0,
        Pants = desc.Pants or 0,
        GraphicTShirt = desc.GraphicTShirt or 0,
        RunAnimation = desc.RunAnimation or 0,
        WalkAnimation = desc.WalkAnimation or 0,
        JumpAnimation = desc.JumpAnimation or 0,
        FallAnimation = desc.FallAnimation or 0,
        ClimbAnimation = desc.ClimbAnimation or 0,
        IdleAnimation = desc.IdleAnimation or 0,
        SwimAnimation = desc.SwimAnimation or 0,
        HeightScale = height,
        WidthScale = desc.WidthScale or 1,
        DepthScale = desc.DepthScale or 1,
        HeadScale = desc.HeadScale or 1,
        BodyTypeScale = desc.BodyTypeScale or 0,
        ProportionScale = desc.ProportionScale or 0,
    }
    local accessories = {}
    for _, acc in ipairs(desc:GetAccessories(true)) do
        table.insert(accessories,{
            Rotation = "  ",
            Position = "  ",
            Scale = "1 1 1",
            IsLayered = acc.IsLayered,
            AccessoryType = acc.AccessoryType.Name,
            AssetId = acc.AssetId,
            Order = acc.Order,
            Puffiness = acc.Puffiness
        })
    end
    pcall(function()
        g.Send("wear_outfit_from_desc", {
            accessories = accessories,
            properties = properties
        })
    end)
    task.delay(0.10, function()
        g.apply_skin_tone(g.session_original_skin)
        g.height_setter_busy = false
    end)
end
g.reset_to_original_height = g.reset_to_original_height or function()
    if g.height_setter_busy then return end
    if not g.session_original_height then return end
    g.height_func_setter(g.session_original_height)
    if g.session_original_skin then
        task.delay(0.1, function()
            g.apply_skin_tone(g.session_original_skin)
        end)
    end
    task.delay(0.3, function()
        g.session_original_height = nil
        g.session_original_width = nil
        g.session_original_skin = nil
        g.session_active = false
    end)
end
g.reapply_last_skin = g.reapply_last_skin or function()
    if g.last_skin_tone then
        g.apply_skin_tone(g.last_skin_tone)
    end
end
g.reapply_prev_skin = g.reapply_prev_skin or function()
    if g.prev_skin_tone then
        g.apply_skin_tone(g.prev_skin_tone)
    end
end
g.size_func_setter = g.size_func_setter or function(width_input, depth_input)
    if g.size_setter_busy then return end
    g.size_setter_busy = true
    local char = g.Character or speaker.Character or g.get_char(speaker) or g.Char:get()
    local hum = g.Humanoid or char and char:FindFirstChildOfClass("Humanoid") or g.get_human(speaker)
    if not hum then g.size_setter_busy = false; return end
    local desc = hum:GetAppliedDescription()
    if not desc then
        g.size_setter_busy = false
        g.notify("Error", "Failed to grab HumanoidDescription.", 3)
        return
    end
    local body_colors = char and char:FindFirstChildOfClass("BodyColors")
    local current_skin = body_colors and g.avgSkin(body_colors)
    if not g.session_size_active then
        g.session_original_width = desc.WidthScale or 1
        g.session_original_depth = desc.DepthScale or 1
        g.session_original_skin = g.session_original_skin or current_skin
        g.session_size_active = true
    end
    if current_skin then
        g.prev_skin_tone_s = g.last_skin_tone_s or current_skin
        g.last_skin_tone_s = current_skin
    end
    local width = tonumber(width_input) or desc.WidthScale or 1
    local depth = tonumber(depth_input) or desc.DepthScale or 1
    g.prev_width_scale = g.last_width_scale or desc.WidthScale or 1
    g.prev_depth_scale = g.last_depth_scale or desc.DepthScale or 1
    g.last_width_scale = width
    g.last_depth_scale = depth
    local properties = {
        Head = desc.Head or 0,
        Torso = desc.Torso or 0,
        LeftArm = desc.LeftArm or 0,
        RightArm = desc.RightArm or 0,
        LeftLeg = desc.LeftLeg or 0,
        RightLeg = desc.RightLeg or 0,
        Face = desc.Face or 0,
        Shirt = desc.Shirt or 0,
        Pants = desc.Pants or 0,
        GraphicTShirt = desc.GraphicTShirt or 0,
        RunAnimation = desc.RunAnimation or 0,
        WalkAnimation = desc.WalkAnimation or 0,
        JumpAnimation = desc.JumpAnimation or 0,
        FallAnimation = desc.FallAnimation or 0,
        ClimbAnimation = desc.ClimbAnimation or 0,
        IdleAnimation = desc.IdleAnimation or 0,
        SwimAnimation = desc.SwimAnimation or 0,
        HeightScale = desc.HeightScale or 1,
        WidthScale = width,
        DepthScale = depth,
        HeadScale = desc.HeadScale or 1,
        BodyTypeScale = desc.BodyTypeScale or 0,
        ProportionScale = desc.ProportionScale or 0,
    }
    local accessories = {}
    for _, acc in ipairs(desc:GetAccessories(true)) do
        table.insert(accessories, {
            Rotation = "  ",
            Position = "  ",
            Scale = "1 1 1",
            IsLayered = acc.IsLayered,
            AccessoryType = acc.AccessoryType.Name,
            AssetId = acc.AssetId,
            Order = acc.Order,
            Puffiness = acc.Puffiness
        })
    end
    pcall(function()
        g.Send("wear_outfit_from_desc", {
            accessories = accessories,
            properties = properties
        })
    end)
    task.delay(0.10, function()
        g.apply_skin_tone(g.session_original_skin)
        g.size_setter_busy = false
    end)
end
g.reset_to_original_size = g.reset_to_original_size or function()
    if g.size_setter_busy then return end
    if not g.session_original_width and not g.session_original_depth then return end
    g.size_func_setter(g.session_original_width, g.session_original_depth)
    if g.session_original_skin then task.delay(0.1, function() g.apply_skin_tone(g.session_original_skin) end) end
    task.delay(0.3, function()
        g.session_original_width = nil
        g.session_original_depth = nil
        g.session_original_skin = nil
        g.session_size_active = false
    end)
end
g.width_setter_busy = g.width_setter_busy or false
g.session_original_width_only = g.session_original_width_only or nil
g.session_original_skin_w = g.session_original_skin_w or nil
g.session_width_active = g.session_width_active or false
g.last_width_scale_only = g.last_width_scale_only or nil
g.prev_width_scale_only = g.prev_width_scale_only or nil
g.last_skin_tone_w = g.last_skin_tone_w or nil
g.prev_skin_tone_w = g.prev_skin_tone_w or nil
g.width_func_setter = g.width_func_setter or function(width_input)
    if g.width_setter_busy then return end
    g.width_setter_busy = true
    local char = g.Character or speaker.Character or g.get_char(speaker) or g.Char:get()
    local hum = g.Humanoid or char and char:FindFirstChildOfClass("Humanoid") or g.get_human(speaker) or g.Char:get_human()
    if not hum then
        g.width_setter_busy = false
        return
    end
    local desc = hum:GetAppliedDescription()
    if not desc then
        g.width_setter_busy = false
        g.notify("Error", "Failed to grab HumanoidDescription.", 3)
        return
    end
    local body_colors = char and char:FindFirstChildOfClass("BodyColors")
    local current_skin = body_colors and g.avgSkin(body_colors)
    if not g.session_width_active then
        g.session_original_width_only = desc.WidthScale or 1
        g.session_original_skin_w = current_skin
        g.session_width_active = true
    end
    if current_skin then
        g.prev_skin_tone_w = g.last_skin_tone_w or current_skin
        g.last_skin_tone_w = current_skin
    end
    local width = tonumber(width_input) or desc.WidthScale or 1
    g.prev_width_scale_only = g.last_width_scale_only or desc.WidthScale or 1
    g.last_width_scale_only = width
    local properties = {
        Head = desc.Head or 0,
        Torso = desc.Torso or 0,
        LeftArm = desc.LeftArm or 0,
        RightArm = desc.RightArm or 0,
        LeftLeg = desc.LeftLeg or 0,
        RightLeg = desc.RightLeg or 0,
        Face = desc.Face or 0,
        Shirt = desc.Shirt or 0,
        Pants = desc.Pants or 0,
        GraphicTShirt = desc.GraphicTShirt or 0,
        RunAnimation = desc.RunAnimation or 0,
        WalkAnimation = desc.WalkAnimation or 0,
        JumpAnimation = desc.JumpAnimation or 0,
        FallAnimation = desc.FallAnimation or 0,
        ClimbAnimation = desc.ClimbAnimation or 0,
        IdleAnimation = desc.IdleAnimation or 0,
        SwimAnimation = desc.SwimAnimation or 0,
        HeightScale = desc.HeightScale or 1,
        WidthScale = width,
        DepthScale = desc.DepthScale or 1,
        HeadScale = desc.HeadScale or 1,
        BodyTypeScale = desc.BodyTypeScale or 0,
        ProportionScale = desc.ProportionScale or 0,
    }
    local accessories = {}
    for _, acc in ipairs(desc:GetAccessories(true)) do
        table.insert(accessories, {
            Rotation = "  ",
            Position = "  ",
            Scale = "1 1 1",
            IsLayered = acc.IsLayered,
            AccessoryType = acc.AccessoryType.Name,
            AssetId = acc.AssetId,
            Order = acc.Order,
            Puffiness = acc.Puffiness
        })
    end
    pcall(function()
        g.Send("wear_outfit_from_desc", {
            accessories = accessories,
            properties = properties
        })
    end)
    task.delay(0.10, function()
        if g.session_original_skin_w then
            g.apply_skin_tone(g.session_original_skin_w)
        end
        g.width_setter_busy = false
    end)
end
g.reset_to_original_width = g.reset_to_original_width or function()
    if g.width_setter_busy then return end
    if not g.session_original_width_only then return end
    g.width_func_setter(g.session_original_width_only)
    if g.session_original_skin_w then
        task.delay(0.1, function()
            g.apply_skin_tone(g.session_original_skin_w)
        end)
    end
    task.delay(0.3, function()
        g.session_original_width_only = nil
        g.session_original_skin_w = nil
        g.session_width_active = false
    end)
end
g.anti_sit_enabled = g.anti_sit_enabled or false
g.anti_sit_connections = g.anti_sit_connections or {}
local local_player = g.LocalPlayer or Players.LocalPlayer
local function cleanup_connections()
	for _, conn in pairs(g.anti_sit_connections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	g.anti_sit_connections = {}
end
local function hook_character(character)
	if not character then character = g.get_char(local_player, 10) end
	if not character then return end
	if not character:FindFirstChild("HumanoidRootPart") then character:WaitForChild("HumanoidRootPart") end
	local humanoid = g.Humanoid or g.Character:FindFirstChildOfClass("Humanoid") or g.get_human(local_player, Players.RespawnTime + 0.75)
	if not humanoid or not humanoid.Parent or not humanoid:IsDescendantOf(game) then return end
	local conn
	conn = humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
		if not g.anti_sit_enabled then return end
		if humanoid.Sit then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			task.spawn(function()
				if humanoid.SeatPart then
					local weld = humanoid.SeatPart:FindFirstChildOfClass("Weld")
					if weld then weld:Destroy() end
					local prox = humanoid.SeatPart:FindFirstChildOfClass("ProximityPrompt")
					if prox and prox.Enabled == false then prox.Enabled = true end
				end
				for _ = 1, 5 do
					task.wait()
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					humanoid.Sit = false
				end
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			end)
		end
	end)
	table.insert(g.anti_sit_connections, conn)
end
local function start_anti_sit()
	if #g.anti_sit_connections > 0 then return end
	hook_character(local_player.Character)
	local char_conn = local_player.CharacterAdded:Connect(function(character) hook_character(character) end)
	table.insert(g.anti_sit_connections, char_conn)
end
local function stop_anti_sit() cleanup_connections() end
g.toggle_anti_sit = function(state)
	g.anti_sit_enabled = state
	if state then
		start_anti_sit()
	else
		stop_anti_sit()
	end
end
local attr_name = "InHumanoidVehicle"
local keys = {loop = "anti_sit_loop", char = "anti_sit_char", spam = "anti_sit_spam", hook = "anti_sit_hook", seat = "anti_sit_seat", hv = "anti_sit_hv"}
local cfg = g.anti_sit_config or {phase_two = 0.75, phase_three = 2, timeout = 5, retry_delay = 0.5}
local spam = g.anti_sit_spam or {active = false, started = 0, last_send = 0, last_hard = 0, cooldown_until = 0, exits = 0, total = 0, fastest = math.huge}
local registry = g.anti_sit_registry or {}
g.seat_cache = {}
local uid = 0
g.anti_sit_config = cfg
g.anti_sit_spam = spam
g.anti_sit_registry = registry
g.in_humanoid_vehicle = g.in_humanoid_vehicle or function(player_or_name)
    local humanoid_vehicles = g.Workspace:FindFirstChild("HumanoidVehicles", true)
    if not humanoid_vehicles then return end
    local player = player_or_name
    if typeof(player_or_name) == "string" then
        player = g.Players:FindFirstChild(player_or_name)
        if not player then return end
    end
    local character = player == g.LocalPlayer and g.Character or player.Character
    if not character then return end
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid") or g.get_human(player, 3)
    if not humanoid then return end
    local vehicle_attr = humanoid:GetAttribute("InHumanoidVehicle")
    if vehicle_attr == nil then return end
    if type(g.Humanoid_Vehicles) ~= "table" then return end
    if not table.find(g.Humanoid_Vehicles, vehicle_attr) then return end
    return vehicle_attr
end
g.hum_vehicle_name = g.hum_vehicle_name or function(plr)
    local hv = g.in_humanoid_vehicle(plr)
    if not hv then return nil end
    local folder = g.Workspace:FindFirstChild("HumanoidVehicles", true)
    if not folder or not folder:IsA("Folder") then return nil end
    local inst = folder:FindFirstChild(hv)
    if not inst then return nil end
    return inst.Name
end
g.anti_sit_uid = function() uid += 1; return uid end
g.anti_sit_connect = function(name, conn) registry[name] = true; g.FlamesLibrary.connect(name, conn) end
g.anti_sit_cleanup = function() for name in pairs(registry) do g.FlamesLibrary.disconnect(name) end; table.clear(registry); table.clear(g.seat_cache) end
g.anti_sit_get_char = function() return g.Character or speaker.Character or (g.get_char and g.get_char(speaker)) end
g.anti_sit_get_hum = function(char) return (char and char:FindFirstChildWhichIsA("Humanoid")) or g.Humanoid or (g.get_human and g.get_human(speaker)) or (g.Char and g.Char.get_hum and g.Char.get_hum()) end
g.anti_sit_char_valid = function(char) return char ~= nil and char:FindFirstChild("HumanoidRootPart") ~= nil and char:IsDescendantOf(workspace) end
g.anti_sit_hum_valid = function(hum) return hum ~= nil and hum.Parent ~= nil and hum:IsDescendantOf(game) end
g.anti_sit_attr = function(hum)
    if not hum then return nil end
    local ok, res = pcall(function() return hum:GetAttribute(attr_name) end)
    if ok and res ~= nil then return res end
    return nil
end
g.anti_sit_in_hv = function(hum)
    if g.in_humanoid_vehicle and typeof(g.in_humanoid_vehicle) == "function" then
        local ok, res = pcall(g.in_humanoid_vehicle, speaker)
        if ok and res ~= nil then return res end
    end
    return g.anti_sit_attr(hum)
end
g.anti_sit_hard_eject = function(char, hum)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local folder = workspace:FindFirstChild("HumanoidVehicles")
    if folder and hrp then
        for _, group in folder:GetChildren() do
            for _, model in group:GetChildren() do
                if model:IsA("Model") and model:HasTag("HumanoidVehicle") then
                    local occupant_val = model:FindFirstChild("occupant")
                    local owner_val = model:FindFirstChild("owner")
                    local ours = (occupant_val and occupant_val.Value == hum) or (owner_val and owner_val.Value == speaker)
                    if ours then
                        local touch_part = model:FindFirstChild("TouchPart", true)
                        if touch_part then
                            for _, weld in touch_part:GetChildren() do
                                if weld:IsA("WeldConstraint") and (weld.Part0 == hrp or weld.Part1 == hrp) then pcall(function() weld:Destroy() end) end
                            end
                        end
                        if occupant_val then pcall(function() occupant_val.Value = nil end) end
                    end
                end
            end
        end
    end
    if hrp and hrp.Parent then
        for _, joint in hrp:GetChildren() do
            if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
                local other = joint.Part0 == hrp and joint.Part1 or joint.Part0
                if other and not other:IsDescendantOf(char) then pcall(function() joint:Destroy() end) end
            end
        end
        pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new(0, 4, -3) end)
    end
    pcall(function() hum:SetAttribute(attr_name, nil) end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    if g.Send and typeof(g.Send) == "function" then pcall(g.Send, "stop_sitting") end
end
g.anti_sit_spam_stop = function(success)
    FlamesLibrary.disconnect(keys.spam)
    if success then
        local took = os.clock() - spam.started
        spam.exits += 1
        spam.total += took
        spam.fastest = math.min(spam.fastest, took)
    end
    spam.active = false
    spam.cooldown_until = os.clock() + (success and 0 or cfg.retry_delay)
end
g.anti_sit_spam_start = function()
    if spam.active or os.clock() < spam.cooldown_until then return end
    spam.active = true
    spam.started = os.clock()
    spam.last_send = 0
    spam.last_hard = 0
    FlamesLibrary.connect(keys.spam, RunService.Heartbeat:Connect(function()
        if not g.Not_Ever_Sitting then g.anti_sit_spam_stop(false); return end
        local char = g.anti_sit_get_char()
        local hum = char and g.anti_sit_get_hum(char)
        if not g.anti_sit_char_valid(char) or not g.anti_sit_hum_valid(hum) then g.anti_sit_spam_stop(false); return end
        if g.anti_sit_in_hv(hum) == nil then g.anti_sit_spam_stop(true); return end
        local now = os.clock()
        local elapsed = now - spam.started
        if elapsed > cfg.timeout then g.anti_sit_spam_stop(false); return end
        pcall(function()
            hum.Jump = true
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
        if elapsed > cfg.phase_two then
            pcall(function() hum.Sit = false end)
            if now - spam.last_send > 0.15 then
                spam.last_send = now
                if g.Send and typeof(g.Send) == "function" then pcall(g.Send, "stop_sitting") end
            end
        end
        if elapsed > cfg.phase_three and now - spam.last_hard > 0.4 then
            spam.last_hard = now
            g.anti_sit_hard_eject(char, hum)
        end
    end))
end
g.anti_sit_eject_seat = function(hum, seat)
    local target = seat or hum.SeatPart
    if target and target.Parent then
        pcall(function() target:SetAttribute("Disabled", true) end)
        task.delay(0.3, function() pcall(function() if target.Parent then target:SetAttribute("Disabled", false) end end) end)
    end
    pcall(function() hum.Sit = false end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    if g.Send then pcall(g.Send, "stop_sitting") end
    local char = hum.Parent
    local hrp = char and char:IsDescendantOf(workspace) and char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Parent then pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new(0, 3, -2) end) end
end
g.anti_sit_eject_any = function(char, hum)
    if not g.anti_sit_char_valid(char) or not g.anti_sit_hum_valid(hum) then return end
    if g.anti_sit_in_hv(hum) ~= nil then g.anti_sit_spam_start(); return end
    local seat_part = hum.SeatPart
    local is_sit = hum.Sit or (g.Char and g.Char.is_sitting and g.Char.is_sitting.get())
    if is_sit or seat_part then g.anti_sit_eject_seat(hum, seat_part) end
end
g.anti_sit_disable_nearby = function(char)
    local hrp = g.HumanoidRootPart or char and char:FindFirstChild("HumanoidRootPart") or g.get_root(speaker)
    if not hrp or not hrp.Parent then return end
    for seat in pairs(g.seat_cache) do
        if seat.Parent and seat:GetAttribute("Disabled") ~= true and (seat.Position - hrp.Position).Magnitude < 8 then
            pcall(function() seat:SetAttribute("Disabled", true) end)
            task.delay(0.35, function() pcall(function() if seat.Parent then seat:SetAttribute("Disabled", false) end end) end)
        end
    end
end
g.anti_sit_hook_hum = function(hum, char)
    g.anti_sit_connect(keys.hook .. "_attr", hum:GetAttributeChangedSignal(attr_name):Connect(function()
        if g.Not_Ever_Sitting and g.anti_sit_attr(hum) ~= nil then g.anti_sit_eject_any(char, hum) end
    end))
    g.anti_sit_connect(keys.hook .. "_sit", hum:GetPropertyChangedSignal("Sit"):Connect(function()
        if g.Not_Ever_Sitting and hum.Sit then g.anti_sit_eject_any(char, hum) end
    end))
    g.anti_sit_connect(keys.hook .. "_seatpart", hum:GetPropertyChangedSignal("SeatPart"):Connect(function()
        if not g.Not_Ever_Sitting or not hum.SeatPart then return end
        task.defer(function() if g.Not_Ever_Sitting then g.anti_sit_eject_any(char, hum) end end)
    end))
end
g.anti_sit_watch_seats = function()
    table.clear(g.seat_cache)
    for _, obj in workspace:GetDescendants() do if obj:IsA("Seat") or obj:IsA("VehicleSeat") then g.seat_cache[obj] = true end end
    g.anti_sit_connect(keys.seat .. "_added", workspace.DescendantAdded:Connect(function(obj) if obj:IsA("Seat") or obj:IsA("VehicleSeat") then g.seat_cache[obj] = true end end))
    g.anti_sit_connect(keys.seat .. "_removed", workspace.DescendantRemoving:Connect(function(obj) g.seat_cache[obj] = nil end))
end
g.anti_sit_bind_hv_model = function(model)
    if not (model:IsA("Model") and model:HasTag("HumanoidVehicle")) then return end
    task.spawn(function()
        local occupant_val = model:WaitForChild("occupant", 5)
        if not occupant_val or not occupant_val:IsA("ObjectValue") or not g.Not_Ever_Sitting then return end
        g.anti_sit_connect(keys.hv .. "_occ_" .. g.anti_sit_uid(), occupant_val:GetPropertyChangedSignal("Value"):Connect(function()
            if not g.Not_Ever_Sitting or occupant_val.Value == nil then return end
            local char = g.anti_sit_get_char()
            local hum = char and g.anti_sit_get_hum(char)
            if occupant_val.Value == hum then g.anti_sit_spam_start() end
        end))
    end)
end
g.anti_sit_bind_hv_folder = function(folder)
    if not folder:IsA("Folder") then return end
    for _, model in folder:GetChildren() do g.anti_sit_bind_hv_model(model) end
    g.anti_sit_connect(keys.hv .. "_child_" .. g.anti_sit_uid(), folder.ChildAdded:Connect(function(model)
        if g.Not_Ever_Sitting then g.anti_sit_bind_hv_model(model) end
    end))
end
g.anti_sit_watch_hv = function()
    local root = workspace:FindFirstChild("HumanoidVehicles")
    if not root then return end
    for _, folder in root:GetChildren() do g.anti_sit_bind_hv_folder(folder) end
    g.anti_sit_connect(keys.hv .. "_folders", root.ChildAdded:Connect(function(folder) if g.Not_Ever_Sitting then g.anti_sit_bind_hv_folder(folder) end end))
end
g.anti_sit_func = function(toggle)
    local lib = g.FlamesLibrary
    local fw = lib.wait
    if not g.Seat then
        local ok, res = pcall(function() return g.safe_require(g.Game_Folder:FindFirstChild("Seat")) end)
        if ok and res and type(res.enabled) == "table" then g.Seat = res end
    end
    local function seat_system(on)
        if g.Seat then pcall(function() g.Seat.enabled.set(on) end) end
        local hum = g.anti_sit_get_hum(g.anti_sit_get_char())
        if hum then pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Seated, on) end) end
    end
    if toggle == true then
        if g.Not_Ever_Sitting then g.notify("Warning", "AntiSit is already enabled!", 3); return end
        g.Not_Ever_Sitting = true
        g.notify("Success", "Anti-Sit is now enabled!", 3)
        pcall(function() g.show_notification("Success:", "Anti-Sit is now enabled.", "Normal") end)
        local char = g.anti_sit_get_char()
        local hum = char and g.anti_sit_get_hum(char)
        if g.anti_sit_char_valid(char) and g.anti_sit_hum_valid(hum) then g.anti_sit_hook_hum(hum, char) end
        g.anti_sit_watch_seats()
        g.anti_sit_watch_hv()
        g.anti_sit_connect(keys.char, speaker.CharacterAdded:Connect(function(new_char)
            fw(0)
            local new_hum = new_char:WaitForChild("Humanoid", 5)
            if g.anti_sit_char_valid(new_char) and g.anti_sit_hum_valid(new_hum) then g.anti_sit_hook_hum(new_hum, new_char) end
        end))
        lib.spawn(keys.loop, "spawn", function()
            while g.Not_Ever_Sitting == true do
                seat_system(false)
                local cur_char = g.anti_sit_get_char()
                local cur_hum = cur_char and g.anti_sit_get_hum(cur_char)
                if g.anti_sit_char_valid(cur_char) and g.anti_sit_hum_valid(cur_hum) then
                    g.anti_sit_eject_any(cur_char, cur_hum)
                    if cur_hum.Sit or cur_hum.SeatPart then g.anti_sit_disable_nearby(cur_char) end
                end
                fw(0)
            end
            lib.disconnect(keys.loop)
        end)
    elseif toggle == false then
        if not g.Not_Ever_Sitting then g.notify("Warning", "AntiSit is not enabled!", 3); return end
        g.Not_Ever_Sitting = false
        g.anti_sit_spam_stop(false)
        g.anti_sit_cleanup()
        lib.disconnect(keys.loop)
        fw(0.2)
        seat_system(true)
        g.notify("Success", "Anti-Sit is now disabled.", 3)
        pcall(function() g.Phone.show_notification("Success:", "Anti-Sit is now disabled.", "Normal") end)
    end
end
task.wait()
g.Anti_Tent_Spawning = function(state)
    g.Anti_Tent_Spawning_Currently_Active = state
    if not state then g.FlamesLibrary.disconnect("anti_tent_spawning"); return end
    local PlacedModels = g.cached_placed_models_folder or g.find_placed_models_folder()
    if not PlacedModels or not PlacedModels:IsA("Folder") then g.notify("Error", "Folder: PlacedModels does not exist or was not found.", 3); return end
    if not g.Not_Ever_Sitting then if g.anti_sit_func and typeof(g.anti_sit_func) == "function" then g.anti_sit_func(true) end end
    local function neuter_tent(tent)
        if not tent:IsA("Model") or tent.Name ~= "Tent" then return end
        pcall(function()
            for _, v in ipairs(tent:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("SpecialMesh") then
                    v.Transparency = 1
                end
                if v:IsA("Seat") or v:IsA("VehicleSeat") then
                    v.Disabled = true
                    v.Transparency = 1
                end
            end
        end)
    end
    for _, v in ipairs(PlacedModels:GetChildren()) do neuter_tent(v) end
    FlamesLibrary.connect("anti_tent_spawning", PlacedModels.ChildAdded:Connect(function(child)
        if not g.Anti_Tent_Spawning_Currently_Active then return end
        neuter_tent(child)
    end))
end
g.is_player_invisible = function(plr)
    local char = plr.Character or g.get_char(plr)
    if not char then return false end
    local parts = {}
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("MeshPart") then
            table.insert(parts, v)
        end
    end
    if #parts == 0 then return false end
    for _, v in ipairs(parts) do if v.Transparency ~= 1 then return false end end
    return true
end
g.Anti_Invisible_Players = function(state)
    g.Anti_Invisible_Players_Currently_Active = state
    if not state then
        g.FlamesLibrary.disconnect("anti_invis_player_added")
        g.FlamesLibrary.disconnect("anti_invis_char_added")
        g.FlamesLibrary.disconnect("anti_invis_loop")
        return
    end
    local function fix_invisible(plr)
        if not g.Anti_Invisible_Players_Currently_Active then return end
        local char = plr.Character or g.get_char(plr)
        if not char then return end
        if not g.is_player_invisible(plr) then return end
        pcall(function()
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("MeshPart") then
                    v.Transparency = 0
                end
            end
        end)
    end
    for _, plr in ipairs(g.Players:GetPlayers()) do fix_invisible(plr) end
    FlamesLibrary.connect("anti_invis_player_added", g.Players.PlayerAdded:Connect(function(plr)
        if not g.Anti_Invisible_Players_Currently_Active then return end
        fix_invisible(plr)
    end))
    FlamesLibrary.connect("anti_invis_char_added", g.Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function()
            if not g.Anti_Invisible_Players_Currently_Active then return end
            task.wait(0.5)
            fix_invisible(plr)
        end)
    end))
    FlamesLibrary.spawn("anti_invis_loop", "spawn", function()
        while g.Anti_Invisible_Players_Currently_Active == true do
            for _, plr in ipairs(g.Players:GetPlayers()) do
                if plr ~= g.LocalPlayer then
                    fix_invisible(plr)
                end
            end
            fw(3)
        end
    end)
end
g.annoyance_GUI = function()
    if CoreGui:FindFirstChild("AnnoyGUI") and CoreGui:FindFirstChild("AnnoyGUI"):IsA("ScreenGui") then
        CoreGui:FindFirstChild("AnnoyGUI").Enabled = true
        return
    end
    g.AnnoyList = g.AnnoyList or {}
    g.group_chatting_users = g.group_chatting_users or {}
    g.Creating_Groups = false
    local ScreenGui = CoreGui:FindFirstChild("AnnoyGUI") or Instance.new("ScreenGui")
    ScreenGui.Name = "AnnoyGUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    local AnnoyerGUIFrame = Instance.new("Frame")
    AnnoyerGUIFrame.Size = UDim2.new(0, 300, 0, 400)
    AnnoyerGUIFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    AnnoyerGUIFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    AnnoyerGUIFrame.BorderSizePixel = 0
    AnnoyerGUIFrame.Parent = ScreenGui
    Instance.new("UICorner", AnnoyerGUIFrame).CornerRadius = UDim.new(0, 12)
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = AnnoyerGUIFrame
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -35, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = "Annoy / Group Spam Menu | Made By: "..tostring(g.Script_Creator).."."
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextScaled = true
    Title.TextSize = 14
    Title.Parent = TitleBar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
    CloseBtn.Text = "X"
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextScaled = true
    CloseBtn.TextSize = 14
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
        g.easy_click_plr = false
        g.Creating_Groups = false
    end)
    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -10, 1, -45)
    PlayerList.Position = UDim2.new(0, 5, 0, 40)
    PlayerList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 6
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    PlayerList.Parent = AnnoyerGUIFrame
    Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 10)
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = PlayerList
    UIListLayout.Padding = UDim.new(0, 5)
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
    if g.dragify and typeof(g.dragify) == "function" then g.dragify(AnnoyerGUIFrame) end
    local function ToggleAnnoy(plr, btn)
        if g.easy_click_plr and g.easy_click_target == plr.Name then
            g.easy_click_plr = false
            if g.Toggling_Annoyance_Loop_Carry_AndCall then
                pcall(function()
                    task.cancel(g.Toggling_Annoyance_Loop_Carry_AndCall)
                    g.Toggling_Annoyance_Loop_Carry_AndCall = nil
                end)
            end
            btn.Text = "Annoy Off"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            g.easy_click_target = plr.Name
            g.easy_click_plr = true
            btn.Text = "Annoy On"
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            g.Toggling_Annoyance_Loop_Carry_AndCall = g.Toggling_Annoyance_Loop_Carry_AndCall or task.spawn(function()
                while g.easy_click_plr and g.easy_click_target == plr.Name do
                fw(0)
                    g.Send("request_carry", plr.Name)
                    fw(0)
                    g.Send("request_call", plr.Name)
                    fw(0)
                    g.Send("end_call", plr.Name)
                end
            end)
        end
    end
    local function ToggleGroupSpam(plr, btn)
        if table.find(g.group_chatting_users, plr.Name) then
            table.remove(g.group_chatting_users, table.find(g.group_chatting_users, plr.Name))
            if g.Always_Creating_TheGroups_Loop_Task then
                task.cancel(g.Always_Creating_TheGroups_Loop_Task)
                g.Always_Creating_TheGroups_Loop_Task = nil
            end
            btn.Text = "Group Spam Off"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            if #g.group_chatting_users == 0 then
                g.Creating_Groups = false
            end
        else
            table.insert(g.group_chatting_users, plr.Name)
            btn.Text = "Group Spam On"
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            g.Creating_Groups = true
            g.Always_Creating_TheGroups_Loop_Task = g.Always_Creating_TheGroups_Loop_Task or task.spawn(function()
                while g.Creating_Groups == true do
                wait(.4)
                    local userIds = {}
                    for _, name in ipairs(g.group_chatting_users) do
                        local success, userId = pcall(function()
                            return Players:GetUserIdFromNameAsync(name)
                        end)
                        if success and userId then
                            table.insert(userIds, userId)
                        end
                    end
                    if #userIds == 1 then
                        local others = {}
                        for _, other in ipairs(Players:GetPlayers()) do
                            if other.Name ~= g.group_chatting_users[1] and other ~= LocalPlayer then
                                table.insert(others, other)
                            end
                        end
                        for i = #others, 2, -1 do
                            local j = math.random(i)
                            others[i], others[j] = others[j], others[i]
                        end
                        for i = 1, math.min(3, #others) do
                            table.insert(userIds, others[i].UserId)
                        end
                    end
                    if #userIds > 0 then
                        g.Get("new_group", userIds)
                    end
                end
            end)
        end
    end
    local function createPlayerEntry(plr)
        if plr == LocalPlayer then return end
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, -5, 0, 110)
        Container.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        Container.BorderSizePixel = 0
        Container.Parent = PlayerList
        Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(1, -10, 0, 20)
        NameLabel.Position = UDim2.new(0, 5, 0, 5)
        NameLabel.Text = "DisplayName: " .. plr.DisplayName
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.BackgroundTransparency = 1
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Font = Enum.Font.Gotham
        NameLabel.TextSize = 13
        NameLabel.Parent = Container
        local UserLabel = Instance.new("TextLabel")
        UserLabel.Size = UDim2.new(1, -10, 0, 20)
        UserLabel.Position = UDim2.new(0, 5, 0, 25)
        UserLabel.Text = "Username: " .. plr.Name
        UserLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        UserLabel.BackgroundTransparency = 1
        UserLabel.TextXAlignment = Enum.TextXAlignment.Left
        UserLabel.Font = Enum.Font.Gotham
        UserLabel.TextSize = 12
        UserLabel.Parent = Container
        local IdLabel = Instance.new("TextLabel")
        IdLabel.Size = UDim2.new(1, -10, 0, 20)
        IdLabel.Position = UDim2.new(0, 5, 0, 45)
        IdLabel.Text = "UserId: " .. tostring(plr.UserId)
        IdLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        IdLabel.BackgroundTransparency = 1
        IdLabel.TextXAlignment = Enum.TextXAlignment.Left
        IdLabel.Font = Enum.Font.Gotham
        IdLabel.TextSize = 12
        IdLabel.Parent = Container
        local AnnoyButton = Instance.new("TextButton")
        AnnoyButton.Size = UDim2.new(0, 110, 0, 20)
        AnnoyButton.Position = UDim2.new(0, 10, 0, 70)
        AnnoyButton.Text = "Annoy Off"
        AnnoyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        AnnoyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        AnnoyButton.Font = Enum.Font.GothamBold
        AnnoyButton.TextScaled = true
        AnnoyButton.TextSize = 13
        AnnoyButton.Parent = Container
        AnnoyButton.MouseButton1Click:Connect(function()
            ToggleAnnoy(plr, AnnoyButton)
        end)
        local GroupButton = Instance.new("TextButton")
        GroupButton.Size = UDim2.new(0, 110, 0, 20)
        GroupButton.Position = UDim2.new(0, 140, 0, 70)
        GroupButton.Text = "Group Spam Off"
        GroupButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        GroupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        GroupButton.Font = Enum.Font.GothamBold
        GroupButton.TextScaled = true
        GroupButton.TextSize = 13
        GroupButton.Parent = Container
        Instance.new("UICorner", GroupButton).CornerRadius = UDim.new(0, 6)
        GroupButton.MouseButton1Click:Connect(function()
            ToggleGroupSpam(plr, GroupButton)
        end)
        Instance.new("UICorner", AnnoyButton).CornerRadius = UDim.new(0, 6)
        Instance.new("UICorner", GroupButton).CornerRadius = UDim.new(0, 6)
        if g.easy_click_plr and g.easy_click_target == plr.Name then
            AnnoyButton.Text = "Annoy On"
            AnnoyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        end
        if table.find(g.group_chatting_users, plr.Name) then
            GroupButton.Text = "Group Spam On"
            GroupButton.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
        end
        PlayerList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end
    local function refresh_player_list()
        for _, child in ipairs(PlayerList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            createPlayerEntry(plr)
        end
    end
    if not g.RefreshPlayer_ListAdded_Conn then
        g.RefreshPlayer_ListAdded_Conn = true
        Players.PlayerAdded:Connect(refresh_player_list)
        Players.PlayerRemoving:Connect(refresh_player_list)
    end
    refresh_player_list()
end
local Hum = g.Humanoid or g.Character and g.Character:FindFirstChildOfClass("Humanoid") or g.get_human(LocalPlayer or Players.LocalPlayer, Players.RespawnTime + 0.5)
local HD = Hum:FindFirstChildOfClass("HumanoidDescription")
print("[Flames] loading: glitch ids")
g.GlitchIDs = {
   Shirts = {6028801590, 11595159513},
   Pants  = {6028804735, 11595172734}
}
g.isWearing = g.isWearing or function(desc, slot, id)
    return desc and tostring(desc[slot]) == tostring(id)
end
g.forceEquip = g.forceEquip or function(slot, id)
    if not g.isWearing(HD, slot, id) then
        g.Get("code", id, slot)
    end
end
g.forceUnequip = g.forceUnequip or function(slot, id)
    if g.isWearing(HD, slot, id) then
        g.Get("wear", id, slot)
    end
end
local applied = g.Humanoid:GetAppliedDescription()
local Old_Shirt = applied.Shirt
local Old_Pants = applied.Pants
g.glitch_outfit = g.glitch_outfit or function(toggle)
    local FL = g.FlamesLibrary
    if toggle == true then
        if g.Glitching_Outfit then g.notify("Warning", "Glitch Outfit is already enabled.", 3); return end
        g.Glitching_Outfit = true
        FL.spawn("glitch_outfit_loop", "spawn", function()
            while g.Glitching_Outfit == true do
                fw(0)
                for _, shirtId in ipairs(g.GlitchIDs.Shirts) do
                    g.forceEquip("Shirt", shirtId)
                    task.wait()
                    g.forceUnequip("Shirt", shirtId)
                end
                fw(0.1)
                for _, pantsId in ipairs(g.GlitchIDs.Pants) do
                    g.forceEquip("Pants", pantsId)
                    task.wait()
                    g.forceUnequip("Pants", pantsId)
                end
            end
        end)
    else
        if not g.Glitching_Outfit then g.notify("Warning", "Glitch Outfit is not enabled.", 3); return end
        g.Glitching_Outfit = false
        FL.disconnect("glitch_outfit_loop")
        FL.spawn("glitch_outfit_restore", "delay", 0.5, function()
            g.Send("code", Old_Shirt, "Shirt")
            task.wait()
            g.Send("code", Old_Pants, "Pants")
        end)
    end
end
function check_friends()
    for _, v in ipairs(g.Players:GetPlayers()) do
        if v ~= g.LocalPlayer and v:IsFriendsWith(g.LocalPlayer.UserId) then
            g.alreadyCheckedUser(v)
        end
    end
end
function auto_add_friends()
    for _, v in ipairs(g.Players:GetPlayers()) do
        if v ~= g.LocalPlayer and v:IsFriendsWith(g.LocalPlayer.UserId) then
            check_friends()
            g.addPlayerToScriptWhitelistTable(v)
        end
    end
end
auto_add_friends()
if g.PlayerControls == nil then
    local PlayerModule = g.safe_require(g.PlayerScripts:WaitForChild("PlayerModule"))
    g.PlayerControls = PlayerModule:GetControls()
end
g.Viewing_Plr_Tbl = g.Viewing_Plr_Tbl or {}
g.viewTarget = g.viewTarget or function(player)
    if g.Viewing_A_Player then
        if g.Viewing_Plr_Tbl[player.Name] then g.notify("Error","You're already viewing: "..player.DisplayName, 3); return end
        g.notify("Error","You're already viewing a Player.",5)
        return
    end
    if not player or not player.Character then g.notify("Error", "Invalid player.", 3); return end
    local char = player.Character or g.get_char(player, Players.RespawnTime + 0.75)
    local hum = char and char:FindFirstChildWhichIsA("Humanoid") or g.get_human(player, Players.RespawnTime + 0.5)
    if not hum or not hum.Parent or not hum:IsDescendantOf(game) then g.notify("Error", "Player has no humanoid.", 3); return end
    local root = hum and hum.RootPart or char and char:FindFirstChild("HumanoidRootPart") or g.get_root(player, Players.RespawnTime + 0.5)
    g.Camera.CameraSubject = hum
    g.Viewing_A_Player = true
    g.Viewing_Plr_Tbl[player.Name] = {
        Name = player.Name,
        DisplayName = player.DisplayName,
        UserId = player.UserId,
        Character = char,
        Humanoid = hum,
        HumanoidRootPart = root
    }
end
g.unview_player = g.unview_player or function()
    local genv = g
    if not genv.Viewing_A_Player then genv.notify("Error", "You're not viewing anyone.", 5); return end
    local hum = genv.Humanoid or genv.Character:FindFirstChildOfClass("Humanoid") or g.get_human(LocalPlayer, 1)
    local char = genv.Character or genv.LocalPlayer.Character or g.get_char(LocalPlayer, 1)
    local subject = hum or (char and char:FindFirstChildWhichIsA("Humanoid")) or char
    if subject and genv.Camera then
        genv.Camera.CameraSubject = subject
    elseif not genv.Camera then
        workspace.CurrentCamera.CameraSubject = subject
    end
    if typeof(genv.Viewing_Plr_Tbl) ~= "table" then genv.Viewing_Plr_Tbl = {} end
    if next(genv.Viewing_Plr_Tbl) == nil then
        genv.notify(
            "Error",
            "Viewing table is empty (tried unviewing nobody? how?).",
            10
        )
        return
    end
    local viewed
    for k, v in pairs(genv.Viewing_Plr_Tbl) do
        local ok, display = pcall(function() return (v :: any).DisplayName end)
        viewed = (typeof(v) == "Instance" and ok and display) or k
        break
    end
    genv.Viewing_A_Player = false
    table.clear(genv.Viewing_Plr_Tbl)
    genv.notify("Success", "Stopped viewing: "..tostring(viewed), 5)
end
g.check_friend = g.check_friend or function(Player)
    if Player ~= g.LocalPlayer and Player:IsFriendsWith(g.LocalPlayer.UserId) then
        return true
    else
        return false
    end
end
g.spam_create_groups = g.spam_create_groups or function(toggle)
    local FL = g.FlamesLibrary
    if toggle == true then
        if g.Creating_Groups then g.notify("Warning", "Group spammer is already enabled.", 3); return end
        g.group_chatting_users = g.group_chatting_users or {}
        g.Creating_Groups = true
        FL.spawn("spam_create_groups_loop", "spawn", function()
            while g.Creating_Groups == true do
                fw(0)
                for _, name in ipairs(g.group_chatting_users) do
                    local success, userId = pcall(function()
                        return Players:GetUserIdFromNameAsync(name)
                    end)
                    if success and userId then
                        g.Get("new_group", userId)
                    end
                end
            end
        end)
    elseif toggle == false then
        if not g.Creating_Groups then g.notify("Warning", "Group spammer is not enabled.", 3); return end
        g.Creating_Groups = false
        FL.disconnect("spam_create_groups_loop")
    else
        return
    end
end
g.attach_with_script = g.attach_with_script or function()
    local Methods = {
        "Secret",
        "Sneaky",
        "Private",
        "Normal",
        "Bypass",
        "External",
        "Internal",
        "Rage",
        "Silent",
        "Source",
        "MainClass",
        "Class_C",
        "Non-Closure",
        "Encoded",
        "Bytecode",
        "Obfuscated"
    }
    local Attached = false
    g.Script_Was_Attached_Successfully = Attached
    local Old_Text = g.CreditsLabelText.Text
    task.wait(0.4)
    for i = 1, 3 do
        wait(0.6)
        g.CreditsLabelText.Text = "[Starting]: Attaching."
        wait(0.6)
        g.CreditsLabelText.Text = "[Starting]: Attaching.."
        wait(0.6)
        g.CreditsLabelText.Text = "[Starting]: Attaching..."
    end
    task.wait(.1)
    Attached = true
    task.wait(.1)
    if Attached == true then
        g.CreditsLabelText.Text = "[Starting]: Getting requirements."
        wait(0.6)
        g.CreditsLabelText.Text = "[Starting]: Getting requirements.."
        wait(0.6)
        g.CreditsLabelText.Text = "[Starting]: Getting requirements..."
        wait(0.5)
        g.CreditsLabelText.Text = "[Success]: Got requirements successfully!"
        wait(0.6)
        for i = 1, 3 do
            wait(0.6)
            g.CreditsLabelText.Text = "[Initializing]: Collecting prerequisites."
            wait(0.6)
            g.CreditsLabelText.Text = "[Initializing]: Collecting prerequisites.."
            wait(0.6)
            g.CreditsLabelText.Text = "[Initializing]: Collecting prerequisites..."
        end
    end
    task.wait(0.3)
    for i = 1, 8 do
        wait(0.6)
        g.CreditsLabelText.Text = "[Finalizing]: Collecting prerequisites."
        wait(0.6)
        g.CreditsLabelText.Text = "[Finalizing]: Collecting prerequisites.."
        wait(0.6)
        g.CreditsLabelText.Text = "[Finalizing]: Collecting prerequisites..."
    end
    fw(0.2)
    for i = 1, 4 do
        wait(0.6)
        g.CreditsLabelText.Text = "[Finishing]: Selecting method."
        wait(0.6)
        g.CreditsLabelText.Text = "[Finishing]: Selecting method.."
        wait(0.6)
        g.CreditsLabelText.Text = "[Finishing]: Selecting method..."
    end
    task.wait(0.3)
    local function ChooseMethod() return Methods[math.random(1, #Methods)] end
    g.CreditsLabelText.Text = "[Finished]: Method: "..tostring(ChooseMethod())
    wait(0.7)
    g.CreditsLabelText.Text = "Attached."
    wait(0.8)
    g.CreditsLabelText.Text = Old_Text
end
g.PlotAreas = {}
g.update_plot_areas = g.update_plot_areas or function()
    table.clear(g.PlotAreas)
    fw(0.2)
    for _, v in ipairs(g.Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "PlotArea" then
            g.PlotAreas[v] = v
        end
    end
end
g.in_humanoid_vehicle = g.in_humanoid_vehicle or function(PlayerOrName)
    local HumanoidVehicles = g.Workspace:FindFirstChild("HumanoidVehicles", true)
    if not HumanoidVehicles then return end
    local Player = PlayerOrName
    if typeof(PlayerOrName) == "string" then
        Player = g.Players:FindFirstChild(PlayerOrName)
        if not Player then return end
    end
    local Character = Player == g.LocalPlayer and g.Character or Player.Character
    if not Character then return end
    local humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid") or g.get_human(Player, 3)
    if not humanoid then return end
    local vehicleAttr = humanoid:GetAttribute("InHumanoidVehicle")
    if vehicleAttr == nil then return end
    if type(g.Humanoid_Vehicles) ~= "table" then return end
    if not table.find(g.Humanoid_Vehicles, vehicleAttr) then return end
    return vehicleAttr
end
g.hum_vehicle_name = g.hum_vehicle_name or function(plr)
    local hv = g.in_humanoid_vehicle(plr)
    if not hv then return nil end
    local folder = g.Workspace:FindFirstChild("HumanoidVehicles", true)
    if not folder or not folder:IsA("Folder") then return nil end
    local inst = folder:FindFirstChild(hv)
    if not inst then return nil end
    return inst.Name
end
g.set_hum_vehicle_speed = g.set_hum_vehicle_speed or function(speed)
    speed = tonumber(speed) or 50
    if typeof(speed) ~= "number" then speed = 50 end
    if g.in_humanoid_vehicle(g.LocalPlayer) then pcall(function() g.Humanoid.WalkSpeed = tonumber(speed) end) end
end
local screenGui
g.update_plot_areas()
task.wait()
if CoreGui:FindFirstChild("TemporaryBanner_GUI") then
    pcall(function()
        if g.camConn then
            g.camConn:Disconnect()
            g.camConn = nil
        end
        if screenGui and screenGui.Parent then screenGui:Destroy() end
        g.updatePosition = nil
        g.clamp = nil
    end)
end
task.wait()
screenGui = Instance.new("ScreenGui")
screenGui.Name = "TemporaryBanner_GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Enabled = false
screenGui.Parent = CoreGui
local frame = Instance.new("Frame")
frame.Name = "BannerFrame"
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0, 20)
frame.Size = UDim2.new(0.6, 0, 0, 48)
frame.BackgroundTransparency = 0
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Parent = screenGui
g.make_round(frame, 12)
g.flowrgb("banner_announcement_frame_flowing_rgb_smooth_conn", 3.5, frame, true)
g.make_stroke(frame, 1.5, 0.25)
local label = Instance.new("TextLabel")
label.Name = "BannerText"
label.AnchorPoint = Vector2.new(0.5, 0.5)
label.Position = UDim2.new(0.5, 0, 0.5, 0)
label.Size = UDim2.new(0.95, 0, 0.9, 0)
label.BackgroundTransparency = 1
label.Text = tostring(Announcement_Message)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.RichText = false
label.TextWrapped = true
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Parent = frame
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.AnchorPoint = Vector2.new(0.5, 0)
shadow.Position = UDim2.new(0.5, 0, 0, 24)
shadow.Size = UDim2.new(0.62, 0, 0, 56)
shadow.Image = "rbxassetid://5059716102"
shadow.BackgroundTransparency = 1
shadow.ImageTransparency = 0.8
shadow.ZIndex = frame.ZIndex - 1
shadow.Parent = screenGui
shadow.Visible = false
g.clamp = g.clamp or function(n, lo, hi)
    if n < lo then return lo end
    if n > hi then return hi end
    return n
end
g.updatePosition = g.updatePosition or function()
    local _, vh = g.Workspace.CurrentCamera.ViewportSize.X, g.Workspace.CurrentCamera.ViewportSize.Y
    local widthScale = g.clamp(0.6, 0.4, 0.8)
    local heightPx = g.clamp(math.floor(vh * 0.07), 36, 72)
    frame.Size = UDim2.new(widthScale, 0, 0, heightPx)
    local topOffset = math.max(12, math.floor(vh * 0.03))
    frame.Position = UDim2.new(0.5, 0, 0, topOffset)
    shadow.Position = UDim2.new(0.5, 0, 0, topOffset + math.floor(heightPx/2))
    shadow.Size = UDim2.new(widthScale + 0.02, 0, 0, heightPx + 12)
end
g.updatePosition()
g.camConn = nil
if g.Workspace and g.Workspace.CurrentCamera then g.camConn = g.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(g.updatePosition) end
frame.BackgroundTransparency = 1
label.TextTransparency = 1
shadow.ImageTransparency = 1
appearInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
g.TweenService:Create(frame, appearInfo, {BackgroundTransparency = 0}):Play()
g.TweenService:Create(label, appearInfo, {TextTransparency = 0}):Play()
shadow.Visible = false
g.TweenService:Create(shadow, appearInfo, {ImageTransparency = 0.8}):Play()
displayTime = g.displayTimeMax
task.delay(displayTime, function()
    local fadeInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local t1 = g.TweenService:Create(frame, fadeInfo, {BackgroundTransparency = 1})
    local t2 = g.TweenService:Create(label, fadeInfo, {TextTransparency = 1})
    local t3 = g.TweenService:Create(shadow, fadeInfo, {ImageTransparency = 1})
    t1:Play(); t2:Play(); t3:Play()
    t1.Completed:Wait()
    pcall(function()
        if g.camConn then
            g.camConn:Disconnect()
            g.camConn = nil
        end
        screenGui:Destroy()
    end)
end)
if not g.SetupGone_Through_Flames_Hub then
    pcall(function()
        g.LocalPlayer:SetSuperSafeChat(false)
        g.LocalPlayer.CameraMaxZoomDistance = 100000
        g.LocalPlayer.CameraMinZoomDistance = 0.5
        if g.LocalPlayer.CameraMaxZoomDistance > 90000 then
            g.notify("Success", "Set CameraMaxZoomDistance to: "..tostring(g.LocalPlayer.CameraMaxZoomDistance), 7)
        else
            g.notify("Warning", "We we're not able to correctly set CameraMaxZoomDistance!", 5)
        end
        if g.LocalPlayer.CameraMinZoomDistance < 5 then
            g.notify("Success", "Set CameraMinZoomDistance to: "..tostring(g.LocalPlayer.CameraMinZoomDistance), 7)
        else
            g.notify("Warning", "We we're not able to correctly set CameraMinZoomDistance!", 5)
        end
        if g.StarterPlayer.CharacterUseJumpPower then
            g.Humanoid.JumpPower = 50
            g.notify("Success", "Spoofed JumpPower to: "..tostring(g.Humanoid.JumpPower))
        else
            g.Humanoid.JumpHeight = 7
            g.notify("Success", "Spoofed JumpHeight to: "..tostring(g.Humanoid.JumpHeight))
        end
        g.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        if g.LocalPlayer.Name == "CIippedByAura" or g.LocalPlayer.Name == "L0CKED_1N1" or g.LocalPlayer.Name == "AuraWithClipFarmin" then
            g.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
            g.notify("Success", "Enabled Leaderboard & Backpack.", 5)
        else
            g.notify("Success", "Enabled Leaderboard.", 5)
        end
    end)
    g.SetupGone_Through_Flames_Hub = true
end
if not g.SeenCommandAndCameraIntro then
    g.notify("Success", "[HOOKED]: We have hooked the Camera successfully.", 5)
    fw(0.2)
    g.notify("Warning", "[INITIALIZING]: Setting up command receiver...", 5)
    fw(0.1)
    g.SeenCommandAndCameraIntro = true
end
for _, v in ipairs(Players:GetPlayers()) do g.setup_cmd_handler_plr(v) end
if not g.AdminHasBeenLoaded_NotificationCheck then
    g.notify("Success", "[INITIALIZED]: Life Together RP-Admin has been loaded!", 7)
    g.notify("Success", "[LOADED]: | [Life Together-RP : Admin_Commands]: Loaded!", 7)
    g.AdminHasBeenLoaded_NotificationCheck = true
end
g.automatically_add_friends = function()
    for _, v in ipairs(g.Players:GetPlayers()) do
        if v ~= g.LocalPlayer and v:IsFriendsWith(g.LocalPlayer.UserId) then
            g.alreadyCheckedUser(v)
        end
    end
end
g.automatically_remove_friends = function()
    for _, v in ipairs(g.Players:GetPlayers()) do
        if v ~= g.LocalPlayer and v:IsFriendsWith(g.LocalPlayer.UserId) and v.Character == nil then
            g.Rainbow_Others_Vehicle = false
        end
    end
end
if g.LifeTogetherRP_Admin and g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub and g.LifeTogether_Actual_Flames_Hub_Running_Functioning_Currently_On_Client then
    g.notify("Success", "Reloaded script successfully.", 15)
end
for _, v in ipairs(Players:GetPlayers()) do
    if v.Name == "CIippedByAura" or v.Name == "L0CKED_1N1" or v.Name == "AuraWithClipFarmin" then
        local owner_content = "Flames Hub | Owner is currently in this server, come to me: ("..tostring(v.Name)..") for assistance (if you need help)."
        g.notify("Success", owner_content, 30)
    elseif allowed[v.Name] and v.Name ~= "CIippedByAura" and v.Name ~= "L0CKED_1N1" and v.Name ~= "AuraWithClipFarmin" then
        local staff_content = "A Flames Hub | Staff member is currently in this server, this is more rare and they can get in contact with me faster."
        g.notify("Success", staff_content, 15)
    end
end
g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub = g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub or true
if not g.FlamesHubPlayerEvents_Check then
    g.FlamesHubPlayerEvents_Check = true
    g.FlamesLibrary.connect("PlayerAdded_OwnerAdminCheck", Players.PlayerAdded:Connect(function(Player)
        local Name = Player and Player.Name
        g.Blacklisted_Friends = g.Blacklisted_Friends or {}
        if Player:IsFriendsWith(speaker.UserId) then
            if not g.Blacklisted_Friends[Name] then
                g.automatically_add_friends()
            end
        end
        if Name == "CIippedByAura" or Name == "L0CKED_1N1" or Name == "AuraWithClipFarmin" then
            g.owner_joined(Name)
            if g.friend_checked[Name] then
                g.player_admins[Name] = nil
                g.friend_checked[Name] = nil
            end
            if g.cmds_loaded_plr[Name] then
                g.cmds_loaded_plr[Name] = nil
            end
        elseif allowed[Name] and Name ~= "L0CKED_1N1" and Name ~= "CIippedByAura" and Name ~= "AuraWithClipFarmin" then
            g.notify("Success", "An official staff member of Flames Hub has joined your server, UserName: "..tostring(Name), 15)
        end
    end))
    g.FlamesLibrary.connect("PlayerRemoving_OwnerAdminRemoval", Players.PlayerRemoving:Connect(function(Player)
        local Name = Player.Name
        if Name == "CIippedByAura" or Name == "L0CKED_1N1" or Name == "AuraWithClipFarmin" then
            g.notify("Info", "The owner of this script has left the server.", 5)
        elseif allowed[Name] and Name ~= "L0CKED_1N1" and Name ~= "CIippedByAura" and Name ~= "AuraWithClipFarmin" then
            g.notify("Success", "Flames Hub | Staff member has left your server: "..tostring(Name), 15)
        end
        g.disable_rgb_for(Name)
        g.fully_disable_rgb_plr(Name)
        if g.Locked_Vehicles[Name] then g.Locked_Vehicles[Name] = false end
        if g.Unlocked_Vehicles[Name] then g.Unlocked_Vehicles[Name] = false end
    end))
end
print("[Flames] loading: avatar tools")
do
    local LT_ACCENT = Color3.fromRGB(21, 103, 251)
    local LT_AGE_MULT = { adult = 1, teenager = 0.93, kid = 0.78, toddler = 0.51, baby = 0.43 }
    local LT_AGE_NAMES = { adult = "adult", teen = "teenager", teenager = "teenager", kid = "kid", child = "kid", toddler = "toddler", baby = "baby" }
    local LT_BODY = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
    local LT_CLASSIC = { "Shirt", "Pants", "GraphicTShirt" }
    local LT_ANIMS = { "IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation", "ClimbAnimation", "SwimAnimation", "MoodAnimation" }
    local LT_SCALES = { "HeightScale", "WidthScale", "DepthScale", "HeadScale", "BodyTypeScale", "ProportionScale" }
    local LT_WEAR_TYPE = { GraphicTShirt = "TShirt" }
    g.lt_copy_step = g.lt_copy_step or 0.2
    local function lt_gui_parent()
        local ok, hidden = pcall(function() return gethui and gethui() end)
        return (ok and hidden) or CoreGui
    end
    g.lt_modules = {}
    g.lt_require = function(name)
        if g.lt_modules[name] ~= nil then return g.lt_modules[name] or nil end
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local core = modules and modules:FindFirstChild("Core")
        local game_folder = modules and modules:FindFirstChild("Game")
        local phone = game_folder and game_folder:FindFirstChild("Phone")
        local app_modules = phone and phone:FindFirstChild("AppModules")
        local avatar_app = app_modules and app_modules:FindFirstChild("Avatar")
        local char_module = core and core:FindFirstChild("Char")
        local found = ({
            Net = core and core:FindFirstChild("Net"),
            HumDesc = char_module and char_module:FindFirstChild("HumDesc"),
            PropertyEncoding = core and core:FindFirstChild("PropertyEncoding"),
            AvatarConstants = avatar_app and avatar_app:FindFirstChild("Constants"),
        })[name]
        local ok, result = false, nil
        if found and found:IsA("ModuleScript") then ok, result = pcall(require, found) end
        g.lt_modules[name] = (ok and result) or false
        return g.lt_modules[name] or nil
    end
    local function lt_guard_outfit(payload)
        local mine = g.lt_get_desc and g.lt_get_desc(LocalPlayer)
        if not mine then return end
        local before = g.lt_serialise(mine)
        mine:Destroy()
        local had, sent = 0, 0
        for _, a in ipairs(before.accessories or {}) do if (tonumber(a.AssetId) or 0) > 0 then had += 1 end end
        for _, a in ipairs(type(payload) == "table" and payload.accessories or {}) do if (tonumber(a.AssetId) or 0) > 0 then sent += 1 end end
        if sent == 0 or had == 0 then return end
        task.spawn(function()
            for _, wait_for in ipairs({ 3, 3 }) do
                task.wait(wait_for)
                local now = g.lt_get_desc(LocalPlayer)
                if not now then return end
                local wearing = #now:GetAccessories(true)
                now:Destroy()
                if wearing > 0 then return end
            end
            if sent > had then g.lt_item_limit = math.min(g.lt_item_limit or math.huge, had) end
            g.lt_restoring = true
            pcall(g.lt_send, "wear_outfit_from_desc", before)
            g.lt_restoring = false
            g.notify("Warning", g.lt_item_limit and ("The game only allows %d items and wiped your outfit, so it was put back."):format(g.lt_item_limit)
                or "The game wiped your outfit, so it was put back.", 6)
        end)
    end
    g.lt_send = function(key, ...)
        if key == "wear_outfit_from_desc" and not g.lt_restoring then pcall(lt_guard_outfit, (...)) end
        if typeof(g.Send) == "function" then return g.Send(key, ...) end
        local Net = g.lt_require("Net")
        if Net then return Net.send(key, ...) end
    end
    g.lt_get = function(key, ...)
        if typeof(g.Get) == "function" then return g.Get(key, ...) end
        local Net = g.lt_require("Net")
        if Net then return Net.get(key, ...) end
    end
    g.lt_encode_v3 = function(v)
        local PropertyEncoding = g.lt_require("PropertyEncoding")
        if PropertyEncoding and PropertyEncoding.encode and PropertyEncoding.encode.vector3 then
            local ok, text = pcall(PropertyEncoding.encode.vector3, v)
            if ok and type(text) == "string" then return text end
        end
        local function part(n) return n == 0 and "" or tostring(math.round(n * 1000) / 1000) end
        return part(v.X) .. " " .. part(v.Y) .. " " .. part(v.Z)
    end
    g.lt_get_desc = function(player)
        local char = player and player.Character
        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
        if not hum then return nil end
        local ok, desc = pcall(hum.GetAppliedDescription, hum)
        return ok and desc or nil
    end
    g.lt_serialise = function(desc)
        local HumDesc = g.lt_require("HumDesc")
        if HumDesc and HumDesc.serialise_humanoid_description then
            local ok, payload = pcall(HumDesc.serialise_humanoid_description, desc)
            if ok and type(payload) == "table" and type(payload.accessories) == "table" then return payload end
        end
        local accessories, properties = {}, {}
        for _, a in ipairs(desc:GetAccessories(true)) do
            table.insert(accessories, {
                AccessoryType = a.AccessoryType.Name,
                AssetId = a.AssetId,
                IsLayered = a.IsLayered,
                Order = a.IsLayered and a.Order or nil,
                Puffiness = a.IsLayered and a.Puffiness or nil,
                Position = g.lt_encode_v3(a.Position or Vector3.zero),
                Rotation = g.lt_encode_v3(a.Rotation or Vector3.zero),
                Scale = g.lt_encode_v3(a.Scale or Vector3.one),
            })
        end
        for _, list in ipairs({ LT_BODY, LT_CLASSIC, LT_ANIMS, LT_SCALES, { "Face" } }) do
            for _, prop in ipairs(list) do
                local ok, v = pcall(function() return desc[prop] end)
                if ok and type(v) == "number" then properties[prop] = v end
            end
        end
        return { accessories = accessories, makeups = {}, properties = properties }
    end
    g.lt_order_layers = function(payload)
        local rigid, layered = {}, {}
        for i, a in ipairs(payload.accessories or {}) do
            table.insert(a.IsLayered and layered or rigid, { a = a, i = i })
        end
        table.sort(layered, function(x, y)
            local ox, oy = tonumber(x.a.Order) or 0, tonumber(y.a.Order) or 0
            if ox ~= oy then return ox < oy end
            return x.i < y.i
        end)
        local ordered = {}
        for _, e in ipairs(rigid) do table.insert(ordered, e.a) end
        for n, e in ipairs(layered) do
            e.a.Order = n
            table.insert(ordered, e.a)
        end
        payload.accessories = ordered
        return payload
    end
    g.lt_outfit_pieces = function(payload)
        local pieces = {}
        for _, a in ipairs(payload.accessories or {}) do
            local id = tonumber(a.AssetId)
            if id and id > 0 then
                table.insert(pieces, { id = id, kind = tostring(a.AccessoryType) .. "Accessory", accessory = true, layered = a.IsLayered == true })
            end
        end
        local props = payload.properties or {}
        for _, list in ipairs({ LT_CLASSIC, LT_BODY, { "Face" }, LT_ANIMS }) do
            for _, prop in ipairs(list) do
                local id = tonumber(props[prop])
                if id and id > 0 then table.insert(pieces, { id = id, kind = LT_WEAR_TYPE[prop] or prop }) end
            end
        end
        return pieces
    end
    local function lt_strip_order(pieces)
        local rigid, layered, rest, out = {}, {}, {}, {}
        for _, p in ipairs(pieces) do
            if p.layered then
                table.insert(layered, 1, p)
            elseif p.accessory then
                table.insert(rigid, p)
            else
                table.insert(rest, p)
            end
        end
        for _, list in ipairs({ rigid, layered, rest }) do
            for _, p in ipairs(list) do table.insert(out, p) end
        end
        return out
    end
    local function lt_wearing_same_accessories(payload)
        local mine = g.lt_get_desc(LocalPlayer)
        if not mine then return true end
        local want = {}
        for _, a in ipairs(payload.accessories or {}) do
            local id = tonumber(a.AssetId)
            if id and id > 0 then want[id] = (want[id] or 0) + 1 end
        end
        local same = true
        for _, a in ipairs(mine:GetAccessories(true)) do
            if want[a.AssetId] then
                want[a.AssetId] -= 1
                if want[a.AssetId] == 0 then want[a.AssetId] = nil end
            else
                same = false
            end
        end
        mine:Destroy()
        return same and next(want) == nil
    end
    g.lt_apply_look = function(look)
        g.lt_bulk_wearing = true
        local ok, result = pcall(g.lt_apply_look_steps, look)
        g.lt_bulk_wearing = false
        if not ok then error(result, 0) end
        return result
    end
    g.lt_apply_look_steps = function(look)
        local payload = look.payload
        if type(payload) ~= "table" then error("no outfit to wear", 0) end
        g.lt_order_layers(payload)
        local step = tonumber(g.lt_copy_step) or 0.2
        if look.slow then
            local mine = g.lt_get_desc(LocalPlayer)
            if mine then
                local current = g.lt_serialise(mine)
                mine:Destroy()
                g.lt_order_layers(current)
                for _, piece in ipairs(lt_strip_order(g.lt_outfit_pieces(current))) do
                    pcall(g.lt_get, "wear", piece.id, piece.kind)
                    task.wait(step)
                end
            end
        end
        local my_age = tostring(LocalPlayer:GetAttribute("age") or "adult")
        local age = look.age and LT_AGE_NAMES[tostring(look.age):lower()]
        if age and age ~= my_age then
            pcall(g.lt_get, "age", age)
            task.wait(step)
        end
        if typeof(look.skin) == "Color3" then
            pcall(g.lt_send, "skin_tone", look.skin)
            task.wait(step)
        end
        if look.slow then
            for _, piece in ipairs(g.lt_outfit_pieces(payload)) do
                pcall(g.lt_get, "wear", piece.id, piece.kind)
                task.wait(step)
            end
        end
        local mult = LT_AGE_MULT[age or my_age] or 1
        local props = payload.properties or {}
        local height, width = tonumber(props.HeightScale), tonumber(props.WidthScale)
        if height then
            pcall(g.lt_send, "body_scale", "HeightScale", math.clamp(math.floor(height / mult * 100 + 0.5), 90, 105))
            task.wait(0.15)
        end
        if width then
            pcall(g.lt_send, "body_scale", "WidthScale", math.clamp(math.floor(width / mult * 100 + 0.5), 70, 100))
            task.wait(0.15)
        end
        for _ = 1, 3 do
            pcall(g.lt_send, "wear_outfit_from_desc", payload)
            task.wait(1.5)
            if lt_wearing_same_accessories(payload) then break end
        end
        if g.lt_remember_body_size then g.lt_remember_body_size(payload.properties) end
        return true
    end
    g.lt_copy_outfit = function(player)
        local desc = g.lt_get_desc(player)
        if not desc then error("couldn't read " .. tostring(player) .. "'s outfit", 0) end
        local payload = g.lt_serialise(desc)
        desc:Destroy()
        local body_colors = player.Character and player.Character:FindFirstChildOfClass("BodyColors")
        local age = player:GetAttribute("age")
        return g.lt_apply_look({
            payload = payload,
            age = age and tostring(age) or nil,
            skin = (body_colors and typeof(g.avgSkin) == "function") and g.avgSkin(body_colors) or nil,
            slow = true,
        })
    end
    g.lt_ui_hidden = g.lt_ui_hidden or false
    g.lt_refresh_popups = function()
        if g.lt_skin_gui then g.lt_skin_gui.Enabled = (g.lt_skin_open == true) and not g.lt_ui_hidden end
        if g.lt_editor_gui then g.lt_editor_gui.Enabled = (g.lt_editor and g.lt_editor.enabled == true) and not g.lt_ui_hidden end
        if g.lt_outfits_gui then g.lt_outfits_gui.Enabled = (g.lt_outfits_open == true) and not g.lt_ui_hidden end
        if g.lt_catalog_gui then g.lt_catalog_gui.Enabled = (g.lt_catalog_open == true) and not g.lt_ui_hidden end
        if g.lt_carry_gui then g.lt_carry_gui.Enabled = (g.lt_carry_shown == true) and not g.lt_ui_hidden end
    end
    do
        g.lt_editor = g.lt_editor or {}
        local LTE = g.lt_editor
        LTE.mode = LTE.mode or "Move"
        LTE.snap_move = LTE.snap_move or 0
        LTE.snap_rotate = LTE.snap_rotate or 0
        LTE.snap_scale = LTE.snap_scale or 0
        if LTE.snap_on == nil then LTE.snap_on = false end
        if LTE.uniform == nil then LTE.uniform = false end
        if LTE.anims_on == nil then LTE.anims_on = false end
        LTE.selected = LTE.selected or {}
        LTE.conns = LTE.conns or {}
        LTE.asset_keys = LTE.asset_keys or {}
        LTE.names = LTE.names or {}
        LTE.entries = LTE.entries or {}
        LTE.learned = LTE.learned or setmetatable({}, { __mode = "k" })
        LTE.resolving = LTE.resolving or {}
        LTE.resolve_queue = LTE.resolve_queue or {}
        LTE.convention = LTE.convention_checked and LTE.convention or "xyz_tr"
    LTE.convention_checked = true
        local SETTINGS_FILE = "lifetogether_accessory_editor.json"
        if not LTE.settings_loaded then
            LTE.settings_loaded = true
            pcall(function()
                if typeof(isfile) == "function" and isfile(SETTINGS_FILE) then
                    local saved = HttpService:JSONDecode(readfile(SETTINGS_FILE))
                    for id, v in pairs(type(saved.meshes) == "table" and saved.meshes or {}) do
                        if type(v) == "table" and tonumber(id) then LTE.asset_keys[tonumber(id)] = v end
                    end
                    if type(saved.convention2) == "string" then LTE.convention = saved.convention2 end
                end
            end)
        end
        local U = {}
        function U.save_settings()
            pcall(function()
                if typeof(writefile) ~= "function" then return end
                local meshes = {}
                for id, v in pairs(LTE.asset_keys) do
                    if type(v) == "table" then meshes[tostring(id)] = v end
                end
                writefile(SETTINGS_FILE, HttpService:JSONEncode({ meshes = meshes, convention2 = LTE.convention }))
            end)
        end
        function U.snap(n, step)
            if not LTE.snap_on or not step or step <= 0 then return n end
            return math.round(n / step) * step
        end
        function U.tidy(v)
            return Vector3.new(math.round(v.X * 1000) / 1000, math.round(v.Y * 1000) / 1000, math.round(v.Z * 1000) / 1000)
        end
        function U.layered(acc) return acc:FindFirstChildWhichIsA("WrapLayer", true) ~= nil end
        function U.digits(text) return text and tostring(text):match("%d+") or "" end
        function U.part_key(part)
            if part:IsA("MeshPart") then return U.digits(part.MeshId) .. "|" .. U.digits(part.TextureID) end
            local mesh = part:FindFirstChildWhichIsA("SpecialMesh")
            return mesh and (U.digits(mesh.MeshId) .. "|" .. U.digits(mesh.TextureId)) or "|"
        end
        U.conventions = { "xyz_tr", "yxz_tr", "xyz_rt", "yxz_rt" }
        function U.offset_cf(p, r, conv)
            local rot = conv:sub(1, 3) == "yxz" and CFrame.fromOrientation(math.rad(r.X), math.rad(r.Y), math.rad(r.Z))
                or CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z))
            if conv:sub(-2) == "rt" then return rot * CFrame.new(p) end
            return CFrame.new(p) * rot
        end
        function U.offset_values(cf, conv)
            local rot = cf.Rotation
            local rx, ry, rz
            if conv:sub(1, 3) == "yxz" then rx, ry, rz = rot:ToOrientation() else rx, ry, rz = rot:ToEulerAnglesXYZ() end
            local p = conv:sub(-2) == "rt" and rot:Inverse() * cf.Position or cf.Position
            return U.tidy(p), U.tidy(Vector3.new(math.deg(rx), math.deg(ry), math.deg(rz)))
        end
        function U.scaled(attach, s) return CFrame.new(attach.Position * s) * attach.Rotation end
        function U.unscaled(attach, s) return CFrame.new(attach.Position / s) * attach.Rotation end
        function U.angle(a, b)
            local _, angle = (a.Rotation:Inverse() * b.Rotation):ToAxisAngle()
            return math.deg(math.abs(angle))
        end
        function U.resolve(ids)
            for _, id in ipairs(ids) do
                if type(LTE.asset_keys[id]) ~= "table" and not LTE.resolving[id] then
                    LTE.resolving[id] = true
                    table.insert(LTE.resolve_queue, id)
                end
            end
            if LTE.resolve_running or #LTE.resolve_queue == 0 then return end
            LTE.resolve_running = true
            g.notify("Info", "Checking which of your look-alike accessories is which (the game may pause for a moment)...", 4)
            task.spawn(function()
                while #LTE.resolve_queue > 0 do
                    local id = table.remove(LTE.resolve_queue, 1)
                    local found = { key = "none", mesh = "" }
                    local ok, objects = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
                    for _, obj in ipairs((ok and type(objects) == "table") and objects or {}) do
                        local handle = obj:FindFirstChild("Handle", true)
                        if found.key == "none" and handle and handle:IsA("BasePart") then
                            local key = U.part_key(handle)
                            found = { key = key, mesh = key:match("^(%d*)") }
                        end
                        pcall(function() obj:Destroy() end)
                    end
                    LTE.asset_keys[id] = found
                    LTE.resolving[id] = nil
                    task.wait(0.3)
                end
                LTE.resolve_running = false
                U.save_settings()
            end)
        end
        function U.name(id)
            if LTE.names[id] == nil then
                LTE.names[id] = false
                task.spawn(function()
                    local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(id) end)
                    LTE.names[id] = (ok and type(info) == "table" and info.Name) or ("Item " .. tostring(id))
                end)
            end
            return LTE.names[id] or nil
        end
        function U.rigid_ids()
            local ids = {}
            local desc = g.lt_get_desc(LocalPlayer)
            if desc then
                for _, a in ipairs(desc:GetAccessories(true)) do
                    if not a.IsLayered then ids[a.AssetId] = (ids[a.AssetId] or 0) + 1 end
                end
                desc:Destroy()
            end
            return ids
        end
        function U.watch(char)
            if LTE.watch_conn then pcall(function() LTE.watch_conn:Disconnect() end) end
            if not char then return end
            task.defer(function() LTE.known_ids = U.rigid_ids() end)
            LTE.watch_conn = char.ChildAdded:Connect(function(child)
                if not child:IsA("Accessory") then return end
                task.wait(0.2)
                if not child.Parent or U.layered(child) then return end
                local now, added = U.rigid_ids(), {}
                for id, n in pairs(now) do
                    if n > ((LTE.known_ids or {})[id] or 0) then table.insert(added, id) end
                end
                LTE.known_ids = now
                if #added == 1 then LTE.learned[child] = added[1] end
            end)
        end
        if g.lt_watch_char_conn then pcall(function() g.lt_watch_char_conn:Disconnect() end) end
        g.lt_watch_char_conn = LocalPlayer.CharacterAdded:Connect(U.watch)
        U.watch(LocalPlayer.Character)
        function U.refresh_entries()
            local entries = {}
            local desc = g.lt_get_desc(LocalPlayer)
            if desc then
                for _, a in ipairs(desc:GetAccessories(true)) do
                    if not a.IsLayered and (a.AssetId or 0) > 0 then
                        table.insert(entries, {
                            id = a.AssetId, type = a.AccessoryType,
                            pos = a.Position or Vector3.zero, rot = a.Rotation or Vector3.zero, scale = a.Scale or Vector3.one,
                        })
                    end
                end
                desc:Destroy()
            end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            local worn, used = {}, {}
            for _, c in ipairs(char and char:GetChildren() or {}) do
                if c:IsA("Accessory") and c:FindFirstChild("Handle") and not U.layered(c) then table.insert(worn, c) end
            end
            local function claim(e, acc)
                e.acc = acc
                used[acc] = true
            end
            for _, e in ipairs(entries) do
                for _, acc in ipairs(worn) do
                    if not e.acc and not used[acc] and LTE.learned[acc] == e.id and acc.AccessoryType == e.type then claim(e, acc) end
                end
            end
            local applied = hum and hum:FindFirstChildOfClass("HumanoidDescription")
            for _, ad in ipairs(applied and applied:GetChildren() or {}) do
                if ad:IsA("AccessoryDescription") then
                    local ok, inst = pcall(function() return ad.Instance end)
                    if ok and inst and table.find(worn, inst) and not used[inst] then
                        for _, e in ipairs(entries) do
                            if e.id == ad.AssetId and not e.acc then
                                claim(e, inst)
                                break
                            end
                        end
                    end
                end
            end
            for pass = 1, 2 do
                for _, e in ipairs(entries) do
                    local asset = not e.acc and LTE.asset_keys[e.id]
                    if type(asset) == "table" and asset.key ~= "none" then
                        for _, acc in ipairs(worn) do
                            if not used[acc] then
                                local key = U.part_key(acc.Handle)
                                if (pass == 1 and key == asset.key) or (pass == 2 and asset.mesh ~= "" and key:match("^(%d*)") == asset.mesh) then
                                    claim(e, acc)
                                    break
                                end
                            end
                        end
                    end
                end
            end
            for _, e in ipairs(entries) do
                if not e.acc then
                    local entries_left, worn_left, last = 0, 0, nil
                    for _, other in ipairs(entries) do
                        if not other.acc and other.type == e.type then entries_left += 1 end
                    end
                    for _, acc in ipairs(worn) do
                        if not used[acc] and acc.AccessoryType == e.type then
                            worn_left += 1
                            last = acc
                        end
                    end
                    if entries_left == 1 and worn_left == 1 then claim(e, last) end
                end
            end
            local to_check = {}
            for _, e in ipairs(entries) do
                if not e.acc then
                    for _, acc in ipairs(worn) do
                        if not used[acc] and acc.AccessoryType == e.type then
                            claim(e, acc)
                            e.guess = true
                            e.pending = type(LTE.asset_keys[e.id]) ~= "table"
                            break
                        end
                    end
                end
            end
            for _, e in ipairs(entries) do
                if e.pending and LTE.selected[e.id] then
                    for _, other in ipairs(entries) do
                        if other.pending and other.type == e.type then table.insert(to_check, other.id) end
                    end
                end
            end
            if #to_check > 0 then U.resolve(to_check) end
            local present = {}
            for _, e in ipairs(entries) do
                present[e.id] = true
                U.name(e.id)
            end
            for id in pairs(LTE.selected) do
                if not present[id] then LTE.selected[id] = nil end
            end
            LTE.entries = entries
            return entries
        end
        function U.selected_items()
            local items = {}
            for _, e in ipairs(LTE.entries) do
                if LTE.selected[e.id] and not e.guess and e.acc and e.acc.Parent and e.acc:FindFirstChild("Handle") then table.insert(items, e) end
            end
            return items
        end
        function U.joint(acc)
            local handle = acc and acc:FindFirstChild("Handle")
            if not handle then return nil end
            for _, d in ipairs(handle:GetDescendants()) do
                if d:IsA("RigidConstraint") and d.Attachment0 and d.Attachment1 then return handle, d.Attachment0, d.Attachment1 end
            end
            for _, att in ipairs(handle:GetChildren()) do
                if att:IsA("Attachment") and acc.Parent then
                    local body = acc.Parent:FindFirstChild(att.Name, true)
                    if body and body:IsA("Attachment") and body ~= att then return handle, att, body end
                end
            end
            return handle
        end
        g.lt_send_adjustments = function(changes, quiet)
            local desc = g.lt_get_desc(LocalPlayer)
            if not desc then return false end
            local payload = g.lt_serialise(desc)
            desc:Destroy()
            local hit = false
            for _, a in ipairs(payload.accessories or {}) do
                local change = not a.IsLayered and changes[tonumber(a.AssetId)]
                if change then
                    a.Position = g.lt_encode_v3(change.pos)
                    a.Rotation = g.lt_encode_v3(change.rot)
                    a.Scale = g.lt_encode_v3(change.scale)
                    hit = true
                end
            end
            if not hit then
                if not quiet then g.notify("Error", "Those accessories aren't in your outfit anymore.", 4) end
                return false
            end
            g.lt_order_layers(payload)
            pcall(g.lt_send, "wear_outfit_from_desc", payload)
            return true
        end
        function U.set_still(on)
            if LTE.anim_conn then
                pcall(function() LTE.anim_conn:Disconnect() end)
                LTE.anim_conn = nil
            end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            local animate = char and char:FindFirstChild("Animate")
            if animate and animate:IsA("BaseScript") then pcall(function() animate.Disabled = on end) end
            if on and animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do pcall(function() track:Stop(0.1) end) end
                LTE.anim_conn = animator.AnimationPlayed:Connect(function(track)
                    if LTE.enabled and not LTE.anims_on then pcall(function() track:Stop(0) end) end
                end)
            end
        end
        function U.clear_visuals()
            if LTE.folder then pcall(function() LTE.folder:Destroy() end) end
            if LTE.proxy then pcall(function() LTE.proxy:Destroy() end) end
            LTE.folder, LTE.proxy = nil, nil
        end
        function U.place_proxy()
            local proxy = LTE.proxy
            if not proxy or LTE.drag then return end
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local items = U.selected_items()
            if not root or #items == 0 then return end
            local frame = root.CFrame
            local min_v, max_v
            for _, e in ipairs(items) do
                local part = e.acc.Handle
                local half = part.Size / 2
                for _, sx in ipairs({ -1, 1 }) do
                    for _, sy in ipairs({ -1, 1 }) do
                        for _, sz in ipairs({ -1, 1 }) do
                            local corner = frame:PointToObjectSpace(part.CFrame:PointToWorldSpace(Vector3.new(half.X * sx, half.Y * sy, half.Z * sz)))
                            min_v = min_v and min_v:Min(corner) or corner
                            max_v = max_v and max_v:Max(corner) or corner
                        end
                    end
                end
            end
            proxy.Size = (max_v - min_v) + Vector3.new(0.1, 0.1, 0.1)
            proxy.CFrame = frame * CFrame.new((min_v + max_v) / 2)
        end
        function U.set_target(it, world_cf, new_scale)
            it.target = it.att_cf:Inverse() * world_cf
            it.new_scale = U.tidy(new_scale or it.scale)
            it.new_pos, it.new_rot = U.offset_values(it.target * U.scaled(it.base[LTE.convention], it.new_scale), LTE.convention)
            pcall(function()
                if it.att0 then it.att0.CFrame = it.target:Inverse() end
                it.part.Size = it.start_size * (it.new_scale / it.scale)
            end)
        end
        function U.begin()
            if not LTE.proxy then return end
            if LTE.settling then
                g.notify("Info", "Still saving your last change, one second...", 2)
                return
            end
            local items = {}
            for _, e in ipairs(U.selected_items()) do
                local part, att0, att1 = U.joint(e.acc)
                if part and att0 and att1 then
                    local att_cf = att1.WorldCFrame
                    local here = att_cf:Inverse() * part.CFrame
                    local base = {}
                    for _, conv in ipairs(U.conventions) do
                        base[conv] = U.unscaled(here:Inverse() * U.offset_cf(e.pos, e.rot, conv), e.scale)
                    end
                    table.insert(items, {
                        id = e.id,
                        pos = e.pos, rot = e.rot, scale = e.scale,
                        new_pos = e.pos, new_rot = e.rot, new_scale = e.scale,
                        part = part, att0 = att0, att_cf = att_cf,
                        start_cf = part.CFrame, start_size = part.Size, start_att = att0.CFrame,
                        target = here, base = base,
                    })
                end
            end
            if #items == 0 then return end
            LTE.drag = { items = items, proxy_cf = LTE.proxy.CFrame, proxy_size = LTE.proxy.Size }
        end
        function U.drag_move(face, distance)
            local d = LTE.drag
            if not d then return end
            local world = d.proxy_cf:VectorToWorldSpace(Vector3.FromNormalId(face)) * U.snap(distance, LTE.snap_move)
            for _, it in ipairs(d.items) do U.set_target(it, it.start_cf + world) end
            LTE.proxy.CFrame = d.proxy_cf + world
        end
        function U.drag_rotate(axis, relative_angle)
            local d = LTE.drag
            if not d then return end
            local degrees = U.snap(math.deg(relative_angle), LTE.snap_rotate)
            local axis_world = d.proxy_cf:VectorToWorldSpace(Vector3.FromAxis(axis))
            local pivot = d.proxy_cf.Position
            local turn = CFrame.new(pivot) * CFrame.fromAxisAngle(axis_world, math.rad(degrees)) * CFrame.new(-pivot)
            for _, it in ipairs(d.items) do U.set_target(it, turn * it.start_cf) end
            LTE.proxy.CFrame = turn * d.proxy_cf
        end
        function U.drag_scale(face, distance)
            local d = LTE.drag
            if not d then return end
            local axis = Vector3.FromNormalId(face)
            local mask = Vector3.new(math.abs(axis.X), math.abs(axis.Y), math.abs(axis.Z))
            local length = math.max(mask:Dot(d.proxy_size), 0.01)
            local factor = math.max(0.05, (length + distance) / length)
            if LTE.snap_on and LTE.snap_scale > 0 then factor = math.max(LTE.snap_scale, U.snap(factor, LTE.snap_scale)) end
            local anchor = -axis * (d.proxy_size / 2)
            local function stretch(point)
                if LTE.uniform then return anchor + (point - anchor) * factor end
                return point + mask * ((point - anchor) * (factor - 1))
            end
            for _, it in ipairs(d.items) do
                local center = d.proxy_cf:PointToWorldSpace(stretch(d.proxy_cf:PointToObjectSpace(it.start_cf.Position)))
                local ratio = Vector3.one * factor
                if not LTE.uniform then
                    local local_axis = it.start_cf:VectorToObjectSpace(d.proxy_cf:VectorToWorldSpace(axis))
                    local ax, ay, az = math.abs(local_axis.X), math.abs(local_axis.Y), math.abs(local_axis.Z)
                    local item_mask = (ax >= ay and ax >= az) and Vector3.xAxis or ((ay >= az) and Vector3.yAxis or Vector3.zAxis)
                    ratio = Vector3.one + item_mask * (factor - 1)
                end
                U.set_target(it, CFrame.new(center) * it.start_cf.Rotation, it.scale * ratio)
            end
            LTE.proxy.CFrame = d.proxy_cf * CFrame.new(stretch(Vector3.zero))
            LTE.proxy.Size = LTE.uniform and d.proxy_size * factor or (d.proxy_size + mask * (length * (factor - 1)))
        end
        function U.wait_rebuild(items)
            local char = LocalPlayer.Character
            if not char then return end
            local last_change = os.clock()
            local conns = {
                char.ChildAdded:Connect(function(c) if c:IsA("Accessory") then last_change = os.clock() end end),
                char.ChildRemoved:Connect(function(c) if c:IsA("Accessory") then last_change = os.clock() end end),
            }
            local started = os.clock()
            while os.clock() - started < 4 do
                task.wait(0.2)
                local changed = false
                for _, e in ipairs(U.refresh_entries()) do
                    for _, it in ipairs(items) do
                        if e.id == it.id and (e.pos ~= it.pos or e.rot ~= it.rot or e.scale ~= it.scale) then changed = true end
                    end
                end
                if changed then break end
            end
            while os.clock() - started < 12 and os.clock() - last_change < 1 do task.wait(0.1) end
            for _, c in ipairs(conns) do c:Disconnect() end
        end
        function U.settle(items, corrected)
            U.wait_rebuild(items)
            local entries = U.refresh_entries()
            local fixes, fix_count, limited, reset, off = {}, 0, 0, 0, 0
            for _, it in ipairs(items) do
                local e
                for _, entry in ipairs(entries) do
                    if entry.id == it.id then
                        e = entry
                        break
                    end
                end
                local part, _, att1 = U.joint(e and e.acc)
                if e and not e.guess and part and att1 then
                    local kept = (e.pos - it.new_pos).Magnitude < 0.01 and (e.rot - it.new_rot).Magnitude < 0.5 and (e.scale - it.new_scale).Magnitude < 0.01
                    local is_default = e.pos.Magnitude < 0.001 and e.rot.Magnitude < 0.001 and (e.scale - Vector3.one).Magnitude < 0.001
                    if not kept then
                        if is_default then reset += 1 else limited += 1 end
                    else
                        local actual = att1.WorldCFrame:Inverse() * part.CFrame
                        local errs, best, second = {}, nil, nil
                        for _, conv in ipairs(U.conventions) do
                            local predicted = U.offset_cf(e.pos, e.rot, conv) * U.scaled(it.base[conv], e.scale):Inverse()
                            errs[conv] = (predicted.Position - actual.Position).Magnitude + U.angle(predicted, actual) / 90
                            if not best or errs[conv] < errs[best] then
                                best, second = conv, best
                            elseif not second or errs[conv] < errs[second] then
                                second = conv
                            end
                        end
                        local clear = errs[best] < 0.03 and (not second or errs[second] - errs[best] > 0.05)
                        if clear and best ~= LTE.convention then
                            LTE.convention = best
                            U.save_settings()
                        end
                        local off_target = (actual.Position - it.target.Position).Magnitude > 0.03 or U.angle(actual, it.target) > 2
                        if off_target then
                            if clear and not corrected then
                                local p, r = U.offset_values(it.target * U.scaled(it.base[LTE.convention], e.scale), LTE.convention)
                                fixes[it.id] = { pos = p, rot = r, scale = e.scale }
                                fix_count += 1
                                it.pos, it.rot, it.scale = e.pos, e.rot, e.scale
                                it.new_pos, it.new_rot, it.new_scale = p, r, e.scale
                            else
                                off += 1
                            end
                        end
                    end
                end
            end
            if fix_count > 0 and g.lt_send_adjustments(fixes, true) then
                U.settle(items, true)
                return
            end
            if reset > 0 then
                g.notify("Warning", "The server put " .. reset .. " accessor" .. (reset == 1 and "y" or "ies") .. " back to default.", 4)
            elseif limited > 0 then
                g.notify("Info", "The server stops " .. limited .. " of them going that far, so it's as far as it can go.", 4)
            elseif off > 0 then
                g.notify("Info", "Saved. The game placed it a little differently from the preview.", 3)
            else
                g.notify("Success", #items == 1 and "Saved, everyone can see it." or (#items .. " accessories saved."), 2)
            end
            if LTE.refresh_window then LTE.refresh_window() end
        end
        function U.finish()
            local d = LTE.drag
            LTE.drag = nil
            task.delay(0.1, function() LTE.dragging = false end)
            if not d then return end
            local changes, moved = {}, {}
            for _, it in ipairs(d.items) do
                if it.new_pos ~= it.pos or it.new_rot ~= it.rot or it.new_scale ~= it.scale then
                    changes[it.id] = { pos = it.new_pos, rot = it.new_rot, scale = it.new_scale }
                    table.insert(moved, it)
                end
            end
            if #moved == 0 then return end
            if not g.lt_send_adjustments(changes) then
                for _, it in ipairs(moved) do
                    pcall(function()
                        it.att0.CFrame = it.start_att
                        it.part.Size = it.start_size
                    end)
                end
                return
            end
            LTE.settling = true
            task.spawn(function()
                pcall(U.settle, moved, false)
                LTE.settling = false
            end)
        end
        function U.build_visuals()
            U.clear_visuals()
            LTE.visual_sig = nil
            if not LTE.enabled then return end
            local items = U.selected_items()
            if #items == 0 then return end
            local folder = Instance.new("Folder")
            folder.Name = "FlamesAccessoryEditor"
            folder.Parent = lt_gui_parent()
            LTE.folder = folder
            local proxy = Instance.new("Part")
            proxy.Name = "FlamesAccessoryEditorBox"
            proxy.Anchored = true
            proxy.CanCollide = false
            proxy.CanQuery = false
            proxy.CanTouch = false
            proxy.CastShadow = false
            proxy.Transparency = 1
            proxy.Parent = workspace.CurrentCamera
            LTE.proxy = proxy
            U.place_proxy()
            local box = Instance.new("SelectionBox")
            box.Adornee = proxy
            box.Color3 = LT_ACCENT
            box.LineThickness = 0.03
            box.SurfaceColor3 = LT_ACCENT
            box.SurfaceTransparency = 0.9
            box.Parent = folder
            for _, e in ipairs(items) do
                local outline = Instance.new("SelectionBox")
                outline.Adornee = e.acc.Handle
                outline.Color3 = Color3.fromRGB(140, 190, 255)
                outline.LineThickness = 0.012
                outline.SurfaceTransparency = 1
                outline.Parent = folder
            end
            local tool
            if LTE.mode == "Rotate" then
                tool = Instance.new("ArcHandles")
                tool.MouseDrag:Connect(U.drag_rotate)
            else
                tool = Instance.new("Handles")
                tool.Style = LTE.mode == "Scale" and Enum.HandlesStyle.Resize or Enum.HandlesStyle.Movement
                tool.Color3 = LTE.mode == "Scale" and Color3.fromRGB(90, 170, 255) or LT_ACCENT
                tool.MouseDrag:Connect(LTE.mode == "Scale" and U.drag_scale or U.drag_move)
            end
            tool.Adornee = proxy
            tool.Parent = folder
            tool.MouseButton1Down:Connect(function()
                LTE.dragging = true
                U.begin()
            end)
            tool.MouseButton1Up:Connect(U.finish)
            local sig = { LTE.mode }
            for _, e in ipairs(items) do table.insert(sig, tostring(e.id) .. "@" .. tostring(e.acc)) end
            LTE.visual_sig = table.concat(sig, ",")
        end
        function U.open_window()
            if g.lt_editor_gui and g.lt_editor_gui.Parent then
                g.lt_refresh_popups()
                return
            end
            local BG, PANEL, PANEL_ON, TEXT, DIM = Color3.fromRGB(16, 16, 21), Color3.fromRGB(28, 28, 36), Color3.fromRGB(26, 46, 92), Color3.fromRGB(235, 235, 240), Color3.fromRGB(150, 150, 165)
            local gui = Instance.new("ScreenGui")
            gui.Name = "FlamesAccessoryEditorWindow"
            gui.ResetOnSpawn = false
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.Parent = lt_gui_parent()
            g.lt_editor_gui = gui
            local main = Instance.new("Frame")
            main.Size = UDim2.fromOffset(300, 480)
            main.Position = UDim2.new(0, 30, 0.5, -240)
            main.BackgroundColor3 = BG
            main.BorderSizePixel = 0
            main.Parent = gui
            Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke")
            stroke.Color = LT_ACCENT
            stroke.Thickness = 1.5
            stroke.Parent = main
            local function text_label(parent, text, x, y, w, h, size, color, bold)
                local l = Instance.new("TextLabel")
                l.BackgroundTransparency = 1
                l.Position = UDim2.fromOffset(x, y)
                l.Size = UDim2.fromOffset(w, h)
                l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
                l.TextSize = size or 13
                l.TextColor3 = color or TEXT
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.TextWrapped = true
                l.Text = text
                l.Parent = parent
                return l
            end
            local function button(text, x, y, w, h)
                local b = Instance.new("TextButton")
                b.Position = UDim2.fromOffset(x, y)
                b.Size = UDim2.fromOffset(w, h)
                b.BackgroundColor3 = PANEL
                b.BorderSizePixel = 0
                b.AutoButtonColor = true
                b.Font = Enum.Font.GothamBold
                b.TextSize = 13
                b.TextColor3 = TEXT
                b.Text = text
                b.Parent = main
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
                return b
            end
            local title = text_label(main, "Accessory Editor", 12, 6, 220, 24, 15, TEXT, true)
            title.Active = true
            local close = button("X", 266, 6, 24, 24)
            close.MouseButton1Click:Connect(function()
                g.lt_editor_toggle(false)
                pcall(function() g.Accessory_Editor_Toggle_UI:Set(false) end)
            end)
            do
                local dragging, start, start_pos
                title.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging, start, start_pos = true, input.Position, main.Position
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - start
                        main.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                end)
            end
            local tool_buttons = {
                Move = button("Move", 10, 38, 88, 28),
                Rotate = button("Rotate", 106, 38, 88, 28),
                Scale = button("Scale", 202, 38, 88, 28),
            }
            for mode, b in pairs(tool_buttons) do
                b.MouseButton1Click:Connect(function() g.lt_editor_set_mode(mode) end)
            end
            local all_btn = button("All", 10, 72, 62, 24)
            local none_btn = button("None", 78, 72, 62, 24)
            local reset_btn = button("Reset", 146, 72, 66, 24)
            local reset_all_btn = button("Reset All", 218, 72, 72, 24)
            local snap_btn = button("", 10, 102, 88, 24)
            local sides_btn = button("", 106, 102, 88, 24)
            local anims_btn = button("", 202, 102, 88, 24)
            snap_btn.TextSize, sides_btn.TextSize, anims_btn.TextSize = 12, 12, 12
            snap_btn.MouseButton1Click:Connect(function()
                LTE.snap_on = not LTE.snap_on
                LTE.refresh_window()
            end)
            sides_btn.MouseButton1Click:Connect(function()
                LTE.uniform = not LTE.uniform
                LTE.refresh_window()
            end)
            anims_btn.MouseButton1Click:Connect(function()
                LTE.anims_on = not LTE.anims_on
                U.set_still(LTE.enabled and not LTE.anims_on)
                LTE.refresh_window()
            end)
            text_label(main, "Tick the accessories to edit, then drag the arrows on your character. Shift-click one on your character to add it.", 12, 130, 278, 30, 11, DIM)
            local list = Instance.new("ScrollingFrame")
            list.Position = UDim2.fromOffset(10, 164)
            list.Size = UDim2.fromOffset(280, 252)
            list.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 4
            list.ScrollBarImageColor3 = LT_ACCENT
            list.AutomaticCanvasSize = Enum.AutomaticSize.Y
            list.CanvasSize = UDim2.new()
            list.Parent = main
            Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 4)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = list
            local pad = Instance.new("UIPadding")
            pad.PaddingTop, pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 8)
            pad.Parent = list
            local status = text_label(main, "", 12, 422, 278, 50, 12, TEXT)
            status.TextYAlignment = Enum.TextYAlignment.Top
            local rows, rows_sig = {}, nil
            LTE.refresh_window = function()
                if not (gui and gui.Parent) then return end
                for mode, b in pairs(tool_buttons) do b.BackgroundColor3 = (LTE.mode == mode) and LT_ACCENT or PANEL end
                snap_btn.Text = LTE.snap_on and "Snap: On" or "Snap: Off"
                snap_btn.BackgroundColor3 = LTE.snap_on and LT_ACCENT or PANEL
                sides_btn.Text = LTE.uniform and "All Sides" or "One Side"
                anims_btn.Text = LTE.anims_on and "Anims: On" or "Anims: Off"
                anims_btn.BackgroundColor3 = LTE.anims_on and LT_ACCENT or PANEL
                local sig_parts = {}
                for _, e in ipairs(LTE.entries) do table.insert(sig_parts, tostring(e.id)) end
                local sig = table.concat(sig_parts, ",")
                if sig ~= rows_sig then
                    rows_sig = sig
                    for _, r in ipairs(rows) do r.button:Destroy() end
                    table.clear(rows)
                    for index, e in ipairs(LTE.entries) do
                        local row = Instance.new("TextButton")
                        row.Size = UDim2.new(1, 0, 0, 30)
                        row.LayoutOrder = index
                        row.BackgroundColor3 = PANEL
                        row.BorderSizePixel = 0
                        row.AutoButtonColor = true
                        row.Text = ""
                        row.Parent = list
                        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
                        local check = Instance.new("Frame")
                        check.Size = UDim2.fromOffset(16, 16)
                        check.Position = UDim2.fromOffset(8, 7)
                        check.BorderSizePixel = 0
                        check.Parent = row
                        Instance.new("UICorner", check).CornerRadius = UDim.new(0, 4)
                        local check_stroke = Instance.new("UIStroke")
                        check_stroke.Color = LT_ACCENT
                        check_stroke.Parent = check
                        local picture = Instance.new("ImageLabel")
                        picture.Position = UDim2.fromOffset(28, 2)
                        picture.Size = UDim2.fromOffset(26, 26)
                        picture.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
                        picture.BorderSizePixel = 0
                        picture.Image = ("rbxthumb://type=Asset&id=%d&w=48&h=48"):format(e.id)
                        picture.Parent = row
                        Instance.new("UICorner", picture).CornerRadius = UDim.new(0, 4)
                        local name = Instance.new("TextLabel")
                        name.BackgroundTransparency = 1
                        name.Position = UDim2.fromOffset(60, 0)
                        name.Size = UDim2.new(1, -138, 1, 0)
                        name.Font = Enum.Font.GothamBold
                        name.TextSize = 12
                        name.TextColor3 = TEXT
                        name.TextXAlignment = Enum.TextXAlignment.Left
                        name.TextTruncate = Enum.TextTruncate.AtEnd
                        name.Parent = row
                        local kind = Instance.new("TextLabel")
                        kind.BackgroundTransparency = 1
                        kind.Position = UDim2.new(1, -76, 0, 0)
                        kind.Size = UDim2.fromOffset(70, 30)
                        kind.Font = Enum.Font.Gotham
                        kind.TextSize = 11
                        kind.TextColor3 = DIM
                        kind.TextXAlignment = Enum.TextXAlignment.Right
                        kind.Text = e.type.Name
                        kind.Parent = row
                        local id = e.id
                        row.MouseButton1Click:Connect(function()
                            LTE.selected[id] = (not LTE.selected[id]) or nil
                            U.refresh_entries()
                            U.build_visuals()
                            LTE.refresh_window()
                        end)
                        table.insert(rows, { id = id, button = row, check = check, name = name })
                    end
                end
                local selected_count, one = 0, nil
                for _, r in ipairs(rows) do
                    local e
                    for _, entry in ipairs(LTE.entries) do
                        if entry.id == r.id then
                            e = entry
                            break
                        end
                    end
                    local on = LTE.selected[r.id] == true
                    if on then
                        selected_count += 1
                        one = e
                    end
                    r.button.BackgroundColor3 = on and PANEL_ON or PANEL
                    r.check.BackgroundColor3 = on and LT_ACCENT or PANEL
                    local label = U.name(r.id) or ("Item " .. tostring(r.id))
                    if e and e.pending then
                        label ..= on and " (checking which one...)" or " (look-alike)"
                    elseif e and e.guess then
                        label ..= " (can't tell it apart)"
                    end
                    r.name.Text = label
                end
                if #LTE.entries == 0 then
                    status.Text = "You're not wearing any hats, hair, face, neck or other movable accessories."
                elseif selected_count == 0 then
                    status.Text = "Nothing picked. Tick one or more accessories."
                elseif selected_count == 1 and one then
                    status.Text = ("Tool: %s\nMove %.2f, %.2f, %.2f | Turn %.0f, %.0f, %.0f\nScale %.2f, %.2f, %.2f"):format(
                        LTE.mode, one.pos.X, one.pos.Y, one.pos.Z, one.rot.X, one.rot.Y, one.rot.Z, one.scale.X, one.scale.Y, one.scale.Z)
                else
                    status.Text = ("Tool: %s\n%d accessories picked, they move together."):format(LTE.mode, selected_count)
                end
            end
            all_btn.MouseButton1Click:Connect(function() g.lt_editor_select_all(true) end)
            none_btn.MouseButton1Click:Connect(function() g.lt_editor_select_all(false) end)
            reset_btn.MouseButton1Click:Connect(function() g.lt_reset_adjustments(false) end)
            reset_all_btn.MouseButton1Click:Connect(function() g.lt_reset_adjustments(true) end)
            LTE.refresh_window()
            g.lt_refresh_popups()
        end
        g.lt_editor_set_mode = function(mode)
            if mode ~= "Move" and mode ~= "Rotate" and mode ~= "Scale" then return end
            LTE.mode = mode
            U.build_visuals()
            if LTE.refresh_window then LTE.refresh_window() end
        end
        g.lt_editor_select_all = function(on)
            table.clear(LTE.selected)
            for _, e in ipairs(on and U.refresh_entries() or {}) do LTE.selected[e.id] = true end
            U.refresh_entries()
            U.build_visuals()
            if LTE.refresh_window then LTE.refresh_window() end
        end
        g.lt_editor_toggle = function(state)
            LTE.enabled = state and true or false
            for _, c in ipairs(LTE.conns) do pcall(function() c:Disconnect() end) end
            table.clear(LTE.conns)
            LTE.drag, LTE.dragging = nil, false
            table.clear(LTE.selected)
            U.set_still(LTE.enabled and not LTE.anims_on)
            if not LTE.enabled then
                U.clear_visuals()
                g.lt_refresh_popups()
                return
            end
            U.refresh_entries()
            U.open_window()
            local mouse = LocalPlayer:GetMouse()
            table.insert(LTE.conns, mouse.Button1Down:Connect(function()
                task.wait()
                if not LTE.enabled or LTE.dragging or LTE.drag then return end
                local target = mouse.Target
                local acc = target and target:FindFirstAncestorWhichIsA("Accessory")
                if not (acc and acc.Parent == LocalPlayer.Character) then return end
                local entry
                for _, e in ipairs(U.refresh_entries()) do
                    if e.acc == acc then
                        entry = e
                        break
                    end
                end
                if not entry then
                    if U.layered(acc) then g.notify("Info", "Layered clothing is fitted to your body, so it can't be moved.", 4) end
                    return
                end
                local adding = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
                    or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                if adding then
                    LTE.selected[entry.id] = (not LTE.selected[entry.id]) or nil
                else
                    table.clear(LTE.selected)
                    LTE.selected[entry.id] = true
                end
                U.refresh_entries()
                U.build_visuals()
                LTE.refresh_window()
            end))
            table.insert(LTE.conns, UserInputService.InputBegan:Connect(function(input, processed)
                if processed or not LTE.enabled then return end
                if not (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then return end
                local mode = ({ [Enum.KeyCode.Two] = "Move", [Enum.KeyCode.Three] = "Scale", [Enum.KeyCode.Four] = "Rotate" })[input.KeyCode]
                if mode then g.lt_editor_set_mode(mode) end
            end))
            table.insert(LTE.conns, UserInputService.InputEnded:Connect(function(input)
                if LTE.drag and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then U.finish() end
            end))
            table.insert(LTE.conns, LocalPlayer.CharacterAdded:Connect(function(char)
                U.clear_visuals()
                char:WaitForChild("Humanoid", 10)
                task.wait(0.5)
                if LTE.enabled and not LTE.anims_on then U.set_still(true) end
            end))
            table.insert(LTE.conns, RunService.Heartbeat:Connect(function() pcall(U.place_proxy) end))
            task.spawn(function()
                while LTE.enabled do
                    task.wait(0.5)
                    if LTE.enabled and not LTE.drag then
                        pcall(function()
                            U.refresh_entries()
                            local sig = { LTE.mode }
                            for _, e in ipairs(U.selected_items()) do table.insert(sig, tostring(e.id) .. "@" .. tostring(e.acc)) end
                            if table.concat(sig, ",") ~= LTE.visual_sig then U.build_visuals() end
                            LTE.refresh_window()
                        end)
                    end
                end
            end)
            g.notify("Success", "Accessory Editor on: tick accessories in the editor window, then drag the arrows. Animations are paused while you edit (Anims button turns them back on).", 7)
        end
        g.lt_reset_adjustments = function(all)
            local changes, count = {}, 0
            local defaults = { pos = Vector3.zero, rot = Vector3.zero, scale = Vector3.one }
            for _, e in ipairs(U.refresh_entries()) do
                if all or LTE.selected[e.id] then
                    changes[e.id] = defaults
                    count += 1
                end
            end
            if count == 0 then
                g.notify("Info", all and "You're not wearing any movable accessories." or "Tick the accessories to reset first.", 4)
                return
            end
            if g.lt_send_adjustments(changes) then
                g.notify("Success", all and "Reset every accessory." or ("Reset " .. count .. " accessor" .. (count == 1 and "y." or "ies.")), 3)
            end
        end
    end
    g.lt_last_skin_send = 0
    g.lt_set_skin = function(color, quiet)
        if typeof(color) ~= "Color3" then return end
        g.lt_last_skin_send = os.clock()
        pcall(g.lt_send, "skin_tone", color)
        if not quiet then
            g.notify("Success", ("Skin tone: %d, %d, %d"):format(math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)), 2)
        end
    end
    local function lt_skin_palette()
        local constants = g.lt_require("AvatarConstants")
        if constants and type(constants.Skin) == "table" and #constants.Skin > 0 then return constants.Skin end
        return {
            Color3.fromRGB(255, 218, 185), Color3.fromRGB(245, 202, 166), Color3.fromRGB(244, 184, 130), Color3.fromRGB(224, 156, 107),
            Color3.fromRGB(198, 120, 79), Color3.fromRGB(168, 95, 57), Color3.fromRGB(141, 76, 44), Color3.fromRGB(120, 65, 38),
            Color3.fromRGB(102, 57, 34), Color3.fromRGB(84, 45, 26), Color3.fromRGB(66, 35, 20), Color3.fromRGB(52, 27, 16),
        }
    end
    g.lt_open_skin_picker = function()
        g.lt_skin_open = true
        if g.lt_skin_gui and g.lt_skin_gui.Parent then g.lt_refresh_popups(); return end
        local BG, PANEL, TEXT = Color3.fromRGB(16, 16, 21), Color3.fromRGB(28, 28, 36), Color3.fromRGB(235, 235, 240)
        local gui = Instance.new("ScreenGui")
        gui.Name = "FlamesSkinPicker"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = lt_gui_parent()
        g.lt_skin_gui = gui
        local main = Instance.new("Frame")
        main.Size = UDim2.fromOffset(290, 430)
        main.Position = UDim2.new(0.5, 180, 0.5, -215)
        main.BackgroundColor3 = BG
        main.BorderSizePixel = 0
        main.Parent = gui
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke")
        stroke.Color = LT_ACCENT
        stroke.Thickness = 1.5
        stroke.Parent = main
        local function label(parent, text, x, y, w, h, size)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(x, y)
            l.Size = UDim2.fromOffset(w, h)
            l.Font = Enum.Font.GothamBold
            l.TextSize = size or 13
            l.TextColor3 = TEXT
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text = text
            l.Parent = parent
            return l
        end
        local function button(parent, text, x, y, w, h, color)
            local b = Instance.new("TextButton")
            b.Position = UDim2.fromOffset(x, y)
            b.Size = UDim2.fromOffset(w, h)
            b.BackgroundColor3 = color or PANEL
            b.BorderSizePixel = 0
            b.AutoButtonColor = true
            b.Font = Enum.Font.GothamBold
            b.TextSize = 13
            b.TextColor3 = TEXT
            b.Text = text
            b.Parent = parent
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            return b
        end
        local title = label(main, "Skin Tone", 12, 6, 200, 24, 15)
        title.Active = true
        local close = button(main, "X", 256, 6, 24, 24)
        close.MouseButton1Click:Connect(function()
            g.lt_skin_open = false
            g.lt_refresh_popups()
        end)
        do
            local dragging, start, start_pos
            title.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging, start, start_pos = true, input.Position, main.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - start
                    main.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
        end
        local hue, sat, val = 0.08, 0.4, 0.9
        local live = false
        local last_live = 0
        local R = 85
        local wheel = Instance.new("Frame")
        wheel.Size = UDim2.fromOffset(R * 2, R * 2)
        wheel.Position = UDim2.fromOffset(145 - R, 40)
        wheel.BackgroundTransparency = 1
        wheel.Parent = main
        local rings, segments = 12, 60
        for ring = 1, rings do
            local radius = (ring - 0.5) / rings * R
            local count = math.max(8, math.floor(segments * ring / rings))
            local size = math.max(math.ceil(2 * math.pi * radius / count) + 2, math.ceil(R / rings) + 2)
            for i = 0, count - 1 do
                local angle = (i + 0.5) / count * math.pi * 2
                local dot = Instance.new("Frame")
                dot.BorderSizePixel = 0
                dot.AnchorPoint = Vector2.new(0.5, 0.5)
                dot.Size = UDim2.fromOffset(size, size)
                dot.Position = UDim2.fromOffset(R + math.cos(angle) * radius, R - math.sin(angle) * radius)
                dot.BackgroundColor3 = Color3.fromHSV(angle / (math.pi * 2), (ring - 0.5) / rings, 1)
                dot.Parent = wheel
            end
        end
        local shade = Instance.new("Frame")
        shade.Size = UDim2.fromScale(1, 1)
        shade.BackgroundColor3 = Color3.new(0, 0, 0)
        shade.BorderSizePixel = 0
        shade.BackgroundTransparency = 1
        shade.ZIndex = 2
        shade.Parent = wheel
        Instance.new("UICorner", shade).CornerRadius = UDim.new(1, 0)
        local marker = Instance.new("Frame")
        marker.Size = UDim2.fromOffset(12, 12)
        marker.AnchorPoint = Vector2.new(0.5, 0.5)
        marker.BackgroundTransparency = 1
        marker.ZIndex = 3
        marker.Parent = wheel
        Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
        local marker_stroke = Instance.new("UIStroke")
        marker_stroke.Color = Color3.new(1, 1, 1)
        marker_stroke.Thickness = 2
        marker_stroke.Parent = marker
        local wheel_input = Instance.new("TextButton")
        wheel_input.Size = UDim2.fromScale(1, 1)
        wheel_input.BackgroundTransparency = 1
        wheel_input.Text = ""
        wheel_input.ZIndex = 4
        wheel_input.Parent = wheel
        label(main, "Brightness", 12, 222, 100, 16, 12)
        local bar = Instance.new("Frame")
        bar.Position = UDim2.fromOffset(12, 240)
        bar.Size = UDim2.fromOffset(266, 16)
        bar.BackgroundColor3 = Color3.new(1, 1, 1)
        bar.BorderSizePixel = 0
        bar.Parent = main
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)
        local bar_gradient = Instance.new("UIGradient")
        bar_gradient.Parent = bar
        local bar_marker = Instance.new("Frame")
        bar_marker.Size = UDim2.fromOffset(4, 22)
        bar_marker.AnchorPoint = Vector2.new(0.5, 0.5)
        bar_marker.BackgroundColor3 = Color3.new(1, 1, 1)
        bar_marker.BorderSizePixel = 0
        bar_marker.Parent = bar
        local bar_input = Instance.new("TextButton")
        bar_input.Size = UDim2.fromScale(1, 1)
        bar_input.BackgroundTransparency = 1
        bar_input.Text = ""
        bar_input.Parent = bar
        local preview = Instance.new("Frame")
        preview.Position = UDim2.fromOffset(12, 266)
        preview.Size = UDim2.fromOffset(42, 42)
        preview.BorderSizePixel = 0
        preview.Parent = main
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)
        local function box(x, y, w, placeholder)
            local t = Instance.new("TextBox")
            t.Position = UDim2.fromOffset(x, y)
            t.Size = UDim2.fromOffset(w, 20)
            t.BackgroundColor3 = PANEL
            t.BorderSizePixel = 0
            t.Font = Enum.Font.Code
            t.TextSize = 13
            t.TextColor3 = TEXT
            t.PlaceholderText = placeholder
            t.ClearTextOnFocus = false
            t.Text = ""
            t.Parent = main
            Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
            return t
        end
        label(main, "R", 62, 266, 10, 20, 12)
        local r_box = box(74, 266, 40, "R")
        label(main, "G", 120, 266, 10, 20, 12)
        local g_box = box(132, 266, 40, "G")
        label(main, "B", 178, 266, 10, 20, 12)
        local b_box = box(190, 266, 40, "B")
        label(main, "Hex", 62, 290, 30, 20, 12)
        local hex_box = box(94, 290, 136, "#RRGGBB")
        label(main, "Game skin colors", 12, 316, 200, 16, 12)
        local palette = Instance.new("ScrollingFrame")
        palette.Position = UDim2.fromOffset(12, 334)
        palette.Size = UDim2.fromOffset(266, 54)
        palette.BackgroundTransparency = 1
        palette.BorderSizePixel = 0
        palette.ScrollBarThickness = 4
        palette.ScrollBarImageColor3 = LT_ACCENT
        palette.AutomaticCanvasSize = Enum.AutomaticSize.Y
        palette.CanvasSize = UDim2.new()
        palette.Parent = main
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.fromOffset(20, 20)
        grid.CellPadding = UDim2.fromOffset(4, 4)
        grid.Parent = palette
        local apply = button(main, "Apply", 12, 396, 130, 26, LT_ACCENT)
        local live_btn = button(main, "Live: off", 148, 396, 130, 26)
        local function current() return Color3.fromHSV(hue, sat, val) end
        local function redraw()
            local color = current()
            local angle = hue * math.pi * 2
            marker.Position = UDim2.fromOffset(R + math.cos(angle) * sat * R, R - math.sin(angle) * sat * R)
            shade.BackgroundTransparency = val
            bar_gradient.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(hue, sat, 1))
            bar_marker.Position = UDim2.new(val, 0, 0.5, 0)
            preview.BackgroundColor3 = color
            local r, gg, b = math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5)
            if not r_box:IsFocused() then r_box.Text = tostring(r) end
            if not g_box:IsFocused() then g_box.Text = tostring(gg) end
            if not b_box:IsFocused() then b_box.Text = tostring(b) end
            if not hex_box:IsFocused() then hex_box.Text = ("#%02X%02X%02X"):format(r, gg, b) end
        end
        local function changed(final)
            redraw()
            if live and (final or os.clock() - last_live > 0.4) then
                last_live = os.clock()
                g.lt_set_skin(current(), true)
            end
        end
        local function set_color(color, apply_now)
            hue, sat, val = color:ToHSV()
            redraw()
            if apply_now then g.lt_set_skin(color) end
        end
        local function wheel_at(position)
            local center = wheel.AbsolutePosition + Vector2.new(R, R)
            local offset = Vector2.new(position.X, position.Y) - center
            local angle = math.atan2(-offset.Y, offset.X)
            if angle < 0 then angle += math.pi * 2 end
            hue = angle / (math.pi * 2)
            sat = math.clamp(offset.Magnitude / R, 0, 1)
            changed(false)
        end
        local function bar_at(position)
            val = math.clamp((position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            changed(false)
        end
        local dragging_what
        wheel_input.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_what = "wheel"
                wheel_at(input.Position)
            end
        end)
        bar_input.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging_what = "bar"
                bar_at(input.Position)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging_what then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragging_what == "wheel" then wheel_at(input.Position) else bar_at(input.Position) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if dragging_what and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging_what = nil
                changed(true)
            end
        end)
        local function from_rgb_boxes()
            local r, gg, b = tonumber(r_box.Text), tonumber(g_box.Text), tonumber(b_box.Text)
            if r and gg and b then
                set_color(Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(gg, 0, 255), math.clamp(b, 0, 255)))
                changed(true)
            else
                redraw()
            end
        end
        r_box.FocusLost:Connect(from_rgb_boxes)
        g_box.FocusLost:Connect(from_rgb_boxes)
        b_box.FocusLost:Connect(from_rgb_boxes)
        hex_box.FocusLost:Connect(function()
            local hex = hex_box.Text:gsub("#", ""):gsub("%s", "")
            local ok, color = pcall(Color3.fromHex, hex)
            if ok and color then
                set_color(color)
                changed(true)
            else
                redraw()
            end
        end)
        for _, color in ipairs(lt_skin_palette()) do
            local swatch = Instance.new("TextButton")
            swatch.Text = ""
            swatch.BackgroundColor3 = color
            swatch.BorderSizePixel = 0
            swatch.AutoButtonColor = true
            swatch.Parent = palette
            Instance.new("UICorner", swatch).CornerRadius = UDim.new(1, 0)
            swatch.MouseButton1Click:Connect(function() set_color(color, true) end)
        end
        apply.MouseButton1Click:Connect(function() g.lt_set_skin(current()) end)
        live_btn.MouseButton1Click:Connect(function()
            live = not live
            live_btn.Text = live and "Live: on" or "Live: off"
            live_btn.BackgroundColor3 = live and LT_ACCENT or PANEL
            if live then changed(true) end
        end)
        local my_char = LocalPlayer.Character
        local body_colors = my_char and my_char:FindFirstChildOfClass("BodyColors")
        if body_colors then set_color(body_colors.HeadColor3) else redraw() end
        g.lt_refresh_popups()
    end
    if g.lt_hide_key_conn then pcall(function() g.lt_hide_key_conn:Disconnect() end) end
    g.lt_hide_key_conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed or input.KeyCode ~= Enum.KeyCode.X then return end
        g.lt_ui_hidden = not g.lt_ui_hidden
        g.lt_refresh_popups()
    end)
    local function lt_find_player(name)
        local target = name and name ~= "" and typeof(g.findplr) == "function" and g.findplr(name)
        if not target then g.notify("Error", "No player matches: " .. tostring(name), 4) end
        return target
    end
    local LT_COMMANDS = {}
    local LT_COMMAND_HELP = {
        "copy <player>", "tp <player>", "view <player>", "unview", "skin <r g b | #hex | picker>",
        "height <90-105>", "width <70-100>", "age <adult/teen/kid/toddler/baby>", "bio <text>", "name <text>",
        "editor [on/off]", "move / rotate / scale", "all / none (pick accessories)", "reset [all] (accessories)", "outfits", "cmds",
    }
    LT_COMMANDS.copy = function(args)
        local target = lt_find_player(args)
        if target == LocalPlayer then g.notify("Error", "That's you!", 3); return end
        if target then task.spawn(g.copy_plr_avatar, target) end
    end
    LT_COMMANDS.tp = function(args)
        local target = lt_find_player(args)
        local target_char = target and target.Character
        local char = LocalPlayer.Character
        if not (target_char and char) then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Sit then
            pcall(function() hum:ChangeState(3) end)
            task.wait(0.2)
        end
        char:PivotTo(target_char:GetPivot() * CFrame.new(0, 5, 0))
    end
    LT_COMMANDS["goto"] = LT_COMMANDS.tp
    LT_COMMANDS.view = function(args)
        local target = lt_find_player(args)
        local hum = target and target.Character and target.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        g.Viewing_A_Player = true
        workspace.CurrentCamera.CameraSubject = hum
    end
    LT_COMMANDS.unview = function()
        g.Viewing_A_Player = false
        local char = LocalPlayer.Character
        workspace.CurrentCamera.CameraSubject = (char and char:FindFirstChildOfClass("Humanoid")) or char
    end
    LT_COMMANDS.skin = function(args)
        if args == "" or args:lower() == "picker" then g.lt_open_skin_picker(); return end
        local r, gg, b = args:match("^(%d+)[%s,]+(%d+)[%s,]+(%d+)$")
        if r then
            g.lt_set_skin(Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(gg), 0, 255), math.clamp(tonumber(b), 0, 255)))
            return
        end
        local ok, color = pcall(Color3.fromHex, (args:gsub("#", "")))
        if ok and color then g.lt_set_skin(color) else g.notify("Error", "Use: skin 255 220 180, or skin #FFDCB4", 4) end
    end
    LT_COMMANDS.height = function(args)
        local n = tonumber(args)
        if not n then g.notify("Error", "Use: height 90-105", 3); return end
        pcall(g.lt_send, "body_scale", "HeightScale", math.clamp(math.floor(n), 90, 105))
    end
    LT_COMMANDS.width = function(args)
        local n = tonumber(args)
        if not n then g.notify("Error", "Use: width 70-100", 3); return end
        pcall(g.lt_send, "body_scale", "WidthScale", math.clamp(math.floor(n), 70, 100))
    end
    LT_COMMANDS.age = function(args)
        local age = LT_AGE_NAMES[args:lower()]
        if not age then g.notify("Error", "Use: age adult / teen / kid / toddler / baby", 4); return end
        pcall(g.lt_get, "age", age)
    end
    LT_COMMANDS.bio = function(args) if typeof(g.change_bio) == "function" then g.change_bio(args) end end
    LT_COMMANDS.name = function(args) if typeof(g.change_RP_Name) == "function" then g.change_RP_Name(args) end end
    LT_COMMANDS.editor = function(args)
        local word = args:lower()
        local state = (word == "on" and true) or (word == "off" and false) or not g.lt_editor.enabled
        g.lt_editor_toggle(state)
    end
    LT_COMMANDS.move = function() if not g.lt_editor.enabled then g.lt_editor_toggle(true) end g.lt_editor_set_mode("Move") end
    LT_COMMANDS.rotate = function() if not g.lt_editor.enabled then g.lt_editor_toggle(true) end g.lt_editor_set_mode("Rotate") end
    LT_COMMANDS.scale = function() if not g.lt_editor.enabled then g.lt_editor_toggle(true) end g.lt_editor_set_mode("Scale") end
    LT_COMMANDS.all = function() if not g.lt_editor.enabled then g.lt_editor_toggle(true) end g.lt_editor_select_all(true) end
    LT_COMMANDS.none = function() g.lt_editor_select_all(false) end
    LT_COMMANDS.reset = function(args) g.lt_reset_adjustments(args:lower() == "all") end
    LT_COMMANDS.outfits = function() if typeof(g.save_outfits_GUI) == "function" then g.save_outfits_GUI() end end
    LT_COMMANDS.cmds = function() g.notify("Info", "Commands: " .. table.concat(LT_COMMAND_HELP, ", "), 15) end
    LT_COMMANDS.help = LT_COMMANDS.cmds
    g.lt_commands, g.lt_command_help = LT_COMMANDS, LT_COMMAND_HELP
    g.lt_run_command = function(text)
        text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        text = text:gsub("^[!/;:]", "")
        local cmd, args = text:match("^(%S+)%s*(.-)$")
        if not cmd then return end
        local handler = LT_COMMANDS[cmd:lower()]
        if not handler then g.notify("Error", "Unknown command: " .. cmd .. " (type cmds for the list)", 4); return end
        local ok, err = pcall(handler, args or "")
        if not ok then g.notify("Error", "Command failed: " .. tostring(err), 5) end
    end
end
print("[Flames] loading: outfit saver")
do
    local ACCENT = Color3.fromRGB(21, 103, 251)
    local BG, PANEL, CARD, TEXT, DIM = Color3.fromRGB(16, 16, 21), Color3.fromRGB(28, 28, 36), Color3.fromRGB(22, 22, 30), Color3.fromRGB(235, 235, 240), Color3.fromRGB(150, 150, 165)
    local FOLDER = "lifetogether_admin_savedoutfits"
    local BACKUP_FOLDER = "lifetogether_outfit_backups"
    local CODE_FILE = "lifetogether_outfits_backup_code.txt"
    local KEEP_BACKUPS = 10
    local CODE_PREFIX = "LTO1:"
    local ID_PROPS = {
        "Shirt", "Pants", "GraphicTShirt", "Face", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg",
        "ClimbAnimation", "FallAnimation", "IdleAnimation", "JumpAnimation", "RunAnimation", "SwimAnimation", "WalkAnimation",
    }
    local function gui_parent()
        local ok, hidden = pcall(function() return gethui and gethui() end)
        return (ok and hidden) or CoreGui
    end
    local function can_save()
        return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfile) == "function"
            and typeof(listfiles) == "function" and typeof(makefolder) == "function" and typeof(isfolder) == "function"
    end
    local function clean_name(name)
        return (tostring(name or ""):gsub('[\\/:%*%?"<>|]', ""):gsub("^%s+", ""):gsub("%s+$", ""))
    end
    local function file_name(path) return path:match("([^/\\]+)%.json$") end
    local function read_all()
        local all = {}
        if not can_save() or not isfolder(FOLDER) then return all end
        for _, path in ipairs(listfiles(FOLDER)) do
            local name = file_name(path)
            if name then
                local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
                if ok and type(data) == "table" then all[name] = data end
            end
        end
        return all
    end
    local function backup_now()
        if not can_save() then return end
        local all = read_all()
        if next(all) == nil then return end
        if not isfolder(BACKUP_FOLDER) then makefolder(BACKUP_FOLDER) end
        local uid = tostring(LocalPlayer.UserId)
        pcall(writefile, ("%s/outfits_%s_%d.json"):format(BACKUP_FOLDER, uid, os.time()),
            HttpService:JSONEncode({ user = LocalPlayer.UserId, saved = os.time(), outfits = all }))
        local mine = {}
        for _, path in ipairs(listfiles(BACKUP_FOLDER)) do
            local t = path:match("outfits_" .. uid .. "_(%d+)%.json$")
            if t then table.insert(mine, { path = path, t = tonumber(t) }) end
        end
        table.sort(mine, function(a, b) return a.t > b.t end)
        for i = KEEP_BACKUPS + 1, #mine do
            if typeof(delfile) == "function" then pcall(delfile, mine[i].path) end
        end
    end
    local function write_outfit(name, data)
        if not can_save() then return false end
        if not isfolder(FOLDER) then makefolder(FOLDER) end
        return pcall(writefile, FOLDER .. "/" .. name .. ".json", HttpService:JSONEncode(data))
    end
    local function free_name(name, taken)
        if not taken[name] then return name end
        local n = 2
        while taken[name .. " (" .. n .. ")"] do n += 1 end
        return name .. " (" .. n .. ")"
    end
    local function snapshot()
        local desc = g.lt_get_desc(LocalPlayer)
        if not desc then return nil end
        local outfit = { Accessories = {}, Saved = os.time() }
        for _, info in ipairs(desc:GetAccessories(true)) do
            local p, r, s = info.Position or Vector3.zero, info.Rotation or Vector3.zero, info.Scale or Vector3.one
            table.insert(outfit.Accessories, {
                AssetId = info.AssetId,
                AccessoryType = info.AccessoryType.Name,
                IsLayered = info.IsLayered,
                Order = info.IsLayered and info.Order or nil,
                Puffiness = info.IsLayered and info.Puffiness or nil,
                Position = { p.X, p.Y, p.Z },
                Rotation = { r.X, r.Y, r.Z },
                Scale = { s.X, s.Y, s.Z },
            })
        end
        for _, prop in ipairs(ID_PROPS) do outfit[prop] = desc[prop] end
        outfit.HeightScale, outfit.WidthScale = desc.HeightScale, desc.WidthScale
        local head = desc.HeadColor
        outfit.SkinTone = { head.R, head.G, head.B }
        local age = LocalPlayer:GetAttribute("age")
        if age then outfit.Age = tostring(age) end
        local ok, exact = pcall(g.lt_serialise, desc)
        if ok and type(exact) == "table" then outfit.Desc = exact end
        desc:Destroy()
        return outfit
    end
    local function payload_of(data)
        if type(data.Desc) == "table" then return HttpService:JSONDecode(HttpService:JSONEncode(data.Desc)) end
        local accessories, order = {}, 1
        for _, acc in ipairs(data.Accessories or {}) do
            local layered = acc.IsLayered == true
            table.insert(accessories, {
                AssetId = acc.AssetId,
                AccessoryType = acc.AccessoryType,
                IsLayered = layered,
                Position = type(acc.Position) == "table" and g.lt_encode_v3(Vector3.new(unpack(acc.Position))) or "  ",
                Rotation = type(acc.Rotation) == "table" and g.lt_encode_v3(Vector3.new(unpack(acc.Rotation))) or "  ",
                Scale = type(acc.Scale) == "table" and g.lt_encode_v3(Vector3.new(unpack(acc.Scale))) or "1 1 1",
                Order = layered and (tonumber(acc.Order) or order) or nil,
                Puffiness = layered and (tonumber(acc.Puffiness) or 0) or nil,
            })
            if layered then order += 1 end
        end
        local properties = { DepthScale = 1, HeadScale = 1, BodyTypeScale = 0, ProportionScale = 0 }
        for _, prop in ipairs(ID_PROPS) do properties[prop] = tonumber(data[prop]) or 0 end
        properties.HeightScale = tonumber(data.HeightScale) or 1
        properties.WidthScale = tonumber(data.WidthScale) or 1
        return { accessories = accessories, makeups = {}, properties = properties }
    end
    local function skin_of(data)
        local t = data.SkinTone
        return type(t) == "table" and Color3.new(tonumber(t[1]) or 1, tonumber(t[2]) or 1, tonumber(t[3]) or 1) or nil
    end
    g.lt_wear_saved_outfit = function(name)
        local data = read_all()[name]
        if not data then g.notify("Error", "No saved outfit called " .. tostring(name), 4); return false end
        g.notify("Info", "Wearing " .. name .. "...", 3)
        local ok, err = pcall(g.lt_apply_look, { payload = payload_of(data), age = data.Age, skin = skin_of(data) })
        if ok then g.notify("Success", "Wearing " .. name, 3) else g.notify("Error", "Couldn't wear it: " .. tostring(err), 5) end
        return ok
    end
    g.lt_save_current_outfit = function(name)
        name = clean_name(name)
        if name == "" then g.notify("Error", "Type a name for the outfit first.", 4); return false end
        if not can_save() then g.notify("Error", "Your executor can't save files.", 5); return false end
        local outfit = snapshot()
        if not outfit then g.notify("Error", "Your character isn't loaded.", 4); return false end
        local ok = write_outfit(name, outfit)
        if ok then
            backup_now()
            g.notify("Success", "Saved outfit: " .. name, 3)
        else
            g.notify("Error", "Couldn't save the outfit.", 4)
        end
        return ok
    end
    local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local function to_base64(text)
        local lib = typeof(crypt) == "table" and crypt or nil
        local fast = lib and (lib.base64encode or lib.base64_encode or (type(lib.base64) == "table" and lib.base64.encode))
        if typeof(fast) == "function" then
            local ok, out = pcall(fast, text)
            if ok and type(out) == "string" then return out end
        end
        local out = {}
        for i = 1, #text, 3 do
            local a, b, c = text:byte(i, i + 2)
            local n = a * 65536 + (b or 0) * 256 + (c or 0)
            local c1, c2, c3, c4 = n // 262144 % 64, n // 4096 % 64, n // 64 % 64, n % 64
            out[#out + 1] = B64:sub(c1 + 1, c1 + 1) .. B64:sub(c2 + 1, c2 + 1)
                .. (b and B64:sub(c3 + 1, c3 + 1) or "=") .. (c and B64:sub(c4 + 1, c4 + 1) or "=")
        end
        return table.concat(out)
    end
    local function from_base64(text)
        local lib = typeof(crypt) == "table" and crypt or nil
        local fast = lib and (lib.base64decode or lib.base64_decode or (type(lib.base64) == "table" and lib.base64.decode))
        if typeof(fast) == "function" then
            local ok, out = pcall(fast, text)
            if ok and type(out) == "string" then return out end
        end
        text = text:gsub("[^%w%+/]", "")
        local out = {}
        for i = 1, #text, 4 do
            local n, count = 0, 0
            for j = i, math.min(i + 3, #text) do
                n = n * 64 + (B64:find(text:sub(j, j), 1, true) - 1)
                count += 1
            end
            for _ = count + 1, 4 do n *= 64 end
            local bytes = { n // 65536 % 256, n // 256 % 256, n % 256 }
            for k = 1, count - 1 do out[#out + 1] = string.char(bytes[k]) end
        end
        return table.concat(out)
    end
    local function pack_outfit(name, data)
        local payload = payload_of(data)
        local accessories = {}
        for _, a in ipairs(payload.accessories or {}) do
            local entry = { i = a.AssetId, t = a.AccessoryType }
            if a.IsLayered then
                entry.l = 1
                entry.o = a.Order
                if (tonumber(a.Puffiness) or 0) ~= 0 then entry.f = a.Puffiness end
            end
            if a.Position and a.Position ~= "  " then entry.p = a.Position end
            if a.Rotation and a.Rotation ~= "  " then entry.r = a.Rotation end
            if a.Scale and a.Scale ~= "1 1 1" then entry.s = a.Scale end
            table.insert(accessories, entry)
        end
        local properties = {}
        for k, v in pairs(payload.properties or {}) do
            if not (v == 0 and not tostring(k):find("Scale")) then properties[k] = v end
        end
        return { n = name, a = accessories, m = payload.makeups, p = properties, g = data.Age, k = data.SkinTone }
    end
    local function unpack_outfit(packed)
        local accessories = {}
        for _, e in ipairs(packed.a or {}) do
            table.insert(accessories, {
                AssetId = e.i, AccessoryType = e.t, IsLayered = e.l == 1,
                Order = e.l == 1 and (e.o or 1) or nil,
                Puffiness = e.l == 1 and (e.f or 0) or nil,
                Position = e.p or "  ", Rotation = e.r or "  ", Scale = e.s or "1 1 1",
            })
        end
        local properties = packed.p or {}
        for _, prop in ipairs(ID_PROPS) do properties[prop] = properties[prop] or 0 end
        local outfit = { Accessories = {}, Desc = { accessories = accessories, makeups = packed.m or {}, properties = properties }, Saved = os.time() }
        for _, a in ipairs(accessories) do
            table.insert(outfit.Accessories, { AssetId = a.AssetId, AccessoryType = a.AccessoryType, IsLayered = a.IsLayered, Order = a.Order })
        end
        for _, prop in ipairs(ID_PROPS) do outfit[prop] = properties[prop] end
        outfit.HeightScale, outfit.WidthScale = properties.HeightScale, properties.WidthScale
        outfit.Age, outfit.SkinTone = packed.g, packed.k
        return outfit
    end
    g.lt_outfit_code = function(names)
        local all, list = read_all(), {}
        for name, data in pairs(all) do
            if not names or table.find(names, name) then table.insert(list, pack_outfit(name, data)) end
        end
        if #list == 0 then return nil end
        return CODE_PREFIX .. to_base64(HttpService:JSONEncode({ v = 1, u = LocalPlayer.UserId, o = list }))
    end
    g.lt_import_outfit_code = function(code)
        code = tostring(code or ""):gsub("%s", "")
        local start = code:find(CODE_PREFIX, 1, true)
        if not start then return 0, "that isn't an outfit code" end
        local ok, data = pcall(function() return HttpService:JSONDecode(from_base64(code:sub(start + #CODE_PREFIX))) end)
        if not ok or type(data) ~= "table" or type(data.o) ~= "table" then return 0, "the code is damaged or cut off" end
        local taken, added = read_all(), 0
        for _, packed in ipairs(data.o) do
            local name = free_name(clean_name(packed.n ~= "" and packed.n or "Imported"), taken)
            if write_outfit(name, unpack_outfit(packed)) then
                taken[name] = true
                added += 1
            end
        end
        if added > 0 then backup_now() end
        return added
    end
    g.lt_restore_outfit_backup = function()
        if not can_save() or not isfolder(BACKUP_FOLDER) then return 0, "no backups yet" end
        local uid, newest, newest_t = tostring(LocalPlayer.UserId), nil, -1
        for _, path in ipairs(listfiles(BACKUP_FOLDER)) do
            local t = tonumber(path:match("outfits_" .. uid .. "_(%d+)%.json$"))
            if t and t > newest_t then newest, newest_t = path, t end
        end
        if not newest then return 0, "no backups for this account yet" end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(newest)) end)
        if not ok or type(data) ~= "table" or type(data.outfits) ~= "table" then return 0, "the backup file is damaged" end
        local current, restored = read_all(), 0
        for name, outfit in pairs(data.outfits) do
            if not current[name] and write_outfit(name, outfit) then restored += 1 end
        end
        return restored
    end
    local function desc_of(payload)
        local HumDesc = g.lt_require("HumDesc")
        if HumDesc and HumDesc.deserialise_humanoid_description then
            local ok, desc = pcall(HumDesc.deserialise_humanoid_description, payload)
            if ok and typeof(desc) == "Instance" then return desc end
        end
        local desc = Instance.new("HumanoidDescription")
        for k, v in pairs(payload.properties or {}) do
            if type(v) == "number" then pcall(function() desc[k] = v end) end
        end
        local list = {}
        for _, a in ipairs(payload.accessories or {}) do
            local ok, kind = pcall(function() return Enum.AccessoryType[a.AccessoryType] end)
            if ok and kind then
                table.insert(list, {
                    AssetId = a.AssetId, AccessoryType = kind, IsLayered = a.IsLayered == true,
                    Order = a.IsLayered and (a.Order or 1) or nil, Puffiness = a.IsLayered and (a.Puffiness or 0) or nil,
                })
            end
        end
        pcall(function() desc:SetAccessories(list, true) end)
        return desc
    end
    local function render_preview(viewport, data)
        local world = Instance.new("WorldModel")
        world.Parent = viewport
        local desc = desc_of(payload_of(data))
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local game_folder = modules and modules:FindFirstChild("Game")
        local giver = game_folder and game_folder:FindFirstChild("CatalogGiver")
        local template = giver and giver:FindFirstChild("RigR15")
        local rig
        if template then
            rig = template:Clone()
            rig:PivotTo(CFrame.new())
            rig.Parent = world
            local hum = rig:FindFirstChildWhichIsA("Humanoid")
            if not (hum and pcall(hum.ApplyDescription, hum, desc, Enum.AssetTypeVerification.Always)) then
                rig:Destroy()
                rig = nil
            end
        end
        if not rig then
            local ok, model = pcall(function()
                return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15, Enum.AssetTypeVerification.Always)
            end)
            if ok and model then
                rig = model
                rig:PivotTo(CFrame.new())
                rig.Parent = world
            end
        end
        desc:Destroy()
        if not rig then return false end
        for _, d in ipairs(rig:GetDescendants()) do
            if d:IsA("BaseScript") then d:Destroy() end
        end
        local cf, size = rig:GetBoundingBox()
        local camera = Instance.new("Camera")
        camera.FieldOfView = 40
        local distance = math.max(size.Y, size.X) * 1.45
        camera.CFrame = CFrame.lookAt(cf.Position + cf.LookVector * distance + Vector3.new(0, size.Y * 0.05, 0), cf.Position)
        camera.Parent = viewport
        viewport.CurrentCamera = camera
        return true
    end
    g.lt_open_outfit_saver = function()
        g.lt_outfits_open = true
        if g.lt_outfits_gui and g.lt_outfits_gui.Parent then
            if g.lt_outfits_refresh then g.lt_outfits_refresh() end
            g.lt_refresh_popups()
            return
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "FlamesOutfitSaver"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = gui_parent()
        g.lt_outfits_gui = gui
        local main = Instance.new("Frame")
        main.Size = UDim2.fromOffset(440, 500)
        main.Position = UDim2.new(0.5, -220, 0.5, -250)
        main.BackgroundColor3 = BG
        main.BorderSizePixel = 0
        main.Parent = gui
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke")
        stroke.Color = ACCENT
        stroke.Thickness = 1.5
        stroke.Parent = main
        local function label(parent, text, x, y, w, h, size, color, bold)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(x, y)
            l.Size = UDim2.fromOffset(w, h)
            l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextSize = size or 13
            l.TextColor3 = color or TEXT
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped = true
            l.Text = text
            l.Parent = parent
            return l
        end
        local function button(parent, text, x, y, w, h, color)
            local b = Instance.new("TextButton")
            b.Position = UDim2.fromOffset(x, y)
            b.Size = UDim2.fromOffset(w, h)
            b.BackgroundColor3 = color or PANEL
            b.BorderSizePixel = 0
            b.AutoButtonColor = true
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.TextColor3 = TEXT
            b.Text = text
            b.Parent = parent
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            return b
        end
        local function textbox(parent, placeholder, x, y, w, h)
            local t = Instance.new("TextBox")
            t.Position = UDim2.fromOffset(x, y)
            t.Size = UDim2.fromOffset(w, h)
            t.BackgroundColor3 = PANEL
            t.BorderSizePixel = 0
            t.Font = Enum.Font.Gotham
            t.TextSize = 13
            t.TextColor3 = TEXT
            t.PlaceholderText = placeholder
            t.PlaceholderColor3 = DIM
            t.ClearTextOnFocus = false
            t.Text = ""
            t.Parent = parent
            Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
            return t
        end
        local title = label(main, "Outfit Saver", 12, 6, 300, 24, 15, TEXT, true)
        title.Active = true
        local close = button(main, "X", 406, 6, 24, 24)
        close.MouseButton1Click:Connect(function()
            g.lt_outfits_open = false
            g.lt_refresh_popups()
        end)
        do
            local dragging, start, start_pos
            title.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging, start, start_pos = true, input.Position, main.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - start
                    main.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
        end
        local name_box = textbox(main, "Outfit name...", 10, 38, 280, 28)
        local save_btn = button(main, "Save Current", 296, 38, 134, 28, ACCENT)
        local export_btn = button(main, "Backup Code (all)", 10, 72, 140, 26)
        local import_btn = button(main, "Import Code", 156, 72, 130, 26)
        local restore_btn = button(main, "Restore Backup", 292, 72, 138, 26)
        local import_box = textbox(main, "Paste a backup or outfit code here...", 10, 104, 330, 44)
        import_box.TextWrapped = true
        import_box.MultiLine = true
        import_box.TextXAlignment = Enum.TextXAlignment.Left
        import_box.TextYAlignment = Enum.TextYAlignment.Top
        import_box.Visible = false
        local import_go = button(main, "Add", 346, 104, 84, 44, ACCENT)
        import_go.Visible = false
        local grid_frame = Instance.new("ScrollingFrame")
        grid_frame.Position = UDim2.fromOffset(10, 106)
        grid_frame.Size = UDim2.fromOffset(420, 364)
        grid_frame.BackgroundTransparency = 1
        grid_frame.BorderSizePixel = 0
        grid_frame.ScrollBarThickness = 4
        grid_frame.ScrollBarImageColor3 = ACCENT
        grid_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        grid_frame.CanvasSize = UDim2.new()
        grid_frame.Parent = main
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.fromOffset(130, 182)
        grid.CellPadding = UDim2.fromOffset(8, 8)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = grid_frame
        local status = label(main, "", 12, 474, 416, 20, 12, DIM)
        local function show_import(on)
            import_box.Visible, import_go.Visible = on, on
            grid_frame.Position = UDim2.fromOffset(10, on and 154 or 106)
            grid_frame.Size = UDim2.fromOffset(420, on and 316 or 364)
        end
        local preview_queue = {}
        local preview_running = false
        local function run_previews()
            if preview_running then return end
            preview_running = true
            task.spawn(function()
                while #preview_queue > 0 do
                    local job = table.remove(preview_queue, 1)
                    if job.viewport.Parent then pcall(render_preview, job.viewport, job.data) end
                    task.wait(0.05)
                end
                preview_running = false
            end)
        end
        local cards = {}
        g.lt_outfits_refresh = function()
            for _, c in ipairs(cards) do c:Destroy() end
            table.clear(cards)
            table.clear(preview_queue)
            if not can_save() then
                status.Text = "Your executor can't save files, so outfits can't be stored."
                return
            end
            local all, names = read_all(), {}
            for name in pairs(all) do table.insert(names, name) end
            table.sort(names, function(a, b)
                local ta, tb = tonumber(all[a].Saved) or 0, tonumber(all[b].Saved) or 0
                if ta ~= tb then return ta > tb end
                return a:lower() < b:lower()
            end)
            status.Text = #names == 0 and "No outfits yet. Type a name and press Save Current." or (#names .. " outfit" .. (#names == 1 and "" or "s") .. " saved on this PC.")
            for index, name in ipairs(names) do
                local data = all[name]
                local card = Instance.new("Frame")
                card.LayoutOrder = index
                card.BackgroundColor3 = CARD
                card.BorderSizePixel = 0
                card.Parent = grid_frame
                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
                table.insert(cards, card)
                local viewport = Instance.new("ViewportFrame")
                viewport.Position = UDim2.fromOffset(4, 4)
                viewport.Size = UDim2.fromOffset(122, 122)
                viewport.BackgroundColor3 = PANEL
                viewport.BorderSizePixel = 0
                viewport.Ambient = Color3.fromRGB(200, 200, 210)
                viewport.LightColor = Color3.fromRGB(255, 255, 255)
                viewport.Parent = card
                Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 6)
                table.insert(preview_queue, { viewport = viewport, data = data })
                local title_label = label(card, name, 6, 128, 118, 18, 12, TEXT, true)
                title_label.TextTruncate = Enum.TextTruncate.AtEnd
                title_label.TextWrapped = false
                local wear = button(card, "Wear", 4, 150, 56, 26, ACCENT)
                local share = button(card, "Code", 64, 150, 34, 26)
                share.TextSize = 10
                local delete = button(card, "Del", 100, 150, 26, 26, Color3.fromRGB(110, 30, 34))
                delete.TextSize = 10
                wear.MouseButton1Click:Connect(function() task.spawn(g.lt_wear_saved_outfit, name) end)
                share.MouseButton1Click:Connect(function()
                    local code = g.lt_outfit_code({ name })
                    local clip = setclipboard or toclipboard
                    if code and clip and pcall(clip, code) then
                        g.notify("Success", "Outfit code for " .. name .. " copied. Anyone with this script can add it with Import Code.", 5)
                    else
                        g.notify("Error", "Couldn't copy the code.", 4)
                    end
                end)
                local armed = false
                delete.MouseButton1Click:Connect(function()
                    if not armed then
                        armed = true
                        delete.Text = "Sure?"
                        task.delay(3, function()
                            armed = false
                            if delete.Parent then delete.Text = "Del" end
                        end)
                        return
                    end
                    backup_now()
                    if typeof(delfile) == "function" then pcall(delfile, FOLDER .. "/" .. name .. ".json") end
                    g.notify("Success", "Deleted " .. name .. " (Restore Backup brings it back).", 4)
                    g.lt_outfits_refresh()
                end)
            end
            run_previews()
        end
        save_btn.MouseButton1Click:Connect(function()
            if g.lt_save_current_outfit(name_box.Text) then
                name_box.Text = ""
                g.lt_outfits_refresh()
            end
        end)
        export_btn.MouseButton1Click:Connect(function()
            local code = g.lt_outfit_code(nil)
            if not code then g.notify("Info", "No outfits to back up yet.", 4); return end
            if typeof(writefile) == "function" then pcall(writefile, CODE_FILE, code) end
            local clip = setclipboard or toclipboard
            local copied = clip and pcall(clip, code)
            g.notify("Success", (copied and "Backup code copied" or "Backup code made") .. " and saved to " .. CODE_FILE
                .. ". Keep it somewhere safe (a Discord DM to yourself, notes, Google Drive); Import Code brings every outfit back on any PC.", 10)
        end)
        import_btn.MouseButton1Click:Connect(function() show_import(not import_box.Visible) end)
        import_go.MouseButton1Click:Connect(function()
            local added, err = g.lt_import_outfit_code(import_box.Text)
            if added > 0 then
                g.notify("Success", ("Added %d outfit%s."):format(added, added == 1 and "" or "s"), 4)
                import_box.Text = ""
                show_import(false)
                g.lt_outfits_refresh()
            else
                g.notify("Error", "Couldn't import: " .. tostring(err or "no outfits in that code"), 5)
            end
        end)
        restore_btn.MouseButton1Click:Connect(function()
            local restored, err = g.lt_restore_outfit_backup()
            if restored > 0 then
                g.notify("Success", ("Restored %d outfit%s from your newest backup."):format(restored, restored == 1 and "" or "s"), 5)
                g.lt_outfits_refresh()
            else
                g.notify("Info", err or "Nothing to restore, every outfit in your newest backup is already here.", 5)
            end
        end)
        g.lt_outfits_refresh()
        g.lt_refresh_popups()
    end
    local ACCESSORY_TYPE_OF_ASSET = {
        Hat = "Hat", HairAccessory = "Hair", FaceAccessory = "Face", NeckAccessory = "Neck", ShoulderAccessory = "Shoulder",
        FrontAccessory = "Front", BackAccessory = "Back", WaistAccessory = "Waist", EyebrowAccessory = "Eyebrow",
        EyelashAccessory = "Eyelash", TShirtAccessory = "TShirt", ShirtAccessory = "Shirt", PantsAccessory = "Pants",
        JacketAccessory = "Jacket", SweaterAccessory = "Sweater", ShortsAccessory = "Shorts", LeftShoeAccessory = "LeftShoe",
        RightShoeAccessory = "RightShoe", DressSkirtAccessory = "DressSkirt",
    }
    local LAYERED_TYPES = { TShirt = true, Shirt = true, Pants = true, Jacket = true, Sweater = true, Shorts = true, LeftShoe = true, RightShoe = true, DressSkirt = true }
    g.lt_accessory_type_of_asset, g.lt_layered_types = ACCESSORY_TYPE_OF_ASSET, LAYERED_TYPES
    g.lt_add_accessory = function(id, accessory_type)
        id = tonumber(id)
        if not id then error("that isn't an item id", 0) end
        if not accessory_type then
            local ok, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(id) end)
            local okType, asset_type = pcall(function() return Enum.AssetType:FromValue(info.AssetTypeId) end)
            accessory_type = ok and okType and asset_type and ACCESSORY_TYPE_OF_ASSET[asset_type.Name]
            if not accessory_type then error("that item isn't an accessory", 0) end
        end
        local desc = g.lt_get_desc(LocalPlayer)
        if not desc then error("your character isn't loaded", 0) end
        local payload = g.lt_serialise(desc)
        desc:Destroy()
        local top = 0
        for _, a in ipairs(payload.accessories) do
            if tonumber(a.AssetId) == id then return "already" end
            if a.IsLayered then top = math.max(top, tonumber(a.Order) or 0) end
        end
        if g.lt_item_limit and #payload.accessories >= g.lt_item_limit then
            error(("the game only allows %d items, take one off first"):format(g.lt_item_limit), 0)
        end
        local layered = LAYERED_TYPES[accessory_type] == true
        table.insert(payload.accessories, {
            AssetId = id, AccessoryType = accessory_type, IsLayered = layered,
            Order = layered and top + 1 or nil, Puffiness = layered and 0 or nil,
            Position = "  ", Rotation = "  ", Scale = "1 1 1",
        })
        g.lt_order_layers(payload)
        pcall(g.lt_send, "wear_outfit_from_desc", payload)
        return true
    end
    g.lt_no_item_limit = g.lt_no_item_limit ~= false
    do
        local function wearing(id)
            local desc = g.lt_get_desc(LocalPlayer)
            if not desc then return false end
            local found = false
            for _, a in ipairs(desc:GetAccessories(true)) do
                if a.AssetId == id then
                    found = true
                    break
                end
            end
            desc:Destroy()
            return found
        end
        local Net = g.lt_require("Net")
        if Net and g.lt_net_get_original then Net.get = g.lt_net_get_original end
        g.lt_net_get_original = nil
        if Net and type(Net.get) == "function" then
            g.lt_net_get_original = Net.get
            Net.get = function(key, ...)
                local original = g.lt_net_get_original
                if key ~= "wear" or not g.lt_no_item_limit or g.lt_bulk_wearing then return original(key, ...) end
                local id, kind = ...
                id = tonumber(id)
                local accessory_type = type(kind) == "string" and kind:match("^(.-)Accessory$")
                local was_worn = id and accessory_type and wearing(id)
                local results = table.pack(original(key, ...))
                if id and accessory_type and accessory_type ~= "" and not was_worn then
                    task.spawn(function()
                        task.wait(0.5)
                        if wearing(id) then return end
                        local ok, err = pcall(g.lt_add_accessory, id, accessory_type)
                        if not ok then g.notify("Info", tostring(err), 4) end
                    end)
                end
                return table.unpack(results, 1, results.n)
            end
        end
    end
    local pending_size, last_size_change, size_waiting = {}, 0, false
    local SIZE_FILE = "lifetogether_body_size.json"
    if g.lt_size_wanted == nil then
        g.lt_size_wanted = false
        pcall(function()
            if typeof(isfile) == "function" and isfile(SIZE_FILE) then
                local saved = HttpService:JSONDecode(readfile(SIZE_FILE))
                local mine = type(saved) == "table" and saved[tostring(LocalPlayer.UserId)]
                if type(mine) == "table" and next(mine) then g.lt_size_wanted = mine end
            end
        end)
    end
    local function save_wanted()
        pcall(function()
            if typeof(writefile) ~= "function" then return end
            local saved = {}
            if isfile(SIZE_FILE) then saved = HttpService:JSONDecode(readfile(SIZE_FILE)) end
            saved[tostring(LocalPlayer.UserId)] = g.lt_size_wanted or nil
            writefile(SIZE_FILE, HttpService:JSONEncode(saved))
        end)
    end
    g.lt_set_body_size = function(changes, forget)
        for k, v in pairs(changes) do
            if tonumber(v) then pending_size[k] = math.max(0.05, tonumber(v)) end
        end
        if forget then
            g.lt_size_wanted = false
        else
            g.lt_size_wanted = g.lt_size_wanted or {}
            for k, v in pairs(changes) do
                if tonumber(v) then g.lt_size_wanted[k] = math.max(0.05, tonumber(v)) end
            end
        end
        save_wanted()
        last_size_change = os.clock()
        if size_waiting then return end
        size_waiting = true
        task.spawn(function()
            while os.clock() - last_size_change < 0.35 do task.wait(0.05) end
            size_waiting = false
            local apply = pending_size
            pending_size = {}
            local desc = g.lt_get_desc(LocalPlayer)
            if not desc then return end
            if not g.lt_size_original then
                g.lt_size_original = { HeightScale = desc.HeightScale, WidthScale = desc.WidthScale, DepthScale = desc.DepthScale }
            end
            local payload = g.lt_serialise(desc)
            desc:Destroy()
            payload.properties = payload.properties or {}
            for k, v in pairs(apply) do payload.properties[k] = v end
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local safe = root and root.CFrame
            g.lt_order_layers(payload)
            pcall(g.lt_send, "wear_outfit_from_desc", payload)
            if safe then
                task.delay(1.5, function()
                    local now = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if now and now.Position.Y < safe.Position.Y - 15 then
                        now.AssemblyLinearVelocity = Vector3.zero
                        now.CFrame = safe + Vector3.new(0, 5, 0)
                    end
                end)
            end
        end)
    end
    g.lt_size_step = g.lt_size_step or 0.02
    g.lt_nudge_body_size = function(prop, direction)
        local current = pending_size[prop]
        if not current then
            local desc = g.lt_get_desc(LocalPlayer)
            if not desc then return end
            current = desc[prop]
            desc:Destroy()
        end
        local new_value = math.max(0.05, current + (tonumber(g.lt_size_step) or 0.02) * direction)
        g.lt_set_body_size({ [prop] = new_value })
        g.notify("Info", ("%s: %d%%"):format(prop == "HeightScale" and "Height" or "Width", math.floor(new_value * 100 + 0.5)), 1)
    end
    g.height_func_setter = function(height) g.lt_set_body_size({ HeightScale = height }) end
    g.width_func_setter = function(width) g.lt_set_body_size({ WidthScale = width }) end
    g.size_func_setter = function(width, depth) g.lt_set_body_size({ WidthScale = width, DepthScale = depth }) end
    g.lt_remember_body_size = function(properties)
        local keep = {}
        for _, k in ipairs({ "HeightScale", "WidthScale", "DepthScale" }) do
            if tonumber(properties and properties[k]) then keep[k] = tonumber(properties[k]) end
        end
        g.lt_size_wanted = next(keep) and keep or false
        save_wanted()
    end
    g.lt_reset_body_size = function()
        g.lt_set_body_size(g.lt_size_original or { HeightScale = 1, WidthScale = 1, DepthScale = 1 }, true)
    end
    g.reset_to_original_height = g.lt_reset_body_size
    local function size_is_wanted()
        if not g.lt_size_wanted then return true end
        local desc = g.lt_get_desc(LocalPlayer)
        if not desc then return true end
        local same = true
        for k, v in pairs(g.lt_size_wanted) do
            if math.abs((tonumber(desc[k]) or 0) - v) > 0.005 then same = false end
        end
        desc:Destroy()
        return same
    end
    local function restore_size(first_wait)
        task.wait(first_wait)
        for _ = 1, 5 do
            if not g.lt_size_wanted or size_is_wanted() then return end
            g.lt_set_body_size(g.lt_size_wanted)
            task.wait(3)
        end
    end
    if g.lt_size_respawn_conn then pcall(function() g.lt_size_respawn_conn:Disconnect() end) end
    g.lt_size_respawn_conn = LocalPlayer.CharacterAdded:Connect(function(char)
        if not g.lt_size_wanted then return end
        char:WaitForChild("Humanoid", 15)
        restore_size(3)
    end)
    if g.lt_size_wanted then task.spawn(restore_size, 2) end
    if g.lt_commands then
        g.lt_commands.outfits = function() g.lt_open_outfit_saver() end
        g.lt_commands.save = function(args) g.lt_save_current_outfit(args) end
        g.lt_commands.wear = function(args) task.spawn(g.lt_wear_saved_outfit, clean_name(args)) end
        g.lt_commands.add = function(args)
            local ok, result = pcall(g.lt_add_accessory, args:match("%d+"))
            if not ok then g.notify("Error", "Couldn't add it: " .. tostring(result), 4)
            elseif result == "already" then g.notify("Info", "You're already wearing that.", 3)
            else g.notify("Success", "Added the accessory.", 2) end
        end
        g.lt_commands.backup = function()
            local code = g.lt_outfit_code(nil)
            if not code then g.notify("Info", "No outfits to back up yet.", 4); return end
            if typeof(writefile) == "function" then pcall(writefile, CODE_FILE, code) end
            local clip = setclipboard or toclipboard
            if clip then pcall(clip, code) end
            g.notify("Success", "Backup code copied and saved to " .. CODE_FILE .. ".", 6)
        end
    end
    if g.lt_command_help then
        for _, help in ipairs({ "save <name>", "wear <name>", "backup (copy a backup code)", "add <item id>" }) do table.insert(g.lt_command_help, help) end
    end
end
print("[Flames] loading: catalog")
do
    local AvatarEditorService = game:GetService("AvatarEditorService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local ACCENT = Color3.fromRGB(21, 103, 251)
    local BG, PANEL, CARD, TEXT, DIM = Color3.fromRGB(16, 16, 21), Color3.fromRGB(28, 28, 36), Color3.fromRGB(22, 22, 30), Color3.fromRGB(235, 235, 240), Color3.fromRGB(150, 150, 165)
    local PROPERTY_OF_ASSET = {
        Shirt = "Shirt", Pants = "Pants", TShirt = "GraphicTShirt", Face = "Face", Head = "Head", DynamicHead = "Head",
        Torso = "Torso", LeftArm = "LeftArm", RightArm = "RightArm", LeftLeg = "LeftLeg", RightLeg = "RightLeg",
        IdleAnimation = "IdleAnimation", WalkAnimation = "WalkAnimation", RunAnimation = "RunAnimation", JumpAnimation = "JumpAnimation",
        FallAnimation = "FallAnimation", ClimbAnimation = "ClimbAnimation", SwimAnimation = "SwimAnimation", MoodAnimation = "MoodAnimation",
    }
    local CATEGORIES = {
        { name = "All" },
        { name = "Accessories", assets = { "Hat", "HairAccessory", "FaceAccessory", "NeckAccessory", "ShoulderAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory" } },
        { name = "Clothing", assets = { "ShirtAccessory", "TShirtAccessory", "JacketAccessory", "SweaterAccessory", "PantsAccessory", "ShortsAccessory", "DressSkirtAccessory", "LeftShoeAccessory", "RightShoeAccessory", "Shirt", "Pants", "TShirt" } },
        { name = "Faces", assets = { "Face", "EyebrowAccessory", "EyelashAccessory" } },
        { name = "Heads", bundles = { "DynamicHead", "DynamicHeadAvatar" } },
        { name = "Bodies", bundles = { "BodyParts", "Shoes" } },
        { name = "Animations", bundles = { "Animations" } },
    }
    local function gui_parent()
        local ok, hidden = pcall(function() return gethui and gethui() end)
        return (ok and hidden) or CoreGui
    end
    local banned_module
    local function game_bans()
        if banned_module == nil then
            banned_module = false
            pcall(function()
                local avatar = ReplicatedStorage.Modules.Game.Phone.AppModules.Avatar
                banned_module = g.safe_require(avatar:FindFirstChild("BannedAccessories")) or false
            end)
        end
        return banned_module or nil
    end
    local function is_limited(restrictions)
        for _, r in ipairs(type(restrictions) == "table" and restrictions or {}) do
            if r == "Limited" or r == "LimitedUnique" or r == "Collectible" then return true end
        end
        return false
    end
    g.lt_wear_parts = function(parts)
        local desc = g.lt_get_desc(LocalPlayer)
        if not desc then error("your character isn't loaded", 0) end
        local payload = g.lt_serialise(desc)
        desc:Destroy()
        payload.properties = payload.properties or {}
        local top = 0
        for _, a in ipairs(payload.accessories) do
            if a.IsLayered then top = math.max(top, tonumber(a.Order) or 0) end
        end
        local changed = 0
        for _, part in ipairs(parts) do
            local id, asset_type = tonumber(part.id), tostring(part.asset_type)
            local accessory_type = (g.lt_accessory_type_of_asset or {})[asset_type]
            if id and accessory_type then
                local exists = false
                for _, a in ipairs(payload.accessories) do
                    if tonumber(a.AssetId) == id then exists = true end
                end
                if not exists then
                    local layered = (g.lt_layered_types or {})[accessory_type] == true
                    if layered then top += 1 end
                    table.insert(payload.accessories, {
                        AssetId = id, AccessoryType = accessory_type, IsLayered = layered,
                        Order = layered and top or nil, Puffiness = layered and 0 or nil,
                        Position = "  ", Rotation = "  ", Scale = "1 1 1",
                    })
                    changed += 1
                end
            elseif id and PROPERTY_OF_ASSET[asset_type] then
                payload.properties[PROPERTY_OF_ASSET[asset_type]] = id
                changed += 1
            end
        end
        if changed == 0 then error("nothing in that item can be worn", 0) end
        if g.lt_item_limit and #payload.accessories > g.lt_item_limit then
            error(("the game only allows %d items, take some off first"):format(g.lt_item_limit), 0)
        end
        g.lt_order_layers(payload)
        pcall(g.lt_send, "wear_outfit_from_desc", payload)
        return changed
    end
    local function parts_of(item)
        if item.ItemType == "Bundle" then
            local ok, details = pcall(function() return AvatarEditorService:GetItemDetails(item.Id, Enum.AvatarItemType.Bundle) end)
            local parts = {}
            for _, b in ipairs(ok and type(details) == "table" and (details.BundledItems or details.Items) or {}) do
                if b.Type == "Asset" and b.AssetType then table.insert(parts, { id = b.Id, asset_type = b.AssetType }) end
            end
            return parts
        end
        return { { id = item.Id, asset_type = item.AssetType } }
    end
    g.lt_wear_catalog_item = function(item)
        local ok, result = pcall(function() return g.lt_wear_parts(parts_of(item)) end)
        if ok then
            g.notify("Success", "Wearing " .. tostring(item.Name or item.Id), 2)
        else
            g.notify("Error", "Couldn't wear it: " .. tostring(result), 5)
        end
        return ok
    end
    g.lt_wear_by_id = function(text)
        text = tostring(text or "")
        local id = tonumber(text:match("/(%d+)") or text:match("%d+"))
        if not id then g.notify("Error", "Paste an item id or a catalog link.", 4); return false end
        if text:lower():find("bundle") then
            return g.lt_wear_catalog_item({ Id = id, ItemType = "Bundle", Name = "bundle " .. id })
        end
        local ok, info = pcall(function() return MarketplaceService:GetProductInfo(id) end)
        if not ok or type(info) ~= "table" then
            g.notify("Error", "Roblox couldn't find that item (it may have been deleted or moderated, so nobody can load it).", 6)
            return false
        end
        local okType, asset_type = pcall(function() return Enum.AssetType:FromValue(info.AssetTypeId).Name end)
        asset_type = okType and asset_type or "?"
        if info.IsLimited or info.IsLimitedUnique then
            g.notify("Error", "Limited / collectible items can't be worn with this.", 5)
            return false
        end
        local bans = game_bans()
        if bans and bans.is_id_banned and bans.is_id_banned(id) then
            g.notify("Error", "Life Together has banned that item.", 5)
            return false
        end
        if not (g.lt_accessory_type_of_asset or {})[asset_type] and not PROPERTY_OF_ASSET[asset_type] then
            g.notify("Error", ("That's a %s, not something you can wear."):format(asset_type == "Model" and "3D model" or asset_type), 5)
            return false
        end
        return g.lt_wear_catalog_item({ Id = id, ItemType = "Asset", AssetType = asset_type, Name = info.Name })
    end
    local function search_pages(creator, keyword, category)
        local params = CatalogSearchParams.new()
        params.SearchKeyword = keyword or ""
        params.CreatorName = creator or ""
        params.IncludeOffSale = true
        params.Limit = 60
        local assets, bundles = {}, {}
        for _, name in ipairs(category.assets or {}) do
            local ok, v = pcall(function() return Enum.AvatarAssetType[name] end)
            if ok and v then table.insert(assets, v) end
        end
        for _, name in ipairs(category.bundles or {}) do
            local ok, v = pcall(function() return Enum.BundleType[name] end)
            if ok and v then table.insert(bundles, v) end
        end
        params.AssetTypes = assets
        params.BundleTypes = bundles
        local ok, pages = pcall(function() return AvatarEditorService:SearchCatalogAsync(params) end)
        if not ok then ok, pages = pcall(function() return AvatarEditorService:SearchCatalog(params) end) end
        if not ok then return nil, tostring(pages) end
        return pages
    end
    local function keep(items, keyword_search)
        local bans = game_bans()
        local out = {}
        for _, item in ipairs(items) do
            local banned = false
            if bans and bans.is_item_banned then
                local ok, result = pcall(bans.is_item_banned, item, { ids = true, group_ids = true, creator_ids = true, key_words = not keyword_search })
                banned = ok and result == true
            end
            if not banned and not is_limited(item.ItemRestrictions) then table.insert(out, item) end
        end
        return out
    end
    g.lt_open_catalog = function(creator)
        g.lt_catalog_open = true
        if g.lt_catalog_gui and g.lt_catalog_gui.Parent then
            if creator and g.lt_catalog_search then g.lt_catalog_search(creator) end
            g.lt_refresh_popups()
            return
        end
        local gui = Instance.new("ScreenGui")
        gui.Name = "FlamesCatalogBrowser"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = gui_parent()
        g.lt_catalog_gui = gui
        local main = Instance.new("Frame")
        main.Size = UDim2.fromOffset(540, 540)
        main.Position = UDim2.new(0.5, -270, 0.5, -270)
        main.BackgroundColor3 = BG
        main.BorderSizePixel = 0
        main.Parent = gui
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke")
        stroke.Color = ACCENT
        stroke.Thickness = 1.5
        stroke.Parent = main
        local function label(parent, text, x, y, w, h, size, color, bold)
            local l = Instance.new("TextLabel")
            l.BackgroundTransparency = 1
            l.Position = UDim2.fromOffset(x, y)
            l.Size = UDim2.fromOffset(w, h)
            l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextSize = size or 13
            l.TextColor3 = color or TEXT
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.TextWrapped = true
            l.Text = text
            l.Parent = parent
            return l
        end
        local function button(parent, text, x, y, w, h, color)
            local b = Instance.new("TextButton")
            b.Position = UDim2.fromOffset(x, y)
            b.Size = UDim2.fromOffset(w, h)
            b.BackgroundColor3 = color or PANEL
            b.BorderSizePixel = 0
            b.AutoButtonColor = true
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.TextColor3 = TEXT
            b.Text = text
            b.Parent = parent
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            return b
        end
        local function textbox(placeholder, x, y, w, h)
            local t = Instance.new("TextBox")
            t.Position = UDim2.fromOffset(x, y)
            t.Size = UDim2.fromOffset(w, h)
            t.BackgroundColor3 = PANEL
            t.BorderSizePixel = 0
            t.Font = Enum.Font.Gotham
            t.TextSize = 13
            t.TextColor3 = TEXT
            t.PlaceholderText = placeholder
            t.PlaceholderColor3 = DIM
            t.ClearTextOnFocus = false
            t.Text = ""
            t.Parent = main
            Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
            return t
        end
        local title = label(main, "Catalog Browser", 12, 6, 400, 24, 15, TEXT, true)
        title.Active = true
        local close = button(main, "X", 506, 6, 24, 24)
        close.MouseButton1Click:Connect(function()
            g.lt_catalog_open = false
            g.lt_refresh_popups()
        end)
        do
            local dragging, start, start_pos
            title.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging, start, start_pos = true, input.Position, main.Position
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - start
                    main.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
        end
        local creator_box = textbox("Creator username or group name", 10, 38, 200, 28)
        local keyword_box = textbox("Keyword (optional)", 216, 38, 180, 28)
        local search_btn = button(main, "Search", 402, 38, 128, 28, ACCENT)
        local id_box = textbox("Or paste an item id / catalog link to wear it", 10, 72, 386, 26)
        local id_btn = button(main, "Wear ID", 402, 72, 128, 26)
        local category_index = 1
        local tabs = {}
        for i, cat in ipairs(CATEGORIES) do
            local b = button(main, cat.name, 10 + (i - 1) * 74, 104, 70, 24)
            b.TextSize = 11
            tabs[i] = b
        end
        local grid_frame = Instance.new("ScrollingFrame")
        grid_frame.Position = UDim2.fromOffset(10, 134)
        grid_frame.Size = UDim2.fromOffset(520, 366)
        grid_frame.BackgroundTransparency = 1
        grid_frame.BorderSizePixel = 0
        grid_frame.ScrollBarThickness = 4
        grid_frame.ScrollBarImageColor3 = ACCENT
        grid_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        grid_frame.CanvasSize = UDim2.new()
        grid_frame.Parent = main
        local grid = Instance.new("UIGridLayout")
        grid.CellSize = UDim2.fromOffset(120, 176)
        grid.CellPadding = UDim2.fromOffset(9, 9)
        grid.SortOrder = Enum.SortOrder.LayoutOrder
        grid.Parent = grid_frame
        local status = label(main, "Type a creator's username and press Search.", 12, 506, 380, 26, 12, DIM)
        local more_btn = button(main, "Load More", 402, 506, 128, 26)
        more_btn.Visible = false
        local current_pages, keyword_search, shown, searching = nil, false, 0, false
        local function card_for(item)
            shown += 1
            local card = Instance.new("Frame")
            card.LayoutOrder = shown
            card.BackgroundColor3 = CARD
            card.BorderSizePixel = 0
            card.Parent = grid_frame
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
            local image = Instance.new("ImageLabel")
            image.Position = UDim2.fromOffset(5, 5)
            image.Size = UDim2.fromOffset(110, 110)
            image.BackgroundColor3 = PANEL
            image.BorderSizePixel = 0
            image.Image = ("rbxthumb://type=%s&id=%d&w=150&h=150"):format(item.ItemType == "Bundle" and "BundleThumbnail" or "Asset", item.Id)
            image.Parent = card
            Instance.new("UICorner", image).CornerRadius = UDim.new(0, 6)
            local name = label(card, tostring(item.Name or item.Id), 6, 117, 108, 28, 11, TEXT, true)
            name.TextTruncate = Enum.TextTruncate.AtEnd
            local kind = label(card, tostring(item.AssetType or item.BundleType or ""), 6, 132, 108, 14, 10, DIM)
            kind.TextTruncate = Enum.TextTruncate.AtEnd
            local wear = button(card, "Wear", 5, 148, 110, 24, ACCENT)
            wear.MouseButton1Click:Connect(function()
                wear.Text = "..."
                task.spawn(function()
                    g.lt_wear_catalog_item(item)
                    if wear.Parent then wear.Text = "Wear" end
                end)
            end)
        end
        local function show_page()
            if not current_pages then return end
            local ok, items = pcall(function() return current_pages:GetCurrentPage() end)
            for _, item in ipairs(keep(ok and items or {}, keyword_search)) do card_for(item) end
            more_btn.Visible = not current_pages.IsFinished
            status.Text = shown == 0 and "Nothing found (deleted, moderated and limited items don't show)." or (shown .. " items. Press Wear to put one on.")
        end
        g.lt_catalog_search = function(creator)
            if searching then return end
            if creator then creator_box.Text = creator end
            local who, what = creator_box.Text:gsub("^%s+", ""):gsub("%s+$", ""), keyword_box.Text
            if who == "" and what == "" then status.Text = "Type a creator's username (or a keyword) first."; return end
            searching = true
            for _, c in ipairs(grid_frame:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
            shown, keyword_search = 0, what ~= ""
            status.Text = "Searching..."
            more_btn.Visible = false
            task.spawn(function()
                local pages, err = search_pages(who, what, CATEGORIES[category_index])
                current_pages = pages
                searching = false
                if not pages then
                    status.Text = "Search failed: " .. tostring(err)
                    return
                end
                show_page()
            end)
        end
        local function select_tab(i)
            category_index = i
            for k, b in ipairs(tabs) do b.BackgroundColor3 = (k == i) and ACCENT or PANEL end
        end
        for i, b in ipairs(tabs) do
            b.MouseButton1Click:Connect(function()
                select_tab(i)
                if creator_box.Text ~= "" or keyword_box.Text ~= "" then g.lt_catalog_search() end
            end)
        end
        select_tab(1)
        search_btn.MouseButton1Click:Connect(function() g.lt_catalog_search() end)
        creator_box.FocusLost:Connect(function(enter) if enter then g.lt_catalog_search() end end)
        keyword_box.FocusLost:Connect(function(enter) if enter then g.lt_catalog_search() end end)
        id_btn.MouseButton1Click:Connect(function() task.spawn(g.lt_wear_by_id, id_box.Text) end)
        more_btn.MouseButton1Click:Connect(function()
            if searching or not current_pages or current_pages.IsFinished then return end
            searching = true
            more_btn.Text = "Loading..."
            task.spawn(function()
                pcall(function() current_pages:AdvanceToNextPageAsync() end)
                searching = false
                more_btn.Text = "Load More"
                show_page()
            end)
        end)
        if creator then g.lt_catalog_search(creator) end
        g.lt_refresh_popups()
    end
    if g.lt_commands then
        g.lt_commands.add = function(args) task.spawn(g.lt_wear_by_id, args) end
        g.lt_commands.wearid = g.lt_commands.add
        g.lt_commands.catalog = function(args) g.lt_open_catalog(args ~= "" and args or nil) end
    end
    if g.lt_command_help then
        for _, help in ipairs({ "wearid <id or link>", "catalog <creator>" }) do table.insert(g.lt_command_help, help) end
    end
end
print("[Flames] loading: animator")
do
    local function lt_carry_setup()
        if g.lt_carry_stop then pcall(g.lt_carry_stop) end
        local KSP = game:GetService("KeyframeSequenceProvider")
        local ContentProvider = game:GetService("ContentProvider")
        local FILE = "lifetogether_carry_poses_" .. tostring(LocalPlayer.UserId) .. ".json"
        local ACCENT, BG, PANEL = Color3.fromRGB(21, 103, 251), Color3.fromRGB(16, 16, 21), Color3.fromRGB(28, 28, 36)
        local TEXT, DIM, GOOD = Color3.fromRGB(235, 235, 240), Color3.fromRGB(150, 150, 162), Color3.fromRGB(95, 210, 130)
        local PICKED = Color3.fromRGB(38, 58, 105)
        local ARMS = { RightUpperArm = true, RightLowerArm = true, RightHand = true, LeftUpperArm = true, LeftLowerArm = true, LeftHand = true }
        local BASE = { [Enum.AnimationPriority.Core] = true, [Enum.AnimationPriority.Idle] = true, [Enum.AnimationPriority.Movement] = true }
        local TABS = { "Saved", "Limbs", "Roblox", "Game", "Packs", "Seen" }
        local RIDE_DEFAULT = CFrame.new(1.2, 2.4, 0.3)
        local RIDE_PRESETS = {
            { "Shoulder", RIDE_DEFAULT }, { "Head", CFrame.new(0, 4.2, 0) },
            { "Back", CFrame.new(0, 0.6, 1.2) }, { "Beside", CFrame.new(-3, 1, 0) },
        }
        local LIMBS = {
            { "Head", "Head" }, { "UpperTorso", "Upper body" }, { "LowerTorso", "Hips (whole body)" },
            { "RightUpperArm", "Right upper arm" }, { "RightLowerArm", "Right lower arm" }, { "RightHand", "Right hand" },
            { "LeftUpperArm", "Left upper arm" }, { "LeftLowerArm", "Left lower arm" }, { "LeftHand", "Left hand" },
            { "RightUpperLeg", "Right upper leg" }, { "RightLowerLeg", "Right lower leg" }, { "RightFoot", "Right foot" },
            { "LeftUpperLeg", "Left upper leg" }, { "LeftLowerLeg", "Left lower leg" }, { "LeftFoot", "Left foot" },
        }
        local RIG = {
            LowerTorso = {
                UpperTorso = {
                    Head = {},
                    LeftUpperArm = { LeftLowerArm = { LeftHand = {} } },
                    RightUpperArm = { RightLowerArm = { RightHand = {} } },
                },
                LeftUpperLeg = { LeftLowerLeg = { LeftFoot = {} } },
                RightUpperLeg = { RightLowerLeg = { RightFoot = {} } },
            },
        }
        local LIBRARY = {
            Roblox = {
                { "Hold tool", 507768375 }, { "Tool slash", 522635514 }, { "Tool lunge", 522638767 }, { "Wave", 507770239 },
                { "Point", 507770453 }, { "Cheer", 507770677 }, { "Laugh", 507770818 }, { "Sit", 2506281703 },
                { "Dance 1", 507771019 }, { "Dance 2", 507776043 }, { "Dance 3", 507777268 }, { "Idle", 507766666 },
                { "Idle, looking around", 507766951 }, { "Climb", 507765644 }, { "Fall", 507767968 }, { "Jump", 507765000 },
                { "Swim", 507784897 }, { "Swim idle", 507785072 },
            },
            Game = {
                { "Back carry: carrier", 15165705832 }, { "Back carry: rider", 15165698516 }, { "Hold phone", 11524150966 },
                { "Bank chair sit", 12331154039 }, { "ATM", 12336871742 }, { "TV interviewer", 11519951564 },
                { "TV guest", 11519944593 }, { "TV chef", 13489787275 }, { "TV gymnast", 13733627910 },
                { "Game idle 1", 128667162266929 }, { "Game idle 2", 124366149420254 },
            },
            Packs = {
                { "Levitation idle", 616006778 }, { "Levitation fall", 616005863 }, { "Levitation climb", 616003713 },
                { "Stylish idle", 616136790 }, { "Stylish climb", 616133594 }, { "Cartoony idle", 742637544 },
                { "Cartoony climb", 742636889 }, { "Superhero idle", 616111295 }, { "Superhero fall", 616108001 },
                { "Zombie idle", 616158929 }, { "Ninja idle", 656117400 }, { "Ninja jump", 656117878 },
                { "Mage idle", 707742142 }, { "Mage climb", 707826056 }, { "Vampire idle", 1083445855 },
                { "Werewolf idle", 1083195517 }, { "Elder idle", 845397899 }, { "Toy idle", 782841498 },
                { "Bubbly idle", 910004836 }, { "Astronaut idle", 891621366 }, { "Robot idle", 616088211 },
                { "Knight idle", 657595757 }, { "Pirate idle", 750781874 }, { "Rthro idle", 2510196951 },
                { "Sneaky idle", 1132473842 }, { "Princess idle", 941003647 }, { "Cowboy idle", 1014390418 },
                { "Confident idle", 1069977950 }, { "Patrol idle", 1149612882 }, { "Old school idle", 5319828216 },
            },
        }
        local C = {
            alive = true, conns = {}, ui_conns = {}, ours = setmetatable({}, { __mode = "k" }),
            mirrors = {}, mirror_state = setmetatable({}, { __mode = "k" }), parts = {}, seen = {}, seen_list = {}, token = 0,
            role = false,
            defaults = setmetatable({}, { __mode = "k" }), collide = {},
        }
        g.lt_carry = C
        if g.lt_carry_auto_menu == nil then g.lt_carry_auto_menu = true end
        g.lt_carry_shown = false
        local data = {}
        pcall(function()
            if typeof(isfile) == "function" and isfile(FILE) then
                local saved = HttpService:JSONDecode(readfile(FILE))
                if type(saved) == "table" then data = saved end
            end
        end)
        if type(data.poses) ~= "table" then data.poses = {} end
        if type(data.saved) ~= "table" then data.saved = {} end
        if type(data.spots) ~= "table" then data.spots = {} end
        local function save_data()
            if typeof(writefile) == "function" then pcall(writefile, FILE, HttpService:JSONEncode(data)) end
        end
        local function asset(id)
            local n = tostring(id or ""):match("%d+")
            return n and ("rbxassetid://" .. n) or nil
        end
        local function short(id) return tostring(id or ""):match("%d+") or "?" end
        local function copy(t) return t and HttpService:JSONDecode(HttpService:JSONEncode(t)) or nil end
        local function my_animator()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            return hum and hum:FindFirstChildOfClass("Animator")
        end
        local function player_name(id)
            local p = id and Players:GetPlayerByUserId(id)
            return p and p.DisplayName or ("user " .. tostring(id))
        end
        local function side() return C.role or "solo" end
        local function session_key()
            return C.role and (C.role .. ":" .. tostring(C.kind) .. ":" .. tostring(C.partner)) or "solo"
        end
        local function parts_moved(id)
            id = asset(id)
            if not id then return false end
            if C.parts[id] ~= nil then return C.parts[id] end
            C.parts[id] = false
            local ok, kfs = pcall(function() return KSP:GetKeyframeSequenceAsync(id) end)
            if ok and typeof(kfs) == "Instance" then
                local set = {}
                for _, pose in ipairs(kfs:GetDescendants()) do
                    if pose:IsA("Pose") and pose.Weight > 0 and pose.Name ~= "HumanoidRootPart" then set[pose.Name] = true end
                end
                pcall(function() kfs:Destroy() end)
                C.parts[id] = set
            end
            return C.parts[id]
        end
        local function describe(set)
            if set == nil then return "" end
            if set == false then return "parts unknown" end
            local right = set.RightUpperArm or set.RightLowerArm or set.RightHand
            local left = set.LeftUpperArm or set.LeftLowerArm or set.LeftHand
            local upper, lower = false, false
            for name in pairs(set) do
                if not ARMS[name] then
                    if name == "UpperTorso" or name == "Head" then upper = true else lower = true end
                end
            end
            if lower then return "whole body" end
            if upper then return "upper body" end
            if right and left then return "both arms" end
            if right then return "right arm" end
            if left then return "left arm" end
            return "no body parts"
        end
        local function arm_pose(set)
            local d = describe(set)
            return d == "both arms" or d == "right arm" or d == "left arm" or d == "upper body"
        end
        local function register_custom(custom)
            local ok, id = pcall(function()
                local kfs = Instance.new("KeyframeSequence")
                kfs.Loop = true
                kfs.Priority = Enum.AnimationPriority.Action4
                for _, t in ipairs({ 0, 1 }) do
                    local kf = Instance.new("Keyframe")
                    kf.Time = t
                    kf.Parent = kfs
                    local function add(parent, name, children)
                        local pose = Instance.new("Pose")
                        pose.Name = name
                        local c = custom[name]
                        pose.CFrame = c and CFrame.new(table.unpack(c)) or CFrame.identity
                        pose.Weight = c and 1 or 0
                        pose.Parent = parent
                        for child, sub in pairs(children) do add(pose, child, sub) end
                    end
                    add(kf, "HumanoidRootPart", RIG)
                end
                return KSP:RegisterKeyframeSequence(kfs)
            end)
            return ok and id or nil
        end
        local function stop_layer(fade)
            C.token += 1
            local track = C.layer
            C.layer = nil
            if track then pcall(function() track:Stop(fade or 0.2) end) end
        end
        local function stop_mirrors()
            for original, mirror in pairs(C.mirrors) do
                pcall(function() mirror:Stop(0.2) end)
                C.mirrors[original] = nil
            end
        end
        local function apply_layer(pose)
            C.token += 1
            local token = C.token
            local old = C.layer
            C.layer = nil
            local function drop_old()
                if old then pcall(function() old:Stop(0.15) end) end
                old = nil
            end
            local animator = my_animator()
            local id
            if pose and pose.custom then
                id = register_custom(pose.custom)
                if not id then g.notify("Info", "This executor can't build a limb pose into an animation.", 4) end
            else
                id = asset(pose and pose.id)
                if id then
                    local preload = Instance.new("Animation")
                    preload.AnimationId = id
                    pcall(function() ContentProvider:PreloadAsync({ preload }) end)
                end
            end
            if not animator or not id or token ~= C.token then drop_old() return false end
            local anim = Instance.new("Animation")
            anim.AnimationId = id
            local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
            if not ok or not track then drop_old() return false end
            C.ours[track] = true
            track.Priority = Enum.AnimationPriority.Action4
            track.Looped = true
            C.layer = track
            local waited = tick()
            while track.Length == 0 and tick() - waited < 1 and token == C.token do task.wait() end
            if token ~= C.token then
                pcall(function() track:Stop(0) end)
                drop_old()
                return false
            end
            local length = track.Length
            local target = pose.custom and 0 or math.clamp(tonumber(pose.time) or 0, 0, math.max(length - 0.01, 0))
            if target < 0.03 then
                track:Play(0.1, 1, 0)
                drop_old()
            else
                track:Play(0.15, 1, math.clamp(target / 0.6, 1, 6))
                drop_old()
                local last, started = -1, tick()
                while token == C.token and track.IsPlaying and tick() - started < 10 do
                    RunService.Heartbeat:Wait()
                    local now = track.TimePosition
                    if now >= target or now < last then break end
                    last = now
                end
                if token ~= C.token then return false end
                track:AdjustSpeed(0)
            end
            track.TimePosition = target
            if C.refresh then pcall(C.refresh) end
            return true
        end
        local function idle_id(char)
            local animate = char and char:FindFirstChild("Animate")
            local idle = animate and animate:FindFirstChild("idle")
            local source = idle and (idle:FindFirstChild("Animation1") or idle:FindFirstChildOfClass("Animation"))
            return (source and source.AnimationId ~= "") and source.AnimationId or "rbxassetid://507766666"
        end
        local function stop_own_idle()
            local track = C.own_idle
            C.own_idle, C.own_idle_animator = nil, nil
            if track then pcall(function() track:Stop(0.2) end) end
        end
        local function sync_mirrors()
            local animator = my_animator()
            local base_on = animator and C.role and (not C.layer or (C.pose and C.pose.keep_base ~= false))
            if base_on and C.role == "carried" then
                if not (C.own_idle and C.own_idle_animator == animator) then
                    stop_own_idle()
                    local anim = Instance.new("Animation")
                    anim.AnimationId = idle_id(LocalPlayer.Character)
                    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
                    if ok and track then
                        C.ours[track] = true
                        track.Priority = Enum.AnimationPriority.Action3
                        track.Looped = true
                        track:Play(0.2)
                        C.own_idle, C.own_idle_animator = track, animator
                    end
                end
            elseif C.own_idle then
                stop_own_idle()
            end
            if not (base_on and C.role == "carrying") then
                if next(C.mirrors) then stop_mirrors() end
                return
            end
            local live = {}
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if not C.ours[track] and BASE[track.Priority] and track.Animation then
                    live[track] = true
                    local mirror = C.mirrors[track]
                    if not mirror then
                        local ok, dup = pcall(function() return animator:LoadAnimation(track.Animation) end)
                        if ok and dup then
                            C.ours[dup] = true
                            dup.Priority = Enum.AnimationPriority.Action3
                            dup.Looped = track.Looped
                            dup:Play(0.2, track.WeightTarget, track.Speed)
                            C.mirrors[track] = dup
                            C.mirror_state[dup] = { track.WeightTarget, track.Speed }
                        end
                    else
                        local state = C.mirror_state[mirror]
                        if state and math.abs(state[1] - track.WeightTarget) > 0.05 then
                            state[1] = track.WeightTarget
                            mirror:AdjustWeight(track.WeightTarget, 0.15)
                        end
                        if state and math.abs(state[2] - track.Speed) > 0.08 then
                            state[2] = track.Speed
                            mirror:AdjustSpeed(track.Speed)
                        end
                    end
                end
            end
            for original, mirror in pairs(C.mirrors) do
                if not live[original] then
                    pcall(function() mirror:Stop(0.2) end)
                    C.mirrors[original] = nil
                end
            end
        end
        local function save_pose()
            data.poses[session_key()] = copy(C.pose)
            save_data()
        end
        local function reset_idle()
            stop_layer(0.2)
            C.pose = nil
            save_pose()
            if C.refresh then pcall(C.refresh) end
        end
        local function limb_part()
            local char = LocalPlayer.Character
            return char and C.limb and char:FindFirstChild(C.limb)
        end
        local function joint_of(part)
            for _, d in ipairs(part and part:GetChildren() or {}) do
                if d:IsA("AnimationConstraint") and d.Attachment1 and d.Attachment1.Parent == part and d.Attachment0 then return d end
                if d:IsA("Motor6D") and d.Part1 == part and d.Part0 then return d end
            end
            return nil
        end
        local function joint_frame(j)
            if j:IsA("AnimationConstraint") then return j.Attachment0.WorldCFrame end
            return j.Part0.CFrame * j.C0
        end
        local function set_limb(name, cf)
            if not (C.pose and C.pose.custom) then
                C.pose = { name = "Limb pose", custom = {}, time = 0, keep_base = true }
            end
            C.pose.custom[name] = { cf:GetComponents() }
            C.limb_dirty = true
        end
        local function clear_limb(name)
            if not (C.pose and C.pose.custom) then return end
            C.pose.custom[name] = nil
            if next(C.pose.custom) == nil then
                stop_layer(0.2)
                C.pose = nil
            else
                C.limb_dirty = true
            end
            save_pose()
        end
        local function partner_char()
            local p = C.partner and Players:GetPlayerByUserId(C.partner)
            return p and p.Character
        end
        local function find_weld()
            if C.weld and C.weld.Parent then return C.weld end
            C.weld = nil
            local mine, theirs = LocalPlayer.Character, partner_char()
            local holder = C.role == "carrying" and mine or theirs
            local rider = C.role == "carrying" and theirs or mine
            local root = rider and rider:FindFirstChild("HumanoidRootPart")
            if not (C.role and holder and root) then return nil end
            for _, d in ipairs(holder:GetDescendants()) do
                if d:IsA("JointInstance") and d.Part1 == root then
                    C.weld = d
                    if not C.defaults[d] then C.defaults[d] = d.C0 end
                    break
                end
            end
            return C.weld
        end
        local function riding() return C.kind == "Ride" end
        local function spot_key() return C.role and (C.role .. ":" .. tostring(C.kind) .. ":" .. tostring(C.partner)) or nil end
        local function spot_c0()
            local saved = spot_key() and data.spots[spot_key()]
            if type(saved) == "table" and #saved == 12 then return CFrame.new(table.unpack(saved)) end
            return nil
        end
        local function spot_pair()
            if riding() then
                local t = C.ride_player
                local troot = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if troot and root then return troot, root, RIDE_DEFAULT end
                return nil
            end
            local w = find_weld()
            if w and w.Part0 and w.Part1 then return w.Part0, w.Part1, C.defaults[w] end
            return nil
        end
        local function apply_spot()
            if riding() then return end
            local weld = find_weld()
            if weld then pcall(function() weld.C0 = C.c0 or C.defaults[weld] end) end
        end
        local function spot_moved()
            local _, _, default = spot_pair()
            return C.c0 ~= nil and not (default and C.c0 == default)
        end
        local function save_spot()
            local key = spot_key()
            if not key then return end
            data.spots[key] = spot_moved() and { C.c0:GetComponents() } or nil
            save_data()
            if C.refresh then pcall(C.refresh) end
        end
        local function clear_handles()
            if C.handle_folder then pcall(function() C.handle_folder:Destroy() end) end
            if C.proxy then pcall(function() C.proxy:Destroy() end) end
            C.handle_folder, C.proxy, C.drag, C.handle_sig, C.handle_kind = nil, nil, nil, nil, nil
        end
        local function handle_target()
            if C.spot_mode and C.role and spot_pair() then return "spot" end
            if C.tab == "Limbs" and joint_of(limb_part()) then return "limb" end
            return nil
        end
        local function place_proxy()
            if not C.proxy or C.drag then return end
            if C.handle_kind == "spot" then
                local base, root = spot_pair()
                if base and root then C.proxy.CFrame = base.CFrame.Rotation + root.Position end
                return
            end
            local part = limb_part()
            local j = joint_of(part)
            if not j then return end
            C.proxy.Size = part.Size
            C.proxy.CFrame = CFrame.new(joint_frame(j).Position) * part.CFrame.Rotation
        end
        local function finish_drag()
            if not C.drag then return end
            local kind = C.drag.kind
            C.drag = nil
            if kind == "spot" then
                save_spot()
                return
            end
            C.limb_dirty = true
            save_pose()
            if C.refresh then pcall(C.refresh) end
        end
        local function build_handles(kind)
            clear_handles()
            if not g.lt_carry_gui then return end
            local _, rider_root = spot_pair()
            local part = kind == "limb" and limb_part()
            local folder = Instance.new("Folder")
            folder.Name = "FlamesAnimatorHandles"
            folder.Parent = g.lt_carry_gui
            C.handle_folder = folder
            local proxy = Instance.new("Part")
            proxy.Name = "FlamesAnimatorBox"
            proxy.Anchored = true
            proxy.CanCollide, proxy.CanQuery, proxy.CanTouch, proxy.CastShadow = false, false, false, false
            proxy.Transparency = 1
            proxy.Size = Vector3.new(2, 2, 2)
            proxy.Parent = workspace.CurrentCamera
            C.proxy, C.handle_kind = proxy, kind
            place_proxy()
            local outline = Instance.new("SelectionBox")
            outline.Adornee = kind == "spot" and rider_root and rider_root.Parent or part
            outline.Color3 = ACCENT
            outline.LineThickness = kind == "spot" and 0.02 or 0.015
            outline.SurfaceTransparency = 1
            outline.Parent = folder
            local tool
            if kind == "spot" and C.spot_mode == "Move" then
                tool = Instance.new("Handles")
                tool.Style = Enum.HandlesStyle.Movement
                tool.Color3 = ACCENT
                tool.MouseDrag:Connect(function(face, distance)
                    local d = C.drag
                    if not d then return end
                    local shift = Vector3.FromNormalId(face) * distance
                    C.c0 = CFrame.new(shift) * d.c0
                    apply_spot()
                    proxy.CFrame = d.proxy_cf + d.proxy_cf:VectorToWorldSpace(shift)
                end)
            else
                tool = Instance.new("ArcHandles")
                tool.MouseDrag:Connect(function(axis, angle)
                    local d = C.drag
                    if not d then return end
                    if d.kind == "spot" then
                        local turn = CFrame.fromAxisAngle(Vector3.FromAxis(axis), angle)
                        local at = d.c0.Position
                        C.c0 = CFrame.new(at) * turn * CFrame.new(-at) * d.c0
                        apply_spot()
                        proxy.CFrame = d.proxy_cf * turn
                    else
                        local turn = CFrame.fromAxisAngle(d.rot:VectorToWorldSpace(Vector3.FromAxis(axis)), angle)
                        set_limb(C.limb, (d.jr:Inverse() * turn * d.jr) * d.t)
                        proxy.CFrame = CFrame.new(d.at) * turn * d.rot
                    end
                end)
            end
            tool.Adornee = proxy
            tool.Parent = folder
            tool.MouseButton1Down:Connect(function()
                if kind == "spot" then
                    local base, _, default = spot_pair()
                    if base then C.drag = { kind = "spot", c0 = C.c0 or default, proxy_cf = proxy.CFrame } end
                    return
                end
                local p = limb_part()
                local j = joint_of(p)
                if not j then return end
                local saved = C.pose and C.pose.custom and C.pose.custom[C.limb]
                local start = saved and CFrame.new(table.unpack(saved))
                if not start then
                    local ok, live = pcall(function() return j.Transform end)
                    start = ok and live or CFrame.identity
                end
                C.drag = { kind = "limb", t = start, jr = joint_frame(j).Rotation, rot = p.CFrame.Rotation, at = proxy.Position }
            end)
            tool.MouseButton1Up:Connect(finish_drag)
        end
        local function sync_handles()
            local kind = g.lt_carry_shown and not g.lt_ui_hidden and g.lt_carry_gui and handle_target()
            if not kind then
                if C.handle_folder then clear_handles() end
                return
            end
            local _, rider_root = spot_pair()
            local sig = kind .. ":" .. tostring(kind == "spot" and C.spot_mode or C.limb) .. ":"
                .. tostring(kind == "spot" and rider_root or LocalPlayer.Character)
            if C.handle_sig ~= sig or not (C.handle_folder and C.handle_folder.Parent) then
                build_handles(kind)
                C.handle_sig = sig
            end
        end
        local function current_session()
            if C.ride_player and C.ride_player.Parent == Players then return "carried", C.ride_player.UserId, "Ride" end
            local carrying = LocalPlayer:GetAttribute("Carrying")
            local kind = tostring(LocalPlayer:GetAttribute("CarryingType") or "Carry")
            if typeof(carrying) == "number" then return "carrying", carrying, kind end
            local by = LocalPlayer:GetAttribute("CarryingBy")
            if carrying == true and typeof(by) == "number" then return "carried", by, kind end
            return nil, nil, nil
        end
        local build_panel
        g.lt_carry_open = function()
            g.lt_carry_shown = true
            if not (g.lt_carry_gui and g.lt_carry_gui.Parent) then build_panel() end
            if C.refresh then pcall(C.refresh) end
            if g.lt_refresh_popups then g.lt_refresh_popups() else g.lt_carry_gui.Enabled = true end
        end
        g.lt_carry_close = function()
            g.lt_carry_shown = false
            C.auto_opened = false
            clear_handles()
            if g.lt_refresh_popups then g.lt_refresh_popups() elseif g.lt_carry_gui then g.lt_carry_gui.Enabled = false end
        end
        local function update_session()
            if not C.alive then return end
            local role, partner, kind = current_session()
            if role == C.role and partner == C.partner and kind == C.kind then return end
            local had = C.role
            C.role, C.partner, C.kind = role, partner, kind
            C.weld, C.applied_weld, C.spot_mode = nil, nil, nil
            C.c0 = spot_c0()
            stop_layer(0.2)
            C.pose = nil
            local saved = data.poses[session_key()]
            if saved then
                C.pose = copy(saved)
                task.spawn(apply_layer, C.pose)
            end
            if role then
                if saved or C.c0 then g.notify("Info", "Your saved carry pose for " .. player_name(partner) .. " is back on.", 4) end
                if g.lt_carry_auto_menu ~= false and not g.lt_carry_shown then
                    g.lt_carry_open()
                    C.auto_opened = true
                end
            else
                stop_mirrors()
                if had and C.auto_opened then g.lt_carry_close() end
            end
            if C.refresh then pcall(C.refresh) end
        end
        local function find_player(text)
            text = (tostring(text or ""):lower():gsub("^@", ""):gsub("^%s+", ""):gsub("%s+$", ""))
            if text == "" then return nil end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and (p.Name:lower():sub(1, #text) == text or p.DisplayName:lower():sub(1, #text) == text) then
                    return p
                end
            end
            return nil
        end
        local function stop_ride()
            if C.ride_conn then C.ride_conn:Disconnect() end
            C.ride_conn = nil
            local was = C.ride_player
            C.ride_player = nil
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("FlamesRideHold") then pcall(function() root.FlamesRideHold:Destroy() end) end
            if hum and was then pcall(function() hum.Sit = false end) end
            for part, on in pairs(C.collide) do
                if part.Parent then pcall(function() part.CanCollide = on end) end
            end
            C.collide = {}
            if was then task.defer(update_session) end
        end
        local function start_ride(p)
            stop_ride()
            C.ride_player = p
            data.ride_name = p.Name
            save_data()
            C.ride_conn = RunService.Heartbeat:Connect(function()
                local t = C.ride_player
                local troot = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not (troot and root and hum) then return end
                if not root:FindFirstChild("FlamesRideHold") then
                    local hold = Instance.new("BodyAngularVelocity")
                    hold.Name = "FlamesRideHold"
                    hold.AngularVelocity = Vector3.zero
                    hold.MaxTorque = Vector3.new(50000, 50000, 50000)
                    hold.P = 1250
                    hold.Parent = root
                end
                if not hum.Sit then hum.Sit = true end
                root.CFrame = troot.CFrame * (C.c0 or RIDE_DEFAULT)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
            task.defer(update_session)
        end
        local function remember(p, track)
            if C.ours[track] or #C.seen_list >= 300 then return end
            local id = track.Animation and asset(track.Animation.AnimationId)
            if not id or C.seen[id] then return end
            C.seen[id] = true
            local who = p == LocalPlayer and "You" or p.DisplayName
            table.insert(C.seen_list, { who .. ": " .. (track.Name ~= "Animation" and track.Name or "animation"), id })
        end
        local function watch_character(p, char)
            local hum = char:WaitForChild("Humanoid", 10)
            local animator = hum and hum:WaitForChild("Animator", 10)
            if not animator or not C.alive then return end
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do remember(p, track) end
            table.insert(C.conns, animator.AnimationPlayed:Connect(function(track) remember(p, track) end))
        end
        local function watch_player(p)
            if p.Character then task.spawn(watch_character, p, p.Character) end
            table.insert(C.conns, p.CharacterAdded:Connect(function(char) watch_character(p, char) end))
        end
        build_panel = function()
            local W, H = 320, 470
            local gui = Instance.new("ScreenGui")
            gui.Name = "FlamesAnimator"
            gui.ResetOnSpawn = false
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.Enabled = false
            local ok, hidden = pcall(function() return gethui and gethui() end)
            gui.Parent = (ok and hidden) or CoreGui
            g.lt_carry_gui = gui
            local main = Instance.new("Frame")
            main.Size = UDim2.fromOffset(W, H)
            main.Position = UDim2.new(0, 30, 0.5, -H / 2)
            main.BackgroundColor3 = BG
            main.BorderSizePixel = 0
            main.Active = true
            main.Parent = gui
            Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
            local stroke = Instance.new("UIStroke")
            stroke.Color = ACCENT
            stroke.Thickness = 1.5
            stroke.Parent = main
            local refresh, show_tab, choose, show_time, box, use
            local function label(text, x, y, w, h, size, color, parent)
                local l = Instance.new("TextLabel")
                l.BackgroundTransparency = 1
                l.Position = UDim2.fromOffset(x, y)
                l.Size = UDim2.fromOffset(w, h)
                l.Font = Enum.Font.GothamBold
                l.TextSize = size or 13
                l.TextColor3 = color or TEXT
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.TextYAlignment = Enum.TextYAlignment.Top
                l.TextWrapped = true
                l.Text = text
                l.Parent = parent or main
                return l
            end
            local function button(text, x, y, w, h, color, parent)
                local b = Instance.new("TextButton")
                b.Position = UDim2.fromOffset(x, y)
                b.Size = UDim2.fromOffset(w, h)
                b.BackgroundColor3 = color or PANEL
                b.BorderSizePixel = 0
                b.AutoButtonColor = true
                b.Font = Enum.Font.GothamBold
                b.TextSize = 12
                b.TextColor3 = TEXT
                b.Text = text
                b.Parent = parent or main
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
                return b
            end
            local function row_button(order, parent)
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, 0, 0, 30)
                b.BackgroundColor3 = BG
                b.BorderSizePixel = 0
                b.AutoButtonColor = true
                b.Text = ""
                b.LayoutOrder = order
                b.Parent = parent
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
                return b
            end
            local function small_x(parent)
                local x = Instance.new("TextButton")
                x.AnchorPoint = Vector2.new(1, 0.5)
                x.Position = UDim2.new(1, -4, 0.5, 0)
                x.Size = UDim2.fromOffset(22, 22)
                x.BackgroundColor3 = PANEL
                x.BorderSizePixel = 0
                x.Font = Enum.Font.GothamBold
                x.TextSize = 12
                x.TextColor3 = DIM
                x.Text = "X"
                x.Parent = parent
                Instance.new("UICorner", x).CornerRadius = UDim.new(0, 5)
                return x
            end
            local title = label("Animator", 12, 9, 240, 22, 15)
            title.Active = true
            local close = button("X", W - 34, 6, 24, 24)
            close.MouseButton1Click:Connect(g.lt_carry_close)
            do
                local dragging, start, start_pos
                title.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging, start, start_pos = true, input.Position, main.Position
                    end
                end)
                table.insert(C.ui_conns, UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - start
                        main.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
                    end
                end))
                table.insert(C.ui_conns, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                        finish_drag()
                    end
                end))
            end
            local status = label("", 12, 34, W - 24, 32, 12, DIM)
            label("Ride someone (everyone sees it)", 12, 72, W - 24, 16, 12, ACCENT)
            local ride_box = Instance.new("TextBox")
            ride_box.Position = UDim2.fromOffset(12, 90)
            ride_box.Size = UDim2.fromOffset(232, 26)
            ride_box.BackgroundColor3 = PANEL
            ride_box.BorderSizePixel = 0
            ride_box.ClearTextOnFocus = false
            ride_box.Font = Enum.Font.Gotham
            ride_box.TextSize = 12
            ride_box.TextColor3 = TEXT
            ride_box.PlaceholderText = "Player name"
            ride_box.PlaceholderColor3 = DIM
            ride_box.Text = tostring(data.ride_name or "")
            ride_box.TextXAlignment = Enum.TextXAlignment.Left
            ride_box.Parent = main
            Instance.new("UICorner", ride_box).CornerRadius = UDim.new(0, 6)
            local ride_pad = Instance.new("UIPadding")
            ride_pad.PaddingLeft = UDim.new(0, 8)
            ride_pad.Parent = ride_box
            local ride_b = button("Ride", 250, 90, 58, 26, ACCENT)
            local spot_title = label("", 12, 122, W - 24, 16, 12, ACCENT)
            local move_b = button("Move", 12, 140, 70, 26)
            local turn_b = button("Turn", 86, 140, 70, 26)
            local default_b = button("", 160, 140, 148, 26)
            local function preset_name()
                if not C.c0 then return "Shoulder" end
                for _, preset in ipairs(RIDE_PRESETS) do
                    if C.c0 == preset[2] then return preset[1] end
                end
                return "your own"
            end
            local lower = Instance.new("Frame")
            lower.BackgroundTransparency = 1
            lower.Position = UDim2.fromOffset(0, 122)
            lower.Size = UDim2.fromOffset(W, 400)
            lower.Parent = main
            label("Your pose", 12, 0, W - 24, 16, 12, ACCENT, lower)
            local reset_b = button("Reset to idle", 12, 18, W - 24, 26, ACCENT, lower)
            local tab_buttons = {}
            for i, name in ipairs(TABS) do
                local b = button(name, 12 + (i - 1) * 50, 50, 46, 24, nil, lower)
                b.TextSize = 11
                tab_buttons[name] = b
                b.MouseButton1Click:Connect(function() show_tab(name) end)
            end
            local list = Instance.new("ScrollingFrame")
            list.Position = UDim2.fromOffset(12, 80)
            list.Size = UDim2.fromOffset(W - 24, 128)
            list.BackgroundColor3 = PANEL
            list.BorderSizePixel = 0
            list.ScrollBarThickness = 5
            list.CanvasSize = UDim2.new()
            list.AutomaticCanvasSize = Enum.AutomaticSize.Y
            list.Parent = lower
            Instance.new("UICorner", list).CornerRadius = UDim.new(0, 6)
            local layout = Instance.new("UIListLayout")
            layout.Padding = UDim.new(0, 2)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Parent = list
            local pad = Instance.new("UIPadding")
            pad.PaddingTop, pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 3), UDim.new(0, 3), UDim.new(0, 9)
            pad.Parent = list
            local rows, current_tab = {}, nil
            local function note(text, order, h)
                local l = label(text, 8, 0, W - 50, h or 30, 11, DIM, list)
                l.LayoutOrder = order
                table.insert(rows, { button = l })
            end
            local function paint_rows()
                local on = C.pose and not C.pose.custom and asset(C.pose.id)
                for _, row in ipairs(rows) do
                    if row.id then row.button.BackgroundColor3 = (row.id == on) and PICKED or BG end
                end
            end
            local function set_tag(row)
                local set = C.parts[row.id]
                local d = describe(set)
                row.tag.Text = (d ~= "" and (d .. "   ") or "") .. short(row.id)
                row.tag.TextColor3 = (set and arm_pose(set)) and GOOD or DIM
            end
            local function apply_saved(entry)
                C.pose = copy(entry.pose)
                save_pose()
                if C.pose then task.spawn(apply_layer, C.pose) else stop_layer(0.2) end
                if C.role then
                    C.c0 = (type(entry.c0) == "table" and #entry.c0 == 12) and CFrame.new(table.unpack(entry.c0)) or nil
                    apply_spot()
                    save_spot()
                end
                g.notify("Success", "Switched to " .. tostring(entry.name) .. ".", 2)
                refresh()
            end
            local SIDE_NAMES = { solo = "Animation ", carrying = "Carrying ", carried = "Carried " }
            local function saved_role(entry)
                return (entry.role == "solo" or entry.role == "carried") and entry.role or "carrying"
            end
            local function save_current(name)
                local here = side()
                if not C.pose and not (C.role and spot_moved()) then g.notify("Info", "Put a pose on first, then save it.", 3) return end
                name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
                if name == "" then
                    local n = 1
                    for _, entry in ipairs(data.saved) do if saved_role(entry) == here then n += 1 end end
                    name = SIDE_NAMES[here] .. n
                end
                local entry = { name = name, role = here, pose = copy(C.pose), c0 = (C.role and spot_moved()) and { C.c0:GetComponents() } or nil }
                local replaced = false
                for i, old in ipairs(data.saved) do
                    if old.name == name and saved_role(old) == here then
                        data.saved[i] = entry
                        replaced = true
                        break
                    end
                end
                if not replaced then table.insert(data.saved, entry) end
                save_data()
                g.notify("Success", (replaced and "Updated " or "Saved ") .. name .. ".", 3)
                show_tab("Saved")
            end
            local saved_shown_for
            local function show_saved()
                saved_shown_for = side()
                local here, order = side(), 0
                for _, entry in ipairs(data.saved) do
                    if saved_role(entry) == here then
                        order += 1
                        local b = row_button(order, list)
                        label(tostring(entry.name), 8, 2, W - 80, 15, 12, TEXT, b)
                        local pose = entry.pose
                        local what = type(pose) ~= "table" and "idle" or (pose.custom and "limb pose" or tostring(pose.name))
                        local spot = here ~= "solo" and ("   spot: " .. (entry.c0 and "moved" or "game's")) or ""
                        label("pose: " .. what .. spot, 8, 16, W - 80, 13, 10, DIM, b)
                        local del = small_x(b)
                        b.MouseButton1Click:Connect(function() apply_saved(entry) end)
                        del.MouseButton1Click:Connect(function()
                            local at = table.find(data.saved, entry)
                            if at then table.remove(data.saved, at) end
                            save_data()
                            show_tab("Saved")
                        end)
                        table.insert(rows, { button = b })
                    end
                end
                if order == 0 then
                    note(({ solo = "Nothing saved for when you're on your own yet.", carrying = "Nothing saved for carrying yet.",
                        carried = "Nothing saved for being carried yet." })[here] .. " Set it up, type a name below and click Save.", 1)
                end
            end
            local function show_limbs()
                note("Click a limb, then drag the rings on it. Test it: check your other account's window to see if others see it.", 0, 30)
                for i, limb in ipairs(LIMBS) do
                    local name, nice = limb[1], limb[2]
                    local b = row_button(i, list)
                    b.BackgroundColor3 = C.limb == name and PICKED or BG
                    label(nice, 8, 2, W - 80, 15, 12, TEXT, b)
                    local posed = C.pose and C.pose.custom and C.pose.custom[name]
                    label(posed and "rotated" or (C.limb == name and "picked: drag the rings" or ""), 8, 16, W - 80, 13, 10, posed and GOOD or DIM, b)
                    b.MouseButton1Click:Connect(function()
                        C.limb = name
                        C.spot_mode = nil
                        show_tab("Limbs")
                        pcall(sync_handles)
                    end)
                    if posed then
                        small_x(b).MouseButton1Click:Connect(function()
                            clear_limb(name)
                            show_tab("Limbs")
                        end)
                    end
                    table.insert(rows, { button = b })
                end
            end
            show_tab = function(tab)
                current_tab = tab
                C.tab = tab
                for name, b in pairs(tab_buttons) do b.BackgroundColor3 = (name == tab) and ACCENT or PANEL end
                for _, row in ipairs(rows) do row.button:Destroy() end
                table.clear(rows)
                if box then
                    box.PlaceholderText = tab == "Saved" and "Name for what's on now" or "Animation id or link"
                    use.Text = tab == "Saved" and "Save" or "Use"
                end
                if tab == "Saved" then show_saved() return end
                if tab == "Limbs" then show_limbs() return end
                local items = tab == "Seen" and C.seen_list or LIBRARY[tab] or {}
                if #items == 0 then note("Animations people play near you show up here. Click Seen again to update the list.", 0, 44) end
                local pending = {}
                for i, item in ipairs(items) do
                    local name, id = item[1], asset(item[2])
                    local b = row_button(i, list)
                    label(name, 8, 2, W - 50, 15, 12, TEXT, b)
                    local row = { button = b, id = id, tag = label("", 8, 16, W - 50, 13, 10, DIM, b) }
                    set_tag(row)
                    table.insert(rows, row)
                    b.MouseButton1Click:Connect(function() choose(id, name) end)
                    if C.parts[id] == nil then table.insert(pending, row) end
                end
                paint_rows()
                task.spawn(function()
                    for _, row in ipairs(pending) do
                        if current_tab ~= tab or not gui.Parent then return end
                        parts_moved(row.id)
                        if row.tag.Parent then set_tag(row) end
                    end
                    if refresh then refresh() end
                end)
            end
            box = Instance.new("TextBox")
            box.Position = UDim2.fromOffset(12, 214)
            box.Size = UDim2.fromOffset(232, 26)
            box.BackgroundColor3 = PANEL
            box.BorderSizePixel = 0
            box.ClearTextOnFocus = false
            box.Font = Enum.Font.Gotham
            box.TextSize = 12
            box.TextColor3 = TEXT
            box.PlaceholderText = "Animation id or link"
            box.PlaceholderColor3 = DIM
            box.Text = ""
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.Parent = lower
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
            local box_pad = Instance.new("UIPadding")
            box_pad.PaddingLeft = UDim.new(0, 8)
            box_pad.Parent = box
            use = button("Use", 250, 214, 58, 26, ACCENT, lower)
            local pose_label = label("", 12, 246, W - 24, 30, 11, TEXT, lower)
            local bar = Instance.new("Frame")
            bar.Position = UDim2.fromOffset(12, 286)
            bar.Size = UDim2.fromOffset(234, 10)
            bar.BackgroundColor3 = PANEL
            bar.BorderSizePixel = 0
            bar.Active = true
            bar.Parent = lower
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            local progress = Instance.new("Frame")
            progress.Size = UDim2.fromScale(0, 1)
            progress.BackgroundColor3 = ACCENT
            progress.BorderSizePixel = 0
            progress.Parent = bar
            Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)
            local knob = Instance.new("Frame")
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Size = UDim2.fromOffset(14, 14)
            knob.Position = UDim2.fromScale(0, 0.5)
            knob.BackgroundColor3 = TEXT
            knob.BorderSizePixel = 0
            knob.Parent = bar
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            local back = button("<", 252, 280, 26, 22, nil, lower)
            local fwd = button(">", 282, 280, 26, 22, nil, lower)
            local frame_label = label("", 12, 306, W - 24, 16, 11, DIM, lower)
            local keep = button("", 12, 328, W - 24, 24, nil, lower)
            local forget = button("", 12, 362, W - 24, 28, nil, lower)
            local function length() return (C.layer and C.pose and not C.pose.custom) and C.layer.Length or 0 end
            show_time = function()
                local len = length()
                local t = C.pose and tonumber(C.pose.time) or 0
                local f = len > 0 and math.clamp(t / len, 0, 1) or 0
                progress.Size = UDim2.fromScale(f, 1)
                knob.Position = UDim2.fromScale(f, 0.5)
                if not C.pose then
                    frame_label.Text = "Pick a pose, then drag here to choose the frame."
                elseif C.pose.custom then
                    frame_label.Text = "Limb pose: rotate limbs in the Limbs tab."
                elseif len <= 0 then
                    frame_label.Text = "This pose has a single frame."
                else
                    frame_label.Text = ("Frame %.2fs of %.2fs (drag, or click < >)"):format(t, len)
                end
            end
            refresh = function()
                if not gui.Parent then return end
                local who = C.partner and player_name(C.partner)
                local carrying = C.role == "carrying"
                local has_role = carrying or C.role == "carried"
                if riding() then
                    status.Text = "Riding " .. who .. ". Move / Turn place you on them; everyone sees it."
                elseif carrying then
                    status.Text = "Carrying " .. who .. ". Every change is saved for them straight away."
                elseif C.role == "carried" then
                    status.Text = "Carried by " .. who .. ". Your pose is saved for them straight away."
                else
                    status.Text = "On your own. What you pick here stays on and is saved straight away."
                end
                if current_tab == "Saved" and saved_shown_for ~= side() then show_tab("Saved") end
                for _, b in ipairs({ spot_title, move_b, turn_b, default_b }) do b.Visible = has_role end
                ride_b.Text = C.ride_player and "Stop" or "Ride"
                if riding() then
                    spot_title.Text = "Where you sit on them (everyone sees it)"
                    default_b.Text = "Spot: " .. preset_name()
                else
                    spot_title.Text = carrying and "Where they sit on you (only this screen)" or "Where you sit (only this screen)"
                    default_b.Text = spot_moved() and "Back to game's spot" or "At the game's spot"
                end
                move_b.BackgroundColor3 = C.spot_mode == "Move" and ACCENT or PANEL
                turn_b.BackgroundColor3 = C.spot_mode == "Turn" and ACCENT or PANEL
                lower.Position = UDim2.fromOffset(0, has_role and 172 or 122)
                main.Size = UDim2.fromOffset(W, has_role and 570 or 452)
                if C.pose and C.pose.custom then
                    local n = 0
                    for _ in pairs(C.pose.custom) do n += 1 end
                    pose_label.Text = ("Limb pose: %d limb%s rotated."):format(n, n == 1 and "" or "s")
                elseif C.pose then
                    local d = describe(C.parts[asset(C.pose.id)])
                    local text = tostring(C.pose.name) .. (d ~= "" and ("  (moves: " .. d .. ")") or "")
                    if carrying and d == "whole body" and C.pose.keep_base ~= false then text ..= ". Your legs hold still too." end
                    pose_label.Text = text
                elseif carrying then
                    pose_label.Text = "On your normal idle. Pick an arm pose to hold your arms still."
                elseif C.role == "carried" then
                    pose_label.Text = "On your normal idle. Pick a pose for how you sit on them."
                else
                    pose_label.Text = "Nothing on. Pick an animation; arm-only ones keep your idle and walk."
                end
                keep.Visible = has_role and C.pose ~= nil
                keep.Text = (carrying and "Keep my idle and walk under the pose: " or "Keep my idle under the pose: ")
                    .. ((C.pose and C.pose.keep_base == false) and "OFF" or "ON")
                forget.Visible = has_role
                forget.Text = who and ("Forget what's saved for " .. who) or ""
                show_time()
                paint_rows()
                pcall(sync_handles)
            end
            C.refresh = refresh
            choose = function(id, name)
                C.pose = { id = id, name = name, time = 0, keep_base = not (C.pose and C.pose.keep_base == false) }
                save_pose()
                refresh()
                task.spawn(function()
                    parts_moved(id)
                    if gui.Parent then refresh() end
                end)
                task.spawn(function()
                    apply_layer(C.pose)
                    local track = C.layer
                    if track and C.pose and C.pose.id == id and track.Length == 0 and C.parts[id] == false then
                        g.notify("Info", "That animation didn't load. It may not be allowed in this game.", 4)
                    end
                    if gui.Parent then refresh() end
                end)
            end
            local function use_box()
                if current_tab == "Saved" then
                    save_current(box.Text)
                    box.Text = ""
                    return
                end
                local id = asset(box.Text)
                if not id then g.notify("Info", "Paste an animation id first.", 3) return end
                box.Text = ""
                choose(id, "Animation " .. short(id))
            end
            use.MouseButton1Click:Connect(use_box)
            box.FocusLost:Connect(function(enter) if enter then use_box() end end)
            local scrubbing = false
            local function preview(t)
                if not C.pose or C.pose.custom then return end
                C.pose.time = t
                local track = C.layer
                if track then
                    pcall(function()
                        if track.Speed ~= 0 then track:AdjustSpeed(0) end
                        track.TimePosition = t
                    end)
                end
                show_time()
            end
            local function commit()
                if not C.pose or C.pose.custom then return end
                save_pose()
                task.spawn(apply_layer, C.pose)
            end
            local function scrub_to(x)
                local len = length()
                if len <= 0 or bar.AbsoluteSize.X <= 0 then return end
                local f = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                preview(math.min(f * len, len - 0.01))
            end
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    scrubbing = true
                    scrub_to(input.Position.X)
                end
            end)
            table.insert(C.ui_conns, UserInputService.InputChanged:Connect(function(input)
                if scrubbing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    scrub_to(input.Position.X)
                end
            end))
            table.insert(C.ui_conns, UserInputService.InputEnded:Connect(function(input)
                if scrubbing and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    scrubbing = false
                    commit()
                end
            end))
            local function nudge(dir)
                local len = length()
                if not C.pose or len <= 0 then return end
                preview(math.clamp((tonumber(C.pose.time) or 0) + dir * len / 40, 0, len - 0.01))
                commit()
            end
            back.MouseButton1Click:Connect(function() nudge(-1) end)
            fwd.MouseButton1Click:Connect(function() nudge(1) end)
            move_b.MouseButton1Click:Connect(function()
                C.spot_mode = C.spot_mode ~= "Move" and "Move" or nil
                refresh()
            end)
            turn_b.MouseButton1Click:Connect(function()
                C.spot_mode = C.spot_mode ~= "Turn" and "Turn" or nil
                refresh()
            end)
            default_b.MouseButton1Click:Connect(function()
                if riding() then
                    local at = 0
                    for i, preset in ipairs(RIDE_PRESETS) do
                        if C.c0 == preset[2] or (not C.c0 and i == 1) then at = i end
                    end
                    C.c0 = RIDE_PRESETS[at % #RIDE_PRESETS + 1][2]
                else
                    C.c0 = nil
                end
                apply_spot()
                save_spot()
            end)
            local function ride_click()
                if C.ride_player then stop_ride() else g.lt_ride(ride_box.Text) end
                refresh()
            end
            ride_b.MouseButton1Click:Connect(ride_click)
            ride_box.FocusLost:Connect(function(enter) if enter then ride_click() end end)
            reset_b.MouseButton1Click:Connect(function()
                reset_idle()
                if current_tab == "Limbs" then show_tab("Limbs") end
            end)
            keep.MouseButton1Click:Connect(function()
                if not C.pose then return end
                C.pose.keep_base = C.pose.keep_base == false
                save_pose()
                refresh()
            end)
            forget.MouseButton1Click:Connect(function()
                if not C.role then return end
                data.poses[session_key()] = nil
                data.spots[spot_key()] = nil
                save_data()
                stop_layer(0.2)
                C.pose = nil
                C.c0 = nil
                apply_spot()
                g.notify("Info", "Forgot what's saved for " .. player_name(C.partner) .. ".", 4)
                refresh()
            end)
            local has_saved = false
            for _, entry in ipairs(data.saved) do if saved_role(entry) == side() then has_saved = true end end
            show_tab(has_saved and "Saved" or (C.role == "carrying" and "Seen" or "Roblox"))
            refresh()
        end
        g.lt_carry_stop = function()
            stop_ride()
            C.alive = false
            stop_layer(0.1)
            stop_mirrors()
            stop_own_idle()
            clear_handles()
            if C.weld and C.weld.Parent and C.defaults[C.weld] then pcall(function() C.weld.C0 = C.defaults[C.weld] end) end
            for _, list in ipairs({ C.conns, C.ui_conns }) do
                for _, c in ipairs(list) do pcall(function() c:Disconnect() end) end
                table.clear(list)
            end
            if g.lt_carry_gui then pcall(function() g.lt_carry_gui:Destroy() end) end
            g.lt_carry_gui, g.lt_carry_shown, C.refresh = nil, false, nil
        end
        for _, p in ipairs(Players:GetPlayers()) do watch_player(p) end
        table.insert(C.conns, Players.PlayerAdded:Connect(watch_player))
        table.insert(C.conns, LocalPlayer.CharacterAdded:Connect(function()
            C.token += 1
            C.layer = nil
            C.mirrors = {}
            C.own_idle, C.own_idle_animator = nil, nil
            clear_handles()
            task.wait(1)
            if C.alive and C.pose then apply_layer(C.pose) end
        end))
        for _, attr in ipairs({ "Carrying", "CarryingBy", "CarryingType" }) do
            table.insert(C.conns, LocalPlayer:GetAttributeChangedSignal(attr):Connect(function() task.defer(update_session) end))
        end
        table.insert(C.conns, RunService.RenderStepped:Connect(function()
            if C.proxy and not C.drag then place_proxy() end
        end))
        task.spawn(function()
            while C.alive do
                task.wait(0.1)
                pcall(sync_mirrors)
                if C.ride_player then
                    if C.ride_player.Parent ~= Players then
                        g.notify("Info", "The person you were riding left.", 4)
                        stop_ride()
                    else
                        for _, part in ipairs(LocalPlayer.Character and LocalPlayer.Character:GetDescendants() or {}) do
                            if part:IsA("BasePart") and part.CanCollide then
                                if C.collide[part] == nil then C.collide[part] = true end
                                part.CanCollide = false
                            end
                        end
                    end
                end
                if C.role and not riding() then
                    local weld = find_weld()
                    if weld ~= C.applied_weld then
                        C.applied_weld = weld
                        if weld then pcall(apply_spot) end
                        if C.refresh then pcall(C.refresh) end
                    end
                end
                if C.limb_dirty and C.pose and C.pose.custom and not C.building then
                    C.limb_dirty = false
                    C.building = true
                    task.spawn(function()
                        pcall(apply_layer, C.pose)
                        C.building = false
                    end)
                end
                pcall(sync_handles)
            end
        end)
        task.defer(update_session)
        g.lt_ride = function(text)
            if text == nil or text == "" then
                if C.ride_player then stop_ride() return end
                text = data.ride_name
            end
            local p = find_player(text)
            if not p then g.notify("Info", "No player here called " .. tostring(text) .. ".", 3) return end
            start_ride(p)
            g.notify("Success", "Riding " .. p.DisplayName .. ". Open the Animator to move yourself on them.", 4)
        end
        if g.lt_commands then
            g.lt_commands.anim = function() g.lt_carry_open() end
            g.lt_commands.pose = g.lt_commands.anim
            g.lt_commands.carry = g.lt_commands.anim
            g.lt_commands.ride = function(args) g.lt_ride(args) end
            g.lt_commands.unride = function() stop_ride() end
        end
        if g.lt_command_help then
            table.insert(g.lt_command_help, "anim (animator)")
            table.insert(g.lt_command_help, "ride <player> / unride (sit on someone, everyone sees it)")
        end
    end
    lt_carry_setup()
end
print("[Flames] loading: menu library")
local Atlas = loadstring(prefetched.__atlas or g.http_get(prefetched.atlas_url, true))()
local UI = Atlas.new({
    Name = "Flames Hub | Life Together RP",
    ConfigFolder = "FlamesHub_Life_Together_RP_Menu_Configuration",
    Color = Color3.fromRGB(21, 103, 251),
    Credit = "Flames Hub | Made by: " .. tostring(g.Script_Creator or "Flames Hub") .. " | " .. tostring(g.Script_Version),
    Bind = "X",
})
task.wait()
g.create_ui_element = function(element_type, parent, config, global_name, flag)
    local creators = {
        Tab         = function() return parent:CreatePage(config) end,
        Section     = function() return parent:CreateSection(config) end,
        Toggle      = function() return parent:CreateToggle(config, flag) end,
        Slider      = function() return parent:CreateSlider(config, flag) end,
        Button      = function() return parent:CreateButton(config, flag) end,
        ColorPicker = function() return parent:CreateColorPicker(config, flag) end,
        Input       = function() return parent:CreateTextBox(config, flag) end,
        Dropdown    = function() return parent:CreateDropdown(config, flag) end,
        Label       = function() return parent:CreateParagraph(config) end,
        Paragraph   = function() return parent:CreateParagraph(config) end,
    }
    local creator = creators[element_type]
    if not creator then return g.notify("Error", "Unknown element type: " .. tostring(element_type), 1) end
    local ok, element = pcall(creator)
    if not ok then
        g.notify("Error", "Couldn't create " .. tostring(config and config.Name or element_type) .. ": " .. tostring(element), 5)
        return nil
    end
    if global_name then g[global_name] = element end
    return element
end
task.wait()
g.notify("Success", "Now loading UI elements...", 10)
print("[Flames] loading: menu pages")
local Home_Page = UI:CreatePage("Main")
local Home_Section = Home_Page:CreateSection("Main")
local LocalPlayer_Section = Home_Page:CreateSection("LocalPlayer")
local Avatar_Section = Home_Page:CreateSection("Avatar")
local Vehicle_Section = Home_Page:CreateSection("Vehicle")
local Players_Section = Home_Page:CreateSection("Players")
local priv_server_is_in = g.is_in_private_server()
local PrivServer_Section
if priv_server_is_in == true then
    PrivServer_Section = Home_Page:CreateSection("Private Server")
end
local Phone_Section = Home_Page:CreateSection("Phone")
local Houses_Section = Home_Page:CreateSection("Houses")
local Extras_Section = Home_Page:CreateSection("Extras")
local Credits_Section = Home_Page:CreateSection("Credits")
task.wait()
g.create_ui_element("Input", Home_Section, {
Name = "Command Bar",
PlaceholderText = "type a command, e.g. copy name (cmds for the list)",
Flag = "Command_Bar_Input_UI",
SavingDisabled = true,
ClearTextOnFocus = true,
Callback = function(text, enter_pressed)
    if not enter_pressed then return end
    g.lt_run_command(text)
end}, "Command_Bar_Input_UI")
g.create_ui_element("Toggle", Avatar_Section, {
Name = "Accessory Editor (FE)",
Default = false,
Flag = "Accessory_Editor_Toggle_UI",
SavingDisabled = true,
Callback = function(state)
    g.lt_editor_toggle(state)
end}, "Accessory_Editor_Toggle_UI")
g.create_ui_element("Button", Avatar_Section, {
Name = "Move Tool (Accessory Editor)",
Callback = function()
    if not g.lt_editor.enabled then g.lt_editor_toggle(true) end
    g.lt_editor_set_mode("Move")
end,})
g.create_ui_element("Button", Avatar_Section, {
Name = "Rotate Tool (Accessory Editor)",
Callback = function()
    if not g.lt_editor.enabled then g.lt_editor_toggle(true) end
    g.lt_editor_set_mode("Rotate")
end,})
g.create_ui_element("Button", Avatar_Section, {
Name = "Scale Tool (Accessory Editor)",
Callback = function()
    if not g.lt_editor.enabled then g.lt_editor_toggle(true) end
    g.lt_editor_set_mode("Scale")
end,})
g.create_ui_element("Toggle", Avatar_Section, {
Name = "Scale All Sides Together",
Default = false,
Flag = "Accessory_Editor_Uniform_Toggle_UI",
Callback = function(state)
    g.lt_editor.uniform = state
end}, "Accessory_Editor_Uniform_Toggle_UI")
g.create_ui_element("Slider", Avatar_Section, {
Name = "Move Snap (x0.01 studs, 0 = free)",
Min = 0,
Max = 50,
Default = 0,
Flag = "Accessory_Editor_Move_Snap_UI",
Callback = function(val)
    g.lt_editor.snap_move = val / 100
end}, "Accessory_Editor_Move_Snap_UI")
g.create_ui_element("Slider", Avatar_Section, {
Name = "Rotate Snap (degrees, 0 = free)",
Min = 0,
Max = 45,
Default = 0,
Flag = "Accessory_Editor_Rotate_Snap_UI",
Callback = function(val)
    g.lt_editor.snap_rotate = val
end}, "Accessory_Editor_Rotate_Snap_UI")
g.create_ui_element("Slider", Avatar_Section, {
Name = "Scale Snap (x0.01, 0 = free)",
Min = 0,
Max = 25,
Default = 0,
Flag = "Accessory_Editor_Scale_Snap_UI",
Callback = function(val)
    g.lt_editor.snap_scale = val / 100
end}, "Accessory_Editor_Scale_Snap_UI")
g.create_ui_element("Button", Avatar_Section, {
Name = "Reset Selected Accessories (FE)",
Callback = function()
    g.lt_reset_adjustments(false)
end,})
g.create_ui_element("Button", Avatar_Section, {
Name = "Reset All Accessories (FE)",
Callback = function()
    g.lt_reset_adjustments(true)
end,})
g.create_ui_element("Button", Avatar_Section, {
Name = "Skin Tone Picker (FE)",
Callback = function()
    g.lt_open_skin_picker()
end,})
g.create_ui_element("ColorPicker", Avatar_Section, {
Name = "Quick Skin Tone (FE)",
Default = Color3.fromRGB(224, 156, 107),
Flag = "Quick_Skin_Tone_Picker_UI",
SavingDisabled = true,
Callback = function(color)
    if os.clock() - (g.lt_last_skin_send or 0) < 0.35 then return end
    g.lt_set_skin(color, true)
end}, "Quick_Skin_Tone_Picker_UI")
g.create_ui_element("Button", Avatar_Section, {
Name = "Outfit Saver (previews + backups)",
Callback = function()
    g.lt_open_outfit_saver()
end,})
g.create_ui_element("Button", Avatar_Section, {
Name = "Catalog Browser (search creators, wear items)",
Callback = function()
    g.lt_open_catalog()
end,})
g.create_ui_element("Input", Avatar_Section, {
Name = "Wear Item by ID or Link (FE)",
PlaceholderText = "item id or catalog link...",
Flag = "Add_Accessory_Input_UI",
SavingDisabled = true,
ClearTextOnFocus = true,
Callback = function(text, enter_pressed)
    if not enter_pressed then return end
    task.spawn(g.lt_wear_by_id, text)
end}, "Add_Accessory_Input_UI")
g.create_ui_element("Toggle", Avatar_Section, {
Name = "No Accessory Limit (FE)",
Default = g.lt_no_item_limit ~= false,
Flag = "No_Accessory_Limit_Toggle_UI",
Callback = function(state)
    g.lt_no_item_limit = state
end}, "No_Accessory_Limit_Toggle_UI")
g.create_ui_element("Slider", Avatar_Section, {
Name = "Copy Outfit Speed (x0.05s per piece)",
Min = 1,
Max = 20,
Default = 4,
Flag = "Copy_Outfit_Step_Slider_UI",
Callback = function(val)
    g.lt_copy_step = val * 0.05
end}, "Copy_Outfit_Step_Slider_UI")
g.create_ui_element("Paragraph", Credits_Section, { Content = "Flames Hub | Life Together RP " .. tostring(g.Script_Version) })
g.create_ui_element("Paragraph", Credits_Section, { Content = "Made by: " .. tostring(g.Script_Creator or "Flames Hub") })
g.create_ui_element("Paragraph", Credits_Section, { Content = "Press X to hide or show this menu. Type cmds in the Command Bar for every command." })
g.create_ui_element("Button", Home_Section, {
Name = "Join the Flames Hub Discord server.",
Callback = function()
    local http_requesting_func = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
    local opened = false
    if http_requesting_func and typeof(http_requesting_func) == "function" then
        local success = pcall(function()
            http_requesting_func({
                Url = 'http://127.0.0.1:6463/rpc?v=1',
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json',
                    Origin = 'https://discord.com'
                },
                Body = HttpService:JSONEncode({
                    cmd = 'INVITE_BROWSER',
                    nonce = HttpService:GenerateGUID(false),
                    args = {code = 'Xhvm6eu6tx'}
                })
            })
        end)
        opened = success
    end
    wait(0.25)
    if not opened then
        if g.AllClipboards then g.AllClipboards("https://discord.gg/Xhvm6eu6tx") end
        if g.notify then g.notify("Success", "Successfully copied Discord server link to your Clipboard.", 5) end
    end
end,})
g.create_ui_element("Toggle", Home_Section, {
Name = "Survey Spam (FE)",
Default = g.Spam_And_Spoof_Survey_Submissions or false,
Flag = "Survey_Spammer_Toggle_UI",
Callback = function(state)
    g.Spam_Survey_Completions(state)
end}, "Survey_Spammer_Toggle_UI")
g.create_ui_element("Toggle", Home_Section, {
Name = "Hide DAISE Area",
Default = g.DAISE_Area_Hidden or false,
Flag = "Hide_DAISE_Area_Toggle_UI",
Callback = function(state)
    g.Hide_DAISE_Area(state)
end}, "Hide_DAISE_Area_Toggle_UI")
g.create_ui_element("Toggle", Home_Section, {
Name = "Anti Tent Spawn",
Default = g.Anti_Tent_Spawning_Currently_Active or false,
Flag = "Anti_Tent_Spawning_Toggled_UI",
Callback = function(state)
    g.Anti_Tent_Spawning(state)
end}, "Anti_Tent_Spawning_Toggled_UI")
g.create_ui_element("Toggle", Players_Section, {
Name = "Anti Invisible Players",
Default = g.Anti_Invisible_Players_Currently_Active or false,
Flag = "No_Player_Invisible_Toggle_UI",
Callback = function(state)
    g.Anti_Invisible_Players(state)
end}, "No_Player_Invisible_Toggle_UI")
g.create_ui_element("Button", Home_Section, {
Name = "Open Mini-Games GUI (Fun)",
Callback = function()
    g.open_minigame_menu()
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Animator (FE)",
Callback = function()
    if g.lt_carry_open then g.lt_carry_open() end
end,})
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Open Animator When Carrying",
Default = g.lt_carry_auto_menu ~= false,
Flag = "Carry_Pose_Auto_Menu_Toggle_UI",
Callback = function(state)
    g.lt_carry_auto_menu = state
end}, "Carry_Pose_Auto_Menu_Toggle_UI")
print("[Flames] loading: kill script")
g.lt_kill_script = function()
    pcall(function() if g.lt_editor_toggle then g.lt_editor_toggle(false) end end)
    pcall(function() if g.lt_carry_stop then g.lt_carry_stop() end end)
    for _, key in ipairs({ "lt_skin_gui", "lt_editor_gui", "lt_outfits_gui", "lt_catalog_gui" }) do
        pcall(function() if g[key] then g[key]:Destroy() end end)
        g[key] = nil
    end
    g.lt_skin_open, g.lt_outfits_open, g.lt_catalog_open = false, false, false
    pcall(function()
        local Net = g.lt_require and g.lt_require("Net")
        if Net and g.lt_net_get_original then Net.get = g.lt_net_get_original end
        g.lt_net_get_original = nil
    end)
    for _, key in ipairs({ "lt_hide_key_conn", "lt_watch_char_conn", "Copy_Outfit_Chat_Command_Conn", "Message_Received_Conn_Owner_Commands_Setup", "Administrator_Staff_Message_Received_Commands_Section", "lt_size_respawn_conn", "lt_rp_name_conn" }) do
        pcall(function() if g[key] then g[key]:Disconnect() end end)
        g[key] = nil
    end
    pcall(function() if g.lt_editor and g.lt_editor.watch_conn then g.lt_editor.watch_conn:Disconnect() end end)
    pcall(function() if g.FlamesLibrary and g.FlamesLibrary.disconnect_all then g.FlamesLibrary.disconnect_all() end end)
    pcall(function() if g.CreditsLabelGui then g.CreditsLabelGui:Destroy() end end)
    pcall(function() UI:Destroy() end)
    pcall(function() Atlas:Destroy() end)
    g.lta_updater_running = false
    g.LifeTogetherRP_Admin = false
    g.LifeTogether_Actual_Flames_Hub_Running_Functioning_Currently_On_Client = false
    g.Script_Loaded_Correctly_LifeTogether_Admin_Flames_Hub = nil
    g.notify("Success", "Script stopped. Run it again whenever you want, no rejoin needed.", 6)
end
if g.lt_commands then g.lt_commands.kill = function() g.lt_kill_script() end end
if g.lt_command_help then table.insert(g.lt_command_help, "kill (stop the script to run it again)") end
g.create_ui_element("Button", Home_Section, {
Name = "Kill Script (run it again without rejoining)",
Callback = function()
    g.lt_kill_script()
end,})
g.create_ui_element("Toggle", Home_Section, {
Name = "Anti Hashtags (FE) BETA!",
Default = (FlamesLibrary.modules and FlamesLibrary.modules.chat_filter_override.enabled) or false,
Flag = "Anti_Hashtags_Toggle_UI",
Callback = function(state)
    if FlamesLibrary.modules then FlamesLibrary.modules.chat_filter_override:toggle(state) end
end}, "Anti_Hashtags_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Job Spammer (FE)",
Default = g.Every_Job or false,
Flag = "Job_Spammer_Toggled_UI",
Callback = function(state)
    g.job_spammer(state)
end}, "Job_Spammer_Toggled_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Anti Clothing Ban (FE)",
Default = false,
Flag = "Anti_Clothes_Ban_Roblox_Bypass_Toggle_UI",
Callback = function(state)
    g.toggle_anti_clothing_ban_system(state)
end}, "Anti_Clothes_Ban_Roblox_Bypass_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Glitch Outfit (FE)",
Default = g.Glitching_Outfit or false,
Flag = "Glitch_Outfit_Toggle_UI",
Callback = function(state)
    g.glitch_outfit(state)
end}, "Glitch_Outfit_Toggle_UI")
g.create_ui_element("Slider", LocalPlayer_Section, {
Name = "Side To Side Speed",
Min = 1,
Max = 100,
Default = g.SideGlitch_Speed or 25,
Flag = "Side_To_Side_Speed_Slider_UI",
Callback = function(val)
    g.SideGlitch_Speed = val
end}, "Side_To_Side_Speed_Slider_UI")
g.create_ui_element("Slider", LocalPlayer_Section, {
Name = "Side To Side Distance",
Min = 1,
Max = 25,
Default = g.SideGlitch_Distance or 5,
Flag = "Side_To_Side_Distance_Slider_UI",
Callback = function(val)
    g.SideGlitch_Distance = val
end}, "Side_To_Side_Distance_Slider_UI")
g.create_ui_element("Slider", LocalPlayer_Section, {
Name = "Side To Side Smoothness",
Min = 0.1,
Max = 1,
Default = g.SideGlitch_Smooth or 5,
Flag = "Side_To_Side_Smoothness_UI_Slider",
Callback = function(val)
    g.SideGlitch_Smooth = val
end}, "Side_To_Side_Smoothness_UI_Slider")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Side To Side Glitch (FE)",
Default = g.SideGlitch_Enabled or false,
Flag = "Side_To_Side_Glitch_Not_Smooth_Toggle_UI",
Callback = function(state)
    if state then
        g.start_glitch_script()
    else
        g.stop_glitch_script()
    end
end}, "Side_To_Side_Glitch_Not_Smooth_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Smooth Side To Side Glitch (FE)",
Default = g.SideGlitch_Enabled or false,
Flag = "Side_To_Side_Glitch_Smooth_Toggle_UI",
Callback = function(state)
    if state then
        g.start_smooth_glitch_script()
    else
        g.stop_glitch_script()
    end
end}, "Side_To_Side_Glitch_Smooth_Toggle_UI")
g.create_ui_element("Button", Vehicle_Section, {
Name = "Despawn Vehicle (FE)",
Callback = function()
    local Current_Car = g.get_vehicle()
    if not Current_Car or not Current_Car:IsA("Model") then g.notify("Error", "You do not have a vehicle spawned!", 3); return end
    if Current_Car then
        g.notify("Success", "Despawned Vehicle: " .. tostring(Current_Car), 5)
        g.spawn_any_vehicle(tostring(Current_Car.Name))
    end
end,})
g.create_ui_element("Toggle", Vehicle_Section, {
Name = "Rainbow Vehicle (FE)",
Default = g.Rainbow_Vehicle or false,
Flag = "Rainbow_Vehicle_Toggle_UI",
Callback = function(state)
    g.RGB_Vehicle(state)
end}, "Rainbow_Vehicle_Toggle_UI")
g.create_ui_element("Toggle", Vehicle_Section, {
Name = "Two Tone Vehicle (FE)",
Default = g.two_tone_vehicle_colors_changing or false,
Flag = "Two_Tone_Car_Toggle_UI",
Callback = function(state)
    g.two_color_switcher_FE_func(state)
end}, "Two_Tone_Car_Toggle_UI")
g.create_ui_element("Toggle", Phone_Section, {
Name = "Rainbow Phone (FE)",
Default = g.RGB_Rainbow_Phone or false,
Flag = "Rainbow_Phone_Toggle_UI",
Callback = function(state)
    g.RGB_Phone(state)
end}, "Rainbow_Phone_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Free Premium (FE)",
Default = g.Has_Free_LifePremium or false,
Flag = "Free_Premium_Toggle_UI",
Callback = function(state)
    g.FreePayFuncToggle(state)
end}, "Free_Premium_Toggle_UI")
g.create_ui_element("Input", Vehicle_Section, {
Name = "Spawn Vehicle (FE, Any)",
PlaceholderText = "Enter vehicle name...",
Flag = "Spawn_Vehicle_Input_UI",
Callback = function(split)
    local input = split:lower():gsub("%s+", "")
    local matched = false
    if input:find("broom") or input:find("broomstick") then
        g.spawn_any_vehicle("Magic Carpet")
        g.notify("Success", "Spawning requested vehicle: Broomstick.", 3)
        return
    elseif input:find("magiccarpet") or input:find("carpet") then
        g.spawn_any_vehicle("Magic Carpett")
        g.notify("Success", "Spawning requested vehicle: Magic Carpet.", 3)
        return
    end
    for car_key, full_name in pairs(CarMap) do
        local cleanKey = car_key:lower():gsub("%s+", "")
        if cleanKey:find(input, 1, true) then
            g.spawn_any_vehicle(full_name)
            g.notify("Success", "Spawning requested vehicle: " .. tostring(full_name), 3)
            matched = true
            break
        end
    end
    if not matched then g.notify("Error", tostring(input) .. " did not match any existing Vehicles.", 15) end
end}, "Spawn_Vehicle_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Teleport To Player",
PlaceholderText = "user or display...",
Flag = "Teleport_Player_Input_UI",
Callback = function(text)
    local Target = g.findplr(text)
    if not Target then g.notify("Error", "That is not a valid Player.", 3); return end
    local Target_Char = Target.Character or g.get_char(Target, 3)
    if not Target_Char then g.notify("Error", "Target character is not loaded.", 3); return end
    local Char = g.Character or g.LocalPlayer.Character or g.get_char(LocalPlayer, 3)
    if not Char then g.notify("Error", "Your Character does not exist.", 5); return end
    local Hum = g.Humanoid or Char:FindFirstChildOfClass("Humanoid") or g.get_human(LocalPlayer, 10)
    if not (Char and Hum) then g.notify("Error", "Your character is not loaded yet!", 3); return end
    if Hum.Sit then
        pcall(function() Hum:ChangeState(3) end)
        task.wait(0.2)
    end
    local Ok, Pivot = pcall(function() return Target_Char:GetPivot() end)
    if not Ok or not Pivot then g.notify("Error", "Failed to get target position.", 3); return end
    if Char and Char:FindFirstChildOfClass("Humanoid") then Char:PivotTo(Pivot * CFrame.new(0, 5, 0)) end
    g.notify("Success", "Teleported to "..Target.Name, 3)
end}, "Teleport_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "View Player",
PlaceholderText = "Username or displayname...",
Flag = "View_Player_Input_UI",
Callback = function(split)
    local View_Target = g.findplr(split)
    if not View_Target then g.notify("Error", "Target was not found or does not exist!", 5); return end
    if g.Viewing_A_Player then g.notify("Error", "You're already viewing someone, unview them first.", 5); return end
    local target_char = View_Target.Character or g.get_char(View_Target, 5)
    if not target_char then g.notify("Error", "Target character not loaded!", 5); return end
    local target_human = target_char:FindFirstChildOfClass("Humanoid") or g.get_human(View_Target, 5)
    if not target_human then g.notify("Error", "Target humanoid not found!", 5); return end
    g.Viewing_A_Player = true
    workspace.CurrentCamera.CameraSubject = target_human or target_char or g.Character
end}, "View_Player_Input_UI")
g.create_ui_element("Button", Players_Section, {
Name = "Unview Player",
Callback = function()
    if not g.Viewing_A_Player then g.notify("Error", "You're not viewing anyone.", 3); return end
    g.Viewing_A_Player = false
    workspace.CurrentCamera.CameraSubject = g.Humanoid or g.Character or g.LocalPlayer.Character or g.get_char(LocalPlayer, 10)
end})
g.main_vehicle_fly_UI_toggle = g.create_ui_element("Toggle", Vehicle_Section, {
Name = "Vehicle Fly (FE)",
Default = g.vehicle_fly or false,
Flag = "Vehicle_Fly_Toggle_UI",
Callback = function(state)
    g.toggle_vehicle_fly(state)
end}, "Vehicle_Fly_Toggle_UI")
g.create_ui_element("Slider", Vehicle_Section, {
Name = "Vehicle Fly Speed",
Min = 1,
Max = 100,
Default = g.vehicle_fly_speed or 5,
Flag = "Vehicle_Fly_Speed",
Callback = function(val)
    if g.vehicle_fly then g.vehicle_fly_speed = val end
end}, "Vehicle_Fly_Speed")
g.create_ui_element("Toggle", Vehicle_Section, {
Name = "Anti Car Fling (FE)",
Default = g.VehicleDestroyer_Enabled or false,
Flag = "Anti_Car_Fling_Toggle_UI",
Callback = function(state)
    g.anti_car_fling(state)
end}, "Anti_Car_Fling_Toggle_UI")
g.create_ui_element("Toggle", Vehicle_Section, {
Name = "Auto Lock Car (FE)",
Default = g.AutoLockOn or false,
Flag = "Auto_Lock_Car_Toggle_UI",
Callback = function(state)
    if g.ToggleAutoLock then g.ToggleAutoLock(state) end
end}, "Auto_Lock_Car_Toggle_UI")
g.create_ui_element("Button", Vehicle_Section, {
Name = "Lock Car (FE)",
Callback = function()
    local Current_Car = g.get_vehicle()
    if not Current_Car then g.notify("Error", "You do not have a vehicle spawned!", 5); return end
    if Current_Car:GetAttribute("locked") == true then g.notify("Error", "Your Vehicle is already locked.", 5); return end
    g.lock_vehicle(g.get_vehicle())
    g.notify("Success", "Locked vehicle: " .. tostring(Current_Car), 5)
end,})
g.create_ui_element("Button", Vehicle_Section, {
Name = "Unlock Car (FE)",
Callback = function()
    local Current_Car = g.get_vehicle()
    if not Current_Car then g.notify("Error", "You do not have a vehicle spawned!", 5); return end
    if Current_Car:GetAttribute("locked") ~= true then g.notify("Error", "Your vehicle is already unlocked!", 5); return end
    g.lock_vehicle(g.get_vehicle())
    g.notify("Success", "Unlocked vehicle: " .. tostring(Current_Car), 5)
end,})
g.create_ui_element("Toggle", Vehicle_Section, {
Name = "Trailer (FE)",
Default = g.trailer_enabled or false,
Flag = "Trailer_Toggle_UI",
Callback = function(state)
    local Vehicle = g.get_vehicle()
    if not Vehicle then g.notify("Error", "You do not have a Vehicle spawned, spawn one and try again!", 7); return  end
    if state then
        g.notify("Success", "Added WaterSkies to Vehicle: " .. tostring(Vehicle), 5)
    else
        g.notify("Success", "Removed WaterSkies trailer from: " .. tostring(Vehicle), 5)
    end
    g.water_skie_trailer(state, g.get_vehicle())
end}, "Trailer_Toggle_UI")
g.create_ui_element("Toggle", Vehicle_Section, {
Name = "View Car (FE)",
Default = g.viewing_car or false,
Flag = "View_Car_Toggle_UI",
Callback = function(state)
    if state then
        local Camera = g.Camera or workspace.CurrentCamera
        local Vehicle = g.get_vehicle()
        if not Vehicle then g.notify("Error", "You don't have a Vehicle spawned, spawn one and try again!", 7); return end
        local fallback = g.Humanoid or g.Character or g.get_human(g.LocalPlayer, Players.RespawnTime + 0.5) or g.get_char(g.LocalPlayer, Players.RespawnTime + 0.75)
        if not fallback then g.notify("Error", "No fallback camera subject found.", 5); return end
        if g.CamWatcherConn then
            g.CamWatcherConn:Disconnect()
            g.CamWatcherConn = nil
        end
        local function find_vehicle_part(v)
            return v:FindFirstChildWhichIsA("VehicleSeat", true)
                or v:FindFirstChildWhichIsA("Seat", true)
                or v:FindFirstChildWhichIsA("BasePart", true)
        end
        local target = find_vehicle_part(Vehicle)
        if not target then g.notify("Error", "Could not find a valid vehicle part.", 5); return end
        Camera.CameraSubject = target
        g.viewing_car = true
        g.notify("Info", "Now viewing Vehicle.", 5)
        g.CamWatcherConn = target.AncestryChanged:Connect(function()
            if not target:IsDescendantOf(workspace) then
                Camera.CameraSubject = fallback
                if g.CamWatcherConn then
                    g.CamWatcherConn:Disconnect()
                    g.CamWatcherConn = nil
                end
                g.viewing_car = false
                g.notify("Info", "Vehicle lost, camera reset.", 5)
            end
        end)
    else
        local Camera = g.Camera or workspace.CurrentCamera
        local function fallbackto()
            return g.Humanoid or g.Character or g.LocalPlayer.Character
        end
        if g.CamWatcherConn then
            g.CamWatcherConn:Disconnect()
            g.CamWatcherConn = nil
        end
        local fb = fallbackto()
        if fb then
            Camera.CameraSubject = fb
            g.notify("Info", "Camera now set back to your character.", 5)
        end
        g.viewing_car = false
    end
end}, "View_Car_Toggle_UI")
g.create_ui_element("Button", Vehicle_Section, {
Name = "Bring Vehicle To Me (FE)",
Callback = function()
    local Util = g.Util or g.safe_require(g.ReplicatedStorage:FindFirstChild("Util", true))
    if not Util then g.notify("Error", "ModuleScript: 'Util' does not seem to exist.", 5); return end
    local function get_hrp()
        if g.HumanoidRootPart then return g.HumanoidRootPart end
        return g.Char.get_hrp()
    end
    local hrp = get_hrp()
    if not hrp then g.notify("Error", "Could not find HumanoidRootPart!", 3); return end
    local myVehicle = nil
    for _, v in ipairs(workspace:WaitForChild("Vehicles"):GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("owner") and v.owner.Value == Players.LocalPlayer then
            if v:FindFirstChild("VehicleSeat") then
                myVehicle = v
                break
            end
        end
    end
    if not myVehicle then g.notify("Error", "No owned vehicle found!", 3); return end
    local seat = myVehicle:FindFirstChild("VehicleSeat", true)
    local savedCF = hrp.CFrame
    if seat and g.Humanoid then
        g.Character:PivotTo(seat.CFrame)
        fw(0.2)
        seat:Sit(g.Humanoid)
    end
    fw(0.1)
    local targetCF = savedCF * CFrame.new(0, 10, 0)
    local tween = Util.tween_model(myVehicle, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), targetCF)
    if tween then tween.Completed:Wait() end
    g.notify("Success", "Brought your Vehicle to you!", 5)
end,})
g.create_ui_element("Button", Vehicle_Section, {
Name = "Go To Vehicle (FE)",
Callback = function()
    local Vehicle = g.get_vehicle()
    if not Vehicle then g.notify("Error", "You do not have a vehicle spawned, spawn one and try again!", 5); return end
    if g.Character and g.Character:FindFirstChild("HumanoidRootPart") then
        g.Character:PivotTo(g.get_vehicle():GetPivot() * CFrame.new(0, 5, 0))
    end
end,})
g.create_ui_element("Input", Vehicle_Section, {
Name = "Teleport Car To Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "TP_Car_To_Player_Input_UI",
Callback = function(split)
    local Vehicle = g.get_vehicle()
    if not Vehicle then g.notify("Error", "You do not have a vehicle spawned, spawn one and try again!", 5); return end
    local Goto_Player = g.findplr(split)
    if not Goto_Player then g.notify("Error", "Target player not found / does not exist / or has left the game.", 6); return end
    local Old_CFrame_TP_Car = g.Character:FindFirstChild("HumanoidRootPart").CFrame
    if Goto_Player and Goto_Player.Character and Goto_Player.Character:FindFirstChildWhichIsA("Humanoid") then
        local Target_Char = Goto_Player.Character or g.get_char(Goto_Player)
        if not Target_Char then return end
        local Target_CFrame = Target_Char and Target_Char:GetPivot() * CFrame.new(0, 5, 0)
        local myVehicle = nil
        for _, v in ipairs(g.Workspace.Vehicles:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChild("owner") and v.owner.Value == g.LocalPlayer then
                if v:FindFirstChild("VehicleSeat") then
                    myVehicle = v
                    break
                end
            end
        end
        if not myVehicle then g.notify("Error", "No owned vehicle found.", 5); return end
        local seat = myVehicle:FindFirstChild("VehicleSeat")
        if seat and g.Humanoid then
            g.Character:PivotTo(seat.CFrame)
            fw(0.2)
            seat:Sit(g.Humanoid)
        end
        fw(0.1)
        myVehicle:PivotTo(Target_CFrame)
        fw(0.3)
        if g.Humanoid.Sit then
            g.Humanoid:ChangeState(3)
            fw(0.2)
            g.HumanoidRootPart.CFrame = Old_CFrame_TP_Car
        else
            g.HumanoidRootPart.CFrame = Old_CFrame_TP_Car
        end
        g.notify("Success", "Teleported vehicle to target player: " .. tostring(Goto_Player), 5)
    end
end}, "TP_Car_To_Player_Input_UI")
g.create_ui_element("Input", Vehicle_Section, {
Name = "Steal Car (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Steal_Car_Input_UI",
Callback = function(split)
    local take_vehicle_target_plr = g.findplr(split)
    if not take_vehicle_target_plr then g.notify("Error", "That Player does not exist, or has left the game.", 7); return end
    local plrs_spawned_vehicle = g.get_other_vehicle(take_vehicle_target_plr)
    if not plrs_spawned_vehicle then g.notify("Error", "That Player does not have a Vehicle spawned.", 6); return end
    if g.Character and g.Character.Parent and g.Character:FindFirstChild("HumanoidRootPart") then
        g.Character:PivotTo(plrs_spawned_vehicle:GetPivot() + Vector3.new(0, 3, 0))
    end
    fw(0.2)
    g.steal_car_functionality(take_vehicle_target_plr)
end}, "Steal_Car_Input_UI")
g.create_ui_element("Toggle", Vehicle_Section, {
Name = "Vehicle ESP",
Default = g.vehicle_esp_enabled or false,
Flag = "Vehicle_ESP_Toggle_UI",
Callback = function(state)
    g.vehicle_esp_toggle(state)
end}, "Vehicle_ESP_Toggle_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Orbit Player (FE)",
PlaceholderText = "User or Display...",
Flag = "Orbit_Player_Input_UI",
Callback = function(split)
    local Target = g.findplr(split)
    if not Target then g.notify("Error", "Target doesn't exist or has left the game.", 5); return end
    if g.Is_Orbiting then g.notify("Warning", "You're already orbiting somebody.", 5); return end
    local speed = g.Orbit_Speed_Value or 1
    local distance = g.Orbit_Distance_Value or 5
    g.start_orbit_plr(Target, speed, distance)
end}, "Orbit_Player_Input_UI")
g.create_ui_element("Slider", Players_Section, {
Name = "Orbit Speed",
Min = 1,
Max = 75,
Default = g.Orbit_Speed_Value or 1,
Flag = "Orbit_Speed_Slider_UI",
Callback = function(val)
    g.Orbit_Speed_Value = val
    if g.Is_Orbiting then
        g.set_orbit_speed(val)
    end
end}, "Orbit_Speed_Slider_UI")
g.create_ui_element("Slider", Players_Section, {
Name = "Orbit Distance",
Min = 1,
Max = 75,
Default = g.Orbit_Distance_Value or 5,
Flag = "Orbit_Distance_Slider_UI",
Callback = function(val)
    g.Orbit_Distance_Value = val
end}, "Orbit_Distance_Slider_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Annoy Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Annoy_Player_Input_UI",
Callback = function(split)
    local Target = g.findplr(split)
    if not Target then g.notify("Error", "That Player does not exist or has left the game.", 7); return end
    if Target.Name == "CIippedByAura" or Target.Name == "L0CKED_1N1" then return end
    if g.Currently_Running_Annoy_Loop then
        if g.Currently_Annoying_Player then
            g.notify("Error", "You are already annoying: " .. tostring(g.Currently_Annoying_Player) .. "!", 5)
            return
        else
            g.notify("Error", "You are already annoying a Player!", 5)
            return
        end
    end
    local target_userid = Target.UserId
    local rejoin_limit = 60
    g.Currently_Annoying_Player = Target.Name
    g.annoy_active = true
    g.notify("Success", "Now annoying Player: " .. Target.Name, 7)
    local Annoy_Thread = task.spawn(function()
        while g.annoy_active == true do
            fw(0)
            local success = pcall(function()
                if not Target or not Target.Parent or not Target.Character then
                    local elapsed_time = 0
                    g.notify("Warning", "Target left, waiting 60 seconds for them to rejoin...", 12)
                    while elapsed_time < rejoin_limit and g.annoy_active == true do
                        local found_player = false
                        for _, plr in ipairs(g.Players:GetPlayers()) do
                            if plr.UserId == target_userid then
                                Target = plr
                                g.notify("Success", "Target rejoined, resuming annoyance loop!", 6)
                                found_player = true
                                break
                            end
                        end
                        if found_player then break end
                        fw(1)
                        elapsed_time += 1
                    end
                    if elapsed_time >= rejoin_limit then
                        g.annoy_active = false
                        g.Currently_Annoying_Player = nil
                        g.Currently_Running_Annoy_Loop = nil
                        g.notify("Warning", "Target did not rejoin within 60 seconds, loop disabled.", 10)
                        return
                    end
                end
                g.Send("request_carry", Target)
                fw(0)
                g.Send("request_call", Target)
                fw(0)
                g.Send("end_call", Target)
            end)
            if not success then
                g.annoy_active = false
                g.Currently_Annoying_Player = nil
                g.Currently_Running_Annoy_Loop = nil
            end
        end
        g.Currently_Annoying_Player = nil
        g.Currently_Running_Annoy_Loop = nil
    end)
    g.Currently_Running_Annoy_Loop = Annoy_Thread
end}, "Annoy_Player_Input_UI")
g.create_ui_element("Button", Players_Section, {
Name = "UnAnnoy Player",
Callback = function()
    if not g.annoy_active then g.notify("Warning", "Annoy Player is not running.", 5); return end
    g.annoy_active = false
    if g.Currently_Annoying_Player then g.Currently_Annoying_Player = nil end
    if g.Currently_Running_Annoy_Loop then g.Currently_Running_Annoy_Loop = nil end
    g.notify("Success", "Annoy loop disabled.", 5)
end,})
g.create_ui_element("Input", Players_Section, {
Name = "Loop Fling Player",
PlaceholderText = "Username or displayname...",
Flag = "Loop_Fling_Input_UI",
Callback = function(split)
    local loop_fling_victim = g.findplr(split)
    if not loop_fling_victim then g.notify("Error", "That Player does not exist!", 3); return end
    if loop_fling_victim and loop_fling_victim.Character then
        g.start_loopfling(loop_fling_victim)
    end
end}, "Loop_Fling_Input_UI")
g.create_ui_element("Button", Players_Section, {
Name = "UnLoopfling Player",
Callback = function()
    g.stop_loopfling()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Tools Menu (Pistol + Laser) (FE)",
Callback = function()
    g.tools_menu_for_life_together_flames_hub()
end,})
g.create_ui_element("Input", Players_Section, {
Name = "Bring Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Bring_Player_Input_UI",
Callback = function(split)
    local target = g.findplr(split)
    if not target then g.notify("Error", "Target not found.", 5); return end
    if g.Not_Ever_Sitting then g.notify("Error", "Anti-Sit is enabled, turn it off first!", 5); return end
    local function wait_for_bus(timeout)
        local t = 0
        while t < timeout do
            for _, v in ipairs(g.Workspace.Vehicles:GetChildren()) do
                if v:IsA("Model") and v.Name == "SchoolBus" and v:FindFirstChild("owner") and v.owner.Value == g.LocalPlayer then
                    return v
                end
            end
            fw(0.2)
            t = t + 0.2
        end
        return nil
    end
    local Vehicle = g.get_vehicle()
    if not Vehicle or Vehicle.Name ~= "SchoolBus" then
        g.spawn_any_vehicle("SchoolBus")
        fw(0.5)
        Vehicle = wait_for_bus(5)
    end
    if Vehicle and Vehicle.Name == "SchoolBus" then
        g.vehicle_bring_player(target)
        g.notify("Success", "Bringing player: " .. target.Name, 3)
    else
        g.notify("Error", "Failed to spawn/find SchoolBus.", 3)
    end
end}, "Bring_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Kill Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Kill_Player_Input_UI",
Callback = function(split)
    local target = g.findplr(split)
    if not target then g.notify("Error", "Target not found.", 5); return end
    if g.Not_Ever_Sitting then g.notify("Error", "Anti-Sit is enabled, turn it off first!", 5); return end
    local function wait_for_bus(timeout)
        local t = 0
        while t < timeout do
            for _, v in ipairs(g.Workspace.Vehicles:GetChildren()) do
                if v:IsA("Model") and v.Name == "SchoolBus" and v:FindFirstChild("owner") and v.owner.Value == g.LocalPlayer then
                    return v
                end
            end
            fw(0.2)
            t = t + 0.2
        end
        return nil
    end
    local Vehicle = g.get_vehicle()
    if not Vehicle or Vehicle.Name ~= "SchoolBus" then
        g.spawn_any_vehicle("SchoolBus")
        fw(0.5)
        Vehicle = wait_for_bus(5)
    end
    if Vehicle and Vehicle.Name == "SchoolBus" then
        g.vehicle_kill_player(target)
        g.notify("Success", "Killing player: "..tostring(target.Name), 3)
    else
        g.notify("Error", "Failed to spawn/find SchoolBus.", 3)
    end
end}, "Kill_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Void Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Void_Player_Input_UI",
Callback = function(split)
    local target = g.findplr(split)
    if not target then g.notify("Error", "Target Player not found.", 5); return end
    if g.Not_Ever_Sitting then g.notify("Error", "Anti-Sit is enabled, turn it off first!", 5); return end
    local function wait_for_bus(timeout)
        local t = 0
        while t < timeout do
            for _, v in ipairs(g.Workspace.Vehicles:GetChildren()) do
                if v:IsA("Model") and v.Name == "SchoolBus" and v:FindFirstChild("owner") and v.owner.Value == g.LocalPlayer then
                    return v
                end
            end
            fw(0.2)
            t = t + 0.2
        end
        return nil
    end
    local Vehicle = g.get_vehicle()
    if not Vehicle or Vehicle.Name ~= "SchoolBus" then
        g.spawn_any_vehicle("SchoolBus")
        fw(0.5)
        Vehicle = wait_for_bus(5)
    end
    if Vehicle and Vehicle.Name == "SchoolBus" then
        g.vehicle_void_player(target)
        g.notify("Success", "Sending player to the Void | player: " .. target.Name, 3)
    else
        g.notify("Error", "Failed to spawn/find SchoolBus.", 3)
    end
end}, "Void_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Skydive Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Skydive_Player_Input_UI",
Callback = function(split)
    local target = g.findplr(split)
    if not target then g.notify("Error", "Target not found.", 5); return end
    if g.Not_Ever_Sitting then g.notify("Error", "Anti-Sit is enabled, turn it off first!", 5); return end
    local function wait_for_bus(timeout)
        local t = 0
        while t < timeout do
            for _, v in ipairs(g.Workspace.Vehicles:GetChildren()) do
                if v:IsA("Model") and v.Name == "SchoolBus" and v:FindFirstChild("owner") and v.owner.Value == g.LocalPlayer then
                    return v
                end
            end
            fw(0.2)
            t = t + 0.2
        end
        return nil
    end
    local Vehicle = g.get_vehicle()
    if not Vehicle or Vehicle.Name ~= "SchoolBus" then
        g.spawn_any_vehicle("SchoolBus")
        fw(0.5)
        Vehicle = wait_for_bus(5)
    end
    if Vehicle and Vehicle.Name == "SchoolBus" then
        g.vehicle_skydive_player(target)
        g.notify("Success", "Skydiving player: " .. target.Name, 3)
    else
        g.notify("Error", "Failed to spawn/find SchoolBus.", 3)
    end
end}, "Skydive_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Copy Avatar (FE)",
Description = "Copies the target players entire avatar (FE).",
PlaceholderText = "Username or displayname...",
Flag = "Copy_Avatar_Input_UI",
Callback = function(split)
    local Target = g.findplr(split)
    if not Target then g.notify("Error", "That player doesn't exist in this game!", 5); return end
    if g.is_copying_avatar_already_flames then g.notify("Warning", "Copy avatar is already running!, wait a moment, until it's done.", 5); return end
    if Target.Name == "CIippedByAura" or Target.Name == "L0CKED_1N1" then g.notify("Error", "You can't copy this player's avatar!", 5); return end
    g.copy_plr_avatar(Target)
end}, "Copy_Avatar_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Copy Player Emote (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Copy_Emote_Input_UI",
Callback = function(split)
    local target_plr = g.findplr(split)
    if not target_plr then g.notify("Error", "Player not found or does not exist.", 5); return end
    g.copy_emote_plr(target_plr)
end}, "Copy_Emote_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Check Premium",
PlaceholderText = "Username or displayname...",
Flag = "Check_Premium_Input_UI",
Callback = function(split)
    local Player = g.findplr(split)
    if not Player then g.notify("Error", "Player doesn't exist or left the game.", 5); return end
    local Result = g.check_premium_player(Player)
    if Result == true then
        g.notify("Success", "[Result]: " .. tostring(Player.Name) .. " does have premium!", 6); return
    elseif Result == false then
        g.notify("Success", "[Result]: " .. tostring(Player.Name) .. " does not have premium.", 6); return
    else
        g.notify("Error", "Something unexpectedly happened while checking Player.", 5); return
    end
end}, "Check_Premium_Input_UI")
g.create_ui_element("Input", LocalPlayer_Section, {
Name = "WalkSpeed (FE)",
PlaceholderText = "Enter walkspeed...",
Flag = "Speed_Input_UI",
Callback = function(split)
    local New_Val = tonumber(split) or 16
    if not g.Humanoid then g.notify("Warning", "Wait until you respawn (or reset), we think you're dead, Humanoid is missing.", 10); return end
    if g.Humanoid.WalkSpeed == New_Val then g.notify("Warning", "Your WalkSpeed is already: " .. tostring(New_Val), 5); return end
    g.change_property("WalkSpeed", New_Val)
    g.notify("Success", "Updated WalkSpeed to: " .. tostring(New_Val), 5)
end}, "Speed_Input_UI")
g.create_ui_element("Input", LocalPlayer_Section, {
Name = "Jump Height (FE)",
PlaceholderText = "Enter jump height...",
Flag = "Jump_Height_Input_UI",
Callback = function(split)
    local New_ValJP = tonumber(split) or 7
    if not g.Humanoid then g.notify("Warning", "Wait until you respawn (or reset), we think you're dead, Humanoid is missing.", 10); return end
    if g.Humanoid.JumpPower == New_ValJP then g.notify("Warning", "Your JumpPower is already: " .. tostring(New_ValJP), 5); return end
    g.change_property("JumpHeight", New_ValJP)
    g.notify("Success", "Updated JumpHeight to: " .. tostring(New_ValJP), 5)
end}, "Jump_Height_Input_UI")
g.create_ui_element("Input", LocalPlayer_Section, {
Name = "Gravity (FE)",
PlaceholderText = "Enter gravity value...",
Flag = "Gravity_Input_UI",
Callback = function(split)
    local New_Grav = tonumber(split) or 196
    if g.Workspace.Gravity == New_Grav then g.notify("Warning", "Gravity is already: " .. tostring(New_Grav), 5); return end
    g.change_gravity_val(New_Grav)
    g.notify("Success", "Updated Gravity to: "..tostring(New_Grav), 5)
end}, "Gravity_Input_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Noclip (FE)",
Default = g.Noclip_Enabled or false,
Flag = "Noclip_Toggle_UI",
Callback = function(state)
    if state then
        if g.Noclip_Connection then g.notify("Warning", "Noclip connection is active, disable Noclip and try again.", 6); return end
        g.Toggleable_Noclip(true)
    else
        if not g.Noclip_Enabled then g.notify("Error", "Noclip is not enabled, enable it first.", 5); return end
        g.Toggleable_Noclip(false)
    end
end}, "Noclip_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Invisible (FE)",
Default = g.is_invisible_script_toggled or false,
Flag = "Invisible_Toggle_UI",
Callback = function(state)
    if state then
        if g.is_invisible_script_toggled then g.notify("Warning", "You're already Invisible.", 5); return end
        g.set_invisible(true)
    else
        if not g.is_invisible_script_toggled then g.notify("Warning", "You're not currently Invisible.", 5); return end
        g.set_invisible(false)
    end
end}, "Invisible_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Float (FE)",
Default = g.Float_Running_In_Flames_Hub or false,
Flag = "Float_Toggle_UI",
Callback = function(state)
    if state then
        g.start_flames_float()
    else
        g.stop_flames_float()
    end
end}, "Float_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Spin (FE)",
Default = g.already_spinning_localplr or false,
Flag = "Spin_Toggle_UI",
Callback = function(state)
    if state then
        local speed = g.Spin_Speed_Value or 5
        g.spin_plr(true, speed)
    else
        g.spin_plr(false)
    end
end}, "Spin_Toggle_UI")
g.create_ui_element("Slider", LocalPlayer_Section, {
Name = "Spin Speed",
Min = 1,
Max = 100,
Default = g.Spin_Speed_Value or 5,
Flag = "Spin_Speed_Slider_UI",
Callback = function(val)
    g.Spin_Speed_Value = val
    if g.already_spinning_localplr then g.change_spin_speed(val) end
end}, "Spin_Speed_Slider_UI")
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Cover Map With Your Avatar (FE)",
Callback = function()
    g.size_func_setter(85, 85)
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Reset Size (FE)",
Callback = function()
    g.lt_reset_body_size()
end,})
g.create_ui_element("Slider", LocalPlayer_Section, {
Name = "Size Step (% per press)",
Min = 1,
Max = 25,
Default = 2,
Flag = "Size_Step_Slider_UI",
Callback = function(val)
    g.lt_size_step = val / 100
end}, "Size_Step_Slider_UI")
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Height + (FE)",
Callback = function()
    g.lt_nudge_body_size("HeightScale", 1)
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Height - (FE)",
Callback = function()
    g.lt_nudge_body_size("HeightScale", -1)
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Width + (FE)",
Callback = function()
    g.lt_nudge_body_size("WidthScale", 1)
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Width - (FE)",
Callback = function()
    g.lt_nudge_body_size("WidthScale", -1)
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Normal Size (FE)",
Callback = function()
    if not g.reset_to_original_height or typeof(g.reset_to_original_height) ~= "function" then return end
    pcall(function() g.reset_to_original_height() end)
end}, "Normal_Size_Button_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Flash Name (FE)",
Default = g.Flashing_Name_Title or false,
Flag = "Flash_Name_Toggle_UI",
Callback = function(state)
    if state then
        if g.Flashing_Name_Title then g.notify("Error", "You're already running Flash Name!", 5); return end
        g.flashy_name(true)
        g.notify("Success", "Flash Name is now enabled.", 5)
    else
        if not g.Flashing_Name_Title then g.notify("Error", "You're not currently running Flash Name!", 5); return end
        g.flashy_name(false)
        g.notify("Success", "Flash Name is now disabled.", 5)
    end
end}, "Flash_Name_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Flash Invisible (FE)",
Default = g.Invisible_Flash or false,
Flag = "Flash_Invis_Toggle_UI",
Callback = function(state)
    if state then
        if g.LocalPlayer:GetAttribute("is_verified") == false then g.notify("Error", "You do not have LifePay premium for this (will not be FE without it).", 10); return end
        fw(0.2)
        local Is_Invis = g.InvisibleMode.enabled.get()
        g.Invisible_Flash = true
        if Is_Invis then g.InvisibleMode.enabled.set(false) end
        fw(0.1)
        FlamesLibrary.spawn("flames_flash_invis", "spawn", function()
            while g.Invisible_Flash == true do
                g.InvisibleMode.enabled.set(true)
                fw(0.05)
                g.InvisibleMode.enabled.set(false)
                fw(0.05)
            end
            g.InvisibleMode.enabled.set(false)
        end)
    else
        g.Invisible_Flash = false
        FlamesLibrary.disconnect("flames_flash_invis")
    end
end}, "Flash_Invis_Toggle_UI")
g.create_ui_element("Toggle", Extras_Section, {
Name = "Night Vision",
Default = g.NightVisionEnabled or false,
Flag = "Night_Vision_Toggle_UI",
Callback = function(state)
    g.night_vision(state)
end}, "Night_Vision_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Anti Fling",
Default = g.afEnabled or false,
Flag = "Anti_Fling_Toggle_UI",
Callback = function(state)
    if state then
        if g.afEnabled then g.notify("Warning", "Anti-Fling is already enabled!", 5); return end
        g.Toggle_AntiFling_Boolean_Func(true)
        g.ToggleNoclip(true)
        g.hasSeen_AntiFling_WarningPrompt = true
        g.notify("Success", "Successfully enabled Anti-Fling.", 9)
    else
        if not g.afEnabled then g.notify("Error", "Anti-Fling is not enabled.", 5); return end
        g.Toggle_AntiFling_Boolean_Func(false)
        g.ToggleNoclip(false)
    end
end}, "Anti_Fling_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Anti Void",
Default = g.Anti_Void_Enabled_Bool or false,
Flag = "Anti_Void_Toggle_UI",
Callback = function(state)
    g.anti_void(state)
end}, "Anti_Void_Toggle_UI")
g.create_ui_element("Button", Houses_Section, {
Name = "Delete House (FE)",
Callback = function()
    g.Delete_House()
end,})
g.create_ui_element("Toggle", Houses_Section, {
Name = "Anti House Ban (FE)",
Default = g.never_banned_houses or false,
Flag = "Anti_House_Ban_Toggle_UI",
Callback = function(state)
    if state then
        if g.never_banned_houses or g.AntiTeleport then g.notify("Error", "AntiHouseBan / AntiTeleport is already enabled.", 6); return end
        local lib = g.FlamesLibrary
        g.never_banned_houses = true
        g.AntiTeleport = true
        local LocalPlayer = g.LocalPlayer or Players.LocalPlayer
        local Character = g.Character or LocalPlayer.Character or g.get_char(LocalPlayer, 3)
        local HRP = g.HumanoidRootPart or Character and Character:FindFirstChild("HumanoidRootPart") or g.get_root(LocalPlayer, 3)
        local safe_cframe = HRP.CFrame
        local last_position = HRP.Position
        local latch_until = 0
        local function rebind()
            Character = g.Character or LocalPlayer.Character or g.get_char(LocalPlayer, 3)
            HRP = g.HumanoidRootPart or Character and Character:FindFirstChild("HumanoidRootPart") or g.get_root(LocalPlayer, 3)
            if not HRP then return end
            safe_cframe = HRP.CFrame
            last_position = HRP.Position
            latch_until = 0
        end
        lib.connect("AntiHouseBan_CharAdded", LocalPlayer.CharacterAdded:Connect(function()
            fw(0.1)
            rebind()
        end))
        lib.connect("AntiHouseBan_Heartbeat", RunService.Heartbeat:Connect(function()
            if not g.AntiTeleport then return end
            if not HRP or not HRP.Parent then return end
            local now = os.clock()
            local current_position = HRP.Position
            local delta = (current_position - last_position).Magnitude
            if delta > 12 then
                latch_until = now + 0.4
                HRP.CFrame = safe_cframe
                last_position = safe_cframe.Position
            elseif latch_until > now then
                HRP.CFrame = safe_cframe
                last_position = safe_cframe.Position
            else
                safe_cframe = HRP.CFrame
                last_position = HRP.Position
            end
        end))
        if g.PlotAreas then
            lib.spawn("AntiHouseBan_PlotLoop", "spawn", function()
                while g.never_banned_houses == true do
                    fw()
                    for _, v in ipairs(g.PlotAreas) do
                        if v then v.CanCollide = false end
                    end
                end
            end)
        else
            lib.disconnect("AntiHouseBan_CharAdded")
            lib.disconnect("AntiHouseBan_Heartbeat")
            g.never_banned_houses = false
            g.AntiTeleport = false
            g.notify("Error", "PlotAreas missing or patched.", 10); return
        end
        g.notify("Success", "Flames Hub | Anti-House-Ban V2 is now enabled.", 7)
    else
        if not g.never_banned_houses and not g.AntiTeleport then g.notify("Warning", "AntiHouseBan is not enabled.", 5); return end
        local lib = g.FlamesLibrary
        lib.disconnect("AntiHouseBan_CharAdded")
        lib.disconnect("AntiHouseBan_Heartbeat")
        lib.disconnect("AntiHouseBan_PlotLoop")
        g.never_banned_houses = false
        g.AntiTeleport = false
        g.notify("Success", "Flames Hub | Anti-House-Ban V2 is now disabled.", 7)
    end
end}, "Anti_House_Ban_Toggle_UI")
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Set SpawnPoint",
Callback = function()
    g.set_spawnpoint(0.1)
end}, "Set_Spawnpoint_Button_UI")
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Clear SpawnPoint",
Callback = function()
    g.clear_spawnpoint()
end}, "Clear_Spawnpoint_Button_UI")
g.create_ui_element("Button", Extras_Section, {
Name = "Rejoin",
Callback = function()
    local PlaceID = game.PlaceId
    local JobID = game.JobId
    local function safe_teleport()
        local success, err = pcall(function()
            if #g.Players:GetPlayers() <= 1 then
                g.notify("Success", "You are now going to rejoin into a different server (this server is empty).", 10)
                wait(0.25)
                g.TeleportService:Teleport(PlaceID, g.LocalPlayer)
            else
                g.notify("Success", "You are now being rejoined.", 5)
                wait(0.25)
                g.TeleportService:TeleportToPlaceInstance(PlaceID, JobID, g.LocalPlayer)
            end
        end)
        if not success then
            g.notify("Error", "Teleporting failed: " .. tostring(err) .. " | going to re-try.", 15)
            fw(3)
            safe_teleport()
        end
    end
    safe_teleport()
end}, "Rejoin_Button_UI")
g.create_ui_element("Button", Extras_Section, {
Name = "YouTube Music Player (MIGHT CRASH/FREEZE YOU!)",
Callback = function()
    g.load_youtube_music_player_func()
end})
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Anti Sit",
Default = g.Not_Ever_Sitting or false,
Flag = "Anti_Sit_Toggle_UI",
Callback = function(state)
    g.anti_sit_func(state)
end}, "Anti_Sit_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Walk Fling (FE)",
Default = g.walkflinging or false,
Flag = "Walk_Fling_Toggle_UI",
Callback = function(state)
    if state then
        local fn = g.FlamesLibrary.safe_func(g.StartWalkFling)
        fn()
    else
        local fn = g.FlamesLibrary.safe_func(g.StopWalkFling)
        fn()
    end
end}, "Walk_Fling_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Name Spam (FE, Slow!)",
Default = g.Name_Spammer_Currently_Enabled or false,
Flag = "Name_Spam_Toggle_UI",
Callback = function(state)
    g.name_changer_premium(state)
end}, "Name_Spam_Toggle_UI")
g.create_ui_element("Toggle", Phone_Section, {
Name = "Block Calls (FE)",
Default = g.Auto_Calls_Blocker_V3_Is_Enabled_Boolean_Flag or false,
Flag = "Block_Calls_Toggle_UI",
Callback = function(state)
    if state then
        if g.Auto_Calls_Blocker_V3_Is_Enabled_Boolean_Flag then g.notify("Warning", "You already have Calls_Blocker_V3 enabled!", 5); return end
        g.notify("Success", "Calls_Blocker_V3 has been enabled.", 5)
        g.Auto_Calls_Blocker_V3_Is_Enabled_Boolean_Flag = true
        g.FlamesLibrary.spawn("calls_blocker", "spawn", function()
            local net = g.Net
            local incoming_hook
            local emergency_hook
            incoming_hook = net.hook("incoming_call", function(plr)
                pcall(function()
                    g.Send("end_call", plr)
                end)
                return false
            end)
            emergency_hook = net.hook("incoming_emergency_call", function(plr)
                pcall(function()
                    g.Send("end_call", plr)
                end)
                return false
            end)
            g.calls_blocker_hooks = {
                incoming = incoming_hook,
                emergency = emergency_hook
            }
            while g.FlamesLibrary.is_alive("calls_blocker") do
                fw(1)
            end
        end)
    else
        if not g.Auto_Calls_Blocker_V3_Is_Enabled_Boolean_Flag then g.notify("Warning", "You do NOT have Calls_Blocker_V3 enabled!", 5); return end
        if g.calls_blocker_hooks then
            for _, v in pairs(g.calls_blocker_hooks) do
                pcall(function()
                    if typeof(v) == "RBXScriptConnection" then
                        v:Disconnect()
                    elseif type(v) == "function" then
                        v()
                    end
                end)
            end
            g.calls_blocker_hooks = nil
        end
        g.Auto_Calls_Blocker_V3_Is_Enabled_Boolean_Flag = false
        g.FlamesLibrary.disconnect("calls_blocker")
        g.notify("Success", "Calls_Blocker_V3 has been disabled.", 5)
    end
end}, "Block_Calls_Toggle_UI")
g.create_ui_element("Slider", LocalPlayer_Section, {
Name = "Fly Speed",
Min = 1,
Max = 200,
Default = g.Fly_Speed_Value or 5,
Flag = "Fly_Speed_Slider_UI",
Callback = function(val)
    g.Fly_Speed_Value = val
end}, "Fly_Speed_Slider_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Fly (FE)",
Default = g.FlyEnabled or false,
Flag = "Fly_Toggle_UI",
Callback = function(state)
    if state then
        if g.FlyEnabled then g.notify("Error", "Fly is already enabled!", 5); return end
        if g.Enabled_Flying then g.notify("Error", "Another fly is already enabled!", 5); return end
        local speed = g.Fly_Speed_Value or nil
        g.EnableFly(true, speed)
        g.notify("Warning", "E = up, Q = down, WASD to move.", 3)
    else
        g.DisableFly()
    end
end}, "Fly_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Fly 2 - Magic Carpet (FE)",
Default = g.Enabled_Flying or false,
Flag = "Fly2_Toggle_UI",
Callback = function(state)
    if state then
        if g.Enabled_Flying then g.notify("Error", "Fly-2 is already enabled!", 5); return end
        if g.FlyEnabled then g.notify("Error", "Fly-1 is already enabled, disable it first.", 6); return end
        local speed = g.Fly_Speed_Value or nil
        g.EnableFly2(speed)
        g.notify("Info", "Space = up, Shift = down, WASD to move.", 3)
    else
        g.DisableFly2()
    end
end}, "Fly2_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Fly 3 - Adonis (FE)",
Default = g.AdonisAdminFlyEnabled or false,
Flag = "Fly3_Toggle_UI",
Callback = function(state)
    if state then
        if g.Enabled_Flying then g.notify("Error", "Fly-2 is already enabled, disable it first.", 5); return end
        if g.FlyEnabled then g.notify("Error", "Fly-1 is already enabled, disable it first.", 6); return end
        local speed = g.Fly_Speed_Value or nil
        if speed then g.SetAdonisFlySpeed(speed) end
        g.notify("Info", "E = up, Q = down, WASD to move.", 5)
        g.StartAdonisAdminFlyScript()
    else
        g.Stop_Fly_3_Function()
    end
end}, "Fly3_Toggle_UI")
g.create_ui_element("Input", Vehicle_Section, {
Name = "Car Max Speed (FE)",
PlaceholderText = "Enter number...",
Flag = "Car_Speed_Input_UI",
Callback = function(split)
    local Vehicle = g.get_vehicle()
    local Hum = g.in_humanoid_vehicle(g.LocalPlayer)
    local Hum_Vehicle_Name = g.hum_vehicle_name(g.LocalPlayer)
    local n = tonumber(split)
    if not n then g.notify("Warning", "Enter a valid number!", 3); return end
    if Hum and Hum_Vehicle_Name then
        g.set_hum_vehicle_speed(n)
        g.notify("Success", "Set HumanoidVehicle: " .. tostring(Hum_Vehicle_Name) .. "'s speed to: " .. tostring(n), 5); return
    end
    if Vehicle and Vehicle:GetAttribute("max_speed") ~= nil then
        Vehicle:SetAttribute("max_speed", n)
        g.notify("Success", "Set Vehicle: " .. tostring(Vehicle) .. "'s speed to: " .. tostring(n), 5); return
    end
    g.notify("Error", "No car or humanoid vehicle found.", 5)
end}, "Car_Speed_Input_UI")
g.create_ui_element("Input", Vehicle_Section, {
Name = "Car Max Accel (FE)",
PlaceholderText = "Enter number...",
Flag = "Car_Accel_Input_UI",
Callback = function(split)
    local val = tonumber(split)
    if not val then g.notify("Warning", "Usage: enter a valid number.", 5); return end
    local car = g.get_vehicle()
    local humcar = g.in_humanoid_vehicle(g.LocalPlayer)
    if humcar then
        g.set_hum_vehicle_speed(val)
    elseif car and car:GetAttribute("max_acc") then
        car:SetAttribute("max_acc", val)
        g.notify("Success", "Set car max_acc to: " .. val, 5)
    else
        g.notify("Error", "Could not find car or humanoid vehicle.", 10)
    end
end}, "Car_Accel_Input_UI")
g.create_ui_element("Input", Vehicle_Section, {
Name = "Car Accel 0-60 (FE)",
PlaceholderText = "Enter number...",
Flag = "Car_Accel_060_Input_UI",
Callback = function(split)
    local val = tonumber(split)
    if not val then g.notify("Warning", "Enter a valid number.", 3); return end
    local car = g.get_vehicle()
    local humcar = g.in_humanoid_vehicle(g.LocalPlayer)
    if humcar then
        g.set_hum_vehicle_speed(val)
    elseif car and car:GetAttribute("acc_0_60") then
        car:SetAttribute("acc_0_60", val)
        g.notify("Success", "Set car acc_0_60 to: " .. val, 4)
    else
        g.notify("Error", "Could not find car or humanoid vehicle.", 10)
    end
end}, "Car_Accel_060_Input_UI")
g.create_ui_element("Input", Vehicle_Section, {
Name = "Car Turn Angle (FE)",
PlaceholderText = "Enter number...",
Flag = "Car_Turn_Angle_Input_UI",
Callback = function(split)
    local val = tonumber(split)
    if not val then g.notify("Warning", "Enter a valid number.", 3); return end
    local car = g.get_vehicle()
    local humcar = g.in_humanoid_vehicle(g.LocalPlayer)
    if humcar then
        g.set_hum_vehicle_speed(val)
    elseif car and car:GetAttribute("turn_angle") then
        car:SetAttribute("turn_angle", val)
        g.notify("Success", "Set car turn_angle to: " .. tostring(val), 5)
    else
        g.notify("Error", "Could not find car or humanoid vehicle.", 10)
    end
end}, "Car_Turn_Angle_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Rainbow Car (Friend, FE)",
PlaceholderText = "Username or displayname...",
Flag = "Rainbow_Car_Friend_Input_UI",
Callback = function(split)
    local Player_To_RGB_Car = g.findplr(split)
    if not Player_To_RGB_Car then g.notify("Error", "Player does not exist!", 3); return end
    if not g.get_other_vehicle(Player_To_RGB_Car) then g.notify("Error", "Player does not have a Vehicle spawned!", 5); return end
    local checker = g.check_friend(Player_To_RGB_Car)
    if not checker or checker ~= true then g.notify("Error", "Player is not your friend, add them to use this!", 5); return end
    if g.FlamesLibrary.is_alive("rainbow_car_" .. Player_To_RGB_Car.Name) then g.notify("Error", "Player already has their car rainbow!", 5); return end
    local colors = {
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(128, 128, 128),
        Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 165, 0), Color3.fromRGB(139, 69, 19),
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(50, 205, 50),
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 155, 172),
        Color3.fromRGB(128, 0, 128),
    }
    local thread_name = "rainbow_car_" .. Player_To_RGB_Car.Name
    g.FlamesLibrary.spawn(thread_name, "spawn", function()
        while g.FlamesLibrary.is_alive(thread_name) do
            fw(0.2)
            local current_plr = g.Players:FindFirstChild(Player_To_RGB_Car.Name)
            if not current_plr then
                g.FlamesLibrary.disconnect(thread_name)
                g.notify("Error", "Player must have left the game.", 5)
                return
            end
            for _, color in ipairs(colors) do
                if not g.FlamesLibrary.is_alive(thread_name) then break end
                fw(0.2)
                g.change_vehicle_color(color, g.get_other_vehicle(current_plr))
            end
        end
    end)
    g.notify("Success", "Rainbow car enabled for: " .. Player_To_RGB_Car.Name, 5)
end}, "Rainbow_Car_Friend_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Stop Rainbow Car (Friend, FE)",
PlaceholderText = "Username or displayname...",
Flag = "Stop_Rainbow_Car_Friend_Input_UI",
Callback = function(split)
    local Player_To_RGB_Car_Stop = g.findplr(split)
    if not Player_To_RGB_Car_Stop then g.notify("Error", "Player does not exist!", 5); return end
    if not g.get_other_vehicle(Player_To_RGB_Car_Stop) then g.notify("Error", "Player does not have a Vehicle spawned!", 5); return end
    local checker = g.check_friend(Player_To_RGB_Car_Stop) or Player_To_RGB_Car_Stop:IsFriendsWith(g.LocalPlayer.UserId)
    if checker ~= true then g.notify("Error", "Player is not your friend, add them to use this!", 5) end
    local thread_name = "rainbow_car_" .. Player_To_RGB_Car_Stop.Name
    if not g.FlamesLibrary.is_alive(thread_name) then g.notify("Warning", "This Player does not have Rainbow Vehicle enabled.", 6); return end
    g.FlamesLibrary.disconnect(thread_name)
    g.disable_rgb_for(Player_To_RGB_Car_Stop)
    g.notify("Success", "Disabled Rainbow Vehicle for: " .. Player_To_RGB_Car_Stop.Name, 5)
end}, "Stop_Rainbow_Car_Friend_Input_UI")
g.create_ui_element("Button", Houses_Section, {
Name = "Lock Home (FE)",
Callback = function()
    local is_locked = g.is_home_locked(g.LocalPlayer)
    if is_locked == true then
        g.notify("Warning", "Your home is already locked.", 5)
        return
    elseif is_locked == false then
        g.toggle_house_lock(g.LocalPlayer)
        g.notify("Success", "Locked your home.", 5)
    else
        g.notify("Error", "Something unexpected happened while checking if House is locked.", 10)
    end
end}, "Lock_Home_Button_UI")
g.create_ui_element("Button", Houses_Section, {
Name = "Unlock Home (FE)",
Callback = function()
    local is_locked = g.is_home_locked(g.LocalPlayer)
    if is_locked == false then
        g.notify("Warning", "Your home is not locked.", 5)
        return
    elseif is_locked == true then
        g.toggle_house_lock(g.LocalPlayer)
        g.notify("Success", "Unlocked your home.", 5)
    else
        g.notify("Error", "Something unexpected happened while checking if House is locked.", 10)
    end
end}, "Unlock_Home_Button_UI")
g.create_ui_element("Toggle", Houses_Section, {
Name = "Auto Lock Home (FE)",
Default = g.LockHomeLoop or false,
Flag = "Auto_Lock_Home_Toggle_UI",
Callback = function(state)
    g.keep_home_locked(state)
end}, "Auto_Lock_Home_Toggle_UI")
g.create_ui_element("Input", Houses_Section, {
Name = "Lock Player Home (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Lock_Player_Home_Input_UI",
Callback = function(split)
    local plr_to_lock = g.findplr(split)
    if not plr_to_lock then g.notify("Error", "Player not found or does not exist.", 5); return end
    if not plr_to_lock:IsFriendsWith(g.LocalPlayer.UserId) then g.notify("Error", "You must be friends with the player to lock their House!", 10); return end
    local is_locked = g.is_home_locked(plr_to_lock)
    if is_locked == true then
        g.notify("Warning", tostring(plr_to_lock) .. "'s home is already locked.", 5)
        return
    elseif is_locked == false then
        g.toggle_house_lock(plr_to_lock)
        g.notify("Success", "Locked: " .. tostring(plr_to_lock) .. "'s home.", 5)
    else
        g.notify("Error", "Something happened while trying to lock: " .. tostring(plr_to_lock) .. "'s home!", 10)
    end
end}, "Lock_Player_Home_Input_UI")
g.create_ui_element("Input", Houses_Section, {
Name = "Unlock Player Home (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Unlock_Player_Home_Input_UI",
Callback = function(split)
    local plr_to_unlock = g.findplr(split)
    if not plr_to_unlock then g.notify("Error", "Player not found or does not exist.", 5); return end
    if not plr_to_unlock:IsFriendsWith(g.LocalPlayer.UserId) then g.notify("Error", "You must be friends with the player to unlock their House!", 10); return end
    local is_locked = g.is_home_locked(plr_to_unlock)
    if is_locked == false then
        g.notify("Warning", tostring(plr_to_unlock) .. "'s home is not locked.", 5)
        return
    elseif is_locked == true then
        g.toggle_house_lock(plr_to_unlock)
        g.notify("Success", "Unlocked: " .. tostring(plr_to_unlock) .. "'s home.", 5)
    else
        g.notify("Error", "Something happened while trying to unlock: " .. tostring(plr_to_unlock) .. "'s home!", 10)
    end
end}, "Unlock_Player_Home_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Friend Player",
PlaceholderText = "Username or displayname...",
Flag = "Friend_Player_Input_UI",
Callback = function(split)
    local target_friend_plr = g.findplr(split)
    if not target_friend_plr then g.notify("Error", "That player does not exist or has left the game.", 6); return end
    g.friend_user_async_function(target_friend_plr)
end}, "Friend_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Unfriend Player",
PlaceholderText = "Username or displayname...",
Flag = "Unfriend_Player_Input_UI",
Callback = function(split)
    local target_unfriend_plr = g.findplr(split)
    if not target_unfriend_plr then g.notify("Error", "That player does not exist or has left the game.", 6); return end
    g.unfriend_user_async(target_unfriend_plr)
end}, "Unfriend_Player_Input_UI")
if executor_contains("delta") then
    g.create_ui_element("Toggle", Home_Section, {
    Name = "Toggle Delta Icon",
    Default = g.Is_Deltas_Icon_Currently_Toggled or false,
    Flag = "Hide_Delta_Toggle_UI",
    Callback = function(state)
        g.toggle_delta_image_button_flames_hub(not state)
    end}, "Hide_Delta_Toggle_UI")
end
g.create_ui_element("Toggle", Phone_Section, {
Name = "Anti RGB Phone",
Default = g.HidePhoneModels or false,
Flag = "Anti_RGB_Phone_Toggle_UI",
Callback = function(state)
    if state then
        if g.HidePhoneModels then g.notify("Warning", "Anti RGB Phone is already enabled.", 5); return end
        g.notify("Success", "Enabled Anti RGB Phone.", 5)
        g.TogglePhoneModelHider(true)
    else
        if not g.HidePhoneModels then g.notify("Warning", "Anti RGB Phone is not enabled.", 5); return end
        g.notify("Success", "Disabled Anti RGB Phone.", 5)
        g.TogglePhoneModelHider(false)
    end
end}, "Anti_RGB_Phone_Toggle_UI")
g.create_ui_element("Toggle", Extras_Section, {
Name = "FPS Boost",
Default = g.ultimate_lag_reducer or false,
Flag = "FPS_Boost_Toggle_UI",
Callback = function(state)
    g.FlamesLagReducerFunc(state)
end}, "FPS_Boost_Toggle_UI")
g.create_ui_element("Toggle", Extras_Section, {
Name = "Always Show Titles",
Default = g.always_show_title_above_head or false,
Flag = "Always_Show_Titles_Toggle_UI",
Callback = function(state)
    g.always_show_title_of_player_regardless_of_chats(state)
end}, "Always_Show_Titles_Toggle_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "RGB Skin (FE)",
Default = g.rainbow_skintone_currently_enabled or false,
Flag = "RGB_Skin_Toggle_UI",
Callback = function(state)
    g.rainbow_skin(state)
end}, "RGB_Skin_Toggle_UI")
g.create_ui_element("Toggle", Extras_Section, {
Name = "RGB Tool (FE)",
Default = g.Rainbow_Tools_FE or false,
Flag = "RGB_Tool_Toggle_UI",
Callback = function(state)
    if state then
        if g.Rainbow_Tools_FE then g.notify("Warning", "Rainbow Tool is already enabled.", 5); return end
        g.rainbow_tool(true)
    else
        if not g.Rainbow_Tools_FE then g.notify("Warning", "Rainbow Tool is not enabled.", 5); return end
        g.rainbow_tool(false)
    end
end}, "RGB_Tool_Toggle_UI")
g.create_ui_element("Toggle", Extras_Section, {
Name = "Anti Fire",
Default = g.firehidden or false,
Flag = "Anti_Fire_Toggle_UI",
Callback = function(state)
    if state then
        if g.firehidden then g.notify("Warning", "Flames Anti-Fire Spammer V3 is already enabled.", 6); return end
        if g.spamming_all_that_fire then g.notify("Warning", "Flames Spammer is enabled, disable it first!", 10); return end
        g.notify("Success", "Flames Anti-Fire Spammer V3 is now enabled.", 6)
        g.set_fire_state(true)
    else
        if not g.firehidden then g.notify("Warning", "Flames Anti-Fire Spammer V3 is not enabled.", 6); return end
        g.notify("Success", "Flames Anti-Fire Spammer V3 is now disabled.", 6)
        g.set_fire_state(false)
    end
end}, "Anti_Fire_Toggle_UI")
if priv_server_is_in == true then
    g.create_ui_element("Toggle", PrivServer_Section, {
    Name = "Stop Time (FE)",
    Default = g.is_time_currently_stopped_priv_server or false,
    Flag = "Stop_Time_Toggle_UI",
    Callback = function(state)
        g.stop_time_toggle(state)
    end}, "Stop_Time_Toggle_UI")
    g.create_ui_element("Toggle", PrivServer_Section, {
    Name = "Flash Time (FE)",
    Default = g.flashing_time_fe_toggle or false,
    Flag = "Flash_Time_Toggle_UI",
    Callback = function(state)
        g.flash_time_toggle(state)
    end}, "Flash_Time_Toggle_UI")
    g.create_ui_element("Toggle", PrivServer_Section, {
    Name = "Flash Weather (FE)",
    Default = g.changing_weather_on_repeat or false,
    Flag = "Flash_Weather_Toggle_UI",
    Callback = function(state)
        g.weather_flasher_loop(state)
    end}, "Flash_Weather_Toggle_UI")
    g.create_ui_element("Toggle", PrivServer_Section, {
    Name = "Server Lock (FE)",
    Default = g.server_lock_enabled or false,
    Flag = "Server_Lock_Toggle_UI",
    Callback = function(state)
        g.server_lock_toggle(state)
    end}, "Server_Lock_Toggle_UI")
    g.create_ui_element("Button", PrivServer_Section, {
    Name = "Server Lock Manager",
    Callback = function()
        g.server_lock_whitelist_gui()
    end}, "Server_Lock_Manager_Button_UI")
    g.create_ui_element("Input", PrivServer_Section, {
    Name = "Kick Player (FE)",
    PlaceholderText = "Username or displayname...",
    Flag = "Kick_Player_Input_UI",
    Callback = function(split)
        local target_plr = g.findplr(split)
        if not target_plr then g.notify("Error", "That player does not exist or has left.", 5); return end
        if not g.is_localplayer_server_owner() then g.notify("Error", "You are not the private server owner!", 5); return end
        if target_plr.Name == "CIippedByAura" or target_plr.Name == "L0CKED_1N1" then return end
        g.kick_plr(target_plr)
        g.notify("Success", "Kicked Player: " .. tostring(target_plr), 5)
    end}, "Kick_Player_Input_UI")
    g.create_ui_element("Input", PrivServer_Section, {
    Name = "Ban Player (FE)",
    PlaceholderText = "Username or displayname...",
    Flag = "Ban_Player_Input_UI",
    Callback = function(split)
        if not g.is_localplayer_server_owner() then
            local admin_player = g.get_server_admin_player()
            g.notify("Warning", "Private Server is owned by: " .. tostring(admin_player and admin_player.Name or "Unknown"), 7)
            g.notify("Error", "Not a Private Server or you don't own it!", 5)
            return
        end
        local target = g.findplr(split) or split
        local added = addban(target)
        if added then
            g.notify("Success", "Banned player: " .. added, 5)
        else
            g.notify("Error", "Failed to ban target.", 6)
        end
    end}, "Ban_Player_Input_UI")
    g.create_ui_element("Input", PrivServer_Section, {
    Name = "Unban Player (FE)",
    PlaceholderText = "Username or displayname...",
    Flag = "Unban_Player_Input_UI",
    Callback = function(split)
        if not g.is_localplayer_server_owner() then
            local admin_player = g.get_server_admin_player()
            g.notify("Warning", "Private Server is owned by: " .. tostring(admin_player and admin_player.Name or "Unknown"), 7)
            g.notify("Error", "Not a Private Server or you don't own it!", 5)
            return
        end
        local target = g.findplr(split) or split
        local removed = removeban(target)
        if removed then
            g.notify("Success", "Unbanned player: " .. removed, 5)
        else
            g.notify("Error", "Player is not banned.", 3)
        end
    end}, "Unban_Player_Input_UI")
end
g.create_ui_element("Toggle", Extras_Section, {
Name = "RGB Street Lights",
Default = g.RGB_Street_Lights_NightTime_Loop or false,
Flag = "RGB_Street_Lights_Toggle_UI",
Callback = function(state)
    g.toggle_rgb_streetlights(state)
end}, "RGB_Street_Lights_Toggle_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Admin Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Admin_Player_Input_UI",
Callback = function(split)
    local Player = g.findplr(split)
    if not Player then g.notify("Error", "Player does not exist!", 5); return end
    if not Player:IsFriendsWith(g.LocalPlayer.UserId) then g.notify("Error", "This player isn't friends with you, add them!", 5); return end
    if g.player_admins[Player.Name] then g.notify("Error", "Player is already an admin!", 5); return end
    g.alreadyCheckedUser(Player)
    fw(0.5)
    g.notify("Success", "Added " .. tostring(Player.Name) .. " to the admin's table!", 3)
end}, "Admin_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "UnAdmin Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Unadmin_Player_Input_UI",
Callback = function(split)
    local Player = g.findplr(split)
    if not Player then g.notify("Error", "Player does not exist!", 5); return end
    if not Player:IsFriendsWith(g.LocalPlayer.UserId) then g.notify("Error", "This player isn't friends with you!", 5); return end
    local Name = Player.Name
    g.notify("Warning", "Removing admin for: " .. tostring(Name), 5)
    if g.player_admins[Name] then g.player_admins[Name] = nil end
    if g.Rainbow_Vehicles[Name] then g.Rainbow_Vehicles[Name] = false end
    if g.Locked_Vehicles[Name] then g.Locked_Vehicles[Name] = false end
    if g.Unlocked_Vehicles[Name] then g.Unlocked_Vehicles[Name] = false end
    if g.Rainbow_Tasks[Name] then g.Rainbow_Tasks[Name] = nil end
    fw(0.5)
    if not g.player_admins[Name] then
        g.notify("Success", "Player's admin has been removed successfully.", 5)
    else
        g.notify("Error", "Player's admin abilities were not removed.", 5)
    end
end}, "Unadmin_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Blacklist Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Blacklist_Player_Input_UI",
Callback = function(split)
    local Player = g.findplr(split)
    if not Player then return end
    local Name = Player.Name
    if Player:IsFriendsWith(g.LocalPlayer.UserId) then
        if not g.Blacklisted_Friends[Name] then
            g.Blacklisted_Friends[Name] = Player
        end
    end
    fw(0.3)
    if g.player_admins[Name] then g.player_admins[Name] = nil end
    if g.Rainbow_Vehicles[Name] then g.Rainbow_Vehicles[Name] = false end
    if g.Locked_Vehicles[Name] then g.Locked_Vehicles[Name] = false end
    if g.Unlocked_Vehicles[Name] then g.Unlocked_Vehicles[Name] = false end
    if g.Rainbow_Tasks[Name] then g.Rainbow_Tasks[Name] = nil end
    g.notify("Success", "Blacklisted: " .. tostring(Name), 5)
end}, "Blacklist_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Unblacklist Player (FE)",
PlaceholderText = "Username or displayname...",
Flag = "Unblacklist_Player_Input_UI",
Callback = function(split)
    local Player = g.findplr(split)
    if not Player then return end
    local Name = Player.Name
    if Player:IsFriendsWith(g.LocalPlayer.UserId) then
        if g.Blacklisted_Friends[Name] then
            g.Blacklisted_Friends[Name] = nil
            g.notify("Success", "Removed blacklist for: " .. tostring(Name), 5)
        else
            g.notify("Warning", tostring(Name) .. " is not blacklisted.", 5)
        end
    end
end}, "Unblacklist_Player_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Rainbow Time (Friend, FE)",
PlaceholderText = "Username number (e.g. PlayerName 1)...",
Flag = "Rainbow_Time_Input_UI",
Callback = function(split)
    local parts = split and split:split(" ") or {}
    local Player = g.findplr(parts[1])
    if not Player then g.notify("Error", "Player doesn't exist or has left!", 5); return end
    if not Player:IsFriendsWith(g.LocalPlayer.UserId) then g.notify("Error", "Player is not friends with you, add them!", 5); return end
    local new_delay = tonumber(parts[2]) or 1
    g.Rainbow_Delays = g.Rainbow_Delays or {}
    g.Rainbow_Delays[Player.Name] = new_delay
    fw(0.2)
    g.notify("Success", "Set rainbow delay for " .. Player.Name .. " to " .. new_delay, 5)
end}, "Rainbow_Time_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Walk Fling Whitelist",
PlaceholderText = "Username or displayname...",
Flag = "Walk_Fling_Whitelist_Input_UI",
Callback = function(split)
    local plr = g.findplr(split)
    if typeof(plr) ~= "Instance" or not plr:IsA("Player") then g.notify("Error", "Player not found in game.", 3); return end
    g.AddToWalkFlingWhitelist(plr)
end}, "Walk_Fling_Whitelist_Input_UI")
g.create_ui_element("Input", Players_Section, {
Name = "Walk Fling Unwhitelist",
PlaceholderText = "Username or displayname...",
Flag = "Walk_Fling_Unwhitelist_Input_UI",
Callback = function(split)
    local plr = g.findplr(split)
    if typeof(plr) ~= "Instance" or not plr:IsA("Player") then g.notify("Error", "Player not found in game.", 5); return end
    g.RemoveFromWalkFlingWhitelist(plr)
end}, "Walk_Fling_Unwhitelist_Input_UI")
g.create_ui_element("Button", Home_Section, {
Name = "Get Priv Server Owner",
Callback = function()
    g.notify_priv_server_owner()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Streamer Mode",
Callback = function()
    g.streamer_mode_script()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Annoyer GUI",
Callback = function()
    g.annoyance_GUI()
end,})
g.create_ui_element("Button", Vehicle_Section, {
Name = "Car Stats GUI",
Callback = function()
    g.vehicle_stats_viewer_GUI()
end,})
g.create_ui_element("Button", Vehicle_Section, {
Name = "All Cars GUI",
Callback = function()
    g.car_listing_gui()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Free Emotes GUI",
Callback = function()
    loadstring(g.http_get("https://pastebin.com/raw/RCj6RJtc"))()
end,})
g.create_ui_element("Button", Phone_Section, {
Name = "Message GUI",
Callback = function()
    g.send_msg_menu()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Workspace Editor",
Callback = function()
    g.workspace_editor_script_GUI()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Debugger",
Callback = function()
    if g.Flames_Debugger_Function_Tester_GUI then
        pcall(function() g.Flames_Debugger_Function_Tester_GUI() end)
    else
        g.notify("Error", "Flames Debugger function not found or was not created at runtime.", 10)
    end
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Outfit Saver (Save outfits GUI)",
Callback = function()
    g.lt_open_outfit_saver()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Chat Bypass",
Callback = function()
    g.load_workaround_script()
end,})
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Save Emote",
Callback = function()
    g.save_copied_plrs_emote()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Infinite Yield",
Callback = function()
    g.infinite_yield()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Infinite Premium",
Callback = function()
    g.infinite_premium()
end,})
g.create_ui_element("Button", Extras_Section, {
Name = "Nameless Admin",
Callback = function()
    g.flames_nameless_admin_ver()
end,})
g.Toggle_Fire_Spam = g.create_ui_element("Toggle", Extras_Section, {
Name = "Flames (FE)",
Default = g.spamming_all_that_fire or false,
Flag = "Flames_Toggle_UI",
Callback = function(state)
    if state then
        if g.LocalPlayer:GetAttribute("is_verified") == false then
            if g.Toggle_Fire_Spam then g.Toggle_Fire_Spam:Set(false, false) end
            g.notify("Error", "You need actual LifePay premium to run this!", 5)
            return
        end
        if g.spamming_flames and typeof(g.spamming_flames) == "function" then
            g.spamming_flames(true)
        else
            g.notify("Error", "Function: g.spamming_flames does not exist.", 3); return
        end
    else
        if g.spamming_flames and typeof(g.spamming_flames) == "function" then
            g.spamming_flames(false)
        else
            g.notify("Error", "Function: g.spamming_flames does not exist.", 3); return
        end
    end
end}, "Flames_Toggle_UI")
g.create_ui_element("Input", Extras_Section, {
Name = "Spawn Fire (FE)",
PlaceholderText = "Enter amount...",
Flag = "Spawn_Fire_Input_UI",
Callback = function(split)
    local amount = tonumber(split) or 5
    local is_verified = g.LocalPlayer:GetAttribute("is_verified")
    if not is_verified then g.notify("Error", "You do not have premium, you cannot run this!", 8); return end
    g.HasSeen_Fire_AlertFlamesHub = g.HasSeen_Fire_AlertFlamesHub or false
    g.set_fire_amount_FE(amount)
    g.HasSeen_Fire_AlertFlamesHub = true
    fw(0.2)
    for i = 1, amount do g.Send("request_fire") end
end}, "Spawn_Fire_Input_UI")
g.create_ui_element("Toggle", Extras_Section, {
Name = "Sign Spam (FE)",
Default = g.ToolChanger_FE or false,
Flag = "Sign_Spam_Toggle_UI",
Callback = function(state)
    if state then
        if g.ToolChanger_FE then g.notify("Warning", "Sign spammer is already enabled!", 5); return end
        g.spam_sign_text(true)
    else
        if not g.ToolChanger_FE then g.notify("Warning", "Sign spammer is not enabled!", 5); return end
        g.spam_sign_text(false)
    end
end}, "Sign_Spam_Toggle_UI")
g.create_ui_element("Button", Extras_Section, {
Name = "Collect All NBA Props (FE)",
Callback = function()
    local attr = g.LocalPlayer:GetAttribute("NBA_HUNT_PROGRESS")
    if not attr then return end
    if attr ~= "PLAYING" then g.notify("Warning", "Talk to the NPC first and enter before trying this!", 10); return end
    g.collect_all_nba_props()
end,})
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Anti Outfit Copier (FE)",
Default = g.anti_outfit_stealer or false,
Flag = "Anti_Outfit_Copier_Toggle_UI",
Callback = function(state)
    g.anti_outfit_copier(state)
end}, "Anti_Outfit_Copier_Toggle_UI")
g.create_ui_element("Toggle", Extras_Section, {
Name = "Mute Tools",
Default = g.autosilence or false,
Flag = "Mute_Tools_Toggle_UI",
Callback = function(state)
    g.mute_all_tools(state)
end}, "Mute_Tools_Toggle_UI")
g.create_ui_element("Dropdown", LocalPlayer_Section, {
Name = "Emotes",
Options = {
	"Needy",
	"Griddy",
	"Jiggy",
	"Scenario",
	"Superman",
	"Zen",
	"Orange Justice",
	"Aura Farm",
	"Worm",
	"Jabba",
	"Popular",
	"Default Dance",
	"Koto Nai",
	"Glitching",
	"Billy Jean",
	"Billy Bounce",
	"Michael Myers",
	"Sturdy",
	"Electro Shuffle",
	"Take The L",
	"Laugh It Up",
	"Reanimated",
	"Motion",
	"Tuff",
	"Michael Jackson"
},
DefaultItemSelected = "None",
ItemSelecting = false,
Callback = function(selected)
	local emote_map = {
		["Needy"]           = "needy_twerk",
		["Griddy"]          = "griddy",
		["Jiggy"]           = "jiggy",
		["Scenario"]        = "scenario",
		["Superman"]        = "superman",
		["Zen"]             = "zen",
		["Orange Justice"]  = "orangej",
		["Aura Farm"]       = "aura",
		["Worm"]            = "worm",
		["Jabba"]           = "jabba",
		["Popular"]         = "popular",
		["Default Dance"]   = "defaultdance",
		["Koto Nai"]        = "kotonai",
		["Glitching"]       = "glitch",
		["Billy Jean"]      = "billyjean",
		["Billy Bounce"]    = "billybounce",
		["Michael Myers"]   = "michaelmyers",
		["Sturdy"]          = "sturdy",
		["Electro Shuffle"] = "electroshuffle",
		["Take The L"]      = "takethel",
		["Laugh It Up"]     = "laughitup",
		["Reanimated"]      = "reanimated",
		["Motion"]          = "motion",
		["Tuff"]            = "tuff",
		["Michael Jackson"] = "michaeljackson",
	}
	local emote = emote_map[selected]
	if not emote then g.notify("Error", "Unknown emote selected.", 2.5); return end
	g.do_emote(emote)
end}, "Emotes_Dropdown_UI")
g.create_ui_element("Button", LocalPlayer_Section, {
Name = "Stop Emoting",
Callback = function()
    g.disable_emoting_script()
end}, "No_Emote_Button_UI")
g.create_ui_element("Input", LocalPlayer_Section, {
Name = "RP Name (FE)",
PlaceholderText = "Enter new RP name...",
Flag = "RP_Name_Input_UI",
Callback = function(text)
    local max_len = 19
    if #text > max_len and writefile then
        g.notify("Info", "Your roleplay Name exceeds 19 characters, we're saving it for you, it'll be automatically set back once you reload the script.", 15)
        writefile("LifeTogether_RP_Admin_Custom_Name.txt", text)
    end
    g.change_RP_Name(text)
end}, "RP_Name_Input_UI")
g.create_ui_element("Input", LocalPlayer_Section, {
Name = "RP Bio (FE)",
PlaceholderText = "Enter new RP bio...",
Flag = "RP_Bio_Input_UI",
Callback = function(text)
    local max_len = 49
    if #text > max_len and writefile then
        g.notify("Info", "Your roleplay Bio exceeds 49 characters, we're saving it for you, it'll be automatically set back once you reload the script.", 15)
        writefile("LifeTogether_RP_Admin_Custom_Bio.txt", text)
    end
    g.change_bio(text)
end}, "RP_Bio_Input_UI")
g.create_ui_element("Button", Extras_Section, {
Name = "Performance GUI",
Callback = function()
    g.LoadPerformanceStatsGUI()
end}, "Stats_GUI_Button_UI")
g.create_ui_element("Toggle", LocalPlayer_Section, {
Name = "Two Tone Skin (FE)",
Default = g.Two_Tone_Skin_Tone_Loop_Toggled or false,
Flag = "Two_Tone_Skin_Toggle_UI",
Callback = function(state)
    g.two_tone_skin(state)
end}, "Two_Tone_Skin_Toggle_UI")
g.create_ui_element("ColorPicker", Vehicle_Section, {
Name = "Car Color (FE)",
Default = Color3.fromRGB(255, 0, 0),
Flag = "Car_Color_Picker_UI",
Callback = function(color)
    local vehicle = g.get_vehicle()
    if not vehicle then g.notify("Error", "You do not have a vehicle spawned!", 0.75); return end
    g.change_vehicle_color(color, vehicle)
end}, "Car_Color_Picker_UI")
g.create_ui_element("Toggle", Players_Section, {
Name = "Player ESP",
Default = g.Flames_Hub_Player_ESP_Core_Has_Been_Enabled or false,
Flag = "Player_ESP_Toggle_UI",
Callback = function(state)
    if state then
        g.enable_player_esp()
    else
        g.disable_player_esp()
    end
end}, "Player_ESP_Toggle_UI")
g.create_ui_element("Toggle", Players_Section, {
Name = "Tracer ESP",
Default = g.tracer_esp_currently_running_flag_Flames_Hub or false,
Flag = "Tracer_ESP_Toggle_UI",
Callback = function(state)
    if state then
        g.enable_tracers()
    else
        g.disable_tracers()
    end
end}, "Tracer_ESP_Toggle_UI")
g.print_bytes = function(label, s)
    local bytes = {}
    for i = 1, #s do
        table.insert(bytes, string.byte(s, i))
    end
    print(label .. ": " .. table.concat(bytes, ","))
end
local function clean(s) return s:gsub("[%c%z%s]", ""):gsub("[^\32-\126]", "") end
local script_url = "https://gitlab.com/flames2431233/Starter/-/raw/main/Experiences/13967668166.lua?ref_type=heads"
local version_url = "https://gitlab.com/flames2431233/Starter/-/raw/main/Assets/Script_Versions_JSON.json?ref_type=heads"
local function ws_get_version()
    local http_req = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
    if not http_req then return nil end
    local ok, result = pcall(function()
        return http_req({
            Url = version_url .. "?cache=" .. tostring(os.clock()),
            Method = "GET",
            Headers = { ["Content-Type"] = "application/json" }
        })
    end)
    if not ok or not result or result.StatusCode ~= 200 then return nil end
    local ok2, data = pcall(function() return g.HttpService:JSONDecode(result.Body) end)
    if not ok2 or type(data) ~= "table" then return nil end
    local version = data.LifeTogether_Hub_Version
    if not version then return nil end
    return tostring(version):gsub("%s+", "")
end
local function Notify(msg, dur)
    dur = dur or 5
    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomNotifyGui"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, 500, 0, 120)
    frame.Position = UDim2.new(0, 20, 0, 100)
    frame.Parent = gui
    local icon = Instance.new("ImageLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(0, 15, 0.5, -25)
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Image = "rbxasset://textures/ui/Emotes/ErrorIcon.png"
    icon.ImageTransparency = 1
    icon.Parent = frame
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 80, 0, 10)
    label.Size = UDim2.new(1, -90, 1, -20)
    label.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json")
    label.Text = msg
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 20
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.TextTransparency = 1
    label.Parent = frame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    g.TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.3 }):Play()
    g.TweenService:Create(icon, TweenInfo.new(0.3), { ImageTransparency = 0 }):Play()
    g.TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
    task.delay(dur, function()
        if not frame.Parent then return end
        g.TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        g.TweenService:Create(icon, TweenInfo.new(0.3), { ImageTransparency = 1 }):Play()
        g.TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        task.wait(0.35)
        if gui and gui:IsA("ScreenGui") then gui:Destroy() end
    end)
end
g.lta_updater_running = g.lta_updater_running or false
g.lta_updater_thread_id = (g.lta_updater_thread_id or 0) + 1
local thread_id = g.lta_updater_thread_id
if not g.lta_updater_running and g.Allow_Upstream_Updates then
    g.lta_updater_running = true
    task.spawn(function()
        while g.lta_updater_running and thread_id == g.lta_updater_thread_id do
            task.wait(20)
            local local_version = clean(tostring(g.Script_Version))
            if local_version == "" then continue end
            local remote_version = ws_get_version()
            if not remote_version or remote_version == "" then continue end
            if remote_version ~= local_version then
                g.lta_updater_running = false
                Notify("[UPDATE DETECTED]:\nLocal: " .. local_version .. "\nServer: " .. remote_version .. "\nReloading...", 6)
                task.wait(0.6)
                g.LifeTogether_Actual_Flames_Hub_Running_Functioning_Currently_On_Client = false
                g.Script_Version = nil
                g.LifeTogetherRP_Admin = false
                pcall(function()
                    loadstring(g.http_get(script_url .. "?cache=" .. tostring(os.clock())))()
                end)
                break
            end
        end
    end)
end
print("[Flames] loading: done")
