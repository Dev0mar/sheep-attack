local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Animator = {}
Animator.__index = Animator

local Trove = require(ReplicatedStorage.Packages.Trove)
local DB = require(ReplicatedStorage.Source.Config.NPCAnimations)

function Animator.new(instance)
	local self = setmetatable({}, Animator)

	self.Instance = instance
	self._trove = Trove.new()
	self._trove:AttachToInstance(instance)

	if not instance:IsDescendantOf(workspace) then
		self:Destroy()
		return self
	end

	local function playAnimation()
		if not self._animationHandler or not self.animation then return end
		self._animationHandler:Play(self.animation)
	end
	local function createHook()
		if not self.animator or not self.identifier then return end
		if self._animationHandler then
			self._animationHandler:Destroy()
		end
		if not DB[self.identifier] then
			warn("Could not load animation configurations for [ " .. tostring(self.identifier) .. " ] at NPC:\n")
			print(instance)
			return
		end
		self._animationHandler = DB[self.identifier].new(instance, self.animator)
		task.wait(0.5)
		playAnimation()
	end

	self.identifier = instance:GetAttribute("identifier")
	self.animation = instance:GetAttribute("animation")
	self.animator = instance:WaitForChild("Humanoid")
	self.animator = self.animator and self.animator:FindFirstChild("Animator")

	self._trove:Connect(instance:GetAttributeChangedSignal("identifier"), function()
		self.identifier = instance:GetAttribute("identifier")
		createHook()
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("animation"), function()
		self.animation = instance:GetAttribute("animation")
		playAnimation()
	end)

	if not self.animator then
		instance.DescendantAdded:Once(function(child)
			if child:IsA("Animator") and child.Parent:IsA("Humanoid") then
				self.animator = child
				createHook()
			end
		end)
	end

	createHook()

	return self
end

function Animator:Destroy()
	self._trove:Clean()
end

return Animator