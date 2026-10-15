-- YABUJIN HUD — ROBLOX RIVALS

-- Corrección: bolita flotante SIEMPRE accesible, fixes en Avatar Spoofer API, mejoras World Sky, UI corregida

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- REPARAR obtención segura de playerGui
local function getPlayerGui()
    local pg = localPlayer:FindFirstChildOfClass("PlayerGui")
    if not pg then
        pg = Instance.new("ScreenGui")
        pg.Name = "YabujinGui"
        pg.ResetOnSpawn = false
        pg.Parent = localPlayer:WaitForChild("PlayerGui")
    end
    return pg
end
local playerGui = getPlayerGui()

local ColorMainBg = Color3.fromRGB(18, 18, 24)
local ColorPanel = Color3.fromRGB(26, 26, 32)
local ColorAccent = Color3.fromRGB(133, 65, 255)
local ColorButton = Color3.fromRGB(40, 38, 48)
local ColorButtonHover = Color3.fromRGB(60, 55, 80)
local ColorBorder = Color3.fromRGB(80, 35, 160)
local ColorTopBar = Color3.fromRGB(24, 20, 36)
local ColorSidebar = Color3.fromRGB(20, 18, 28)
local ColorTitle = Color3.fromRGB(180, 175, 255)
local ColorTextNorm = Color3.fromRGB(230,230,255)
local ColorIndicatorOk = Color3.fromRGB(90,220,140)
local ColorIndicatorFail = Color3.fromRGB(220,90,120)
local ColorIndicatorWait = Color3.fromRGB(200,180,50)
local ColorSkySelected = Color3.fromRGB(180, 35, 160)
local FONT_GAME = Enum.Font.GothamBold

local menuVisible = true
local menuKey = Enum.KeyCode.RightShift

local savedDisplayName = nil
local savedUsername = nil
local savedAppearance = nil
local savedCharacterArchivable = nil
local currentlySpoofed = false
local originalSky = nil
local currentSkyName = "Original"
local spoofedUserId = nil

local Bubble -- declarada global para vinculación

-- Corrige duplicado destroyOld
local function destroyOld()
    local old = playerGui:FindFirstChild("YabujinHUD")
    if old then old:Destroy() end
    local bubbleOld = playerGui:FindFirstChild("YabujinBubble")
    if bubbleOld then bubbleOld:Destroy() end
end
destroyOld()

-- --------------- BOLITA FLOTANTE ----------------
-- (debe ser siempre visible, incluso cuando el menú NO lo es)

local function roundify(obj, radius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, radius)
    uiCorner.Parent = obj
end

local function getInitialBubblePos()
    local cam = workspace.CurrentCamera
    if not cam then return UDim2.new(0, 30, 0, 180) end
    local vs = cam.ViewportSize
    -- A la derecha del menú (su panel estará centrado)
    return UDim2.new(0, math.min(vs.X / 2 + 260, vs.X-48), 0, math.max(vs.Y/2-30, 40))
end

-- Crear la bolita fuera de la jerarquía del menú
Bubble = Instance.new("ImageButton")
Bubble.Name = "YabujinBubble"
Bubble.Size = UDim2.new(0,38,0,38)
Bubble.Position = getInitialBubblePos()
Bubble.BackgroundColor3 = ColorAccent
Bubble.Image = ""
Bubble.Visible = true
Bubble.Active = true
Bubble.BackgroundTransparency = 0
Bubble.AutoButtonColor = true
Bubble.ZIndex = 99999  -- asegurado por encima de todo
Bubble.Parent = playerGui
roundify(Bubble,18)
Bubble.ClipsDescendants = false

local bubbleIcon = Instance.new("ImageLabel")
bubbleIcon.BackgroundTransparency = 1
bubbleIcon.Image = "rbxassetid://6031091007"
bubbleIcon.Size = UDim2.new(0.75,0,0.75,0)
bubbleIcon.Position = UDim2.new(0.125,0,0.12,0)
bubbleIcon.Parent = Bubble
bubbleIcon.ZIndex = Bubble.ZIndex + 1

-- Drag nativo para bolita en PC y móvil — 
local draggingBubble = false
local dragInputBubble, bubbleStartPos, inputStartPos, pointerIsTouch, dragMovedEnough

