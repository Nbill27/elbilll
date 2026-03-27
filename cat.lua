local Players           = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService        = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local VIM               = game:GetService("VirtualInputManager")
local RS                = game:GetService("ReplicatedStorage")
local Lighting          = game:GetService("Lighting")

local player = Players.LocalPlayer

local VelarisUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/testUI.lua"))()
local Alert = nil
pcall(function()
    Alert = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/alert%20new%20ui.lua"))()
end)

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local function Notify(title, desc, duration)
    VelarisUI:MakeNotify({
        Title       = title,
        Description = desc or "",
        Color       = "Red",
        Time        = 0.5,
        Delay       = duration or 3,
        Footer      = "Free Script Not For Sale"

    })
end

local function findStrongestPetAny()
    local strongest, max = nil, 0
    for _, obj in pairs(CollectionService:GetTagged("Roaming")) do
        local s = obj:GetAttribute("Strength")
        local o = obj:GetAttribute("OwnerId")
        if s and (not o or o == 0) and s > max then max = s; strongest = obj end
    end
    return strongest
end


local function findPetsInPlayer()
    local found = {}
    for _, obj in ipairs(player:GetDescendants()) do
        if (obj.Name:find("Pets") or obj.Name:find("Equipped")) and obj:IsA("Folder") then
            for _, pet in ipairs(obj:GetChildren()) do
                local id = pet:GetAttribute("UUID") or pet:GetAttribute("Id") or pet.Name
                found[id] = { Id = id, Name = pet.Name }
            end
        end
    end
    return found
end

local function findPetsInWorkspace()
    local found = {}
    local root  = getRoot()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local isOwner = (obj:GetAttribute("OwnerId") == player.UserId) or (obj:GetAttribute("Owner") == player.Name)
            if not isOwner and CollectionService:HasTag(obj, "Roaming") then
                if root and (obj:GetPivot().Position - root.Position).Magnitude < 20 then isOwner = true end
            end
            if isOwner then
                local id = obj:GetAttribute("UUID") or obj:GetAttribute("Id") or obj.Name
                found[id] = { Id = id, Name = obj.Name, Model = obj }
            end
        end
    end
    return found
end

local CF_Underwater   = CFrame.new(13.0744, 180.5068, -4959.8169)
local CF_DragonIsland = CFrame.new(-105.803, 830.677, -2745.03)

-- State 
local _walkSpeed        = 16
local _jumpHeight       = 50
local _flyEnabled       = false
local _flySpeed         = 50
local _flyBV, _flyBA
local _noclip           = false
local _acEnabled        = false
local _acSpeed          = 10
local _acThread         = nil
local _collectEnabled   = false
local _collectDelay     = 5
local _collectThread    = nil
local _autoLoadUW       = false
local _lastUWTime       = 0
local _savedPos         = nil
local _returning        = false
local _uwInterval       = 60
local _antiDrown        = false
local _fullbright       = false
local _targetStrength   = 1

local function findPetByMinStrength(minS)
    local found = nil
    for _, obj in pairs(CollectionService:GetTagged("Roaming")) do
        local s = obj:GetAttribute("Strength")
        local o = obj:GetAttribute("OwnerId")
        if s and (not o or o == 0) and s >= minS then
            found = obj
            break
        end
    end
    return found
end

local function startFly()
    local root = getRoot(); local hum = getHum()
    if not root or not hum then return end
    hum.PlatformStand = true
    _flyBV = Instance.new("BodyVelocity"); _flyBV.Velocity = Vector3.zero
    _flyBV.MaxForce = Vector3.new(1e9,1e9,1e9); _flyBV.Parent = root
    _flyBA = Instance.new("BodyAngularVelocity"); _flyBA.AngularVelocity = Vector3.zero
    _flyBA.MaxTorque = Vector3.new(1e9,1e9,1e9); _flyBA.Parent = root
    RunService:BindToRenderStep("FlyUpdate", 300, function()
        if not _flyEnabled then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W)            then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S)            then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A)            then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D)            then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)        then dir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl)  then dir -= Vector3.new(0,1,0) end
        if _flyBV then _flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * _flySpeed or Vector3.zero end
    end)
end

local function stopFly()
    RunService:UnbindFromRenderStep("FlyUpdate")
    if _flyBV then _flyBV:Destroy(); _flyBV = nil end
    if _flyBA then _flyBA:Destroy(); _flyBA = nil end
    local hum = getHum(); if hum then hum.PlatformStand = false end
end

RunService.Stepped:Connect(function()
    if not _noclip then return end
    local char = player.Character; if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end)

