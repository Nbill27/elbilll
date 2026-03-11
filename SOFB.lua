local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local plr   = game.Players.LocalPlayer
local rs    = game:GetService("RunService")
local vim   = game:GetService("VirtualInputManager")
local RS    = game:GetService("ReplicatedStorage")

local brainrot  = false
local cash      = false
local afk       = false
local antilag   = false
local invis     = false
local noclip    = false
local speed     = false
local autoIndex = false  -- NEW

local spd         = 50
local brdelay     = 1.5
local cashdelay   = 0.5

local farmMode    = "All"local brloop      = nil
local cashloop    = nil
local indexloop   = nil   -- NEW
local nocliploop  = nil
local speedloop   = nil
local afkconn     = nil
local promptconn  = nil
local chair       = nil


local savedBasePos = nil


local function getChar()  return plr.Character or plr.CharacterAdded:Wait() end
local function getHum()   local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()  local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function setTrans(val)
    local c = getChar(); if not c then return end
    for _, v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart"then
            v.Transparency = val
        end
    end
end

local function killLag()
    settings().Rendering.QualityLevel = 1
    local l = game:GetService("Lighting")
    l.GlobalShadows = false; l.FogEnd = 1e5
end

local function Notify(title, content, duration)
    WindUI:Notify({ Title = title, Content = content, Duration = duration or 3, CanClose = true })
end

local function saveBase()
    local root = getRoot()
    if root then
        savedBasePos = root.CFrame
        Notify("Base Saved", "Posisi base tersimpan!", 2)
    end
end

local function returnToBase()
    local root = getRoot()
    if not root then return end
    if savedBasePos then
        root.CFrame = savedBasePos
    else
        
        pcall(function()
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in pairs(plots:GetChildren()) do
                    -- Cek owner plot
                    local owner = plot:FindFirstChild("Owner") or plot:FindFirstChild("PlotOwner")
                    if owner and (owner.Value == plr or owner.Value == plr.Name or owner.Value == plr.UserId) then
                        local basePad = plot:FindFirstChild("SpawnPad")
                            or plot:FindFirstChild("Base")
                            or plot:FindFirstChildWhichIsA("BasePart")
                        if basePad then
                            root.CFrame = basePad.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end)
    end
end

local function getCoinValue(item)
    local v = item:GetAttribute("Income")
    if v then return tonumber(v) or 0 end
    return 0
end


local function getRarity(item)
    local r = item:GetAttribute("Rarity")
    if r then return tostring(r):lower() end
    return ""end

local function shouldFarm(item)
    if farmMode == "All"or farmMode == "Best (Most Coins)"then return true end
    local rarity = getRarity(item)
    if farmMode == "Secret"then return rarity == "secret"end
    if farmMode == "Mythic"then return rarity == "mythic"end
    if farmMode == "Mythic & Secret"then return rarity == "mythic"or rarity == "secret"end
    return true
end

local function pickTarget(folder, root)
    local candidates = {}
    for _, item in pairs(folder:GetChildren()) do
        local hitbox = item:FindFirstChild("ServerHitbox") or (item:IsA("BasePart") and item)
        if hitbox then
            if shouldFarm(hitbox) then
                table.insert(candidates, hitbox)
            end
        end
    end
    if #candidates == 0 then return nil end

    if farmMode == "Best (Most Coins)"then
        table.sort(candidates, function(a, b)
            return getCoinValue(a) > getCoinValue(b)
        end)
        return candidates[1]
    else
        local target, maxDist = nil, -1
        for _, item in ipairs(candidates) do
            local dist = (root.Position - item.Position).Magnitude
            if dist > maxDist then target = item; maxDist = dist end
        end
        return target
    end
end

local ClaimRemote = nil
pcall(function()
    ClaimRemote = RS.Remotes.NewBrainrotIndex.ClaimBrainrotIndex
end)

