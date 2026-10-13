-- SERVICIOS DE ROBLOX
-- =============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CONFIGURACIÓN DE LA INTERFAZ (GUI)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioPremiumGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999999 
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 10)
UICorner_Main.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Rio Premium"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Parent = MainFrame

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(1, 0)
UICorner_Close.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.Parent = MainFrame

local UICorner_Min = Instance.new("UICorner")
UICorner_Min.CornerRadius = UDim.new(1, 0)
UICorner_Min.Parent = MinimizeButton

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

-- Botón 1: Aimbot Cámara
local AimButton = Instance.new("TextButton")
AimButton.Size = UDim2.new(0, 270, 0, 40)
AimButton.Position = UDim2.new(0, 15, 0, 60)
AimButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AimButton.Text = "AIMBOT (CÁMARA): OFF"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.TextSize = 15
AimButton.Font = Enum.Font.SourceSansBold
AimButton.Parent = MainFrame

local UICorner_Aim = Instance.new("UICorner")
UICorner_Aim.Parent = AimButton

-- Botón 2: Silent Aim
local SilentButton = Instance.new("TextButton")
SilentButton.Size = UDim2.new(0, 270, 0, 40)
SilentButton.Position = UDim2.new(0, 15, 0, 115)
SilentButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SilentButton.Text = "SILENT AIM: OFF"
SilentButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentButton.TextSize = 15
SilentButton.Font = Enum.Font.SourceSansBold
SilentButton.Parent = MainFrame

local UICorner_Silent = Instance.new("UICorner")
UICorner_Silent.Parent = SilentButton

-- Botón 3: ESP Highlight
local EspButton = Instance.new("TextButton")
EspButton.Size = UDim2.new(0, 270, 0, 40)
EspButton.Position = UDim2.new(0, 15, 0, 170)
EspButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
EspButton.Text = "ESP HIGHLIGHT: OFF"
EspButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EspButton.TextSize = 15
EspButton.Font = Enum.Font.SourceSansBold
EspButton.Parent = MainFrame

local UICorner_Esp = Instance.new("UICorner")
UICorner_Esp.Parent = EspButton

-- LÓGICA DE ARRASTRE (DRAGGABLE SYSTEM)
-- =============================================================================
local function makeDraggable(guiElement)
    local dragging, dragInput, dragStart, startPos
    guiElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiElement.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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

-- LÓGICA DE VENTANAS (ABRIR, CERRAR, MINIMIZAR)
-- =============================================================================
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatingCircle.Position = MainFrame.Position
    FloatingCircle.Visible = true
end)

FloatingCircle.MouseButton1Click:Connect(function()
    FloatingCircle.Visible = false
    MainFrame.Position = FloatingCircle.Position
    MainFrame.Visible = true
end)

-- CONTROLES Y CONFIGURACIÓN DE FUNCIONES
-- =============================================================================
local aimbotEnabled = false
local silentAimEnabled = false
local espEnabled = false
local holdsRightClick = false
local targetEnemy = nil

AimButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        AimButton.Text = "AIMBOT (CÁMARA): ON"
    else
        AimButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        AimButton.Text = "AIMBOT (CÁMARA): OFF"
    end
end)

SilentButton.MouseButton1Click:Connect(function()
    silentAimEnabled = not silentAimEnabled
    if silentAimEnabled then
        SilentButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        SilentButton.Text = "SILENT AIM: ON"
    else
        SilentButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SilentButton.Text = "SILENT AIM: OFF"
    end
end)

EspButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        EspButton.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        EspButton.Text = "ESP HIGHLIGHT: ON"
    else
        EspButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        EspButton.Text = "ESP HIGHLIGHT: OFF"
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("EspHighlight") then
                player.Character.EspHighlight:Destroy()
            end
        end
    end
end)

-- Detectar pulsación de clic derecho para el aimbot tradicional
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdsRightClick = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdsRightClick = false
    end
end)

-- Obtener el enemigo más cercano a la mira (Optimizado para hilos externos)
task.spawn(function()
    while true do
        task.wait(0.1)
        if aimbotEnabled or silentAimEnabled or espEnabled then
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

-- =============================================================================
local success, err = pcall(function()
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, index)
if self == Mouse and silentAimEnabled and (index == "Hit" or index == "Target") then
if targetEnemy and targetEnemy.Character and targetEnemy.Character:FindFirstChild("Head") then
if index == "Hit" then
return targetEnemy.Character.Head.CFrame
elseif index == "Target" then
return targetEnemy.Character.Head
end
end
end
return oldIndex(self, index)
end)
setreadonly(mt, true)
end)
-- BUCLE PRINCIPAL (RENDERSTEPPED) - CONTROL DE CÁMARA Y ESP HIGHLIGHT
-- =============================================================================
RunService.RenderStepped:Connect(function()
-- 1. Lógica del Aimbot de Cámara tradicional
if aimbotEnabled and holdsRightClick and targetEnemy then
if targetEnemy.Character and targetEnemy.Character:FindFirstChild("Head") then
Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetEnemy.Character.Head.Position)
end
end
-- 2. Fragmento final solicitado (Sin espacios a la izquierda) para el ESP
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
if highlight then
highlight:Destroy()
end
end
end
end
end)
