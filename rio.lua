-- SERVICIOS DE ROBLOX
-- =============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CONFIGURACIÓN DE TECLAS Y VISIBILIDAD
-- =============================================================================
local menuKey = Enum.KeyCode.RightShift
local menuVisible = true
local bindingMode = false

-- ESTADOS DE LAS FUNCIONES EXISTENTES Y NUEVAS
-- =============================================================================
local silentAimEnabled = false
local triggerbotEnabled = false
local espEnabled = false
local targetEnemy = nil

-- CREACIÓN DE INTERFAZ AGRANDADA ESTILO UNNAMED (MÁS ESPACIO PARA EL FUTURO)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioPremiumGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Contenedor Principal Más Amplio (Aumentado a 560x400 para emular perfectamente la UI de tu imagen)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 400)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
MainFrame.Active = true
MainFrame.Visible = menuVisible
MainFrame.Parent = ScreenGui

-- Borde superior acentuado en color azul premium
local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 2)
TopAccent.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TopAccent.BorderSizePixel = 0
TopAccent.Parent = MainFrame

-- Título Principal
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "Rio Premium"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Subtítulo lateral
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 200, 0, 35)
Subtitle.Position = UDim2.new(1, -215, 0, 2)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Unnamed Enhancements Style"
Subtitle.TextColor3 = Color3.fromRGB(120, 120, 120)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Code
Subtitle.TextXAlignment = Enum.TextXAlignment.Right
Subtitle.Parent = MainFrame

-- SISTEMA DE PESTAÑAS AMPLIADO (TABS BAR)
-- =============================================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
TabBar.BorderSizePixel = 1
TabBar.BorderColor3 = Color3.fromRGB(40, 40, 40)
TabBar.Parent = MainFrame

-- Cuadros contenedores de páginas
local MainTabFrame = Instance.new("Frame")
MainTabFrame.Size = UDim2.new(1, -20, 1, -85)
MainTabFrame.Position = UDim2.new(0, 10, 0, 75)
MainTabFrame.BackgroundTransparency = 1
MainTabFrame.Visible = true
MainTabFrame.Parent = MainFrame

local EspTabFrame = Instance.new("Frame")
EspTabFrame.Size = UDim2.new(1, -20, 1, -85)
EspTabFrame.Position = UDim2.new(0, 10, 0, 75)
EspTabFrame.BackgroundTransparency = 1
EspTabFrame.Visible = false
EspTabFrame.Parent = MainFrame

local SettingsTabFrame = Instance.new("Frame")
SettingsTabFrame.Size = UDim2.new(1, -20, 1, -85)
SettingsTabFrame.Position = UDim2.new(0, 10, 0, 75)
SettingsTabFrame.BackgroundTransparency = 1
SettingsTabFrame.Visible = false
SettingsTabFrame.Parent = MainFrame

-- Botones de las Pestañas superiores
local MainTabButton = Instance.new("TextButton")
MainTabButton.Size = UDim2.new(0, 90, 1, 0)
MainTabButton.Position = UDim2.new(0, 0, 0, 0)
MainTabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainTabButton.Text = "main"
MainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabButton.Font = Enum.Font.Code
MainTabButton.TextSize = 14
MainTabButton.Parent = TabBar

local EspTabButton = Instance.new("TextButton")
EspTabButton.Size = UDim2.new(0, 90, 1, 0)
EspTabButton.Position = UDim2.new(0, 95, 0, 0)
EspTabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
EspTabButton.Text = "esp"
EspTabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
EspTabButton.Font = Enum.Font.Code
EspTabButton.TextSize = 14
EspTabButton.Parent = TabBar

local SettingsTabButton = Instance.new("TextButton")
SettingsTabButton.Size = UDim2.new(0, 90, 1, 0)
SettingsTabButton.Position = UDim2.new(0, 190, 0, 0)
SettingsTabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
SettingsTabButton.Text = "settings"
SettingsTabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
SettingsTabButton.Font = Enum.Font.Code
SettingsTabButton.TextSize = 14
SettingsTabButton.Parent = TabBar

-- Lógica para alternar pestañas
local function updateTabs(activeButton, activeFrame)
    MainTabFrame.Visible = false
    EspTabFrame.Visible = false
    SettingsTabFrame.Visible = false
    MainTabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    MainTabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    EspTabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    EspTabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    SettingsTabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    SettingsTabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    activeFrame.Visible = true
    activeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    activeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
end

MainTabButton.MouseButton1Click:Connect(function() updateTabs(MainTabButton, MainTabFrame) end)
EspTabButton.MouseButton1Click:Connect(function() updateTabs(EspTabButton, EspTabFrame) end)
SettingsTabButton.MouseButton1Click:Connect(function() updateTabs(SettingsTabButton, SettingsTabFrame) end)

