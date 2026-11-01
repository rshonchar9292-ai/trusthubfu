--// ╔══════════════════════════════════════════════════════════════╗
--// ║  ProjectX / Fust Survival - Loader v2.0                      ║
--// ╚══════════════════════════════════════════════════════════════╝

--// УВАГА: Перевір, щоб це посилання вело на твій репозиторій!
--// Якщо ти створив новий репо (наприклад, trusthubfu), зміни його тут:
local BASE_URL = "https://raw.githubusercontent.com/rshonchar9292-ai/projectx/main/"

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
        logErr("HTTP помилка: " .. urlPath)
        return nil 
    end
    
    if not code or #code < 10 then 
        logErr("Файл порожній або не знайдено: " .. urlPath)
        return nil 
    end
    
    if code:find("404: Not Found") then 
        logErr("404 Not Found: " .. urlPath)
        return nil 
    end

    -- Компіляція
    local fn, err = loadstring(code)
    if not fn then 
        logErr("Помилка компіляції: " .. urlPath .. "\n" .. tostring(err))
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
log("=== СТАРТ ===")

local UI = loadModule("ui")
if not UI then 
    logErr("❌ Критична помилка: UI не завантажено!")
    return 
end
log("✅ UI успішно завантажено")

--// ============================================================
--// 2. ЗАВАНТАЖЕННЯ МОДУЛІВ (Features)
--// ============================================================
local Features = {
    -- Базові функції
    Movement  = loadModule("features.movement"),
    Fling     = loadModule("features.fling"),
    Animation = loadModule("features.animation"),
    
    -- Функції з попередніх етапів
    Shahed    = loadModule("features.shahed"),
    Rocket    = loadModule("features.rocket"),
    Emotes    = loadModule("features.emotes"),
    
    -- Нові функції для Fust Survival
    Combat    = loadModule("features.combat"),   -- Aimbot
    Visuals   = loadModule("features.visuals"),  -- ESP, Tracers
}

--// ============================================================
--// 3. ПЕРЕВІРКА СТАТУСУ МОДУЛІВ
--// ============================================================
log("─────────────────────────────")
log("Movement: "  .. type(Features.Movement))
log("Combat: "    .. type(Features.Combat))
log("Visuals: "   .. type(Features.Visuals))
log("Emotes: "    .. type(Features.Emotes))
log("Shahed: "    .. type(Features.Shahed))
log("Rocket: "    .. type(Features.Rocket))
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
