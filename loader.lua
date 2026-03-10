local scripts = {
    [130594398886540] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/GardenHorizons.lua",
    [93978595733734]  = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/script.lua",
    [96645548064314]  = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/CAT.lua",
    [119987266683883] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/BrainrotHAMA.lua",
    [122446657157717] = "https://raw.githubusercontent.com/Nbill27/elbilll/refs/heads/main/SA.lua",
}

local url = scripts[game.PlaceId]
if url then
    local success, content = pcall(function() return game:HttpGet(url) end)
    if success then
        loadstring(content)()
    end

end
