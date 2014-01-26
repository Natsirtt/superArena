local arena_mt = {}
arena_mt.__index = arena_mt

local ARENA_WIDTH = 20
local ARENA_HEIGHT = 20

local TILE_SIZE = 50

--                  id de l'asset
local left          = 12
local right         = 13
local top           = 10
local bottom        = 15
local topLeft       = 9
local bottomLeft    = 14
local topRight      = 11
local bottomRight   = 16
local center        = 4
local porte         = 24
local porteDetruite = -1
local public        = {x = 300, y = 0, width = 15, height = 15}
local public2       = {x = 300, y = 15, width = 15, height = 15}
local publicDown    = {x = 315, y = 0, width = 15, height = 15}
local publicDown2   = {x = 315, y = 15, width = 15, height = 15}

function newArena()
	local arena = {}
	
	arena.tileSet = love.graphics.newImage("assets/tileset.png")
	arena.tiles = {}
	arena.publicTimer = 0
	arena.hasLeftDoor = true
	arena.hasRightDoor = true
	arena.boxes = {}
	
	for i = 1, ARENA_WIDTH do
		arena.tiles[i] = {}
		for j = 1, ARENA_HEIGHT do
			local tile = nil
			if (i == 1) and (j == 1) then
				-- Partie haute gauche
				tile = topLeft
			elseif (i == 1) and (j == ARENA_HEIGHT) then
				-- Partie bas gauche
				tile = bottomLeft
			elseif (j == ARENA_HEIGHT / 2) and (i == 1) then
				-- Porte gauche
				tile = porteGauche
				arena.porteGauche = {x = i, y = j}
			elseif (j == ARENA_HEIGHT / 2) and (i == ARENA_WIDTH) then
				-- Porte droite
				tile = porteDroite
				arena.porteDroite = {x = i, y = j}
			elseif (i == 1) then
				-- Partie gauche
				tile = left
			elseif (j == 1) and (i == ARENA_WIDTH) then
				-- Partie haute droite
				tile = topRight
			elseif (j == 1)  then
				-- Partie haute
				tile = top
			elseif (i == ARENA_WIDTH) and (j == ARENA_HEIGHT) then
				-- PARTIE bas droite
				tile = bottomRight
			elseif (i == ARENA_WIDTH) then
				-- PARTIE droite
				tile = right
			elseif (j == ARENA_HEIGHT) then
				-- PARTIE bas
				tile = bottom
			else
				tile = center
			end
			
			arena.tiles[i][j] = tile;
		end
	end
	
	for i, t in ipairs(arena.tiles) do
		arena.boxes[i] = {}
		for j, tile in ipairs(t) do
			if (tile ~= center) then
				arena.boxes[i][j] = {
					{x = (i - 1) * TILE_SIZE,             y = (j - 1) * TILE_SIZE},
					{x = (i - 1) * TILE_SIZE + TILE_SIZE, y = (j - 1) * TILE_SIZE},
					{x = (i - 1) * TILE_SIZE + TILE_SIZE, y = (j - 1) * TILE_SIZE + TILE_SIZE},
					{x = (i - 1) * TILE_SIZE,             y = (j - 1) * TILE_SIZE + TILE_SIZE}
				}
			end
		end
	end
	
	arena.lvl = newLevel()

	return setmetatable(arena, arena_mt)
end

function arena_mt:update(dt)
	self.lvl:update(dt)
end

