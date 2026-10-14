-- ============================================================
-- RIO PREMIUM UI + LOGICA  (ARCHIVO UNICO)
-- Pega TODO esto en un solo script y ejecutalo.
-- ============================================================

-- ===== SERVICIOS =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local UserInputService = UIS
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local newcclosure = (type(newcclosure) == "function") and newcclosure or function(f) return f end

if not LocalPlayer then
    warn("Rio: LocalPlayer no disponible.")
    return
end

-- ===== VARIABLES COMPARTIDAS =====
-- La UI las modifica, la logica las lee.
getgenv().silentAimVars = getgenv().silentAimVars or {
    enabled = false,
    hitChance = 100,
    radius = 15,
    manipulation = false,
    closestPart = true,
    visualize = false,
    showFov = true,
    targeting = { selectedTargetPart = "Head" },
}
getgenv().ragebotVars = getgenv().ragebotVars or { enabled = false, fov = 999 }
getgenv().aimbotVars = getgenv().aimbotVars or { enabled = false, smoothing = 50, fov = 15 }
getgenv().characterVars = getgenv().characterVars or {
    voidSpam = false,
    flyToggle = false,
    noclipToggle = false,
    infiniteJump = false,
    movementSpeed = 16,
}
getgenv().espVars = getgenv().espVars or {
    enabled = false, boxes = false, skeleton = false, healthbar = false,
    names = false, distance = false, color = Color3.fromRGB(0, 255, 0),
}

local silentAimVars = getgenv().silentAimVars
local ragebotVars = getgenv().ragebotVars
local aimbotVars = getgenv().aimbotVars
local characterVars = getgenv().characterVars
local espVars = getgenv().espVars

-- ============================================================
-- INTERFAZ
-- ============================================================
local ACCENT = Color3.fromRGB(105, 48, 220)
local BG = Color3.fromRGB(17, 17, 18)
local PANEL = Color3.fromRGB(25, 25, 27)
local INNER = Color3.fromRGB(31, 31, 34)
local WHITE = Color3.fromRGB(225, 225, 228)
local MUTED = Color3.fromRGB(150, 150, 155)
local OFF = Color3.fromRGB(36, 36, 39)

local toggleKey = Enum.KeyCode.RightShift
local moveEnabled = false
local draggingWindow = false
local listeningKey = false
local selectedTab = "main"
local accentTargets = {}
local accentRefreshers = {}
local pages = {}
local tabButtons = {}
local columns = {}

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local coreGui
pcall(function() coreGui = game:GetService("CoreGui") end)

local parent = coreGui or playerGui

for _, container in ipairs({playerGui, coreGui}) do
    if container then
        pcall(function()
            local old = container:FindFirstChild("RioPremiumUI")
            if old then old:Destroy() end
        end)
    end
end

local function create(className, properties, parentObject)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parentObject
    return object
end

local function registerAccent(object, property)
    table.insert(accentTargets, { object = object, property = property })
end

local function setAccentColor(color)
    ACCENT = color
    for _, item in ipairs(accentTargets) do
        pcall(function() item.object[item.property] = ACCENT end)
    end
    for _, refresh in ipairs(accentRefreshers) do
        pcall(refresh)
    end
end

local gui = create("ScreenGui", {
    Name = "RioPremiumUI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, parent)

local main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(640, 760),
    BackgroundColor3 = BG,
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(45, 45, 48),
}, gui)

create("UISizeConstraint", { MinSize = Vector2.new(580, 620), MaxSize = Vector2.new(680, 800) }, main)

local floatButton = create("TextButton", {
    Name = "RioRageFloat",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(0.5, -330, 0.5, 0),
    Size = UDim2.fromOffset(62, 62),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
    Text = "RioRage",
    TextColor3 = Color3.fromRGB(0, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    ZIndex = 50,
}, gui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, floatButton)
local floatStroke = create("UIStroke", { Color = Color3.fromRGB(30, 30, 30), Thickness = 1.5 }, floatButton)
registerAccent(floatStroke, "Color")

local draggingFloat, movedFloat, pointerStart, buttonStart = false, false, nil, nil

floatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingFloat, movedFloat = true, false
        pointerStart = input.Position
        buttonStart = floatButton.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not draggingFloat then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - pointerStart
        if delta.Magnitude > 5 then movedFloat = true end
        if movedFloat then
            floatButton.Position = UDim2.new(
                buttonStart.X.Scale, buttonStart.X.Offset + delta.X,
                buttonStart.Y.Scale, buttonStart.Y.Offset + delta.Y)
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if not draggingFloat then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingFloat = false
        if not movedFloat and gui.Parent then
            main.Visible = not main.Visible
        end
    end
end)

