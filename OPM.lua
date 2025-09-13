-- Ultimate Auto Farm Hub v2 - Complete Rewrite
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variables
local isChestCollecting = false
local isBarrelFarming = false
local isAutoRespawnEnabled = false
local chestConnection = nil
local barrelConnection = nil
local respawnConnection = nil
local gui = nil
local fruitSelectorGUI = nil
local lastHealth = 100
local lastChestScan = 0
local chestScanCooldown = 1 -- Minimum seconds between chest scans

-- Counters
local chestCount = 0
local barrelCount = 0

-- Protected call function
local function pcallWrap(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

-- Create Main GUI
local function createGUI()
    if playerGui:FindFirstChild("AutoFarmHubV2") then
        playerGui:FindFirstChild("AutoFarmHubV2"):Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmHubV2"
    screenGui.ResetOnSpawn = false
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 360)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -180)
    mainFrame.BackgroundColor3 = Color3.new(0.12, 0.12, 0.12)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.new(0.08, 0.08, 0.08)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Ultimate Auto Farm Hub v2"
    titleLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Chest Section v2
    local chestFrame = Instance.new("Frame")
    chestFrame.Name = "ChestFrame"
    chestFrame.Size = UDim2.new(1, -20, 0, 60)
    chestFrame.Position = UDim2.new(0, 10, 0, 50)
    chestFrame.BackgroundColor3 = Color3.new(0.16, 0.16, 0.16)
    chestFrame.BorderSizePixel = 0
    chestFrame.Parent = mainFrame
    
    local chestCorner = Instance.new("UICorner")
    chestCorner.CornerRadius = UDim.new(0, 6)
    chestCorner.Parent = chestFrame
    
    local chestTitle = Instance.new("TextLabel")
    chestTitle.Name = "ChestTitle"
    chestTitle.Size = UDim2.new(0.6, 0, 0, 20)
    chestTitle.Position = UDim2.new(0, 10, 0, 5)
    chestTitle.BackgroundTransparency = 1
    chestTitle.Text = "Chest TouchTransmitter v2"
    chestTitle.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    chestTitle.TextSize = 12
    chestTitle.Font = Enum.Font.Gotham
    chestTitle.TextXAlignment = Enum.TextXAlignment.Left
    chestTitle.Parent = chestFrame
    
    local chestCountLabel = Instance.new("TextLabel")
    chestCountLabel.Name = "ChestCount"
    chestCountLabel.Size = UDim2.new(0.4, 0, 0, 20)
    chestCountLabel.Position = UDim2.new(0.6, 0, 0, 5)
    chestCountLabel.BackgroundTransparency = 1
    chestCountLabel.Text = "0"
    chestCountLabel.TextColor3 = Color3.new(0.4, 0.8, 1)
    chestCountLabel.TextSize = 12
    chestCountLabel.Font = Enum.Font.GothamBold
    chestCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    chestCountLabel.Parent = chestFrame
    
    local chestButton = Instance.new("TextButton")
    chestButton.Name = "ChestButton"
    chestButton.Size = UDim2.new(1, -20, 0, 30)
    chestButton.Position = UDim2.new(0, 10, 0, 25)
    chestButton.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
    chestButton.BorderSizePixel = 0
    chestButton.Text = "Start"
    chestButton.TextColor3 = Color3.new(1, 1, 1)
    chestButton.TextSize = 11
    chestButton.Font = Enum.Font.GothamBold
    chestButton.Parent = chestFrame
    
    local chestBtnCorner = Instance.new("UICorner")
    chestBtnCorner.CornerRadius = UDim.new(0, 4)
    chestBtnCorner.Parent = chestButton
    
    -- Barrel Section
    local barrelFrame = Instance.new("Frame")
    barrelFrame.Name = "BarrelFrame"
    barrelFrame.Size = UDim2.new(1, -20, 0, 60)
    barrelFrame.Position = UDim2.new(0, 10, 0, 120)
    barrelFrame.BackgroundColor3 = Color3.new(0.16, 0.16, 0.16)
    barrelFrame.BorderSizePixel = 0
    barrelFrame.Parent = mainFrame
    
    local barrelCorner = Instance.new("UICorner")
    barrelCorner.CornerRadius = UDim.new(0, 6)
    barrelCorner.Parent = barrelFrame
    
    local barrelTitle = Instance.new("TextLabel")
    barrelTitle.Name = "BarrelTitle"
    barrelTitle.Size = UDim2.new(0.6, 0, 0, 20)
    barrelTitle.Position = UDim2.new(0, 10, 0, 5)
    barrelTitle.BackgroundTransparency = 1
    barrelTitle.Text = "Barrel Circle"
    barrelTitle.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    barrelTitle.TextSize = 12
    barrelTitle.Font = Enum.Font.Gotham
    barrelTitle.TextXAlignment = Enum.TextXAlignment.Left
    barrelTitle.Parent = barrelFrame
    
    local barrelCountLabel = Instance.new("TextLabel")
    barrelCountLabel.Name = "BarrelCount"
    barrelCountLabel.Size = UDim2.new(0.4, 0, 0, 20)
    barrelCountLabel.Position = UDim2.new(0.6, 0, 0, 5)
    barrelCountLabel.BackgroundTransparency = 1
    barrelCountLabel.Text = "0"
    barrelCountLabel.TextColor3 = Color3.new(1, 0.8, 0.4)
    barrelCountLabel.TextSize = 12
    barrelCountLabel.Font = Enum.Font.GothamBold
    barrelCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    barrelCountLabel.Parent = barrelFrame
    
    local barrelButton = Instance.new("TextButton")
    barrelButton.Name = "BarrelButton"
    barrelButton.Size = UDim2.new(1, -20, 0, 30)
    barrelButton.Position = UDim2.new(0, 10, 0, 25)
    barrelButton.BackgroundColor3 = Color3.new(0.6, 0.4, 0.2)
    barrelButton.BorderSizePixel = 0
    barrelButton.Text = "Start"
    barrelButton.TextColor3 = Color3.new(1, 1, 1)
    barrelButton.TextSize = 11
    barrelButton.Font = Enum.Font.GothamBold
    barrelButton.Parent = barrelFrame
    
    local barrelBtnCorner = Instance.new("UICorner")
    barrelBtnCorner.CornerRadius = UDim.new(0, 4)
    barrelBtnCorner.Parent = barrelButton
    
    -- Fruit Section
    local fruitFrame = Instance.new("Frame")
    fruitFrame.Name = "FruitFrame"
    fruitFrame.Size = UDim2.new(1, -20, 0, 60)
    fruitFrame.Position = UDim2.new(0, 10, 0, 190)
    fruitFrame.BackgroundColor3 = Color3.new(0.16, 0.16, 0.16)
    fruitFrame.BorderSizePixel = 0
    fruitFrame.Parent = mainFrame
    
    local fruitCorner = Instance.new("UICorner")
    fruitCorner.CornerRadius = UDim.new(0, 6)
    fruitCorner.Parent = fruitFrame
    
    local fruitTitle = Instance.new("TextLabel")
    fruitTitle.Name = "FruitTitle"
    fruitTitle.Size = UDim2.new(0.6, 0, 0, 20)
    fruitTitle.Position = UDim2.new(0, 10, 0, 5)
    fruitTitle.BackgroundTransparency = 1
    fruitTitle.Text = "Fruit Selector"
    fruitTitle.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    fruitTitle.TextSize = 12
    fruitTitle.Font = Enum.Font.Gotham
    fruitTitle.TextXAlignment = Enum.TextXAlignment.Left
    fruitTitle.Parent = fruitFrame
    
    local fruitCountLabel = Instance.new("TextLabel")
    fruitCountLabel.Name = "FruitCount"
    fruitCountLabel.Size = UDim2.new(0.4, 0, 0, 20)
    fruitCountLabel.Position = UDim2.new(0.6, 0, 0, 5)
    fruitCountLabel.BackgroundTransparency = 1
    fruitCountLabel.Text = "0"
    fruitCountLabel.TextColor3 = Color3.new(0.8, 1, 0.4)
    fruitCountLabel.TextSize = 12
    fruitCountLabel.Font = Enum.Font.GothamBold
    fruitCountLabel.TextXAlignment = Enum.TextXAlignment.Right
    fruitCountLabel.Parent = fruitFrame
    
    local fruitButton = Instance.new("TextButton")
    fruitButton.Name = "FruitButton"
    fruitButton.Size = UDim2.new(1, -20, 0, 30)
    fruitButton.Position = UDim2.new(0, 10, 0, 25)
    fruitButton.BackgroundColor3 = Color3.new(0.4, 0.6, 0.2)
    fruitButton.BorderSizePixel = 0
    fruitButton.Text = "Select Fruits"
    fruitButton.TextColor3 = Color3.new(1, 1, 1)
    fruitButton.TextSize = 11
    fruitButton.Font = Enum.Font.GothamBold
    fruitButton.Parent = fruitFrame
    
    local fruitBtnCorner = Instance.new("UICorner")
    fruitBtnCorner.CornerRadius = UDim.new(0, 4)
    fruitBtnCorner.Parent = fruitButton
    
    -- Auto Respawn Section
    local respawnFrame = Instance.new("Frame")
    respawnFrame.Name = "RespawnFrame"
    respawnFrame.Size = UDim2.new(1, -20, 0, 60)
    respawnFrame.Position = UDim2.new(0, 10, 0, 260)
    respawnFrame.BackgroundColor3 = Color3.new(0.16, 0.16, 0.16)
    respawnFrame.BorderSizePixel = 0
    respawnFrame.Parent = mainFrame
    
    local respawnCorner = Instance.new("UICorner")
    respawnCorner.CornerRadius = UDim.new(0, 6)
    respawnCorner.Parent = respawnFrame
    
    local respawnTitle = Instance.new("TextLabel")
    respawnTitle.Name = "RespawnTitle"
    respawnTitle.Size = UDim2.new(0.6, 0, 0, 20)
    respawnTitle.Position = UDim2.new(0, 10, 0, 5)
    respawnTitle.BackgroundTransparency = 1
    respawnTitle.Text = "Auto Respawn"
    respawnTitle.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    respawnTitle.TextSize = 12
    respawnTitle.Font = Enum.Font.Gotham
    respawnTitle.TextXAlignment = Enum.TextXAlignment.Left
    respawnTitle.Parent = respawnFrame
    
    local respawnStatus = Instance.new("TextLabel")
    respawnStatus.Name = "RespawnStatus"
    respawnStatus.Size = UDim2.new(0.4, 0, 0, 20)
    respawnStatus.Position = UDim2.new(0.6, 0, 0, 5)
    respawnStatus.BackgroundTransparency = 1
    respawnStatus.Text = "OFF"
    respawnStatus.TextColor3 = Color3.new(0.8, 0.4, 0.4)
    respawnStatus.TextSize = 12
    respawnStatus.Font = Enum.Font.GothamBold
    respawnStatus.TextXAlignment = Enum.TextXAlignment.Right
    respawnStatus.Parent = respawnFrame
    
    local respawnButton = Instance.new("TextButton")
    respawnButton.Name = "RespawnButton"
    respawnButton.Size = UDim2.new(1, -20, 0, 30)
    respawnButton.Position = UDim2.new(0, 10, 0, 25)
    respawnButton.BackgroundColor3 = Color3.new(0.4, 0.4, 0.6)
    respawnButton.BorderSizePixel = 0
    respawnButton.Text = "Start"
    respawnButton.TextColor3 = Color3.new(1, 1, 1)
    respawnButton.TextSize = 11
    respawnButton.Font = Enum.Font.GothamBold
    respawnButton.Parent = respawnFrame
    
    local respawnBtnCorner = Instance.new("UICorner")
    respawnBtnCorner.CornerRadius = UDim.new(0, 4)
    respawnBtnCorner.Parent = respawnButton
    
    -- Status Bar
    local statusBar = Instance.new("TextLabel")
    statusBar.Name = "StatusBar"
    statusBar.Size = UDim2.new(1, -20, 0, 20)
    statusBar.Position = UDim2.new(0, 10, 0, 330)
    statusBar.BackgroundTransparency = 1
    statusBar.Text = "Ready - All Systems Online v2"
    statusBar.TextColor3 = Color3.new(0.6, 0.6, 0.6)
    statusBar.TextSize = 10
    statusBar.Font = Enum.Font.Gotham
    statusBar.TextXAlignment = Enum.TextXAlignment.Center
    statusBar.Parent = mainFrame
    
    screenGui.Parent = playerGui
    return screenGui, chestButton, barrelButton, fruitButton, respawnButton, closeButton, chestCountLabel, barrelCountLabel, fruitCountLabel, respawnStatus, statusBar
