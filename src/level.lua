-- TODO: Add tunnel length to Level config and set tilesets/enemytypes/loottables for each "dungeon"
Level = {
	-- Individual room min/max dimensions
	minWidth = 5,
	maxWidth = 15,
	minHeight = 5,
	maxHeight = 15,
	-- Max rooms in a dungeon
	maxRooms = 10,
	-- Internal value of level generator, don't touch
	roomCount = 0
}
-- TODO: Add a tunnel length min/max
math.randomseed(os.time())

-- generateRoom: Generates a single square room
-- Parameters: x/y for room location (optional), width/height for custom dimensions (in terms of tiles, so 100 pixels should be 4) (optional)
function Level.generateRoom(x, y, width, height)
	-- Break out of generation if roomCount exceeds maxRooms

	-- TODO: Possibly refactor this later to just use the parameters instead of assigning new variables
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
		-- TODO: Implement DRY on this? Make a function to return these dimensions? It's repeated once though.
		roomWidth = math.random(Level.maxWidth - Level.minWidth) + Level.minWidth
		roomHeight = math.random(Level.maxHeight - Level.minHeight) + Level.minHeight
	else
		roomWidth = width
		roomHeight = height
	end

	-- Put the player right in the upper corner of the dungeon to check the structure
	Heartbeat.player.x = startX - 25
	Heartbeat.player.y = startY - 25
	print(Heartbeat.player.x .. " " .. Heartbeat.player.y)

	-- Later do a thing where it compares against the end of the screen and makes it snug
	-- Perhaps adjust width/height directly?
	-- Make sure the room doesn't go out of the level bounds
	--if ((endX - (roomWidth * 25) <= 0) or (endY - (roomHeight * 25) <= 0)) then
		--print("I happend")
		--Level.generateRoom(width, height)
		--return
	--end

	-- Making the room (square)
	for j=1,roomHeight do
		for i=1,roomWidth do

			-- Check whether or not to use wall or ground
			if (i == 1 or i == roomWidth or j == 1 or j == roomHeight) then
				Heartbeat.newTile(Wall, startX, startY)
			else
				Heartbeat.newTile(Ground, startX, startY)
			end

			-- Generate the tunnels. There's a cleaner way of doing this but fuck it
			--if (i == 1 and j ~= 1 and j~= roomHeight and math.random(1) == 1) then
				--Level.generateTunnel(startX, startY, "left")
			--end
			--if (i == roomWidth and j ~= 1 and j~= roomHeight and math.random(1) == 1) then
				--print("Generating a tunnel on the right...")
				--Level.generateTunnel(startX, startY, "right")
			--end
			--if (j == 1 and i ~= 1 and i ~= roomWidth and math.random(1) == 1) then
				--print("UP TUNNEL")
				--Level.generateTunnel(startX, startY, "up")
			--end
			if (j == roomHeight and i ~= 1 and i ~= roomWidth and math.random(15) == 1) then
				Level.generateTunnel(startX, startY, "down")
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
	if (Level.roomCount >= Level.maxRooms) then
		return 0
	end
	Level.roomCount = Level.roomCount + 1

	local tunnelLength = math.random(7) + 3
	local roomWidth = math.random(Level.maxWidth - Level.minWidth) + Level.minWidth
	local roomHeight = math.random(Level.maxHeight - Level.minHeight) + Level.minHeight
	-- Place tunnels are proper locations for the four cardinal directions
	-- There's probably a cleaner way of doing this as well
	Heartbeat.removeTile(nil, x, y)
	Heartbeat.newTile(Ground, x, y)
	if (direction == "up") then
		for i=1,tunnelLength do
			y = y - 25
			Heartbeat.newTile(Wall, x - 25, y)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x + 25, y)
		end
		Level.generateRoom(x - (math.random(roomWidth-2) * 25), y - (roomHeight * 25), roomWidth, roomHeight)
		Heartbeat.removeTile(nil, x, y - 25)
		Heartbeat.newTile(Ground, x, y - 25)
	elseif (direction == "down") then
		for i=1,tunnelLength do
			y = y + 25
			Heartbeat.newTile(Wall, x - 25, y)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x + 25, y)
		end
		Level.generateRoom(x - (math.random(roomWidth-2) * 25), y, roomWidth, roomHeight)
	elseif (direction == "left") then
		-- Validity check
		if (not Level.checkValidity(x - (25 * tunnelLength), y - 25, tunnelLength * 25, 75)) then
			print("BAD FIT")
			return
		end

		-- Generate the tunnel
		for i=1,tunnelLength do
			x = x - 25
			Heartbeat.newTile(Wall, x, y - 25)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x, y + 25)
		end

		-- Make a new room
		Level.generateRoom(x - (25 * roomWidth), y - (math.random(roomHeight-2) * 25), roomWidth, roomHeight)
		-- Swap out the wall for ground
		Heartbeat.removeTile(nil, x - 25, y)
		Heartbeat.newTile(Ground, x - 25, y)
	elseif (direction == "right") then
		if (not Level.checkValidity(x + (25 * tunnelLength), y - 25, tunnelLength * 25, 75)) then
			print("BAD FIT")
			return
		end

		for i=1,tunnelLength do
			x = x + 25
			Heartbeat.newTile(Wall, x, y - 25)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x, y + 25)
		end

		print("MAking new room at " .. x + (25 * roomWidth) .. " " .. y - (math.random(roomHeight-2) * 25))
		Level.generateRoom(x, y - (math.random(roomHeight-2) * 25), roomWidth, roomHeight)
	end
end

-- checkValidity: Returns true if a given structure isn't conflicting with already placed tiles
function Level.checkValidity(x, y, width, height)
	for i=x,width do
		for j=y,height do
			if (Heartbeat.getTile(i, j) ~= nil) then
				return false
			end
			j = j + 25
		end
		i = i + 25
	end
	return true
end

