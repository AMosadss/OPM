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
local isCompassAutoEnabled = false
local chestConnection = nil
local barrelConnection = nil
local respawnConnection = nil
local compassConnection = nil
local gui = nil
local fruitSelectorGUI = nil
local lastHealth = 100
local lastChestScan = 0
local chestScanCooldown = 1 -- Minimum seconds between chest scans
local lastCompassCheck = 0
local compassCheckCooldown = 5 -- Check compass every 5 seconds

-- Counters
local chestCount = 0
local barrelCount = 0
local compassCount = 0

-- Protected call function
local function pcallWrap(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

-- Create Main GUI
local function createGUI()
    if playerGui:FindFirstChild("GSO_Hub_V3") then
        playerGui:FindFirstChild("GSO_Hub_V3"):Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GSO_Hub_V3"
    screenGui.ResetOnSpawn = false
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 300)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.new(0.2, 0.8, 0.8) -- Turquoise/Cyan color
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.new(0, 0, 0) -- Black border
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.new(0, 0, 0) -- Black header
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🎮 GSO Hub v3"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header
    
    -- License Label
    local licenseLabel = Instance.new("TextLabel")
    licenseLabel.Name = "License"
    licenseLabel.Size = UDim2.new(0, 100, 0, 20)
    licenseLabel.Position = UDim2.new(0, 15, 0, 35)
    licenseLabel.BackgroundTransparency = 1
    licenseLabel.Text = "License = GSO Hub"
    licenseLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    licenseLabel.TextSize = 12
    licenseLabel.Font = Enum.Font.Gotham
    licenseLabel.TextXAlignment = Enum.TextXAlignment.Left
    licenseLabel.Parent = header
    
    -- Toggle Button (Minimize)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 40, 0, 30)
    toggleButton.Position = UDim2.new(1, -90, 0, 15)
    toggleButton.BackgroundColor3 = Color3.new(1, 1, 1) -- White button
    toggleButton.BorderSizePixel = 2
    toggleButton.BorderColor3 = Color3.new(0, 0, 0) -- Black border
    toggleButton.Text = "−"
    toggleButton.TextColor3 = Color3.new(0, 0, 0)
    toggleButton.TextSize = 18
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Parent = header
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggleButton
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 30)
    closeButton.Position = UDim2.new(1, -45, 0, 15)
    closeButton.BackgroundColor3 = Color3.new(1, 1, 1) -- White button
    closeButton.BorderSizePixel = 2
    closeButton.BorderColor3 = Color3.new(0, 0, 0) -- Black border
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(0, 0, 0)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Main Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -60)
    contentFrame.Position = UDim2.new(0, 0, 0, 60)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Category Tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Size = UDim2.new(1, -20, 0, 40)
    tabFrame.Position = UDim2.new(0, 10, 0, 10)
    tabFrame.BackgroundColor3 = Color3.new(1, 1, 1) -- White tabs
    tabFrame.BorderSizePixel = 2
    tabFrame.BorderColor3 = Color3.new(0, 0, 0) -- Black border
    tabFrame.Parent = contentFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabFrame
    
    -- Farm Tab
    local farmTab = Instance.new("TextButton")
    farmTab.Name = "FarmTab"
    farmTab.Size = UDim2.new(0.33, 0, 1, 0)
    farmTab.Position = UDim2.new(0, 0, 0, 0)
    farmTab.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    farmTab.BorderSizePixel = 0
    farmTab.Text = "🌾 Farm"
    farmTab.TextColor3 = Color3.new(0, 0, 0)
    farmTab.TextSize = 14
    farmTab.Font = Enum.Font.GothamBold
    farmTab.Parent = tabFrame
    
    local farmTabCorner = Instance.new("UICorner")
    farmTabCorner.CornerRadius = UDim.new(0, 8)
    farmTabCorner.Parent = farmTab
    
    -- Utility Tab
    local utilityTab = Instance.new("TextButton")
    utilityTab.Name = "UtilityTab"
    utilityTab.Size = UDim2.new(0.33, 0, 1, 0)
    utilityTab.Position = UDim2.new(0.33, 0, 0, 0)
    utilityTab.BackgroundColor3 = Color3.new(1, 1, 1)
    utilityTab.BorderSizePixel = 0
    utilityTab.Text = "🔧 Utility"
    utilityTab.TextColor3 = Color3.new(0, 0, 0)
    utilityTab.TextSize = 14
    utilityTab.Font = Enum.Font.GothamBold
    utilityTab.Parent = tabFrame
    
    local utilityTabCorner = Instance.new("UICorner")
    utilityTabCorner.CornerRadius = UDim.new(0, 8)
    utilityTabCorner.Parent = utilityTab
    
    -- Auto Tab
    local autoTab = Instance.new("TextButton")
    autoTab.Name = "AutoTab"
    autoTab.Size = UDim2.new(0.34, 0, 1, 0)
    autoTab.Position = UDim2.new(0.66, 0, 0, 0)
    autoTab.BackgroundColor3 = Color3.new(1, 1, 1)
    autoTab.BorderSizePixel = 0
    autoTab.Text = "🤖 Auto"
    autoTab.TextColor3 = Color3.new(0, 0, 0)
    autoTab.TextSize = 14
    autoTab.Font = Enum.Font.GothamBold
    autoTab.Parent = tabFrame
    
    local autoTabCorner = Instance.new("UICorner")
    autoTabCorner.CornerRadius = UDim.new(0, 8)
    autoTabCorner.Parent = autoTab
    
    -- Farm Tab Content
    local farmContent = Instance.new("Frame")
    farmContent.Name = "FarmContent"
    farmContent.Size = UDim2.new(1, -20, 1, -60)
    farmContent.Position = UDim2.new(0, 10, 0, 60)
    farmContent.BackgroundColor3 = Color3.new(1, 1, 1) -- White background
    farmContent.BorderSizePixel = 2
    farmContent.BorderColor3 = Color3.new(0, 0, 0) -- Black border
    farmContent.Visible = true
    farmContent.Parent = contentFrame
    
    local farmContentCorner = Instance.new("UICorner")
    farmContentCorner.CornerRadius = UDim.new(0, 8)
    farmContentCorner.Parent = farmContent
    
    -- Chest Section
    local chestFrame = Instance.new("Frame")
    chestFrame.Name = "ChestFrame"
    chestFrame.Size = UDim2.new(1, -20, 0, 50)
    chestFrame.Position = UDim2.new(0, 10, 0, 20)
    chestFrame.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    chestFrame.BorderSizePixel = 2
    chestFrame.BorderColor3 = Color3.new(0, 0, 0)
    chestFrame.Parent = farmContent
    
    local chestCorner = Instance.new("UICorner")
    chestCorner.CornerRadius = UDim.new(0, 6)
    chestCorner.Parent = chestFrame
    
    local chestTitle = Instance.new("TextLabel")
    chestTitle.Name = "ChestTitle"
    chestTitle.Size = UDim2.new(0.6, 0, 1, 0)
    chestTitle.Position = UDim2.new(0, 10, 0, 0)
    chestTitle.BackgroundTransparency = 1
    chestTitle.Text = "💎 Chest Collector"
    chestTitle.TextColor3 = Color3.new(0, 0, 0)
    chestTitle.TextSize = 14
    chestTitle.Font = Enum.Font.GothamBold
    chestTitle.TextXAlignment = Enum.TextXAlignment.Left
    chestTitle.Parent = chestFrame
    
    local chestCountLabel = Instance.new("TextLabel")
    chestCountLabel.Name = "ChestCount"
    chestCountLabel.Size = UDim2.new(0.2, 0, 1, 0)
    chestCountLabel.Position = UDim2.new(0.6, 0, 0, 0)
    chestCountLabel.BackgroundTransparency = 1
    chestCountLabel.Text = "0"
    chestCountLabel.TextColor3 = Color3.new(0, 0.5, 1)
    chestCountLabel.TextSize = 14
    chestCountLabel.Font = Enum.Font.GothamBold
    chestCountLabel.TextXAlignment = Enum.TextXAlignment.Center
    chestCountLabel.Parent = chestFrame
    
    local chestButton = Instance.new("TextButton")
    chestButton.Name = "ChestButton"
    chestButton.Size = UDim2.new(0.2, 0, 0, 30)
    chestButton.Position = UDim2.new(0.8, 0, 0, 10)
    chestButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    chestButton.BorderSizePixel = 2
    chestButton.BorderColor3 = Color3.new(0, 0, 0)
    chestButton.Text = "▶ Start"
    chestButton.TextColor3 = Color3.new(0, 0, 0)
    chestButton.TextSize = 12
    chestButton.Font = Enum.Font.GothamBold
    chestButton.Parent = chestFrame
    
    local chestBtnCorner = Instance.new("UICorner")
    chestBtnCorner.CornerRadius = UDim.new(0, 4)
    chestBtnCorner.Parent = chestButton
    
    -- Barrel Section
    local barrelFrame = Instance.new("Frame")
    barrelFrame.Name = "BarrelFrame"
    barrelFrame.Size = UDim2.new(1, -20, 0, 50)
    barrelFrame.Position = UDim2.new(0, 10, 0, 80)
    barrelFrame.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    barrelFrame.BorderSizePixel = 2
    barrelFrame.BorderColor3 = Color3.new(0, 0, 0)
    barrelFrame.Parent = farmContent
    
    local barrelCorner = Instance.new("UICorner")
    barrelCorner.CornerRadius = UDim.new(0, 6)
    barrelCorner.Parent = barrelFrame
    
    local barrelTitle = Instance.new("TextLabel")
    barrelTitle.Name = "BarrelTitle"
    barrelTitle.Size = UDim2.new(0.6, 0, 1, 0)
    barrelTitle.Position = UDim2.new(0, 10, 0, 0)
    barrelTitle.BackgroundTransparency = 1
    barrelTitle.Text = "🛢️ Barrel Circle"
    barrelTitle.TextColor3 = Color3.new(0, 0, 0)
    barrelTitle.TextSize = 14
    barrelTitle.Font = Enum.Font.GothamBold
    barrelTitle.TextXAlignment = Enum.TextXAlignment.Left
    barrelTitle.Parent = barrelFrame
    
    local barrelCountLabel = Instance.new("TextLabel")
    barrelCountLabel.Name = "BarrelCount"
    barrelCountLabel.Size = UDim2.new(0.2, 0, 1, 0)
    barrelCountLabel.Position = UDim2.new(0.6, 0, 0, 0)
    barrelCountLabel.BackgroundTransparency = 1
    barrelCountLabel.Text = "0"
    barrelCountLabel.TextColor3 = Color3.new(1, 0.5, 0)
    barrelCountLabel.TextSize = 14
    barrelCountLabel.Font = Enum.Font.GothamBold
    barrelCountLabel.TextXAlignment = Enum.TextXAlignment.Center
    barrelCountLabel.Parent = barrelFrame
    
    local barrelButton = Instance.new("TextButton")
    barrelButton.Name = "BarrelButton"
    barrelButton.Size = UDim2.new(0.2, 0, 0, 30)
    barrelButton.Position = UDim2.new(0.8, 0, 0, 10)
    barrelButton.BackgroundColor3 = Color3.new(1, 0.6, 0.2)
    barrelButton.BorderSizePixel = 2
    barrelButton.BorderColor3 = Color3.new(0, 0, 0)
    barrelButton.Text = "▶ Start"
    barrelButton.TextColor3 = Color3.new(0, 0, 0)
    barrelButton.TextSize = 12
    barrelButton.Font = Enum.Font.GothamBold
    barrelButton.Parent = barrelFrame
    
    local barrelBtnCorner = Instance.new("UICorner")
    barrelBtnCorner.CornerRadius = UDim.new(0, 4)
    barrelBtnCorner.Parent = barrelButton
    
    -- Utility Tab Content
    local utilityContent = Instance.new("Frame")
    utilityContent.Name = "UtilityContent"
    utilityContent.Size = UDim2.new(1, -20, 1, -60)
    utilityContent.Position = UDim2.new(0, 10, 0, 60)
    utilityContent.BackgroundColor3 = Color3.new(1, 1, 1) -- White background
    utilityContent.BorderSizePixel = 2
    utilityContent.BorderColor3 = Color3.new(0, 0, 0) -- Black border
    utilityContent.Visible = false
    utilityContent.Parent = contentFrame
    
    local utilityContentCorner = Instance.new("UICorner")
    utilityContentCorner.CornerRadius = UDim.new(0, 8)
    utilityContentCorner.Parent = utilityContent
    
    -- Fruit Section
    local fruitFrame = Instance.new("Frame")
    fruitFrame.Name = "FruitFrame"
    fruitFrame.Size = UDim2.new(1, -20, 0, 50)
    fruitFrame.Position = UDim2.new(0, 10, 0, 20)
    fruitFrame.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    fruitFrame.BorderSizePixel = 2
    fruitFrame.BorderColor3 = Color3.new(0, 0, 0)
    fruitFrame.Parent = utilityContent
    
    local fruitCorner = Instance.new("UICorner")
    fruitCorner.CornerRadius = UDim.new(0, 6)
    fruitCorner.Parent = fruitFrame
    
    local fruitTitle = Instance.new("TextLabel")
    fruitTitle.Name = "FruitTitle"
    fruitTitle.Size = UDim2.new(0.6, 0, 1, 0)
    fruitTitle.Position = UDim2.new(0, 10, 0, 0)
    fruitTitle.BackgroundTransparency = 1
    fruitTitle.Text = "🍎 Fruit Selector"
    fruitTitle.TextColor3 = Color3.new(0, 0, 0)
    fruitTitle.TextSize = 14
    fruitTitle.Font = Enum.Font.GothamBold
    fruitTitle.TextXAlignment = Enum.TextXAlignment.Left
    fruitTitle.Parent = fruitFrame
    
    local fruitCountLabel = Instance.new("TextLabel")
    fruitCountLabel.Name = "FruitCount"
    fruitCountLabel.Size = UDim2.new(0.2, 0, 1, 0)
    fruitCountLabel.Position = UDim2.new(0.6, 0, 0, 0)
    fruitCountLabel.BackgroundTransparency = 1
    fruitCountLabel.Text = "0"
    fruitCountLabel.TextColor3 = Color3.new(0, 0.8, 0.2)
    fruitCountLabel.TextSize = 14
    fruitCountLabel.Font = Enum.Font.GothamBold
    fruitCountLabel.TextXAlignment = Enum.TextXAlignment.Center
    fruitCountLabel.Parent = fruitFrame
    
    local fruitButton = Instance.new("TextButton")
    fruitButton.Name = "FruitButton"
    fruitButton.Size = UDim2.new(0.2, 0, 0, 30)
    fruitButton.Position = UDim2.new(0.8, 0, 0, 10)
    fruitButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
    fruitButton.BorderSizePixel = 2
    fruitButton.BorderColor3 = Color3.new(0, 0, 0)
    fruitButton.Text = "🍎 Select"
    fruitButton.TextColor3 = Color3.new(0, 0, 0)
    fruitButton.TextSize = 12
    fruitButton.Font = Enum.Font.GothamBold
    fruitButton.Parent = fruitFrame
    
    local fruitBtnCorner = Instance.new("UICorner")
    fruitBtnCorner.CornerRadius = UDim.new(0, 4)
    fruitBtnCorner.Parent = fruitButton
    
    -- Auto Tab Content
    local autoContent = Instance.new("Frame")
    autoContent.Name = "AutoContent"
    autoContent.Size = UDim2.new(1, -20, 1, -60)
    autoContent.Position = UDim2.new(0, 10, 0, 60)
    autoContent.BackgroundColor3 = Color3.new(1, 1, 1) -- White background
    autoContent.BorderSizePixel = 2
    autoContent.BorderColor3 = Color3.new(0, 0, 0) -- Black border
    autoContent.Visible = false
    autoContent.Parent = contentFrame
    
    local autoContentCorner = Instance.new("UICorner")
    autoContentCorner.CornerRadius = UDim.new(0, 8)
    autoContentCorner.Parent = autoContent
    
    -- Auto Respawn Section
    local respawnFrame = Instance.new("Frame")
    respawnFrame.Name = "RespawnFrame"
    respawnFrame.Size = UDim2.new(1, -20, 0, 50)
    respawnFrame.Position = UDim2.new(0, 10, 0, 20)
    respawnFrame.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    respawnFrame.BorderSizePixel = 2
    respawnFrame.BorderColor3 = Color3.new(0, 0, 0)
    respawnFrame.Parent = autoContent
    
    local respawnCorner = Instance.new("UICorner")
    respawnCorner.CornerRadius = UDim.new(0, 6)
    respawnCorner.Parent = respawnFrame
    
    local respawnTitle = Instance.new("TextLabel")
    respawnTitle.Name = "RespawnTitle"
    respawnTitle.Size = UDim2.new(0.6, 0, 1, 0)
    respawnTitle.Position = UDim2.new(0, 10, 0, 0)
    respawnTitle.BackgroundTransparency = 1
    respawnTitle.Text = "🔄 Auto Respawn"
    respawnTitle.TextColor3 = Color3.new(0, 0, 0)
    respawnTitle.TextSize = 14
    respawnTitle.Font = Enum.Font.GothamBold
    respawnTitle.TextXAlignment = Enum.TextXAlignment.Left
    respawnTitle.Parent = respawnFrame
    
    local respawnStatus = Instance.new("TextLabel")
    respawnStatus.Name = "RespawnStatus"
    respawnStatus.Size = UDim2.new(0.2, 0, 1, 0)
    respawnStatus.Position = UDim2.new(0.6, 0, 0, 0)
    respawnStatus.BackgroundTransparency = 1
    respawnStatus.Text = "OFF"
    respawnStatus.TextColor3 = Color3.new(0.8, 0.2, 0.2)
    respawnStatus.TextSize = 14
    respawnStatus.Font = Enum.Font.GothamBold
    respawnStatus.TextXAlignment = Enum.TextXAlignment.Center
    respawnStatus.Parent = respawnFrame
    
    local respawnButton = Instance.new("TextButton")
    respawnButton.Name = "RespawnButton"
    respawnButton.Size = UDim2.new(0.2, 0, 0, 30)
    respawnButton.Position = UDim2.new(0.8, 0, 0, 10)
    respawnButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
    respawnButton.BorderSizePixel = 2
    respawnButton.BorderColor3 = Color3.new(0, 0, 0)
    respawnButton.Text = "▶ Start"
    respawnButton.TextColor3 = Color3.new(0, 0, 0)
    respawnButton.TextSize = 12
    respawnButton.Font = Enum.Font.GothamBold
    respawnButton.Parent = respawnFrame
    
    local respawnBtnCorner = Instance.new("UICorner")
    respawnBtnCorner.CornerRadius = UDim.new(0, 4)
    respawnBtnCorner.Parent = respawnButton
    
    -- Auto Compass Section
    local compassFrame = Instance.new("Frame")
    compassFrame.Name = "CompassFrame"
    compassFrame.Size = UDim2.new(1, -20, 0, 50)
    compassFrame.Position = UDim2.new(0, 10, 0, 80)
    compassFrame.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    compassFrame.BorderSizePixel = 2
    compassFrame.BorderColor3 = Color3.new(0, 0, 0)
    compassFrame.Parent = autoContent
    
    local compassCorner = Instance.new("UICorner")
    compassCorner.CornerRadius = UDim.new(0, 6)
    compassCorner.Parent = compassFrame
    
    local compassTitle = Instance.new("TextLabel")
    compassTitle.Name = "CompassTitle"
    compassTitle.Size = UDim2.new(0.6, 0, 1, 0)
    compassTitle.Position = UDim2.new(0, 10, 0, 0)
    compassTitle.BackgroundTransparency = 1
    compassTitle.Text = "🧭 Auto Compass"
    compassTitle.TextColor3 = Color3.new(0, 0, 0)
    compassTitle.TextSize = 14
    compassTitle.Font = Enum.Font.GothamBold
    compassTitle.TextXAlignment = Enum.TextXAlignment.Left
    compassTitle.Parent = compassFrame
    
    local compassStatus = Instance.new("TextLabel")
    compassStatus.Name = "CompassStatus"
    compassStatus.Size = UDim2.new(0.2, 0, 1, 0)
    compassStatus.Position = UDim2.new(0.6, 0, 0, 0)
    compassStatus.BackgroundTransparency = 1
    compassStatus.Text = "OFF"
    compassStatus.TextColor3 = Color3.new(0.8, 0.2, 0.2)
    compassStatus.TextSize = 14
    compassStatus.Font = Enum.Font.GothamBold
    compassStatus.TextXAlignment = Enum.TextXAlignment.Center
    compassStatus.Parent = compassFrame
    
    local compassButton = Instance.new("TextButton")
    compassButton.Name = "CompassButton"
    compassButton.Size = UDim2.new(0.2, 0, 0, 30)
    compassButton.Position = UDim2.new(0.8, 0, 0, 10)
    compassButton.BackgroundColor3 = Color3.new(0.6, 0.2, 0.8)
    compassButton.BorderSizePixel = 2
    compassButton.BorderColor3 = Color3.new(0, 0, 0)
    compassButton.Text = "▶ Start"
    compassButton.TextColor3 = Color3.new(0, 0, 0)
    compassButton.TextSize = 12
    compassButton.Font = Enum.Font.GothamBold
    compassButton.Parent = compassFrame
    
    local compassBtnCorner = Instance.new("UICorner")
    compassBtnCorner.CornerRadius = UDim.new(0, 4)
    compassBtnCorner.Parent = compassButton
    
    screenGui.Parent = playerGui
    return screenGui, chestButton, barrelButton, fruitButton, respawnButton, compassButton, closeButton, toggleButton, farmTab, utilityTab, autoTab, farmContent, utilityContent, autoContent, chestCountLabel, barrelCountLabel, fruitCountLabel, respawnStatus, compassStatus
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
        -- Try multiple locations for barrels
        local barrelLocations = {
            workspace:FindFirstChild("Barrels"),
            workspace:FindFirstChild("Barrel"),
            workspace:FindFirstChild("BarrelSpawn"),
            workspace
        }
        
        for _, location in pairs(barrelLocations) do
            if location then
                -- Check direct children
                for _, item in pairs(location:GetChildren()) do
                    if item and item.Parent then
                        -- Check if it's a barrel by name pattern
                        if item.Name:lower():find("barrel") or item.Name:lower():find("crate") then
                            if item:FindFirstChild("ClickDetector") then
                                print("🔍 Found barrel with ClickDetector:", item.Name)
                                table.insert(barrels, item)
                            elseif item:IsA("Model") then
                                -- Check if any part in the model has ClickDetector
                                for _, part in pairs(item:GetDescendants()) do
                                    if part:IsA("BasePart") and part:FindFirstChild("ClickDetector") then
                                        print("🔍 Found barrel part with ClickDetector:", item.Name, "->", part.Name)
                                        table.insert(barrels, item)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Check nested structure (like workspace.Barrels.Barrels)
                if location:FindFirstChild("Barrels") then
                    for _, barrel in pairs(location.Barrels:GetChildren()) do
                        if barrel and barrel.Parent and barrel:FindFirstChild("ClickDetector") then
                            print("🔍 Found barrel in nested structure:", barrel.Name)
                            table.insert(barrels, barrel)
                        elseif barrel and barrel:IsA("Model") then
                            -- Check if any part in the model has ClickDetector
                            for _, part in pairs(barrel:GetDescendants()) do
                                if part:IsA("BasePart") and part:FindFirstChild("ClickDetector") then
                                    print("🔍 Found barrel part in nested structure:", barrel.Name, "->", part.Name)
                                    table.insert(barrels, barrel)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        print("📊 Total barrels found:", #barrels)
        return barrels
    end)
    
    if not success then
        print("❌ Error getting barrels:", result)
    end
    
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

