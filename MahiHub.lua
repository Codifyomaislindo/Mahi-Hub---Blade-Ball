local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local MahiHub = WindUI:CreateWindow({
    Title = "Mahi Hub",
    Icon = "rbxassetid://129260712070622", -- Placeholder icon, replace with a suitable one
    IconThemed = true,
    Author = "Manus",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = false,
    },
    SideBarWidth = 200,
    ScrollBarEnabled = true,
})

-- Tabs
local Tabs = {}

Tabs.Main = MahiHub:Tab({
    Title = "Main",
    Icon = "home",
})

Tabs.Esp = MahiHub:Tab({
    Title = "Esp",
    Icon = "eye",
})

Tabs.Utils = MahiHub:Tab({
    Title = "Utils",
    Icon = "tool",
})

-- Main Tab Functions
local autoParryEnabled = false
local autoSpamEnabled = false
local manualSpamEnabled = false

-- Function to find the ball (simplified, might need more robust detection in-game)
local function findBall()
    for i, v in pairs(workspace:GetChildren()) do
        if string.find(v.Name:lower(), "ball") and v:IsA("Part") then
            return v
        end
    end
    return nil
end

-- Function to perform parry (replace with actual remote event if found)
local function doParry()
    -- This is a placeholder. You'll need to find the actual RemoteEvent for parrying.
    -- Example: game:GetService("ReplicatedStorage").RemoteEvents.Parry:FireServer()
    print("Performing parry...")
    -- Simulate a click or key press if direct remote is not available or detected
    -- UserInputService:SimulateKeyPress(Enum.KeyCode.E) -- Example for 'E' key parry
end

Tabs.Main:Toggle({
    Title = "Auto Parry",
    Desc = "Automatically parries the ball.",
    Value = autoParryEnabled,
    Callback = function(state)
        autoParryEnabled = state
        if state then
            -- Logic for auto parry (e.g., constantly check for ball proximity and parry)
            RunService.RenderStepped:Connect(function()
                if autoParryEnabled then
                    local ball = findBall()
                    if ball and (LocalPlayer.Character.HumanoidRootPart.Position - ball.Position).Magnitude < 20 then -- Example distance
                        doParry()
                    end
                end
            end)
        end
    end
})

Tabs.Main:Toggle({
    Title = "Auto Spam",
    Desc = "Automatically spams parry when ball is fast and close (during Clash).",
    Value = autoSpamEnabled,
    Callback = function(state)
        autoSpamEnabled = state
        if state then
            -- Logic for auto spam (detect fast ball and player in clash state)
            RunService.RenderStepped:Connect(function()
                if autoSpamEnabled then
                    local ball = findBall()
                    if ball and ball.Velocity.Magnitude > 50 and (LocalPlayer.Character.HumanoidRootPart.Position - ball.Position).Magnitude < 10 then -- Example speed and distance
                        doParry()
                    end
                end
            end)
        end
    end
})

Tabs.Main:Toggle({
    Title = "Manual Spam",
    Desc = "Continuously spams parry on click.",
    Value = manualSpamEnabled,
    Callback = function(state)
        manualSpamEnabled = state
        if state then
            -- Logic for manual spam (e.g., loop parry while enabled)
            RunService.RenderStepped:Connect(function()
                if manualSpamEnabled then
                    doParry()
                end
            end)
        end
    end
})

-- Esp Tab Functions
local espBallEnabled = false
local ballSpeedEnabled = false
local espPlayerEnabled = false

-- Function to create a simple ESP box (visuals will need to be handled carefully for exploits)
local function createEspBox(part, color)
    local esp = Instance.new("BoxHandleAdornment")
    esp.Adornee = part
    esp.AlwaysOnTop = true
    esp.ZIndex = 10
    esp.Color3 = color
    esp.Transparency = 0.7
    esp.Size = part.Size
    esp.Parent = game:GetService("CoreGui") -- Or PlayerGui
    return esp
end

Tabs.Esp:Toggle({
    Title = "Esp Ball",
    Desc = "Shows an ESP box on the ball.",
    Value = espBallEnabled,
    Callback = function(state)
        espBallEnabled = state
        local ballEsp = nil
        if state then
            RunService.RenderStepped:Connect(function()
                if espBallEnabled then
                    local ball = findBall()
                    if ball and not ballEsp then
                        ballEsp = createEspBox(ball, Color3.fromRGB(255, 0, 0))
                    elseif not ball and ballEsp then
                        ballEsp:Destroy()
                        ballEsp = nil
                    end
                else
                    if ballEsp then
                        ballEsp:Destroy()
                        ballEsp = nil
                    end
                end
            end)
        else
            if ballEsp then
                ballEsp:Destroy()
                ballEsp = nil
            end
        end
    end
})

