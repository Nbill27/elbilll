local GAME_ID = 130342654546662
if game.PlaceId ~= GAME_ID then
    warn("[elbilll] Script ini hanya bisa dijalankan di Sambung Kata!")
    warn("[elbilll] PlaceId sekarang : " .. tostring(game.PlaceId))
    warn("[elbilll] PlaceId dibutuhkan: " .. tostring(GAME_ID))
    return
end

local Players        = game:GetService("Players")
local CoreGui        = game:GetService("CoreGui")
local TweenService   = game:GetService("TweenService")
local UIS            = game:GetService("UserInputService")
local LocalPlayer    = Players.LocalPlayer

local parentGui = CoreGui
if not pcall(function() Instance.new("ScreenGui").Parent = CoreGui end) then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

if parentGui:FindFirstChild("elbilll_SambungKata") then
    parentGui.elbilll_SambungKata:Destroy()
end

-- ── Config
local URL_KAMUS   = "https://raw.githubusercontent.com/eenvyexe/KBBI/refs/heads/main/words.txt"
local KamusData   = {}
local isMinimized = false

-- ── Palette — Dark slate dengan aksen amber/gold
local C = {
    bg        = Color3.fromRGB(10,  11,  15),
    surface   = Color3.fromRGB(16,  18,  24),
    surface2  = Color3.fromRGB(22,  25,  34),
    border    = Color3.fromRGB(38,  42,  58),
    accent    = Color3.fromRGB(255, 190,  60),
    accentDim = Color3.fromRGB(140, 100,  20),
    text      = Color3.fromRGB(220, 222, 230),
    textDim   = Color3.fromRGB(100, 105, 125),
    textHot   = Color3.fromRGB(255, 215, 100),
    red       = Color3.fromRGB(230,  65,  65),
}

-- ── Ukuran tetap sama seperti asli
local W      = 180
local H_FULL = 235
local H_MIN  = 35

-- ================================================================
-- SCREEN GUI
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "elbilll_SambungKata"
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 100
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent         = parentGui

-- ── Outer glow (shadow layer)
local GlowFrame = Instance.new("Frame")
GlowFrame.Size                   = UDim2.new(0, 188, 0, 243)
GlowFrame.Position               = UDim2.new(1, -224, 0.5, -121)
GlowFrame.BackgroundColor3       = C.accent
GlowFrame.BackgroundTransparency = 0.82
GlowFrame.BorderSizePixel        = 0
GlowFrame.ZIndex                 = 0
GlowFrame.Parent                 = ScreenGui
Instance.new("UICorner", GlowFrame).CornerRadius = UDim.new(0, 14)

-- ── Main frame — 180x235, posisi sama persis asli
local Frame = Instance.new("Frame")
Frame.Name             = "MainFrame"
Frame.Size             = UDim2.new(0, W, 0, H_FULL)
Frame.Position         = UDim2.new(1, -220, 0.5, -117)
Frame.BackgroundColor3 = C.bg
Frame.BorderSizePixel  = 0
Frame.ClipsDescendants = true
Frame.ZIndex           = 1
Frame.Parent           = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Frame)
MainStroke.Color           = C.border
MainStroke.Thickness       = 1.2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ================================================================
-- DRAG SUPPORT (manual, works on mobile)
-- ================================================================
do
    local dragging, dragStart, startPos = false, nil, nil

    local function beginDrag(pos)
        dragging  = true
        dragStart = pos
        startPos  = Frame.Position
    end
    local function moveDrag(pos)
        if not dragging then return end
        local delta = pos - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        GlowFrame.Position = UDim2.new(
            Frame.Position.X.Scale, Frame.Position.X.Offset - 4,
            Frame.Position.Y.Scale, Frame.Position.Y.Offset - 4
        )
    end
    local function endDrag() dragging = false end

    Frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            beginDrag(inp.Position)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            moveDrag(inp.Position)
        end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
end

-- ================================================================
-- HEADER BAR
-- ================================================================
local Header = Instance.new("Frame")
Header.Size             = UDim2.new(1, 0, 0, 35)
Header.Position         = UDim2.new(0, 0, 0, 0)
Header.BackgroundColor3 = C.surface
Header.BorderSizePixel  = 0
Header.ZIndex           = 2
Header.Parent           = Frame

