local VelarisUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/testUI.lua"))()
local Alert = nil
pcall(function()
    Alert = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/alert%20new%20ui.lua"))()
end)

-- ─── Services & Player ─────────────────────────────────────────
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ─── Helper functions ─────────────────────────────────────────
local function getKnitRF(service, rf)
    return RS:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.7.0")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild(service)
        :WaitForChild("RF")
        :WaitForChild(rf)
end

local function getMyBase()
    local possibleFolders = {"Bases", "Plots"}
    for _, folderName in ipairs(possibleFolders) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, base in ipairs(folder:GetChildren()) do
                local ownerAttr = base:GetAttribute("Owner")
                if ownerAttr then
                    if type(ownerAttr) == "number" and ownerAttr == lp.UserId then
                        return base
                    elseif type(ownerAttr) == "string" and (ownerAttr == lp.Name or ownerAttr == tostring(lp.UserId)) then
                        return base
                    elseif type(ownerAttr) == "Instance" and ownerAttr == lp then
                        return base
                    end
                end
                local ownerObj = base:FindFirstChild("Owner") or base:FindFirstChild("PlotOwner")
                if ownerObj then
                    if ownerObj:IsA("NumberValue") and ownerObj.Value == lp.UserId then
                        return base
                    elseif ownerObj:IsA("StringValue") and (ownerObj.Value == lp.Name or ownerObj.Value == tostring(lp.UserId)) then
                        return base
                    elseif ownerObj:IsA("ObjectValue") and ownerObj.Value == lp then
                        return base
                    end
                end
                local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, part in ipairs(base:GetDescendants()) do
                        if part:IsA("BasePart") and (part.Position - hrp.Position).Magnitude < 30 then
                            return base
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function getBaseIndicatorPos()
    local base = getMyBase()
    if not base then return nil end
    local indicator = base:FindFirstChild("Indicator")
    if not indicator then return nil end
    local main = indicator:FindFirstChild("Main")
    if not main then return nil end
    return main.Position
end

local function getIndexedNames()
    local indexed = {}
    local items = lp.PlayerGui:FindFirstChild("Index")
    if not items then return indexed end
    local container = items:FindFirstChild("Container")
    if not container then return indexed end
    local body = container:FindFirstChild("Body")
    if not body then return indexed end
    local itemsFolder = body:FindFirstChild("Items")
    if not itemsFolder then return indexed end
    for _, categoryFrame in ipairs(itemsFolder:GetChildren()) do
        for _, itemFrame in ipairs(categoryFrame:GetChildren()) do
            local title = itemFrame:FindFirstChild("Title")
            if title and title:IsA("TextLabel") and title.Text ~= "???" then
                indexed[title.Text] = true
            end
        end
    end
    return indexed
end

local function allIndexed()
    local items = lp.PlayerGui:FindFirstChild("Index")
    if not items then return true end
    local container = items:FindFirstChild("Container")
    if not container then return true end
    local body = container:FindFirstChild("Body")
    if not body then return true end
    local itemsFolder = body:FindFirstChild("Items")
    if not itemsFolder then return true end
    for _, categoryFrame in ipairs(itemsFolder:GetChildren()) do
        for _, itemFrame in ipairs(categoryFrame:GetChildren()) do
            local title = itemFrame:FindFirstChild("Title")
            if title and title:IsA("TextLabel") and title.Text == "???" then
                return false
            end
        end
    end
    return true
end

local function teleportTo(pos)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos)
    end
end

-- ─── State variables ──────────────────────────────────────────
local jetpackEnabled = false
local jetpackConnection = nil
local upgradeTypes = {}
local speedAmount = "1"
local powerAmount = "1"
local autoUpgrade = false
local autoPickaxe = false
local autoCollect = false
local autoRebirth = false
local autoDig = false
local autoActivate = false
local autoFarmUnindexed = false
local autoUpgradeBrainrots = false
local maxBrainrotLevel = "35"

-- Loop handles
local upgradeLoop = nil
local pickaxeLoop = nil
local collectLoop = nil
local rebirthLoop = nil
local digLoop = nil
local activateLoop = nil
local farmUnindexedLoop = nil
local brainrotUpgradeLoop = nil

