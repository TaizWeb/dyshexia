HealthPotion = {
	id = "health_potion",
	name = "Health Potion",
	texture = love.graphics.newImage("assets/items/health_potion.png"),
	width = 14,
	height = 16,
	scaleX = 1.5,
	scaleY = 1.5
}

function HealthPotion.onPickup(this)
	Heartbeat.player.addInventoryItem(this)
	Heartbeat.removeItem(this)
end

function HealthPotion.onUse()
	print("Tastes like kool aid")
end

