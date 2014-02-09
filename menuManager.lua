
local mt = {}
mt.__index = mt

function newMenuManager()
	local this = {}
	
	this.playerConnection = {}
	
	local w = love.graphics.getWidth() / 2
	local h = love.graphics.getHeight() / 2
	for i = 1, 4 do
		this.playerConnection[i] = newPlayerConnectionGui(i, ((i - 1) % 2) * w, 
															(math.floor((i - 1) / 2)) * h, 
															w, h)
	end
	
	this.controllers = {}
		
	this.gameManager = nil
	
	love.graphics.setNewFont(24)
	
	this.menuChannel = love.thread.getChannel("menuManager")
	this.serverChannel = love.thread.getChannel("serverChannel")
	
	return setmetatable(this, mt)
end

function mt:getFirstFreeConnectionUi()
	for _, ui in ipairs(self.playerConnection) do
		if (not ui:isBinded()) then
			return ui
		end
	end
	return nil
end

function mt:updateNetwork(dt)
	local msg = self.menuChannel:pop()
	while (msg ~= nil) do
		local param = msg:match("^(%S*)")
		print("Je suis le menu et je reçoie : "..param)
		if (param == "startGame") then
			self.gameManager = newGameManager(self.controllers)
		elseif (param == "newPlayer") then
			local ui = self:getFirstFreeConnectionUi()
			ui:bind(newNetworkController(nil))
		end
		msg = self.menuChannel:pop()
	end
end

function mt:update(dt)
	self:updateNetwork(dt)
	if (self.gameManager == nil) then
		if (#self.controllers < 4) then
			local added = getControllersManager():tryBindingNewController()
			if added then
				local c = getControllersManager():getUnusedController()
				self.serverChannel:push("menuManager newPlayer")
				self.controllers[#self.controllers + 1] = c
				time = love.timer.getTime()
				while (love.timer.getTime() - time) < 0.1 do
				end
			end
		end
		for _, ui in ipairs(self.playerConnection) do
			ui:update(dt)
			if (ui:ready() and (self.gameManager == nil)) then
				self.serverChannel:push("menuManager startGame")
			end
		end
	else
		self.gameManager:update(dt)
	end
end


function mt:draw()
	if (self.gameManager == nil) then
		for _, ui in ipairs(self.playerConnection) do
			ui:draw()
		end
	else
		self.gameManager:draw()
	end
end
