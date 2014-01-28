local XHudDist = 10
local YHudDist = 25

local function drawAsset(asset, x, y, general)
	local x2, y2 = self:getDistances(x, y)
	local xOffset = (x2 ~= x)
	local yOffset = (y2 ~= y)
	getAssetsManager():drawUIAsset(self.player, asset, x2, y2, general, xOffset, yOffset)
end

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
	-- hud
	if player:isDead() then
		drawAsset("hudDead", XHudDist, YHudDist, false)
	else
		local x2, y2 = getDistances(player:getNumber(), XHudDist, YHudDist)
		getAssetsManager():drawHUD(player, x2, y2)
	end
end
