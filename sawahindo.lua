local WindUI      = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS          = game:GetService("ReplicatedStorage")

-- ── Remotes ──────────────────────────────────────────────────────────────────
local Remotes    = RS:WaitForChild("Remotes"):WaitForChild("TutorialRemotes")
local RemoteSell = Remotes:WaitForChild("RequestSell")
local RemotePlant= Remotes:WaitForChild("PlantCrop")
local RemoteShop = Remotes:WaitForChild("RequestShop")

-- ── Config ────────────────────────────────────────────────────────────────────
local Config = {
    AutoPlant        = false,
    AutoSell         = false,
    AutoBuy          = false,
    AutoHarvest      = false,
    UseInventorySeed = true,
    AllowedSeeds     = {},
    PlantDelay       = 0.5,
    SellDelay        = 2,
    SellAmount       = 999,
    HarvestDelay     = 0.15,
    BuyDelay         = 1,
    BuyAmount        = 10,
    SelectedSeedIndex= 1,
}

-- ── State ─────────────────────────────────────────────────────────────────────
local PlotPositions       = {}
local ShopSeeds           = {}
local ShopDropdown        = {}
local autoEquipIdx        = 1
local PlotStatusParagraph = nil

-- ════════════════════════════════════════════════════════════════
--  SEED LOGIC
-- ════════════════════════════════════════════════════════════════
local function normalize(s)
    return string.lower((tostring(s or "")):gsub("%s+", " "):match("^%s*(.-)%s*$"))
end

local function resolvePlantType(tool)
    if not tool then return nil end
    local attr = tool:GetAttribute("PlantType")
    if attr and tostring(attr) ~= "" then return tostring(attr) end
    local n = tostring(tool.Name or "")
    return string.match(n, "^[Bb]ibit%s+(.-)%s+[xX]%d+$")
        or string.match(n, "^[Bb]ibit%s+(.+)$")
        or string.match(n, "^[xX]%d+%s+(.+)%s+[Ss]eed")
        or string.match(n, "^(.+)%s+[Ss]eed")
        or n
end

local SEED_KW = { "seed", "bibit", "benih", "biji" }
local function isSeedKeyword(name)
    local nl = normalize(name)
    for _, kw in ipairs(SEED_KW) do
        if string.find(nl, kw, 1, true) then return true end
    end
    return false
end

local function isValidSeedTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool:GetAttribute("IsCrate") or tool:GetAttribute("IsHarvested") then return false end
    local hasAttr = tool:GetAttribute("PlantType") and tostring(tool:GetAttribute("PlantType")) ~= ""
    if not isSeedKeyword(tool.Name) and not hasAttr then return false end
    if #Config.AllowedSeeds > 0 then
        local pt = normalize(resolvePlantType(tool) or "")
        local nl = normalize(tool.Name)
        local ok = false
        for _, a in ipairs(Config.AllowedSeeds) do
            local na = normalize(a)
            if na == pt
            or string.find(nl, na, 1, true)
            or string.find(pt, na, 1, true) then
                ok = true; break
            end
        end
        if not ok then return false end
    end
    return true
end

