local mt = {}
mt.__index = mt


function newIAController(player)
	
    local this = {}
	
	this.player = player
	
	this.nearest = nil
    
    return setmetatable(this, mt)
end

function mt:getID()
    return -1
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
	local x = 0
	local y = 0
	if (self.player ~= nil) then
		local nearest = self.player.gameManager:getNearestPlayer(self.player.x, self.player.y)
		
		self.nearest = nearest
		if (nearest ~= nil) then
			if (nearest.x > self.player.x) then
				x = 1
			elseif (nearest.x < self.player.x) then
				x = -1
			end
			if (nearest.y > self.player.y) then
				y = 1
			elseif (nearest.y < self.player.y) then
				y = -1
			end
		end
	end
    
    return x, y
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
	if (self.player ~= nil) then
		local dx, dy = self:getAxes()
		local oldDX, oldDY = self.player:getDirection()
		if (dx ~= oldDX) or (dy ~= oldDY) then
			self.player:setDirection(dx, dy)
		end
		
		if (self.nearest) then
			local x = self.player.x
			local y = self.player.y
			local x2 = self.nearest.x
			local y2 = self.nearest.y
			local d = math.sqrt((x2 - x) * (x2 - x) - (y2 - y) * (y2 - y))
			if (d < 30) then
				self.player:attack()
			end
		end
	end
end
