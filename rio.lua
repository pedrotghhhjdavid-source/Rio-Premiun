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

-- ESTADOS DE LAS FUNCIONES EXISTENTES
-- =============================================================================
local silentAimEnabled = false
local triggerbotEnabled = false
local espEnabled = false
local targetEnemy = nil

-- CREACIÓN DE INTERFAZ INTEGRAL ESTILO UNNAMED (TEMA: NEGRO Y ROJO)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioPremiumGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Contenedor Principal (Tamaño real Unnamed, Fondo Negro Oscuro)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 420)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Negro Profundo
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(35, 35, 35) -- Bordes finos oscuros
MainFrame.Active = true
MainFrame.Visible = menuVisible
MainFrame.Parent = ScreenGui

-- Línea de borde acentuada ROJA en la parte superior (Reemplazo del azul)
local TopAccent = Instance.new("Frame")
TopAccent.Size = UDim2.new(1, 0, 0, 2)
TopAccent.BackgroundColor3 = Color3.fromRGB(220, 20, 20) -- Rojo Premium
TopAccent.BorderSizePixel = 0
TopAccent.Parent = MainFrame

-- Título Principal (Rio Premium dorado como querías conservar)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 2)
Title.BackgroundTransparency = 1
Title.Text = "Rio Premium"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 15
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Subtítulo lateral Unnamed Enhancements
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(0, 200, 0, 35)
Subtitle.Position = UDim2.new(1, -215, 0, 2)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Unnamed Enhancements - Cracked"
Subtitle.TextColor3 = Color3.fromRGB(100, 100, 100)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Code
Subtitle.TextXAlignment = Enum.TextXAlignment.Right
Subtitle.Parent = MainFrame

-- SISTEMA DE NAVEGACIÓN POR PESTAÑAS (TAB BAR BARRA SUPERIOR)
-- =============================================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 26)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TabBar.BorderSizePixel = 1
TabBar.BorderColor3 = Color3.fromRGB(35, 35, 35)
TabBar.Parent = MainFrame

-- Marcos de contenido para las páginas
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

-- Botones del Menú de Pestañas
local MainTabButton = Instance.new("TextButton")
MainTabButton.Size = UDim2.new(0, 75, 1, 0)
MainTabButton.Position = UDim2.new(0, 0, 0, 0)
MainTabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainTabButton.Text = "main"
MainTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainTabButton.Font = Enum.Font.Code
MainTabButton.TextSize = 13
MainTabButton.BorderSizePixel = 0
MainTabButton.Parent = TabBar

local EspTabButton = Instance.new("TextButton")
EspTabButton.Size = UDim2.new(0, 75, 1, 0)
EspTabButton.Position = UDim2.new(0, 76, 0, 0)
EspTabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
EspTabButton.Text = "esp"
EspTabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
EspTabButton.Font = Enum.Font.Code
EspTabButton.TextSize = 13
EspTabButton.BorderSizePixel = 0
EspTabButton.Parent = TabBar

local SettingsTabButton = Instance.new("TextButton")
SettingsTabButton.Size = UDim2.new(0, 75, 1, 0)
SettingsTabButton.Position = UDim2.new(0, 152, 0, 0)
SettingsTabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SettingsTabButton.Text = "settings"
SettingsTabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
SettingsTabButton.Font = Enum.Font.Code
SettingsTabButton.TextSize = 13
SettingsTabButton.BorderSizePixel = 0
SettingsTabButton.Parent = TabBar

-- Lógica para intercambiar las páginas
local function updateTabs(activeButton, activeFrame)
    MainTabFrame.Visible = false
    EspTabFrame.Visible = false
    SettingsTabFrame.Visible = false
    MainTabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    MainTabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
    EspTabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    EspTabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
    SettingsTabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    SettingsTabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
    
    activeFrame.Visible = true
    activeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    activeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
end

MainTabButton.MouseButton1Click:Connect(function() updateTabs(MainTabButton, MainTabFrame) end)
EspTabButton.MouseButton1Click:Connect(function() updateTabs(EspTabButton, EspTabFrame) end)
SettingsTabButton.MouseButton1Click:Connect(function() updateTabs(SettingsTabButton, SettingsTabFrame) end)


-- DISEÑO DE RECUADROS POR COLUMNAS (MÉTODO UNNAMED EXACTO)
-- =============================================================================

