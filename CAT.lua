local Players           = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

-- ── Game ID Check
if game.PlaceId ~= 96645548064314 then
    return
end

local player = Players.LocalPlayer

-- ── Helpers
local function getRoot()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

local function findStrongestPetAny()
    local strongest, max = nil, 0
    for _, obj in pairs(CollectionService:GetTagged("Roaming")) do
        local s = obj:GetAttribute("Strength")
        local o = obj:GetAttribute("OwnerId")
        if s and (not o or o == 0) and s > max then
            max = s; strongest = obj
        end
    end
    return strongest
end

local function findStrongestPetCustom(minStr)
    local strongest, max = nil, minStr - 1
    for _, obj in pairs(CollectionService:GetTagged("Roaming")) do
        local s = obj:GetAttribute("Strength")
        local o = obj:GetAttribute("OwnerId")
        if s and s >= minStr and (not o or o == 0) and s > max then
            max = s; strongest = obj
        end
    end
    return strongest
end

-- ── Koordinat
local CF_Underwater   = CFrame.new(13.0744, 180.5068, -4959.8169)
local CF_DragonIsland = CFrame.new(-105.803, 830.677, -2745.03)

-- ══════════════════════════════════════════════════════════════
--  LOAD WINDUI
-- ══════════════════════════════════════════════════════════════
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title         = "elbilll",
    Folder        = "elbilll_config",
    Icon          = "bird",
    NewElements   = true,
    HideSearchBar = false,
    OpenButton    = {
        Title           = "Open elbilll",
        CornerRadius    = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        OnlyMobile      = false,
        Scale           = 0.5,
        Color           = ColorSequence.new(
            Color3.fromHex("#8B0000"),
            Color3.fromHex("#1a1a1a")
        ),
    },
    Topbar = {
        Height      = 44,
        ButtonsType = "Mac",
    },
})

Window:Tag({
    Title  = "v1.0",
    Icon   = "github",
    Color  = Color3.fromHex("#8B0000"),
    Border = true,
})

-- ── Sections (Sidebar Group)
local SectionInfo     = Window:Section({ Title = "Info" })
local SectionFarm     = Window:Section({ Title = "Farm" })
local SectionTeleport = Window:Section({ Title = "Teleport" })
local SectionEvent    = Window:Section({ Title = "Event" })

-- ══════════════════════════════════════════════════════════════
--  [INFO] TAB
-- ══════════════════════════════════════════════════════════════
local InfoTab = SectionInfo:Tab({ Title="Info", Icon="info", Border=true })
InfoTab:Section({ Title="Welcome to elbilll", TextSize=22, FontWeight=Enum.FontWeight.Bold })
InfoTab:Space()
InfoTab:Paragraph({
    Title = "elbilll Alert!",
    Desc  = "This script is designed to enhance your gameplay experience!\nWhile it has been carefully optimized, detection is always a possibility in public servers.\n\nIf you have suggestions or encounter any issues, feel free to contact us on Discord!\n\nUse responsibly and enjoy the features!",
})
InfoTab:Space()
InfoTab:Paragraph({
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
            WindUI:Notify({ Title="Discord", Content="Link discord berhasil di-copy!", Icon="check", Duration=3 })
        end,
    }},
})
InfoTab:Space()
InfoTab:Paragraph({ Title="Server Info", Desc="Job ID: "..(game.JobId ~= "" and game.JobId or "N/A") })

-- ══════════════════════════════════════════════════════════════
--  [MAIN] TAB 1 — TELEPORT TO STRONGEST PET
-- ══════════════════════════════════════════════════════════════
local TpStrongestTab = SectionFarm:Tab({
    Title  = "Tp Strongest",
    Icon   = "zap",
    Border = true,
})