-- SECCIÓN INTERNA PRINCIPAL (MAIN TAB) - BOTONES DISTRIBUIDOS A LOS EXTREMOS
-- =============================================================================
-- Silent Aim posicionado al extremo izquierdo
local SilentToggle = Instance.new("TextButton")
SilentToggle.Size = UDim2.new(0, 240, 0, 35)
SilentToggle.Position = UDim2.new(0, 15, 0, 20)
SilentToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SilentToggle.Text = "Silent Aim: OFF"
SilentToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
SilentToggle.Font = Enum.Font.Code
SilentToggle.TextSize = 14
SilentToggle.Parent = MainTabFrame

-- Triggerbot añadido al extremo derecho (Como se ve en tu imagen del menú)
local TriggerToggle = Instance.new("TextButton")
TriggerToggle.Size = UDim2.new(0, 240, 0, 35)
TriggerToggle.Position = UDim2.new(1, -255, 0, 20) -- Alineado simétricamente a la derecha
TriggerToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TriggerToggle.Text = "Triggerbot: OFF"
TriggerToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
TriggerToggle.Font = Enum.Font.Code
TriggerToggle.TextSize = 14
TriggerToggle.Parent = MainTabFrame

-- SECCIÓN ESP (ESP TAB)
-- =============================================================================
local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.new(0, 240, 0, 35)
EspToggle.Position = UDim2.new(0, 15, 0, 20)
EspToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
EspToggle.Text = "ESP Highlight: OFF"
EspToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
EspToggle.Font = Enum.Font.Code
EspToggle.TextSize = 14
EspToggle.Parent = EspTabFrame

-- SECCIÓN CONFIGURACIONES (SETTINGS TAB)
-- =============================================================================
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(0, 200, 0, 30)
KeybindLabel.Position = UDim2.new(0, 15, 0, 20)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Menu Key (Toggle):"
KeybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
KeybindLabel.Font = Enum.Font.Code
KeybindLabel.TextSize = 14
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.Parent = SettingsTabFrame

local KeybindButton = Instance.new("TextButton")
KeybindButton.Size = UDim2.new(0, 150, 0, 30)
KeybindButton.Position = UDim2.new(0, 180, 0, 20)
KeybindButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
KeybindButton.Text = "RightShift"
KeybindButton.TextColor3 = Color3.fromRGB(0, 150, 255)
KeybindButton.Font = Enum.Font.Code
KeybindButton.TextSize = 14
KeybindButton.Parent = SettingsTabFrame

-- INTERFAZ COMPLEMENTARIA (CERRAR Y MINIMIZAR ORIGINALES)
-- =============================================================================
local FloatingCircle = Instance.new("TextButton")
FloatingCircle.Name = "FloatingCircle"
FloatingCircle.Size = UDim2.new(0, 50, 0, 50)
FloatingCircle.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatingCircle.BackgroundColor3 = Color3.fromRGB(212, 175, 55)
FloatingCircle.Text = "RP"
FloatingCircle.TextColor3 = Color3.fromRGB(30, 30, 30)
FloatingCircle.TextSize = 16
FloatingCircle.Font = Enum.Font.SourceSansBold
FloatingCircle.Visible = false
FloatingCircle.Active = true
FloatingCircle.Parent = ScreenGui

