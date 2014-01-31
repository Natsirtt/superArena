local level_mt = {}
level_mt.__index = level_mt


local LEVEL_MAP = {
{-1, -1, 19, 42, 42, 42, 42, 42, 05},
{-1, 03, 178, 65, 65, 65, 42, 42, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 42, 65, 65, 65, 75, 42, 21},
{-1, 19, 42, 65, 65, 65, 42, 75, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 58, 43, 21},
{-1, 19, 19, 65, 65, 76, 75, 27, 176, 05},
{-1, 19, 65, 65, 65, 65, 65, 65, 65, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 65, 21},
{-1, 35, 36, 36, 36, 146, 65, 65, 65, 21},
{-1, 03, 04, 04, 04, 178, 65, 65, 65, 21},
{-1, 19, 65, 65, 65, 65, 65, 65, 144, 37},
{03, 178, 65, 65, 65, 65, 65, 65, 21},
{19, 65, 65, 65, 65, 65, 65, 65, 21},
{19, 65, 65, 65, 19, 19, 19, 19, 21},
{19, 65, 65, 65, 65, 65, 19, 19, 21},
{35, 146, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 19, 19, 19, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 65, 65, 21},
{-1, 19, 19, 65, 65, 65, 19, 19, 21},
{-1, 19, 19, 65, 65, 65, 19, 19, 21}
}

local LEVEL_WIDTH = 10
local LEVEL_HEIGHT = 25

local TILE_SIZE = 50

function newLevel()
	local level = {}
	
	level.tileSet = love.graphics.newImage("assets/tileset.png")
	level.width = 0
	level.height = 0
	level.map = nil
	
	level.particleEffects = {}
	
	local m, w, h = generateLevel()
	level.width = w
	level.height = h
	level.map = m
	
	local dx = ARENA_WIDTH * TILE_SIZE / 2 - TILE_SIZE * w / 2
    local dy = -TILE_SIZE * h
	
	level.boxes = {}
	for j, t in ipairs(level.map) do
		level.boxes[j] = {}
		for i, tileID in ipairs(t) do
			if (tileID ~= 65) then
				local body = love.physics.newBody(world, 0, 0, "static")
				body:setMassData(0, 0, 10, 0)
				local shape = love.physics.newPolygonShape(-TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, TILE_SIZE / 2,
														-TILE_SIZE / 2, TILE_SIZE / 2)
				local fixture = love.physics.newFixture(body, shape, 1)
				fixture:setFriction(10000)
				level.boxes[j][i] = fixture
				body:setPosition((i - 1) * TILE_SIZE + dx, (j - 1) * TILE_SIZE + dy + TILE_SIZE / 2 + TILE_SIZE)
			end
		end
	end

	return setmetatable(level, level_mt)
end

function level_mt:update(dt)
	for _, p in ipairs(self.particleEffects) do
		p:update(dt)
	end
end

function level_mt:draw()
	for j, t in ipairs(self.map) do
		for i, tileID in ipairs(t) do
			if (tileID ~= nil) and (tileID ~= -1) then
				drawAsset(tileID, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
			end
		end
	end
	for _, p in ipairs(self.particleEffects) do
		love.graphics.draw(p)
	end
	-- Debug
	-- love.graphics.push()
	-- love.graphics.origin()
	-- love.graphics.setColor(255, 255, 255)
	-- for j, t in ipairs(self.boxes) do
		-- for i, box in ipairs(t) do
			-- local topLeftX, topLeftY, bottomRightX, bottomRightY = self.boxes[j][i]:getBoundingBox()
			-- love.graphics.rectangle("line", topLeftX, topLeftY, bottomRightX - topLeftX, bottomRightY - topLeftY)
		-- end
	-- end
	-- love.graphics.pop()
end

function level_mt:getWidth()
	return TILE_SIZE * self.width
end

function level_mt:getHeight()
	return TILE_SIZE * self.height
end


function generateLevel()
	local level = {}
	local minWidth = 25
	local maxWidth = 50
	local minHeight = 25
	local maxHeight = 50
	
	local actualWidth = love.math.random(minWidth, maxWidth)
	local actualHeight = love.math.random(minHeight, maxHeight)
	
	for j = 1, actualHeight do
		level[j] = {}
		for i = 1, actualWidth do
			local p = love.math.random(0, 1)
			if (p > 0.5) then
				level[j][i] = 65
			else
				level[j][i] = 42
			end
		end
	end
	
	return level, actualWidth, actualHeight
end

-- Renvoie la hitBox du tile i, j
function level_mt:getHitBox(i, j)
	local topLeftX, topLeftY, bottomRightX, bottomRightY = self.boxes[j][i]:getBoundingBox()
	-- print(topLeftX.." "..topLeftY.." "..bottomRightX.." "..bottomRightY)
	return {
		{x = topLeftX,     y = topLeftY     },
		{x = bottomRightX, y = topLeftY     },
		{x = bottomRightX, y = bottomRightY },
		{x = topLeftX,     y = bottomRightY }
	}
end

function level_mt:breakTile(i, j)
	self.map[j][i] = 65
	self.boxes[j][i]:destroy()
	self.boxes[j][i] = nil
end

function level_mt:hit(box)
	for j, t in ipairs(self.map) do
		for i, tileID in ipairs(t) do
			if (tileID ~= nil) and (tileID == 42) and (self.boxes[j][i] ~= nil) then
				local hitbox = self:getHitBox(i, j)
				if (rectCollision(hitbox, box)) then
					self:breakTile(i, j)
					self:smoke((i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
				end
			end
		end
	end
end

-- Créé un effet de fumé en x, y
function level_mt:smoke(x, y)
	local p = love.graphics.newParticleSystem(love.graphics.newImage("assets/smoke.png"), 1000)
	p:setEmissionRate(20)
	p:setSpeed(520, 400)
	p:setPosition(x, y)
	p:setEmitterLifetime(0.3)
	p:setParticleLifetime(0.3)
	p:setDirection(0)
	p:setSpread(368)
	p:setRadialAcceleration(-5200)
	p:setTangentialAcceleration(1000)
	p:stop()
	self.particleEffects[#self.particleEffects + 1] = p
	p:start()
end