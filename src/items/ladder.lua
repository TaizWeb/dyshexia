Ladder = {
	id = "ladder",
	texture = love.graphics.newImage("assets/tiles/ladder.png"),
	width = 16,
	height = 16,
	scaleX = 25/16,
	scaleY = 25/16
}

function Ladder.onPickup(this)
	Heartbeat.player.health = 50
	Heartbeat.clear()
	Player.currentLevel = Player.currentLevel + 1
	Heartbeat.editor.readLevel("level" .. Player.currentLevel)
	-- I'm hardcoding shit because levelgen isn't a thing yet
	if (Player.currentLevel == 2) then
		Heartbeat.player.x = 750
		Heartbeat.player.y = 325
	elseif (Player.currentLevel == 3) then
		Heartbeat.player.x = 1925
		Heartbeat.player.y = 275 
	elseif (Player.currentLevel == 4) then
		Heartbeat.player.x = 1850
		Heartbeat.player.y = 150
	elseif (Player.currentLevel == 5) then
		Heartbeat.player.x = 0
		Heartbeat.player.y = 0
	end
end

