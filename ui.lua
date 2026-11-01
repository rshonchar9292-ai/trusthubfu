--// TrustFU UI (Maximum Stealth)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = {}

local Theme = {
    Bg = Color3.fromRGB(12, 12, 15), Panel = Color3.fromRGB(20, 20, 26), Element = Color3.fromRGB(30, 30, 38),
    Hover = Color3.fromRGB(45, 45, 55), Accent = Color3.fromRGB(130, 150, 255), Text = Color3.fromRGB(240, 240, 245),
    Dim = Color3.fromRGB(150, 150, 160), Line = Color3.fromRGB(50, 50, 65),
}
local Anim = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parent
    return obj
end
local function corner(parent, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, parent) end
local function stroke(parent, c, t) return new("UIStroke", {Color = c or Theme.Line, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, parent) end

-- Функції створення елементів (Toggle, Slider, Dropdown, Card)
local function createToggle(parent, text, default, callback)
    local Btn = new("TextButton", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Element, Text = "", AutoButtonColor = false}, parent)
    corner(Btn, 8)
    new("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, Btn)
    local Track = new("Frame", {Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -46, 0.5, -10), BackgroundColor3 = default and Theme.Accent or Theme.Line}, Btn)
    corner(Track, 10)
    local Dot = new("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)}, Track)
    corner(Dot, 10)
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Track, Anim.Fast, {BackgroundColor3 = state and Theme.Accent or Theme.Line}):Play()
        TweenService:Create(Dot, Anim.Bounce, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
    return Btn
end

local function createSlider(parent, text, min, max, default, callback)
    local Frame = new("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Theme.Element}, parent)
    corner(Frame, 8)
    new("TextLabel", {Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 12, 0, 5), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, Frame)
    local Val = new("TextLabel", {Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, 5), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right}, Frame)
    local Bar = new("Frame", {Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 32), BackgroundColor3 = Theme.Line}, Frame)
    corner(Bar, 3)
    local Fill = new("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent}, Bar)
    corner(Fill, 3)
    local dragging = false
    Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local alpha = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * alpha)
            Fill.Size = UDim2.new(alpha, 0, 1, 0)
            Val.Text = tostring(val)
            callback(val)
        end
    end)
    return Frame
end

