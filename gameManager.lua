local mt = {}
mt.__index = mt

function newGameManager()
	local self = {}

	self.players = {}
	self.arena = nil

	self.task = addingPlayersPhase
	self.drawTask = addingPlayersPhaseDraw

	self.phaseInitialized = false

	return setmetatable(self, mt)
end

function mt:draw()
	if self.drawTask ~= nil then
		self.drawTask(self)
	end
end

function mt:update(dt)
	self.task(self, dt)
end

function addingPlayersPhase(self, dt)
	-- testing if an existing controller is pressing a key (that means we go to the next game state)
	for _, controller in ipairs(getControllersManager():getBindedControllers()) do
		if controller:isAnyDown() then
			self.task = arenaPhase
			self.drawTask = arenaPhaseDraw
			return
		end
	end
	-- adding a new player
	local added = getControllersManager():tryBindingNewController()
	if added then
		self.players[#self.players + 1] = newPlayer()
		-- a little idle time to let the player some time
		-- to release the button, or the first test of this
		-- function will be true
		time = love.timer.getTime()
		while love.timer.getTime() - time < 0.3 do
		end
	end
end

function addingPlayersPhaseDraw(self)
	love.graphics.print(self:debugInfo(), 100, 100)
end

function arenaPhase(self, dt)
	if not self.phaseInitialized then
		self.arena = newArena()
		self.phaseInitialized = true
	end

	love.graphics.setNewFont(24)
	if (love.keyboard.isDown("a")) then
        self.arena:destroyLeftDoor()
    end

	for _, player in ipairs(self.players) do
		player:update(dt)
		-- arena hitbox
		local quad = self.arena:getValidQuad(nil, player:getQuad())
        player:setPositionFromQuad(quad)
    end
end

function arenaPhaseDraw(self)
	if not self.phaseInitialized then
		return
	end

	self.arena:draw()
	for _, player in ipairs(self.players) do
		player:draw()
	end
end

function mt:playerAttack(player)

end

function mt:debugInfo()
	local res = "players = {"
	for i, _ in ipairs(self.players) do
		res = res .. i ..","
	end
	res = res .. "}"
	return res
end
