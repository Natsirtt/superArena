local mt = {}
mt.__index = mt

SWORD_LENGTH = 75
local SWORD_AMPLITUDE = 45

local SHIELD_LENGTH = 25
local SHIELD_AMPLITUDE = 50

local MAX_LIFE = 10
local SPEED_BASE = 500
local RADIUS = 20
local DEFENDING_MAX_TIME = 3
local ANIMATION_RATE = 0.1
local DIE_ANIMATION_FRAME_NB = 18

PLAYER_DAMAGE = 1

local BLINK_LIMIT = 0.2
local BLINK_PER_SECOND = 15.0

function newPlayer(gameManager, playerNo)
    local this = {}
	
	this.gameManager = gameManager
	
	this.exploded = false
	
	this.angle = 0
    this.x = 400
    this.y = 400
    this.dx = 0
    this.dy = 0
	this.w = 25 -- taille de la boundingBox
	this.h = 25 -- taille de la boundingBox
    this.isDefendingBool = false
	this.canDefend = true
    this.isAttackingBool = false
    this.defendingTimeLeft = DEFENDING_MAX_TIME
    this.speed = SPEED_BASE

	--------------------------------------------------
	-- Système de sons
	--------------------------------------------------
	this.deathSound = love.audio.newSource("death.wav", "static")
	this.attackSound = love.audio.newSource("attack2.wav", "static")

	--------------------------------------------------
	-- Système d'animation
	--------------------------------------------------
	this.assets = nil
	if (playerNo == -1) then
		this.assets = getAssetsManager():getPlayerAssets("ennemy")
	else
		this.assets = getAssetsManager():getPlayerAssets("assets/player"..playerNo..".png")
	end
	this.playerChannel = love.thread.getChannel("player"..playerNo)
	
	this.assetsX = "idle"
	this.assetsY = 0
	this.temporaryAsset = false
	this.temporaryRemainingFrame = 0
	this.assetsMod = 4
	this.assestsLastChange = love.timer.getTime()
	this.dieAnimationStarted = false
	
    this.attackAssetsX = "attackDown"
    this.attackAssetsY = -1
    this.attackAnimationProcessing = false
    this.defenseAssetsX = "shieldDown"
    this.defenseAssetsY = -1
    this.defenseAnimationProcessing = false
	
	--------------------------------------------------
	-- Système de particules / Effets
	--------------------------------------------------
	this.blinkTimer = 0.0
	this.blinkColor = {r = 255, g = 0, b = 255}
	
	this.deathTimer = 0
	this.deathParticleSystem = nil
	this.hitTimer = 0
	this.hitParticleSystem = nil
	this.explosionParticleSystem = nil
	
	--------------------------------------------------
	-- Système physique
	--------------------------------------------------
	if (world ~= nil) then
		this.body = love.physics.newBody(world, 0, 0, "dynamic")
		this.body:setMassData(0, 0, 1, 1)
		--this.body:setLinearDamping(10)
		this.shape = love.physics.newPolygonShape(- this.w / 2, - this.h / 2,
												 this.w / 2, - this.h / 2,
												 this.w / 2, this.h / 2,
												 - this.w / 2, this.h / 2)
		this.fixture = love.physics.newFixture(this.body, this.shape, 1)
		this.fixture:setFriction(0)
		this.fixture:setRestitution(0)
		this.body:setPosition(this.x, this.y)
	end
	
	
	this.playerNo = playerNo
    this.life = MAX_LIFE
    this.ui = nil
    
    return setmetatable(this, mt)
end

-- La position du centre
function mt:setPosition(x, y)
	self.x = x
	self.y = y
	if (world ~= nil) then
		self.body:setPosition(x, y)
	end
end

function mt:getPosition()
	if (world ~= nil) then
		local x, y = self.body:getPosition()
		self.x = x
		self.y = y
	end
	return self.x, self.y
end

function mt:blink(color)
	if (self.blinkTimer == 0) then
		self.blinkTimer = BLINK_LIMIT
		self.blinkColor = color
	end
end

function mt:getNumber()
	return self.playerNo
end

function mt:getQuad()
	return {
		{x = self.x - RADIUS, y = self.y - RADIUS},
		{x = self.x + RADIUS, y = self.y - RADIUS},
		{x = self.x + RADIUS, y = self.y + RADIUS},
		{x = self.x - RADIUS, y = self.y + RADIUS}
	}
end

