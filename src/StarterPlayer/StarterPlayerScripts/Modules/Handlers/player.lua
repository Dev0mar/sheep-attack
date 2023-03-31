local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Handler = {}

local Initiated = false
local Player = Players.LocalPlayer


local function handleCharacter(char)
	-- local humanoid = char:WaitForChild("Humanoid")
	
end

function Handler:init()
	if Initiated then return end
	Initiated = true

	Player.CharacterAdded:Connect(handleCharacter)
	if Player.Character then
		handleCharacter(Player.Character)
	end
end

return Handler