local function getOrEquipSeedTool()
    local char = LocalPlayer.Character
    if not char then return nil end

    for _, t in ipairs(char:GetChildren()) do
        if isValidSeedTool(t) then return t end
    end

    if not Config.UseInventorySeed then return nil end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
        or LocalPlayer:WaitForChild("Backpack", 2)
    if not backpack then return nil end

    local candidates = {}
    for _, t in ipairs(backpack:GetChildren()) do
        if isValidSeedTool(t) then table.insert(candidates, t) end
    end
    if #candidates == 0 then return nil end

    local order = {}
    if #Config.AllowedSeeds > 0 then
        for _, n in ipairs(Config.AllowedSeeds) do table.insert(order, n) end
    else
        for _, t in ipairs(candidates) do
            local pt = resolvePlantType(t) or t.Name
            if not table.find(order, pt) then table.insert(order, pt) end
        end
    end

    if autoEquipIdx > #order then autoEquipIdx = 1 end
    local preferred = normalize(order[autoEquipIdx])
    autoEquipIdx    = (autoEquipIdx % #order) + 1

    local pick = nil
    for _, t in ipairs(candidates) do
        if string.find(normalize(t.Name), preferred, 1, true) then pick = t; break end
    end
    if not pick then
        for _, t in ipairs(candidates) do
            local pt = resolvePlantType(t)
            if pt and normalize(pt) == preferred then pick = t; break end
        end
    end
    if not pick then pick = candidates[1] end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    for _ = 1, 4 do
        pcall(function()
            humanoid:UnequipTools()
            humanoid:EquipTool(pick)
        end)
        task.wait(0.08)
        if pick:IsDescendantOf(char) then return pick end
        pcall(function() pick.Parent = char end)
        task.wait(0.05)
        if pick:IsDescendantOf(char) then return pick end
    end

    return nil
end

-- ════════════════════════════════════════════════════════════════
--  HARVEST
-- ════════════════════════════════════════════════════════════════
local HARVEST_KW = { "harvest", "panen", "pick", "petik", "collect" }
local function matchHarvest(s)
    s = string.lower(s or "")
    for _, kw in ipairs(HARVEST_KW) do
        if string.find(s, kw, 1, true) then return true end
    end
    return false
end
local function tryHarvestProx()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            if matchHarvest(obj.ActionText or "")
            or matchHarvest(obj.Parent and obj.Parent.Name or "")
            or matchHarvest((obj.Parent and obj.Parent.Parent) and obj.Parent.Parent.Name or "") then
                pcall(function() fireproximityprompt(obj) end)
                task.wait(Config.HarvestDelay)
            end
        end
    end
end
local function tryHarvestTouch()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and matchHarvest(obj.Name) then
            local ti = obj:FindFirstChildOfClass("TouchTransmitter") or obj:FindFirstChild("TouchInterest")
            if ti then
                pcall(function() firetouchinterest(obj, hrp, 0) end)
                task.wait(Config.HarvestDelay)
            end
        end
    end
end

-- ════════════════════════════════════════════════════════════════
--  SHOP
-- ════════════════════════════════════════════════════════════════
local function FetchShopSeeds()
    local ok, data = pcall(function() return RemoteShop:InvokeServer("GET_LIST") end)
    if not ok or type(data) ~= "table" then return end
    local seeds = data.Seeds or data.seeds or data.Items or data.items or data
    if type(seeds) ~= "table" then return end
    ShopSeeds = {}; ShopDropdown = {}
    for i, seed in ipairs(seeds) do
        if type(seed) == "table" then
            local name  = seed.Name or seed.name or seed.ID or seed.ItemName or tostring(i)
            local price = seed.Price or seed.price or "?"
            local label = string.format("[%d] %s — %s koin", i, tostring(name), tostring(price))
            table.insert(ShopSeeds,    { index=i, name=name, price=price, label=label })
            table.insert(ShopDropdown, label)
        end
    end
end
FetchShopSeeds()
if #ShopSeeds == 0 then
    local fb = { "Rice Seeds","Corn Seeds","Tomato Seeds","Eggplant Seeds","Strawberry Seeds","Palm Seeds","Durian Seeds" }
    for i, n in ipairs(fb) do
        table.insert(ShopSeeds,    { index=i, name=n, label=n })
        table.insert(ShopDropdown, n)
    end
end

-- ════════════════════════════════════════════════════════════════
--  HELPER POSISI
-- ════════════════════════════════════════════════════════════════
local function GetHRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end
local function TeleportTo(pos)
    local hrp = GetHRP()
    if hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)); task.wait(0.15) end
end
local function GetGroundPos()
    local hrp = GetHRP()
    if not hrp then return nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), params)
    if result then return result.Position end
    return Vector3.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
