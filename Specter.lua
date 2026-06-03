-- [[
-- SPECTER X PREMIUM (SAFE LOADSTRING VERSION)
-- Anti-Crash & Anti-Nil protection added for all mobile executors.
-- ]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local GuiParent = localPlayer:WaitForChild("PlayerGui")

-- // SPECTER X CONFIGURATION
local Config = {
    SilentAim = true,
    ShowFOV = true,
    FOVRadius = 150,
    FOVColor = Color3.fromRGB(0, 255, 200),
    
    -- ESP Settings
    ESP_Box = false,
    ESP_Tracer = false,
    ESP_Color = Color3.fromRGB(255, 0, 100),
    Tracer_Origin = "Bottom"
}

-- Key System Data
local TargetKey = "script-beta2U9YPLGP8"
-- YENİ PREMIUM LINK ENTEGRE EDİLDİ
local KeyLink = "https://work.ink/2CXm/specter-x-premium"

local isAlive = false
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpecterXSystemGui"
ScreenGui.Parent = GuiParent
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- // VERIFICATION & CORE LOGIC INITIALIZATION
local MainFrame = Instance.new("Frame")
local function StartCheat()
    MainFrame.Visible = true
    
    -- Safe Drawing Library Check
    local fovCircle = nil
    local drawingSuccess, drawingLib = pcall(function() return Drawing end)

    if drawingSuccess and drawingLib and type(drawingLib) == "table" and drawingLib.new then
        pcall(function()
            local c = drawingLib.new("Circle")
            c.Color = Config.FOVColor
            c.Thickness = 1.5
            c.NumSides = 64
            c.Radius = Config.FOVRadius
            c.Filled = false
            c.Visible = Config.ShowFOV
            fovCircle = c
        end)
    end

    if fovCircle then
        RunService.RenderStepped:Connect(function()
            if Config.ShowFOV and isAlive and camera then
                local viewportSize = camera.ViewportSize
                if viewportSize then
                    fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                    fovCircle.Radius = Config.FOVRadius
                    fovCircle.Color = Config.FOVColor
                    fovCircle.Visible = true
                else
                    fovCircle.Visible = false
                end
            else
                fovCircle.Visible = false
            end
        end)
    end

    local function monitorCharacter(character)
        isAlive = true
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function() isAlive = false end)
        end
    end
    if localPlayer.Character then monitorCharacter(localPlayer.Character) end
    localPlayer.CharacterAdded:Connect(monitorCharacter)
    localPlayer.CharacterRemoving:Connect(function() isAlive = false end)

    -- Closest Target Logic
    local function getClosestHeadInFOV()
        if not isAlive or not camera or not Config.SilentAim then return nil end
        local closestHead = nil
        local shortestDistance = Config.FOVRadius
        local viewportSize = camera.ViewportSize
        local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local head = char:FindFirstChild("Head")
                    if humanoid and head and humanoid.Health > 0 then
                        local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local targetPos2D = Vector2.new(screenPosition.X, screenPosition.Y)
                            local distance = (targetPos2D - screenCenter).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestHead = head
                            end
                        end
                    end
                end
            end
        end
        return closestHead
    end

    -- Hook Mechanism
    local BulletHandlerModule = nil
    local rsm = ReplicatedStorage:FindFirstChild("ModuleScripts")
    if rsm and rsm:FindFirstChild("GunModules") and rsm.GunModules:FindFirstChild("BulletHandler") then
        BulletHandlerModule = require(rsm.GunModules.BulletHandler)
    elseif type(getloadedmodules) == "function" then
        for _, mod in pcall(getloadedmodules) do
            if type(mod) == "table" and mod.Name == "BulletHandler" then BulletHandlerModule = require(mod) break end
        end
    end

    if BulletHandlerModule and type(BulletHandlerModule.Fire) == "function" then
        local originalFire = BulletHandlerModule.Fire
        BulletHandlerModule.Fire = function(p6)
            if isAlive and type(p6) == "table" and Config.SilentAim then
                if p6.Origin and p6.Direction then
                    local targetHead = getClosestHeadInFOV()
                    if targetHead then
                        local newDirection = (targetHead.Position - p6.Origin).Unit
                        if newDirection.X == newDirection.X then p6.Direction = newDirection end
                    end
                end
            end
            return originalFire(p6)
        end
    end

    -- // ADVANCED ESP SYSTEM (PROTECTED)
    if drawingSuccess and drawingLib and type(drawingLib) == "table" and drawingLib.new then
        local function CreateESP(player)
            local Box, Tracer
            pcall(function()
                Box = drawingLib.new("Square")
                Box.Thickness = 1.5
                Box.Filled = false
                Box.Color = Config.ESP_Color
                Box.Visible = false

                Tracer = drawingLib.new("Line")
                Tracer.Thickness = 1.5
                Tracer.Color = Config.ESP_Color
                Tracer.Visible = false
            end)

            if not Box or not Tracer then return end

            local updater
            updater = RunService.RenderStepped:Connect(function()
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                    local hrp = player.Character.HumanoidRootPart
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    
                    if onScreen then
                        if Config.ESP_Box then
                            local scale = 1000 / screenPos.Z
                            Box.Size = Vector2.new(scale * 1.5, scale * 2)
                            Box.Position = Vector2.new(screenPos.X - Box.Size.X / 2, screenPos.Y - Box.Size.Y / 2)
                            Box.Color = Config.ESP_Color
                            Box.Visible = true
                        else
                            Box.Visible = false
                        end

                        if Config.ESP_Tracer then
                            local viewportSize = camera.ViewportSize
                            if Config.Tracer_Origin == "Bottom" then
                                Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                            else
                                Tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                            end
                            Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                            Tracer.Color = Config.ESP_Color
                            Tracer.Visible = true
                        else
                            Tracer.Visible = false
                        end
                    else
                        Box.Visible = false
                        Tracer.Visible = false
                    end
                else
                    Box.Visible = false
                    Tracer.Visible = false
                    if not Players:FindFirstChild(player.Name) then
                        pcall(function() Box:Remove() Tracer:Remove() end)
                        updater:Disconnect()
                    end
                end
            end)
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer then CreateESP(p) end
        end
        Players.PlayerAdded:Connect(function(p)
            if p ~= localPlayer then CreateESP(p) end
        end)
    end