local function scanBrainrotList()
    local results = {}
    local seen    = {}

    local searchRoots = {}
    pcall(function()
        for _, name in ipairs({"BrainrotData","Brainrots","GameData","Data","Assets","Config"}) do
            local obj = RS:FindFirstChild(name)
            if obj then table.insert(searchRoots, obj) end
        end
    end)
    pcall(function()
        local folder = workspace:FindFirstChild("ActiveBrainrots")
        if folder then table.insert(searchRoots, folder) end
    end)

    for _, root in ipairs(searchRoots) do
        if not root then continue end
        for _, obj in ipairs(root:GetDescendants()) do
        
            if obj:IsA("ModuleScript") then
                pcall(function()
                    local data = require(obj)
                    if type(data) == "table"then
                        for name, info in pairs(data) do
                            if type(name) == "string"and not seen[name] then
                                local rarity = "Normal"if type(info) == "table"then
                                    rarity = info.Rarity or info.rarity or "Normal"end
                                seen[name] = true
                                table.insert(results, { name, rarity })
                            end
                        end
                    end
                end)
            end
            
            if (obj:IsA("Model") or obj:IsA("Folder")) and not seen[obj.Name] then
                local rarity = obj:GetAttribute("Rarity") or "Normal"seen[obj.Name] = true
                table.insert(results, { obj.Name, tostring(rarity) })
            end
            -- ServerHitbox attribute
            if obj:IsA("BasePart") and obj.Name == "ServerHitbox"then
                local brName = obj:GetAttribute("Name")
                    or (obj.Parent and obj.Parent.Name)
                local rarity = obj:GetAttribute("Rarity") or "Normal"if brName and not seen[brName] then
                    seen[brName] = true
                    table.insert(results, { brName, tostring(rarity) })
                end
            end
        end
    end

    if #results == 0 then
        pcall(function()
            local folder = workspace:FindFirstChild("ActiveBrainrots")
            if not folder then return end
            for _, item in ipairs(folder:GetChildren()) do
                if not seen[item.Name] then
                    local rarity = item:GetAttribute("Rarity") or "Normal"seen[item.Name] = true
                    table.insert(results, { item.Name, tostring(rarity) })
                end
            end
        end)
    end

    return results
end

