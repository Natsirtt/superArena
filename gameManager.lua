love.filesystem.load("camera.lua")()

local mt = {}
mt.__index = mt

function newGameManager()
	local self = {}

	self.players = {}
	self.arena = nil

	self.task = addingPlayersPhase
	self.drawTask = addingPlayersPhaseDraw

	self.phaseInitialized = false
	
	self.globalTimer = 60 -- En secondes (à modifier)
	self.camera = nil
	
	world = love.physics.newWorld(0, 0, true)
	self.cameraPlayers = {}

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
		local p = newPlayer(self, #self.players + 1)
		self.players[#self.players + 1] = p
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
	self.globalTimer = math.max(0, self.globalTimer - dt)

	if not self.phaseInitialized then
		self.arena = newArena()
		self.camera = newCamera()
		self.phaseInitialized = true
	end

	self.camera:update(dt)

	love.graphics.setNewFont(24)
	if (love.keyboard.isDown("a")) then
        self.arena:destroyDoor()
    end

	for _, player in ipairs(self.players) do
		local lastQuad = player:getQuad()
		player:update(dt)

		-- arena hitbox
		--local quad = self.arena:getValidQuad(lastQuad, player:getQuad(), player.dx * player.speed * dt, player.dy * player.speed * dt)
        --player:setPositionFromQuad(quad)
    end
	
	world:update(dt)
end

function arenaPhaseDraw(self)
	if not self.phaseInitialized then
		return
	end
	
	love.graphics.push()
	
	local w = self.arena.getWidth()
	local h = self.arena.getHeight()
	
	--love.graphics.translate(love.window.getWidth() / 2 - w / 2, love.window.getHeight() / 2 - h / 2)

	-- keeping our own table of players to be focused by the camera
	-- allow us to keep following the last one even when he dies
	local cameraPlayers = self:getAlivePlayers()
	if #cameraPlayers ~= 0 then
		self.cameraPlayers = cameraPlayers
	end
	local x, y = self.camera:getBestPosition(self.cameraPlayers)
	love.graphics.translate(love.window.getWidth() / 2 - x, love.window.getHeight() / 2 - y)
	
	self.camera:draw()
	self.arena:draw()
	-- self.arena:drawDebug()
	-- getAssetsManager():drawAsset(24, 200, 200)
	-- getAssetsManager():debugAssets()
	for _, player in ipairs(self.players) do
		player:draw()
		--player:debugSprites("shield")
	end
	love.graphics.pop()
	
	love.graphics.setColor(255, 0, 0)
	love.graphics.print(string.format("%d", self.globalTimer).."s", love.window.getWidth() / 2, 10)
end

function mt:getAlivePlayers()
	local alive = {}
	for i, p in ipairs(self.players) do
		if (not p:isDead()) then
			table.insert(alive, p)
		end
	end
	return alive
end

function mt:playerAttack(player)
	-- la longueur de la hitbox (de l'épée)
	local length = 80
	-- l'amplitude de l'épée
	local amp = 30
	
	local dx = math.cos(math.rad(player.angle))
	local dy = math.cos(math.rad(player.angle))
	
	local dx2 = math.cos(math.rad(player.angle + 90))
	local dy2 = math.cos(math.rad(player.angle + 90))
	
	local hitBox = {
		{x = player.x + dx2 / 2,      y = player.y + dx2 / 2},
		{x = player.x + dx2 / 2 + dx, y = player.y + dx2 / 2 + dy},
		{x = player.x - dx2 / 2 + dx, y = player.y - dx2 / 2 + dy},
		{x = player.x - dx2 / 2,      y = player.y - dx2 / 2},
	}
	for _, p in ipairs(self:getAlivePlayers()) do
		if (p ~= player) then
			if (rectCollision(hitBox, p:getQuad())) then
				p:hit(PLAYER_DAMAGE)
			end
		end
	end
end

function mt:debugInfo()
	local res = "players = {"
	for i, _ in ipairs(self.players) do
		res = res .. i ..","
	end
	res = res .. "}"
	return res
end