local moveButton = create("TextButton", {
    Name = "RioMoveToggle",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(0.5, -330, 0.5, 70),
    Size = UDim2.fromOffset(62, 62),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
    Text = "ON",
    TextColor3 = Color3.fromRGB(0, 0, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    ZIndex = 50,
}, gui)
create("UICorner", { CornerRadius = UDim.new(1, 0) }, moveButton)
local moveStroke = create("UIStroke", { Color = Color3.fromRGB(30, 30, 30), Thickness = 1.5 }, moveButton)
registerAccent(moveStroke, "Color")

local moveButtonDragging, moveButtonMoved, moveButtonStart, moveButtonStartPosition, moveButtonTouch =
    false, false, nil, nil, nil

moveButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        moveButtonDragging, moveButtonMoved = true, false
        moveButtonStart = input.Position
        moveButtonStartPosition = moveButton.Position
        moveButtonTouch = (input.UserInputType == Enum.UserInputType.Touch) and input or nil
    end
end)

UIS.InputChanged:Connect(function(input)
    if not moveButtonDragging then return end
    local validInput = moveButtonTouch and (input == moveButtonTouch)
        or (input.UserInputType == Enum.UserInputType.MouseMovement)
    if not validInput then return end
    local delta = input.Position - moveButtonStart
    if delta.Magnitude > 5 then moveButtonMoved = true end
    if moveButtonMoved then
        moveButton.Position = UDim2.new(
            moveButtonStartPosition.X.Scale, moveButtonStartPosition.X.Offset + delta.X,
            moveButtonStartPosition.Y.Scale, moveButtonStartPosition.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if not moveButtonDragging then return end
    local finished = moveButtonTouch and (input == moveButtonTouch)
        or (input.UserInputType == Enum.UserInputType.MouseButton1)
    if not finished then return end
    moveButtonDragging, moveButtonTouch = false, nil
    if not moveButtonMoved then
        moveEnabled = not moveEnabled
        if moveEnabled then moveButton.Text = "OFF"
        else moveButton.Text = "ON"; draggingWindow = false end
    end
end)

local outline = create("UIStroke", { Color = ACCENT, Thickness = 1 }, main)
registerAccent(outline, "Color")

local header = create("Frame", { Name = "Header", Size = UDim2.new(1, 0, 0, 43), BackgroundColor3 = PANEL, BorderSizePixel = 0 }, main)

local dragStart, startPos, dragInput

header.InputBegan:Connect(function(input)
    if not moveEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        draggingWindow = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingWindow = false end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)

UIS.InputChanged:Connect(function(input)
    if not moveEnabled or not draggingWindow or input ~= dragInput then return end
    local delta = input.Position - dragStart
    main.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)

create("TextLabel", {
    Name = "RioRageTitle", AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.fromOffset(260, 32),
    BackgroundTransparency = 1, Text = "RioRage.win",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 20, TextXAlignment = Enum.TextXAlignment.Center,
}, header)

create("TextLabel", {
    Name = "GameLabel", AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -50, 0.5, 0), Size = UDim2.fromOffset(100, 32),
    BackgroundTransparency = 1, Text = "Rivals",
    TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold,
    TextSize = 20, TextXAlignment = Enum.TextXAlignment.Right,
}, header)

local close = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -9, 0.5, 0),
    Size = UDim2.fromOffset(33, 29), BackgroundColor3 = Color3.fromRGB(90, 28, 35),
    BorderSizePixel = 0, Text = "X", TextColor3 = WHITE, Font = Enum.Font.Code, TextSize = 18,
}, header)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local nav = create("Frame", { Position = UDim2.fromOffset(8, 49), Size = UDim2.new(1, -16, 0, 39), BackgroundTransparency = 1 }, main)
create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder,
}, nav)

local tabNames = { "main", "world", "esp", "visuals", "character", "misc", "settings" }

local body = create("Frame", { Position = UDim2.fromOffset(8, 96), Size = UDim2.new(1, -16, 1, -104), BackgroundTransparency = 1 }, main)

