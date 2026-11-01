--// features/combat/aimbot.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Aimbot = {}

--// Налаштування за замовчуванням
local settings = {
    enabled = false,
    smoothness = 5,
    targetPart = "Head",
    teamCheck = true,
    wallCheck = true,
    fovRadius = 150
}

--// Змінні для роботи
local fovGui = nil
local fovCircle = nil
local target = nil

--// Створення кола FOV
local function createFOV()
    if fovGui then fovGui:Destroy() end
    
    fovGui = Instance.new("ScreenGui")
    fovGui.Name = "AimbotFOV"
    fovGui.ResetOnSpawn = false
    fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, settings.fovRadius * 2, 0, settings.fovRadius * 2)
    fovCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 0
    fovCircle.Parent = fovGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fovCircle
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(130, 150, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = fovCircle
end

--// Оновлення UI при зміні налаштувань
function Aimbot:updateFOV()
    if fovCircle then
        fovCircle.Size = UDim2.new(0, settings.fovRadius * 2, 0, settings.fovRadius * 2)
    end
end

--// Пошук найближчої цілі до прицілу
local function getTarget()
    local closest = nil
    local shortestDist = settings.fovRadius
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            -- Перевірка: чи живий, чи не союзник
            if hum and hum.Health > 0 then
                if settings.teamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                local part = char:FindFirstChild(settings.targetPart)
                if part then
                    -- Перевірка на видимість (Raycast)
                    if settings.wallCheck then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        
                        local origin = Camera.CFrame.Position
                        local direction = (part.Position - origin)
                        local result = Workspace:Raycast(origin, direction, rayParams)
                        
                        if result then continue end -- Є стіна на шляху
                    end
                    
                    -- Перевірка відстані до центру екрану
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = part
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

--// Основний цикл аімбота
RunService.RenderStepped:Connect(function()
    if not settings.enabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Шукаємо ціль
    target = getTarget()
    
    if target then
        -- Плавне наведення (Smoothness)
        local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / settings.smoothness)
    end
end)

--// Експорт функцій для UI
function Aimbot:setEnabled(state)
    settings.enabled = state
    if state then
        createFOV()
    else
        if fovGui then fovGui:Destroy() fovGui = nil end
    end
end

function Aimbot:setSmoothness(val)
    settings.smoothness = val
end

function Aimbot:setAimPart(partName)
    settings.targetPart = partName
end

function Aimbot:setTeamCheck(state)
    settings.teamCheck = state
end

function Aimbot:setWallCheck(state)
    settings.wallCheck = state
end

function Aimbot:setFOV(radius)
    settings.fovRadius = radius
    self:updateFOV()
end

print("[ProjectX] Combat > Aimbot module loaded.")
return Aimbot
