local itemIdsToUse, useRange, moveRange = {8997, 3043}, 1, 7
local function findItemsInLayer(layerIndex)
	local searchLayers = {
		{from = {x = posx() - 1, y = posy() - 1, z = posz()}, to = {x = posx() + 1, y = posy() + 1, z = posz()}},
		{from = {x = posx() - 2, y = posy() - 2, z = posz()}, to = {x = posx() + 2, y = posy() + 2, z = posz()}},
		{from = {x = posx() - 3, y = posy() - 3, z = posz()}, to = {x = posx() + 3, y = posy() + 3, z = posz()}},
		{from = {x = posx() - 4, y = posy() - 4, z = posz()}, to = {x = posx() + 4, y = posy() + 4, z = posz()}},
		{from = {x = posx() - 5, y = posy() - 5, z = posz()}, to = {x = posx() + 5, y = posy() + 5, z = posz()}},
		{from = {x = posx() - 6, y = posy() - 6, z = posz()}, to = {x = posx() + 6, y = posy() + 6, z = posz()}},
		{from = {x = posx() - 7, y = posy() - 7, z = posz()}, to = {x = posx() + 7, y = posy() + 7, z = posz()}}
	}
	if layerIndex > #searchLayers then return false end
	local currentLayer = searchLayers[layerIndex]
	for x = currentLayer.from.x, currentLayer.to.x do
		for y = currentLayer.from.y, currentLayer.to.y do
			local tile = g_map.getTile({x = x, y = y, z = posz()})
			if tile then
				for _, item in ipairs(tile:getItems()) do
					if item and table.contains(itemIdsToUse, item:getId()) then
						if CaveBot.isOn() then CaveBot.setOff() print("desativando cavebot") end
						local distance = getDistanceBetween(pos(), tile:getPosition())
						if distance <= useRange then
							g_game.use(item)
							return true
						elseif distance > useRange and distance <= moveRange then
							if autoWalk(tile:getPosition(), moveRange, {ignoreNonPathable = true, precision = 1}) then
								delay(200)
								return true
							end
						end
					end
				end
			end
		end
	end
	return findItemsInLayer(layerIndex + 1)
end

macro(200, "click UP", function()
	if not findItemsInLayer(1) then
		if CaveBot.isOff() then
			print("ativando cavebot")
			CaveBot.setOn()
		end
	end
end)
