-- YABUJIN HUD — ROBLOX RIVALS
-- Corrección: mejoras flotante SIEMPRE accesible y draggable, fixes en Avatar Spoofer UI/bordes, fixes reales cielos.

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

-- ACTUAL API COMPATIBLE en la mayoría de entornos (si la API está bloqueada por el executor, se notificará)
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

function spoofAvatarFromUserId(targetId, statusCallback)
    -- Trabaja con APIs estándar. Si el entorno/ejecutor lo prohíbe, informa del motivo real.
    if not localPlayer.Character then
        statusCallback("error", "Sin personaje local")
        return
    end
    if not targetId then
        statusCallback("error", "UserId inválido")
        return
    end

    statusCallback("loading")
    local desc
    local ok_desc = false
    local maybe_desc = nil
    if Players.GetHumanoidDescriptionFromUserId then
        ok_desc, maybe_desc = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(tonumber(targetId))
        end)
    else
        statusCallback("error", "Este entorno no soporta cambiar la apariencia por UserId (API no disponible o bloqueada)")
        return
    end
    if not ok_desc or not maybe_desc then
        -- Esta API puede estar restringida en algunos ejecutores, o el juego puede impedir los cambios locales.
        if not ok_desc and tostring(maybe_desc):find("not a valid member") then
            statusCallback("error", "El método Players:GetHultc1qalrd99hju33uagsf8927k7xfxr423gr93gnjz8 no está disponible en este executor o juego.")
        else
            statusCallback("error", "No se pudo obtener la descripción del avatar (el usuario podría tener restricciones en Roblox, el juego, o el executor impide aplicar descripciones)")
        end
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
        if tostring(errApply):find("not a valid") then
            statusCallback("error", "Este executor o juego bloquea ApplyDescription en humanoides locales.")
        else
            statusCallback("error", "Falló al aplicar la descripción: "..tostring(errApply))
        end
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

