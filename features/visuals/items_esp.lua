--// features/visuals/items_esp.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ItemsESP = {}

--// Налаштування
local settings = {
    enabled = false,
    showNames = true,
    maxDistance = 500,
    highlightColor = Color3.fromRGB(255, 255, 0) -- Жовтий колір за замовчуванням
}

--// Ключові слова для пошуку предметів (можна додати свої)
-- Наприклад, якщо в грі дерево називається "Log", додай "log"
local itemKeywords = {
    "tree", "wood", "log", "rock", "stone", "ore", "metal", 
    "crate", "loot", "box", "item", "pickup", "weapon", "gun", "food"
}

local activeItems = {} -- Таблиця для зберігання Highlights
local activeBillboards = {} -- Таблиця для імен

--// Функція перевірки, чи є об'єкт предметом
local function isItem(obj)
    if obj:IsA("BasePart") or obj:IsA("Model") then
        local name = obj.Name:lower()
        for _, keyword in ipairs(itemKeywords) do
            if name:find(keyword) then
                return true
            end
        end
    end
    return false
end

--// Очищення ESP
local function clearESP()
    for _, hl in pairs(activeItems) do
        if hl and hl.Parent then hl:Destroy() end
    end
    table.clear(activeItems)
    
    for _, bb in pairs(activeBillboards) do
        if bb and bb.Parent then bb:Destroy() end
    end
    table.clear(activeBillboards)
end

--// Додавання ESP до предмета
local function addESP(obj)
    if activeItems[obj] then return end

    -- Визначаємо, до чого прикріпити (до самої деталі або до PrimaryPart моделі)
    local adornee = obj
    if obj:IsA("Model") then
        adornee = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
        if not adornee then return end
    end

    -- 1. Підсвічування (Highlight)
    local hl = Instance.new("Highlight")
    hl.Name = "ItemESP_Highlight"
    hl.Adornee = obj
    hl.FillColor = settings.highlightColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = obj
    activeItems[obj] = hl

    -- 2. Ім'я над предметом (Billboard)
    if settings.showNames then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ItemESP_Name"
        bb.Adornee = adornee
        bb.Size = UDim2.new(0, 150, 0, 30)
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = settings.maxDistance
        bb.Parent = obj

        local text = Instance.new("TextLabel")
        text.Name = "InfoText"
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Font = Enum.Font.GothamBold
        text.TextSize = 12
        text.TextColor3 = settings.highlightColor
        text.TextStrokeTransparency = 0.5
        text.Text = obj.Name
        text.Parent = bb

        activeBillboards[obj] = bb
    end
end

--// Видалення ESP з предмета (якщо він зник)
local function removeESP(obj)
    if activeItems[obj] then
        activeItems[obj]:Destroy()
        activeItems[obj] = nil
    end
    if activeBillboards[obj] then
        activeBillboards[obj]:Destroy()
        activeBillboards[obj] = nil
    end
end

--// Сканування світу на наявність предметів
local function scanWorld()
    if not settings.enabled then return end
    
    -- Перебираємо всі об'єкти в Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isItem(obj) then
            -- Перевіряємо, чи це не гравець
            local isPlayer = false
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character and obj:IsDescendantOf(plr.Character) then
                    isPlayer = true
                    break
                end
            end
            
            if not isPlayer then
                addESP(obj)
            end
        end
    end
end

--// Слухаємо нові об'єкти (наприклад, коли хтось викидає лут)
Workspace.DescendantAdded:Connect(function(obj)
    if not settings.enabled then return end
    task.wait(0.1) -- Невелика затримка, щоб об'єкт повністю завантажився
    if obj.Parent and isItem(obj) then
        addESP(obj)
    end
end)

--// Оновлення відстані в реальному часі
RunService.Heartbeat:Connect(function()
    if not settings.enabled or not settings.showNames then return end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for obj, bb in pairs(activeBillboards) do
        if not obj.Parent then
            removeESP(obj)
            continue
        end
        
        local adornee = bb.Adornee
        if adornee then
            local dist = math.floor((adornee.Position - myRoot.Position).Magnitude)
            local text = bb:FindFirstChild("InfoText")
            if text then
                text.Text = string.format("%s [%dm]", obj.Name, dist)
            end
        end
    end
end)

--// Експорт функцій для UI
function ItemsESP:setEnabled(state)
    settings.enabled = state
    if state then
        scanWorld()
    else
        clearESP()
    end
end

function ItemsESP:setShowNames(state)
    settings.showNames = state
    -- Перестворюємо ESP, щоб застосувати зміни
    if settings.enabled then
        clearESP()
        scanWorld()
    end
end

function ItemsESP:setMaxDistance(dist)
    settings.maxDistance = dist
end

function ItemsESP:setColor(color)
    settings.highlightColor = color
    if settings.enabled then
        clearESP()
        scanWorld()
    end
end

print("[ProjectX] Visuals > Items ESP module loaded.")
return ItemsESP
