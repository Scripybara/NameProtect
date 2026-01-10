--[[
    SwiftbaraProtect v1.0.0
    Made by Swiftbara <3
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local originalName = player.Name
local originalDisplay = player.DisplayName

local settings = {
    enabled = true,
    myName = "SwiftbaraProtect",
    othersName = "SwiftbaraProtect",
}

local connections = {}
local monitoredTexts = {}

print("SwiftbaraProtect v6.0 - Loading...")

-- Replace names in text
local function replaceName(text)
    if type(text) ~= "string" or text == "" then 
        return text 
    end
    
    local result = text
    
    result = result:gsub(originalName, settings.myName)
    if originalDisplay ~= "" and originalDisplay ~= originalName then
        result = result:gsub(originalDisplay, settings.myName)
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            result = result:gsub(p.Name, settings.othersName)
            if p.DisplayName ~= "" and p.DisplayName ~= p.Name then
                result = result:gsub(p.DisplayName, settings.othersName)
            end
        end
    end
    
    return result
end

-- Monitor text changes
local function watchText(obj)
    if not obj then return end
    if monitoredTexts[obj] then return end
    
    local success = pcall(function()
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            monitoredTexts[obj] = true
            
            local textChanged = obj:GetPropertyChangedSignal("Text"):Connect(function()
                if not settings.enabled then return end
                
                pcall(function()
                    local current = obj.Text
                    if current and current ~= "" then
                        local replaced = replaceName(current)
                        if replaced ~= current then
                            obj.Text = replaced
                        end
                    end
                end)
            end)
            
            table.insert(connections, textChanged)
            
            if settings.enabled then
                local current = obj.Text
                if current and current ~= "" then
                    local replaced = replaceName(current)
                    if replaced ~= current then
                        obj.Text = replaced
                    end
                end
            end
        end
    end)
end

-- Protect leaderboard
local function protectLeaderboard()
    pcall(function()
        local playerList = CoreGui:FindFirstChild("PlayerList")
        if playerList then
            for _, child in pairs(playerList:GetDescendants()) do
                watchText(child)
            end
            
            local added = playerList.DescendantAdded:Connect(function(child)
                task.wait()
                if settings.enabled then
                    watchText(child)
                end
            end)
            
            table.insert(connections, added)
        end
    end)
end

-- Protect chat
local function protectChat()
    pcall(function()
        local chat = CoreGui:FindFirstChild("ExperienceChat") or CoreGui:FindFirstChild("Chat")
        if chat then
            for _, child in pairs(chat:GetDescendants()) do
                watchText(child)
            end
            
            local added = chat.DescendantAdded:Connect(function(child)
                task.wait()
                if settings.enabled then
                    watchText(child)
                end
            end)
            
            table.insert(connections, added)
        end
    end)
end

-- Hide nametags
local function hideNames(humanoid)
    if not humanoid then return end
    pcall(function()
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end)
end

local function hideAllNames()
    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                hideNames(humanoid)
            end
            
            local head = char:FindFirstChild("Head")
            if head then
                for _, child in pairs(head:GetChildren()) do
                    if child:IsA("BillboardGui") then
                        child.Enabled = false
                    end
                end
            end
        end
    end
end

-- Main scan
local function scanAll()
    if not settings.enabled then return end
    
    hideAllNames()
    
    pcall(function()
        for _, child in pairs(CoreGui:GetDescendants()) do
            watchText(child)
        end
    end)
    
    pcall(function()
        local gui = player:FindFirstChild("PlayerGui")
        if gui then
            for _, child in pairs(gui:GetDescendants()) do
                watchText(child)
            end
        end
    end)
end

-- Start protection
local function startProtection()
    scanAll()
    protectLeaderboard()
    protectChat()
    
    local loop = RunService.Heartbeat:Connect(function()
        if settings.enabled then
            hideAllNames()
        end
    end)
    table.insert(connections, loop)
    
    local coreAdded = CoreGui.DescendantAdded:Connect(function(child)
        if settings.enabled then
            watchText(child)
        end
    end)
    table.insert(connections, coreAdded)
    
    pcall(function()
        local gui = player:WaitForChild("PlayerGui", 5)
        if gui then
            local guiAdded = gui.DescendantAdded:Connect(function(child)
                if settings.enabled then
                    watchText(child)
                end
            end)
            table.insert(connections, guiAdded)
        end
    end)
    
    for _, p in pairs(Players:GetPlayers()) do
        local charAdded = p.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if settings.enabled then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    hideNames(humanoid)
                end
                
                local head = char:FindFirstChild("Head")
                if head then
                    for _, child in pairs(head:GetChildren()) do
                        if child:IsA("BillboardGui") then
                            child.Enabled = false
                        end
                    end
                end
            end
        end)
        table.insert(connections, charAdded)
    end
    
    local playerAdded = Players.PlayerAdded:Connect(function(p)
        local charAdded = p.CharacterAdded:Connect(function(char)
            task.wait(0.3)
            if settings.enabled then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    hideNames(humanoid)
                end
                
                local head = char:FindFirstChild("Head")
                if head then
                    for _, child in pairs(head:GetChildren()) do
                        if child:IsA("BillboardGui") then
                            child.Enabled = false
                        end
                    end
                end
            end
        end)
        table.insert(connections, charAdded)
    end)
    table.insert(connections, playerAdded)
    
    task.spawn(function()
        while task.wait(2) do
            if settings.enabled then
                protectLeaderboard()
                protectChat()
            end
        end
    end)
end

-- Stop protection
local function stopProtection()
    for _, p in pairs(Players:GetPlayers()) do
        pcall(function()
            local char = p.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
                end
                
                local head = char:FindFirstChild("Head")
                if head then
                    for _, child in pairs(head:GetChildren()) do
                        if child:IsA("BillboardGui") then
                            child.Enabled = true
                        end
                    end
                end
            end
        end)
    end
    
    monitoredTexts = {}
end

-- Create GUI
local function makeGUI()
    pcall(function()
        if CoreGui:FindFirstChild("SwiftbaraProtectGUI") then
            CoreGui.SwiftbaraProtectGUI:Destroy()
        end
    end)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "SwiftbaraProtectGUI"
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 200, 0, 45)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 200, 255)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 130, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SwiftbaraProtect"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 30)
    button.Position = UDim2.new(1, -58, 0.5, -15)
    button.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    button.Text = "ON"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    button.MouseButton1Click:Connect(function()
        settings.enabled = not settings.enabled
        
        if settings.enabled then
            button.Text = "ON"
            button.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
            stroke.Color = Color3.fromRGB(100, 200, 255)
            monitoredTexts = {}
            scanAll()
            protectLeaderboard()
            protectChat()
        else
            button.Text = "OFF"
            button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            stroke.Color = Color3.fromRGB(200, 60, 60)
            stopProtection()
        end
    end)
    
    local dragging, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            frame.Visible = not frame.Visible
        end
    end)
    
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        elseif gethui then
            gui.Parent = gethui()
        else
            gui.Parent = CoreGui
        end
    end)
    
    return gui
end

makeGUI()
startProtection()

print("SwiftbaraProtect v6.0 - Active!")
print("Original Name: " .. originalName)
print("Spoofed Name: " .. settings.myName)
print("Press RIGHT CTRL to hide/show")

getgenv().SwiftbaraProtect = {
    SetMyName = function(name)
        settings.myName = name
        monitoredTexts = {}
        scanAll()
        print("Your name changed to: " .. name)
    end,
    
    SetOthersName = function(name)
        settings.othersName = name
        monitoredTexts = {}
        scanAll()
        print("Others name changed to: " .. name)
    end,
    
    Toggle = function(state)
        settings.enabled = state
        if not state then 
            stopProtection() 
        else
            monitoredTexts = {}
            scanAll()
            protectLeaderboard()
            protectChat()
        end
    end,
    
    Destroy = function()
        settings.enabled = false
        stopProtection()
        for _, conn in pairs(connections) do
            pcall(function() 
                conn:Disconnect() 
            end)
        end
        pcall(function() 
            CoreGui.SwiftbaraProtectGUI:Destroy() 
        end)
        print("SwiftbaraProtect - Destroyed!")
    end
}
