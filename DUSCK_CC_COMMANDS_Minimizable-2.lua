-- ==========================================
-- ANA SCRIPT BAŞLANGICI
-- ==========================================
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

for _, guiName in ipairs({ "CustomAdminPanel", "MMVWatermark", "LanguageSelectorGui" }) do
	local oldGui = playerGui:FindFirstChild(guiName)
	if oldGui then
		oldGui:Destroy()
	end
end

-- ==========================================
-- DİL SİSTEMİ (PORTEKİZCE / İSPANYOLCA)
-- ==========================================
local currentLang = "es"

local Translations = {
	pt = {
		panelTitle = "DUSCK | CC COMMANDS",
		subtitle = "DIGITE UM COMANDO",
		textboxHint = "TEXTBOX",
		readyStatus = "PRONTO",
		placeholder = "DIGITE UM COMANDO..",
		blockStatusOn = "BLOCK: LIGADO",
		blockStatusOff = "BLOCK: DESLIGADO",
		playerBlockRan = "PLAYER BLOCK/UNBLOCK EXECUTADO!",
		jailRan = "JAIL/UNJAIL EXECUTADO!",
		flingRan = "FLING EXECUTADO!",
		givenPrefix = "ENTREGUE (",
		givenSuffix = ")!",
		invalidCommand = "COMANDO INVÁLIDO!",
		cmdBlockName = "Bloquear",
		cmdEspName = "Alternar ESP",
		cmdRocketName = "Lança-Foguetes",
		cmdGoldenCarpetName = "Tapete Dourado",
		cmdRainbowCarpetName = "Tapete Arco-Íris",
		cmdHairDryerName = "Secador de Cabelo",
		cmdCrossbowName = "Crossbow of the Sea",
		cmdWaterBombName = "Water Bomb",
		cmdSnowyCoilName = "Mola de Gravidade Nevado",
		cmdDualCoilName = "Mola de Gravidade Dupla",
		cmdJetpackName = "Jetpack",
		cmdDarkPegasusName = "Pégaso Sombrio",
		cmdSpeedCoilName = "Speed Coil",
		cmdGravityCoilName = "Mola de Gravidade",
		cmdHyperCoilName = "Hiper Mola",
		cmdWhosunaName = "Whosuna",
		cmdNonmagicCarpetName = "Tapete Não-Mágico"
	},
	es = {
		panelTitle = "DUSCK | CC COMMANDS",
		subtitle = "ESCRIBE UN COMANDO",
		textboxHint = "TEXTBOX",
		readyStatus = "LISTO",
		placeholder = "ESCRIBE UN COMANDO..",
		blockStatusOn = "BLOCK: ACTIVADO",
		blockStatusOff = "BLOCK: DESACTIVADO",
		playerBlockRan = "¡PLAYER BLOCK/UNBLOCK EJECUTADO!",
		jailRan = "¡JAIL/UNJAIL EJECUTADO!",
		flingRan = "¡FLING EJECUTADO!",
		givenPrefix = "¡ENTREGADO (",
		givenSuffix = ")!",
		invalidCommand = "¡COMANDO NO VÁLIDO!",
		cmdBlockName = "Bloquear",
		cmdEspName = "Alternar ESP",
		cmdRocketName = "Lanzacohetes",
		cmdGoldenCarpetName = "Alfombra Dorada",
		cmdRainbowCarpetName = "Alfombra Arcoíris",
		cmdHairDryerName = "Secador de Pelo",
		cmdCrossbowName = "Crossbow of the Sea",
		cmdWaterBombName = "Water Bomb",
		cmdSnowyCoilName = "Resorte de Gravedad Nevado",
		cmdDualCoilName = "Resorte de Gravedad Doble",
		cmdJetpackName = "Jetpack",
		cmdDarkPegasusName = "Pegaso Oscuro",
		cmdSpeedCoilName = "Speed Coil",
		cmdGravityCoilName = "Resorte de Gravedad",
		cmdHyperCoilName = "Hiper Resorte",
		cmdWhosunaName = "Whosuna",
		cmdNonmagicCarpetName = "Alfombra No Mágica"
	}
}

local function tr(key)
	local dict = Translations[currentLang] or Translations.es
	return dict[key] or Translations.es[key] or key
end

local applyLanguageToPanel = nil

-- ==========================================
-- 1. KENDİ BLOCK SİSTEMİ + HER MAÇ ENVANTER SIFIRLAMA
-- ==========================================
local blockEnabled = false

local SpawnedToolNames = {
	"RocketLauncher",
	"GoldenCarpet",
	"Hair Dryer",
	"Crossbow of the Sea",
	"Water Bomb",
	"SnowyCoil",
	"SpeedCoil",
	"GravityCoil",
	"Whosuna",
	"Nonmagic Carpet"
}

local function clearMatchInventory()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	local char = LocalPlayer.Character

	local function cleanContainer(container)
		if not container then return end
		for _, item in ipairs(container:GetChildren()) do
			if item:IsA("Tool") then
				local lowerName = string.lower(item.Name)
				local matched = false
				for _, toolName in ipairs(SpawnedToolNames) do
					if item.Name == toolName then
						matched = true
						break
					end
				end
				if not matched and (
					string.find(lowerName, "coil")
					or string.find(lowerName, "speed")
					or string.find(lowerName, "gravity")
					or string.find(lowerName, "carpet")
					or string.find(lowerName, "pegasus")
					or string.find(lowerName, "jetpack")
					or string.find(lowerName, "crossbow")
					or string.find(lowerName, "water bomb")
					or string.find(lowerName, "whosuna")
					or string.find(lowerName, "nonmagic")
				) then
					matched = true
				end
				if matched then
					item:Destroy()
				end
			end
		end
	end

	cleanContainer(backpack)
	cleanContainer(char)
end

local function setCharacterLock(locked)
	local char = LocalPlayer.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hrp then
			hrp.Anchored = locked
			if not locked then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
		end
		if hum then
			hum.WalkSpeed = locked and 0 or 16
			hum.JumpPower = locked and 0 or 50
		end
	end
end

local function toggleBlock()
	blockEnabled = not blockEnabled
	setCharacterLock(blockEnabled)
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.35)
	clearMatchInventory()
	if blockEnabled then
		setCharacterLock(true)
	else
		setCharacterLock(false)
	end
end)

-- ==========================================
-- 1B. İNSANLARA BLOCK / UNBLOCK, JAIL VE FLING SİSTEMİ
-- ==========================================
local blockedPlayers = {}
local playerBlockVisuals = {}
local jailedPlayers = {}
local playerJailVisuals = {}
local jailSavedCFrames = {}
local goJailInside = false

local function getPlayerRole(plr)
	local character = plr.Character
	if not character then return "Innocent" end

	if character:FindFirstChild("Knife") or (plr.Backpack and plr.Backpack:FindFirstChild("Knife")) then
		return "Murderer"
	elseif character:FindFirstChild("Gun") or (plr.Backpack and plr.Backpack:FindFirstChild("Gun")) then
		return "Sheriff"
	else
		return "Innocent"
	end
end

local function removePlayerBlockVisuals(plr)
	local data = playerBlockVisuals[plr]
	if data then
		if data.cage and data.cage.Parent then
			data.cage:Destroy()
		end
		if data.headCover and data.headCover.Parent then
			data.headCover:Destroy()
		end
		playerBlockVisuals[plr] = nil
	end
end

local function applyPlayerBlockVisuals(plr)
	if not blockedPlayers[plr] then
		removePlayerBlockVisuals(plr)
		return
	end

	local char = plr.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp then return end

	local data = playerBlockVisuals[plr]
	if not data then
		data = {}
		playerBlockVisuals[plr] = data
	end

	local cage = data.cage
	if not cage or not cage.Parent then
		cage = Instance.new("Part")
		cage.Name = "PlayerBlueBlock"
		cage.Size = Vector3.new(7, 8, 7)
		cage.Color = Color3.fromRGB(0, 120, 255)
		cage.Material = Enum.Material.Neon
		cage.Transparency = 0.45
		cage.Anchored = true
		cage.CanCollide = true
		cage.Parent = workspace
		data.cage = cage
	end
	cage.CFrame = hrp.CFrame

	local headCover = data.headCover
	if not headCover or not headCover.Parent then
		headCover = Instance.new("Part")
		headCover.Name = "PlayerBlackHeadCover"
		headCover.Size = Vector3.new(2.2, 2.2, 2.2)
		headCover.Color = Color3.fromRGB(10, 10, 12)
		headCover.Material = Enum.Material.SmoothPlastic
		headCover.Transparency = 0
		headCover.Anchored = true
		headCover.CanCollide = false
		headCover.Parent = workspace
		data.headCover = headCover
	end

	if head then
		headCover.CFrame = head.CFrame
	else
		headCover.CFrame = hrp.CFrame * CFrame.new(0, 2.5, 0)
	end

	if hum then
		pcall(function()
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end)
	end
end

local function removePlayerJailVisuals(plr)
	local model = playerJailVisuals[plr]
	if model and model.Parent then
		model:Destroy()
	end
	playerJailVisuals[plr] = nil
end

local function buildClosedBlueJailBox(centerCFrame)
	local model = Instance.new("Model")
	model.Name = "JailBlueBox"

	local boxSize = 7.5
	local wallThickness = 1.2
	local half = boxSize / 2
	local blueColor = Color3.fromRGB(0, 130, 255)
	local wallProps = PhysicalProperties.new(100, 0.5, 0, 1, 1)

	local function makeWall(name, size, offsetCFrame)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Color = blueColor
		p.Material = Enum.Material.Neon
		p.Transparency = 0.25
		p.Anchored = true
		p.CanCollide = true
		p.CanTouch = false
		p.CanQuery = true
		p.CustomPhysicalProperties = wallProps
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.CFrame = centerCFrame * offsetCFrame
		p.Parent = model
		return p
	end

	makeWall("Floor", Vector3.new(boxSize + wallThickness * 2, wallThickness, boxSize + wallThickness * 2), CFrame.new(0, -half - wallThickness / 2, 0))
	makeWall("Ceiling", Vector3.new(boxSize + wallThickness * 2, wallThickness, boxSize + wallThickness * 2), CFrame.new(0, half + wallThickness / 2, 0))
	makeWall("FrontWall", Vector3.new(boxSize, boxSize, wallThickness), CFrame.new(0, 0, -half - wallThickness / 2))
	makeWall("BackWall", Vector3.new(boxSize, boxSize, wallThickness), CFrame.new(0, 0, half + wallThickness / 2))
	makeWall("LeftWall", Vector3.new(wallThickness, boxSize, boxSize), CFrame.new(-half - wallThickness / 2, 0, 0))
	makeWall("RightWall", Vector3.new(wallThickness, boxSize, boxSize), CFrame.new(half + wallThickness / 2, 0, 0))

	model.Parent = workspace
	return model
end

local function getActiveJailAnchor()
	for plr, isJailed in pairs(jailedPlayers) do
		if isJailed and plr.Parent == Players then
			if jailSavedCFrames[plr] then
				return jailSavedCFrames[plr]
			end
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				return hrp.CFrame
			end
		end
	end
	local existingBox = workspace:FindFirstChild("JailBlueBox", true)
	if existingBox and existingBox:IsA("Model") then
		local primary = existingBox.PrimaryPart or existingBox:FindFirstChildWhichIsA("BasePart")
		if primary then
			return primary.CFrame
		end
	end
	return nil
end

