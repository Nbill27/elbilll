local VelarisUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/testUI.lua"))()
local Alert = nil
pcall(function()
    Alert = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/alert%20new%20ui.lua"))()
end)

-- ─── Services & Player ───────────────────────────────────────
local lp  = game.Players.LocalPlayer
local rs  = game:GetService("RunService")

-- ─── Koordinat ───────────────────────────────────────────────
local COORDS = {
    Secret    = CFrame.new(571,  36,  13),
    Celestial = CFrame.new(827,  36,   0),
    Divine    = CFrame.new(924,  36,  -7),
}

-- ─── State ───────────────────────────────────────────────────
local boostActive    = false
local boostSpd       = 48
local boostJmp       = 75
local boostLoop      = nil
local farmLoop       = nil
local autoFarmActive = false
local cashDelay      = 5
local baseCF         = nil

-- ─── Helpers ─────────────────────────────────────────────────
local function getChar() return lp.Character or lp.CharacterAdded:Wait() end
local function getHum()  local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function Notify(title, desc, duration)
    VelarisUI:MakeNotify({
        Title       = title,
        Description = desc or "",
        Color       = "Default",
        Time        = 0.5,
        Delay       = duration or 3,
    })
end

local function teleport(cf)
    local root = getRoot()
    if not root then return end
    root.CFrame = cf
    local hum = getHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Landed) end
end

-- ─── Anti CanCollide ─────────────────────────────────────────
rs.Stepped:Connect(function()
    local char = lp.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.CanCollide = false
        end
    end
end)

lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    task.spawn(function()
        while true do
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                    p.CanCollide = false
                end
            end
            task.wait(0.2 + math.random(0, 3) / 10)
        end
    end)
end)

-- ═════════════════════════════════════════════════════════════
--  UI
-- ═════════════════════════════════════════════════════════════
local Window = VelarisUI:Window({
    Title        = "elbilll | Cut Grass",
    Footer       = "",
    Color        = "Red",
    Version      = 1.7,
    ["Tab Width"] = 110,
    Image       = "107802296255222",
    Configname   = "elbilll_cutgrass",
    ShowUser     = true,
    Search       = true,
    Config       = { AutoSave = true, AutoLoad = true },
})

local Tabs = {
    Main      = Window:AddTab({ Name = "Main",      Icon = "lucide:zap" }),
    Teleport  = Window:AddTab({ Name = "Teleport",  Icon = "lucide:map-pin" }),
    Movement  = Window:AddTab({ Name = "Movement",  Icon = "lucide:person-standing" }),
}

-- ─── TAB: MAIN ───────────────────────────────────────────────
local FarmSec = Tabs.Main:AddSection({ Title = "Auto Farm Cash", Icon = "lucide:coins", Open = true })

FarmSec:AddToggle({
    Title   = "Auto Collect Cash",
    Content = "Touch semua Active_part setiap N detik",
    Default = false,
    Callback = function(v)
        autoFarmActive = v
        if v then
            farmLoop = task.spawn(function()
                while autoFarmActive do
                    pcall(function()
                        local hrp = getRoot()
                        if not hrp then return end
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj.Name == "Active_part" and obj:IsA("BasePart") then
                                firetouchinterest(hrp, obj, 0)
                                task.wait(0.1)
                                firetouchinterest(hrp, obj, 1)
                            end
                        end
                    end)
                    task.wait(cashDelay)
                end
            end)
            Notify("Auto Farm", "Enabled", 3)
        else
            if farmLoop then task.cancel(farmLoop); farmLoop = nil end
            Notify("Auto Farm", "Disabled", 3)
        end
    end,
})

FarmSec:AddSlider({
    Title     = "Cash Delay (seconds)",
    Min       = 0.5, Max = 30, Default = 5, Increment = 0.5,
    Callback  = function(v) cashDelay = v end,
})

FarmSec:AddDivider()

local GrassSec = Tabs.Main:AddSection({ Title = "Grass", Icon = "lucide:trash-2", Open = true })

GrassSec:AddButton({
    Title    = "Delete Grass",
    Callback = function()
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if string.find(obj.Name, "Grass_") or obj.Name == "AntiJumpCollider" then
                obj:Destroy(); count += 1
            end
        end
        Notify("Delete Grass", "Deleted: " .. count .. " objects", 3)
    end,
})

