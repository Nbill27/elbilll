local TweenService = game:GetService("TweenService")
local Players      = game:GetService("Players")
local Player       = Players.LocalPlayer

local GARDEN_HORIZONS   = 130594398886540
local VIOLENCE_DISTRICT = 93978595733734
local SAMBUNG_KATA      = 130342654546662
local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name           = "LoaderScript"
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local ok, cg = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = ok and cg or Player:WaitForChild("PlayerGui")

local GREEN      = Color3.fromRGB( 57, 255,  20) 
local GREEN_DIM  = Color3.fromRGB( 20,  90,   8)
local GREEN_DARK = Color3.fromRGB(  8,  20,   4)
local WHITE      = Color3.fromRGB(200, 230, 200)
local GRAY       = Color3.fromRGB( 70,  90,  70)
local DARK       = Color3.fromRGB(  6,   8,   6)

local BG = Instance.new("Frame")
BG.Size                   = UDim2.new(1, 0, 1, 0)
BG.BackgroundColor3       = DARK
BG.BorderSizePixel        = 0
BG.BackgroundTransparency = 1
BG.Parent                 = ScreenGui

for i = 0, 80 do
    local line = Instance.new("Frame")
    line.Size                   = UDim2.new(1, 0, 0, 1)
    line.Position               = UDim2.new(0, 0, 0, i * 12)
    line.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    line.BackgroundTransparency = 0.91
    line.BorderSizePixel        = 0
    line.ZIndex                 = 2
    line.Parent                 = BG
end

for _, yPos in ipairs({0, 1}) do
    local strip = Instance.new("Frame")
    strip.Size             = UDim2.new(1, 0, 0, 2)
    strip.Position         = UDim2.new(0, 0, yPos, yPos == 1 and -2 or 0)
    strip.BackgroundColor3 = GREEN_DIM
    strip.BorderSizePixel  = 0
    strip.ZIndex           = 3
    strip.Parent           = BG
end

local Panel = Instance.new("Frame")
Panel.Size             = UDim2.new(0, 460, 0, 220)
Panel.Position         = UDim2.new(0.5, -230, 0.5, -110)
Panel.BackgroundColor3 = Color3.fromRGB(8, 12, 8)
Panel.BorderSizePixel  = 0
Panel.ZIndex           = 4
Panel.Parent           = BG
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 6)

local PanelStroke = Instance.new("UIStroke", Panel)
PanelStroke.Color           = GREEN_DIM
PanelStroke.Thickness       = 1
PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local PanelHeader = Instance.new("Frame")
PanelHeader.Size             = UDim2.new(1, 0, 0, 26)
PanelHeader.BackgroundColor3 = Color3.fromRGB(10, 16, 10)
PanelHeader.BorderSizePixel  = 0
PanelHeader.ZIndex           = 5
PanelHeader.Parent           = Panel
Instance.new("UICorner", PanelHeader).CornerRadius = UDim.new(0, 6)

local HeaderFix = Instance.new("Frame")
HeaderFix.Size             = UDim2.new(1, 0, 0, 8)
HeaderFix.Position         = UDim2.new(0, 0, 1, -8)
HeaderFix.BackgroundColor3 = Color3.fromRGB(10, 16, 10)
HeaderFix.BorderSizePixel  = 0
HeaderFix.ZIndex           = 5
HeaderFix.Parent           = PanelHeader

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size                   = UDim2.new(1, -16, 1, 0)
HeaderTitle.Position               = UDim2.new(0, 10, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text                   = "elbilll@loader ~ $"
HeaderTitle.TextColor3             = GREEN
HeaderTitle.TextSize               = 12
HeaderTitle.Font                   = Enum.Font.Code
HeaderTitle.TextXAlignment         = Enum.TextXAlignment.Left
HeaderTitle.ZIndex                 = 6
HeaderTitle.Parent                 = PanelHeader

for i, clr in ipairs({
    Color3.fromRGB(255, 95, 86),
    Color3.fromRGB(255, 189, 46),
    Color3.fromRGB(39, 201, 63),
}) do
    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 9, 0, 9)
    dot.Position         = UDim2.new(1, -(12 + (i-1)*14), 0.5, -4)
    dot.BackgroundColor3 = clr
    dot.BorderSizePixel  = 0
    dot.ZIndex           = 6
    dot.Parent           = PanelHeader
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
end

local LC = Instance.new("Frame")
LC.Size             = UDim2.new(1, -28, 1, -44)
LC.Position         = UDim2.new(0, 14, 0, 32)
LC.BackgroundTransparency = 1
LC.ZIndex           = 5
LC.Parent           = Panel

local UIL = Instance.new("UIListLayout", LC)
UIL.SortOrder      = Enum.SortOrder.LayoutOrder
UIL.Padding        = UDim.new(0, 3)
UIL.FillDirection  = Enum.FillDirection.Vertical