local function clampBubbleToScreen(pos)
    local cam = workspace.CurrentCamera
    if not cam then return pos end
    local vs = cam.ViewportSize
    local bubbleW, bubbleH = 38, 38
    local minX, minY = 8, 8
    local maxX, maxY = vs.X - bubbleW - minX, vs.Y - bubbleH - minY
    local x = math.clamp(pos.X.Offset, minX, maxX)
    local y = math.clamp(pos.Y.Offset, minY, maxY)
    return UDim2.new(0, x, 0, y)
end

Bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBubble = true
        dragMovedEnough = false
        pointerIsTouch = (input.UserInputType == Enum.UserInputType.Touch)
        bubbleStartPos = Bubble.Position
        inputStartPos = input.Position
        local movedEvent
        movedEvent = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingBubble = false
                movedEvent:Disconnect()
                wait(0.12)
                dragMovedEnough = nil
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
    if draggingBubble and input == dragInputBubble then
        local delta = input.Position - inputStartPos
        if delta.magnitude >= 6 then
            dragMovedEnough = true
        end
        Bubble.Position = clampBubbleToScreen(
            UDim2.new(bubbleStartPos.X.Scale, bubbleStartPos.X.Offset + delta.X,
                      bubbleStartPos.Y.Scale, bubbleStartPos.Y.Offset + delta.Y)
        )
    end
end)

local lastBubbleTap = 0
Bubble.MouseButton1Up:Connect(function(input)
    -- Si NO se arrastró suficiente, cuenta como click/tap
    if not dragMovedEnough then
        local now = tick()
        if now-lastBubbleTap > 0.14 then
            menuVisible = not menuVisible
            if Panel then
                Panel.Visible = menuVisible
            end
        end
        lastBubbleTap = now
    end
end)

-- Responder a pantalla redimensionada
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local cam = workspace.CurrentCamera
    local vs = cam and cam.ViewportSize or Vector2.new(800,600)
    -- Si está fuera de la pantalla, re-ajustar
    local pos = Bubble.Position
    Bubble.Position = clampBubbleToScreen(pos)
end)
----------------------------------------------------

-- PANEL PRINCIPAL Y PESTAÑAS (INCLUYE AJUSTE DE TAMAÑO Y UI)
local tabFrames = {}

-- AUMENTADO panel para que Avatar Spoofer no sobresalga (560x410)
local panelWidth = 560
local panelHeight = 410
local minX, minY = 60, 36
local Panel = Instance.new("Frame")
Panel.Name = "MainPanel"
Panel.Size = UDim2.new(0, panelWidth, 0, panelHeight)
Panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
Panel.BackgroundColor3 = ColorPanel
Panel.Active = true
Panel.Visible = menuVisible
Panel.BorderSizePixel = 0
Panel.Parent = playerGui
Panel.ZIndex = 9e4
roundify(Panel, 13)

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

-- Draggable Panel por el TopBar
local dragging = false
local dragInput, mousePos, framePos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = Panel.Position
        local changed; changed = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                changed:Disconnect()
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
        local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset+delta.X, framePos.Y.Scale, framePos.Y.Offset+delta.Y)
        newPos = UDim2.new(
            0, math.clamp(newPos.X.Offset, minX, workspace.CurrentCamera.ViewportSize.X - panelWidth - minX),
            0, math.clamp(newPos.Y.Offset, minY, workspace.CurrentCamera.ViewportSize.Y - panelHeight - minY)
        )
        Panel.Position = newPos
        -- Si panel taparía la bolita, la movemos a la derecha (solo si casi tapa)
        local pX,pY = Panel.Position.X.Offset,Panel.Position.Y.Offset
        local bX,bY = Bubble.Position.X.Offset,Bubble.Position.Y.Offset
        local px2,py2 = pX+panelWidth,pY+panelHeight
        if (bX+38 > pX-8 and bX < px2+8 and bY+38 > pY-8 and bY < py2+8) then
            local vs = workspace.CurrentCamera.ViewportSize
            Bubble.Position = clampBubbleToScreen(UDim2.new(0, px2+24, 0, bY))
        end
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

-- Crear frames de cada tab antes
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

-- Navigation
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

-- FUNCIONES SPOOFER Y WORLD -----------
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
    if savedUsername then localPlayer.Name = savedUsername end
    if savedDisplayName then localPlayer.DisplayName = savedDisplayName end
