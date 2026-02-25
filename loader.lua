local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local GARDEN_HORIZONS = 130594398886540
local VIOLENCE_DISTRICT = 93978595733734


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ElbilllLoader"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local success, result = pcall(function() return game:GetService("CoreGui") end)
ScreenGui.Parent = success and result or Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 300, 0, 80)
Logo.Position = UDim2.new(0.5, -150, 0.5, -60)
Logo.BackgroundTransparency = 1
Logo.Text = "elbilll"
Logo.TextColor3 = Color3.fromRGB(230, 230, 230)
Logo.TextSize = 80
Logo.Font = Enum.Font.GothamBold
Logo.TextTransparency = 1
Logo.Parent = MainFrame

local Glow = Instance.new("UIStroke")
Glow.Color = Color3.fromRGB(138, 43, 226)
Glow.Thickness = 0
Glow.Transparency = 1
Glow.Parent = Logo

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 400, 0, 30)
StatusLabel.Position = UDim2.new(0.5, -200, 0.5, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Initializating..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 16
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextTransparency = 1
StatusLabel.Parent = MainFrame

local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0, 300, 0, 4)
BarBackground.Position = UDim2.new(0.5, -150, 0.5, 80)
BarBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
BarBackground.BorderSizePixel = 0
BarBackground.BackgroundTransparency = 1
BarBackground.Parent = MainFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = BarBackground

Instance.new("UICorner", BarBackground).CornerRadius = UDim.new(1, 0)
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

local function fade(instance, property, value, duration)
    TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quart), {[property] = value}):Play()
end

local function setStatus(text)
    StatusLabel.Text = text
    StatusLabel.TextTransparency = 0.5
end

task.spawn(function()
    fade(MainFrame, "BackgroundTransparency", 0, 0.5)
    task.wait(0.5)
    fade(Logo, "TextTransparency", 0, 0.8)
    fade(Glow, "Thickness", 4, 1)
    fade(Glow, "Transparency", 0.3, 1)
    
    task.wait(0.5)
    
    fade(StatusLabel, "TextTransparency", 0.5, 0.5)
    fade(BarBackground, "BackgroundTransparency", 0, 0.5)
    
    local function loadProgress(target, status, duration)
        setStatus(status)
        TweenService:Create(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Sine), {Size = UDim2.new(target, 0, 1, 0)}):Play()
        task.wait(duration)
    end
    
    loadProgress(0.3, "Checking Game Compatibility...", 0.8)
    loadProgress(0.6, "Fetching Script Data...", 1.2)
    loadProgress(1, "Preparing elbilll...", 0.8)
    
    task.wait(0.2)
    
    local function executeScript()
        if game.PlaceId == GARDEN_HORIZONS then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/GardenHorizons.lua"))()
        elseif game.PlaceId == VIOLENCE_DISTRICT then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/script.lua"))()
        else
            warn("[elbilll] Game tidak didukung oleh loader. PlaceId: " .. tostring(game.PlaceId))
            Player:Kick("[elbilll] Game ini tidak didukung.")
        end
    end
    
    fade(Logo, "TextTransparency", 1, 0.5)
    fade(Glow, "Transparency", 1, 0.5)
    fade(StatusLabel, "TextTransparency", 1, 0.5)
    fade(BarBackground, "BackgroundTransparency", 1, 0.5)
    fade(ProgressBar, "BackgroundTransparency", 1, 0.5)
    task.wait(0.3)
    
    executeScript()
    
    fade(MainFrame, "BackgroundTransparency", 1, 0.5)
    task.wait(0.5)
    ScreenGui:Destroy()
end)

