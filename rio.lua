-- YABUJIN | REAL EXECUTOR - LOCAL VISUAL UI
-- Paste this entire file into your executor OR host it on your own raw-text URL.
-- Important: this changes client-side UI/visuals only. It cannot change Rivals server identity,
-- official level, contracts, currencies, platform detection, leaderboard, or other players' views.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local function protect(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then return result end
    return nil
end

-- Parent to executor UI container when available; otherwise use PlayerGui.
local uiParent
if typeof(gethui) == "function" then
    uiParent = protect(gethui)
end
if not uiParent then
    uiParent = protect(function() return game:GetService("CoreGui") end)
end
if not uiParent then
    uiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local previous = uiParent:FindFirstChild("YabujinRealVisualUI")
if previous then protect(function() previous:Destroy() end) end

local C = {
    bg = Color3.fromRGB(13, 13, 16),
    panel = Color3.fromRGB(22, 22, 27),
    panel2 = Color3.fromRGB(29, 29, 35),
    purple = Color3.fromRGB(139, 87, 255),
    purpleDark = Color3.fromRGB(54, 37, 83),
    text = Color3.fromRGB(242, 241, 248),
    muted = Color3.fromRGB(157, 155, 169),
    border = Color3.fromRGB(55, 53, 65),
    green = Color3.fromRGB(120, 230, 165),
}

local state = {
    level = "14",
    username = LocalPlayer.Name,
    displayName = LocalPlayer.DisplayName,
    userId = tostring(LocalPlayer.UserId),
    avatarId = tostring(LocalPlayer.UserId),
    platform = "PC",
    contractName = "Assault Rifle",
    eliminations = "33",
    playtime = "1222",
    keys = "29",
    tokens = "0",
    extraStats = "",
    theme = "Default",
    fov = 70,
    noHands = false,
    levelEnabled = false,
    identityPreview = false,
    avatarPreview = false,
    platformEnabled = false,
    contractsEnabled = false,
    resourcesEnabled = false,
}

local gui = Instance.new("ScreenGui")
gui.Name = "YabujinRealVisualUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
protect(function() gui.DisplayOrder = 999999 end)
gui.Parent = uiParent

local function new(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        protect(function() obj[k] = v end)
    end
    obj.Parent = parent
    return obj
end
local function corner(obj, radius)
    new("UICorner", {CornerRadius = UDim.new(0, radius or 6)}, obj)
end
local function outline(obj, color, thickness)
    new("UIStroke", {Color = color or C.border, Thickness = thickness or 1, Transparency = 0.08}, obj)
end
local function label(parent, txt, size, bold, color)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Text = txt or "",
        TextColor3 = color or C.text,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Code,
        TextSize = size or 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end
local function button(parent, txt, height, callback)
    local b = new("TextButton", {
        Size = UDim2.new(1, 0, 0, height or 30),
        BackgroundColor3 = C.panel2,
        Text = txt or "Button",
        TextColor3 = C.text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        AutoButtonColor = true,
        TextWrapped = true,
    }, parent)
    corner(b, 5); outline(b)
    if callback then b.Activated:Connect(callback) end
    return b
end
local inputControls = {}
local toggleControls = {}
local function input(parent, caption, initial, placeholder, callback, stateKey)
    local wrap = new("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 1}, parent)
    local title = label(wrap, caption, 11, false, C.muted)
    title.Position = UDim2.new(0, 1, 0, 0)
    title.Size = UDim2.new(1, 0, 0, 18)
    local box = new("TextBox", {
        Position = UDim2.new(0, 0, 0, 21), Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = C.panel2, TextColor3 = C.text, PlaceholderColor3 = C.muted,
        Text = tostring(initial or ""), PlaceholderText = placeholder or "Enter value",
        ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code, TextSize = 12, TextWrapped = false,
    }, wrap)
    corner(box, 4); outline(box)
    new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 6)}, box)
    box.FocusLost:Connect(function()
        if callback then callback(box.Text) end
    end)
    if stateKey then inputControls[stateKey] = box end
    return box
