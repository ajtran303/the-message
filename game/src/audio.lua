local audio = {}

local SAMPLE_RATE = 44100

local heartbeatSource = nil
local geigerSource = nil
local footstepSource = nil
local clickSource = nil

local function makeSoundData(duration, generator)
	local samples = math.floor(SAMPLE_RATE * duration)
	local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)
	for i = 0, samples - 1 do
		local t = i / SAMPLE_RATE
		data:setSample(i, generator(t, duration))
	end
	return data
end

local function generateHeartbeat()
	-- Two-thump heartbeat pattern, loopable ~1.1 sec
	local duration = 1.1
	return makeSoundData(duration, function(t)
		-- First thump at t=0, second at t=0.18
		local s = 0
		for _, offset in ipairs({0.0, 0.18}) do
			local dt = t - offset
			if dt >= 0 and dt < 0.12 then
				local env = math.sin(dt / 0.12 * math.pi)
				env = env * env
				s = s + math.sin(dt * math.pi * 2 * 45) * env * 0.6
				s = s + math.sin(dt * math.pi * 2 * 30) * env * 0.3
			end
		end
		return math.max(-1, math.min(1, s))
	end)
end

local function generateGeiger()
	-- Random clicks over ~3 seconds, loopable
	local duration = 3.0
	local samples = math.floor(SAMPLE_RATE * duration)
	local data = love.sound.newSoundData(samples, SAMPLE_RATE, 16, 1)

	-- Pre-generate click positions
	math.randomseed(42)
	local clicks = {}
	local pos = 0
	while pos < samples do
		clicks[#clicks + 1] = pos
		-- Random gap: 400-4000 samples (irregular rhythm)
		pos = pos + math.random(400, 4000)
	end

	for i = 0, samples - 1 do
		local s = 0
		for _, clickPos in ipairs(clicks) do
			local d = i - clickPos
			if d >= 0 and d < 120 then
				local env = 1 - d / 120
				env = env * env
				s = s + (math.random() * 2 - 1) * env * 0.4
			end
		end
		data:setSample(i, math.max(-1, math.min(1, s)))
	end
	math.randomseed(os.time())
	return data
end

local function generateFootstep()
	-- Short crunch/thud
	local duration = 0.1
	return makeSoundData(duration, function(t, dur)
		local env = 1 - t / dur
		env = env * env * env
		local noise = math.random() * 2 - 1
		local thud = math.sin(t * math.pi * 2 * 80) * env * 0.3
		return math.max(-1, math.min(1, noise * env * 0.25 + thud))
	end)
end

local function generateClick()
	-- Tiny UI tick
	local duration = 0.04
	return makeSoundData(duration, function(t, dur)
		local env = 1 - t / dur
		env = env * env
		return math.sin(t * math.pi * 2 * 800) * env * 0.3
	end)
end

function audio.load()
	heartbeatSource = love.audio.newSource(generateHeartbeat(), "static")
	heartbeatSource:setLooping(true)
	heartbeatSource:setVolume(0)

	geigerSource = love.audio.newSource(generateGeiger(), "static")
	geigerSource:setLooping(true)
	geigerSource:setVolume(0)

	footstepSource = love.audio.newSource(generateFootstep(), "static")
	footstepSource:setLooping(false)

	clickSource = love.audio.newSource(generateClick(), "static")
	clickSource:setLooping(false)
end

-- Footstep system
local footstepTimer = 0
local footstepInterval = 0.45
local footstepPlaying = false

function audio.updateFootsteps(dt, isWalking, movingRight)
	if isWalking then
		footstepInterval = movingRight and 0.4 or 0.6
		footstepTimer = footstepTimer + dt
		if footstepTimer >= footstepInterval then
			footstepTimer = footstepTimer - footstepInterval
			footstepSource:stop()
			footstepSource:setPitch(0.8 + math.random() * 0.4)
			footstepSource:setVolume(0.3)
			footstepSource:play()
		end
		footstepPlaying = true
	else
		footstepTimer = 0
		footstepPlaying = false
	end
end

-- Center ending audio phases
local centerTimer = 0
local PHASE1_END = 6    -- heartbeat only
local PHASE2_END = 20   -- heartbeat + geiger
-- After phase 2: heartbeat fades, geiger alone

function audio.startCenter()
	centerTimer = 0
	heartbeatSource:setVolume(0.7)
	heartbeatSource:play()
	geigerSource:setVolume(0)
	geigerSource:play()
end

function audio.updateCenter(dt)
	centerTimer = centerTimer + dt

	if centerTimer < PHASE1_END then
		-- Phase 1: heartbeat only
		heartbeatSource:setVolume(0.7)
		geigerSource:setVolume(0)
	elseif centerTimer < PHASE2_END then
		-- Phase 2: geiger fades in
		local t = (centerTimer - PHASE1_END) / (PHASE2_END - PHASE1_END)
		heartbeatSource:setVolume(0.7)
		geigerSource:setVolume(t * 0.5)
	else
		-- Phase 3: heartbeat fades to quiet, geiger alone
		local t = math.min(1, (centerTimer - PHASE2_END) / 10)
		heartbeatSource:setVolume(0.7 * (1 - t) * (1 - t))
		geigerSource:setVolume(0.5)
	end
end

function audio.stopAll()
	heartbeatSource:stop()
	geigerSource:stop()
	footstepSource:stop()
	footstepTimer = 0
	centerTimer = 0
end

function audio.playClick()
	clickSource:stop()
	clickSource:play()
end

return audio