end
local function UpdatePlotStatus()
    local txt = #PlotPositions == 0
        and "Belum ada plot (0 posisi)"
        or  "Tersimpan: " .. #PlotPositions .. " plot"
    pcall(function()
        if not PlotStatusParagraph then return end
        if PlotStatusParagraph.SetDesc then PlotStatusParagraph:SetDesc(txt)
        elseif PlotStatusParagraph.Set then PlotStatusParagraph:Set(txt) end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  LOOPS
-- ════════════════════════════════════════════════════════════════

-- Auto Plant
task.spawn(function()
    while true do
        task.wait(Config.PlantDelay)
        if Config.AutoPlant and #PlotPositions > 0 then
            for _, pos in ipairs(PlotPositions) do
                pcall(function()
                    TeleportTo(pos)
                    if Config.UseInventorySeed then
                        getOrEquipSeedTool()
                    end
                    RemotePlant:FireServer(pos)
                end)
                task.wait(0.1)
            end
        end
    end
end)

-- Auto Sell
task.spawn(function()
    local crops = { "Padi","Jagung","Tomat","Terong","Strawberry","Palm","Durian" }
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then
            for _, c in ipairs(crops) do
                pcall(function() RemoteSell:InvokeServer("SELL", c, Config.SellAmount) end)
                task.wait(0.08)
            end
        end
    end
end)

-- Auto Buy
task.spawn(function()
    while true do
        task.wait(Config.BuyDelay)
        if Config.AutoBuy then
            pcall(function()
                local s = ShopSeeds[Config.SelectedSeedIndex]
                if not s then return end
                local ok = pcall(function() RemoteShop:InvokeServer("BUY", s.name, Config.BuyAmount) end)
                if not ok then pcall(function() RemoteShop:InvokeServer("BUY", s.index, Config.BuyAmount) end) end
            end)
        end
    end
end)

-- Auto Harvest
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoHarvest then
            pcall(tryHarvestProx)
            pcall(tryHarvestTouch)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
--  UI — WINDUI
-- ════════════════════════════════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title         = "elbilll 〢Sawah Indo",
    Folder        = "elbilll_config",
    Icon          = "sprout",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton    = {
        Title           = "elbilll 〢 Sawah Indo",
        CornerRadius    = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        OnlyMobile      = false,
        Scale           = 1.2,
        Color           = ColorSequence.new(
            Color3.fromHex("#8B0000"),
            Color3.fromHex("#1a1a1a")
        ),
    },
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

Window:Tag({ Title = "v1.1", Icon = "github", Color = Color3.fromHex("#8B0000"), Border = true })

-- Satu Section saja — semua tab langsung muncul flat
local Sec = Window:Section({ Title = "Menu" })

-- ── TAB INFO ─────────────────────────────────────────────────────────────────
local TabInfo = Sec:Tab({ Title = "Info", Icon = "info", Border = true })

TabInfo:Section({ Title = "elbilll 〢 Sawah Indo", TextSize = 22, FontWeight = Enum.FontWeight.Bold })
TabInfo:Space()

TabInfo:Paragraph({
    Title = "elbilll Notice",
    Desc  = "This script is designed to enhance your gameplay experience!\n"
         .. "While it has been carefully optimized, detection is always a possibility in public servers.\n\n"
         .. "If you have suggestions or encounter any issues, feel free to contact us on Discord!\n\n"
         .. "Use responsibly and enjoy the features!",
    Buttons = {{
        Title = "Copy Discord", Icon = "link",
        Callback = function()
            pcall(function() if setclipboard then setclipboard("https://discord.gg/nJHyfxNMqm") end end)
            WindUI:Notify({ Title="Discord", Content="Link copied!", Icon="check", Duration=3 })
        end,
    }},
})

TabInfo:Space()
TabInfo:Paragraph({
    Title = "Server Info",
    Desc  = "Job ID: " .. (game.JobId ~= "" and game.JobId or "N/A") .. "\nSeed loaded: " .. #ShopSeeds,
})

-- ── TAB FARM ─────────────────────────────────────────────────────────────────
local TabFarm = Sec:Tab({ Title = "Farm", Icon = "shovel", Border = true })

local PlotSection = TabFarm:Section({
    Title = "Plot Manager", Desc = "Berdiri di plot → klik Add Plot",
    Box = true, BoxBorder = true, Opened = true,
})

PlotStatusParagraph = PlotSection:Paragraph({
    Title = "Status Plot",
    Desc  = "Belum ada plot (0 posisi)",
})
PlotSection:Space()

local PlotBtnGrp = PlotSection:Group({})
PlotBtnGrp:Button({
    Title = "Add Plot", Icon = "plus", Justify = "Center", Color = Color3.fromHex("#8B0000"),
    Callback = function()
        local pos = GetGroundPos()
        if not pos then
            WindUI:Notify({ Title="Error", Content="Karakter tidak ditemukan!", Icon="x", Duration=2 })
            return
        end
        table.insert(PlotPositions, pos)
        UpdatePlotStatus()
        WindUI:Notify({
            Title   = "Plot #" .. #PlotPositions .. " ditambah",
            Content = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z),
            Icon    = "map-pin", Duration = 2,
        })
    end,
})
PlotBtnGrp:Space()
PlotBtnGrp:Button({
    Title = "Remove Last", Icon = "minus", Justify = "Center",
    Callback = function()
        if #PlotPositions == 0 then
            WindUI:Notify({ Title="Plot Manager", Content="Tidak ada plot!", Icon="info", Duration=2 })
            return
        end
        table.remove(PlotPositions, #PlotPositions)
        UpdatePlotStatus()
        WindUI:Notify({ Title="Plot dihapus", Content="Sisa: "..#PlotPositions.." plot", Icon="trash", Duration=2 })
    end,
})
PlotBtnGrp:Space()
PlotBtnGrp:Button({
    Title = "Clear All", Icon = "trash-2", Justify = "Center",
    Callback = function()
        PlotPositions = {}
        UpdatePlotStatus()
        WindUI:Notify({ Title="Plot Cleared", Content="Semua plot dihapus.", Icon="check", Duration=2 })
    end,
})

local PlantSection = TabFarm:Section({
    Title = "Auto Plant", Box = true, BoxBorder = true, Opened = true,
})
PlantSection:Toggle({
    Flag = "UseInventorySeed", Title = "Auto Equip Seed dari Inventory",
    Desc = "Ambil & equip seed dari backpack otomatis sebelum nanem",
    Value = true, Callback = function(v) Config.UseInventorySeed = v end,
})
PlantSection:Space()
PlantSection:Toggle({
    Flag = "AutoPlant", Title = "Auto Plant",
    Desc = "Nanem terus di semua plot yang di-add",
    Value = false, Callback = function(v) Config.AutoPlant = v end,
})
PlantSection:Space()
PlantSection:Slider({
    Flag = "PlantDelay", Title = "Plant Delay (s)", Step = 0.1, IsTooltip = true,
    Value = { Min = 0.1, Max = 3, Default = 0.5 },
    Callback = function(v) Config.PlantDelay = v end,
})

-- ── TAB HARVEST ──────────────────────────────────────────────────────────────
local TabHarvest = Sec:Tab({ Title = "Harvest", Icon = "wheat", Border = true })

local HarvestSection = TabHarvest:Section({
    Title = "Auto Harvest", Desc = "panen dilakukan secara otomatis tanpa intervensi manual setiap kali tanaman siap dipanen",
    Box = true, BoxBorder = true, Opened = true,
})
HarvestSection:Toggle({
    Flag = "AutoHarvest", Title = "Auto Harvest",
    Desc = "Panen otomatis saat tanaman siap, tanpa perlu klik manual",
    Value = false, Callback = function(v) Config.AutoHarvest = v end,
})
HarvestSection:Space()
HarvestSection:Slider({
    Flag = "HarvestDelay", Title = "Harvest Delay per Crop (s)", Step = 0.01, IsTooltip = true,
    Value = { Min = 0.05, Max = 1, Default = 0.15 },
    Callback = function(v) Config.HarvestDelay = v end,
})
HarvestSection:Space()
HarvestSection:Button({
    Title = "Harvest Now", Icon = "zap", Justify = "Center", Color = Color3.fromHex("#8B0000"),
    Callback = function()
        pcall(tryHarvestProx); pcall(tryHarvestTouch)
        WindUI:Notify({ Title="Harvest", Content="Triggered!", Icon="check", Duration=2 })
    end,
})

-- ── TAB SELL ─────────────────────────────────────────────────────────────────
local TabSell = Sec:Tab({ Title = "Sell", Icon = "coins", Border = true })

local SellSection = TabSell:Section({
    Title = "Auto Sell", Box = true, BoxBorder = true, Opened = true,
})
SellSection:Toggle({
    Flag = "AutoSell", Title = "Auto Sell All", Desc = "Jual semua crop di inventory otomatis",
    Value = false, Callback = function(v) Config.AutoSell = v end,
})
SellSection:Space()
SellSection:Slider({
    Flag = "SellDelay", Title = "Sell Interval (s)", Step = 0.5, IsTooltip = true,
    Value = { Min = 0.5, Max = 10, Default = 2 },
    Callback = function(v) Config.SellDelay = v end,
})
SellSection:Space()
SellSection:Button({
    Title = "Sell Now", Icon = "banknote", Justify = "Center", Color = Color3.fromHex("#8B0000"),
    Callback = function()
        local crops = { "Padi","Jagung","Tomat","Terong","Strawberry","Palm","Durian" }
        for _, c in ipairs(crops) do
            pcall(function() RemoteSell:InvokeServer("SELL", c, 999) end)
            task.wait(0.05)
        end
        WindUI:Notify({ Title="Sell", Content="Semua crop terjual!", Icon="check", Duration=3 })
    end,
})

-- ── TAB SHOP ─────────────────────────────────────────────────────────────────
local TabShop = Sec:Tab({ Title = "Shop", Icon = "shopping-bag", Border = true })

local ShopSection = TabShop:Section({
    Title = "Auto Buy", Box = true, BoxBorder = true, Opened = true,
})
ShopSection:Dropdown({
    Flag = "SeedSelect", Title = "Pilih Seed",
    Desc = "Data dari GET_LIST (" .. #ShopSeeds .. " seed)",
    Values = ShopDropdown, Value = ShopDropdown[1],
    Callback = function(val)
        for i, l in ipairs(ShopDropdown) do
            if l == val then Config.SelectedSeedIndex = i; break end
        end
    end,
})
ShopSection:Space()
ShopSection:Toggle({
    Flag = "AutoBuy", Title = "Auto Buy Seed", Desc = "Beli seed yang dipilih secara otomatis",
    Value = false, Callback = function(v) Config.AutoBuy = v end,
})
ShopSection:Space()
ShopSection:Slider({
    Flag = "BuyAmount", Title = "Jumlah Beli per Cycle", Step = 1, IsTooltip = true,
    Value = { Min = 1, Max = 100, Default = 10 },
    Callback = function(v) Config.BuyAmount = v end,
})
ShopSection:Space()
ShopSection:Slider({
    Flag = "BuyDelay", Title = "Buy Interval (s)", Step = 0.5, IsTooltip = true,
    Value = { Min = 0.5, Max = 10, Default = 1 },
    Callback = function(v) Config.BuyDelay = v end,
})
ShopSection:Space()
local ShopBtnGrp = ShopSection:Group({})
ShopBtnGrp:Button({
    Title = "Buy Now", Icon = "shopping-cart", Justify = "Center", Color = Color3.fromHex("#8B0000"),
    Callback = function()
        pcall(function()
            local s = ShopSeeds[Config.SelectedSeedIndex]
            if s then RemoteShop:InvokeServer("BUY", s.name, Config.BuyAmount) end
        end)
        WindUI:Notify({ Title="Buy", Content="Pembelian selesai", Icon="check", Duration=2 })
    end,
})
ShopBtnGrp:Space()
ShopBtnGrp:Button({
    Title = "Refresh", Icon = "refresh-cw", Justify = "Center",
    Callback = function()
        FetchShopSeeds()
        WindUI:Notify({ Title="Shop", Content=#ShopSeeds.." seed di-load!", Icon="check", Duration=2 })
    end,
})

-- ── TAB SETTINGS ─────────────────────────────────────────────────────────────
local TabSettings = Sec:Tab({ Title = "Settings", Icon = "settings", Border = true })

TabSettings:Keybind({
    Flag = "ToggleKey", Title = "Toggle UI Key", Desc = "Tombol buka/tutup UI",
    Value = "RightShift",
    Callback = function(key)
        pcall(function() Window:SetToggleKey(Enum.KeyCode[key]) end)
    end,
})

-- ── LAUNCH ────────────────────────────────────────────────────────────────────
WindUI:Notify({
    Title    = "elbilll 〢Sawah Indo",
    Content  = "Script loaded! Add plot → aktifkan Auto Plant.",
    Icon     = "sprout",
    Duration = 5,
    CanClose = true,
})