local function makeColumns(page)
    local left = create("ScrollingFrame", {
        Name = "LeftColumn", Size = UDim2.new(0.5, -5, 1, 0), BackgroundTransparency = 1,
        ScrollBarThickness = 4, ScrollBarImageColor3 = ACCENT,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, page)
    local right = create("ScrollingFrame", {
        Name = "RightColumn", Position = UDim2.new(0.5, 5, 0, 0), Size = UDim2.new(0.5, -5, 1, 0),
        BackgroundTransparency = 1, ScrollBarThickness = 4, ScrollBarImageColor3 = ACCENT,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, page)
    registerAccent(left, "ScrollBarImageColor3")
    registerAccent(right, "ScrollBarImageColor3")
    for _, column in ipairs({left, right}) do
        create("UIListLayout", { Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder }, column)
    end
    return left, right
end

for index, name in ipairs(tabNames) do
    local tab = create("TextButton", {
        Name = name .. "Tab", LayoutOrder = index, Size = UDim2.new(1 / #tabNames, -5, 1, 0),
        BackgroundColor3 = OFF, BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(48, 48, 52),
        Text = name, TextColor3 = WHITE, Font = Enum.Font.Code, TextSize = 17,
    }, nav)
    local page = create("Frame", { Name = name .. "Page", Visible = name == "main", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, body)
    local left, right = makeColumns(page)
    tabButtons[name], pages[name], columns[name] = tab, page, {left, right}
    tab.MouseButton1Click:Connect(function()
        selectedTab = name
        for key, otherPage in pairs(pages) do otherPage.Visible = key == selectedTab end
        for key, otherTab in pairs(tabButtons) do
            otherTab.BackgroundColor3 = key == selectedTab and ACCENT or OFF
            otherTab.TextColor3 = key == selectedTab and WHITE or MUTED
        end
    end)
end

table.insert(accentRefreshers, function()
    for key, tab in pairs(tabButtons) do
        tab.BackgroundColor3 = key == selectedTab and ACCENT or OFF
        tab.TextColor3 = key == selectedTab and WHITE or MUTED
    end
end)

local function section(parentObject, name, height)
    local panel = create("Frame", {
        Name = name, Size = UDim2.new(1, -5, 0, height), BackgroundColor3 = PANEL,
        BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(48, 48, 52),
    }, parentObject)
    local line = create("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = ACCENT }, panel)
    registerAccent(line, "BackgroundColor3")
    create("TextLabel", {
        Position = UDim2.fromOffset(10, 3), Size = UDim2.new(1, -20, 0, 27),
        BackgroundTransparency = 1, Text = name, TextColor3 = WHITE,
        Font = Enum.Font.Code, TextSize = 17, TextXAlignment = Enum.TextXAlignment.Center,
    }, panel)
    local content = create("Frame", { Position = UDim2.fromOffset(8, 34), Size = UDim2.new(1, -16, 1, -41), BackgroundTransparency = 1 }, panel)
    create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, content)
    return content
end

-- Checkbox con CALLBACK (conecta a las variables)
local function checkbox(parentObject, label, default, callback)
    local state = default == true
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 27), BackgroundTransparency = 1 }, parentObject)
    local box = create("TextButton", {
        Position = UDim2.fromOffset(0, 4), Size = UDim2.fromOffset(19, 19),
        BackgroundColor3 = state and ACCENT or OFF, BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(50, 50, 54), Text = state and "✓" or "",
        TextColor3 = WHITE, Font = Enum.Font.Code, TextSize = 15,
    }, row)
    local labelText = create("TextLabel", {
        Position = UDim2.fromOffset(27, 0), Size = UDim2.new(1, -29, 1, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = WHITE,
        Font = Enum.Font.Code, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local function refresh()
        box.BackgroundColor3 = state and ACCENT or OFF
        box.Text = state and "✓" or ""
        if callback then callback(state) end
    end
    table.insert(accentRefreshers, function()
        box.BackgroundColor3 = state and ACCENT or OFF
    end)

    box.MouseButton1Click:Connect(function() state = not state; refresh() end)
    labelText.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            state = not state; refresh()
        end
    end)
    if callback then callback(state) end
end

-- Slider con CALLBACK
local function slider(parentObject, label, minValue, maxValue, initial, suffix, callback)
    local value = initial
    local dragging = false
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 47), BackgroundTransparency = 1 }, parentObject)
    create("TextLabel", {
        Size = UDim2.new(0.68, 0, 0, 21), BackgroundTransparency = 1, Text = label,
        TextColor3 = WHITE, Font = Enum.Font.Code, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local valueText = create("TextLabel", {
        Position = UDim2.new(0.68, 0, 0, 0), Size = UDim2.new(0.32, 0, 0, 21),
        BackgroundTransparency = 1, TextColor3 = WHITE, Text = tostring(value) .. (suffix or ""),
        Font = Enum.Font.Code, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    local track = create("TextButton", {
        Position = UDim2.new(0, 0, 0, 27), Size = UDim2.new(1, 0, 0, 9),
        BackgroundColor3 = OFF, BorderSizePixel = 0, Text = "", AutoButtonColor = false,
    }, row)
    local fill = create("Frame", { Size = UDim2.new((value - minValue) / (maxValue - minValue), 0, 1, 0), BackgroundColor3 = ACCENT }, track)
    registerAccent(fill, "BackgroundColor3")

    local function update(x)
        local width = track.AbsoluteSize.X
        if width <= 0 then return end
        local fraction = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        value = math.floor(minValue + fraction * (maxValue - minValue) + 0.5)
        valueText.Text = tostring(value) .. (suffix or "")
        fill.Size = UDim2.new(fraction, 0, 1, 0)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then update(input.Position.X) end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    if callback then callback(value) end
end

-- Dropdown con CALLBACK
local function dropdown(parentObject, label, options, initialIndex, callback)
    local index = initialIndex or 1
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 47), BackgroundTransparency = 1 }, parentObject)
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = label,
        TextColor3 = WHITE, Font = Enum.Font.Code, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local button = create("TextButton", {
        Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = INNER, BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(48, 48, 52),
        Text = options[index] .. "   >", TextColor3 = WHITE, Font = Enum.Font.Code,
        TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    button.MouseButton1Click:Connect(function()
        index = index % #options + 1
        button.Text = options[index] .. "   >"
        if callback then callback(options[index], index) end
    end)
    if callback then callback(options[index], index) end
end

local function actionButton(parentObject, text, callback)
    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = INNER, BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(48, 48, 52), Text = text, TextColor3 = WHITE,
        Font = Enum.Font.Code, TextSize = 15,
    }, parentObject)
    button.MouseButton1Click:Connect(callback)
    return button
end

local function note(parentObject, text)
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = text,
        TextWrapped = true, TextColor3 = MUTED, Font = Enum.Font.Code, TextSize = 13,
    }, parentObject)
