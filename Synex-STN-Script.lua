--[[
    STN GUI - Mobile Edition (Full Functional)
]]

-- Cleanup old GUIs
for i, v in pairs(game:GetDescendants()) do
    if v.Name == "STN_MobileGui" then
        v:Destroy()
    end
end

-- ============================================================
--  SERVICES
-- ============================================================
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
--  STATE
-- ============================================================
local savedLighting = nil
local originalDistances = {}

-- ============================================================
--  GUI ROOT
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "STN_MobileGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

-- ============================================================
--  ПЛАВАЮЩАЯ КНОПКА (35x35)
-- ============================================================
local FAB = Instance.new("TextButton")
FAB.Size = UDim2.new(0, 35, 0, 35)
FAB.Position = UDim2.new(0, 15, 0.5, -17)
FAB.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FAB.BackgroundTransparency = 0.5
FAB.Text = "STN"
FAB.TextColor3 = Color3.fromRGB(255, 255, 255)
FAB.TextSize = 11
FAB.Font = Enum.Font.GothamBold
FAB.ZIndex = 20
FAB.Parent = ScreenGui

local fabCorner = Instance.new("UICorner", FAB)
fabCorner.CornerRadius = UDim.new(1, 0)

-- Перетаскивание кнопки
local dragging = false
local dragStart = nil
local startPos = nil

FAB.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = FAB.Position
    end
end)

FAB.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        FAB.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================================
--  МЕНЮ
-- ============================================================
local menuOpen = false

local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 200, 0, 285)
Menu.Position = UDim2.new(0.5, -100, 0.5, -142)
Menu.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Menu.BackgroundTransparency = 0
Menu.Visible = false
Menu.ZIndex = 10
Menu.Parent = ScreenGui
Menu.ClipsDescendants = true

local menuCorner = Instance.new("UICorner", Menu)
menuCorner.CornerRadius = UDim.new(0, 12)

-- Заголовок
local MenuHeader = Instance.new("Frame")
MenuHeader.Size = UDim2.new(1, 0, 0, 40)
MenuHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
MenuHeader.BackgroundTransparency = 0
MenuHeader.ZIndex = 15
MenuHeader.Parent = Menu
local headerCorner = Instance.new("UICorner", MenuHeader)
headerCorner.CornerRadius = UDim.new(0, 12)

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, 0, 1, 0)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "STN SCRIPT"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.TextSize = 14
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextXAlignment = Enum.TextXAlignment.Center
MenuTitle.ZIndex = 16
MenuTitle.Parent = MenuHeader

-- ScrollingFrame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ZIndex = 10
ScrollFrame.Parent = Menu

local ScrollList = Instance.new("UIListLayout", ScrollFrame)
ScrollList.Padding = UDim.new(0, 4)
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder

local ScrollPad = Instance.new("UIPadding", ScrollFrame)
ScrollPad.PaddingLeft = UDim.new(0, 8)
ScrollPad.PaddingRight = UDim.new(0, 8)
ScrollPad.PaddingTop = UDim.new(0, 8)
ScrollPad.PaddingBottom = UDim.new(0, 8)

-- ============================================================
--  ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ============================================================
local function saveOriginalDistance(prompt)
    if not originalDistances[prompt] then
        originalDistances[prompt] = prompt.MaxActivationDistance
    end
end

local function restoreOriginalDistance(prompt)
    if originalDistances[prompt] then
        prompt.MaxActivationDistance = originalDistances[prompt]
    end
end

-- ============================================================
--  ФУНКЦИЯ СОЗДАНИЯ КНОПКИ (с полноценной логикой)
-- ============================================================
local function makeButton(text, isToggle, onToggle, onExecute)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.Text = text .. " - OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.BackgroundTransparency = 0
    btn.ZIndex = 12
    btn.Parent = ScrollFrame
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local state = false
    
    btn.MouseButton1Click:Connect(function()
        if isToggle then
            state = not state
            if state then
                btn.BackgroundColor3 = Color3.fromRGB(70, 130, 90)
                btn.Text = text .. " - ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
                btn.Text = text .. " - OFF"
            end
            if onToggle then onToggle(state) end
        else
            if onExecute then onExecute() end
        end
    end)
    
    return btn
end

