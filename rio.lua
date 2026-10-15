----------------------------------------------------------------------
-- YABUJIN HUD — ROBLOX RIVALS (ACTUALIZADO: SPOOFER POR USER ID)
----------------------------------------------------------------------

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

----------------------------------------------------------------------
-- [Colores]
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
local ColorFloating = Color3.fromRGB(132, 57, 251)

local FONT_GAME = Enum.Font.GothamBold

local menuVisible = true
local menuKey = Enum.KeyCode.RightShift

----------------------------------------------------------------------
-- [Guardado de Estado original del usuario y cielo]
local savedDisplayName = nil
local savedUsername = nil
local savedAvatarDesc = nil -- para Avatar Spoofer
local savedUserId = nil
local currentAvatarSpoofTarget = nil

local originalSky = nil
local currentSkyName = "Original"

----------------------------------------------------------------------
-- [Utilidades]
local function roundify(obj, radius)
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, radius)
    uiCorner.Parent = obj
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

----------------------------------------------------------------------
-- [Creación de HUD Principal]
local function destroyOld()
    local old = playerGui:FindFirstChild("YabujinHUD")
    if old then old:Destroy() end
end
destroyOld()

local Main = Instance.new("ScreenGui")
Main.Name = "YabujinHUD"
Main.ResetOnSpawn = false
Main.IgnoreGuiInset = false
Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Main.Parent = playerGui

----------------------------------------------------------------------
-- [Draggable & Responsive Panel]
local panelWidth = 510
local panelHeight = 370
local minX, minY = 60, 36

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

-- Topbar
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

-- Floating ball for aesthetics
local function createFloatingBall()
    local ball = Instance.new("Frame")
    ball.BackgroundTransparency = 0.27
    ball.Size = UDim2.new(0, 33, 0, 33)
    ball.Position = UDim2.new(0, panelWidth-49, 0, -14)
    ball.BackgroundColor3 = ColorFloating
    roundify(ball, 70)
    ball.ZIndex = 3
    ball.Parent = Panel
    -- Sutil rebote
    spawn(function()
        local t = 0
        while ball.Parent do
            t = t + RunService.RenderStepped:Wait()
            ball.Position = UDim2.new(0, panelWidth-49, 0, -14 + math.sin(t*2.1)*3)
        end
    end)
end
createFloatingBall()

-- Dragging logic
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
        local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset+delta.X, framePos.Y.Scale, framePos.Y.Offset+delta.Y)
        newPos = UDim2.new(
            0, math.clamp(newPos.X.Offset, minX, workspace.CurrentCamera.ViewportSize.X - panelWidth - minX),
            0, math.clamp(newPos.Y.Offset, minY, workspace.CurrentCamera.ViewportSize.Y - panelHeight - minY)
        )
        Panel.Position = newPos
    end
end)

----------------------------------------------------------------------

-- [Sidebar]
local sidebarW = 110

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, sidebarW, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = ColorSidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Panel
roundify(Sidebar, 10)

-- Sidebar Tabs
local tabs = {{"Spoofer","Spoofer"},{"World","World"},{"Configuración","Settings"}}
local selectedTab = "Spoofer"
local tabButtons = {}
local tabFrames = {}