end

-- Chest Functions v2 - Using Working firetouchinterest Method with Output
local function getChests()
    local chests = {}
    local success, result = pcallWrap(function()
        -- Try multiple locations for chests
        local chestLocations = {
            workspace:FindFirstChild("Chests"),
            workspace:FindFirstChild("TreasureChests"),
            workspace:FindFirstChild("Chest"),
            workspace
        }
        
        for _, location in pairs(chestLocations) do
            if location then
                for _, treasureChest in pairs(location:GetChildren()) do
                    if treasureChest.Name == "TreasureChest" and treasureChest:IsA("Model") then
                        print("🔍 Checking TreasureChest:", treasureChest.Name)
                        
                        -- Check if this chest has any collectible parts
                        local hasCollectiblePart = false
                        for _, part in pairs(treasureChest:GetChildren()) do
                            if part.Name == "TreasureChestPart" and part:IsA("BasePart") then
                                -- Check for various interaction methods
                                if part:FindFirstChild("TouchInterest") or 
                                   part:FindFirstChild("ClickDetector") or
                                   treasureChest:FindFirstChild("Collect") or
                                   treasureChest:FindFirstChild("Touch") then
                                    print("✅ Found collectible chest:", treasureChest.Name)
                                    table.insert(chests, treasureChest)
                                    hasCollectiblePart = true
                                    break
                                end
                            end
                        end
                        
                        -- If no specific parts found, still add the chest for teleportation method
                        if not hasCollectiblePart then
                            print("⚠️ Adding chest without specific parts:", treasureChest.Name)
                            table.insert(chests, treasureChest)
                        end
                    end
                end
            end
        end
        
        print("📊 Total chests found:", #chests)
        return chests
    end)
    
    if not success then
        print("❌ Error getting chests:", result)
    end
    
    return success and result or {}
end

local function collectChest(chest)
    local success, result = pcallWrap(function()
        if not chest or not chest.Parent then 
            print("⚠️ Chest or parent not found")
            return false 
        end
        
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
            print("⚠️ Character or HumanoidRootPart not found")
            return false 
        end
        
        local humanoidRootPart = player.Character.HumanoidRootPart
        
        -- Try multiple methods to collect the chest
        local collectionMethods = {
            function()
                -- Method 1: Try firetouchinterest if available
                if firetouchinterest then
                    for _, part in pairs(chest:GetChildren()) do
                        if part.Name == "TreasureChestPart" and part:IsA("BasePart") then
                            local touchInterest = part:FindFirstChild("TouchInterest")
                            if touchInterest then
                                print("🚀 Using firetouchinterest on:", part.Name)
                                firetouchinterest(part, humanoidRootPart, 0)
                                wait(0.05)
                                firetouchinterest(part, humanoidRootPart, 1)
                                return true
                            end
                        end
                    end
                end
                return false
            end,
            
            function()
                -- Method 2: Try direct part touching
                for _, part in pairs(chest:GetChildren()) do
                    if part.Name == "TreasureChestPart" and part:IsA("BasePart") then
                        print("🚀 Using direct touch on:", part.Name)
                        -- Teleport player close to the chest part
                        local chestPosition = part.Position
                        humanoidRootPart.CFrame = CFrame.new(chestPosition + Vector3.new(0, 5, 0))
                        wait(0.1)
                        return true
                    end
                end
                return false
            end,
            
            function()
                -- Method 3: Try using ClickDetector if available
                for _, part in pairs(chest:GetChildren()) do
                    if part.Name == "TreasureChestPart" and part:IsA("BasePart") then
                        local clickDetector = part:FindFirstChild("ClickDetector")
                        if clickDetector then
                            print("🚀 Using ClickDetector on:", part.Name)
                            if fireclickdetector then
                                fireclickdetector(clickDetector)
                                return true
                            elseif clickDetector.MouseClick then
                                clickDetector.MouseClick:Fire(player)
                                return true
                            end
                        end
                    end
                end
                return false
            end,
            
            function()
                -- Method 4: Try using RemoteEvents if available
                local remoteEvent = chest:FindFirstChild("Collect") or chest:FindFirstChild("Touch")
                if remoteEvent and remoteEvent:IsA("RemoteEvent") then
                    print("🚀 Using RemoteEvent on:", chest.Name)
                    remoteEvent:FireServer()
                    return true
                end
                return false
            end
        }
        
        -- Try each method until one succeeds
        for i, method in ipairs(collectionMethods) do
            local methodSuccess, methodResult = pcall(method)
            if methodSuccess and methodResult then
                print("✨ Collection method " .. i .. " succeeded!")
                return true
            end
        end
        
        print("❌ All collection methods failed")
        return false
    end)
    
    return success and result
end

-- Barrel Functions
local function getBarrels()
    local barrels = {}
    local success, result = pcallWrap(function()
        if workspace:FindFirstChild("Barrels") and workspace.Barrels:FindFirstChild("Barrels") then
            for _, barrel in pairs(workspace.Barrels.Barrels:GetChildren()) do
                if barrel and barrel.Parent and barrel:FindFirstChild("ClickDetector") then
                    table.insert(barrels, barrel)
                end
            end
        end
        return barrels
    end)
    return success and result or {}
end

local function teleportBarrelToPlayer(barrel, offset)
    local success = pcallWrap(function()
        if not barrel or not barrel.Parent then return false end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false end
        
        local playerPosition = player.Character.HumanoidRootPart.Position
        local targetPosition = playerPosition + offset
        
        if barrel:IsA("BasePart") then
            if barrel.Anchored then barrel.Anchored = false end
            barrel.CFrame = CFrame.new(targetPosition)
            return true
        elseif barrel:IsA("Model") then
            local part = barrel:FindFirstChild("HumanoidRootPart") or barrel.PrimaryPart or barrel:FindFirstChildOfClass("BasePart")
            if part then
                if part.Anchored then part.Anchored = false end
                if barrel.PrimaryPart then
                    barrel:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                else
                    part.CFrame = CFrame.new(targetPosition)
                end
                return true
            end
        end
        return false
    end)
    return success
end

local function bypassClickDetector(barrel)
    local success = pcallWrap(function()
        if not barrel or not barrel.Parent then return false end
        
        local clickDetector = barrel:FindFirstChild("ClickDetector")
        if clickDetector then
            if fireclickdetector then
                fireclickdetector(clickDetector)
                return true
            elseif clickDetector.MouseClick then
                clickDetector.MouseClick:Fire(player)
                return true
            elseif firesignal then
                firesignal(clickDetector.MouseClick, player)
                return true
            end
        end
        return false
    end)
    return success
end

-- Fruit Functions
local function findFruitsGrouped()
    local fruitsGrouped = {}
    local success, result = pcallWrap(function()
        local allFruits = {}
        
        for _, item in pairs(workspace:GetChildren()) do
            if item:IsA("Tool") and item.Name:match("Fruit$") then
                table.insert(allFruits, item)
            end
        end
        
        for _, item in pairs(workspace:GetDescendants()) do
            if item:IsA("Tool") and item.Name:match("Fruit$") and item.Parent == workspace then
                local alreadyFound = false
                for _, fruit in pairs(allFruits) do
                    if fruit == item then
                        alreadyFound = true
                        break
                    end
                end
                if not alreadyFound then
                    table.insert(allFruits, item)
                end
            end
        end
        
        for _, fruit in pairs(allFruits) do
            if not fruitsGrouped[fruit.Name] then
                fruitsGrouped[fruit.Name] = {}
            end
            table.insert(fruitsGrouped[fruit.Name], fruit)
        end
        
        return fruitsGrouped
    end)
    
    if success then
        return result
    else
        return {}
    end
end

local function createFruitSelectorGUI()
    if fruitSelectorGUI then
        fruitSelectorGUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FruitSelectorGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.new(0.06, 0.06, 0.06)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Fruit Selector"
    titleLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundColor3 = Color3.new(0.14, 0.14, 0.14)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.new(0.4, 0.4, 0.4)
    scrollFrame.Parent = mainFrame
    
    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 6)
    scrollCorner.Parent = scrollFrame
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding = UDim.new(0, 5)
    
    local fruitsGrouped = findFruitsGrouped()
    local yPosition = 5
    
    for fruitName, fruitList in pairs(fruitsGrouped) do
        local count = #fruitList
        
        local fruitFrame = Instance.new("Frame")
        fruitFrame.Name = fruitName
        fruitFrame.Size = UDim2.new(1, -12, 0, 40)
        fruitFrame.BackgroundColor3 = Color3.new(0.18, 0.18, 0.18)
        fruitFrame.BorderSizePixel = 0
        fruitFrame.Parent = scrollFrame
        
        local fruitCorner = Instance.new("UICorner")
        fruitCorner.CornerRadius = UDim.new(0, 4)
        fruitCorner.Parent = fruitFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = fruitName
        nameLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9)
        nameLabel.TextSize = 12
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = fruitFrame
        
        local countLabel = Instance.new("TextLabel")
        countLabel.Size = UDim2.new(0.15, 0, 1, 0)
        countLabel.Position = UDim2.new(0.7, 0, 0, 0)
        countLabel.BackgroundTransparency = 1
        countLabel.Text = "x" .. count
        countLabel.TextColor3 = Color3.new(0.8, 1, 0.4)
        countLabel.TextSize = 11
        countLabel.Font = Enum.Font.GothamBold
        countLabel.TextXAlignment = Enum.TextXAlignment.Center
        countLabel.Parent = fruitFrame
        
        local collectButton = Instance.new("TextButton")
        collectButton.Size = UDim2.new(0.15, 0, 0, 30)
        collectButton.Position = UDim2.new(0.85, -5, 0, 5)
        collectButton.BackgroundColor3 = Color3.new(0.4, 0.6, 0.2)
        collectButton.BorderSizePixel = 0
        collectButton.Text = "Get"
        collectButton.TextColor3 = Color3.new(1, 1, 1)
        collectButton.TextSize = 10
        collectButton.Font = Enum.Font.GothamBold
        collectButton.Parent = fruitFrame
        
        local collectCorner = Instance.new("UICorner")
        collectCorner.CornerRadius = UDim.new(0, 3)
        collectCorner.Parent = collectButton
        
        collectButton.MouseButton1Click:Connect(function()
            collectSpecificFruit(fruitName, fruitList)
        end)
        
        yPosition = yPosition + 45
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
    
    closeButton.MouseButton1Click:Connect(function()
        if fruitSelectorGUI then
            fruitSelectorGUI:Destroy()
            fruitSelectorGUI = nil
        end
    end)
    
    fruitSelectorGUI = screenGui
    return screenGui
