--[[
    STN GUI - Mobile Edition (FINAL ULTIMATE)
]]

-- Cleanup old GUIs
for i, v in pairs(game:GetDescendants()) do
    if v.Name == "STN_MobileGui" then
        v:Destroy()
    end
end

-- Services
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "STN_MobileGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

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
Menu.Size = UDim2.new(0, 210, 0, 340) -- немного увеличил высоту для новых кнопок
Menu.Position = UDim2.new(0.5, -105, 0.5, -170)
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
--  ANTI-CHEAT BYPASS
-- ============================================================
local bypassEnabled = false

local function enableBypass()
    if bypassEnabled then return end
    bypassEnabled = true
    
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and method == "Kick" then
            return nil
        end
        return oldNamecall(self, ...)
    end)
    
    local mt = getrawmetatable(game)
    local oldNewIndex = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = newcclosure(function(t, k, v)
        if not checkcaller() and t:IsA("Humanoid") then
            if k == "WalkSpeed" or k == "JumpPower" then
                return nil
            end
        end
        return oldNewIndex(t, k, v)
    end)
    setreadonly(mt, true)
    
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("LocalScript") then
            local name = v.Name:lower()
            if name:find("anticheat") or name:find("adoni") or name:find("checker") then
                v.Disabled = true
            end
        end
    end
    print("Anti-Cheat Bypass ON")
end

local function disableBypass()
    bypassEnabled = false
    print("Anti-Cheat Bypass OFF")
end

-- ============================================================
--  ESP: ТЕКСТОВЫЕ НАДПИСИ ДЛЯ ОБЪЕКТОВ
-- ============================================================
local activeTags = {} -- храним все созданные BillboardGui

local function addObjectTag(obj, text, color)
    if not obj or not obj.Parent then return end
    -- Удаляем старый тег
    for i, tag in ipairs(activeTags) do
        if tag.Adornee == obj then
            tag:Destroy()
            table.remove(activeTags, i)
            break
        end
    end
    local bill = Instance.new("BillboardGui")
    bill.Name = "STN_ObjectTag"
    bill.AlwaysOnTop = true
    bill.Size = UDim2.new(0, 120, 0, 30)
    bill.StudsOffset = Vector3.new(0, 2, 0)
    bill.Parent = obj
    local label = Instance.new("TextLabel", bill)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    table.insert(activeTags, bill)
end

local function removeTagsByCondition(condition)
    for i = #activeTags, 1, -1 do
        local tag = activeTags[i]
        if condition(tag) then
            tag:Destroy()
            table.remove(activeTags, i)
        end
    end
end

-- Словарь для состояний ESP объектов
local espObjectStates = {
    relic = false,
    murch = false,
    blacklightCase = false,
    aila = false,
    battery = false
}

local function updateRelicTag()
    if espObjectStates.relic then
        for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
            if v.Name == "Relic" then
                addObjectTag(v, "RELIC", Color3.fromRGB(50, 100, 200))
            end
        end
    else
        removeTagsByCondition(function(tag)
            return tag.Adornee and tag.Adornee.Parent and tag.Adornee.Parent.Parent == Workspace.TempMap.Main.Relics
        end)
    end
end

local function updateMurchTag()
    if espObjectStates.murch then
        for _, v in pairs(Workspace.Misc:GetDescendants()) do
            if v.Name == "MurchCase" then
                addObjectTag(v, "MURCH CASE", Color3.fromRGB(255, 60, 60))
            end
        end
    else
        removeTagsByCondition(function(tag)
            return tag.Adornee and tag.Adornee.Name == "MurchCase"
        end)
    end
end

local function updateBlacklightCaseTag()
    if espObjectStates.blacklightCase then
        for _, v in pairs(Workspace.Misc:GetDescendants()) do
            if v.Name == "BLACKLIGHTCase" then
                addObjectTag(v, "BLACKLIGHT CASE", Color3.fromRGB(180, 60, 255))
            end
        end
    else
        removeTagsByCondition(function(tag)
            return tag.Adornee and tag.Adornee.Name == "BLACKLIGHTCase"
        end)
    end
end