-- ─── TAB: TELEPORT ───────────────────────────────────────────
local BaseSec = Tabs.Teleport:AddSection({ Title = "Base", Icon = "lucide:home", Open = true })

BaseSec:AddButton({
    Title    = "Save Base",
    Callback = function()
        local root = getRoot()
        if root then
            baseCF = root.CFrame
            Notify("Base", "Base disimpan!", 2)
        end
    end,
    SubTitle = "Simpan posisi base sekarang",
})

BaseSec:AddButton({
    Title    = "TP ke Base",
    Callback = function()
        if not baseCF then Notify("Base", "Base belum disave!", 2); return end
        teleport(baseCF)
        Notify("TP", "Base", 2)
    end,
    SubTitle = "Teleport ke base yang tersimpan",
})

BaseSec:AddDivider()

local TPSec = Tabs.Teleport:AddSection({ Title = "Grass Area", Icon = "lucide:map-pin", Open = true })

TPSec:AddButton({
    Title    = "TP ke Secret",
    Callback = function()
        teleport(COORDS.Secret)
        Notify("TP", "Secret", 2)
    end,
})

TPSec:AddButton({
    Title    = "TP ke Celestial",
    Callback = function()
        teleport(COORDS.Celestial)
        Notify("TP", "Celestial", 2)
    end,
})

TPSec:AddButton({
    Title    = "TP ke Divine",
    Callback = function()
        teleport(COORDS.Divine)
        Notify("TP", "Divine", 2)
    end,
})

-- ─── TAB: MOVEMENT ───────────────────────────────────────────
local MovSec = Tabs.Movement:AddSection({ Title = "Movement Settings", Icon = "lucide:run", Open = true })

MovSec:AddToggle({
    Title   = "Speed & Jump Boost",
    Content = "Custom WalkSpeed & JumpPower",
    Default = false,
    Callback = function(v)
        boostActive = v
        if v then
            boostLoop = task.spawn(function()
                local hum = getHum()
                if not hum then return end
                local cs, cj = hum.WalkSpeed, hum.JumpPower
                for i = 1, 10 do
                    if not boostActive then break end
                    pcall(function()
                        local h = getHum()
                        if h then
                            h.WalkSpeed = cs + (boostSpd - cs) * (i / 10)
                            h.JumpPower = cj + (boostJmp - cj) * (i / 10)
                        end
                    end)
                    task.wait(0.1)
                end
                while boostActive do
                    pcall(function()
                        local h = getHum()
                        if h then
                            if math.abs(h.WalkSpeed - boostSpd) > 1 then h.WalkSpeed = boostSpd end
                            if math.abs(h.JumpPower  - boostJmp) > 1 then h.JumpPower  = boostJmp end
                        end
                    end)
                    task.wait(0.3 + math.random(0, 3) / 10)
                end
            end)
            Notify("Boost", "Enabled", 3)
        else
            if boostLoop then task.cancel(boostLoop); boostLoop = nil end
            task.spawn(function()
                local h = getHum()
                if not h then return end
                local ss, sj = h.WalkSpeed, h.JumpPower
                for i = 1, 5 do
                    pcall(function()
                        local hh = getHum()
                        if hh then
                            hh.WalkSpeed = ss + (16 - ss) * (i / 5)
                            hh.JumpPower = sj + (50 - sj) * (i / 5)
                        end
                    end)
                    task.wait(0.05)
                end
            end)
            Notify("Boost", "Disabled", 3)
        end
    end,
})

MovSec:AddSlider({
    Title     = "Walk Speed",
    Min       = 16, Max = 200, Default = 48, Increment = 1,
    Callback  = function(v)
        boostSpd = v
        if not boostActive then
            pcall(function() local h = getHum(); if h then h.WalkSpeed = v end end)
        end
    end,
})

MovSec:AddSlider({
    Title     = "Jump Power",
    Min       = 50, Max = 500, Default = 75, Increment = 1,
    Callback  = function(v)
        boostJmp = v
        if not boostActive then
            pcall(function() local h = getHum(); if h then h.JumpPower = v end end)
        end
    end,
})

-- ─── Alert & Welcome ─────────────────────────────────────────
if Alert then pcall(Alert, Window, Tabs) end

task.wait(0.5)
VelarisUI:MakeNotify({
    Title       = "elbilll | Cut Grass",
    Description = "Loaded! Welcome, " .. lp.Name .. "!",
    Color       = "Default",
    Time        = 0.5,
    Delay       = 5,
})