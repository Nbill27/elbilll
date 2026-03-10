local Players          = game:GetService("Players")

-- ── Game ID Check
if game.PlaceId ~= 122446657157717 then
    return
end

local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()
local Camera           = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local S = {
    -- Combat
    Aimbot       = false,
    AimbotSmooth = 1,
    TriggerBot   = false,
    Hitbox       = false,
    HitboxSize   = 2,

    -- Visuals
    ESP_Box      = false,
    ESP_Skeleton = false,
    ESP_Line     = false,
    ESP_Distance = false,
    VisCheck     = false,

    -- Weapon
    NoRecoil     = false,
    NoSpread     = false,
    FastReload   = false,

    -- Movement
    Speed        = false,
    SpeedVal     = 0.05,
    Jump         = false,
    JumpVal      = 50,
    AutoStrafe   = false,
}

--  DRAWING HELPERS
local ActiveDrawings = {}

local function NewLine(from, to, color)
    local line        = Drawing.new("Line")
    line.Visible      = true
    line.From         = from
    line.To           = to
    line.Color        = color or Color3.fromRGB(255, 255, 0)
    line.Thickness    = 1
    return line
end

local function NewText(pos, text, color, size)
    local t           = Drawing.new("Text")
    t.Visible         = true
    t.Position        = pos
    t.Text            = text
    t.Color           = color or Color3.fromRGB(255, 255, 255)
    t.Size            = size or 14
    t.Center          = true
    t.Outline         = true
    t.OutlineColor    = Color3.fromRGB(0, 0, 0)
    return t
end

local function ClearDrawings()
    for _, d in pairs(ActiveDrawings) do
        pcall(function() d:Remove() end)
    end
    ActiveDrawings = {}
end

--  UTILITY
local function GetCharacter(plr)
    return plr and plr.Character
end

local function GetHRP(plr)
    local char = GetCharacter(plr)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(plr)
    local char = GetCharacter(plr)
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function IsAlive(plr)
    local hum = GetHumanoid(plr)
    return hum and hum.Health > 0
end

local function IsVisible(targetPos)
    if not S.VisCheck then return true end
    local lchar = LocalPlayer.Character
    local tchar = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head and head.Position == targetPos then
                tchar = p.Character
            end
        end
    end
    local ignore = {lchar, tchar}
    local parts = Camera:GetPartsObscuringTarget({targetPos}, ignore)
    return #parts == 0
end

--  AIMBOT — find closest enemy to crosshair
local function GetClosestPlayer()
    local closest, closestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and IsAlive(plr) then
            local char = GetCharacter(plr)
            local head = char and char:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and IsVisible(head.Position) then
                    local mousePos = UserInputService:GetMouseLocation()
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest     = plr
                    end
                end
            end
        end
    end
    return closest
end

--  WEAPON MODIFIERS
local function ApplyWeaponMods()
    pcall(function()
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not tool then return end
        for _, v in pairs(tool:GetDescendants()) do
            local isNum = v:IsA("NumberValue") or v:IsA("DoubleConstrainedValue") or v:IsA("IntValue")
            if isNum then
                local n = v.Name:lower()
                if S.NoRecoil   and (n:find("recoil")   or n:find("kick"))     then v.Value = 0    end
                if S.NoSpread   and (n:find("spread")   or n:find("accuracy")) then v.Value = 0    end
                if S.FastReload and (n:find("reload")   or n:find("time"))     then v.Value = 0.05 end
            end
        end
    end)
end

