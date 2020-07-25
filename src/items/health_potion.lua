HealthPotion = {
	id = "health_potion",
	name = "Health Potion",
	desc = "Tastes like kool-aid!",
	texture = love.graphics.newImage("assets/items/health_potion.png"),
	width = 14,
	height = 16,
	scaleX = 1.5,
	scaleY = 1.5
}

function HealthPotion.onPickup(this)
	-- The reason these lines need to be specified is because coins
	-- don't actually get put into the inventory. Neither does the
	-- ladder, which is a (technically) an item.
	Heartbeat.player.addInventoryItem(this)
	Heartbeat.removeItem(this)
end

function HealthPotion.onUse()
	-- This is a bit fucky since Heartbeat handles the player's health, while the Player object stores the maxHealth variable
	if ((Heartbeat.player.health + 50) > Player.maxHealth) then
		Heartbeat.player.health = Player.maxHealth
	else
		Heartbeat.player.health = Heartbeat.player.health + 50
	end
end

