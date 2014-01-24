local arena_mt = {}
arena_mt.__index = arena_mt

local ARENA_WIDTH = 10
local ARENA_HEIGHT = 10

local TILE_SIZE = 50

--                  x, y, width , height
local left        = {x = 0, y = 100, width = 100, height = 100}
local right       = {x = 200,y = 100, 100, width = 100, height = 100}
local top         = {x = 100, y = 0, width = 100, height = 100}
local bottom      = {x = 100, y = 200, width = 100, height = 100}
local topLeft     = {x = 0, y = 0, width = 100, height = 100}
local bottomLeft  = {x = 0, y = 200, width = 100, height = 100}
local topRight    = {x = 200, y = 0, width = 100, height = 100}
local bottomRight = {x = 200, y = 200, width = 100, height = 100}
local center      = {x = 100, y = 100, width = 100, height = 100}
local public      = {x = 300, y = 0, width = 15, height = 15}
local public2     = {x = 300, y = 15, width = 15, height = 15}

function newArena()
	local arena = {}
	
	arena.tileSet = love.graphics.newImage("tileset.png")
	arena.tiles = {}
	arena.publicTimer = 0
	
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

	return setmetatable(arena, arena_mt)
end

function arena_mt:update(dt)
	
end

function arena_mt:draw()
	local p = nil
	if (self.publicTimer < 10) then
		p = public
	else
		p = public2
		if (self.publicTimer >= 20) then
			self.publicTimer = 0
		end
	end
	self.publicTimer = self.publicTimer + 1
	
	for i, t in ipairs(self.tiles) do
		for j, tile in ipairs(t) do
			local quad = love.graphics.newQuad(tile.x, tile.y, tile.width, tile.height, self.tileSet:getWidth(), self.tileSet:getHeight())
			love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE, 0, TILE_SIZE / 100, TILE_SIZE / 100)
			-- Dessin du public
			if (j == 1) and (i ~= 1) and (i < ARENA_WIDTH) then
				for ip = 1, TILE_SIZE / p.width do
					for jp = 1, TILE_SIZE / (p.height/2) do
						local quad = love.graphics.newQuad(p.x, p.y, p.width, p.height, self.tileSet:getWidth(), self.tileSet:getHeight())
						local off = 0
						if (jp % 2) == 0 then
							off = 7
						end
						love.graphics.draw(self.tileSet, quad, (i - 1) * TILE_SIZE + (ip - 1) * p.width + off, (jp - 1) * p.height / 2)
					end
				end
			end
		end
	end
end
