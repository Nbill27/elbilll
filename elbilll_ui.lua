-- // elbilll UI | Custom Standalone Library
-- // Based on VelarisUI/Brigida aesthetics
-- // Optimized for performance and standalone usage

local UI = {}

-- [[ SERVICES ]]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")

-- [[ THEME ]]
local Theme = {
    Accent = Color3.fromRGB(255, 0, 0), -- Default Red
    Background = Color3.fromRGB(15, 15, 15),
    CornerRadius = UDim.new(0, 8),
    Transparency = 0.15
}

-- [[ ICONS (Lucide/Solar IDs) ]]
local Icons = {
    ["home"] = "rbxassetid://10723345518",
    ["settings"] = "rbxassetid://10723391215",
    ["user"] = "rbxassetid://10723395963",
    ["shield"] = "rbxassetid://10723392301",
    ["zap"] = "rbxassetid://10723401539",
    ["terminal"] = "rbxassetid://10723393963",
    ["layers"] = "rbxassetid://10723377755",
    ["map"] = "rbxassetid://10723380481",
    ["shopping-cart"] = "rbxassetid://10723392813",
    ["database"] = "rbxassetid://10723348123",
    ["mouse-pointer"] = "rbxassetid://10723383827",
    ["copy"] = "rbxassetid://10723346514",
    ["chevron-right"] = "rbxassetid://10723346158",
    ["chevron-down"] = "rbxassetid://10723346082",
    ["cross"] = "rbxassetid://9886659671",
    ["minus"] = "rbxassetid://9886659276",
    ["info"] = "rbxassetid://10723363361",
    ["box"] = "rbxassetid://10723346210",
    ["trending-up"] = "rbxassetid://10723394761",
    ["person-standing"] = "rbxassetid://10723387795",
    ["run"] = "rbxassetid://10723387795",
    ["eye"] = "rbxassetid://10723351336",
    ["link"] = "rbxassetid://10723377884",
    ["sword"] = "rbxassetid://10723393963",
    ["star"] = "rbxassetid://10723391781",
    ["coins"] = "rbxassetid://10723346383",
    ["navigation"] = "rbxassetid://10723384260",
    ["sparkles"] = "rbxassetid://10723391515",
    ["plane"] = "rbxassetid://10723388046",
    ["ghost"] = "rbxassetid://10723361517",
    ["anchor"] = "rbxassetid://10723343468",
    ["flame"] = "rbxassetid://10723352694",
    ["dna"] = "rbxassetid://10723349607",
    ["tag"] = "rbxassetid://10723393931"
}

-- [[ UTILITIES ]]
local function GetIcon(name)
    if not name or name == "" then return "" end
    name = name:lower():gsub("lucide:", "")
    if name:match("^%d+$") then return "rbxassetid://" .. name end
    if name:match("^rbxassetid://") then return name end
    return Icons[name] or Icons["home"]
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

local function Ripple(button)
    button.ClipsDescendants = true
    button.MouseButton1Click:Connect(function()
        local circle = Instance.new("ImageLabel")
        circle.Image = "rbxassetid://266543268"
        circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        circle.ImageTransparency = 0.8
        circle.BackgroundTransparency = 1
        circle.ZIndex = 10
        circle.Size = UDim2.fromOffset(0, 0)
        circle.Parent = button

        local mPos = Vector2.new(Mouse.X - button.AbsolutePosition.X, Mouse.Y - button.AbsolutePosition.Y)
        circle.Position = UDim2.fromOffset(mPos.X, mPos.Y)

        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        TweenService:Create(circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(size, size),
            Position = UDim2.fromOffset(mPos.X - size/2, mPos.Y - size/2),
            ImageTransparency = 1
        }):Play()

        task.wait(0.5)
        circle:Destroy()
    end)
end

