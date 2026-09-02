--==================================================
--       NGUYỄN GIA HƯNG - ROBLOX MENU
--       Speed + ESP
--       LocalScript
--       StarterPlayer > StarterPlayerScripts
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--==================================================
-- SETTINGS
--==================================================

local DEFAULT_SPEED = 16
local speedEnabled = false
local espEnabled = false
local espObjects = {}

--==================================================
-- SCREEN GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "NguyenGiaHungMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

--==================================================
-- MAIN FRAME
--==================================================

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 330, 0, 360)
main.Position = UDim2.new(0.5, -165, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(70, 70, 90)
stroke.Thickness = 1.5
stroke.Parent = main

--==================================================
-- TOP BAR
--==================================================

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 55)
top.BackgroundColor3 = Color3.fromRGB(25, 25, 34)
top.BorderSizePixel = 0
top.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NGUYỄN GIA HƯNG"
title.TextColor3 = Color3.fromRGB(255, 215, 70)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 18)
subtitle.Position = UDim2.new(0, 19, 0, 31)
subtitle.BackgroundTransparency = 1
subtitle.Text = "SPEED  •  ESP"
subtitle.TextColor3 = Color3.fromRGB(150, 150, 165)
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = top

--==================================================
-- CLOSE BUTTON
--==================================================

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 34, 0, 34)
close.Position = UDim2.new(1, -45, 0, 10)
close.BackgroundColor3 = Color3.fromRGB(190, 55, 55)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 22
close.BorderSizePixel = 0
close.Parent = top

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 9)
closeCorner.Parent = close

--==================================================
-- CONTENT
--==================================================

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -30, 1, -75)
content.Position = UDim2.new(0, 15, 0, 65)
content.BackgroundTransparency = 1
content.Parent = main

--==================================================
-- SPEED CARD
--==================================================

local speedCard = Instance.new("Frame")
speedCard.Size = UDim2.new(1, 0, 0, 125)
speedCard.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
speedCard.BorderSizePixel = 0
speedCard.Parent = content

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 12)
speedCorner.Parent = speedCard

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(1, -30, 0, 28)
speedTitle.Position = UDim2.new(0, 15, 0, 10)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "⚡  SPEED"
speedTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
speedTitle.Font = Enum.Font.GothamBold
speedTitle.TextSize = 16
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = speedCard

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 150, 0, 38)
speedBox.Position = UDim2.new(0, 15, 0, 55)
speedBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
speedBox.Text = "50"
speedBox.PlaceholderText = "Tốc độ"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false
speedBox.BorderSizePixel = 0
speedBox.Parent = speedCard

local speedBoxCorner = Instance.new("UICorner")
speedBoxCorner.CornerRadius = UDim.new(0, 8)
speedBoxCorner.Parent = speedBox

--==================================================
-- GENERIC TOGGLE CREATOR
--==================================================

local function createToggle(parent, position, text)
    local button = Instance.new("TextButton")

    button.Size = UDim2.new(0, 125, 0, 38)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
    button.Text = text .. ": TẮT"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    return button
end

local speedToggle = createToggle(
    speedCard,
    UDim2.new(1, -140, 0, 55),
    "SPEED"
)

--==================================================
-- ESP CARD
--==================================================

local espCard = Instance.new("Frame")
espCard.Size = UDim2.new(1, 0, 0, 125)
espCard.Position = UDim2.new(0, 0, 0, 140)
espCard.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
espCard.BorderSizePixel = 0
espCard.Parent = content

local espCorner = Instance.new("UICorner")
espCorner.CornerRadius = UDim.new(0, 12)
espCorner.Parent = espCard

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, -30, 0, 28)
espTitle.Position = UDim2.new(0, 15, 0, 10)
espTitle.BackgroundTransparency = 1
espTitle.Text = "👁  ESP PLAYER"
espTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
espTitle.Font = Enum.Font.GothamBold
espTitle.TextSize = 16
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = espCard

