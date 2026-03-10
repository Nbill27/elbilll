-- ── Game ID Check
if game.PlaceId ~= 119987266683883 then
    return
end

local WindUI            = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local RunService        = game:GetService("RunService")
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player            = Players.LocalPlayer

local BASE_CF = CFrame.new(2.260926246643066, 5, -15.772657394409180)

local desiredSpeed     = 16
local speedConn
local noclipConn
local jumpConn
local cheeseThread
local cheeseEnabled    = false
local farmThread
local farmEnabled      = false
local farmDelay        = 1.5
local farmRarityFilter = "All"
local selectedBrainrot

-- ══════════════════════════════════════════════════════════════
--  BRAINROT DATA
-- ══════════════════════════════════════════════════════════════
local RARITY_ORDER = { "Secret","Mythic","Divine","Celestial","Exclusive","Legendary","Epic","Rare","Uncommon","Special","Common" }

local function rarityRank(name)
    if not name then return 999 end
    local n = name:lower()
    for i, r in ipairs(RARITY_ORDER) do
        if n:find(r:lower()) then return i end
    end
    return 999
end

local brainrotList   = {}
local brainrotModels = {}
local brainrotRarity = {}

local function loadBrainrots()
    brainrotList   = {}
    brainrotModels = {}
    brainrotRarity = {}
    local ok = pcall(function()
        local folder = workspace:WaitForChild("GameFolder", 5):WaitForChild("Brainrots", 5)
        for _, rarityFolder in pairs(folder:GetChildren()) do
            for _, model in pairs(rarityFolder:GetChildren()) do
                if model:IsA("Model") then
                    local display = model.Name .. " [" .. rarityFolder.Name .. "]"
                    table.insert(brainrotList, display)
                    brainrotModels[display] = model
                    brainrotRarity[display] = rarityFolder.Name
                end
            end
        end
    end)
    table.sort(brainrotList, function(a, b)
        local ra = rarityRank(brainrotRarity[a])
        local rb = rarityRank(brainrotRarity[b])
        if ra ~= rb then return ra < rb end
        return a < b
    end)
    return ok
end

loadBrainrots()

-- Kumpulkan opsi rarity unik
local rarityOptions = { "All" }
do
    local seen = {}
    for _, d in ipairs(brainrotList) do
        local r = brainrotRarity[d]
        if r and not seen[r] then seen[r] = true; table.insert(rarityOptions, r) end
    end
end

-- ══════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════
local function goBase()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = BASE_CF end
end

local function teleportTo(model)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root or not model then return false end
    local part = model:FindFirstChildWhichIsA("BasePart")
    if not part then return false end
    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 1, 0))
    return true
end

local function collectBrainrot(model)
    if not model then return end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            if firetouchinterest then
                pcall(function() firetouchinterest(root, part, 0); task.wait(0.03); firetouchinterest(root, part, 2) end)
            end
            pcall(function() root.CFrame = CFrame.new(part.Position + Vector3.new(0, 1, 0)) end)
            task.wait(0.04)
            pcall(function()
                for _, o in ipairs(part:GetChildren()) do
                    if o:IsA("ProximityPrompt") then fireproximityprompt(o) end
                    if o:IsA("ClickDetector")   then fireclickdetector(o)   end
                end
            end)
        end
    end
end

local function getAllCheeseIDs()
    local ids, seen = {}, {}
    local function scan(parent)
        for _, obj in ipairs(parent:GetChildren()) do
            local id
            pcall(function()
                id = obj:GetAttribute("ID") or obj:GetAttribute("CheeseID")
                    or obj:GetAttribute("Id") or obj:GetAttribute("uuid")
            end)
            if not id then
                local sv = obj:FindFirstChild("ID") or obj:FindFirstChild("CheeseID")
                if sv and sv:IsA("StringValue") then id = sv.Value end
            end
            if id and not seen[id] then seen[id] = true; table.insert(ids, id) end
            if #obj:GetChildren() > 0 then scan(obj) end
        end
    end
    pcall(function() scan(workspace:WaitForChild("GameFolder", 3)) end)
    pcall(function() scan(workspace) end)
    if #ids == 0 then table.insert(ids, "c2bb11839df04ce1872219bd24c0fc44") end
    return ids