-- [Contenedores para cada Tab]
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -sidebarW, 1, -40)
ContentFrame.Position = UDim2.new(0, sidebarW, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = Panel

----------------------------------------------------------------------

-- [SPOOFER TAB]
local SpooferFrame = Instance.new("Frame")
SpooferFrame.Name = "Spoofer"
SpooferFrame.Size = UDim2.new(1, 0, 1, 0)
SpooferFrame.BackgroundTransparency = 1
SpooferFrame.Parent = ContentFrame
tabFrames["Spoofer"] = SpooferFrame

----------------------------------------------------------------------

-- [WORLD TAB]
local WorldFrame = Instance.new("Frame")
WorldFrame.Name = "World"
WorldFrame.Size = UDim2.new(1, 0, 1, 0)
WorldFrame.BackgroundTransparency = 1
WorldFrame.Parent = ContentFrame
WorldFrame.Visible = false
tabFrames["World"] = WorldFrame

----------------------------------------------------------------------

-- [SETTINGS TAB]
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Name = "Settings"
SettingsFrame.Size = UDim2.new(1, 0, 1, 0)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Parent = ContentFrame
SettingsFrame.Visible = false
tabFrames["Settings"] = SettingsFrame

----------------------------------------------------------------------

-- [NAVIGATION LOGIC]
for i, tabPair in ipairs(tabs) do
    local tabText, tabKey = tabPair[1], tabPair[2]
    local btn = Instance.new("TextButton")
    btn.Name = tabKey.."Tab"
    btn.Text = tabText
    btn.Font = FONT_GAME
    btn.TextScaled = true
    btn.BackgroundColor3 = (selectedTab == tabKey) and ColorAccent or ColorButton
    btn.TextColor3 = ColorTextNorm
    btn.Position = UDim2.new(0, 10, 0, ((i-1) * 56) + 16)
    btn.Size = UDim2.new(1, -22, 0, 42)
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    roundify(btn, 8)
    tabButtons[tabKey] = btn

    btn.MouseEnter:Connect(function()
        if selectedTab ~= tabKey then
            animateButton(btn, ColorButtonHover)
        end
    end)
    btn.MouseLeave:Connect(function()
        if selectedTab ~= tabKey then
            animateButton(btn, ColorButton)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        for name, frame in pairs(tabFrames) do
            frame.Visible = (name == tabKey)
        end
        for key, button in pairs(tabButtons) do
            animateButton(button, ColorButton)
        end
        animateButton(btn, ColorAccent)
        selectedTab = tabKey
    end)
end
for name, frame in pairs(tabFrames) do
    frame.Visible = (name == selectedTab)
end

----------------------------------------------------------------------

-- [SPOOFER UI Section]
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

local spoofStatus = "normal"
local statusText = ""
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

----------------------------------------------------------------------
-- [Spoofer Logic]

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

StarterGui.MenuOpened:Connect(function()
    local uname = UsernameBox.Text ~= "" and UsernameBox.Text or nil
    local dname = DispBox.Text ~= "" and DispBox.Text or nil
    spoofName(uname, dname)
end)

ApplyBtn.MouseButton1Click:Connect(function()
    local uname = UsernameBox.Text ~= "" and UsernameBox.Text or nil
    local dname = DispBox.Text ~= "" and DispBox.Text or nil
    local ok, msg = spoofName(uname, dname)
    if ok then
        spoofStatus = "success"
        statusText = "Cambiado localmente"
        statusLabel.TextColor3 = ColorIndicatorOk
    else
        spoofStatus = "error"
        statusText = "No fue posible"
        statusLabel.TextColor3 = ColorIndicatorFail
    end
    statusLabel.Text = statusText
end)

ResetBtn.MouseButton1Click:Connect(function()
    resetName()
    spoofStatus = "reset"
    statusText = "Restaurado"
    statusLabel.TextColor3 = ColorIndicatorOk
    statusLabel.Text = statusText
end)

----------------------------------------------------------------------

-- [AVATAR SPOOFER UI y Lógica]
-- Por USERNAME
local AvSection = Instance.new("Frame")
AvSection.Name = "AvatarSection"
AvSection.Size = UDim2.new(0, 255, 0, 85)
AvSection.Position = UDim2.new(0, 245, 0, 20)
AvSection.BackgroundColor3 = ColorPanel
AvSection.BackgroundTransparency = 0.22
AvSection.Parent = SpooferFrame
roundify(AvSection, 10)

local AvLabel = Instance.new("TextLabel")
AvLabel.Text = "Avatar Spoofer by Username"
AvLabel.Font = FONT_GAME
AvLabel.TextColor3 = ColorTextNorm
AvLabel.TextSize = 15
AvLabel.Size = UDim2.new(1, -16, 0, 17)
AvLabel.Position = UDim2.new(0, 8, 0, 5)
AvLabel.BackgroundTransparency = 1
AvLabel.Parent = AvSection

local AvUserBox = Instance.new("TextBox")
AvUserBox.PlaceholderText = "Username"
AvUserBox.Text = ""
AvUserBox.Font = FONT_GAME
AvUserBox.TextColor3 = ColorTextNorm
AvUserBox.BackgroundColor3 = ColorButton
AvUserBox.Size = UDim2.new(0, 115, 0, 28)
AvUserBox.Position = UDim2.new(0, 10, 0, 30)
roundify(AvUserBox, 7)
AvUserBox.Parent = AvSection

local AvApplyBtn = Instance.new("TextButton")
AvApplyBtn.Text = "Apply"
AvApplyBtn.Font = FONT_GAME
AvApplyBtn.TextColor3 = ColorTextNorm
AvApplyBtn.BackgroundColor3 = ColorAccent
AvApplyBtn.Size = UDim2.new(0, 54, 0, 28)
AvApplyBtn.Position = UDim2.new(0, 132, 0, 30)
roundify(AvApplyBtn, 7)
AvApplyBtn.Parent = AvSection

local AvResetBtn = Instance.new("TextButton")
AvResetBtn.Text = "Reset"
AvResetBtn.Font = FONT_GAME
AvResetBtn.TextColor3 = ColorTextNorm
AvResetBtn.BackgroundColor3 = ColorButton
AvResetBtn.Size = UDim2.new(0, 54, 0, 28)
AvResetBtn.Position = UDim2.new(0, 189, 0, 30)
roundify(AvResetBtn, 7)
AvResetBtn.Parent = AvSection

local AvStatusLbl = Instance.new("TextLabel")
AvStatusLbl.Text = ""
AvStatusLbl.Font = FONT_GAME
AvStatusLbl.TextColor3 = ColorIndicatorOk
AvStatusLbl.TextSize = 15
AvStatusLbl.Size = UDim2.new(1, -16, 0, 18)
AvStatusLbl.Position = UDim2.new(0, 8, 0, 61)
AvStatusLbl.BackgroundTransparency = 1
AvStatusLbl.Parent = AvSection

local function setAvatarStatus(type, msg)
    if type=="loading" then
        AvStatusLbl.Text = "Cargando..."
        AvStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type=="success" then
        AvStatusLbl.Text = "Aplicado"
        AvStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type=="error" then
        AvStatusLbl.Text = msg or "No se pudo aplicar"
        AvStatusLbl.TextColor3 = ColorIndicatorFail
    else
        AvStatusLbl.Text = ""
    end
end

-- Por USER ID
local AvIdSection = Instance.new("Frame")
AvIdSection.Name = "AvatarIdSection"
AvIdSection.Size = UDim2.new(0, 255, 0, 85)
AvIdSection.Position = UDim2.new(0, 245, 0, 115)
AvIdSection.BackgroundColor3 = ColorPanel
AvIdSection.BackgroundTransparency = 0.22
AvIdSection.Parent = SpooferFrame
roundify(AvIdSection, 10)

local AvIdLabel = Instance.new("TextLabel")
AvIdLabel.Text = "Avatar Spoofer by User ID"
AvIdLabel.Font = FONT_GAME
AvIdLabel.TextColor3 = ColorTextNorm
AvIdLabel.TextSize = 15
AvIdLabel.Size = UDim2.new(1, -16, 0, 17)
AvIdLabel.Position = UDim2.new(0, 8, 0, 5)
AvIdLabel.BackgroundTransparency = 1
AvIdLabel.Parent = AvIdSection

local AvIdBox = Instance.new("TextBox")
AvIdBox.PlaceholderText = "User Id"
AvIdBox.Text = ""
AvIdBox.Font = FONT_GAME
AvIdBox.TextColor3 = ColorTextNorm
AvIdBox.BackgroundColor3 = ColorButton
AvIdBox.Size = UDim2.new(0, 115, 0, 28)
AvIdBox.Position = UDim2.new(0, 10, 0, 30)
roundify(AvIdBox, 7)
AvIdBox.Parent = AvIdSection

local AvIdApplyBtn = Instance.new("TextButton")
AvIdApplyBtn.Text = "Apply"
AvIdApplyBtn.Font = FONT_GAME
AvIdApplyBtn.TextColor3 = ColorTextNorm
AvIdApplyBtn.BackgroundColor3 = ColorAccent
AvIdApplyBtn.Size = UDim2.new(0, 54, 0, 28)
AvIdApplyBtn.Position = UDim2.new(0, 132, 0, 30)
roundify(AvIdApplyBtn, 7)
AvIdApplyBtn.Parent = AvIdSection

local AvIdResetBtn = Instance.new("TextButton")
AvIdResetBtn.Text = "Reset"
AvIdResetBtn.Font = FONT_GAME
AvIdResetBtn.TextColor3 = ColorTextNorm
AvIdResetBtn.BackgroundColor3 = ColorButton
AvIdResetBtn.Size = UDim2.new(0, 54, 0, 28)
AvIdResetBtn.Position = UDim2.new(0, 189, 0, 30)
roundify(AvIdResetBtn, 7)
AvIdResetBtn.Parent = AvIdSection

local AvIdStatusLbl = Instance.new("TextLabel")
AvIdStatusLbl.Text = ""
AvIdStatusLbl.Font = FONT_GAME
AvIdStatusLbl.TextColor3 = ColorIndicatorOk
AvIdStatusLbl.TextSize = 15
AvIdStatusLbl.Size = UDim2.new(1, -16, 0, 18)
AvIdStatusLbl.Position = UDim2.new(0, 8, 0, 61)
AvIdStatusLbl.BackgroundTransparency = 1
AvIdStatusLbl.Parent = AvIdSection

local function setAvatarIdStatus(type, msg)
    if type=="loading" then
        AvIdStatusLbl.Text = "Cargando..."
        AvIdStatusLbl.TextColor3 = ColorIndicatorWait
    elseif type=="success" then
        AvIdStatusLbl.Text = "Aplicado"
        AvIdStatusLbl.TextColor3 = ColorIndicatorOk
    elseif type=="error" then
        AvIdStatusLbl.Text = msg or "No se pudo aplicar"
        AvIdStatusLbl.TextColor3 = ColorIndicatorFail
    else
        AvIdStatusLbl.Text = ""
    end
end

-- [Logica principal AVATAR]
local function saveOriginalAppearance()
    if not localPlayer.Character then return end
    savedAvatarDesc = nil
    local ok, desc = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
    end)
    if ok and desc then
        savedAvatarDesc = desc
        savedUserId = localPlayer.UserId
    end
