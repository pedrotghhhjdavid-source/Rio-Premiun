-- RIO.WIN PREMIUM GUI SCRIPT (VERSIÓN FINAL COMPLETA)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local menuVisible, currentTab, toggleKey, listeningForKey = true, "main", Enum.KeyCode.RightShift, false
local aimbotEnabled, espEnabled, showFovCircle, aiming = false, false, false, false
local fovRadius, minFov, maxFov = 150, 30, 500

local FovCircle = Drawing.new("Circle")
FovCircle.Thickness, FovCircle.Color, FovCircle.Filled, FovCircle.Transparency, FovCircle.NumSides, FovCircle.Visible = 1, Color3.fromRGB(0, 140, 255), false, 0.8, 64, false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.DisplayOrder, ScreenGui.ResetOnSpawn, ScreenGui.IgnoreGuiInset = 999999, false, true
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name, MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3, MainFrame.BorderColor3, MainFrame.BorderSizePixel, MainFrame.Active, MainFrame.Parent = "RioMainFrame", UDim2.new(0, 520, 0, 360), UDim2.new(0.5, -260, 0.4, -180), Color3.fromRGB(25, 25, 28), Color3.fromRGB(0, 140, 255), 1, true, ScreenGui

local TopBar = Instance.new("Frame")
TopBar.Size, TopBar.BackgroundTransparency, TopBar.Parent = UDim2.new(1, 0, 0, 45), 1, MainFrame

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size, LogoLabel.Position, LogoLabel.BackgroundTransparency, LogoLabel.Text, LogoLabel.TextColor3, LogoLabel.Font, LogoLabel.TextSize, LogoLabel.Parent = UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 5), 1, "rio.win", Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 15, TopBar

local TabContainer = Instance.new("Frame")
TabContainer.Size, TabContainer.Position, TabContainer.BackgroundTransparency, TabContainer.Parent = UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 0, 30), 1, TopBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection, TabListLayout.HorizontalAlignment, TabListLayout.SortOrder, TabListLayout.Padding, TabListLayout.Parent = Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Center, Enum.SortOrder.LayoutOrder, UDim.new(0, 15), TabContainer

local ContentContainer = Instance.new("Frame")
ContentContainer.Size, ContentContainer.Position, ContentContainer.BackgroundTransparency, ContentContainer.Parent = UDim2.new(1, -20, 1, -65), UDim2.new(0, 10, 0, 55), 1, MainFrame

local MainTabFrame = Instance.new("Frame")
MainTabFrame.Size, MainTabFrame.BackgroundTransparency, MainTabFrame.Visible, MainTabFrame.Parent = UDim2.new(1, 0, 1, 0), 1, true, ContentContainer

local SettingsTabFrame = Instance.new("Frame")
SettingsTabFrame.Size, SettingsTabFrame.BackgroundTransparency, SettingsTabFrame.Visible, SettingsTabFrame.Parent = UDim2.new(1, 0, 1, 0), 1, false, ContentContainer

local tabs = {"main", "world", "esp", "Visuals", "character", "misc", "settings"}
for i, tabName in ipairs(tabs) do
    local TabButton = Instance.new("TextButton")
    TabButton.Size, TabButton.BackgroundTransparency, TabButton.Text, TabButton.TextColor3, TabButton.Font, TabButton.TextSize, TabButton.LayoutOrder, TabButton.Parent = UDim2.new(0, 65, 1, 0), 1, tabName, (tabName == "main") and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 155), Enum.Font.GothamSemibold, 12, i, TabContainer
    TabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        for _, btn in ipairs(TabContainer:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = (btn.Text == currentTab) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 155) end end
        MainTabFrame.Visible = (currentTab == "main")
        SettingsTabFrame.Visible = (currentTab == "settings")
    end)
end

local LeftColumn = Instance.new("Frame")
LeftColumn.Size, LeftColumn.BackgroundColor3, LeftColumn.BorderColor3, LeftColumn.Parent = UDim2.new(0.5, -5, 1, 0), Color3.fromRGB(20, 20, 22), Color3.fromRGB(45, 45, 50), MainTabFrame

local AimTitle = Instance.new("TextLabel")
AimTitle.Size, AimTitle.Position, AimTitle.BackgroundTransparency, AimTitle.Text, AimTitle.TextColor3, AimTitle.Font, AimTitle.TextSize, AimTitle.TextXAlignment, AimTitle.Parent = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 5), 1, "Aimbot Settings", Color3.fromRGB(0, 140, 255), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Left, LeftColumn

local AimToggleBtn = Instance.new("TextButton")
AimToggleBtn.Size, AimToggleBtn.Position, AimToggleBtn.BackgroundColor3, AimToggleBtn.BorderColor3, AimToggleBtn.Text, AimToggleBtn.TextColor3, AimToggleBtn.Font, AimToggleBtn.TextSize, AimToggleBtn.TextXAlignment, AimToggleBtn.Parent = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 40), Color3.fromRGB(35, 35, 40), Color3.fromRGB(55, 55, 60), "  Activar Aimbot: OFF", Color3.fromRGB(180, 180, 180), Enum.Font.GothamSemibold, 11, Enum.TextXAlignment.Left, LeftColumn

local FovToggleBtn = Instance.new("TextButton")
FovToggleBtn.Size, FovToggleBtn.Position, FovToggleBtn.BackgroundColor3, FovToggleBtn.BorderColor3, FovToggleBtn.Text, FovToggleBtn.TextColor3, FovToggleBtn.Font, FovToggleBtn.TextSize, FovToggleBtn.TextXAlignment, FovToggleBtn.Parent = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 75), Color3.fromRGB(35, 35, 40), Color3.fromRGB(55, 55, 60), "  Mostrar Circulo FOV: OFF", Color3.fromRGB(180, 180, 180), Enum.Font.GothamSemibold, 11, Enum.TextXAlignment.Left, LeftColumn

