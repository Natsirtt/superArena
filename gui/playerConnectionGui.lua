local mt = {}
mt.__index = mt

local playerColor = {
{r = 66, g = 195, b = 255},
{r = 176, g = 20, b = 20},
{r = 20, g = 176, b = 27},
{r = 204, g = 27, b = 208},
}

function newPlayerConnectionGui(id, x, y, w, h)
	local this = {}
	
	this.id = id
	this.x = x
	this.y = y
	this.w = w
	this.h = h
	
	this.controller = nil
	
	this.canStart = false
	this.start = false
	
	this.player = nil
	
	return setmetatable(this, mt)
end

function mt:isBinded()
	return self.controller ~= nil
end

function mt:bind(controller)
	self.controller = controller
	self.player = newPlayer(nil, self.id)
	self.player:setDirection(0, 1)
	self.player.angle = 180
	if (controller.isGamePad) or (controller.isKeyboard) then
		self.controller:bind(self.player)
	end	
end

function mt:update(dt)
	if (self.player ~= nil) then
		self.controller:update(dt)
		self.player:update(dt)
		self.player:setPosition(self.x + self.w / 2, self.y + self.h / 2 + 75)
	end
	if (self:isBinded() and (not self.controller:isAnyDown())) then
		self.canStart = true
	end
	if (self.canStart) then
		if (self.controller.isGamePad and self.controller:isDown(self.controller:getStartButton())) then
			self.start = true
		elseif self.controller.isKeyboard and self.controller:isDown("return") then
			self.start = true
		elseif (not self.controller.isGamePad) and 
				(not self.controller.isKeyboard) and (self.controller:isAnyDown()) then
			self.start = true
		end
	end
end

function mt:ready()
	return self.start
end


function mt:draw()
	local font = love.graphics.getFont()
	if (self:isBinded()) then
		local color = playerColor[self.id]
		love.graphics.setColor(color.r, color.g, color.b)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
		love.graphics.setColor(255, 255, 255)
		
		local s = "Joueur "..self.id
		local length = font:getWidth(s)
		love.graphics.print(s, self.x + self.w / 2 - length / 2, self.y + self.h / 2 - 50)
		if (self.controller.isGamePad) then
			s = "Start pour lancer le jeu !"
		elseif (self.controller.isKeyboard) then
			s = "Appuyer sur Entrée pour lancer le jeu !"
		else
			s = "Appuyer pour lancer le jeu !"
		end
		length = font:getWidth(s)
		love.graphics.print(s, self.x + self.w / 2 - length / 2, self.y + self.h / 2)
		
		if (self.player ~= nil) then
			self.player:draw()
		end
	else
		local s = "Joueur "..self.id
		local length = font:getWidth(s)
		love.graphics.print(s, self.x + self.w / 2 - length / 2, self.y + self.h / 2 - 50)
		s = "Appuyer sur un bouton pour commencer"
		length = font:getWidth(s)
		love.graphics.print(s, self.x + self.w / 2 - length / 2, self.y + self.h / 2)
	end
	
end