end

-- // 1. KEY SYSTEM GUI
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Parent = ScreenGui
KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
KeyFrame.Position = UDim2.new(0.5, -160, 0.4, -90)
KeyFrame.Size = UDim2.new(0, 320, 0, 180)
local kCorner = Instance.new("UICorner")
kCorner.CornerRadius = UDim.new(0, 10)
kCorner.Parent = KeyFrame

local kTitle = Instance.new("TextLabel")
kTitle.Parent = KeyFrame
kTitle.BackgroundTransparency = 1
kTitle.Position = UDim2.new(0, 0, 0, 15)
kTitle.Size = UDim2.new(1, 0, 0, 25)
kTitle.Font = Enum.Font.GothamBold
kTitle.Text = "SPECTER X - KEY SYSTEM"
kTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
kTitle.TextSize = 15

local KeyInput = Instance.new("TextBox")
KeyInput.Parent = KeyFrame
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
KeyInput.Position = UDim2.new(0, 20, 0, 55)
KeyInput.Size = UDim2.new(1, -40, 0, 35)
KeyInput.Font = Enum.Font.Gotham
KeyInput.PlaceholderText = "Enter key here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
local kiCorner = Instance.new("UICorner")
kiCorner.CornerRadius = UDim.new(0, 6)
kiCorner.Parent = KeyInput

local GetKeyBtn = Instance.new("TextButton")
GetKeyBtn.Parent = KeyFrame
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
GetKeyBtn.Position = UDim2.new(0, 20, 0, 110)
GetKeyBtn.Size = UDim2.new(0, 130, 0, 35)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.Text = "Get Key (Copy)"
GetKeyBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
GetKeyBtn.TextSize = 13
local gkCorner = Instance.new("UICorner")
gkCorner.CornerRadius = UDim.new(0, 6)
gkCorner.Parent = GetKeyBtn

local CheckKeyBtn = Instance.new("TextButton")
CheckKeyBtn.Parent = KeyFrame
CheckKeyBtn.BackgroundColor3 = Config.FOVColor
CheckKeyBtn.Position = UDim2.new(1, -150, 0, 110)
CheckKeyBtn.Size = UDim2.new(0, 130, 0, 35)
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.Text = "Check Key"
CheckKeyBtn.TextColor3 = Color3.fromRGB(20, 20, 25)
CheckKeyBtn.TextSize = 13
local ckCorner = Instance.new("UICorner")
ckCorner.CornerRadius = UDim.new(0, 6)
ckCorner.Parent = CheckKeyBtn

GetKeyBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        if setclipboard then
            setclipboard(KeyLink)
        elseif toclipboard then
            toclipboard(KeyLink)
        else
            error()
        end
    end)
    if success then
        GetKeyBtn.Text = "Copied Link!"
        task.wait(2)
        GetKeyBtn.Text = "Get Key (Copy)"
    else
        GetKeyBtn.Text = "Link in Chat/Log"
        print("SPECTER X KEY LINK: " .. KeyLink)
    end
end)

CheckKeyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == TargetKey then
        KeyFrame:Destroy()
        StartCheat()
    else
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        CheckKeyBtn.Text = "Wrong Key!"
        task.wait(1.5)
        CheckKeyBtn.BackgroundColor3 = Config.FOVColor
        CheckKeyBtn.Text = "Check Key"
    end
end)

-- // 2. SPECTER X MAIN PANEL
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false 

