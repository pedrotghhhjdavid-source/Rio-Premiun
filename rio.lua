--[[
YABUJIN | REAL EXECUTOR | LOCAL VISUAL USERNAME, DISPLAYNAME & AVATAR SPOOFER
Este módulo te permite modificar EL NOMBRE ENCIMA DE TU PERSONAJE y TU APARIENCIA solo de forma visual/local. NO cambia datos oficiales del servidor ni lo que ven otros jugadores.
Botones y campos añadidos funcionan en la pestaña "Avatar" y aplican directamente a tu personaje local.
Más abajo tienes un resumen de funciones logradas y limitaciones.
]]

-- ========== DEFINICIÓN DE VARIABLES, VALIDACIONES Y FUNCIONES UTILS =========

-- Function stubs for required objects if not present
if not game or not game.Players then
	error("Roblox game environment is required for this script.")
end

local LocalPlayer = LocalPlayer or game.Players.LocalPlayer
local protect = protect or function(cb) local ok, _ = pcall(cb) end
local state = state or { username = nil, displayName = nil }
local body = body
local textbox = textbox
local button = button
local label = label
local C = C or { green=Color3.fromRGB(60,240,120), red=Color3.fromRGB(220,60,60) }

-- ========== IMPLEMENTACIÓN FUNCIONAL PRINCIPAL ==========

-- Evitar duplicidad de GUIs si se reejecuta el script
do
	local char = LocalPlayer and LocalPlayer.Character
	if char and char:FindFirstChild("Head") then
		local oldGui = char.Head:FindFirstChild("Yabujin_OverheadGui")
		if oldGui then
			protect(function() oldGui:Destroy() end)
		end
	end
end

local originalAppearance = {
	desc = nil,
	ready = false,
}

local appliedSpoof = {
	username = nil,
	displayName = nil,
	userId = nil,
}

local function isValidUserId(str)
	local n = tonumber(str)
	return n and n >= 1 and math.floor(n) == n
end

local function getOrCreateOverheadGui(targetChar)
	if not targetChar or not targetChar:FindFirstChild("Head") then return nil end
	local head = targetChar:FindFirstChild("Head")
	local gui = head:FindFirstChild("Yabujin_OverheadGui")
	if gui then return gui end

	gui = Instance.new("BillboardGui")
	gui.Name = "Yabujin_OverheadGui"
	gui.Size = UDim2.new(0, 220, 0, 45)
	gui.StudsOffset = Vector3.new(0, 2.0, 0)
	gui.MaxDistance = 180
	gui.AlwaysOnTop = true
	gui.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "SpoofedName"
	nameLabel.Size = UDim2.new(1, 0, 0, 22)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0.75
	nameLabel.TextColor3 = Color3.fromRGB(213,234,241)
	nameLabel.TextStrokeColor3 = Color3.fromRGB(15,24,54)
	nameLabel.TextScaled = true
	nameLabel.Text = ""
	nameLabel.Parent = gui

	local displayLabel = Instance.new("TextLabel")
	displayLabel.Name = "SpoofedDisplay"
	displayLabel.Size = UDim2.new(1, 0, 0, 17)
	displayLabel.Position = UDim2.new(0, 0, 0, 22)
	displayLabel.BackgroundTransparency = 1
	displayLabel.Font = Enum.Font.Gotham
	displayLabel.TextStrokeTransparency = 0.8
	displayLabel.TextColor3 = Color3.fromRGB(245,235,190)
	displayLabel.TextStrokeColor3 = Color3.fromRGB(40,30,20)
	displayLabel.TextScaled = true
	displayLabel.Text = ""
	displayLabel.Parent = gui

	return gui
end

local function updateOverhead(username, displayName)
	local char = LocalPlayer and LocalPlayer.Character
	if not char then return end
	local gui = getOrCreateOverheadGui(char)
	if not gui then return end
	local nameLabel = gui:FindFirstChild("SpoofedName")
	local displayLabel = gui:FindFirstChild("SpoofedDisplay")
	if nameLabel then nameLabel.Text = tostring(username or "") end
	if displayLabel then displayLabel.Text = tostring(displayName or "") end
end

local function showErrorMsg(msg)
	if not (body and label) then
		warn("[VISUAL SPOOF] "..msg)
		return
	end
	for _, child in ipairs(body:GetChildren()) do
		if child:IsA("TextLabel") and child.Name == "ErrorLabel" then
			child:Destroy()
		end
	end
	local lbl = label(body, "[Visual Error] "..tostring(msg), 11, true, C.red)
	lbl.Name = "ErrorLabel"
	lbl.Size = UDim2.new(1,0,0,19)
	task.delay(2.5, function()
		if lbl and lbl.Parent then lbl:Destroy() end
	end)
end

