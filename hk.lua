-- ══════════════════════════════════════════════════════════════
--  elbilll | Hooked  —  VelarisUI Edition
-- ══════════════════════════════════════════════════════════════

local VelarisUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/testUI.lua"))()
local Alert = nil
pcall(function()
    Alert = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/alert%20new%20ui.lua"))()
end)

local Players    = game:GetService("Players")
local RS         = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")

local plr        = Players.LocalPlayer
local TEvent     = require(RS.Shared.Core.TEvent)

-- ══════════════════════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════════════════════
local Config = {
    SilentHook       = false,
    SilentHookRange  = 75,
    InstaKill        = false,
    KillInLobby      = false,
    HitboxExpander   = false,
    HitboxScale      = 10,
    SpeedEnabled     = false,
    SpeedValue       = 28,
    InfJump          = false,
    NoclipEnabled    = false,
    ESPEnabled       = false,
}

local HOOK_ID      = 67
local OrigHitboxes = {}
local ESPCache     = {}
local Connections  = {}

local silentLoop   = nil
local instaLoop    = nil
local noclipConn   = nil
local infJumpConn  = nil

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function GetChar()  return plr.Character end
local function GetHum()   local c = GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetHead()  local c = GetChar(); return c and c:FindFirstChild("Head") end

local function Notify(title, content, duration)
    VelarisUI:MakeNotify({
        Title       = title,
        Description = content or "",
        Color       = "Red",
        Time        = 0.5,
        Delay       = duration or 3,
    })
end

local function HasForceField(character)
    return character:FindFirstChildWhichIsA("ForceField") ~= nil
end

-- ══════════════════════════════════════════════════════════════
--  GET TARGETS
-- ══════════════════════════════════════════════════════════════
local function GetTargets(maxRange, allowLobby)
    local myHead = GetHead()
    if not myHead then return {} end
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p == plr then continue end
        local pt = p.Team
        if pt == plr.Team then continue end
        if pt and pt.Name == "Lobby" and not allowLobby then continue end
        local char = p.Character
        if not char or HasForceField(char) then continue end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local head = char:FindFirstChild("Head")
        if not head or not hum or hum.Health <= 0 then continue end
        local dist = (head.Position - myHead.Position).Magnitude
        if maxRange and dist > maxRange then continue end
        table.insert(targets, { Player = p, Head = head, Distance = dist })
    end
    table.sort(targets, function(a, b) return a.Distance < b.Distance end)
    return targets
end

-- ══════════════════════════════════════════════════════════════
--  HOOK PRIMITIVES
-- ══════════════════════════════════════════════════════════════
local function DoHookFire(target, range, flyTime, backSpeed)
    local myHead = GetHead()
    if not myHead then return end
    pcall(function()
        TEvent.FireRemote("HookFire", {
            hookId        = HOOK_ID,
            startPosition = myHead.Position,
            direction     = (target.Head.Position - myHead.Position).Unit,
            distance      = range or Config.SilentHookRange,
            hookFlyTime   = flyTime or 0,
            hookBackSpeed = backSpeed or 60,
            fireTime      = tick(),
        })
    end)
end

local function DoHookHit(target, backSpeed)
    pcall(function()
        TEvent.FireRemote("HookHit", {
            hookId         = HOOK_ID,
            targetPlayer   = target.Player,
            targetPartName = "Head",
            hookBackSpeed  = backSpeed or 60,
        })
    end)
end

local function DoHookRelease(target)
    pcall(function()
        TEvent.FireRemote("HookRelease", {
            hookId       = HOOK_ID,
            targetPlayer = target.Player,
            reason       = "retracted",
        })
    end)
end

-- ══════════════════════════════════════════════════════════════
--  SILENT HOOK
-- ══════════════════════════════════════════════════════════════
local function StartSilentHook()
    if silentLoop then return end
    silentLoop = task.spawn(function()
        while Config.SilentHook do
            local targets = GetTargets(Config.SilentHookRange, Config.KillInLobby)
            if #targets > 0 then
                local t = targets[1]
                DoHookFire(t, Config.SilentHookRange, 0.25, 60)
                task.wait(0.25)
                DoHookHit(t, 60)
                task.wait(0.05)
                DoHookRelease(t)
            end
            task.wait(0.8)
        end
        silentLoop = nil
    end)
end

local function StopSilentHook()
    Config.SilentHook = false
    silentLoop = nil
end

