love.filesystem.load("camera.lua")()

local mt = {}
mt.__index = mt

--maybe we could do something like an audioManager but for now the game song will be here
local music = love.audio.newSource("audio/the-fight.mp3")

function newGameManager(controllers)
	local self = {}
	
	self.rebootListener = nil

	self.players = {}
	self.iaPlayers = {}
	
	self.arena = nil
	
	self.globalTimer = 90 -- En secondes (à modifier)
	self.camera = nil
	self.cameraPosX = 0
	self.cameraPosY = 0
	
	self.isCoop = false
	self.finish = false
	
	if (world ~= nil) then
		world:destroy()
	end
	world = love.physics.newWorld(0, 0, true)
	self.cameraPlayers = {}
	
	for i, c in ipairs(controllers) do
		local p = newPlayer(self, #self.players + 1)
		self.players[#self.players + 1] = p
		c:bind(p)
	end
	
	love.graphics.setNewFont(24)
	self.arena = newArena(self)
	self.arena:setDoorListener(
		function()
			self.isCoop = true
			for _, player in ipairs(self.players) do
				self.isCoop = self.isCoop and not player.hasBeenHit
			end
		end
	)
	for _, player in ipairs(self.players) do
		player:setDyingListener(
			function(killer, killed)
				killer:heal(2)
				local alives = self:getAlivePlayers()
				self.finish = (#alives == 0) or (#alives == 1) and not self.isCoop
			end
		)
	end

	self.camera = newCamera()
	music:play() -- one play for now, no loop
	--ui debug
	math.randomseed(os.time())
		
	return setmetatable(self, mt)
end

function mt:update(dt)
	if (not self.finish) and (self.arena.hasDoor) then
		self.globalTimer = math.max(0, self.globalTimer - dt)
		
		if (self.globalTimer <= 0) then
			self.finish = true
		end
	end

	self.camera:update(dt)
	self.arena:update(dt)
	
	if (not self.finish) then
		getControllersManager():updateAll(dt)
	end
	-- On met les joueurs à jour
	for _, player in ipairs(self.players) do
		player:update(dt)
	end
	-- On met les IA à jour
	for _, player in ipairs(self.iaPlayers) do
		player:update(dt)
	end
	-- On met à jour la physique
	world:update(dt)
	
	if (self.finish) then
		local binded = getControllersManager().bindedControllers
		for _, c in ipairs(binded) do
			if ((c.isGamePad) or (c.isKeyboard)) and c:isDown(c:getStartButton()) then
				if (self.rebootListener) then
					self.rebootListener()
				end
			end
		end
	end
end

function mt:draw()
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
	-- On dessine l'arene
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
	-- On dessine la partie de l'arene qui doit etre dessiné après le joueur
	self.arena:postPlayerDraw()
	
	love.graphics.pop()
	-- On dessine les controllers si besoin
	getControllersManager():drawAll()

	-- UI
	for _, player in ipairs(self.players) do
		drawUI(player)
	end
	
	if (self.finish) then
		local font = love.graphics.getFont()
		local victoryString, lineNb = self:getVictoryString()
		local w = font:getWidth(victoryString)
		local h = font:getHeight(victoryString)
		victoryString = victoryString.."Start/Démarrer pour recommencer"
		lineNb = lineNb + 1
		love.graphics.setColor(0, 0, 0)
		love.graphics.rectangle("fill", love.graphics.getWidth() / 2 - (w + 20) / 2, love.graphics.getHeight() / 2 - (h * lineNb + 20) / 2, w + 20, h * lineNb + 20)
		love.graphics.setColor(255, 255, 255)
		love.graphics.printf(victoryString, love.graphics.getWidth() / 2 - w / 2, love.graphics.getHeight() / 2 - h * lineNb / 2, w, "center")
	end
	
	love.graphics.setColor(255, 0, 0)
	
	-- On affiche le timer
	if (self.arena.hasDoor) then
		love.graphics.print(string.format("%d", self.globalTimer).."s", love.window.getWidth() / 2, 10)
	end
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
	
	if (not self.isCoop) or (self.isCoop and not player.isRealPlayer) then
		for _, p in ipairs(self:getAlivePlayers()) do
			if (p ~= player) then
				local x2, y2 = p:getPosition()
				local d = (x - x2) * (x - x2) + (y - y2) * (y - y2)
				if (d <= maxDistSqr) then
					if (rectCollision(sword, p:getQuad())) then
						if (p:canBeHit(player)) then
							p:hit(player, PLAYER_DAMAGE, x, y)
							local x, y = p:getPosition()
							self.arena:blood(x, y)
						else
							player.shieldSound:play()
							if (player.body) then
								local dx = (x - x2) / d
								local dy = (y - y2) / d
								player.body:applyLinearImpulse(dx * 10000, dy * 10000)
							end
						end
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
				if (rectCollision(sword, p:getQuad())) then
					if (p:canBeHit(player)) then
						p:hit(player, PLAYER_DAMAGE, x, y)
						local x, y = p:getPosition()
						self.arena:blood(x, y)
					else
						if (player.body) then
							local dx = (x - x2) / d
							local dy = (y - y2) / d
							player.body:applyLinearImpulse(dx, dy)
						end
					end
				end
			end
		end
	end
	self.arena:hit(player, sword)
end

function mt:playerExplosion(player)
	local maxDistSqr = EXPLOSION_RADIUS * EXPLOSION_RADIUS
	local x, y = player:getPosition()
	
	if (not self.isCoop) or (self.isCoop and not player.isRealPlayer) then
		for _, p in ipairs(self:getAlivePlayers()) do
			if (p ~= player) then
				local x2, y2 = p:getPosition()
				local d = (x - x2) * (x - x2) + (y - y2) * (y - y2)
				if (d <= maxDistSqr) then
					p:hit(player, PLAYER_DAMAGE, x, y)
					self.arena:blood(x2, y2)
				end
			end
		end
	end
	for _, p in ipairs(self.iaPlayers) do
		if (not p:isDead()) and (p ~= player) then
			local x2, y2 = p:getPosition()
			local d = (x - x2) * (x - x2) + (y - y2) * (y - y2)
			if (d <= maxDistSqr) then
				p:hit(player, PLAYER_DAMAGE, x, y)
				self.arena:blood(x2, y2)
			end
		end
	end
	self.arena:explosion(player, x, y, EXPLOSION_RADIUS)
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
	local self = self
	player:setDyingListener(
		function(killer, killed)
			killer:incrementKillScore()
			killer:heal(2)
		end
	)
end

function mt:getVictoryString()
	local alives = self:getAlivePlayers()
	if (self.globalTimer <= 0) then
		local n = 1
		local s = "Bravo vous êtes des guerriers honorables !\n"
		for _, player in ipairs(self.players) do
			s = s.."joueur "..player.playerNo.." : 0 points\n"
			n = n + 1
		end
		return s, n
	end
	if (#alives == 1) then
		return "Le joueur "..alives[1].playerNo.." remporte la victoire\n", 1
	end
	if (#alives == 0) then
		local n = 1
		local s = "Aucun joueur ne remporte la victoire\n"
		for i, player in ipairs(self.players) do
			s = s.."joueur "..i.." : "..player:getScore().." points\n"
			n = n + 1
		end
		return s, n
	end
	if (#alives ~= 0) and self.isCoop then
		return "Bravo !\n", 1
	end
	return "", 0
end

function mt:setRebootListener(func)
	self.rebootListener = func
end

----------------------------------------------
-- DEBUG
----------------------------------------------
function mt:debugInfo()
	local res = "players = {"
	for i, _ in ipairs(self.players) do
		res = res .. i ..","
	end
	res = res .. "}"
	return res
end
