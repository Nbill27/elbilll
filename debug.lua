local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local LocalPlayer         = Players.LocalPlayer
local Camera              = workspace.CurrentCamera
local isMobile            = UserInputService.TouchEnabled

local function log(msg, ...)
    print("[DEBUG]", string.format(msg, ...))
end

local function warn_log(msg, ...)
    warn("[DEBUG]", string.format(msg, ...))
end

-- 1. REMOTE DETECTION
local _SkillCheckResultEvent = nil
pcall(function()
    _SkillCheckResultEvent = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("Generator", 5):WaitForChild("SkillCheckResultEvent", 5)
end)

-- 2. HELPERS
local function findNearestGeneratorPoint()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local genFolder = workspace:FindFirstChild("Map")
    genFolder = genFolder and genFolder:FindFirstChild("Generator")
    if not genFolder then return end

    local best, bestDist = nil, math.huge
    for _, obj in pairs(genFolder:GetChildren()) do
        if obj.Name:find("GeneratorPoint") then
            local pos = obj:IsA("Model") and obj:GetPivot().Position or (obj:IsA("BasePart") and obj.Position)
            if pos then
                local dist = (root.Position - pos).Magnitude
                if dist < bestDist then
                    bestDist, best = dist, obj
                end
            end
        end
    end
    return best, genFolder
end

local function findInteractButton()
    local PG = LocalPlayer.PlayerGui
    local vp = Camera.ViewportSize
    local minArea = vp.X * vp.Y * 0.01
    local best, bestScore = nil, 0

    for _, gui in pairs(PG:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, v in pairs(gui:GetDescendants()) do
                if v:IsA("ImageButton") or v:IsA("TextButton") then
                    local pos = v.AbsolutePosition
                    local sz = v.AbsoluteSize
                    if pos.X > vp.X * 0.5 and (sz.X * sz.Y) > minArea then
                        local score = (sz.X * sz.Y) * (v.Visible and 2 or 1)
                        if score > bestScore then
                            bestScore, best = score, v
                        end
                    end
                end
            end
        end
    end
    return best
end

-- 3. SIMULATION WRAPPERS
local function testRemote(folder, point)
    if not _SkillCheckResultEvent then return false, "Remote not found" end
    return pcall(function()
        _SkillCheckResultEvent:FireServer("success", 1, folder, point)
    end)
end

local function testInput(btn)
    if not btn then return false, "Button not found" end
    local pos = btn.AbsolutePosition + (btn.AbsoluteSize * 0.5)
    
    -- Method A: Connections
    pcall(function()
        for _, c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
        for _, c in pairs(getconnections(btn.Activated)) do c:Fire() end
    end)
    
    -- Method B: Touch
    pcall(function()
        VirtualInputManager:SendTouchEvent(0, pos, true)
        VirtualInputManager:SendTouchEvent(0, pos, false)
    end)
    
    return true
end

-- 4. MAIN MONITOR
log("Platform: %s | Remote: %s", isMobile and "MOBILE" or "PC", _SkillCheckResultEvent and "READY" or "MISSING")

local PG = LocalPlayer:WaitForChild("PlayerGui")
local CheckGui = PG:WaitForChild("SkillCheckPromptGui", 10)

if not CheckGui then
    warn_log("SkillCheckPromptGui not found after 10s. Manual check needed.")
    return
end

local Check = CheckGui:WaitForChild("Check", 5)
local Line  = Check and Check:WaitForChild("Line", 5)
local Goal  = Check and Check:WaitForChild("Goal", 5)

if not (Check and Line and Goal) then
    warn_log("Critical elements missing in GUI.")
    return
end

log("Listener Active. Start repair at generator...")

Check:GetPropertyChangedSignal("Visible"):Connect(function()
    if not Check.Visible then return end
    
    log("Skill Check Visible!")
    local hit = false
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not Check.Visible then connection:Disconnect(); return end
        if hit then return end

        local lr = Line.Rotation % 360
        local gr = Goal.Rotation % 360
        local offset = isMobile and 8 or 0
        local gs, ge = (gr + 104 - offset) % 360, (gr + 114) % 360
        
        local inZone = (gs > ge) and (lr >= gs or lr <= ge) or (lr >= gs and lr <= ge)
        
        if inZone then
            hit = true
            connection:Disconnect()
            log("PERFECT ZONE! Executing tests...")
            
            -- Test 1: Remote
            local point, folder = findNearestGeneratorPoint()
            local r_ok, r_err = testRemote(folder, point)
            log("Method 1 (Remote): %s", r_ok and "Fired" or r_err)
            
            -- Test 2: Input
            if isMobile then
                local btn = findInteractButton()
                local i_ok = testInput(btn)
                log("Method 2 (Input): %s", i_ok and ("Btn:" .. btn.Name) or "Failed")
            else
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.wait(0.01)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
                end)
                log("Method 2 (Space): Sent")
            end
        end
    end)
end)
