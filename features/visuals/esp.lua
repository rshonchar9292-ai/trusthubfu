--// features/visuals/esp.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local ESP = {}

--// Налаштування
local settings = {
    enabled = false,
    teamCheck = true,
    showNames = true,
    maxDistance = 1000,
}

--// Таблиці для зберігання створених елементів
local activeESP = {} -- Highlights
local activeBillboards = {} -- TextLabels над головою

--// Функція очищення
local function clearESP()
    for _, hl in pairs(activeESP) do
        if hl then hl:Destroy() end
    end
    table.clear(activeESP)
    
    for _, bb in pairs(activeBillboards) do
        if bb then bb:Destroy() end
    end
    table.clear(activeBillboards)
end

--// Створення/оновлення ESP для конкретного гравця
local function updatePlayerESP(player)
    if player == LocalPlayer then return end
    
    local char = player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    
    -- Якщо гравець мертвий, не має RootPart, або це союзник (якщо увімкнено teamCheck) - прибираємо ESP
    if not hum or hum.Health <= 0 or not root then
        if activeESP[player] then activeESP[player]:Destroy(); activeESP[player] = nil end
        if activeBillboards[player] then activeBillboards[player]:Destroy(); activeBillboards[player] = nil end
        return
    end

    if settings.teamCheck and player.Team == LocalPlayer.Team then
        if activeESP[player] then activeESP[player]:Destroy(); activeESP[player] = nil end
        if activeBillboards[player] then activeBillboards[player]:Destroy(); activeBillboards[player] = nil end
        return
    end

    -- 1. Створення Highlight (контур)
    if not activeESP[player] or not activeESP[player].Parent then
        local hl = Instance.new("Highlight")
        hl.Name = "FustESP_" .. player.Name
        hl.Adornee = char
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        activeESP[player] = hl
    end

    -- 2. Створення Billboard (Ім'я та відстань)
    if settings.showNames and head then
        if not activeBillboards[player] or not activeBillboards[player].Parent then
            local bb = Instance.new("BillboardGui")
            bb.Name = "FustNameTag"
            bb.Adornee = head
            bb.Size = UDim2.new(0, 200, 0, 50)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.MaxDistance = settings.maxDistance
            bb.Parent = char
            
            local text = Instance.new("TextLabel")
            text.Name = "InfoText"
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.Font = Enum.Font.GothamBold
            text.TextSize = 14
            text.TextColor3 = Color3.fromRGB(255, 255, 255)
            text.TextStrokeTransparency = 0.5
            text.Text = player.Name
            text.Parent = bb
            
            activeBillboards[player] = bb
        end
        
        -- Оновлення відстані
        local rootPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPos then
            local dist = math.floor((root.Position - rootPos.Position).Magnitude)
            local textLabel = activeBillboards[player]:FindFirstChild("InfoText")
            if textLabel then
                textLabel.Text = string.format("%s [%dm]", player.Name, dist)
            end
        end
    else
        if activeBillboards[player] then activeBillboards[player]:Destroy(); activeBillboards[player] = nil end
    end
end

--// Головний цикл
RunService.Heartbeat:Connect(function()
    if not settings.enabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        updatePlayerESP(player)
    end
end)

--// Очищення при виході гравця
Players.PlayerRemoving:Connect(function(player)
    if activeESP[player] then activeESP[player]:Destroy(); activeESP[player] = nil end
    if activeBillboards[player] then activeBillboards[player]:Destroy(); activeBillboards[player] = nil end
end)

--// Експорт функцій для UI
function ESP:setEnabled(state)
    settings.enabled = state
    if not state then clearESP() end
end

function ESP:setTeamCheck(state)
    settings.teamCheck = state
    clearESP() -- Перестворюємо при зміні налаштування
end

function ESP:setShowNames(state)
    settings.showNames = state
    clearESP()
end

print("[ProjectX] Visuals > ESP module loaded.")
return ESP