local espInfo = Instance.new("TextLabel")
espInfo.Size = UDim2.new(1, -30, 0, 25)
espInfo.Position = UDim2.new(0, 15, 0, 45)
espInfo.BackgroundTransparency = 1
espInfo.Text = "Highlight đỏ • Viền trắng • Always On Top"
espInfo.TextColor3 = Color3.fromRGB(145, 145, 160)
espInfo.Font = Enum.Font.Gotham
espInfo.TextSize = 11
espInfo.TextXAlignment = Enum.TextXAlignment.Left
espInfo.Parent = espCard

local espToggle = createToggle(
    espCard,
    UDim2.new(0, 15, 0, 75),
    "ESP"
)

--==================================================
-- OPEN BUTTON
--==================================================

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 55, 0, 55)
openButton.Position = UDim2.new(0, 20, 0.5, -27)
openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 34)
openButton.Text = "HGH"
openButton.TextColor3 = Color3.fromRGB(255, 215, 70)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 13
openButton.BorderSizePixel = 0
openButton.Visible = false
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 14)
openCorner.Parent = openButton

--==================================================
-- DRAG SYSTEM
--==================================================

local dragging = false
local dragStart
local startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)

--==================================================
-- CLOSE / OPEN
--==================================================

close.MouseButton1Click:Connect(function()
    main.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    main.Visible = true
    openButton.Visible = false
end)

--==================================================
-- SPEED
--==================================================

local function updateSpeed()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if speedEnabled then
        local value = tonumber(speedBox.Text)

        if not value then
            value = 50
        end

        humanoid.WalkSpeed = math.clamp(value, 0, 200)
    else
        humanoid.WalkSpeed = DEFAULT_SPEED
    end
end

local function updateSpeedButton()
    if speedEnabled then
        speedToggle.Text = "SPEED: BẬT"
        speedToggle.BackgroundColor3 = Color3.fromRGB(45, 175, 90)
    else
        speedToggle.Text = "SPEED: TẮT"
        speedToggle.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
    end
end

speedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    updateSpeedButton()
    updateSpeed()
end)

speedBox.FocusLost:Connect(function()
    if speedEnabled then
        updateSpeed()
    end
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled then
        updateSpeed()
    end
end)

--==================================================
-- ESP
--==================================================

local function removeESP(player)
    if espObjects[player] then
        espObjects[player]:Destroy()
        espObjects[player] = nil
    end
end

local function addESP(targetPlayer)
    if targetPlayer == player then return end

    local character = targetPlayer.Character
    if not character then return end

    removeESP(targetPlayer)

    local highlight = Instance.new("Highlight")
    highlight.Name = "NguyenGiaHungESP"

    -- Đỏ bên trong
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5

    -- Viền trắng
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0

    -- Xuyên vật cản
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    highlight.Adornee = character
    highlight.Parent = character

    espObjects[targetPlayer] = highlight
end

local function enableESP()
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        addESP(targetPlayer)
    end
end

local function disableESP()
    for targetPlayer, highlight in pairs(espObjects) do
        if highlight then
            highlight:Destroy()
        end

        espObjects[targetPlayer] = nil
    end
end

local function updateESPButton()
    if espEnabled then
        espToggle.Text = "ESP: BẬT"
        espToggle.BackgroundColor3 = Color3.fromRGB(45, 175, 90)
        enableESP()
    else
        espToggle.Text = "ESP: TẮT"
        espToggle.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
        disableESP()
    end
end

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    updateESPButton()
end)

-- Người chơi mới
Players.PlayerAdded:Connect(function(targetPlayer)

    targetPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)

        if espEnabled then
            addESP(targetPlayer)
        end
    end)

end)

-- Respawn của người chơi hiện tại
player.CharacterAdded:Connect(function()
    task.wait(0.5)

    if speedEnabled then
        updateSpeed()
    end

    if espEnabled then
        enableESP()
    end
end)

--==================================================
-- INITIAL STATE
--==================================================

updateSpeedButton()
updateESPButton()

print("===================================")
print("  NGUYỄN GIA HƯNG MENU LOADED")
print("  SPEED + ESP")
print("===================================")