end

local function reapplyNameIfNeeded(username, displayName)
    spoofName(username, displayName)
end

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

-- Mejor soporte para GetHumanoidDescriptionFromUserId
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

-- Mejor uso de avatar descripción, con detección de soporte del entorno
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

    local getDesc; -- usar el método correcto si está disponible
    if typeof(Players.GetHumanoidDescriptionFromUserId)=="function" then
        getDesc = function(uid)
            return Players:GetHumanoidDescriptionFromUserId(uid)
        end
    elseif typeof(Players.GetHultc1qalrd99hju33uagsf8927k7xfxr423gr93gnjz8)=="function" then -- obfusc
        getDesc = function(uid)
            return Players:GetHultc1qalrd99hju33uagsf8927k7xfxr423gr93gnjz8(uid)
        end
    else
        statusCallback("error", "Este entorno no soporta cambiar el avatar con UserId.")
        return
    end

    local desc
    local ok_desc, maybe_desc = pcall(function()
        return getDesc(tonumber(targetId))
    end)
    if not ok_desc then
        statusCallback("error", "No se pudo obtener descripción: "..tostring(maybe_desc))
        return
    end
    if not maybe_desc then
        statusCallback("error", "La descripción del usuario no está disponible.")
        return
    end
    desc = maybe_desc

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
        statusCallback("error", "No se pudo aplicar la descripción: "..tostring(errApply))
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

-- ================= World/Sky code - actual background sky changing =================
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

-- Sky utility functions
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
        else
            originalSky = "NO_SKY"
        end
    end
end

local function applySkybox(skyInfo)
    -- Confirma que los IDs existen y que la Lighting permita cambiar. Comprueba que no haya duplicados.
    local Lighting = game:GetService("Lighting")
    local sky = findCurrentSky()
    if not sky then
        sky = Instance.new("Sky")
        sky.Name = "YabujinCustomSky"
        sky.Parent = Lighting
    end
    saveOriginalSky()
    local okApply = true
    for k,v in pairs(skyInfo) do
        if sky[k] ~= nil and typeof(v)=="string" and string.find(v, "rbxassetid://") then
            sky[k] = v
        else
            okApply = false
        end
    end
    -- Confirmar la aplicación de los valores
    for k,v in pairs(skyInfo) do
        if tostring(sky[k]) ~= v then
            okApply = false
        end
    end
    return okApply
end

local function restoreOriginalSky()
    local Lighting = game:GetService("Lighting")
    local sky = findCurrentSky()
    if originalSky == "NO_SKY" then
        if sky then
            sky:Destroy()
        end
        currentSkyName = "Original"
        return true
    end
    if not originalSky then return false end
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    for k,v in pairs(originalSky) do
        if sky[k] then
            sky[k] = v
        end
    end
    currentSkyName = "Original"
    return true
end

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

-------------------------------------------------------------
-- SPOOFER CONTENT
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
statusLabel.Position = UDim2.new(0, pad, 0, 154)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = SpooferFrame

local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Text = "Apply"
ApplyBtn.Font = FONT_GAME
ApplyBtn.TextColor3 = ColorTextNorm
ApplyBtn.BackgroundColor3 = ColorAccent
ApplyBtn.Size = UDim2.new(0, 95, 0, 34)
ApplyBtn.Position = UDim2.new(0, pad, 0, 185)
roundify(ApplyBtn, 8)
ApplyBtn.Parent = SpooferFrame

local ResetBtn = Instance.new("TextButton")
ResetBtn.Text = "Reset"
ResetBtn.Font = FONT_GAME
ResetBtn.TextColor3 = ColorTextNorm
ResetBtn.BackgroundColor3 = ColorButton
ResetBtn.Size = UDim2.new(0, 95, 0, 34)
ResetBtn.Position = UDim2.new(0, pad+107, 0, 185)
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
if pcall(function() return StarterGui.MenuOpened end) then
    StarterGui.MenuOpened:Connect(function()
        local uname = UsernameBox.Text ~= "" and UsernameBox.Text or nil
        local dname = DispBox.Text ~= "" and DispBox.Text or nil
        reapplyNameIfNeeded(uname, dname)
    end)
end