end

-- ============================================================
-- MAIN (conectado)
-- ============================================================
local left, right = columns.main[1], columns.main[2]

local aimPanel = create("Frame", {
    Name = "AimSettingsTabs", Size = UDim2.new(1, -5, 0, 292), BackgroundColor3 = PANEL,
    BorderSizePixel = 1, BorderColor3 = Color3.fromRGB(48, 48, 52),
}, left)
local aimTop = create("Frame", { Size = UDim2.new(1, 0, 0, 31), BackgroundColor3 = BG }, aimPanel)
local aimLine = create("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = ACCENT }, aimTop)
registerAccent(aimLine, "BackgroundColor3")

local silentTab = create("TextButton", {
    Name = "SilentAimTab", Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = ACCENT,
    BorderSizePixel = 0, Text = "silent aim", TextColor3 = WHITE, Font = Enum.Font.Code, TextSize = 16,
}, aimTop)
local aimbotTab = create("TextButton", {
    Name = "AimbotTab", Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundColor3 = OFF, BorderSizePixel = 0, Text = "aimbot", TextColor3 = WHITE,
    Font = Enum.Font.Code, TextSize = 16,
}, aimTop)

local aimBody = create("Frame", { Position = UDim2.fromOffset(8, 38), Size = UDim2.new(1, -16, 1, -44), BackgroundTransparency = 1 }, aimPanel)
local silentPage = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, aimBody)
local aimbotPage = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }, aimBody)
for _, page in ipairs({silentPage, aimbotPage}) do
    create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, page)
end

local function refreshAimTabs()
    silentTab.BackgroundColor3 = silentPage.Visible and ACCENT or OFF
    aimbotTab.BackgroundColor3 = aimbotPage.Visible and ACCENT or OFF
end
table.insert(accentRefreshers, refreshAimTabs)
silentTab.MouseButton1Click:Connect(function() silentPage.Visible = true; aimbotPage.Visible = false; refreshAimTabs() end)
aimbotTab.MouseButton1Click:Connect(function() silentPage.Visible = false; aimbotPage.Visible = true; refreshAimTabs() end)

