local arena_mt = {}
arena_mt.__index = arena_mt

ARENA_WIDTH = 21
ARENA_HEIGHT = 23

local TILE_SIZE = 50

local PUBLIC_FRAME_TIME = 0.4

local BLINK_LIMIT = 0.5
local BLINK_PER_SECOND = 20.0

--                  id de l'asset
local center        = 17
local porte         = 40
local porteDetruite = 17
local arche         = 24

local ARENA_MAP = {
--1   2   3   4   5  6    7   8   9  04  11  19  21  14  36  16  68  18  19  20  21
{51, 52, 52, 52, 52, 52, 52, 52, 52, 7, -1, 9, 52, 52, 52, 52, 52, 52, 52, 52, 53},
{67, 68, 68, 68, 68, 68, 68, 68, 68, 23, 24, 25, 68, 68, 68, 68, 68, 68, 68, 68, 69},
{67, 68, 68, 03, 04, 04, 04, 04, 04, 39, 40, 41, 04, 04, 04, 04, 04, 05, 68, 68, 69},

{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 19, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 17, 21, 68, 68, 69},
{67, 68, 68, 35, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 36, 37, 68, 68, 69},

{67, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 69},
{67, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 68, 69},
{83, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 84, 85}
}

function newArena()
	local arena = {}
	
	arena.tileSet = love.graphics.newImage("assets/tileset.png")
	arena.tiles = {}
	arena.publicTimer = 0
	arena.doorLife = 04
	arena.hasDoor = true
	arena.boxes = {}
	
	arena.blinkTimer = 0.0
	arena.blinkColor = {r = 255, g = 0, b = 255}	
	arena.hitTimer = 0
	arena.hitParticleSystem = nil
	
	for i, t in ipairs(ARENA_MAP) do
		for j, tile in ipairs(t) do
			if (arena.tiles[j] == nil) then
				arena.tiles[j] = {}
			end
			if (tile == porte) then
				arena.porte = {x = j, y = i}
			end
			arena.tiles[j][i] = tile
		end
	end
	
	for i, t in ipairs(arena.tiles) do
		arena.boxes[i] = {}
		for j, tile in ipairs(t) do
			if (tile ~= center) then
				local body = love.physics.newBody(world, 0, 0, "static")
				body:setMassData(0, 0, 10, 0)
				local shape = love.physics.newPolygonShape(-TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, -TILE_SIZE / 2,
														TILE_SIZE / 2, TILE_SIZE / 2,
														-TILE_SIZE / 2, TILE_SIZE / 2)
				local fixture = love.physics.newFixture(body, shape, 1)
				fixture:setFriction(10000)
				fixture:setRestitution(0)
				arena.boxes[i][j] = fixture
				body:setPosition((i - 1) * TILE_SIZE + TILE_SIZE / 2, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
			end
		end
	end
	
	arena.lvl = newLevel()

	return setmetatable(arena, arena_mt)
end

function arena_mt:update(dt)
	self.blinkTimer = math.max(self.blinkTimer - dt, 0.0)
	if (self.hitParticleSystem ~= nil) then
		self.hitTimer = self.hitTimer + dt
		self.hitParticleSystem:update(dt)
	end

	-- public animation
	self.publicTimer = (self.publicTimer + dt) % (2 * PUBLIC_FRAME_TIME)
	self.publicDown = self.publicTimer <= PUBLIC_FRAME_TIME
	print(self.publicDown)

	self.lvl:update(dt)
end

function arena_mt:draw()
	if (not self.hasDoor) then
		love.graphics.push()
		love.graphics.translate(self:getWidth() / 2 - self.lvl:getWidth() / 2, -self.lvl:getHeight() + TILE_SIZE)
		self.lvl:draw()
		love.graphics.pop()
	end
	
	for i, t in ipairs(self.tiles) do
		for j, tile in ipairs(t) do
			if (tile ~= -1) then
				if (tile == porte) then
					local percent = math.sin(math.rad((BLINK_LIMIT - self.blinkTimer * BLINK_PER_SECOND * 368.0)))
					if (self.blinkTimer ~= 0) then
						percent = math.abs(percent)
						local r = self.blinkColor.r + (255 - self.blinkColor.r) * (1 - percent)
						local g = self.blinkColor.g + (255 - self.blinkColor.g) * (1 - percent)
						local b = self.blinkColor.b + (255 - self.blinkColor.b) * (1 - percent)
						love.graphics.setColor(r, g, b)
					else
						love.graphics.setColor(255, 255, 255)
					end
				else
					love.graphics.setColor(255, 255, 255)
				end
				
				local tileToDraw = tile
				if not self.publicDown and ((tileToDraw >= 51) and (tileToDraw <= 53) or
										(tileToDraw >= 67) and (tileToDraw <= 69) or
										(tileToDraw >= 83) and (tileToDraw <= 85)) then
					tileToDraw = tileToDraw + 4
				end
				if (tileToDraw == arche) then
					tileToDraw = center
				end
				drawAsset(tileToDraw, (i - 1) * TILE_SIZE + TILE_SIZE / 2, (j - 1) * TILE_SIZE + TILE_SIZE / 2)
			end
		end
	end
	--drawBox(self:getDoorHitBox())
end

function arena_mt:postPlayerDraw()
	drawAsset(arche, (self.porte.x - 1) * TILE_SIZE + TILE_SIZE / 2, (self.porte.y - 2) * TILE_SIZE + TILE_SIZE / 2)
	if (self.hitParticleSystem ~= nil) then
		love.graphics.draw(self.hitParticleSystem)
	end
end

function arena_mt:destroyDoor()
	if (self.hasDoor) then
		self.tiles[self.porte.x][self.porte.y] = porteDetruite
		
		self.boxes[self.porte.x][self.porte.y]:destroy()
		self.boxes[self.porte.x][self.porte.y] = nil
		
		self.boxes[self.porte.x + 1][self.porte.y]:destroy()
		self.boxes[self.porte.x + 1][self.porte.y] = nil
		
		self.boxes[self.porte.x - 1][self.porte.y]:destroy()
		self.boxes[self.porte.x - 1][self.porte.y] = nil
		
		self.boxes[self.porte.x][self.porte.y - 1]:destroy()
		self.boxes[self.porte.x][self.porte.y - 1] = nil
		
		self.boxes[self.porte.x][self.porte.y - 2]:destroy()
		self.boxes[self.porte.x][self.porte.y - 2] = nil
		self.hasDoor = false
	end
end

function arena_mt:getDoorHitBox()
	local x1 = (self.porte.x - 1) * TILE_SIZE
	local y1 = (self.porte.y - 1) * TILE_SIZE
	return {
		{x = x1, y = y1},
		{x = x1, y = y1 + TILE_SIZE},
		{x = x1 + TILE_SIZE, y = y1 + TILE_SIZE},
		{x = x1 + TILE_SIZE, y = y1}
	}
end

-- box -> la hitbox de l'épée qui tape
function arena_mt:hitDoor(box)
	if (self.hasDoor) then
		local dbox = self:getDoorHitBox()
		if (rectCollision(box, dbox)) then
			self.doorLife = math.max(0, self.doorLife - 1)
			self:blink({r = 255, g = 20, b = 20})
			local m = getQuadCenter(dbox)
			local p = love.graphics.newParticleSystem(love.graphics.newImage("assets/smoke.png"), 1000)
			p:setEmissionRate(20)
			p:setSpeed(520, 400)
			p:setPosition(m.x, m.y)
			p:setEmitterLifetime(0.3)
			p:setParticleLifetime(0.3)
			p:setDirection(0)
			p:setSpread(368)
			p:setRadialAcceleration(-5200)
			p:setTangentialAcceleration(1000)
			p:stop()
			self.hitParticleSystem = p
			p:start()
			
			if (self.doorLife == 0) then
				self:destroyDoor()
			end
		end
	end
end

function arena_mt:blink(color)
	if (self.blinkTimer == 0) then
		self.blinkTimer = BLINK_LIMIT
		self.blinkColor = color
	end
end

function arena_mt:getWidth()
	return TILE_SIZE * ARENA_WIDTH
end

function arena_mt:getHeight()
	return TILE_SIZE * ARENA_HEIGHT
end
