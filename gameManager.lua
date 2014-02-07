love.filesystem.load("camera.lua")()

local mt = {}
mt.__index = mt

--maybe we could do something like an audioManager but for now the game song will be here
local music = love.audio.newSource("audio/the-fight.mp3")

function newGameManager()
	local self = {}

	self.players = {}
	self.iaPlayers = {}
	
	self.arena = nil

	self.task = addingPlayersPhase
	self.drawTask = addingPlayersPhaseDraw

	self.phaseInitialized = false
	
	self.globalTimer = 60 -- En secondes (à modifier)
	self.camera = nil
	self.cameraPosX = 0
	self.cameraPosY = 0
	
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
			return
		end
	end
	-- adding a new player
	local added = getControllersManager():tryBindingNewController()
	if added then
		local p = newPlayer(self, #self.players + 1)
		self.players[#self.players + 1] = p
		getControllersManager():getUnusedController():bind(p)
		-- a little idle time to let the player some time
		-- to release the button, or the first test of this
		-- function will be true
		time = love.timer.getTime()
		while (love.timer.getTime() - time) < 0.1 do
		end
	end

	-- UI debug
	--self.players = {newPlayer(self, 1),
	--				newPlayer(self, 2),
	--				newPlayer(self, 3),
	--				newPlayer(self, 4)}
	--self.task = arenaPhase
end

function addingPlayersPhaseDraw(self)
	love.graphics.print(self:debugInfo(), 100, 100)
end

function arenaPhase(self, dt)
	self.globalTimer = math.max(0, self.globalTimer - dt)
	self.drawTask = arenaPhaseDraw

	if not self.phaseInitialized then
		love.graphics.setNewFont(24)
		self.arena = newArena(self)
		self.camera = newCamera()
		self.phaseInitialized = true
		music:play() -- one play for now, no loop
		--ui debug
		math.randomseed(os.time())
		----------
	end

	self.camera:update(dt)
	self.arena:update(dt)
	
	getControllersManager():updateAll(dt)

	for _, player in ipairs(self.players) do
		local lastQuad = player:getQuad()
		--ui debug
		--if math.random(0, 100) > 99 then
		--	player:hit(1)
		--end
		----------
		player:update(dt)
    end
	-- On met les ordis à jour
	for _, player in ipairs(self.iaPlayers) do
		player:update(dt)
    end
	
	world:update(dt)
end

function arenaPhaseDraw(self)
	if not self.phaseInitialized then
		return
	end
	
	love.graphics.push()

	-- keeping our own table of players to be focused by the camera
	-- allow us to keep following the last one even when he dies
	local cameraPlayers = self:getAlivePlayers()
	if #cameraPlayers ~= 0 then
		self.cameraPlayers = cameraPlayers
	end
	local x, y = self.camera:getBestPosition(self.cameraPlayers)
	love.graphics.translate(love.window.getWidth() / 2 - x, love.window.getHeight() / 2 - y)
	self.cameraPosX = love.window.getWidth() / 2 - x
	self.cameraPosY = love.window.getHeight() / 2 - y
	
	self.camera:draw()
	self.arena:draw()
	-- self.arena:drawDebug()
	-- getAssetsManager():drawAsset(24, 200, 200)
	-- getAssetsManager():debugAssets()
	for _, player in ipairs(self.players) do
		player:draw()
		--player:debugSprites("shield")
	end
	
	-- On dessine les ordis
	for _, player in ipairs(self.iaPlayers) do
		player:draw()
    end
	
	self.arena:postPlayerDraw()
	
	love.graphics.pop()
	
	getControllersManager():drawAll()


	-- UI
	for _, player in ipairs(self.players) do
		drawUI(player)
	end
	
	love.graphics.setColor(255, 0, 0)
	
	--love.graphics.print(string.format("%d", self.globalTimer).."s", love.window.getWidth() / 2, 10)
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
	local sword = player:getSwordHitBox()
	
	local maxDistSqr = SWORD_LENGTH * SWORD_LENGTH
	local x, y = player:getPosition()
	
	for _, p in ipairs(self:getAlivePlayers()) do
		if (p ~= player) then
			local x2, y2 = p:getPosition()
			local d = (x - x2) * (x - x2) + (y - y2) * (y - y2)
			if (d <= maxDistSqr) then
				local shield = p:getShieldHitBox()
				if (rectCollision(sword, p:getQuad())) then
					if (not p:isDefending() or (p:isDefending() and (not rectCollision(sword, shield)))) then
						p:hit(PLAYER_DAMAGE)
						local x, y = p:getPosition()
						self.arena:blood(x, y)
					end
				end
			end
		end
	end
	for _, p in ipairs(self.iaPlayers) do
		if (not p:isDead()) and (p ~= player) then
			local x2, y2 = p:getPosition()
			local d = (x - x2) * (x - x2) + (y - y2) * (y - y2)
			if (d <= maxDistSqr) then
				local shield = p:getShieldHitBox()
				if (rectCollision(sword, p:getQuad())) then
					if (not p:isDefending() or (p:isDefending() and (not rectCollision(sword, shield)))) then
						p:hit(PLAYER_DAMAGE)
						local x, y = p:getPosition()
						self.arena:blood(x, y)
					end
				end
			end
		end
	end
	self.arena:hit(sword)
end


function mt:getNearestPlayer(x, y) 
	local nearest = nil
	local distance = nil
	
	for _, p in ipairs(self:getAlivePlayers()) do
		local x2 = p.x
		local y2 = p.y
		local d = math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y))
		if (distance == nil) or (d < distance) then
			nearest = p
			distance = d
		end
	end
	
	return nearest
end

function mt:addIAPlayer(player)
	self.iaPlayers[#self.iaPlayers + 1] = player
end

function mt:debugInfo()
	local res = "players = {"
	for i, _ in ipairs(self.players) do
		res = res .. i ..","
	end
	res = res .. "}"
	return res
end