local function updateAilaTag()
    if espObjectStates.aila then
        for _, v in pairs(Workspace.Misc:GetDescendants()) do
            if v.Name == "AILACase" then
                addObjectTag(v, "AILA CASE", Color3.fromRGB(0, 180, 255))
            end
        end
    else
        removeTagsByCondition(function(tag)
            return tag.Adornee and tag.Adornee.Name == "AILACase"
        end)
    end
end

local function updateBatteryTag()
    if espObjectStates.battery then
        for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
            if v.Name == "BlacklightBattery" then
                addObjectTag(v, "BLACKLIGHT BATTERY", Color3.fromRGB(180, 60, 255))
            end
        end
    else
        removeTagsByCondition(function(tag)
            return tag.Adornee and tag.Adornee.Name == "BlacklightBattery"
        end)
    end
end

-- ============================================================
--  PLAYER ESP (Highlight + имя выше)
-- ============================================================
local playerEspActive = false
local playerHighlights = {}
local playerNameTags = {}

local function updatePlayerESP()
    if playerEspActive then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local char = plr.Character
                -- Highlight
                local hl = Instance.new("Highlight")
                hl.Adornee = char
                hl.FillTransparency = 1
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = char
                table.insert(playerHighlights, hl)
                -- Имя выше
                local bill = Instance.new("BillboardGui")
                bill.Name = "STN_PlayerTag"
                bill.AlwaysOnTop = true
                bill.Size = UDim2.new(0, 120, 0, 30)
                bill.StudsOffset = Vector3.new(0, 4, 0)
                bill.Parent = char
                local text = Instance.new("TextLabel", bill)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = plr.Name
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextSize = 14
                text.Font = Enum.Font.GothamBold
                text.TextStrokeTransparency = 0.3
                table.insert(playerNameTags, bill)
            end
        end
    else
        for _, h in pairs(playerHighlights) do h:Destroy() end
        playerHighlights = {}
        for _, t in pairs(playerNameTags) do t:Destroy() end
        playerNameTags = {}
    end
end

Players.PlayerAdded:Connect(function(plr)
    if playerEspActive then
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            updatePlayerESP()
        end)
    end
end)

-- ============================================================
--  ФУНКЦИИ ДЛЯ КНОПОК (ползунки для скорости, toggle)
-- ============================================================
local function makeSliderButton(text, minVal, maxVal, defaultVal, onValueChange)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 58)
    container.BackgroundTransparency = 1
    container.Parent = ScrollFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.Text = text .. " - OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.ZIndex = 20
    btn.Parent = container
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    -- Панель ползунка
    local sliderPanel = Instance.new("Frame")
    sliderPanel.Size = UDim2.new(1, 0, 0, 20)
    sliderPanel.Position = UDim2.new(0, 0, 0, 36)
    sliderPanel.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    sliderPanel.BackgroundTransparency = 0
    sliderPanel.Visible = false
    sliderPanel.ZIndex = 20
    sliderPanel.Parent = container
    
    local sliderCorner = Instance.new("UICorner", sliderPanel)
    sliderCorner.CornerRadius = UDim.new(0, 4)
    
    -- Трек
    local track = Instance.new("Frame")
    track.Size = UDim2.new(0.7, 0, 0, 4)
    track.Position = UDim2.new(0.15, 0, 0.5, -2)
    track.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    track.ZIndex = 21
    track.Parent = sliderPanel
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(0, 2)
    
    -- Заполнение
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 160, 255)
    fill.ZIndex = 21
    fill.Parent = track
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 2)
    
    -- Ручка
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new(0, -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.ZIndex = 22
    knob.Parent = track
    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(0, 6)
    
    -- Значение
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.15, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.87, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 10
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.ZIndex = 21
    valueLabel.Parent = sliderPanel
    
    local state = false
    local currentVal = defaultVal
    
    local function updateSliderUI(pct)
        local trackWidth = track.AbsoluteSize.X
        if trackWidth == 0 then trackWidth = 100 end
        local newWidth = trackWidth * pct
        fill.Size = UDim2.new(0, newWidth, 1, 0)
        knob.Position = UDim2.new(0, newWidth - 6, 0.5, -6)
        currentVal = math.floor(minVal + (maxVal - minVal) * pct)
        valueLabel.Text = tostring(currentVal)
        if state and onValueChange then
            onValueChange(currentVal)
        end
    end
    
    task.wait(0.1)
    local initPct = (defaultVal - minVal) / (maxVal - minVal)
    updateSliderUI(initPct)
    
    local sliderDragging = false
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateSliderUI(pct)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            updateSliderUI(pct)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(70, 130, 90)
            btn.Text = text .. " - ON"
            sliderPanel.Visible = true
            container.Size = UDim2.new(1, 0, 0, 58)
            if onValueChange then onValueChange(currentVal) end
        else
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            btn.Text = text .. " - OFF"
            sliderPanel.Visible = false
            container.Size = UDim2.new(1, 0, 0, 34)
            if onValueChange then onValueChange(minVal) end
        end
    end)
    
    return container, function() return state, currentVal end