end
saveOriginalAppearance()

local function spoofAvatarByUserId(str_id, cb)
    cb = cb or function() end
    local userId = tonumber(str_id)
    if not userId then
        cb("error","ID inválido")
        return
    end
    cb("loading")
    local ok, desc = pcall(function()
        return Players:GetHultc1qalrd99hju33uagsf8927k7xfxr423gr93gnjz8(userId)
    end)
    if ok and desc then
        if not savedAvatarDesc then saveOriginalAppearance() end
        local char = localPlayer.Character
        local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local success2, err2 = pcall(function()
                humanoid:ApplyDescription(desc)
            end)
            if success2 then
                currentAvatarSpoofTarget = userId
                cb("success")
                return
            else
                cb("error", "No se pudo aplicar la apariencia: "..tostring(err2))
                return
            end
        else
            cb("error", "Humanoid no encontrado.")
            return
        end
    elseif not ok and desc:find("not allowed") then
        cb("error", "No permitido por el juego.")
        return
    else
        cb("error","No se pudo obtener la apariencia.")
    end
end

local function spoofAvatarFromUsername(username, cb)
    cb = cb or function() end
    if not username or username == "" then
        cb("error", "Username vacío")
        return
    end
    cb("loading")
    local ok, resp = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://users.roblox.com/v1/usernames/users?usernames=[\""..username.."\"]&excludeBannedUsers=true"))
    end)
    if not ok or not resp or not resp.data or #resp.data == 0 or not resp.data[1].id then
        cb("error", "Usuario no encontrado.")
        return
    end
    local userId = resp.data[1].id
    spoofAvatarByUserId(userId, cb)
