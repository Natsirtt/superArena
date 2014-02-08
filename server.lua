
local socket = require ("socket")

local udp = socket.udp()

udp:setoption('broadcast',true)
udp:setoption('dontroute',true)
udp:setsockname("*", 6002)
udp:sendto("Connection", "255.255.255.255", 6002)

local hostname = socket.dns.gethostname()

function client(ip, port)
	udp = socket.udp()
	udp:setpeername(ip, port)
end

function server()
	print("Demarrage en mode serveur")

	udp:setoption('broadcast', false)
	udp:setoption('dontroute', false)
	udp:settimeout(nil)
	
	while true do
		local msg, ip, port = udp:receivefrom()
		if (msg ~= nil) ans (hostname ~= socket.dns.tohostname(ip)) then
			if (msg == "Connection") then
				udp:sendto("ConnectionOK", ip, port)
			end
		end
	end
end

print("Attente d'un serveur")
udp:settimeout(3)
local msg, ip, port = udp:receivefrom()
if (msg ~= nil) ans (hostname ~= socket.dns.tohostname(ip)) then
	if (msg == "ConnectionOK") then
		client()
	else
		server()
	end
else
	server()
end