local function createDropdown(parent, text, options, default, callback)
    local Frame = new("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Element}, parent)
    corner(Frame, 8)
    local Btn = new("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""}, Frame)
    local TxtLbl = new("TextLabel", {Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text .. ": " .. default, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, Frame)
    local open = false
    local dropFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 1, 4), BackgroundColor3 = Theme.Panel, ClipsDescendants = true, Visible = false, ZIndex = 50}, Frame)
    corner(dropFrame, 8)
    stroke(dropFrame)
    new("UIListLayout", {Padding = UDim.new(0, 2)}, dropFrame)
    for _, opt in ipairs(options) do
        local optBtn = new("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Element, Text = opt, TextColor3 = Theme.Text, Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 51}, dropFrame)
        optBtn.MouseButton1Click:Connect(function()
            TxtLbl.Text = text .. ": " .. opt
            callback(opt)
            dropFrame.Visible = false
            dropFrame.Size = UDim2.new(1, 0, 0, 0)
            open = false
        end)
    end
    Btn.MouseButton1Click:Connect(function()
        open = not open
        dropFrame.Visible = open
        TweenService:Create(dropFrame, Anim.Fast, {Size = open and UDim2.new(1, 0, 0, #options * 32) or UDim2.new(1, 0, 0, 0)}):Play()
    end)
    return Frame
end

local function makeCard(parent, title, desc, settingsFunc)
    local Card = new("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Theme.Panel, ClipsDescendants = true}, parent)
    corner(Card, 10)
    stroke(Card, Theme.Line)
    local Header = new("TextButton", {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1, Text = ""}, Card)
    new("TextLabel", {Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 10), BackgroundTransparency = 1, Text = title, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left}, Card)
    new("TextLabel", {Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 12, 0, 30), BackgroundTransparency = 1, Text = desc, TextColor3 = Theme.Dim, Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left}, Card)
    local Content = new("Frame", {Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 65), BackgroundTransparency = 1}, Card)
    new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, Content)
    local isOpen = false
    Header.MouseButton2Click:Connect(function()
        isOpen = not isOpen
        local contentHeight = #Content:GetChildren() * 56
        local targetSize = isOpen and UDim2.new(1, 0, 0, 65 + contentHeight + 10) or UDim2.new(1, 0, 0, 60)
        TweenService:Create(Card, Anim.Bounce, {Size = targetSize}):Play()
    end)
    if settingsFunc then settingsFunc(Content) end
    return Card
end

-- ІНІЦІАЛІЗАЦІЯ
function UI:init(Features)
    print("[TrustFU] Ініціалізація Stealth UI...")
    
    local randomName = "Config_" .. math.random(10000, 99999)
    local parentGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Спроба використати найкращий захист
    if syn and syn.protect_gui then
        print("[TrustFU] Використовую syn.protect_gui")
    elseif protectgui then
        print("[TrustFU] Використовую protectgui()")
    end

    local ScreenGui = new("ScreenGui", {Name = randomName, ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 2147483647, Parent = parentGui})
    
    -- Застосовуємо захист
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(ScreenGui) end)
    elseif protectgui then pcall(function() protectgui(ScreenGui) end) end
    
    local Float = new("TextButton", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 20, 0.5, -25), BackgroundColor3 = Theme.Accent, Text = "X", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 20, ZIndex = 2147483647}, ScreenGui)
    corner(Float, 25)
    stroke(Float, Color3.new(1,1,1), 2)
    print("[TrustFU] Кнопка 'X' створена!")

    local dragging, dragStart, startPos, moved = false, nil, nil, false
    Float.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved = true, false
            dragStart, startPos = input.Position, Float.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then moved = true end
            Float.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Main = new("Frame", {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Theme.Bg, Visible = false, ZIndex = 2147483647}, ScreenGui)
    corner(Main, 14)
    stroke(Main, Theme.Line, 2)
    
    local Header = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Theme.Panel, ZIndex = 2147483647}, Main)
    corner(Header, 14)
    new("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "TrustFU | Fust Survival", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 2147483647}, Header)
    
    local Content = new("Frame", {Size = UDim2.new(1, -20, 1, -60), Position = UDim2.new(0, 10, 0, 50), BackgroundTransparency = 1, ZIndex = 2147483647}, Main)
    local TabBar = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, ZIndex = 2147483647}, Content)
    new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 5)}, TabBar)
    
    local Pages = {}
    local function createTab(name)
        local Btn = new("TextButton", {Size = UDim2.new(0.48, 0, 1, 0), BackgroundColor3 = Theme.Element, Text = name, TextColor3 = Theme.Text, Font = Enum.Font.GothamMedium, TextSize = 12, ZIndex = 2147483647}, TabBar)
        corner(Btn, 6)
        local Page = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundTransparency = 1, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 2147483647}, Content)
        new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, Page)
        Pages[name] = Page
        Btn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            Page.Visible = true
            for _, c in ipairs(TabBar:GetChildren()) do if c:IsA("TextButton") then c.BackgroundColor3 = Theme.Element end end
            Btn.BackgroundColor3 = Theme.Accent
        end)
        return Page
    end

    local CombatTab = createTab("Бій")
    local VisualsTab = createTab("Візуал")

    makeCard(CombatTab, "Аімбот", "ПКМ — налаштування", function(cont)
        createToggle(cont, "Увімкнути Аімбот", false, function(v) if Features.Combat and Features.Combat.Aimbot then Features.Combat.Aimbot:setEnabled(v) end end)
        createSlider(cont, "Плавність", 1, 20, 5, function(v) if Features.Combat and Features.Combat.Aimbot then Features.Combat.Aimbot:setSmoothness(v) end end)
        createSlider(cont, "Радіус FOV", 50, 500, 150, function(v) if Features.Combat and Features.Combat.Aimbot then Features.Combat.Aimbot:setFOV(v) end end)
        createDropdown(cont, "Частина тіла", {"Голова", "Торс", "Центр"}, "Голова", function(v)
            local partMap = {["Голова"] = "Head", ["Торс"] = "Torso", ["Центр"] = "HumanoidRootPart"}
            if Features.Combat and Features.Combat.Aimbot then Features.Combat.Aimbot:setAimPart(partMap[v] or "Head") end
        end)
        createToggle(cont, "Перевірка команди", true, function(v) if Features.Combat and Features.Combat.Aimbot then Features.Combat.Aimbot:setTeamCheck(v) end end)
        createToggle(cont, "Перевірка стін", true, function(v) if Features.Combat and Features.Combat.Aimbot then Features.Combat.Aimbot:setWallCheck(v) end end)
    end)

    makeCard(VisualsTab, "ESP Гравців", "Підсвічує ворогів", function(cont)
        createToggle(cont, "Увімкнути ESP", false, function(v) if Features.Visuals and Features.Visuals.ESP then Features.Visuals.ESP:setEnabled(v) end end)
        createToggle(cont, "Імена та відстань", true, function(v) if Features.Visuals and Features.Visuals.ESP then Features.Visuals.ESP:setShowNames(v) end end)
        createToggle(cont, "Ігнорувати союзників", true, function(v) if Features.Visuals and Features.Visuals.ESP then Features.Visuals.ESP:setTeamCheck(v) end end)
    end)

    makeCard(VisualsTab, "ESP Предметів", "Підсвічує ресурси та лут", function(cont)
        createToggle(cont, "Увімкнути ESP Предметів", false, function(v) if Features.Visuals and Features.Visuals.ItemsESP then Features.Visuals.ItemsESP:setEnabled(v) end end)
        createToggle(cont, "Показувати назви", true, function(v) if Features.Visuals and Features.Visuals.ItemsESP then Features.Visuals.ItemsESP:setShowNames(v) end end)
        createSlider(cont, "Макс. відстань", 100, 2000, 500, function(v) if Features.Visuals and Features.Visuals.ItemsESP then Features.Visuals.ItemsESP:setMaxDistance(v) end end)
    end)

    local isOpen = false
    local function toggleUI()
        isOpen = not isOpen
        if isOpen then
            Main.Visible = true
            TweenService:Create(Main, Anim.Bounce, {Size = UDim2.new(0, 480, 0, 420)}):Play()
        else
            local t = TweenService:Create(Main, Anim.Fast, {Size = UDim2.new(0, 0, 0, 0)})
            t:Play()
            t.Completed:Connect(function() Main.Visible = false end)
        end
    end

    Float.MouseButton1Click:Connect(function() if not moved then toggleUI() end end)
    UserInputService.InputBegan:Connect(function(input, gpe) if input.KeyCode == Enum.KeyCode.F4 then toggleUI() end end)
    
    Pages["Бій"].Visible = true
    for _, c in ipairs(TabBar:GetChildren()) do if c:IsA("TextButton") and c.Text == "Бій" then c.BackgroundColor3 = Theme.Accent end end
    
    print("[TrustFU] UI успішно ініціалізовано з максимальним захистом!")
end

return UI