end

local function makeToggleButton(text, onToggle)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
    btn.Text = text .. " - OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.ZIndex = 20
    btn.Parent = ScrollFrame
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 6)
    
    local state = false
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(70, 130, 90)
            btn.Text = text .. " - ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(55, 55, 75)
            btn.Text = text .. " - OFF"
        end
        if onToggle then onToggle(state) end
    end)
    
    return btn, function() return state end
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
    lbl.ZIndex = 20
    lbl.Parent = ScrollFrame
end

-- ============================================================
--  AURA (без ползунков, максимальная дальность 2000)
-- ============================================================
local relicAuraActive = false
local relicAuraThread = nil
local itemAuraActive = false
local itemAuraThread = nil

local function startRelicAura()
    if relicAuraThread then coroutine.close(relicAuraThread) end
    relicAuraThread = coroutine.create(function()
        while relicAuraActive do
            task.wait(0.1)
            pcall(function()
                for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                    if v.Name == "Relic" and v:FindFirstChild("RelicPrompt") then
                        local prompt = v.RelicPrompt
                        local orig = prompt.MaxActivationDistance
                        prompt.MaxActivationDistance = 2000
                        fireproximityprompt(prompt)
                        prompt.MaxActivationDistance = orig
                    end
                end
                for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
                    if v.Name == "BlacklightBattery" then
                        local prompt = v:FindFirstChild("BlacklightBatteryPrompt")
                        if prompt then
                            local orig = prompt.MaxActivationDistance
                            prompt.MaxActivationDistance = 2000
                            fireproximityprompt(prompt)
                            prompt.MaxActivationDistance = orig
                        end
                    end
                end
            end)
        end
    end)
    coroutine.resume(relicAuraThread)
end

local function startItemAura()
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
                for _, v in pairs(Workspace.Misc:GetDescendants()) do
                    if v.Name == "MurchCase" or v.Name == "AILACase" or v.Name == "BLACKLIGHTCase" then
                        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            local orig = prompt.MaxActivationDistance
                            prompt.MaxActivationDistance = 2000
                            fireproximityprompt(prompt)
                            prompt.MaxActivationDistance = orig
                        end
                    end
                end
            end)
        end
    end)
    coroutine.resume(itemAuraThread)
end

-- ============================================================
--  INSTANT INTERACT (цикл + отслеживание новых промптов)
-- ============================================================
local instantInteractActive = false
local instantInteractConnection = nil
local instantInteractTrackConnection = nil
local originalHoldDurations = {} -- словарь: промпт -> оригинальное значение

-- Функция сохранения оригинального значения (если ещё не сохранено)
local function saveOriginalHoldDuration(prompt)
    if not originalHoldDurations[prompt] then
        originalHoldDurations[prompt] = prompt.HoldDuration
    end
end

-- Функция установки нуля для всех известных промптов
local function setAllPromptsToZero()
    for prompt, _ in pairs(originalHoldDurations) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = 0
        else
            -- если промпт уничтожен, удаляем из таблицы
            originalHoldDurations[prompt] = nil
        end
    end
    -- дополнительно проходим по всем промптам в игре, чтобы не пропустить новые
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            saveOriginalHoldDuration(v)
            v.HoldDuration = 0
        end
    end
end

-- Функция восстановления оригинальных значений
local function restoreAllPrompts()
    for prompt, orig in pairs(originalHoldDurations) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = orig
        end
    end