local function newLine(order)
    local lbl = Instance.new("TextLabel")
    lbl.Size                   = UDim2.new(1, 0, 0, 17)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = ""
    lbl.TextColor3             = WHITE
    lbl.TextSize               = 13
    lbl.Font                   = Enum.Font.Code
    lbl.TextXAlignment         = Enum.TextXAlignment.Left
    lbl.TextYAlignment         = Enum.TextYAlignment.Center
    lbl.ZIndex                 = 6
    lbl.LayoutOrder            = order
    lbl.Parent                 = LC
    return lbl
end

local L1 = newLine(1)
local L2 = newLine(2)
local L3 = newLine(3)
local L4 = newLine(4)
local L5 = newLine(5)

local BarArea = Instance.new("Frame")
BarArea.Size             = UDim2.new(1, -28, 0, 24)
BarArea.Position         = UDim2.new(0, 14, 1, -28)
BarArea.BackgroundTransparency = 1
BarArea.ZIndex           = 5
BarArea.Parent           = Panel

local BarTrack = Instance.new("Frame")
BarTrack.Size             = UDim2.new(1, -48, 0, 3)
BarTrack.Position         = UDim2.new(0, 0, 0.5, -1)
BarTrack.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
BarTrack.BorderSizePixel  = 0
BarTrack.ZIndex           = 6
BarTrack.Parent           = BarArea
Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size             = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = GREEN
BarFill.BorderSizePixel  = 0
BarFill.ZIndex           = 7
BarFill.Parent           = BarTrack
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local PctLabel = Instance.new("TextLabel")
PctLabel.Size                   = UDim2.new(0, 42, 1, 0)
PctLabel.Position               = UDim2.new(1, 4, 0, 0)
PctLabel.BackgroundTransparency = 1
PctLabel.Text                   = "0%"
PctLabel.TextColor3             = GREEN
PctLabel.TextSize               = 12
PctLabel.Font                   = Enum.Font.Code
PctLabel.TextXAlignment         = Enum.TextXAlignment.Left
PctLabel.ZIndex                 = 7
PctLabel.Parent                 = BarArea

local function fade(inst, prop, val, dur)
    TweenService:Create(inst, TweenInfo.new(dur, Enum.EasingStyle.Quart), {[prop] = val}):Play()
end

local function typeText(lbl, text, speed, color)
    lbl.TextColor3 = color or WHITE
    lbl.Text = ""
    for i = 1, #text do
        lbl.Text = string.sub(text, 1, i)
        task.wait(speed or 0.018)
    end
end

local curPct = 0
local function animateProgress(targetPct, dur)
    TweenService:Create(BarFill, TweenInfo.new(dur, Enum.EasingStyle.Sine), {
        Size = UDim2.new(targetPct / 100, 0, 1, 0)
    }):Play()
    local from  = curPct
    local steps = math.max(1, math.floor(dur / 0.035))
    for i = 1, steps do
        PctLabel.Text = math.floor(from + (targetPct - from) * (i / steps)) .. "%"
        task.wait(0.035)
    end
    curPct        = targetPct
    PctLabel.Text = targetPct .. "%"
end


local function executeScript()
    if game.PlaceId == GARDEN_HORIZONS then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/GardenHorizons.lua"))()
    elseif game.PlaceId == VIOLENCE_DISTRICT then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/script.lua"))()
    elseif game.PlaceId == SAMBUNG_KATA then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/Sambungkata.lua"))()
    else
        warn("[elbilll] Game tidak didukung. PlaceId: " .. tostring(game.PlaceId))
        Player:Kick("[elbilll] Game ini tidak didukung.")
    end
end

task.spawn(function()

    
    fade(BG,    "BackgroundTransparency", 0, 0.2)
    fade(Panel, "BackgroundTransparency", 0, 0.2)
    task.wait(0.25)

    typeText(L1, "elbilll Ganteng", 0.02, GREEN)
    typeText(L2, string.rep("-", 36), 0.006, GREEN_DIM)
    typeText(L3, ">> checking compatibility...", 0.015, GRAY)
    task.spawn(function() animateProgress(30, 0.35) end)
    task.wait(0.35)
    L3.Text       = ">> compatibility    [ ok ]"
    L3.TextColor3 = GREEN

    typeText(L4, ">> fetching script data...", 0.015, GRAY)
    task.spawn(function() animateProgress(65, 0.4) end)
    task.wait(0.4)
    L4.Text       = ">> script data      [ ok ]"
    L4.TextColor3 = GREEN

  
    typeText(L5, ">> launching Script...", 0.015, GRAY)
    task.spawn(function() animateProgress(100, 0.35) end)
    task.wait(0.35)
    L5.Text       = ">> Launching Script [ ok ]"
    L5.TextColor3 = GREEN

    task.wait(0.2)

    executeScript()
    fade(Panel, "BackgroundTransparency", 1, 0.3)
    task.wait(0.15)
    fade(BG,    "BackgroundTransparency", 1, 0.3)
    task.wait(0.35)
    ScreenGui:Destroy()
end)
