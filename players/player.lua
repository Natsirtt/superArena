local mt = {}
mt.__index = mt

local MAX_LIFE = 10
local SPEED_BASE = 500
local RADIUS = 20

local PLAYER_TILE = {x = 350, y = 0, width = 50, height = 50}

function newPlayer()
    local this = {}
	this.tileSet = love.graphics.newImage("tileset.png")
    
	this.angle = 0
    this.x = 400
    this.y = 400
    this.dx = 0
    this.dy = 0
    this.speed = SPEED_BASE
    this.hitbox = {}
    this.controller = getControllersManager():getUnusedController()
    
    --if this.controller == nil then
        -- should not happen if we use stuff correctly
    --end
    
    this.life = MAX_LIFE
    
    return setmetatable(this, mt)
end

function mt:getQuad()
    return {x = self.x - RADIUS,
            y = self.y - RADIUS,
            w = RADIUS * 2,
            h = RADIUS * 2}
end

function mt:setPositionFromQuad(quad)
    self.x = quad.x + RADIUS
    self.y = quad.y + RADIUS
end

function mt:update(dt)
    self.dx, self.dy = self.controller:getAxes()
    self.x = self.x + dt * self.dx * self.speed
    self.y = self.y + dt * self.dy * self.speed
	
	if (self.dx == -1) and (self.dy == -1) then
		self.angle = 45
	elseif (self.dx == -1) and (self.dy == 0) then
		self.angle = 90
	elseif (self.dx == -1) and (self.dy == 1) then
		self.angle = 135
	elseif (self.dx == 1) and (self.dy == -1) then
		self.angle = -45
	elseif (self.dx == 1) and (self.dy == 0) then
		self.angle = -90
	elseif (self.dx == 1) and (self.dy == 1) then
		self.angle = -135
	elseif (self.dx == 0) and (self.dy == -1) then
		self.angle = 0
	elseif (self.dx == 0) and (self.dy == 1) then
		self.angle = 180
	end
end

function mt:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(math.rad(-self.angle))
	local quad = love.graphics.newQuad(PLAYER_TILE.x, PLAYER_TILE.y, PLAYER_TILE.width, PLAYER_TILE.height, self.tileSet:getWidth(), self.tileSet:getHeight())
	love.graphics.draw(self.tileSet, quad, 0 - RADIUS, 0 - RADIUS, 0, RADIUS * 2 / 50, RADIUS * 2 / 50)
	
	love.graphics.pop()
	
	love.graphics.print(self.dx.." "..self.dy, 100, 100)
end

function mt:isDead()
    return self.life <= 0
end

function mt:getLife()
    return self.life
end

function mt:hit(lifePoints)
    self.life = self.life - lifePoints
end

function mt:heal(lifePoints)
    self.life = self.life + lifePoints
    if self.life > MAX_LIFE then
        self.life = MAX_LIFE
    end
end