end

local function resetAvatar(cb)
    cb = cb or function() end
    if not savedAvatarDesc then
        cb("error", "Sin backup de aspecto original")
        return
    end
    local char = localPlayer.Character
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local ok, err = pcall(function()
            humanoid:ApplyDescription(savedAvatarDesc)
        end)
        if ok then
            currentAvatarSpoofTarget = nil
            cb("success")
        else
            cb("error", "No se pudo restaurar: "..tostring(err))
        end
    else
        cb("error", "Humanoid no encontrado")
    end
end

AvApplyBtn.MouseButton1Click:Connect(function()
    local user = AvUserBox.Text
    if not user or #user < 3 then
        setAvatarStatus("error", "Username inválido")
        return
    end
    spoofAvatarFromUsername(user, setAvatarStatus)
end)
AvResetBtn.MouseButton1Click:Connect(function()
    resetAvatar(setAvatarStatus)
end)

AvIdApplyBtn.MouseButton1Click:Connect(function()
    local id = AvIdBox.Text
    if not id or #id < 1 then
        setAvatarIdStatus("error", "ID vacío")
        return
    end
    spoofAvatarByUserId(id, setAvatarIdStatus)
end)
AvIdResetBtn.MouseButton1Click:Connect(function()
    resetAvatar(setAvatarIdStatus)
end)