Tabs.Esp:Toggle({
    Title = "Ball Speed",
    Desc = "Displays the ball's speed.",
    Value = ballSpeedEnabled,
    Callback = function(state)
        ballSpeedEnabled = state
        local speedDisplay = nil
        if state then
            speedDisplay = Instance.new("TextLabel")
            speedDisplay.Size = UDim2.new(0, 200, 0, 30)
            speedDisplay.Position = UDim2.new(0.5, -100, 0.1, 0)
            speedDisplay.BackgroundTransparency = 1
            speedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
            speedDisplay.TextScaled = true
            speedDisplay.Font = Enum.Font.SourceSansBold
            speedDisplay.Parent = game:GetService("CoreGui") -- Or PlayerGui

            RunService.RenderStepped:Connect(function()
                if ballSpeedEnabled and speedDisplay then
                    local ball = findBall()
                    if ball then
                        speedDisplay.Text = "Ball Speed: " .. math.floor(ball.Velocity.Magnitude) .. " studs/s"
                    else
                        speedDisplay.Text = "Ball not found"
                    end
                end
            end)
        else
            if speedDisplay then
                speedDisplay:Destroy()
                speedDisplay = nil
            end
        end
    end
})

Tabs.Esp:Toggle({
    Title = "Esp Player",
    Desc = "Shows ESP boxes on other players.",
    Value = espPlayerEnabled,
    Callback = function(state)
        espPlayerEnabled = state
        local playerEspTable = {}

        if state then
            RunService.RenderStepped:Connect(function()
                if espPlayerEnabled then
                    for i, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local humanoidRootPart = player.Character.HumanoidRootPart
                            if not playerEspTable[player.UserId] then
                                playerEspTable[player.UserId] = createEspBox(humanoidRootPart, Color3.fromRGB(0, 255, 0))
                            else
                                playerEspTable[player.UserId].Adornee = humanoidRootPart
                            end
                        else
                            if playerEspTable[player.UserId] then
                                playerEspTable[player.UserId]:Destroy()
                                playerEspTable[player.UserId] = nil
                            end
                        end
                    end
                else
                    for userId, esp in pairs(playerEspTable) do
                        esp:Destroy()
                        playerEspTable[userId] = nil
                    end
                end
            end)
        else
            for userId, esp in pairs(playerEspTable) do
                esp:Destroy()
                playerEspTable[userId] = nil
            end
        end
    end
})

-- Utils Tab Functions
local antiAfkEnabled = false
local playerSpeedValue = 16 -- Default Roblox walkspeed

Tabs.Utils:Toggle({
    Title = "Anti AFK",
    Desc = "Prevents Roblox from kicking you for being AFK.",
    Value = antiAfkEnabled,
    Callback = function(state)
        antiAfkEnabled = state
        if state then
            -- Simple anti-AFK: simulate small movements or camera shifts
            -- More advanced anti-AFK might involve teleporting or interacting with game elements
            RunService.Heartbeat:Connect(function()
                if antiAfkEnabled then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Simulate a jump
                    wait(0.1)
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running) -- Return to running state
                end
            end)
        end
    end
})

Tabs.Utils:Input({
    Title = "Player Speed",
    Desc = "Changes your player's walk speed.",
    Value = tostring(playerSpeedValue),
    Placeholder = "Enter speed",
    Type = "Number", -- Assuming WindUI supports number input type or handles conversion
    Callback = function(input)
        local newSpeed = tonumber(input)
        if newSpeed and newSpeed > 0 then
            playerSpeedValue = newSpeed
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = playerSpeedValue
            end
        else
            warn("Invalid speed value entered.")
        end
    end
})

-- Initial setup for player speed if character already exists
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    LocalPlayer.Character.Humanoid.WalkSpeed = playerSpeedValue
end

-- Connect to CharacterAdded to set speed for new characters (e.g., after dying)
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = playerSpeedValue
end)

-- Select the first tab on UI load
MahiHub:SelectTab(1)

-- Instructions for use (can be displayed in a separate popup or a dedicated info tab)
WindUI:Notify({
    Title = "Mahi Hub Loaded!",
    Content = "Bem-vindo ao Mahi Hub! Use as abas para acessar as funcionalidades. Lembre-se de que este é um script de exploit e deve ser usado com cautela.",
    Duration = 10,
})

-- Note: This script is a basic outline. Actual implementation of parry, ESP, and anti-AFK
-- will require in-depth knowledge of Blade Ball's internal mechanics, remote events,
-- and anti-cheat measures. The 'doParry' function and ESP box creation are simplified
-- and may need to be adapted based on how Blade Ball handles these actions.
-- Detecting 'Clash' state for auto spam will also require specific game knowledge.

-- For mobile optimization, WindUI is generally responsive, but specific UI adjustments
-- might be needed depending on the final layout and element sizes.

-- Remote events for parry and other actions are usually found by decompiling the game
-- or by observing network traffic during gameplay. This is beyond the scope of a simple script.

-- Example of how to get a remote event (hypothetical):
-- local parryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ParryEvent")
-- if parryRemote then
--     parryRemote:FireServer()
-- end

-- For ESP, drawing directly on CoreGui or PlayerGui is common for exploits.
-- However, the game might have anti-cheat that detects such modifications.

-- Anti-AFK can be tricky. Simple movements might be detected. More complex solutions
-- involve simulating realistic player behavior or exploiting game-specific AFK checks.

-- This script provides the structure and basic WindUI integration. The core exploit
-- logic needs to be filled in with game-specific details.