local function applyPlayerJail(plr)
	if not jailedPlayers[plr] then
		removePlayerJailVisuals(plr)
		return
	end

	local char = plr.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hrp then return end

	local anchorCF = jailSavedCFrames[plr] or hrp.CFrame
	jailSavedCFrames[plr] = anchorCF

	local model = playerJailVisuals[plr]
	if not model or not model.Parent then
		model = buildClosedBlueJailBox(anchorCF)
		playerJailVisuals[plr] = model
	end

	pcall(function()
		hrp.Anchored = true
		hrp.CFrame = anchorCF
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end)

	if hum then
		pcall(function()
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end)
	end
end

local function enforceGoJailState()
	local anchorCF = getActiveJailAnchor()
	if not anchorCF then
		goJailInside = false
		return
	end

	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local relPos = anchorCF:PointToObjectSpace(hrp.Position)
	local insideHalf = 3.75

	if goJailInside then
		local clampedX = math.clamp(relPos.X, -2.2, 2.2)
		local clampedY = math.clamp(relPos.Y, -2.0, 2.0)
		local clampedZ = math.clamp(relPos.Z, -2.2, 2.2)
		local targetCF = anchorCF * CFrame.new(clampedX, clampedY, clampedZ)
		pcall(function()
			hrp.CFrame = targetCF
			hrp.AssemblyLinearVelocity = Vector3.zero
			hrp.AssemblyAngularVelocity = Vector3.zero
		end)
	else
		local insideX = math.abs(relPos.X) < insideHalf
		local insideY = math.abs(relPos.Y) < insideHalf
		local insideZ = math.abs(relPos.Z) < insideHalf
		if insideX and insideY and insideZ then
			local outsideCF = anchorCF * CFrame.new(0, 0, 6.2)
			pcall(function()
				hrp.CFrame = outsideCF
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end
end

local function setGoJail(shouldGoInside)
	local anchorCF = getActiveJailAnchor()
	if shouldGoInside then
		if not anchorCF then return end
		goJailInside = true
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			pcall(function()
				hrp.CFrame = anchorCF * CFrame.new(0, 0, 0)
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	else
		goJailInside = false
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and anchorCF then
			pcall(function()
				hrp.CFrame = anchorCF * CFrame.new(0, 0, 6.5)
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	end
end

local function setTargetJailed(targetPlr, shouldJail)
	if not targetPlr then return end
	if shouldJail then
		removePlayerJailVisuals(targetPlr)
		local char = targetPlr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			jailSavedCFrames[targetPlr] = hrp.CFrame
		end
		jailedPlayers[targetPlr] = true
		applyPlayerJail(targetPlr)
	else
		local currentAnchor = jailSavedCFrames[targetPlr]
		jailedPlayers[targetPlr] = nil
		jailSavedCFrames[targetPlr] = nil
		removePlayerJailVisuals(targetPlr)

		local char = targetPlr.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if hrp then
			local stayThereCF = currentAnchor or hrp.CFrame
			pcall(function()
				hrp.Anchored = false
				hrp.CanTouch = true
				hrp.CFrame = stayThereCF
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		if hum then
			pcall(function()
				hum.WalkSpeed = 16
				hum.JumpPower = 50
			end)
		end

		if not next(jailedPlayers) then
			goJailInside = false
		end
	end
end

local function findRoleOrPlayerTarget(query, allowSelf)
	if not query or query == "" then return nil end
	local lowerQuery = string.lower(string.match(query, "^%s*(.-)%s*$") or "")
	if lowerQuery == "" then return nil end

	if allowSelf and (lowerQuery == "me" or lowerQuery == "self") then
		return LocalPlayer
	end

	if lowerQuery == "murder" or lowerQuery == "murderer" then
		for _, plr in ipairs(Players:GetPlayers()) do
			if getPlayerRole(plr) == "Murderer" and (allowSelf or plr ~= LocalPlayer) then
				return plr
			end
		end
		return nil
	end

	if lowerQuery == "sherif" or lowerQuery == "sheriff" then
		for _, plr in ipairs(Players:GetPlayers()) do
			if getPlayerRole(plr) == "Sheriff" and (allowSelf or plr ~= LocalPlayer) then
				return plr
			end
		end
		return nil
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		if allowSelf or plr ~= LocalPlayer then
			if string.find(string.lower(plr.Name), lowerQuery, 1, true)
				or string.find(string.lower(plr.DisplayName), lowerQuery, 1, true) then
				return plr
			end
		end
	end
	return nil
end

local function flingTargetPlayer(targetPlr)
	if not targetPlr or targetPlr == LocalPlayer then return end
	local targetChar = targetPlr.Character
	local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")

	if not targetHrp or not myHrp then return end

	local oldCF = myHrp.CFrame
	local oldSit = myHum and myHum.Sit or false
	local oldPlatformStand = myHum and myHum.PlatformStand or false

	if myHum then
		pcall(function()
			myHum.PlatformStand = false
			myHum.Sit = false
		end)
	end

	local bv = Instance.new("BodyVelocity")
	bv.Name = "FlingVelocity"
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Velocity = Vector3.new(120, 420, 120)
	bv.Parent = myHrp

	local bav = Instance.new("BodyAngularVelocity")
	bav.Name = "FlingSpin"
	bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bav.AngularVelocity = Vector3.new(0, 9999, 0)
	bav.Parent = myHrp

	local startClock = os.clock()
	local flingConn
	flingConn = RunService.Heartbeat:Connect(function()
		if os.clock() - startClock > 0.7 or not targetHrp.Parent or not myHrp.Parent then
			if flingConn then flingConn:Disconnect() end
			return
		end
		bv.Velocity = Vector3.new(140, 440, 140)
		pcall(function()
			myHrp.CFrame = targetHrp.CFrame * CFrame.Angles(math.rad(os.clock() * 900), math.rad(os.clock() * 900), 0)
			myHrp.AssemblyLinearVelocity = Vector3.new(180, 450, 180)
			myHrp.AssemblyAngularVelocity = Vector3.new(0, 9999, 0)
			targetHrp.AssemblyLinearVelocity = Vector3.new(
				(targetHrp.Position.X - myHrp.Position.X) * 14 + 90,
				380,
				(targetHrp.Position.Z - myHrp.Position.Z) * 14 + 90
			)
		end)
	end)

	task.delay(0.72, function()
		if flingConn then flingConn:Disconnect() end
		if bv and bv.Parent then bv:Destroy() end
		if bav and bav.Parent then bav:Destroy() end
		if myHrp and myHrp.Parent then
			pcall(function()
				myHrp.AssemblyLinearVelocity = Vector3.zero
				myHrp.AssemblyAngularVelocity = Vector3.zero
				myHrp.CFrame = oldCF
			end)
		end
		if myHum and myHum.Parent then
			pcall(function()
				myHum.Sit = oldSit
				myHum.PlatformStand = oldPlatformStand
			end)
		end
	end)
end

local function findPlayerByPartialName(query)
	if not query or query == "" then return nil end
	local lowerQuery = string.lower(query)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if string.find(string.lower(plr.Name), lowerQuery, 1, true)
				or string.find(string.lower(plr.DisplayName), lowerQuery, 1, true) then
				return plr
			end
		end
	end
	return nil
end

local function setTargetBlocked(targetPlr, shouldBlock)
	if not targetPlr or targetPlr == LocalPlayer then return end
	if shouldBlock then
		blockedPlayers[targetPlr] = true
		applyPlayerBlockVisuals(targetPlr)
	else
		blockedPlayers[targetPlr] = nil
		removePlayerBlockVisuals(targetPlr)
		local char = targetPlr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function()
				hum.WalkSpeed = 16
				hum.JumpPower = 50
			end)
		end
	end
end

-- ==========================================
-- ENVÍO AL CHAT + SELECTOR DE MAPAS
-- ==========================================
local function sendToRobloxChat(text)
	if type(text) ~= "string" or text == "" then return false end
	local toSend = text
	if not string.match(toSend, "^/") then
		toSend = "/" .. toSend
	end
	local ok = pcall(function()
		if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			local channels = TextChatService:FindFirstChild("TextChannels")
			local general = channels and (channels:FindFirstChild("RBXGeneral") or channels:FindFirstChild("General"))
			if general and general:IsA("TextChannel") then
				general:SendAsync(toSend)
				return
			end
			if channels then
				for _, ch in ipairs(channels:GetChildren()) do
					if ch:IsA("TextChannel") then
						ch:SendAsync(toSend)
						return
					end
				end
			end
		end
		local success = pcall(function()
			Players:Chat(toSend)
		end)
		if not success then
			local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
			if chatEvents then
				local sayMsg = chatEvents:FindFirstChild("SayMessageRequest")
				if sayMsg then
					sayMsg:FireServer(toSend, "All")
				end
			end
		end
	end)
	return ok
end

-- sher / sheriff / murd / murder / murderer  (con o sin nombre)
local function isRoleChatMessage(lowerText)
	return lowerText == "sher" or lowerText == "/sher"
		or lowerText == "sheriff" or lowerText == "/sheriff"
		or lowerText == "murd" or lowerText == "/murd"
		or lowerText == "murder" or lowerText == "/murder"
		or lowerText == "murderer" or lowerText == "/murderer"
		or string.match(lowerText, "^/?sheriff%s+%S+")
		or string.match(lowerText, "^/?sher%s+%S+")
		or string.match(lowerText, "^/?murderer%s+%S+")
		or string.match(lowerText, "^/?murder%s+%S+")
		or string.match(lowerText, "^/?murd%s+%S+")
end

local MapList = {
	"Biolab", "Icecastle", "Log Cabin", "Workshop", "Workplace", "Factory",
	"Milbase", "Station", "House2", "Hotel", "BeachResort", "Yacht",
	"Barn", "Farmhouse", "ChristmasItaly", "Manor", "Mineshaft",
	"VampireCastle", "Spaceship", "SkiVillage_6v6", "SkiVillage_RegularMode", "Pier",
}

local mapSelectorGui = nil

local function hideMapSelector()
	if mapSelectorGui then
		mapSelectorGui.Enabled = false
	end
end

local function showMapSelector()
	if not mapSelectorGui then
		mapSelectorGui = Instance.new("ScreenGui")
		mapSelectorGui.Name = "DUSCKMapSelector"
		mapSelectorGui.ResetOnSpawn = false
		mapSelectorGui.DisplayOrder = 50
		mapSelectorGui.Parent = playerGui

		local backdrop = Instance.new("TextButton")
		backdrop.Name = "Backdrop"
		backdrop.Size = UDim2.new(1, 0, 1, 0)
		backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		backdrop.BackgroundTransparency = 0.55
		backdrop.BorderSizePixel = 0
		backdrop.Text = ""
		backdrop.AutoButtonColor = false
		backdrop.Parent = mapSelectorGui
		backdrop.MouseButton1Click:Connect(hideMapSelector)

		local frame = Instance.new("Frame")
		frame.Name = "MapListFrame"
		frame.Size = UDim2.new(0, 260, 0, 380)
		frame.Position = UDim2.new(0.5, -130, 0.5, -190)
		frame.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
		frame.BorderSizePixel = 0
		frame.Parent = mapSelectorGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(68, 68, 74)
		stroke.Thickness = 1.4
		stroke.Parent = frame

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -40, 0, 28)
		title.Position = UDim2.new(0, 12, 0, 8)
		title.BackgroundTransparency = 1
		title.Text = "ELEGIR MAPA"
		title.TextColor3 = Color3.fromRGB(245, 245, 248)
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = frame

		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 26, 0, 22)
		closeBtn.Position = UDim2.new(1, -34, 0, 8)
		closeBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		closeBtn.BorderSizePixel = 0
		closeBtn.Text = "X"
		closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeBtn.Font = Enum.Font.GothamBold
		closeBtn.TextSize = 13
		closeBtn.Parent = frame
		local closeCorner = Instance.new("UICorner")
		closeCorner.CornerRadius = UDim.new(0, 6)
		closeCorner.Parent = closeBtn
		closeBtn.MouseButton1Click:Connect(hideMapSelector)

		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = "MapScroll"
		scroll.Size = UDim2.new(1, -16, 1, -48)
		scroll.Position = UDim2.new(0, 8, 0, 40)
		scroll.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 5
		scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Parent = frame

		local scrollCorner = Instance.new("UICorner")
		scrollCorner.CornerRadius = UDim.new(0, 7)
		scrollCorner.Parent = scroll

		local listLayout = Instance.new("UIListLayout")
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Padding = UDim.new(0, 4)
		listLayout.Parent = scroll

		local listPadding = Instance.new("UIPadding")
		listPadding.PaddingTop = UDim.new(0, 6)
		listPadding.PaddingBottom = UDim.new(0, 6)
		listPadding.PaddingLeft = UDim.new(0, 6)
		listPadding.PaddingRight = UDim.new(0, 6)
		listPadding.Parent = scroll

		for i, mapName in ipairs(MapList) do
			local btn = Instance.new("TextButton")
			btn.Name = "Map_" .. mapName
			btn.Size = UDim2.new(1, -4, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(43, 43, 48)
			btn.BorderSizePixel = 0
			btn.Text = mapName
			btn.TextColor3 = Color3.fromRGB(235, 235, 240)
			btn.Font = Enum.Font.GothamBold
			btn.TextSize = 12
			btn.LayoutOrder = i
			btn.Parent = scroll

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 6)
			btnCorner.Parent = btn

			btn.MouseEnter:Connect(function()
				btn.BackgroundColor3 = Color3.fromRGB(55, 90, 160)
			end)
			btn.MouseLeave:Connect(function()
				btn.BackgroundColor3 = Color3.fromRGB(43, 43, 48)
			end)

			btn.MouseButton1Click:Connect(function()
				sendToRobloxChat("/map " .. mapName)
				hideMapSelector()
				local mainPanel = playerGui:FindFirstChild("CustomAdminPanel")
				if mainPanel then
					local mainFrame = mainPanel:FindFirstChild("MainFrame")
					local status = mainFrame and mainFrame:FindFirstChild("StatusLabel")
					if status then
						status.Text = "MAP: " .. mapName
						task.delay(1.6, function()
							if status and status.Parent then
								status.Text = tr("readyStatus")
							end
						end)
					end
				end
			end)
		end
	end
	mapSelectorGui.Enabled = true
end

local function handleChatOrCommandString(msg)
	if type(msg) ~= "string" then return false end
	local trimmed = string.match(msg, "^%s*(.-)%s*$")
	if not trimmed or trimmed == "" then return false end
	local lowerTrimmed = string.lower(trimmed)

	-- Selector de mapas
	if lowerTrimmed == "map" or lowerTrimmed == "/map" then
		showMapSelector()
		return "map"
	end

	local flingTargetName = string.match(lowerTrimmed, "^/?fling%s+(.+)$")
	if flingTargetName then
		local target = findRoleOrPlayerTarget(flingTargetName, false)
		if target then
			flingTargetPlayer(target)
		end
		return "fling"
	end

	if lowerTrimmed == "/gojail" or lowerTrimmed == "gojail" then
		setGoJail(true)
		return "jail"
	end

	if lowerTrimmed == "/gounjail" or lowerTrimmed == "gounjail" then
		setGoJail(false)
		return "jail"
	end

	local jailTargetName = string.match(lowerTrimmed, "^/?jail%s+(.+)$")
	if jailTargetName then
		local target = findRoleOrPlayerTarget(jailTargetName, true)
		if target then
			setTargetJailed(target, true)
		end
		return "jail"
	end

	if lowerTrimmed == "/jail" or lowerTrimmed == "jail" then
		setTargetJailed(LocalPlayer, true)
		return "jail"
	end

	local unjailTargetName = string.match(lowerTrimmed, "^/?unjail%s+(.+)$")
	if unjailTargetName then
		local target = findRoleOrPlayerTarget(unjailTargetName, true)
		if target then
			setTargetJailed(target, false)
		end
		return "jail"
	end

	if lowerTrimmed == "/unjail" or lowerTrimmed == "unjail" then
		for plr in pairs(jailedPlayers) do
			setTargetJailed(plr, false)
		end
		return "jail"
	end

	local blockTargetName = string.match(lowerTrimmed, "^/?block%s+(.+)$")
	if blockTargetName then
		local target = findPlayerByPartialName(blockTargetName)
		if target then
			setTargetBlocked(target, true)
		end
		return "block"
	end

	local unblockTargetName = string.match(lowerTrimmed, "^/?unblock%s+(.+)$")
	if unblockTargetName then
		local lowerTarget = string.lower(unblockTargetName)
		if lowerTarget == "me" or lowerTarget == string.lower(LocalPlayer.Name) or lowerTarget == string.lower(LocalPlayer.DisplayName) then
			blockEnabled = false
			setCharacterLock(false)
			return "block"
		end
		local target = findPlayerByPartialName(unblockTargetName)
		if target then
			setTargetBlocked(target, false)
		elseif blockEnabled then
			blockEnabled = false
			setCharacterLock(false)
		end
		return "block"
	end

	if lowerTrimmed == "/unblock" or lowerTrimmed == "unblock" then
		blockEnabled = false
		setCharacterLock(false)
		for plr in pairs(blockedPlayers) do
			setTargetBlocked(plr, false)
		end
		return "block"
	end

	return false
end

LocalPlayer.Chatted:Connect(function(msg)
	handleChatOrCommandString(msg)
end)

pcall(function()
	if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		TextChatService.MessageReceived:Connect(function(textChatMessage)
			if textChatMessage.TextSource and textChatMessage.TextSource.UserId == LocalPlayer.UserId then
				handleChatOrCommandString(textChatMessage.Text)
			end
		end)
	end
end)

RunService.Heartbeat:Connect(function()
	for plr, isBlocked in pairs(blockedPlayers) do
		if isBlocked then
			if plr.Parent == Players then
				applyPlayerBlockVisuals(plr)
			else
				blockedPlayers[plr] = nil
				removePlayerBlockVisuals(plr)
			end
		end
	end

	for plr, isJailed in pairs(jailedPlayers) do
		if isJailed then
			if plr.Parent == Players then
				applyPlayerJail(plr)
			else
				jailedPlayers[plr] = nil
				jailSavedCFrames[plr] = nil
				removePlayerJailVisuals(plr)
			end
		end
	end

	enforceGoJailState()
end)

Players.PlayerRemoving:Connect(function(plr)
	blockedPlayers[plr] = nil
	removePlayerBlockVisuals(plr)
	jailedPlayers[plr] = nil
	jailSavedCFrames[plr] = nil
	removePlayerJailVisuals(plr)
end)

-- ==========================================
-- 2. EŞYA VE ÖZELLİK FONKSİYONLARI
-- ==========================================

local function triggerWaterExplosion(point)
	if not point then return end
	local scale = 8 + (4 * math.random(1, 3))
	local terrain = workspace.Terrain
	pcall(function()
		terrain:FillBall(point, scale, Enum.Material.Water)
		task.delay(7, function()
			pcall(function()
				terrain:FillBall(point, scale, Enum.Material.Air)
			end)
		end)
	end)
end

-- A) ROCKET LAUNCHER (/GEAR ME ROCKETLAUNCHER)
local function giveRocketLauncher()
	local DECAL_ID = 114668885487967
	local LAUNCHER_MODEL_ID = 32356064
	local EXPLOSION_SOUND_ID = "rbxassetid://12221984"

	local LAUNCH_SPEED = 120
	local COOLDOWN = 0.8

	local mouse = LocalPlayer:GetMouse()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
	if not backpack then return end

	if backpack:FindFirstChild("RocketLauncher") then
		backpack.RocketLauncher:Destroy()
	end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("RocketLauncher") then
		LocalPlayer.Character.RocketLauncher:Destroy()
	end

	local realImageId = "rbxassetid://" .. tostring(DECAL_ID)
	local decalOk, decalObjects = pcall(function()
		return game:GetObjects("rbxassetid://" .. tostring(DECAL_ID))
	end)
	if decalOk and type(decalObjects) == "table" then
		local obj = next(decalObjects) and select(2, next(decalObjects))
		if obj then
			if obj:IsA("Decal") or obj:IsA("Texture") then
				realImageId = obj.Texture
			elseif obj:FindFirstChildOfClass("Decal") then
				realImageId = obj:FindFirstChildOfClass("Decal").Texture
			end
			obj:Destroy()
		end
	end

	local tool = Instance.new("Tool")
	tool.Name = "RocketLauncher"
	tool.TextureId = realImageId
	tool.RequiresHandle = true

	local handle
	local modelOk, modelObjects = pcall(function()
		return game:GetObjects("rbxassetid://" .. tostring(LAUNCHER_MODEL_ID))
	end)

	if modelOk and type(modelObjects) == "table" then
		local loaded = next(modelObjects) and select(2, next(modelObjects))
		if loaded then
			if loaded:IsA("Tool") then
				for _, child in ipairs(loaded:GetChildren()) do
					if not child:IsA("Script") and not child:IsA("LocalScript") then
						child.Parent = tool
					end
				end
				handle = tool:FindFirstChild("Handle")
				loaded:Destroy()
			elseif loaded:IsA("BasePart") then
				loaded.Name = "Handle"
				loaded.Parent = tool
				handle = loaded
			elseif loaded:IsA("Model") then
				handle = loaded.PrimaryPart or loaded:FindFirstChildWhichIsA("BasePart", true)
				if handle then
					handle.Name = "Handle"
					for _, part in ipairs(loaded:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Anchored = false
							if part ~= handle then
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = handle
								weld.Part1 = part
								weld.Parent = handle
							end
						end
					end
					for _, child in ipairs(loaded:GetChildren()) do
						child.Parent = tool
					end
				end
				loaded:Destroy()
			end
		end
	end

	if not handle then
		handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(3.8, 1.1, 1.1)
		handle.BrickColor = BrickColor.new("Dark green")
		handle.Material = Enum.Material.Metal
		handle.CanCollide = false
		handle.Parent = tool
	end

	tool.Grip = CFrame.new(0.85, 0, 0) * CFrame.Angles(0, math.rad(-90), 0) * CFrame.Angles(math.rad(90), 0, 0)

	local canShoot = true
	tool.Activated:Connect(function()
		if not canShoot then return end
		canShoot = false

		local character = LocalPlayer.Character
		local currentHandle = tool:FindFirstChild("Handle")
		if not character or not currentHandle then
			canShoot = true
			return
		end

		local targetPos = mouse.Hit.Position
		local spawnPos = currentHandle.Position
		local direction = (targetPos - spawnPos).Unit

		local bomb = Instance.new("Part")
		bomb.Name = "FuseBomb"
		bomb.Shape = Enum.PartType.Ball
		bomb.Size = Vector3.new(2, 2, 2)
		bomb.BrickColor = BrickColor.new("Really black")
		bomb.Material = Enum.Material.SmoothPlastic
		bomb.CanCollide = true
		bomb.CFrame = CFrame.new(spawnPos + direction * 3.5)
		bomb.Parent = workspace

		local fire = Instance.new("Fire")
		fire.Size = 5
		fire.Heat = 12
		fire.Parent = bomb

		bomb.AssemblyLinearVelocity = direction * LAUNCH_SPEED + Vector3.new(0, 10, 0)

		local exploded = false
		local function detonate()
			if exploded then return end
			exploded = true

			local sound = Instance.new("Sound")
			sound.SoundId = EXPLOSION_SOUND_ID
			sound.Volume = 1.5
			sound.Parent = bomb
			sound:Play()

			local explosion = Instance.new("Explosion")
			explosion.Position = bomb.Position
			explosion.BlastRadius = 14
			explosion.BlastPressure = 50000
			explosion.DestroyJointRadiusPercent = 0
			explosion.Parent = workspace

			bomb.Transparency = 1
			bomb.Anchored = true
			bomb.CanCollide = false
			fire.Enabled = false

			Debris:AddItem(bomb, 2)
		end

		bomb.Touched:Connect(function(hit)
			if hit and not hit:IsDescendantOf(character) and not hit:IsDescendantOf(tool) then
				detonate()
			end
		end)

		task.delay(5, detonate)
		task.wait(COOLDOWN)
		canShoot = true
	end)

	tool.Parent = backpack
end

-- B) GOLDEN CARPET (/GEAR ME GOLDENCARPET)
local function giveGoldenCarpet()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
	if not backpack then return end

	if backpack:FindFirstChild("GoldenCarpet") then
		backpack.GoldenCarpet:Destroy()
	end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("GoldenCarpet") then
		LocalPlayer.Character.GoldenCarpet:Destroy()
	end

	local gearId = 402305186
	local tool
	local success, objects = pcall(function()
		return game:GetObjects("rbxassetid://" .. gearId)
	end)

	if success and objects and #objects > 0 then
		tool = objects[1]
		for _, v in ipairs(tool:GetDescendants()) do
			if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
				v:Destroy()
			end
		end
	else
		tool = Instance.new("Tool")
		local fallbackHandle = Instance.new("Part")
		fallbackHandle.Name = "Handle"
		fallbackHandle.Size = Vector3.new(4, 0.2, 6)
		fallbackHandle.BrickColor = BrickColor.new("Bright yellow")
		fallbackHandle.Material = Enum.Material.Neon
		fallbackHandle.CanCollide = false
		fallbackHandle.Parent = tool
	end

	tool.Name = "GoldenCarpet"
	tool.TextureId = "rbxassetid://1014109561"

	local handle = tool:FindFirstChild("Handle")
	if handle then
		handle.Transparency = 0
		local mesh = handle:FindFirstChildOfClass("SpecialMesh")
		if not mesh then
			mesh = Instance.new("SpecialMesh")
			mesh.Parent = handle
		end
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://223079737"
		mesh.TextureId = "rbxassetid://1014108463"
		mesh.Scale = Vector3.new(1.4, 1.4, 1.4)
	end

	local animId = "rbxassetid://855828754"
	local GRIP_DOC = CFrame.new(-1.47, 0.35, -1.65, 0, 0, -1, -1, 0, 0, 0, 1, 0)
	local GRIP_NGANG = CFrame.new(-1.5, 0.8, -1.65, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	tool.Grip = GRIP_DOC

	local equipped, isFlying = false, false
	local FLY_SPEED = 70
	local bodyVel, bodyGyro, lastTrailPos, currentAnimTrack

	local GoldenColors = {
		Color3.fromRGB(255, 240, 100), Color3.fromRGB(255, 223, 0),
		Color3.fromRGB(255, 215, 0), Color3.fromRGB(238, 201, 0),
		Color3.fromRGB(255, 230, 50)
	}

	local function createRainbow(fromPos, toPos)
		local dist = (toPos - fromPos).Magnitude
		if dist < 1 then return end
		local mid = fromPos:Lerp(toPos, 0.5)
		local lookCF = CFrame.lookAt(mid, toPos)
		local model = Instance.new("Model", workspace)

		for i, color in ipairs(GoldenColors) do
			local p = Instance.new("Part")
			p.Size = Vector3.new(0.65, 0.5, dist + 2)
			p.Anchored, p.CanCollide, p.Material = true, false, Enum.Material.Neon
			p.Color, p.Transparency = color, 0.02
			p.CFrame = lookCF * CFrame.new((i - 3) * 0.65, -2.2, 0)

			local light = Instance.new("PointLight", p)
			light.Color, light.Brightness, light.Range = color, 15, 18
			p.Parent = model
		end
		Debris:AddItem(model, 1.5)
	end

	local function cleanupMovers()
		if bodyVel then bodyVel:Destroy() bodyVel = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	end

	local function stopFlying()
		isFlying = false
		tool.Grip = GRIP_DOC
		lastTrailPos = nil
		cleanupMovers()
		if currentAnimTrack then currentAnimTrack:Stop() currentAnimTrack:Destroy() currentAnimTrack = nil end
		local char = LocalPlayer.Character
		if char and char:FindFirstChild("Humanoid") then
			char.Humanoid.PlatformStand = false
			char.Humanoid.AutoRotate = true
		end
	end

	local function startFlying()
		local char = LocalPlayer.Character
		if not char then return end
		local hrp, humanoid = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
		if not hrp or not humanoid then return end

		isFlying = true
		tool.Grip = GRIP_NGANG
		lastTrailPos = hrp.Position
		humanoid.PlatformStand = true
		humanoid.AutoRotate = false
		cleanupMovers()

		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			local animObj = Instance.new("Animation", animator)
			animObj.AnimationId = animId
			currentAnimTrack = animator:LoadAnimation(animObj)
			currentAnimTrack.Priority = Enum.AnimationPriority.Action
			currentAnimTrack:Play()
		end

		bodyVel = Instance.new("BodyVelocity", hrp)
		bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVel.Velocity = Vector3.zero

		bodyGyro = Instance.new("BodyGyro", hrp)
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.P, bodyGyro.CFrame = 12000, hrp.CFrame
		hrp.AssemblyLinearVelocity = Vector3.new(0, 25, 0)
	end

	tool.Activated:Connect(function()
		if equipped then
			if isFlying then stopFlying() else startFlying() end
		end
	end)

	tool.Equipped:Connect(function() equipped = true tool.Grip = GRIP_DOC end)
	tool.Unequipped:Connect(function() equipped = false stopFlying() end)

	local charConn
	if LocalPlayer.Character then
		charConn = LocalPlayer.CharacterAdded:Connect(stopFlying)
	end

	local trailCooldown = 0
	local renderConn
	renderConn = RunService.RenderStepped:Connect(function(dt)
		if not tool or not tool.Parent then
			stopFlying()
			if renderConn then renderConn:Disconnect() end
			if charConn then charConn:Disconnect() end
			return
		end
		if not (equipped and isFlying and LocalPlayer.Character) then return end
		local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp or not bodyVel or not bodyGyro then return end

		bodyGyro.CFrame = camera.CFrame
		local moveDir = Vector3.zero
		if LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0.05 then
			local localMove = camera.CFrame:VectorToObjectSpace(LocalPlayer.Character.Humanoid.MoveDirection)
			moveDir = Vector3.new(localMove.X, 0, localMove.Z)
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir += Vector3.new(0, -1, 0) end

		if moveDir.Magnitude > 0 then
			bodyVel.Velocity = (camera.CFrame.RightVector * moveDir.X + Vector3.new(0, 1, 0) * moveDir.Y + camera.CFrame.LookVector * -moveDir.Z).Unit * FLY_SPEED
		else
			bodyVel.Velocity = Vector3.zero
		end

		trailCooldown -= dt
		if trailCooldown <= 0 then
			trailCooldown = 0.05
			local currentPos = hrp.Position
			if lastTrailPos and (currentPos - lastTrailPos).Magnitude > 1.5 then
				createRainbow(lastTrailPos, currentPos)
				lastTrailPos = currentPos
			end
		end
	end)

	tool.Parent = backpack
end

-- C) RAINBOW CARPET (/GEAR ME RAINBOWCARPET)
local function runRainbowCarpetScript()
	pcall(function()
		loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Open-Source-227632"))()
	end)