end
local function toggle(parent, caption, initial, callback, stateKey)
    local value = initial == true
    local b = button(parent, (value and "ON  ✓   " or "OFF  ◻   ") .. caption, 30)
    local function paint()
        b.Text = (value and "ON  ✓   " or "OFF  ◻   ") .. caption
        b.BackgroundColor3 = value and C.purpleDark or C.panel2
    end
    paint()
    b.Activated:Connect(function()
        value = not value; paint()
        if callback then callback(value) end
    end)
    local controller = {button = b, get = function() return value end, set = function(v) value = v == true; paint(); if callback then callback(value) end end}
    if stateKey then toggleControls[stateKey] = controller end
    return controller
end
local function card(parent, titleText, height)
    local f = new("Frame", {Size = UDim2.new(1, -4, 0, height), BackgroundColor3 = C.panel}, parent)
    corner(f, 7); outline(f)
    local head = new("Frame", {Size = UDim2.new(1, 0, 0, 31), BackgroundColor3 = C.panel2}, f)
    corner(head, 7)
    local cap = label(head, "  ◈  " .. titleText, 12, true, C.text)
    cap.Size = UDim2.new(1, -8, 1, 0)
    local body = new("Frame", {Position = UDim2.new(0, 10, 0, 37), Size = UDim2.new(1, -20, 1, -44), BackgroundTransparency = 1}, f)
    local list = new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, body)
    return f, body, list
end
local content
local search
local platformButton
local avatarInfoLabel
local previewLabel

local function refreshPreview()
    if previewLabel then
        local lines = {}
        table.insert(lines, "Username: " .. ((state.identityPreview and state.username ~= "") and state.username or LocalPlayer.Name))
        table.insert(lines, "DisplayName: " .. state.displayName)
        table.insert(lines, "User ID preview: " .. state.userId)
        if state.levelEnabled then table.insert(lines, "Level preview: " .. state.level) end
        if state.platformEnabled then table.insert(lines, "Platform label: " .. state.platform) end
        if state.contractsEnabled then table.insert(lines, "Contract: " .. state.contractName .. " | Eliminations: " .. state.eliminations .. " | Playtime: " .. state.playtime) end
        if state.resourcesEnabled then table.insert(lines, "Keys: " .. state.keys .. " | Tokens: " .. state.tokens) end
        previewLabel.Text = table.concat(lines, "\n")
    end
    if avatarInfoLabel then
        avatarInfoLabel.Text = "Username: " .. state.username .. "\nDisplayName: " .. state.displayName .. "\nUser ID preview: " .. state.userId
    end
end

local function page(name)
    local p = new("ScrollingFrame", {
        Name = name, Visible = false, BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.purple,
    }, content)
    local l = new("UIListLayout", {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder}, p)
    new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)}, p)
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 20)
    end)
    return p
end

-- HUD with live FPS and best-effort ping.
local hud = new("TextLabel", {
    Name = "YabujinHUD", Position = UDim2.new(0, 8, 0, 8), Size = UDim2.new(0, 300, 0, 28),
    BackgroundColor3 = Color3.fromRGB(5, 5, 8), BackgroundTransparency = 0.12,
    Text = "  Yabujin | " .. LocalPlayer.Name .. " | -- fps | -- ms",
    TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = false,
}, gui)
corner(hud, 6); outline(hud, C.border)
local frameCount, lastFrame, fpsNow = 0, os.clock(), 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = os.clock()
    if now - lastFrame >= 1 then
        fpsNow = frameCount / (now - lastFrame)
        frameCount, lastFrame = 0, now
        local ping = "N/A"
        protect(function()
            ping = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms"
        end)
        local shownName = state.identityPreview and state.username or LocalPlayer.Name
        if shownName == "" then shownName = LocalPlayer.Name end
        hud.Text = "  Yabujin | " .. shownName .. " | " .. tostring(math.floor(fpsNow)) .. " fps | " .. ping
    end
end)

-- Floating menu orb stays visible when the panel is hidden.
local orb = new("TextButton", {
    Name = "YabujinToggle", Size = UDim2.fromOffset(44, 44), Position = UDim2.new(0, 10, 0.43, 0),
    BackgroundColor3 = C.purple, Text = "Y", TextColor3 = C.text,
    Font = Enum.Font.GothamBlack, TextSize = 19, AutoButtonColor = true,
}, gui)
corner(orb, 22); outline(orb, Color3.fromRGB(194, 169, 255), 1.4)

