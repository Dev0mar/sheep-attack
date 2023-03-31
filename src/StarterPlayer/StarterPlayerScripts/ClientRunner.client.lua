--[[
	Client GameRunner:

	Starts up the game's systems, first loading Utility modules, then Services then Handlers.

	# If any module throws an error it will output a warning explaining what module and what is the issue
	# Services and Utils are stored and passed onto handlers to be able to use
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = script.Parent:WaitForChild("Modules")
local Binders = require(ReplicatedStorage.Source.Util.Binders)

local Player = Players.LocalPlayer

local ServiceList, UtilList = {}, {}

if not Player.Character then
	Player.CharacterAdded:Wait()
end

for _, Util in ipairs(ReplicatedStorage.Source.Util:GetChildren()) do
	local Success, Result = pcall(function()
		return require(Util)
	end)
	
	if not Success then
		warn("Unable to load util module [ " .. Util:GetFullName() .. " ] got error:\n " .. tostring(Result))
		continue
	end
	UtilList[Util.Name] = Result
end
print("Loaded Utilities")

for _, Handler in ipairs(Modules.Handlers:GetChildren()) do
	task.spawn(function()
		local Success, Result = pcall(function()
			return require(Handler)
		end)
		
		if not Success then
			warn("Failed to load handler [ " .. Handler:GetFullName() .. " ] got error:\n " .. tostring(Result))
			return
		end

		if Result.init then
			local InitSuccess, InitResult = pcall(function()
				return Result:init(ServiceList, UtilList)
			end)

			if not InitSuccess then
				warn("Failed to initialize handler [ " .. Handler:GetFullName() .. " ] got error:\n " .. tostring(InitResult))
				return
			end
		end
	end)
end

for _, InstanceComponent in ipairs(Modules.InstanceComponents:GetDescendants()) do
	if not InstanceComponent:IsA("ModuleScript") then continue end
	local binder = require(InstanceComponent)
	binder.Util = UtilList
	Binders:Add(InstanceComponent.Name, binder)
end
Binders:Start()