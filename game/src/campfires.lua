local campfires = {}

local PROXIMITY = 40
local BASE_UNIT = 200
local START_X = 300

-- Fibonacci spacing: 1, 1, 2, 3, 5
local SPACING = {1, 1, 2, 3, 5}

local list = {}
local groundY = 0
local elapsed = 0

function campfires.load(playerGroundY)
	groundY = playerGroundY
	local x = START_X
	list = {}
	for i = 1, 5 do
		list[i] = { x = x, visited = false }
		if i < 5 then
			x = x + SPACING[i + 1] * BASE_UNIT
		end
	end
end

function campfires.reset()
	for _, cf in ipairs(list) do
		cf.visited = false
	end
	elapsed = 0
end

function campfires.update(dt)
	elapsed = elapsed + dt
end

function campfires.getList()
	return list
end

function campfires.checkProximity(playerX)
	for i, cf in ipairs(list) do
		if not cf.visited and math.abs(playerX - cf.x) < PROXIMITY then
			return i
		end
	end
	return nil
end

function campfires.markVisited(index)
	list[index].visited = true
end

local function drawFlame(sx, sy, dim, t)
	-- Logs
	love.graphics.setColor(0.35 * dim, 0.18 * dim, 0.08 * dim)
	love.graphics.polygon("fill", sx - 10, sy, sx - 2, sy - 4, sx + 6, sy)
	love.graphics.polygon("fill", sx - 6, sy, sx + 2, sy - 3, sx + 10, sy)

	-- Flame layers (animated)
	local flicker1 = math.sin(t * 6) * 2
	local flicker2 = math.cos(t * 8.5) * 1.5
	local flicker3 = math.sin(t * 11) * 1

	-- Outer glow
	love.graphics.setColor(1 * dim, 0.3 * dim, 0.05 * dim, 0.3 * dim)
	love.graphics.polygon("fill",
		sx - 8, sy,
		sx + flicker1, sy - 20 + flicker2,
		sx + 8, sy
	)

	-- Mid flame
	love.graphics.setColor(1 * dim, 0.5 * dim, 0.1 * dim, 0.7 * dim)
	love.graphics.polygon("fill",
		sx - 5, sy - 2,
		sx + flicker2, sy - 16 + flicker3,
		sx + 5, sy - 2
	)

	-- Inner flame
	love.graphics.setColor(1 * dim, 0.85 * dim, 0.3 * dim, 0.9 * dim)
	love.graphics.polygon("fill",
		sx - 3, sy - 3,
		sx + flicker3, sy - 10 + flicker1 * 0.5,
		sx + 3, sy - 3
	)

	-- Ember particles
	love.graphics.setColor(1 * dim, 0.6 * dim, 0.1 * dim, 0.6 * dim)
	for j = 1, 3 do
		local et = t * 3 + j * 2.1
		local ex = sx + math.sin(et * 1.7 + j) * 4
		local ey = sy - 8 - math.fmod(et * 5, 18)
		local ea = 1 - math.fmod(et * 5, 18) / 18
		love.graphics.setColor(1 * dim, 0.5 * dim, 0.1 * dim, ea * 0.5 * dim)
		love.graphics.circle("fill", ex, ey, 1)
	end
end

local function drawAshes(sx, sy, dim)
	-- Dead campfire: charred logs and ash
	love.graphics.setColor(0.15 * dim, 0.1 * dim, 0.08 * dim)
	love.graphics.polygon("fill", sx - 10, sy, sx - 2, sy - 3, sx + 6, sy)
	love.graphics.polygon("fill", sx - 6, sy, sx + 2, sy - 2, sx + 10, sy)

	-- Ash pile
	love.graphics.setColor(0.25 * dim, 0.2 * dim, 0.18 * dim)
	love.graphics.ellipse("fill", sx, sy - 2, 7, 3)
end

function campfires.draw(cameraX)
	local screenW = love.graphics.getWidth()

	for i, cf in ipairs(list) do
		local sx = cf.x - cameraX
		if sx > -30 and sx < screenW + 30 then
			local dim = 1.0 - (i - 1) * 0.18
			if cf.visited then
				drawAshes(sx, groundY, dim)
			else
				drawFlame(sx, groundY, dim, elapsed + i * 3.7)
			end
		end
	end
end

return campfires
