--[[
	Server GameRunner:

	Starts up the game's systems, first loading Utility modules, then Services then Handlers.

	# If any module throws an error it will output a warning explaining what module and what is the issue
	# Services and Utils are stored and passed onto handlers to be able to use
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Modules = ServerStorage.Modules
local Binders = require(ReplicatedStorage.Source.Util.Binders)

local ServiceList, UtilList, HandlersList = {}, {}, {}

for _, Util in ipairs(ReplicatedStorage.Source.Util:GetChildren()) do
	local Success, Result = pcall(function()
		return require(Util)
	end)

	if not Success then
		warn("Failed to load Utility module [ " .. Util:GetFullName() .. " ] caught error:\n" .. tostring(Result))
		continue
	end

	UtilList[Util.Name] = Result
end

for _, Service in ipairs(Modules.Services:GetChildren()) do
	local Success, Result = pcall(function()
		return require(Service)
	end)

	if not Success then
		warn("Failed to load service [ " .. Service:GetFullName() .. " ] got error:\n " .. tostring(Result))
		continue
	end

	ServiceList[Service.Name] = Result
end

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
				warn(debug.traceback("Failed to initialize handler [ " .. Handler:GetFullName() .. " ] got error:\n " .. tostring(InitResult)))
				return
			end
			HandlersList[Handler.Name] = Result
		end
	end)
end

for _, InstanceComponent in Modules.InstanceComponents:GetChildren() do
	if not InstanceComponent:IsA("ModuleScript") then continue end
	local binder = require(InstanceComponent)
	binder.Util = UtilList
	binder.Handlers = HandlersList
	binder.Services = ServiceList
	Binders:Add(InstanceComponent.Name, binder)
end
Binders:Start()