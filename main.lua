--// 67 FEET PREMIUM HUB (CUSTOM UI ENGINE - AMBERGLOW EDITION)
--// 100% Indépendant - Zéro Loadstring - Thème Premium
--// Jeu : Pet-Squads-Y

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- ==========================================
-- 🔑 CONFIGURATION DU MOT DE PASSE
-- ==========================================
local MOT_DE_PASSE = "67feetlove" -- <--- CHANGER LE MOT DE PASSE ICI


-- ==========================================
-- FONCTION PRINCIPALE (CHARGE LE HUB SUR-MESURE)
-- ==========================================
local function LoadMainHub()
    -- Variables d'état des hacks
    local states = {
        fly = false, noclip = false, infJump = false, esp = false, clickTp = false,
        speed = 16, jump = 50, autoTapAura = false, auraRadius = 20, autoCollect = false,
        autoBuyZone = false, autoMine = false, digsiteMode = "All Mine", autoEgg = false,
        selectedEgg = "", disableEggAnimation = false, autoBuyEventUpgrades = false,
        selectedEventUpgrades = {}, afkMode = false, autoConsumePotions = false,
        selectedPotions = {}, autoPlaceFlags = false, selectedFlag = "", autoQuests = false
    }

    -- ==========================================
    -- 0. SÉCURITÉ : ANTI-KICK (BYPASS ANTI-CHEAT)
    -- ==========================================
    pcall(function()
        local mt = getrawmetatable(game)
        if mt and mt.__namecall then
            local oldNamecall = mt.__namecall
            if setreadonly then
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    local method = getnamecallmethod()
                    if method == "Kick" or method == "kick" then return nil end
                    return oldNamecall(self, ...)
                end)
                setreadonly(mt, true)
            end
        end
    end)

    -- ==========================================
    -- FONCTIONS D'INVENTAIRE (SCANNER GUIDS)
    -- ==========================================
    local getGC = getgc or get_gc_objects or function() return {} end
    local function trim(s) return s:match("^%s*(.-)%s*$") end

    local function tryLoadFromSaveModule()
        local saveLibrary = ReplicatedStorage:FindFirstChild("Library") and ReplicatedStorage.Library:FindFirstChild("Client") and ReplicatedStorage.Library.Client:FindFirstChild("Save")
        if saveLibrary then
            local success, save = pcall(function() return require(saveLibrary).Get() end)
            if success and save and save.Inventory then return save.Inventory end
        end
        return nil
    end

    local function tryLoadFromMemoryScan()
        local success, reg = pcall(getreg or debug.getregistry)
        if success and type(reg) == "table" then
            for _, v in pairs(reg) do
                if type(v) == "table" and rawget(v, "Inventory") and type(v.Inventory) == "table" then return v.Inventory end
            end
        end
        return nil
    end

    local function getInventoryItems(searchName, targetCategory)
        local inventory = tryLoadFromSaveModule() or tryLoadFromMemoryScan()
        if not inventory then return {} end
        local cleanSearch = trim(searchName:lower()):gsub("%s*potion%s*", ""):gsub("%s*flag%s*", "")
        cleanSearch = trim(cleanSearch)
        local matches = {}
        for catName, catTable in pairs(inventory) do
            local categoryMatch = true
            if targetCategory then
                local tc, cn = targetCategory:lower(), catName:lower()
                categoryMatch = (cn == tc or cn == (tc .. "s") or cn:find(tc) or tc:find(cn))
            end
            if categoryMatch and type(catTable) == "table" then
                for guid, data in pairs(catTable) do
                    local name = data.id or data.Name or ""
                    local cleanItemName = trim(name:lower())
                    if cleanItemName == cleanSearch or cleanItemName:find(cleanSearch, 1, true) then
                        table.insert(matches, {guid = guid, realName = name, tier = data._tn or data.Tier or 1})
                    end
                end
            end
        end
        return matches
    end

    -- ==========================================
    -- 1. MOTEUR UI RAYFIELD-LIKE AMÉLIORÉ (AMBERGLOW)
    -- ==========================================
    if CoreGui:FindFirstChild("67FeetCustomHub") then CoreGui["67FeetCustomHub"]:Destroy() end

    local CustomUI = Instance.new("ScreenGui")
    CustomUI.Name = "67FeetCustomHub"
    CustomUI.Parent = CoreGui
    CustomUI.ResetOnSpawn = false
    CustomUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- CORRECTION DU BUG D'AFFICHAGE

    -- Couleurs Thème Rayfield AmberGlow
    local Colors = {
        MainBg = Color3.fromRGB(25, 25, 25),
        SideBg = Color3.fromRGB(18, 18, 18),
        TopBg = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(255, 175, 50), -- Gold/Amber
        ElementBg = Color3.fromRGB(35, 35, 35),
        ElementHover = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(150, 150, 160)
    }

    local HubMain = Instance.new("Frame")
    HubMain.Size = UDim2.new(0, 680, 0, 450)
    HubMain.Position = UDim2.new(0.5, -340, 0.5, -225)
    HubMain.BackgroundColor3 = Colors.MainBg
    HubMain.BorderSizePixel = 0
    HubMain.ClipsDescendants = true
    HubMain.Parent = CustomUI
    Instance.new("UICorner", HubMain).CornerRadius = UDim.new(0, 10)
    
    local HubStroke = Instance.new("UIStroke", HubMain)
    HubStroke.Color = Color3.fromRGB(40, 40, 40)
    HubStroke.Thickness = 1

    -- Drag Logic
    local dragging, dragInput, dragStart, startPos
    HubMain.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = HubMain.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    HubMain.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            HubMain.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- HEADER TOP
    local TopBar = Instance.new("Frame", HubMain)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Colors.TopBg
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 20
    local TopBarCorner = Instance.new("UICorner", TopBar)
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    local TopBarFix = Instance.new("Frame", TopBar) 
    TopBarFix.Size = UDim2.new(1, 0, 0, 10)
    TopBarFix.Position = UDim2.new(0, 0, 1, -10)
    TopBarFix.BackgroundColor3 = Colors.TopBg
    TopBarFix.BorderSizePixel = 0

    local HeaderLogo = Instance.new("ImageLabel", TopBar)
    HeaderLogo.Size = UDim2.new(0, 28, 0, 28)
    HeaderLogo.Position = UDim2.new(0, 15, 0.5, -14)
    HeaderLogo.BackgroundTransparency = 1
    HeaderLogo.ScaleType = Enum.ScaleType.Fit
    HeaderLogo.Image = "rbxthumb://type=Asset&id=74238841967167&w=150&h=150"

    local HeaderTitle = Instance.new("TextLabel", TopBar)
    HeaderTitle.Size = UDim2.new(1, -60, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 55, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = "67 Feet Premium ⭐️ | Pet-Squads-Y"
    HeaderTitle.TextColor3 = Colors.Accent
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

    local Divider = Instance.new("Frame", TopBar)
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, 0)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Divider.BorderSizePixel = 0

    -- SIDEBAR
    local Sidebar = Instance.new("Frame", HubMain)
    Sidebar.Size = UDim2.new(0, 170, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Colors.SideBg
    Sidebar.BorderSizePixel = 0
    
    local SidebarDivider = Instance.new("Frame", Sidebar)
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SidebarDivider.BorderSizePixel = 0

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    
    local TabPadding = Instance.new("UIPadding", TabContainer)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.PaddingTop = UDim.new(0, 10)
    
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)

    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 20)
    end)

    -- USER INFO (BOTTOM SIDEBAR)
    local UserInfo = Instance.new("Frame", Sidebar)
    UserInfo.Size = UDim2.new(1, 0, 0, 50)
    UserInfo.Position = UDim2.new(0, 0, 1, -50)
    UserInfo.BackgroundColor3 = Colors.SideBg
    UserInfo.BorderSizePixel = 0

    local UserAvatar = Instance.new("ImageLabel", UserInfo)
    UserAvatar.Size = UDim2.new(0, 30, 0, 30)
    UserAvatar.Position = UDim2.new(0, 15, 0.5, -15)
    UserAvatar.BackgroundTransparency = 1
    UserAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
    Instance.new("UICorner", UserAvatar).CornerRadius = UDim.new(1, 0)

    local UserName = Instance.new("TextLabel", UserInfo)
    UserName.Size = UDim2.new(1, -60, 1, 0)
    UserName.Position = UDim2.new(0, 55, 0, 0)
    UserName.BackgroundTransparency = 1
    UserName.Text = player.Name
    UserName.TextColor3 = Colors.Text
    UserName.Font = Enum.Font.GothamMedium
    UserName.TextSize = 12
    UserName.TextXAlignment = Enum.TextXAlignment.Left

    -- CONTENT AREA
    local ContentArea = Instance.new("Frame", HubMain)
    ContentArea.Size = UDim2.new(1, -170, 1, -45)
    ContentArea.Position = UDim2.new(0, 170, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 10

    local tabs = {}
    local Lib = {}
    local tabLayoutCounter = 0
    
    function Lib:CreateTab(name, iconText)
        tabLayoutCounter = tabLayoutCounter + 1
        local tabBtn = Instance.new("TextButton", TabContainer)
        tabBtn.LayoutOrder = tabLayoutCounter
        tabBtn.Size = UDim2.new(1, 0, 0, 36) -- Taille auto-gérée par le Padding
        tabBtn.BackgroundColor3 = Colors.SideBg
        tabBtn.Text = "   " .. (iconText or "") .. "  " .. name
        tabBtn.TextColor3 = Colors.SubText
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 13
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

        local tabLine = Instance.new("Frame", tabBtn)
        tabLine.Size = UDim2.new(0, 3, 0, 0)
        tabLine.Position = UDim2.new(0, 6, 0.5, 0)
        tabLine.AnchorPoint = Vector2.new(0, 0.5)
        tabLine.BackgroundColor3 = Colors.Accent
        tabLine.BorderSizePixel = 0
        Instance.new("UICorner", tabLine).CornerRadius = UDim.new(1, 0)

        local tabContent = Instance.new("ScrollingFrame", ContentArea)
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Colors.Accent
        tabContent.Visible = false
        
        local contentLayout = Instance.new("UIListLayout", tabContent)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)

        local function updateCanvas()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end
        tabContent.ChildAdded:Connect(function() task.wait(); updateCanvas() end)
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.content.Visible = false
                TweenService:Create(t.btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.SideBg, TextColor3 = Colors.SubText}):Play()
                TweenService:Create(t.line, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            end
            tabContent.Visible = true
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementBg, TextColor3 = Colors.Accent}):Play()
            TweenService:Create(tabLine, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0.5, 0)}):Play()
        end)

        table.insert(tabs, {btn = tabBtn, content = tabContent, line = tabLine})
        if #tabs == 1 then
            tabContent.Visible = true
            tabBtn.BackgroundColor3 = Colors.ElementBg
            tabBtn.TextColor3 = Colors.Accent
            tabLine.Size = UDim2.new(0, 3, 0.5, 0)
        end

        local TabAPI = {}
        local itemLayoutCounter = 0

        function TabAPI:CreateLabel(text)
            itemLayoutCounter = itemLayoutCounter + 1
            local lbl = Instance.new("TextLabel", tabContent)
            lbl.LayoutOrder = itemLayoutCounter
            lbl.Size = UDim2.new(1, -10, 0, 25)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = Colors.Text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end

        function TabAPI:CreateParagraph(config)
            itemLayoutCounter = itemLayoutCounter + 1
            local frame = Instance.new("Frame", tabContent)
            frame.LayoutOrder = itemLayoutCounter
            frame.BackgroundColor3 = Colors.ElementBg
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(50, 50, 50)
            
            local pTitle = Instance.new("TextLabel", frame)
            pTitle.Size = UDim2.new(1, -20, 0, 25)
            pTitle.Position = UDim2.new(0, 10, 0, 5)
            pTitle.BackgroundTransparency = 1
            pTitle.Text = config.Title
            pTitle.TextColor3 = Colors.Accent
            pTitle.Font = Enum.Font.GothamBold
            pTitle.TextSize = 13
            pTitle.TextXAlignment = Enum.TextXAlignment.Left

            local pContent = Instance.new("TextLabel", frame)
            pContent.Size = UDim2.new(1, -20, 0, 20)
            pContent.Position = UDim2.new(0, 10, 0, 30)
            pContent.BackgroundTransparency = 1
            pContent.Text = config.Content
            pContent.TextColor3 = Colors.SubText
            pContent.Font = Enum.Font.Gotham
            pContent.TextSize = 12
            pContent.TextXAlignment = Enum.TextXAlignment.Left
            pContent.TextYAlignment = Enum.TextYAlignment.Top
            pContent.TextWrapped = true

            local function adaptSize()
                local txtHeight = pContent.TextBounds.Y
                pContent.Size = UDim2.new(1, -20, 0, txtHeight)
                frame.Size = UDim2.new(1, -10, 0, 35 + txtHeight + 10)
            end
            pContent:GetPropertyChangedSignal("TextBounds"):Connect(adaptSize)
            task.delay(0.05, adaptSize) -- Double sécurité pour le calcul du texte

            return {
                Set = function(self, newConfig)
                    if newConfig.Title then pTitle.Text = newConfig.Title end
                    if newConfig.Content then pContent.Text = newConfig.Content end
                end
            }
        end

        function TabAPI:CreateToggle(name, default, callback)
            itemLayoutCounter = itemLayoutCounter + 1
            local frame = Instance.new("Frame", tabContent)
            frame.LayoutOrder = itemLayoutCounter
            frame.Size = UDim2.new(1, -10, 0, 45)
            frame.BackgroundColor3 = Colors.ElementBg
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(50, 50, 50)
            
            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 15, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Colors.Text
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local toggleBg = Instance.new("Frame", frame)
            toggleBg.Size = UDim2.new(0, 44, 0, 22)
            toggleBg.Position = UDim2.new(1, -60, 0.5, -11)
            toggleBg.BackgroundColor3 = default and Colors.Accent or Color3.fromRGB(60, 60, 65)
            Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", toggleBg)
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            local toggleBtn = Instance.new("TextButton", frame)
            toggleBtn.Size = UDim2.new(1, 0, 1, 0)
            toggleBtn.BackgroundTransparency = 1
            toggleBtn.Text = ""

            local toggled = default
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                local goalColor = toggled and Colors.Accent or Color3.fromRGB(60, 60, 65)
                local goalPos = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = goalColor}):Play()
                TweenService:Create(circle, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = goalPos}):Play()
                if callback then callback(toggled) end
            end)
            if callback then task.spawn(callback, toggled) end
            
            return {
                Set = function(self, val)
                    toggled = val
                    local goalColor = toggled and Colors.Accent or Color3.fromRGB(60, 60, 65)
                    local goalPos = toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                    TweenService:Create(toggleBg, TweenInfo.new(0.25), {BackgroundColor3 = goalColor}):Play()
                    TweenService:Create(circle, TweenInfo.new(0.25), {Position = goalPos}):Play()
                    if callback then task.spawn(callback, toggled) end
                end
            }
        end

        function TabAPI:CreateSlider(name, min, max, default, callback)
            itemLayoutCounter = itemLayoutCounter + 1
            local frame = Instance.new("Frame", tabContent)
            frame.LayoutOrder = itemLayoutCounter
            frame.Size = UDim2.new(1, -10, 0, 65)
            frame.BackgroundColor3 = Colors.ElementBg
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(50, 50, 50)
            
            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(0.7, 0, 0, 20)
            lbl.Position = UDim2.new(0, 15, 0, 10)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Colors.Text
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel", frame)
            valLbl.Size = UDim2.new(0.3, 0, 0, 20)
            valLbl.Position = UDim2.new(0.7, -15, 0, 10)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = tostring(default)
            valLbl.TextColor3 = Colors.Accent
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = 13
            valLbl.TextXAlignment = Enum.TextXAlignment.Right

            local barBg = Instance.new("TextButton", frame)
            barBg.Size = UDim2.new(1, -30, 0, 6)
            barBg.Position = UDim2.new(0, 15, 0, 40)
            barBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            barBg.Text = ""
            Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

            local barFill = Instance.new("Frame", barBg)
            local pct = (default - min) / (max - min)
            barFill.Size = UDim2.new(pct, 0, 1, 0)
            barFill.BackgroundColor3 = Colors.Accent
            Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
            
            local thumb = Instance.new("Frame", barFill)
            thumb.Size = UDim2.new(0, 14, 0, 14)
            thumb.Position = UDim2.new(1, -7, 0.5, -7)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                barFill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + (max - min) * pos)
                valLbl.Text = tostring(val)
                if callback then callback(val) end
            end

            barBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
        end

        -- LE FAMEUX DROPDOWN RÉPARÉ ET INFAILLIBLE
        function TabAPI:CreateDropdown(name, options, isMulti, callback)
            itemLayoutCounter = itemLayoutCounter + 1
            local frame = Instance.new("Frame", tabContent)
            frame.LayoutOrder = itemLayoutCounter
            frame.BackgroundColor3 = Colors.ElementBg
            frame.ClipsDescendants = true
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(50, 50, 50)
            
            local headerBtn = Instance.new("TextButton", frame)
            headerBtn.Size = UDim2.new(1, 0, 0, 45)
            headerBtn.BackgroundTransparency = 1
            headerBtn.Text = ""

            local lbl = Instance.new("TextLabel", headerBtn)
            lbl.Size = UDim2.new(0.5, 0, 1, 0)
            lbl.Position = UDim2.new(0, 15, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Colors.Text
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local valLbl = Instance.new("TextLabel", headerBtn)
            valLbl.Size = UDim2.new(0.4, 0, 1, 0)
            valLbl.Position = UDim2.new(0.6, -45, 0, 0)
            valLbl.BackgroundTransparency = 1
            valLbl.Text = options[1] or "Sélectionner..."
            valLbl.TextColor3 = Colors.SubText
            valLbl.Font = Enum.Font.Gotham
            valLbl.TextSize = 12
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.TextTruncate = Enum.TextTruncate.AtEnd
            
            local arrow = Instance.new("TextLabel", headerBtn)
            arrow.Size = UDim2.new(0, 20, 0, 20)
            arrow.Position = UDim2.new(1, -30, 0.5, -10)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▼"
            arrow.TextColor3 = Colors.SubText
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 12

            local listFrame = Instance.new("ScrollingFrame", frame)
            listFrame.Size = UDim2.new(1, 0, 1, -45)
            listFrame.Position = UDim2.new(0, 0, 0, 45)
            listFrame.BackgroundTransparency = 1
            listFrame.ScrollBarThickness = 3
            listFrame.ScrollBarImageColor3 = Colors.Accent
            listFrame.BorderSizePixel = 0
            
            local listLayout = Instance.new("UIListLayout", listFrame)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local isOpen = false
            local selectedMulti = {}
            local currentOpts = options
            
            local function updateSize()
                if isOpen then
                    local contentHeight = #currentOpts * 30
                    local targetHeight = math.min(contentHeight, 150) + 50
                    listFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
                    TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, targetHeight)}):Play()
                    TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                else
                    TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 45)}):Play()
                    TweenService:Create(arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                end
            end

            headerBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                updateSize()
            end)

            local function buildOptions(opts)
                currentOpts = opts
                for _, child in pairs(listFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for i, opt in ipairs(opts) do
                    local optBtn = Instance.new("TextButton", listFrame)
                    optBtn.Size = UDim2.new(1, -20, 0, 30)
                    optBtn.Position = UDim2.new(0, 10, 0, 0)
                    optBtn.BackgroundColor3 = Colors.ElementBg
                    optBtn.Text = "  " .. opt
                    optBtn.TextColor3 = Colors.SubText
                    optBtn.Font = Enum.Font.Gotham
                    optBtn.TextSize = 12
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

                    optBtn.MouseEnter:Connect(function() TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementHover}):Play() end)
                    optBtn.MouseLeave:Connect(function() TweenService:Create(optBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.ElementBg}):Play() end)

                    optBtn.MouseButton1Click:Connect(function()
                        if not isMulti then
                            valLbl.Text = opt
                            isOpen = false
                            updateSize()
                            if callback then callback({opt}) end
                        else
                            if selectedMulti[opt] then
                                selectedMulti[opt] = nil
                                optBtn.TextColor3 = Colors.SubText
                            else
                                selectedMulti[opt] = true
                                optBtn.TextColor3 = Colors.Accent
                            end
                            local res = {}
                            for k, v in pairs(selectedMulti) do if v then table.insert(res, k) end end
                            valLbl.Text = #res > 0 and (#res .. " sélectionnés") or "Aucun"
                            if callback then callback(res) end
                        end
                    end)
                end
                if isOpen then updateSize() end
            end

            buildOptions(options)
            updateSize()
            
            -- Lancement initial
            if not isMulti and #options > 0 then
                if callback then task.spawn(function() callback({options[1]}) end) end
            end

            return {
                Refresh = function(newOpts)
                    buildOptions(newOpts)
                    if not isMulti and #newOpts > 0 and not table.find(newOpts, valLbl.Text) then
                        valLbl.Text = newOpts[1]
                        if callback then task.spawn(function() callback({newOpts[1]}) end) end
                    end
                end
            }
        end

        function TabAPI:CreateButton(name, callback)
            itemLayoutCounter = itemLayoutCounter + 1
            local btn = Instance.new("TextButton", tabContent)
            btn.LayoutOrder = itemLayoutCounter
            btn.Size = UDim2.new(1, -10, 0, 40)
            btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            btn.Text = name
            btn.TextColor3 = Colors.Accent
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local strk = Instance.new("UIStroke", btn)
            strk.Color = Colors.Accent
            strk.Thickness = 1

            btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 60)}):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play() end)
            btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        end

        return TabAPI
    end

    -- ==========================================
    -- 2. CRÉATION DES ONGLETS ET INJECTION DES HACKS
    -- ==========================================
    
    -- === TAB MOUVEMENTS ===
    local TabMain = Lib:CreateTab("Mouvements", "🏃")
    TabMain:CreateLabel("Statistiques du Joueur")
    TabMain:CreateSlider("Vitesse de déplacement", 16, 200, 16, function(val)
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val end
    end)
    TabMain:CreateSlider("Puissance de saut", 50, 300, 50, function(val)
        local hum = player.Character and player.Character:FindFirstChild("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = val end
    end)
    
    TabMain:CreateLabel("Exploits")
    local flyBodyVel, flyBodyGyro
    local flyKeys = {w = false, a = false, s = false, d = false, space = false, lshift = false}
    TabMain:CreateToggle("Voler (Fly)", false, function(val)
        states.fly = val
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local root = char.HumanoidRootPart
        local hum = char:FindFirstChild("Humanoid")
        if states.fly then
            hum.PlatformStand = true
            flyBodyVel = Instance.new("BodyVelocity", root)
            flyBodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVel.Velocity = Vector3.zero
            flyBodyGyro = Instance.new("BodyGyro", root)
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 10000
            task.spawn(function()
                while states.fly and char.Parent do
                    local move = Vector3.new()
                    if flyKeys.w then move = move + camera.CFrame.LookVector end
                    if flyKeys.s then move = move - camera.CFrame.LookVector end
                    if flyKeys.a then move = move - camera.CFrame.RightVector end
                    if flyKeys.d then move = move + camera.CFrame.RightVector end
                    if flyKeys.space then move = move + Vector3.new(0, 1, 0) end
                    if flyKeys.lshift then move = move - Vector3.new(0, 1, 0) end
                    flyBodyVel.Velocity = move.Magnitude > 0 and move.Unit * 60 or Vector3.zero
                    flyBodyGyro.CFrame = camera.CFrame
                    RunService.Heartbeat:Wait()
                end
            end)
        else
            if flyBodyVel then flyBodyVel:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
            hum.PlatformStand = false
        end
    end)

    UserInputService.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.Z then flyKeys.w = true
        elseif i.KeyCode == Enum.KeyCode.S then flyKeys.s = true
        elseif i.KeyCode == Enum.KeyCode.A or i.KeyCode == Enum.KeyCode.Q then flyKeys.a = true
        elseif i.KeyCode == Enum.KeyCode.D then flyKeys.d = true
        elseif i.KeyCode == Enum.KeyCode.Space then flyKeys.space = true
        elseif i.KeyCode == Enum.KeyCode.LeftShift then flyKeys.lshift = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.KeyCode == Enum.KeyCode.W or i.KeyCode == Enum.KeyCode.Z then flyKeys.w = false
        elseif i.KeyCode == Enum.KeyCode.S then flyKeys.s = false
        elseif i.KeyCode == Enum.KeyCode.A or i.KeyCode == Enum.KeyCode.Q then flyKeys.a = false
        elseif i.KeyCode == Enum.KeyCode.D then flyKeys.d = false
        elseif i.KeyCode == Enum.KeyCode.Space then flyKeys.space = false
        elseif i.KeyCode == Enum.KeyCode.LeftShift then flyKeys.lshift = false end
    end)

    local noclipConnection
    TabMain:CreateToggle("Noclip (Traverser les murs)", false, function(val)
        states.noclip = val
        if states.noclip then
            noclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, p in pairs(player.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect() end
        end
    end)

    TabMain:CreateToggle("Saut Infini", false, function(val) states.infJump = val end)
    UserInputService.JumpRequest:Connect(function()
        if states.infJump and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    local clickTpConnection
    TabMain:CreateToggle("Click TP (Ctrl + Clic)", false, function(val)
        states.clickTp = val
        if states.clickTp then
            clickTpConnection = mouse.Button1Down:Connect(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                end
            end)
        else
            if clickTpConnection then clickTpConnection:Disconnect() end
        end
    end)

    -- === TAB VISUELS ===
    local TabVisuals = Lib:CreateTab("Visuels & ESP", "👁️")
    local espFolder = Instance.new("Folder", CoreGui)
    espFolder.Name = "67FeetCustomESP"
    local function refreshESP()
        espFolder:ClearAllChildren()
        if not states.esp then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hl = Instance.new("Highlight", espFolder)
                hl.Adornee = p.Character
                hl.FillColor = Color3.fromRGB(255, 175, 50)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
            end
        end
    end
    TabVisuals:CreateToggle("Activer l'ESP", false, function(val) states.esp = val; refreshESP() end)
    Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1) refreshESP() end) end)

    -- === TAB FARMING ===
    local TabFarm = Lib:CreateTab("Farming", "⛏️")
    TabFarm:CreateLabel("Auto Tap Aura")
    TabFarm:CreateSlider("Rayon Aura", 5, 120, 20, function(val) states.auraRadius = val end)
    
    local auraVisual = Instance.new("Part")
    auraVisual.Shape = Enum.PartType.Cylinder
    auraVisual.Anchored = true
    auraVisual.CanCollide = false
    auraVisual.CastShadow = false
    auraVisual.Transparency = 0.85
    auraVisual.Color = Color3.fromRGB(255, 175, 50)
    auraVisual.Material = Enum.Material.ForceField

    RunService.Heartbeat:Connect(function()
        if states.autoTapAura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            auraVisual.Parent = workspace
            auraVisual.Size = Vector3.new(0.2, states.auraRadius * 2, states.auraRadius * 2)
            auraVisual.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
        else
            auraVisual.Parent = nil
        end
    end)

    TabFarm:CreateToggle("Activer Auto Tap", false, function(val)
        states.autoTapAura = val
        if states.autoTapAura then
            task.spawn(function()
                while states.autoTapAura do
                    pcall(function()
                        local char = player.Character
                        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                        local rootPos = char.HumanoidRootPart.Position
                        local network = ReplicatedStorage:FindFirstChild("Network")
                        local damageRemote = network and network:FindFirstChild("Breakables_PlayerDealDamage")
                        if damageRemote then
                            local breakablesFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
                            if breakablesFolder then
                                for _, group in pairs(breakablesFolder:GetChildren()) do
                                    for _, breakable in pairs(group:GetChildren()) do
                                        local hitbox = breakable:FindFirstChild("Hitbox")
                                        if hitbox and (hitbox.Position - rootPos).Magnitude <= states.auraRadius then
                                            damageRemote:FireServer(group.Name)
                                            damageRemote:FireServer(group.Name) 
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait()
                end
            end)
        end
    end)

    TabFarm:CreateLabel("Monde & Récupération")
    TabFarm:CreateToggle("Auto Collect (Orbes & Sacs)", false, function(val)
        states.autoCollect = val
        if states.autoCollect then
            task.spawn(function()
                while states.autoCollect do
                    pcall(function()
                        local network = ReplicatedStorage:FindFirstChild("Network")
                        if not network then return end
                        local cOrbs = network:FindFirstChild("Orbs: Collect")
                        local orbsFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Orbs")
                        if cOrbs and orbsFolder then
                            local ids = {}
                            for _, orb in pairs(orbsFolder:GetChildren()) do table.insert(ids, orb.Name) end
                            if #ids > 0 then cOrbs:FireServer(ids) for _, orb in pairs(orbsFolder:GetChildren()) do orb:Destroy() end end
                        end
                        local cLoot = network:FindFirstChild("Lootbags_Claim")
                        local lootFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Lootbags")
                        if cLoot and lootFolder then
                            local ids = {}
                            for _, bag in pairs(lootFolder:GetChildren()) do table.insert(ids, bag.Name) end
                            if #ids > 0 then cLoot:FireServer(ids) for _, bag in pairs(lootFolder:GetChildren()) do bag:Destroy() end end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end)

    TabFarm:CreateToggle("Auto Buy Zones", false, function(val)
        states.autoBuyZone = val
        if states.autoBuyZone then
            task.spawn(function()
                while states.autoBuyZone do
                    pcall(function()
                        local pRemote = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Zones_RequestPurchase")
                        local mapF = workspace:FindFirstChild("Map")
                        if pRemote and mapF then
                            for _, z in pairs(mapF:GetChildren()) do
                                local gateHUD = z:FindFirstChild("INTERACT") and z.INTERACT:FindFirstChild("Gate") and z.INTERACT.Gate:FindFirstChild("Gate") and z.INTERACT.Gate.Gate:FindFirstChild("GateHUD")
                                if gateHUD and gateHUD.Enabled then
                                    local zNameLabel = gateHUD:FindFirstChild("ZoneName")
                                    if zNameLabel then task.spawn(function() pcall(function() pRemote:InvokeServer(zNameLabel.Text) end) end) end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end)

    TabFarm:CreateLabel("Mini-jeu: Digsite (RESTAURÉ)")
    -- LE DROPDOWN DIGSITE EST ICI (RÉPARÉ)
    TabFarm:CreateDropdown("Mode de Mining", {"All Mine", "Efficiency"}, false, function(val) states.digsiteMode = val[1] end)
    
    TabFarm:CreateToggle("Activer Auto Mine", false, function(val)
        states.autoMine = val
        if states.autoMine then
            pcall(function()
                local digsiteFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Instances") and workspace.__THINGS.Instances:FindFirstChild("Digsite")
                local enterPart = digsiteFolder and digsiteFolder:FindFirstChild("Teleports") and digsiteFolder.Teleports:FindFirstChild("Enter")
                if enterPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = enterPart.CFrame
                end
            end)

            local ignoredBlocks = {}
            local gridCoords = {}
            local gridIndex = 1
            
            task.spawn(function()
                while states.autoMine do
                    local foundAndMined = false
                    pcall(function()
                        local digRemote = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Instancing_FireCustomFromClient")
                        local importantFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("__INSTANCE_CONTAINER") and workspace.__THINGS.__INSTANCE_CONTAINER:FindFirstChild("Active") and workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("Digsite") and workspace.__THINGS.__INSTANCE_CONTAINER.Active.Digsite:FindFirstChild("Important")
                        
                        if digRemote and importantFolder then
                            local minX, maxX, minZ, maxZ = 1, 9, 1, 9
                            if #gridCoords == 0 then
                                for x = minX + 1, maxX, 2 do
                                    for z = minZ + 1, maxZ, 2 do table.insert(gridCoords, {x = x, z = z}) end
                                end
                            end
                            
                            local activeBlocks = importantFolder:FindFirstChild("ActiveBlocks")
                            local activeChests = importantFolder:FindFirstChild("ActiveChests")
                            
                            if states.digsiteMode == "All Mine" then
                                local validBlocks = {}
                                local processedCoords = {}
                                
                                local function scanFolder(folder, digType)
                                    if not folder then return end
                                    for _, item in pairs(folder:GetDescendants()) do
                                        if item:IsA("Model") or item:IsA("BasePart") then
                                            if ignoredBlocks[item] then continue end
                                            local coord = item:GetAttribute("Coord")
                                            if not coord and item.Name:match("%d+, %d+, %d+") then
                                                local split = string.split(item.Name, ", ")
                                                coord = Vector3.new(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
                                            end
                                            if coord and typeof(coord) == "Vector3" then
                                                local coordKey = tostring(coord)
                                                if coord.X >= minX and coord.X <= maxX and coord.Z >= minZ and coord.Z <= maxZ then
                                                    if not processedCoords[coordKey] then
                                                        table.insert(validBlocks, {instance = item, coord = coord, type = digType})
                                                        processedCoords[coordKey] = true
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                scanFolder(activeBlocks, "DigBlock")
                                scanFolder(activeChests, "DigChest")
                                
                                if #validBlocks > 0 then
                                    table.sort(validBlocks, function(a, b) return a.coord.Y < b.coord.Y end)
                                    local targetData = validBlocks[1]
                                    local block = targetData.instance
                                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                    if block and block.Parent then
                                        foundAndMined = true
                                        local hitCount = 0
                                        while block and block.Parent and hitCount < 25 do
                                            if not states.autoMine or states.digsiteMode ~= "All Mine" then break end
                                            if root and block.Parent then
                                                root.CFrame = CFrame.new(block:GetPivot().Position + Vector3.new(0, 3.5, 0))
                                                root.Velocity = Vector3.zero
                                            end
                                            digRemote:FireServer("Digsite", targetData.type, targetData.coord)
                                            hitCount = hitCount + 1
                                            task.wait(0.02)
                                        end
                                        if hitCount >= 25 then ignoredBlocks[block] = true end
                                    end
                                end
                                
                            elseif states.digsiteMode == "Efficiency" then
                                local directChestTarget = nil
                                if activeChests then
                                    for _, item in pairs(activeChests:GetDescendants()) do
                                        if item:IsA("Model") or item:IsA("BasePart") then
                                            if ignoredBlocks[item] then continue end
                                            local coord = item:GetAttribute("Coord")
                                            if not coord and item.Name:match("%d+, %d+, %d+") then
                                                local split = string.split(item.Name, ", ")
                                                coord = Vector3.new(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
                                            end
                                            if coord and typeof(coord) == "Vector3" then
                                                if coord.X >= minX and coord.X <= maxX and coord.Z >= minZ and coord.Z <= maxZ then
                                                    directChestTarget = {instance = item, coord = coord, type = "DigChest"}
                                                    break 
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                local targetData = directChestTarget
                                if not targetData and #gridCoords > 0 then
                                    local colTarget = gridCoords[gridIndex]
                                    local colBlocks = {}
                                    if activeBlocks then
                                        for _, item in pairs(activeBlocks:GetDescendants()) do
                                            if item:IsA("Model") or item:IsA("BasePart") then
                                                if ignoredBlocks[item] then continue end
                                                local coord = item:GetAttribute("Coord")
                                                if not coord and item.Name:match("%d+, %d+, %d+") then
                                                    local split = string.split(item.Name, ", ")
                                                    coord = Vector3.new(tonumber(split[1]), tonumber(split[2]), tonumber(split[3]))
                                                end
                                                if coord and typeof(coord) == "Vector3" and coord.X == colTarget.x and coord.Z == colTarget.z then
                                                    table.insert(colBlocks, {instance = item, coord = coord, type = "DigBlock"})
                                                end
                                            end
                                        end
                                    end
                                    if #colBlocks > 0 then
                                        table.sort(colBlocks, function(a, b) return a.coord.Y < b.coord.Y end)
                                        targetData = colBlocks[1]
                                    else
                                        gridIndex = gridIndex + 1
                                        if gridIndex > #gridCoords then gridIndex = 1 end
                                    end
                                end
                                
                                if targetData then
                                    local block = targetData.instance
                                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                    if block and block.Parent then
                                        foundAndMined = true
                                        local hitCount = 0
                                        while block and block.Parent and hitCount < 25 do
                                            if not states.autoMine or states.digsiteMode ~= "Efficiency" then break end
                                            if root and block.Parent then
                                                root.CFrame = CFrame.new(block:GetPivot().Position + Vector3.new(0, 3.5, 0))
                                                root.Velocity = Vector3.zero
                                            end
                                            digRemote:FireServer("Digsite", targetData.type, targetData.coord)
                                            hitCount = hitCount + 1
                                            task.wait(0.02)
                                        end
                                        if hitCount >= 25 then ignoredBlocks[block] = true end
                                    end
                                end
                            end
                        end
                    end)
                    if not states.autoMine then break end
                    if foundAndMined then task.wait() else task.wait(0.2) end
                end
            end)
        end
    end)

    -- === TAB OEUFS ===
    local TabEggs = Lib:CreateTab("Oeufs", "🥚")
    local function GetEggList()
        local raw = {}
        local eF = workspace:FindFirstChild("__DIRECTORY") and workspace.__DIRECTORY:FindFirstChild("Eggs") and workspace.__DIRECTORY.Eggs:FindFirstChild("Zone Eggs")
        if eF then
            for _, w in pairs(eF:GetChildren()) do
                local r = w:FindFirstChild("Release")
                if r then
                    for _, e in pairs(r:GetChildren()) do
                        local n, nm = string.match(e.Name, "^(%d+)%s*|%s*(.+)")
                        table.insert(raw, {num = tonumber(n) or 999, name = nm or e.Name})
                    end
                end
            end
        end
        table.sort(raw, function(a, b) return a.num < b.num end)
        local dList, nMap = {}, {}
        for _, ed in ipairs(raw) do
            local dStr = ed.num .. " - " .. ed.name
            table.insert(dList, dStr)
            nMap[dStr] = ed.name
        end
        if #dList == 0 then table.insert(dList, "20 - Tentacle Egg"); nMap["20 - Tentacle Egg"] = "Tentacle Egg" end
        return dList, nMap
    end
    
    local eList, eMap = GetEggList()
    TabEggs:CreateDropdown("Sélectionner un Œuf", eList, false, function(val) states.selectedEgg = eMap[val[1]] or "Tentacle Egg" end)
    
    -- // CORRECTION HATCH EGG (Utilisation de RemoteFunction au lieu de Eggs_RequestPurchase) \\
    TabEggs:CreateToggle("Auto Open (x99)", false, function(val)
        states.autoEgg = val
        if states.autoEgg then
            task.spawn(function()
                while states.autoEgg do
                    pcall(function()
                        if states.selectedEgg ~= "" then
                            local network = ReplicatedStorage:FindFirstChild("Network")
                            local eRemote = network and network:FindFirstChild("RemoteFunction")
                            if eRemote then 
                                -- 1. On envoie la demande d'ouverture avec la structure exacte des arguments
                                local args = {
                                    states.selectedEgg,
                                    99
                                }
                                eRemote:InvokeServer(unpack(args))
                                
                                -- 2. On envoie l'appel vide (souvent utilisé par le jeu pour clore la requête/animation)
                                pcall(function() eRemote:InvokeServer() end)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end)
    
    TabEggs:CreateToggle("No Animation (Anti-Lag)", false, function(val) states.disableEggAnimation = val end)
    
    task.spawn(function()
        while task.wait(0.1) do
            if states.disableEggAnimation then
                pcall(function()
                    for _, child in pairs(camera:GetChildren()) do
                        if child.Name == "EggOpenLight" or child.Name == "Eggs" or child.Name == "Pets" then child:Destroy() end
                    end
                    for _, child in pairs(workspace:GetChildren()) do
                        if child.Name == "EggOpenLight" or child.Name == "Eggs" or child.Name == "Pets" then
                            if child:IsA("Model") or child:IsA("Folder") then child:Destroy() end
                        end
                    end
                end)
            end
        end
    end)
    camera.ChildAdded:Connect(function(child)
        if states.disableEggAnimation and (child.Name == "EggOpenLight" or child.Name == "Eggs" or child.Name == "Pets") then
            task.spawn(function() task.wait() if child and child.Parent then child:Destroy() end end)
        end
    end)

    -- === TAB EVENTS ===
    local TabEvent = Lib:CreateTab("Événements", "⭐")
    local defUpgrades = {"DefenseMoreDamage", "DefenseMoreLuck", "DefenseMoreCoins", "DefenseHugeChance", "DefenseRewardsLuck", "DefenseMoreDiamonds", "DefenseAutoClicker", "DefenseCritDamage"}
    TabEvent:CreateLabel("Lucky Defense Upgrades")
    local EventUpgradesDrop = TabEvent:CreateDropdown("Améliorations à acheter", defUpgrades, true, function(val)
        states.selectedEventUpgrades = {}
        for _, upg in ipairs(val) do states.selectedEventUpgrades[upg] = true end
    end)
    TabEvent:CreateToggle("Auto Buy Lucky Upgrades", false, function(val)
        states.autoBuyEventUpgrades = val
        if states.autoBuyEventUpgrades then
            task.spawn(function()
                while states.autoBuyEventUpgrades do
                    pcall(function()
                        local uRemote = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("EventUpgrades: Purchase")
                        if uRemote then
                            for uName, active in pairs(states.selectedEventUpgrades) do
                                if active then uRemote:InvokeServer(uName) end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end)
    
    task.spawn(function()
        local knownUpgrades = {}
        for _, v in ipairs(defUpgrades) do table.insert(knownUpgrades, v) end
        while task.wait(5) do
            pcall(function()
                local uF = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("__INSTANCE_CONTAINER") and workspace.__THINGS.__INSTANCE_CONTAINER:FindFirstChild("Active") and workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("LuckyDefense") and workspace.__THINGS.__INSTANCE_CONTAINER.Active.LuckyDefense:FindFirstChild("Upgrades")
                if uF then
                    local newFound = false
                    for _, upg in pairs(uF:GetDescendants()) do
                        if upg:IsA("Model") and upg.Name ~= "Folder" and not table.find(knownUpgrades, upg.Name) then
                            table.insert(knownUpgrades, upg.Name)
                            newFound = true
                        end
                    end
                    if newFound then EventUpgradesDrop.Refresh(knownUpgrades) end
                end
            end)
        end
    end)

    -- === TAB BOOSTS ===
    local TabBoosts = Lib:CreateTab("Boosts", "🧪")
    TabBoosts:CreateLabel("Auto Potions")
    TabBoosts:CreateDropdown("Potions à utiliser", {"Coins Potion", "Luck Potion", "Damage Potion", "Speed Potion", "Treasure Hunter Potion"}, true, function(val)
        states.selectedPotions = {}
        for _, pot in ipairs(val) do states.selectedPotions[pot] = true end
    end)
    TabBoosts:CreateToggle("Démarrer Auto Potions", false, function(val)
        states.autoConsumePotions = val
        if states.autoConsumePotions then
            task.spawn(function()
                while states.autoConsumePotions do
                    pcall(function()
                        local pRemote = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Potions: Consume")
                        if pRemote then
                            for pType, active in pairs(states.selectedPotions) do
                                if active and states.autoConsumePotions then
                                    local m = getInventoryItems(pType, "Potion")
                                    for _, item in ipairs(m) do
                                        if states.autoConsumePotions then pRemote:FireServer(item.guid, 1); task.wait(0.1) end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end)
    TabBoosts:CreateLabel("Auto Drapeaux")
    TabBoosts:CreateDropdown("Sélectionner Drapeau", {"Coins Flag", "Magnet Flag", "Haste Flag", "Fortune Flag", "Diamonds Flag"}, false, function(val) states.selectedFlag = val[1] or "" end)
    TabBoosts:CreateToggle("Démarrer Auto Drapeau", false, function(val)
        states.autoPlaceFlags = val
        if states.autoPlaceFlags then
            task.spawn(function()
                while states.autoPlaceFlags do
                    pcall(function()
                        local fRemote = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("FlexibleFlags_Consume")
                        if fRemote and states.selectedFlag ~= "" then
                            local m = getInventoryItems(states.selectedFlag, "Flag")
                            if #m > 0 then
                                table.sort(m, function(a, b) return a.tier > b.tier end)
                                fRemote:InvokeServer(m[1].realName, m[1].guid)
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end)

    -- 🛑 TOUTE LA LOGIQUE AUTOPILOT RESTAURÉE EXACTEMENT COMME AVANT 🛑
    local TabQuests = Lib:CreateTab("Autopilot", "🤖")
    TabQuests:CreateParagraph({Title = "🤖 Comment ça marche ?", Content = "Le bot lit vos quêtes actuelles et active automatiquement les fonctions du Hub (Oeufs, Potions, Mine) en arrière-plan sans que vous n'ayez rien à faire."})
    
    local QuestPara = TabQuests:CreateParagraph({Title = "📜 Status des Quêtes", Content = "Scanneur inactif."})

    local function getActiveQuests()
        local quests = {}
        pcall(function()
            local holder = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("GoalsSide") and player.PlayerGui.GoalsSide:FindFirstChild("Frame") and player.PlayerGui.GoalsSide.Frame:FindFirstChild("Quests") and player.PlayerGui.GoalsSide.Frame.Quests:FindFirstChild("QuestsGradient") and player.PlayerGui.GoalsSide.Frame.Quests.QuestsGradient:FindFirstChild("QuestsHolder")
            if holder then
                for _, diff in ipairs({"Easy", "Medium", "Hard"}) do
                    local goal = holder:FindFirstChild(diff) and holder[diff]:FindFirstChild("RankGradient") and holder[diff].RankGradient:FindFirstChild("RankHolder") and holder[diff].RankGradient.RankHolder:FindFirstChild("Goal")
                    local t, p = goal and goal:FindFirstChild("title"), goal and goal:FindFirstChild("progress")
                    if t and t:IsA("TextLabel") and t.Text ~= "" then
                        table.insert(quests, {difficulty = diff, text = t.Text, progress = p and p.Text or "0/1"})
                    end
                end
            end
        end)
        return quests
    end

    local function findDiamondBreakable()
        local bF = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
        if bF then
            for _, g in pairs(bF:GetChildren()) do
                for _, b in pairs(g:GetChildren()) do
                    local isD = false
                    for _, desc in ipairs(b:GetDescendants()) do
                        if (desc:IsA("Decal") or desc:IsA("Texture")) and (desc.Texture:find("88416525922321") or desc.Texture:find("88416525922321c")) then isD = true break
                        elseif (desc:IsA("SpecialMesh") or desc:IsA("MeshPart")) and (tostring(desc.MeshId):find("88416525922321") or tostring(desc.TextureId):find("88416525922321")) then isD = true break end
                    end
                    if b.Name:lower():find("diamond") or b.Name:lower():find("diamant") then isD = true end
                    if isD then
                        local hb = b:FindFirstChild("Hitbox") or b:FindFirstChildWhichIsA("BasePart")
                        if hb then return b, hb, g.Name end
                    end
                end
            end
        end
        return nil
    end

    local qEEgg, qEPot, qEMine = false, false, false

    TabQuests:CreateToggle("Démarrer l'Autopilot", false, function(val)
        states.autoQuests = val
        if states.autoQuests then
            task.spawn(function()
                while states.autoQuests do
                    local quests = getActiveQuests()
                    local hasHatch, hasPot, hasDiam, hasMine = false, false, false, false
                    for _, q in ipairs(quests) do
                        local t = q.text:lower()
                        if t:find("hatch") and (t:find("best") or t:find("egg") or t:find("oeuf")) then hasHatch = true
                        elseif t:find("potion") or t:find("consume") then hasPot = true
                        elseif t:find("diamond") or t:find("diamant") then hasDiam = true
                        elseif t:find("dig") or t:find("mine") or t:find("chest") then hasMine = true end
                    end
                    
                    if hasHatch then
                        if not qEEgg then qEEgg = true; pcall(function() local d, m = GetEggList(); if #d > 0 then states.selectedEgg = m[d[#d]] end end); states.autoEgg = true end
                    else
                        if qEEgg then qEEgg = false; states.autoEgg = false end
                    end
                    
                    if hasPot then
                        if not qEPot then qEPot = true; states.selectedPotions["Coins Potion"] = true; states.autoConsumePotions = true end
                    else
                        if qEPot then qEPot = false; states.autoConsumePotions = false end
                    end
                    
                    if hasDiam then
                        if qEMine then qEMine = false; states.autoMine = false end
                        local b, hb, gn = findDiamondBreakable()
                        if b and hb and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            player.Character.HumanoidRootPart.CFrame = hb.CFrame + Vector3.new(0, 3, 0)
                            local dR = ReplicatedStorage:FindFirstChild("Network") and ReplicatedStorage.Network:FindFirstChild("Breakables_PlayerDealDamage")
                            if dR then dR:FireServer(gn); dR:FireServer(gn) end
                        end
                    elseif hasMine then
                        if not qEMine then qEMine = true; states.digsiteMode = "Efficiency"; states.autoMine = true end
                    else
                        if qEMine then qEMine = false; states.autoMine = false end
                    end
                    task.wait(1.5)
                end
            end)
        else
            if qEEgg then qEEgg = false; states.autoEgg = false end
            if qEPot then qEPot = false; states.autoConsumePotions = false end
            if qEMine then qEMine = false; states.autoMine = false end
        end
    end)

    task.spawn(function()
        while task.wait(1.5) do
            local quests = getActiveQuests()
            local c = ""
            if #quests == 0 then c = "Aucune quête active trouvée. En attente..."
            else for _, q in ipairs(quests) do c = c .. string.format("• [%s] %s (%s)\n", q.difficulty, q.text, q.progress) end end
            pcall(function() QuestPara:Set({Title = states.autoQuests and "🟢 Tracker Actif" or "🔴 Tracker Désactivé", Content = c}) end)
        end
    end)

    -- === TAB SETTINGS ===
    local TabSettings = Lib:CreateTab("Paramètres", "⚙️")
    TabSettings:CreateToggle("Anti-AFK", false, function(val)
        states.afkMode = val
        if states.afkMode then
            local vu = game:GetService("VirtualUser")
            player.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
        end
    end)
    TabSettings:CreateButton("Fermer et Détruire le Hub", function()
        CustomUI:Destroy()
        if auraVisual then auraVisual:Destroy() end
        if espFolder then espFolder:Destroy() end
    end)
end

-- ==========================================
-- SYSTEME DE CLEF (UI DE CONNEXION PREMIUM)
-- ==========================================
local TweenService = game:GetService("TweenService")

if CoreGui:FindFirstChild("PremiumHubKeySystem") then
    CoreGui.PremiumHubKeySystem:Destroy()
end

local KeySystemUI = Instance.new("ScreenGui")
KeySystemUI.Name = "PremiumHubKeySystem"
KeySystemUI.Parent = CoreGui
KeySystemUI.ResetOnSpawn = false
KeySystemUI.IgnoreGuiInset = true -- Prend tout l'écran

-- 1. Fond sombre cinématique (Overlay)
local Overlay = Instance.new("Frame")
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 1 -- Commence transparent
Overlay.BorderSizePixel = 0
Overlay.Parent = KeySystemUI

TweenService:Create(Overlay, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.4}):Play()

-- 2. Fenêtre principale
local MainFrame = Instance.new("Frame")
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Commence à 0 pour l'animation
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = KeySystemUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(255, 175, 50)
FrameStroke.Thickness = 1.5
FrameStroke.Transparency = 0.4
FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FrameStroke.Parent = MainFrame

-- Animation d'ouverture (Bounce)
TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 340, 0, 320)}):Play()

-- ==========================================
-- 🖼️ LOGO FLOTTANT PERSONNALISÉ (FORMAT CARRÉ 1024x1024)
-- ==========================================
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 110, 0, 110) -- Proportions parfaites pour ton image carrée
Logo.Position = UDim2.new(0.5, -55, 0, 15) -- Parfaitement centré
Logo.BackgroundTransparency = 1
Logo.ScaleType = Enum.ScaleType.Fit
Logo.Image = "rbxthumb://type=Asset&id=74238841967167&w=420&h=420"
Logo.Parent = MainFrame

-- Animation de flottement infinie ajustée au nouveau centre
local floatTweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local floatTween = TweenService:Create(Logo, floatTweenInfo, {Position = UDim2.new(0.5, -55, 0, 5)})
floatTween:Play()
-- ==========================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 130)
Title.BackgroundTransparency = 1
Title.Text = "67 FEET PREMIUM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 155)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Pet-Squads-Y"
SubTitle.TextColor3 = Color3.fromRGB(255, 175, 50)
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 12
SubTitle.Parent = MainFrame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.85, 0, 0, 40)
TextBox.Position = UDim2.new(0.075, 0, 0, 190)
TextBox.PlaceholderText = "Entrez votre clé d'accès..."
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
TextBox.Font = Enum.Font.GothamMedium
TextBox.TextSize = 14
TextBox.Parent = MainFrame

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 6)
Corner2.Parent = TextBox

local TextBoxStroke = Instance.new("UIStroke")
TextBoxStroke.Color = Color3.fromRGB(50, 50, 60)
TextBoxStroke.Thickness = 1
TextBoxStroke.Parent = TextBox

TextBox.Focused:Connect(function()
    TweenService:Create(TextBoxStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(255, 175, 50)}):Play()
end)
TextBox.FocusLost:Connect(function()
    TweenService:Create(TextBoxStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(50, 50, 60)}):Play()
end)

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.85, 0, 0, 40)
SubmitBtn.Position = UDim2.new(0.075, 0, 0, 245)
SubmitBtn.Text = "SE CONNECTER"
SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 175, 50)
SubmitBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 13
SubmitBtn.AutoButtonColor = false
SubmitBtn.Parent = MainFrame

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 6)
Corner3.Parent = SubmitBtn

local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 195, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 140, 0))
}
ButtonGradient.Parent = SubmitBtn

SubmitBtn.MouseEnter:Connect(function()
    TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {Size = UDim2.new(0.87, 0, 0, 42), Position = UDim2.new(0.065, 0, 0, 244)}):Play()
end)
SubmitBtn.MouseLeave:Connect(function()
    TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {Size = UDim2.new(0.85, 0, 0, 40), Position = UDim2.new(0.075, 0, 0, 245)}):Play()
end)

SubmitBtn.MouseButton1Click:Connect(function()
    if TextBox.Text == MOT_DE_PASSE then
        ButtonGradient:Destroy()
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubmitBtn.Text = "ACCÈS AUTORISÉ"
        
        -- Animation de fermeture
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(Overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.5)
        KeySystemUI:Destroy()
        LoadMainHub()
    else
        ButtonGradient:Destroy()
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
        SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SubmitBtn.Text = "CLÉ INCORRECTE"
        
        -- Effet de tremblement (Shake)
        local originalPos = MainFrame.Position
        for i = 1, 6 do
            MainFrame.Position = originalPos + UDim2.new(0, math.random(-5, 5), 0, 0)
            task.wait(0.05)
        end
        MainFrame.Position = originalPos
        
        task.wait(1)
        SubmitBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
        SubmitBtn.Text = "SE CONNECTER"
        ButtonGradient.Parent = SubmitBtn
    end
end)
