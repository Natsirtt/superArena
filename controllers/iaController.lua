local mt = {}
mt.__index = mt

local EXPLOSION_TIMEOUT = 5.0 -- en secondes

local ATTACK_COOLDOWN = 0.75

local ATTACK_DISTANCE = 50
local ENNEMY_DETECTION = 200

function newIAController(player)
	
    local this = {}
	
	this.player = player
	this.attackTimer = 0
	this.deathTimer = 0
	
	this.nearest = nil
	
	player.life = 2
	player.speed = player.speed / 2
	
	this.id = controller_id
	controller_id  = controller_id + 1
    
    return setmetatable(this, mt)
end

function mt:getID()
    return seld.id
end

function mt:isConnected()
    return true
end

function mt:isDown(buttonN, ...)
    return false
end

function mt:isAnyDown()
    return false
end

function mt:isAttackButtonDown()
    
end

function mt:rumble(f)

end

function mt:getAxes()
	local dx = 0
	local dy = 0
	if (self.player ~= nil) then
		local nearest = self.player.gameManager:getNearestPlayer(self.player.x, self.player.y)
		
		self.nearest = nearest
		if (nearest ~= nil) then
			local x, y = self.player:getPosition()
			local x2, y2 = nearest:getPosition()
			local d = self:getDistance(x2, y2)
			if (d < ENNEMY_DETECTION) then
				if (x2 > x) then
					dx = 1
				elseif (x2 < x) then
					dx = -1
				end
				if (y2 > y) then
					dy = 1
				elseif (y2 < y) then
					dy = -1
				end
			end
		end
	end
    
    return dx, dy
end

function mt:getX()
    local x = self:getAxes()
    return x
end

function mt:getY()
    local _, y = self:getAxes()
    return y
end

function mt:bind(player)
	self.player = player
end

function mt:update(dt)
	self.attackTimer = math.max(self.attackTimer - dt, 0)
	if (self.player ~= nil) and (not self.player:isDead()) then
		local dx, dy = self:getAxes()
		local oldDX, oldDY = self.player:getDirection()
		if (dx ~= oldDX) or (dy ~= oldDY) then
			self.player:setDirection(dx, dy)
		end
		
		if (self.nearest ~= nil) and (self.attackTimer == 0) then
			local d = self:getTargetDistance(self.nearest)
			if (d < ATTACK_DISTANCE) then
				local x, y = self.player:getPosition()
				local x2, y2 = self.nearest:getPosition()
				self.player:attack()
				self.attackTimer = ATTACK_COOLDOWN
			end
		end
	elseif (self.player ~= nil) and (self.player:isDead()) then
		self.deathTimer = self.deathTimer + dt
		if (self.deathTimer >= EXPLOSION_TIMEOUT) then
			self.player:explode()
		end
	end
end

function mt:getDistance(x2, y2)
	local x, y = self.player:getPosition()
	local d = math.sqrt((x2 - x) * (x2 - x) + (y2 - y) * (y2 - y))
	return d
end

function mt:getTargetDistance(target)
	if (target ~= nil) then
		local x, y = target:getPosition()
		return self:getDistance(x, y)
	end
	return 0
end

function mt:draw()

end