-- accent line di bawah header
local AccentLine = Instance.new("Frame")
AccentLine.Size             = UDim2.new(1, 0, 0, 2)
AccentLine.Position         = UDim2.new(0, 0, 1, -2)
AccentLine.BackgroundColor3 = C.accent
AccentLine.BackgroundTransparency = 0.4
AccentLine.BorderSizePixel  = 0
AccentLine.ZIndex           = 3
AccentLine.Parent           = Header

-- Nama script
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size                = UDim2.new(1, -72, 1, 0)
TitleLabel.Position            = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text                = "elbilll  /  sambung kata"
TitleLabel.TextColor3          = C.text
TitleLabel.Font                = Enum.Font.GothamBold
TitleLabel.TextSize            = 14
TitleLabel.TextXAlignment      = Enum.TextXAlignment.Left
TitleLabel.ZIndex              = 3
TitleLabel.Parent              = Header

-- Tombol minimize
local BtnMin = Instance.new("TextButton")
BtnMin.Size             = UDim2.new(0, 26, 0, 26)
BtnMin.Position         = UDim2.new(1, -58, 0.5, -13)
BtnMin.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
BtnMin.Text             = "–"
BtnMin.TextColor3       = C.text
BtnMin.Font             = Enum.Font.GothamSemibold
BtnMin.TextSize         = 16
BtnMin.ZIndex           = 4
BtnMin.Parent           = Header
Instance.new("UICorner", BtnMin).CornerRadius = UDim.new(0, 6)

-- Tombol close
local BtnClose = Instance.new("TextButton")
BtnClose.Size             = UDim2.new(0, 26, 0, 26)
BtnClose.Position         = UDim2.new(1, -28, 0.5, -13)
BtnClose.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
BtnClose.Text             = "×"
BtnClose.TextColor3       = Color3.fromRGB(255, 255, 255)
BtnClose.Font             = Enum.Font.GothamSemibold
BtnClose.TextSize         = 18
BtnClose.ZIndex           = 4
BtnClose.Parent           = Header
Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(0, 6)

-- ================================================================
-- BODY (search + results)
-- ================================================================
local Body = Instance.new("Frame")
Body.Name             = "Body"
Body.Size             = UDim2.new(1, 0, 1, -H_MIN)
Body.Position         = UDim2.new(0, 0, 0, H_MIN)
Body.BackgroundTransparency = 1
Body.ClipsDescendants = true
Body.ZIndex           = 2
Body.Parent           = Frame

-- Search box container
local SearchBg = Instance.new("Frame")
SearchBg.Size             = UDim2.new(1, -20, 0, 35)
SearchBg.Position         = UDim2.new(0, 10, 0, 10)
SearchBg.BackgroundColor3 = C.surface2
SearchBg.BorderSizePixel  = 0
SearchBg.ZIndex           = 3
SearchBg.Parent           = Body
Instance.new("UICorner", SearchBg).CornerRadius = UDim.new(0, 7)

local SearchStroke = Instance.new("UIStroke", SearchBg)
SearchStroke.Color     = C.border
SearchStroke.Thickness = 1

-- prefix label ">" di dalam search box
local SearchPrefix = Instance.new("TextLabel")
SearchPrefix.Size             = UDim2.new(0, 18, 1, 0)
SearchPrefix.Position         = UDim2.new(0, 8, 0, 0)
SearchPrefix.BackgroundTransparency = 1
SearchPrefix.Text             = "›"
SearchPrefix.TextColor3       = C.accent
SearchPrefix.Font             = Enum.Font.GothamSemibold
SearchPrefix.TextSize         = 16
SearchPrefix.ZIndex           = 4
SearchPrefix.Parent           = SearchBg

local InputBox = Instance.new("TextBox")
InputBox.Size             = UDim2.new(1, -30, 1, 0)
InputBox.Position         = UDim2.new(0, 26, 0, 0)
InputBox.BackgroundTransparency = 1
InputBox.TextColor3       = C.textHot
InputBox.PlaceholderText  = "Booting database..."
InputBox.PlaceholderColor3 = C.textDim
InputBox.TextEditable     = false
InputBox.Font             = Enum.Font.Gotham
InputBox.TextSize         = 14
InputBox.ClearTextOnFocus = false
InputBox.TextXAlignment   = Enum.TextXAlignment.Left
InputBox.ZIndex           = 4
InputBox.Parent           = SearchBg