--  LOAD UI
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title         = "elbilll | Sniper Arena",
    Folder        = "elbilll_sniper_full",
    Icon          = "crosshair",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton = {
        Title           = "elbilll",
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

Window:Tag({ Title = "v2.0", Icon = "github", Color = Color3.fromHex("#8B0000"), Border = true })

-- ── Sidebar sections
local TInfo = Window:Tab({
    Title  = "Info",
    Icon   = "info",
    Border = true,
})

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

local CombatSec   = Window:Section({ Title = "Combat"   })
local VisualsSec  = Window:Section({ Title = "Visuals"  })
local WeaponSec   = Window:Section({ Title = "Weapon"   })
local MoveSec     = Window:Section({ Title = "Movement" })

--  TAB — COMBAT
local CombatTab = CombatSec:Tab({
    Title     = "Combat",
    Icon      = "crosshair",
    IconColor = Color3.fromHex("#8B0000"),
    IconShape = "Square",
    Border    = true,
})

-- ── Aimbot
local AimSection = CombatTab:Section({
    Title = "Aimbot", Box = true, BoxBorder = true, Opened = true,
})

AimSection:Toggle({
    Flag     = "Aimbot",
    Title    = "Aimbot",
    Desc     = "Hold Right Click to snap aim to nearest enemy's head",
    Value    = false,
    Callback = function(v) S.Aimbot = v end,
})

AimSection:Space()

AimSection:Slider({
    Flag      = "AimbotSmooth",
    Title     = "Aimbot Smoothness",
    Desc      = "1 = instant snap | higher = smoother/slower",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 1, Max = 20, Default = 1 },
    Callback  = function(v) S.AimbotSmooth = v end,
})

AimSection:Space()

-- ── TriggerBot
local TrigSection = CombatTab:Section({
    Title = "TriggerBot", Box = true, BoxBorder = true, Opened = true,
})

TrigSection:Toggle({
    Flag     = "TriggerBot",
    Title    = "Trigger Assist (Auto Fire)",
    Desc     = "Automatically fires when your cursor is hovering over an enemy",
    Value    = false,
    Callback = function(v) S.TriggerBot = v end,
})

CombatTab:Space()

-- ── Hitbox
local HitboxSection = CombatTab:Section({
    Title = "Hitbox Expand", Box = true, BoxBorder = true, Opened = true,
})

HitboxSection:Toggle({
    Flag     = "Hitbox",
    Title    = "Hitbox Expand (Big Head)",
    Desc     = "Enlarges enemy head hitbox — easier to land shots",
    Value    = false,
    Callback = function(v)
        S.Hitbox = v
        if not v then
            -- restore all heads when disabled
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local char = plr.Character
                    local head = char and char:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(2, 1, 1)
                    end
                end
            end
        end
    end,
})

HitboxSection:Space()

HitboxSection:Slider({
    Flag      = "HitboxSize",
    Title     = "Hitbox Size",
    Desc      = "Head hitbox scale (default head is ~1)",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 1, Max = 10, Default = 2 },
    Callback  = function(v) S.HitboxSize = v end,
})

--  TAB — VISUALS
local VisualsTab = VisualsSec:Tab({
    Title     = "Visuals",
    Icon      = "eye",
    IconColor = Color3.fromHex("#8B0000"),
    IconShape = "Square",
    Border    = true,
})

local ESPSection = VisualsTab:Section({
    Title = "ESP", Box = true, BoxBorder = true, Opened = true,
})

ESPSection:Toggle({
    Flag     = "ESP_Box",
    Title    = "Enemy Highlight (Box)",
    Desc     = "Red highlight box around all enemies",
    Value    = false,
    Callback = function(v)
        S.ESP_Box = v
        if not v then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local h = plr.Character:FindFirstChild("PoloESP")
                    if h then h:Destroy() end
                end
            end
        end
    end,
})

ESPSection:Space()

ESPSection:Toggle({
    Flag     = "ESP_Skeleton",
    Title    = "Skeleton ESP",
    Desc     = "Draws bone lines between body parts",
    Value    = false,
    Callback = function(v) S.ESP_Skeleton = v end,
})

ESPSection:Space()

ESPSection:Toggle({
    Flag     = "ESP_Line",
    Title    = "Tracer ESP (Lines)",
    Desc     = "Draws a line from bottom of screen to each enemy",
    Value    = false,
    Callback = function(v) S.ESP_Line = v end,
})

ESPSection:Space()

ESPSection:Toggle({
    Flag     = "ESP_Distance",
    Title    = "Distance ESP",
    Desc     = "Shows distance (studs) above each enemy",
    Value    = false,
    Callback = function(v) S.ESP_Distance = v end,
})

ESPSection:Space()