local function claimAllIndex()
    if not ClaimRemote then
        Notify("Index", "Remote ClaimBrainrotIndex tidak ditemukan!", 3)
        return
    end
    local list = scanBrainrotList()
    if #list == 0 then
        Notify("Index", "Tidak ada brainrot ditemukan di game data!", 4)
        return
    end
    local claimed = 0
    for _, entry in ipairs(list) do
        pcall(function()
            ClaimRemote:FireServer(table.unpack(entry))
            claimed += 1
        end)
        task.wait(0.15)
    end
    Notify("Auto Index", "Claimed " .. claimed .. "/" .. #list .. "entries!", 3)
end
 
local Window = WindUI:CreateWindow({
    Title         = "elbilll | Swing Obby",
    Folder        = "elbilll_swingobby",
    Icon          = "bird",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton    = {
        Title           = "elbilll",
        CornerRadius    = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        OnlyMobile      = false,
        Scale           = 1.2,
        Color           = ColorSequence.new(Color3.fromHex("#8B0000"), Color3.fromHex("#1a1a1a")),
    },
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

Window:Tag({ Title = "v1.1", Icon = "bird", Color = Color3.fromHex("#8B0000"), Border = true })


local TMain = Window:Tab({ Title = "Main", Icon = "zap", IconColor = Color3.fromHex("#8B0000"), Border = true })


local FarmSec = TMain:Section({ Title = "Auto Farm Brainrots", Box = true, BoxBorder = true, Opened = true })

FarmSec:Button({
    Title = "Save Base Position",
    Desc    = "Simpan posisi base (lakukan di base SEBELUM farm!)",
    Icon    = "map-pin",
    Justify = "Center",
    Callback = function()
        saveBase()
    end,
})

FarmSec:Space()

FarmSec:Dropdown({
    Flag     = "FarmMode",
    Title    = "Farm Mode",
    Desc     = "Pilih brainrot yang di-target",
    Values   = { "All", "Best (Most Coins)", "Mythic", "Secret", "Mythic & Secret" },
    Value    = "All",
    Multi    = false,
    Callback = function(v)
        farmMode = v
        if brainrot then Notify("Farm Mode", "Changed to: " .. v, 3) end
    end,
})

FarmSec:Space()

FarmSec:Toggle({
    Flag     = "AutoBrainrots",
    Title    = "Auto Brainrots",
    Desc     = "Farm brainrot otomatis. Save base dulu sebelum ON!",
    Value    = false,
    Callback = function(v)
        brainrot = v
        if brainrot then
            
            if not savedBasePos then
                saveBase()
                task.wait(0.2)
            end

            if promptconn then promptconn:Disconnect() end
            for _, child in pairs(workspace:GetDescendants()) do
                if child:IsA("ProximityPrompt") then child.HoldDuration = 0 end
            end
            promptconn = workspace.DescendantAdded:Connect(function(d)
                if d:IsA("ProximityPrompt") then d.HoldDuration = 0 end
            end)

            brloop = task.spawn(function()
                while brainrot do
                    pcall(function()
                        local root = getRoot()
                        if not root then return end
                        local folder = workspace:FindFirstChild("ActiveBrainrots")
                        if not folder then task.wait(1); return end

                        local target = pickTarget(folder, root)
                        if not target then task.wait(1); return end

                        
                        root.CFrame = target.CFrame * CFrame.new(0, 0, 2)
                        task.wait(0.05)

                        
                        local pp = target:FindFirstChildWhichIsA("ProximityPrompt")
                            or (target.Parent and target.Parent:FindFirstChildWhichIsA("ProximityPrompt"))
                        if pp then
                            for i = 1, 3 do
                                if not brainrot then break end
                                pcall(fireproximityprompt, pp)
                                task.wait(0.03)
                            end
                        else
                            -- Fallback: spam E
                            for i = 1, 10 do
                                if not brainrot then break end
                                vim:SendKeyEvent(true,  Enum.KeyCode.E, false, game)
                                task.wait(0.03)
                                vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                                task.wait(0.03)
                            end
                        end

                        task.wait(brdelay)

                        
                        returnToBase()
                        task.wait(0.1)
                    end)
                    task.wait(0.1)
                end
            end)
            Notify("Auto Brainrots", "Enabled · Mode: " .. farmMode, 3)
        else
            if brloop    then task.cancel(brloop); brloop = nil end
            if promptconn then promptconn:Disconnect(); promptconn = nil end
            Notify("Auto Brainrots", "Disabled", 3)
        end
    end,
})

FarmSec:Space()

FarmSec:Slider({
    Flag      = "BrainrotDelay",
    Title     = "Brainrot Delay (seconds)",
    Desc      = "Jeda antar pick brainrot",
    Step      = 0.1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 0.1, Max = 5, Default = 1.5 },
    Callback  = function(v) brdelay = v end,
})

TMain:Space()
local IndexSec = TMain:Section({ Title = "Auto Claim Index", Box = true, BoxBorder = true, Opened = true })

IndexSec:Paragraph({
    Title = "Info",
    Desc  = "Otomatis claim semua entry di Brainrot Index.\nJalankan sekali — tidak perlu loop.",
})

IndexSec:Space()

IndexSec:Button({
    Title = "Claim All Index Now",
    Desc     = "Fire ClaimBrainrotIndex untuk semua brainrot dalam daftar",
    Icon     = "star",
    Color    = Color3.fromHex("#1a6b3c"),
    Justify  = "Center",
    Callback = function()
        task.spawn(claimAllIndex)
    end,
})

IndexSec:Space()

IndexSec:Toggle({
    Flag     = "AutoIndex",
    Title    = "Auto Claim Loop",
    Desc     = "Claim index terus setiap 30 detik (untuk brainrot baru yang masuk)",
    Value    = false,
    Callback = function(v)
        autoIndex = v
        if v then
            indexloop = task.spawn(function()
                while autoIndex do
                    claimAllIndex()
                    task.wait(30)
                end
            end)
            Notify("Auto Index", "Loop aktif, claim tiap 30 detik.", 3)
        else
            if indexloop then task.cancel(indexloop); indexloop = nil end
            Notify("Auto Index", "Loop dimatikan.", 3)
        end
    end,
})

TMain:Space()
local CashSec = TMain:Section({ Title = "Auto Cash", Box = true, BoxBorder = true, Opened = true })

CashSec:Toggle({
    Flag     = "AutoCash",
    Title    = "Auto Cash",
    Desc     = "Otomatis ambil cash dari semua plots",
    Value    = false,
    Callback = function(v)
        cash = v
        if cash then
            cashloop = task.spawn(function()
                while cash do
                    pcall(function()
                        local root = getRoot()
                        if root then
                            local plots = workspace:FindFirstChild("Plots")
                            if plots then
                                for _, plot in pairs(plots:GetChildren()) do
                                    local pods = plot:FindFirstChild("Pods")
                                    if pods then
                                        for _, pod in pairs(pods:GetChildren()) do
                                            local touch = pod:FindFirstChild("TouchPart")
                                            if touch and touch:FindFirstChild("TouchInterest") then
                                                firetouchinterest(root, touch, 0)
                                                task.wait(0.03 + math.random(0,3)/100)
                                                firetouchinterest(root, touch, 1)
                                            end
                                        end
                                    end
                                    task.wait(0.02 + math.random(0,2)/100)
                                end
                            end
                        end
                    end)
                    task.wait(cashdelay + math.random(0,2)/10)
                end
            end)
            Notify("Auto Cash", "Enabled", 3)
        else
            if cashloop then task.cancel(cashloop); cashloop = nil end
            Notify("Auto Cash", "Disabled", 3)
        end
    end,
})

CashSec:Space()

CashSec:Slider({
    Flag      = "CashDelay",
    Title     = "Cash Delay (seconds)",
    Step      = 0.1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 0.1, Max = 2, Default = 0.5 },
    Callback  = function(v) cashdelay = v end,
})

--  Anti AFK
TMain:Space()
local AfkSec = TMain:Section({ Title = "Misc", Box = true, BoxBorder = true, Opened = true })

AfkSec:Toggle({
    Flag     = "AntiAFK",
    Title    = "Anti AFK",
    Value    = false,
    Callback = function(v)
        afk = v
        if afk then
            if afkconn then afkconn:Disconnect() end
            afkconn = plr.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1 + math.random(0,5)/10)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
            Notify("Anti AFK", "Enabled", 3)
        else
            if afkconn then afkconn:Disconnect(); afkconn = nil end
            Notify("Anti AFK", "Disabled", 3)
        end
    end,
})


