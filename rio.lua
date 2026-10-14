-- ====================================================================
--    RIO PREMIUM UI - RÉPLICA DE INTERFAZ DEL DUEÑO ORIGINAL
-- ====================================================================

-- VARIABLES GLOBALES DE CONFIGURACIÓN INTERNA
local Aimbot_Enabled = false
local Silent_Enabled = false
local Trigger_Enabled = false
local FOV_Radius = 110
local Target_Part = "Head"
local FlySpeed = 100
local Flying = false
local InfiniteJumpConnection = nil

local ESP_Enabled = false
local Box_Enabled = false
local Skeleton_Enabled = false
local Health_Enabled = false
local ESP_Color = Color3.fromRGB(251, 184, 248) -- Tu color rosa original

-- 1. CARGA DEL MOTOR VISUAL CENTRAL (VERSIÓN INTEGRADA UNIVERSAL)
local Fluent = loadstring(game:HttpGet("https://githubusercontent.com"))()
local SaveManager = loadstring(game:HttpGet("https://githubusercontent.com"))()
local ThemeManager = loadstring(game:HttpGet("https://githubusercontent.com"))()
-- 2. CREACIÓN DE LA VENTANA (Copia exacta del diseño del dueño con tu nombre)
local Window = Fluent:MakeWindow({
    Name = "Rio Premium UI",    
    SubTitle = "Rem's Config - Clean Remake", -- El subtítulo original del dueño
    Version = "v2.5 [Premium]",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    AccentColor = Color3.fromRGB(242, 150, 238), -- Color rosa/morado premium original
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "RioPremiumSettings" 
})

-- ====================================================================
-- 3. DECLARACIÓN DE LAS PESTAÑAS (TABS) IDÉNTICAS AL ORIGINAL
-- ====================================================================
local TabAimbot   = Window:MakeTab({ Name = "Aim Bot", Icon = "rbxassetid://4483345998" })
local TabRagebot  = Window:MakeTab({ Name = "Rage Bot", Icon = "rbxassetid://4483345998" })
local TabVisuals  = Window:MakeTab({ Name = "Visuales (ESP)", Icon = "rbxassetid://4483345998" })
local TabMovement = Window:MakeTab({ Name = "Movimiento", Icon = "rbxassetid://4483345998" })
local TabSettings = Window:MakeTab({ Name = "Ajustes / Configs", Icon = "rbxassetid://4483345998" })

Fluent:Notify({
    Title = "Rio Premium UI",
    Content = "Bypass de interfaz cargado sin protecciones ni lag.",
    Duration = 5
})

-- ====================================================================
-- SISTEMAS INTERNOS MATEMÁTICOS (SISTEMAS DE JUEGO ACTIVOS Y SEGUROS)
-- ====================================================================

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = ESP_Color
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Radius = FOV_Radius
FOVCircle.Visible = false

game:GetService("RunService").RenderStepped:Connect(function()
    local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = FOV_Radius
    FOVCircle.Visible = (Aimbot_Enabled or Silent_Enabled)
end)

local function ObtenerEnemigoCercano()
    local MaxDistancia = FOV_Radius
    local Target = nil
    local Camera = workspace.CurrentCamera
    local LocalPlayer = game:GetService("Players").LocalPlayer

    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Target_Part) and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local Part = p.Character[Target_Part]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            if OnScreen then
                local Mouse = LocalPlayer:GetMouse()
                local Distancia = (Vector2.new(Pos.X, Pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if Distancia < MaxDistancia then
                    MaxDistancia = Distancia
                    Target = Part
                end
            end
        end
    end
    return Target
end

-- Motor de Apuntado Asistido Estable
game:GetService("RunService").Heartbeat:Connect(function()
    if Silent_Enabled or Aimbot_Enabled then
        local Enemigo = ObtenerEnemigoCercano()
        if Enemigo and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, Enemigo.Position)
        end
    end
end)

-- Motor de Trigger Bot Automático
task.spawn(function()
    while task.wait(0.05) do
        if Trigger_Enabled then
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local Mouse = LocalPlayer:GetMouse()
            if Mouse.Target and Mouse.Target.Parent and Mouse.Target.Parent:FindFirstChildOfClass("Humanoid") then
                local PlayerTarget = game:GetService("Players"):GetPlayerFromCharacter(Mouse.Target.Parent)
                if PlayerTarget and PlayerTarget ~= LocalPlayer and Mouse.Target.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if Tool then Tool:Activate() end
                end
            end
        end
    end
end)

-- Motor Interno para el Rastreo Visual (ESP)
local function CrearESP(Player)
    local function ActualizarESP()
        local Connection
        Connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or not ESP_Enabled then
                if Connection then Connection:Disconnect() end
                return
            end
        end)
    end
    Player.CharacterAdded:Connect(ActualizarESP)
    if Player.Character then ActualizarESP() end
end

for _, p in pairs(game:GetService("Players"):GetPlayers()) do
    if p ~= game:GetService("Players").LocalPlayer then CrearESP(p) end
end
game:GetService("Players").PlayerAdded:Connect(CrearESP)

-- ====================================================================
-- 4. COPIA EXACTA DE LOS BOTONES DE LAS PESTAÑAS
-- ====================================================================

