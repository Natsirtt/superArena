local mt = {}
mt.__index = mt

local init = false
local instance = {}

local TILE_SIZE = 50

function getAssetsManager()
    if not init then
        local self = {}

        local tileSet = love.graphics.newImage("assets/tileset.png")
		self.assets = {}
		self.playerAssets = {}
		
		for i = 1, tileSet:getHeight() / TILE_SIZE do
			for j = 1, tileSet:getWidth() / TILE_SIZE do
				local imageData = tileSet:getData()
				local nid = love.image.newImageData(TILE_SIZE, TILE_SIZE)
				nid:paste(imageData, 0, 0, (j - 1) * TILE_SIZE , (i - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
				table.insert(self.assets, love.graphics.newImage(nid))
			end
		end


		-- UI / HUD

		self.uiAssets = {}
		local prefix = "assets/ui/"

		self.uiAssets["attackButton"] = love.graphics.newImage(prefix.."btn_attack.png")
		self.uiAssets["attackButtonP1"] = love.graphics.newImage(prefix.."P1_btn_attack_use.png")
		self.uiAssets["attackButtonP2"] = love.graphics.newImage(prefix.."P2_btn_attack_use.png")
		self.uiAssets["attackButtonP3"] = love.graphics.newImage(prefix.."P3_btn_attack_use.png")
		self.uiAssets["attackButtonP4"] = love.graphics.newImage(prefix.."P4_btn_attack_use.png")

		self.uiAssets["defenseButton"] = love.graphics.newImage(prefix.."btn_defense.png")
		self.uiAssets["defenseButtonP1"] = love.graphics.newImage(prefix.."P1_btn_defense_use.png")
		self.uiAssets["defenseButtonP2"] = love.graphics.newImage(prefix.."P2_btn_defense_use.png")
		self.uiAssets["defenseButtonP3"] = love.graphics.newImage(prefix.."P3_btn_defense_use.png")
		self.uiAssets["defenseButtonP4"] = love.graphics.newImage(prefix.."P4_btn_defense_use.png")

		self.uiAssets["life"] = love.graphics.newImage(prefix.."life.png")
		self.uiAssets["life2"] = love.graphics.newImage(prefix.."life2.png")
		self.uiAssets["hudP1"] = love.graphics.newImage(prefix.."P1_HUD.png")
		self.uiAssets["hudP2"] = love.graphics.newImage(prefix.."P2_HUD.png")
		self.uiAssets["hudP3"] = love.graphics.newImage(prefix.."P3_HUD.png")
		self.uiAssets["hudP4"] = love.graphics.newImage(prefix.."P4_HUD.png")
		self.uiAssets["hudDeadP1"] = love.graphics.newImage(prefix.."P1_HUD_dead.png")
		self.uiAssets["hudDeadP2"] = love.graphics.newImage(prefix.."P2_HUD_dead.png")
		self.uiAssets["hudDeadP3"] = love.graphics.newImage(prefix.."P3_HUD_dead.png")
		self.uiAssets["hudDeadP4"] = love.graphics.newImage(prefix.."P4_HUD_dead.png")
		
		self.smoke = love.graphics.newImage("assets/smoke.png")

        instance = setmetatable(self, mt)
        init = true
    end
    return instance
end

function mt:getSmoke()
	return self.smoke
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function mt:drawAsset(asset, x, y)
	if 0 <= asset and asset < #self.assets then
		local tex = self.assets[asset + 1]
		love.graphics.draw(tex, round(x - tex:getWidth() / 2, 5), round(y - tex:getHeight() / 2, 5))
	end
end

function mt:drawHUD(player, x, y)
	if player:getNumber() == 1 or player:getNumber() == 4 then
		texStr = "life"
	else
		texStr = "life2"
	end

	if player:getNumber() == 1 then
		-- la vie commence à gauche de la jauge
		-- local x2 = x + hudWidth - hudWidth / 5 -- valeur pour commencer à droite
		local x2 = x + 105
		local y2 = y + 48
		tex = self.uiAssets[texStr]
		for i = 1, player:getLife() do
			-- self:drawUIAsset(player, texStr, x2 - ((i-1)*(tex:getWidth()-6)), y2, true) -- commencer à droite
			self:drawUIAsset(player, texStr, x2 + ((i-1)*(tex:getWidth()-6)), y2, true)
		end
		-- print("Life = " .. x2 .. " - " .. y2 .. " hud height = " .. hudHeight)
	elseif player:getNumber() == 3 then
		-- la vie commence à gauche de la jauge
		
	end
end

function mt:drawUIAsset(asset, x, y)
	love.graphics.draw(self.uiAssets[asset], x, y)
end

function drawAsset(asset, x, y)
	getAssetsManager():drawAsset(asset, x, y)
end

function mt:debugAssets()
	for i = 0, 49 do
		self:drawAsset(i, (TILE_SIZE + 5) * i, 0)
	end
end

function genEnnemy()
	local im = {}
	im[#im + 1] = love.graphics.newImage("assets/player1.png")
	im[#im + 1] = love.graphics.newImage("assets/player2.png")
	im[#im + 1] = love.graphics.newImage("assets/player3.png")
	im[#im + 1] = love.graphics.newImage("assets/player4.png")
	
	local canvas = love.graphics.newCanvas(800, 2550)
	love.graphics.setCanvas(canvas)
	love.graphics.setBlendMode("additive")
	for _, image in ipairs(im) do
		love.graphics.draw(image)
	end
	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha")
	
	local newImage = love.graphics.newImage(canvas:getImageData())
	return newImage
end

function mt:getPlayerAssets(tilesetName)
	if (self.playerAssets[tilesetName] == nil) then
		local assets = {}

		local tileSet = nil
		if (tilesetName == "ennemy") then
			tileSet = genEnnemy()
		else
			tileSet = love.graphics.newImage(tilesetName)
		end

		assets["idleDown"] = newAnimation(tileSet, {0, 1, 2, 3}, 15, true)
		assets["idleRight"] = newAnimation(tileSet, {70, 71, 72, 73}, 15, true)
		assets["idleLeft"] = newAnimation(tileSet, {75, 76, 77, 78}, 15, true)
		assets["idleUp"] = newAnimation(tileSet, {80, 85, 86, 87}, 15, true)
		
		assets["walkDown"] = newAnimation(tileSet, {5, 6, 7, 8}, 15, true)
		assets["walkRight"] = newAnimation(tileSet, {10, 11, 12, 13}, 15, true)
		assets["walkLeft"] = newAnimation(tileSet, {15, 16, 17, 18}, 15, true)
		assets["walkUp"] = newAnimation(tileSet, {20, 21, 22, 23}, 15, true)
		
		assets["attackRight"] = newAnimation(tileSet, {25, 26, 26, 27}, 15, false)
		assets["attackLeft"] = newAnimation(tileSet, {30, 31, 31, 32}, 15, false)
		assets["attackUp"] = newAnimation(tileSet, {35, 36, 36, 37}, 15, false)
		assets["attackDown"] = newAnimation(tileSet, {40, 41, 41, 42}, 15, false)

		-- shield
		assets["shieldDown"] = newAnimation(tileSet, {45}, 1, false)
		assets["shieldRight"] = newAnimation(tileSet, {46}, 1, false)
		assets["shieldLeft"] = newAnimation(tileSet, {47}, 1, false)
		assets["shieldUp"] = newAnimation(tileSet, {48}, 1, false)

		-- victory
		assets["victory"] = newAnimation(tileSet, {50, 51}, 8, true)

		--die animation
		assets["die"] = newAnimation(tileSet, {55, 56, 57, 58, 59, 60, 61, 62, 63, 65}, 10, false)

		assets["tornado"] = newAnimation(tileSet, {41, 26, 25, 35, 36, 30, 31, 40}, 30, false)
		
		self.playerAssets[tilesetName] = assets
	end
	
	return self.playerAssets[tilesetName]
end