function arena_mt:draw()
	local p = nil
	if (self.publicTimer < 10) then
		p1 = public
		p2 = publicDown
	else
		p1 = public2
		p2 = publicDown2
		if (self.publicTimer >= 20) then
			self.publicTimer = 0
		end
	end
	self.publicTimer = self.publicTimer + 1
	
	for i, t in ipairs(self.tiles) do
		for j, tile in ipairs(t) do
			if (tile ~= -1) then
				drawAsset(tile, (i) * TILE_SIZE + TILE_SIZE / 2, (j) * TILE_SIZE + TILE_SIZE / 2)
				
				-- Dessin du public du haut
				-- if (j == 1) and (i ~= 1) and (i < ARENA_WIDTH) then
					-- for ip = 1, TILE_SIZE / p1.width do
						-- for jp = 1, TILE_SIZE / ((p1.height/2) + 1) do
							-- local quad = love.graphics.newQuad(p1.x, p1.y, p1.width, p1.height, self.tileSet:getWidth(), self.tileSet:getHeight())
							-- local off = 0
							-- if (jp % 2) == 0 then
								-- off = 7
							-- end
							-- love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE + (ip - 1) * p1.width + off, (jp - 1) * p1.height / 2)
						-- end
					-- end
				-- end
				-- Dessin du public du bas
				-- if (j == ARENA_HEIGHT) and (i ~= 1) and (i < ARENA_WIDTH) then
					-- for ip = 1, TILE_SIZE / p2.width do
						-- for jp = 1, TILE_SIZE / ((p2.height/2) + 1) do
							-- local quad = love.graphics.newQuad(p2.x, p2.y, p2.width, p2.height, self.tileSet:getWidth(), self.tileSet:getHeight())
							-- local off = 0
							-- if (jp % 2) == 0 then
								-- off = 7
							-- end
							-- love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE + (ip - 1) * p2.width + off,
																	-- (j - 1) * TILE_SIZE + (jp - 1) * p2.height / 2)
						-- end
					-- end
				-- end
			end
		end
	end
	love.graphics.push()
	love.graphics.translate(self.lvl:getWidth() / 2, -self.lvl:getHeight())
	self.lvl:draw()
	love.graphics.pop()
end

function arena_mt:destroyLeftDoor()
	self.tiles[self.porteGauche.x][self.porteGauche.y] = porteGaucheDetruite
	self.hasLeftDoor = false
end

function arena_mt:destroyRightDoor()
	self.tiles[self.porteDroite.x][self.porteDroite.y] = porteGaucheDetruite
	self.hasRightDoor = false
end

-- Renvoie une position valide pour un deplacement de lastQuad vers newQuad (lastQuad est supposé valide)
-- Marche Pas......
-- function arena_mt:getValidQuad(lastQuad, newQuad, dx, dy)
	-- local quad = newQuad
	-- for j, t in ipairs(self.boxes) do
		-- for i, box in ipairs(t) do
			-- if (box ~= nil) and (quad ~= nil) then
				-- if (rectCollision(box, quad)) then
					-- local c1 = getQuadCenter(quad)
					-- local oldC = getQuadCenter(lastQuad)
					-- local c2 = getQuadCenter(box)
					-- local boundX = false
					-- local boundY = false
					-- local newDX = dx
					-- local newDY = dy
					-- if (rectCollision(box, getTranslatedQuad(lastQuad, dx, 0))) then
						-- boundX = true
					-- end
					-- if (rectCollision(box, getTranslatedQuad(lastQuad, 0, dy))) then
						-- boundY = true
					-- end
					-- local w = getQuadWidth(quad) / 2
					-- local h = getQuadHeight(quad) / 2
					
					-- if (oldC.x < c2.x) and boundX then
						-- c1.x = box[1].x - w - 10
					-- elseif (oldC.x > c2.x) and boundX then
						-- c1.x = box[2].x + w + 10
					-- end
					-- if (oldC.y < c2.y) and boundY then
						-- c1.y = box[1].y - h - 10
					-- elseif (oldC.y < c2.y) and boundY then
						-- c1.y = box[3].y + h + 10
					-- end
					-- quad = {
						-- {x = c1.x - w, y = c1.y - h},
						-- {x = c1.x + w, y = c1.y - h},
						-- {x = c1.x + w, y = c1.y + h},
						-- {x = c1.x - w, y = c1.y + h}
					-- }
					-- return quad
				-- end
			-- end
		-- end
	-- end
	-- return self.lvl:getValidQuad(lastQuad, quad, dx, dy)
-- end

function arena_mt:getDoorHitBox()
	local x1 = self.porte.x - 1 * TILE_SIZE
	local y1 = self.porte.x - 1 * TILE_SIZE
	return {
		{x = x1, y = y1},
		{x = x1 + TILE_SIZE, y = y1},
		{x = x1 + TILE_SIZE, y = y1 + TILE_SIZE},
		{x = x1 + TILE_SIZE, y = y1}
	}
end

-- box -> la hitbox de l'épée qui tape
function arena_mt:hitDoor(box)
	if (self.hasDoor) then
		local dbox = self:getDoorHitBox()
		if (rectCollision(box, dbox)) then
			self:destroyDoor()
		end
	end
end


function arena_mt:getWidth()
	return TILE_SIZE * ARENA_WIDTH
end

function arena_mt:getHeight()
	return TILE_SIZE * ARENA_HEIGHT
end