end

-- ══════════════════════════════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title         = "Elbilll | Lava Brainrot",
    Folder        = "elbilll_config",
    Icon          = "skull",
    NewElements   = true,
    HideSearchBar = true,
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

Window:Tag({ Title = "Brainrot", Icon = "skull", Color = Color3.fromHex("#8B0000"), Border = true })

-- Sidebar sections → urutan tampil di sidebar
local TInfo = Window:Tab({ Title = "Info", Icon = "info", Border = true })

TInfo:Section({ Title = "Welcome to elbilll", TextSize = 22, FontWeight = Enum.FontWeight.Bold })
TInfo:Space()
TInfo:Paragraph({
    Title = "elbilll Alert!",
    Desc  = "This script is designed to enhance your gameplay experience!\nWhile it has been carefully optimized, detection is always a possibility in public servers.\n\nIf you have suggestions or encounter any issues, feel free to contact us on Discord!\n\nUse responsibly and enjoy the features!",
})
TInfo:Space()
TInfo:Paragraph({
    Title   = "elbilll Discord",
    Desc    = "Official link discord elbilll!",
    Buttons = {{
        Title    = "Copy Discord Link",
        Icon     = "link",
        Callback = function()
            pcall(function()
                if setclipboard then setclipboard("https://discord.gg/nJHyfxNMqm")
                elseif toclipboard then toclipboard("https://discord.gg/nJHyfxNMqm") end
            end)
            WindUI:Notify({ Title = "Discord", Content = "Link discord berhasil di-copy!", Icon = "check", Duration = 3 })
        end,
    }},
})
TInfo:Space()
TInfo:Paragraph({ Title = "Server Info", Desc = "Job ID: " .. (game.JobId ~= "" and game.JobId or "N/A") })

local S_Main  = Window:Section({ Title = "Main"     })
local S_Farm  = Window:Section({ Title = "Farm"     })
local S_Event = Window:Section({ Title = "Event"    })
local S_Move  = Window:Section({ Title = "Movement" })

local TMain = S_Main:Tab({ Title = "Main", Icon = "zap", IconColor = Color3.fromHex("#8B0000"), Border = true })

TMain:Button({
    Title    = "Disable VIP Doors",
    Desc     = "Removes collision from all VIP doors",
    Callback = function()
        local ok = pcall(function()
            for _, p in ipairs(workspace:WaitForChild("GameFolder",5):WaitForChild("VIPDoors",5):GetChildren()) do
                if p:IsA("BasePart") and p.Name == "VIPDoor" then
                    p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
                end
            end
        end)
        WindUI:Notify({ Title = ok and "VIP Doors" or "Error", Content = ok and "Disabled!" or "Folder not found", Icon = ok and "check" or "x", Duration = 3 })
    end,
})

TMain:Space()

TMain:Toggle({
    Flag     = "LavaToggle",
    Title    = "Disable Lavas",
    Desc     = "Makes lava transparent and harmless",
    Value    = false,
    Callback = function(v)
        local ok = pcall(function()
            for _, p in ipairs(workspace:WaitForChild("GameFolder",5):WaitForChild("Lavas",5):GetChildren()) do
                if p:IsA("BasePart") then
                    p.CanCollide = not v; p.CanTouch = not v; p.CanQuery = not v
                    p.Transparency = v and 1 or 0
                end
            end
        end)
        if not ok then WindUI:Notify({ Title = "Error", Content = "Lavas folder not found", Icon = "x", Duration = 3 }) end
    end,
})

TMain:Space()

