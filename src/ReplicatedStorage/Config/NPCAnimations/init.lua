local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Anims = {}

local Trove = require(ReplicatedStorage.Packages.Trove)

for _, module in ipairs(script:GetChildren()) do
	if not module:IsA("ModuleScript") then continue end

	local success, result = pcall(function()
		return require(module)
	end)

	if not success then
		warn(debug.traceback("Failed to load animation [ " .. module.Name .. " ] caught error: \n" .. tostring(result)))
		continue
	end

	result.__index = result

	function result.new(instance, animator)
		local self = setmetatable({}, result)

		self.Instance = instance
		self._animator = animator
		self._trove = Trove.new()

		self._animations = {}
		self._tracks = {}

		
		for animationName, id in pairs(self.AnimationIds) do
			self._animations[animationName] = Instance.new("Animation")
			self._animations[animationName].AnimationId = id
			self._trove:Add(self._animations[animationName])
		end

		return self
	end

	function result:Play(animationName)
		if not self._animations[animationName] and not self._tracks[animationName] then return end
		self._tracks[animationName] = self._animator:LoadAnimation(self._animations[animationName])
		self._tracks[animationName]:Play()

		if self[animationName] then
			self[animationName](self)
		end
	end

	function result:Destroy()
		self._trove:Clean()
	end

	Anims[module.Name] = result
end

return Anims