-- Main window, sized to fit smaller screens.
local cameraAtStart = workspace.CurrentCamera
local viewport = cameraAtStart and cameraAtStart.ViewportSize or Vector2.new(900, 600)
local winW = math.clamp(viewport.X - 78, 300, 720)
local winH = math.clamp(viewport.Y - 70, 300, 510)
local window = new("Frame", {
    Name = "MainWindow", Position = UDim2.new(0, 62, 0, 48), Size = UDim2.fromOffset(winW, winH),
    BackgroundColor3 = C.bg, Visible = true,
}, gui)
corner(window, 8); outline(window, C.border, 1.2)
local top = new("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = Color3.fromRGB(10, 10, 13)}, window)
corner(top, 8)
local brand = label(top, "YABUJIN  /  LOCAL VISUALS", 13, true)
brand.Position = UDim2.new(0, 12, 0, 0); brand.Size = UDim2.new(1, -65, 1, 0)
local close = button(top, "×", 27, function() window.Visible = false end)
close.Size = UDim2.fromOffset(30, 27); close.Position = UDim2.new(1, -38, 0, 7); close.BackgroundColor3 = C.purpleDark

local sidebarW = math.clamp(math.floor(winW * 0.30), 96, 155)
local sidebar = new("Frame", {Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(0, sidebarW, 1, -42), BackgroundColor3 = Color3.fromRGB(15, 15, 19)}, window)
local navLayout = new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, sidebar)
new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7)}, sidebar)
content = new("Frame", {Position = UDim2.new(0, sidebarW, 0, 42), Size = UDim2.new(1, -sidebarW, 1, -42), BackgroundTransparency = 1}, window)

local pages = {}
local navButtons = {}
local currentPage = "Spoofer"
local pageNames = {"Spoofer", "Avatar", "World", "Camera", "Visuals", "Settings"}
for _, name in ipairs(pageNames) do
    pages[name] = page(name)
    local b = button(sidebar, name, 32)
    b.BackgroundTransparency = 0.08
    b.Activated:Connect(function()
        currentPage = name
        for pageName, p in pairs(pages) do p.Visible = pageName == name end
        for buttonName, nav in pairs(navButtons) do nav.BackgroundColor3 = buttonName == name and C.purpleDark or C.panel2 end
        if search then search.Text = "" end
    end)
    navButtons[name] = b
end

-- Search box sits between title and pages; hides nonmatching page buttons.
search = new("TextBox", {
    Position = UDim2.new(0, 10, 0, 48), Size = UDim2.new(1, -20, 0, 28),
    BackgroundColor3 = C.panel2, TextColor3 = C.text, PlaceholderColor3 = C.muted,
    PlaceholderText = "Search sections...", Text = "", ClearTextOnFocus = false,
    Font = Enum.Font.Code, TextSize = 11,
}, content)
corner(search, 5); outline(search)
for _, p in pairs(pages) do p.Position = UDim2.new(0, 0, 0, 82); p.Size = UDim2.new(1, 0, 1, -82) end

