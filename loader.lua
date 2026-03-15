task.wait(1) 

local scripts = {
    [130594398886540] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/GardenHorizons.lua",
    [96645548064314]  = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/CAT.lua",
    [119987266683883] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/BrainrotHAMA.lua",
    [122446657157717] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/SA.lua",
    [114640202062357] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/SOFB.lua",
    [83369512629707]  = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/sawahindo.lua",
    [97365843755210]  = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/CGRB.lua",
}

local placeId = tonumber(game.PlaceId)
local url = scripts[placeId]

if not url then
    warn("[elbilll] PlaceId " .. tostring(placeId) .. " is not registered in the script list.")
    return
end

local ok, result = pcall(function()
    return game:HttpGet(url, true)
end)

if not ok or not result or result == "" then
    warn("[elbilll] Failed to fetch script: " .. tostring(result))
    return
end

local ok2, err = pcall(loadstring(result))
if not ok2 then
    warn("[elbilll] Error while executing script: " .. tostring(err))
end
