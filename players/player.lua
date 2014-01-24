local mt = {}
mt.__index = mt

local MAX_LIFE = 10
local SPEED_BASE = 100
local RADIUS = 20

function newPlayer()
    local this = {}
    
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
            w = RADIUS,
            h = RADIUS}
end

function mt:setPositionFromQuad(quad)
    self.x = quad.x
    self.y = quad.y
end

function mt:update(dt)
    self.dx, self.dy = self.controller:getAxes()
    self.x = self.x + dt * self.dx * self.speed
    self.y = self.y + dt * self.dy * self.speed
end

function mt:draw()
    love.graphics.circle("fill", self.x, self.y, RADIUS, 10)
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