-- Auto Compass Functions
local function checkCompassTime()
    local success, result = pcallWrap(function()
        local questMerchant = workspace:FindFirstChild("Merchants")
        if questMerchant then
            local questMerchant2 = questMerchant:FindFirstChild("QuestMerchant2")
            if questMerchant2 then
                local clickable = questMerchant2:FindFirstChild("Clickable")
                if clickable then
                    local clickDetector = clickable:FindFirstChild("ClickDetector")
                    if clickDetector then
                        -- Fire the ClickDetector to check compass time
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
        end
        return false
    end)
    
    return success and result
end

local function claimCompass()
    local success, result = pcallWrap(function()
        local args = {"Claim1"}
        ReplicatedStorage:WaitForChild("Connections"):WaitForChild("Claim_Sam"):FireServer(unpack(args))
        return true
    end)
    
    if success then
        compassCount = compassCount + 1
        print("✅ Successfully claimed compass! Total: " .. compassCount)
    else
        print("❌ Failed to claim compass:", result)
    end
    
    return success and result
end

local function autoCompass(compassCountLabel)
    if not isCompassAutoEnabled then return end
    
    -- Check cooldown to prevent spam
    local currentTime = tick()
    if currentTime - lastCompassCheck < compassCheckCooldown then
        return
    end
    lastCompassCheck = currentTime
    
    spawn(function()
        local success, result = pcallWrap(function()
            print("🧭 Checking compass availability...")
            
            -- Check compass time first
            local checkSuccess = checkCompassTime()
            if checkSuccess then
                wait(0.5) -- Wait a bit for the check to complete
                
                print("🧭 Attempting to claim compass...")
                
                -- Try to claim the compass
                local claimSuccess = claimCompass()
                if claimSuccess then
                    print("🧭 Compass claimed! Total: " .. compassCount)
                else
                    print("🧭 Compass not available yet...")
                end
            else
                print("🧭 Failed to check compass time...")
            end
        end)
        
        if not success then
            print("❌ Error in autoCompass:", result)
        end
    end)