-- ─── Pickaxe helper ───────────────────────────────────────────
local pickaxeOrder = {
    "Wooden Pickaxe",
    "Rusty Pickaxe",
    "Stone Pickaxe",
    "Iron Pickaxe",
    "Golden Pickaxe",
    "Duel Iron Pickaxe",
    "Diamond Pickaxe",
    "Duel Golden Pickaxe",
    "Duel Diamond Pickaxe",
    "Powerdrill",
    "Auto Drill",
    "Hammer Drill",
    "Super Drill",
}

local validPickaxes = {}
for _, name in ipairs(pickaxeOrder) do validPickaxes[name] = true end

local function getExcavatorTool()
    local char = lp.Character
    if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and validPickaxes[tool.Name] then
            return tool
        end
    end
end

local function getDigPosition()
    local char = lp.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = { workspace.Terrain }
    local directions = {
        root.CFrame.LookVector * 5,
        Vector3.new(0, -5, 0),
        root.CFrame.LookVector * 3 + Vector3.new(0, -2, 0),
    }
    for _, dir in ipairs(directions) do
        local result = workspace:Raycast(root.Position, dir, params)
        if result then
            return result.Position
        end
    end
    return root.Position + root.CFrame.LookVector * 4
end

-- ─── Remote references ────────────────────────────────────────
local UpgradeRF = getKnitRF("UpgradeService", "Upgrade")
local BuyRF = getKnitRF("ExcavatorService", "Buy")
local ClaimRF = getKnitRF("ButtonService", "Claim")
local RebirthRF = getKnitRF("RebirthService", "Rebirth")
local HitRemote = getKnitRF("ExcavatorService", "Hit")
local BrainrotUpgradeRemote = getKnitRF("LevellingService", "Upgrade")
local CarryRemote = getKnitRF("CarryService", "Carry")

-- ─── UI Creation ──────────────────────────────────────────────
local Window = VelarisUI:Window({
    Title = "elbilll | ",
    Footer = "Dig for Brainrots!",
    Color = "Red",
    Version = 1.0,
    ["Tab Width"] = 110,
    Image = "107802296255222",
    Configname = "digdeeper",
    ShowUser = true,
    Search = true,
    Config = { AutoSave = true, AutoLoad = true },
})

local Tabs = {
    Info = Window:AddTab({ Name = "Info", Icon = "lucide:info" }),
    Core = Window:AddTab({ Name = "Core", Icon = "lucide:pickaxe" }),
    Enhance = Window:AddTab({ Name = "Enhance", Icon = "lucide:wrench" }),
    Travel = Window:AddTab({ Name = "Travel", Icon = "lucide:map-pin" }),
}

-- ─── Info Tab ─────────────────────────────────────────────────
local InfoSec = Tabs.Info:AddSection({ Title = "Welcome to elbilll!", Icon = "lucide:info", Open = true })
InfoSec:AddParagraph({
    Title   = "elbilll Alert!",
    Content = "This script is designed to enhance your gameplay experience.\nDetection is always possible in public servers — use responsibly.\n\nJob ID: " .. (game.JobId ~= "" and game.JobId or "N/A"),
})
InfoSec:AddButton({
    Title    = "Copy Discord Link",
    Callback = function()
        pcall(function()
            if setclipboard then setclipboard("https://discord.gg/nJHyfxNMqm")
            elseif toclipboard then toclipboard("https://discord.gg/nJHyfxNMqm") end
        end)
        VelarisUI:MakeNotify({
            Title = "Discord",
            Description = "Link copied to clipboard!",
            Color = "Red",
            Time = 0.5,
            Delay = 3,
        })
    end,
})

-- ─── Core Tab ─────────────────────────────────────────────────
local CoreSec = Tabs.Core:AddSection({ Title = "Core Features", Icon = "lucide:settings", Open = true })

-- Inf Jetpack
CoreSec:AddToggle({
    Title = "Infinite Jetpack Fuel",
    Default = false,
    Callback = function(v)
        jetpackEnabled = v
        if jetpackEnabled then
            local Knit = require(RS.Packages.Knit)
            local RunService = game:GetService("RunService")
            local JetpackController = Knit.GetController("JetpackController")
            if not JetpackController then
                jetpackEnabled = false
                return
            end
            jetpackConnection = RunService.Heartbeat:Connect(function()
                if JetpackController and JetpackController._maxFuel then
                    JetpackController._fuel = JetpackController._maxFuel
                end
            end)
        else
            if jetpackConnection then
                jetpackConnection:Disconnect()
                jetpackConnection = nil
                local Knit = require(RS.Packages.Knit)
                local JetpackController = Knit.GetController("JetpackController")
                if JetpackController then
                    JetpackController._fuel = 1
                end
            end
        end
    end,
})

