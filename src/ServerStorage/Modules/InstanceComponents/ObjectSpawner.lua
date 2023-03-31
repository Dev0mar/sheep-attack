local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Spawner = {}
Spawner.__index = Spawner

local Trove = require(ReplicatedStorage.Packages.Trove)
local Prefabs = ReplicatedStorage:FindFirstChild("Prefabs") or Instance.new("Folder")
Prefabs.Name = "Prefabs"
Prefabs.Parent = ReplicatedStorage

local SpawnFolder = workspace:FindFirstChild("SpawnableItems") or Instance.new("Folder")
SpawnFolder.Name = "SpawnableItems"
SpawnFolder.Parent = workspace

function Spawner.new(instance)
	local self = setmetatable({}, Spawner)

	self.Instance = instance
	self._trove = Trove.new()
	self._trove:AttachToInstance(self.Instance)
	self._objects = self.Instance:GetAttribute("Objects") or ""
	self._itemTag = "Spawner_" .. string.sub(HttpService:GenerateGUID(false), 1, math.random(5,8))

	self._instanceSize = if self.Instance:IsA("Model") then self.Instance:GetExtentsSize() else self.Instance.Size


	self._spawnInterval = 5
	self._lastSpawned = 0
	self._maxItems = 10
	
	self._trove:Connect(self.Instance:GetAttributeChangedSignal("Objects"), function()
		self._objects = self.Instance:GetAttribute("Objects") or ""
	end)

	self._trove:Connect(RunService.Heartbeat, function()
		if os.time() - self._lastSpawned < self._spawnInterval then return end
		self._lastSpawned = os.time()
		SpawnFolder:ClearAllChildren()
		local spawnedCount = #CollectionService:GetTagged(self._itemTag)
		if spawnedCount >= self._maxItems then return end
		local spawnables = {}
		local spawnablesCount = 0
		for _, itemName in ipairs(string.split(self._objects, ",")) do
			itemName = string.match(itemName, "^%s*(.-)%s*$")
			local item = Prefabs:FindFirstChild(itemName, true)
			if not item then continue end
			table.insert(spawnables, item)
			spawnablesCount += 1
		end

		if spawnablesCount == 0 then return end

		for _ = 1, self._maxItems-spawnedCount do
			local randomItem = spawnables[math.random(spawnablesCount)]:Clone()
			local isModel = randomItem:IsA("Model")
			local itemSize = if isModel then randomItem:GetExtentsSize() else randomItem.Size
			if self._instanceSize.Magnitude < itemSize.Magnitude then continue end
			local availableSpace = self._instanceSize - itemSize
			local availableSpaceX = math.random(-availableSpace.X, availableSpace.X)
			local availableSpaceZ = math.random(-availableSpace.Z, availableSpace.Z)
			local targetLocation = self.Instance.CFrame * CFrame.new(availableSpaceX/2, 1, availableSpaceZ/2)
			if isModel then
				randomItem:PivotTo(targetLocation)
			else
				randomItem.CFrame = targetLocation
			end
			CollectionService:AddTag(randomItem, self._itemTag)
			randomItem.Parent = SpawnFolder
		end
	end)

	return self
end

function Spawner:Destroy()
	self._trove:Clean()
end

return Spawner