end

function collectSpecificFruit(fruitName, fruitList)
    print("Collecting all " .. fruitName .. " fruits...")
    
    spawn(function()
        for i, fruit in pairs(fruitList) do
            if fruit and fruit.Parent then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local fruitPosition
                    
                    if fruit:IsA("Tool") then
                        local handle = fruit:FindFirstChild("Handle")
                        if handle then
                            fruitPosition = handle.Position + Vector3.new(0, 3, 0)
                        end
                    end
                    
                    if fruitPosition then
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(fruitPosition)
                        print("Teleported to " .. fruitName .. " (" .. i .. "/" .. #fruitList .. ")")
                        wait(0.2)
                    end
                end
            end
        end
        print("Finished collecting " .. fruitName .. "!")
    end)
end

-- Auto Respawn Functions
local function autoRespawn()
    local success = pcallWrap(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local currentHealth = humanoid.Health
            
            if currentHealth <= 0 and lastHealth > 0 then
                print("Player died - Auto respawning...")
                wait(0.5)
                
                local args = {1}
                ReplicatedStorage:WaitForChild("Connections"):WaitForChild("Spawn"):FireServer(unpack(args))
                print("Respawn command sent!")
            end
            
            lastHealth = currentHealth
        else
            if isAutoRespawnEnabled then
                print("Character not found - Auto respawning...")
                local args = {1}
                ReplicatedStorage:WaitForChild("Connections"):WaitForChild("Spawn"):FireServer(unpack(args))
            end
        end
    end)
    
    if not success then
        print("Auto respawn error occurred, retrying...")
    end
end

-- Auto Functions
local function autoChest(chestCountLabel, statusBar)
    if not isChestCollecting then return end
    
    -- Check cooldown to prevent spam
    local currentTime = tick()
    if currentTime - lastChestScan < chestScanCooldown then
        return
    end
    lastChestScan = currentTime
    
    spawn(function()
        local success, result = pcallWrap(function()
            local chests = getChests()
            if chestCountLabel and chestCountLabel.Parent then
                chestCountLabel.Text = tostring(#chests)
            end
            
            if #chests > 0 then
                if statusBar and statusBar.Parent then
                    statusBar.Text = "Collecting chests using improved methods..."
                end
                
                local collectedCount = 0
                for i, chest in pairs(chests) do
                    if not isChestCollecting then 
                        print("🛑 Chest collection stopped by user")
                        break 
                    end
                    
                    if chest and chest.Parent then
                        print("🎯 Attempting to collect chest " .. i .. "/" .. #chests)
                        
                        local collectSuccess = collectChest(chest)
                        if collectSuccess then
                            collectedCount = collectedCount + 1
                            chestCount = chestCount + 1
                            if statusBar and statusBar.Parent then
                                statusBar.Text = "Collected " .. collectedCount .. "/" .. #chests .. " chests"
                            end
                            print("✅ Successfully collected chest " .. i)
                        else
                            print("❌ Failed to collect chest " .. i)
                            if statusBar and statusBar.Parent then
                                statusBar.Text = "Failed to collect chest " .. i .. "/" .. #chests
                            end
                        end
                        
                        -- Add small delay to prevent spam
                        wait(0.2)
                    else
                        print("⚠️ Chest " .. i .. " no longer exists, skipping")
                    end
                end
                
                if isChestCollecting then
                    if statusBar and statusBar.Parent then
                        statusBar.Text = "Collected " .. collectedCount .. " chests! Scanning..."
                    end
                    print("🔄 All chests processed, waiting before next scan...")
                    wait(3)
                end
            else
                if statusBar and statusBar.Parent then
                    statusBar.Text = "No chests found, scanning..."
                end
                print("🔍 No chests found, waiting before next scan...")
                wait(2)
            end
        end)
        
        if not success then
            print("❌ Error in autoChest:", result)
            if statusBar and statusBar.Parent then
                statusBar.Text = "Error occurred, retrying..."
            end
            wait(1)
        end
    end)
end

local function autoBarrel(barrelCountLabel, statusBar)
    if not isBarrelFarming then return end
    
    spawn(function()
        local barrels = getBarrels()
        barrelCountLabel.Text = tostring(#barrels)
        
        if #barrels > 0 then
            statusBar.Text = "Magnetizing barrels..."
            
            local angleStep = (2 * math.pi) / math.max(#barrels, 1)
            local radius = 7
            
            for i, barrel in pairs(barrels) do
                if not isBarrelFarming then break end
                
                local angle = angleStep * (i - 1)
                local offset = Vector3.new(
                    math.cos(angle) * radius,
                    3,
                    math.sin(angle) * radius
                )
                
                if teleportBarrelToPlayer(barrel, offset) then
                    wait(0.1)
                    
                    if bypassClickDetector(barrel) then
                        barrelCount = barrelCount + 1
                        statusBar.Text = "Farmed " .. i .. "/" .. #barrels .. " barrels"
                        wait(0.1)
                    else
                        statusBar.Text = "Failed to farm barrel " .. i .. "/" .. #barrels
                        wait(0.05)
                    end
                else
                    wait(0.05)
                end
            end
            
            if isBarrelFarming then
                statusBar.Text = "All barrels processed! Scanning..."
                wait(3)
            end
        else
            statusBar.Text = "No barrels found, scanning..."
            wait(1)
        end
    end)
end

-- Toggle Functions
local function toggleChest(button, chestCountLabel, statusBar)
    isChestCollecting = not isChestCollecting
    
    if isChestCollecting then
        button.Text = "Stop"
        button.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        
        chestConnection = RunService.Heartbeat:Connect(function()
            if isChestCollecting then
                autoChest(chestCountLabel, statusBar)
            end
        end)
    else
        button.Text = "Start"
        button.BackgroundColor3 = Color3.new(0.2, 0.6, 0.3)
        if chestConnection then
            chestConnection:Disconnect()
            chestConnection = nil
        end
        statusBar.Text = "Ready - All Systems Online v2"
    end
end

local function toggleBarrel(button, barrelCountLabel, statusBar)
    isBarrelFarming = not isBarrelFarming
    
    if isBarrelFarming then
        button.Text = "Stop"
        button.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        barrelConnection = RunService.Heartbeat:Connect(function()
            if isBarrelFarming then
                autoBarrel(barrelCountLabel, statusBar)
            end
        end)
    else
        button.Text = "Start"
        button.BackgroundColor3 = Color3.new(0.6, 0.4, 0.2)
        if barrelConnection then
            barrelConnection:Disconnect()
            barrelConnection = nil
        end
        statusBar.Text = "Ready - All Systems Online v2"
    end
end

local function openFruitSelector(statusBar)
    createFruitSelectorGUI()
    statusBar.Text = "Fruit selector opened - choose fruits to collect"
end

local function toggleRespawn(button, respawnStatus)
    isAutoRespawnEnabled = not isAutoRespawnEnabled
    
    if isAutoRespawnEnabled then
        button.Text = "Stop"
        button.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
        respawnStatus.Text = "ON"
        respawnStatus.TextColor3 = Color3.new(0.4, 1, 0.4)
        
        respawnConnection = RunService.Heartbeat:Connect(function()
            if isAutoRespawnEnabled then
                autoRespawn()
            end
        end)
        print("Auto Respawn System started!")
    else
        button.Text = "Start"
        button.BackgroundColor3 = Color3.new(0.4, 0.4, 0.6)
        respawnStatus.Text = "OFF"
        respawnStatus.TextColor3 = Color3.new(0.8, 0.4, 0.4)
        
        if respawnConnection then
            respawnConnection:Disconnect()
            respawnConnection = nil
        end
        print("Auto Respawn System stopped!")
    end
end

-- Close Function
local function closeGUI()
    isChestCollecting = false
    isBarrelFarming = false
    isAutoRespawnEnabled = false
    
    if chestConnection then
        chestConnection:Disconnect()
        chestConnection = nil
    end
    if barrelConnection then
        barrelConnection:Disconnect()
        barrelConnection = nil
    end
    if respawnConnection then
        respawnConnection:Disconnect()
        respawnConnection = nil
    end
    if gui then
        gui:Destroy()
        gui = nil
    end
    if fruitSelectorGUI then
        fruitSelectorGUI:Destroy()
        fruitSelectorGUI = nil
    end
    
    chestCount = 0
    barrelCount = 0
end

-- Initialize
wait(0.5)

gui, chestButton, barrelButton, fruitButton, respawnButton, closeButton, chestCountLabel, barrelCountLabel, fruitCountLabel, respawnStatus, statusBar = createGUI()

-- Connect Events
chestButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        toggleChest(chestButton, chestCountLabel, statusBar)
    end)
end)

barrelButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        toggleBarrel(barrelButton, barrelCountLabel, statusBar)
    end)
end)

fruitButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        openFruitSelector(statusBar)
    end)
