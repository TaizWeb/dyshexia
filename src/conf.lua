function love.conf(t)
	-- These save resources by being disabled, changing them does nothing
	t.modules.physics = false
	t.modules.joystick = false
	-- Edit these to your preferred resolution
	t.window.width = 800--1366
	t.window.height = 600--768
	-- Keybinds
	Keybinds = {
		pause = "return",
		action = "z",
		back = "x",
		up = "k",
		down = "j",
		left = "h",
		right = "l",
	}
end