-- Silent aim -> silentAimVars
checkbox(silentPage, "enabled", false, function(v) silentAimVars.enabled = v end)
checkbox(silentPage, "manipulation", false, function(v) silentAimVars.manipulation = v end)
checkbox(silentPage, "closest part", true, function(v) silentAimVars.closestPart = v end)
checkbox(silentPage, "visualize", false, function(v) silentAimVars.visualize = v end)
checkbox(silentPage, "show fov", true, function(v) silentAimVars.showFov = v end)
slider(silentPage, "radius", 1, 300, 15, "px", function(v) silentAimVars.radius = v end)
slider(silentPage, "hit chance", 0, 100, 100, "%", function(v) silentAimVars.hitChance = v end)

-- Aimbot -> aimbotVars
checkbox(aimbotPage, "enabled", false, function(v) aimbotVars.enabled = v end)
checkbox(aimbotPage, "smooth aim", false, function(v) aimbotVars.smooth = v end)
checkbox(aimbotPage, "visible only", true, function(v) aimbotVars.visibleOnly = v end)
slider(aimbotPage, "FOV", 1, 300, 15, "px", function(v) aimbotVars.fov = v end)
slider(aimbotPage, "smoothing", 1, 100, 50, "%", function(v) aimbotVars.smoothing = v end)
dropdown(aimbotPage, "target part", { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }, 1,
    function(opt) silentAimVars.targeting.selectedTargetPart = opt end)

local targeting = section(left, "targeting", 390)
checkbox(targeting, "visible only", true)
checkbox(targeting, "ignore protected", false)
checkbox(targeting, "disable on flash", false)
checkbox(targeting, "limit distance", false)
slider(targeting, "reaction time", 0, 500, 0, "ms")
slider(targeting, "forget time", 0, 10, 0, "s")
dropdown(targeting, "target part", { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }, 1,
    function(opt) silentAimVars.targeting.selectedTargetPart = opt end)
dropdown(targeting, "closest part blacklist", { "HumanoidRootPart", "UpperTorso", "Head", "None" }, 1)

local trigger = section(right, "triggerbot", 105)
checkbox(trigger, "enabled", false)
dropdown(trigger, "mode", {"Equa", "Default"}, 1)

local weapons = section(right, "weapons", 245)
checkbox(weapons, "no spread", false)
checkbox(weapons, "full auto", false)
checkbox(weapons, "always backstab", true)
dropdown(weapons, "grenade options", { "...", "default", "custom" }, 1)
slider(weapons, "firerate", 0, 100, 100, "%")

-- Ragebot -> ragebotVars / characterVars
local rage = section(right, "ragebot", 315)
checkbox(rage, "enabled", false, function(v) ragebotVars.enabled = v end)
checkbox(rage, "void spam", false, function(v) characterVars.voidSpam = v end)
slider(rage, "shoot attempts", 1, 10, 1, "x", function(v) ragebotVars.shootAttempts = v end)
dropdown(rage, "attack mode", {"gun", "melee", "mixed"}, 1)
dropdown(rage, "preferred weapon", {"primary", "secondary"}, 1)
dropdown(rage, "settings", {"...", "default"}, 1)

local priority = section(right, "priority", 125)
dropdown(priority, "priority mode", { "closest", "visible", "lowest health" }, 1)
checkbox(priority, "prioritize selected", false)

-- WORLD
local worldPanel = section(columns.world[1], "world", 220)
checkbox(worldPanel, "enabled", false)
checkbox(worldPanel, "remove fog", false)
checkbox(worldPanel, "fullbright", false)
checkbox(worldPanel, "show objects", false)
slider(worldPanel, "brightness", 0, 100, 50, "%")

local environment = section(columns.world[2], "environment", 180)
checkbox(environment, "show environment panel", false)
dropdown(environment, "world preset", { "default", "dark", "bright" }, 1)
note(environment, "Controles visuales. No modifican el mundo del juego.")

-- ESP -> espVars
local espPanel = section(columns.esp[1], "player esp", 230)
checkbox(espPanel, "enabled", false, function(v) espVars.enabled = v end)
checkbox(espPanel, "box", false, function(v) espVars.boxes = v end)
checkbox(espPanel, "skeleton", false, function(v) espVars.skeleton = v end)
checkbox(espPanel, "healthbar", false, function(v) espVars.healthbar = v end)
checkbox(espPanel, "name", false, function(v) espVars.names = v end)
checkbox(espPanel, "distance", false, function(v) espVars.distance = v end)