-- Spoofer page. These fields update this UI's local preview, not official Rivals data.
do
    local p = pages.Spoofer
    local _, body = card(p, "Identity Preview", 255)
    input(body, "Username shown in custom HUD", state.username, "Username", function(v)
        state.username = v
        refreshPreview()
        hud.Text = "  Yabujin | " .. (v ~= "" and v or LocalPlayer.Name) .. " | " .. tostring(math.floor(fpsNow)) .. " fps | -- ms"
    end, "username")
    input(body, "DisplayName preview", state.displayName, "Display name", function(v) state.displayName = v; refreshPreview() end, "displayName")
    input(body, "User ID preview", state.userId, "Numeric user ID", function(v) state.userId = v; refreshPreview() end, "userId")
    toggle(body, "Use custom username in HUD", false, function(v)
        state.identityPreview = v
        refreshPreview()
        local shownName = v and state.username or LocalPlayer.Name
        hud.Text = "  Yabujin | " .. (shownName ~= "" and shownName or LocalPlayer.Name) .. " | " .. tostring(math.floor(fpsNow)) .. " fps | -- ms"
    end, "identityPreview")

    local _, lvl = card(p, "Level Spoofer / Preview", 140)
    input(lvl, "Local preview level", state.level, "e.g. 250", function(v) state.level = v; refreshPreview() end, "level")
    toggle(lvl, "Show custom level in preview", false, function(v) state.levelEnabled = v; refreshPreview() end, "levelEnabled")

    local _, platBody = card(p, "Platform Label", 115)
    platformButton = button(platBody, "Platform label: PC  ▾", 30, function()
        local options = {"PC", "Mobile", "Console"}
        local idx = table.find(options, state.platform) or 1
        state.platform = options[idx % #options + 1]
        platformButton.Text = "Platform label: " .. state.platform .. "  ▾"
        refreshPreview()
    end)
    toggle(platBody, "Show platform in local preview", false, function(v) state.platformEnabled = v; refreshPreview() end, "platformEnabled")

    local _, contractBody = card(p, "Contract Preview", 250)
    input(contractBody, "Contract / weapon label", state.contractName, "Contract name", function(v) state.contractName = v; refreshPreview() end, "contractName")
    input(contractBody, "Eliminations preview", state.eliminations, "0", function(v) state.eliminations = v; refreshPreview() end, "eliminations")
    input(contractBody, "Playtime preview", state.playtime, "Seconds", function(v) state.playtime = v; refreshPreview() end, "playtime")
    toggle(contractBody, "Enable contract preview label", false, function(v) state.contractsEnabled = v; refreshPreview() end, "contractsEnabled")

    local _, resourceBody = card(p, "Resource Preview", 190)
    input(resourceBody, "Keys (display only)", state.keys, "0", function(v) state.keys = v; refreshPreview() end, "keys")
    input(resourceBody, "Tokens (display only)", state.tokens, "0", function(v) state.tokens = v; refreshPreview() end, "tokens")
    toggle(resourceBody, "Enable resource preview label", false, function(v) state.resourcesEnabled = v; refreshPreview() end, "resourcesEnabled")
    local _, noteBody = card(p, "Live Local Preview", 175)
    previewLabel = label(noteBody, "", 11, false, C.text)
    previewLabel.Size = UDim2.new(1, 0, 1, 0)
    refreshPreview()
end

-- Avatar preview: thumbnail only; does not replace the player's real character.
do
    local p = pages.Avatar
    local _, body = card(p, "Avatar Thumbnail Preview", 265)
    local avatarImg = new("ImageLabel", {Size = UDim2.fromOffset(110, 110), BackgroundColor3 = C.panel2, Image = "", ScaleType = Enum.ScaleType.Fit}, body)
    corner(avatarImg, 7); outline(avatarImg)
    local previewText = label(body, "Thumbnail preview only", 11, false, C.muted)
    previewText.Size = UDim2.new(1, 0, 0, 24)
    input(body, "Roblox User ID", state.avatarId, "Enter numeric UserId", function(v) state.avatarId = v end, "avatarId")
    button(body, "Load avatar thumbnail", 30, function()
        local id = tonumber(state.avatarId)
        if not id or id < 1 then previewText.Text = "Enter a valid numeric User ID."; return end
        avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(math.floor(id)) .. "&w=420&h=420"
        previewText.Text = "Showing avatar thumbnail for ID " .. tostring(math.floor(id))
        state.avatarPreview = true
    end)
    local _, info = card(p, "Local Identity Preview", 125)
    avatarInfoLabel = label(info, "", 11, false, C.text)
    avatarInfoLabel.Size = UDim2.new(1, 0, 1, 0)
    refreshPreview()
    local _, tip = card(p, "Important", 75)
    local t = label(tip, "The avatar and identity above are preview-only. This does not change your real account or what other players see.", 11, false, C.muted)
    t.Size = UDim2.new(1, 0, 1, 0)
end

-- World themes are local Lighting tints (not downloadable skybox texture packs).
local lightingOriginal = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    FogColor = Lighting.FogColor,
    FogEnd = Lighting.FogEnd,
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness,
}
local oldCC = Lighting:FindFirstChild("YabujinLocalColorGrade")
if oldCC then protect(function() oldCC:Destroy() end) end
local colorGrade = new("ColorCorrectionEffect", {Name = "YabujinLocalColorGrade", Enabled = false, Saturation = 0.05, Contrast = 0.05, Brightness = 0}, Lighting)
local themes = {
    ["Default"] = nil,
    ["Galaxy Purple"] = {ambient = Color3.fromRGB(74, 52, 120), outdoor = Color3.fromRGB(47, 32, 86), fog = Color3.fromRGB(42, 25, 79), saturation = 0.18, contrast = 0.12, brightness = -0.02},
    ["Cosmic Blue"] = {ambient = Color3.fromRGB(47, 79, 135), outdoor = Color3.fromRGB(28, 49, 100), fog = Color3.fromRGB(17, 36, 87), saturation = 0.12, contrast = 0.10, brightness = 0},
    ["Crimson Void"] = {ambient = Color3.fromRGB(116, 44, 58), outdoor = Color3.fromRGB(72, 22, 34), fog = Color3.fromRGB(68, 12, 27), saturation = 0.16, contrast = 0.18, brightness = -0.03},
    ["Emerald Aurora"] = {ambient = Color3.fromRGB(46, 114, 91), outdoor = Color3.fromRGB(24, 76, 63), fog = Color3.fromRGB(12, 64, 54), saturation = 0.16, contrast = 0.10, brightness = 0.01},
    ["Pink Nebula"] = {ambient = Color3.fromRGB(131, 70, 131), outdoor = Color3.fromRGB(82, 39, 100), fog = Color3.fromRGB(79, 31, 87), saturation = 0.20, contrast = 0.12, brightness = 0.01},
}
local function applyTheme(name)
    state.theme = name
    local theme = themes[name]
    if not theme then
        Lighting.Ambient = lightingOriginal.Ambient
        Lighting.OutdoorAmbient = lightingOriginal.OutdoorAmbient
        Lighting.FogColor = lightingOriginal.FogColor
        Lighting.FogEnd = lightingOriginal.FogEnd
        Lighting.ClockTime = lightingOriginal.ClockTime
        Lighting.Brightness = lightingOriginal.Brightness
        colorGrade.Enabled = false
        return
    end
    Lighting.Ambient = theme.ambient
    Lighting.OutdoorAmbient = theme.outdoor
    Lighting.FogColor = theme.fog
    Lighting.FogEnd = 100000
    colorGrade.TintColor = theme.ambient:Lerp(Color3.new(1, 1, 1), 0.45)
    colorGrade.Saturation = theme.saturation
    colorGrade.Contrast = theme.contrast
    colorGrade.Brightness = theme.brightness
    colorGrade.Enabled = true