-- Garis pemisah
local Divider = Instance.new("Frame")
Divider.Size             = UDim2.new(1, -20, 0, 1)
Divider.Position         = UDim2.new(0, 10, 0, (35) + 16)
Divider.BackgroundColor3 = C.border
Divider.BorderSizePixel  = 0
Divider.ZIndex           = 3
Divider.Parent           = Body

-- Scroll frame untuk hasil
local ResultOffset = 59
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size                = UDim2.new(1, -20, 1, -(ResultOffset + 8))
ScrollFrame.Position            = UDim2.new(0, 10, 0, ResultOffset)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel     = 0
ScrollFrame.ScrollBarThickness  = 2
ScrollFrame.ScrollBarImageColor3 = C.accentDim
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
ScrollFrame.ZIndex              = 3
ScrollFrame.Parent              = Body

local ResultLabel = Instance.new("TextLabel")
ResultLabel.Size              = UDim2.new(1, -4, 0, 0)
ResultLabel.Position          = UDim2.new(0, 0, 0, 0)
ResultLabel.BackgroundTransparency = 1
ResultLabel.TextColor3        = C.text
ResultLabel.Text              = "Waiting for input..."
ResultLabel.Font              = Enum.Font.Gotham
ResultLabel.TextSize          = 13
ResultLabel.TextYAlignment    = Enum.TextYAlignment.Top
ResultLabel.TextXAlignment    = Enum.TextXAlignment.Left
ResultLabel.AutomaticSize     = Enum.AutomaticSize.Y
ResultLabel.TextWrapped       = true
ResultLabel.ZIndex            = 4
ResultLabel.Parent            = ScrollFrame

-- Footer / watermark
local Footer = Instance.new("TextLabel")
Footer.Size             = UDim2.new(1, 0, 0, 18)
Footer.Position         = UDim2.new(0, 0, 1, -18)
Footer.BackgroundTransparency = 1
Footer.Text             = "elbilll  |  discord.gg/nJHyfxNMqm"
Footer.TextColor3       = C.accentDim
Footer.Font             = Enum.Font.Gotham
Footer.TextSize         = 11
Footer.TextXAlignment   = Enum.TextXAlignment.Center
Footer.ZIndex           = 3
Footer.Parent           = Body

-- ================================================================
-- INTRO OVERLAY
-- ================================================================
local Intro = Instance.new("Frame")
Intro.Size             = UDim2.new(1, 0, 1, 0)
Intro.BackgroundColor3 = C.bg
Intro.Active           = true
Intro.ZIndex           = 20
Intro.Parent           = Frame
Instance.new("UICorner", Intro).CornerRadius = UDim.new(0, 12)

-- nama besar
local IntroName = Instance.new("TextLabel")
IntroName.Size             = UDim2.new(1, -20, 0, 40)
IntroName.Position         = UDim2.new(0, 10, 0.28, 0)
IntroName.BackgroundTransparency = 1
IntroName.Text             = "elbilll"
IntroName.TextColor3       = C.accent
IntroName.Font             = Enum.Font.GothamBold
IntroName.TextSize         = 28
IntroName.ZIndex           = 21
IntroName.Parent           = Intro

-- garis bawah judul
local IntroLine = Instance.new("Frame")
IntroLine.Size             = UDim2.new(0, 40, 0, 2)
IntroLine.Position         = UDim2.new(0.5, -20, 0, 0)
IntroLine.AnchorPoint      = Vector2.new(0, 0)
IntroLine.BackgroundColor3 = C.accent
IntroLine.BackgroundTransparency = 0.3
IntroLine.BorderSizePixel  = 0
IntroLine.ZIndex           = 21
IntroLine.Parent           = IntroName

local IntroSub = Instance.new("TextLabel")
IntroSub.Size             = UDim2.new(1, -20, 0, 22)
IntroSub.Position         = UDim2.new(0, 10, 0.56, 0)
IntroSub.BackgroundTransparency = 1
IntroSub.Text             = "sambung kata"
IntroSub.TextColor3       = C.textDim
IntroSub.Font             = Enum.Font.Gotham
IntroSub.TextSize         = 13
IntroSub.ZIndex           = 21
IntroSub.Parent           = Intro

local IntroStatus = Instance.new("TextLabel")
IntroStatus.Size             = UDim2.new(1, -20, 0, 18)
IntroStatus.Position         = UDim2.new(0, 10, 0.72, 0)
IntroStatus.BackgroundTransparency = 1
IntroStatus.Text             = "initializing..."
IntroStatus.TextColor3       = C.textDim
IntroStatus.Font             = Enum.Font.Gotham
IntroStatus.TextSize         = 11
IntroStatus.ZIndex           = 21
IntroStatus.Parent           = Intro