end

-- D) HAIR DRYER (/GEAR ME HAIRDRYER)
local function giveHairDryer()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
	if not backpack then return end
	local character = LocalPlayer.Character

	for _, item in pairs(backpack:GetChildren()) do
		if item.Name == "Hair Dryer" then
			item:Destroy()
		end
	end
	if character then
		for _, item in pairs(character:GetChildren()) do
			if item.Name == "Hair Dryer" then
				item:Destroy()
			end
		end
	end

	local HAIR_DRYER_ID = 11719016
	local success, tool = pcall(function()
		return game:GetObjects("rbxassetid://" .. HAIR_DRYER_ID)[1]
	end)

	if not success or not tool or not tool:IsA("Tool") then
		warn("❌ Hair Dryer could not be loaded.")
		return
	end

	tool.Name = "Hair Dryer"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.ToolTip = "Hair Dryer Original 💨"

	for _, child in ipairs(tool:GetDescendants()) do
		if child:IsA("Script") or child:IsA("LocalScript") then
			child:Destroy()
		end
	end

	local particles = Instance.new("ParticleEmitter")
	particles.Name = "BubbleEmitter"
	particles.Texture = "rbxassetid://241650934"
	particles.Rate = 120
	particles.Lifetime = NumberRange.new(1.5, 2.5)
	particles.Speed = NumberRange.new(10, 25)
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(1, 1.8)
	})
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	particles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	particles.LightEmission = 0.5
	particles.Enabled = false

	local canUse = true
	local cooldown = 1.0
	local clickToken = 0

	tool.Equipped:Connect(function()
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local att = root:FindFirstChild("BubbleAttachment")
			if not att then
				att = Instance.new("Attachment")
				att.Name = "BubbleAttachment"
				att.Parent = root
			end
			particles.Parent = att
		end
	end)

	tool.Activated:Connect(function()
		if not canUse then return end

		local char = LocalPlayer.Character
		if not char then return end

		local rootPart = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")

		if not rootPart or not hum or hum.Health <= 0 then return end

		canUse = false
		clickToken = clickToken + 1
		local myToken = clickToken

		particles.Enabled = true

		local oldBoost = rootPart:FindFirstChild("SecadoraBoost")
		if oldBoost then oldBoost:Destroy() end

		local cam = workspace.CurrentCamera
		local backwardDir = -Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z).Unit

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Name = "SecadoraBoost"
		bodyVelocity.Velocity = Vector3.new(backwardDir.X * 45, 25, backwardDir.Z * 45)
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Parent = rootPart
		Debris:AddItem(bodyVelocity, 0.9)

		task.delay(1.5, function()
			if myToken == clickToken then
				particles.Enabled = false
			end
		end)

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://106593526813937"
		sound.Volume = 1
		sound.PlaybackSpeed = 1
		sound.Parent = rootPart
		sound:Play()

		task.delay(1.5, function()
			if sound and sound.Parent then
				sound:Stop()
				sound:Destroy()
			end
		end)

		task.wait(cooldown)
		canUse = true
	end)

	tool.Unequipped:Connect(function()
		particles.Enabled = false
	end)

	tool.Parent = backpack
