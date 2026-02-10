local environment = {}

local groundY = 0
local screenW = 0
local worldEnd = 0

-- Dust particles
local dust = {}
local DUST_COUNT = 50

-- Stars
local stars = {}
local STAR_COUNT = 100

-- Ground cracks
local cracks = {}

function environment.load(playerGroundY)
	groundY = playerGroundY
	screenW = love.graphics.getWidth()
	worldEnd = screenW * 13

	environment.reset()
end

function environment.reset()
	-- Generate dust pool
	dust = {}
	for i = 1, DUST_COUNT do
		dust[i] = {
			x = math.random() * worldEnd,
			y = math.random() * groundY,
			speed = 8 + math.random() * 12,
			size = 1 + math.random() * 1.5,
			alpha = 0.1 + math.random() * 0.15,
			drift = math.random() * math.pi * 2,
		}
	end

	-- Generate stars
	stars = {}
	local skyLimit = groundY * 0.6
	for i = 1, STAR_COUNT do
		stars[i] = {
			x = math.random() * worldEnd,
			y = math.random() * skyLimit,
			brightness = 0.3 + math.random() * 0.7,
			twinkleSpeed = 1.5 + math.random() * 3,
			twinklePhase = math.random() * math.pi * 2,
			size = 0.5 + math.random() * 1,
		}
	end

	-- Generate ground cracks
	cracks = {}
	local crackX = worldEnd * 0.3
	while crackX < worldEnd do
		local t = crackX / worldEnd
		-- More cracks toward center
		local gap = 80 - 60 * t
		local segCount = 2 + math.floor(math.random() * 3)
		local segs = {}
		local cx, cy = crackX + (math.random() - 0.5) * gap * 0.4, groundY
		for s = 1, segCount do
			local nx = cx + 4 + math.random() * 12
			local ny = groundY + (math.random() - 0.5) * 6
			segs[s] = {x1 = cx, y1 = cy, x2 = nx, y2 = ny}
			cx, cy = nx, ny
		end
		cracks[#cracks + 1] = {
			x = crackX,
			segments = segs,
			t = t,
		}
		crackX = crackX + gap + math.random() * gap * 0.5
	end
end

function environment.update(dt, cameraX, progress)
	local speedMul = 1 + progress * 2

	for _, d in ipairs(dust) do
		d.drift = d.drift + dt * 0.7
		d.x = d.x + d.speed * speedMul * dt
		d.y = d.y + math.sin(d.drift) * 8 * dt

		-- Recycle when offscreen right of camera view
		if d.x > cameraX + screenW + 20 then
			d.x = cameraX - 20 - math.random() * 40
			d.y = math.random() * groundY
		-- Also recycle if way behind camera
		elseif d.x < cameraX - 60 then
			d.x = cameraX + screenW + math.random() * 40
			d.y = math.random() * groundY
		end
	end
end

function environment.drawSky(cameraX, progress, time)
	local sw = screenW

	-- Stars (fade with progress)
	local starAlpha = 1 - progress
	if starAlpha > 0 then
		for _, s in ipairs(stars) do
			local sx = s.x - cameraX
			if sx > -2 and sx < sw + 2 then
				local twinkle = 0.7 + 0.3 * math.sin(time * s.twinkleSpeed + s.twinklePhase)
				local a = s.brightness * twinkle * starAlpha
				love.graphics.setColor(0.9, 0.85, 0.8, a)
				love.graphics.circle("fill", sx, s.y, s.size)
			end
		end
	end

	-- Dust particles
	local dustAlpha = 0.5 + progress * 0.5
	for _, d in ipairs(dust) do
		local sx = d.x - cameraX
		if sx > -5 and sx < sw + 5 then
			love.graphics.setColor(0.6, 0.55, 0.45, d.alpha * dustAlpha)
			love.graphics.circle("fill", sx, d.y, d.size)
		end
	end
end

function environment.drawGround(cameraX, progress)
	local sw = screenW

	-- Ground cracks (alpha ramps with progress)
	if progress > 0.1 then
		for _, c in ipairs(cracks) do
			local cx = c.x - cameraX
			if cx > -40 and cx < sw + 40 then
				local a = 0.15 + 0.45 * progress * c.t
				love.graphics.setColor(0.12, 0.08, 0.05, a)
				love.graphics.setLineWidth(1)
				for _, seg in ipairs(c.segments) do
					love.graphics.line(
						seg.x1 - cameraX, seg.y1,
						seg.x2 - cameraX, seg.y2
					)
				end
			end
		end
	end
end

function environment.drawCampfireGlow(cameraX, campfireList)
	local sw = screenW

	for i, cf in ipairs(campfireList) do
		if not cf.visited then
			local sx = cf.x - cameraX
			if sx > -100 and sx < sw + 100 then
				local dim = 1.0 - (i - 1) * 0.18
				-- Concentric ellipses for soft glow
				local layers = {
					{rx = 70, ry = 12, a = 0.06},
					{rx = 50, ry = 9, a = 0.10},
					{rx = 30, ry = 6, a = 0.15},
				}
				for _, l in ipairs(layers) do
					love.graphics.setColor(1, 0.6, 0.15, l.a * dim)
					love.graphics.ellipse("fill", sx, groundY + 2, l.rx, l.ry)
				end
			end
		end
	end
end

return environment
