Coin = {
	id = "coin",
	texture = love.graphics.newImage("assets/items/coin.png"),
	width = 14,
	height = 16,
	scaleX = 1.5,
	scaleY = 1.5
}

function Coin.onPickup(this)
	Player.money = Player.money + math.ceil(math.random() * 100)
	Heartbeat.removeItem(this)
end

