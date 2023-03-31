--[[
	Player Handler:

	Handles player related functionality,

	# Sets player collision so players don't collide with each other
]]
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local Handler = {}

local EventCache = {}
local shuttingDown = false

function HandleCharacter(Char)
	local HRP
	repeat
		HRP = Char:FindFirstChild("HumanoidRootPart")
	until HRP or not Players:GetPlayerFromCharacter(Char)
	if not Players:GetPlayerFromCharacter(Char) then return end
	local Player = Players:GetPlayerFromCharacter(Char)
	for _, Child in ipairs(Char:GetDescendants()) do
		if Child:IsA("BasePart") or Child:IsA("MeshPart") or Child:IsA("UnionOperation") then
			Child.CollisionGroup = "PlayerCharacter"
		end
	end
	
	Char.Humanoid.WalkSpeed = 30
end

function Handler:init(Services, Util)
	Players.PlayerAdded:Connect(function(Player)
		EventCache[Player] = {}
		
		Player.CharacterAppearanceLoaded:Connect(function(Char)
			HandleCharacter(Char)
		end)
		if Player.Character then
			HandleCharacter(Player.Character)
		end
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"


		leaderstats.Parent = Player
	end)

	Players.PlayerRemoving:Connect(function(Player)
		if EventCache[Player] then
			for _, Event in pairs(EventCache[Player]) do
				if typeof(Event) == "RBXScriptConnection" then
					Event:Disconnect()
				end
			end
			EventCache[Player] = nil
		end
	end)
	PhysicsService:RegisterCollisionGroup("PlayerCharacter")
	
	PhysicsService:CollisionGroupSetCollidable("PlayerCharacter", "PlayerCharacter", false)

	game:BindToClose(function()
		shuttingDown = true
	end)
end

return Handler