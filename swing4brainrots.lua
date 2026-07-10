--[[
    Swing Obby for Brainrots – Advanced Auto-Farm GUI
    For authorized security research and local testing only.
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- === CONFIGURATION ===
local CONFIG = {
    AutoFarm = false,
    TargetBrain = nil,          -- Will be set dynamically
    BasePosition = nil,         -- Will be detected
    CollectKey = "E",           -- Key to hold for collection
    DetectionRange = 15,        -- How close to brain to start holding E
    TeleportDelay = 1.5,        -- Seconds after collection before teleport
    SpeedBoost = 60,
    JumpBoost = 120,
}

-- === BRAIN RANKING SYSTEM ===
local BRAIN_VALUES = {
    ["Brainrot"] = 100,
    ["GoldenBrain"] = 500,
    ["MegaBrain"] = 1000,
    ["GodlyBrain"] = 5000,
    ["Brain"] = 50,             -- Fallback
}

local function getBrainValue(brainPart)
    for name, value in pairs(BRAIN_VALUES) do
        if brainPart.Name:find(name) then
            return value
        end
    end
    return 10 -- Default low value
end

local function findBestBrain()
    local best = nil
    local bestValue = 0
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():match("brain") then
            local value = getBrainValue(v)
            if value > bestValue then
                bestValue = value
                best = v
            end
        end
    end
    return best, bestValue
end

-- === DETECT BASE ===
local function findBase()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and (v.Name:lower():match("base") or v.Name:lower():match("spawn")) then
            return v.Position
        end
    end
    -- Fallback: use current position if no base found
    local root = Character:FindFirstChild("HumanoidRootPart")
    return root and root.Position or Vector3.new(0, 10, 0)
end

-- === AUTO-FARM CORE ===
local function autoFarm()
    while CONFIG.AutoFarm and task.wait(0.1) do
        if not Character or not Humanoid or Humanoid.Health <= 0 then
            Character = Player.Character or Player.CharacterAdded:Wait()
            Humanoid = Character:WaitForChild("Humanoid")
            continue
        end

        local root = Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- 1. Find best brain
        local target, value = findBestBrain()
        if not target then
            print("[Kyler] No brains found – waiting...")
            continue
        end
        CONFIG.TargetBrain = target

        -- 2. Move toward target
        local targetPos = target.Position + Vector3.new(0, 3, 0)
        local distance = (root.Position - targetPos).Magnitude

        if distance > CONFIG.DetectionRange then
            -- Move toward brain
            local direction = (targetPos - root.Position).Unit
            root.CFrame = root.CFrame + direction * 2
            Humanoid:MoveTo(targetPos)
        else
            -- 3. Hold E to collect
            local keyCode = Enum.KeyCode[CONFIG.CollectKey:upper()]
            if keyCode then
                UserInputService:SetKeyDown(keyCode)
                task.wait(0.5) -- Hold for collection
                UserInputService:SetKeyUp(keyCode)
                print("[Kyler] Collected brain – value: " .. value)

                -- 4. Check if in inventory
                local inventory = Player:FindFirstChild("Backpack") or Player:FindFirstChild("StarterGear")
                local collected = false
                for _ = 1, 10 do -- Check for 2 seconds
                    task.wait(0.2)
                    if inventory and #inventory:GetChildren() > 0 then
                        collected = true
                        break
                    end
                end

                if collected then
                    print("[Kyler] Brain confirmed in inventory – teleporting to base")
                    -- 5. Teleport back to base
                    local basePos = CONFIG.BasePosition or findBase()
                    root.CFrame = CFrame.new(basePos + Vector3.new(0, 5, 0))
                    task.wait(CONFIG.TeleportDelay)
                    -- Drop off (optional – game may auto-deposit)
                end
            end
        end
    end
end

-- === CREATE ADVANCED GUI ===
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KylerAutoFarm"
    screenGui.Parent = Player:WaitForChild("PlayerGui")

    -- Main Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 280)
    frame.Position = UDim2.new(0.5, -160, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "⭐ KYLER AUTO-FARM ⭐"
    title.TextColor3 = Color3.fromRGB(0, 255, 200)
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Parent = frame

    -- Status Label
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 45)
    status.Text = "Status: IDLE"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 16
    status.BackgroundTransparency = 1
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 140, 0, 40)
    toggleBtn.Position = UDim2.new(0.5, -70, 0.3, 0)
    toggleBtn.Text = "▶ START FARM"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    toggleBtn.MouseButton1Click:Connect(function()
        CONFIG.AutoFarm = not CONFIG.AutoFarm
        if CONFIG.AutoFarm then
            toggleBtn.Text = "⏹ STOP FARM"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            status.Text = "Status: FARMING..."
            status.TextColor3 = Color3.fromRGB(0, 255, 100)
            -- Start farm loop if not already running
            coroutine.wrap(autoFarm)()
            -- Detect base once
            CONFIG.BasePosition = findBase()
        else
            toggleBtn.Text = "▶ START FARM"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            status.Text = "Status: IDLE"
            status.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    -- Info Panel
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 80)
    info.Position = UDim2.new(0, 10, 0, 140)
    info.Text = "Target: Waiting...\nValue: --\nDistance: --"
    info.TextColor3 = Color3.fromRGB(200, 200, 200)
    info.TextSize = 14
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.BackgroundTransparency = 1
    info.Parent = frame

    -- Settings Frame
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(1, -20, 0, 50)
    settingsFrame.Position = UDim2.new(0, 10, 0, 225)
    settingsFrame.BackgroundTransparency = 1
    settingsFrame.Parent = frame

    -- Keybind Label
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0, 60, 0, 25)
    keyLabel.Text = "Collect:"
    keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    keyLabel.TextSize = 14
    keyLabel.BackgroundTransparency = 1
    keyLabel.Parent = settingsFrame

    -- Keybind TextBox
    local keyBox = Instance.new("TextBox")
    keyBox.Size = UDim2.new(0, 40, 0, 25)
    keyBox.Position = UDim2.new(0, 65, 0, 0)
    keyBox.Text = CONFIG.CollectKey
    keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    keyBox.Font = Enum.Font.GothamBold
    keyBox.Parent = settingsFrame
    keyBox.FocusLost:Connect(function()
        CONFIG.CollectKey = keyBox.Text:sub(1, 1):upper()
        keyBox.Text = CONFIG.CollectKey
    end)

    -- Update info every second
    spawn(function()
        while task.wait(1) do
            if CONFIG.TargetBrain then
                local root = Character:FindFirstChild("HumanoidRootPart")
                local dist = root and (root.Position - CONFIG.TargetBrain.Position).Magnitude or 0
                local val = getBrainValue(CONFIG.TargetBrain)
                info.Text = string.format("Target: %s\nValue: $%d\nDistance: %.1f", 
                    CONFIG.TargetBrain.Name, val, dist)
            else
                info.Text = "Target: Searching...\nValue: --\nDistance: --"
            end
        end
    end)

    print("[Kyler] GUI Loaded – click START to begin auto-farm.")
end

-- === INIT ===
spawn(function()
    -- Wait for character
    while not Character or not Humanoid do
        task.wait(0.5)
        Character = Player.Character or Player.CharacterAdded:Wait()
        Humanoid = Character:WaitForChild("Humanoid")
    end
    CONFIG.BasePosition = findBase()
    createGUI()
end)

print("[Kyler] Auto-Farm System loaded. Use GUI to start.")
