local WEBSOCKET = "wss://rapid-occipital-xenon.glitch.me/"
local WEBHOOK = "https://webhook.lewisakura.moe/api/webhooks/1139753665142464566/QYHAujAEBd6l-z290g8fsciB3ApZOBVWkSa1VV0NumcM0RcWx_r_HqilAHNk_ynKXBO3/queue"
local LOOT_WEBHOOK = "https://discord.com/api/webhooks/1139811269860413481/1ZKD0SRWs-bkHKTZ4PdYd3oVR8O3oZhv7qENwvny7kNHwSbpyh3ih-xcnyRD67hsUeu7"
local RESET_SERVER_MESSAGE = "secretmsg2"
local SERVER_MESSAGE = "secretmsg"
local USERNAME = "alekart"

repeat
	task.wait()
until game:IsLoaded()

local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local TeleportService =	game:GetService("TeleportService")

local serverhopping = false
local localPlayer = game.Players.LocalPlayer
local playing = false
local socket

local function sendwebhook(content)
	if not WEBHOOK then
		return
	end

	request({
		Url = WEBHOOK,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({
		  content = content,
		  username = "server finder",
		  avatar_url = "https://media.tenor.com/hxSbF16puGwAAAAC/dog-dogs.gif",
		})
	})
end

local function hopNoChest()
	serverhopping = true

	if socket then
		socket:Send(RESET_SERVER_MESSAGE)
	end

	local servers = HttpService:JSONDecode(
		game:HttpGet("https://games.roblox.com/v1/games/7390824960/servers/Public?sortOrder=Asc&limit=100")
	)
	local server = servers.data[math.random(1, #servers.data)]
	local tries = 0

	while task.wait(1) do
   		TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, localPlayer)

		tries += 1

		if tries >= 10 then
			servers = HttpService:JSONDecode(
				game:HttpGet("https://games.roblox.com/v1/games/7390824960/servers/Public?sortOrder=Asc&limit=100")
			)
			server = servers.data[math.random(1, #servers.data)]
			tries = 0
			sendwebhook("# failed hopping to server trying again...")
		end
	end
end

local function serverhop()
	if serverhopping then
		return
	end

	serverhopping = true

	if playing then
		task.wait(3)
		
		for i,v in pairs(workspace.LiveChests:GetChildren()) do
			if v:WaitForChild("ChestMarker").TextLabel.Text:find(localPlayer.Name) then
				fireclickdetector(v.ClickPart.ClickDetector)
			end
		end

		task.wait(2)
	end

	localPlayer:Kick()
	
	hopNoChest()
end

GuiService.ErrorMessageChanged:Connect(function()
	local errorCode = GuiService:GetErrorCode().Value

	if errorCode <= Enum.ConnectionError.PlacelaunchOtherError.Value and errorCode >= Enum.ConnectionError.DisconnectErrors.Value then
		if not serverhopping then
			serverhopping = true
			sendwebhook("# kicked(or timed out) server hopping...")
			hopNoChest()
		end
	end
end)

local body
local serverfound = false
local body2
local isPayload = false

if workspace.IgnoreParts:FindFirstChild("PayloadModel") then
	local event
	local debounce = false
	serverfound = true
	isPayload = true
	event = game.ReplicatedStorage.Events.ClientEffects.OnClientEvent:Connect(function(type, info)
		if type == "UpdatePayloadGUI" and not debounce then
			debounce = true
			body2 = "\nserver region: " .. game.ReplicatedStorage.ServerRegion.Value .. ", " .. game.ReplicatedStorage.ServerCountry.Value .. "\nserver name: " .. game.ReplicatedStorage.ServerName.Value .. "\ngame mode: payload\nplayercount: " .. #game.Players:GetPlayers() .. "/25\nends: <t:" .. info.Time + os.time() .. ":R>\nobjective: " .. info.MyObjective
			body = "<@&1139789035011842121>\nusername: " .. USERNAME .. body2
			if info.MyObjective == "PUSH THE PAYLOAD" and info.Time < 120 then
				playing = false
				localPlayer:Kick()
				sendwebhook("# found payload with too little time hopping...")
				hopNoChest()
			else
				isPayload = false
			end

			event:Disconnect()
		end
	end)
	
	workspace.IgnoreParts.PayloadModel.AncestryChanged:Connect(function()
		if playing then
			sendwebhook("# event over hopping servers...")
		end

		serverhop()
	end)
	
end

if workspace.CapturePoints.PointA:FindFirstChild("CapturePart") then
	body2 = "\nserver region: " .. game.ReplicatedStorage.ServerRegion.Value .. ", " .. game.ReplicatedStorage.ServerCountry.Value .. "\nserver name: " .. game.ReplicatedStorage.ServerName.Value .. "\ngame mode: turf war\nplayer count: " .. #game.Players:GetPlayers() .. "/25"
	body = "<@&1139789035011842121>\nusername: " .. USERNAME .. body2
	serverfound = true

	workspace.CapturePoints.PointA.CapturePart.AncestryChanged:Connect(function()
		if playing then
			sendwebhook("# event over hopping servers...")
		end

		serverhop()
	end)
end

if not serverfound then
	serverhop()
else
	while not playing do
		task.wait(0.5)
		for i,v in pairs(getconnections(localPlayer.PlayerGui:WaitForChild("LoadingGUI"):WaitForChild("LoadedFrame"):WaitForChild("PlayButton").MouseButton1Up)) do
			playing = true
			v:Fire()
		end
	end
end

repeat task.wait(0.5) until not isPayload

local sho = false
local infernal = false

local noruLocations = {
	[1] = "the forest",
	[2] = "the forest",
	[3] = "the desert",
	[4] = "the sewers",
	[5] = "the city",
}

local businessLocations = {
	[1] = "the city",
	[2] = "the forest",
	[3] = "the outside of sewers",
	[4] = "the back of desert tp",
	[5] = "asakusa",
}

if body then
	if workspace.Alive:FindFirstChild("ShoNPC") then
		sho = true
	end
	
	if workspace.Alive:FindFirstChild("VengefulInfernalDemon") then
		infernal = true
	end
	
	if sho and infernal then
		body = body .. "\n\nbosses: Sho and Infernal"
	else
		if sho then
			body = body .. "\n\nbosses: Sho"
		else
			body = body .. "\n\nbosses: Infernal"
		end
	end
	
	local noru = workspace.LiveNPCS:FindFirstChild("Noru")
	
	if noru then
		local closestSpawn = 1
		local closestDistance = math.huge
	
		for i,v in pairs(workspace.HelpfulNPCS.NoruSpawns:GetChildren()) do
			local distance = (v.Position - noru.HumanoidRootPart.Position).Magnitude 
			
			if distance < closestDistance then
				closestDistance = distance
				closestSpawn = i
			end
		end
	
		body = body .. "\nNoru in " .. noruLocations[closestSpawn]
	end
	
	local man = workspace.LiveNPCS:FindFirstChild("Business Man")
	
	if man then
		local closestSpawn = 1
		local closestDistance = math.huge
	
		for i,v in pairs(workspace.HelpfulNPCS.BlackMarketSpawns:GetChildren()) do
			local distance = (v.Position - man.HumanoidRootPart.Position).Magnitude 
	
			if distance < closestDistance then
				closestDistance = distance
				closestSpawn = i
			end
		end
	
		body = body .. "\nBusiness Man in " .. businessLocations[closestSpawn]
	end
	
	body = body .. "\n## copy and paste:\n```\nusername: " .. USERNAME .. body2 .. "```"

	if WEBSOCKET then
		socket = WebSocket.connect(WEBSOCKET)
		socket:Send(SERVER_MESSAGE .. "|" .. game.JobId)
	end


	task.wait(5)
	sendwebhook(body)
end

localPlayer.PlayerGui:WaitForChild("NotoficationGUI"):WaitForChild("NotoficationHolder").ChildAdded:Connect(function(child)
	if not LOOT_WEBHOOK then
		return
	end

	task.wait(0.5)

	if string.sub(child.Text, 1, 1) == "+" then
		request({
		Url = LOOT_WEBHOOK,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({
		  content = child.Text,
		  username = "loot",
		  avatar_url = "https://media.tenor.com/hxSbF16puGwAAAAC/dog-dogs.gif",
		})
	})
	end
end)
