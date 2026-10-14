- RIO PREMIUM UI - INTERFAZ ORIGINAL (BASE VISUAL)
-- Pensado para ejecutores que admitan Drawing/Web UI no es requerido.
-- Conserva nombres, pestañas y estilo; no incluye aimbot, auto-disparo ni ESP contra jugadores.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local ACCENT = Color3.fromRGB(242, 150, 238)
local BG = Color3.fromRGB(25, 23, 32)
local PANEL = Color3.fromRGB(37, 33, 45)
local WHITE = Color3.fromRGB(245, 240, 250)
local MUTED = Color3.fromRGB(185, 176, 195)

local old = game:GetService("CoreGui"):FindFirstChild("RioPremiumUI")
if old then old:Destroy() end

local parent
pcall(function() parent = game:GetService("CoreGui") end)
if not parent then parent = LocalPlayer:WaitForChild("PlayerGui") end

local gui = Instance.new("ScreenGui")
gui.Name = "RioPremiumUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = parent

local function create(class, props, parentObj)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    obj.Parent = parentObj
    return obj
end

local main = create("Frame", {
    Name = "Main", Size = UDim2.fromOffset(580, 460),
    Position = UDim2.new(0.5, -290, 0.5, -230),
    BackgroundColor3 = BG, BorderSizePixel = 0,
}, gui)
create("UICorner", {CornerRadius = UDim.new(0, 10)}, main)
create("UIStroke", {Color = ACCENT, Thickness = 1.4}, main)

local top = create("Frame", {
    Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
}, main)
create("UICorner", {CornerRadius = UDim.new(0, 10)}, top)
create("Frame", {
    Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 10),
    BackgroundColor3 = PANEL, BorderSizePixel = 0,
}, top)

create("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(1, -80, 1, 0), Text = "Rio Premium UI",
    Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local close = create("TextButton", {
    Position = UDim2.new(1, -42, 0, 9), Size = UDim2.fromOffset(32, 30),
    Text = "×", Font = Enum.Font.GothamBold, TextSize = 21,
    TextColor3 = WHITE, BackgroundColor3 = Color3.fromRGB(100, 49, 87),
    BorderSizePixel = 0,
}, top)
create("UICorner", {CornerRadius = UDim.new(0, 6)}, close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Arrastrar ventana
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local sidebar = create("Frame", {
    Position = UDim2.fromOffset(10, 58), Size = UDim2.new(0, 155, 1, -68),
    BackgroundColor3 = PANEL, BorderSizePixel = 0,
}, main)
create("UICorner", {CornerRadius = UDim.new(0, 8)}, sidebar)
create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 7),
    PaddingRight = UDim.new(0, 7)}, sidebar)
create("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)

local content = create("Frame", {
    Position = UDim2.fromOffset(174, 58), Size = UDim2.new(1, -184, 1, -68),
    BackgroundColor3 = PANEL, BorderSizePixel = 0,
}, main)
create("UICorner", {CornerRadius = UDim.new(0, 8)}, content)

local pages, tabButtons, controls = {}, {}, {}
local function addPage(key, title, order)
    local tab = create("TextButton", {
        LayoutOrder = order, Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = BG, BorderSizePixel = 0, Text = title,
        TextColor3 = WHITE, Font = Enum.Font.GothamMedium, TextSize = 12,
    }, sidebar)
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, tab)
    local page = create("ScrollingFrame", {
        Name = key, Visible = false, Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = ACCENT,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
    }, content)
    create("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    create("TextLabel", {
        LayoutOrder = 0, Size = UDim2.new(1, -4, 0, 30), BackgroundTransparency = 1,
        Text = title, TextColor3 = ACCENT, Font = Enum.Font.GothamBold, TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, page)
    pages[key], tabButtons[key] = page, tab
    tab.MouseButton1Click:Connect(function()
        for k, p in pairs(pages) do p.Visible = (k == key) end
        for k, b in pairs(tabButtons) do
            b.BackgroundColor3 = (k == key) and ACCENT or BG
            b.TextColor3 = (k == key) and BG or WHITE
        end
    end)
    return page
end

local function info(page, text)
    local label = create("TextLabel", {
        Size = UDim2.new(1, -4, 0, 42), BackgroundColor3 = BG, BorderSizePixel = 0,
        Text = text, TextWrapped = true, TextColor3 = MUTED,
        Font = Enum.Font.Gotham, TextSize = 11,
    }, page)
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, label)
end

local function toggle(page, label, default, callback)
    local state = default == true
    local row = create("Frame", {
        Size = UDim2.new(1, -4, 0, 38), BackgroundColor3 = BG, BorderSizePixel = 0,
    }, page)
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, row)
    create("TextLabel", {
        Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -82, 1, 0),
        BackgroundTransparency = 1, Text = label, TextColor3 = WHITE,
        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local btn = create("TextButton", {
        Position = UDim2.new(1, -66, 0.5, -12), Size = UDim2.fromOffset(56, 24),
        BackgroundColor3 = state and ACCENT or Color3.fromRGB(74, 69, 83),
        Text = state and "ON" or "OFF", TextColor3 = state and BG or WHITE,
        Font = Enum.Font.GothamBold, TextSize = 10, BorderSizePixel = 0,
    }, row)
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, btn)
    local function set(v)
        state = v
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and ACCENT or Color3.fromRGB(74, 69, 83)
        btn.TextColor3 = state and BG or WHITE
        if callback then callback(state) end
    end
    btn.MouseButton1Click:Connect(function() set(not state) end)
    controls[label] = set