end

-- Обработчик новых объектов (для новых промптов, появляющихся во время работы)
local function onDescendantAdded(descendant)
    if instantInteractActive and descendant:IsA("ProximityPrompt") then
        saveOriginalHoldDuration(descendant)
        descendant.HoldDuration = 0
    end
end

local function enableInstantInteract()
    if instantInteractActive then return end
    instantInteractActive = true
    
    -- Сохраняем оригинальные значения всех существующих промптов
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            saveOriginalHoldDuration(v)
            v.HoldDuration = 0
        end
    end
    
    -- Запускаем цикл для постоянного обнуления (на случай, если игра меняет значение)
    instantInteractConnection = RunService.Heartbeat:Connect(function()
        if not instantInteractActive then return end
        for prompt, _ in pairs(originalHoldDurations) do
            if prompt and prompt.Parent and prompt.HoldDuration ~= 0 then
                prompt.HoldDuration = 0
            end
        end
    end)
    
    -- Отслеживаем новые промпты
    instantInteractTrackConnection = game.DescendantAdded:Connect(onDescendantAdded)
    
    print("Instant Interact ON")
end

local function disableInstantInteract()
    if not instantInteractActive then return end
    instantInteractActive = false
    
    -- Останавливаем цикл и отслеживание
    if instantInteractConnection then
        instantInteractConnection:Disconnect()
        instantInteractConnection = nil
    end
    if instantInteractTrackConnection then
        instantInteractTrackConnection:Disconnect()
        instantInteractTrackConnection = nil
    end
    
    -- Восстанавливаем оригинальные значения для всех промптов, которые ещё существуют
    restoreAllPrompts()
    
    -- Очищаем таблицу, чтобы при повторном включении всё сохранилось заново
    originalHoldDurations = {}
    
    print("Instant Interact OFF")
end

-- ============================================================
--  AIRJUMP (ходьба по воздуху)
-- ============================================================
local airJumpEnabled = false
local airJumpPlatform = nil
local airJumpCurrentY = 0
local airJumpFallSpeed = 0.1

local function getAirJumpPlatform()
    if not airJumpPlatform or not airJumpPlatform.Parent then
        airJumpPlatform = Instance.new("Part")
        airJumpPlatform.Size = Vector3.new(7, 1, 7)
        airJumpPlatform.Transparency = 1
        airJumpPlatform.Anchored = true
        airJumpPlatform.CanCollide = true
        airJumpPlatform.Parent = workspace
    end
    return airJumpPlatform
end

local airJumpConnection = nil

local function startAirJump()
    if airJumpConnection then airJumpConnection:Disconnect() end
    airJumpConnection = RunService.Heartbeat:Connect(function()
        if not airJumpEnabled then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum then
            if hum.FloorMaterial == Enum.Material.Air and not hum.Sit then
                local p = getAirJumpPlatform()
                if airJumpCurrentY == 0 or airJumpCurrentY < (hrp.Position.Y - 5) then
                    airJumpCurrentY = hrp.Position.Y - 3.5
                end
                airJumpCurrentY = airJumpCurrentY - airJumpFallSpeed
                p.CFrame = CFrame.new(hrp.Position.X, airJumpCurrentY, hrp.Position.Z)
                p.CanCollide = true
            else
                airJumpCurrentY = 0
                if airJumpPlatform then
                    airJumpPlatform.CanCollide = false
                    airJumpPlatform.CFrame = CFrame.new(0, -500, 0)
                end
            end
        end
    end)
end

local function stopAirJump()
    if airJumpConnection then airJumpConnection:Disconnect(); airJumpConnection = nil end
    if airJumpPlatform then
        airJumpPlatform:Destroy()
        airJumpPlatform = nil
    end
    airJumpCurrentY = 0
end

-- ============================================================
--  MOVEMENT (Fly исправлен, добавлен AirJump)
-- ============================================================
local flyActive = false
local flyBodyVel = nil
local flyBodyGyro = nil
local flySpeed = 50

local function startFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
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
            local forward = cam.CFrame.LookVector * -moveDir.Z
            local right = cam.CFrame.RightVector * moveDir.X
            local dir = (forward + right).Unit
            flyBodyVel.Velocity = dir * flySpeed
        else
            flyBodyVel.Velocity = Vector3.new(0, 0, 0)
        end
        flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
    end)
