Chalice = {
	id = "chalice",
	name = "Pirate's Chalice",
	desc = "It's filled with...\nsomething sticky...",
	texture = love.graphics.newImage("assets/items/chalice.png"),
	width = 16,
	height = 16,
	scaleX = 1.5,
	scaleY = 1.5
}

function Chalice.onPickup(this)
	Heartbeat.player.addInventoryItem(this)
	Heartbeat.removeItem(this)
end
