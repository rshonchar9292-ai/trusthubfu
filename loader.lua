--// TrustFU Loader
local BASE_URL = "https://raw.githubusercontent.com/rshonchar9292-ai/trusthubfu/main/"

local function log(msg) print("[TrustFU] " .. tostring(msg)) end
local function logErr(msg) warn("[TrustFU ERROR] " .. tostring(msg)) end

local function loadModule(path)
    local urlPath = path:gsub("%.", "/")
    local url = BASE_URL .. urlPath .. ".lua?t=" .. tostring(os.time())
    log("⏳ Завантажую: " .. urlPath)

    local ok, code = pcall(function() return game:HttpGet(url) end)
    if not ok then logErr("HTTP помилка: " .. urlPath) return nil end
    if not code or #code < 10 then logErr("Файл порожній: " .. urlPath) return nil end
    if code:find("404: Not Found") then logErr("404 Not Found: " .. urlPath) return nil end

    local fn, err = loadstring(code)
    if not fn then logErr("Помилка компіляції: " .. urlPath .. "\n" .. tostring(err)) return nil end

    local ok2, result = xpcall(fn, function(err2) return err2 .. "\n" .. debug.traceback() end)
    if not ok2 then logErr("Помилка виконання: " .. urlPath .. "\n" .. tostring(result)) return nil end

    log("✅ OK: " .. urlPath .. " → " .. type(result))
    return result
end

local UI = loadModule("ui")
if not UI then logErr("❌ UI НЕ ЗАВАНТАЖЕНО") return end

local Features = {
    Combat = { Aimbot = loadModule("features.combat.aimbot") },
    Visuals = { ESP = loadModule("features.visuals.esp"), ItemsESP = loadModule("features.visuals.items_esp") },
    AntiBan = loadModule("features.anti_ban"),
}

_G.TrustFUFeatures = Features

local ok, err = xpcall(function() UI:init(Features) end, function(err2) return err2 end)
if not ok then logErr("UI INIT FAIL:\n" .. tostring(err)) return end