end
do
    local p = pages.World
    local _, body = card(p, "Local Color Themes", 305)
    local themeStatus = label(body, "Current theme: Default", 11, false, C.muted)
    themeStatus.Size = UDim2.new(1, 0, 0, 22)
    local choices = {"Galaxy Purple", "Cosmic Blue", "Crimson Void", "Emerald Aurora", "Pink Nebula"}
    for _, themeName in ipairs(choices) do
        button(body, themeName, 29, function()
            applyTheme(themeName)
            themeStatus.Text = "Current theme: " .. themeName .. " (local lighting)"
        end)
    end
    button(body, "Restore Default", 29, function()
        applyTheme("Default")
        themeStatus.Text = "Current theme: Default"
    end)
    local _, note = card(p, "Theme Info", 70)
    local n = label(note, "These apply local ambient/fog/color grading. They do not load a custom skybox texture or affect other players.", 11, false, C.muted)
    n.Size = UDim2.new(1, 0, 1, 0)
end

-- Camera field of view works locally; Roblox client scripts cannot force actual monitor resolution.
local originalFov = workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70
local function setFov(value)
    state.fov = math.clamp(tonumber(value) or 70, 50, 110)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = state.fov end
end
do
    local p = pages.Camera
    local _, body = card(p, "Camera FOV", 170)
    local fovText = label(body, "FOV: " .. tostring(state.fov), 12, true)
    fovText.Size = UDim2.new(1, 0, 0, 25)
    button(body, "− 5 FOV", 30, function() setFov(state.fov - 5); fovText.Text = "FOV: " .. tostring(state.fov) end)
    button(body, "+ 5 FOV", 30, function() setFov(state.fov + 5); fovText.Text = "FOV: " .. tostring(state.fov) end)
    button(body, "Reset FOV", 30, function() setFov(originalFov); fovText.Text = "FOV: " .. tostring(state.fov) end)
    local _, info = card(p, "Resolution / Stretch", 90)
    local n = label(info, "This changes camera FOV only. True stretched resolution requires display/graphics settings and cannot be forced reliably by this local UI.", 11, false, C.muted)
    n.Size = UDim2.new(1, 0, 1, 0)
