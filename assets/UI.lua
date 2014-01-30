local XHudDist = 10
local YHudDist = 25
local hudWidth = -1
local hudHeight = -1
local lifeWidth = -1

local function getDistances(playerNo, x, y)
	if playerNo == 1 then
		return x, y
	end
	if playerNo == 2 then
		return love.window.getWidth() - x, y
	end
	if playerNo == 3 then
		return x, love.window.getHeight() - y
	end
	if playerNo == 4 then
		return love.window.getWidth() - x, love.window.getHeight() -y
	end
	return -100000000, -100000000
end

function drawUI(player)
	if hudWidth == -1 then
		-- initializing local variables needed to compute X and Y depending on the player
		local tex = love.graphics.newImage("assets/ui/P1_HUD.png")
		hudWidth = tex:getWidth()
		hudHeight = tex:getHeight()

		tex = love.graphics.newImage("assets/ui/life.png")
		lifeWidth = tex:getWidth()
	end
	-- hud
	local x2, y2 = getDistances(player:getNumber(), XHudDist, YHudDist)
	local x = XHudDist
	local y = YHudDist
	if player:getNumber() == 2 or player:getNumber() == 4 then
		-- we have an offset on X
		x = x + love.window.getWidth() - hudWidth - XHudDist - 4 -- les textures des persos 2 et 4 ont un décalage en X par rapport à 1 et 3
	end
	if player:getNumber() == 3 or player:getNumber() == 4 then
		-- we have an offset on Y
		y = y + love.window.getHeight() - hudHeight - YHudDist
	end
	if player:isDead() then
		getAssetsManager():drawUIAsset("hudDeadP"..player:getNumber(), x, y)
	else
		getAssetsManager():drawUIAsset("hudP"..player:getNumber(), x, y)

		--life
		local lifeAsset = "life"
		if player:getNumber() == 2 or player:getNumber() == 3 then
			lifeAsset = "life2"
		end

		x = x + 105
		y = y + 48
		if player:getNumber() == 1 then
			for i = 1, player:getLife() do
				getAssetsManager():drawUIAsset(lifeAsset, x + ((i-1)*(lifeWidth-6)), y)
			end
		elseif player:getNumber() == 2 then
			x = x + 80 -- no idea why
			y = y - 4 -- hey don't ask me
			for i = 1, player:getLife() do
				getAssetsManager():drawUIAsset(lifeAsset, x - ((i-1)*(lifeWidth-6)), y)
			end
		elseif player:getNumber() == 3 then
			y = y + 12
			for i = 1, player:getLife() do
				getAssetsManager():drawUIAsset(lifeAsset, x + ((i-1)*(lifeWidth-6)), y)
			end
		elseif player:getNumber() == 4 then
			x = x + 85
			y = y + 15
			for i = 1, player:getLife() do
				getAssetsManager():drawUIAsset(lifeAsset, x - ((i-1)*(lifeWidth-6)), y)
			end
		end
	end
end
