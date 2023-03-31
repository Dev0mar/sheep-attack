local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Interactable = {}
Interactable.__index = Interactable

local Trove = require(ReplicatedStorage.Packages.Trove)
local InteractionActions = ServerStorage.InteractionActions

function Interactable.new(instance: Instance)
	local self = setmetatable({}, Interactable)

	self.Instance = instance
	self._trove = Trove.new()
	self._trove:AttachToInstance(self.Instance)

	self._proximity = self.Instance:FindFirstChild("ProximityPrompt") or Instance.new("ProximityPrompt")
	self._proximity.RequiresLineOfSight = false
	self._proximity.HoldDuration = 1
	self._proximity.Parent = self.Instance

	local interactionAction = self.Instance:GetAttribute("InteractionAction")
	if interactionAction then
		local actionModule = InteractionActions:FindFirstChild(tostring(interactionAction))
		self._interactionAction = actionModule and require(actionModule)
	end

	self._trove:Connect(self.Instance:GetAttributeChangedSignal("InteractionAction"), function()
		interactionAction = self.Instance:GetAttribute("InteractionAction")
		if interactionAction then
			local actionModule = InteractionActions:FindFirstChild(tostring(interactionAction))
			self._interactionAction = require(actionModule)
		end
	end)

	self._trove:Connect(self._proximity.Triggered, function(player)
		if self._interactionAction then
			self._interactionAction:Run(player, self.Instance)
		end
	end)

	return self
end

function Interactable:Destroy()
	self._trove:Clean()
end

return Interactable