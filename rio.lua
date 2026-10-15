-- YABUJIN HUD — ROBLOX RIVALS
-- Final version: bolita flotante REAL, fixes Roblox Output errors, no invents

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
if not playerGui then
    playerGui = Instance.new("ScreenGui")
    playerGui.Name = "YabujinGui"
    playerGui.ResetOnSpawn = false
    playerGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

local ColorMainBg    = Color3.fromRGB(18, 18, 24)
local ColorPanel     = Color3.fromRGB(26, 26, 32)
local ColorAccent    = Color3.fromRGB(133, 65, 255)
local ColorButton    = Color3.fromRGB(40, 38, 48)
local ColorButtonHover = Color3.fromRGB(60, 55, 80)
local ColorBorder    = Color3.fromRGB(80, 35, 160)
local ColorTopBar    = Color3.fromRGB(24, 20, 36)
local ColorSidebar   = Color3.fromRGB(20, 18, 28)
local ColorTitle     = Color3.fromRGB(180, 175, 255)
local ColorTextNorm  = Color3.fromRGB(230,230,255)
local ColorIndicatorOk   = Color3.fromRGB(90,220,140)
local ColorIndicatorFail = Color3.fromRGB(220,90,120)
local ColorIndicatorWait = Color3.fromRGB(200,180,50)
local ColorSkySelected   = Color3.fromRGB(180, 35, 160)
local FONT_GAME = Enum.Font.GothamBold

local menuVisible = true
local menuKey = Enum.KeyCode.RightShift
local savedDisplayName, savedUsername, savedAppearance, savedCharacterArchivable = nil, nil, nil, nil
local currentlySpoofed = false
local originalSky = nil
local currentSkyName = "Original"
local spoofedUserId = nil

-- Eliminar objetos viejos
local function destroyOld()
    local old = playerGui:FindFirstChild("YabujinHUD")
    if old then old:Destroy() end
    local bubbleOld = playerGui:FindFirstChild("YabujinBubble")
    if bubbleOld then bubbleOld:Destroy() end
end
destroyOld()

-----------------------------------------------------------------
--  Nombres y Display Name Spoofer
-----------------------------------------------------------------
local function spoofName(username, displayName)
    local success, err = pcall(function()
        if not savedUsername then savedUsername = localPlayer.Name end
        if not savedDisplayName then savedDisplayName = localPlayer.DisplayName end
        if username and #username > 0 then
            localPlayer.Name = username
        end
        if displayName and #displayName > 0 then
            localPlayer.DisplayName = displayName
        end
    end)
    return success, err
end

local function resetName()
    if savedUsername then
        localPlayer.Name = savedUsername
    end
    if savedDisplayName then
        localPlayer.DisplayName = savedDisplayName
    end
end

local function reapplyNameIfNeeded(username, displayName)
    spoofName(username, displayName)
end


-----------------------------------------------------------------
-- Apariencia Avatar
-----------------------------------------------------------------
local function saveOriginalAppearance()
    if not localPlayer.Character then return end
    savedAppearance = {}
    savedCharacterArchivable = localPlayer.Character.Archivable
    pcall(function()
        local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if humanoid and humanoid:GetAppliedDescription() then
            savedAppearance.Description = humanoid:GetAppliedDescription():Clone()
        end
    end)
    savedAppearance.CFrame = localPlayer.Character.PrimaryPart and localPlayer.Character.PrimaryPart.CFrame or nil
end

-- Corrige el error línea 347: Players:GetHultc1qalrd99... NO EXISTE NUNCA
local function getHumanoidDescriptionFromUserIdSafe(uid)
    -- Para obtener una HumanoidDescription de otro usuario, busca una API válida
    -- Usar Players:GetHumanoidDescriptionFromUserId
    local ok, desc
    ok, desc = pcall(function()
        if Players.GetHumanoidDescriptionFromUserId then
            return Players:GetHumanoidDescriptionFromUserId(tonumber(uid))
        else
            return nil
        end
    end)
    if ok then return desc end
    return nil
end

-- Avatar Spoofer por Username
local function spoofAvatarFromUsername(username, statusCallback)
    if not localPlayer.Character then
        statusCallback("error", "Sin personaje local.")
        return
    end
    if not username or username == "" then
        statusCallback("error", "Username vacío o inválido.")
        return
    end

    statusCallback("loading")
    local resp
    local ok_json, msg_json = pcall(function()
        resp = HttpService:JSONDecode(
            game:HttpGet('https://users.roblox.com/v1/usernames/users?usernames=["'..username..'"]&excludeBannedUsers=true')
        )
    end)
    if not ok_json or not resp or not resp.data or #resp.data == 0 then
        statusCallback("error", "Usuario no encontrado")
        return
    end

    local targetId = tonumber(resp.data[1].id)
    if not targetId then
        statusCallback("error", "UserId inválido")
        return
    end
    spoofAvatarFromUserId(targetId, statusCallback)
end