-- Auto Clicker 
local function getButtonPos()
    local gui = player.PlayerGui:FindFirstChild("LassoMinigame"); if not gui then return nil end
    local btn = gui:FindFirstChild("Holder")
    btn = btn and btn:FindFirstChild("CounterHolder")
    btn = btn and btn:FindFirstChild("ConsoleIndicator")
    btn = btn and btn:FindFirstChild("ConsoleButton")
    if btn and btn.Visible then
        local pos = btn.AbsolutePosition; local size = btn.AbsoluteSize
        return Vector2.new(pos.X + size.X/2, pos.Y + size.Y/2)
    end
    return nil
end

local function doClick(pos)
    pcall(function()
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true,  game, 1); task.wait(0.01)
        VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if _autoLoadUW and not _returning then
            if os.clock() - _lastUWTime >= _uwInterval then
                _lastUWTime = os.clock()
                local root = getRoot()
                if root then
                    _savedPos  = root.CFrame; _returning = true
                    root.CFrame = CF_Underwater
                    Notify("Auto Load UW", "Teleporting to Underwater, returning in 3 seconds...", 3)
                    task.delay(3, function()
                        local r = getRoot()
                        if r and _savedPos then r.CFrame = _savedPos end
                        _returning = false
                    end)
                end
            end
        end
    end
end)


task.spawn(function()
    while true do
        task.wait(1)
        if _fullbright then
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.GlobalShadows = false; Lighting.FogEnd = 10e9
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("BlurEffect") or v:IsA("Atmosphere") then v:Destroy() end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if _antiDrown then
            pcall(function()
                local sw = player.PlayerScripts:FindFirstChild("Controllers")
                sw = sw and sw:FindFirstChild("SwimmingHandler")
                if sw then sw.Disabled = true end
            end)
        end
    end
end)

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = _walkSpeed; hum.JumpHeight = _jumpHeight end
end)

-- Auto Equip Lasso 
pcall(function()
    local Event = RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.LassoService.RE.EquipLasso
    firesignal(Event.OnClientEvent, "Stellar Lasso")
end)

local Window = VelarisUI:Window({
    Title        = "elbilll | Catch and Tame Free Script Not For Sale",
    Footer       = "Free Script Not For Sale",
    Color        = "Red",
    Version      = 1.2,
    ["Tab Width"] = 110,
    Image        = "107802296255222",
    Configname   = "elbilll_cat",
    ShowUser     = true,
    Search       = true,
    Config       = { AutoSave = true, AutoLoad = true },
})

local Tabs = {
    Info      = Window:AddTab({ Name = "Info",      Icon = "lucide:info" }),
    Player    = Window:AddTab({ Name = "Player",    Icon = "lucide:user" }),
    Main      = Window:AddTab({ Name = "Main",      Icon = "lucide:star" }),
    AutoBuy   = Window:AddTab({ Name = "Auto Buy",  Icon = "lucide:shopping-cart" }),
    Teleport  = Window:AddTab({ Name = "Teleport",  Icon = "lucide:navigation" }),
    Event     = Window:AddTab({ Name = "Event",     Icon = "lucide:sparkles" }),
    Misc      = Window:AddTab({ Name = "Misc",      Icon = "lucide:settings" }),
}

-- INFO 
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
        Notify("Discord", "Link copied to clipboard!", 3)
    end,
})

-- PLAYER
local MovSec = Tabs.Player:AddSection({ Title = "Movement", Icon = "lucide:run", Open = true })

MovSec:AddSlider({
    Title     = "Walk Speed",
    Content   = "Default: 16",
    Min = 1, Max = 200, Default = 16, Increment = 1,
    Callback  = function(v)
        _walkSpeed = v
        local hum = getHum(); if hum then hum.WalkSpeed = v end
    end,
})

MovSec:AddSlider({
    Title     = "Jump Height",
    Content   = "Default: 50",
    Min = 1, Max = 500, Default = 50, Increment = 1,
    Callback  = function(v)
        _jumpHeight = v
        local hum = getHum(); if hum then hum.JumpHeight = v end
    end,
})

MovSec:AddDivider()

local FlySec = Tabs.Player:AddSection({ Title = "Fly", Icon = "lucide:plane", Open = true })

FlySec:AddSlider({
    Title = "Fly Speed", Min = 10, Max = 300, Default = 50, Increment = 5,
    Callback = function(v) _flySpeed = v end,
})

FlySec:AddToggle({
    Title   = "Fly",
    Content = "Use WASD to move, Space to go up, Ctrl to go down",
    Default = false,
    Callback = function(v)
        _flyEnabled = v
        if v then startFly() else stopFly() end
        Notify("Fly", v and "ON" or "OFF", 2)
    end,
})