end

-- E) CROSSBOW OF THE SEA (/GEAR ME CROSSBOW) - ASSET ID 236438668 REPLICA + JUMP
local function giveCrossbowOfTheSea()
	local toolId = 236438668
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
	if not backpack then return end

	if backpack:FindFirstChild("Crossbow of the Sea") then
		backpack["Crossbow of the Sea"]:Destroy()
	end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Crossbow of the Sea") then
		LocalPlayer.Character["Crossbow of the Sea"]:Destroy()
	end

	local SHOT_SOUND_ID = "rbxassetid://99204505"
	local HIT_SOUND_ID  = "rbxassetid://58274204"
	local mouse = LocalPlayer:GetMouse()

	local function createArrow()
		local arrow = Instance.new("Part")
		arrow.Name = "SeaArrow"
		arrow.Size = Vector3.new(0.2, 0.2, 2.5)
		arrow.Transparency = 0.25
		arrow.Reflectance = 0.5
		arrow.CanCollide = false
		arrow.Anchored = false
		arrow.Material = Enum.Material.SmoothPlastic
		arrow.BrickColor = BrickColor.new("Cyan")

		local mesh = Instance.new("SpecialMesh")
		mesh.MeshId = "rbxassetid://235107348"
		mesh.TextureId = "rbxassetid://235107780"
		mesh.Scale = Vector3.new(1, 1, 1)
		mesh.Parent = arrow

		local hitSound = Instance.new("Sound")
		hitSound.Name = "Hit"
		hitSound.SoundId = HIT_SOUND_ID
		hitSound.Volume = 1
		hitSound.Parent = arrow

		return arrow
	end

	local success, objects = pcall(function()
		return game:GetObjects("rbxassetid://" .. tostring(toolId))
	end)

	local tool
	if success and objects and objects[1] and objects[1]:IsA("Tool") then
		tool = objects[1]
	else
		tool = Instance.new("Tool")
		local fallbackHandle = Instance.new("Part")
		fallbackHandle.Name = "Handle"
		fallbackHandle.Size = Vector3.new(0.5, 1.3, 3.0)
		fallbackHandle.BrickColor = BrickColor.new("Cyan")
		fallbackHandle.Material = Enum.Material.Neon
		fallbackHandle.CanCollide = false
		fallbackHandle.Parent = tool
	end

	tool.Name = "Crossbow of the Sea"
	tool.Parent = backpack

	for _, child in ipairs(tool:GetDescendants()) do
		if child:IsA("Script") or child:IsA("LocalScript") then
			child:Destroy()
		end
	end

	local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
	if handle then
		local shotSound = Instance.new("Sound")
		shotSound.Name = "Shot"
		shotSound.SoundId = SHOT_SOUND_ID
		shotSound.Volume = 0.5
		shotSound.Parent = handle
	end

	local AttackAble = true
	local AttackReloadTime = 1.2
	local ProjectileSpeed = 120

	tool.Activated:Connect(function()
		if not AttackAble then return end
		AttackAble = false

		local char = LocalPlayer.Character
		if not char then
			AttackAble = true
			return
		end

		local currentHandle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
		if currentHandle and currentHandle:FindFirstChild("Shot") then
			currentHandle.Shot.Pitch = math.random(90, 110) / 100
			currentHandle.Shot:Play()
		end

		local targetPoint = (mouse and mouse.Hit) and mouse.Hit.Position or Vector3.new(0, 10, 0)
		local launchPoint = (currentHandle and currentHandle.Position)
			or (char.PrimaryPart and char.PrimaryPart.Position)
			or Vector3.new(0, 5, 0)

		local arrow = createArrow()
		arrow.CFrame = CFrame.new(launchPoint, targetPoint)
		arrow.AssemblyLinearVelocity = arrow.CFrame.LookVector * ProjectileSpeed
		arrow.Parent = workspace

		local connection
		connection = arrow.Touched:Connect(function(part)
			if part:IsDescendantOf(char) then return end

			triggerWaterExplosion(arrow.Position)

			if arrow:FindFirstChild("Hit") then
				arrow.Hit:Play()
			end

			arrow.Anchored = true
			arrow.CanCollide = false
			arrow.Transparency = 1

			if connection then
				connection:Disconnect()
			end
		end)

		Debris:AddItem(arrow, 8)

		task.delay(AttackReloadTime, function()
			AttackAble = true
		end)
	end)

	local JUMP_POWER = 78
	local BOOST_FRAMES = 8

	local function isInWater()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum then return false end
		local state = hum:GetState()
		return state == Enum.HumanoidStateType.Swimming or state == Enum.HumanoidStateType.GettingUp
	end

	local jumpConn = UserInputService.JumpRequest:Connect(function()
		if not tool.Parent or tool.Parent ~= LocalPlayer.Character then return end
		if not isInWater() then return end

		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end

		hum:ChangeState(Enum.HumanoidStateType.Jumping)

		root.AssemblyLinearVelocity = Vector3.new(
			root.AssemblyLinearVelocity.X,
			JUMP_POWER,
			root.AssemblyLinearVelocity.Z
		)

		task.spawn(function()
			for _ = 1, BOOST_FRAMES do
				if not root or not root.Parent then break end
				if root.AssemblyLinearVelocity.Y < JUMP_POWER * 0.7 then
					root.AssemblyLinearVelocity = Vector3.new(
						root.AssemblyLinearVelocity.X,
						math.max(root.AssemblyLinearVelocity.Y, JUMP_POWER * 0.85),
						root.AssemblyLinearVelocity.Z
					)
				end
				RunService.Heartbeat:Wait()
			end
		end)
	end)

	tool.Destroying:Connect(function()
		if jumpConn then jumpConn:Disconnect() end
	end)

	local charHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if charHum then
		pcall(function()
			charHum:EquipTool(tool)
		end)
	end