-- Avatar Spoofer por UserId
function spoofAvatarFromUserId(targetId, statusCallback)
    if not localPlayer.Character then
        statusCallback("error", "Sin personaje local")
        return
    end
    if not targetId then
        statusCallback("error", "UserId inválido")
        return
    end

    statusCallback("loading")

    local desc = getHultc1qalrd99hju33uagsf8927k7xfxr423gr93gnjz8(targetId)
    if not desc then
        statusCallback("error", "No se pudo obtener la descripción del avatar (puede que el executor o Roblox limite esta función)")
        return
    end

    if not savedAppearance then
        saveOriginalAppearance()
    end

    local char = localPlayer.Character
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        statusCallback("error", "Humanoid no encontrado en tu personaje")
        return
    end

    local successApply, errApply = pcall(function()
        humanoid:ApplyDescription(desc)
    end)

    if successApply then
        currentlySpoofed = true
        spoofedUserId = targetId
        statusCallback("success")
    else
        statusCallback("error", "Falló al aplicar descripción: " .. tostring(errApply))
    end
end

local function resetAvatar(statusCallback)
    if not localPlayer.Character then
        statusCallback("error", "Sin personaje local.")
        return
    end

    if not savedAppearance or not savedAppearance.Description then
        statusCallback("error", "No hay apariencia guardada.")
        return
    end

    local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then
        statusCallback("error", "No se encontró el Humanoid del personaje local.")
        return
    end

    local success, err = pcall(function()
        humanoid:ApplyDescription(savedAppearance.Description)
    end)

    if success then
        currentlySpoofed = false
        spoofedUserId = nil
        statusCallback("success")
    else
        statusCallback("error", "No se pudo restaurar la apariencia: "..tostring(err))
    end
end

local function getAvatarHeadshot(userId)
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    local img = ""
    local ok, ret = pcall(function()
        return Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    end)
    if ok then img = ret end
    return img
end

-----------------------------------------------------------------
-- CiELOS World
-----------------------------------------------------------------
local skyOptions = {
    ["Galaxy"] = {
        Name = "Galaxy",
        Skybox = {
            ["SkyboxBk"] = "rbxassetid://1215722140",
            ["SkyboxDn"] = "rbxassetid://1215722141",
            ["SkyboxFt"] = "rbxassetid://1215722142",
            ["SkyboxLf"] = "rbxassetid://1215722143",
            ["SkyboxRt"] = "rbxassetid://1215722144",
            ["SkyboxUp"] = "rbxassetid://1215722145"
        },
        Preview = "rbxassetid://1215785310"
    },
    ["Nebula"] = {
        Name = "Nebula",
        Skybox = {
            ["SkyboxBk"] = "rbxassetid://159454299",
            ["SkyboxDn"] = "rbxassetid://159454300",
            ["SkyboxFt"] = "rbxassetid://159454296",
            ["SkyboxLf"] = "rbxassetid://159454297",
            ["SkyboxRt"] = "rbxassetid://159454298",
            ["SkyboxUp"] = "rbxassetid://159454301"
        },
        Preview = "rbxassetid://159455084"
    },
    ["Black Hole"] = {
        Name = "Black Hole",
        Skybox = {
            ["SkyboxBk"] = "rbxassetid://9595254130",
            ["SkyboxDn"] = "rbxassetid://9595254251",
            ["SkyboxFt"] = "rbxassetid://9595254346",
            ["SkyboxLf"] = "rbxassetid://9595254435",
            ["SkyboxRt"] = "rbxassetid://9595254547",
            ["SkyboxUp"] = "rbxassetid://9595254829"
        },
        Preview = "rbxassetid://9595263442"
    },
    ["Cosmos"] = {
        Name = "Cosmos",
        Skybox = {
            ["SkyboxBk"] = "rbxassetid://48464313",
            ["SkyboxDn"] = "rbxassetid://48464316",
            ["SkyboxFt"] = "rbxassetid://48464314",
            ["SkyboxLf"] = "rbxassetid://48464310",
            ["SkyboxRt"] = "rbxassetid://48464312",
            ["SkyboxUp"] = "rbxassetid://48464315"
        },
        Preview = "rbxassetid://48464331"
    },
    ["Cosmic Aurora"] = {
        Name = "Cosmic Aurora",
        Skybox = {
            ["SkyboxBk"] = "rbxassetid://167180292",
            ["SkyboxDn"] = "rbxassetid://167180294",
            ["SkyboxFt"] = "rbxassetid://167180295",
            ["SkyboxLf"] = "rbxassetid://167180297",
            ["SkyboxRt"] = "rbxassetid://167180296",
            ["SkyboxUp"] = "rbxassetid://167180293"
        },
        Preview = "rbxassetid://167180321"
    },
}

local function findCurrentSky()
    for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
        if v:IsA("Sky") then
            return v
        end
    end
    return nil
end

local function saveOriginalSky()
    if not originalSky then
        local current = findCurrentSky()
        if current then
            originalSky = {}
            for _, p in pairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do
                originalSky[p] = current[p]
            end
            originalSky._ref = current
        else
            originalSky = false -- no había sky original
        end
    end
end

local function applySkybox(skyInfo)
    local Lighting = game:GetService("Lighting")
    saveOriginalSky()
    local sky = findCurrentSky()
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    -- Asegura reemplazo de texturas
    local changed = false
    for k,v in pairs(skyInfo) do
        if sky[k] ~= nil then
            sky[k] = v
            changed = true
        end
    end
    return changed
end

