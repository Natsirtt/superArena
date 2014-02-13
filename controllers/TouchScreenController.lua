local mt = {}
mt.__index = mt

function newTouchScreenController()
    local this = {}
    	
	this.player = nil
	
	this.id = controller_id
	controller_id  = controller_id + 1
	
	this.minStickRadius = 50
	this.maxStickRadius = 150
	this.stickX = this.maxStickRadius
	this.stickY = love.graphics.getHeight() - this.maxStickRadius
	
	this.movePressed = false
	this.lastMoveTouchX = this.stickX
	this.lastMoveTouchY = this.stickY
	this.moveTouchId = -1     -- l'id du touch (valable jusqu'à la fin du touch)
	this.moveTouchNumber = -1 -- Le numéro du touch si on drag (valable pour une frame)
	
	this.buttonRadius = 70
	this.shieldX = love.graphics.getWidth() - this.buttonRadius * 2
	this.attackX = this.shieldX - this.buttonRadius * 2
	this.attackY = love.graphics.getHeight() - this.buttonRadius * 2
	this.shieldY = this.attackY - this.buttonRadius
	
	
	this.joystick = nil
	
	this.attackDown = false
	this.shieldDown = false
	
	for _, j in ipairs(love.joystick.getJoysticks()) do
		if (j:getName() == "Android Accelerometer") then
			this.joystick = j
		end
	end
	
	this.attackIcon = love.graphics.newImage("assets/ui/btn_attack.png")
	this.shieldIcon = love.graphics.newImage("assets/ui/btn_defense.png")
	
	this.serverChannel = love.thread.getChannel("serverChannel")
	
    return setmetatable(this, mt)
end

function mt:getID()
    return this.id
end

function mt:isConnected()
    return love.touch
end


-- 0 --> Touche d'attaque
-- 1 --> Touche de défense
function mt:isDown(button)
	if (button == 0) then 
		return self.attackDown
	elseif (button == 1) then
		return self.shieldDown
	end
	
    return false
end

function mt:isAnyDown()
    return love.touch and (love.touch.getTouchCount() > 0)
end

function mt:rumble(f)
	if self.joystick:isVibrationSupported() then
		self.joystick:setVibration(f, f)
	end
end

function mt:getAxes()
	if (not self:isConnected()) then
		return 0, 0
	end
	if (not self.movePressed) or (self.moveTouchNumber == -1) then
		return 0, 0
	end
	
	local _, tx, ty = love.touch.getTouch(self.moveTouchNumber)
	tx = tx * love.graphics.getWidth()
	ty = ty * love.graphics.getHeight()
	local x = 0
	local y = 0
			
    if tx < (self.stickX - self.minStickRadius) then
        x = -1
    elseif tx > (self.stickX + self.minStickRadius) then
        x = 1
    else
        x = 0
    end
    
    if ty < (self.stickY - self.minStickRadius) then
        y = -1
    elseif ty > (self.stickY + self.minStickRadius) then
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

function mt:updateMoveStick()
	if (love.touch) then
		if (not self.movePressed) then
			local count = love.touch.getTouchCount()
			for i = 1, count do
				local tid, tx, ty = love.touch.getTouch(i)
				tx = tx * love.graphics.getWidth()
				ty = ty * love.graphics.getHeight()
				local xp = (tx - self.stickX)
				local yp = (ty - self.stickY)
				local d = math.sqrt((xp * xp) + (yp * yp))
				self.movePressed =  d < self.minStickRadius
				if (self.movePressed) then
					self.moveTouchId = tid
					return
				end
			end
		else
			local found = false
			self.moveTouchNumber = -1
			local count = love.touch.getTouchCount()
			for i = 1, count do
				local tid, tx, ty = love.touch.getTouch(i)
				if (tid == self.moveTouchId) then
					found = true	
					tx = tx * love.graphics.getWidth()
					ty = ty * love.graphics.getHeight()
					local xp = (tx - self.stickX)
					local yp = (ty - self.stickY)
					local d = math.sqrt((xp * xp) + (yp * yp))
					if (d > self.maxStickRadius) then
						xp = xp / d
						yp = yp / d
						self.lastMoveTouchX = self.stickX + xp * self.maxStickRadius
						self.lastMoveTouchY = self.stickY + yp * self.maxStickRadius
					else
						self.lastMoveTouchX = tx
						self.lastMoveTouchY = ty
					end
						
					if (d > self.minStickRadius) then
						self.moveTouchNumber = i
					end
				end
			end
			if (not found) then
				self.moveTouchId = -1
				self.lastMoveTouchX = self.stickX
				self.lastMoveTouchY = self.stickY
			end
			self.movePressed = found
		end
	end