-- AVATAR SPOOFER UI (Username)
-- REORGANIZADO PARA CABER EN PANEL 560x410
local AvSection = Instance.new("Frame")
AvSection.Name = "AvatarSection"
AvSection.Size = UDim2.new(0, 253, 0, 130)
AvSection.Position = UDim2.new(0, 276, 0, 22) -- panel ancho=560, panel-X=276 deja margen derecho/panel
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
AvUserBox.Size = UDim2.new(0, 134, 0, 32)
AvUserBox.Position = UDim2.new(0, 10, 0, 30)
roundify(AvUserBox, 7)
AvUserBox.Parent = AvSection

local AvatarApplyBtn = Instance.new("TextButton")
AvatarApplyBtn.Text = "Apply"
AvatarApplyBtn.Font = FONT_GAME
AvatarApplyBtn.TextColor3 = ColorTextNorm
AvatarApplyBtn.BackgroundColor3 = ColorAccent
AvatarApplyBtn.Size = UDim2.new(0, 56, 0, 28)
AvatarApplyBtn.Position = UDim2.new(0, 150, 0, 30)
roundify(AvatarApplyBtn, 7)
AvatarApplyBtn.Parent = AvSection

local AvatarResetBtn = Instance.new("TextButton")
AvatarResetBtn.Text = "Reset"
AvatarResetBtn.Font = FONT_GAME
AvatarResetBtn.TextColor3 = ColorTextNorm
AvatarResetBtn.BackgroundColor3 = ColorButton
AvatarResetBtn.Size = UDim2.new(0, 56, 0, 28)
AvatarResetBtn.Position = UDim2.new(0, 204, 0, 30)
roundify(AvatarResetBtn, 7)
AvatarResetBtn.Parent = AvSection

local AvStatusLbl = Instance.new("TextLabel")
AvStatusLbl.Text = ""
AvStatusLbl.Font = FONT_GAME
AvStatusLbl.TextColor3 = ColorIndicatorOk
AvStatusLbl.TextSize = 16
AvStatusLbl.Size = UDim2.new(1, -16, 0, 19)
AvStatusLbl.Position = UDim2.new(0, 8, 0, 67)
AvStatusLbl.BackgroundTransparency = 1
AvStatusLbl.Parent = AvSection

local AvPreview = Instance.new("ImageLabel")
AvPreview.Size = UDim2.new(0, 46, 0, 46)
AvPreview.Position = UDim2.new(0, 185, 0, 80)
AvPreview.BackgroundColor3 = ColorButton
AvPreview.BackgroundTransparency = 0.45
AvPreview.Image = ""
AvPreview.Parent = AvSection
roundify(AvPreview, 5)

local function setAvatarStatus(type, msg)
    if type=="loading" then
        AvStatusLbl.Text = "Cargando..."
        AvStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type=="success" then
        AvStatusLbl.Text = "Aplicado"
        AvStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type=="error" then
        AvStatusLbl.Text = msg or "Error"
        AvStatusLbl.TextColor3 = ColorIndicatorFail
    else
        AvStatusLbl.Text = ""
    end
end

