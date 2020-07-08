Level = {
	minWidth = 5,
	maxWidth = 15,
	minHeight = 5,
	maxHeight = 15
}

-- generateRoom: Generates a single square room
-- Parameters: x/y for room location (optional), width/height for custom dimensions (optional)
function Level.generateRoom(x, y, width, height)
	-- TODO: Possibly refactor this later to just use the parameters instead of assigning new variables
	math.randomseed(os.time())
	local startX
	local startY
	local roomWidth
	local roomHeight

	-- Variable checking, if left unassigned set them to default values
	if (x == nil or y == nil) then
		startX = math.floor(((math.random() * Heartbeat.levelWidth) / 25)) * 25
		startY = math.floor(((math.random() * Heartbeat.levelHeight) / 25)) * 25
	else
		startX = x
		startY = y
	end
	if (width == nil or height == nil) then
		roomWidth = math.random(maxWidth - minWidth) + minWidth
		roomHeight = math.random(maxHeight - minHeight) + minHeight
	else
		roomWidth = width
		roomHeight = height
	end

	-- Put the player right in the upper corner of the dungeon to check the structure
	Heartbeat.player.x = startX - 25
	Heartbeat.player.y = startY - 25

	-- Later do a thing where it compares against the end of the screen and makes it snug
	-- Perhaps adjust width/height directly?
	-- Make sure the room doesn't go out of the level bounds
	--if ((endX - (roomWidth * 25) <= 0) or (endY - (roomHeight * 25) <= 0)) then
		--print("I happend")
		--Level.generateRoom(width, height)
		--return
	--end

	-- Making the room (square)
	local generateOnce = false
	for j=1,roomHeight do
		for i=1,roomWidth do
			-- Generate the tunnels. There's a cleaner way of doing this but fuck it
			if (i == 1 and math.random(1) == 1 and not generateOnce) then
				Level.generateTunnel(startX, startY, "left")
				generateOnce = true
			end
			--if (i == roomWidth and math.random(15) == 1) then
				--Level.generateTunnel(startX, startY, "right")
			--end
			--if (j == 1 and math.random(15) == 1) then
				--Level.generateTunnel(startX, startY, "up")
			--end
			--if (j == roomHeight and math.random(15) == 1) then
				--Level.generateTunnel(startX, startY, "down")
			--end

			-- Check whether or not to use wall or ground
			if (i == 1 or i == roomWidth or j == 1 or j == roomHeight) then
				Heartbeat.newTile(Wall, startX, startY)
			else
				Heartbeat.newTile(Ground, startX, startY)
			end
			startX = startX + 25
		end
		startX = startX - (25 * roomWidth)
		startY = startY + 25
	end
end

-- generateTunnel: Generates a tunnel given location and which wall it's on
-- Parameters: x/y for location, direction for which wall it's extending from
function Level.generateTunnel(x, y, direction)
	local tunnelLength = math.random(7) + 3
	local roomWidth = math.random(maxWidth - minWidth) + minWidth
	local roomHeight = math.random(maxHeight - minHeight) + minHeight
	--startX = math.floor(((math.random() * Heartbeat.levelWidth) / 25)) * 25
	--startY = math.floor(((math.random() * Heartbeat.levelHeight) / 25)) * 25
	-- Place tunnels are proper locations for the four cardinal directions
	-- There's probably a cleaner way of doing this as well
	if (direction == "up") then
		for i=1,tunnelLength do
			y = y - 25
			Heartbeat.newTile(Wall, x - 25, y)
			Heartbeat.newTile(Wall, x, y)
			Heartbeat.newTile(Wall, x + 25, y)
		end
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
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x, y + 25)
		end
	elseif (direction == "right") then
		for i=1,tunnelLength do
			x = x + 25
			Heartbeat.newTile(Wall, x, y - 25)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x, y + 25)
		end
	end
end