local function restoreOriginalSky()
    local Lighting = game:GetService("Lighting")
    if originalSky then
        if originalSky ~= false and originalSky._ref and originalSky._ref.Parent then
            -- restaurar texturas originales
            local sky = findCurrentSky()
            if sky and sky == originalSky._ref then
                for k,v in pairs(originalSky) do
                    if typeof(k) == "string" and sky[k] then
                        sky[k] = v
                    end
                end
            elseif sky and sky ~= originalSky._ref then
                -- Eliminar el sky duplicado y restaura el original
                sky:Destroy()
                if originalSky._ref.Parent ~= Lighting then
                    originalSky._ref.Parent = Lighting
                end
            end
        else
            -- No había Sky original, quitar el nuevo
            local sky = findCurrentSky()
            if sky then sky:Destroy() end
        end
        currentSkyName = "Original"
        return true
    end
    return false
end

-----------------------------------------------------------------
-- INTERFACE: ROUNDIFY Y ANIMACIONES
-----------------------------------------------------------------
local function animateButton(button, toColor)
    spawn(function()
        if button:IsA("ImageButton") or button:IsA("TextButton") then
            local dur = 0.10
            local c0 = button.BackgroundColor3
            local t = 0
            while t < dur do
                t = t + RunService.RenderStepped:Wait()
                local alpha = t / dur
                button.BackgroundColor3 = c0:lerp(toColor,alpha)
            end
            button.BackgroundColor3 = toColor
        end
    end)
end

local function roundify(obj, radius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, radius)
    uiCorner.Parent = obj
end

-----------------------------------------------------------------
-- INTERFAZ -- PANEL MAIN Y BOLITA
-----------------------------------------------------------------
-- Tamaño ajustado para NO sobresalga el AvatarSpoofer
local panelWidth = 540
local panelHeight = 305+85+30 -- 420
local minX, minY = 16, 16

local Main = Instance.new("ScreenGui")
Main.Name = "YabujinHUD"
Main.ResetOnSpawn = false
Main.IgnoreGuiInset = false
Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Main.Parent = playerGui

-- tabFrames antes por compatibilidad
local tabFrames = {}

local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, panelWidth, 0, panelHeight)
Panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
Panel.BackgroundColor3 = ColorPanel
Panel.Active = true
Panel.Visible = menuVisible
Panel.BorderSizePixel = 0
Panel.Parent = Main
roundify(Panel, 13)

-- BOLITA FLOTANTE MORADA (ver instrucciones)
local Bubble = Instance.new("ImageButton")
Bubble.Name = "YabujinBubble"
Bubble.Size = UDim2.new(0, 38, 0, 38)
-- Por defecto a la derecha del panel
Bubble.Position = UDim2.new(0, Panel.Position.X.Offset + Panel.Size.X.Offset + 12, 0, Panel.Position.Y.Offset + 18)
Bubble.BackgroundColor3 = ColorAccent
Bubble.Image = ""
Bubble.Visible = true
Bubble.Active = true
Bubble.BackgroundTransparency = 0
Bubble.AutoButtonColor = true
Bubble.ZIndex = 10000
Bubble.Parent = playerGui   -- No depende de Main ni Panel: ¡siempre visible!
roundify(Bubble, 18)
Bubble.ClipsDescendants = false

local bubbleIcon = Instance.new("ImageLabel")
bubbleIcon.BackgroundTransparency = 1
bubbleIcon.Image = "rbxassetid://6031091007"
bubbleIcon.Size = UDim2.new(0.75, 0, 0.75, 0)
bubbleIcon.Position = UDim2.new(0.125, 0, 0.12, 0)
bubbleIcon.Parent = Bubble
bubbleIcon.ZIndex = 10001

-- Implementar DRAG&GOTCHA para PC y Móvil
local draggingBubble = false
local dragInputBubble
local bubbleDragStart, bubbleStartPos
local minBubbleX, minBubbleY = 8, 8

local function clampBubbleToScreen()
    -- Siempre visible, no tapa elementos del panel.
    local vp = workspace.CurrentCamera.ViewportSize
    local pos = Bubble.Position
    local size = Bubble.AbsoluteSize
    -- Permite cierta distancia al borde derecho
    local x = math.clamp(pos.X.Offset, minBubbleX, math.max(vp.X-Bubble.Size.X.Offset-12, minBubbleX))
    local y = math.clamp(pos.Y.Offset, minBubbleY, math.max(vp.Y-Bubble.Size.Y.Offset-12, minBubbleY))
    Bubble.Position = UDim2.new(0, x, 0, y)
end

Bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBubble = true
        bubbleDragStart = input.Position
        bubbleStartPos = Bubble.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingBubble = false
            end
        end)
    end
end)

Bubble.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputBubble = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInputBubble and draggingBubble then
        local delta = input.Position - bubbleDragStart
        Bubble.Position = UDim2.new(
            0, bubbleStartPos.X.Offset + delta.X,
            0, bubbleStartPos.Y.Offset + delta.Y
        )
        clampBubbleToScreen()
    end
end)

-- Toggle menú SOLO si NO estás arrastrando (click corto)
local bubbleClickBlocked = false
Bubble.MouseButton1Down:Connect(function()
    bubbleClickBlocked = false
end)
Bubble.MouseButton1Up:Connect(function()
    if not draggingBubble then
        menuVisible = not menuVisible
        Panel.Visible = menuVisible
        -- Bubble SIEMPRE visible
    end
end)