end

-- ============================================================
--  СОЗДАНИЕ ВСЕХ КНОПОК
-- ============================================================
addSection("━━━ ESP ━━━")

makeToggleButton("Relic ESP", function(state)
    espObjectStates.relic = state
    updateRelicTag()
end)

makeToggleButton("Murch Case ESP", function(state)
    espObjectStates.murch = state
    updateMurchTag()
end)

makeToggleButton("Blacklight Case ESP", function(state)
    espObjectStates.blacklightCase = state
    updateBlacklightCaseTag()
end)

makeToggleButton("Aila Case ESP", function(state)
    espObjectStates.aila = state
    updateAilaTag()
end)

makeToggleButton("Battery ESP", function(state)
    espObjectStates.battery = state
    updateBatteryTag()
end)

makeToggleButton("Player ESP", function(state)
    playerEspActive = state
    updatePlayerESP()
end)

addSection("━━━ AURA ━━━")

-- Relic Aura (без ползунка)
makeToggleButton("Relic Aura", function(state)
    relicAuraActive = state
    if state then
        startRelicAura()
    else
        if relicAuraThread then coroutine.close(relicAuraThread); relicAuraThread = nil end
    end
end)

-- Item Aura (без ползунка)
makeToggleButton("Item Aura", function(state)
    itemAuraActive = state
    if state then
        startItemAura()
    else
        if itemAuraThread then coroutine.close(itemAuraThread); itemAuraThread = nil end
    end
end)

addSection("━━━ MOVEMENT ━━━")

-- Noclip
makeToggleButton("Noclip", function(state)
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

-- Fly (с ползунком)
makeSliderButton("Fly", 10, 50, 50, function(val)
    flySpeed = val
    if flyActive and flyBodyVel then
        flyBodyVel.Velocity = flyBodyVel.Velocity.Unit * flySpeed
    end
end)
for _, v in pairs(ScrollFrame:GetChildren()) do
    if v:IsA("Frame") and v:FindFirstChildWhichIsA("TextButton") then
        local btn = v:FindFirstChildWhichIsA("TextButton")
        if btn and btn.Text:find("Fly") then
            btn.MouseButton1Click:Connect(function()
                task.wait(0.05)
                flyActive = btn.Text:find("ON") ~= nil
                if flyActive then startFly() else
                    if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
                    if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then hum.PlatformStand = false end
                end
            end)
            break
        end
    end
end

-- Jump Power (с ползунком)
local jumpPowerActive = false
local jumpPowerValue = 50
makeSliderButton("Jump Power", 1, 150, 50, function(val)
    jumpPowerValue = val
    if jumpPowerActive then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = jumpPowerValue end
    end
end)
for _, v in pairs(ScrollFrame:GetChildren()) do
    if v:IsA("Frame") and v:FindFirstChildWhichIsA("TextButton") then
        local btn = v:FindFirstChildWhichIsA("TextButton")
        if btn and btn.Text:find("Jump Power") then
            btn.MouseButton1Click:Connect(function()
                task.wait(0.05)
                jumpPowerActive = btn.Text:find("ON") ~= nil
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then
                    if jumpPowerActive then hum.JumpPower = jumpPowerValue else hum.JumpPower = 50 end
                end
            end)
            break
        end
    end
end

-- Walk Speed (с ползунком, защита от сброса)
local walkSpeedActive = false
local walkSpeedValue = 16
local walkSpeedConnection = nil
local function holdWalkSpeed()
    if walkSpeedConnection then walkSpeedConnection:Disconnect() end
    walkSpeedConnection = RunService.Heartbeat:Connect(function()
        if walkSpeedActive then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.WalkSpeed ~= walkSpeedValue then
                hum.WalkSpeed = walkSpeedValue
            end
        end
    end)
end
makeSliderButton("Walk Speed", 10, 100, 16, function(val)
    walkSpeedValue = val
    if walkSpeedActive then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = walkSpeedValue end
    end
end)
for _, v in pairs(ScrollFrame:GetChildren()) do
    if v:IsA("Frame") and v:FindFirstChildWhichIsA("TextButton") then
        local btn = v:FindFirstChildWhichIsA("TextButton")
        if btn and btn.Text:find("Walk Speed") then
            btn.MouseButton1Click:Connect(function()
                task.wait(0.05)
                walkSpeedActive = btn.Text:find("ON") ~= nil
                if walkSpeedActive then
                    holdWalkSpeed()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then hum.WalkSpeed = walkSpeedValue end
                else
                    if walkSpeedConnection then walkSpeedConnection:Disconnect(); walkSpeedConnection = nil end
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end)
            break
        end
    end
end

-- AirJump (ходьба по воздуху)
makeToggleButton("AirJump", function(state)
    airJumpEnabled = state
    if state then
        startAirJump()
    else
        stopAirJump()
    end
end)

addSection("━━━ MISC ━━━")

-- Full Bright
local fullBrightState = false
local savedLighting = {}
makeToggleButton("Full Bright", function(state)
    fullBrightState = state
    if state then
        savedLighting = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ExposureCompensation = Lighting.ExposureCompensation,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            FogStart = Lighting.FogStart,
            GlobalShadows = Lighting.GlobalShadows,
        }
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = false
            end
        end
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        Lighting.Brightness = 2
        Lighting.ExposureCompensation = 0.5
        Lighting.ClockTime = 14
        Lighting.FogEnd = 5000
        Lighting.FogStart = 5000
        Lighting.GlobalShadows = false
        pcall(function() if Lighting.Atmosphere then Lighting.Atmosphere.Enabled = false end end)
    else
        if savedLighting then
            Lighting.Ambient = savedLighting.Ambient
            Lighting.OutdoorAmbient = savedLighting.OutdoorAmbient
            Lighting.Brightness = savedLighting.Brightness
            Lighting.ExposureCompensation = savedLighting.ExposureCompensation
            Lighting.ClockTime = savedLighting.ClockTime
            Lighting.FogEnd = savedLighting.FogEnd
            Lighting.FogStart = savedLighting.FogStart
            Lighting.GlobalShadows = savedLighting.GlobalShadows
        end
    end
end)