local TMove = Window:Tab({ Title = "Movement", Icon = "person-standing", IconColor = Color3.fromHex("#8B0000"), Border = true })
local MoveSec = TMove:Section({ Title = "Movement Settings", Box = true, BoxBorder = true, Opened = true })

MoveSec:Toggle({
    Flag     = "Speed",
    Title    = "Speed Hack",
    Value    = false,
    Callback = function(v)
        speed = v
        local hum = getHum()
        if hum then
            if speed then
                hum.WalkSpeed = spd
                task.spawn(function()
                    while speed do
                        if hum and hum.Parent then
                            if hum.WalkSpeed ~= spd then hum.WalkSpeed = spd end
                        end
                        task.wait(0.3 + math.random(0,3)/10)
                    end
                end)
                Notify("Speed Hack", "Enabled · " .. spd, 3)
            else
                if hum and hum.Parent then hum.WalkSpeed = 16 end
                Notify("Speed Hack", "Disabled", 3)
            end
        end
    end,
})

MoveSec:Space()

MoveSec:Slider({
    Flag      = "SpeedValue",
    Title     = "Speed Value",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 1, Max = 999, Default = 50 },
    Callback  = function(v)
        spd = v
        if speed then local hum=getHum(); if hum and hum.Parent then hum.WalkSpeed=v end end
    end,
})

MoveSec:Space()

MoveSec:Toggle({
    Flag     = "Noclip",
    Title    = "Noclip",
    Value    = false,
    Callback = function(v)
        noclip = v
        if noclip then
            task.spawn(function()
                while noclip do
                    local char = getChar()
                    if char then
                        for _, part in pairs(char:GetDescendants()) do
                            if part:IsA("BasePart") and part.Parent then
                                part.CanCollide = false
                            end
                        end
                    end
                    task.wait(0.2 + math.random(0,3)/10)
                end
            end)
            Notify("Noclip", "Enabled", 3)
        else
            Notify("Noclip", "Disabled", 3)
        end
    end,
})

MoveSec:Space()

MoveSec:Slider({
    Flag      = "JumpPower",
    Title     = "Jump Power",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 50, Max = 200, Default = 50 },
    Callback  = function(v)
        local hum = getHum()
        if hum and hum.Parent then hum.JumpPower = v end
    end,
})


local TVis  = Window:Tab({ Title = "Visual", Icon = "eye", IconColor = Color3.fromHex("#8B0000"), Border = true })
local VisSec = TVis:Section({ Title = "Visual Settings", Box = true, BoxBorder = true, Opened = true })

VisSec:Toggle({
    Flag     = "Invisible",
    Title    = "Invisible",
    Value    = false,
    Callback = function(v)
        invis = v
        if invis then
            setTrans(0.5)
            local root = getRoot()
            if root then
                local saved = root.CFrame
                local char  = getChar()
                char:MoveTo(Vector3.new(-25.95, 84, 3537.55))
                task.wait(0.15 + math.random(0,5)/100)
                if chair then chair:Destroy() end
                chair = Instance.new("Seat")
                chair.Anchored    = false
                chair.CanCollide  = false
                chair.Name        = "invischair"chair.Transparency = 1
                chair.Position    = Vector3.new(-25.95, 84, 3537.55)
                chair.Parent      = workspace
                local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                if torso then
                    local weld = Instance.new("Weld")
                    weld.Part0=chair; weld.Part1=torso; weld.Parent=chair
                end
                chair.CFrame = saved
            end
            Notify("Invisible", "Enabled", 3)
        else
            setTrans(0)
            if chair then chair:Destroy(); chair = nil end
            Notify("Invisible", "Disabled", 3)
        end
    end,
})

VisSec:Space()

VisSec:Toggle({
    Flag     = "AntiLag",
    Title    = "Anti Lag",
    Value    = false,
    Callback = function(v)
        antilag = v
        if antilag then
            killLag()
            Notify("Anti Lag", "Enabled", 3)
        else
            settings().Rendering.QualityLevel = 5
            game:GetService("Lighting").GlobalShadows = true
            Notify("Anti Lag", "Disabled", 3)
        end
    end,
})


task.wait(0.5)
WindUI:Notify({
    Title    = "elbilll | Swing Obby",
    Content  = "v1.1 Loaded!\nSave base dulu sebelum farm.\nAuto Index sudah tersedia.",
    Icon     = "check",
    Duration = 5,
    CanClose = true,
})