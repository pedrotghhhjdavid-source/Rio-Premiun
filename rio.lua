-- ============================================================
-- RIO PREMIUM UI
-- Interfaz visual inspirada en la referencia del usuario.
-- Los controles de aimbot/ESP son elementos visuales.
-- ============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("Rio Premium UI: LocalPlayer no disponible.")
    return
end

-- Colores
local ACCENT = Color3.fromRGB(105, 48, 220)
local BG = Color3.fromRGB(17, 17, 18)
local PANEL = Color3.fromRGB(25, 25, 27)
local INNER = Color3.fromRGB(31, 31, 34)
local WHITE = Color3.fromRGB(225, 225, 228)
local MUTED = Color3.fromRGB(150, 150, 155)
local OFF = Color3.fromRGB(36, 36, 39)

-- Estado de la interfaz
local toggleKey = Enum.KeyCode.RightShift
local listeningKey = false
local selectedTab = "main"
local accentTargets = {}
local accentRefreshers = {}
local pages = {}
local tabButtons = {}
local columns = {}

-- Colocar la interfaz en un contenedor permitido.
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local coreGui

pcall(function()
    coreGui = game:GetService("CoreGui")
end)

local parent = playerGui
if coreGui then
    parent = coreGui
end

-- Limpiar una ejecución anterior.
for _, container in ipairs({playerGui, coreGui}) do
    if container then
        pcall(function()
            local old = container:FindFirstChild("RioPremiumUI")
            if old then
                old:Destroy()
            end
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
    table.insert(accentTargets, {
        object = object,
        property = property,
    })
end

local function setAccentColor(color)
    ACCENT = color

    for _, item in ipairs(accentTargets) do
        pcall(function()
            item.object[item.property] = ACCENT
        end)
    end

    for _, refresh in ipairs(accentRefreshers) do
        pcall(refresh)
    end
end

-- Ventana principal grande.
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

create("UISizeConstraint", {
    MinSize = Vector2.new(580, 620),
    MaxSize = Vector2.new(680, 800),
}, main)
-- Bolita flotante RioRage
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
    AutoButtonColor = true,
    Active = true,
    ZIndex = 50,
}, gui)

create("UICorner", {
    CornerRadius = UDim.new(1, 0),
}, floatButton)

local floatStroke = create("UIStroke", {
    Color = Color3.fromRGB(30, 30, 30),
    Thickness = 1.5,
}, floatButton)

registerAccent(floatStroke, "Color")

-- Arrastrar o pulsar la bolita
local draggingFloat = false
local movedFloat = false
local pointerStart
local buttonStart

floatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingFloat = true
        movedFloat = false
        pointerStart = input.Position
        buttonStart = floatButton.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if not draggingFloat then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - pointerStart

        if delta.Magnitude > 5 then
            movedFloat = true
        end

        if movedFloat then
            floatButton.Position = UDim2.new(
                buttonStart.X.Scale,
                buttonStart.X.Offset + delta.X,
                buttonStart.Y.Scale,
                buttonStart.Y.Offset + delta.Y
            )
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if not draggingFloat then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingFloat = false

        if not movedFloat and gui.Parent then
            main.Visible = not main.Visible
        end
    end
end)
local outline = create("UIStroke", {
    Color = ACCENT,
    Thickness = 1,
}, main)
registerAccent(outline, "Color")

-- Encabezado
local header = create("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
}, main)

local gameLabel = create("TextLabel", {
    Name = "GameLabel",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -50, 0.5, 0),
    Size = UDim2.fromOffset(100, 32),
    BackgroundTransparency = 1,
    Text = "Rivals",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Right,
}, header)

local close = create("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -9, 0.5, 0),
    Size = UDim2.fromOffset(33, 29),
    BackgroundColor3 = Color3.fromRGB(90, 28, 35),
    BorderSizePixel = 0,
    Text = "X",
    TextColor3 = WHITE,
    Font = Enum.Font.Code,
    TextSize = 18,
}, header)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Barra de pestañas.
local nav = create("Frame", {
    Position = UDim2.fromOffset(8, 49),
    Size = UDim2.new(1, -16, 0, 39),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, main)

create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, nav)

