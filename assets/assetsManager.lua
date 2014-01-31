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

        instance = setmetatable(self, mt)
        init = true
    end
    return instance
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

function mt:getPlayerAssets(tilesetName)
	if (self.playerAssets[tilesetName] == nil) then
		local assets = {}
		assets["idle"] = {}
		assets["walkDown"] = {}
		assets["walkRight"] = {}
		assets["walkLeft"] = {}
		assets["walkUp"] = {}
		assets["attackRight"] = {}
		assets["attackLeft"] = {}
		assets["attackUp"] = {}
		assets["attackDown"] = {}
		assets["shieldDown"] = {}
		assets["shieldUp"] = {}
		assets["shieldLeft"] = {}
		assets["shieldRight"] = {}
		assets["victory"] = {}
		assets["die"] = {}
		assets["idleUp"] = {}
		assets["idleLeft"] = {}
		assets["idleRight"] = {}

		local tileSet = love.graphics.newImage(tilesetName)
		local imageData = tileSet:getData()
		local nid = love.image.newImageData(150, 150)
		local j = 0

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["idle"], love.graphics.newImage(nid))
		end

		j = j + 1

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["walkDown"], love.graphics.newImage(nid))
		end

		j = j + 1

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["walkRight"], love.graphics.newImage(nid))
		end

		j = j + 1

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["walkLeft"], love.graphics.newImage(nid))
		end

		j = j + 1

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["walkUp"], love.graphics.newImage(nid))
		end

		j = j + 1

		for i = 1, 2 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["attackRight"], love.graphics.newImage(nid))
		end
		table.insert(assets["attackRight"], love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
		table.insert(assets["attackRight"], love.graphics.newImage(nid))

		j = j + 1

		for i = 1, 2 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["attackLeft"], love.graphics.newImage(nid))
		end
		table.insert(assets["attackLeft"], love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
		table.insert(assets["attackLeft"], love.graphics.newImage(nid))

		j = j + 1

		for i = 1, 2 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["attackUp"], love.graphics.newImage(nid))
		end
		table.insert(assets["attackUp"], love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
		table.insert(assets["attackUp"], love.graphics.newImage(nid))

		j = j + 1

		for i = 1, 2 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["attackDown"], love.graphics.newImage(nid))
		end
		table.insert(assets["attackDown"], love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 150 * 2, 150 * j, 150, 150)
		table.insert(assets["attackDown"], love.graphics.newImage(nid))

		j = j + 1

		-- shield

		nid:paste(imageData, 0, 0, 0, 150 * j, 150, 150)
		table.insert(assets["shieldDown"], love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 150, 150 * j, 150, 150)
		table.insert(assets["shieldRight"], love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 300, 150 * j, 150, 150)
		table.insert(assets["shieldLeft"], love.graphics.newImage(nid))
		nid:paste(imageData, 0, 0, 450, 150 * j, 150, 150)
		table.insert(assets["shieldUp"], love.graphics.newImage(nid))

		j = j + 1

		-- victory

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * ((i - 1) % 2), 150 * j, 150, 150)
			table.insert(assets["victory"], love.graphics.newImage(nid))
		end

		j = j + 1

		--die animation

		for i = 1, 5 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["die"], love.graphics.newImage(nid))
		end
		table.insert(assets["die"], love.graphics.newImage(nid))

		j = j + 1

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["die"], love.graphics.newImage(nid))
			table.insert(assets["die"], love.graphics.newImage(nid))
		end
		table.insert(assets["die"], love.graphics.newImage(nid))
		table.insert(assets["die"], love.graphics.newImage(nid))
		table.insert(assets["die"], love.graphics.newImage(nid))

		j = j + 1

		nid:paste(imageData, 0, 0, 0, 150 * j, 150, 150)
		table.insert(assets["die"], love.graphics.newImage(nid))

		j = j + 1

		-- idle right

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["idleRight"], love.graphics.newImage(nid))
		end

		j = j + 1

		-- idle left

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["idleLeft"], love.graphics.newImage(nid))
		end

		j = j + 1

		-- idle up

		for i = 1, 4 do
			nid:paste(imageData, 0, 0, 150 * (i - 1), 150 * j, 150, 150)
			table.insert(assets["idleUp"], love.graphics.newImage(nid))
		end
		
		self.playerAssets[tilesetName] = assets
	end
	
	return self.playerAssets[tilesetName]
end