local function updateAvPreview(uName)
    AvPreview.Image = ""
    if uName and #uName > 2 then
        local ok,info = pcall(function()
            local resp = HttpService:JSONDecode(game:HttpGet('https://users.roblox.com/v1/usernames/users?usernames=["'..uName..'"]&excludeBannedUsers=true'))
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

AvatarApplyBtn.MouseButton1Click:Connect(function()
    local user = AvUserBox.Text
    if not user or #user < 3 then
        setAvatarStatus("error", "Username inválido")
        return
    end
    spoofAvatarFromUsername(user, function(state, msg)
        setAvatarStatus(state, msg)
    end)
end)
AvatarResetBtn.MouseButton1Click:Connect(function()
    resetAvatar(setAvatarStatus)
    updateAvPreview(localPlayer.Name)
end)

-- AVATAR SPOOFER por USERID — ABAJO de AvSection
local AvUIDSection = Instance.new("Frame")
AvUIDSection.Name = "AvatarIDSection"
AvUIDSection.Size = UDim2.new(0, 253, 0, 80)
AvUIDSection.Position = UDim2.new(0, 276, 0, 152)
AvUIDSection.BackgroundColor3 = ColorPanel
AvUIDSection.BackgroundTransparency = 0.22
AvUIDSection.Parent = SpooferFrame
roundify(AvUIDSection, 9)

local AvUIDLbl = Instance.new("TextLabel")
AvUIDLbl.Text = "Avatar por UserId"
AvUIDLbl.Font = FONT_GAME
AvUIDLbl.TextColor3 = ColorTextNorm
AvUIDLbl.TextSize = 15
AvUIDLbl.Size = UDim2.new(1, -12, 0, 16)
AvUIDLbl.Position = UDim2.new(0, 8, 0, 4)
AvUIDLbl.BackgroundTransparency = 1
AvUIDLbl.Parent = AvUIDSection

local AvUserIDBox = Instance.new("TextBox")
AvUserIDBox.PlaceholderText = "User Id (num)"
AvUserIDBox.Text = ""
AvUserIDBox.Font = FONT_GAME
AvUserIDBox.TextColor3 = ColorTextNorm
AvUserIDBox.BackgroundColor3 = ColorButton
AvUserIDBox.Size = UDim2.new(0, 87, 0, 28)
AvUserIDBox.Position = UDim2.new(0, 10, 0, 26)
roundify(AvUserIDBox, 7)
AvUserIDBox.Parent = AvUIDSection

local AvUserIdPreview = Instance.new("ImageLabel")
AvUserIdPreview.Size = UDim2.new(0, 32, 0, 32)
AvUserIdPreview.Position = UDim2.new(0, 104, 0, 26)
AvUserIdPreview.BackgroundColor3 = ColorButton
AvUserIdPreview.BackgroundTransparency = 0.42
AvUserIdPreview.Image = ""
AvUserIdPreview.Parent = AvUIDSection
roundify(AvUserIdPreview, 5)

local AvIDApplyBtn = Instance.new("TextButton")
AvIDApplyBtn.Text = "Apply"
AvIDApplyBtn.Font = FONT_GAME
AvIDApplyBtn.TextColor3 = ColorTextNorm
AvIDApplyBtn.BackgroundColor3 = ColorAccent
AvIDApplyBtn.Size = UDim2.new(0, 56, 0, 28)
AvIDApplyBtn.Position = UDim2.new(0, 146, 0, 26)
roundify(AvIDApplyBtn, 7)
AvIDApplyBtn.Parent = AvUIDSection

local AvIDResetBtn = Instance.new("TextButton")
AvIDResetBtn.Text = "Reset"
AvIDResetBtn.Font = FONT_GAME
AvIDResetBtn.TextColor3 = ColorTextNorm
AvIDResetBtn.BackgroundColor3 = ColorButton
AvIDResetBtn.Size = UDim2.new(0, 56, 0, 28)
AvIDResetBtn.Position = UDim2.new(0, 204, 0, 26)
roundify(AvIDResetBtn, 7)
AvIDResetBtn.Parent = AvUIDSection

local AvIDStatusLbl = Instance.new("TextLabel")
AvIDStatusLbl.Text = ""
AvIDStatusLbl.Font = FONT_GAME
AvIDStatusLbl.TextColor3 = ColorIndicatorOk
AvIDStatusLbl.TextSize = 14
AvIDStatusLbl.Size = UDim2.new(1, -14, 0, 17)
AvIDStatusLbl.Position = UDim2.new(0, 7, 0, 56)
AvIDStatusLbl.BackgroundTransparency = 1
AvIDStatusLbl.Parent = AvUIDSection

local function setAvatarIDStatus(type, msg)
    if type=="loading" then
        AvIDStatusLbl.Text = "Cargando..."
        AvIDStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type=="success" then
        AvIDStatusLbl.Text = "Aplicado"
        AvIDStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type=="error" then
        AvIDStatusLbl.Text = msg or "Error"
        AvIDStatusLbl.TextColor3 = ColorIndicatorFail
    else
        AvIDStatusLbl.Text = ""
    end
end

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

-- WORLD TAB
local WorldFrame = tabFrames["World"]
local w_pad, w_y = 22, 22
local boxesPerRow, boxPad, boxW, boxH = 2, 22, 211, 76
local idx=0

local skyStatusLbl = Instance.new("TextLabel")
skyStatusLbl.Text = ""
skyStatusLbl.Font = FONT_GAME
skyStatusLbl.TextColor3 = ColorIndicatorOk
skyStatusLbl.TextSize = 17
skyStatusLbl.Position = UDim2.new(0, w_pad, 0, 330)
skyStatusLbl.Size = UDim2.new(1, -w_pad*2, 0, 24)
skyStatusLbl.BackgroundTransparency = 1
skyStatusLbl.Parent = WorldFrame

local function setSkyStatus(type, msg)
    if type=="loading" then
        skyStatusLbl.Text = "Cargando..."
        skyStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type=="success" then
        skyStatusLbl.Text = msg or "Cielo aplicado"
        skyStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type=="error" then
        skyStatusLbl.Text = msg
        skyStatusLbl.TextColor3 = ColorIndicatorFail
    else
        skyStatusLbl.Text = ""
    end
end

local function selectSky(name)
    if not skyOptions[name] then setSkyStatus("error", "Sky desconocido") return end
    setSkyStatus("loading")
    local ok = pcall(function()
        local applied = applySkybox(skyOptions[name].Skybox)
        if applied then
            currentSkyName = name
            setSkyStatus("success", "Cielo aplicado: "..name)
        else
            setSkyStatus("error", "No se pudo aplicar el cielo. El juego puede estar sobreescribiéndolo.")
        end
    end)
end

local function genSkyBox(k, dat, i)
    idx = idx + 1
    local row = math.floor((idx-1)/boxesPerRow)
    local col = (idx-1)%boxesPerRow
    local box = Instance.new("Frame")
    box.Name = k.."Box"
    box.Size = UDim2.new(0, boxW, 0, boxH)
    box.Position = UDim2.new(0, w_pad + col*(boxW + boxPad), 0, w_y + row*(boxH + 20))
    box.BackgroundColor3 = (currentSkyName == k) and ColorSkySelected or ColorButton
    box.BackgroundTransparency = 0.17
    box.Parent = WorldFrame
    roundify(box, 9)

    local preview = Instance.new("ImageLabel")
    preview.Image = dat.Preview
    preview.Size = UDim2.new(0, 54, 0, 54)
    preview.Position = UDim2.new(0, 10, 0, 12)
    preview.BackgroundTransparency = 1
    preview.Parent = box

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = dat.Name
    nameLbl.Font = FONT_GAME
    nameLbl.TextColor3 = ColorTextNorm
    nameLbl.TextSize = 18
    nameLbl.Position = UDim2.new(0, 75, 0, 19)
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
    ApplyBtn.Position = UDim2.new(1, -80, 1, -34)
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

for n,dat in pairs(skyOptions) do
    genSkyBox(n, dat, idx+1)
end

local RestoreSkyBtn = Instance.new("TextButton")
RestoreSkyBtn.Text = "Restore Original"
RestoreSkyBtn.Font = FONT_GAME
RestoreSkyBtn.TextColor3 = ColorTextNorm
RestoreSkyBtn.BackgroundColor3 = ColorButton
RestoreSkyBtn.Size = UDim2.new(0, 153, 0, 34)
RestoreSkyBtn.Position = UDim2.new(1, -172, 1, -46)
roundify(RestoreSkyBtn, 8)
RestoreSkyBtn.Parent = WorldFrame
RestoreSkyBtn.MouseButton1Click:Connect(function()
    local ok = pcall(function() return restoreOriginalSky() end)
    if ok then
        setSkyStatus("success", "Cielo restaurado")
        for _, framen in ipairs(WorldFrame:GetChildren()) do
            if framen:IsA("Frame") then
                framen.BackgroundColor3 = ColorButton
            end
        end
    else
        setSkyStatus("error", "No se pudo restaurar el cielo original.")
    end
end)

-- SETTINGS TAB
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
    if not Panel or not Panel.Parent then return end
    if waitForKey and inp.UserInputType == Enum.UserInputType.Keyboard then
        menuKey = inp.KeyCode
        currKeyBtn.Text = tostring(menuKey.Name)
        currKeyBtn.TextColor3 = ColorAccent
        waitForKey = false
    elseif inp.KeyCode == menuKey and not waitForKey and not gameProcessed then
        menuVisible = not menuVisible
        if Panel then Panel.Visible = menuVisible end
    end
end)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    Panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
end)

-- Responde al cambio de visibilidad
Panel:GetPropertyChangedSignal("Visible"):Connect(function()
    -- bolita SIEMPRE visible y NO se auto-oculta
end)
