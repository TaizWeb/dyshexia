-- TODO: Add tunnel length to Level config and set tilesets/enemytypes/loottables for each "dungeon"
Level = {
	-- Individual room min/max dimensions
	minWidth = 5,
	maxWidth = 15,
	minHeight = 5,
	maxHeight = 15,
	-- Max rooms in a dungeon
	maxRooms = 15,
	-- How often tunnels appear, default 15 (1/15 per tile in room)
	tunnelRarity = 10,
	-- Internal value of level generator, don't touch
	roomCount = 0,
	-- Indexing the rooms. Used for item placement and conflict checking
	-- The format is x, y, width, height
	rooms = {}
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
		startX = math.floor(((Heartbeat.levelWidth/2) / 25)) * 25
		startY = math.floor(((Heartbeat.levelHeight/2) / 25)) * 25
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

	if (not Level.checkValidity(startX, startY, roomWidth * 25, roomHeight * 25) or not Level.checkRoomConflict(startX, startY, roomWidth * 25, roomHeight * 25)) then
		print("BAD ROOM")
		print("Room at " .. startX .. " " .. startY .. " with dimensions " .. roomWidth * 25 .. " " .. roomHeight * 25)
		return
		--Level.generateRoom()
	end

	-- Index the rooms for later usage
	Level.rooms[#Level.rooms+1] = {
		x = startX,
		y = startY,
		width = roomWidth * 25,
		height = roomHeight * 25
	}


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
	for j=1,roomHeight do
		for i=1,roomWidth do

			-- Check whether or not to use wall or ground
			if (i == 1 or i == roomWidth or j == 1 or j == roomHeight) then
				Heartbeat.newTile(Wall, startX, startY)
			else
				Heartbeat.newTile(Ground, startX, startY)
			end

			-- Generate the tunnels. There's a cleaner way of doing this but fuck it
			if (i == 1 and j ~= 1 and j~= roomHeight and math.random(Level.tunnelRarity) == 1) then
				Level.generateTunnel(startX, startY, "left")
			end
			if (i == roomWidth and j ~= 1 and j~= roomHeight and math.random(Level.tunnelRarity) == 1) then
				Level.generateTunnel(startX, startY, "right")
			end
			if (j == 1 and i ~= 1 and i ~= roomWidth and math.random(Level.tunnelRarity) == 1) then
				Level.generateTunnel(startX, startY, "up")
			end
			if (j == roomHeight and i ~= 1 and i ~= roomWidth and math.random(Level.tunnelRarity) == 1) then
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
	-- These are for the removeTile line at the bottom, since x/y are edited directly in the loops
	local initialX = x
	local initialY = y

	-- Increment the room count
	if (Level.roomCount >= Level.maxRooms) then
		return 0
	end
	Level.roomCount = Level.roomCount + 1

	-- Calculate both tunnel length and dimensions
	local tunnelLength = math.random(7) + 3
	local roomWidth = math.random(Level.maxWidth - Level.minWidth) + Level.minWidth
	local roomHeight = math.random(Level.maxHeight - Level.minHeight) + Level.minHeight

	-- Place tunnels are proper locations for the four cardinal directions
	-- There's probably a cleaner way of doing this as well
	if (direction == "up") then
		if (not Level.checkValidity(x - 25, y - (25 * tunnelLength+1), 75, tunnelLength * 25) and not Level.checkRoomConflict(x - 25, y - (25 * tunnelLength+1), 75, tunnelLength * 25)) then
			print("Bad Up")
			return
		end

		for i=1,tunnelLength do
			y = y - 25
			Heartbeat.newTile(Wall, x - 25, y)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x + 25, y)
		end

		Level.generateRoom(x - (math.random(roomWidth-2) * 25), y - (roomHeight * 25), roomWidth, roomHeight)
		Heartbeat.removeTile(nil, x, y - 25)
		Heartbeat.newTile(Ground, x, y - 25)
		if (Heartbeat.getTile(x, y - 50) == nil) then
			Heartbeat.removeTile(nil, x, y - 25)
			Heartbeat.removeTile(nil, x, y)
			Heartbeat.newTile(Wall, x, y)
		end
	elseif (direction == "down") then
		if (not Level.checkValidity(x - 25, y + (25 * tunnelLength), 75, tunnelLength * 25) and not Level.checkRoomConflict(x - 25, y + (25 * tunnelLength), 75, tunnelLength * 25)) then
			print("BAd down")
			return
		end

		for i=1,tunnelLength do
			y = y + 25
			Heartbeat.newTile(Wall, x - 25, y)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x + 25, y)
		end
		Level.generateRoom(x - (math.random(roomWidth-2) * 25), y, roomWidth, roomHeight)
		if (Heartbeat.getTile(x, y + 50) == nil) then
			Heartbeat.removeTile(nil, x, y + 25)
			Heartbeat.removeTile(nil, x, y)
			Heartbeat.newTile(Wall, x, y)
		end
	elseif (direction == "left") then
		-- Validity check
		if (not Level.checkValidity(x - (25 * tunnelLength), y - 25, tunnelLength * 25, 75) and not Level.checkRoomConflict(x - (25 * tunnelLength), y - 25, tunnelLength * 25, 75)) then
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
		if (Heartbeat.getTile(x - 50, y) == nil) then
			Heartbeat.removeTile(nil, x - 25, y)
			Heartbeat.removeTile(nil, x, y)
			Heartbeat.newTile(Wall, x, y)
		end
	elseif (direction == "right") then
		if (not Level.checkValidity(x + (25 * tunnelLength), y - 25, tunnelLength * 25, 75) and not Level.checkRoomConflict(x + (25 * tunnelLength), y - 25, tunnelLength * 25, 75)) then
			print("BAD FIT")
			return
		end

		for i=1,tunnelLength do
			x = x + 25
			Heartbeat.newTile(Wall, x, y - 25)
			Heartbeat.newTile(Ground, x, y)
			Heartbeat.newTile(Wall, x, y + 25)
		end

		Level.generateRoom(x, y - (math.random(roomHeight-2) * 25), roomWidth, roomHeight)
		if (Heartbeat.getTile(x + 50, y) == nil) then
			Heartbeat.removeTile(nil, x + 25, y)
			Heartbeat.removeTile(nil, x, y)
			Heartbeat.newTile(Wall, x, y)
		end
	end

	-- Remove the old wall tile and make it a floor
	Heartbeat.removeTile(nil, initialX, initialY)
	Heartbeat.newTile(Ground, initialX, initialY)
