
-- BRAINROT HUB V1
-- Pour ton propre jeu Roblox Studio

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local active = false
local autoWalk = false
local speedBoost = false
local stepDistance = 3
local normalSpeed = 16
local boostSpeed = 28
local minimized = false

local oldGui = playerGui:FindFirstChild("BrainrotHub")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHub"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 300)
frame.Position = UDim2.new(0.65, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(13, 19, 32)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 140, 255)
stroke.Thickness = 1.5
stroke.Parent = frame

local function makeLabel(text, y, height, size)
    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(12, y)
    label.Size = UDim2.new(1, -24, 0, height)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(235, 242, 255)
    label.TextSize = size or 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    return label
end

local function makeButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Position = UDim2.fromOffset(12, y)
    button.Size = UDim2.new(1, -24, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(24, 45, 72)
    button.TextColor3 = Color3.fromRGB(235, 245, 255)
    button.Text = text
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

makeLabel("BRAINROT HUB  V1", 10, 28, 19)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Position = UDim2.new(1, -35, 0, 8)
minimizeButton.Size = UDim2.fromOffset(25, 25)
minimizeButton.Text = "-"
minimizeButton.TextSize = 20
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 110, 220)
minimizeButton.Parent = frame

local function getCharacter()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if hum and root and hum.Health > 0 then
        return char, hum, root
    end
end

local semiButton
local speedButton
local walkButton
local distanceButton

semiButton = makeButton("SEMI TP : OFF", 48, function()
    active = not active
    semiButton.Text = "SEMI TP : " .. (active and "ON" or "OFF")
    semiButton.BackgroundColor3 = active
        and Color3.fromRGB(0, 125, 220)
        or Color3.fromRGB(24, 45, 72)
end)

speedButton = makeButton("SPEED BOOST : OFF", 88, function()
    speedBoost = not speedBoost
    speedButton.Text = "SPEED BOOST : "
        .. (speedBoost and "ON" or "OFF")

    local _, hum = getCharacter()
    if hum then
        hum.WalkSpeed = speedBoost and boostSpeed or normalSpeed
    end
end)

walkButton = makeButton("AUTO WALK : OFF", 128, function()
    autoWalk = not autoWalk
    walkButton.Text = "AUTO WALK : "
        .. (autoWalk and "ON" or "OFF")
end)

distanceButton = makeButton("DISTANCE : 3", 168, function()
    if stepDistance == 3 then
        stepDistance = 5
    elseif stepDistance == 5 then
        stepDistance = 8
    else
        stepDistance = 3
    end

    distanceButton.Text = "DISTANCE : " .. stepDistance
end)

makeLabel("Déplacement par petits pas", 211, 22, 12)
makeLabel("Utilise les commandes normales", 235, 22, 11)

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(frame:GetChildren()) do
        if obj ~= minimizeButton and obj ~= corner
            and obj ~= stroke then
            obj.Visible = not minimized
        end
    end

    frame.Size = minimized
        and UDim2.fromOffset(260, 42)
        or UDim2.fromOffset(260, 300)

    minimizeButton.Text = minimized and "+" or "-"
end)

local elapsed = 0

RunService.Heartbeat:Connect(function(dt)
    elapsed += dt

    local char, hum, root = getCharacter()
    if not char then return end

    if speedBoost then
        hum.WalkSpeed = boostSpeed
    end

    if autoWalk then
        hum:Move(Vector3.new(0, 0, -1), true)
    end

    if active and elapsed >= 0.15 then
        elapsed = 0

        local direction = hum.MoveDirection
        if direction.Magnitude > 0 then
            local displacement = direction.Unit * stepDistance

            -- Vérifie qu'un obstacle ne bloque pas le pas.
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {char}

            local result = workspace:Raycast(
                root.Position,
                displacement,
                params
            )

            if not result then
                char:PivotTo(char:GetPivot() + displacement)
            end
        end
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    local _, hum = getCharacter()
    if hum then
        hum.WalkSpeed = speedBoost and boostSpeed or normalSpeed
    end
end)