local function applyAvatarSpoof(userId)
	if not isValidUserId(userId) then
		showErrorMsg("UserId inválido para visual avatar spoof.")
		return
	end
	local char = LocalPlayer and LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not humanoid then
		showErrorMsg("Humanoid no encontrado.")
		return
	end

	local desc
	local success, err = pcall(function()
		desc = game.Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not success or not desc then
		showErrorMsg("No se pudo cargar la descripción del avatar: "..(err or "desconocido"))
		return
	end
	local ok, apperr = pcall(function()
		humanoid:ApplyDescription(desc)
	end)
	if not ok then
		showErrorMsg("Fallo aplicando descripción: "..(apperr or "desconocido"))
		return
	end
	appliedSpoof.userId = tonumber(userId)
end

do
	local function cacheOriginal()
		local char = LocalPlayer and LocalPlayer.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if char and humanoid and not originalAppearance.ready then
			originalAppearance.desc = humanoid:GetAppliedDescription()
			originalAppearance.ready = true
		end
	end
	if LocalPlayer and LocalPlayer.Character then cacheOriginal() end
	if LocalPlayer then LocalPlayer.CharacterAdded:Connect(cacheOriginal) end
end

local function restoreOriginalAvatar()
	local char = LocalPlayer and LocalPlayer.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not humanoid then
		showErrorMsg("No se puede restaurar, humanoid ausente.")
		return
	end
	if not originalAppearance.ready or not originalAppearance.desc then
		showErrorMsg("No hay avatar original almacenado.")
		return
	end
	local ok, apperr = pcall(function()
		humanoid:ApplyDescription(originalAppearance.desc)
	end)
	if not ok then
		showErrorMsg("Fallo al restaurar descripción: "..(apperr or "desconocido"))
	end
	appliedSpoof.userId = nil
end

if LocalPlayer then
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.defer(function()
			local head = char:FindFirstChild("Head")
			if head then
				for _, g in pairs(head:GetChildren()) do
					if g:IsA("BillboardGui") and g.Name == "Yabujin_OverheadGui" then
						protect(function() g:Destroy() end)
					end
				end
			end
			updateOverhead(appliedSpoof.username or state.username or LocalPlayer.Name,
			               appliedSpoof.displayName or state.displayName or LocalPlayer.DisplayName)
			if appliedSpoof.userId and isValidUserId(appliedSpoof.userId) then
				applyAvatarSpoof(appliedSpoof.userId)
			else
				restoreOriginalAvatar()
			end
		end)
	end)
end

if LocalPlayer and LocalPlayer.Character then
	task.defer(function()
		updateOverhead(appliedSpoof.username or state.username or LocalPlayer.Name,
		               appliedSpoof.displayName or state.displayName or LocalPlayer.DisplayName)
	end)
end

-- ========== UI INTEGRATION ==========

if textbox and body then
	textbox(body, "Username", function(text)
		appliedSpoof.username = text
		state.username = text
		updateOverhead(
			text,
			appliedSpoof.displayName or state.displayName or (LocalPlayer and LocalPlayer.DisplayName)
		)
	end)

	textbox(body, "DisplayName", function(text)
		appliedSpoof.displayName = text
		state.displayName = text
		updateOverhead(
			appliedSpoof.username or state.username or (LocalPlayer and LocalPlayer.Name),
			text
		)
	end)

	textbox(body, "UserId", function(text)
		if isValidUserId(text) then
			local success, err = pcall(function()
				applyAvatarSpoof(text)
			end)
			if not success then
				showErrorMsg("Error aplicando spoof de avatar: "..(err or "desconocido"))
			end
		else
			showErrorMsg("UserId inválido.")
		end
	end)
end

if button and body then
	button(body, "Restaurar apariencia original", function()
		local ok, err = pcall(function()
			restoreOriginalAvatar()
		end)
		updateOverhead(LocalPlayer and LocalPlayer.Name, LocalPlayer and LocalPlayer.DisplayName)
		appliedSpoof.username = nil
		appliedSpoof.displayName = nil
		state.username = nil
		state.displayName = nil
		for _, child in ipairs(body:GetChildren()) do
			if child:IsA("TextLabel") and child.Name == "FeedbackLabel" then
				child:Destroy()
			end
		end
		local lbl = label(body, ok and "Avatar visual restaurado." or ("Error: "..(err or "desconocido")), 11, false, C.green)
		lbl.Name = "FeedbackLabel"
		lbl.Size = UDim2.new(1,0,0,19)
	end)
end

if not (game and game.Players and game.Players.GetHultc1qalrd99hju33uagsf8927k7xfxr423gr93gnjz8 and Instance and Instance.new) then
	showErrorMsg("Esta versión de Roblox o Real Executor NO soporta spoof visual de avatar por UserId.")
end
