

```lua
--[[
    STN GUI - Mobile Edition (Fixed)
    Author: Synex_zxc
]]

-- Cleanup old GUIs
for i, v in pairs(game:GetDescendants()) do
    if v.Name == "STN_MobileGui" then
        v:Destroy()
    end
end

-- ============================================================
--  STATE
-- ============================================================
local cool          = false   -- ItemFarm toggle
local relicOn       = false   -- RelicAura toggle
local taskOn        = false   -- ItemAura toggle
local guiOpen       = true    -- Panel visibility
local fullBrightOn  = false   -- FullBright toggle

-- Сохранённые оригинальные настройки освещения (заполняются при первом включении)
local savedLighting = nil

-- Хранилище оригинальных дистанций для ProximityPrompt
local originalDistances = {}

-- ============================================================
--  SERVICES
-- ============================================================
local TweenService   = game:GetService("TweenService")
local RunService     = game:GetService("RunService")
local Players        = game:GetService("Players")
local Workspace      = game:GetService("Workspace")
local Lighting       = game:GetService("Lighting")
local LocalPlayer    = Players.LocalPlayer

-- ============================================================
--  THEME
-- ============================================================
local THEME = {
    BG         = Color3.fromRGB(15, 15, 20),
    PANEL      = Color3.fromRGB(22, 22, 30),
    CARD       = Color3.fromRGB(30, 30, 42),
    ACCENT     = Color3.fromRGB(80, 140, 255),
    ACCENT2    = Color3.fromRGB(120, 80, 255),
    TEXT       = Color3.fromRGB(230, 230, 255),
    SUBTEXT    = Color3.fromRGB(140, 140, 170),
    ON         = Color3.fromRGB(60, 220, 130),
    OFF        = Color3.fromRGB(200, 60, 80),
    BORDER     = Color3.fromRGB(50, 50, 70),
}

-- ============================================================
--  GUI ROOT
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "STN_MobileGui"
ScreenGui.ResetOnSpawn     = false
ScreenGui.IgnoreGuiInset   = true
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent           = game:WaitForChild("CoreGui")

-- ============================================================
--  HELPERS
-- ============================================================
local function addCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 12)
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color or THEME.BORDER
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

local function addGradient(parent, c0, c1, rot)
    local g = Instance.new("UIGradient", parent)
    g.Color    = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
end

local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quad), props):Play()
end

-- Сохранение оригинальной дистанции промпта
local function saveOriginalDistance(prompt)
    if not originalDistances[prompt] then
        originalDistances[prompt] = prompt.MaxActivationDistance
    end
end

-- Восстановление оригинальной дистанции
local function restoreOriginalDistance(prompt)
    if originalDistances[prompt] then
        prompt.MaxActivationDistance = originalDistances[prompt]
    end
end

-- ============================================================
--  TOGGLE BUTTON (FAB) — открывает/закрывает меню
-- ============================================================
local FAB = Instance.new("TextButton")
FAB.Size            = UDim2.new(0, 54, 0, 54)
FAB.Position        = UDim2.new(0, 14, 0.5, -27)
FAB.AnchorPoint     = Vector2.new(0, 0)
FAB.BackgroundColor3 = THEME.ACCENT
FAB.Text            = "☰"
FAB.TextColor3      = Color3.new(1,1,1)
FAB.TextSize        = 24
FAB.Font            = Enum.Font.GothamBold
FAB.ZIndex          = 20
FAB.Parent          = ScreenGui
addCorner(FAB, 27)
addGradient(FAB, THEME.ACCENT, THEME.ACCENT2, 135)

local fabShadow = Instance.new("Frame")
fabShadow.Size               = UDim2.new(1, 8, 1, 8)
fabShadow.Position           = UDim2.new(0, -4, 0, 4)
fabShadow.BackgroundColor3   = Color3.fromRGB(0,0,0)
fabShadow.BackgroundTransparency = 0.7
fabShadow.ZIndex             = 19
fabShadow.Parent             = FAB
addCorner(fabShadow, 27)

-- ============================================================
--  MAIN PANEL
-- ============================================================
local Panel = Instance.new("Frame")
Panel.Name              = "Panel"
Panel.Size              = UDim2.new(0, 260, 0, 520)
Panel.Position          = UDim2.new(0, 78, 0.5, -260)
Panel.BackgroundColor3  = THEME.PANEL
Panel.BorderSizePixel   = 0
Panel.ZIndex            = 10
Panel.Parent            = ScreenGui
addCorner(Panel, 18)
addStroke(Panel, THEME.BORDER, 1)

addGradient(Panel, Color3.fromRGB(25,25,38), Color3.fromRGB(18,18,26), 135)

-- ---- HEADER ----
local Header = Instance.new("Frame")
Header.Size             = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = THEME.BG
Header.BorderSizePixel  = 0
Header.ZIndex           = 11
Header.Parent           = Panel
addCorner(Header, 18)

local HeaderFill = Instance.new("Frame")
HeaderFill.Size              = UDim2.new(1,0, 0, 18)
HeaderFill.Position          = UDim2.new(0,0, 1,-18)
HeaderFill.BackgroundColor3  = THEME.BG
HeaderFill.BorderSizePixel   = 0
HeaderFill.ZIndex            = 11
HeaderFill.Parent            = Header

addGradient(Header, THEME.ACCENT, THEME.ACCENT2, 90)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size              = UDim2.new(1, -20, 1, 0)
TitleLabel.Position          = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text              = "✦  STN GUI"
TitleLabel.TextColor3        = Color3.new(1,1,1)
TitleLabel.TextSize          = 18
TitleLabel.Font              = Enum.Font.GothamBold
TitleLabel.TextXAlignment    = Enum.TextXAlignment.Left
TitleLabel.ZIndex            = 12
TitleLabel.Parent            = Header

local SubLabel = Instance.new("TextLabel")
SubLabel.Size                = UDim2.new(1, -20, 0, 14)
SubLabel.Position            = UDim2.new(0, 16, 0, 30)
SubLabel.BackgroundTransparency = 1
SubLabel.Text                = "Mobile Edition"
SubLabel.TextColor3          = Color3.fromRGB(200, 200, 255)
SubLabel.TextTransparency    = 0.3
SubLabel.TextSize            = 11
SubLabel.Font                = Enum.Font.Gotham
SubLabel.TextXAlignment      = Enum.TextXAlignment.Left
SubLabel.ZIndex              = 12
SubLabel.Parent              = Header

-- ---- SCROLLING CONTENT ----
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size                  = UDim2.new(1, 0, 1, -58)
Scroll.Position              = UDim2.new(0, 0, 0, 58)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel       = 0
Scroll.ScrollBarThickness    = 3
Scroll.ScrollBarImageColor3  = THEME.ACCENT
Scroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
Scroll.ZIndex                = 11
Scroll.Parent                = Panel

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.Padding          = UDim.new(0, 8)
ListLayout.SortOrder        = Enum.SortOrder.LayoutOrder

local ScrollPad = Instance.new("UIPadding", Scroll)
ScrollPad.PaddingLeft   = UDim.new(0, 10)
ScrollPad.PaddingRight  = UDim.new(0, 10)
ScrollPad.PaddingTop    = UDim.new(0, 10)
ScrollPad.PaddingBottom = UDim.new(0, 10)

-- ============================================================
--  BUTTON FACTORY
-- ============================================================
local buttons = {}
local order   = 0

local function makeButton(label, icon, isToggle, onClick)
    order = order + 1

    local Card = Instance.new("Frame")
    Card.Size               = UDim2.new(1, 0, 0, 58)
    Card.BackgroundColor3   = THEME.CARD
    Card.BorderSizePixel    = 0
    Card.LayoutOrder        = order
    Card.ZIndex             = 12
    Card.Parent             = Scroll
    addCorner(Card, 12)
    addStroke(Card, THEME.BORDER, 1)

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size              = UDim2.new(0, 38, 0, 38)
    IconLabel.Position          = UDim2.new(0, 10, 0.5, -19)
    IconLabel.BackgroundColor3  = THEME.BG
    IconLabel.Text              = icon
    IconLabel.TextSize          = 18
    IconLabel.Font              = Enum.Font.GothamBold
    IconLabel.TextColor3        = THEME.ACCENT
    IconLabel.ZIndex            = 13
    IconLabel.Parent            = Card
    addCorner(IconLabel, 10)

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size              = UDim2.new(1, -110, 0, 20)
    NameLabel.Position          = UDim2.new(0, 58, 0.5, -10)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text              = label
    NameLabel.TextColor3        = THEME.TEXT
    NameLabel.TextSize          = 14
    NameLabel.Font              = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment    = Enum.TextXAlignment.Left
    NameLabel.ZIndex            = 13
    NameLabel.Parent            = Card

    local Badge = Instance.new("TextLabel")
    Badge.Size              = UDim2.new(0, 46, 0, 24)
    Badge.Position          = UDim2.new(1, -56, 0.5, -12)
    Badge.BackgroundColor3  = isToggle and THEME.OFF or THEME.ACCENT
    Badge.Text              = isToggle and "OFF" or "RUN"
    Badge.TextColor3        = Color3.new(1,1,1)
    Badge.TextSize          = 11
    Badge.Font              = Enum.Font.GothamBold
    Badge.ZIndex            = 13
    Badge.Parent            = Card
    addCorner(Badge, 6)

    local Btn = Instance.new("TextButton")
    Btn.Size                    = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency  = 1
    Btn.Text                    = ""
    Btn.ZIndex                  = 14
    Btn.Parent                  = Card

    local toggled = false

    Btn.MouseButton1Click:Connect(function()
        tween(Card, {BackgroundColor3 = THEME.ACCENT}, 0.08)
        task.delay(0.08, function()
            tween(Card, {BackgroundColor3 = THEME.CARD}, 0.15)
        end)

        if isToggle then
            toggled = not toggled
            if toggled then
                Badge.Text             = "ON"
                Badge.BackgroundColor3 = THEME.ON
            else
                Badge.Text             = "OFF"
                Badge.BackgroundColor3 = THEME.OFF
            end
        end

        onClick(toggled)
    end)

    buttons[label] = { card = Card, badge = Badge }
    return Card
end

-- ============================================================
--  SECTION LABEL
-- ============================================================
local function makeSection(text)
    order = order + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size                 = UDim2.new(1, 0, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = text
    lbl.TextColor3           = THEME.SUBTEXT
    lbl.TextSize             = 11
    lbl.Font                 = Enum.Font.GothamBold
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.LayoutOrder          = order
    lbl.ZIndex               = 12
    lbl.Parent               = Scroll

    local pad = Instance.new("UIPadding", lbl)
    pad.PaddingLeft = UDim.new(0, 4)
end

-- ============================================================
--  BUTTON DEFINITIONS & LOGIC
-- ============================================================

-- ── ESP ────────────────────────────────────────────────────
makeSection("  ESP")

-- ── RELIC ESP (синяя обводка) ────────────────────
do
    local relicEspOn = false
    local ESP_COLOR  = Color3.fromRGB(50, 150, 255)
    local ESP_NAME   = "STN_RelicESP"

    makeButton("Relic ESP", "◈", true, function(state)
        relicEspOn = state
        if state then
            for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                if v.ClassName == "Relic" or v:IsA("MeshPart") or v:IsA("Model") then
                    if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end

                    local gui       = Instance.new("BillboardGui", v)
                    gui.Name        = ESP_NAME
                    gui.AlwaysOnTop = true
                    gui.Size        = UDim2.new(0, 60, 0, 60)
                    gui.StudsOffset = Vector3.new(0, 2, 0)

                    local border    = Instance.new("Frame", gui)
                    border.Size     = UDim2.new(1, 0, 1, 0)
                    border.BackgroundTransparency = 1
                    border.BorderSizePixel = 0
                    local stroke    = Instance.new("UIStroke", border)
                    stroke.Color    = ESP_COLOR
                    stroke.Thickness = 2

                    local lbl       = Instance.new("TextLabel", gui)
                    lbl.Size        = UDim2.new(1, 0, 0, 18)
                    lbl.Position    = UDim2.new(0, 0, 1, 2)
                    lbl.BackgroundTransparency = 1
                    lbl.Text        = v.Name
                    lbl.TextColor3  = ESP_COLOR
                    lbl.TextSize    = 14
                    lbl.Font        = Enum.Font.Legacy
                    lbl.TextStrokeTransparency = 0.4
                end
            end
        else
            for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end
            end
        end
    end)
end

-- ── TASK ESP ────────────────────────────────────
do
    local taskEspOn = false
    local ESP_COLOR = Color3.fromRGB(255, 60, 60)
    local ESP_NAME  = "STN_TaskESP"

    makeButton("Task ESP", "◉", true, function(state)
        taskEspOn = state
        if state then
            for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
                if v.ClassName == "Model" then
                    if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end

                    local gui       = Instance.new("BillboardGui", v)
                    gui.Name        = ESP_NAME
                    gui.AlwaysOnTop = true
                    gui.Size        = UDim2.new(0, 60, 0, 60)
                    gui.StudsOffset = Vector3.new(0, 2, 0)

                    local border    = Instance.new("Frame", gui)
                    border.Size     = UDim2.new(1, 0, 1, 0)
                    border.BackgroundTransparency = 1
                    border.BorderSizePixel = 0
                    local stroke    = Instance.new("UIStroke", border)
                    stroke.Color    = ESP_COLOR
                    stroke.Thickness = 2

                    local lbl       = Instance.new("TextLabel", gui)
                    lbl.Size        = UDim2.new(1, 0, 0, 18)
                    lbl.Position    = UDim2.new(0, 0, 1, 2)
                    lbl.BackgroundTransparency = 1
                    lbl.Text        = v.Name
                    lbl.TextColor3  = ESP_COLOR
                    lbl.TextSize    = 14
                    lbl.Font        = Enum.Font.Legacy
                    lbl.TextStrokeTransparency = 0.4
                end
            end
        else
            for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
                if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end
            end
        end
    end)
end

-- ── MURCH CASE ESP (красный) ─────────────────────────────
do
    local murchEspOn = false
    local ESP_COLOR = Color3.fromRGB(255, 60, 60)
    local ESP_NAME  = "STN_MurchESP"

    makeButton("Murch Case ESP", "📦", true, function(state)
        murchEspOn = state
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower() == "murch case" or v.Name:lower() == "murchcase" then
                    if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end

                    local gui = Instance.new("BillboardGui", v)
                    gui.Name = ESP_NAME
                    gui.AlwaysOnTop = true
                    gui.Size = UDim2.new(0, 60, 0, 60)
                    gui.StudsOffset = Vector3.new(0, 2, 0)

                    local border = Instance.new("Frame", gui)
                    border.Size = UDim2.new(1, 0, 1, 0)
                    border.BackgroundTransparency = 1
                    border.BorderSizePixel = 0
                    local stroke = Instance.new("UIStroke", border)
                    stroke.Color = ESP_COLOR
                    stroke.Thickness = 2

                    local lbl = Instance.new("TextLabel", gui)
                    lbl.Size = UDim2.new(1, 0, 0, 18)
                    lbl.Position = UDim2.new(0, 0, 1, 2)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = v.Name
                    lbl.TextColor3 = ESP_COLOR
                    lbl.TextSize = 14
                    lbl.Font = Enum.Font.Legacy
                    lbl.TextStrokeTransparency = 0.4
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end
            end
        end
    end)
end

-- ── BLACKLIGHT CASE ESP (фиолетовый) ─────────────────────
do
    local blacklightEspOn = false
    local ESP_COLOR = Color3.fromRGB(180, 60, 255)
    local ESP_NAME  = "STN_BlacklightESP"

    makeButton("Blacklight Case ESP", "🔮", true, function(state)
        blacklightEspOn = state
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower() == "blacklight case" or v.Name:lower() == "blacklightcase" then
                    if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end

                    local gui = Instance.new("BillboardGui", v)
                    gui.Name = ESP_NAME
                    gui.AlwaysOnTop = true
                    gui.Size = UDim2.new(0, 60, 0, 60)
                    gui.StudsOffset = Vector3.new(0, 2, 0)

                    local border = Instance.new("Frame", gui)
                    border.Size = UDim2.new(1, 0, 1, 0)
                    border.BackgroundTransparency = 1
                    border.BorderSizePixel = 0
                    local stroke = Instance.new("UIStroke", border)
                    stroke.Color = ESP_COLOR
                    stroke.Thickness = 2

                    local lbl = Instance.new("TextLabel", gui)
                    lbl.Size = UDim2.new(1, 0, 0, 18)
                    lbl.Position = UDim2.new(0, 0, 1, 2)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = v.Name
                    lbl.TextColor3 = ESP_COLOR
                    lbl.TextSize = 14
                    lbl.Font = Enum.Font.Legacy
                    lbl.TextStrokeTransparency = 0.4
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end
            end
        end
    end)
end

-- ── AILA CASE ESP (голубой) ──────────────────────────────
do
    local ailaEspOn = false
    local ESP_COLOR = Color3.fromRGB(0, 180, 255)
    local ESP_NAME  = "STN_AilaESP"

    makeButton("Aila Case ESP", "✨", true, function(state)
        ailaEspOn = state
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower() == "aila case" or v.Name:lower() == "ailacase" then
                    if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end

                    local gui = Instance.new("BillboardGui", v)
                    gui.Name = ESP_NAME
                    gui.AlwaysOnTop = true
                    gui.Size = UDim2.new(0, 60, 0, 60)
                    gui.StudsOffset = Vector3.new(0, 2, 0)

                    local border = Instance.new("Frame", gui)
                    border.Size = UDim2.new(1, 0, 1, 0)
                    border.BackgroundTransparency = 1
                    border.BorderSizePixel = 0
                    local stroke = Instance.new("UIStroke", border)
                    stroke.Color = ESP_COLOR
                    stroke.Thickness = 2

                    local lbl = Instance.new("TextLabel", gui)
                    lbl.Size = UDim2.new(1, 0, 0, 18)
                    lbl.Position = UDim2.new(0, 0, 1, 2)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = v.Name
                    lbl.TextColor3 = ESP_COLOR
                    lbl.TextSize = 14
                    lbl.Font = Enum.Font.Legacy
                    lbl.TextStrokeTransparency = 0.4
                end
            end
        else
            for _, v in pairs(workspace:GetDescendants()) do
                if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end
            end
        end
    end)
end

-- ── BATTERY ESP (фиолетовый) ──────────────────────────────
do
    local battEspOn = false
    local ESP_COLOR = Color3.fromRGB(180, 60, 255)
    local ESP_NAME  = "STN_BatteryESP"

    makeButton("Battery ESP", "🔋", true, function(state)
        battEspOn = state
        if state then
            for _, v in pairs(Workspace:GetDescendants()) do
                local name = v.Name:lower()
                if (name:find("battery") or name:find("blacklight") or name:find("batteries"))
                    and (v:IsA("BasePart") or v:IsA("Model") or v:IsA("MeshPart")) then

                    if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end

                    local gui       = Instance.new("BillboardGui", v)
                    gui.Name        = ESP_NAME
                    gui.AlwaysOnTop = true
                    gui.Size        = UDim2.new(0, 60, 0, 60)
                    gui.StudsOffset = Vector3.new(0, 2, 0)

                    local border    = Instance.new("Frame", gui)
                    border.Size     = UDim2.new(1, 0, 1, 0)
                    border.BackgroundTransparency = 1
                    border.BorderSizePixel = 0
                    local stroke    = Instance.new("UIStroke", border)
                    stroke.Color    = ESP_COLOR
                    stroke.Thickness = 2

                    local lbl       = Instance.new("TextLabel", gui)
                    lbl.Size        = UDim2.new(1, 0, 0, 18)
                    lbl.Position    = UDim2.new(0, 0, 1, 2)
                    lbl.BackgroundTransparency = 1
                    lbl.Text        = v.Name
                    lbl.TextColor3  = ESP_COLOR
                    lbl.TextSize    = 14
                    lbl.Font        = Enum.Font.Legacy
                    lbl.TextStrokeTransparency = 0.4
                end
            end
        else
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:FindFirstChild(ESP_NAME) then v:FindFirstChild(ESP_NAME):Destroy() end
            end
        end
    end)
end

-- ── PLAYER ESP (белый бокс + палитра цветов) ───────────────
do
    order = order + 1

    local espColor  = Color3.fromRGB(255, 255, 255)
    local espActive = false

    local PALETTE = {
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255,  60,  60),
        Color3.fromRGB(255, 140,  0),
        Color3.fromRGB(255, 230,  0),
        Color3.fromRGB(60,  220,  80),
        Color3.fromRGB(0,   180, 255),
        Color3.fromRGB(50,  100, 255),
        Color3.fromRGB(180,  60, 255),
        Color3.fromRGB(255,  60, 180),
    }

    local PALETTE_H = 34
    local Card = Instance.new("Frame")
    Card.Size             = UDim2.new(1, 0, 0, 58 + 8 + PALETTE_H)
    Card.BackgroundColor3 = THEME.CARD
    Card.BorderSizePixel  = 0
    Card.LayoutOrder      = order
    Card.ZIndex           = 12
    Card.Parent           = Scroll
    addCorner(Card, 12)
    addStroke(Card, THEME.BORDER, 1)

    local IconLbl = Instance.new("TextLabel")
    IconLbl.Size             = UDim2.new(0, 38, 0, 38)
    IconLbl.Position         = UDim2.new(0, 10, 0, 10)
    IconLbl.BackgroundColor3 = THEME.BG
    IconLbl.Text             = "👁"
    IconLbl.TextSize         = 18
    IconLbl.Font             = Enum.Font.GothamBold
    IconLbl.TextColor3       = THEME.ACCENT
    IconLbl.Parent           = Card
    addCorner(IconLbl, 10)

    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size             = UDim2.new(1, -110, 0, 20)
    NameLbl.Position         = UDim2.new(0, 58, 0, 18)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text             = "Player ESP"
    NameLbl.TextColor3       = THEME.TEXT
    NameLbl.TextSize         = 14
    NameLbl.Font             = Enum.Font.GothamSemibold
    NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
    NameLbl.Parent           = Card

    local Badge = Instance.new("TextLabel")
    Badge.Size             = UDim2.new(0, 46, 0, 24)
    Badge.Position         = UDim2.new(1, -56, 0, 10)
    Badge.BackgroundColor3 = THEME.OFF
    Badge.Text             = "OFF"
    Badge.TextColor3       = Color3.new(1,1,1)
    Badge.TextSize         = 11
    Badge.Font             = Enum.Font.GothamBold
    Badge.Parent           = Card
    addCorner(Badge, 6)

    local ColorPreview = Instance.new("Frame")
    ColorPreview.Size             = UDim2.new(0, 18, 0, 18)
    ColorPreview.Position         = UDim2.new(1, -80, 0, 13)
    ColorPreview.BackgroundColor3 = espColor
    ColorPreview.BorderSizePixel  = 0
    ColorPreview.Parent           = Card
    addCorner(ColorPreview, 4)
    addStroke(ColorPreview, Color3.new(1,1,1), 1)

    local Divider = Instance.new("Frame")
    Divider.Size             = UDim2.new(1, -20, 0, 1)
    Divider.Position         = UDim2.new(0, 10, 0, 60)
    Divider.BackgroundColor3 = THEME.BORDER
    Divider.BorderSizePixel  = 0
    Divider.Parent           = Card

    local PaletteRow = Instance.new("Frame")
    PaletteRow.Size             = UDim2.new(1, -20, 0, PALETTE_H)
    PaletteRow.Position         = UDim2.new(0, 10, 0, 68)
    PaletteRow.BackgroundTransparency = 1
    PaletteRow.Parent           = Card

    local dotSize  = 22
    local dotGap   = 6

    for i, col in ipairs(PALETTE) do
        local dot = Instance.new("TextButton")
        dot.Size             = UDim2.new(0, dotSize, 0, dotSize)
        dot.Position         = UDim2.new(0, (i-1)*(dotSize+dotGap), 0.5, -dotSize/2)
        dot.BackgroundColor3 = col
        dot.BorderSizePixel  = 0
        dot.Text             = ""
        dot.Parent           = PaletteRow
        addCorner(dot, dotSize/2)

        local dotStroke = Instance.new("UIStroke", dot)
        dotStroke.Color     = (i == 1) and Color3.new(1,1,1) or Color3.fromRGB(80,80,100)
        dotStroke.Thickness = (i == 1) and 2 or 1

        dot.MouseButton1Click:Connect(function()
            espColor = col
            ColorPreview.BackgroundColor3 = col
            for _, d in pairs(PaletteRow:GetChildren()) do
                local s = d:FindFirstChildOfClass("UIStroke")
                if s then s.Color = Color3.fromRGB(80,80,100); s.Thickness = 1 end
            end
            dotStroke.Color     = Color3.new(1,1,1)
            dotStroke.Thickness = 2
        end)
    end

    local TopBtn = Instance.new("TextButton")
    TopBtn.Size                  = UDim2.new(1, 0, 0, 58)
    TopBtn.BackgroundTransparency = 1
    TopBtn.Text                  = ""
    TopBtn.ZIndex                = 15
    TopBtn.Parent                = Card

    local toggled = false

    local function startESP()
        local camera = Workspace.CurrentCamera
        local player = LocalPlayer
        local Autothickness = true

        local allLines = {}

        local function NewLine()
            local line        = Drawing.new("Line")
            line.Visible      = false
            line.From         = Vector2.new(0, 0)
            line.To           = Vector2.new(1, 1)
            line.Color        = espColor
            line.Thickness    = 2
            line.Transparency = 1
            table.insert(allLines, line)
            return line
        end

        local function setupESP(v)
            local lines = {}
            for i = 1, 12 do lines["line"..i] = NewLine() end
            lines.Tracer       = NewLine()
            lines.Tracer.Color = espColor

            local nameText          = Drawing.new("Text")
            nameText.Visible        = false
            nameText.Text           = v.Name
            nameText.Color          = espColor
            nameText.Size           = 16
            nameText.Font           = Drawing.Fonts.Legacy
            nameText.Outline        = true
            nameText.OutlineColor   = Color3.new(0, 0, 0)
            nameText.Center         = true
            table.insert(allLines, nameText)

            local conn
            conn = RunService.RenderStepped:Connect(function()
                if not espActive then
                    for _, x in pairs(lines) do x.Visible = false end
                    nameText.Visible = false
                    conn:Disconnect()
                    return
                end
                for _, x in pairs(lines) do x.Color = espColor end
                nameText.Color = espColor

                local char = v.Character
                if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart")
                    and v.Name ~= player.Name and char.Humanoid.Health > 0 and char:FindFirstChild("Head") then

                    local _, vis = camera:WorldToViewportPoint(char.HumanoidRootPart.Position)
                    if vis then
                        local Scale = char.Head.Size.Y / 2
                        local Size  = Vector3.new(2, 3, 1.5) * (Scale * 2)
                        local hrp   = char.HumanoidRootPart.CFrame

                        local T1 = camera:WorldToViewportPoint((hrp * CFrame.new(-Size.X, Size.Y, -Size.Z)).p)
                        local T2 = camera:WorldToViewportPoint((hrp * CFrame.new(-Size.X, Size.Y,  Size.Z)).p)
                        local T3 = camera:WorldToViewportPoint((hrp * CFrame.new( Size.X, Size.Y,  Size.Z)).p)
                        local T4 = camera:WorldToViewportPoint((hrp * CFrame.new( Size.X, Size.Y, -Size.Z)).p)
                        local B1 = camera:WorldToViewportPoint((hrp * CFrame.new(-Size.X,-Size.Y, -Size.Z)).p)
                        local B2 = camera:WorldToViewportPoint((hrp * CFrame.new(-Size.X,-Size.Y,  Size.Z)).p)
                        local B3 = camera:WorldToViewportPoint((hrp * CFrame.new( Size.X,-Size.Y,  Size.Z)).p)
                        local B4 = camera:WorldToViewportPoint((hrp * CFrame.new( Size.X,-Size.Y, -Size.Z)).p)

                        local pts = {
                            {T1,T2},{T2,T3},{T3,T4},{T4,T1},
                            {B1,B2},{B2,B3},{B3,B4},{B4,B1},
                            {B1,T1},{B2,T2},{B3,T3},{B4,T4}
                        }
                        for i, p in ipairs(pts) do
                            lines["line"..i].From = Vector2.new(p[1].X, p[1].Y)
                            lines["line"..i].To   = Vector2.new(p[2].X, p[2].Y)
                        end

                        local trace = camera:WorldToViewportPoint((hrp * CFrame.new(0, -Size.Y, 0)).p)
                        lines.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        lines.Tracer.To   = Vector2.new(trace.X, trace.Y)

                        local topCenter = camera:WorldToViewportPoint((hrp * CFrame.new(0, Size.Y, 0)).p)
                        nameText.Position = Vector2.new(topCenter.X, topCenter.Y - 18)
                        nameText.Visible  = true

                        if Autothickness then
                            local lp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if lp then
                                local dist = (lp.Position - char.HumanoidRootPart.Position).Magnitude
                                local th   = math.clamp(1/dist*100, 0.1, 4)
                                for _, x in pairs(lines) do x.Thickness = th end
                            end
                        end

                        for _, x in pairs(lines) do x.Visible = true end
                    else
                        for _, x in pairs(lines) do x.Visible = false end
                        nameText.Visible = false
                    end
                else
                    for _, x in pairs(lines) do x.Visible = false end
                    nameText.Visible = false
                    if not Players:FindFirstChild(v.Name) then conn:Disconnect() end
                end
            end)
        end

        for _, v in pairs(Players:GetChildren()) do
            if v ~= LocalPlayer then setupESP(v) end
        end
        Players.PlayerAdded:Connect(function(v) if espActive then setupESP(v) end end)

        return allLines
    end

    local activeLines = nil

    TopBtn.MouseButton1Click:Connect(function()
        toggled = not toggled
        tween(Card, {BackgroundColor3 = THEME.ACCENT}, 0.08)
        task.delay(0.08, function() tween(Card, {BackgroundColor3 = THEME.CARD}, 0.15) end)

        if toggled then
            Badge.Text             = "ON"
            Badge.BackgroundColor3 = THEME.ON
            espActive              = true
            activeLines            = startESP()
        else
            Badge.Text             = "OFF"
            Badge.BackgroundColor3 = THEME.OFF
            espActive              = false
            if activeLines then
                for _, line in pairs(activeLines) do
                    line.Visible = false
                    line:Remove()
                end
                activeLines = nil
            end
        end
    end)
end

-- ── AURA ──────────────────────────────────────────────────
makeSection("  AURA")

-- ── RELIC & BLACKLIGHT AURA (с ползунком дальности) ─────
do
    order = order + 1

    local AURA_MIN    = 10
    local AURA_MAX    = 500
    local auraRange   = AURA_MIN
    local auraToggled = false
    local activePrompts = {} -- отслеживаем изменённые промпты

    local Card = Instance.new("Frame")
    Card.Size             = UDim2.new(1, 0, 0, 96)
    Card.BackgroundColor3 = THEME.CARD
    Card.BorderSizePixel  = 0
    Card.LayoutOrder      = order
    Card.Parent           = Scroll
    addCorner(Card, 12)
    addStroke(Card, THEME.BORDER, 1)

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size             = UDim2.new(0, 38, 0, 38)
    IconLabel.Position         = UDim2.new(0, 10, 0, 10)
    IconLabel.BackgroundColor3 = THEME.BG
    IconLabel.Text             = "💎"
    IconLabel.TextSize         = 18
    IconLabel.Font             = Enum.Font.GothamBold
    IconLabel.TextColor3       = THEME.ACCENT
    IconLabel.Parent           = Card
    addCorner(IconLabel, 10)

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size             = UDim2.new(1, -110, 0, 20)
    NameLabel.Position         = UDim2.new(0, 58, 0, 18)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text             = "Relic & Blacklight Aura"
    NameLabel.TextColor3       = THEME.TEXT
    NameLabel.TextSize         = 14
    NameLabel.Font             = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment   = Enum.TextXAlignment.Left
    NameLabel.Parent           = Card

    local Badge = Instance.new("TextLabel")
    Badge.Size             = UDim2.new(0, 46, 0, 24)
    Badge.Position         = UDim2.new(1, -56, 0, 10)
    Badge.BackgroundColor3 = THEME.OFF
    Badge.Text             = "OFF"
    Badge.TextColor3       = Color3.new(1,1,1)
    Badge.TextSize         = 11
    Badge.Font             = Enum.Font.GothamBold
    Badge.Parent           = Card
    addCorner(Badge, 6)

    local RangeLabel = Instance.new("TextLabel")
    RangeLabel.Size              = UDim2.new(1, -20, 0, 16)
    RangeLabel.Position          = UDim2.new(0, 10, 0, 52)
    RangeLabel.BackgroundTransparency = 1
    RangeLabel.Text              = "Range: " .. AURA_MIN .. " studs"
    RangeLabel.TextColor3        = THEME.SUBTEXT
    RangeLabel.TextSize          = 11
    RangeLabel.Font              = Enum.Font.Gotham
    RangeLabel.TextXAlignment    = Enum.TextXAlignment.Left
    RangeLabel.Parent            = Card

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size             = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position         = UDim2.new(0, 10, 0, 74)
    SliderTrack.BackgroundColor3 = THEME.BG
    SliderTrack.BorderSizePixel  = 0
    SliderTrack.Parent           = Card
    addCorner(SliderTrack, 3)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size              = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3  = THEME.ACCENT
    SliderFill.BorderSizePixel   = 0
    SliderFill.Parent            = SliderTrack
    addCorner(SliderFill, 3)
    addGradient(SliderFill, THEME.ACCENT, THEME.ACCENT2, 90)

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size              = UDim2.new(0, 18, 0, 18)
    SliderKnob.Position          = UDim2.new(0, -9, 0.5, -9)
    SliderKnob.BackgroundColor3  = Color3.new(1,1,1)
    SliderKnob.BorderSizePixel   = 0
    SliderKnob.Parent            = SliderTrack
    addCorner(SliderKnob, 9)
    addStroke(SliderKnob, THEME.ACCENT, 2)

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size               = UDim2.new(1, 0, 0, 30)
    SliderBtn.Position           = UDim2.new(0, 0, 0, -12)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text               = ""
    SliderBtn.Parent             = SliderTrack

    local Btn = Instance.new("TextButton")
    Btn.Size                 = UDim2.new(1, 0, 0, 48)
    Btn.BackgroundTransparency = 1
    Btn.Text                 = ""
    Btn.Parent               = Card

    local function updateSliderUI(pct)
        SliderFill.Size     = UDim2.new(pct, 0, 1, 0)
        SliderKnob.Position = UDim2.new(pct, -9, 0.5, -9)
        auraRange = math.floor(AURA_MIN + (AURA_MAX - AURA_MIN) * pct)
        RangeLabel.Text = "Range: " .. auraRange .. " studs"
    end

    local function applyRangeToAll()
        -- Реликвии
        pcall(function()
            for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                if v.Name == "Relic" then
                    local prompt = v:FindFirstChild("RelicPrompt")
                    if prompt then
                        saveOriginalDistance(prompt)
                        prompt.MaxActivationDistance = auraRange
                        activePrompts[prompt] = true
                    end
                end
            end
        end)

        -- Blacklight Batteries
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                local name = v.Name:lower()
                if (name:find("blacklight") and name:find("battery")) or name == "blacklightbattery" then
                    local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        saveOriginalDistance(prompt)
                        prompt.MaxActivationDistance = auraRange
                        activePrompts[prompt] = true
                    end
                end
            end
        end)
    end

    local function restoreAllRanges()
        for prompt, _ in pairs(activePrompts) do
            if prompt and prompt.Parent then
                restoreOriginalDistance(prompt)
            end
        end
        activePrompts = {}
    end

    local sliderDragging = false

    local function handleSliderInput(input)
        local trackPos   = SliderTrack.AbsolutePosition
        local trackSize  = SliderTrack.AbsoluteSize
        local relX       = input.Position.X - trackPos.X
        local pct        = math.clamp(relX / trackSize.X, 0, 1)
        updateSliderUI(pct)
        if auraToggled then
            applyRangeToAll()
        end
    end

    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            handleSliderInput(input)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if sliderDragging and (
            input.UserInputType == Enum.UserInputType.Touch or
            input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            handleSliderInput(input)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)

    Btn.MouseButton1Click:Connect(function()
        auraToggled = not auraToggled
        tween(Card, {BackgroundColor3 = THEME.ACCENT}, 0.08)
        task.delay(0.08, function() tween(Card, {BackgroundColor3 = THEME.CARD}, 0.15) end)

        if auraToggled then
            Badge.Text             = "ON"
            Badge.BackgroundColor3 = THEME.ON
            relicOn                = true
            _G.RelicAuraOn         = true
            applyRangeToAll()
        else
            Badge.Text             = "OFF"
            Badge.BackgroundColor3 = THEME.OFF
            relicOn                = false
            _G.RelicAuraOn         = false
            restoreAllRanges()
        end
    end)
end

-- ── ITEM AURA (с ползунком дальности) ────────────────────
do
    order = order + 1

    local AURA_MIN    = 10
    local AURA_MAX    = 500
    local auraRange   = AURA_MIN
    local auraToggled = false
    local activePrompts = {}

    local Card = Instance.new("Frame")
    Card.Size             = UDim2.new(1, 0, 0, 96)
    Card.BackgroundColor3 = THEME.CARD
    Card.BorderSizePixel  = 0
    Card.LayoutOrder      = order
    Card.Parent           = Scroll
    addCorner(Card, 12)
    addStroke(Card, THEME.BORDER, 1)

    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size             = UDim2.new(0, 38, 0, 38)
    IconLabel.Position         = UDim2.new(0, 10, 0, 10)
    IconLabel.BackgroundColor3 = THEME.BG
    IconLabel.Text             = "📦"
    IconLabel.TextSize         = 18
    IconLabel.Font             = Enum.Font.GothamBold
    IconLabel.TextColor3       = THEME.ACCENT
    IconLabel.Parent           = Card
    addCorner(IconLabel, 10)

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size             = UDim2.new(1, -110, 0, 20)
    NameLabel.Position         = UDim2.new(0, 58, 0, 18)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text             = "Item Aura"
    NameLabel.TextColor3       = THEME.TEXT
    NameLabel.TextSize         = 14
    NameLabel.Font             = Enum.Font.GothamSemibold
    NameLabel.TextXAlignment   = Enum.TextXAlignment.Left
    NameLabel.Parent           = Card

    local Badge = Instance.new("TextLabel")
    Badge.Size             = UDim2.new(0, 46, 0, 24)
    Badge.Position         = UDim2.new(1, -56, 0, 10)
    Badge.BackgroundColor3 = THEME.OFF
    Badge.Text             = "OFF"
    Badge.TextColor3       = Color3.new(1,1,1)
    Badge.TextSize         = 11
    Badge.Font             = Enum.Font.GothamBold
    Badge.Parent           = Card
    addCorner(Badge, 6)

    local RangeLabel = Instance.new("TextLabel")
    RangeLabel.Size              = UDim2.new(1, -20, 0, 16)
    RangeLabel.Position          = UDim2.new(0, 10, 0, 52)
    RangeLabel.BackgroundTransparency = 1
    RangeLabel.Text              = "Range: " .. AURA_MIN .. " studs"
    RangeLabel.TextColor3        = THEME.SUBTEXT
    RangeLabel.TextSize          = 11
    RangeLabel.Font              = Enum.Font.Gotham
    RangeLabel.TextXAlignment    = Enum.TextXAlignment.Left
    RangeLabel.Parent            = Card

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size             = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position         = UDim2.new(0, 10, 0, 74)
    SliderTrack.BackgroundColor3 = THEME.BG
    SliderTrack.BorderSizePixel  = 0
    SliderTrack.Parent           = Card
    addCorner(SliderTrack, 3)

    local SliderFill = Instance.new("Frame")
    SliderFill.Size              = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3  = THEME.ACCENT
    SliderFill.BorderSizePixel   = 0
    SliderFill.Parent            = SliderTrack
    addCorner(SliderFill, 3)
    addGradient(SliderFill, THEME.ACCENT, THEME.ACCENT2, 90)

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size              = UDim2.new(0, 18, 0, 18)
    SliderKnob.Position          = UDim2.new(0, -9, 0.5, -9)
    SliderKnob.BackgroundColor3  = Color3.new(1,1,1)
    SliderKnob.BorderSizePixel   = 0
    SliderKnob.Parent            = SliderTrack
    addCorner(SliderKnob, 9)
    addStroke(SliderKnob, THEME.ACCENT, 2)

    local SliderBtn = Instance.new("TextButton")
    SliderBtn.Size               = UDim2.new(1, 0, 0, 30)
    SliderBtn.Position           = UDim2.new(0, 0, 0, -12)
    SliderBtn.BackgroundTransparency = 1
    SliderBtn.Text               = ""
    SliderBtn.Parent             = SliderTrack

    local Btn = Instance.new("TextButton")
    Btn.Size                 = UDim2.new(1, 0, 0, 48)
    Btn.BackgroundTransparency = 1
    Btn.Text                 = ""
    Btn.Parent               = Card

    local function updateSliderUI(pct)
        SliderFill.Size     = UDim2.new(pct, 0, 1, 0)
        SliderKnob.Position = UDim2.new(pct, -9, 0.5, -9)
        auraRange = math.floor(AURA_MIN + (AURA_MAX - AURA_MIN) * pct)
        RangeLabel.Text = "Range: " .. auraRange .. " studs"
    end

    local function applyRangeToAll()
        -- BonusItems
        pcall(function()
            for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
                if v.ClassName == "ProximityPrompt" then
                    saveOriginalDistance(v)
                    v.MaxActivationDistance = auraRange
                    activePrompts[v] = true
                end
            end
        end)

        -- Murch Case
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower() == "murch case" or v.Name:lower() == "murchcase" then
                    local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        saveOriginalDistance(prompt)
                        prompt.MaxActivationDistance = auraRange
                        activePrompts[prompt] = true
                    end
                end
            end
        end)

        -- Blacklight Case
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower() == "blacklight case" or v.Name:lower() == "blacklightcase" then
                    local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        saveOriginalDistance(prompt)
                        prompt.MaxActivationDistance = auraRange
                        activePrompts[prompt] = true
                    end
                end
            end
        end)

        -- Aila Case
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name:lower() == "aila case" or v.Name:lower() == "ailacase" then
                    local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        saveOriginalDistance(prompt)
                        prompt.MaxActivationDistance = auraRange
                        activePrompts[prompt] = true
                    end
                end
            end
        end)

        -- Blacklight Batteries
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                local name = v.Name:lower()
                if (name:find("blacklight") and name:find("battery")) or name == "blacklightbattery" then
                    local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        saveOriginalDistance(prompt)
                        prompt.MaxActivationDistance = auraRange
                        activePrompts[prompt] = true
                    end
                end
            end
        end)

        -- Обычные батарейки
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                local name = v.Name:lower()
                if (name:find("battery") and not name:find("blacklight")) or name == "batteries" then
                    local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        saveOriginalDistance(prompt)
                        prompt.MaxActivationDistance = auraRange
                        activePrompts[prompt] = true
                    end
                end
            end
        end)
    end

    local function restoreAllRanges()
        for prompt, _ in pairs(activePrompts) do
            if prompt and prompt.Parent then
                restoreOriginalDistance(prompt)
            end
        end
        activePrompts = {}
    end

    local sliderDragging = false

    local function handleSliderInput(input)
        local trackPos   = SliderTrack.AbsolutePosition
        local trackSize  = SliderTrack.AbsoluteSize
        local relX       = input.Position.X - trackPos.X
        local pct        = math.clamp(relX / trackSize.X, 0, 1)
        updateSliderUI(pct)
        if auraToggled then
            applyRangeToAll()
        end
    end

    SliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            handleSliderInput(input)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if sliderDragging and (
            input.UserInputType == Enum.UserInputType.Touch or
            input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            handleSliderInput(input)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)

    Btn.MouseButton1Click:Connect(function()
        auraToggled = not auraToggled
        tween(Card, {BackgroundColor3 = THEME.ACCENT}, 0.08)
        task.delay(0.08, function() tween(Card, {BackgroundColor3 = THEME.CARD}, 0.15) end)

        if auraToggled then
            Badge.Text             = "ON"
            Badge.BackgroundColor3 = THEME.ON
            taskOn                 = true
            _G.TaskAuraOn          = true
            applyRangeToAll()
        else
            Badge.Text             = "OFF"
            Badge.BackgroundColor3 = THEME.OFF
            taskOn                 = false
            _G.TaskAuraOn          = false
            restoreAllRanges()
        end
    end)
end

-- ── MISC ──────────────────────────────────────────────────
makeSection("  MISC")

makeButton("Insta Build", "🔨", false, function()
    for i = 1, 100 do
        for _, v in pairs(Workspace.Misc:GetDescendants()) do
            if v.Name == "BarricadePrompt" then
                fireproximityprompt(v)
            end
        end
    end
end)

makeButton("Full Bright", "☀", true, function(state)
    fullBrightOn = state

    if state then
        if savedLighting == nil then
            savedLighting = {
                Ambient              = Lighting.Ambient,
                OutdoorAmbient       = Lighting.OutdoorAmbient,
                Brightness           = Lighting.Brightness,
                ExposureCompensation = Lighting.ExposureCompensation,
                ClockTime            = Lighting.ClockTime,
                FogEnd               = Lighting.FogEnd,
            }
            savedLighting.effects = {}
            for _, name in ipairs({"FlareColorCorrection","BasicColorCorrection","PlayerBlur",
                "DefaultColorCorrection","DefaultBloom","DefaultSunRays","DefaultBlur"}) do
                local obj = Lighting:FindFirstChild(name)
                if obj then savedLighting.effects[name] = obj.Enabled end
            end
            pcall(function()
                savedLighting.AtmosphereEnabled = Lighting.Atmosphere.Enabled
            end)
        end

        for _, name in ipairs({"FlareColorCorrection","BasicColorCorrection","PlayerBlur",
            "DefaultColorCorrection","DefaultBloom","DefaultSunRays","DefaultBlur"}) do
            local obj = Lighting:FindFirstChild(name)
            if obj then obj.Enabled = false end
        end
        Lighting.Ambient               = Color3.fromRGB(236, 236, 236)
        Lighting.OutdoorAmbient        = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness            = 3
        Lighting.ExposureCompensation  = 0.25
        Lighting.ClockTime             = 14.5
        Lighting.FogEnd                = 10000000
        pcall(function() Lighting.Atmosphere.Enabled = false end)
    else
        if savedLighting then
            Lighting.Ambient               = savedLighting.Ambient
            Lighting.OutdoorAmbient        = savedLighting.OutdoorAmbient
            Lighting.Brightness            = savedLighting.Brightness
            Lighting.ExposureCompensation  = savedLighting.ExposureCompensation
            Lighting.ClockTime             = savedLighting.ClockTime
            Lighting.FogEnd                = savedLighting.FogEnd
            for _, name in ipairs({"FlareColorCorrection","BasicColorCorrection","PlayerBlur",
                "DefaultColorCorrection","DefaultBloom","DefaultSunRays","DefaultBlur"}) do
                local obj = Lighting:FindFirstChild(name)
                if obj and savedLighting.effects[name] ~= nil then
                    obj.Enabled = savedLighting.effects[name]
                end
            end
            pcall(function()
                if savedLighting.AtmosphereEnabled ~= nil then
                    Lighting.Atmosphere.Enabled = savedLighting.AtmosphereEnabled
                end
            end)
        end
    end
end)

-- ── ITEM FARM (телепорт + активация) ──────────────────────
makeButton("Item Farm", "🎯", true, function(state)
    cool = state
    _G.FarmOn = state
    if state then
        coroutine.wrap(function()
            local speed       = 6
            local tweenInfo2  = TweenInfo.new(speed, Enum.EasingStyle.Linear)
            while _G.FarmOn and task.wait(0.1) do
                pcall(function()
                    -- Собираем все позиции предметов
                    local targets = {}

                    -- Relics
                    for _, v in pairs(Workspace.TempMap.Main.Relics:GetChildren()) do
                        if v.Name == "Relic" and v:FindFirstChild("RelicPrompt") then
                            table.insert(targets, {pos = v.Position, prompt = v.RelicPrompt})
                        end
                    end

                    -- Murch Case
                    for _, v in pairs(workspace:GetDescendants()) do
                        if (v.Name:lower() == "murch case" or v.Name:lower() == "murchcase") then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                table.insert(targets, {pos = v.Position, prompt = prompt})
                            end
                        end
                    end

                    -- Blacklight Case
                    for _, v in pairs(workspace:GetDescendants()) do
                        if (v.Name:lower() == "blacklight case" or v.Name:lower() == "blacklightcase") then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                table.insert(targets, {pos = v.Position, prompt = prompt})
                            end
                        end
                    end

                    -- Aila Case
                    for _, v in pairs(workspace:GetDescendants()) do
                        if (v.Name:lower() == "aila case" or v.Name:lower() == "ailacase") then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                table.insert(targets, {pos = v.Position, prompt = prompt})
                            end
                        end
                    end

                    -- Blacklight Batteries
                    for _, v in pairs(workspace:GetDescendants()) do
                        local name = v.Name:lower()
                        if (name:find("blacklight") and name:find("battery")) or name == "blacklightbattery" then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                table.insert(targets, {pos = v.Position, prompt = prompt})
                            end
                        end
                    end

                    -- BonusItems (Task предметы)
                    for _, v in pairs(Workspace.TempMap.Main.BonusItems:GetDescendants()) do
                        if v.ClassName == "ProximityPrompt" then
                            local parent = v.Parent
                            if parent and parent.Position then
                                table.insert(targets, {pos = parent.Position, prompt = v})
                            end
                        end
                    end

                    -- Обычные батарейки
                    for _, v in pairs(workspace:GetDescendants()) do
                        local name = v.Name:lower()
                        if (name:find("battery") and not name:find("blacklight")) or name == "batteries" then
                            local prompt = v:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                table.insert(targets, {pos = v.Position, prompt = prompt})
                            end
                        end
                    end

                    -- Телепортируемся и активируем каждый предмет
                    for _, target in pairs(targets) do
                        if not _G.FarmOn then break end
                        local tw = TweenService:Create(
                            LocalPlayer.Character.HumanoidRootPart,
                            tweenInfo2,
                            {CFrame = CFrame.new(target.pos)}
                        )
                        tw:Play()
                        task.wait(1)
                        fireproximityprompt(target.prompt)
                        task.wait(0.5)
                    end
                end)
            end
        end)()
    end
end)

-- ============================================================
--  MOVEMENT
-- ============================================================
makeSection("  MOVEMENT")

-- ── NOCLIP ────────────────────────────────────────────────
do
    local noclipOn   = false
    local noclipConn = nil

    makeButton("Noclip", "👁‍🗨", true, function(state)
        noclipOn = state
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end)
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)
end

-- ── FLY ───────────────────────────────────────────────────
do
    local FLY_MIN     = 10
    local FLY_MAX     = 200
    local FLY_DEFAULT = 50
    local flyOn       = false
    local flyConn     = nil

    local flyCard = makeSliderCard("Fly Speed", "🪁", FLY_MIN, FLY_MAX, FLY_DEFAULT,
        function(state, val)
            flyOn = state
            local char = LocalPlayer.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            if state then
                pcall(function()
                    if hrp:FindFirstChild("STN_FlyVel")  then hrp.STN_FlyVel:Destroy()  end
                    if hrp:FindFirstChild("STN_FlyGyro") then hrp.STN_FlyGyro:Destroy() end
                end)

                local bv      = Instance.new("BodyVelocity", hrp)
                bv.Name       = "STN_FlyVel"
                bv.Velocity   = Vector3.new(0, 0, 0)
                bv.MaxForce   = Vector3.new(1e5, 1e5, 1e5)

                local bg      = Instance.new("BodyGyro", hrp)
                bg.Name       = "STN_FlyGyro"
                bg.MaxTorque  = Vector3.new(1e5, 1e5, 1e5)
                bg.P          = 1e4
                bg.CFrame     = hrp.CFrame

                hum.PlatformStand = true

                flyConn = RunService.RenderStepped:Connect(function()
                    local c2   = LocalPlayer.Character
                    local hrp2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                    local bv2  = hrp2 and hrp2:FindFirstChild("STN_FlyVel")
                    local bg2  = hrp2 and hrp2:FindFirstChild("STN_FlyGyro")
                    if not (hrp2 and bv2 and bg2) then return end

                    local cam   = Workspace.CurrentCamera
                    local speed = val
                    local cf    = cam.CFrame
                    local dir   = Vector3.new(0, 0, 0)

                    local moveDir = hum and hum.MoveDirection or Vector3.new(0,0,0)
                    if moveDir.Magnitude > 0 then
                        dir = cf.LookVector * moveDir.Z * (-1) + cf.RightVector * moveDir.X
                        dir = Vector3.new(dir.X, 0, dir.Z).Unit
                    end

                    bv2.Velocity = dir * speed + Vector3.new(0, 0, 0)
                    bv2.Velocity = Vector3.new(bv2.Velocity.X, 0, bv2.Velocity.Z)
                    bg2.CFrame   = CFrame.new(hrp2.Position, hrp2.Position + cf.LookVector)
                end)
            else
                if flyConn then flyConn:Disconnect(); flyConn = nil end
                local c2   = LocalPlayer.Character
                local hrp2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                if hrp2 then
                    pcall(function()
                        if hrp2:FindFirstChild("STN_FlyVel")  then hrp2.STN_FlyVel:Destroy()  end
                        if hrp2:FindFirstChild("STN_FlyGyro") then hrp2.STN_FlyGyro:Destroy() end
                    end)
                end
                local hum2 = c2 and c2:FindFirstChild("Humanoid")
                if hum2 then hum2.PlatformStand = false end
            end
        end,
        function(val) end
    )
end

-- ── JUMP POWER ────────────────────────────────────────────
do
    local JUMP_MIN     = 7
    local JUMP_MAX     = 200
    local JUMP_DEFAULT = 7
    local jumpOn       = false
    local savedJump    = nil

    makeSliderCard("Jump Power", "⬆", JUMP_MIN, JUMP_MAX, JUMP_DEFAULT,
        function(state, val)
            jumpOn = state
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            if not hum then return end

            if state then
                if savedJump == nil then savedJump = hum.JumpPower end
                hum.JumpPower = val
            else
                if savedJump ~= nil then
                    hum.JumpPower = savedJump
                    savedJump = nil
                end
            end
        end,
        function(val)
            if not jumpOn then return end
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            if hum then hum.JumpPower = val end
        end
    )
end

-- ── WALK SPEED ────────────────────────────────────────────
do
    local WS_MIN     = 1
    local WS_MAX     = 100
    local WS_DEFAULT = 16
    local wsOn       = false
    local wsConn     = nil
    local savedWS    = nil

    makeSliderCard("Walk Speed", "🏃", WS_MIN, WS_MAX, WS_DEFAULT,
        function(state, val)
            wsOn = state
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")

            if state then
                if savedWS == nil and hum then savedWS = hum.WalkSpeed end
                wsConn = RunService.Heartbeat:Connect(function()
                    local c2  = LocalPlayer.Character
                    local h2  = c2 and c2:FindFirstChild("Humanoid")
                    if h2 and h2.WalkSpeed ~= val then
                        h2.WalkSpeed = val
                    end
                end)
                if hum then hum.WalkSpeed = val end
            else
                if wsConn then wsConn:Disconnect(); wsConn = nil end
                local c2 = LocalPlayer.Character
                local h2 = c2 and c2:FindFirstChild("Humanoid")
                if h2 then
                    h2.WalkSpeed = savedWS or WS_DEFAULT
                end
                savedWS = nil
            end
        end,
        function(val)
            if not wsOn then return end
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    )
end

-- ============================================================
--  ФАБРИКА ДЛЯ SLIDER CARD (чтобы не ломать старый код)
-- ============================================================
local function makeSliderCard(label, icon, minVal, maxVal, defaultVal, onToggle, onSlide)
    order = order + 1

    local currentVal = defaultVal
    local toggled    = false

    local Card = Instance.new("Frame")
    Card.Size             = UDim2.new(1, 0, 0, 96)
    Card.BackgroundColor3 = THEME.CARD
    Card.BorderSizePixel  = 0
    Card.LayoutOrder      = order
    Card.Parent           = Scroll
    addCorner(Card, 12)
    addStroke(Card, THEME.BORDER, 1)

    local IconLbl = Instance.new("TextLabel")
    IconLbl.Size             = UDim2.new(0, 38, 0, 38)
    IconLbl.Position         = UDim2.new(0, 10, 0, 10)
    IconLbl.BackgroundColor3 = THEME.BG
    IconLbl.Text             = icon
    IconLbl.TextSize         = 18
    IconLbl.Font             = Enum.Font.GothamBold
    IconLbl.TextColor3       = THEME.ACCENT
    IconLbl.Parent           = Card
    addCorner(IconLbl, 10)

    local NameLbl = Instance.new("TextLabel")
    NameLbl.Size             = UDim2.new(1, -110, 0, 20)
    NameLbl.Position         = UDim2.new(0, 58, 0, 18)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Text             = label
    NameLbl.TextColor3       = THEME.TEXT
    NameLbl.TextSize         = 14
    NameLbl.Font             = Enum.Font.GothamSemibold
    NameLbl.TextXAlignment   = Enum.TextXAlignment.Left
    NameLbl.Parent           = Card

    local Badge = Instance.new("TextLabel")
    Badge.Size             = UDim2.new(0, 46, 0, 24)
    Badge.Position         = UDim2.new(1, -56, 0, 10)
    Badge.BackgroundColor3 = THEME.OFF
    Badge.Text             = "OFF"
    Badge.TextColor3       = Color3.new(1,1,1)
    Badge.TextSize         = 11
    Badge.Font             = Enum.Font.GothamBold
    Badge.Parent           = Card
    addCorner(Badge, 6)

    local ValLbl = Instance.new("TextLabel")
    ValLbl.Size              = UDim2.new(1, -20, 0, 16)
    ValLbl.Position          = UDim2.new(0, 10, 0, 52)
    ValLbl.BackgroundTransparency = 1
    ValLbl.Text              = label .. ": " .. tostring(defaultVal)
    ValLbl.TextColor3        = THEME.SUBTEXT
    ValLbl.TextSize          = 11
    ValLbl.Font              = Enum.Font.Gotham
    ValLbl.TextXAlignment    = Enum.TextXAlignment.Left
    ValLbl.Parent            = Card

    local Track = Instance.new("Frame")
    Track.Size             = UDim2.new(1, -20, 0, 6)
    Track.Position         = UDim2.new(0, 10, 0, 74)
    Track.BackgroundColor3 = THEME.BG
    Track.BorderSizePixel  = 0
    Track.Parent           = Card
    addCorner(Track, 3)

    local Fill = Instance.new("Frame")
    Fill.Size             = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = THEME.ACCENT
    Fill.BorderSizePixel  = 0
    Fill.Parent           = Track
    addCorner(Fill, 3)
    addGradient(Fill, THEME.ACCENT, THEME.ACCENT2, 90)

    local Knob = Instance.new("Frame")
    Knob.Size             = UDim2.new(0, 18, 0, 18)
    Knob.Position         = UDim2.new(0, -9, 0.5, -9)
    Knob.BackgroundColor3 = Color3.new(1,1,1)
    Knob.BorderSizePixel  = 0
    Knob.Parent           = Track
    addCorner(Knob, 9)
    addStroke(Knob, THEME.ACCENT, 2)

    local initPct = (defaultVal - minVal) / (maxVal - minVal)
    Fill.Size     = UDim2.new(initPct, 0, 1, 0)
    Knob.Position = UDim2.new(initPct, -9, 0.5, -9)

    local SliderHit = Instance.new("TextButton")
    SliderHit.Size               = UDim2.new(1, 0, 0, 30)
    SliderHit.Position           = UDim2.new(0, 0, 0, -12)
    SliderHit.BackgroundTransparency = 1
    SliderHit.Text               = ""
    SliderHit.Parent             = Track

    local TopHit = Instance.new("TextButton")
    TopHit.Size                  = UDim2.new(1, 0, 0, 48)
    TopHit.BackgroundTransparency = 1
    TopHit.Text                  = ""
    TopHit.Parent                = Card

    local UIS = game:GetService("UserInputService")
    local sliderDrag = false

    local function applySlider(inputPos)
        local trackPos  = Track.AbsolutePosition
        local trackSize = Track.AbsoluteSize
        local pct       = math.clamp((inputPos.X - trackPos.X) / trackSize.X, 0, 1)
        currentVal      = math.floor(minVal + (maxVal - minVal) * pct)
        Fill.Size       = UDim2.new(pct, 0, 1, 0)
        Knob.Position   = UDim2.new(pct, -9, 0.5, -9)
        ValLbl.Text     = label .. ": " .. tostring(currentVal)
        if toggled and onSlide then onSlide(currentVal) end
    end

    SliderHit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDrag = true
            applySlider(inp.Position)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if sliderDrag and (
            inp.UserInputType == Enum.UserInputType.Touch or
            inp.UserInputType == Enum.UserInputType.MouseMovement
        ) then applySlider(inp.Position) end
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDrag = false
        end
    end)

    TopHit.MouseButton1Click:Connect(function()
        toggled = not toggled
        tween(Card, {BackgroundColor3 = THEME.ACCENT}, 0.08)
        task.delay(0.08, function() tween(Card, {BackgroundColor3 = THEME.CARD}, 0.15) end)
        if toggled then
            Badge.Text             = "ON"
            Badge.BackgroundColor3 = THEME.ON
        else
            Badge.Text             = "OFF"
            Badge.BackgroundColor3 = THEME.OFF
        end
        onToggle(toggled, currentVal)
    end)

    return { card = Card, badge = Badge, getValue = function() return currentVal end }
end

-- ============================================================
--  FAB TOGGLE — show/hide panel
-- ============================================================
FAB.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    if guiOpen then
        Panel.Visible = true
        tween(Panel, {Position = UDim2.new(0, 78, 0.5, -260)}, 0.25)
        FAB.Text = "☰"
    else
        tween(Panel, {Position = UDim2.new(0, 78, 0.5, -240)}, 0.15)
        task.delay(0.15, function() Panel.Visible = false end)
        FAB.Text = "✦"
    end
end)

-- ============================================================
--  DRAG SUPPORT (touch + mouse)
-- ============================================================
local dragging, dragInput, dragStart, startPos

local function onDragInput(input)
    if not dragging then return end
    local delta = input.Position - dragStart
    Panel.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = Panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMove then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput then onDragInput(input) end
end)
```