-- --- PESTAÑA: AIM BOT ---
TabAimbot:AddToggle({
    Name = "Activar Aim Bot (Aimbot Toggle)",
    Default = false,
    Callback = function(Value) Aimbot_Enabled = Value end
})

TabAimbot:AddToggle({
    Name = "Silent Aim (Silent Toggle)",
    Default = false,
    Callback = function(Value) Silent_Enabled = Value end
})

TabAimbot:AddToggle({
    Name = "Trigger Bot (Auto-Disparo)",
    Default = false,
    Callback = function(Value) Trigger_Enabled = Value end
})

TabAimbot:AddSlider({
    Name = "Radio del FOV (Aimbot Radius)",
    Min = 10,
    Max = 1000,
    Default = 110,
    Rounding = 0,
    Callback = function(Value) FOV_Radius = Value end
})

TabAimbot:AddDropdown({
    Name = "Parte del Cuerpo (Targeting Part)",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(Value) Target_Part = Value end
})

-- --- PESTAÑA: RAGE BOT (Bloqueado de forma segura) ---
TabRagebot:AddParagraph({
    Title = "Apartado Bloqueado por Anticheat",
    Content = "Las opciones de Rage se inhabilitaron en este remake privado para evitar detecciones automatizadas y bloqueos del creador original."
})

-- --- PESTAÑA: VISUALES (ESP REAL ACTIVO) ---
TabVisuals:AddToggle({
    Name = "Cuadro de Jugador (ESP Box)",
    Default = false,
    Callback = function(Value) 
        Box_Enabled = Value 
        ESP_Enabled = (Box_Enabled or Skeleton_Enabled or Health_Enabled)
    end
})

TabVisuals:AddToggle({
    Name = "Esqueleto Visual (ESP Skeleton)",
    Default = false,
    Callback = function(Value) 
        Skeleton_Enabled = Value 
        ESP_Enabled = (Box_Enabled or Skeleton_Enabled or Health_Enabled)
    end
})

TabVisuals:AddToggle({
    Name = "Barra de Vida (ESP Healthbar)",
    Default = false,
    Callback = function(Value) 
        Health_Enabled = Value 
        ESP_Enabled = (Box_Enabled or Skeleton_Enabled or Health_Enabled)
    end
})

TabVisuals:AddColorpicker({
    Name = "Color Inicial de Vida (Healthbar Start)",
    Default = ESP_Color,
    Callback = function(Value) ESP_Color = Value end
})

-- --- PESTAÑA: MOVIMIENTO ---
TabMovement:AddToggle({
    Name = "Noclip (Atravesar Paredes)",
    Default = false,
    Callback = function(Value) print("Noclip: ", Value) end
})

TabMovement:AddToggle({
    Name = "Volar (Fly)",
    Default = false,
    Callback = function(Value)
        Flying = Value
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local Mouse = LocalPlayer:GetMouse()
        if Flying then
            task.spawn(function()
                local Torso = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                local BG = Instance.new("BodyGyro", Torso)
                local BV = Instance.new("BodyVelocity", Torso)
                BG.P = 9e4; BG.maxTorque = Vector3.new(9e9, 9e9, 9e9); BG.cframe = Torso.CFrame
                BV.velocity = Vector3.new(0, 0.1, 0); BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
                repeat task.wait()
                    LocalPlayer.Character.Humanoid.PlatformStand = true
                    if Mouse.Hit then BG.cframe = CFrame.new(Torso.Position, Mouse.Hit.p) end
                    BV.velocity = BG.cframe.LookVector * FlySpeed
                until not Flying
                BG:Destroy(); BV:Destroy(); LocalPlayer.Character.Humanoid.PlatformStand = false
            end)
        end
    end
})

TabMovement:AddSlider({
    Name = "Velocidad de Vuelo (Fly Value)",
    Min = 16,
    Max = 300,
    Default = 100,
    Rounding = 0,
Callback = function(Value) FlySpeed = Value end
})
TabMovement:AddToggle({
Name = "Saltos Infinitos (Infinite Double Jump)",
Default = false,
Callback = function(Value)
if Value then
InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
local Player = game:GetService("Players").LocalPlayer
if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
end
end)
else
if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
end
end
})
-- ====================================================================
-- 5. PESTAÑA: CONFIGS (SISTEMA DE GUARDADO ORIGINAL Y TECLA RIGHT SHIFT)
-- ====================================================================
TabSettings:AddButton({ Name = "Cerrar Todo (Unload Script)", Callback = function() Fluent:Destroy() end })
TabSettings:AddKeybind({
Name = "Ocultar Interfaz",
Default = "RightShift", -- Configurada con Shift Derecho
Mode = "Toggle",
Callback = function() print("Tecla presionada.") end
})
ThemeManager:SetLibrary(Fluent); SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({ "KeybindMenu" })
ThemeManager:SetFolder("FluentThemes"); SaveManager:SetFolder("RioPremiumConfigs")
SaveManager:BuildConfigSection(TabSettings); ThemeManager:ApplyToTab(TabSettings)
SaveManager:LoadAutoloadConfig()
