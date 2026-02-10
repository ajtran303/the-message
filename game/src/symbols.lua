local symbols = {}

local TOTAL_SYMBOLS = 20
local COUNTS = {3, 3, 4, 4, 5}

local progress = {
	campfireIndex = 1,
	shaderParams = {0, 0, 0, 0, 0},
}

local activeSymbols = nil
local selectedIndex = nil
local campfireSymbols = nil

local function shuffle()
	-- Build pool of all symbol ids
	local pool = {}
	for i = 1, TOTAL_SYMBOLS do
		pool[i] = i
	end
	-- Fisher-Yates shuffle
	for i = TOTAL_SYMBOLS, 2, -1 do
		local j = math.random(1, i)
		pool[i], pool[j] = pool[j], pool[i]
	end
	-- Deal from shuffled pool into campfire sets
	campfireSymbols = {}
	local idx = 1
	for cf = 1, 5 do
		local set = {}
		for s = 1, COUNTS[cf] do
			set[s] = pool[idx]
			idx = idx + 1
		end
		campfireSymbols[cf] = { symbols = set, effect = cf }
	end
end

function symbols.activate(campfireIndex)
	local data = campfireSymbols[campfireIndex]
	activeSymbols = {}
	for i, v in ipairs(data.symbols) do
		activeSymbols[i] = v
	end
	selectedIndex = nil
end

function symbols.getActive()
	return activeSymbols
end

function symbols.getSelected()
	return selectedIndex
end

function symbols.select(index)
	if not activeSymbols then return end
	if index < 1 or index > #activeSymbols then return end

	if selectedIndex == nil then
		selectedIndex = index
	elseif selectedIndex == index then
		selectedIndex = nil
	else
		activeSymbols[selectedIndex], activeSymbols[index] = activeSymbols[index], activeSymbols[selectedIndex]
		selectedIndex = nil
	end
end

function symbols.confirm(campfireIndex)
	if not activeSymbols then return end
	local param = activeSymbols[1] / TOTAL_SYMBOLS
	progress.shaderParams[campfireIndex] = param
	progress.campfireIndex = campfireIndex + 1
	activeSymbols = nil
	selectedIndex = nil
end

function symbols.reset()
	progress.campfireIndex = 1
	progress.shaderParams = {0, 0, 0, 0, 0}
	activeSymbols = nil
	selectedIndex = nil
	shuffle()
end

function symbols.getProgress()
	return progress
end

-- Initial shuffle
shuffle()

return symbols