end

-- No Hands is best-effort: hides locally rendered arm/hand-named BaseParts under CurrentCamera.
local hiddenParts = {}
local cameraDescConn, cameraChildConn
local function restoreHands()
    for part, oldValue in pairs(hiddenParts) do
        if part and part.Parent then protect(function() part.LocalTransparencyModifier = oldValue end) end
    end
    table.clear(hiddenParts)
end
local function scanHands()
    if not state.noHands then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    for _, obj in ipairs(cam:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = string.lower(obj.Name)
            if string.find(name, "hand", 1, true) or string.find(name, "arm", 1, true) then
                if hiddenParts[obj] == nil then hiddenParts[obj] = obj.LocalTransparencyModifier end
                obj.LocalTransparencyModifier = 1
            end
        end
    end
end
local function setNoHands(on)
    state.noHands = on == true
    if state.noHands then
        scanHands()
        if cameraDescConn then cameraDescConn:Disconnect() end
        local cam = workspace.CurrentCamera
        if cam then cameraDescConn = cam.DescendantAdded:Connect(function() task.defer(scanHands) end) end
    else
        if cameraDescConn then cameraDescConn:Disconnect(); cameraDescConn = nil end
        restoreHands()
    end
end
do
    local p = pages.Visuals
    local _, body = card(p, "Local Visuals", 125)
    toggle(body, "No Hands (best effort)", false, function(v) setNoHands(v) end, "noHands")
    local _, info = card(p, "Limitations", 90)
    local n = label(info, "Some Rivals viewmodels may use different part names or be recreated by the game, so No Hands may not apply to every weapon.", 11, false, C.muted)
    n.Size = UDim2.new(1, 0, 1, 0)
end

-- Session-only configs: intentionally no executor file APIs or external writes.
do
    local p = pages.Settings
    local _, body = card(p, "Profile Manager", 230)
    local configNameBox = input(body, "Profile name", "Default", "Name this profile", function(v) end)
    local selectedLabel = label(body, "Selected profile: none", 11, false, C.muted)
    selectedLabel.Size = UDim2.new(1, 0, 0, 24)
    local configs, selected = {}, nil
    button(body, "Save current settings", 30, function()
        local name = configNameBox.Text
        if name == "" then name = "Default" end
        local copy = {}
        for k, v in pairs(state) do copy[k] = v end
        configs[name] = copy
        selected = name
        selectedLabel.Text = "Saved and selected: " .. name .. " (this session)"
    end)
    button(body, "Select next saved profile", 30, function()
        local names = {}
        for name in pairs(configs) do table.insert(names, name) end
        table.sort(names)
        if #names == 0 then selectedLabel.Text = "No profiles saved yet."; return end
        local idx = table.find(names, selected) or 0
        selected = names[idx % #names + 1]
        configNameBox.Text = selected
        selectedLabel.Text = "Selected profile: " .. selected
    end)
    button(body, "Load selected profile", 30, function()
        if not selected or not configs[selected] then selectedLabel.Text = "Select a saved profile first."; return end
        for k, v in pairs(configs[selected]) do state[k] = v end
        for key, box in pairs(inputControls) do if box and state[key] ~= nil then box.Text = tostring(state[key]) end end
        for key, control in pairs(toggleControls) do if control and state[key] ~= nil then control.set(state[key]) end end
        if state.identityPreview then
            hud.Text = "  Yabujin | " .. (state.username ~= "" and state.username or LocalPlayer.Name) .. " | " .. tostring(math.floor(fpsNow)) .. " fps | -- ms"
        else
            hud.Text = "  Yabujin | " .. LocalPlayer.Name .. " | " .. tostring(math.floor(fpsNow)) .. " fps | -- ms"
        end
        setFov(state.fov)
        applyTheme(state.theme)
        setNoHands(state.noHands)
        refreshPreview()
        platformButton.Text = "Platform label: " .. state.platform .. "  ▾"
        refreshPreview()
        selectedLabel.Text = "Loaded: " .. selected .. " (this session)"
    end)
    local _, info = card(p, "Compatibility", 100)
    local n = label(info, "If Real Executor blocks gethui/CoreGui or certain client APIs, the UI may fail on that version. This script uses ordinary local UI/Lighting/Camera APIs and makes no anti-cheat bypass attempts.", 11, false, C.muted)
    n.Size = UDim2.new(1, 0, 1, 0)
end

-- Search section names; typing narrows the sidebar. Page content is left intact.
search:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(search.Text)
    local anyMatch = false
    for name, nav in pairs(navButtons) do
        local match = q == "" or string.find(string.lower(name), q, 1, true) ~= nil
        nav.Visible = match
        if match then anyMatch = true end
    end
    if q ~= "" and anyMatch then
        for name, nav in pairs(navButtons) do
            if nav.Visible then
                currentPage = name
                for pageName, p in pairs(pages) do p.Visible = pageName == name end
                for buttonName, b in pairs(navButtons) do b.BackgroundColor3 = buttonName == name and C.purpleDark or C.panel2 end
                break
            end
        end
    elseif q == "" then
        for name, nav in pairs(navButtons) do nav.Visible = true; nav.BackgroundColor3 = name == currentPage and C.purpleDark or C.panel2 end
    end
end)

-- Draggable window from header.
local winDragging, winInput, winDragStart, winStartPos = false, nil, nil, nil
top.InputBegan:Connect(function(inputObj)
    if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
        winDragging, winInput = true, inputObj
        winDragStart, winStartPos = inputObj.Position, window.Position
    end
end)
UserInputService.InputChanged:Connect(function(inputObj)
    if winDragging and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj == winInput) then
        local delta = inputObj.Position - winDragStart
        window.Position = UDim2.new(winStartPos.X.Scale, winStartPos.X.Offset + delta.X, winStartPos.Y.Scale, winStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inputObj)
    if inputObj == winInput or inputObj.UserInputType == Enum.UserInputType.MouseButton1 then winDragging = false; winInput = nil end
end)