local UICorner_Circle = Instance.new("UICorner")
UICorner_Circle.CornerRadius = UDim.new(1, 0)
UICorner_Circle.Parent = FloatingCircle

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -65, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 14
MinimizeButton.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame
-- LÓGICA DE INTERACTIVIDAD DE BOTONES TOGGLE
-- =============================================================================
SilentToggle.MouseButton1Click:Connect(function()
silentAimEnabled = not silentAimEnabled
if silentAimEnabled then
SilentToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
SilentToggle.Text = "Silent Aim: ON"
SilentToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
else
SilentToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SilentToggle.Text = "Silent Aim: OFF"
SilentToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
end
end)
TriggerToggle.MouseButton1Click:Connect(function()
triggerbotEnabled = not triggerbotEnabled
if triggerbotEnabled then
TriggerToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
TriggerToggle.Text = "Triggerbot: ON"
TriggerToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
else
TriggerToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TriggerToggle.Text = "Triggerbot: OFF"
TriggerToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
end
end)
EspToggle.MouseButton1Click:Connect(function()
espEnabled = not espEnabled
if espEnabled then
EspToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
EspToggle.Text = "ESP Highlight: ON"
EspToggle.TextColor3 = Color3.fromRGB(100, 255, 100)
else
EspToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
EspToggle.Text = "ESP Highlight: OFF"
EspToggle.TextColor3 = Color3.fromRGB(255, 100, 100)
for _, player in pairs(Players:GetPlayers()) do
if player.Character and player.Character:FindFirstChild("EspHighlight") then
player.Character.EspHighlight:Destroy()
end
end
end
end)
-- ASIGNACIÓN DE TECLAS DE ACCESO RÁPIDO
KeybindButton.MouseButton1Click:Connect(function()
bindingMode = true
KeybindButton.Text = "[Presiona una tecla]"
KeybindButton.TextColor3 = Color3.fromRGB(255, 200, 0)
end)
UserInputService.InputBegan:Connect(function(input, processed)
if bindingMode then
if input.UserInputType == Enum.UserInputType.Keyboard then
menuKey = input.KeyCode
bindingMode = false
KeybindButton.Text = tostring(input.KeyCode.Name)
KeybindButton.TextColor3 = Color3.fromRGB(0, 150, 255)
end
return
end
if not processed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == menuKey then
menuVisible = not menuVisible
if not FloatingCircle.Visible then
MainFrame.Visible = menuVisible
end
end
end)
-- SISTEMA DRAGGABLE DE ARRASTRE
local function makeDraggable(guiElement)
local dragging, dragInput, dragStart, startPos
guiElement.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
dragging = true
dragStart = input.Position
startPos = guiElement.Position
input.Changed:Connect(function()
if input.UserInputState == Enum.UserInputState.End then dragging = false end
end)
end
end)
guiElement.InputChanged:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
dragInput = input
end
end)
UserInputService.InputChanged:Connect(function(input)
if input == dragInput and dragging then
local delta = input.Position - dragStart
guiElement.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
end)
end
makeDraggable(MainFrame)
makeDraggable(FloatingCircle)
-- MANEJO DE VENTANAS (OCULTAR, CERRAR)
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
MinimizeButton.MouseButton1Click:Connect(function()
MainFrame.Visible = false
FloatingCircle.Position = MainFrame.Position
FloatingCircle.Visible = true
end)
FloatingCircle.MouseButton1Click:Connect(function()
FloatingCircle.Visible = false
MainFrame.Position = FloatingCircle.Position
MainFrame.Visible = menuVisible
end)
-- PROCESADOR SEGMENTADO DE JUGADORES ANTI-LAG
task.spawn(function()
while true do
task.wait(0.1)
if silentAimEnabled or espEnabled then
local closestPlayer = nil
local shortestDistance = math.huge
local playersList = Players:GetPlayers()
for i = 1, #playersList do
local player = playersList[i]
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.Health > 0 then
local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
if onScreen then
local mousePos = UserInputService:GetMouseLocation()
local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
if distance < shortestDistance then
closestPlayer = player
shortestDistance = distance
end
end
end
end
end
targetEnemy = closestPlayer
end
end
end)
-- LÓGICA CORE: SISTEMA DE TRIGGERBOT AUTOMÁTICO ASÍNCRONO
task.spawn(function()
while true do
RunService.RenderStepped:Wait()
if triggerbotEnabled and Mouse.Target then
local targetObject = Mouse.Target
local characterModel = targetObject.Parent
local detectedPlayer = Players:GetPlayerFromCharacter(characterModel) or Players:GetPlayerFromCharacter(characterModel.Parent)
if detectedPlayer and detectedPlayer ~= LocalPlayer then
local humanoid = characterModel:FindFirstChildOfClass("Humanoid") or characterModel.Parent:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.Health > 0 then
-- Asegura compatibilidad ejecutando clics virtuales según la API de tu inyector
if mouse1click then
mouse1click()
elseif Input then
UserInputService:SimulateInput(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin)
task.wait()
UserInputService:SimulateInput(Enum.UserInputType.MouseButton1, Enum.UserInputState.End)
end
task.wait(0.05) -- Pequeño retraso para emular el tiempo de respuesta humano y evitar bloqueos
end
end
end
end
end)
-- HOOK DE DISPAROS (SILENT AIM METATABLE)
local success, err = pcall(function()
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, index)
if self == Mouse and silentAimEnabled and (index == "Hit" or index == "Target") then
if targetEnemy and targetEnemy.Character and targetEnemy.Character:FindFirstChild("Head") then
if index == "Hit" then return targetEnemy.Character.Head.CFrame
elseif index == "Target" then return targetEnemy.Character.Head end
end
end
return oldIndex(self, index)
end)
setreadonly(mt, true)
end)
-- ITERACIÓN SÍNCRONA DE RENDERIZADO PARA EL ESP HIGHLIGHT
RunService.RenderStepped:Connect(function()
if espEnabled then
for _, player in pairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
local char = player.Character
local highlight = char:FindFirstChild("EspHighlight")
if not highlight then
highlight = Instance.new("Highlight")
highlight.Name = "EspHighlight"
highlight.FillColor = Color3.fromRGB(255, 0, 0)
highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
highlight.FillTransparency = 0.5
highlight.OutlineTransparency = 0
highlight.Adornee = char
highlight.Parent = char
end
end
end
else
for _, player in pairs(Players:GetPlayers()) do
if player.Character then
local highlight = player.Character:FindFirstChild("EspHighlight")
if highlight then highlight:Destroy() end
end
end
end
end)