function mt:oldGetQuad()
    return {x = self.x - RADIUS,
            y = self.y - RADIUS,
            w = RADIUS * 2,
            h = RADIUS * 2}
end

function mt:setPositionFromQuad(quad)
	local pm1 = getMiddlePoint(quad[1], quad[3])
	local pm2 = getMiddlePoint(quad[2], quad[4])
	
	local middle = getMiddlePoint(pm1, pm2)

    self.x = middle.x
    self.y = middle.y
end

function mt:setDefending(isDefending)
	if self:isDead() then
		return
	end

	self.isDefendingBool = isDefending and self.canDefend and not self.attackAnimationProcessing
	self.defenseAnimationProcessing = false
	if (self.isDefendingBool) then
		self:beginDefenseAnimation()
	end
end

function mt:isDefending()
	return self.isDefendingBool
end

function mt:canAttack()
	return not self:isDead() and not self:isDefending() and not self.attackAnimationProcessing
end

function mt:attack()
	if self:canAttack() then
		if (self.gameManager ~= nil) then
			self.gameManager:playerAttack(self)
		end
		self.attackSound:play()
		self:beginAttackAnimation()
	end
end

function mt:beginAttackAnimation()
	self.attackAnimationProcessing = true
	self.attackAssetsY = -1
	if self.angle == 90 then
		self.attackAssetsX = "attackLeft"
	elseif self.angle == -90 then
		self.attackAssetsX = "attackRight"
	elseif self.angle == 180 or math.abs(self.angle) == 135 then
		self.attackAssetsX = "attackDown"
	elseif self.angle == 0 or math.abs(self.angle) == 45 then
		self.attackAssetsX = "attackUp"
	end
	-- we make sure we change the asset right now
	self.assestsLastChange = love.timer.getTime() - ANIMATION_RATE - 1
end

function mt:beginDefenseAnimation()
	self.defenseAnimationProcessing = true
	self.defenseAssetsY = -1
	if self.angle == 90 then
		self.defenseAssetsX = "shieldLeft"
	elseif self.angle == -90 then
		self.defenseAssetsX = "shieldRight"
	elseif self.angle == 180 or math.abs(self.angle) == 135 then
		self.defenseAssetsX = "shieldDown"
	elseif self.angle == 0 or math.abs(self.angle) == 45 then
		self.defenseAssetsX = "shieldUp"
	end
	-- we make sure we change the asset right now
	self.assestsLastChange = love.timer.getTime() - ANIMATION_RATE - 1
end

function mt:processAttackAnimation()
	self.attackAssetsY = self.attackAssetsY + 1
	-- print("attack assets y = " .. self.attackAssetsY)
	if self.attackAssetsY >= 4 then
		self.attackAnimationProcessing = false
	end
end

function mt:processDefenseAnimation()
	self.defenseAssetsY = self.defenseAssetsY + 1
	-- print("defense assets y = " .. self.defenseAssetsY)
	if self.defenseAssetsY >= 1 then
		self.defenseAssetsY = 1
		self.defenseAnimationProcessing = false
	end
end

function mt:setDirection(dx, dy)
	if not self:isDead() then
		self.dx = dx
		self.dy = dy
		if (world ~= nil) then
			self.body:setLinearVelocity(self.dx * self.speed, self.dy * self.speed)
		end
	end
end

function mt:getDirection()
	return self.dx, self.dy
end

function mt:toUpdateMessage()
	local s = "player"..self.playerNo.." "..self.life.." "..
				self.x.." "..self.y.." "..self.dx.." "..self.dy.." "..
				self.angle.." "..false.." "..self:isDefending()
	return s
end

function mt:processMessages()
	local tmp = self.playerChannel:pop()
	while tmp ~= nil do
		local msg = tmp.message
		if (msg == "attack") then
			self:attack()
		else
			local arg1, arg2 = msg:match("^(%S*) (.*)")
			if (arg1 == "defend") and (arg2 == "true") then
				self:setDefending(true)
			elseif (arg1 == "defend") and (arg2 == "false") then
				self:setDefending(false)
			elseif (arg1 == "dir") then
				local dx, dy = arg2:match("^(%S*) (.*)")
				self:setDirection(tonumber(dx), tonumber(dy))
			elseif (arg1 == "update") then
				local life, x, y, dx, dy, angle, attack, defense = arg2:match("^(%d*) (%d*) (%d*) (%d*) (%d*) (%d*) (%d*)")
		
				self.life = tonumber(life)
				self.setPosition(tonumber(x), tonumber(y))
				self.setDirection(tonumber(dx), tonumber(dy))
				self.angle = tonumber(angle)
				
				if (tonumber(defense) == 1) then
					self:setDefending(true)
				else
					self:setDefending(false)
					if (tonumber(attack) == 1) then
						self:attack()
					end
				end
			end
		end
		tmp = self.playerChannel:pop()
	end
