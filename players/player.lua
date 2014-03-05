love.filesystem.load("players/playerAnimation.lua")()

local mt = {}
mt.__index = mt

SWORD_LENGTH = 50
local SWORD_AMPLITUDE = 45

local MAX_LIFE = 10
local SPEED_BASE = 1500
local RADIUS = 20
local DEFENDING_MAX_TIME = 3

local DASH_COOLDOWN = 0.6
local TORNADO_COOLDOWN = 0.5

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
	this.dashCooldown = 0
	this.tornadoCooldown = 0

	--------------------------------------------------
	-- Système de sons
	--------------------------------------------------
	this.deathSound = love.audio.newSource("audio/death.wav", "static")
	this.attackSound = love.audio.newSource("audio/attack2.wav", "static")
	this.dashSound = love.audio.newSource("audio/dash.wav", "static")
	this.shieldSound = love.audio.newSource("audio/shield.wav", "static")
	this.tornadoSound = love.audio.newSource("audio/tornado.wav", "static")

	--------------------------------------------------
	-- Système d'animation
	--------------------------------------------------
	this.assets = nil
	if (playerNo < 0) then
		this.assets = getAssetsManager():getPlayerAssets("ennemy")
	else
		this.assets = getAssetsManager():getPlayerAssets("assets/player"..playerNo..".png")
	end
	
	this.currentAnimation = this.assets[ANIMATIONS[this.angle].idle]
	
	this.dieAnimationStarted = false
    this.attackAnimationProcessing = false
    this.defenseAnimationProcessing = false
    this.tornadoAnimationProcessing = false
	
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
		this.body:setMassData(0, 0, 50, 1)
		this.body:setLinearDamping(6.0)
		this.shape = love.physics.newPolygonShape(- this.w / 2, - this.h / 2,
												 this.w / 2, - this.h / 2,
												 this.w / 2, this.h / 2,
												 - this.w / 2, this.h / 2)
		this.fixture = love.physics.newFixture(this.body, this.shape, 1)
		this.fixture:setFriction(100)
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
	if ((world ~= nil) and (self.body ~= nil)) then
		self.body:setPosition(x, y)
	end
end

function mt:getPosition()
	if ((world ~= nil) and (self.body ~= nil)) then
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
	return not self:isDead() and not self:isDefending() and 
			not self.attackAnimationProcessing and not self.tornadoAnimationProcessing
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
	self.currentAnimation = self.assets[ANIMATIONS[self.angle].attack]
	self.currentAnimation:play()
end

function mt:beginDefenseAnimation()
	self.defenseAnimationProcessing = true
	self.currentAnimation = self.assets[ANIMATIONS[self.angle].shield]
	self.currentAnimation:play()
end

function mt:beginTornadoAnimation()
	self.tornadoAnimationProcessing = true
	self.currentAnimation = self.assets["tornado"]
	self.currentAnimation:play()
end

function mt:setDirection(dx, dy)
	if not self:isDead() then
		self.dx = dx
		self.dy = dy
		if ((world ~= nil) and (self.body ~= nil)) then
			if (dx ~= self.dx) and (dy ~= self.dy) then
				self.body:setLinearVelocity(0, 0)
			end
		end
	end
end

function mt:getDirection()
	return self.dx, self.dy
end

function mt:update(dt)
	self.blinkTimer = math.max(self.blinkTimer - dt, 0.0)
	self.dashCooldown = math.max(self.dashCooldown - dt, 0.0)
	self.tornadoCooldown = math.max(self.tornadoCooldown - dt, 0)
	
	if (not self:isDead()) then
		-- position checking
		if self.isDefendingBool then --or self.isAttackingBool then
			self:setDirection(0, 0)
		end
		if ((world ~= nil) and (self.body ~= nil)) then
			-- self.body:setLinearVelocity(self.dx * self.speed, self.dy * self.speed)
			self.body:applyForce(self.dx * self.speed, self.dy * self.speed)
			self.body:setAngle(math.rad(0))
			local x, y = self.body:getPosition()
			self.x = x
			self.y = y
		end
		
		if (self.dx == -1) and (self.dy == -1) then
			self.angle = 45
		elseif (self.dx == -1) and (self.dy == 0) then
			self.angle = 90
		elseif (self.dx == -1) and (self.dy == 1) then
			self.angle = 135
		elseif (self.dx == 1) and (self.dy == -1) then		
			self.angle = -45
		elseif (self.dx == 1) and (self.dy == 0) then
			self.angle = -90
		elseif (self.dx == 1) and (self.dy == 1) then
			self.angle = -135
		elseif (self.dx == 0) and (self.dy == -1) then
			self.angle = 0
		elseif (self.dx == 0) and (self.dy == 1) then
			self.angle = 180
		end
		
		if self.attackAnimationProcessing then
			if (self.currentAnimation ~= self.assets[ANIMATIONS[self.angle].attack]) then
				self.assets[ANIMATIONS[self.angle].attack]:play()
				self.assets[ANIMATIONS[self.angle].attack].currentFrame = self.currentAnimation.currentFrame
				self.assets[ANIMATIONS[self.angle].attack].finish = self.currentAnimation.finish
				self.currentAnimation = self.assets[ANIMATIONS[self.angle].attack]
			end
			if self.currentAnimation:isFinished() then
				self.attackAnimationProcessing = false
			end
		elseif self.defenseAnimationProcessing then
			if self.currentAnimation:isFinished() then
				self.defenseAnimationProcessing = false
			end
		elseif self.tornadoAnimationProcessing then
			if self.currentAnimation:isFinished() then
				self.tornadoAnimationProcessing = false
			end
		else
			if (self.dx == 0) and (self.dy == 0) then
				if (self.currentAnimation ~= self.assets[ANIMATIONS[self.angle].idle]) then
					self.currentAnimation = self.assets[ANIMATIONS[self.angle].idle]
					self.currentAnimation:play()
				end
			else
				if (self.currentAnimation ~= self.assets[ANIMATIONS[self.angle].walk]) then
					self.currentAnimation = self.assets[ANIMATIONS[self.angle].walk]
					self.currentAnimation:play()
				end
			end
		end
		self.currentAnimation:update(dt)
		

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
	else
		-- player is dead
		if (self.exploded) and (self.fixture ~= nil) then
			self.fixture:destroy()
			self.fixture = nil
		end
		self.currentAnimation:update(dt)
		--self.deathTimer = self.deathTimer + dt
		--self.deathParticleSystem:update(dt)
	end
	if (self.hitParticleSystem ~= nil) then
		self.hitTimer = self.hitTimer + dt
		self.hitParticleSystem:setPosition(self.x, self.y)
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
		local tex = self.currentAnimation:getCurrentFrame()
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
	-- if (world and self.fixture) then
		-- local topLeftX, topLeftY, bottomRightX, bottomRightY = self.fixture:getBoundingBox()
		-- love.graphics.rectangle("line", topLeftX, topLeftY, bottomRightX - topLeftX, bottomRightY - topLeftY)
	-- end
	
	-- Affichage du bouclier
	-- love.graphics.setColor(255, 0, 0)
	-- self:drawShield()
	-- love.graphics.setPointSize(5)
	-- love.graphics.point(self.x, self.y)
	-- love.graphics.setColor(255, 255, 255)
	
	-- Affichage de la bounding box de l'épée
	-- drawBox(self:getSwordHitBox())
	