end

-- E2) WATER BOMB (/GEAR ME WATERBOMB)
local function giveWaterBomb()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
	if not backpack then return end

	if backpack:FindFirstChild("Water Bomb") then
		backpack["Water Bomb"]:Destroy()
	end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Water Bomb") then
		LocalPlayer.Character["Water Bomb"]:Destroy()
	end

	local mouse = LocalPlayer:GetMouse()

	local tool = Instance.new("Tool")
	tool.Name = "Water Bomb"
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	tool.ToolTip = "Water Bomb 💧"
	tool.TextureId = "rbxthumb://type=Asset&id=236438668&w=420&h=420"

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Shape = Enum.PartType.Ball
	handle.Size = Vector3.new(1.8, 1.8, 1.8)
	handle.BrickColor = BrickColor.new("Cyan")
	handle.Material = Enum.Material.Neon
	handle.CanCollide = false
	handle.Parent = tool

	local canThrow = true
	tool.Activated:Connect(function()
		if not canThrow then return end
		canThrow = false

		local char = LocalPlayer.Character
		local currentHandle = tool:FindFirstChild("Handle")
		if not char or not currentHandle then
			canThrow = true
			return
		end

		local targetPos = (mouse and mouse.Hit) and mouse.Hit.Position or (currentHandle.Position + Vector3.new(0, -4, 0))
		local spawnPos = currentHandle.Position
		local direction = (targetPos - spawnPos).Magnitude > 0.1 and (targetPos - spawnPos).Unit or Vector3.new(0, 0, -1)

		local bomb = Instance.new("Part")
		bomb.Name = "WaterBombProjectile"
		bomb.Shape = Enum.PartType.Ball
		bomb.Size = Vector3.new(2, 2, 2)
		bomb.BrickColor = BrickColor.new("Cyan")
		bomb.Material = Enum.Material.Neon
		bomb.CanCollide = true
		bomb.CFrame = CFrame.new(spawnPos + direction * 3)
		bomb.AssemblyLinearVelocity = direction * 110 + Vector3.new(0, 12, 0)
		bomb.Parent = workspace

		local exploded = false
		local function detonate()
			if exploded then return end
			exploded = true
			triggerWaterExplosion(bomb.Position)

			local hitSound = Instance.new("Sound")
			hitSound.SoundId = "rbxassetid://58274204"
			hitSound.Volume = 1
			hitSound.Parent = bomb
			hitSound:Play()

			bomb.Anchored = true
			bomb.CanCollide = false
			bomb.Transparency = 1
			Debris:AddItem(bomb, 2)
		end

		local conn
		conn = bomb.Touched:Connect(function(hit)
			if hit and not hit:IsDescendantOf(char) and not hit:IsDescendantOf(tool) then
				if conn then conn:Disconnect() end
				detonate()
			end
		end)

		task.delay(4, detonate)
		task.wait(1.0)
		canThrow = true
	end)

	tool.Parent = backpack
end

-- F) SNOWY GRAVITY COIL (/GEAR ME SNOWYCOIL)
local function giveSnowyGravityCoil()
	local GRAVITY_REDUCTION = 0.75
	local SNOWY_COIL_ASSET_ID = 190492616
	local GRAVITY_SOUND_ID = "rbxassetid://16619553"
	local INVENTORY_ICON = "rbxthumb://type=Asset&id=480031544&w=420&h=420"

	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
	if not backpack then return end

	if backpack:FindFirstChild("SnowyCoil") then backpack.SnowyCoil:Destroy() end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("SnowyCoil") then LocalPlayer.Character.SnowyCoil:Destroy() end

	local tool
	local success, objects = pcall(function()
		return game:GetObjects("rbxassetid://" .. SNOWY_COIL_ASSET_ID)
	end)

	if success and objects and objects[1] and objects[1]:IsA("Tool") then
		tool = objects[1]
	else
		tool = Instance.new("Tool")
		if success and objects and objects[1] then
			objects[1].Parent = tool
		end
	end

	tool.Name = "SnowyCoil"
	tool.ToolTip = "Jump higher!"
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool.TextureId = INVENTORY_ICON

	local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
	if not handle then
		handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(1, 1.2, 2)
		handle.CanCollide = false
		handle.Massless = true
		handle.Parent = tool
	else
		handle.Name = "Handle"
	end

	local sound = handle:FindFirstChild("CoilSound")
	if not sound then
		sound = Instance.new("Sound")
		sound.Name = "CoilSound"
		sound.SoundId = GRAVITY_SOUND_ID
		sound.Volume = 1
		sound.Parent = handle
	end

	local force, conn, hb

	tool.Equipped:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end

		if sound then sound:Play() end

		force = Instance.new("BodyForce")
		force.Name = "GravityCoilEffect"
		force.Parent = root
		force.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity * GRAVITY_REDUCTION, 0)

		local oldJump = hum.UseJumpPower and hum.JumpPower or hum.JumpHeight
		if hum.UseJumpPower then hum.JumpPower = 75 else hum.JumpHeight = 18 end

		hb = RunService.Heartbeat:Connect(function()
			if not tool.Parent or tool.Parent ~= char or not char.Parent then
				if force then force:Destroy() end
				if hb then hb:Disconnect() end
				return
			end
			force.Force = Vector3.new(0, root.AssemblyMass * workspace.Gravity * GRAVITY_REDUCTION, 0)
		end)

		conn = tool.Unequipped:Connect(function()
			if force then force:Destroy() end
			if hb then hb:Disconnect() end
			if conn then conn:Disconnect() end
			if hum and hum.Parent then
				if hum.UseJumpPower then hum.JumpPower = oldJump else hum.JumpHeight = oldJump end
			end
		end)
	end)

	tool.Unequipped:Connect(function()
		if force then force:Destroy() end
		if hb then hb:Disconnect() end
	end)

	tool.Parent = backpack
end