-- Brainrot selector + teleport manual
local BrainrotDD = TMain:Dropdown({
    Flag     = "BrainrotSelect",
    Title    = "Select Brainrot",
    Desc     = "Pick a target for farming or teleport",
    Values   = brainrotList,
    Default  = 1,
    Multi    = false,
    Callback = function(v) selectedBrainrot = v end,
})

TMain:Space()

TMain:Button({
    Title    = "Refresh List",
    Desc     = "Reload brainrots from workspace",
    Icon     = "refresh-cw",
    Callback = function()
        local ok = loadBrainrots()
        pcall(function() if BrainrotDD then BrainrotDD:SetValues(brainrotList) end end)
        WindUI:Notify({ Title = "Brainrots", Content = ok and (#brainrotList.." found") or "Folder not found", Icon = ok and "check" or "x", Duration = 3 })
    end,
})

TMain:Space()

TMain:Button({
    Title    = "Teleport to Brainrot",
    Desc     = "Instantly move to the selected target",
    Icon     = "map-pin",
    Callback = function()
        if not selectedBrainrot then
            WindUI:Notify({ Title = "Teleport", Content = "Please select a brainrot first!", Icon = "x", Duration = 3 }); return
        end
        local ok = teleportTo(brainrotModels[selectedBrainrot])
        WindUI:Notify({ Title = "Teleport", Content = ok and ("Arrived at "..selectedBrainrot) or "Target parts not found!", Icon = ok and "check" or "x", Duration = 3 })
    end,
})

--TAB  ·  FARM
local TFarm = S_Farm:Tab({ Title = "Farm", Icon = "wheat", IconColor = Color3.fromHex("#8B0000"), Border = true })

TFarm:Dropdown({
    Flag     = "FarmRarity",
    Title    = "Rarity Filter",
    Desc     = "Choose rarity to farm (or 'All' for everything)",
    Values   = rarityOptions,
    Default  = 1,
    Multi    = false,
    Callback = function(v) farmRarityFilter = v end,
})

TFarm:Space()

TFarm:Slider({
    Flag      = "FarmDelay",
    Title     = "Farm Delay (Seconds)",
    Desc      = "Wait time between each collection",
    Step      = 0.5,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 0.5, Max = 10, Default = 1.5 },
    Callback  = function(v) farmDelay = v end,
})

TFarm:Space()

TFarm:Toggle({
    Flag     = "AutoFarm",
    Title    = "Auto Farm",
    Desc     = "Loop: Teleport -> Collect -> Base -> Repeat",
    Value    = false,
    Callback = function(v)
        farmEnabled = v
        if v then
            farmThread = task.spawn(function()
                while farmEnabled do
                    loadBrainrots()

                    local targets = {}
                    for _, d in ipairs(brainrotList) do
                        local r = brainrotRarity[d] or ""
                        if farmRarityFilter == "All" or r == farmRarityFilter then
                            table.insert(targets, d)
                        end
                    end

                    if #targets == 0 then
                        WindUI:Notify({ Title = "Farm", Content = "No targets found!", Icon = "x", Duration = 3 })
                        farmEnabled = false; break
                    end

                    for _, d in ipairs(targets) do
                        if not farmEnabled then break end
                        local model = brainrotModels[d]
                        if not model or not model.Parent then task.wait(0.2); continue end

                        -- 1. Teleport ke brainrot
                        teleportTo(model)
                        selectedBrainrot = d
                        task.wait(0.5)

                        -- 2. Collect
                        collectBrainrot(model)
                        task.wait(0.3)

                        -- 3. Balik base
                        goBase()

                        -- 4. Delay
                        task.wait(farmDelay)
                    end

                    task.wait(1)
                end
            end)
            WindUI:Notify({ Title = "Auto Farm", Content = "Enabled • Filter: "..farmRarityFilter, Icon = "check", Duration = 3 })
        else
            farmEnabled = false
            if farmThread then task.cancel(farmThread); farmThread = nil end
            WindUI:Notify({ Title = "Auto Farm", Content = "Disabled", Icon = "x", Duration = 3 })
        end
    end,
})


-- TAB VENT
local TEvent = S_Event:Tab({ Title = "Event", Icon = "star", IconColor = Color3.fromHex("#8B0000"), Border = true })

TEvent:Toggle({
    Flag     = "AutoCheese",
    Title    = "Auto Collect Cheese",
    Desc     = "Automatically fires collection for all cheese",
    Value    = false,
    Callback = function(v)
        cheeseEnabled = v
        if v then
            cheeseThread = task.spawn(function()
                local remote = ReplicatedStorage.Remotes.CheeseEvent.CollectCheese
                while cheeseEnabled do
                    for _, id in ipairs(getAllCheeseIDs()) do
                        if not cheeseEnabled then break end
                        pcall(function() remote:FireServer({ [1] = id }) end)
                        task.wait(0.05)
                    end
                    task.wait(0.2)
                end
            end)
            WindUI:Notify({ Title = "Cheese", Content = "Auto Collection Started", Icon = "check", Duration = 3 })
        else
            cheeseEnabled = false
            if cheeseThread then task.cancel(cheeseThread); cheeseThread = nil end
            WindUI:Notify({ Title = "Cheese", Content = "Auto Collection Stopped", Icon = "x", Duration = 3 })
        end
    end,
})

TEvent:Space()

TEvent:Button({
    Title    = "Collect Cheese Once",
    Desc     = "collection one time for all available (maybe work)",
    Icon     = "mouse-pointer-click",
    Callback = function()
        local remote = ReplicatedStorage.Remotes.CheeseEvent.CollectCheese
        local ids, count = getAllCheeseIDs(), 0
        for _, id in ipairs(ids) do
            if pcall(function() remote:FireServer({ [1] = id }) end) then count = count + 1 end
            task.wait(0.05)
        end
        WindUI:Notify({ Title = "Cheese", Content = count.."/"..#ids.." items collected", Icon = count > 0 and "check" or "x", Duration = 3 })
    end,
})

--  TAB  ·  MOVEMENT
local TMove = S_Move:Tab({ Title = "Movement", Icon = "person-standing", IconColor = Color3.fromHex("#8B0000"), Border = true })

TMove:Slider({
    Flag      = "WalkSpeed",
    Title     = "Walk Speed",
    Desc      = "Default: 16",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 1, Max = 100, Default = 16 },
    Callback  = function(v)
        desiredSpeed = v
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.Heartbeat:Connect(function()
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = desiredSpeed end
        end)
    end,
})

TMove:Space()

TMove:Slider({
    Flag      = "JumpPower",
    Title     = "Jump Power",
    Desc      = "Default: 50",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 1, Max = 200, Default = 50 },
    Callback  = function(v)
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
    end,
})

TMove:Space()

TMove:Toggle({
    Flag     = "Noclip",
    Title    = "Noclip",
    Desc     = "Walk through walls and objects",
    Value    = false,
    Callback = function(v)
        if v then
            noclipConn = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, p in ipairs(player.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
            if player.Character then
                for _, p in ipairs(player.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end
    end,
})

TMove:Space()

TMove:Toggle({
    Flag     = "InfJump",
    Title    = "Infinite Jump",
    Desc     = "Allows jumping multiple times in the air",
    Value    = false,
    Callback = function(v)
        if v then
            jumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
        end
    end,
})

TMove:Space()

TMove:Button({
    Title    = "Teleport to Base",
    Desc     = "Instantly return to the spawn base",
    Icon     = "home",
    Callback = function()
        goBase()
        WindUI:Notify({ Title = "Teleport", Content = "Returned to base!", Icon = "check", Duration = 3 })
    end,
})

--  STARTUP
task.wait(0.5)
WindUI:Notify({ Title = "Elbilll | Lava Brainrot", Content = "Loaded!", Icon = "check", Duration = 5, CanClose = true })