local mt = {}
mt.__index = mt

function newIAController(player)

	if (player == nil) then
		love.event.quit()
	end
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
			print(nearest:getNumber())
			if (nearest.x > self.player.x) then
				x = -1
			elseif (nearest.x < self.player.x) then
				x = 1
			end
			if (nearest.y > self.player.y) then
				y = -1
			elseif (nearest.y < self.player.y) then
				y = 1
			end
		else
			print("nil")
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
	print("update")
	if (self.player ~= nil) then
		print("update2")
		local dx, dy = self:getAxes()
		local oldDX, oldDY = self.player:getDirection()
		if (dx ~= oldDX) or (dy ~= oldDY) then
			self.player:setDirection(dx, dy)
		end
		
		local x = self.player.x
		local y = self.player.y
		local x2 = nearest.x
		local y2 = nearest.y
		local d = math.sqrt((x2 - x) * (x2 - x) - (y2 - y) * (y2 - y))
		if (d < 30) then
			self.player:attack()
		end
	else
		print("nil player")
	end
end
