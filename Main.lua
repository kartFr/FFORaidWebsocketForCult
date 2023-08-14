local TeleportService = game:GetService("TeleportService")

local localPlayer = game.Players.LocalPlayer
local socket
local serverHopping = false

local success = pcall(function()
    socket = WebSocket.connect("wss://rapid-occipital-xenon.glitch.me/?" .. localPlayer.Name)
end)

if not success then
    return
end

local function hopServers(message)
    serverHopping = true
    while task.wait(1) do
        TeleportService:TeleportToPlaceInstance(game.PlaceId, message, game.Players.LocalPlayer)
    end
end

socket.OnMessage:Connect(hopServers)

socket.OnClose:connect(function()
    if not serverHopping then
        socket = WebSocket.connect("wss://rapid-occipital-xenon.glitch.me/?" .. localPlayer.Name)
    end
end)

local playing

while not playing do
    task.wait(0.5)
    for i,v in pairs(getconnections(game.Players.LocalPlayer.PlayerGui:WaitForChild("LoadingGUI"):WaitForChild("LoadedFrame"):WaitForChild("PlayButton").MouseButton1Up)) do
        playing = true
        v:Fire()
    end
end

workspace.LiveChests.ChildAdded:connect(function(child)
    task.wait(3)
    if child:WaitForChild("ChestMarker"):WaitForChild("TextLabel").Text:find(game.Players.LocalPlayer.Name) then
        fireclickdetector(child:WaitForChild("ClickPart").ClickDetector)
    end
end)
