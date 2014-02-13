local socket = require ("socket")

require "love.math"

local BROADCAST_PORT = 6000
local SERVER_PORT = 6001

local udp = socket.udp()

udp:setoption('broadcast',true)
udp:setoption('dontroute',true)
udp:setsockname("*", BROADCAST_PORT)
udp:sendto("Connection", "255.255.255.255", BROADCAST_PORT)

local serverChannel = love.thread.getChannel("serverChannel")

local hostname = socket.dns.gethostname()

function client(ip, port)
	local tcp = socket.tcp()
	
	tcp:connect(ip, SERVER_PORT)
	tcp:settimeout(0.1)
	
	while true do
		local msg = tcp:receive()
		if (msg ~= nil) then
			local channel, param = msg:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push(param)
		end
		
		local m = serverChannel:pop()
		while (m ~= nil) do
			local channel, param = m:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push(param)
			
			tcp:send(m)
			
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
	
	while true do
		local messages = {}
		-- On récupére tous les messages envoyés par en local
		local m = serverChannel:pop()
		while (m ~= nil) do
			messages[#messages + 1] = m
			m = serverChannel:pop()
		end
		-- On récupère tous les messages distants
		for _, client in ipairs(clients) do
			local msg = client:receive()
			while (msg ~= nil) do
				messages[#messages + 1] = msg
				msg = client:receive()
			end
		end	
		-- On envoie les messages à tous les clients
		local i = 1
		while i <= #messages do
			local msg = messages[i]
			if (msg == "menuManager startGame") then
				local s = generateLevel()
				messages[#messages + 1] = s
			end
			local channel, param = msg:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push(param)
			
			for _, client in ipairs(clients) do
				client:send(msg)
			end
			i = i + 1
		end

		if (not gameStarted) then
			-- On teste si un client cherche un serveur
			local msg, ip, port = udp:receivefrom()
			if (msg ~= nil) and (hostname ~= socket.dns.tohostname(ip)) then
				if (msg == "Connection") then
					udp:sendto("ConnectionOK", ip, port)
				end
			end
			local c = tcp:accept()
			if (c ~= nil) then
				clients[#clients + 1] = c
				c:settimeout(0.0)
			end
		else
			if (udp ~= nil) then
				udp:close()
				udp = nil
			end
		end
	end
end

print("Attente d'un serveur")
udp:settimeout(2)
local found = false
while not found do
	local msg, ip, port = udp:receivefrom()
	if (msg ~= nil) and (hostname ~= socket.dns.tohostname(ip)) then
		if (msg == "ConnectionOK") then
			client()
		else
			server()
		end
	else
		server()
	end
end
