local level_mt = {}
level_mt.__index = level_mt


local LEVEL_MAP = {
{-01, -01, 019, 042, 042, 042, 042, 042, 005, -01},
{-01, 003, 178, 065, 065, 065, 042, 042, 021, -01},
{-01, 019, 065, 065, 065, 065, 065, 065, 021, -01},
{-01, 019, 042, 065, 065, 065, 075, 042, 021, -01},
{-01, 019, 042, 065, 065, 065, 042, 075, 021, -01},
{-01, 019, 065, 065, 065, 065, 065, 065, 021, -01},
{-01, 019, 065, 065, 065, 065, 065, 065, 021, -01},
{-01, 019, 019, 065, 065, 065, 058, 043, 021, -01},
{-01, 019, 019, 065, 065, 076, 075, 027, 176, 005},
{-01, 019, 065, 065, 065, 065, 065, 065, 065, 021},
{-01, 019, 065, 065, 065, 065, 065, 065, 065, 021},
{-01, 035, 036, 036, 036, 146, 065, 065, 065, 021},
{-01, 003, 004, 004, 004, 178, 065, 065, 065, 021},
{-01, 019, 065, 065, 065, 065, 065, 065, 144, 037},
{003, 178, 065, 065, 065, 065, 065, 065, 021, -01},
{019, 065, 065, 065, 065, 065, 065, 065, 021, -01},
{019, 065, 065, 065, 019, 019, 019, 019, 021, -01},
{019, 065, 065, 065, 065, 065, 019, 019, 021, -01},
{035, 146, 019, 065, 065, 065, 065, 065, 021, -01},
{-01, 019, 019, 065, 065, 065, 065, 065, 021, -01},
{-01, 019, 019, 019, 019, 019, 065, 065, 021, -01},
{-01, 019, 019, 065, 065, 065, 065, 065, 021, -01},
{-01, 019, 019, 065, 065, 065, 065, 065, 021, -01},
{-01, 019, 019, 065, 065, 065, 019, 019, 021, -01},
{-01, 019, 019, 065, 065, 065, 019, 019, 021, -01}
}

local LEVEL_WIDTH = 10
local LEVEL_HEIGHT = 25

local TILE_SIZE = 50

function newLevel(gameManager)
	local level = {}
	
	level.gameManager = gameManager
	
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
	
	local maxPnj = 15

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
			else
				local r = love.math.random(0, 1)
				if (r > 0.9) and (maxPnj > 0)  then
					maxPnj = maxPnj - 1
					local player = newPlayer(gameManager, 2)
					player:setPosition((i - 1) * TILE_SIZE + dx, (j - 1) * TILE_SIZE + dy + TILE_SIZE / 2 + TILE_SIZE)
					gameManager:addIAPlayer(player)
					
					local c = newIAController(player)
					getControllersManager():addController(c)
				end
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
			if (i == 1) or (i == actualWidth) or (j == 0) 
						or ((j == actualHeight) and ((i < (actualWidth / 2) - 1) or (i > (actualWidth / 2) + 2))) then
				level[j][i] = 19
			else
				local p = love.math.random(0, 1)
				if (p > 0.5) then
					level[j][i] = 65
				else
					level[j][i] = 42
				end
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