--[[
    Swing Obby for Brainrots – Advanced Client-Side Utility
    For authorized security research and local testing only.
    Use responsibly and only on games you own or have permission to test.
]]

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Mouse = Player:GetMouse()

-- Configuration (adjust as needed)
local CONFIG = {
    AutoSwing = true,          -- Automatically swing on ropes
    NoFall = true,             -- Prevent falling into voids
    TeleportToBrain = true,    -- Teleport brain to base instantly
    SpeedBoost = 50,           -- Walkspeed multiplier
    JumpBoost = 100,           -- JumpPower multiplier
    ReachMultiplier = 5,       -- Extend rope interaction range
    ESPEnabled = true,         -- Show brain locations
}

-- === Core Functions ===
local function getRopeParts()
    local parts = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():match("rope") then
            table.insert(parts, v)
        end
    end
    return parts
end

local function autoSwing()
    while CONFIG.AutoSwing and task.wait(0.1) do
        local rope = getRopeParts()[1]
        if rope and Character and Humanoid then
            -- Simulate interaction with rope
            local rootPart = Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(rope.Position + Vector3.new(0, 2, 0))
                Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
            end
        end
    end
end

local function preventFall()
    while CONFIG.NoFall and task.wait(0.05) do
        if Character and Humanoid and Humanoid.Health > 0 then
            local root = Character:FindFirstChild("HumanoidRootPart")
            if root and root.Position.Y < -10 then
                root.CFrame = root.CFrame + Vector3.new(0, 50, 0)
            end
        end
    end
end

local function teleportBrain()
    while CONFIG.TeleportToBrain and task.wait(1) do
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Part") and v.Name:lower():match("brain") then
                local base = workspace:FindFirstChild("Base") or workspace:FindFirstChild("Spawn")
                if base and Character then
                    local root = Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(base.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
    end
end

local function speedHack()
    while task.wait(0.1) do
        if Character and Humanoid then
            Humanoid.WalkSpeed = CONFIG.SpeedBoost
            Humanoid.JumpPower = CONFIG.JumpBoost
        end
    end
end

local function extendReach()
    while task.wait(0.5) do
        local tool = Player:FindFirstChild("Backpack"):FindFirstChildWhichIsA("Tool")
        if tool then
            tool.GripPos = tool.GripPos * CONFIG.ReachMultiplier
        end
    end
end

-- === ESP (Highlight Brains) ===
local function brainESP()
    if not CONFIG.ESPEnabled then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Part") and v.Name:lower():match("brain") then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Adornee = v
            highlight.Parent = v
        end
    end
end

-- === UI (Simple Gui) ===
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = Player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Text = "Kyler's Test Panel"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 100, 0, 30)
    toggleBtn.Position = UDim2.new(0.5, -50, 0.4, 0)
    toggleBtn.Text = "Toggle All"
    toggleBtn.Parent = frame
    toggleBtn.MouseButton1Click:Connect(function()
        CONFIG.AutoSwing = not CONFIG.AutoSwing
        CONFIG.NoFall = not CONFIG.NoFall
        CONFIG.TeleportToBrain = not CONFIG.TeleportToBrain
    end)
end

-- === Initialize ===
coroutine.wrap(autoSwing)()
coroutine.wrap(preventFall)()
coroutine.wrap(teleportBrain)()
coroutine.wrap(speedHack)()
coroutine.wrap(extendReach)()
coroutine.wrap(brainESP)()
coroutine.wrap(createGUI)()

print("[Kyler] Script loaded. Use responsibly on authorized systems.")