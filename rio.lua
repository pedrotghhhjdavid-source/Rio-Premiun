-- ====================================================================
--         Unnamed Enhancements - RÉPLICA EXACTA LIMPIA (2026)
-- ====================================================================

-- 1. CARGAR MOTOR VISUAL Y COMPLEMENTOS DESDE EL REPOSITORIO OFICIAL
local Fluent = loadstring(game:HttpGet("https://github.com"))()
local SaveManager = loadstring(game:HttpGet("https://githubusercontent.com"))()
local ThemeManager = loadstring(game:HttpGet("https://githubusercontent.com"))()

-- 2. CREACIÓN Y DISEÑO DE LA VENTANA PRINCIPAL
local Window = Fluent:MakeWindow({
    Name = "Unnamed Enhancements",    -- Nombre idéntico a la réplica
    SubTitle = "Rem's Config - Clean Remake",
    Version = "v2.0 [Premium]",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    AccentColor = Color3.fromRGB(242, 150, 238), -- Color rosa/morado de tu configuración original
    HidePremium = true,
    SaveConfig = true,
    ConfigFolder = "FluentSettings" -- Carpeta donde se guardarán tus configuraciones
})

-- ====================================================================
-- 3. DECLARACIÓN DE LAS PESTAÑAS (TABS) DEL MENÚ
-- ====================================================================
local TabAimbot   = Window:MakeTab({ Name = "Aim Bot", Icon = "rbxassetid://4483345998" })
local TabRagebot  = Window:MakeTab({ Name = "Rage Bot", Icon = "rbxassetid://4483345998" })
local TabVisuals  = Window:MakeTab({ Name = "Visuales (ESP)", Icon = "rbxassetid://4483345998" })
local TabMovement = Window:MakeTab({ Name = "Movimiento", Icon = "rbxassetid://4483345998" })
local TabSettings = Window:MakeTab({ Name = "Ajustes", Icon = "rbxassetid://4483345998" })

-- Alerta de inyección en pantalla
Fluent:Notify({
    Title = "Unnamed Enhancements Remake",
    Content = "Bypass de interfaz cargado sin protecciones ni lag.",
    Duration = 5
})

-- ====================================================================
-- 4. PESTAÑA: AIM BOT (Réplica de opciones de puntería legítima)
-- ====================================================================
TabAimbot:AddToggle({
    Name = "Activar Aim Bot (Aimbot Toggle)",
    Default = false,
    Callback = function(Value)
        print("Aim Bot cambiado a: ", Value)
    end
})

TabAimbot:AddToggle({
    Name = "Silent Aim (Silent Toggle)",
    Default = true,
    Callback = function(Value)
        print("Silent Aim cambiado a: ", Value)
    end
})

TabAimbot:AddSlider({
    Name = "Radio del FOV (Aimbot Radius)",
    Min = 10,
    Max = 1000,
    Default = 110, -- Mismo radio por defecto que tu script original
    Rounding = 0,
    Callback = function(Value)
        print("FOV Radio ajustado a: " .. Value)
    end
})

TabAimbot:AddDropdown({
    Name = "Parte del Cuerpo (Targeting Part)",
    Options = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(Value)
        print("Objetivo fijado en: " .. Value)
    end
})

-- ====================================================================
-- 5. PESTAÑA: RAGE BOT (Réplica de opciones hiper-agresivas)
-- ====================================================================
TabRagebot:AddToggle({
    Name = "Habilitar Ragebot",
    Default = false,
    Callback = function(Value)
        print("Ragebot Estado: ", Value)
    end
})

TabRagebot:AddToggle({
    Name = "Disparo en Vacío (Void Spam)",
    Default = true,
    Callback = function(Value)
        print("Void Spam cambiado a: ", Value)
    end
})

TabRagebot:AddSlider({
    Name = "Multiplicador de Cadencia (Firerate)",
    Min = 1,
    Max = 100,
    Default = 15, -- Valor extraído exactamente del config del script
    Rounding = 0,
    Callback = function(Value)
        print("Cadencia de disparo: " .. Value)
    end
})

-- ====================================================================
-- 6. PESTAÑA: VISUALES (ESP de jugadores extraído del código)
-- ====================================================================
TabVisuals:AddToggle({
    Name = "Cuadro de Jugador (ESP Box)",
    Default = false,
    Callback = function(Value)
        print("ESP Box cambiado a: ", Value)
    end
})

TabVisuals:AddToggle({
    Name = "Esqueleto Visual (ESP Skeleton)",
    Default = true,
    Callback = function(Value)
        print("ESP Skeleton cambiado a: ", Value)
    end
})

TabVisuals:AddToggle({
    Name = "Barra de Vida (ESP Healthbar)",
    Default = true,
    Callback = function(Value)
        print("ESP Healthbar cambiado a: ", Value)
    end
})

-- Selector de color integrado idéntico para el ESP
TabVisuals:AddColorpicker({
    Name = "Color Inicial de Vida (Healthbar Start)",
    Default = Color3.fromRGB(251, 184, 248), -- Tono rosa de tu config
    Callback = function(Value)
        print("Color de Vida modificado a: ", Value)
    end
})

-- ====================================================================
-- 7. PESTAÑA: MOVIMIENTO (Ajustes de físicas del jugador)
-- ====================================================================
TabMovement:AddToggle({
    Name = "Noclip (Atravesar Paredes)",
    Default = true,
    Callback = function(Value)
        print("Noclip cambiado a: ", Value)
    end
})

TabMovement:AddToggle({
    Name = "Volar (Fly)",
    Default = true,
    Callback = function(Value)
        print("Vuelo cambiado a: ", Value)
    end
})

TabMovement:AddToggle({
    Name = "Saltos Infinitos (Infinite Double Jump)",
    Default = true,
    Callback = function(Value)
        print("Salto Infinito cambiado a: ", Value)
    end
})

TabMovement:AddSlider({
    Name = "Velocidad de Vuelo (Fly Value)",
    Min = 16,
    Max = 500,
    Default = 100,
    Rounding = 0,
    Callback = function(Value)
        print("Velocidad de vuelo ajustada a: " .. Value)
    end
})

-- ====================================================================
-- 8. PESTAÑA: AJUSTES (Sistemas de Temas y Guardado Automático)
-- ====================================================================

-- Botón para cerrar la UI de forma limpia
TabSettings:AddButton({
    Name = "Cerrar Todo (Unload Script)",
    Callback = function()
        Fluent:Destroy()
    end
})

-- Tecla rápida de activación/ocultación (Keybind)
TabSettings:AddKeybind({
    Name = "Ocultar Interfaz",
    Default = "RightControl",
    Mode = "Toggle", 
    Callback = function(Value)
        print("Tecla de menú presionada.")
    end
})

-- CONEXIÓN DIRECTA CON LOS ADMINISTRADORES DE SYSTEMAS DE FLUENT UI
ThemeManager:SetLibrary(Fluent)
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "KeybindMenu" })
ThemeManager:SetFolder("FluentThemes")
SaveManager:SetFolder("FluentConfigs")

-- Esto creará automáticamente los botones de "Guardar Configuración", "Cargar Configuración"
-- y los selectores de Temas visuales dentro de tu pestaña de Ajustes.
SaveManager:BuildConfigSection(TabSettings)
ThemeManager:ApplyToTab(TabSettings)

SaveManager:LoadAutoloadConfig()
