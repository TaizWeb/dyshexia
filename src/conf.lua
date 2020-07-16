function love.conf(t)
	-- These save resources by being disabled, changing them does nothing
	t.modules.physics = false
	t.modules.joystick = false
	-- Edit these to your preferred resolution
	t.window.width = 1366
	t.window.height = 768
end

