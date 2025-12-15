local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")

local player = Players.LocalPlayer

local character
local humanoidRootPart
local glueStartTime
local hasStartedDetectAnchor
local inSurvivors = false

local function resetVariables()
    glueStartTime = nil
    hasStartedDetectAnchor = false
end

local function updateCharacter(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

player.CharacterAdded:Connect(function(newChar)
    updateCharacter(newChar)
    if inSurvivors then
        resetVariables()
    end
end)

if player.Character then
    updateCharacter(player.Character)
end

player:GetPropertyChangedSignal("Team"):Connect(function()
    local isIn = player.Team and player.Team.Name == "Survivors"
    if isIn and not inSurvivors then
        resetVariables()
    end
    inSurvivors = isIn
end)

inSurvivors = player.Team and player.Team.Name == "Survivors" or false
if inSurvivors then
    resetVariables()
end

local function findSamBoss()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "SamBoss" and obj:IsA("Model") then
            return obj
        end
    end
    return nil
end

local function findDetectPart()
    local cookieCollect = Workspace:FindFirstChild("CookieCollect")
    if cookieCollect and cookieCollect:IsA("Model") then
        return cookieCollect:FindFirstChild("Detect")
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not character or not character.Parent or not humanoidRootPart then
        return
    end
    
    if not inSurvivors then
        return
    end
    
    local currentTime = tick()
    local samBoss = findSamBoss()
    local detectPart = findDetectPart()
    
    if samBoss and not glueStartTime then
        glueStartTime = currentTime
    end
    
    local elapsed = glueStartTime and (currentTime - glueStartTime) or math.huge
    
    if elapsed < 10 then
        if samBoss then
            local torso = samBoss:FindFirstChild("Torso")
            if torso and torso:IsA("BasePart") then
                humanoidRootPart.CFrame = torso.CFrame
            end
        end
    else
        if not hasStartedDetectAnchor then
            hasStartedDetectAnchor = true
        end
        
        if hasStartedDetectAnchor then
            if samBoss and detectPart and detectPart:IsA("BasePart") then
                humanoidRootPart.CFrame = detectPart.CFrame + Vector3.new(0, 5, 0)
            elseif not samBoss then
                hasStartedDetectAnchor = false
            end
        end
    end
end)