local tabNames = {
    "main",
    "world",
    "esp",
    "visuals",
    "character",
    "misc",
    "settings",
}

-- Área de contenido.
local body = create("Frame", {
    Position = UDim2.fromOffset(8, 96),
    Size = UDim2.new(1, -16, 1, -104),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, main)

-- Columnas desplazables.
local function makeColumns(page)
    local left = create("ScrollingFrame", {
        Name = "LeftColumn",
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0.5, -5, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ACCENT,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, page)

    local right = create("ScrollingFrame", {
        Name = "RightColumn",
        Position = UDim2.new(0.5, 5, 0, 0),
        Size = UDim2.new(0.5, -5, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = ACCENT,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, page)

    registerAccent(left, "ScrollBarImageColor3")
    registerAccent(right, "ScrollBarImageColor3")

    for _, column in ipairs({left, right}) do
        create("UIListLayout", {
            Padding = UDim.new(0, 9),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, column)
    end

    return left, right
end

for index, name in ipairs(tabNames) do
    local tab = create("TextButton", {
        Name = name .. "Tab",
        LayoutOrder = index,
        Size = UDim2.new(1 / #tabNames, -5, 1, 0),
        BackgroundColor3 = OFF,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(48, 48, 52),
        Text = name,
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 17,
    }, nav)

    local page = create("Frame", {
        Name = name .. "Page",
        Visible = name == "main",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, body)

    local left, right = makeColumns(page)

    tabButtons[name] = tab
    pages[name] = page
    columns[name] = {left, right}

    tab.MouseButton1Click:Connect(function()
        selectedTab = name

        for key, otherPage in pairs(pages) do
            otherPage.Visible = key == selectedTab
        end

        for key, otherTab in pairs(tabButtons) do
            otherTab.BackgroundColor3 =
                key == selectedTab and ACCENT or OFF

            otherTab.TextColor3 =
                key == selectedTab and WHITE or MUTED
        end
    end)
end

table.insert(accentRefreshers, function()
    for key, tab in pairs(tabButtons) do
        tab.BackgroundColor3 = key == selectedTab and ACCENT or OFF
        tab.TextColor3 = key == selectedTab and WHITE or MUTED
    end
end)

-- Crear paneles.
local function section(parentObject, name, height)
    local panel = create("Frame", {
        Name = name,
        Size = UDim2.new(1, -5, 0, height),
        BackgroundColor3 = PANEL,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(48, 48, 52),
    }, parentObject)

    local line = create("Frame", {
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
    }, panel)

    registerAccent(line, "BackgroundColor3")

    create("TextLabel", {
        Position = UDim2.fromOffset(10, 3),
        Size = UDim2.new(1, -20, 0, 27),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, panel)

    local content = create("Frame", {
        Position = UDim2.fromOffset(8, 34),
        Size = UDim2.new(1, -16, 1, -41),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, panel)

    create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)

    return content
end

-- Checkbox visual.
local function checkbox(parentObject, label, default)
    local state = default == true

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parentObject)

    local box = create("TextButton", {
        Position = UDim2.fromOffset(0, 4),
        Size = UDim2.fromOffset(19, 19),
        BackgroundColor3 = state and ACCENT or OFF,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(50, 50, 54),
        Text = state and "✓" or "",
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 15,
    }, row)

    local labelText = create("TextLabel", {
        Position = UDim2.fromOffset(27, 0),
        Size = UDim2.new(1, -29, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local function refresh()
        box.BackgroundColor3 = state and ACCENT or OFF
        box.Text = state and "✓" or ""
    end

    table.insert(accentRefreshers, refresh)

    box.MouseButton1Click:Connect(function()
        state = not state
        refresh()
    end)

    labelText.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            refresh()
        end
    end)
end

-- Slider visual con ajuste mediante clic y arrastre.
local function slider(parentObject, label, minValue, maxValue, initial, suffix)
    local value = initial
    local dragging = false

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 47),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parentObject)

    local labelText = create("TextLabel", {
        Size = UDim2.new(0.68, 0, 0, 21),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local valueText = create("TextLabel", {
        Position = UDim2.new(0.68, 0, 0, 0),
        Size = UDim2.new(0.32, 0, 0, 21),
        BackgroundTransparency = 1,
        TextColor3 = WHITE,
        Text = tostring(value) .. (suffix or ""),
        Font = Enum.Font.Code,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)

    local track = create("TextButton", {
        Position = UDim2.new(0, 0, 0, 27),
        Size = UDim2.new(1, 0, 0, 9),
        BackgroundColor3 = OFF,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, row)

    local fill = create("Frame", {
        Size = UDim2.new(
            (value - minValue) / (maxValue - minValue), 0, 1, 0
        ),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0,
    }, track)

    registerAccent(fill, "BackgroundColor3")

    local function update(x)
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return
        end

        local fraction = math.clamp(
            (x - track.AbsolutePosition.X) / width,
            0,
            1
        )

        value = math.floor(
            minValue + fraction * (maxValue - minValue) + 0.5
        )

        valueText.Text = tostring(value) .. (suffix or "")
        fill.Size = UDim2.new(fraction, 0, 1, 0)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Selector visual: clic para cambiar de opción.
local function dropdown(parentObject, label, options, initialIndex)
    local index = initialIndex or 1

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 47),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    }, parentObject)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local button = create("TextButton", {
        Position = UDim2.fromOffset(0, 22),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = INNER,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(48, 48, 52),
        Text = options[index] .. "   >",
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    button.MouseButton1Click:Connect(function()
        index = index % #options + 1
        button.Text = options[index] .. "   >"
    end)
end

local function actionButton(parentObject, text, callback)
    local button = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = INNER,
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(48, 48, 52),
        Text = text,
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 15,
    }, parentObject)

    button.MouseButton1Click:Connect(callback)
    return button
end

local function note(parentObject, text)
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = text,
        TextWrapped = true,
        TextColor3 = MUTED,
        Font = Enum.Font.Code,
        TextSize = 13,
    }, parentObject)
end

-- ============================================================
-- MAIN: dos columnas similares a la imagen.
-- ============================================================

local left = columns.main[1]
local right = columns.main[2]

-- Panel dividido: silent aim / aimbot
local aimPanel = create("Frame", {
    Name = "AimSettingsTabs",
    Size = UDim2.new(1, -5, 0, 292),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(48, 48, 52),
}, left)

local aimTop = create("Frame", {
    Size = UDim2.new(1, 0, 0, 31),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
}, aimPanel)

local aimLine = create("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
}, aimTop)

registerAccent(aimLine, "BackgroundColor3")

local silentTab = create("TextButton", {
    Name = "SilentAimTab",
    Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundColor3 = ACCENT,
    BorderSizePixel = 0,
    Text = "silent aim",
    TextColor3 = WHITE,
    Font = Enum.Font.Code,
    TextSize = 16,
}, aimTop)

local aimbotTab = create("TextButton", {
    Name = "AimbotTab",
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.new(0.5, 0, 1, 0),
    BackgroundColor3 = OFF,
    BorderSizePixel = 0,
    Text = "aimbot",
    TextColor3 = WHITE,
    Font = Enum.Font.Code,
    TextSize = 16,
}, aimTop)

local aimBody = create("Frame", {
    Position = UDim2.fromOffset(8, 38),
    Size = UDim2.new(1, -16, 1, -44),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, aimPanel)

local silentPage = create("Frame", {
    Name = "SilentAimPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
}, aimBody)

local aimbotPage = create("Frame", {
    Name = "AimbotPage",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
}, aimBody)

for _, page in ipairs({silentPage, aimbotPage}) do
    create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
end

local function refreshAimTabs()
    silentTab.BackgroundColor3 =
        silentPage.Visible and ACCENT or OFF

    aimbotTab.BackgroundColor3 =
        aimbotPage.Visible and ACCENT or OFF
end

table.insert(accentRefreshers, refreshAimTabs)

silentTab.MouseButton1Click:Connect(function()
    silentPage.Visible = true
    aimbotPage.Visible = false
    refreshAimTabs()
end)

aimbotTab.MouseButton1Click:Connect(function()
    silentPage.Visible = false
    aimbotPage.Visible = true
    refreshAimTabs()
end)

-- Opciones visuales de silent aim
checkbox(silentPage, "enabled", false)
checkbox(silentPage, "manipulation", false)
checkbox(silentPage, "closest part", true)
checkbox(silentPage, "visualize", false)
checkbox(silentPage, "show fov", false)

slider(silentPage, "radius", 1, 300, 15, "px")
slider(silentPage, "hit chance", 0, 100, 100, "%")

-- Opciones visuales de aimbot
checkbox(aimbotPage, "enabled", false)
checkbox(aimbotPage, "smooth aim", false)
checkbox(aimbotPage, "visible only", true)

slider(aimbotPage, "FOV", 1, 300, 15, "px")
slider(aimbotPage, "smoothing", 1, 100, 50, "%")

dropdown(aimbotPage, "target part", {
    "Head",
    "UpperTorso",
    "LowerTorso",
    "HumanoidRootPart",
}, 1)

local targeting = section(left, "targeting", 390)
checkbox(targeting, "visible only", true)
checkbox(targeting, "ignore protected", false)
checkbox(targeting, "disable on flash", false)
checkbox(targeting, "limit distance", false)
slider(targeting, "reaction time", 0, 500, 0, "ms")
slider(targeting, "forget time", 0, 10, 0, "s")
dropdown(targeting, "target part", {
    "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"
}, 1)
dropdown(targeting, "closest part blacklist", {
    "HumanoidRootPart", "UpperTorso", "Head", "None"
}, 1)

local trigger = section(right, "triggerbot", 105)
checkbox(trigger, "enabled", false)
dropdown(trigger, "mode", {"Equa", "Default"}, 1)

local weapons = section(right, "weapons", 245)
checkbox(weapons, "no spread", false)
checkbox(weapons, "full auto", false)
checkbox(weapons, "always backstab", true)
dropdown(weapons, "grenade options", {
    "...", "default", "custom"
}, 1)
slider(weapons, "firerate", 0, 100, 100, "%")

local rage = section(right, "ragebot", 315)
checkbox(rage, "enabled", false)
checkbox(rage, "void spam", false)
slider(rage, "shoot attempts", 1, 10, 1, "x")
dropdown(rage, "attack mode", {"gun", "melee", "mixed"}, 1)
dropdown(rage, "preferred weapon", {"primary", "secondary"}, 1)
dropdown(rage, "settings", {"...", "default"}, 1)

local priority = section(right, "priority", 125)
dropdown(priority, "priority mode", {
    "closest", "visible", "lowest health"
}, 1)
checkbox(priority, "prioritize selected", false)

-- ============================================================
-- WORLD
-- ============================================================

local worldLeft = columns.world[1]
local worldRight = columns.world[2]

local worldPanel = section(worldLeft, "world", 220)
checkbox(worldPanel, "enabled", false)
checkbox(worldPanel, "remove fog", false)
checkbox(worldPanel, "fullbright", false)
checkbox(worldPanel, "show objects", false)
slider(worldPanel, "brightness", 0, 100, 50, "%")

local environment = section(worldRight, "environment", 180)
checkbox(environment, "show environment panel", false)
dropdown(environment, "world preset", {
    "default", "dark", "bright"
}, 1)
note(environment, "Controles visuales. No modifican el mundo del juego.")

-- ============================================================
-- ESP
-- ============================================================

local espLeft = columns.esp[1]
local espRight = columns.esp[2]

local espPanel = section(espLeft, "player esp", 230)
checkbox(espPanel, "enabled", false)
checkbox(espPanel, "box", false)
checkbox(espPanel, "skeleton", false)
checkbox(espPanel, "healthbar", false)
checkbox(espPanel, "name", false)
checkbox(espPanel, "distance", false)

local espFilters = section(espRight, "filters", 190)
checkbox(espFilters, "visible only", false)
checkbox(espFilters, "ignore teammates", false)
checkbox(espFilters, "show NPCs", false)
dropdown(espFilters, "box style", {"normal", "corner"}, 1)
dropdown(espFilters, "text style", {"default", "compact"}, 1)

-- ============================================================
-- VISUALS
-- ============================================================

local visualLeft = columns.visuals[1]
local visualRight = columns.visuals[2]

local visualPanel = section(visualLeft, "visuals", 230)
checkbox(visualPanel, "show FOV circle", false)
checkbox(visualPanel, "crosshair", false)
checkbox(visualPanel, "tracers", false)
checkbox(visualPanel, "show labels", false)
slider(visualPanel, "crosshair size", 1, 30, 8, "px")

local visualOptions = section(visualRight, "display options", 180)
dropdown(visualOptions, "style", {"default", "minimal"}, 1)
checkbox(visualOptions, "outline", true)
checkbox(visualOptions, "show status", false)
note(visualOptions, "Opciones de apariencia de la interfaz.")

-- ============================================================
-- CHARACTER
-- ============================================================

local charLeft = columns.character[1]
local charRight = columns.character[2]

local movement = section(charLeft, "character", 235)
checkbox(movement, "movement options", false)
checkbox(movement, "fly toggle", false)
checkbox(movement, "noclip toggle", false)
checkbox(movement, "infinite jump", false)
slider(movement, "movement speed", 16, 100, 16, "")

local characterSettings = section(charRight, "character settings", 180)
dropdown(characterSettings, "preset", {
    "default", "custom"
}, 1)
checkbox(characterSettings, "show status", false)
note(characterSettings, "Los controles de movimiento son solo visuales.")

-- ============================================================
-- MISC
-- ============================================================

local miscLeft = columns.misc[1]
local miscRight = columns.misc[2]

local miscPanel = section(miscLeft, "misc", 190)
checkbox(miscPanel, "show notifications", true)
checkbox(miscPanel, "show status label", false)
checkbox(miscPanel, "compact labels", false)
dropdown(miscPanel, "interface mode", {"default", "classic"}, 1)

local miscInfo = section(miscRight, "information", 130)
note(miscInfo, "Rio Premium UI")
note(miscInfo, "RightShift: ocultar o mostrar la interfaz.")

-- ============================================================
-- SETTINGS: tecla y color de acento.
-- ============================================================

local settingsLeft = columns.settings[1]
local settingsRight = columns.settings[2]

local keyPanel = section(settingsLeft, "interface settings", 190)

local keybindButton
keybindButton = actionButton(
    keyPanel,
    "toggle key: RightShift (click to change)",
    function()
        listeningKey = true
        keybindButton.Text = "Press any keyboard key..."
    end
)

actionButton(keyPanel, "Reset key to RightShift", function()
    toggleKey = Enum.KeyCode.RightShift
    listeningKey = false
    keybindButton.Text =
        "toggle key: RightShift (click to change)"
end)

local colors = section(settingsRight, "interface color", 300)

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
        Size = UDim2.new(1, 0, 0, 31),
        BackgroundColor3 = preset.color,
        BorderSizePixel = 0,
        Text = preset.name,
        TextColor3 = WHITE,
        Font = Enum.Font.Code,
        TextSize = 16,
    }, colors)

    button.MouseButton1Click:Connect(function()
        setAccentColor(preset.color)
    end)
end

-- ============================================================
-- Seleccionar la pestaña inicial y manejar la tecla.
-- ============================================================

for key, button in pairs(tabButtons) do
    button.BackgroundColor3 = key == "main" and ACCENT or OFF
    button.TextColor3 = key == "main" and WHITE or MUTED
end

UIS.InputBegan:Connect(function(input, processed)
    if not gui.Parent then
        return
    end

    if listeningKey then
        if input.UserInputType == Enum.UserInputType.Keyboard
            and input.KeyCode ~= Enum.KeyCode.Unknown then

            toggleKey = input.KeyCode
            listeningKey = false
            keybindButton.Text =
                "toggle key: " .. toggleKey.Name .. " (click to change)"
        end
        return
    end

    if not processed
        and input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == toggleKey then

        main.Visible = not main.Visible
    end
end)

-- Aviso de carga.
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Rio Premium UI",
        Text = "Interface loaded",
        Duration = 3,
    })
end)

print("Rio Premium UI: interfaz creada.")