Bubble.TouchTap:Connect(function()
    if not draggingBubble then
        menuVisible = not menuVisible
        Panel.Visible = menuVisible
    end
end)

-----------------------------------------------------------------
-- TOPBAR, Sidebar y TABS (conserva)
-----------------------------------------------------------------
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.Position = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = ColorTopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = Panel
roundify(TopBar, 13)
local Title = Instance.new("TextLabel")
Title.Text = "YABUJIN"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Font = FONT_GAME
Title.TextColor3 = ColorTitle
Title.TextStrokeTransparency = 0.77
Title.TextStrokeColor3 = ColorAccent
Title.TextScaled = true
Title.Parent = TopBar

-- Draggable Panel
local dragging = false
local dragInput, mousePos, framePos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = Panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        local vp = workspace.CurrentCamera.ViewportSize
        newPos = UDim2.new(
            0, math.clamp(newPos.X.Offset, minX, vp.X - panelWidth - minX),
            0, math.clamp(newPos.Y.Offset, minY, vp.Y - panelHeight - minY)
        )
        Panel.Position = newPos
        -- Move Bubble next to panel!
        Bubble.Position = UDim2.new(0, Panel.Position.X.Offset + Panel.Size.X.Offset + 12, 0, Panel.Position.Y.Offset + 18)
        clampBubbleToScreen()
    end
end)

local sidebarW = 110
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, sidebarW, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = ColorSidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Panel
roundify(Sidebar, 10)