-- ══════════════════════════════════════════════════════════════
--  INSTA KILL
-- ══════════════════════════════════════════════════════════════
local function StartInstaKill()
    if instaLoop then return end
    instaLoop = task.spawn(function()
        while Config.InstaKill do
            local targets = GetTargets(nil, Config.KillInLobby)
            for i = 1, math.min(#targets, 5) do
                local t = targets[i]
                DoHookFire(t, 9e9, 0, 9e9)
                task.wait(0.01)
                DoHookHit(t, 9e9)
                task.wait(0.01)
                DoHookRelease(t)
                task.wait(0.02)
            end
            task.wait(0.1)
        end
        instaLoop = nil
    end)
end

local function StopInstaKill()
    Config.InstaKill = false
    instaLoop = nil
end

-- ══════════════════════════════════════════════════════════════
--  HITBOX EXPANDER
-- ══════════════════════════════════════════════════════════════
local function ExpandHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p == plr then continue end
        local char = p.Character; if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
        if not OrigHitboxes[p] then OrigHitboxes[p] = hrp.Size end
        local s = Config.HitboxScale
        pcall(function()
            hrp.Size = Vector3.new(s, s, s)
            hrp.Transparency = 0.9
            hrp.CanCollide   = false
        end)
    end
end

local function ResetHitboxes()
    for p, size in pairs(OrigHitboxes) do
        pcall(function()
            if p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Size = size; hrp.Transparency = 1 end
            end
        end)
    end
    OrigHitboxes = {}
end

-- ══════════════════════════════════════════════════════════════
--  MOVEMENT
-- ══════════════════════════════════════════════════════════════
local function StartNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        local c = GetChar(); if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

local function StopNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
end

local function SetupInfJump()
    if infJumpConn then return end
    infJumpConn = UIS.JumpRequest:Connect(function()
        if Config.InfJump then
            pcall(function() GetHum():ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════
--  ESP
-- ══════════════════════════════════════════════════════════════
local function CreateESP(p)
    if p == plr or ESPCache[p] then return end
    local hl = Instance.new("Highlight")
    hl.FillTransparency    = 0.6
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.fromRGB(200, 50, 50)
    hl.FillColor    = Color3.fromRGB(139, 0, 0)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(200, 40)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    local nl = Instance.new("TextLabel", bb)
    nl.Size = UDim2.new(1, 0, 0.5, 0)
    nl.BackgroundTransparency = 1
    nl.TextColor3 = Color3.fromRGB(255, 255, 255)
    nl.TextStrokeTransparency = 0.3
    nl.Font = Enum.Font.GothamBold
    nl.TextSize = 12
    nl.Text = p.DisplayName
    local il = Instance.new("TextLabel", bb)
    il.Size = UDim2.new(1, 0, 0.5, 0)
    il.Position = UDim2.new(0, 0, 0.5, 0)
    il.BackgroundTransparency = 1
    il.TextColor3 = Color3.fromRGB(0, 255, 80)
    il.TextStrokeTransparency = 0.3
    il.Font = Enum.Font.GothamBold
    il.TextSize = 10
    il.Text = "..."
    ESPCache[p] = { Highlight = hl, Billboard = bb, InfoLabel = il }
    local function Attach()
        pcall(function()
            if p.Character then
                hl.Adornee = p.Character; hl.Parent = p.Character
                local head = p.Character:FindFirstChild("Head")
                if head then bb.Adornee = head; bb.Parent = head end
            end
        end)
    end
    Attach()
    Connections["ESP_"..p.UserId] = p.CharacterAdded:Connect(function()
        task.wait(1); if Config.ESPEnabled then Attach() end
    end)
end

local function RemoveESP(p)
    local c = ESPCache[p]
    if c then
        pcall(function() c.Highlight:Destroy() end)
        pcall(function() c.Billboard:Destroy() end)
        ESPCache[p] = nil
    end
    local k = "ESP_"..p.UserId
    if Connections[k] then Connections[k]:Disconnect(); Connections[k] = nil end
end

local function EnableAllESP()
    for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
    Connections.ESPJoin  = Players.PlayerAdded:Connect(function(p) if Config.ESPEnabled then CreateESP(p) end end)
    Connections.ESPLeave = Players.PlayerRemoving:Connect(RemoveESP)
end

local function DisableAllESP()
    for p in pairs(ESPCache) do RemoveESP(p) end
    if Connections.ESPJoin  then Connections.ESPJoin:Disconnect();  Connections.ESPJoin  = nil end
    if Connections.ESPLeave then Connections.ESPLeave:Disconnect(); Connections.ESPLeave = nil end
end

-- ══════════════════════════════════════════════════════════════
--  MAIN LOOP
-- ══════════════════════════════════════════════════════════════
local hbClock, espClock = 0, 0
RunService.Heartbeat:Connect(function(dt)
    if Config.SpeedEnabled then
        pcall(function() GetHum().WalkSpeed = Config.SpeedValue end)
    end
    hbClock = hbClock + dt
    if Config.HitboxExpander and hbClock >= 0.5 then
        hbClock = 0; pcall(ExpandHitboxes)
    end
    espClock = espClock + dt
    if Config.ESPEnabled and espClock >= 0.3 then
        espClock = 0
        local myHead = GetHead()
        for p, data in pairs(ESPCache) do
            pcall(function()
                if p.Character then
                    local hum  = p.Character:FindFirstChildOfClass("Humanoid")
                    local head = p.Character:FindFirstChild("Head")
                    if hum and head then
                        local dist = myHead and math.floor((head.Position - myHead.Position).Magnitude) or "?"
                        local pct  = hum.Health / hum.MaxHealth
                        local col  = pct > 0.6 and Color3.fromRGB(0,255,80) or (pct > 0.3 and Color3.fromRGB(255,200,0) or Color3.fromRGB(255,50,50))
                        local ff   = HasForceField(p.Character) and " [FF]" or ""
                        data.InfoLabel.Text = ("HP:%d | %sm%s"):format(math.floor(hum.Health), dist, ff)
                        data.InfoLabel.TextColor3 = col
                        data.Highlight.FillColor  = col
                    end
                end
            end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════════════════════
local Window = VelarisUI:Window({
    Title         = "elbilll | Hooked",
    Footer        = "",
    Color         = "Red",
    Version       = 1.0,
    ["Tab Width"] = 110,
    Image         = "107802296255222",
    Configname    = "elbilll_hooked",
    ShowUser      = true,
    Search        = true,
    Config        = { AutoSave = true, AutoLoad = true },
})

local Tabs = {
    Info     = Window:AddTab({ Name = "Info",     Icon = "lucide:info" }),
    Main     = Window:AddTab({ Name = "Main",     Icon = "lucide:zap" }),
    Movement = Window:AddTab({ Name = "Movement", Icon = "lucide:person-standing" }),
    Visual   = Window:AddTab({ Name = "Visual",   Icon = "lucide:eye" }),
}

-- ══════════════════════════════════════════════════════════════
--  TAB: INFO
-- ══════════════════════════════════════════════════════════════
local InfoSec = Tabs.Info:AddSection({ Title = "Welcome to elbilll Hub!", Icon = "lucide:info", Open = true })

InfoSec:AddParagraph({
    Title   = "elbilll Notice",
    Content = "Script ini dirancang untuk game Hooked.\n"
           .. "Gunakan dengan bijak — deteksi selalu mungkin terjadi di server publik.\n\n"
           .. "Ada saran atau bug? Hubungi kami di Discord!\n\n"
           .. "Selamat bermain!",
})

InfoSec:AddButton({
    Title    = "Copy Discord Link",
    SubTitle = "discord.gg/nJHyfxNMqm",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("https://discord.gg/nJHyfxNMqm")
            elseif toclipboard then toclipboard("https://discord.gg/nJHyfxNMqm") end
        end)
        Notify("Discord", "Discord link copied to clipboard!", 3)
    end,
})

InfoSec:AddDivider()

local ServerSec = Tabs.Info:AddSection({ Title = "Server Info", Icon = "lucide:server", Open = true })

ServerSec:AddParagraph({
    Title   = "Server Info",
    Content = "Job ID: " .. (game.JobId ~= "" and game.JobId or "N/A") .. "\nPlayer: " .. plr.Name,
})

-- ══════════════════════════════════════════════════════════════
--  TAB: MAIN
-- ══════════════════════════════════════════════════════════════
local SilentSec = Tabs.Main:AddSection({ Title = "Silent Hook", Icon = "lucide:anchor", Open = true })

SilentSec:AddToggle({
    Title   = "Silent Hook",
    Content = "Hook musuh terdekat satu per satu — terlihat seperti hook normal",
    Default = false,
    Callback = function(v)
        Config.SilentHook = v
        if v then StartSilentHook() else StopSilentHook() end
        Notify("Silent Hook", v and "Enabled" or "Disabled", 3)
    end,
})

SilentSec:AddDivider()

SilentSec:AddSlider({
    Title     = "Hook Range (studs)",
    Content   = "Jarak maksimal silent hook",
    Min = 20, Max = 100, Default = 75, Increment = 5,
    Callback  = function(v) Config.SilentHookRange = v end,
})

SilentSec:AddDivider()

SilentSec:AddToggle({
    Title   = "Kill in Lobby",
    Content = "Izinkan hook musuh yang masih di Lobby",
    Default = false,
    Callback = function(v)
        Config.KillInLobby = v
        Notify("Kill in Lobby", v and "Enabled" or "Disabled", 3)
    end,
})

local InstaSec = Tabs.Main:AddSection({ Title = "Insta Kill", Icon = "lucide:skull", Open = true })

InstaSec:AddToggle({
    Title   = "Insta Kill",
    Content = "Langsung habisi semua musuh sekaligus (max 5/tick, dari mana saja)",
    Default = false,
    Callback = function(v)
        Config.InstaKill = v
        if v then StartInstaKill() else StopInstaKill() end
        Notify("Insta Kill", v and "Enabled" or "Disabled", 3)
    end,
})

local HitboxSec = Tabs.Main:AddSection({ Title = "Hitbox Expander", Icon = "lucide:expand", Open = true })

HitboxSec:AddToggle({
    Title   = "Hitbox Expander",
    Content = "Perbesar hitbox musuh agar lebih mudah kena",
    Default = false,
    Callback = function(v)
        Config.HitboxExpander = v
        if not v then ResetHitboxes() end
        Notify("Hitbox Expander", v and "Enabled" or "Disabled", 3)
    end,
})

HitboxSec:AddDivider()

HitboxSec:AddSlider({
    Title     = "Hitbox Scale",
    Content   = "Ukuran hitbox musuh",
    Min = 2, Max = 50, Default = 10, Increment = 1,
    Callback  = function(v) Config.HitboxScale = v end,
})

-- ══════════════════════════════════════════════════════════════
--  TAB: MOVEMENT
-- ══════════════════════════════════════════════════════════════
local MoveSec = Tabs.Movement:AddSection({ Title = "Movement Settings", Icon = "lucide:run", Open = true })

MoveSec:AddToggle({
    Title   = "Speed Hack",
    Content = "Aktifkan speed custom",
    Default = false,
    Callback = function(v)
        Config.SpeedEnabled = v
        local hum = GetHum()
        if hum then
            if v then
                hum.WalkSpeed = Config.SpeedValue
            else
                if hum and hum.Parent then hum.WalkSpeed = 16 end
            end
        end
        Notify("Speed Hack", v and ("Enabled · " .. Config.SpeedValue) or "Disabled", 3)
    end,
})

MoveSec:AddDivider()

MoveSec:AddSlider({
    Title     = "Walk Speed",
    Content   = "Nilai speed yang diinginkan",
    Min = 1, Max = 999, Default = 28, Increment = 1,
    Callback  = function(v)
        Config.SpeedValue = v
        if Config.SpeedEnabled then
            local hum = GetHum()
            if hum and hum.Parent then hum.WalkSpeed = v end
        end
    end,
})

MoveSec:AddDivider()

MoveSec:AddToggle({
    Title   = "Noclip",
    Content = "Tembus dinding dan objek",
    Default = false,
    Callback = function(v)
        Config.NoclipEnabled = v
        if v then StartNoclip() else StopNoclip() end
        Notify("Noclip", v and "Enabled" or "Disabled", 3)
    end,
})

MoveSec:AddDivider()

MoveSec:AddToggle({
    Title   = "Infinite Jump",
    Content = "Lompat berkali-kali di udara",
    Default = false,
    Callback = function(v)
        Config.InfJump = v
        if v then SetupInfJump() end
        Notify("Infinite Jump", v and "Enabled" or "Disabled", 3)
    end,
})

-- ══════════════════════════════════════════════════════════════
--  TAB: VISUAL
-- ══════════════════════════════════════════════════════════════
local VisSec = Tabs.Visual:AddSection({ Title = "Visual Settings", Icon = "lucide:eye", Open = true })

VisSec:AddToggle({
    Title   = "Player ESP",
    Content = "Highlight semua pemain + HP + jarak",
    Default = false,
    Callback = function(v)
        Config.ESPEnabled = v
        if v then EnableAllESP() else DisableAllESP() end
        Notify("Player ESP", v and "Enabled" or "Disabled", 3)
    end,
})

-- ══════════════════════════════════════════════════════════════
--  STARTUP
-- ══════════════════════════════════════════════════════════════
if Alert then pcall(Alert, Window, Tabs) end

task.wait(0.5)
VelarisUI:MakeNotify({
    Title       = "elbilll | Hooked",
    Description = "Loaded successfully! Welcome, " .. plr.Name .. "!",
    Color       = "Red",
    Time        = 0.5,
    Delay       = 5,
})