-- COLUMNA IZQUIERDA: Sección Targeting (Silent Aim)
local LeftSection = Instance.new("Frame")
LeftSection.Name = "LeftSection"
LeftSection.Size = UDim2.new(0, 260, 1, -10)
LeftSection.Position = UDim2.new(0, 0, 0, 5)
LeftSection.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
LeftSection.BorderSizePixel = 1
LeftSection.BorderColor3 = Color3.fromRGB(35, 35, 35)
LeftSection.Parent = MainTabFrame

local LeftSectionTitle = Instance.new("TextLabel")
LeftSectionTitle.Size = UDim2.new(1, -10, 0, 25)
LeftSectionTitle.Position = UDim2.new(0, 8, 0, 2)
LeftSectionTitle.BackgroundTransparency = 1
LeftSectionTitle.Text = "targeting"
LeftSectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
LeftSectionTitle.Font = Enum.Font.Code
LeftSectionTitle.TextSize = 13
LeftSectionTitle.TextXAlignment = Enum.TextXAlignment.Left
LeftSectionTitle.Parent = LeftSection

-- Checkbox de Silent Aim (Estilo Linoria funcional)
local SilentIndicator = Instance.new("Frame")
SilentIndicator.Size = UDim2.new(0, 12, 0, 12)
SilentIndicator.Position = UDim2.new(0, 15, 0, 40)
SilentIndicator.BackgroundColor3 = Color3.fromRGB(40, 15, 15) -- Rojo apagado
SilentIndicator.BorderSizePixel = 1
SilentIndicator.BorderColor3 = Color3.fromRGB(80, 20, 20)
SilentIndicator.Parent = LeftSection

local SilentLabel = Instance.new("TextButton")
SilentLabel.Size = UDim2.new(1, -40, 0, 20)
SilentLabel.Position = UDim2.new(0, 35, 0, 36)
SilentLabel.BackgroundTransparency = 1
SilentLabel.Text = "Silent Aim"
SilentLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
SilentLabel.Font = Enum.Font.Code
SilentLabel.TextSize = 13
SilentLabel.TextXAlignment = Enum.TextXAlignment.Left
SilentLabel.Parent = LeftSection


-- COLUMNA DERECHA: Sección Weapons (Triggerbot)
local RightSection = Instance.new("Frame")
RightSection.Name = "RightSection"
RightSection.Size = UDim2.new(0, 260, 1, -10)
RightSection.Position = UDim2.new(1, -260, 0, 5)
RightSection.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
RightSection.BorderSizePixel = 1
RightSection.BorderColor3 = Color3.fromRGB(35, 35, 35)
RightSection.Parent = MainTabFrame

local RightSectionTitle = Instance.new("TextLabel")
RightSectionTitle.Size = UDim2.new(1, -10, 0, 25)
RightSectionTitle.Position = UDim2.new(0, 8, 0, 2)
RightSectionTitle.BackgroundTransparency = 1
RightSectionTitle.Text = "weapons"
RightSectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
RightSectionTitle.Font = Enum.Font.Code
RightSectionTitle.TextSize = 13
RightSectionTitle.TextXAlignment = Enum.TextXAlignment.Left
RightSectionTitle.Parent = RightSection

-- Checkbox de Triggerbot (Estilo Linoria funcional al extremo derecho)
local TriggerIndicator = Instance.new("Frame")
TriggerIndicator.Size = UDim2.new(0, 12, 0, 12)
TriggerIndicator.Position = UDim2.new(0, 15, 0, 40)
TriggerIndicator.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
TriggerIndicator.BorderSizePixel = 1
TriggerIndicator.BorderColor3 = Color3.fromRGB(80, 20, 20)
TriggerIndicator.Parent = RightSection

local TriggerLabel = Instance.new("TextButton")
TriggerLabel.Size = UDim2.new(1, -40, 0, 20)
TriggerLabel.Position = UDim2.new(0, 35, 0, 36)
TriggerLabel.BackgroundTransparency = 1
TriggerLabel.Text = "Triggerbot"
TriggerLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
TriggerLabel.Font = Enum.Font.Code
TriggerLabel.TextSize = 13
TriggerLabel.TextXAlignment = Enum.TextXAlignment.Left
TriggerLabel.Parent = RightSection