local mfCorner = Instance.new("UICorner")
mfCorner.CornerRadius = UDim.new(0, 10)
mfCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 10)
Title.Size = UDim2.new(0, 230, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "SPECTER X PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 420)
ScrollFrame.ScrollBarThickness = 2

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local function createToggle(name, default, callback)
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Parent = ScrollFrame
    ToggleBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    ToggleBg.Size = UDim2.new(1, -5, 0, 40)
    local bgC = Instance.new("UICorner") bgC.CornerRadius = UDim.new(0, 6) bgC.Parent = ToggleBg
    
    local ToggleTitle = Instance.new("TextLabel")
    ToggleTitle.Parent = ToggleBg
    ToggleTitle.BackgroundTransparency = 1
    ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
    ToggleTitle.Size = UDim2.new(0, 140, 1, 0)
    ToggleTitle.Font = Enum.Font.Gotham
    ToggleTitle.Text = name
    ToggleTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleTitle.TextSize = 13
    ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleBg
    ToggleBtn.Position = UDim2.new(1, -45, 0, 8)
    ToggleBtn.Size = UDim2.new(0, 35, 0, 24)
    ToggleBtn.BackgroundColor3 = default and Config.FOVColor or Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = ""
    local tC = Instance.new("UICorner") tC.CornerRadius = UDim.new(0, 12) tC.Parent = ToggleBtn
    
    local state = default
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Config.FOVColor or Color3.fromRGB(50, 50, 60)
        }):Play()
        callback(state)
    end)
end

local function createSlider(name, min, max, default, callback)
    local SliderBg = Instance.new("Frame")
    SliderBg.Parent = ScrollFrame
    SliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    SliderBg.Size = UDim2.new(1, -5, 0, 50)
    local bgC = Instance.new("UICorner") bgC.CornerRadius = UDim.new(0, 6) bgC.Parent = SliderBg
    
    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Parent = SliderBg
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Position = UDim2.new(0, 10, 0, 5)
    SliderTitle.Size = UDim2.new(1, -20, 0, 20)
    SliderTitle.Font = Enum.Font.Gotham
    SliderTitle.Text = name .. ": " .. tostring(default)
    SliderTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderTitle.TextSize = 11
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local MainBar = Instance.new("Frame")
    MainBar.Parent = SliderBg
    MainBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    MainBar.Position = UDim2.new(0, 10, 0, 30)
    MainBar.Size = UDim2.new(1, -20, 0, 4)
    local mbC = Instance.new("UICorner") mbC.CornerRadius = UDim.new(0, 2) mbC.Parent = MainBar
    
    local FillBar = Instance.new("Frame")
    FillBar.Parent = MainBar
    FillBar.BackgroundColor3 = Config.FOVColor
    FillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    local fbC = Instance.new("UICorner") fbC.CornerRadius = UDim.new(0, 2) fbC.Parent = FillBar
    
    local Trigger = Instance.new("TextButton")
    Trigger.Parent = MainBar
    Trigger.BackgroundTransparency = 1
    Trigger.Size = UDim2.new(1, 0, 1, 0)
    Trigger.Text = ""
    
    local dragging = false
    local function update(input)
        local inputPos = input.Position.X
        local barAbsolutePos = MainBar.AbsolutePosition.X
        local barAbsoluteSize = MainBar.AbsoluteSize.X
        
        local sizeX = math.clamp((inputPos - barAbsolutePos) / barAbsoluteSize, 0, 1)
        FillBar.Size = UDim2.new(sizeX, 0, 1, 0)
        local value = math.floor(min + (sizeX * (max - min)))
        SliderTitle.Text = name .. ": " .. tostring(value)
        callback(value)
    end
    
    Trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true 
            update(input) 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
            update(input) 
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = false 
        end
    end)
end

-- // RENDER MENU ELEMENTS
createToggle("Silent Aim", Config.SilentAim, function(v) Config.SilentAim = v end)
createToggle("Show FOV Circle", Config.ShowFOV, function(v) Config.ShowFOV = v end)
createSlider("FOV Radius", 50, 600, Config.FOVRadius, function(v) Config.FOVRadius = v end)

createToggle("Player Box ESP", Config.ESP_Box, function(v) Config.ESP_Box = v end)
createToggle("Player Tracer ESP", Config.ESP_Tracer, function(v) Config.ESP_Tracer = v end)

createToggle("Tracers Center/Bottom", false, function(v)
    Config.Tracer_Origin = v and "Center" or "Bottom"
end)

-- // 3. FLOATING SCREEN TOGGLE BUTTON
local MenuToggleButton = Instance.new("TextButton")
MenuToggleButton.Name = "SpecterXToggleButton"
MenuToggleButton.Parent = ScreenGui
MenuToggleButton.Size = UDim2.new(0, 50, 0, 50)
MenuToggleButton.Position = UDim2.new(0, 15, 0.4, 0) 
MenuToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
MenuToggleButton.Font = Enum.Font.GothamBold
MenuToggleButton.Text = "MENU"
MenuToggleButton.TextColor3 = Config.FOVColor
MenuToggleButton.TextSize = 11
MenuToggleButton.Active = true
MenuToggleButton.Draggable = true 

local mtbCorner = Instance.new("UICorner")
mtbCorner.CornerRadius = UDim.new(0, 25) 
mtbCorner.Parent = MenuToggleButton

MenuToggleButton.MouseButton1Click:Connect(function()
    if not ScreenGui:FindFirstChild("KeyFrame") then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.U then
        if not ScreenGui:FindFirstChild("KeyFrame") then
            MainFrame.Visible = not MainFrame.Visible
        end
    end
end)
