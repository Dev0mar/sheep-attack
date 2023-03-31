local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Handler = {}

local Initialized = false

local AmbientGroup, UIGroup
local Settings = {
	AmbientVolume = 0.5,
	UIVolume = 0.5
}

local currentAmbient

function Handler.PlayAmbient(name)
	if currentAmbient then
		TweenService:Create(currentAmbient, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
			Volume = 0
		}):Play()
		task.wait(1.1)
		currentAmbient:Stop()
		currentAmbient = nil
	end
	local newAmbient = AmbientGroup:FindFirstChild(name, true)
	if not newAmbient then return end
	currentAmbient = newAmbient
	currentAmbient.Volume = 0
	TweenService:Create(currentAmbient, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
		Volume = Settings.AmbientVolume
	}):Play()
	currentAmbient:Play()
end

function Handler.PlayUI(name)
	local sound = name and UIGroup:FindFirstChild(name)
	if not sound then return end
	sound:Play()
end

function Handler:init()
	if Initialized then return end
	Initialized = true

	AmbientGroup = SoundService:WaitForChild("Ambient")
	UIGroup = SoundService:WaitForChild("UI")

	self.PlayAmbient("Main")
end

return Handler