-- VERIFICACIÓN RÍGIDA DE TEXTURAS CIELO
local skyOptions = {
    ["Galaxy"] = {
        Name = "Galaxy",
        Skybox = {
            SkyboxBk = "rbxassetid://1215722140",
            SkyboxDn = "rbxassetid://1215722141",
            SkyboxFt = "rbxassetid://1215722142",
            SkyboxLf = "rbxassetid://1215722143",
            SkyboxRt = "rbxassetid://1215722144",
            SkyboxUp = "rbxassetid://1215722145"
        },
        Preview = "rbxassetid://1215785310"
    },
    ["Nebula"] = {
        Name = "Nebula",
        Skybox = {
            SkyboxBk = "rbxassetid://159454299",
            SkyboxDn = "rbxassetid://159454300",
            SkyboxFt = "rbxassetid://159454296",
            SkyboxLf = "rbxassetid://159454297",
            SkyboxRt = "rbxassetid://159454298",
            SkyboxUp = "rbxassetid://159454301"
        },
        Preview = "rbxassetid://159455084"
    },
    ["Black Hole"] = {
        Name = "Black Hole",
        Skybox = {
            SkyboxBk = "rbxassetid://9595254130",
            SkyboxDn = "rbxassetid://9595254251",
            SkyboxFt = "rbxassetid://9595254346",
            SkyboxLf = "rbxassetid://9595254435",
            SkyboxRt = "rbxassetid://9595254547",
            SkyboxUp = "rbxassetid://9595254829"
        },
        Preview = "rbxassetid://9595263442"
    },
    ["Cosmos"] = {
        Name = "Cosmos",
        Skybox = {
            SkyboxBk = "rbxassetid://48464313",
            SkyboxDn = "rbxassetid://48464316",
            SkyboxFt = "rbxassetid://48464314",
            SkyboxLf = "rbxassetid://48464310",
            SkyboxRt = "rbxassetid://48464312",
            SkyboxUp = "rbxassetid://48464315"
        },
        Preview = "rbxassetid://48464331"
    },
    ["Cosmic Aurora"] = {
        Name = "Cosmic Aurora",
        Skybox = {
            SkyboxBk = "rbxassetid://167180292",
            SkyboxDn = "rbxassetid://167180294",
            SkyboxFt = "rbxassetid://167180295",
            SkyboxLf = "rbxassetid://167180297",
            SkyboxRt = "rbxassetid://167180296",
            SkyboxUp = "rbxassetid://167180293"
        },
        Preview = "rbxassetid://167180321"
    }
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
                if current[p] then
                    originalSky[p] = current[p]
                end
            end
            originalSky._Object = current
        else
            originalSky = { none = true }
        end
    end
end

local function applySkybox(skyInfo)
    local Lighting = game:GetService("Lighting")
    saveOriginalSky()
    local current = findCurrentSky()
    -- No crear múltiples Sky
    local sky = current
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    -- Setea solo si hay cambio
    for k, v in pairs(skyInfo) do
        if sky[k] ~= nil and v and type(v) == "string" and v:find("^rbxassetid://") then
            sky[k] = v
        end
    end
    -- chequeo riguroso de resultado, forzando update
    local changed = false
    for k, v in pairs(skyInfo) do
        if sky[k] ~= v then
            changed = true
        end
    end
    return sky
end

local function restoreOriginalSky()
    local Lighting = game:GetService("Lighting")
    local currSky = findCurrentSky()
    if not originalSky then return false, "No se guardó el cielo original." end
    if originalSky.none then
        if currSky then currSky:Destroy() end
        currentSkyName = "Original"
        return true
    end
    local sky = currSky or Instance.new("Sky")
    sky.Parent = Lighting
    for k, v in pairs(originalSky) do
        if type(k) == "string" and sky[k] ~= nil then
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

local function roundify(obj, radius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, radius)
    uiCorner.Parent = obj
end

local function destroyOld()
    local old = playerGui:FindFirstChild("YabujinHUD")
    if old then old:Destroy() end
    local bubbleOld = playerGui:FindFirstChild("YabujinBubble")
    if bubbleOld then bubbleOld:Destroy() end
end

destroyOld()

local Main = Instance.new("ScreenGui")
Main.Name = "YabujinHUD"
Main.ResetOnSpawn = false
Main.IgnoreGuiInset = false
Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Main.Parent = playerGui

local tabFrames = {}

-- CORREGIDO: agrandar panel para que quepa todo el Avatar Spoofer y que funcione cross-device.
local panelWidth = 610 -- Antes 510
local panelHeight = 410 -- Antes 370
local minX, minY = 20, 20
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

local dragging = false
local dragInput, mousePos, framePos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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

do
    local SpooferFrame = Instance.new("Frame")
    SpooferFrame.Name = "Spoofer"
    SpooferFrame.Size = UDim2.new(1, 0, 1, 0)
    SpooferFrame.BackgroundTransparency = 1
    SpooferFrame.Parent = ContentFrame
    tabFrames["Spoofer"] = SpooferFrame

    local WorldFrame = Instance.new("Frame")
    WorldFrame.Name = "World"
    WorldFrame.Size = UDim2.new(1, 0, 1, 0)
    WorldFrame.BackgroundTransparency = 1
    WorldFrame.Parent = ContentFrame
    tabFrames["World"] = WorldFrame
    WorldFrame.Visible = false

    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Name = "Settings"
    SettingsFrame.Size = UDim2.new(1, 0, 1, 0)
    SettingsFrame.BackgroundTransparency = 1
    SettingsFrame.Parent = ContentFrame
    tabFrames["Settings"] = SettingsFrame
    SettingsFrame.Visible = false
end

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

-------------------------------------------------------------
-- SPOOFER CONTENT
local SpooferFrame = tabFrames["Spoofer"]
local padLeft = 18
local padTop = 24

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Text = "Username"
UsernameLabel.Font = FONT_GAME
UsernameLabel.TextColor3 = ColorTextNorm
UsernameLabel.TextSize = 18
UsernameLabel.Size = UDim2.new(0, 94, 0, 18)
UsernameLabel.Position = UDim2.new(0, padLeft, 0, padTop)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Parent = SpooferFrame

local UsernameBox = Instance.new("TextBox")
UsernameBox.PlaceholderText = localPlayer.Name
UsernameBox.Text = ""
UsernameBox.Font = FONT_GAME
UsernameBox.TextColor3 = ColorTextNorm
UsernameBox.BackgroundColor3 = ColorButton
UsernameBox.Size = UDim2.new(0, 230, 0, 32)
UsernameBox.Position = UDim2.new(0, padLeft, 0, padTop+23)
roundify(UsernameBox, 6)
UsernameBox.Parent = SpooferFrame

local DispLabel = Instance.new("TextLabel")
DispLabel.Text = "Display Name"
DispLabel.Font = FONT_GAME
DispLabel.TextColor3 = ColorTextNorm
DispLabel.TextSize = 18
DispLabel.Size = UDim2.new(0, 124, 0, 18)
DispLabel.Position = UDim2.new(0, padLeft, 0, padTop+73)
DispLabel.BackgroundTransparency = 1
DispLabel.Parent = SpooferFrame

local DispBox = Instance.new("TextBox")
DispBox.PlaceholderText = localPlayer.DisplayName
DispBox.Text = ""
DispBox.Font = FONT_GAME
DispBox.TextColor3 = ColorTextNorm
DispBox.BackgroundColor3 = ColorButton
DispBox.Size = UDim2.new(0, 230, 0, 32)
DispBox.Position = UDim2.new(0, padLeft, 0, padTop+96)
roundify(DispBox, 6)
DispBox.Parent = SpooferFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = ""
statusLabel.Font = FONT_GAME
statusLabel.TextColor3 = ColorIndicatorOk
statusLabel.TextScaled = false
statusLabel.TextSize = 18
statusLabel.Size = UDim2.new(0, 180, 0, 22)
statusLabel.Position = UDim2.new(0, padLeft, 0, padTop+136)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = SpooferFrame

local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Text = "Apply"
ApplyBtn.Font = FONT_GAME
ApplyBtn.TextColor3 = ColorTextNorm
ApplyBtn.BackgroundColor3 = ColorAccent
ApplyBtn.Size = UDim2.new(0, 110, 0, 36)
ApplyBtn.Position = UDim2.new(0, padLeft, 0, padTop+170)
roundify(ApplyBtn, 8)
ApplyBtn.Parent = SpooferFrame

local ResetBtn = Instance.new("TextButton")
ResetBtn.Text = "Reset"
ResetBtn.Font = FONT_GAME
ResetBtn.TextColor3 = ColorTextNorm
ResetBtn.BackgroundColor3 = ColorButton
ResetBtn.Size = UDim2.new(0, 110, 0, 36)
ResetBtn.Position = UDim2.new(0, padLeft+120, 0, padTop+170)
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

-- AVATAR SPOOFER UI
local AvSection = Instance.new("Frame")
AvSection.Name = "AvatarSection"
AvSection.Size = UDim2.new(0, 280, 0, 154) -- ajustado para no sobresalir
AvSection.Position = UDim2.new(0, 270, 0, 24)
AvSection.BackgroundColor3 = ColorPanel
AvSection.BackgroundTransparency = 0.19
AvSection.Parent = SpooferFrame
roundify(AvSection, 10)

local AvLabel = Instance.new("TextLabel")
AvLabel.Text = "Avatar Spoofer"
AvLabel.Font = FONT_GAME
AvLabel.TextColor3 = ColorTextNorm
AvLabel.TextSize = 18
AvLabel.Size = UDim2.new(1, -14, 0, 18)
AvLabel.Position = UDim2.new(0, 7, 0, 6)
AvLabel.BackgroundTransparency = 1
AvLabel.Parent = AvSection

local AvUserBox = Instance.new("TextBox")
AvUserBox.PlaceholderText = "Username Roblox"
AvUserBox.Text = ""
AvUserBox.Font = FONT_GAME
AvUserBox.TextColor3 = ColorTextNorm
AvUserBox.BackgroundColor3 = ColorButton
AvUserBox.Size = UDim2.new(0, 150, 0, 32)
AvUserBox.Position = UDim2.new(0, 13, 0, 32)
roundify(AvUserBox, 7)
AvUserBox.Parent = AvSection

local AvatarApplyBtn = Instance.new("TextButton")
AvatarApplyBtn.Text = "Apply"
AvatarApplyBtn.Font = FONT_GAME
AvatarApplyBtn.TextColor3 = ColorTextNorm
AvatarApplyBtn.BackgroundColor3 = ColorAccent
AvatarApplyBtn.Size = UDim2.new(0, 52, 0, 32)
AvatarApplyBtn.Position = UDim2.new(0, 174, 0, 32)
roundify(AvatarApplyBtn, 7)
AvatarApplyBtn.Parent = AvSection

local AvatarResetBtn = Instance.new("TextButton")
AvatarResetBtn.Text = "Reset"
AvatarResetBtn.Font = FONT_GAME
AvatarResetBtn.TextColor3 = ColorTextNorm
AvatarResetBtn.BackgroundColor3 = ColorButton
AvatarResetBtn.Size = UDim2.new(0, 52, 0, 32)
AvatarResetBtn.Position = UDim2.new(0, 230, 0, 32)
roundify(AvatarResetBtn, 7)
AvatarResetBtn.Parent = AvSection

local AvPreview = Instance.new("ImageLabel")
AvPreview.Size = UDim2.new(0, 50, 0, 50)
AvPreview.Position = UDim2.new(0, 13, 0, 72)
AvPreview.BackgroundColor3 = ColorButton
AvPreview.BackgroundTransparency = 0.3
AvPreview.Image = ""
AvPreview.Parent = AvSection
roundify(AvPreview, 8)

local AvStatusLbl = Instance.new("TextLabel")
AvStatusLbl.Text = ""
AvStatusLbl.Font = FONT_GAME
AvStatusLbl.TextColor3 = ColorIndicatorOk
AvStatusLbl.TextSize = 16
AvStatusLbl.Size = UDim2.new(1, -74, 0, 36)
AvStatusLbl.Position = UDim2.new(0, 73, 0, 80)
AvStatusLbl.BackgroundTransparency = 1
AvStatusLbl.TextWrapped = true
AvStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
AvStatusLbl.Parent = AvSection

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

-- AVATAR SPOOFER USERID: debajo de Avatar Spoofer para evitar solapamiento
local AvUIDSection = Instance.new("Frame")
AvUIDSection.Name = "AvatarIDSection"
AvUIDSection.Size = UDim2.new(0, 280, 0, 85)
AvUIDSection.Position = UDim2.new(0, 270, 0, 185)
AvUIDSection.BackgroundColor3 = ColorPanel
AvUIDSection.BackgroundTransparency = 0.19
AvUIDSection.Parent = SpooferFrame
roundify(AvUIDSection, 8)

local AvUIDLbl = Instance.new("TextLabel")
AvUIDLbl.Text = "Avatar por UserId"
AvUIDLbl.Font = FONT_GAME
AvUIDLbl.TextColor3 = ColorTextNorm
AvUIDLbl.TextSize = 16
AvUIDLbl.Size = UDim2.new(1, -18, 0, 18)
AvUIDLbl.Position = UDim2.new(0, 9, 0, 4)
AvUIDLbl.BackgroundTransparency = 1
AvUIDLbl.Parent = AvUIDSection

local AvUserIDBox = Instance.new("TextBox")
AvUserIDBox.PlaceholderText = "User Id (num)"
AvUserIDBox.Text = ""
AvUserIDBox.Font = FONT_GAME
AvUserIDBox.TextColor3 = ColorTextNorm
AvUserIDBox.BackgroundColor3 = ColorButton
AvUserIDBox.Size = UDim2.new(0, 100, 0, 32)
AvUserIDBox.Position = UDim2.new(0, 13, 0, 27)
roundify(AvUserIDBox, 7)
AvUserIDBox.Parent = AvUIDSection

local AvUserIdPreview = Instance.new("ImageLabel")
AvUserIdPreview.Size = UDim2.new(0, 32, 0, 32)
AvUserIdPreview.Position = UDim2.new(0, 122, 0, 27)
AvUserIdPreview.BackgroundColor3 = ColorButton
AvUserIdPreview.BackgroundTransparency = 0.35
AvUserIdPreview.Image = ""
AvUserIdPreview.Parent = AvUIDSection
roundify(AvUserIdPreview, 7)

local AvIDApplyBtn = Instance.new("TextButton")
AvIDApplyBtn.Text = "Apply"
AvIDApplyBtn.Font = FONT_GAME
AvIDApplyBtn.TextColor3 = ColorTextNorm
AvIDApplyBtn.BackgroundColor3 = ColorAccent
AvIDApplyBtn.Size = UDim2.new(0, 52, 0, 32)
AvIDApplyBtn.Position = UDim2.new(0, 164, 0, 27)
roundify(AvIDApplyBtn, 7)
AvIDApplyBtn.Parent = AvUIDSection

local AvIDResetBtn = Instance.new("TextButton")
AvIDResetBtn.Text = "Reset"
AvIDResetBtn.Font = FONT_GAME
AvIDResetBtn.TextColor3 = ColorTextNorm
AvIDResetBtn.BackgroundColor3 = ColorButton
AvIDResetBtn.Size = UDim2.new(0, 52, 0, 32)
AvIDResetBtn.Position = UDim2.new(0, 220, 0, 27)
roundify(AvIDResetBtn, 7)
AvIDResetBtn.Parent = AvUIDSection

local AvIDStatusLbl = Instance.new("TextLabel")
AvIDStatusLbl.Text = ""
AvIDStatusLbl.Font = FONT_GAME
AvIDStatusLbl.TextColor3 = ColorIndicatorOk
AvIDStatusLbl.TextSize = 16
AvIDStatusLbl.Size = UDim2.new(1, -18, 0, 18)
AvIDStatusLbl.Position = UDim2.new(0, 9, 0, 63)
AvIDStatusLbl.BackgroundTransparency = 1
AvIDStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
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

-------------------------------------------------------------
-- WORLD TAB
local WorldFrame = tabFrames["World"]
local w_pad, w_y = 22, 22
local boxesPerRow, boxPad, boxW, boxH = 2, 22, 230, 82
local idx=0

local skyStatusLbl = Instance.new("TextLabel")
skyStatusLbl.Text = ""
skyStatusLbl.Font = FONT_GAME
skyStatusLbl.TextColor3 = ColorIndicatorOk
skyStatusLbl.TextSize = 18
skyStatusLbl.Position = UDim2.new(0, w_pad, 0, 355)
skyStatusLbl.Size = UDim2.new(1, -w_pad*2, 0, 22)
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

    -- Prueba real de cambio
    local success, err = pcall(function()
        local sky = applySkybox(skyOptions[name].Skybox)
        wait(0.15)
        local valid = true
        for k, v in pairs(skyOptions[name].Skybox) do
            if not sky or sky[k] ~= v then valid = false break end
        end
        if valid then
            currentSkyName = name
            setSkyStatus("success", "Cielo aplicado: "..name)
        else
            setSkyStatus("error", "No se pudo aplicar el cielo (el juego puede estar sobrescribiendo el Sky).")
        end
    end)
    if not success then
        setSkyStatus("error", "Error al intentar cambiar el cielo: "..tostring(err))
    end
end

local function genSkyBox(k, dat, i)
    idx = idx + 1
    local row = math.floor((idx-1)/boxesPerRow)
    local col = (idx-1)%boxesPerRow
    local box = Instance.new("Frame")
    box.Name = k.."Box"
    box.Size = UDim2.new(0, boxW, 0, boxH)
    box.Position = UDim2.new(0, w_pad + col*(boxW + boxPad), 0, w_y + row*(boxH + 22))
    box.BackgroundColor3 = (currentSkyName == k) and ColorSkySelected or ColorButton
    box.BackgroundTransparency = 0.19
    box.Parent = WorldFrame
    roundify(box, 9)
    local preview = Instance.new("ImageLabel")
    preview.Image = dat.Preview
    preview.Size = UDim2.new(0, 62, 0, 62)
    preview.Position = UDim2.new(0, 9, 0, 10)
    preview.BackgroundTransparency = 1
    preview.Parent = box
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = dat.Name
    nameLbl.Font = FONT_GAME
    nameLbl.TextColor3 = ColorTextNorm
    nameLbl.TextSize = 18
    nameLbl.Position = UDim2.new(0, 88, 0, 12)
    nameLbl.Size = UDim2.new(0, 109, 0, 22)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = box
    local ApplyBtn = Instance.new("TextButton")
    ApplyBtn.Text = "Apply"
    ApplyBtn.Font = FONT_GAME
    ApplyBtn.TextColor3 = ColorTextNorm
    ApplyBtn.BackgroundColor3 = ColorAccent
    ApplyBtn.Size = UDim2.new(0, 70, 0, 32)
    ApplyBtn.Position = UDim2.new(1, -80, 1, -44)
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
RestoreSkyBtn.Text = "Restaurar original"
RestoreSkyBtn.Font = FONT_GAME
RestoreSkyBtn.TextColor3 = ColorTextNorm
RestoreSkyBtn.BackgroundColor3 = ColorButton
RestoreSkyBtn.Size = UDim2.new(0, 183, 0, 38)
RestoreSkyBtn.Position = UDim2.new(1, -196, 1, -54)
roundify(RestoreSkyBtn, 8)
RestoreSkyBtn.Parent = WorldFrame
RestoreSkyBtn.MouseButton1Click:Connect(function()
    local ok, err = pcall(function()
        if restoreOriginalSky() then
            setSkyStatus("success", "Cielo restaurado")
        else
            setSkyStatus("error", err or "No se pudo restaurar el cielo original.")
        end
        for _, framen in ipairs(WorldFrame:GetChildren()) do
            if framen:IsA("Frame") then
                framen.BackgroundColor3 = ColorButton
            end
        end
    end)
    if not ok then
        setSkyStatus("error", "No se pudo restaurar el cielo: "..tostring(err))
    end
end)

-------------------------------------------------------------
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
    if not Main or not Main.Parent then return end
    if waitForKey and inp.UserInputType == Enum.UserInputType.Keyboard then
        menuKey = inp.KeyCode
        currKeyBtn.Text = tostring(menuKey.Name)
        currKeyBtn.TextColor3 = ColorAccent
        waitForKey = false
    elseif inp.KeyCode == menuKey and not waitForKey and not gameProcessed then
        menuVisible = not menuVisible
        Panel.Visible = menuVisible
        -- No tocar Bubble: el usuario elige con el botón flotante. Bubble nunca debe desaparecer según nuevas reglas.
    end
end)

