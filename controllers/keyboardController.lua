local mt = {}
mt.__index = mt

function newKeyboardController()
    local this = {}
	
	this.isKeyboard = true
	this.player = nil
    
	this.id = controller_id
	controller_id  = controller_id + 1
	
	this.serverChannel = love.thread.getChannel("serverChannel")
	
	this.lastDx = 0
	this.lastDy = 0
	
    return setmetatable(this, mt)
end

function mt:getID()
    return self.id
end

function mt:isConnected()
    return true
end

function mt:isDown(buttonN, ...)
    return love.keyboard.isDown(buttonN, ...)
end

function mt:isAnyDown()
    if love.keyboard.isDown("z", "q", "s", "d", " ", "lctrl", "return") then --ugh, what?
        return true
    end
    return false
end

function mt:isAttackButtonDown()
    
end

function mt:rumble(f)

end

function mt:getAxes()
	local x = 0
	local y = 0
    if love.keyboard.isDown("q") then
        x = -1
    elseif love.keyboard.isDown("d")  then
        x = 1
    else
        x = 0
    end
    
    if love.keyboard.isDown("z") then
        y = -1
    elseif love.keyboard.isDown("s")  then
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
	if (self.player ~= nil) then
		local dx, dy = self:getAxes()
		local oldDX, oldDY = self.player:getDirection()
		if (dx ~= self.lastDx) or (dy ~= self.lastDy) then
			self.lastDx = dx
			self.lastDy = dy
			self.serverChannel:push("player"..self.player.playerNo.." dir "..dx.." "..dy)
		end
		
		if (love.keyboard.isDown("lctrl")) then
			-- if (not self.player:isDefending() and self.player.canDefend) then
				self.serverChannel:push("player"..self.player.playerNo.." defend true")
			-- end
		else
			if (self.player:isDefending()) then
				self.serverChannel:push("player"..self.player.playerNo.." defend false")
			end
			if (love.keyboard.isDown(" ")) then
				self.serverChannel:push("player"..self.player.playerNo.." attack")
				-- self.player:attack()
			end
		end

		if (love.keyboard.isDown("k")) then
			self.player:hit(self.player.life)
		end
	end
end

function mt:draw()

end
