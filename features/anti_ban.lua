--// features/anti_ban.lua
local AntiBan = {}

--// Перевірка підтримки функцій експлойтером
local hasHook = hookmetamethod and newcclosure and checkcaller and getnamecallmethod

function AntiBan:enable()
    if not hasHook then
        warn("[AntiBan] Твій експлойтер не підтримує необхідні функції для повного захисту.")
        return
    end

    --// 1. Блокування Kick та захист WalkSpeed/JumpPower
    local oldNamecall, oldIndex
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- Блокуємо спробу викликати Kick для нашого гравця
        if not checkcaller() and (method == "Kick" or tostring(self) == "Kick") then
            if self == game.Players.LocalPlayer then
                warn("[AntiBan] Спроба Kick заблокована!")
                return nil
            end
        end
        return oldNamecall(self, ...)
    end))

    oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
        -- Підміна значень для приховання змінених характеристик
        if not checkcaller() and self == game.Players.LocalPlayer.Character then
            if key == "WalkSpeed" and self:FindFirstChild("Humanoid") then
                return 16 -- Показуємо грі стандартну швидкість
            elseif key == "JumpPower" and self:FindFirstChild("Humanoid") then
                return 50 -- Показуємо стандартну силу стрибка
            end
        end
        return oldIndex(self, key)
    end))

    --// 2. Знищення підозрілих RemoteEvent (якщо античит використовує їх для зв'язку)
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "Instance" and obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("kick") or name:find("ban") or name:find("report") or name:find("log") or name:find("cheat") then
                warn("[AntiBan] Знищено підозрілий RemoteEvent: " .. obj:GetFullName())
                obj:Destroy()
            end
        end
    end

    --// 3. Вимкнення LocalScripts, що можуть бути частиною античиту
    for _, s in pairs(game:GetDescendants()) do
        if s:IsA("LocalScript") and (s.Name:lower():find("anti") or s.Name:lower():find("cheat")) then
            s.Disabled = true
            warn("[AntiBan] Вимкнено підозрілий скрипт: " .. s:GetFullName())
        end
    end

    --// 4. Приховування інтерфейсу від сканування (захист GUI)
    if syn and syn.protect_gui then
        for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
            pcall(function() syn.protect_gui(gui) end)
        end
    elseif gethui then
        -- Використовуємо захищений контейнер, якщо доступний
        pcall(function()
            local protected = gethui()
            if protected then
                for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                    gui.Parent = protected
                end
            end
        end)
    end

    print("[AntiBan] Комплексний захист активовано (Kick, Speed, Remotes, Scripts, GUI).")
end

function AntiBan:disable()
    warn("[AntiBan] Для повного вимкнення захисту перезапустіть скрипт.")
end

return AntiBan
