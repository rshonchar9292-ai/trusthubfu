--// ╔══════════════════════════════════════════════════════════════╗
--// ║  Fust Survival / ProjectX - Loader v3.0                      ║
--// ╚══════════════════════════════════════════════════════════════╝

--// Перевір, що це посилання веде на твій новий репозиторій!
local BASE_URL = "https://raw.githubusercontent.com/rshonchar9292-ai/trusthubfu/main/"

local function log(msg) print("[ProjectX] " .. tostring(msg)) end
local function logErr(msg) warn("[ProjectX ERROR] " .. tostring(msg)) end

--// ============================================================
--// ФУНКЦІЯ ЗАВАНТАЖЕННЯ МОДУЛІВ (з обходом кешу)
--// ============================================================
local function loadModule(path)
    local urlPath = path:gsub("%.", "/")
    -- Додаємо ?t=, щоб GitHub завжди віддавав свіжу версію файлу
    local url = BASE_URL .. urlPath .. ".lua?t=" .. tostring(os.time())

    log("⏳ Завантажую: " .. urlPath)

    local ok, code = pcall(function() return game:HttpGet(url) end)
    if not ok then 
        logErr("HTTP помилка (перевір інтернет або посилання): " .. urlPath)
        return nil 
    end
    
    if not code or #code < 10 then 
        logErr("Файл порожній або не знайдено: " .. urlPath)
        return nil 
    end
    
    if code:find("404: Not Found") then 
        logErr("404 Not Found: " .. urlPath .. " (Ти не залив цей файл на GitHub!)")
        return nil 
    end

    -- Компіляція
    local fn, err = loadstring(code)
    if not fn then 
        logErr("Помилка компіляції (синтаксис): " .. urlPath .. "\n" .. tostring(err))
        return nil 
    end

    -- Виконання з відловом помилок
    local ok2, result = xpcall(fn, function(err2) 
        return err2 .. "\n" .. debug.traceback() 
    end)
    
    if not ok2 then 
        logErr("Помилка виконання: " .. urlPath .. "\n" .. tostring(result))
        return nil 
    end

    log("✅ OK: " .. urlPath .. " → " .. type(result))
    return result
end

--// ============================================================
--// 1. ЗАВАНТАЖЕННЯ UI
--// ============================================================
log("=== СТАРТ ЗАВАНТАЖЕННЯ ===")

local UI = loadModule("ui")
if not UI then 
    logErr("❌ Критична помилка: UI не завантажено! Меню не запуститься.")
    return 
end
log("✅ UI успішно завантажено")

--// ============================================================
--// 2. ЗАВАНТАЖЕННЯ МОДУЛІВ (Features)
--// ============================================================
local Features = {
    -- Бойові модулі (в папці combat)
    Combat = {
        Aimbot = loadModule("features.combat.aimbot"),
    },
    
    -- Візуальні модулі (в папці visuals)
    Visuals = {
        ESP = loadModule("features.visuals.esp"),
        ItemsESP = loadModule("features.visuals.items_esp"),
    },

    -- Старі модулі (якщо вони ще лежать у тебе в корені папки features)
    Movement  = loadModule("features.movement"),
    Fling     = loadModule("features.fling"),
    Animation = loadModule("features.animation"),
    Shahed    = loadModule("features.shahed"),
    Rocket    = loadModule("features.rocket"),
    Emotes    = loadModule("features.emotes"),
}

--// ============================================================
--// 3. ПЕРЕВІРКА СТАТУСУ МОДУЛІВ (Виведе в F9)
--// ============================================================
log("─────────────────────────────")
log("Combat > Aimbot:  " .. type(Features.Combat.Aimbot))
log("Visuals > ESP:    " .. type(Features.Visuals.ESP))
log("Visuals > Items:  " .. type(Features.Visuals.ItemsESP))
log("Movement:         " .. type(Features.Movement))
log("Emotes:           " .. type(Features.Emotes))
log("─────────────────────────────")

_G.ProjectXFeatures = Features

--// ============================================================
--// 4. ІНІЦІАЛІЗАЦІЯ UI
--// ============================================================
log("Ініціалізація меню...")

local ok, err = xpcall(function()
    UI:init(Features)
end, function(err2) 
    return err2 .. "\n" .. debug.traceback() 
end)

if not ok then
    logErr("Помилка ініціалізації UI:\n" .. tostring(err))
    return
end

log("✅ Меню успішно запущено!")
log("=== ГОТОВО ===")