-- G) DUAL GRAVITY COIL (/GEAR ME DUALCOIL)
local function runDualGravityCoilScript()
	pcall(function()
		loadstring(game:HttpGet("https://pastefy.app/SQkmjy25/raw"))()
	end)
end

-- H) JETPACK (/GEAR ME JETPACK)
local function runJetpackScript()
	pcall(function()
		loadstring(game:HttpGet("https://pastefy.app/3I4B1Imu/raw"))()
	end)
end

-- I) DARK PEGASUS (/GEAR ME DARKPEGASUS)
local function runDarkPegasusScript()
	pcall(function()
		loadstring(game:HttpGet("https://pastefy.app/MVITXPKt/raw"))()
	end)
end

-- J) SPEED COIL (/GEAR ME SPEEDCOIL) - STANDALONE + LIMPIEZA
local speedCoilRespawnConnection
local speedCoilToolName = "Speed Coil"

local function createSpeedCoil()
	local tool = Instance.new("Tool")
	tool.Name = speedCoilToolName
	tool.ToolTip = "Speed Up!"
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool.TextureId = "rbxassetid://99170415"

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1.2, 2)
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://16606212"
	mesh.TextureId = "rbxassetid://99170547"
	mesh.Scale = Vector3.new(0.7, 0.7, 0.7)
	mesh.Parent = handle

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://99173388"
	sound.Volume = 1
	sound.Parent = handle

	local humanoid
	local oldSpeed

	local function restore()
		if humanoid and humanoid.Parent and oldSpeed ~= nil then
			humanoid.WalkSpeed = oldSpeed
		end
		humanoid = nil
		oldSpeed = nil
	end

	tool.Equipped:Connect(function()
		local character = LocalPlayer.Character
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			oldSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 32
			sound:Play()
		end
	end)

	tool.Unequipped:Connect(restore)
	tool.Destroying:Connect(restore)
	return tool
end

local function removeSpeedCoil()
	if speedCoilRespawnConnection then
		speedCoilRespawnConnection:Disconnect()
		speedCoilRespawnConnection = nil
	end

	for _, container in ipairs({
		LocalPlayer:FindFirstChildOfClass("Backpack"),
		LocalPlayer.Character
	}) do
		if container then
			local tool = container:FindFirstChild(speedCoilToolName)
			if tool and tool:IsA("Tool") then
				tool:Destroy()
			end
		end
	end
end

local function runSpeedCoilScript()
	removeSpeedCoil()

	local function giveCoil()
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
			or LocalPlayer:WaitForChild("Backpack")
		local character = LocalPlayer.Character
		if not backpack then return end

		if not backpack:FindFirstChild(speedCoilToolName)
			and not (character and character:FindFirstChild(speedCoilToolName)) then
			createSpeedCoil().Parent = backpack
		end
	end

	giveCoil()
	speedCoilRespawnConnection = LocalPlayer.CharacterAdded:Connect(function()
		task.wait(1)
		giveCoil()
	end)
end

-- K) GRAVITY COIL (/GEAR ME GRAVITYCOIL) - STANDALONE + LIMPIEZA
local gravityCoilRespawnConnection
local gravityCoilToolName = "Gravity Coil"

local function createGravityCoil()
	local tool = Instance.new("Tool")
	tool.Name = gravityCoilToolName
	tool.ToolTip = "Jump higher!"
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool.TextureId = "rbxassetid://16619617"

	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1.2, 2)
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.MeshId = "rbxassetid://16606212"
	mesh.TextureId = "rbxassetid://16606141"
	mesh.Scale = Vector3.new(0.7, 0.7, 0.7)
	mesh.Parent = handle

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://16619553"
	sound.Volume = 1
	sound.Parent = handle

	local force
	local heartbeat
	local humanoid
	local oldJumpPower
	local oldJumpHeight
	local oldUseJumpPower

	local function removeEffect()
		if heartbeat then
			heartbeat:Disconnect()
			heartbeat = nil
		end
		if force then
			force:Destroy()
			force = nil
		end
		if humanoid and humanoid.Parent then
			if oldUseJumpPower then
				humanoid.JumpPower = oldJumpPower
			else
				humanoid.JumpHeight = oldJumpHeight
			end
		end
		humanoid = nil
	end

	tool.Equipped:Connect(function()
		removeEffect()

		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return end

		sound:Play()
		oldJumpPower = humanoid.JumpPower
		oldJumpHeight = humanoid.JumpHeight
		oldUseJumpPower = humanoid.UseJumpPower

		force = Instance.new("BodyForce")
		force.Name = "GravityCoilEffect"
		force.Parent = root

		if humanoid.UseJumpPower then
			humanoid.JumpPower = 60
		else
			humanoid.JumpHeight = 12
		end

		heartbeat = RunService.Heartbeat:Connect(function()
			if not force or not force.Parent or not root.Parent then
				removeEffect()
				return
			end
			force.Force = Vector3.new(
				0,
				root.AssemblyMass * workspace.Gravity * 0.62,
				0
			)
		end)
	end)

	tool.Unequipped:Connect(removeEffect)
	tool.Destroying:Connect(removeEffect)
	return tool
end

local function removeGravityCoil()
	if gravityCoilRespawnConnection then
		gravityCoilRespawnConnection:Disconnect()
		gravityCoilRespawnConnection = nil
	end

	for _, container in ipairs({
		LocalPlayer:FindFirstChildOfClass("Backpack"),
		LocalPlayer.Character
	}) do
		if container then
			local tool = container:FindFirstChild(gravityCoilToolName)
			if tool and tool:IsA("Tool") then
				tool:Destroy()
			end
		end
	end

	-- Limpia cualquier efecto residual que haya quedado en el personaje.
	local character = LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then
		local residualForce = root:FindFirstChild("GravityCoilEffect")
		if residualForce then residualForce:Destroy() end
	end
end

local function runGravityCoilScript()
	removeGravityCoil()

	local function giveCoil()
		local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
			or LocalPlayer:WaitForChild("Backpack")
		local character = LocalPlayer.Character
		if not backpack then return end

		if not backpack:FindFirstChild(gravityCoilToolName)
			and not (character and character:FindFirstChild(gravityCoilToolName)) then
			createGravityCoil().Parent = backpack
		end
	end

	giveCoil()
	gravityCoilRespawnConnection = LocalPlayer.CharacterAdded:Connect(function()
		task.wait(1)
		giveCoil()
	end)
end

-- L) HYPER COIL (/GEAR ME HYPERCOIL)
local function runHyperCoilScript()
	pcall(function()
		loadstring(game:HttpGet("https://scriptblox.com/raw/Universal-Script-Hypers-Imaginary-Coil-193898"))()
	end)
end

-- M) WHOSUNA UÇAN HALI (/GEAR ME WHOSUNA)
local function giveWhosuna()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack") or LocalPlayer:WaitForChild("Backpack", 5)
	if not backpack then return end

	local TOOL_NAME = "Whosuna"
	local ASSET_ID = 1937103

	for _, container in ipairs({ backpack, LocalPlayer.Character }) do
		if container then
			for _, name in ipairs({ TOOL_NAME, "พรมทอง" }) do
				local old = container:FindFirstChild(name)
				if old then
					old:Destroy()
				end
			end
		end
	end

	local tool = Instance.new("Tool")
	tool.Name = TOOL_NAME
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	tool.TextureId = "rbxthumb://type=Asset&id=" .. tostring(ASSET_ID) .. "&w=420&h=420"
	tool.Parent = backpack

	local speed = 95
	local flying = false
	local carpet, attachment, velocity, rotation, loop
	local humanoid, root
	local oldAutoRotate

	local function safeDestroy(inst)
		if inst and inst.Parent then
			pcall(function()
				inst:Destroy()
			end)
		end
	end

	local function stop()
		flying = false

		if loop then
			loop:Disconnect()
			loop = nil
		end

		for _, item in ipairs({ velocity, rotation, attachment, carpet }) do
			safeDestroy(item)
		end

		velocity, rotation, attachment, carpet = nil, nil, nil, nil

		if humanoid and humanoid.Parent then
			humanoid.PlatformStand = false
			if oldAutoRotate ~= nil then
				humanoid.AutoRotate = oldAutoRotate
			else
				humanoid.AutoRotate = true
			end
			pcall(function()
				humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			end)
		end

		if root and root.Parent then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
	end

	local function applyAssetVisualToCarpet(carpetPart)
		local ok, objs = pcall(function()
			return game:GetObjects("rbxassetid://" .. tostring(ASSET_ID))
		end)
		if not ok or type(objs) ~= "table" then return end

		for _, obj in ipairs(objs) do
			local mesh = obj:IsA("SpecialMesh") and obj or obj:FindFirstChildWhichIsA("SpecialMesh", true)
			if mesh then
				local clonedMesh = mesh:Clone()
				clonedMesh.Parent = carpetPart
				break
			end
			local decal = obj:IsA("Decal") and obj or obj:FindFirstChildWhichIsA("Decal", true)
			if decal then
				local clonedDecal = decal:Clone()
				clonedDecal.Parent = carpetPart
				break
			end
		end

		for _, obj in ipairs(objs) do
			safeDestroy(obj)
		end
	end

	local function start()
		local character = LocalPlayer.Character
		if not character or tool.Parent ~= character then return end

		humanoid = character:FindFirstChildOfClass("Humanoid")
		root = character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not root or humanoid.Health <= 0 then return end

		oldAutoRotate = humanoid.AutoRotate
		flying = true

		carpet = Instance.new("Part")
		carpet.Name = TOOL_NAME .. "Carpet"
		carpet.Size = Vector3.new(5, 0.2, 7)
		carpet.Color = Color3.fromRGB(255, 190, 35)
		carpet.Material = Enum.Material.Metal
		carpet.Anchored = true
		carpet.CanCollide = false
		carpet.CanTouch = false
		carpet.CanQuery = false
		carpet.Parent = workspace

		applyAssetVisualToCarpet(carpet)

		local border = Instance.new("SelectionBox")
		border.Adornee = carpet
		border.Color3 = Color3.fromRGB(255, 235, 130)
		border.LineThickness = 0.05
		border.SurfaceTransparency = 1
		border.Parent = carpet

		attachment = Instance.new("Attachment")
		attachment.Parent = root

		velocity = Instance.new("LinearVelocity")
		velocity.Attachment0 = attachment
		velocity.RelativeTo = Enum.ActuatorRelativeTo.World
		velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		velocity.ForceLimitsEnabled = false
		velocity.VectorVelocity = Vector3.zero
		velocity.Parent = root

		rotation = Instance.new("AlignOrientation")
		rotation.Attachment0 = attachment
		rotation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		rotation.MaxTorque = math.huge
		rotation.Responsiveness = 25
		rotation.Parent = root

		humanoid.AutoRotate = false
		humanoid.PlatformStand = true

		loop = RunService.RenderStepped:Connect(function()
			if not flying or not root or not root.Parent or not humanoid or humanoid.Health <= 0 then
				stop()
				return
			end

			local cam = workspace.CurrentCamera
			if not cam then return end

			local look = cam.CFrame.LookVector
			local flat = Vector3.new(look.X, 0, look.Z)

			if flat.Magnitude > 0.01 then
				flat = flat.Unit
			else
				local facing = root.CFrame.LookVector
				local flatFacing = Vector3.new(facing.X, 0, facing.Z)
				flat = flatFacing.Magnitude > 0.01 and flatFacing.Unit or Vector3.new(0, 0, -1)
			end

			local right = Vector3.new(-flat.Z, 0, flat.X)
			local move = humanoid.MoveDirection
			local forwardAmount = move:Dot(flat)
			local sideAmount = move:Dot(right)

			local direction = look * forwardAmount + right * sideAmount
			if direction.Magnitude > 1 then
				direction = direction.Unit
			end

			velocity.VectorVelocity = direction * speed
			rotation.CFrame = CFrame.lookAt(Vector3.zero, flat)

			local height = humanoid.HipHeight + root.Size.Y / 2 + 0.15
			carpet.CFrame = CFrame.lookAt(root.Position, root.Position + flat) * CFrame.new(0, -height, 0)
		end)
	end

	tool.Activated:Connect(function()
		if flying then
			stop()
		else
			start()
		end
	end)

	tool.Unequipped:Connect(stop)
	tool.Destroying:Connect(stop)
	LocalPlayer.CharacterRemoving:Connect(stop)
