local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local tagName = "Interactable"
local tweenTime = 0.1

local activeHighlights = {}

local function tweenOutlineOnly(highlight, outlineTransparency)
	local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local goal = {
		OutlineTransparency = outlineTransparency
	}
	local tween = TweenService:Create(highlight, tweenInfo, goal)
	tween:Play()
	return tween
end

-- Show outline highlight
local function showHighlight(part)
	local hl = part:FindFirstChildOfClass("Highlight")
	if not hl then
		hl = Instance.new("Highlight")
		hl.FillTransparency = 1 
		hl.OutlineTransparency = 1
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.DepthMode = Enum.HighlightDepthMode.Occluded
		hl.Parent = part
	end
	tweenOutlineOnly(hl, 0.25) 
	activeHighlights[part] = hl
end

-- Hide and destroy highlight
local function hideHighlight(part)
	local hl = activeHighlights[part] or part:FindFirstChildOfClass("Highlight")
	if hl then
		local tween = tweenOutlineOnly(hl, 1)
		tween:Play()
		task.wait(tweenTime)
		hl:Destroy()

	end
	activeHighlights[part] = nil
end

RunService.RenderStepped:Connect(function()
	
	local taggedParts = CollectionService:GetTagged(tagName)
	local closestPart = nil


	for _, part in ipairs(taggedParts) do
		
		local clickDetector = part:FindFirstChildOfClass("ClickDetector")
		
		if part:IsA("BasePart") and clickDetector then
			
			local interactionRadius = clickDetector.MaxActivationDistance
			local closestDistance = interactionRadius + 1
			
			local distance = (part.Position - hrp.Position).Magnitude
			if distance <= interactionRadius and distance < closestDistance then
				closestPart = part
				closestDistance = distance
			end
		end
	end

	for _, part in ipairs(taggedParts) do
		if part == closestPart then
			showHighlight(part)
		else
			hideHighlight(part)
		end
	end
end)

-- 