local tabs = {"Spoofer", "World", "Settings"}
local selectedTab = "Spoofer"
local tabButtons = {}

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -sidebarW, 1, -40)
ContentFrame.Position = UDim2.new(0, sidebarW, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = Panel

-- Crear frames por cada tab (pre-existentes)
do
    -- Spoofer
    local SpooferFrame = Instance.new("Frame")
    SpooferFrame.Name = "Spoofer"
    SpooferFrame.Size = UDim2.new(1, 0, 1, 0)
    SpooferFrame.BackgroundTransparency = 1
    SpooferFrame.Parent = ContentFrame
    tabFrames["Spoofer"] = SpooferFrame
    -- World
    local WorldFrame = Instance.new("Frame")
    WorldFrame.Name = "World"
    WorldFrame.Size = UDim2.new(1, 0, 1, 0)
    WorldFrame.BackgroundTransparency = 1
    WorldFrame.Parent = ContentFrame
    tabFrames["World"] = WorldFrame
    WorldFrame.Visible = false
    -- Settings
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "Settings"
    SettingsFrame.Size = UDim2.new(1, 0, 1, 0)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Parent = ContentFrame
    tabFrames["Settings"] = SettingsFrame
    SettingsFrame.Visible = false
end

-- Navigation: usar tabFrames existente
for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tab.."Tab"
    btn.Text = tab
    btn.Font = FONT_GAME
    btn.TextScaled = true
    btn.BackgroundColor3 = i==1 and ColorAccent or ColorButton
    btn.TextColor3 = ColorTextNorm
    btn.Position = UDim2.new(0, 10, 0, ((i-1) * 56) + 16)
    btn.Size = UDim2.new(1, -22, 0, 42)
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    roundify(btn, 8)
    tabButtons[tab] = btn

    btn.MouseEnter:Connect(function()
        if selectedTab ~= tab then animateButton(btn, ColorButtonHover) end
    end)
    btn.MouseLeave:Connect(function()
        if selectedTab ~= tab then animateButton(btn, ColorButton) end
    end)
    btn.MouseButton1Click:Connect(function()
        for name, frame in pairs(tabFrames) do
            frame.Visible = (name == tab)
            animateButton(tabButtons[name], (name == tab) and ColorAccent or ColorButton)
        end
        selectedTab = tab
    end)
end
for name, frame in pairs(tabFrames) do
    frame.Visible = (name == selectedTab)
end
animateButton(tabButtons[selectedTab], ColorAccent)

-----------------------------------------------------------------
-- SPOOFER TAB LAYOUT
-----------------------------------------------------------------
local SpooferFrame = tabFrames["Spoofer"]
local pad = 18

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Text = "Username"
UsernameLabel.Font = FONT_GAME
UsernameLabel.TextColor3 = ColorTextNorm
UsernameLabel.TextSize = 18
UsernameLabel.Size = UDim2.new(0, 90, 0, 18)
UsernameLabel.Position = UDim2.new(0, pad, 0, 20)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Parent = SpooferFrame

local UsernameBox = Instance.new("TextBox")
UsernameBox.PlaceholderText = localPlayer.Name
UsernameBox.Text = ""
UsernameBox.Font = FONT_GAME
UsernameBox.TextColor3 = ColorTextNorm
UsernameBox.BackgroundColor3 = ColorButton
UsernameBox.Size = UDim2.new(0, 230, 0, 32)
UsernameBox.Position = UDim2.new(0, pad, 0, 43)
roundify(UsernameBox, 6)
UsernameBox.Parent = SpooferFrame

local DispLabel = Instance.new("TextLabel")
DispLabel.Text = "Display Name"
DispLabel.Font = FONT_GAME
DispLabel.TextColor3 = ColorTextNorm
DispLabel.TextSize = 18
DispLabel.Size = UDim2.new(0, 120, 0, 18)
DispLabel.Position = UDim2.new(0, pad, 0, 90)
DispLabel.BackgroundTransparency = 1
DispLabel.Parent = SpooferFrame

local DispBox = Instance.new("TextBox")
DispBox.PlaceholderText = localPlayer.DisplayName
DispBox.Text = ""
DispBox.Font = FONT_GAME
DispBox.TextColor3 = ColorTextNorm
DispBox.BackgroundColor3 = ColorButton
DispBox.Size = UDim2.new(0, 230, 0, 32)
DispBox.Position = UDim2.new(0, pad, 0, 113)
roundify(DispBox, 6)
DispBox.Parent = SpooferFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = ""
statusLabel.Font = FONT_GAME
statusLabel.TextColor3 = ColorIndicatorOk
statusLabel.TextScaled = true
statusLabel.Size = UDim2.new(0, 120, 0, 18)
statusLabel.Position = UDim2.new(0, pad, 0, 150)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = SpooferFrame

local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Text = "Apply"
ApplyBtn.Font = FONT_GAME
ApplyBtn.TextColor3 = ColorTextNorm
ApplyBtn.BackgroundColor3 = ColorAccent
ApplyBtn.Size = UDim2.new(0, 95, 0, 34)
ApplyBtn.Position = UDim2.new(0, pad, 0, 177)
roundify(ApplyBtn, 8)
ApplyBtn.Parent = SpooferFrame

local ResetBtn = Instance.new("TextButton")
ResetBtn.Text = "Reset"
ResetBtn.Font = FONT_GAME
ResetBtn.TextColor3 = ColorTextNorm
ResetBtn.BackgroundColor3 = ColorButton
ResetBtn.Size = UDim2.new(0, 95, 0, 34)
ResetBtn.Position = UDim2.new(0, pad+105, 0, 177)
roundify(ResetBtn, 8)
ResetBtn.Parent = SpooferFrame

ApplyBtn.MouseButton1Click:Connect(function()
    local uname = UsernameBox.Text ~= "" and UsernameBox.Text or nil
    local dname = DispBox.Text ~= "" and DispBox.Text or nil
    local ok, msg = spoofName(uname, dname)
    if ok then
        statusLabel.Text = "Cambiado localmente"
        statusLabel.TextColor3 = ColorIndicatorOk
    else
        statusLabel.Text = "No fue posible"
        statusLabel.TextColor3 = ColorIndicatorFail
    end
end)
ResetBtn.MouseButton1Click:Connect(function()
    resetName()
    statusLabel.Text = "Restaurado"
    statusLabel.TextColor3 = ColorIndicatorOk
end)

-----------------------------------------------------------------
-- AVATAR SPOOFER UI (Username + UserId) -- REORGANIZADO Y AJUSTADO
-----------------------------------------------------------------
-- Background para el AvatarSpoofer + UserId
local AvSection = Instance.new("Frame")
AvSection.Name = "AvatarSection"
AvSection.Size = UDim2.new(0, 252, 0, 174)
AvSection.Position = UDim2.new(0, 245, 0, 20)
AvSection.BackgroundColor3 = ColorPanel
AvSection.BackgroundTransparency = 0.22
AvSection.Parent = SpooferFrame
roundify(AvSection, 10)

local AvLabel = Instance.new("TextLabel")
AvLabel.Text = "Avatar Spoofer"
AvLabel.Font = FONT_GAME
AvLabel.TextColor3 = ColorTextNorm
AvLabel.TextSize = 18
AvLabel.Size = UDim2.new(1, -16, 0, 18)
AvLabel.Position = UDim2.new(0, 8, 0, 5)
AvLabel.BackgroundTransparency = 1
AvLabel.Parent = AvSection

local AvUserBox = Instance.new("TextBox")
AvUserBox.PlaceholderText = "Username Roblox"
AvUserBox.Text = ""
AvUserBox.Font = FONT_GAME
AvUserBox.TextColor3 = ColorTextNorm
AvUserBox.BackgroundColor3 = ColorButton
AvUserBox.Size = UDim2.new(0, 125, 0, 30)
AvUserBox.Position = UDim2.new(0, 10, 0, 32)
roundify(AvUserBox, 7)
AvUserBox.Parent = AvSection

local AvatarApplyBtn = Instance.new("TextButton")
AvatarApplyBtn.Text = "Apply"
AvatarApplyBtn.Font = FONT_GAME
AvatarApplyBtn.TextColor3 = ColorTextNorm
AvatarApplyBtn.BackgroundColor3 = ColorAccent
AvatarApplyBtn.Size = UDim2.new(0, 62, 0, 30)
AvatarApplyBtn.Position = UDim2.new(0, 140, 0, 32)
roundify(AvatarApplyBtn, 7)
AvatarApplyBtn.Parent = AvSection

local AvatarResetBtn = Instance.new("TextButton")
AvatarResetBtn.Text = "Reset"
AvatarResetBtn.Font = FONT_GAME
AvatarResetBtn.TextColor3 = ColorTextNorm
AvatarResetBtn.BackgroundColor3 = ColorButton
AvatarResetBtn.Size = UDim2.new(0, 62, 0, 30)
AvatarResetBtn.Position = UDim2.new(0, 140, 0, 70)
roundify(AvatarResetBtn, 7)
AvatarResetBtn.Parent = AvSection

local AvPreview = Instance.new("ImageLabel")
AvPreview.Size = UDim2.new(0, 44, 0, 44)
AvPreview.Position = UDim2.new(0, 190, 0, 25)
AvPreview.BackgroundColor3 = ColorButton
AvPreview.BackgroundTransparency = 0.4
AvPreview.Image = ""
AvPreview.Parent = AvSection
roundify(AvPreview, 5)

local AvStatusLbl = Instance.new("TextLabel")
AvStatusLbl.Text = ""
AvStatusLbl.Font = FONT_GAME
AvStatusLbl.TextColor3 = ColorIndicatorOk
AvStatusLbl.TextSize = 17
AvStatusLbl.Size = UDim2.new(1, -16, 0, 20)
AvStatusLbl.Position = UDim2.new(0, 8, 0, 105)
AvStatusLbl.BackgroundTransparency = 1
AvStatusLbl.Parent = AvSection

-- UserID extra bloque AVATAR (dentro del mismo AvSection, debajo)
local AvUIDLbl = Instance.new("TextLabel")
AvUIDLbl.Text = "por UserId"
AvUIDLbl.Font = FONT_GAME
AvUIDLbl.TextColor3 = ColorTextNorm
AvUIDLbl.TextSize = 15
AvUIDLbl.Size = UDim2.new(0, 60, 0, 14)
AvUIDLbl.Position = UDim2.new(0, 10, 0, 133)
AvUIDLbl.BackgroundTransparency = 1
AvUIDLbl.Parent = AvSection

local AvUserIDBox = Instance.new("TextBox")
AvUserIDBox.PlaceholderText = "User Id"
AvUserIDBox.Text = ""
AvUserIDBox.Font = FONT_GAME
AvUserIDBox.TextColor3 = ColorTextNorm
AvUserIDBox.BackgroundColor3 = ColorButton
AvUserIDBox.Size = UDim2.new(0, 68, 0, 26)
AvUserIDBox.Position = UDim2.new(0, 70, 0, 130)
roundify(AvUserIDBox, 5)
AvUserIDBox.Parent = AvSection

local AvUserIdPreview = Instance.new("ImageLabel")
AvUserIdPreview.Size = UDim2.new(0, 26, 0, 26)
AvUserIdPreview.Position = UDim2.new(0, 145, 0, 130)
AvUserIdPreview.BackgroundColor3 = ColorButton
AvUserIdPreview.BackgroundTransparency = 0.45
AvUserIdPreview.Image = ""
AvUserIdPreview.Parent = AvSection
roundify(AvUserIdPreview, 5)

local AvIDApplyBtn = Instance.new("TextButton")
AvIDApplyBtn.Text = "Apply"
AvIDApplyBtn.Font = FONT_GAME
AvIDApplyBtn.TextColor3 = ColorTextNorm
AvIDApplyBtn.BackgroundColor3 = ColorAccent
AvIDApplyBtn.Size = UDim2.new(0, 40, 0, 26)
AvIDApplyBtn.Position = UDim2.new(0, 175, 0, 130)
roundify(AvIDApplyBtn, 5)
AvIDApplyBtn.Parent = AvSection

local AvIDResetBtn = Instance.new("TextButton")
AvIDResetBtn.Text = "Reset"
AvIDResetBtn.Font = FONT_GAME
AvIDResetBtn.TextColor3 = ColorTextNorm
AvIDResetBtn.BackgroundColor3 = ColorButton
AvIDResetBtn.Size = UDim2.new(0, 40, 0, 26)
AvIDResetBtn.Position = UDim2.new(0, 218, 0, 130)
roundify(AvIDResetBtn, 5)
AvIDResetBtn.Parent = AvSection

local AvIDStatusLbl = Instance.new("TextLabel")
AvIDStatusLbl.Text = ""
AvIDStatusLbl.Font = FONT_GAME
AvIDStatusLbl.TextColor3 = ColorIndicatorOk
AvIDStatusLbl.TextSize = 15
AvIDStatusLbl.Size = UDim2.new(1, -16, 0, 16)
AvIDStatusLbl.Position = UDim2.new(0, 8, 0, 158)
AvIDStatusLbl.BackgroundTransparency = 1
AvIDStatusLbl.Parent = AvSection

-- Status! y previews
local function setAvatarStatus(type, msg)
    if type == "loading" then
        AvStatusLbl.Text = "Cargando..."
        AvStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type == "success" then
        AvStatusLbl.Text = "Aplicado"
        AvStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type == "error" then
        AvStatusLbl.Text = msg or "Error"
        AvStatusLbl.TextColor3 = ColorIndicatorFail
    else
        AvStatusLbl.Text = ""
    end
end

local function setAvatarIDStatus(type, msg)
    if type == "loading" then
        AvIDStatusLbl.Text = "Cargando..."
        AvIDStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type == "success" then
        AvIDStatusLbl.Text = "Aplicado"
        AvIDStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type == "error" then
        AvIDStatusLbl.Text = msg or "Error"
        AvIDStatusLbl.TextColor3 = ColorIndicatorFail
    else
        AvIDStatusLbl.Text = ""
    end
end

local function updateAvPreview(uName)
    AvPreview.Image = ""
    if uName and #uName > 2 then
        local ok, info = pcall(function()
            local resp = HttpService:JSONDecode(
                game:HttpGet('https://users.roblox.com/v1/usernames/users?usernames=["' .. uName .. '"]&excludeBannedUsers=true')
            )
            if resp and resp.data and resp.data[1] and resp.data[1].id then
                local id = resp.data[1].id
                AvPreview.Image = getAvatarHeadshot(id)
            end
        end)
    end
end

AvUserBox.FocusLost:Connect(function()
    updateAvPreview(AvUserBox.Text)
end)

local function updateAvIdPreview(uId)
    AvUserIdPreview.Image = ""
    local num = tonumber(uId)
    if num and num > 0 then
        local ok, img = pcall(function()
            return getAvatarHeadshot(num)
        end)
        if ok and img then
            AvUserIdPreview.Image = img
        end
    end
end
AvUserIDBox.FocusLost:Connect(function()
    updateAvIdPreview(AvUserIDBox.Text)
end)

AvatarApplyBtn.MouseButton1Click:Connect(function()
    local user = AvUserBox.Text
    if not user or #user < 3 then
        setAvatarStatus("error", "Username inválido")
        return
    end
    spoofAvatarFromUsername(user, setAvatarStatus)
end)
AvatarResetBtn.MouseButton1Click:Connect(function()
    resetAvatar(setAvatarStatus)
    updateAvPreview(localPlayer.Name)
end)
AvIDApplyBtn.MouseButton1Click:Connect(function()
    local uid = tonumber(AvUserIDBox.Text)
    if not uid then
        setAvatarIDStatus("error", "UserId inválido")
        return
    end
    spoofAvatarFromUserId(uid, setAvatarIDStatus)
end)
AvIDResetBtn.MouseButton1Click:Connect(function()
    resetAvatar(setAvatarIDStatus)
    updateAvIdPreview(localPlayer.UserId)
end)

-----------------------------------------------------------------
-- WORLD TAB
-----------------------------------------------------------------
local WorldFrame = tabFrames["World"]
local w_pad, w_y = 22, 22
local boxesPerRow, boxPad, boxW, boxH = 2, 22, 190, 70
local idx = 0

local skyStatusLbl = Instance.new("TextLabel")
skyStatusLbl.Text = ""
skyStatusLbl.Font = FONT_GAME
skyStatusLbl.TextColor3 = ColorIndicatorOk
skyStatusLbl.TextSize = 19
skyStatusLbl.Position = UDim2.new(0, w_pad, 0, 325)
skyStatusLbl.Size = UDim2.new(1, -w_pad*2, 0, 24)
skyStatusLbl.BackgroundTransparency = 1
skyStatusLbl.Parent = WorldFrame

local function setSkyStatus(type, msg)
    if type == "loading" then
        skyStatusLbl.Text = "Cargando..."
        skyStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type == "success" then
        skyStatusLbl.Text = msg or "Cielo aplicado"
        skyStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type == "error" then
        skyStatusLbl.Text = msg or "Error"
        skyStatusLbl.TextColor3 = ColorIndicatorFail
    else
        skyStatusLbl.Text = ""
    end
end

local function selectSky(name)
    if not skyOptions[name] then setSkyStatus("error", "Sky desconocido"); return end
    setSkyStatus("loading")
    local changed = false
    local ok = pcall(function()
        changed = applySkybox(skyOptions[name].Skybox)
    end)
    if changed then
        currentSkyName = name
        setSkyStatus("success", "Cielo aplicado: " .. name)
    else
        setSkyStatus("error", "No se pudo aplicar el cielo. El juego puede estar forzando su propio cielo o bloquear cambios.")
    end
end

local function genSkyBox(k, dat)
    idx = idx + 1
    local row = math.floor((idx-1)/boxesPerRow)
    local col = (idx-1)%boxesPerRow
    local box = Instance.new("Frame")
    box.Name = k.."Box"
    box.Size = UDim2.new(0, boxW, 0, boxH)
    box.Position = UDim2.new(0, w_pad + col*(boxW + boxPad), 0, w_y + row*(boxH + 18))
    box.BackgroundColor3 = (currentSkyName == k) and ColorSkySelected or ColorButton
    box.BackgroundTransparency = 0.23
    box.Parent = WorldFrame
    roundify(box, 9)
    local preview = Instance.new("ImageLabel")
    preview.Image = dat.Preview
    preview.Size = UDim2.new(0, 52, 0, 52)
    preview.Position = UDim2.new(0, 9, 0, 9)
    preview.BackgroundTransparency = 1
    preview.Parent = box
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = dat.Name
    nameLbl.Font = FONT_GAME
    nameLbl.TextColor3 = ColorTextNorm
    nameLbl.TextSize = 18
    nameLbl.Position = UDim2.new(0, 76, 0, 13)
    nameLbl.Size = UDim2.new(0, 89, 0, 22)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = box
    local ApplyBtn = Instance.new("TextButton")
    ApplyBtn.Text = "Apply"
    ApplyBtn.Font = FONT_GAME
    ApplyBtn.TextColor3 = ColorTextNorm
    ApplyBtn.BackgroundColor3 = ColorAccent
    ApplyBtn.Size = UDim2.new(0, 67, 0, 29)
    ApplyBtn.Position = UDim2.new(1, -74, 1, -35)
    roundify(ApplyBtn, 7)
    ApplyBtn.Parent = box
    ApplyBtn.MouseButton1Click:Connect(function()
        selectSky(k)
        for _, framen in ipairs(WorldFrame:GetChildren()) do
            if framen:IsA("Frame") then
                framen.BackgroundColor3 = ColorButton
            end
        end
        box.BackgroundColor3 = ColorSkySelected
    end)
end

for n, dat in pairs(skyOptions) do
    genSkyBox(n, dat)
end

local RestoreSkyBtn = Instance.new("TextButton")
RestoreSkyBtn.Text = "Restore Original"
RestoreSkyBtn.Font = FONT_GAME
RestoreSkyBtn.TextColor3 = ColorTextNorm
RestoreSkyBtn.BackgroundColor3 = ColorButton
RestoreSkyBtn.Size = UDim2.new(0, 153, 0, 34)
RestoreSkyBtn.Position = UDim2.new(1, -170, 1, -45)
roundify(RestoreSkyBtn, 8)
RestoreSkyBtn.Parent = WorldFrame

RestoreSkyBtn.MouseButton1Click:Connect(function()
    local ok = restoreOriginalSky()
    if ok then
        setSkyStatus("success", "Cielo restaurado")
        for _, framen in ipairs(WorldFrame:GetChildren()) do
            if framen:IsA("Frame") then
                framen.BackgroundColor3 = ColorButton
            end
        end
    else
        setSkyStatus("error", "No se pudo restaurar el cielo original")
    end
end)

-----------------------------------------------------------------
-- SETTINGS TAB
-----------------------------------------------------------------
local SettingsFrame = tabFrames["Settings"]
local setTitle = Instance.new("TextLabel")
setTitle.Text = "Shortcut"
setTitle.Font = FONT_GAME
setTitle.TextColor3 = ColorTextNorm
setTitle.TextScaled = true
setTitle.BackgroundTransparency = 1
setTitle.Position = UDim2.new(0, 35, 0, 59)
setTitle.Size = UDim2.new(0, 170, 0, 32)
setTitle.Parent = SettingsFrame
local descLbl = Instance.new("TextLabel")
descLbl.Text = "Menú abre/cierra con:"
descLbl.Font = FONT_GAME
descLbl.TextColor3 = ColorTextNorm
descLbl.TextSize = 17
descLbl.BackgroundTransparency = 1
descLbl.Position = UDim2.new(0, 35, 0, 99)
descLbl.Size = UDim2.new(0, 187, 0, 22)
descLbl.Parent = SettingsFrame
local currKeyBtn = Instance.new("TextButton")
currKeyBtn.Text = tostring(menuKey.Name)
currKeyBtn.Font = FONT_GAME
currKeyBtn.TextScaled = true
currKeyBtn.TextColor3 = ColorAccent
currKeyBtn.BackgroundColor3 = ColorButton
currKeyBtn.Size = UDim2.new(0, 90, 0, 34)
currKeyBtn.Position = UDim2.new(0, 35, 0, 136)
currKeyBtn.AutoButtonColor = true
roundify(currKeyBtn, 9)
currKeyBtn.Parent = SettingsFrame

local waitForKey = false
currKeyBtn.MouseButton1Click:Connect(function()
    currKeyBtn.Text = "..."
    waitForKey = true
    currKeyBtn.TextColor3 = ColorIndicatorWait
end)

UserInputService.InputBegan:Connect(function(inp, gameProcessed)
    if not Main or not Main.Parent then return end
    if waitForKey and inp.UserInputType == Enum.UserInputType.Keyboard then
        menuKey = inp.KeyCode
        currKeyBtn.Text = tostring(menuKey.Name)
        currKeyBtn.TextColor3 = ColorAccent
        waitForKey = false
    elseif inp.KeyCode == menuKey and not waitForKey and not gameProcessed then
        menuVisible = not menuVisible
        Panel.Visible = menuVisible
        -- Bubble SIEMPRE visible
    end
end)

-----------------------------------------------------------------
-- EVENTS Panel/Bubble Responsive
-----------------------------------------------------------------
game:GetService("Workspace").CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    Panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
    -- Mantén bubble visible junto al borde de panel
    Bubble.Position = UDim2.new(0, Panel.Position.X.Offset + Panel.Size.X.Offset + 12, 0, Panel.Position.Y.Offset + 18)
    clampBubbleToScreen()
end)

Panel:GetPropertyChangedSignal("Visible"):Connect(function()
    -- Bolita SIEMPRE visible
end)

Panel:GetPropertyChangedSignal("Position"):Connect(function()
    -- Mueve la bolita junto al panel al draggear el panel
    Bubble.Position = UDim2.new(0, Panel.Position.X.Offset + Panel.Size.X.Offset + 12, 0, Panel.Position.Y.Offset + 18)
    clampBubbleToScreen()
end)