end

function mt:update(dt)
	self.blinkTimer = math.max(self.blinkTimer - dt, 0.0)
	self:processMessages()
	
	if (not self:isDead()) then
		-- position checking
		if self.isDefendingBool then --or self.isAttackingBool then
			self:setDirection(0, 0)
		end
		if (world ~= nil) then
			self.body:setLinearVelocity(self.dx * self.speed, self.dy * self.speed)
			self.body:setAngle(math.rad(0))
			local x, y = self.body:getPosition()
			self.x = x
			self.y = y
		end

		
		if (self.dx == -1) and (self.dy == -1) then
			self.angle = 45
			if not self.temporaryAsset then
				self.assetsX = "walkUp"
			end
		elseif (self.dx == -1) and (self.dy == 0) then
			self.angle = 90
			if not self.temporaryAsset then
				self.assetsX = "walkLeft"
			end
		elseif (self.dx == -1) and (self.dy == 1) then
			self.angle = 135
			if not self.temporaryAsset then
				self.assetsX = "walkDown"
			end
		elseif (self.dx == 1) and (self.dy == -1) then		
			self.angle = -45
			if not self.temporaryAsset then
				self.assetsX = "walkUp"
			end
		elseif (self.dx == 1) and (self.dy == 0) then
			self.angle = -90
			if not self.temporaryAsset then
				self.assetsX = "walkRight"
			end
		elseif (self.dx == 1) and (self.dy == 1) then
			self.angle = -135
			if not self.temporaryAsset then
				self.assetsX = "walkDown"
			end
		elseif (self.dx == 0) and (self.dy == -1) then
			self.angle = 0
			if not self.temporaryAsset then
				self.assetsX = "walkUp"
			end
		elseif (self.dx == 0) and (self.dy == 1) then
			self.angle = 180
			if not self.temporaryAsset then
				self.assetsX = "walkDown"
			end
		end

		if (self.dx == 0) and (self.dy == 0) then
			if not self.temporaryAsset then
				if self.angle == 0 or math.abs(self.angle) == 45 then
					self.assetsX = "idleUp"
				elseif self.angle == 180 or math.abs(self.angle) == 135 then
					self.assetsX = "idle"
				elseif self.angle == 90 then
					self.assetsX = "idleLeft"
				elseif self.angle == -90 then
					self.assetsX = "idleRight"
				end
			end
		end

		-- defending checking
		if self:isDefending() then
			self.defendingTimeLeft = self.defendingTimeLeft - dt
			if self.defendingTimeLeft <= 0 then
				self:setDefending(false)
				self.canDefend = false
			end
		else
			self.defendingTimeLeft = math.min(self.defendingTimeLeft + dt, DEFENDING_MAX_TIME)
			if (self.defendingTimeLeft >= DEFENDING_MAX_TIME) then
				self.canDefend = true
			end
		end

		--animation
		if love.timer.getTime() - self.assestsLastChange >= ANIMATION_RATE then
			self.assestsLastChange = love.timer.getTime()
			if self.attackAnimationProcessing then
				self:processAttackAnimation()
			elseif self.defenseAnimationProcessing then
				self:processDefenseAnimation()
			else
				self.assetsY = (self.assetsY + 1) % self.assetsMod
			end
		end
	else
		-- player is dead
		if love.timer.getTime() - self.assestsLastChange >= ANIMATION_RATE then
			self.assestsLastChange = love.timer.getTime()
			self.assetsX = "die"
			
			if not self.dieAnimationStarted then
				self.assetsY = -1
				self.dieAnimationStarted = true
			end
			if self.assetsY < DIE_ANIMATION_FRAME_NB - 1 then
				self.assetsY = self.assetsY + 1
			end
		end
		--self.deathTimer = self.deathTimer + dt
		--self.deathParticleSystem:update(dt)
	end
	if (self.hitParticleSystem ~= nil) then
		self.hitTimer = self.hitTimer + dt
		self.hitParticleSystem:update(dt)
	end
	if (self.explosionParticleSystem ~= nil) then
		self.explosionParticleSystem:update(dt)
	end