local function addSection(title)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(100, 160, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ZIndex = 12
    lbl.Parent = ScrollFrame
end

-- ============================================================
--  ESP ФУНКЦИИ
-- ============================================================
local function createESP(object, color, name)
    if object:FindFirstChild(name) then object:FindFirstChild(name):Destroy() end
    local gui = Instance.new("BillboardGui", object)
    gui.Name = name
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 60, 0, 60)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    local border = Instance.new("Frame", gui)
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 1
    local stroke = Instance.new("UIStroke", border)
    stroke.Color = color
    stroke.Thickness = 2
    local lbl = Instance.new("TextLabel", gui)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Position = UDim2.new(0, 0, 1, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = object.Name
    lbl.TextColor3 = color
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Legacy
end

-- ESP переменные
local espRelic = false
local espTask = false
local espMurch = false
local espBlacklight = false
local espAila = false
local espBattery = false
local espPlayer = false
local playerEspLines = {}

-- ============================================================
--  КНОПКИ ESP
-- ============================================================
addSection("━━━ ESP ━━━")

makeButton("Relic ESP", true, function(state)
    espRelic = state
    for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
        if state then
            createESP(v, Color3.fromRGB(50, 150, 255), "STN_RelicESP")
        else
            if v:FindFirstChild("STN_RelicESP") then v.STN_RelicESP:Destroy() end
        end
    end
end)

makeButton("Task ESP", true, function(state)
    espTask = state
    for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
        if v.ClassName == "Model" then
            if state then
                createESP(v, Color3.fromRGB(255, 60, 60), "STN_TaskESP")
            else
                if v:FindFirstChild("STN_TaskESP") then v.STN_TaskESP:Destroy() end
            end
        end
    end
end)

makeButton("Murch Case ESP", true, function(state)
    espMurch = state
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower() == "murch case" or v.Name:lower() == "murchcase" then
            if state then
                createESP(v, Color3.fromRGB(255, 60, 60), "STN_MurchESP")
            else
                if v:FindFirstChild("STN_MurchESP") then v.STN_MurchESP:Destroy() end
            end
        end
    end
end)

makeButton("Blacklight Case ESP", true, function(state)
    espBlacklight = state
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower() == "blacklight case" or v.Name:lower() == "blacklightcase" then
            if state then
                createESP(v, Color3.fromRGB(180, 60, 255), "STN_BlacklightESP")
            else
                if v:FindFirstChild("STN_BlacklightESP") then v.STN_BlacklightESP:Destroy() end
            end
        end
    end
end)

makeButton("Aila Case ESP", true, function(state)
    espAila = state
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower() == "aila case" or v.Name:lower() == "ailacase" then
            if state then
                createESP(v, Color3.fromRGB(0, 180, 255), "STN_AilaESP")
            else
                if v:FindFirstChild("STN_AilaESP") then v.STN_AilaESP:Destroy() end
            end
        end
    end
end)

makeButton("Battery ESP", true, function(state)
    espBattery = state
    for _, v in pairs(Workspace:GetDescendants()) do
        local name = v.Name:lower()
        if (name:find("battery") or name:find("blacklight") or name:find("batteries")) and (v:IsA("BasePart") or v:IsA("Model")) then
            if state then
                createESP(v, Color3.fromRGB(180, 60, 255), "STN_BatteryESP")
            else
                if v:FindFirstChild("STN_BatteryESP") then v.STN_BatteryESP:Destroy() end
            end
        end
    end
end)

-- Player ESP (упрощённый)
makeButton("Player ESP", true, function(state)
    espPlayer = state
    if not state then
        for _, line in pairs(playerEspLines) do
            pcall(function() line:Remove() end)
        end
        playerEspLines = {}
    end
end)

-- ============================================================
--  AURA ФУНКЦИИ
-- ============================================================
local relicAuraActive = false
local relicAuraRange = 50
local relicAuraThread = nil

addSection("━━━ AURA ━━━")

makeButton("Relic Aura", true, function(state)
    relicAuraActive = state
    if state then
        if relicAuraThread then coroutine.close(relicAuraThread) end
        relicAuraThread = coroutine.create(function()
            while relicAuraActive do
                task.wait(0.1)
                pcall(function()
                    for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                        if v.Name == "Relic" then
                            local prompt = v:FindFirstChild("RelicPrompt")
                            if prompt then
                                local orig = prompt.MaxActivationDistance
                                prompt.MaxActivationDistance = relicAuraRange
                                fireproximityprompt(prompt)
                                prompt.MaxActivationDistance = orig
                            end
                        end
                    end
                    for _, v in pairs(workspace:GetDescendants()) do
                        local name = v.Name:lower()
                        if (name:find("blacklight") and name:find("battery")) or name == "blacklightbattery" then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                local orig = prompt.MaxActivationDistance
                                prompt.MaxActivationDistance = relicAuraRange
                                fireproximityprompt(prompt)
                                prompt.MaxActivationDistance = orig
                            end
                        end
                    end
                end)
            end
        end)
        coroutine.resume(relicAuraThread)
    else
        if relicAuraThread then coroutine.close(relicAuraThread); relicAuraThread = nil end
    end
end)

local itemAuraActive = false
local itemAuraRange = 50
local itemAuraThread = nil

makeButton("Item Aura", true, function(state)
    itemAuraActive = state
    if state then
        if itemAuraThread then coroutine.close(itemAuraThread) end
        itemAuraThread = coroutine.create(function()
            while itemAuraActive do
                task.wait(0.1)
                pcall(function()
                    for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
                        if v.ClassName == "ProximityPrompt" then
                            fireproximityprompt(v)
                        end
                    end
                    for _, v in pairs(workspace:GetDescendants()) do
                        local name = v.Name:lower()
                        if name == "murch case" or name == "murchcase" or name == "blacklight case" or name == "blacklightcase" or name == "aila case" or name == "ailacase" or (name:find("blacklight") and name:find("battery")) then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then fireproximityprompt(prompt) end
                        end
                    end
                end)
            end
        end)
        coroutine.resume(itemAuraThread)
    else
        if itemAuraThread then coroutine.close(itemAuraThread); itemAuraThread = nil end
    end
end)

-- ============================================================
--  MOVEMENT ФУНКЦИИ
-- ============================================================
addSection("━━━ MOVEMENT ━━━")

-- Noclip
makeButton("Noclip", true, function(state)
    if state then
        RunService.Stepped:Connect(function()
            if not state then return end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end)

-- Fly
local flyActive = false
local flyBodyVel = nil
local flyBodyGyro = nil

makeButton("Fly", true, function(state)
    flyActive = state
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    if state then
        if flyBodyVel then flyBodyVel:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        flyBodyVel = Instance.new("BodyVelocity", hrp)
        flyBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro = Instance.new("BodyGyro", hrp)
        flyBodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBodyGyro.P = 1e4
        hum.PlatformStand = true
        RunService.RenderStepped:Connect(function()
            if not flyActive then return end
            local cam = Workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local dir = cam.CFrame.LookVector * moveDir.Z * (-1) + cam.CFrame.RightVector * moveDir.X
                dir = Vector3.new(dir.X, 0, dir.Z).Unit
                flyBodyVel.Velocity = dir * 50
            else
                flyBodyVel.Velocity = Vector3.new(0, 0, 0)
            end
            flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
        end)
    else
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        hum.PlatformStand = false
    end
end)

-- Jump Power
makeButton("Jump Power", true, function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if state then hum.JumpPower = 100 else hum.JumpPower = 50 end
    end
end)

-- Walk Speed
makeButton("Walk Speed", true, function(state)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        if state then hum.WalkSpeed = 50 else hum.WalkSpeed = 16 end
    end
end)

-- ============================================================
--  MISC ФУНКЦИИ
-- ============================================================
addSection("━━━ MISC ━━━")

-- Insta Build
makeButton("Insta Build", false, nil, function()
    for i = 1, 100 do
        for _, v in pairs(Workspace.Misc:GetDescendants()) do
            if v.Name == "BarricadePrompt" then
                fireproximityprompt(v)
            end
        end
    end
end)

-- Full Bright
makeButton("Full Bright", true, function(state)
    if state then
        if not savedLighting then
            savedLighting = {
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                Brightness = Lighting.Brightness,
                ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd,
            }
        end
        Lighting.Ambient = Color3.fromRGB(236, 236, 236)
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14.5
        Lighting.FogEnd = 10000000
    else
        if savedLighting then
            Lighting.Ambient = savedLighting.Ambient
            Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
            Lighting.Brightness = savedLighting.Brightness
            Lighting.ClockTime = savedLighting.ClockTime
            Lighting.FogEnd = savedLighting.FogEnd
        end
    end
end)

-- Item Farm
local farmActive = false
local farmThread = nil

makeButton("Item Farm", true, function(state)
    farmActive = state
    if state then
        if farmThread then coroutine.close(farmThread) end
        farmThread = coroutine.create(function()
            while farmActive do
                task.wait(0.1)
                pcall(function()
                    local targets = {}
                    for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                        if v.Name == "Relic" and v:FindFirstChild("RelicPrompt") then
                            table.insert(targets, v.Position)
                        end
                    end
                    for _, v in pairs(workspace:GetDescendants()) do
                        local name = v.Name:lower()
                        if name == "murch case" or name == "murchcase" or name == "blacklight case" or name == "blacklightcase" or name == "aila case" or name == "ailacase" or (name:find("blacklight") and name:find("battery")) then
                            table.insert(targets, v.Position)
                        end
                    end
                    for _, pos in pairs(targets) do
                        if not farmActive then break end
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(pos)
                            task.wait(0.5)
                        end
                    end
                end)
            end
        end)
        coroutine.resume(farmThread)
    else
        if farmThread then coroutine.close(farmThread); farmThread = nil end
    end
end)

-- ============================================================
--  ОТКРЫТИЕ/ЗАКРЫТИЕ МЕНЮ
-- ============================================================
FAB.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    Menu.Visible = menuOpen
end)

-- Перетаскивание меню
local menuDragging = false
local menuDragStart = nil
local menuStartPos = nil

MenuHeader.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuDragging = true
        menuDragStart = input.Position
        menuStartPos = Menu.Position
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        menuDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if menuDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - menuDragStart
        Menu.Position = UDim2.new(
            menuStartPos.X.Scale,
            menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale,
            menuStartPos.Y.Offset + delta.Y
        )
    end
end)

print("STN GUI FULL загружен! Нажми на кружок STN")