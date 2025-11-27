-- Key-gated FF2 Ultra OP Loader with FF2-themed rainbow UI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Key system config
local validKeys = {["2xBAT"] = true} -- add your keys
local MAX_ATTEMPTS = 100000000
local DISCORD_INVITE = "https://discord.gg/qwVdSbPJeR"
local attemptsLeft = MAX_ATTEMPTS
local SCRIPT_LOADER = [[
 loadstring(game:HttpGet("https://pastebin.com/raw/GDjjdp8e"))()
]]

-- UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FF2KeyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui") or game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,360,0,170)
frame.Position = UDim2.new(0.5, -180, 0.5, -85)
frame.BackgroundColor3 = Color3.fromRGB(28,45,120) -- FF2 blue
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,15)
corner.Parent = frame

-- Rainbow outline
local outline = Instance.new("UIStroke")
outline.Thickness = 2
outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
outline.Parent = frame

local rainbowHue = 0
RunService.RenderStepped:Connect(function()
    rainbowHue = (rainbowHue + 0.5) % 360
    outline.Color = Color3.fromHSV(rainbowHue/360,1,1)
end)

-- Title / Info
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Enter Key to Load FF2"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 28)
input.Position = UDim2.new(0,10,0,60)
input.PlaceholderText = "Enter key..."
input.Font = Enum.Font.Gotham
input.TextSize = 16
input.Text = ""
input.BackgroundColor3 = Color3.fromRGB(35,35,35)
input.TextColor3 = Color3.fromRGB(255,255,255)
input.BorderSizePixel = 0
input.Parent = frame

local submit = Instance.new("TextButton")
submit.Size = UDim2.new(0,100,0,28)
submit.Position = UDim2.new(1, -110, 0, 96)
submit.Text = "Submit"
submit.Font = Enum.Font.GothamSemibold
submit.TextSize = 14
submit.BackgroundColor3 = Color3.fromRGB(45,45,45)
submit.TextColor3 = Color3.fromRGB(255,255,255)
submit.BorderSizePixel = 0
submit.Parent = frame

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0,120,0,28)
discordBtn.Position = UDim2.new(0,10,0,96)
discordBtn.Text = "Join Discord"
discordBtn.Font = Enum.Font.GothamSemibold
discordBtn.TextSize = 14
discordBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
discordBtn.TextColor3 = Color3.fromRGB(255,255,255)
discordBtn.BorderSizePixel = 0
discordBtn.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 36)
status.Position = UDim2.new(0,10,0,128)
status.BackgroundTransparency = 1
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(200,200,200)
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

-- Draggable frame
local dragToggle, dragInput, dragStart, startPos = false, nil, nil, nil
local function updateDrag(inputObject)
    local delta = inputObject.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
frame.InputBegan:Connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = inputObject.Position
        startPos = frame.Position
        dragInput = inputObject
        inputObject.Changed:Connect(function()
            if inputObject.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(inputObject)
    if inputObject == dragInput and dragToggle then updateDrag(inputObject) end
end)

-- Discord button behavior
discordBtn.MouseButton1Click:Connect(function()
    local ok, _ = pcall(function()
        if setclipboard then setclipboard(DISCORD_INVITE) status.Text = "Discord invite copied to clipboard!" end
    end)
    if not ok then status.Text = "Discord invite: "..DISCORD_INVITE end
end)

-- Load FF2 script
local function loadFF2Script()
    local func, err = loadstring(SCRIPT_LOADER)
    if func then
        func()
        screenGui:Destroy()
    else
        status.Text = "Error loading script: "..tostring(err)
    end
end

-- Handle key submission
local function handleKey(key)
    if validKeys[key] then
        status.Text = "Key accepted! Loading FF2..."
        task.wait(0.2)
        loadFF2Script()
    else
        attemptsLeft = attemptsLeft - 1
        if attemptsLeft > 0 then
            status.Text = "Invalid key. Attempts left: "..attemptsLeft
        else
            status.Text = "No attempts left. Closing."
            task.wait(1)
            screenGui:Destroy()
        end
    end
end

submit.MouseButton1Click:Connect(function() handleKey(input.Text) end)
input.FocusLost:Connect(function(enterPressed) if enterPressed then handleKey(input.Text) end end)