end

-- N) NONMAGIC CARPET (/GEAR ME NONMAGICCARPET)
local function runNonmagicCarpetScript()
	pcall(function()
		loadstring(game:HttpGet("https://pastefy.app/U1zk3Dqt/raw"))()
	end)
end

-- O) MMV ESP SİSTEMİ (/ESP)
local espEnabled = false
local highlights = {}

local function getRole(plr)
	return getPlayerRole(plr)
end

local function removeESP(plr)
	if highlights[plr] then
		highlights[plr]:Destroy()
		highlights[plr] = nil
	end
end

local function updateESPForPlayer(plr)
	if plr == LocalPlayer then return end

	if not espEnabled then
		removeESP(plr)
		return
	end

	local character = plr.Character
	if character then
		local hl = highlights[plr]
		if not hl or not hl.Parent then
			hl = Instance.new("Highlight")
			hl.Adornee = character
			hl.Parent = character
			highlights[plr] = hl
		end

		local role = getRole(plr)
		if role == "Murderer" then
			hl.FillColor = Color3.fromRGB(255, 0, 0)
			hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		elseif role == "Sheriff" then
			hl.FillColor = Color3.fromRGB(0, 0, 255)
			hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		else
			hl.FillColor = Color3.fromRGB(0, 255, 0)
			hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		end
	else
		removeESP(plr)
	end
end

local function toggleESP()
	espEnabled = not espEnabled
	if espEnabled then
		for _, p in ipairs(Players:GetPlayers()) do
			updateESPForPlayer(p)
		end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			removeESP(p)
		end
	end
end

Players.PlayerRemoving:Connect(removeESP)

-- ==========================================
-- 3. KAYITLI KOMUTLAR LİSTESİ (/GEAR ME <İSİM> BÜYÜK HARF)
-- ==========================================
local Commands = {
	{
		command = "/BLOCK",
		nameKey = "cmdBlockName",
		icon = "🔒",
		action = toggleBlock,
		instant = true,
		aliases = { "block", "bloquear" }
	},
	{
		command = "/ESP",
		nameKey = "cmdEspName",
		icon = "👁️",
		action = toggleESP,
		aliases = { "esp" }
	},
	{
		command = "/GEAR ME ROCKETLAUNCHER",
		nameKey = "cmdRocketName",
		icon = "🚀",
		action = giveRocketLauncher,
		aliases = { "rocketlauncher", "rocket", "launcher", "lanzacohetes" }
	},
	{
		command = "/GEAR ME GOLDENCARPET",
		nameKey = "cmdGoldenCarpetName",
		icon = "🟨",
		action = giveGoldenCarpet,
		aliases = { "goldencarpet", "golden", "carpet", "alfombra" }
	},
	{
		command = "/GEAR ME RAINBOWCARPET",
		nameKey = "cmdRainbowCarpetName",
		icon = "🌈",
		action = runRainbowCarpetScript,
		aliases = { "rainbowcarpet", "rainbow", "arcoiris" }
	},
	{
		command = "/GEAR ME HAIRDRYER",
		nameKey = "cmdHairDryerName",
		icon = "💨",
		action = giveHairDryer,
		aliases = { "hairdryer", "dryer", "hair", "secador" }
	},
	{
		command = "/GEAR ME CROSSBOW",
		nameKey = "cmdCrossbowName",
		icon = "🏹",
		action = giveCrossbowOfTheSea,
		aliases = { "crossbow", "crossbowofthesea", "sea", "ballesta", "besta" }
	},
	{
		command = "/GEAR ME WATERBOMB",
		nameKey = "cmdWaterBombName",
		icon = "💧",
		action = giveWaterBomb,
		aliases = { "waterbomb", "water", "bomb" }
	},
	{
		command = "/GEAR ME SNOWYCOIL",
		nameKey = "cmdSnowyCoilName",
		icon = "❄️",
		action = giveSnowyGravityCoil,
		aliases = { "snowycoil", "snowygravitycoil", "snowy", "nevado" }
	},
	{
		command = "/GEAR ME DUALCOIL",
		nameKey = "cmdDualCoilName",
		icon = "🌀",
		action = runDualGravityCoilScript,
		aliases = { "dualcoil", "dualgravitycoil", "dual", "doble", "dupla" }
	},
	{
		command = "/GEAR ME JETPACK",
		nameKey = "cmdJetpackName",
		icon = "🚀",
		action = runJetpackScript,
		aliases = { "jetpack" }
	},
	{
		command = "/GEAR ME DARKPEGASUS",
		nameKey = "cmdDarkPegasusName",
		icon = "🐴",
		action = runDarkPegasusScript,
		aliases = { "darkpegasus", "pegasus", "pegaso" }
	},
	{
		command = "/GEAR ME SPEEDCOIL",
		nameKey = "cmdSpeedCoilName",
		icon = "⚡",
		action = runSpeedCoilScript,
		aliases = { "speedcoil", "speed", "velocidad" }
	},
	{
		command = "/GEAR ME GRAVITYCOIL",
		nameKey = "cmdGravityCoilName",
		icon = "🪐",
		action = runGravityCoilScript,
		aliases = { "gravitycoil", "gravity", "gravedad", "gravidade" }
	},
	{
		command = "/GEAR ME HYPERCOIL",
		nameKey = "cmdHyperCoilName",
		icon = "🔥",
		action = runHyperCoilScript,
		aliases = { "hypercoil", "hyper", "hiper" }
	},
	{
		command = "/GEAR ME WHOSUNA",
		nameKey = "cmdWhosunaName",
		icon = "🪄",
		action = giveWhosuna,
		aliases = { "whosuna", "carpet2" }
	},
	{
		command = "/GEAR ME NONMAGICCARPET",
		nameKey = "cmdNonmagicCarpetName",
		icon = "🪁",
		action = runNonmagicCarpetScript,
		aliases = { "nonmagiccarpet", "nonmagic" }
	}
}

-- ==========================================
-- 4. DUSCK | CC COMMANDS ARAYÜZÜ (KÜÇÜLTÜLMÜŞ)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomAdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 290, 0, 164)
mainFrame.Position = UDim2.new(0.5, -145, 0.60, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Botón para minimizar y botón flotante para restaurar el panel
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 24, 0, 20)
minimizeButton.Position = UDim2.new(1, -30, 0, 6)
minimizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
minimizeButton.BorderSizePixel = 0
minimizeButton.Text = "—"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.Parent = mainFrame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeButton

local restoreButton = Instance.new("TextButton")
restoreButton.Name = "DUSCKRestoreButton"
restoreButton.Size = UDim2.new(0, 48, 0, 48)
restoreButton.Position = UDim2.new(1, -68, 0.72, 0)
restoreButton.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
restoreButton.BorderSizePixel = 0
restoreButton.Text = "D"
restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreButton.Font = Enum.Font.GothamBlack
restoreButton.TextSize = 20
restoreButton.Visible = false
restoreButton.Active = true
restoreButton.Draggable = true
restoreButton.Parent = screenGui

local restoreCorner = Instance.new("UICorner")
restoreCorner.CornerRadius = UDim.new(1, 0)
restoreCorner.Parent = restoreButton

local restoreStroke = Instance.new("UIStroke")
restoreStroke.Color = Color3.fromRGB(68, 68, 74)
restoreStroke.Thickness = 1.5
restoreStroke.Parent = restoreButton

minimizeButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    restoreButton.Visible = true
end)

restoreButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    restoreButton.Visible = false
end)

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(68, 68, 74)
uiStroke.Thickness = 1.2
uiStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 20)
titleLabel.Position = UDim2.new(0, 10, 0, 8)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = tr("panelTitle")
titleLabel.TextColor3 = Color3.fromRGB(245, 245, 248)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainFrame

local subTitleLabel = Instance.new("TextLabel")
subTitleLabel.Size = UDim2.new(1, -20, 0, 16)
subTitleLabel.Position = UDim2.new(0, 10, 0, 30)
subTitleLabel.BackgroundTransparency = 1
subTitleLabel.Text = tr("subtitle")
subTitleLabel.TextColor3 = Color3.fromRGB(210, 210, 215)
subTitleLabel.Font = Enum.Font.GothamBlack
subTitleLabel.TextSize = 10
subTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
subTitleLabel.Parent = mainFrame

local inputCard = Instance.new("Frame")
inputCard.Name = "InputCard"
inputCard.Size = UDim2.new(1, -20, 0, 38)
inputCard.Position = UDim2.new(0, 10, 0, 50)
inputCard.BackgroundColor3 = Color3.fromRGB(43, 43, 46)
inputCard.BorderSizePixel = 0
inputCard.Parent = mainFrame

local inputCardCorner = Instance.new("UICorner")
inputCardCorner.CornerRadius = UDim.new(0, 7)
inputCardCorner.Parent = inputCard

local inputCardStroke = Instance.new("UIStroke")
inputCardStroke.Color = Color3.fromRGB(72, 72, 78)
inputCardStroke.Thickness = 1
inputCardStroke.Parent = inputCard

local commandBox = Instance.new("TextBox")
commandBox.Name = "CommandBox"
commandBox.Size = UDim2.new(1, -14, 1, 0)
commandBox.Position = UDim2.new(0, 7, 0, 0)
commandBox.BackgroundTransparency = 1
commandBox.PlaceholderText = tr("textboxHint")
commandBox.PlaceholderColor3 = Color3.fromRGB(235, 235, 240)
commandBox.Text = ""
commandBox.TextColor3 = Color3.fromRGB(255, 255, 255)
commandBox.Font = Enum.Font.GothamBlack
commandBox.TextSize = 11
commandBox.TextXAlignment = Enum.TextXAlignment.Center
commandBox.TextWrapped = true
commandBox.ClearTextOnFocus = false
commandBox.Parent = inputCard

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 0, 91)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = tr("readyStatus")
statusLabel.TextColor3 = Color3.fromRGB(215, 215, 220)
statusLabel.Font = Enum.Font.GothamBlack
statusLabel.TextSize = 10
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

statusLabel.Parent = mainFrame

-- Botón global para apagar los comandos y limpiar sus efectos locales
local disableAllButton = Instance.new("TextButton")
disableAllButton.Name = "DisableAllButton"
disableAllButton.Size = UDim2.new(1, -20, 0, 28)
disableAllButton.Position = UDim2.new(0, 10, 0, 124)
disableAllButton.BackgroundColor3 = Color3.fromRGB(150, 45, 50)
disableAllButton.BorderSizePixel = 0
disableAllButton.Text = "Disable All"
disableAllButton.TextColor3 = Color3.fromRGB(255, 255, 255)
disableAllButton.Font = Enum.Font.GothamBlack
disableAllButton.TextSize = 11
disableAllButton.Parent = mainFrame