end

function mt:isDead()
    return self.life <= 0
end

function mt:getLife()
    return self.life
end

-- (x, y) La position de l'assaillant
function mt:hit(lifePoints, x, y)
    self.life = self.life - lifePoints
    if self:isDead() then
		self.currentAnimation = self.assets["die"]
		self.currentAnimation:play()
    	self.dx = 0
    	self.dy = 0
		if (self.body ~= nil) then
			self.body:setLinearVelocity(0, 0)
		end
	else
		local dx = x - self.x
		local dy = y - self.y
		local l = math.sqrt((dx * dx) + (dy * dy))
		self.body:applyLinearImpulse(-dx * 500 / l, -dy * 500 / l)
    end
	if (self.gameManager ~= nil) then
		self.gameManager.camera:shake()
	end
	self:blink({r = 255, g = 20, b = 20})
	if self:isDead() then
		local p = love.graphics.newParticleSystem(self.currentAnimation:getCurrentFrame(), 1000)
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
		local p = love.graphics.newParticleSystem(self.currentAnimation:getCurrentFrame(), 1000)
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

-- Vérifie si 'player' peut faire des dégats à 'self'
function mt:canBeHit(player)
	local x, y = self:getPosition()
	local x2,y2 = player:getPosition()
	if (not self:isDefending()) then
		return true
	else
		local p0 = ANIMATIONS[self.angle].shieldPos[1]:copy()
		local p1 = ANIMATIONS[self.angle].shieldPos[2]:copy()
		local x, y = self:getPosition()
		p0:add(x, y)
		p1:add(x, y)
		local p2 = newPoint(x2, y2)
		return determinant(p0, p1, p0, p2) < 0
	end
	
	return false
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

function mt:dash()
	if (self.dashCooldown <= 0) then
		local dx = math.cos(math.rad(self.angle + 90)) * 1000
		local dy = -math.sin(math.rad(self.angle + 90)) * 1000
		if (world ~= nil) and (self.body ~= nil) then
			self.body:applyLinearImpulse(dx, dy)
		end
		self.dashCooldown = DASH_COOLDOWN
		
		local p = love.graphics.newParticleSystem(self.currentAnimation:getCurrentFrame(), 1000)
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
		self.dashSound:play()
	end
end

function mt:tornato()
	if (self:canAttack() and (self.tornadoCooldown <= 0)) then
		self.tornadoCooldown = TORNADO_COOLDOWN
		self:beginTornadoAnimation()
		self.tornadoSound:play()
	end
end

-------------------------------------------------------
-- DEBUG
-------------------------------------------------------

function drawBox(box)
	-- love.graphics.print(math.floor(box[1].x).." "..math.floor(box[1].y).." "..
						-- math.floor(box[2].x).." "..math.floor(box[2].y).." "..
						-- math.floor(box[3].x).." "..math.floor(box[3].y).." "..
						-- math.floor(box[4].x).." "..math.floor(box[4].y).." ",
						-- 100, 100)
	love.graphics.polygon("line", box[1].x, box[1].y, 
								box[4].x, box[4].y,
								box[3].x, box[3].y,
								box[2].x, box[2].y)
end

function mt:drawShield()
	local p0 = ANIMATIONS[self.angle].shieldPos[1]:copy()
	local p1 = ANIMATIONS[self.angle].shieldPos[2]:copy()
	local x, y = self:getPosition()
	p0:add(x, y)
	p1:add(x, y)
	love.graphics.line(p0.x, p0.y, p1.x, p1.y)
end
