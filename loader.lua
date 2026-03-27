task.wait(1)

local scripts = {
    ["CatchAndTame"]     = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/CAT.lua",
    ["SurviveLAVAforBrainrots"]     = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/BrainrotHAMA.lua",
    ["SwingObbyforBrainrots"] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/SOFB.lua",
    ["CutGrassforBrainrots"] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/CGRB.lua",
    ["DigDEEPERforBrainrots"]  = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/DFB.lua",
}

local creatorMap = {
    [4127076] = "CatchAndTame",       
    [876852426] = "SurviveLAVAforBrainrots",
    [991021307] = "SwingObbyforBrainrots",
    [619942673] = "CutGrassforBrainrots",
    [231585978] = "DigDEEPERforBrainrots",
}

local gameName = creatorMap[game.CreatorId]
local url = gameName and scripts[gameName]

if not url then
    warn("[elbilll] Game ini tidak terdaftar. CreatorId: " .. tostring(game.CreatorId))
    return
end

local ok, result = pcall(function()
    return game:HttpGet(url, true)
end)
if not ok or not result or result == "" then
    warn("[elbilll] Gagal fetch script: " .. tostring(result))
    return
end

local ok2, err = pcall(loadstring(result))
if not ok2 then
    warn("[elbilll] Error eksekusi: " .. tostring(err))
end
