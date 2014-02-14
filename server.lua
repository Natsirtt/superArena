local socket = require ("socket")

require "love.math"

local BROADCAST_PORT = 6000
local SERVER_PORT = 6001

local TOTAL_UPDATE_TIMER = 1.0 -- la durée entre chaque grosse mise à jours

local udp = socket.udp()

udp:setoption('broadcast',true)
udp:setoption('dontroute',true)
udp:setsockname("*", BROADCAST_PORT)
udp:sendto("Connection", "255.255.255.255", BROADCAST_PORT)

local serverChannel = love.thread.getChannel("serverChannel")

local hostname = socket.dns.gethostname()

function client(ip, port)
	print("Demarrage en mode client")
	local tcp = socket.tcp()
	
	tcp:connect(ip, SERVER_PORT)
	tcp:settimeout(0.0)
	
	while true do
		local msg = tcp:receive()
		if (msg ~= nil) then
			--print("Reception : "..msg)
			local channel, param = msg:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push({isLocal = false, message = param})
		end
		
		local m = serverChannel:pop()
		while (m ~= nil) do
			local channel, param = m:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push({isLocal = true, message = param})
			
			tcp:send(m.."\n")
			--print("Envoie : "..m)
			m = serverChannel:pop()
		end
	end
end

function generateLevel()
	local minWidth = 25
	local maxWidth = 50
	local minHeight = 25
	local maxHeight = 50
	
	local actualWidth = love.math.random(minWidth, maxWidth)
	local actualHeight = love.math.random(minHeight, maxHeight)
	
	local s = "levelChannel "..actualWidth.." "..actualHeight.." "
		
	for j = 1, actualHeight do
		for i = 1, actualWidth do
			if (i == 1) or (i == actualWidth) or (j == 1) 
						or ((j == actualHeight) and ((i < (actualWidth / 2) - 1) or (i > (actualWidth / 2) + 2))) then
				s = s.."19 "
			else
				local p = love.math.random(0, 1)
				if (p > 0.5) then
					s = s.."65 "
				else
					s = s.."42 "
				end
			end
		end
	end
	
	return s
end

function server()
	print("Demarrage en mode serveur")

	udp:setoption('broadcast', false)
	udp:setoption('dontroute', false)
	udp:settimeout(0.0)
	
	local tcp = socket.tcp()
	tcp:settimeout(0.0)
	tcp:bind("*", SERVER_PORT)
	tcp:listen(3)
	
	
	local gameStarted = false
	
	local clients = {}
	
	local completeUpdateTimer = TOTAL_UPDATE_TIMER
	local lastUpdate = os.time()
	
	while true do
		local messages = {}
		-- On récupére tous les messages envoyés par en local
		local m = serverChannel:pop()
		while (m ~= nil) do
			messages[#messages + 1] = {isLocal = true, message = m}
			m = serverChannel:pop()
		end
		-- On récupère tous les messages distants
		for _, client in ipairs(clients) do
			local msg = client:receive()
			while (msg ~= nil) do
				--print("reception : "..msg)
				messages[#messages + 1] = {isLocal = false, message = msg, client = client}
				msg = client:receive()
			end
		end	
		-- On envoie les messages à tous les clients
		local i = 1
		while i <= #messages do
			local msg = messages[i]
			-- print("Message : "..msg.message)
			if (msg.message == "menuManager startGame") then
				gameStarted = true
				local s = generateLevel()
				messages[#messages + 1] = {isLocal = true, message = s}
			end
			local channel, param = msg.message:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push({isLocal = msg.isLocal, message = param})
			
			for _, client in ipairs(clients) do
				--print("Envoie : "..msg.message)
				if (msg.isLocal) or ((not msg.isLocal) and (msg.client ~= client)) then
					client:send(msg.message.."\n")
				end
			end
			i = i + 1
		end

		if (not gameStarted) then
			-- On teste si un client cherche un serveur
			local msg, ip, port = udp:receivefrom()
			if (msg ~= nil) and (hostname ~= socket.dns.tohostname(ip)) then
				print("Demande de server !")
				if (msg == "Connection") then
					udp:sendto("ConnectionOK", ip, port)
				end
			end
			local c = tcp:accept()
			if (c ~= nil) then
				print("Nouveau Client ! ")
				
				for i = 1, (#clients + 1) do
					c:send("menuManager newPlayer\n")
				end
				clients[#clients + 1] = c
				c:settimeout(0.1)
			end
		else
			if (udp ~= nil) then
				udp:close()
				udp = nil
			end
			completeUpdateTimer = completeUpdateTimer - (os.time() - lastUpdate)
			lastUpdate = os.time()
			if (completeUpdateTimer <= 0.0) then
				love.thread.getChannel("gameManager"):push({isLocal = true, message = "update"})
				completeUpdateTimer = TOTAL_UPDATE_TIMER
			end
		end
	end
end

print("Attente d'un serveur")
local timeout = 1.0
local found = false
local serverIp = nil
local lastTime = os.clock()
while (not found) and (timeout > 0.0) do
	udp:settimeout(timeout)
	local msg, ip, port = udp:receivefrom()
	if (msg ~= nil) and (hostname ~= socket.dns.tohostname(ip)) then
		if (msg == "ConnectionOK") then
			serverIp = ip
			found = true
		end
	end
	timeout = timeout - (os.clock() - lastTime)
	lastTime = os.clock()
end

if (found == true) then
	client(serverIp, 0)
else
	server()
end