end

function mt:draw()
	local percent = math.sin(math.rad((BLINK_LIMIT - self.blinkTimer * BLINK_PER_SECOND * 360.0)))
	if (self.blinkTimer ~= 0) then
		percent = math.abs(percent)
		local r = self.blinkColor.r + (255 - self.blinkColor.r) * (1 - percent)
		local g = self.blinkColor.g + (255 - self.blinkColor.g) * (1 - percent)
		local b = self.blinkColor.b + (255 - self.blinkColor.b) * (1 - percent)
		love.graphics.setColor(r, g, b)
	else
		love.graphics.setColor(255, 255, 255)
	end
	
	if (not self.exploded) then
		local tex = nil
		if self.attackAnimationProcessing then
			tex = self.assets[self.attackAssetsX][self.attackAssetsY + 1]
		elseif self.defenseAnimationProcessing then
			tex = self.assets[self.defenseAssetsX][self.defenseAssetsY + 1]
		else
			tex = self.assets[self.assetsX][self.assetsY + 1]
		end
		local x, y = self:getPosition()
		if (tex ~= nil) then
			love.graphics.push()
			local tx = x - tex:getWidth() / 2
			local ty = y - tex:getHeight() / 2
			love.graphics.translate(x, y)
			-- if (self.angle == 45) or (self.angle == -45) then
				-- love.graphics.rotate(math.rad(-self.angle / 2))
			-- end
			-- if (self.angle == 135) or (self.angle == -135) then
				-- love.graphics.rotate(math.rad(self.angle / 6))
			-- end
			love.graphics.draw(tex, -tex:getWidth() / 2, -tex:getHeight() / 2)
			love.graphics.pop()
		else
			print("Erreur : Pas de texture a afficher pour le joueur "..self:getNumber())
		end
	end
	
	if (self.deathParticleSystem ~= nil) then
		-- love.graphics.draw(self.deathParticleSystem)
	end
	if (self.hitParticleSystem ~= nil) then
		love.graphics.draw(self.hitParticleSystem)
	end	
	if (self.explosionParticleSystem ~= nil) then
		love.graphics.draw(self.explosionParticleSystem)
	end
	love.graphics.setColor(255, 255, 255)

	-- Affichage de la bounding box (debug)
	-- local topLeftX, topLeftY, bottomRightX, bottomRightY = self.fixture:getBoundingBox()
	-- love.graphics.rectangle("line", topLeftX, topLeftY, bottomRightX - topLeftX, bottomRightY - topLeftY)
	
	-- Affiche de la bounding box du bouclier
	-- drawBox(self:getShieldHitBox())
	
end

function mt:isDead()
    return self.life <= 0
end

function mt:getLife()
    return self.life
end

function mt:hit(lifePoints)
    self.life = self.life - lifePoints
    if self:isDead() then
    	self.attackAnimationProcessing = false
    	self.assetsX = "die"
    	self.dx = 0
    	self.dy = 0
    	self.body:setLinearVelocity(0, 0)
	else
		local dx = math.cos(math.rad(self.angle + 180)) * 100
		local dy = -math.sin(math.rad(self.angle + 180)) * 100
		self.body:applyLinearImpulse(dx, dy)
    end
	if (self.gameManager ~= nil) then
		self.gameManager.camera:shake()
	end
	self:blink({r = 255, g = 20, b = 20})
	if self:isDead() then
		local p = love.graphics.newParticleSystem(self.assets[self.assetsX][self.assetsY + 1], 1000)
		p:setEmissionRate(100)
		p:setSpeed(300, 400)
		p:setPosition(self.x, self.y)
		p:setEmitterLifetime(0.3)
		p:setParticleLifetime(1)
		p:setDirection(0)
		p:setSpread(360)
		p:setRadialAcceleration(-3000)
		p:setTangentialAcceleration(1000)
		p:stop()
		self.deathParticleSystem = p
		p:start()
		
		self.deathSound:play()
	else
		local p = love.graphics.newParticleSystem(self.assets[self.assetsX][self.assetsY + 1], 1000)
		p:setEmissionRate(20)
		p:setSpeed(300, 400)
		p:setPosition(self.x, self.y)
		p:setEmitterLifetime(0.3)
		p:setParticleLifetime(0.3)
		p:setDirection(0)
		p:setSpread(360)
		p:setRadialAcceleration(-3000)
		p:setTangentialAcceleration(1000)
		p:stop()
		self.hitParticleSystem = p
		p:start()
	end
