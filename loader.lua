-- elbilll Universal Loader
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player       = Players.LocalPlayer

local GARDEN_HORIZONS   = 130594398886540
local VIOLENCE_DISTRICT = 93978595733734
local CATCH_AND_TAME    = 96645548064314
local LAVA_BRAINROT     = 119987266683883
local SNIPER_ARENA      = 122446657157717

local scripts = {
    [GARDEN_HORIZONS]   = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/GardenHorizons.lua",
    [VIOLENCE_DISTRICT] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/script.lua",
    [CATCH_AND_TAME]    = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/CAT.lua",
    [LAVA_BRAINROT]    = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/Brainrot.lua",
    [SNIPER_ARENA]      = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/sa.lua",
}

local url = scripts[game.PlaceId]

if url then
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        loadstring(result)()
    else
        warn("elbilll: Failed to fetch script from GitHub! URL: " .. url)
    end
else
    print("elbilll: Game not registered. Current Place ID: " .. game.PlaceId)
end