local espFilters = section(columns.esp[2], "filters", 190)
checkbox(espFilters, "visible only", false)
checkbox(espFilters, "ignore teammates", false)
checkbox(espFilters, "show NPCs", false)
dropdown(espFilters, "box style", {"normal", "corner"}, 1)
dropdown(espFilters, "text style", {"default", "compact"}, 1)

-- VISUALS
local visualPanel = section(columns.visuals[1], "visuals", 230)
checkbox(visualPanel, "show FOV circle", false)
checkbox(visualPanel, "crosshair", false)
checkbox(visualPanel, "tracers", false)
checkbox(visualPanel, "show labels", false)
slider(visualPanel, "crosshair size", 1, 30, 8, "px")

local visualOptions = section(columns.visuals[2], "display options", 180)
dropdown(visualOptions, "style", {"default", "minimal"}, 1)
checkbox(visualOptions, "outline", true)
checkbox(visualOptions, "show status", false)
note(visualOptions, "Opciones de apariencia de la interfaz.")

-- CHARACTER -> characterVars
local movement = section(columns.character[1], "character", 235)
checkbox(movement, "movement options", false)
checkbox(movement, "fly toggle", false, function(v) characterVars.flyToggle = v end)
checkbox(movement, "noclip toggle", false, function(v) characterVars.noclipToggle = v end)
checkbox(movement, "infinite jump", false, function(v) characterVars.infiniteJump = v end)
slider(movement, "movement speed", 16, 100, 16, "", function(v) characterVars.movementSpeed = v end)

local characterSettings = section(columns.character[2], "character settings", 180)
dropdown(characterSettings, "preset", { "default", "custom" }, 1)
checkbox(characterSettings, "show status", false)
note(characterSettings, "Los controles de movimiento son solo visuales.")

-- MISC
local miscPanel = section(columns.misc[1], "misc", 190)
checkbox(miscPanel, "show notifications", true)
checkbox(miscPanel, "show status label", false)
checkbox(miscPanel, "compact labels", false)
dropdown(miscPanel, "interface mode", {"default", "classic"}, 1)

local miscInfo = section(columns.misc[2], "information", 130)
note(miscInfo, "Rio Premium UI")
note(miscInfo, "RightShift: ocultar o mostrar la interfaz.")

-- SETTINGS
local keyPanel = section(columns.settings[1], "interface settings", 190)
local keybindButton
keybindButton = actionButton(keyPanel, "toggle key: RightShift (click to change)", function()
    listeningKey = true
    keybindButton.Text = "Press any keyboard key..."
end)
actionButton(keyPanel, "Reset key to RightShift", function()
    toggleKey = Enum.KeyCode.RightShift
    listeningKey = false
    keybindButton.Text = "toggle key: RightShift (click to change)"
end)

local colors = section(columns.settings[2], "interface color", 300)
local presets = {
    {name = "Purple", color = Color3.fromRGB(105, 48, 220)},
    {name = "Blue", color = Color3.fromRGB(40, 120, 245)},
    {name = "Red", color = Color3.fromRGB(225, 55, 70)},
    {name = "Green", color = Color3.fromRGB(45, 190, 105)},
    {name = "Gold", color = Color3.fromRGB(220, 165, 45)},
    {name = "Pink", color = Color3.fromRGB(240, 80, 185)},
}
for _, preset in ipairs(presets) do
    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 31), BackgroundColor3 = preset.color, BorderSizePixel = 0,
        Text = preset.name, TextColor3 = WHITE, Font = Enum.Font.Code, TextSize = 16,
    }, colors)
    button.MouseButton1Click:Connect(function() setAccentColor(preset.color) end)
end

for key, button in pairs(tabButtons) do
    button.BackgroundColor3 = key == "main" and ACCENT or OFF
    button.TextColor3 = key == "main" and WHITE or MUTED
end

UIS.InputBegan:Connect(function(input, processed)
    if not gui.Parent then return end
    if listeningKey then
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
            toggleKey = input.KeyCode
            listeningKey = false
            keybindButton.Text = "toggle key: " .. toggleKey.Name .. " (click to change)"
        end
        return
    end
    if not processed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
        main.Visible = not main.Visible
    end
end)

