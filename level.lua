local level_mt = {}
level_mt.__index = level_mt


-- local LEVEL_MAP = {
-- {-01, -01, 019, 042, 042, 042, 042, 042, 005, -01},
-- {-01, 003, 178, 065, 065, 065, 042, 042, 021, -01},
-- {-01, 019, 065, 065, 065, 065, 065, 065, 021, -01},
-- {-01, 019, 042, 065, 065, 065, 075, 042, 021, -01},
-- {-01, 019, 042, 065, 065, 065, 042, 075, 021, -01},
-- {-01, 019, 065, 065, 065, 065, 065, 065, 021, -01},
-- {-01, 019, 065, 065, 065, 065, 065, 065, 021, -01},
-- {-01, 019, 019, 065, 065, 065, 058, 043, 021, -01},
-- {-01, 019, 019, 065, 065, 076, 075, 027, 176, 005},
-- {-01, 019, 065, 065, 065, 065, 065, 065, 065, 021},
-- {-01, 019, 065, 065, 065, 065, 065, 065, 065, 021},
-- {-01, 035, 036, 036, 036, 146, 065, 065, 065, 021},
-- {-01, 003, 004, 004, 004, 178, 065, 065, 065, 021},
-- {-01, 019, 065, 065, 065, 065, 065, 065, 144, 037},
-- {003, 178, 065, 065, 065, 065, 065, 065, 021, -01},
-- {019, 065, 065, 065, 065, 065, 065, 065, 021, -01},
-- {019, 065, 065, 065, 019, 019, 019, 019, 021, -01},
-- {019, 065, 065, 065, 065, 065, 019, 019, 021, -01},
-- {035, 146, 019, 065, 065, 065, 065, 065, 021, -01},
-- {-01, 019, 019, 065, 065, 065, 065, 065, 021, -01},
-- {-01, 019, 019, 019, 019, 019, 065, 065, 021, -01},
-- {-01, 019, 019, 065, 065, 065, 065, 065, 021, -01},
-- {-01, 019, 019, 065, 065, 065, 065, 065, 021, -01},
-- {-01, 019, 019, 065, 065, 065, 019, 019, 021, -01},
-- {-01, 019, 019, 065, 065, 065, 019, 019, 021, -01}
-- }

