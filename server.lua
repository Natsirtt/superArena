local socket = require ("socket")

local udp = socket.udp()

udp:setoption('broadcast',true)
udp:setoption('dontroute',true)
udp:setsockname("*", 6002)
udp:sendto("Connection", "255.255.255.255", 6002)

local serverChannel = love.thread.getChannel("serverChannel")

local hostname = socket.dns.gethostname()

function client(ip, port)
	udp = socket.udp()
	udp:setpeername(ip, port)
	
	while true do
		local msg, ip, port = udp:receivefrom()
		if (msg ~= nil) and (hostname ~= socket.dns.tohostname(ip)) then
			local channel, param = msg:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push(param)
		end
	end
end

function server()
	print("Demarrage en mode serveur")

	udp:setoption('broadcast', false)
	udp:setoption('dontroute', false)
	udp:settimeout(0.1)
	
	local clients = {}
	
	while true do
		-- On récupére tous les messages envoyés par en local
		local m = serverChannel:pop()
		while (m ~= nil) do
			print("Message : "..m)
			local channel, param = m:match("^(%S*) (.*)")
			love.thread.getChannel(channel):push(param)
			
			for _, client in ipairs(clients) do
				udp:sendto(m, client.ip, client.port)
			end
			
			m = serverChannel:pop()
		end
		
		local msg, ip, port = udp:receivefrom()
		if (msg ~= nil) and (hostname ~= socket.dns.tohostname(ip)) then
			if (msg == "Connection") then
				udp:sendto("ConnectionOK", ip, port)
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