-- animate loading dots
task.spawn(function()
    local dots = {"initializing.", "initializing..", "initializing...", "loading data...", "ready."}
    for i, txt in ipairs(dots) do
        task.wait(0.55)
        if IntroStatus and IntroStatus.Parent then
            IntroStatus.Text = txt
        end
    end
end)

-- fade out intro setelah 3.5 detik
task.spawn(function()
    task.wait(3.5)
    if not Intro or not Intro.Parent then return end
    IntroStatus.Text = "ready."
    task.wait(0.4)

    local ti = TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Intro,      ti, {BackgroundTransparency = 1}):Play()
    TweenService:Create(IntroName,  ti, {TextTransparency       = 1}):Play()
    TweenService:Create(IntroSub,   ti, {TextTransparency       = 1}):Play()
    TweenService:Create(IntroStatus,ti, {TextTransparency       = 1}):Play()
    TweenService:Create(IntroLine,  ti, {BackgroundTransparency = 1}):Play()
    task.wait(1.1)
    if Intro and Intro.Parent then Intro:Destroy() end
end)

-- ================================================================
-- LOGIC
-- ================================================================
local function searchWord()
    local raw   = InputBox.Text or ""
    local query = string.lower(string.match(raw, "%a+") or "")

    if query == "" then
        ResultLabel.Text      = "Waiting for input..."
        ResultLabel.TextColor3 = C.textDim
        return
    end

    local found = {}
    local limit = 40

    for _, word in ipairs(KamusData) do
        if string.sub(word, 1, #query) == query then
            table.insert(found, word:upper())
            if #found >= limit then break end
        end
    end

    if #found > 0 then
        ResultLabel.Text       = table.concat(found, "\n")
        ResultLabel.TextColor3 = C.textHot
    else
        ResultLabel.Text       = "no match found."
        ResultLabel.TextColor3 = C.red
    end
end

-- load database
task.spawn(function()
    local ok, res = pcall(function()
        return game:HttpGet(URL_KAMUS)
    end)

    if ok and res then
        local seen = {}
        for line in string.gmatch(res, "[^\r\n]+") do
            local word = string.match(line, "([%a]+)")
            if word and #word > 1 then
                local w = string.lower(word)
                if not string.find(w, "%-") and not seen[w] then
                    seen[w] = true
                    table.insert(KamusData, w)
                end
            end
        end

        task.wait(3.5) -- tunggu intro selesai
        local count = math.floor(#KamusData / 1000)
        TitleLabel.Text = "elbilll  /  sambung kata"
        InputBox.PlaceholderText = "type prefix..."
        InputBox.TextEditable    = true

        -- flash accent biar keliatan loaded
        TweenService:Create(MainStroke, TweenInfo.new(0.3), {Color = C.accent}):Play()
        task.wait(0.8)
        TweenService:Create(MainStroke, TweenInfo.new(0.5), {Color = C.border}):Play()
    else
        task.wait(3.5)
        TitleLabel.Text      = "connection error"
        TitleLabel.TextColor3 = C.red
        ResultLabel.Text      = "failed to load database."
        ResultLabel.TextColor3 = C.red
    end
end)

-- ================================================================
-- EVENTS
-- ================================================================
BtnMin.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetH   = isMinimized and 35 or 235
    local targetGH  = isMinimized and 43 or 243
    local targetPY  = isMinimized and -17 or -117

    local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Frame,     ti, {Size = UDim2.new(0, W, 0, targetH)}):Play()
    TweenService:Create(GlowFrame, ti, {
        Size     = UDim2.new(0, W + 8, 0, targetGH),
        Position = UDim2.new(
            Frame.Position.X.Scale, Frame.Position.X.Offset - 4,
            0.5, targetPY - 4
        )
    }):Play()

    BtnMin.Text = isMinimized and "+" or "–"
end)

BtnClose.MouseButton1Click:Connect(function()
    local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(Frame,     ti, {BackgroundTransparency = 1}):Play()
    TweenService:Create(GlowFrame, ti, {BackgroundTransparency = 1}):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

InputBox:GetPropertyChangedSignal("Text"):Connect(searchWord)