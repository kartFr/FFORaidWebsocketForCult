local WEBSOCKET = "ws://rapid-occipital-xenon.glitch.me/?"
local TeleportService = game:GetService("TeleportService")

local localPlayer = game.players.localplayer
local socket
local serverHopping = false
local pong = false

local success = pcall(function()
    socket = WebSocket.connect(WEBSOCKET .. localPlayer.Name)
end)

if not success then
    return
end

local function hopServers(message)
    if game.JobId == message then
        return
    end

    if message == "pong" then
        pong = true
        return
    end

    serverHopping = true
    localPlayer:Kick("hopping to server :3")
    while task.wait(1) do
        TeleportService:TeleportToPlaceInstance(game.PlaceId, message, localPlayer)
    end
end

local function socketClose()
    if not serverHopping then
        socket = WebSocket.connect(WEBSOCKET .. localPlayer.Name)

        socket.OnMessage:Connect(hopServers)
    end
end

socket.OnMessage:Connect(hopServers)
socket.OnClose:Connect(socketClose)

task.spawn((function()
    while true do
        pong = false
        socket:Send("ping")
    
        task.wait(5)
    
        if not pong then
            socket:Close()
            socket = WebSocket.connect(WEBSOCKET .. localPlayer.Name)
    
            socket.OnMessage:Connect(hopServers)
            socket.OnClose:Connect(socketClose)
        end
    end
end))

local playing

while not playing do
    task.wait(0.5)
    for i,v in pairs(getconnections(localPlayer.PlayerGui:WaitForChild("LoadingGUI"):WaitForChild("LoadedFrame"):WaitForChild("PlayButton").MouseButton1Up)) do
        playing = true
        v:Fire()
    end
end

workspace.LiveChests.ChildAdded:connect(function(child)
    task.wait(3)
    if child:WaitForChild("ChestMarker"):WaitForChild("TextLabel").Text:find(localPlayer.Name) then
        fireclickdetector(child:WaitForChild("ClickPart").ClickDetector)
    end
end)

