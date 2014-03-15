local mt = {}
mt.__index = mt

local FRAME_SIZE = 150

-----------------------------------------------
-- 
-- @param index Le tableau de l'index des frames à jouer
-- @param speed La vitesse en frames par seconde
-----------------------------------------------
function newAnimation(tileset, index, speed, toRepeat)
    local self = {}
	
	self.tileset = tileset
	self.index = index
	self.speed = speed
	self.toRepeat = toRepeat
	
	self.frames = {}
	
	local width = math.floor(self.tileset:getWidth() / FRAME_SIZE)
	local imageData = self.tileset:getData()
	local nid = love.image.newImageData(FRAME_SIZE, FRAME_SIZE)
	for _, ind in ipairs(self.index) do
		if (self.frames[ind] == nil) then
			local x = ind % width
			local y = math.floor(ind / width)
			nid:paste(imageData, 0, 0, x * FRAME_SIZE, y * FRAME_SIZE, FRAME_SIZE, FRAME_SIZE)
			self.frames[ind] = love.graphics.newImage(nid)
		end
	end
	
	self.currentFrame = 1
	self.finish = false
    
    return setmetatable(self, mt)
end

function mt:play()
	self.currentFrame = 1
	self.finish = false
end

function mt:update(dt)
	if (not self.finish) then
		self.currentFrame = self.currentFrame + self.speed * dt
		if (self.currentFrame >= #self.index + 1) then
			if (self.toRepeat) then
				self.currentFrame = self.currentFrame - #self.index
			else
				self.currentFrame = #self.index
				self.finish = true
			end
		end
	end
end

function mt:getCurrentFrame()
	return self.frames[self.index[math.floor(self.currentFrame)]]
end

function mt:getCurrentFrameIndex()
	return self.index[math.floor(self.currentFrame)]
end

function mt:isFinished()
	return self.finish
end