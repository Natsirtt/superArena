local mt = {}
mt.__index = mt

function newSuperCanvas(width, height)
    local this = {}

    this.width = width
	this.height = height
	
	local maxSize = love.graphics.getMaxImageSize()
	
	this.actualWidth = math.min(width, maxSize)
	this.actualHeight = math.min(height, maxSize)
	
	this.nbWidth = math.ceil(width / maxSize)
	this.nbHeight =  math.ceil(height / maxSize)
	
	this.baseCanvases = {}
    	
	for i = 1, this.nbHeight do
        this.baseCanvases[i]= {}
        for j = 1, this.nbWidth do
            this.baseCanvases[i][j] = love.graphics.newCanvas(this.actualWidth, this.actualHeight)
        end
	end
	
    return setmetatable(this, mt)
end

function mt:clear()
	for _, tab in ipairs(self.baseCanvases) do
        for _, canvas in ipairs(tab) do
            canvas:clear()
        end
	end
end

function mt:getWidth()
	return self.width
end

function mt:getHeight()
    return self.height
end

function mt:drawTo(func, param1, param2, param3)
	for i, tab in ipairs(self.baseCanvases) do
        for j, canvas in ipairs(tab) do
            love.graphics.setCanvas(canvas)
            
            love.graphics.push()
            love.graphics.translate(-(j - 1) * self.actualWidth, -(i - 1) * self.actualHeight)
            
            func(param1, param2, param3)
            
            love.graphics.pop()
        end
	end
    love.graphics.setCanvas(nil)
end

function mt:draw()
	for i, tab in ipairs(self.baseCanvases) do
        for j, canvas in ipairs(tab) do
            love.graphics.push()
            love.graphics.translate((j - 1) * self.actualWidth, (i - 1) * self.actualHeight)
            love.graphics.draw(canvas)
            love.graphics.pop()
        end
	end
end