end

-- Auto Functions
local function autoChest(chestCountLabel)
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
                print("💎 Collecting chests using improved methods...")
                
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
                            print("✅ Successfully collected chest " .. i .. " (Total: " .. chestCount .. ")")
                        else
                            print("❌ Failed to collect chest " .. i)
                        end
                        
                        -- Add small delay to prevent spam
                        wait(0.2)
                    else
                        print("⚠️ Chest " .. i .. " no longer exists, skipping")
                    end
                end
                
                if isChestCollecting then
                    print("🔄 All chests processed, waiting before next scan...")
                    wait(3)
                end
            else
                print("🔍 No chests found, waiting before next scan...")
                wait(2)
            end
        end)
        
        if not success then
            print("❌ Error in autoChest:", result)
            wait(1)
        end
    end)
end

local function autoBarrel(barrelCountLabel)
    if not isBarrelFarming then return end
    
    spawn(function()
        local barrels = getBarrels()
        if barrelCountLabel and barrelCountLabel.Parent then
        barrelCountLabel.Text = tostring(#barrels)
        end
        
        if #barrels > 0 then
            print("🛢️ Teleporting to barrels and using ClickDetector...")
            
            for i, barrel in pairs(barrels) do
                if not isBarrelFarming then break end
                
                -- Get barrel position
                local barrelPosition
                if barrel:IsA("BasePart") then
                    barrelPosition = barrel.Position
                elseif barrel:IsA("Model") then
                    local part = barrel:FindFirstChild("HumanoidRootPart") or barrel.PrimaryPart or barrel:FindFirstChildOfClass("BasePart")
                    if part then
                        barrelPosition = part.Position
                    end
                end
                
                if barrelPosition and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Teleport player to barrel location
                    local humanoidRootPart = player.Character.HumanoidRootPart
                    local teleportPosition = barrelPosition + Vector3.new(0, 5, 0) -- Teleport slightly above the barrel
                    
                    humanoidRootPart.CFrame = CFrame.new(teleportPosition)
                    print("🚀 Teleported to barrel " .. i .. " at position:", barrelPosition)
                    
                    wait(0.2) -- Wait for teleportation to complete
                    
                    -- Use ClickDetector to interact with barrel
                    local clickDetector = barrel:FindFirstChild("ClickDetector")
                    
                    -- If no ClickDetector on the barrel itself, check its descendants
                    if not clickDetector and barrel:IsA("Model") then
                        for _, part in pairs(barrel:GetDescendants()) do
                            if part:IsA("BasePart") and part:FindFirstChild("ClickDetector") then
                                clickDetector = part:FindFirstChild("ClickDetector")
                                print("🔍 Found ClickDetector in barrel part:", part.Name)
                                break
                            end
                        end
                    end
                    
                    if clickDetector then
                        print("🎯 Using ClickDetector on barrel " .. i)
                        
                        -- Try multiple methods to activate ClickDetector
                        local clickSuccess = false
                        
                        -- Method 1: fireclickdetector
                        if fireclickdetector then
                            local success, result = pcall(function()
                                fireclickdetector(clickDetector)
                                return true
                            end)
                            if success then
                                clickSuccess = true
                                print("✅ Used fireclickdetector on barrel " .. i)
                            end
                        end
                        
                        -- Method 2: MouseClick event
                        if not clickSuccess and clickDetector.MouseClick then
                            local success, result = pcall(function()
                                clickDetector.MouseClick:Fire(player)
                                return true
                            end)
                            if success then
                                clickSuccess = true
                                print("✅ Used MouseClick event on barrel " .. i)
                            end
                        end
                        
                        -- Method 3: firesignal
                        if not clickSuccess and firesignal and clickDetector.MouseClick then
                            local success, result = pcall(function()
                                firesignal(clickDetector.MouseClick, player)
                                return true
                            end)
                            if success then
                                clickSuccess = true
                                print("✅ Used firesignal on barrel " .. i)
                            end
                        end
                        
                        if clickSuccess then
                            barrelCount = barrelCount + 1
                            print("🎉 Successfully farmed barrel " .. i .. " (Total: " .. barrelCount .. ")")
                        else
                            print("❌ Failed to farm barrel " .. i)
                        end
                    else
                        print("⚠️ No ClickDetector found on barrel " .. i)
                    end
                    
                    wait(0.3) -- Wait before next barrel
                else
                    print("⚠️ Invalid barrel or character not found for barrel " .. i)
                    wait(0.1)
                end
            end
            
            if isBarrelFarming then
                print("🔄 All barrels processed, waiting before next scan...")
                wait(3)
            end
        else
            print("🔍 No barrels found, waiting before next scan...")
            wait(1)
        end
    end)
end

-- Toggle Functions
local function toggleChest(button, chestCountLabel)
    isChestCollecting = not isChestCollecting
    
    if isChestCollecting then
        button.Text = "⏹ Stop"
        button.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
        
        chestConnection = RunService.Heartbeat:Connect(function()
            if isChestCollecting then
                autoChest(chestCountLabel)
            end
        end)
        print("💎 Chest Collector started!")
    else
        button.Text = "▶ Start"
        button.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
        if chestConnection then
            chestConnection:Disconnect()
            chestConnection = nil
        end
        print("💎 Chest Collector stopped!")
    end
end

local function toggleBarrel(button, barrelCountLabel)
    isBarrelFarming = not isBarrelFarming
    
    if isBarrelFarming then
        button.Text = "⏹ Stop"
        button.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
        barrelConnection = RunService.Heartbeat:Connect(function()
            if isBarrelFarming then
                autoBarrel(barrelCountLabel)
            end
        end)
        print("🛢️ Barrel Circle started!")
    else
        button.Text = "▶ Start"
        button.BackgroundColor3 = Color3.new(1, 0.6, 0.2)
        if barrelConnection then
            barrelConnection:Disconnect()
            barrelConnection = nil
        end
        print("🛢️ Barrel Circle stopped!")
    end
end

local function openFruitSelector()
    createFruitSelectorGUI()
    print("🍎 Fruit selector opened - choose fruits to collect")
end

local function toggleRespawn(button, respawnStatus)
    isAutoRespawnEnabled = not isAutoRespawnEnabled
    
    if isAutoRespawnEnabled then
        button.Text = "⏹ Stop"
        button.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
        respawnStatus.Text = "ON"
        respawnStatus.TextColor3 = Color3.new(0.2, 1, 0.2)
        
        respawnConnection = RunService.Heartbeat:Connect(function()
            if isAutoRespawnEnabled then
                autoRespawn()
            end
        end)
        print("🔄 Auto Respawn System started!")
    else
        button.Text = "▶ Start"
        button.BackgroundColor3 = Color3.new(0.2, 0.4, 0.8)
        respawnStatus.Text = "OFF"
        respawnStatus.TextColor3 = Color3.new(0.8, 0.4, 0.4)
        
        if respawnConnection then
            respawnConnection:Disconnect()
            respawnConnection = nil
        end
        print("🔄 Auto Respawn System stopped!")
    end
end

local function toggleCompass(button, compassStatus)
    isCompassAutoEnabled = not isCompassAutoEnabled
    
    if isCompassAutoEnabled then
        button.Text = "⏹ Stop"
        button.BackgroundColor3 = Color3.new(0.9, 0.2, 0.2)
        compassStatus.Text = "ON"
        compassStatus.TextColor3 = Color3.new(0.2, 1, 0.2)
        
        compassConnection = RunService.Heartbeat:Connect(function()
            if isCompassAutoEnabled then
                autoCompass(nil) -- No count label for compass
            end
        end)
        print("🧭 Auto Compass System started!")
    else
        button.Text = "▶ Start"
        button.BackgroundColor3 = Color3.new(0.6, 0.2, 0.8)
        compassStatus.Text = "OFF"
        compassStatus.TextColor3 = Color3.new(0.8, 0.4, 0.4)
        
        if compassConnection then
            compassConnection:Disconnect()
            compassConnection = nil
        end
        print("🧭 Auto Compass System stopped!")
    end
end

-- Tab Functions
local function switchTab(activeTab, activeContent, inactiveTab1, inactiveTab2, inactiveContent1, inactiveContent2)
    -- Reset all tabs
    activeTab.BackgroundColor3 = Color3.new(0.9, 0.9, 0.9)
    inactiveTab1.BackgroundColor3 = Color3.new(1, 1, 1)
    inactiveTab2.BackgroundColor3 = Color3.new(1, 1, 1)
    
    -- Show active content, hide others
    activeContent.Visible = true
    inactiveContent1.Visible = false
    inactiveContent2.Visible = false
end

-- Toggle Function (Minimize/Maximize)
local function toggleGUI()
    if gui and gui.Parent then
        local mainFrame = gui:FindFirstChild("MainFrame")
        local contentFrame = mainFrame:FindFirstChild("ContentFrame")
        if mainFrame and contentFrame then
            if mainFrame.Size.Y.Offset > 100 then
                -- Minimize - hide content, keep only header
                mainFrame.Size = UDim2.new(0, 400, 0, 60)
                contentFrame.Visible = false
                toggleButton.Text = "+"
            else
                -- Maximize - show content
                mainFrame.Size = UDim2.new(0, 400, 0, 300)
                contentFrame.Visible = true
                toggleButton.Text = "−"
            end
        end
    end
end

-- Close Function
local function closeGUI()
    isChestCollecting = false
    isBarrelFarming = false
    isAutoRespawnEnabled = false
    isCompassAutoEnabled = false
    
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
    if compassConnection then
        compassConnection:Disconnect()
        compassConnection = nil
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
    compassCount = 0
end

-- Initialize
wait(0.5)

gui, chestButton, barrelButton, fruitButton, respawnButton, compassButton, closeButton, toggleButton, farmTab, utilityTab, autoTab, farmContent, utilityContent, autoContent, chestCountLabel, barrelCountLabel, fruitCountLabel, respawnStatus, compassStatus = createGUI()

-- Connect Events
chestButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        toggleChest(chestButton, chestCountLabel)
    end)