-- ============================================================
-- LOGICA
-- ============================================================
local Drawing = Drawing or getgenv().Drawing
local espObjects = {}

-- FOV circle del silent aim
local silentAimFovCircle = Drawing.new("Circle")
silentAimFovCircle.Visible = false
silentAimFovCircle.Thickness = 2
silentAimFovCircle.Filled = false
silentAimFovCircle.Transparency = 0.6
silentAimFovCircle.Color = Color3.fromRGB(180, 140, 255)

task.spawn(newcclosure(function()
    while task.wait(0.025) do
        if silentAimVars and silentAimVars.enabled and silentAimVars.showFov then
            local mousePos = UserInputService:GetMouseLocation()
            silentAimFovCircle.Visible = true
            silentAimFovCircle.Position = Vector2.new(mousePos.X, mousePos.Y + 36)
            silentAimFovCircle.Radius = silentAimVars.radius or 120
        else
            silentAimFovCircle.Visible = false
        end
    end
end))

-- Silent aim (hook mouse.Target / mouse.Hit)
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if self == LocalPlayer:GetMouse() and silentAimVars and silentAimVars.enabled then
        local bestTarget, bestDist = nil, silentAimVars.radius or 120
        local mousePos = UserInputService:GetMouseLocation()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(silentAimVars.targeting.selectedTargetPart or "Head") then
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local worldPos = plr.Character[silentAimVars.targeting.selectedTargetPart].Position
                    local screenPos, onScr = Camera:WorldToViewportPoint(worldPos)
                    if onScr then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                        if dist <= bestDist and math.random(100) <= (silentAimVars.hitChance or 100) then
                            bestDist = dist
                            bestTarget = plr
                        end
                    end
                end
            end
        end
        if bestTarget then
            if key == "Target" then
                return bestTarget.Character[silentAimVars.targeting.selectedTargetPart]
            elseif key == "Hit" then
                return bestTarget.Character[silentAimVars.targeting.selectedTargetPart].Position
            end
        end
    end
    return oldIndex(self, key)
end))

-- Ragebot (camara al Head mas cercano)
task.spawn(newcclosure(function()
    while task.wait() do
        if ragebotVars and ragebotVars.enabled then
            local cf_pos = Camera.CFrame.Position
            local bestPlr, bestDist = nil, math.huge
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local head = plr.Character.Head
                        local toHeadDist = (cf_pos - head.Position).Magnitude
                        local _, onScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen and toHeadDist < bestDist and toHeadDist < (ragebotVars.fov or 999) then
                            bestDist = toHeadDist
                            bestPlr = plr
                        end
                    end
                end
            end
            if bestPlr and bestPlr.Character.Head then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, bestPlr.Character.Head.Position)
            end
        end
    end
end))

-- Void spam
task.spawn(newcclosure(function()
    while task.wait(0.089) do
        if characterVars.voidSpam then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                local original = root.CFrame
                root.CFrame = CFrame.new(original.X, -500, original.Z)
                task.wait(0.04)
                root.CFrame = original
            end
        end
    end
end))