ESPSection:Toggle({
    Flag     = "VisCheck",
    Title    = "Visible Check",
    Desc     = "Only target/show enemies that are not behind walls",
    Value    = false,
    Callback = function(v) S.VisCheck = v end,
})

--  TAB — WEAPON
local WeaponTab = WeaponSec:Tab({
    Title     = "Weapon",
    Icon      = "crosshair",
    IconColor = Color3.fromHex("#8B0000"),
    IconShape = "Square",
    Border    = true,
})

local WeapSection = WeaponTab:Section({
    Title = "Weapon Mods", Box = true, BoxBorder = true, Opened = true,
})

WeapSection:Toggle({
    Flag     = "NoRecoil",
    Title    = "No Recoil",
    Desc     = "Sets all recoil/kick values in equipped weapon to 0",
    Value    = false,
    Callback = function(v) S.NoRecoil = v end,
})

WeapSection:Space()

WeapSection:Toggle({
    Flag     = "NoSpread",
    Title    = "No Spread",
    Desc     = "Sets all spread/accuracy values in weapon to 0",
    Value    = false,
    Callback = function(v) S.NoSpread = v end,
})

WeapSection:Space()

WeapSection:Toggle({
    Flag     = "FastReload",
    Title    = "Fast Reload",
    Desc     = "Sets all reload time values in weapon to 0.05",
    Value    = false,
    Callback = function(v) S.FastReload = v end,
})

--  TAB — MOVEMENT
local MoveTab = MoveSec:Tab({
    Title     = "Movement",
    Icon      = "person-standing",
    IconColor = Color3.fromHex("#8B0000"),
    IconShape = "Square",
    Border    = true,
})

-- ── Speed
local SpeedSection = MoveTab:Section({
    Title = "Speed", Box = true, BoxBorder = true, Opened = true,
})

SpeedSection:Paragraph({
    Title = "Warning",
    Desc  = "Max speed: 0.1. Above this value is detectable.",
})

SpeedSection:Space()

SpeedSection:Toggle({
    Flag     = "Speed",
    Title    = "CFrame Speed",
    Desc     = "Adds extra CFrame movement on top of normal walk speed",
    Value    = false,
    Callback = function(v) S.Speed = v end,
})

SpeedSection:Space()

SpeedSection:Slider({
    Flag      = "SpeedVal",
    Title     = "Speed Value",
    Desc      = "Extra speed multiplier (0.01 - 0.10 recommended)",
    Step      = 0.01,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 0.01, Max = 0.10, Default = 0.05 },
    Callback  = function(v) S.SpeedVal = v end,
})

MoveTab:Space()

-- ── Jump
local JumpSection = MoveTab:Section({
    Title = "Jump", Box = true, BoxBorder = true, Opened = true,
})

JumpSection:Toggle({
    Flag     = "Jump",
    Title    = "Jump Boost",
    Desc     = "Overrides jump power with custom value",
    Value    = false,
    Callback = function(v)
        S.Jump = v
        local hum = GetHumanoid(LocalPlayer)
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower    = v and S.JumpVal or 50
        end
    end,
})

JumpSection:Space()

JumpSection:Slider({
    Flag      = "JumpVal",
    Title     = "Jump Power",
    Desc      = "Jump force (default Roblox = 50)",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 50, Max = 80, Default = 50 },
    Callback  = function(v)
        S.JumpVal = v
        if S.Jump then
            local hum = GetHumanoid(LocalPlayer)
            if hum then hum.JumpPower = v end
        end
    end,
})

MoveTab:Space()

-- ── Strafe
local StrafeSection = MoveTab:Section({
    Title = "Auto Strafe", Box = true, BoxBorder = true, Opened = true,
})

StrafeSection:Toggle({
    Flag     = "AutoStrafe",
    Title    = "Auto Strafe",
    Desc     = "Slightly boosts XZ velocity while moving for strafe effect",
    Value    = false,
    Callback = function(v) S.AutoStrafe = v end,
})

--  TAB — COMBAT