FlySec:AddDivider()

local NCSec = Tabs.Player:AddSection({ Title = "No Clip", Icon = "lucide:ghost", Open = true })

NCSec:AddToggle({
    Title   = "No Clip",
    Content = "Walk through all objects and walls",
    Default = false,
    Callback = function(v)
        _noclip = v
        Notify("No Clip", v and "ON" or "OFF", 2)
    end,
})

-- MAIN 
local TpSec = Tabs.Main:AddSection({ Title = "TP Strongest", Icon = "lucide:navigation", Open = true })

TpSec:AddParagraph({ Title = "Info", Content = "Teleports once to the strongest unowned pet on the map." })

TpSec:AddButton({
    Title    = "Teleport to Strongest Pet",
    SubTitle = "Manual — teleport once",
    Callback = function()
        local pet = findStrongestPetAny(); local root = getRoot()
        if pet and root then
            root.CFrame = pet:GetPivot() + Vector3.new(0,5,0)
            Notify("TP Strongest", "Teleported!", 2)
        else
            Notify("TP Strongest", "No pet found.", 2)
        end
    end,
})

TpSec:AddToggle({
    Title   = "Auto TP Strongest (Loop)",
    Content = "Automatically teleport to the strongest pet on the map continuously",
    Default = false,
    Callback = function(v)
        _tpStrongestLoop = v
        if v then
            if _tpStrongestConn then task.cancel(_tpStrongestConn) end
            _tpStrongestConn = task.spawn(function()
                while _tpStrongestLoop do
                    local pet = findStrongestPetAny()
                    local root = getRoot()
                    if pet and root then
                        root.CFrame = pet:GetPivot() + Vector3.new(0,5,0)
                    end
                    task.wait(_tpStrongestDelay)
                end
            end)
            Notify("Auto TP Strongest", "Loop started", 2)
        else
            if _tpStrongestConn then task.cancel(_tpStrongestConn); _tpStrongestConn = nil end
            Notify("Auto TP Strongest", "Loop stopped", 2)
        end
    end,
})

TpSec:AddSlider({
    Title     = "TP Strongest Delay (seconds)",
    Content   = "Delay between each teleport to strongest pet",
    Min       = 0.1, Max = 10, Default = 0.5, Increment = 0.1,
    Callback  = function(v) _tpStrongestDelay = v end,
})

TpSec:AddDivider()

TpSec:AddInput({
    Title       = "Custom Strength",
    Content     = "Default: 1 | Max: 1,000,000",
    Default     = "1",
    Placeholder = "Enter strength...",
    Callback    = function(v)
        local n = tonumber(v)
        if n then
            _targetStrength = math.clamp(n, 1, 1000000)
        end
    end,
})

TpSec:AddButton({
    Title    = "Teleport to Pet (>= Strength)",
    SubTitle = "Manual — teleport once",
    Callback = function()
        local pet = findPetByMinStrength(_targetStrength)
        local root = getRoot()
        if pet and root then
            root.CFrame = pet:GetPivot() + Vector3.new(0,5,0)
            Notify("TP Custom", "Teleported to " .. pet.Name .. " (" .. tostring(pet:GetAttribute("Strength")) .. " Strength)!", 2)
        else
            Notify("TP Custom", "No pet found with Strength >= " .. tostring(_targetStrength), 2)
        end
    end,
})

TpSec:AddToggle({
    Title   = "Auto TP Custom Strength (Loop)",
    Content = "Automatically teleport to pet with Strength >= input value",
    Default = false,
    Callback = function(v)
        _tpCustomLoop = v
        if v then
            if _tpCustomConn then task.cancel(_tpCustomConn) end
            _tpCustomConn = task.spawn(function()
                while _tpCustomLoop do
                    local pet = findPetByMinStrength(_targetStrength)
                    local root = getRoot()
                    if pet and root then
                        root.CFrame = pet:GetPivot() + Vector3.new(0,5,0)
                    end
                    task.wait(_tpCustomDelay)
                end
            end)
            Notify("Auto TP Custom", "Loop started (>= " .. tostring(_targetStrength) .. ")", 2)
        else
            if _tpCustomConn then task.cancel(_tpCustomConn); _tpCustomConn = nil end
            Notify("Auto TP Custom", "Loop stopped", 2)
        end
    end,
})

TpSec:AddSlider({
    Title     = "TP Custom Delay (seconds)",
    Content   = "Delay between each teleport to custom strength pet",
    Min       = 0.1, Max = 10, Default = 0.5, Increment = 0.1,
    Callback  = function(v) _tpCustomDelay = v end,
})