end

function mt:heal(lifePoints)
    self.life = self.life + lifePoints
    if self.life > MAX_LIFE then
        self.life = MAX_LIFE
    end
end

function mt:getSwordHitBox()
	-- la longueur de la hitbox (de l'épée)
	local length = SWORD_LENGTH
	-- l'amplitude de l'épée
	local amp = SWORD_AMPLITUDE
	
	local dx = math.cos(math.rad(self.angle + 90))
	local dy = -math.sin(math.rad(self.angle + 90))
	local l = math.sqrt(dx * dx + dy * dy)
	dx = (dx / l) * length
	dy = (dy / l) * length
	
	local dx2 = math.cos(math.rad(self.angle + 180))
	local dy2 = -math.sin(math.rad(self.angle + 180))
	l = math.sqrt(dx2 * dx2 + dy2 * dy2)
	dx2 = (dx2 / l) * amp
	dy2 = (dy2 / l) * amp
	
	return {
		{x = self.x + dx2 / 2,      y = self.y + dy2 / 2},
		{x = self.x + dx2 / 2 + dx, y = self.y + dy2 / 2 + dy},
		{x = self.x - dx2 / 2 + dx, y = self.y - dy2 / 2 + dy},
		{x = self.x - dx2 / 2,      y = self.y - dy2 / 2}
	}
end

function mt:getShieldHitBox()
	-- la longueur de la hitbox (de l'épée)
	local length = SHIELD_LENGTH
	-- l'amplitude de l'épée
	local amp = SHIELD_AMPLITUDE
	
	local dx = math.cos(math.rad(self.angle + 90))
	local dy = -math.sin(math.rad(self.angle + 90))
	local l = math.sqrt(dx * dx + dy * dy)
	dx = (dx / l) * length
	dy = (dy / l) * length
	
	local dx2 = math.cos(math.rad(self.angle + 180))
	local dy2 = -math.sin(math.rad(self.angle + 180))
	l = math.sqrt(dx2 * dx2 + dy2 * dy2)
	dx2 = (dx2 / l) * amp
	dy2 = (dy2 / l) * amp
	
	return {
		{x = self.x + dx2 / 2 + dx / 2,      y = self.y + dy2 / 2 + dy / 2},
		{x = self.x + dx2 / 2 + dx,          y = self.y + dy2 / 2 + dy},
		{x = self.x - dx2 / 2 + dx,          y = self.y - dy2 / 2 + dy},
		{x = self.x - dx2 / 2 + dx / 2,      y = self.y - dy2 / 2 + dy / 2}
	}
end

function drawBox(box)
	-- love.graphics.print(math.floor(box[1].x).." "..math.floor(box[1].y).." "..
						-- math.floor(box[2].x).." "..math.floor(box[2].y).." "..
						-- math.floor(box[3].x).." "..math.floor(box[3].y).." "..
						-- math.floor(box[4].x).." "..math.floor(box[4].y).." ",
						-- 100, 100)
	love.graphics.polygon("fill", box[1].x, box[1].y, 
								box[4].x, box[4].y,
								box[3].x, box[3].y,
								box[2].x, box[2].y
								)
end

function mt:debugSprites(state)
	local t = {}
	if state == "shield" then
		table.insert(t, self.assets["shieldDown"][1])
		table.insert(t, self.assets["shieldRight"][1])
		table.insert(t, self.assets["shieldLeft"][1])
		table.insert(t, self.assets["shieldUp"][1])
	else 
		t = self.assets[state]
	end
	for j, sprite in ipairs(t) do
		love.graphics.draw(sprite, 175 * (j - 1), 200)
	end
end

function mt:explode()
	if (not self.exploded) then
		self.life = 0
		self.exploded = true
		local p = love.graphics.newParticleSystem(getAssetsManager():getSmoke(), 100)
		p:setEmissionRate(20)
		p:setSpeed(300, 400)
		local x, y = self:getPosition()
		p:setPosition(x, y)
		p:setEmitterLifetime(0.3)
		p:setParticleLifetime(0.3)
		p:setDirection(0)
		p:setSpread(360)
		p:setRadialAcceleration(-3000)
		p:setTangentialAcceleration(1000)
		p:stop()
		self.hitParticleSystem = p
		p:start()
	end
end