game:GetService("Workspace").CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    Panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
    if Bubble then
        -- Bubble respeta última posición elegida por el usuario
        -- Bubble no se mueve automáticamente por defecto
    end
end)

-------------------------------------------------------------
-- BOLITA FLOTANTE MORADA SIEMPRE visible, DRAGGABLE y no tapa nada
local bubbleDiameter = 44
local defaultBubblePos = UDim2.new(0, sidebarW + 28, 0, 32) -- Cerca panel, arriba
local Bubble = Instance.new("ImageButton")
Bubble.Name = "YabujinBubble"
Bubble.Size = UDim2.new(0, bubbleDiameter, 0, bubbleDiameter)
Bubble.Position = defaultBubblePos
Bubble.BackgroundColor3 = ColorAccent
Bubble.Image = ""
Bubble.Visible = true
Bubble.Active = true
Bubble.BackgroundTransparency = 0
Bubble.AutoButtonColor = true
Bubble.ZIndex = 9999
Bubble.Parent = playerGui
roundify(Bubble, bubbleDiameter//2)
local bubbleIcon = Instance.new("ImageLabel")
bubbleIcon.BackgroundTransparency = 1
bubbleIcon.Image = "rbxassetid://6031091007"
bubbleIcon.Size = UDim2.new(0.76,0,0.76,0)
bubbleIcon.Position = UDim2.new(0.12,0,0.13,0)
bubbleIcon.Parent = Bubble

-- BOLITA: DRAGGABLE EN PC Y MÓVIL
local draggingBubble = false
local dragInputBubble, bubbleMousePos, bubbleFramePos

Bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingBubble = true
        bubbleMousePos = input.Position
        bubbleFramePos = Bubble.Position
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
        -- Solo mover la Bubble dentro del tamaño de pantalla actual, sin tapar los paneles
        local delta = input.Position - bubbleMousePos
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800,600)
        local minXb = 10
        local minYb = 10
        local maxX = math.max(vp.X - bubbleDiameter - 5, minXb)
        local maxY = math.max(vp.Y - bubbleDiameter - 5, minYb)
        local newX = math.clamp(bubbleFramePos.X.Offset + delta.X, minXb, maxX)
        local newY = math.clamp(bubbleFramePos.Y.Offset + delta.Y, minYb, maxY)
        Bubble.Position = UDim2.new(0, newX, 0, newY)
    end
end)

-- Toggle SOLO si no está arrastrando y mouse está "liberado"
local canToggleMenu = true -- control para evitar doble click tras drag
local function pointerUp()
    canToggleMenu = true
end
local function pointerDown()
    canToggleMenu = false
end
-- Bubble.Toggle funciona al liberar tap/click y no hubo drag
Bubble.MouseButton1Down:Connect(pointerDown)
Bubble.TouchLongPress:Connect(pointerDown)
Bubble.MouseButton1Up:Connect(function()
    wait() -- delay a frame por si drag
    if not draggingBubble then
        menuVisible = not menuVisible
        Panel.Visible = menuVisible
    end
    pointerUp()
end)
Bubble.TouchTap:Connect(function()
    if not draggingBubble then
        menuVisible = not menuVisible
        Panel.Visible = menuVisible
    end
end)

-- Nunca ocultar Bubble
Panel:GetPropertyChangedSignal("Visible"):Connect(function()
    -- No ocultar Bubble, la bolita es SIEMPRE visible
end)
