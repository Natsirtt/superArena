local mt = {}
mt.__index = mt

function newGamepadController(joystick)
    local this = {}
    
	this.isGamePad = true
    this.joystick = joystick
	this.player = nil
    
    return setmetatable(this, mt)
end

function mt:getStartButton()
	return 4
end

function mt:getID()
    return self.joystick:getID()
end

function mt:isConnected()
    return self.joystick:isConnected()
end

function mt:isDown(buttonN, ...)
    return self.joystick:isDown(buttonN, ...)
end

function mt:isAnyDown()
    if self:isDown(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22) then --ugh, what?
        return true
    end
    return false
end

function mt:isAttackButtonDown()
    
end

function mt:rumble(f)
	if (self.joystick:isVibrationSupported()) then
		self.joystick:setVibration(f, f)
	end
end

function mt:getAxes()
    local x, y = self.joystick:getAxes()
    
    if x <= -0.5 then
        x = -1
    elseif x >= 0.5 then
        x = 1
    else
        x = 0
    end
    
    if y <= -0.5 then
        y = -1
    elseif y >= 0.5 then
        y = 1
    else
        y = 0
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
	if (self.player ~= nil) and (self.joystick:isConnected()) then
		local dx, dy = self:getAxes()
		local oldDX, oldDY = self.player:getDirection()
		if (dx ~= oldDX) or (dy ~= oldDY) then
			self.player:setDirection(dx, dy)
		end
		
		if (self:isDown(11)) then
			self.player:setDefending(true)
		else
			self.player:setDefending(false)
			if (self:isDown(10)) then
				self.player:attack()
			end
		end

		if (self:isDown(13)) then
			self.player:hit(self.player.life)
		end
	end
end

function mt:draw()

end
