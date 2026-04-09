-- // elbilll UI | Test Script
-- // Gunakan ini untuk mengetes semua fitur library lokal

local UI = nil
local success, err = pcall(function()
    -- Memuat library dari file lokal
    UI = loadstring(readfile("elbilll_ui.lua"))()
end)

if not success or not UI then
    warn("[elbilll] Gagal memuat library: " .. tostring(err))
    -- Link fallback jika file lokal tidak ada (Opsional: ganti dengan link GitHub Anda nanti)
    -- UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/.../elbilll_ui.lua"))()
    return
end

-- 1. Create Window
local Window = UI:CreateWindow({
    Title = "elbilll Hub",
    Footer = "Standalone Edition",
    Color = Color3.fromRGB(255, 0, 0), -- Warna Merah Accent
    ConfigFolder = "elbilll_TestConfig",
    AutoSave = true,
    AutoLoad = true
})

-- 2. Add Tabs
local MainTab = Window:AddTab({ Name = "Main Features", Icon = "zap" })
local SettingTab = Window:AddTab({ Name = "Settings", Icon = "settings" })

-- 3. Main Features
MainTab:AddSection("Farming Tools")

MainTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm_Toggle",
    Callback = function(v)
        print("Auto Farm status:", v)
    end
})

MainTab:AddSlider({
    Name = "Walkspeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Flag = "Walkspeed_Val",
    Callback = function(v)
        print("Speed set to:", v)
    end
})

MainTab:AddSection("Selection Tools")

-- TEST MULTI-DROPDOWN
MainTab:AddDropdown({
    Name = "Select Bosses",
    Options = {"Kaido", "Big Mom", "Shanks", "Blackbeard", "Luffy"},
    Default = {"Kaido"},
    Multi = true, -- Fitur Baru
    Flag = "BossSelection",
    Callback = function(table)
        print("Boss yang dipilih:")
        for boss, state in pairs(table) do
            print("-", boss)
        end
    end
})

MainTab:AddDropdown({
    Name = "Teleport To",
    Options = {"Spawn", "Desert", "Jungle", "Marine Ford"},
    Default = "Spawn",
    Multi = false,
    Flag = "Teleport_Target",
    Callback = function(v)
        print("Teleporting to:", v)
    end
})

-- 4. Settings Tab
SettingTab:AddSection("Information")

SettingTab:AddParagraph({
    Title = "Script Info",
    Content = "Ini adalah library UI standalone buatan elbilll.\nSemua konfigurasi tersimpan otomatis di folder 'elbilll_TestConfig'."
})

SettingTab:AddInput({
    Name = "Custom Message",
    Placeholder = "Ketik sesuatu...",
    Callback = function(text, enter)
        if enter then
            Window:Notify({
                Title = "Input Diterima",
                Content = "Pesan: " .. text,
                Delay = 3
            })
        end
    end
})

SettingTab:AddButton({
    Name = "Destroy UI",
    Callback = function()
        -- Secara default tombol X sudah ada, tapi ini contoh button
        print("UI dihentikan")
    end
})

-- Notification Testing
Window:Notify({
    Title = "elbilll Hub Loaded",
    Content = "Selamat mencoba UI baru Anda!",
    Delay = 5,
    Icon = "shield"
})