TpSec:AddDivider()

local ACSec = Tabs.Main:AddSection({ Title = "Auto Clicker", Icon = "lucide:mouse-pointer", Open = true })

ACSec:AddParagraph({ Title = "Info", Content = "Automatically clicks the LassoMinigame button when the minigame appears." })
ACSec:AddSlider({
    Title = "Speed (clicks/second)", Min = 5, Max = 50, Default = 10, Increment = 1,
    Callback = function(v) _acSpeed = v end,
})
ACSec:AddToggle({
    Title   = "Auto Clicker",
    Content = "Automatically activates when LassoMinigame appears",
    Default = false,
    Callback = function(v)
        _acEnabled = v
        if v then
            Notify("Auto Clicker", "ON — waiting for minigame...", 2)
            _acThread = task.spawn(function()
                player.PlayerGui.ChildAdded:Connect(function(child)
                    if child.Name ~= "LassoMinigame" or not _acEnabled then return end
                    Notify("Auto Clicker", "Minigame detected!", 2)
                    task.spawn(function()
                        while _acEnabled and child.Parent do
                            local pos = getButtonPos()
                            if pos then doClick(pos) end
                            task.wait(1 / _acSpeed)
                        end
                    end)
                end)
            end)
        else
            if _acThread then pcall(task.cancel, _acThread); _acThread = nil end
            Notify("Auto Clicker", "OFF", 2)
        end
    end,
})

ACSec:AddDivider()

local ColSec = Tabs.Main:AddSection({ Title = "Auto Collect", Icon = "lucide:coins", Open = true })

ColSec:AddSlider({
    Title = "Interval (seconds)", Min = 1, Max = 60, Default = 5, Increment = 1,
    Callback = function(v) _collectDelay = v end,
})
ColSec:AddToggle({
    Title   = "Auto Collect Money",
    Content = "Fires collectPetCash for all your pets",
    Default = false,
    Callback = function(v)
        _collectEnabled = v
        if _collectThread then task.cancel(_collectThread); _collectThread = nil end
        if v then
            _collectThread = task.spawn(function()
                while _collectEnabled do
                    pcall(function()
                        local remote = RS:FindFirstChild("Remotes") and RS.Remotes:FindFirstChild("collectPetCash")
                        if not remote then return end
                        local allPets = findPetsInPlayer()
                        for id, data in pairs(findPetsInWorkspace()) do
                            if not allPets[id] then allPets[id] = data end
                        end
                        for id in pairs(allPets) do
                            if not _collectEnabled then break end
                            remote:FireServer(id); task.wait(0.05)
                        end
                    end)
                    task.wait(_collectDelay)
                end
            end)
            Notify("Auto Collect", "ON", 2)
        else
            Notify("Auto Collect", "OFF", 2)
        end
    end,
})


-- AUTO BUY 
local BuySec = Tabs.AutoBuy:AddSection({ Title = "Auto Buy Food & Items", Icon = "lucide:shopping-cart", Open = true })

local buyItems = {
    { "Farmers Feed",  12 },
    { "Enriched Feed", 19 },
    { "Hay",           19 },
    { "Bone",           4 },
    { "Prime Feed",     3 },
    { "Steak",          4 },
    { "Nametag",        1 },
}

local buyLoops = {}

for _, item in ipairs(buyItems) do
    local itemName = item[1]
    local amount   = item[2]
    buyLoops[itemName] = false

    BuySec:AddToggle({
        Title   = "Auto Buy: " .. itemName,
        Default = false,
        Callback = function(v)
            buyLoops[itemName] = v
            if v then
                task.spawn(function()
                    while buyLoops[itemName] do
                        pcall(function()
                            RS.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.FoodService.RE.BuyFood:FireServer(itemName, amount)
                        end)
                        task.wait(1)
                    end
                end)
                Notify("Auto Buy", itemName .. " ON", 2)
            else
                Notify("Auto Buy", itemName .. " OFF", 2)
            end
        end,
    })
end


-- TELEPORT
local UWSec = Tabs.Teleport:AddSection({ Title = "Underwater", Icon = "lucide:anchor", Open = true })

UWSec:AddButton({
    Title    = "Teleport to Underwater",
    Callback = function()
        local root = getRoot()
        if root then root.CFrame = CF_Underwater; Notify("TP", "Teleported to Underwater!", 2) end
    end,
})

UWSec:AddDivider()

local ALSec = Tabs.Teleport:AddSection({ Title = "Auto Load Underwater", Icon = "lucide:timer", Open = true })

