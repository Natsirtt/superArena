local mt = {}
mt.__index = mt

function newNetworkController(player)
	
    local this = {}
	
	this.player = player
	
	this.dx = 0
	this.dy = 0
	
	-- this.controllerChannel = love.thread.getChannel("player"..player.playerNo)

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
	local dx = 0
	local dy = 0
    
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
	-- local msg = self.controllerChannel:pop()
	-- while (msg ~= nil) then		
		-- local life, x, y, dx, dy, angle, attack, defense = msg:match("^(%d*) (%d*) (%d*) (%d*) (%d*) (%d*) (%d*)")
		
		-- self.player.life = tonumber(life)
		-- self.player.setPosition(tonumber(x), tonumber(y))
		-- self.player.setDirection(tonumber(dx), tonumber(dy))
		-- self.player.angle = tonumber(angle)
		
		-- if (tonumber(defense) == 1) then
			-- self.player:setDefending(true)
		-- else
			-- self.player:setDefending(false)
			-- if (tonumber(attack) == 1) then
				-- self.player:attack()
			-- end
		-- end
		
		-- msg = self.controllerChannel:pop()
	-- end
end

function mt:draw()

end