end)

respawnButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        toggleRespawn(respawnButton, respawnStatus)
    end)
end)

closeButton.MouseButton1Click:Connect(function()
    pcallWrap(closeGUI)
end)

-- Handle character events
player.CharacterAdded:Connect(function(character)
    wait(1)
    if character:FindFirstChild("Humanoid") then
        lastHealth = character.Humanoid.Health
        print("Character respawned - monitoring health...")
    end
end)

player.CharacterRemoving:Connect(function()
    print("Character removing...")
    lastHealth = 0
end)

-- Initialize counts
spawn(function()
    wait(1)
    local chests = getChests()
    local barrels = getBarrels()
    local fruitsGrouped = findFruitsGrouped()
    
    local totalFruits = 0
    for fruitName, fruitList in pairs(fruitsGrouped) do
        totalFruits = totalFruits + #fruitList
    end
    
    if chestCountLabel and chestCountLabel.Parent then
        chestCountLabel.Text = tostring(#chests)
    end
    if barrelCountLabel and barrelCountLabel.Parent then
        barrelCountLabel.Text = tostring(#barrels)
    end
    if fruitCountLabel and fruitCountLabel.Parent then
        fruitCountLabel.Text = tostring(totalFruits)
    end
end)

print("========================================")
print("Ultimate Auto Farm Hub v2 loaded!")
print("Complete rewrite with all new features:")
print("- Chest v2: FireTouchTransmitter (no teleporting)")
print("- Barrel: Circle magnetizing system")
print("- Fruit: Selector GUI with teleporting")
print("- Respawn: Auto respawn on death")
print("========================================")
print("Ready for complete automation!")