local MAX_PNJ = 50
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
	
	local c1, c2 = getLevelCanvas(nil, nil, level.map, TILE_SIZE * w, TILE_SIZE * h)
	level.canvas = c1 -- Le canvas du sol
	level.objectCanvas = c2 -- Le canvas des caisses et objets
	level.bloodCanvas = love.graphics.newCanvas(TILE_SIZE * w, TILE_SIZE * h) -- Le canvas du sang
	
	level.dx = ARENA_WIDTH * TILE_SIZE / 2 - TILE_SIZE * w / 2
    level.dy = -TILE_SIZE * h
	
	level.controllers = {} -- Les controllers des pnj
	
	local maxPnj = MAX_PNJ

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
				body:setPosition((i - 1) * TILE_SIZE + level.dx, (j - 1) * TILE_SIZE + level.dy + TILE_SIZE / 2 + TILE_SIZE)
			else
				local r = love.math.random()
				if (r > 0.9) and (maxPnj > 0)  then
					-- On ajout un controller à la liste
					-- Le controller n'est pas spawn par défaut (appeler spawn())
					maxPnj = maxPnj - 1
					local player = newPlayer(gameManager, -1)
					player:setPosition((i - 1) * TILE_SIZE + level.dx, (j - 1) * TILE_SIZE + level.dy + TILE_SIZE / 2 + TILE_SIZE)
					
					local c = newIAController(player)
					level.controllers[#level.controllers + 1] = c
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
	love.graphics.draw(self.canvas)
	love.graphics.draw(self.bloodCanvas)
	love.graphics.draw(self.objectCanvas)
	
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
			if (i == 1) or (i == actualWidth) or (j == 1) 
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
	love.graphics.setCanvas(self.objectCanvas)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setBlendMode("replace")
	love.graphics.setColor(255, 255, 255, 0)
	love.graphics.rectangle("fill", (i - 1) * TILE_SIZE - TILE_SIZE / 2, (j - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
	love.graphics.setBlendMode("alpha")
	love.graphics.setCanvas()
	love.graphics.setColor(r, g, b, a)
end

function level_mt:hit(box)
	local regen = false
	
	local maxDistSqr = SWORD_LENGTH * SWORD_LENGTH
	local m = getQuadCenter(box)
	
	local minX = box[1].x 
	local maxX = box[1].x
	local minY = box[1].y
	local maxY = box[1].y
	for i = 2, #box do
		if (box[i].x < minX) then
			minX = box[i].x
		elseif (box[i].x > maxX) then
			maxX = box[i].x
		end
		if (box[i].y < minY) then
			minY = box[i].y
		elseif (box[i].y > maxY) then
			maxY = box[i].y
		end
	end
	
	minX = math.max(math.floor((minX - self.dx - SWORD_LENGTH) / TILE_SIZE), 0)
	maxX = math.ceil((maxX - self.dx + SWORD_LENGTH) / TILE_SIZE)
	minY = math.max(math.floor((minY - self.dy - SWORD_LENGTH) / TILE_SIZE), 0)
	maxY = math.min(math.ceil((maxY - self.dy + SWORD_LENGTH) / TILE_SIZE), self.height)
	
	for j = minY, maxY do
		local t = self.map[j]
		maxX = math.min(maxX, #t)
		for i = minX, maxX do
			local tileID = t[i]
			if (tileID ~= nil) and (tileID == 42) and (self.boxes[j][i] ~= nil) then
				local x2 = (i - 1) * TILE_SIZE + self.dx
				local y2 = (j - 1) * TILE_SIZE + self.dy + TILE_SIZE / 2 + TILE_SIZE
				local d = (m.x - x2) * (m.x - x2) + (m.y - y2) * (m.y - y2)
				if (d <= maxDistSqr) then
					local hitbox = self:getHitBox(i, j)
					if (rectCollision(hitbox, box)) then
						regen = true
						self:breakTile(i, j)
						self:smoke((i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
					end
				end
			end
		end
	end
	-- Inutile car "breakTile" met automatiquement à jours
	-- if (regen) then
		-- self.canvas = getLevelCanvas(self.canvas, self.map, TILE_SIZE * self.width, TILE_SIZE * self.height)
	-- end
end

-- Créé un effet de fumé en x, y
function level_mt:smoke(x, y)
	local p = love.graphics.newParticleSystem(getAssetsManager():getSmoke(), 100)
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

-- Renvoie un nouveau canvas 
-- @param oldCanvas, si différent de nil, utilise l'ancien canvas
function getLevelCanvas(oldCanvas, oldObjectCanvas, tiles, width, height)
	local canvas = oldCanvas
	local objectCanvas = oldObjectCanvas
	if (canvas == nil) then
		canvas = love.graphics.newCanvas(width, height)
	end
	if (objectCanvas == nil) then
		objectCanvas = love.graphics.newCanvas(width, height)
	end
	love.graphics.setColor(255, 255, 255)
	love.graphics.setCanvas(canvas)
	for j, t in ipairs(tiles) do
		for i, tileID in ipairs(t) do
			if (tileID ~= nil) and (tileID ~= -1) then
				if (tileID == 42) then
					love.graphics.setCanvas(objectCanvas)
					drawAsset(tileID, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
					love.graphics.setCanvas(canvas)
					drawAsset(65, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
				else
					drawAsset(tileID, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
				end
			end
		end
	end
	love.graphics.setCanvas()
	return canvas, objectCanvas
end

local blood = love.graphics.newImage("assets/blood.png")

function level_mt:blood(x, y)
	love.graphics.setCanvas(self.bloodCanvas)
	love.graphics.draw(blood, -self.dx + x - blood:getWidth() / 2, -self.dy + y - blood:getHeight() / 2)
	love.graphics.setCanvas()
end

function level_mt:spawn()
	for _, c in ipairs(self.controllers) do
		getControllersManager():addController(c)
		self.gameManager:addIAPlayer(c.player)
	end
end