-- Auto Buy Pickaxes
CoreSec:AddToggle({
    Title = "Auto Buy Pickaxes",
    Default = false,
    Callback = function(v)
        autoPickaxe = v
        if autoPickaxe then
            pickaxeLoop = task.spawn(function()
                while autoPickaxe do
                    local gui = lp.PlayerGui
                    local scroll = gui:FindFirstChild("Pickaxes")
                        and gui.Pickaxes:FindFirstChild("Container")
                        and gui.Pickaxes.Container:FindFirstChild("Body")
                        and gui.Pickaxes.Container.Body:FindFirstChild("Scroll")
                    if scroll then
                        local allOwned = true
                        for i = #pickaxeOrder, 1, -1 do
                            local name = pickaxeOrder[i]
                            local frame = scroll:FindFirstChild(name)
                            if frame then
                                local equipBtn = frame:FindFirstChild("Buttons")
                                    and frame.Buttons:FindFirstChild("Equip")
                                if equipBtn and not equipBtn.Visible then
                                    allOwned = false
                                    BuyRF:InvokeServer(name)
                                    task.wait(0.1)
                                end
                            else
                                allOwned = false
                            end
                        end
                        if allOwned then
                            autoPickaxe = false
                            VelarisUI:MakeNotify({
                                Title = "Auto Buy Pickaxes",
                                Description = "All pickaxes purchased!",
                                Color = "Red",
                                Time = 0.5,
                                Delay = 5,
                            })
                            break
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            if pickaxeLoop then task.cancel(pickaxeLoop); pickaxeLoop = nil end
        end
    end,
})

-- Auto Collect Money
CoreSec:AddToggle({
    Title = "Auto Collect Money",
    Default = false,
    Callback = function(v)
        autoCollect = v
        if autoCollect then
            collectLoop = task.spawn(function()
                while autoCollect do
                    local Bases = workspace:FindFirstChild("Bases")
                    if Bases then
                        for _, base in ipairs(Bases:GetChildren()) do
                            if base:GetAttribute("Owner") == lp.UserId then
                                local buttons = base:FindFirstChild("Buttons")
                                if buttons then
                                    for _, slot in ipairs(buttons:GetChildren()) do
                                        if not autoCollect then break end
                                        ClaimRF:InvokeServer(slot)
                                        task.wait(0.05)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            if collectLoop then task.cancel(collectLoop); collectLoop = nil end
        end
    end,
})

-- Auto Rebirth
CoreSec:AddToggle({
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(v)
        autoRebirth = v
        if autoRebirth then
            rebirthLoop = task.spawn(function()
                while autoRebirth do
                    RebirthRF:InvokeServer()
                    task.wait(1)
                end
            end)
        else
            if rebirthLoop then task.cancel(rebirthLoop); rebirthLoop = nil end
        end
    end,
})

-- Auto Dig (visual only)
CoreSec:AddToggle({
    Title = "Auto Dig (visual)",
    Description = "Better but only visible to you",
    Default = false,
    Callback = function(v)
        autoDig = v
        if autoDig then
            digLoop = task.spawn(function()
                while autoDig do
                    local char = lp.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        workspace.Terrain:FillBlock(
                            hrp.CFrame,
                            Vector3.new(20, 165, 20),
                            Enum.Material.Air
                        )
                    end
                    task.wait(0.1)
                end
            end)
        else
            if digLoop then task.cancel(digLoop); digLoop = nil end
        end
    end,
})

-- Auto Activate (legit dig)
CoreSec:AddToggle({
    Title = "Auto Dig (legit)",
    Description = "Legit version",
    Default = false,
    Callback = function(v)
        autoActivate = v
        if autoActivate then
            activateLoop = task.spawn(function()
                while autoActivate do
                    local tool = getExcavatorTool()
                    local pos = getDigPosition()
                    if tool and pos then
                        HitRemote:InvokeServer(tool, pos, workspace:GetServerTimeNow())
                    end
                    task.wait(0.01)
                end
            end)
        else
            if activateLoop then task.cancel(activateLoop); activateLoop = nil end
        end
    end,
})

CoreSec:AddDivider()

-- Auto Farm Unindexed
CoreSec:AddToggle({
    Title = "Auto Farm Unindexed",
    Description = "Automatically carries unindexed brainrots to base",
    Default = false,
    Callback = function(v)
        autoFarmUnindexed = v
        if autoFarmUnindexed then
            farmUnindexedLoop = task.spawn(function()
                local POSITIONS = {
                    Vector3.new(-1006, 377,   -692),
                    Vector3.new(-1005, 4340,  -691),
                    Vector3.new(-1011, 7712,  -692),
                    Vector3.new(-1012, 9656,  -693),
                    Vector3.new(-1012, 10608, -692),
                    Vector3.new(-1012, 11156, -693),
                    Vector3.new(-1012, 11368, -691),
                    Vector3.new(-1012, 11496, -692),
                    Vector3.new(-1011, 11596, -690),
                }
                while autoFarmUnindexed do
                    if allIndexed() then
                        task.wait(1)
                    else
                        for posIndex = 1, #POSITIONS do
                            if not autoFarmUnindexed then break end
                            if allIndexed() then break end
                            teleportTo(POSITIONS[posIndex])
                            task.wait(1.5)
                            if not autoFarmUnindexed then break end
                            local indexed = getIndexedNames()
                            local zonesFolder = workspace:FindFirstChild("Zones")
                            local visuals = zonesFolder and zonesFolder:FindFirstChild("Visuals")
                            if visuals then
                                for _, zone in ipairs(visuals:GetChildren()) do
                                    if not autoFarmUnindexed then break end
                                    local brainrotsOuter = zone:FindFirstChild("Brainrots")
                                    local brainrotsFolder = brainrotsOuter and brainrotsOuter:FindFirstChild("Brainrots")
                                    if brainrotsFolder then
                                        for _, part in ipairs(brainrotsFolder:GetChildren()) do
                                            if not autoFarmUnindexed then break end
                                            local partType = part:GetAttribute("Type")
                                            if partType and not indexed[partType] then
                                                CarryRemote:InvokeServer(part)
                                                local basePos = getBaseIndicatorPos()
                                                if basePos then
                                                    teleportTo(basePos)
                                                end
                                                task.wait(1.5)
                                                teleportTo(POSITIONS[posIndex])
                                                task.wait(1.5)
                                                indexed = getIndexedNames()
                                                if allIndexed() then break end
                                            end
                                        end
                                    end
                                    if allIndexed() then break end
                                end
                            end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        else
            if farmUnindexedLoop then task.cancel(farmUnindexedLoop); farmUnindexedLoop = nil end
        end
    end,
})

-- ─── Enhance Tab ──────────────────────────────────────────────
local EnhanceSec = Tabs.Enhance:AddSection({ Title = "Stat Upgrades", Icon = "lucide:trending-up", Open = true })

local upgradeTypesDropdown = EnhanceSec:AddDropdown({
    Title = "Upgrade Types",
    Options = { "Speed", "Power", "Run", "Carry" },
    Multi = true,
    Default = {},
    Callback = function(v)
        upgradeTypes = {}
        if type(v) == "table" then
            for k, val in pairs(v) do
                if type(k) == "string" and val == true then upgradeTypes[k] = true
                elseif type(val) == "string" then upgradeTypes[val] = true end
            end
        end
    end,
})

local speedAmountDropdown = EnhanceSec:AddDropdown({
    Title = "Speed Upgrade Amount",
    Options = { "1", "10" },
    Multi = false,
    Default = "1",
    Callback = function(v) speedAmount = v end,
})

local powerAmountDropdown = EnhanceSec:AddDropdown({
    Title = "Power Upgrade Amount",
    Options = { "1", "10" },
    Multi = false,
    Default = "1",
    Callback = function(v) powerAmount = v end,
})

EnhanceSec:AddToggle({
    Title = "Auto Upgrade Stats",
    Default = false,
    Callback = function(v)
        autoUpgrade = v
        if autoUpgrade then
            upgradeLoop = task.spawn(function()
                while autoUpgrade do
                    for upgType, enabled in pairs(upgradeTypes) do
                        if enabled then
                            local amount = 1
                            if upgType == "Speed" then
                                amount = tonumber(speedAmount) or 1
                            elseif upgType == "Power" then
                                amount = tonumber(powerAmount) or 1
                            end
                            UpgradeRF:InvokeServer(upgType, amount)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            if upgradeLoop then task.cancel(upgradeLoop); upgradeLoop = nil end
        end
    end,
})

EnhanceSec:AddDivider()

-- Brainrot Upgrades (in Enhance tab)
local BrainrotSec = Tabs.Enhance:AddSection({ Title = "Brainrot Upgrades", Icon = "lucide:brain", Open = true })

BrainrotSec:AddToggle({
    Title = "Auto Upgrade Brainrots",
    Description = "Automatically upgrades all brainrots in your base",
    Default = false,
    Callback = function(v)
        autoUpgradeBrainrots = v
        if autoUpgradeBrainrots then
            brainrotUpgradeLoop = task.spawn(function()
                while autoUpgradeBrainrots do
                    local maxLevel = tonumber(maxBrainrotLevel) or 35
                    local base = getMyBase()
                    if base then
                        local slotsFolder = base:FindFirstChild("Slots") or base:FindFirstChild("Pods")
                        if slotsFolder then
                            for _, slot in ipairs(slotsFolder:GetChildren()) do
                                local brainrot = slot:FindFirstChild("Brainrot") or slot:FindFirstChildWhichIsA("Model")
                                if brainrot then
                                    local level = brainrot:GetAttribute("Level")
                                    if type(level) == "number" and level < maxLevel then
                                        BrainrotUpgradeRemote:InvokeServer(slot)
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            if brainrotUpgradeLoop then task.cancel(brainrotUpgradeLoop); brainrotUpgradeLoop = nil end
        end
    end,
})

BrainrotSec:AddInput({
    Title = "Max Upgrade Level",
    Default = "35",
    Placeholder = "Enter max level...",
    Numeric = true,
    Callback = function(value)
        maxBrainrotLevel = value
    end,
})

-- ─── Travel Tab ───────────────────────────────────────────────
local TravelSec = Tabs.Travel:AddSection({ Title = "Instant Movement", Icon = "lucide:map", Open = true })

TravelSec:AddButton({
    Title = "Teleport Home",
    Callback = function()
        local base = getMyBase()
        if base then
            local indicator = base:FindFirstChild("Indicator")
            local main = indicator and indicator:FindFirstChild("Main")
            if main then
                teleportTo(main.Position + Vector3.new(0, 5, 0))
            end
        end
    end,
})

local zoneCoords = {
    ["Common Zone"] = Vector3.new(-1011, 11596, -690),
    ["Uncommon Zone"] = Vector3.new(-1012, 11496, -692),
    ["Rare Zone"] = Vector3.new(-1012, 11368, -691),
    ["Epic Zone"] = Vector3.new(-1012, 11156, -693),
    ["Legendary Zone"] = Vector3.new(-1012, 10608, -692),
    ["Mythic Zone"] = Vector3.new(-1012, 9656, -693),
    ["Brainrot god Zone"] = Vector3.new(-1011, 7712, -692),
    ["Secret Zone"] = Vector3.new(-1005, 4340, -691),
    ["Celestial Zone"] = Vector3.new(-1006, 372, -692),
}

local zoneDropdown = TravelSec:AddDropdown({
    Title = "Select Zone",
    Options = {
        "Common Zone", "Uncommon Zone", "Rare Zone", "Epic Zone",
        "Legendary Zone", "Mythic Zone", "Brainrot god Zone", "Secret Zone", "Celestial Zone"
    },
    Multi = false,
    Default = "Common Zone",
    Callback = function(v) end,
})

TravelSec:AddButton({
    Title = "Teleport to Zone",
    Callback = function()
        local zone = zoneDropdown:GetValue()
        local coords = zoneCoords[zone]
        if coords then
            teleportTo(coords)
        end
    end,
})

-- ─── Welcome Notification ─────────────────────────────────────
task.wait(0.5)
VelarisUI:MakeNotify({
    Title = "elbilll | Dig for Brainrots",
    Description = "Loaded successfully! Welcome, " .. lp.Name .. "!",
    Color = "Red",
    Time = 0.5,
    Delay = 6,
})