end)

barrelButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        toggleBarrel(barrelButton, barrelCountLabel)
    end)
end)

fruitButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        openFruitSelector()
    end)
end)

respawnButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        toggleRespawn(respawnButton, respawnStatus)
    end)
end)

compassButton.MouseButton1Click:Connect(function()
    pcallWrap(function()
        toggleCompass(compassButton, compassStatus)
    end)
end)

-- Tab Events
farmTab.MouseButton1Click:Connect(function()
    pcallWrap(function()
        switchTab(farmTab, farmContent, utilityTab, autoTab, utilityContent, autoContent)
    end)
end)

utilityTab.MouseButton1Click:Connect(function()
    pcallWrap(function()
        switchTab(utilityTab, utilityContent, farmTab, autoTab, farmContent, autoContent)
    end)
end)

autoTab.MouseButton1Click:Connect(function()
    pcallWrap(function()
        switchTab(autoTab, autoContent, farmTab, utilityTab, farmContent, utilityContent)
    end)
end)

-- Toggle and Close Events
toggleButton.MouseButton1Click:Connect(function()
    pcallWrap(toggleGUI)
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
print("🎮 GSO Hub v3 loaded!")
print("Complete rewrite with all new features:")
print("💎 Chest: Advanced collection system")
print("🛢️ Barrel: Circle magnetizing system")
print("🍎 Fruit: Selector GUI with teleporting")
print("🔄 Respawn: Auto respawn on death")
print("🧭 Compass: Auto compass claiming system")
print("========================================")
print("🚀 Ready for complete automation!")