local disableAllCorner = Instance.new("UICorner")
disableAllCorner.CornerRadius = UDim.new(0, 7)
disableAllCorner.Parent = disableAllButton

-- ==========================================
-- 5. KOMUT ÇALIŞTIRMA MANTIĞI
-- ==========================================
applyLanguageToPanel = function()
	titleLabel.Text = tr("panelTitle")
	subTitleLabel.Text = tr("subtitle")
	commandBox.PlaceholderText = tr("textboxHint")
	statusLabel.Text = tr("readyStatus")
end

local function findCommandFromInput(rawText)
	local trimmed = string.match(string.lower(rawText or ""), "^%s*(.-)%s*$")
	if not trimmed or trimmed == "" then return nil end

	local gearArg = string.match(trimmed, "^/?gear%s+me%s+(.+)$")
	if gearArg then
		trimmed = string.gsub(gearArg, "%s+", "")
	end

	local compact = string.gsub(trimmed, "%s+", "")

	for _, cmd in ipairs(Commands) do
		local cmdLower = string.lower(cmd.command)
		local cmdCompact = string.gsub(cmdLower, "%s+", "")
		local cmdGearName = string.match(cmdLower, "^/?gear%s+me%s+(.+)$")
		if cmdGearName then
			cmdGearName = string.gsub(cmdGearName, "%s+", "")
		end
		local localizedName = string.lower(tr(cmd.nameKey))
		local nameCompact = string.gsub(localizedName, "%s+", "")

		if trimmed == cmdLower
			or compact == cmdCompact
			or (cmdGearName and compact == cmdGearName)
			or compact == nameCompact then
			return cmd
		end

		if cmd.aliases then
			for _, alias in ipairs(cmd.aliases) do
				if compact == string.lower(alias) then
					return cmd
				end
			end
		end
	end

	return nil
end

local lastRunTick = 0

local function disableAll()

	-- Detener las conexiones de reaparición y restaurar los efectos de ambas coils.
	pcall(removeSpeedCoil)
	pcall(removeGravityCoil)

	-- Apagar los estados y efectos administrados por este script.
	blockEnabled = false
	pcall(function() setCharacterLock(false) end)

	espEnabled = false
	for _, plr in ipairs(Players:GetPlayers()) do
		pcall(function() removeESP(plr) end)
		pcall(function() setTargetBlocked(plr, false) end)
		if jailedPlayers[plr] then
			pcall(function() setTargetJailed(plr, false) end)
		end
	end

	table.clear(blockedPlayers)
	table.clear(jailedPlayers)
	table.clear(jailSavedCFrames)
	goJailInside = false

	-- Quitar las herramientas que este menú agrega al inventario.
	local containers = {
		LocalPlayer:FindFirstChildOfClass("Backpack"),
		LocalPlayer.Character
	}
	for _, container in ipairs(containers) do
		if container then
			for _, item in ipairs(container:GetChildren()) do
				if item:IsA("Tool") then
					local lowerName = string.lower(item.Name)
					local isMenuTool = false
					for _, toolName in ipairs(SpawnedToolNames) do
						if item.Name == toolName then
							isMenuTool = true
							break
						end
					end
					if lowerName == "rocketlauncher"
						or lowerName == "goldencarpet"
						or lowerName == "hair dryer"
						or lowerName == "crossbow of the sea"
						or lowerName == "water bomb"
						or lowerName == "snowycoil"
						or lowerName == "speedcoil"
						or lowerName == "gravitycoil"
						or lowerName == "whosuna"
						or lowerName == "nonmagic carpet"
						or isMenuTool then
						item:Destroy()
					end
				end
			end
		end
	end

	-- Eliminar objetos visuales creados por los sistemas de bloqueo/cárcel.
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "PlayerBlueBlock"
			or obj.Name == "PlayerBlackHeadCover"
			or obj.Name == "JailBlueBox"
			or obj.Name == "FuseBomb" then
			pcall(function() obj:Destroy() end)
		end
	end

	commandBox.Text = ""
	statusLabel.Text = "ALL CLEARED"
	disableAllButton.Text = "Disable All"
	disableAllButton.BackgroundColor3 = Color3.fromRGB(150, 45, 50)
	disableAllButton.Active = true
	disableAllButton.AutoButtonColor = true
end

disableAllButton.MouseButton1Click:Connect(disableAll)

local function executeCommand()
	local now = os.clock()
	if now - lastRunTick < 0.15 then return end
	lastRunTick = now

	local rawText = commandBox.Text
	commandBox.Text = ""

	local targetMode = handleChatOrCommandString(rawText)
	if targetMode then
		if targetMode == "jail" then
			statusLabel.Text = tr("jailRan")
		elseif targetMode == "fling" then
			statusLabel.Text = tr("flingRan")
		elseif targetMode == "map" then
			statusLabel.Text = "ELIGE UN MAPA"
		else
			statusLabel.Text = tr("playerBlockRan")
		end
		if targetMode ~= "map" then
			task.delay(1.5, function()
				statusLabel.Text = tr("readyStatus")
			end)
		end
		return
	end

	local ranCount = 0
	if rawText and string.match(rawText, "%S") then
		for part in string.gmatch(rawText, "[^|]+") do
			local foundCmd = findCommandFromInput(part)
			if foundCmd then
				foundCmd.action()
				if foundCmd.command == "/BLOCK" then
					statusLabel.Text = blockEnabled and tr("blockStatusOn") or tr("blockStatusOff")
				end
				ranCount += 1
			end
		end
	end

	if ranCount > 0 then
		if statusLabel.Text ~= tr("blockStatusOn") and statusLabel.Text ~= tr("blockStatusOff") then
			statusLabel.Text = tr("givenPrefix") .. tostring(ranCount) .. tr("givenSuffix")
		end
		task.delay(1.6, function()
			statusLabel.Text = tr("readyStatus")
		end)
	else
		local lowerRaw = string.lower(string.match(rawText or "", "^%s*(.-)%s*$") or "")
		if isRoleChatMessage(lowerRaw) then
			sendToRobloxChat(rawText)
			statusLabel.Text = "ENVIADO AL CHAT"
			task.delay(1.4, function()
				statusLabel.Text = tr("readyStatus")
			end)
		else
			statusLabel.Text = tr("invalidCommand")
			task.delay(1.3, function()
				statusLabel.Text = tr("readyStatus")
			end)
		end
	end
end

commandBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		executeCommand()
	end
end)

-- ==========================================
-- 6. TAM EKRAN YARI YARIYA DİL SEÇME EKRANI (PORTEKİZCE / İSPANYOLCA)
-- ==========================================
local langGui = Instance.new("ScreenGui")
langGui.Name = "LanguageSelectorGui"
langGui.ResetOnSpawn = false
langGui.DisplayOrder = 100
langGui.IgnoreGuiInset = true
langGui.Parent = playerGui

local fullBackdrop = Instance.new("Frame")
fullBackdrop.Size = UDim2.new(1, 0, 1, 0)
fullBackdrop.Position = UDim2.new(0, 0, 0, 0)
fullBackdrop.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
fullBackdrop.BorderSizePixel = 0
fullBackdrop.Parent = langGui

local ptHalfBtn = Instance.new("TextButton")
ptHalfBtn.Name = "PortugueseHalf"
ptHalfBtn.Size = UDim2.new(0.5, 0, 1, 0)
ptHalfBtn.Position = UDim2.new(0, 0, 0, 0)
ptHalfBtn.BackgroundColor3 = Color3.fromRGB(18, 46, 32)
ptHalfBtn.BorderSizePixel = 0
ptHalfBtn.Text = ""
ptHalfBtn.Parent = fullBackdrop

local ptLabel = Instance.new("TextLabel")
ptLabel.Size = UDim2.new(0.9, 0, 0, 70)
ptLabel.Position = UDim2.new(0.05, 0, 0.5, -35)
ptLabel.BackgroundTransparency = 1
ptLabel.Text = "PORTUGUÊS"
ptLabel.TextColor3 = Color3.fromRGB(245, 255, 248)
ptLabel.Font = Enum.Font.GothamBlack
ptLabel.TextSize = 32
ptLabel.Parent = ptHalfBtn

local esHalfBtn = Instance.new("TextButton")
esHalfBtn.Name = "SpanishHalf"
esHalfBtn.Size = UDim2.new(0.5, 0, 1, 0)
esHalfBtn.Position = UDim2.new(0.5, 0, 0, 0)
esHalfBtn.BackgroundColor3 = Color3.fromRGB(48, 22, 24)
esHalfBtn.BorderSizePixel = 0
esHalfBtn.Text = ""
esHalfBtn.Parent = fullBackdrop

local esLabel = Instance.new("TextLabel")
esLabel.Size = UDim2.new(0.9, 0, 0, 70)
esLabel.Position = UDim2.new(0.05, 0, 0.5, -35)
esLabel.BackgroundTransparency = 1
esLabel.Text = "ESPAÑOL"
esLabel.TextColor3 = Color3.fromRGB(255, 245, 246)
esLabel.Font = Enum.Font.GothamBlack
esLabel.TextSize = 32
esLabel.Parent = esHalfBtn

local dividerLine = Instance.new("Frame")
dividerLine.Size = UDim2.new(0, 3, 1, 0)
dividerLine.Position = UDim2.new(0.5, -1, 0, 0)
dividerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
dividerLine.BackgroundTransparency = 0.25
dividerLine.BorderSizePixel = 0
dividerLine.ZIndex = 5
dividerLine.Parent = fullBackdrop

local topCreditsFrame = Instance.new("Frame")
topCreditsFrame.Size = UDim2.new(0, 340, 0, 96)
topCreditsFrame.Position = UDim2.new(0.5, -170, 0, 28)
topCreditsFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
topCreditsFrame.BackgroundTransparency = 0.25
topCreditsFrame.BorderSizePixel = 0
topCreditsFrame.ZIndex = 10
topCreditsFrame.Parent = fullBackdrop

local topCreditsCorner = Instance.new("UICorner")
topCreditsCorner.CornerRadius = UDim.new(0, 10)
topCreditsCorner.Parent = topCreditsFrame

local topCreditsStroke = Instance.new("UIStroke")
topCreditsStroke.Color = Color3.fromRGB(90, 150, 255)
topCreditsStroke.Thickness = 1.5
topCreditsStroke.Parent = topCreditsFrame

local topCreditsLayout = Instance.new("UIListLayout")
topCreditsLayout.SortOrder = Enum.SortOrder.LayoutOrder
topCreditsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
topCreditsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
topCreditsLayout.Padding = UDim.new(0, 2)
topCreditsLayout.Parent = topCreditsFrame

local creditLines = {
	"made by:dusckprime",
	"moderator:shadowfitz",
	"shadowali.01"
}

for idx, lineText in ipairs(creditLines) do
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -12, 0, 26)
	lbl.BackgroundTransparency = 1
	lbl.Text = lineText
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextSize = 15
	lbl.LayoutOrder = idx
	lbl.ZIndex = 11
	lbl.Parent = topCreditsFrame
end

local function selectLanguage(langCode)
	currentLang = langCode
	if applyLanguageToPanel then
		applyLanguageToPanel()
	end
	screenGui.Enabled = true
	langGui:Destroy()
end

ptHalfBtn.MouseButton1Click:Connect(function()
	selectLanguage("pt")
end)

esHalfBtn.MouseButton1Click:Connect(function()
	selectLanguage("es")
end)