local function handleCharReset()
    if currentAvatarSpoofTarget then
        spoofAvatarByUserId(currentAvatarSpoofTarget, function(st,msg)
            if st~="success" then
                setAvatarIdStatus("error","El juego impide el spoofing localmente.")
            end
        end)
    elseif savedAvatarDesc then
        resetAvatar()
    end
end

localPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    handleCharReset()
end)

----------------------------------------------------------------------

-- [WORLD - Galactic Skies]
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
        if v:IsA("Sky") then return v end
    end
    return nil
end

local function saveOriginalSky()
    if not originalSky then
        local curr = findCurrentSky()
        if curr then
            originalSky = {}
            for _, prop in pairs({"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"}) do
                originalSky[prop] = curr[prop]
            end
        end
    end
end

local function applySkybox(skyInfo)
    local Lighting = game:GetService("Lighting")
    local sky = findCurrentSky()
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    saveOriginalSky()
    for k, v in pairs(skyInfo) do
        if sky[k] ~= nil then
            sky[k] = v
        end
    end
end

local function restoreOriginalSky()
    if not originalSky then return end
    local sky = findCurrentSky()
    if not sky then return end
    for k,v in pairs(originalSky) do
        if sky[k] then
            sky[k] = v
        end
    end
    currentSkyName = "Original"
end

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
    pcall(function()
        applySkybox(skyOptions[name].Skybox)
        currentSkyName = name
        setSkyStatus("success", "Cielo aplicado: "..name)
    end)
end

local function genSkyBox(k, dat, i)
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
            if framen:IsA("Frame") and framen ~= box then
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
RestoreSkyBtn.Position = UDim2.new(1, -170, 1, -45)
roundify(RestoreSkyBtn, 8)
RestoreSkyBtn.Parent = WorldFrame

RestoreSkyBtn.MouseButton1Click:Connect(function()
    pcall(function() restoreOriginalSky() end)
    setSkyStatus("success", "Cielo restaurado")
    for _, framen in ipairs(WorldFrame:GetChildren()) do
        if framen:IsA("Frame") then
            framen.BackgroundColor3 = ColorButton
        end
    end
end)

----------------------------------------------------------------------

-- [SETTINGS TAB]: Cambiar tecla menú
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
    end
end)

----------------------------------------------------------------------

-- [Responsividad al cambiar tamaño ventana]
game:GetService("Workspace").CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    Panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
end)