-- Draggable floating toggle; tap toggles, drag moves it.
local orbDragging, orbInput, orbStart, orbPos, orbMoved = false, nil, nil, nil, false
orb.InputBegan:Connect(function(inputObj)
    if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
        orbDragging, orbInput, orbMoved = true, inputObj, false
        orbStart, orbPos = inputObj.Position, orb.Position
    end
end)
UserInputService.InputChanged:Connect(function(inputObj)
    if orbDragging and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj == orbInput) then
        local delta = inputObj.Position - orbStart
        if delta.Magnitude > 5 then orbMoved = true end
        orb.Position = UDim2.new(orbPos.X.Scale, orbPos.X.Offset + delta.X, orbPos.Y.Scale, orbPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inputObj)
    if orbDragging and (inputObj == orbInput or inputObj.UserInputType == Enum.UserInputType.MouseButton1) then
        orbDragging = false
        if not orbMoved then window.Visible = not window.Visible end
        orbInput = nil
    end
end)

-- Initial state
for name, nav in pairs(navButtons) do nav.BackgroundColor3 = name == currentPage and C.purpleDark or C.panel2 end
pages[currentPage].Visible = true
hud.Text = "  Yabujin | " .. LocalPlayer.Name .. " | -- fps | -- ms"
print("[Yabujin] Local visual UI loaded. Server-side Rivals values are unchanged.")
