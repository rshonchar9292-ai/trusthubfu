--// features/anti_ban.lua
local AntiBan = {}

--// Перевірка, чи підтримує експлойтер потрібні функції
local function hasExecutorSupport()
    return hookmetamethod and newcclosure and checkcaller and getnamecallmethod
end

function AntiBan:enable()
    if not hasExecutorSupport() then
        warn("[AntiBan] Ваш експлойтер не підтримує необхідні функції (hookmetamethod тощо). Захист вимкнено.")
        return
    end

    -- 1. Блокування Kick
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- Якщо античит намагається викликати Kick для локального гравця
        if not checkcaller() and method == "Kick" and self == game.Players.LocalPlayer then
            print("[AntiBan] Спроба Kick заблокована!")
            return nil -- Блокуємо виклик
        end
        
        return oldNamecall(self, ...)
    end))

    -- 2. Захист від підміни WalkSpeed (приклад)
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        -- Якщо античит читає WalkSpeed у нашого персонажа, показуємо стандартне значення
        if not checkcaller() and key == "WalkSpeed" and self == game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            return 16 -- Показуємо грі, що швидкість нормальна
        end
        return oldIndex(self, key)
    end))

    print("[AntiBan] Захист активовано (Kick + WalkSpeed).")
end

function AntiBan:disable()
    -- Складність у тому, що для вимкнення потрібно зберегти старі функції.
    -- У цій простій версії ми просто попереджаємо.
    warn("[AntiBan] Повне вимкнення потребує перезапуску скрипта.")
end

return AntiBan