-- [[ NOTIFICATIONS ]]
local NotifyContainer = nil
function UI:MakeNotify(config)
    config = config or {}
    local Title = config.Title or "Notification"
    local Content = config.Content or "Message content here"
    local Delay = config.Delay or 5
    local Icon = GetIcon(config.Icon or "shield")

    if not NotifyContainer then
        NotifyContainer = Instance.new("ScreenGui")
        NotifyContainer.Name = "elbilll_Notifications"
        NotifyContainer.DisplayOrder = 100
        NotifyContainer.Parent = CoreGui
        
        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 10)
        List.VerticalAlignment = Enum.VerticalAlignment.Bottom
        List.HorizontalAlignment = Enum.HorizontalAlignment.Right
        List.Parent = NotifyContainer
        
        local Padding = Instance.new("UIPadding")
        Padding.PaddingBottom = UDim.new(0, 20)
        Padding.PaddingRight = UDim.new(0, 20)
        Padding.Parent = NotifyContainer
    end

    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "Notify"
    NotifyFrame.Size = UDim2.new(0, 250, 0, 60)
    NotifyFrame.BackgroundColor3 = Theme.Background
    NotifyFrame.BackgroundTransparency = 0.2
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.Parent = NotifyContainer
    Instance.new("UICorner", NotifyFrame)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Accent
    Stroke.Transparency = 0.5
    Stroke.Parent = NotifyFrame

    local IconLabel = Instance.new("ImageLabel")
    IconLabel.Size = UDim2.new(0, 24, 0, 24)
    IconLabel.Position = UDim2.new(0, 10, 0.5, -12)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Image = Icon
    IconLabel.ImageColor3 = Theme.Accent
    IconLabel.Parent = NotifyFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = Theme.Accent
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 45, 0, 10)
    TitleLabel.Size = UDim2.new(1, -55, 0, 15)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = NotifyFrame

    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Text = Content
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ContentLabel.TextSize = 11
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextWrapped = true
    ContentLabel.Position = UDim2.new(0, 45, 0, 25)
    ContentLabel.Size = UDim2.new(1, -55, 0, 25)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Parent = NotifyFrame

    -- Animation
    NotifyFrame.Position = UDim2.new(1, 300, 1, 0)
    TweenService:Create(NotifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 1, 0)}):Play()
    
    task.delay(Delay, function()
        TweenService:Create(NotifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 300, 1, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        NotifyFrame:Destroy()
    end)
end

-- [[ WINDOW ]]
function UI:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "elbilll UI"
    local Footer = config.Footer or "Scripting Service"
    local AccentColor = config.Color or Theme.Accent

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "elbilll_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.BackgroundColor3 = Theme.Background
    Main.BackgroundTransparency = Theme.Transparency
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, -300, 0.5, -200)
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = Theme.CornerRadius
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.8
    MainStroke.Parent = Main

    local Topbar = Instance.new("Frame")
    Topbar.Name = "Topbar"
    Topbar.Size = UDim2.new(1, 0, 0, 40)
    Topbar.BackgroundTransparency = 1
    Topbar.Parent = Main
    MakeDraggable(Topbar, Main)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Text = Title
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = AccentColor
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = Topbar

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundTransparency = 1
    Sidebar.Parent = Main

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -160, 1, -50)
    ContentArea.Position = UDim2.new(0, 155, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Main

    local Pages = Instance.new("Folder", ContentArea)
    local PageLayout = Instance.new("UIPageLayout", Pages)
    PageLayout.TweenTime = 0.4
    PageLayout.EasingStyle = Enum.EasingStyle.Quad

    local WindowAPI = {}
    local Flags = {}

    -- Config Logic
    local FolderName = config.ConfigFolder or "elbilll_UI"
    local AutoSave = config.AutoSave or false
    
    local function SaveConfig()
        if not isfolder(FolderName) then makefolder(FolderName) end
        local data = {}
        for flag, val in pairs(Flags) do data[flag] = val end
        writefile(FolderName .. "/config.json", HttpService:JSONEncode(data))
    end

    local function LoadConfig()
        if isfile(FolderName .. "/config.json") then
            local data = HttpService:JSONDecode(readfile(FolderName .. "/config.json"))
            for flag, val in pairs(data) do Flags[flag] = val end
        end
    end

    function WindowAPI:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local Name = tabConfig.Name or "Tab"
        local Icon = GetIcon(tabConfig.Icon or "home")

        local TabButton = Instance.new("TextButton")
        TabButton.Name = Name
        TabButton.Size = UDim2.new(1, -10, 0, 30)
        TabButton.BackgroundColor3 = AccentColor
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.Parent = TabContainer
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 4)

        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = Icon
        TabIcon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        TabIcon.Parent = TabButton

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Text = Name
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Position = UDim2.new(0, 32, 0, 0)
        TabLabel.Size = UDim2.new(1, -35, 1, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Parent = TabButton

        local Page = Instance.new("ScrollingFrame")
        Page.Name = Name
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = AccentColor
        Page.Visible = false
        Page.Parent = Pages
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
        Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 5)

        TabButton.MouseButton1Click:Connect(function()
            PageLayout:JumpTo(Page)
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(btn:FindFirstChild("TextLabel"), TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                    TweenService:Create(btn:FindFirstChild("ImageLabel"), TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
                end
            end
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(TabIcon, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        local TabAPI = {}

        function TabAPI:AddSection(name)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Name = "Section_" .. name
            SectionLabel.Text = string.upper(name)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextColor3 = AccentColor
            SectionLabel.TextSize = 10
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Size = UDim2.new(1, -10, 0, 20)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Parent = Page
            
            local Underline = Instance.new("Frame")
            Underline.Size = UDim2.new(1, 0, 0, 1)
            Underline.Position = UDim2.new(0, 0, 1, 0)
            Underline.BackgroundColor3 = AccentColor
            Underline.BackgroundTransparency = 0.8
            Underline.BorderSizePixel = 0
            Underline.Parent = SectionLabel
        end

        function TabAPI:AddButton(btnConfig)
            btnConfig = btnConfig or {}
            local Name = btnConfig.Name or "Button"
            local Callback = btnConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Name = "Button_" .. Name
            Frame.Size = UDim2.new(1, -10, 0, 35)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            
            local Label = Instance.new("TextLabel")
            Label.Text = Name
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Parent = Frame
            
            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(1, -26, 0.5, -8)
            Icon.BackgroundTransparency = 1
            Icon.Image = GetIcon("chevron-right")
            Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            Icon.Parent = Frame

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Frame
            Btn.MouseButton1Click:Connect(Callback)
            Ripple(Btn)

            return {Set = function(_, text) Label.Text = text end}
        end

        function TabAPI:AddToggle(togConfig)
            togConfig = togConfig or {}
            local Name = togConfig.Name or "Toggle"
            local Default = togConfig.Default or false
            local Callback = togConfig.Callback or function() end
            local Flag = togConfig.Flag
            
            local Toggled = Default
            if Flag then 
                if Flags[Flag] ~= nil then Toggled = Flags[Flag] end
            end

            local Frame = Instance.new("Frame")
            Frame.Name = "Toggle_" .. Name
            Frame.Size = UDim2.new(1, -10, 0, 35)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Name
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Parent = Frame

            local ToggleBg = Instance.new("Frame")
            ToggleBg.Size = UDim2.new(0, 30, 0, 16)
            ToggleBg.Position = UDim2.new(1, -40, 0.5, -8)
            ToggleBg.BackgroundColor3 = Toggled and AccentColor or Color3.fromRGB(60, 60, 60)
            ToggleBg.Parent = Frame
            Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)

            local ToggleDot = Instance.new("Frame")
            ToggleDot.Size = UDim2.new(0, 12, 0, 12)
            ToggleDot.Position = Toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleDot.Parent = ToggleBg
            Instance.new("UICorner", ToggleDot).CornerRadius = UDim.new(1, 0)

            local function SetState(state)
                Toggled = state
                TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = Toggled and AccentColor or Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(ToggleDot, TweenInfo.new(0.3), {Position = Toggled and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
                if Flag then Flags[Flag] = Toggled end
                if AutoSave then SaveConfig() end
                Callback(Toggled)
            end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Frame
            Btn.MouseButton1Click:Connect(function() SetState(not Toggled) end)

            local ToggleAPI = {}
            function ToggleAPI:Set(state) SetState(state) end
            return ToggleAPI
        end
        function TabAPI:AddSlider(sldConfig)
            sldConfig = sldConfig or {}
            local Name = sldConfig.Name or "Slider"
            local Min = sldConfig.Min or 0
            local Max = sldConfig.Max or 100
            local Default = sldConfig.Default or Min
            local Callback = sldConfig.Callback or function() end
            local Flag = sldConfig.Flag
            
            local Value = Default
            if Flag then 
                if Flags[Flag] ~= nil then Value = Flags[Flag] end
            end

            local Frame = Instance.new("Frame")
            Frame.Name = "Slider_" .. Name
            Frame.Size = UDim2.new(1, -10, 0, 45)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Name
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.Size = UDim2.new(1, -70, 0, 15)
            Label.BackgroundTransparency = 1
            Label.Parent = Frame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Text = tostring(Value)
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextColor3 = AccentColor
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.Size = UDim2.new(0, 50, 0, 15)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Parent = Frame

            local SliderBg = Instance.new("Frame")
            SliderBg.Size = UDim2.new(1, -20, 0, 4)
            SliderBg.Position = UDim2.new(0, 10, 0, 30)
            SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SliderBg.Parent = Frame
            Instance.new("UICorner", SliderBg)

            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = AccentColor
            SliderFill.Parent = SliderBg
            Instance.new("UICorner", SliderFill)

            local function UpdateSlider(input)
                local percentage = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                Value = math.floor(Min + (Max - Min) * percentage)
                ValueLabel.Text = tostring(Value)
                TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                if Flag then Flags[Flag] = Value end
                if AutoSave then SaveConfig() end
                Callback(Value)
            end

            local dragging = false
            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)

            local SliderAPI = {}
            function SliderAPI:Set(val)
                Value = math.clamp(val, Min, Max)
                ValueLabel.Text = tostring(Value)
                SliderFill.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
                if Flag then Flags[Flag] = Value end
                if AutoSave then SaveConfig() end
                Callback(Value)
            end
            return SliderAPI
        end

        function TabAPI:AddDropdown(drpConfig)
            drpConfig = drpConfig or {}
            local Name = drpConfig.Name or "Dropdown"
            local Options = drpConfig.Options or {}
            local Default = drpConfig.Default
            local Multi = drpConfig.Multi or false
            local Callback = drpConfig.Callback or function() end
            local Flag = drpConfig.Flag
            
            local Selected = Default
            if Flag then 
                if Flags[Flag] ~= nil then 
                    Selected = Flags[Flag]
                end
            end
            
            if Multi and type(Selected) ~= "table" then Selected = {} end
            if not Multi and type(Selected) == "table" then Selected = Selected[1] end

            local Frame = Instance.new("Frame")
            Frame.Name = "Dropdown_" .. Name
            Frame.Size = UDim2.new(1, -10, 0, 35)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Page
            Frame.ClipsDescendants = true
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local function GetDisplayText()
                if Multi then
                    local count = 0
                    for _ in pairs(Selected) do count = count + 1 end
                    return Name .. ": (" .. count .. ") selected"
                end
                return Name .. (Selected and (": " .. tostring(Selected)) or "")
            end

            local Label = Instance.new("TextLabel")
            Label.Text = GetDisplayText()
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(1, -30, 0, 35)
            Label.BackgroundTransparency = 1
            Label.Parent = Frame

            local Arrow = Instance.new("ImageLabel")
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Position = UDim2.new(1, -26, 0, 9)
            Arrow.BackgroundTransparency = 1
            Arrow.Image = GetIcon("chevron-down")
            Arrow.ImageColor3 = Color3.fromRGB(150, 150, 150)
            Arrow.Parent = Frame

            local OptionList = Instance.new("Frame")
            OptionList.Size = UDim2.new(1, 0, 0, 0)
            OptionList.Position = UDim2.new(0, 0, 0, 35)
            OptionList.BackgroundTransparency = 1
            OptionList.Parent = Frame
            local UIList = Instance.new("UIListLayout", OptionList)
            UIList.Padding = UDim.new(0, 2)

            local Opened = false
            local function ToggleDropdown()
                Opened = not Opened
                local targetSize = Opened and (35 + UIList.AbsoluteContentSize.Y + 5) or 35
                TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, targetSize)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Opened and 180 or 0}):Play()
            end

            local function RefreshOptions()
                for _, child in pairs(OptionList:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, option in ipairs(Options) do
                    local isSelected = false
                    if Multi then
                        isSelected = Selected[option] ~= nil
                    else
                        isSelected = Selected == option
                    end

                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 25)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.Text = tostring(option)
                    OptBtn.TextColor3 = isSelected and AccentColor or Color3.fromRGB(180, 180, 180)
                    OptBtn.TextSize = 12
                    OptBtn.Parent = OptionList
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        if Multi then
                            if Selected[option] then Selected[option] = nil else Selected[option] = true end
                        else
                            Selected = option
                            ToggleDropdown()
                        end
                        
                        Label.Text = GetDisplayText()
                        if Flag then Flags[Flag] = Selected end
                        if AutoSave then SaveConfig() end
                        Callback(Selected)
                        RefreshOptions()
                    end)
                end
            end
            RefreshOptions()

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            Btn.Parent = Frame
            Btn.MouseButton1Click:Connect(ToggleDropdown)

            local DropdownAPI = {}
            function DropdownAPI:Refresh(newOptions)
                Options = newOptions or {}
                RefreshOptions()
            end
            function DropdownAPI:Set(val)
                Selected = val
                Label.Text = GetDisplayText()
                if Flag then Flags[Flag] = Selected end
                if AutoSave then SaveConfig() end
                Callback(Selected)
                RefreshOptions()
            end
            return DropdownAPI
        end

        function TabAPI:AddInput(inpConfig)
            inpConfig = inpConfig or {}
            local Name = inpConfig.Name or "Input"
            local Placeholder = inpConfig.Placeholder or "Type here..."
            local Default = inpConfig.Default or ""
            local Callback = inpConfig.Callback or function() end

            local Frame = Instance.new("Frame")
            Frame.Name = "Input_" .. Name
            Frame.Size = UDim2.new(1, -10, 0, 35)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Label = Instance.new("TextLabel")
            Label.Text = Name
            Label.Font = Enum.Font.GothamBold
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.Size = UDim2.new(0.4, -10, 1, 0)
            Label.BackgroundTransparency = 1
            Label.Parent = Frame

            local TextBox = Instance.new("TextBox")
            TextBox.Name = "TextBox"
            TextBox.Size = UDim2.new(0.6, -10, 0, 25)
            TextBox.Position = UDim2.new(0.4, 5, 0.5, -12)
            TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            TextBox.BorderSizePixel = 0
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderText = Placeholder
            TextBox.Text = Default
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.TextSize = 12
            TextBox.Parent = Frame
            Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)

            TextBox.FocusLost:Connect(function(enterPressed)
                Callback(TextBox.Text, enterPressed)
            end)

            local InputAPI = {}
            function InputAPI:Set(val)
                TextBox.Text = val
                Callback(val, false)
            end
            return InputAPI
        end

        function TabAPI:AddParagraph(parConfig)
            parConfig = parConfig or {}
            local Title = parConfig.Title or "Paragraph"
            local Content = parConfig.Content or "Paragraph content goes here."

            local Frame = Instance.new("Frame")
            Frame.Name = "Paragraph_" .. Title
            Frame.Size = UDim2.new(1, -10, 0, 50)
            Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Frame.BackgroundTransparency = 0.5
            Frame.AutomaticSize = Enum.AutomaticSize.Y
            Frame.Parent = Page
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Text = Title
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextColor3 = AccentColor
            TitleLabel.TextSize = 13
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Position = UDim2.new(0, 10, 0, 8)
            TitleLabel.Size = UDim2.new(1, -20, 0, 15)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Parent = Frame

            local ContentLabel = Instance.new("TextLabel")
            ContentLabel.Text = Content
            ContentLabel.Font = Enum.Font.Gotham
            ContentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            ContentLabel.TextSize = 11
            ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
            ContentLabel.TextWrapped = true
            ContentLabel.Position = UDim2.new(0, 10, 0, 25)
            ContentLabel.Size = UDim2.new(1, -20, 0, 0)
            ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
            ContentLabel.BackgroundTransparency = 1
            ContentLabel.Parent = Frame
            
            local Padding = Instance.new("UIPadding", Frame)
            Padding.PaddingBottom = UDim.new(0, 8)

            local ParagraphAPI = {}
            function ParagraphAPI:SetTitle(val) TitleLabel.Text = val end
            function ParagraphAPI:SetContent(val) ContentLabel.Text = val end
            return ParagraphAPI
        end

        return TabAPI
    end

    function WindowAPI:Notify(ntConfig)
        return UI:MakeNotify(ntConfig)
    end

    -- Toggle Logic
    local ToggleKey = config.Keybind or Enum.KeyCode.RightShift
    local Visible = true

    local function SetVisible(state)
        Visible = state
        Main.Visible = Visible
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == ToggleKey then
            SetVisible(not Visible)
        end
    end)

    -- Close/Min Buttons
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 14
    CloseBtn.Parent = Topbar
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Auto Load
    if config.AutoLoad then
        LoadConfig()
    end

    return WindowAPI
end

return UI
