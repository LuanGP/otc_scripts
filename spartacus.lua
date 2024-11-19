------------------------------------------------------ eventos
local proxEvento = UI.Label("Próximo evento:")
proxEvento:setColor("#e4ff00")

local nextEvent = UI.Label("Aguardando próximo evento")
nextEvent:setColor("#00fff0")

local eventos = {
	{ tipo = "Invasão de Bosses", horarios = {"10:00", "15:00", "17:00", "20:00", "03:00", "07:00", "12:00"} },
	{ tipo = "Invasão de EXP", horarios = {"13:40", "15:40", "19:40", "22:40", "02:40", "05:40", "08:40", "11:40"} },
	{ tipo = "ClickUP Event", horarios = {"18:30", "01:30"} }
}

local function atualizarEvento()
	local minutosAgora = (os.date("*t").hour * 60) + os.date("*t").min
	local proximoEvento = { tipo = "NIL", horario = "00:00", diferenca = 1440 }
	
	for _, evento in ipairs(eventos) do
		for _, horario in ipairs(evento.horarios) do
			local minutosEvento = (tonumber(horario:sub(1,2)) * 60) + tonumber(horario:sub(4,5))
			local diferenca = (minutosEvento - minutosAgora + 1440) % 1440
			if diferenca < proximoEvento.diferenca then
				proximoEvento = { tipo = evento.tipo, horario = horario, diferenca = diferenca }
			end
		end
	end
	
	nextEvent:setText(proximoEvento.tipo .. " às " .. proximoEvento.horario)
end

macro(1000, "", atualizarEvento)
atualizarEvento()

------------------------------------------------------ macro potions
local potions, lastUsedIndex = {6542, 6543, 6544, 6545}, 0
macro(2000, "Exp Potion COMBO", function()
	lastUsedIndex = (lastUsedIndex % #potions) + 1
	local pot = findItem(potions[lastUsedIndex])
	if pot then use(pot, player) delay(100) end
end)

UI.Separator()
------------------------------------------------------ contador dungeon
local contadorDungeon = UI.Label("0")
storage.tmpDungeon = storage.tmpDungeon or 0
local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end
macro(500, "", function()
	local remainingTime = storage.tmpDungeon - os.time()
	if remainingTime <= 0 then
		contadorDungeon:setText("PRONTO")
		contadorDungeon:setColor("green")
	else
		contadorDungeon:setText(formatTime(remainingTime))
		contadorDungeon:setColor("red")
	end
end)
local btnDungeon = UI.Button("Start Dungeon", function()
	storage.tmpDungeon = os.time() + (60*60)
end)
btnDungeon:setColor("#00f6ff")
local btnDungeonReset = UI.Button("Test Dungeon", function()
	storage.tmpDungeon = os.time() + 700
end)
------------------------------------------------------ contador BOSS
local contadorBoss = UI.Label("0")
storage.tmpBoss = storage.tmpBoss or 0
local function formatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end
macro(500, "", function()
	local remainingTime = storage.tmpBoss - os.time()
	if remainingTime <= 0 then
		contadorBoss:setText("PRONTO")
		contadorBoss:setColor("green")
	else
		contadorBoss:setText(formatTime(remainingTime))
		contadorBoss:setColor("red")
	end
end)
local btnBoss = UI.Button("Start Boss", function()
	storage.tmpBoss = os.time() + ((60*60)*5)
end)
btnBoss:setColor("#00f6ff")
----------------------------------------------------------------------------------------------------------------- AUTO INA
local txtAutoIna = addTextEdit("autoIna", storage.autoIna or "abadom", function(widget, text) 
	storage.autoIna = text
end)
txtAutoIna:setColor("#000000")
macro(30000, "Auto res ina", function()
	say('utevo res ina "'..storage.autoIna..'"')
end)
---------------MOVER ITEMS ------------------------------------------
storage.moveItems = storage.moveItems or {}
local itemsPadrao = {3043, 3031, 9058, 9642, 3233, 944, 943, 350, 6543, 6542, 6526, 11587, 2971, 8150, 11588, 3042, 6544, 9149, 6545, 11488}
if #storage.moveItems == 0 then
	for _, itemId in ipairs(itemsPadrao) do
		table.insert(storage.moveItems, {id = itemId}) -- Insere o item na tabela
	end
end
function table.contains(tbl, value)
	for _, v in ipairs(tbl) do
		if v == value then return true end
	end
	return false
end

local moveItemsContainer = UI.Container(function(_, items) storage.moveItems = items end, true)
moveItemsContainer:setHeight(70)
moveItemsContainer:setItems(storage.moveItems)

macro(300, "Mover Itens", function()
	local itemsToMovee = {}
	for index, value in pairs(storage.moveItems) do
		table.insert(itemsToMovee, value.id)
	end
	
	for _, container in pairs(g_game.getContainers()) do
		if string.lower(container:getName()) == "reward bag" then
			local containerWindow = container.window
			for _, item in ipairs(container:getItems()) do
				if table.contains(itemsToMovee, item:getId()) then
					containerWindow:setText("movendo")
					delay(100)
				end
			end
		end
	end
	delay(100)
	for _, container in pairs(g_game.getContainers()) do
		local containerWindow = container.window
		if string.lower(containerWindow:getText()) == "movendo" or string.lower(container:getName()) == "reward bag" then
			local movendo = false
			for _, item in ipairs(container:getItems()) do
				if table.contains(itemsToMovee, item:getId()) then
					g_game.move(item, {x = 65535, y = 64, z = 0}, item:getCount())
					movendo = true
					delay(100)
					break
				end
			end
			if movendo == false then
				containerWindow:setText("vazia")
				for _, item in ipairs(container:getItems()) do
					if item:getId() == 3504 then
						g_game.open(item, container)
						delay(100)
					end
				end
			end
		end
	end
	delay(100)
	for _, container in pairs(g_game.getContainers()) do
		if string.lower(container:getName()) == "vazia" then
			local containerWindow = container.window
			containerWindow:close()
		end
	end
end)

---------------------------------------------------------USAR ITEMS
macro(500, "Auto Use Items", function()
	local itemId = {11587, 3043, 3035, 9058}
	local targetCount = 100
	local containers = g_game.getContainers()
	
	function table.contains(table, value)
		for _, v in ipairs(table) do
			if v == value then
				return true
			end
		end
		return false
	end
	
	for _, container in pairs(containers) do
		for __, item in ipairs(container:getItems()) do
			if table.contains(itemId, item:getId()) and item:getCount() >= targetCount then
				g_game.use(item)
				return
			end
		end
	end
end)
---------------------------------------------------------USAR ALAVANCA
macro(500, "Auto alavanca", function()
	useGroundItem(2772)
end)
---------------------------------------------------------atacar menor HP
macro(100, "Ataca o Monstro com Menor HP", function()
	local battlelist = getSpectators()
	local target = nil
	local lowesthpc = 101
	
	for _, val in pairs(battlelist) do
		if val:isMonster() and val:getHealthPercent() < lowesthpc then
			lowesthpc = val:getHealthPercent()
			target = val
		end
	end
	
	if target and g_game.getAttackingCreature() ~= target then
		g_game.attack(target)
	end
end)