-- Item Farm (с задержкой между телепортами)
local farmActive = false
local farmThread = nil
makeToggleButton("Item Farm", function(state)
    farmActive = state
    if state then
        if farmThread then coroutine.close(farmThread) end
        farmThread = coroutine.create(function()
            while farmActive do
                pcall(function()
                    local targets = {}
                    -- Реликвии
                    for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                        if v.Name == "Relic" and v:FindFirstChild("RelicPrompt") then
                            table.insert(targets, {pos = v.Position, prompt = v.RelicPrompt})
                        end
                    end
                    -- Кейсы в Misc
                    for _, v in pairs(Workspace.Misc:GetDescendants()) do
                        if v.Name == "MurchCase" or v.Name == "AILACase" or v.Name == "BLACKLIGHTCase" then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                table.insert(targets, {pos = v.Position, prompt = prompt})
                            end
                        end
                    end
                    -- Blacklight Batteries
                    for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
                        if v.Name == "BlacklightBattery" then
                            local prompt = v:FindFirstChild("BlacklightBatteryPrompt")
                            if prompt then
                                table.insert(targets, {pos = v.Position, prompt = prompt})
                            end
                        end
                    end
                    for _, target in pairs(targets) do
                        if not farmActive then break end
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(target.pos)
                            task.wait(0.5) -- задержка после телепорта
                            fireproximityprompt(target.prompt)
                            task.wait(0.3) -- пауза перед следующим предметом
                        end
                    end
                end)
                task.wait(0.5) -- пауза между циклами, чтобы не спамить телепортами
            end
        end)
        coroutine.resume(farmThread)
    else
        if farmThread then coroutine.close(farmThread); farmThread = nil end
    end
end)

-- Instant Interact (мгновенное взаимодействие)
makeToggleButton("Instant Interact", function(state)
    if state then
        enableInstantInteract()
    else
        disableInstantInteract()
    end
end)

-- Anti-Cheat Bypass
makeToggleButton("Anti-Cheat Bypass", function(state)
    if state then enableBypass() else disableBypass() end
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