end

-- checkValidity: Returns true if a given structure isn't conflicting with already placed tiles
function Level.checkValidity(x, y, width, height)
	width = width + x
	height = height + y
	--for i=x,width do
		--for j=y,height do
			--if (Heartbeat.getTile(i, j) ~= nil) then
				--return false
			--end
			--j = j + 25
		--end
		--i = i + 25
	--end
	if (Heartbeat.getTile(x, y) ~= nil or
		Heartbeat.getTile(width, height) ~= nil or
		Heartbeat.getTile(x, height) ~= nil or
		Heartbeat.getTile(width, y) ~= nil) then
		return false
	else
		return true
	end
end

function Level.checkRoomConflict(x, y, width, height)
	-- This is a base case in the event there's only one room
	if (#Level.rooms <= 1) then
		return true
	end

	local room1 = {
		x = x,
		y = y,
		width = width,
		height = height
	}
	for i=1,#Level.rooms do
		local room2 = {
			x = Level.rooms[i].x,
			y = Level.rooms[i].y,
			width = Level.rooms[i].width,
			height = Level.rooms[i].height
		}
		-- I'm being a sh*tbag here using the entity function
		if (Heartbeat.checkEntityCollision(room1, room2)) then
			print("We got a conflict!")
			return false
		end
	end

	return true
end

