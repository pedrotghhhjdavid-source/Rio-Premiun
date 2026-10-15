YABUJIN | REAL EXECUTOR | LOCAL VISUAL USERNAME, DISPLAYNAME & AVATAR SPOOFER
Este módulo te permite modificar EL NOMBRE ENCIMA DE TU PERSONAJE y TU APARIENCIA solo de forma visual/local. NO cambia datos oficiales del servidor ni lo que ven otros jugadores.
Botones y campos añadidos funcionan en la pestaña "Avatar" y aplican directamente a tu personaje local.
Más abajo tienes un resumen de funciones logradas y limitaciones.
]]

-- ========== [INJECTED SECTION: VISUAL ON-CHARACTER SPOOFERS] =========== --

-- Para evitar problemas de duplicado al reejecutar:
do
	local char = LocalPlayer and LocalPlayer.Character or (game and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character)
	if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("Yabujin_OverheadGui") then
		local protect = protect or function(cb) local ok, _ = pcall(cb) end
		protect(function() char.Head.Yabujin_OverheadGui:Destroy() end)
	end
end

-- Guarda el aspecto original para restaurar
local originalAppearance = {
	desc = nil,      -- HumanoidDescription original (en sesión)
	stored = nil,    -- Clon original del character (por si acaso)
	ready = false,   -- Marca si hemos cacheado ya
}

-- Últimos datos spoof aplicados para persistir en respawn
local appliedSpoof = {
	username = nil,
	displayName = nil,
	userId = nil, -- avatar spoof
}

-- Helper: Validación para UserId
local function isValidUserId(str)
	local n = tonumber(str)
	return n and n >= 1 and math.floor(n) == n
end

-- ========= Crear y mantener BillboardGui overhead para Nombre/DisplayName ========

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

	-- Username label (arriba)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "SpoofedName"
	nameLabel.Size = UDim2.new(1, 0, 0, 22)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0.75
	nameLabel.TextColor3 = Color3.fromRGB(213,234,241)
	nameLabel.TextStrokeColor3 = Color3.fromRGB(20,40,60)
	nameLabel.TextScaled = true
	nameLabel.Text = ""
	nameLabel.Parent = gui

	-- DisplayName label (abajo más pequeño)
	local dispLabel = Instance.new("TextLabel")
	dispLabel.Name = "SpoofedDisplay"
	dispLabel.Size = UDim2.new(1, 0, 0, 18)
	dispLabel.Position = UDim2.new(0, 0, 0, 23)
	dispLabel.BackgroundTransparency = 1
	dispLabel.Font = Enum.Font.Gotham
	dispLabel.TextStrokeTransparency = 0.82
	dispLabel.TextColor3 = Color3.fromRGB(180,180,200)
	dispLabel.TextStrokeColor3 = Color3.fromRGB(36,36,44)
	dispLabel.TextScaled = true
	dispLabel.Text = ""
	dispLabel.Parent = gui

	return gui
end

-- Actualizar overhead visual con los nombres spoof
function updateOverhead(username, displayName)
	local char = LocalPlayer and LocalPlayer.Character
	if not char then return end
	local gui = getOrCreateOverheadGui(char)
	if gui then
		local nameLabel = gui:FindFirstChild("SpoofedName")
		local displayLabel = gui:FindFirstChild("SpoofedDisplay")
		if nameLabel then
			nameLabel.Text = username or ""
		end
		if displayLabel then
			displayLabel.Text = displayName or ""
		end
	end
end

-- ========== Avatar Spoof por UserId seguro y robusto ==============
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

-- ========== Cachear y restaurar HumanoidDescription original ==============
do
	local function cacheOriginal()
		local char = LocalPlayer and LocalPlayer.Character
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		if char and humanoid and not originalAppearance.ready then
			originalAppearance.desc = humanoid:GetAppliedDescription()
			originalAppearance.ready = true
		end
	end
	-- Cachear al cargar
	if LocalPlayer and LocalPlayer.Character then cacheOriginal() end
	if LocalPlayer and LocalPlayer.CharacterAdded then
		LocalPlayer.CharacterAdded:Connect(cacheOriginal)
	end
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

-- ========== Actualiza overhead y avatar tras respawn; limpia GUIs duplicados ==========
if LocalPlayer and LocalPlayer.CharacterAdded then
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.defer(function()
			local head = char:FindFirstChild("Head")
			if head then
				for _, g in pairs(head:GetChildren()) do
					if g:IsA("BillboardGui") and g.Name == "Yabujin_OverheadGui" then
						if protect then
							protect(function() g:Destroy() end)
						else
							pcall(function() g:Destroy() end)
						end
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

-- Al cargar primera vez, aplica nombre/Display si está seteado
if LocalPlayer and LocalPlayer.Character then
	task.defer(function()
		updateOverhead(appliedSpoof.username or state.username or LocalPlayer.Name,
		               appliedSpoof.displayName or state.displayName or LocalPlayer.DisplayName)
	end)
end

-- ========== INTEGRACIÓN CON LA INTERFAZ Y BOTONES ==================
-- Asegura que los elementos de UI invocan sus callbacks reales.

-- Asegúrate de que las siguientes referencias existen previamente:
-- LocalPlayer: el Player local, debería estar definido en un entorno de exploit para Roblox
-- protect: función protect(callback), definida antes en el script para manejar errores de destrucción de GUIs, etc.
-- state: tabla para persistencia de spoof local (siempre usada para valores por defecto)
if not LocalPlayer and game and game.Players then
	LocalPlayer = game.Players.LocalPlayer
end
if not protect then
	protect = function(cb) local ok, _ = pcall(cb) end
end
if not state then
	state = { username = nil, displayName = nil }
end

-- Username spoof visual
if textbox then
	textbox(body, "Username", function(text)
		appliedSpoof.username = text
		state.username = text
		updateOverhead(
			text,
			appliedSpoof.displayName or state.displayName or (LocalPlayer and LocalPlayer.DisplayName)
		)
	end)
end

-- DisplayName spoof visual
if textbox then
	textbox(body, "DisplayName", function(text)
		appliedSpoof.displayName = text
		state.displayName = text
		updateOverhead(
			appliedSpoof.username or state.username or (LocalPlayer and LocalPlayer.Name),
			text
		)
	end)
end

-- UserId para avatar spoof visual
if textbox then
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

-- Botón para restaurar apariencia original y limpiar feedback
if button then
	button(body, "Restaurar apariencia original", function()
		local ok, err = pcall(function()
			restoreOriginalAvatar()
		end)
		updateOverhead(LocalPlayer and LocalPlayer.Name, LocalPlayer and LocalPlayer.DisplayName)
		appliedSpoof.username = nil
		appliedSpoof.displayName = nil
		state.username = nil
		state.displayName = nil
		-- Limpia labels previas de feedback
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

-- ========== Manejo global si APIs no existen ==========
if not (game and game.Players and game.Players.GetHultc1qalrd99hju33uagsf8927k7xfxr423gr93gnjz8 and Instance and Instance.new) then
	showErrorMsg("Esta versión de Roblox o Real Executor NO soporta spoof visual de avatar por UserId.")
end