local FovLabel = Instance.new("TextLabel")
FovLabel.Size, FovLabel.Position, FovLabel.BackgroundTransparency, FovLabel.Text, FovLabel.TextColor3, FovLabel.Font, FovLabel.TextSize, FovLabel.TextXAlignment, FovLabel.Parent = UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 115), 1, "Tamaño del FOV: 150px", Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 11, Enum.TextXAlignment.Left, LeftColumn

local FovSliderFrame = Instance.new("Frame")
FovSliderFrame.Size, FovSliderFrame.Position, FovSliderFrame.BackgroundColor3, FovSliderFrame.BorderSizePixel, FovSliderFrame.Parent = UDim2.new(1, -20, 0, 6), UDim2.new(0, 10, 0, 140), Color3.fromRGB(40, 40, 45), 0, LeftColumn

local FovSliderBar = Instance.new("Frame")
FovSliderBar.Size, FovSliderBar.BackgroundColor3, FovSliderBar.BorderSizePixel, FovSliderBar.Parent = UDim2.new(0.3, 0, 1, 0), Color3.fromRGB(0, 140, 255), 0, FovSliderFrame

local RightColumn = Instance.new("Frame")
RightColumn.Size, RightColumn.Position, RightColumn.BackgroundColor3, RightColumn.BorderColor3, RightColumn.Parent = UDim2.new(0.5, -5, 1, 0), UDim2.new(0.5, 5, 0, 0), Color3.fromRGB(20, 20, 22), Color3.fromRGB(45, 45, 50), MainTabFrame

local EspTitle = Instance.new("TextLabel")
EspTitle.Size, EspTitle.Position, EspTitle.BackgroundTransparency, EspTitle.Text, EspTitle.TextColor3, EspTitle.Font, EspTitle.TextSize, EspTitle.TextXAlignment, EspTitle.Parent = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 5), 1, "Visuals Extra", Color3.fromRGB(0, 140, 255), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Left, RightColumn

local EspToggleBtn = Instance.new("TextButton")
EspToggleBtn.Size, EspToggleBtn.Position, EspToggleBtn.BackgroundColor3, EspToggleBtn.BorderColor3, EspToggleBtn.Text, EspToggleBtn.TextColor3, EspToggleBtn.Font, EspToggleBtn.TextSize, EspToggleBtn.TextXAlignment, EspToggleBtn.Parent = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 40), Color3.fromRGB(35, 35, 40), Color3.fromRGB(55, 55, 60), "  Highlight ESP (Rojo): OFF", Color3.fromRGB(180, 180, 180), Enum.Font.GothamSemibold, 11, Enum.TextXAlignment.Left, RightColumn

local SettingsColumn = Instance.new("Frame")
SettingsColumn.Size, SettingsColumn.BackgroundColor3, SettingsColumn.BorderColor3, SettingsColumn.Parent = UDim2.new(1, 0, 1, 0), Color3.fromRGB(20, 20, 22), Color3.fromRGB(45, 45, 50), SettingsTabFrame

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size, SettingsTitle.Position, SettingsTitle.BackgroundTransparency, SettingsTitle.Text, SettingsTitle.TextColor3, SettingsTitle.Font, SettingsTitle.TextSize, SettingsTitle.TextXAlignment, SettingsTitle.Parent = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 5), 1, "Menu Configuration", Color3.fromRGB(0, 140, 255), Enum.Font.GothamBold, 12, Enum.TextXAlignment.Left, SettingsColumn

local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size, KeybindLabel.Position, KeybindLabel.BackgroundTransparency, KeybindLabel.Text, KeybindLabel.TextColor3, KeybindLabel.Font, KeybindLabel.TextSize, KeybindLabel.TextXAlignment, KeybindLabel.Parent = UDim2.new(1, -20, 0, 25), KeybindLabel.Position = UDim2.new(0, 10, 0, 45), 1, "Abrir / Cerrar Menú Tecla:", Color3.fromRGB(200, 200, 200), Enum.Font.GothamSemibold, 11, Enum.TextXAlignment.Left, SettingsColumn

local KeybindButton = Instance.new("TextButton")
KeybindButton.Size, KeybindButton.Position, KeybindButton.BackgroundColor3, KeybindButton.BorderColor3, KeybindButton.Text, KeybindButton.TextColor3, KeybindButton.Font, KeybindButton.TextSize, KeybindButton.Parent = UDim2.new(0, 150, 0, 30), UDim2.new(0, 10, 0, 75), Color3.fromRGB(35, 35, 40), Color3.fromRGB(0, 140, 255), "RightShift", Color3.fromRGB(255, 255, 255), Enum.Font.GothamBold, 11, SettingsColumn

AimToggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimToggleBtn.Text = aimbotEnabled and "  Activar Aimbot: ON" or "  Activar Aimbot: OFF"
    AimToggleBtn.TextColor3 = aimbotEnabled and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(180, 180, 180)
end)

FovToggleBtn.MouseButton1Click:Connect(function()
    showFovCircle = not showFovCircle
    FovToggleBtn.Text = showFovCircle and "  Mostrar Circulo FOV: ON" or "  Mostrar Circulo FOV: OFF"
    FovToggleBtn.TextColor3 = showFovCircle and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(180, 180, 180)
end)

local fovSliderActive = false