end

local function slider(page, label, minV, maxV, defaultV, callback)
    local value = defaultV
    local row = create("Frame", {
        Size = UDim2.new(1, -4, 0, 58), BackgroundColor3 = BG, BorderSizePixel = 0,
    }, page)
    create("UICorner", {CornerRadius = UDim.new(0, 6)}, row)
    create("TextLabel", {
        Position = UDim2.fromOffset(10, 2), Size = UDim2.new(1, -65, 0, 24),
        BackgroundTransparency = 1, Text = label, TextColor3 = WHITE,
        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local val = create("TextLabel", {
        Position = UDim2.new(1, -54, 0, 2), Size = UDim2.fromOffset(44, 24),
        BackgroundTransparency = 1, Text = tostring(value), TextColor3 = ACCENT,
        Font = Enum.Font.GothamBold, TextSize = 11,
    }, row)
    local track = create("TextButton", {
        Position = UDim2.new(0, 10, 0, 35), Size = UDim2.new(1, -20, 0, 8),
        BackgroundColor3 = Color3.fromRGB(74, 69, 83), Text = "", BorderSizePixel = 0,
        AutoButtonColor = false,
    }, row)
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
    local fill = create("Frame", {
        Size = UDim2.new((value - minV) / (maxV - minV), 0, 1, 0),
        BackgroundColor3 = ACCENT, BorderSizePixel = 0,
    }, track)
    create("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
    local function update(x)
        local fraction = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(minV + fraction * (maxV - minV) + 0.5)
        val.Text = tostring(value)
        fill.Size = UDim2.new(fraction, 0, 1, 0)
        if callback then callback(value) end
    end
    track.MouseButton1Down:Connect(function(x) update(x) end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then update(input.Position.X) end
    end)
    controls[label] = function(v)
        value = math.clamp(v, minV, maxV)
        val.Text = tostring(value)
        fill.Size = UDim2.new((value - minV) / (maxV - minV), 0, 1, 0)
        if callback then callback(value) end
    end
end

-- Mismas cinco pestañas y títulos del script original.
local aim = addPage("Aim", "Aim Bot", 1)
info(aim, "Rio Premium UI v2.5 — controles visuales conservados. Funciones de apuntado no incluidas.")
toggle(aim, "Activar Aim Bot (Aimbot Toggle)", false)
toggle(aim, "Silent Aim (Silent Toggle)", false)
toggle(aim, "Trigger Bot (Auto-Disparo)", false)
slider(aim, "Radio del FOV (Aimbot Radius)", 10, 1000, 110)
info(aim, "Parte del Cuerpo (Targeting Part): Head / UpperTorso / LowerTorso / HumanoidRootPart")

local rage = addPage("Rage", "Rage Bot", 2)
info(rage, "Apartado no implementado en esta versión.")

local visuals = addPage("Visuals", "Visuales (ESP)", 3)
toggle(visuals, "Cuadro de Jugador (ESP Box)", false)
toggle(visuals, "Esqueleto Visual (ESP Skeleton)", false)
toggle(visuals, "Barra de Vida (ESP Healthbar)", false)
info(visuals, "Color Inicial de Vida (Healthbar Start): rosa/morado")
info(visuals, "Los controles visuales se conservan; no rastrean ni dibujan sobre otros jugadores.")

local movement = addPage("Movement", "Movimiento", 4)
toggle(movement, "Noclip (Atravesar Paredes)", false)
toggle(movement, "Volar (Fly)", false)
slider(movement, "Velocidad de Vuelo (Fly Value)", 16, 300, 100)
toggle(movement, "Saltos Infinitos (Infinite Double Jump)", false)
info(movement, "Los controles de movimiento son solo visuales en esta base.")

local settings = addPage("Settings", "Ajustes / Configs", 5)
info(settings, "Ocultar Interfaz: RightShift. Las preferencias no se guardan entre sesiones.")
local hide = create("TextButton", {
    Size = UDim2.new(1, -4, 0, 38), BackgroundColor3 = BG, BorderSizePixel = 0,
    Text = "Ocultar Interfaz (RightShift)", TextColor3 = WHITE,
    Font = Enum.Font.Gotham, TextSize = 11,
}, settings)
create("UICorner", {CornerRadius = UDim.new(0, 6)}, hide)
hide.MouseButton1Click:Connect(function() main.Visible = false end)
local unload = create("TextButton", {
    Size = UDim2.new(1, -4, 0, 38), BackgroundColor3 = Color3.fromRGB(100, 49, 87),
    BorderSizePixel = 0, Text = "Cerrar Todo (Unload Script)", TextColor3 = WHITE,
    Font = Enum.Font.GothamBold, TextSize = 11,
}, settings)
create("UICorner", {CornerRadius = UDim.new(0, 6)}, unload)
unload.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Seleccionar la primera pestaña.
for k, p in pairs(pages) do p.Visible = (k == "Aim") end
for k, b in pairs(tabButtons) do
    b.BackgroundColor3 = (k == "Aim") and ACCENT or BG
    b.TextColor3 = (k == "Aim") and BG or WHITE
end

UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift and gui.Parent then
        main.Visible = not main.Visible
    end
end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Rio Premium UI",
        Text = "Interfaz cargada",
        Duration = 4,
    })
end)