TpStrongestTab:Section({
    Title      = "Teleport to Strongest Pet",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

TpStrongestTab:Space()

TpStrongestTab:Paragraph({
    Title = "Info",
    Desc  = "Teleport sekali ke pet terkuat yang tidak memiliki owner (bebas).",
})

TpStrongestTab:Space()

TpStrongestTab:Button({
    Title    = "Teleport Sekarang",
    Desc     = "Cari dan teleport ke pet terkuat",
    Icon     = "navigation",
    Color    = Color3.fromHex("#8B0000"),
    Justify  = "Center",
    Callback = function()
        local pet  = findStrongestPetAny()
        local root = getRoot()
        if pet and root then
            root.CFrame = pet:GetPivot() + Vector3.new(0, 5, 0)
            WindUI:Notify({
                Title    = "Tp Strongest",
                Content  = "Berhasil teleport ke pet terkuat!",
                Icon     = "check",
                Duration = 3,
            })
        else
            WindUI:Notify({
                Title    = "Tp Strongest",
                Content  = "Tidak ada pet yang ditemukan.",
                Icon     = "x",
                Duration = 3,
            })
        end
    end,
})

-- ══════════════════════════════════════════════════════════════
--  [MAIN] TAB 2 — AUTO TELEPORT CUSTOM
-- ══════════════════════════════════════════════════════════════
local AutoCustomTab = SectionTeleport:Tab({
    Title  = "Auto Tp Custom",
    Icon   = "crosshair",
    Border = true,
})

AutoCustomTab:Section({
    Title      = "Auto Teleport Custom",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

AutoCustomTab:Space()

AutoCustomTab:Paragraph({
    Title = "Info",
    Desc  = "Auto teleport terus ke pet yang strengthnya >= nilai minimum yang diatur.\nAtur dulu minimum strength, baru aktifkan toggle.",
})

AutoCustomTab:Space()

local _autoCustomEnabled = false
local _minStrength       = 3000

AutoCustomTab:Slider({
    Title     = "Minimum Strength",
    Desc      = "Pet harus >= nilai ini untuk di-teleport",
    Step      = 100,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 0, Max = 100000, Default = 3000 },
    Callback  = function(v)
        _minStrength = v
    end,
})

AutoCustomTab:Space()

AutoCustomTab:Toggle({
    Title    = "Auto Teleport Custom",
    Desc     = "ON = auto teleport ke pet dengan strength minimum",
    Value    = false,
    Callback = function(state)
        _autoCustomEnabled = state
        WindUI:Notify({
            Title    = "Auto Tp Custom",
            Content  = state and ("ON — min strength: " .. _minStrength) or "OFF",
            Icon     = state and "check" or "x",
            Duration = 2,
        })
    end,
})

task.spawn(function()
    while true do
        task.wait(0.5)
        if _autoCustomEnabled then
            local root = getRoot()
            local pet  = findStrongestPetCustom(_minStrength)
            if root and pet then
                root.CFrame = pet:GetPivot() + Vector3.new(0, 5, 0)
            end
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  [MAIN] TAB 3 — UNDERWATER
-- ══════════════════════════════════════════════════════════════
local UnderwaterTab = SectionTeleport:Tab({
    Title  = "Underwater",
    Icon   = "waves",
    Border = true,
})

UnderwaterTab:Section({
    Title      = "Underwater",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

UnderwaterTab:Space()

UnderwaterTab:Paragraph({
    Title = "Info",
    Desc  = "Teleport langsung ke lokasi Underwater.",
})

UnderwaterTab:Space()

UnderwaterTab:Button({
    Title    = "Teleport ke Underwater",
    Desc     = "Langsung pindah ke Underwater sekarang",
    Icon     = "anchor",
    Color    = Color3.fromHex("#1a6aff"),
    Justify  = "Center",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CF_Underwater
            WindUI:Notify({
                Title    = "Underwater",
                Content  = "Teleport ke Underwater berhasil!",
                Icon     = "check",
                Duration = 3,
            })
        end
    end,
})

-- ══════════════════════════════════════════════════════════════
--  [TELEPORT] TAB 4 — DRAGON ISLAND
-- ══════════════════════════════════════════════════════════════
local DragonIslandTab = SectionTeleport:Tab({
    Title  = "Dragon Island",
    Icon   = "flame",
    Border = true,
})

DragonIslandTab:Section({
    Title      = "Dragon Island",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

DragonIslandTab:Space()

DragonIslandTab:Paragraph({
    Title = "Info",
    Desc  = "Teleport langsung ke Dragon Island.",
})

DragonIslandTab:Space()

DragonIslandTab:Button({
    Title    = "Teleport ke Dragon Island",
    Desc     = "Langsung pindah ke Dragon Island sekarang",
    Icon     = "navigation",
    Color    = Color3.fromHex("#ff4400"),
    Justify  = "Center",
    Callback = function()
        local root = getRoot()
        if root then
            root.CFrame = CF_DragonIsland
            WindUI:Notify({
                Title    = "Dragon Island",
                Content  = "Teleport ke Dragon Island berhasil!",
                Icon     = "check",
                Duration = 3,
            })
        end
    end,
})

-- ══════════════════════════════════════════════════════════════
--  [MAIN] TAB 5 — AUTO LOAD UW
-- ══════════════════════════════════════════════════════════════
local AutoUWTab = SectionFarm:Tab({
    Title  = "Auto Load UW",
    Icon   = "timer",
    Border = true,
})

AutoUWTab:Section({
    Title      = "Auto Load Underwater",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

AutoUWTab:Space()

AutoUWTab:Paragraph({
    Title = "Info",
    Desc  = "Setiap N detik otomatis teleport ke Underwater lalu kembali ke posisi semula.\nBerguna untuk trigger spawn pet underwater.",
})

AutoUWTab:Space()

local _autoLoadUW = false
local _lastUWTime = 0
local _savedPos   = nil
local _returning  = false
local _uwInterval = 60

AutoUWTab:Slider({
    Title     = "Interval (detik)",
    Desc      = "Jarak waktu tiap auto load UW",
    Step      = 5,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 10, Max = 300, Default = 60 },
    Callback  = function(v)
        _uwInterval = v
    end,
})

AutoUWTab:Space()

AutoUWTab:Toggle({
    Title    = "Auto Load UW",
    Desc     = "ON = otomatis TP ke UnderWater tiap interval lalu balik ke posisi semula",
    Value    = false,
    Callback = function(state)
        _autoLoadUW = state
        if state then _lastUWTime = 0 end
        WindUI:Notify({
            Title    = "Auto Load UW",
            Content  = state and ("ON — interval: " .. _uwInterval .. "s") or "OFF",
            Icon     = state and "check" or "x",
            Duration = 2,
        })
    end,
})

task.spawn(function()
    while true do
        task.wait(0.5)
        if _autoLoadUW and not _returning then
            if os.clock() - _lastUWTime >= _uwInterval then
                _lastUWTime = os.clock()
                local root  = getRoot()
                if root then
                    _savedPos      = root.CFrame
                    _returning     = true
                    root.CFrame    = CF_Underwater
                    WindUI:Notify({
                        Title    = "Auto Load UnderWater",
                        Content  = "Teleport ke UnderWater, kembali dalam 3 detik...",
                        Icon     = "timer",
                        Duration = 3,
                    })
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


-- ══════════════════════════════════════════════════════════════
--  [EVENT] TAB 3 — ERUPTION (VOLCANIC FRUIT)
-- ══════════════════════════════════════════════════════════════
local EruptionTab = SectionEvent:Tab({
    Title  = "Eruption",
    Icon   = "mountain",
    Border = true,
})

EruptionTab:Section({
    Title      = "Eruption — Volcanic Fruit",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

EruptionTab:Space()

EruptionTab:Paragraph({
    Title = "Info",
    Desc  = "Teleport ke Volcanic Fruit lalu klaim otomatis.\nHanya klaim 1 buah per klik (tidak loop).",
})

EruptionTab:Space()

EruptionTab:Button({
    Title    = "Claim Volcanic Fruit",
    Desc     = "Teleport dan klaim 1 Volcanic Fruit",
    Icon     = "zap",
    Color    = Color3.fromHex("#ff6600"),
    Justify  = "Center",
    Callback = function()
        if not fireproximityprompt then
            WindUI:Notify({ Title = "Eruption", Content = "fireproximityprompt tidak tersedia.", Icon = "x", Duration = 3 })
            return
        end
        local root    = getRoot()
        local weather = workspace:FindFirstChild("WeatherVisuals")
        if not root or not weather then
            WindUI:Notify({ Title = "Eruption", Content = "WeatherVisuals tidak ditemukan. Event tidak aktif.", Icon = "x", Duration = 3 })
            return
        end
        for _, item in ipairs(weather:GetChildren()) do
            local fruit  = item:FindFirstChild("VolcanicFruit")
            if not fruit then continue end
            local handle = fruit:FindFirstChildWhichIsA("MeshPart")
            local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt")
            if handle and prompt then
                root.CFrame = handle.CFrame
                task.wait(0.2)
                fireproximityprompt(prompt)
                WindUI:Notify({ Title = "Eruption", Content = "Volcanic Fruit berhasil diklaim!", Icon = "check", Duration = 3 })
                return
            end
        end
        WindUI:Notify({ Title = "Eruption", Content = "Tidak ada Volcanic Fruit yang ditemukan.", Icon = "x", Duration = 3 })
    end,
})

-- ══════════════════════════════════════════════════════════════
--  [EVENT] TAB 4 — COSMIC (COSMIC FRUIT)
-- ══════════════════════════════════════════════════════════════
local CosmicTab = SectionEvent:Tab({
    Title  = "Cosmic",
    Icon   = "star",
    Border = true,
})

CosmicTab:Section({
    Title      = "Cosmic — Cosmic Fruit",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

CosmicTab:Space()

CosmicTab:Paragraph({
    Title = "Info",
    Desc  = "Teleport ke Cosmic Fruit lalu klaim otomatis.\nHanya klaim 1 buah per klik (tidak loop).",
})

CosmicTab:Space()

CosmicTab:Button({
    Title    = "Claim Cosmic Fruit",
    Desc     = "Teleport dan klaim 1 Cosmic Fruit",
    Icon     = "sparkles",
    Color    = Color3.fromHex("#8b00ff"),
    Justify  = "Center",
    Callback = function()
        if not fireproximityprompt then
            WindUI:Notify({ Title = "Cosmic", Content = "fireproximityprompt tidak tersedia.", Icon = "x", Duration = 3 })
            return
        end
        local root    = getRoot()
        local weather = workspace:FindFirstChild("WeatherVisuals")
        if not root or not weather then
            WindUI:Notify({ Title = "Cosmic", Content = "WeatherVisuals tidak ditemukan. Event tidak aktif.", Icon = "x", Duration = 3 })
            return
        end
        for _, item in ipairs(weather:GetChildren()) do
            local fruit  = item:FindFirstChild("CosmicFruit")
            if not fruit then continue end
            local handle = fruit:FindFirstChildWhichIsA("MeshPart")
            local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt")
            if handle and prompt then
                root.CFrame = handle.CFrame
                task.wait(0.2)
                fireproximityprompt(prompt)
                WindUI:Notify({ Title = "Cosmic", Content = "Cosmic Fruit berhasil diklaim!", Icon = "check", Duration = 3 })
                return
            end
        end
        WindUI:Notify({ Title = "Cosmic", Content = "Tidak ada Cosmic Fruit yang ditemukan.", Icon = "x", Duration = 3 })
    end,
})

-- ══════════════════════════════════════════════════════════════
--  [FARM] TAB — AUTO CLICKER (Minigame Speed)
-- ══════════════════════════════════════════════════════════════
local _acEnabled  = false
local _acSpeed    = 10
local _acThread   = nil

local ClickerTab = SectionFarm:Tab({
    Title  = "Auto Clicker",
    Icon   = "mouse-pointer-click",
    Border = true,
})

ClickerTab:Section({
    Title      = "Auto Clicker",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

ClickerTab:Space()

ClickerTab:Paragraph({
    Title = "Info",
    Desc  = "Spam klik otomatis untuk mempercepat minigame lasso.\nPC: klik kiri | Mobile: tap layar\n\nAktifkan sebelum minigame dimulai.",
})

ClickerTab:Space()

ClickerTab:Slider({
    Title     = "Kecepatan (klik/detik)",
    Desc      = "Makin tinggi makin cepat",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 5, Max = 50, Default = 10 },
    Callback  = function(v) _acSpeed = v end,
})

ClickerTab:Space()

ClickerTab:Toggle({
    Title    = "Auto Clicker",
    Desc     = "ON = spam klik/tap otomatis",
    Value    = false,
    Callback = function(state)
        _acEnabled = state
        if state then
            WindUI:Notify({ Title = "Auto Clicker", Content = "Mulai dalam 1.5 detik — tutup UI!", Icon = "timer", Duration = 1.5 })
            _acThread = task.spawn(function()
                task.wait(1.5) -- delay supaya sempat tutup UI
                while _acEnabled do
                    pcall(function()
                        if mouse1click then
                            mouse1click()
                        end
                        if firetouchinterest then
                            local char = player.Character
                            if char then
                                local hrp = char:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    firetouchinterest(hrp, hrp, 0)
                                    firetouchinterest(hrp, hrp, 1)
                                end
                            end
                        end
                    end)
                    task.wait(1 / _acSpeed)
                end
            end)
        else
            if _acThread then pcall(task.cancel, _acThread); _acThread = nil end
            WindUI:Notify({ Title = "Auto Clicker", Content = "OFF", Icon = "x", Duration = 2 })
        end
    end,
})

-- ══════════════════════════════════════════════════════════════
--  [FARM] TAB — AUTO COLLECT (Pet Cash)
-- ══════════════════════════════════════════════════════════════
local _collectEnabled = false
local _collectDelay   = 5
local _collectThread  = nil

local AutoCollectTab = SectionFarm:Tab({
    Title  = "Auto Collect",
    Icon   = "coins",
    Border = true,
})

AutoCollectTab:Section({
    Title      = "Auto Collect Money",
    TextSize   = 18,
    FontWeight = Enum.FontWeight.Bold,
})

AutoCollectTab:Space()

AutoCollectTab:Paragraph({
    Title = "Info",
    Desc  = "Otomatis ambil duit dari semua pet kamu.\nSudah di-patch lebih kuat untuk mencari data pet kamu.",
})

AutoCollectTab:Space()

AutoCollectTab:Slider({
    Title     = "Interval (detik)",
    Desc      = "Jeda waktu tiap ambil duit",
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Value     = { Min = 1, Max = 60, Default = 5 },
    Callback  = function(v) _collectDelay = v end,
})

AutoCollectTab:Space()

local function findPetsInPlayer()
    local found = {}
    for _, obj in ipairs(player:GetDescendants()) do
        if (obj.Name:find("Pets") or obj.Name:find("Equipped")) and obj:IsA("Folder") then
            for _, pet in ipairs(obj:GetChildren()) do
                local id = pet:GetAttribute("UUID") or pet:GetAttribute("Id") or pet.Name
                found[id] = {Id = id, Name = pet.Name}
            end
        end
    end
    return found
end

local function findPetsInWorkspace()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local isOwner = (obj:GetAttribute("OwnerId") == player.UserId) or (obj:GetAttribute("Owner") == player.Name)
            if not isOwner and CollectionService:HasTag(obj, "Roaming") then
                local root = getRoot()
                if root and (obj:GetPivot().Position - root.Position).Magnitude < 20 then
                    isOwner = true
                end
            end

            if isOwner then
                local id = obj:GetAttribute("UUID") or obj:GetAttribute("Id") or obj.Name
                found[id] = {Id = id, Name = obj.Name, Model = obj}
            end
        end
    end
    return found
end

AutoCollectTab:Toggle({
    Title    = "Auto Collect Money",
    Desc     = "ON = Universal Collect (No Teleport)",
    Value    = false,
    Callback = function(state)
        _collectEnabled = state
        
        if _collectThread then task.cancel(_collectThread); _collectThread = nil end

        if state then
            _collectThread = task.spawn(function()
                while _collectEnabled do
                    pcall(function()
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") 
                                       and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("collectPetCash")
                        
                        if not remote then return end

                        local allPets = findPetsInPlayer()
                        local wsPets  = findPetsInWorkspace()
                        for id, data in pairs(wsPets) do
                            if not allPets[id] then
                                allPets[id] = data
                            end
                        end

                        for id, data in pairs(allPets) do
                            if not _collectEnabled then break end
                            remote:FireServer(id)
                            task.wait(0.05)
                        end
                    end)
                    task.wait(_collectDelay)
                end
            end)
            WindUI:Notify({ Title = "Auto Collect", Content = "ON", Icon = "check", Duration = 2 })
        else
            WindUI:Notify({ Title = "Auto Collect", Content = "OFF", Icon = "x", Duration = 2 })
        end
    end,
})

-- ══════════════════════════════════════════════════════════════
--  AUTO EQUIP LASSO (firesignal)
-- ══════════════════════════════════════════════════════════════
pcall(function()
    local Event = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.7.0"].knit.Services.LassoService.RE.EquipLasso
    firesignal(Event.OnClientEvent, "Stellar Lasso")
end)

-- ══════════════════════════════════════════════════════════════
--  NOTIFY AWAL
-- ══════════════════════════════════════════════════════════════
WindUI:Notify({
    Title    = "elbilll",
    Content  = "Script berhasil dimuat!",
    Icon     = "check",
    Duration = 4,
    CanClose = true,
})