-- ESP
task.spawn(newcclosure(function()
    while task.wait(0.06) do
        for _, obj in ipairs(espObjects) do
            for _, v in pairs(obj) do
                if typeof(v) == "table" then
                    for _, line in ipairs(v) do if line.Remove then line:Remove() end end
                elseif v and v.Remove then v:Remove() end
            end
        end
        espObjects = {}
        if espVars and espVars.enabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local hrp = plr.Character.HumanoidRootPart
                        local cam = Camera
                        local root2D, onScreen = cam:WorldToViewportPoint(hrp.Position)
                        local box = Drawing.new("Square")
                        box.Visible = espVars.boxes or false
                        box.Color = espVars.color or Color3.new(0, 1, 0)
                        box.Thickness = 2
                        box.Filled = false
                        local ext = plr.Character:GetExtentsSize()
                        box.Size = Vector2.new(ext.X * 2.3, ext.Y * 2.6)
                        box.Position = Vector2.new(root2D.X - box.Size.X / 2, root2D.Y - box.Size.Y / 2)

                        local skeletonLines = {}
                        if espVars.skeleton then
                            local function drawBone(a, b)
                                if plr.Character:FindFirstChild(a) and plr.Character:FindFirstChild(b) then
                                    local p1, v1 = cam:WorldToViewportPoint(plr.Character[a].Position)
                                    local p2, v2 = cam:WorldToViewportPoint(plr.Character[b].Position)
                                    if v1 and v2 then
                                        local line = Drawing.new("Line")
                                        line.Visible = true
                                        line.Color = espVars.color or Color3.fromRGB(255, 255, 255)
                                        line.From = Vector2.new(p1.X, p1.Y)
                                        line.To = Vector2.new(p2.X, p2.Y)
                                        line.Thickness = 1.5
                                        table.insert(skeletonLines, line)
                                    end
                                end
                            end
                            drawBone("Head", "UpperTorso")
                            drawBone("UpperTorso", "LowerTorso")
                            drawBone("UpperTorso", "LeftUpperArm")
                            drawBone("UpperTorso", "RightUpperArm")
                            drawBone("LeftUpperArm", "LeftLowerArm")
                            drawBone("LeftLowerArm", "LeftHand")
                            drawBone("RightUpperArm", "RightLowerArm")
                            drawBone("RightLowerArm", "RightHand")
                            drawBone("LowerTorso", "LeftUpperLeg")
                            drawBone("LowerTorso", "RightUpperLeg")
                            drawBone("LeftUpperLeg", "LeftLowerLeg")
                            drawBone("LeftLowerLeg", "LeftFoot")
                            drawBone("RightUpperLeg", "RightLowerLeg")
                            drawBone("RightLowerLeg", "RightFoot")
                        end

                        local healthBar = Drawing.new("Line")
                        healthBar.Visible = espVars.boxes and espVars.healthbar
                        healthBar.Color = Color3.new(1 - hum.Health / hum.MaxHealth, hum.Health / hum.MaxHealth, 0)
                        healthBar.Thickness = 4
                        healthBar.From = Vector2.new(root2D.X - box.Size.X / 2 - 5, root2D.Y + box.Size.Y / 2)
                        healthBar.To = Vector2.new(healthBar.From.X, healthBar.From.Y - (hum.Health / hum.MaxHealth) * box.Size.Y)

                        local name = Drawing.new("Text")
                        name.Visible = espVars.names
                        name.Text = plr.DisplayName or plr.Name
                        name.Position = Vector2.new(root2D.X, root2D.Y - box.Size.Y / 2 - 12)
                        name.Color = espVars.color or Color3.new(1, 1, 1)
                        name.Size = 16

                        local distText = Drawing.new("Text")
                        distText.Visible = espVars.distance
                        distText.Text = math.floor((hrp.Position - cam.CFrame.Position).Magnitude) .. "m"
                        distText.Position = Vector2.new(root2D.X, root2D.Y + box.Size.Y / 2 + 2)
                        distText.Color = espVars.color or Color3.new(0.9, 0.9, 1)
                        distText.Size = 13

                        table.insert(espObjects, { box = box, skeleton = skeletonLines, healthbar = healthBar, name = name, distance = distText })
                    end
                end
            end
        end
    end
end))

-- Velocidad
task.spawn(newcclosure(function()
    while task.wait(0.06) do
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") and characterVars.movementSpeed then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = characterVars.movementSpeed
        end
    end
end))

-- Fly
task.spawn(newcclosure(function()
    while task.wait() do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if characterVars.flyToggle then
            if hrp and not hrp:FindFirstChild("FlyForce") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "FlyForce"
                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                bv.Parent = hrp
            end
            if hrp and hrp:FindFirstChild("FlyForce") then
                local vel = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector end
                hrp.FlyForce.Velocity = vel * (characterVars.movementSpeed or 70)
            end
        else
            if hrp and hrp:FindFirstChild("FlyForce") then hrp.FlyForce:Destroy() end
        end
    end
end))

-- Noclip
task.spawn(newcclosure(function()
    while task.wait(0.11) do
        if characterVars.noclipToggle then
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
        end
    end
end))

-- Infinite jump
if not getgenv()._InfJumpConnection then
    getgenv()._InfJumpConnection = UserInputService.JumpRequest:Connect(newcclosure(function()
        if characterVars.infiniteJump then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end))
end

-- Anti-kick
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod and getnamecallmethod() or ""
    if method == "Kick" then return nil end
    return oldNamecall(self, ...)
end))

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Rio Premium UI", Text = "Interface loaded", Duration = 3,
    })
end)

print("Rio Premium UI + logica cargada.")
