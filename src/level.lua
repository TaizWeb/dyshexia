Level = {}
function Level.generateRoom(width, height)
	math.randomseed(os.time())
	Heartbeat.setDimensions(width, height)
	local endY = math.floor(((math.random() * height) / 25)) * 25
	local endX = math.floor(((math.random() * width) / 25)) * 25
	print("endX: " .. endX)
	print("endY: " .. endY)
	local roomWidth = math.random(10) + 5
	local roomHeight = math.random(10) + 5
	-- Make sure the room doesn't go out of the level bounds
	--if ((endX - (roomWidth * 25) <= 0) or (endY - (roomHeight * 25) <= 0)) then
		--print("I happend")
		--Level.generateRoom(width, height)
		--return
	--end

	-- Making the rooms (square)
	for j=1,roomHeight do
		for i=1,roomWidth do
			-- Generate the tunnels. There's a cleaner way of doing this but fuck it
			if (i == 1 and math.random(15) == 1) then
				Level.generateTunnel(endX, endY, "left")
			end
			if (i == roomWidth and math.random(15) == 1) then
				Level.generateTunnel(endX, endY, "right")
			end
			if (j == 1 and math.random(15) == 1) then
				Level.generateTunnel(endX, endY, "up")
			end
			if (j == roomHeight and math.random(15) == 1) then
				Level.generateTunnel(endX, endY, "down")
			end

			if (i == 1 or i == roomWidth or j == 1 or j == roomHeight) then
				Heartbeat.newTile(Wall, endX, endY)
			else
				Heartbeat.newTile(Ground, endX, endY)
			end
			endX = endX - 25
		end
		endX = endX + (25 * roomWidth)
		endY = endY - 25
	end
	--Level.generateTunnel(endX, endY + (25 * roomHeight), roomWidth, roomHeight)
end

function Level.generateTunnel(x, y, direction)
	--tunnelLocation = math.ceil(math.random() * 4)
	--tunnelLocation = 1
	local tunnelLength = math.random(7) + 3
	if (direction == "up") then
		for i=1,tunnelLength do
			y = y - 25
			Heartbeat.newTile(Wall, x - 25, y)
			Heartbeat.newTile(Wall, x, y)
			Heartbeat.newTile(Wall, x + 25, y)
		end
		--tunnelOffset = math.ceil(math.random(roomWidth))
		--tunnelStart = Heartbeat.getTile(x - (25 * tunnelOffset), y - (25 * (roomHeight-1)))
		--print(tunnelStart == nil)
		--print(tunnelStart.x)
		--Heartbeat.removeTile(tunnelStart)
		--print("Removing tile at " .. (x - (25 * tunnelOffset)) .. ", " .. y - (25 * (roomHeight-1)))
	elseif (direction == "down") then
		for i=1,tunnelLength do
			y = y + 25
			Heartbeat.newTile(Wall, x - 25, y)
			Heartbeat.newTile(Wall, x, y)
			Heartbeat.newTile(Wall, x + 25, y)
		end
	elseif (direction == "left") then
		for i=1,tunnelLength do
			x = x - 25
			Heartbeat.newTile(Wall, x, y - 25)
			Heartbeat.newTile(Wall, x, y)
			Heartbeat.newTile(Wall, x, y + 25)
		end
	elseif (direction == "right") then
		for i=1,tunnelLength do
			x = x + 25
			Heartbeat.newTile(Wall, x, y - 25)
			Heartbeat.newTile(Wall, x, y)
			Heartbeat.newTile(Wall, x, y + 25)
		end
	end
end