ALSec:AddParagraph({ Title = "Info", Content = "Every N seconds, automatically teleports to Underwater then returns to your original position." })
ALSec:AddSlider({
    Title = "Interval (seconds)", Min = 10, Max = 300, Default = 60, Increment = 5,
    Callback = function(v) _uwInterval = v end,
})
ALSec:AddToggle({
    Title   = "Auto Load Underwater",
    Default = false,
    Callback = function(v)
        _autoLoadUW = v
        if v then _lastUWTime = 0 end
        Notify("Auto Load UW", v and ("ON — every " .. _uwInterval .. "s") or "OFF", 2)
    end,
})

UWSec:AddDivider()

local DISec = Tabs.Teleport:AddSection({ Title = "Dragon Island", Icon = "lucide:flame", Open = true })

DISec:AddButton({
    Title    = "Teleport to Dragon Island",
    Callback = function()
        local root = getRoot()
        if root then root.CFrame = CF_DragonIsland; Notify("TP", "Teleported to Dragon Island!", 2) end
    end,
})

-- EVENT
local function claimFruit(fruitName, label)
    if not fireproximityprompt then Notify(label, "fireproximityprompt is not available.", 3); return end
    local root    = getRoot()
    local weather = workspace:FindFirstChild("WeatherVisuals")
    if not root or not weather then Notify(label, "Event is not active right now.", 3); return end
    for _, item in ipairs(weather:GetChildren()) do
        local fruit  = item:FindFirstChild(fruitName); if not fruit then continue end
        local handle = fruit:FindFirstChildWhichIsA("MeshPart")
        local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt")
        if handle and prompt then
            root.CFrame = handle.CFrame; task.wait(0.2)
            fireproximityprompt(prompt)
            Notify(label, "Successfully claimed!", 2); return
        end
    end
    Notify(label, "Not found. Event may not be active.", 2)
end

local EvSec = Tabs.Event:AddSection({ Title = "Event Items", Icon = "lucide:sparkles", Open = true })
EvSec:AddParagraph({ Title = "Info", Content = "Teleports to the event item and claims it automatically.\nOnly claims 1 item per click." })

EvSec:AddButton({ Title = "Claim Volcanic Fruit",  Callback = function() claimFruit("VolcanicFruit",  "Eruption") end })
EvSec:AddButton({ Title = "Claim Cosmic Fruit",    Callback = function() claimFruit("CosmicFruit",    "Cosmic")   end })
EvSec:AddButton({ Title = "Claim Bloodmoon Grape", Callback = function() claimFruit("BloodmoonGrape", "Bloodmoon") end })

-- MISC 
local MiscSec = Tabs.Misc:AddSection({ Title = "Visuals & Utility", Icon = "lucide:settings", Open = true })

-- Fullbright
MiscSec:AddToggle({
    Title   = "Fullbright",
    Content = "Makes the map fully lit — removes shadows and fog",
    Default = false,
    Callback = function(v)
        _fullbright = v
        if not v then
            Lighting.Brightness = 1; Lighting.ClockTime = 12
            Lighting.GlobalShadows = true
        end
        Notify("Fullbright", v and "Enabled" or "Disabled", 2)
    end,
})

MiscSec:AddDivider()

MiscSec:AddToggle({
    Title   = "Infinite Oxygen (Anti-Drown)",
    Content = "Prevents your oxygen from running out underwater",
    Default = false,
    Callback = function(v)
        _antiDrown = v
        if not v then
            pcall(function()
                local sw = player.PlayerScripts:FindFirstChild("Controllers")
                sw = sw and sw:FindFirstChild("SwimmingHandler")
                if sw then sw.Disabled = false end
            end)
        end
        Notify("Anti-Drown", v and "Enabled" or "Disabled", 2)
    end,
})

MiscSec:AddDivider()

MiscSec:AddButton({
    Title    = "Anti-Lag (FPS Boost)",
    Callback = function()
        local t = workspace.Terrain
        t.WaterWaveSize = 0; t.WaterWaveSpeed = 0
        t.WaterReflectance = 0; t.WaterTransparency = 0
        Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v:IsA("MeshPart") then
                v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            end
        end
        Notify("Anti-Lag", "Graphics reduced! FPS should improve.", 3)
    end,
    SubTitle = "Removes textures, particles and shadows",
})

if Alert then pcall(Alert, Window, Tabs) end

task.wait(0.5)
VelarisUI:MakeNotify({
    Title       = "elbilll | Catch and Tame",
    Description = "Script loaded! Welcome, " .. player.Name .. "!",
    Color       = "Red",
    Time        = 0.5,
    Delay       = 5,
})