-- CONFIGURACIÓN PESTAÑA ESP (ESTILO RECUADRO BOX COMPLETO)
-- =============================================================================
local EspSection = Instance.new("Frame")
EspSection.Size = UDim2.new(1, 0, 1, -10)
EspSection.Position = UDim2.new(0, 0, 0, 5)
EspSection.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
EspSection.BorderSizePixel = 1
EspSection.BorderColor3 = Color3.fromRGB(35, 35, 35)
EspSection.Parent = EspTabFrame
local EspSectionTitle = Instance.new("TextLabel")
EspSectionTitle.Size = UDim2.new(1, -10, 0, 25)
EspSectionTitle.Position = UDim2.new(0, 8, 0, 2)
EspSectionTitle.BackgroundTransparency = 1
EspSectionTitle.Text = "visuals & esp"
EspSectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
EspSectionTitle.Font = Enum.Font.Code
EspSectionTitle.TextSize = 13
EspSectionTitle.TextXAlignment = Enum.TextXAlignment.Left
EspSectionTitle.Parent = EspSection
local EspIndicator = Instance.new("Frame")
EspIndicator.Size = UDim2.new(0, 12, 0, 12)
EspIndicator.Position = UDim2.new(0, 15, 0, 40)
EspIndicator.BackgroundColor3 = Color3.fromRGB(40, 15, 15)
EspIndicator.BorderSizePixel = 1
EspIndicator.BorderColor3 = Color3.fromRGB(80, 20, 20)
EspIndicator.Parent = EspSection
local EspLabel = Instance.new("TextButton")
EspLabel.Size = UDim2.new(1, -40, 0, 20)
EspLabel.Position = UDim2.new(0, 35, 0, 36)
EspLabel.BackgroundTransparency = 1
EspLabel.Text = "ESP Highlight"
EspLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
EspLabel.Font = Enum.Font.Code
EspLabel.TextSize = 13
EspLabel.TextXAlignment = Enum.TextXAlignment.Left
EspLabel.Parent = EspSection
-- CONFIGURACIÓN PESTAÑA SETTINGS (RECUADRO KEYBINDS)
-- =============================================================================
local SettingsSection = Instance.new("Frame")
SettingsSection.Size = UDim2.new(1, 0, 1, -10)
SettingsSection.Position = UDim2.new(0, 0, 0, 5)
SettingsSection.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
SettingsSection.BorderSizePixel = 1
SettingsSection.BorderColor3 = Color3.fromRGB(35, 35, 35)
SettingsSection.Parent = SettingsTabFrame
local SettingsSectionTitle = Instance.new("TextLabel")
SettingsSectionTitle.Size = UDim2.new(1, -10, 0, 25)
SettingsSectionTitle.Position = UDim2.new(0, 8, 0, 2)
SettingsSectionTitle.BackgroundTransparency = 1
SettingsSectionTitle.Text = "menu & keybinds"
SettingsSectionTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsSectionTitle.Font = Enum.Font.Code
SettingsSectionTitle.TextSize = 13
SettingsSectionTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsSectionTitle.Parent = SettingsSection
local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(0, 200, 0, 30)
KeybindLabel.Position = UDim2.new(0, 15, 0, 40)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Menu Key (Toggle):"
KeybindLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
KeybindLabel.Font = Enum.Font.Code
KeybindLabel.TextSize = 13
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.Parent = SettingsSection
local KeybindButton = Instance.new("TextButton")
KeybindButton.Size = UDim2.new(0, 130, 0, 24)
KeybindButton.Position = UDim2.new(0, 180, 0, 43)
KeybindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
KeybindButton.BorderSizePixel = 1
KeybindButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
KeybindButton.Text = "RightShift"
KeybindButton.TextColor3 = Color3.fromRGB(220, 20, 20) -- Texto del botón Rojo
KeybindButton.Font = Enum.Font.Code
KeybindButton.TextSize = 13
KeybindButton.Parent = SettingsSection
-- ELEMENTOS ADICIONALES REQUERIDOS (MINIMIZAR, CERRAR Y CÍRCULO ORIGINAL)
-- =============================================================================
local FloatingCircle = Instance.new("TextButton")
FloatingCircle.Name = "FloatingCircle"
FloatingCircle.Size = UDim2.new(0, 50, 0, 50)
FloatingCircle.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatingCircle.BackgroundColor3 = Color3.fromRGB(212, 175, 55) -- Preserva inicial dorado
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
MinimizeButton.Size = UDim2.new(0, 22, 0, 22)
MinimizeButton.Position = UDim2.new(1, -60, 0, 6)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeButton.BorderSizePixel = 1
MinimizeButton.BorderColor3 = Color3.fromRGB(45, 45, 45)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 13
MinimizeButton.Parent = MainFrame
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 22, 0, 22)
CloseButton.Position = UDim2.new(1, -30, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(40, 15, 15) -- Fondo de cierre Rojo Oscuro
CloseButton.BorderSizePixel = 1
CloseButton.BorderColor3 = Color3.fromRGB(80, 20, 20)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 13
CloseButton.Parent = MainFrame
-- LÓGICA DE INTERRUPTORES ASÍNCROOS (CHECKBOX TOGGLES INTERNOS)
-- =============================================================================
local function toggleState(state, indicator, label, textOn, textOff)
if state then
indicator.BackgroundColor3 = Color3.fromRGB(220, 20, 20) -- Rojo vivo al encender
indicator.BorderColor3 = Color3.fromRGB(255, 50, 50)
label.TextColor3 = Color3.fromRGB(255, 255, 255)
else
indicator.BackgroundColor3 = Color3.fromRGB(40, 15, 15) -- Rojo oscuro al apagar
indicator.BorderColor3 = Color3.fromRGB(80, 20, 20)
label.TextColor3 = Color3.fromRGB(160, 160, 160)
end
end
SilentLabel.MouseButton1Click:Connect(function()
silentAimEnabled = not silentAimEnabled
toggleState(silentAimEnabled, SilentIndicator, SilentLabel)
end)
TriggerLabel.MouseButton1Click:Connect(function()
triggerbotEnabled = not triggerbotEnabled
toggleState(triggerbotEnabled, TriggerIndicator, TriggerLabel)
end)
EspLabel.MouseButton1Click:Connect(function()
espEnabled = not espEnabled
toggleState(espEnabled, EspIndicator, EspLabel)
if not espEnabled then
for _, player in pairs(Players:GetPlayers()) do
if player.Character and player.Character:FindFirstChild("EspHighlight") then
player.Character.EspHighlight:Destroy()
end
end
end
end)
-- ASIGNACIÓN DE KEYBINDS INTERNA
-- =============================================================================
KeybindButton.MouseButton1Click:Connect(function()
bindingMode = true
KeybindButton.Text = "[Key]"
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 0)
end)
UserInputService.InputBegan:Connect(function(input, processed)
if bindingMode then
if input.UserInputType == Enum.UserInputType.Keyboard then
menuKey = input.KeyCode
bindingMode = false
KeybindButton.Text = tostring(input.KeyCode.Name)
KeybindButton.TextColor3 = Color3.fromRGB(220, 20, 20)
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
-- ARRASTRE DE COMPONENTES CON MOUSE (DRAGGABLE)
-- =============================================================================
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
-- CONTROLADORES DE PANTALLA (ABRIR, CERRAR, MINIMIZAR)
-- =============================================================================
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
-- SCANNER DE OPONENTES SEGURO (ANTI-LAG EN HILO INDEPENDIENTE)
-- =============================================================================
local function getClosestEnemy()
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
return closestPlayer
end
task.spawn(function()
while true do
task.wait(0.1)
if silentAimEnabled or espEnabled then
targetEnemy = getClosestEnemy()
end
end
end)
-- SCRIPT CORE: CONTROL DE AUTOMATIZACIÓN DE DISPAROS (TRIGGERBOT ANTI-CRASH)
-- =============================================================================
task.spawn(function()
while true do
task.wait(0.02)
if triggerbotEnabled and Mouse.Target then
pcall(function()
local targetObject = Mouse.Target
local characterModel = targetObject.Parent
local detectedPlayer = Players:GetPlayerFromCharacter(characterModel) or Players:GetPlayerFromCharacter(characterModel.Parent)
if detectedPlayer and detectedPlayer ~= LocalPlayer then
local humanoid = characterModel:FindFirstChildOfClass("Humanoid") or characterModel.Parent:FindFirstChildOfClass("Humanoid")
if humanoid and humanoid.Health > 0 then
if mouse1click then
mouse1click()
else
UserInputService:SimulateInput(Enum.UserInputType.MouseButton1, Enum.UserInputState.Begin)
task.wait()
UserInputService:SimulateInput(Enum.UserInputType.MouseButton1, Enum.UserInputState.End)
end
task.wait(0.08)
end
end
end)
end
end
end)
-- HOOK DE REDIRECCIÓN DE BALAS (SILENT AIM METATABLE)
-- =============================================================================
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
-- PROCESAMIENTO RENDERSTEPPED (VISUALIZACIÓN DEL ESP HIGHLIGHT DE ENEMY)
-- =============================================================================
RunService.RenderStepped:Connect(function()
if espEnabled then
local playersList = Players:GetPlayers()
for i = 1, #playersList do
local player = playersList[i]
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
