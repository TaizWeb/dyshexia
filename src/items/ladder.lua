Ladder = {
	id = "ladder",
	texture = love.graphics.newImage("assets/tiles/ladder.png"),
	width = 16,
	height = 16,
	scaleX = 25/16,
	scaleY = 25/16
}

function Ladder.onPickup(this)
	-- Clear all items/entities/tiles
	Heartbeat.clear()
	-- Reset stuff like Level.roomCount
	Level.clear()
	-- Create a new level and increment depth count
	Level.generateLevel()
	Player.currentLevel = Player.currentLevel + 1
end