end

function mt:updateButton()
	self.attackDown = false
	self.shieldDown = false
	if (love.touch) then
		local count = love.touch.getTouchCount()
		for i = 1, count do
			local _, tx, ty = love.touch.getTouch(i)
			tx = tx * love.graphics.getWidth()
			ty = ty * love.graphics.getHeight()
			local xp = (tx - self.attackX)
			local yp = (ty - self.attackY)
			local d = math.sqrt((xp * xp) + (yp * yp))
			self.attackDown = self.attackDown or (d < self.buttonRadius)
			xp = (tx - self.shieldX)
			yp = (ty - self.shieldY)
			d = math.sqrt((xp * xp) + (yp * yp))
			self.shieldDown =  self.shieldDown or (d < self.buttonRadius)
		end
	end
end

function mt:update(dt)
	if (self.player ~= nil) and (self:isConnected()) then
		self:updateMoveStick()
		self:updateButton()
			
		local dx, dy = self:getAxes()
		local oldDX, oldDY = self.player:getDirection()
		if (dx ~= oldDX) or (dy ~= oldDY) then
			self.serverChannel:push("player"..self.player.playerNo.." dir "..dx.." "..dy)
		end
		
		if (self:isDown(1)) then
			self:rumble(1.0)
			self.serverChannel:push("player"..self.player.playerNo.." defend true")
		else
			if (self.player:isDefending()) then
				self.serverChannel:push("player"..self.player.playerNo.." defend false")
			end
			if (self:isDown(0)) then
				self:rumble(1.0)
				self.player:attack()
				self.serverChannel:push("player"..self.player.playerNo.." attack")
			else
				self:rumble(0.0)
			end
		end
	end
end

function mt:draw()
	love.graphics.push()
	
	love.graphics.origin()
	
	if (self.attackDown) then
		love.graphics.setColor(255, 0, 0)
	end
	love.graphics.circle("line", self.attackX, self.attackY, self.buttonRadius)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.attackIcon, self.attackX - self.attackIcon:getWidth() / 2, self.attackY - self.attackIcon:getHeight() / 2)
	
	if (self.shieldDown) then
		love.graphics.setColor(255, 0, 0)
	end
	love.graphics.circle("line", self.shieldX, self.shieldY, self.buttonRadius)
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.shieldIcon, self.shieldX - self.shieldIcon:getWidth() / 2, self.shieldY - self.shieldIcon:getHeight() / 2)
	
	if (self.movePressed) then
		love.graphics.setColor(255, 0, 0)
	end
	love.graphics.circle("line", self.lastMoveTouchX, self.lastMoveTouchY, self.minStickRadius)
	love.graphics.setColor(255, 255, 255)
	
	if (self.moveTouchNumber ~= -1) then
		love.graphics.setColor(255, 0, 0)
	end
	love.graphics.circle("line", self.stickX, self.stickY, self.maxStickRadius)
	love.graphics.setColor(255, 255, 255)
	
	-- if (self.joystick ~= nil) then
		-- love.graphics.print("Joystick ", 200, 200)
		-- if (self.joystick:isVibrationSupported()) then
			-- love.graphics.print("Joystick Vibration OK", 200, 250)
		-- end
	-- end
		
	love.graphics.pop()
end