-- ══════════════════════════════════════════════════════════════
--  MAIN RENDER LOOP
-- ══════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    ClearDrawings()

    local localChar = LocalPlayer.Character
    local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char then continue end

        local head = char:FindFirstChild("Head")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not head or not hrp or not hum or hum.Health <= 0 then continue end

        -- ── Hitbox Expand
        if S.Hitbox then
            head.Size         = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
            head.Transparency = 1
            head.CanCollide   = false
        end

        -- ── Box ESP (Highlight)
        local existing = char:FindFirstChild("PoloESP")
        if S.ESP_Box then
            if not existing then
                local hl             = Instance.new("Highlight", char)
                hl.Name              = "PoloESP"
                hl.FillColor         = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor      = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency  = 0.5
            end
        elseif existing then
            existing:Destroy()
        end

        local headScreen, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        local hrpScreen,  hrpOnScreen  = Camera:WorldToViewportPoint(hrp.Position)

        -- ── Tracer Line ESP
        if S.ESP_Line and hrpOnScreen then
            local line = NewLine(
                Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
                Vector2.new(hrpScreen.X, hrpScreen.Y),
                Color3.fromRGB(255, 0, 0)
            )
            table.insert(ActiveDrawings, line)
        end

        -- ── Distance ESP
        if S.ESP_Distance and headOnScreen and localHRP then
            local dist = math.floor((hrp.Position - localHRP.Position).Magnitude)
            local label = NewText(
                Vector2.new(headScreen.X, headScreen.Y - 20),
                dist .. " studs",
                Color3.fromRGB(255, 255, 255),
                13
            )
            table.insert(ActiveDrawings, label)
        end

        -- ── Skeleton ESP
        if S.ESP_Skeleton then
            local function DrawBone(a, b)
                if not a or not b then return end
                local sA, onA = Camera:WorldToViewportPoint(a.Position)
                local sB, onB = Camera:WorldToViewportPoint(b.Position)
                if onA and onB then
                    local line = NewLine(
                        Vector2.new(sA.X, sA.Y),
                        Vector2.new(sB.X, sB.Y),
                        Color3.fromRGB(255, 255, 0)
                    )
                    table.insert(ActiveDrawings, line)
                end
            end
            local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            local lower = char:FindFirstChild("LowerTorso")
            DrawBone(head,  torso)
            DrawBone(torso, lower)
            DrawBone(torso, char:FindFirstChild("RightUpperArm"))
            DrawBone(torso, char:FindFirstChild("LeftUpperArm"))
            DrawBone(lower, char:FindFirstChild("RightUpperLeg"))
            DrawBone(lower, char:FindFirstChild("LeftUpperLeg"))
        end
    end

    -- ── Aimbot (Right Mouse Button held)
    if S.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local screenPos = Camera:WorldToViewportPoint(head.Position)
                local mousePos  = UserInputService:GetMouseLocation()
                local dX        = screenPos.X - mousePos.X
                local dY        = screenPos.Y - mousePos.Y
                mousemoverel(dX / S.AimbotSmooth, dY / S.AimbotSmooth)
            end
        end
    end

    -- ── TriggerBot
    if S.TriggerBot then
        local target = Mouse.Target
        if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
            mouse1click()
        end
    end

    -- ── Speed
    if S.Speed and localChar and localHRP then
        local hum = localChar:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            localHRP.CFrame = localHRP.CFrame + (hum.MoveDirection * S.SpeedVal)
        end
    end

    -- ── Jump
    if S.Jump then
        local hum = GetHumanoid(LocalPlayer)
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower    = S.JumpVal
        end
    end

    -- ── Auto Strafe
    if S.AutoStrafe and localHRP then
        local hum = localChar and localChar:FindFirstChildOfClass("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            local vel = localHRP.Velocity
            localHRP.Velocity = Vector3.new(vel.X * 1.01, vel.Y, vel.Z * 1.01)
        end
    end

    -- ── Weapon Mods (apply every frame for persistence)
    if S.NoRecoil or S.NoSpread or S.FastReload then
        ApplyWeaponMods()
    end
end)


task.wait(0.5)
WindUI:Notify({
    Title    = "elbilll | Sniper Arena",
    Content  = "Full suite loaded! Combat • Visuals • Weapon • Movement",
    Icon     = "check",
    Duration = 5,
    CanClose = true,
})