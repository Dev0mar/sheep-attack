local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Promise = require(script.Parent.Promise)
local Util = {}

if not RunService:IsClient() then return {} end

local Player = Players.LocalPlayer

function Util.GetMouseTarget(FilterType, Filter)
	local cursorPosition = UserInputService:GetMouseLocation()
	local oray = workspace.CurrentCamera:ViewportPointToRay(cursorPosition.X, cursorPosition.Y, 0)
	local raycastParams = RaycastParams.new()
	if FilterType then
		raycastParams.FilterType = FilterType
	end
	if Filter then
		raycastParams.FilterDescendantsInstances = Filter
	end
	raycastParams.IgnoreWater = true
	return workspace:Raycast(workspace.CurrentCamera.CFrame.Position,(oray.Direction * 1000), raycastParams)
end

function Util.GetFirstInstanceWithTag(Tag, Parent)
	return Promise.new(function(Resolve, Reject, Cancel)
		local Abort = false
		Cancel(function()
			Abort = true
		end)
		local Connection
		local StartTime = os.time()
		task.spawn(function()
			while not Abort and os.time() - StartTime < 30 do
				task.wait(1)
			end
			if Abort then return end
			Abort = true
			if Connection then
				Connection:Disconnect()
			end
			Reject(debug.traceback("Infinite yield possible while waiting for item with tag [ " .. tostring(Tag) .. " ]"))
		end)

		Connection = CollectionService:GetInstanceAddedSignal(Tag):Connect(function(Item)
			if Parent and not Item:IsDescendantOf(Parent) then return end
			Connection:Disconnect()
			Connection = nil
			Abort = true
			Resolve(Item)
		end)

		for _, ExistingItem in CollectionService:GetTagged(Tag) do
			if Abort then break end
			if Parent and not ExistingItem:IsDescendantOf(Parent) then continue end
			if Connection then
				Connection:Disconnect()
				Connection = nil
			end
			Abort = true
			Resolve(ExistingItem)
			break
		end
	end)
end

function Util.WaitForChildrenWithTags(Parent, TagList)
	local Children = {}
	local Connections = {}

	local function ChildrenReady()
		local AllFound = true
		for _, TagName in TagList do
			if not Children[TagName] then
				AllFound = false
				break
			end
		end
		if AllFound then
			for _, Connection in Connections do
				Connection:Disconnect()
			end
		end
		return AllFound
	end

	for _, TagName in TagList do
		Connections[TagName] = CollectionService:GetInstanceAddedSignal(TagName):Connect(function(Child)
			if not Child:IsDescendantOf(Parent) then return end
			Connections[TagName]:Disconnect()
			Children[TagName] = Child
		end)

		for _, Existing in CollectionService:GetTagged(TagName) do
			if not Existing:IsDescendantOf(Parent) then continue end
			Children[TagName] = Existing
			if Connections[TagName] then
				Connections[TagName]:Disconnect()
			end
			break
		end
	end

	while not ChildrenReady() do
		task.wait()
	end
	
	return Children
end

return Util