-- This contains some "core" functions of Dyshexia
Dyshexia = {}

-- updateEntityHealth: Send the health update to heartbeat, and display damage indictator
function Dyshexia.updateEntityHealth(entity, damage)
	Heartbeat.updateEntityHealth(entity, entity.health + damage)
	print("Entity now has " .. damage)
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.print(damage, entity.x, entity.y)
	Animation.newAnimation(Dyshexia.drawDamage, 30, {entity, damage})
end

function Dyshexia.drawDamage(frame, data)
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.print(data[2], Camera.convert("x", data[1].x) + 10, Camera.convert("y", data[1].y) - frame)
end

