local player = {}

local SPEED_RIGHT = 100
local SPEED_LEFT = 50
local WIDTH = 16
local HEIGHT = 32

player.x = 0
player.y = 0
player.width = WIDTH
player.height = HEIGHT

local walkTimer = 0

function player.load()
	local screenH = love.graphics.getHeight()
	player.y = screenH - HEIGHT - 40
end

function player.reset()
	player.x = 0
	walkTimer = 0
end

function player.update(dt)
	if love.keyboard.isDown("right", "d") then
		player.x = player.x + SPEED_RIGHT * dt
		walkTimer = walkTimer + dt * 8
	elseif love.keyboard.isDown("left", "a") then
		player.x = player.x - SPEED_LEFT * dt
		walkTimer = walkTimer + dt * 5
	else
		walkTimer = 0
	end
end

function player.draw(cameraX)
	local sx = player.x - cameraX
	local sy = player.y
	local bob = math.sin(walkTimer) * 1.5

	-- Head
	love.graphics.setColor(0.85, 0.8, 0.7)
	love.graphics.circle("fill", sx + WIDTH / 2, sy + 5 + bob, 5)

	-- Body
	love.graphics.setColor(0.6, 0.55, 0.5)
	love.graphics.setLineWidth(2)
	love.graphics.line(sx + WIDTH / 2, sy + 10 + bob, sx + WIDTH / 2, sy + 22 + bob)

	-- Arms
	local armSwing = math.sin(walkTimer) * 3
	love.graphics.line(sx + WIDTH / 2, sy + 14 + bob, sx + WIDTH / 2 - 5, sy + 19 + bob + armSwing)
	love.graphics.line(sx + WIDTH / 2, sy + 14 + bob, sx + WIDTH / 2 + 5, sy + 19 + bob - armSwing)

	-- Legs
	local legSwing = math.sin(walkTimer) * 4
	love.graphics.line(sx + WIDTH / 2, sy + 22 + bob, sx + WIDTH / 2 - 4, sy + HEIGHT + legSwing)
	love.graphics.line(sx + WIDTH / 2, sy + 22 + bob, sx + WIDTH / 2 + 4, sy + HEIGHT - legSwing)

	love.graphics.setLineWidth(1)
end

return player
