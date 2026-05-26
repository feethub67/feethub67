--// PREMIUM MULTI-HACK HUB POUR EXECUTOR (AVEC FLUENT UI)
--// Basé sur l'interface Fluent (Dawid Scripts) - UI Améliorée

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- ==========================================
-- 🔑 CONFIGURATION DU MOT DE PASSE
-- ==========================================
local MOT_DE_PASSE = "67feetlove" -- <--- CHANGER LE MOT DE PASSE ICI


-- ==========================================
-- FONCTION PRINCIPALE (CHARGE LE HUB)
-- ==========================================
local function LoadMainHub()
    -- Variables d'état des hacks
    local states = {
        fly = false,
        noclip = false,
        infJump = false,
        esp = false,
        clickTp = false,
        speed = 16,
        jump = 50,
        autoTapAura = false,
        auraRadius = 20,
        autoCollect = false,
        autoBuyZone = false,
        autoMine = false,
        digsiteMode = "All Mine",
        autoEgg = false,
        selectedEgg = "",
        disableEggAnimation = false,
        autoBuyEventUpgrades = false,
        selectedEventUpgrades = {},
        afkMode = false,
        
        autoConsumePotions = false,
        selectedPotions = {},
        autoPlaceFlags = false,
        selectedFlag = "",
        
        autoQuests = false
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
                    if method == "Kick" or method == "kick" then
                        warn("🛡️ [Premium Hub Sécurité] Une tentative de Kick a été bloquée !")
                        return nil
                    end
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

    local function trim(s)
        return s:match("^%s*(.-)%s*$")
    end

    local function isGUID(str)
        if type(str) ~= "string" then return false end
        return #str == 32 and str:match("^[0-9a-fA-F]+$") ~= nil
    end

    local function tryLoadFromSaveModule()
        local saveLibrary = ReplicatedStorage:FindFirstChild("Library") and ReplicatedStorage.Library:FindFirstChild("Client") and ReplicatedStorage.Library.Client:FindFirstChild("Save")
        if saveLibrary then
            local success, save = pcall(function()
                return require(saveLibrary).Get()
            end)
            if success and save and save.Inventory then
                return save.Inventory
            end
        end
        return nil
    end

    local function tryLoadFromMemoryScan()
        local success, reg = pcall(getreg or debug.getregistry)
        if success and type(reg) == "table" then
            for _, v in pairs(reg) do
                if type(v) == "table" and rawget(v, "Inventory") and type(v.Inventory) == "table" then
                    return v.Inventory
                end
            end
        end
        
        for _, obj in pairs(getGC(true)) do
            if type(obj) == "table" and obj.Inventory and type(obj.Inventory) == "table" then
                for _, categoryTable in pairs(obj.Inventory) do
                    if type(categoryTable) == "table" then
                        for key, _ in pairs(categoryTable) do
                            if isGUID(key) then
                                return obj.Inventory
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local function getInventoryItems(searchName, targetCategory)
        local inventory = tryLoadFromSaveModule() or tryLoadFromMemoryScan()
        if not inventory then 
            return {} 
        end

        local cleanSearch = trim(searchName:lower())
        local baseSearch = cleanSearch:gsub("%s*potion%s*", ""):gsub("%s*flag%s*", "")
        baseSearch = trim(baseSearch)

        local matches = {}

        for catName, catTable in pairs(inventory) do
            local categoryMatch = true
            if targetCategory then
                local tc = targetCategory:lower()
                local cn = catName:lower()
                categoryMatch = (cn == tc or cn == (tc .. "s") or cn:find(tc) or tc:find(cn))
            end

            if categoryMatch and type(catTable) == "table" then
                for guid, data in pairs(catTable) do
                    local name = data.id or data.Name or ""
                    local cleanItemName = trim(name:lower())

                    local isMatch = false
                    if cleanItemName == cleanSearch then
                        isMatch = true
                    elseif cleanItemName:find(baseSearch, 1, true) then
                        isMatch = true
                    end

                    if isMatch then
                        table.insert(matches, {
                            guid = guid,
                            amount = data._am or data.Amount or 1,
                            category = catName,
                            realName = name,
                            tier = data._tn or data.Tier or 1
                        })
                    end
                end
            end
        end
        return matches
    end

    -- ==========================================
    -- 1. CHARGEMENT DE FLUENT UI & ADDONS
    -- ==========================================
    local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/ThemeManager.lua"))()

    local Window = Fluent:CreateWindow({
        Title = "💎 Premium Hub",
        SubTitle = "v2.8 - Edition Auto Quests Parallèles",
        TabWidth = 160,
        Size = UDim2.fromOffset(600, 460),
        Acrylic = true,
        Theme = "Amethyst", 
        MinimizeKey = Enum.KeyCode.RightControl
    })

    -- ==========================================
    -- 2. CRÉATION DES ONGLETS (TABS)
    -- ==========================================
    local Tabs = {
        Main = Window:AddTab({ Title = "Mouvements", Icon = "move" }),
        Visuals = Window:AddTab({ Title = "Visuels & ESP", Icon = "eye" }),
        Farm = Window:AddTab({ Title = "Farming", Icon = "pickaxe" }),
        Eggs = Window:AddTab({ Title = "Oeufs", Icon = "egg" }),
        Event = Window:AddTab({ Title = "Événements", Icon = "star" }),
        Consumables = Window:AddTab({ Title = "Boosts", Icon = "flask-conical" }),
        Quests = Window:AddTab({ Title = "Autopilot", Icon = "bot" }),
        Settings = Window:AddTab({ Title = "Paramètres", Icon = "settings" })
    }

    Window:SelectTab(1)

    -- ==========================================
    -- 3. LOGIQUE DES HACKS (MOUVEMENTS)
    -- ==========================================
    local SectionStats = Tabs.Main:AddSection("Statistiques du Joueur")

    local SpeedSlider = Tabs.Main:AddSlider("SpeedSlider", {
        Title = "Vitesse de déplacement",
        Description = "Modifie le WalkSpeed",
        Default = 16, Min = 16, Max = 200, Rounding = 1,
        Callback = function(Value)
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = Value end
        end
    })

    local JumpSlider = Tabs.Main:AddSlider("JumpSlider", {
        Title = "Puissance de saut",
        Description = "Modifie le JumpPower",
        Default = 50, Min = 50, Max = 300, Rounding = 1,
        Callback = function(Value)
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then 
                hum.UseJumpPower = true
                hum.JumpPower = Value 
            end
        end
    })

    local SectionHacks = Tabs.Main:AddSection("Exploits & Triche")

    -- FLY
    local flyBodyVel, flyBodyGyro
    local flyKeys = {w = false, a = false, s = false, d = false, space = false, lshift = false}
    local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {Title = "Voler (Fly)", Default = false })
    FlyToggle:OnChanged(function(state)
        states.fly = state
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
                    
                    if move.Magnitude > 0 then
                        flyBodyVel.Velocity = move.Unit * 60
                    else
                        flyBodyVel.Velocity = Vector3.zero
                    end
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

    -- NOCLIP
    local noclipConnection
    local NoclipToggle = Tabs.Main:AddToggle("NoclipToggle", {Title = "Traverser les murs (Noclip)", Default = false })
    NoclipToggle:OnChanged(function(state)
        states.noclip = state
        if states.noclip then
            noclipConnection = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then noclipConnection:Disconnect() end
        end
    end)

    -- INFINITE JUMP
    UserInputService.JumpRequest:Connect(function()
        if states.infJump and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    local InfJumpToggle = Tabs.Main:AddToggle("InfJumpToggle", {Title = "Saut Infini", Default = false })
    InfJumpToggle:OnChanged(function(state) states.infJump = state end)

    -- CLICK TP
    local clickTpConnection
    local ClickTpToggle = Tabs.Main:AddToggle("ClickTpToggle", {Title = "Click TP (Ctrl Gauche + Clic)", Default = false })
    ClickTpToggle:OnChanged(function(state)
        states.clickTp = state
        if states.clickTp then
            clickTpConnection = mouse.Button1Down:Connect(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = mouse.Hit.Position
                    player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                end
            end)
        else
            if clickTpConnection then clickTpConnection:Disconnect() end
        end
    end)

    -- ==========================================
    -- 4. LOGIQUE DES VISUELS (ESP)
    -- ==========================================
    local SectionESP = Tabs.Visuals:AddSection("Wallhack & Highlights")

    local espFolder = Instance.new("Folder", CoreGui)
    espFolder.Name = "FluentESP_Highlights"

    local function refreshESP()
        espFolder:ClearAllChildren()
        if not states.esp then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local highlight = Instance.new("Highlight")
                highlight.Parent = espFolder
                highlight.Adornee = p.Character
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
            end
        end
    end

    local ESPToggle = Tabs.Visuals:AddToggle("ESPToggle", {Title = "Activer l'ESP (Joueurs)", Default = false })
    ESPToggle:OnChanged(function(state)
        states.esp = state
        refreshESP()
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function() task.wait(1) refreshESP() end)
    end)

    -- ==========================================
    -- 5. LOGIQUE DE FARMING
    -- ==========================================
    local SectionAura = Tabs.Farm:AddSection("Auto Tap Aura")

    local AuraRadiusSlider = Tabs.Farm:AddSlider("AuraRadius", {
        Title = "Taille de la zone (Rayon)", Default = 20, Min = 5, Max = 120, Rounding = 1,
        Callback = function(Value) states.auraRadius = Value end
    })

    local auraVisual = Instance.new("Part")
    auraVisual.Shape = Enum.PartType.Cylinder
    auraVisual.Anchored = true
    auraVisual.CanCollide = false
    auraVisual.CastShadow = false
    auraVisual.Transparency = 0.85
    auraVisual.Color = Color3.fromRGB(160, 32, 240)
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

    local AutoTapToggle = Tabs.Farm:AddToggle("AutoTapToggle", {Title = "Activer Auto Tap Aura", Default = false })
    AutoTapToggle:OnChanged(function(state)
        states.autoTapAura = state
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
                                        if hitbox then
                                            local distance = (hitbox.Position - rootPos).Magnitude
                                            if distance <= states.auraRadius then
                                                damageRemote:FireServer(group.Name)
                                                damageRemote:FireServer(group.Name) 
                                            end
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

    local SectionWorld = Tabs.Farm:AddSection("Monde & Récupération")

    local AutoCollectToggle = Tabs.Farm:AddToggle("AutoCollectToggle", {Title = "Auto Collect Orbes & Sacs", Default = false })
    AutoCollectToggle:OnChanged(function(state)
        states.autoCollect = state
        if states.autoCollect then
            task.spawn(function()
                while states.autoCollect do
                    pcall(function()
                        local network = ReplicatedStorage:FindFirstChild("Network")
                        if not network then return end

                        local collectOrbsRemote = network:FindFirstChild("Orbs: Collect")
                        local orbsFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Orbs")
                        
                        if collectOrbsRemote and orbsFolder then
                            local orbIds = {}
                            local orbsList = orbsFolder:GetChildren()
                            for _, orb in pairs(orbsList) do table.insert(orbIds, orb.Name) end
                            if #orbIds > 0 then
                                collectOrbsRemote:FireServer(orbIds)
                                for _, orb in pairs(orbsList) do orb:Destroy() end
                            end
                        end

                        local collectLootbagsRemote = network:FindFirstChild("Lootbags_Claim")
                        local lootbagsFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Lootbags")
                        
                        if collectLootbagsRemote and lootbagsFolder then
                            local lootbagIds = {}
                            local bagsList = lootbagsFolder:GetChildren()
                            for _, bag in pairs(bagsList) do table.insert(lootbagIds, bag.Name) end
                            if #lootbagIds > 0 then
                                collectLootbagsRemote:FireServer(lootbagIds)
                                for _, bag in pairs(bagsList) do bag:Destroy() end
                            end
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end)

    local AutoBuyZoneToggle = Tabs.Farm:AddToggle("AutoBuyZoneToggle", {Title = "Auto Buy Zones (Déblocage Auto)", Default = false })
    AutoBuyZoneToggle:OnChanged(function(state)
        states.autoBuyZone = state
        if states.autoBuyZone then
            task.spawn(function()
                while states.autoBuyZone do
                    pcall(function()
                        local network = ReplicatedStorage:FindFirstChild("Network")
                        local purchaseRemote = network and network:FindFirstChild("Zones_RequestPurchase")
                        local mapFolder = workspace:FindFirstChild("Map")
                        
                        if purchaseRemote and mapFolder then
                            for _, zoneFolder in pairs(mapFolder:GetChildren()) do
                                local interact = zoneFolder:FindFirstChild("INTERACT")
                                local gate = interact and interact:FindFirstChild("Gate")
                                
                                if gate then
                                    local innerGate = gate:FindFirstChild("Gate")
                                    local gateHUD = innerGate and innerGate:FindFirstChild("GateHUD")
                                    
                                    if innerGate and innerGate.Transparency == 0 and gateHUD and gateHUD.Enabled == true then
                                        local zoneName = string.match(zoneFolder.Name, "|%s*(.+)")
                                        local zoneNameLabel = gateHUD:FindFirstChild("ZoneName")
                                        local targetZoneName = (zoneNameLabel and zoneNameLabel.Text) or zoneName
                                        
                                        if targetZoneName then
                                            task.spawn(function() pcall(function() purchaseRemote:InvokeServer(targetZoneName) end) end)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end)

    local SectionDigsite = Tabs.Farm:AddSection("Mini-jeu: Digsite")

    local DigsiteModeDropdown = Tabs.Farm:AddDropdown("DigsiteModeDropdown", {
        Title = "Mode de Mining",
        Values = {"All Mine", "Efficiency"},
        Multi = false,
        Default = 1,
    })
    DigsiteModeDropdown:OnChanged(function(Value) states.digsiteMode = Value end)

    local AutoMineToggle = Tabs.Farm:AddToggle("AutoMineToggle", {Title = "Activer Auto Mine", Default = false })
    AutoMineToggle:OnChanged(function(state)
        states.autoMine = state
        if states.autoMine then
            pcall(function()
                local digsiteFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Instances") and workspace.__THINGS.Instances:FindFirstChild("Digsite")
                local teleports = digsiteFolder and digsiteFolder:FindFirstChild("Teleports")
                local enterPart = teleports and teleports:FindFirstChild("Enter")
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
                        local network = ReplicatedStorage:FindFirstChild("Network")
                        local digRemote = network and network:FindFirstChild("Instancing_FireCustomFromClient")
                        
                        local instances = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("__INSTANCE_CONTAINER")
                        local activeInstance = instances and instances:FindFirstChild("Active")
                        local digsite = activeInstance and activeInstance:FindFirstChild("Digsite")
                        local importantFolder = digsite and digsite:FindFirstChild("Important")
                        
                        if digRemote and importantFolder then
                            local minX, maxX, minZ, maxZ = 1, 9, 1, 9
                            
                            if #gridCoords == 0 then
                                for x = minX + 1, maxX, 2 do
                                    for z = minZ + 1, maxZ, 2 do
                                        table.insert(gridCoords, {x = x, z = z})
                                    end
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
                                    local coord = targetData.coord
                                    local digType = targetData.type
                                    
                                    local char = player.Character
                                    local root = char and char:FindFirstChild("HumanoidRootPart")
                                    
                                    if block and block.Parent then
                                        foundAndMined = true
                                        local hitCount = 0
                                        
                                        while block and block.Parent and hitCount < 25 do
                                            if not states.autoMine or states.digsiteMode ~= "All Mine" then break end
                                            if root and block.Parent then
                                                root.CFrame = CFrame.new(block:GetPivot().Position + Vector3.new(0, 3.5, 0))
                                                root.Velocity = Vector3.zero
                                            end
                                            digRemote:FireServer("Digsite", digType, coord)
                                            hitCount = hitCount + 1
                                            task.wait(0.02)
                                        end
                                        if block and block.Parent and hitCount >= 25 then ignoredBlocks[block] = true end
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
                                
                                local targetData = nil
                                
                                if directChestTarget then
                                    targetData = directChestTarget
                                else
                                    if #gridCoords > 0 then
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
                                                    
                                                    if coord and typeof(coord) == "Vector3" then
                                                        if coord.X == colTarget.x and coord.Z == colTarget.z then
                                                            table.insert(colBlocks, {instance = item, coord = coord, type = "DigBlock"})
                                                        end
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
                                end
                                
                                if targetData then
                                    local block = targetData.instance
                                    local coord = targetData.coord
                                    local digType = targetData.type
                                    
                                    local char = player.Character
                                    local root = char and char:FindFirstChild("HumanoidRootPart")
                                    
                                    if block and block.Parent then
                                        foundAndMined = true
                                        local hitCount = 0
                                        
                                        while block and block.Parent and hitCount < 25 do
                                            if not states.autoMine or states.digsiteMode ~= "Efficiency" then break end
                                            if root and block.Parent then
                                                root.CFrame = CFrame.new(block:GetPivot().Position + Vector3.new(0, 3.5, 0))
                                                root.Velocity = Vector3.zero
                                            end
                                            digRemote:FireServer("Digsite", digType, coord)
                                            hitCount = hitCount + 1
                                            task.wait(0.02)
                                        end
                                        if block and block.Parent and hitCount >= 25 then ignoredBlocks[block] = true end
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

    -- ==========================================
    -- 6. LOGIQUE DES OEUFS (AUTO EGG)
    -- ==========================================
    local SectionEggs = Tabs.Eggs:AddSection("Système d'Éclosion")

    local function GetEggList()
        local rawEggList = {}
        local eggFolder = workspace:FindFirstChild("__DIRECTORY") and workspace.__DIRECTORY:FindFirstChild("Eggs") and workspace.__DIRECTORY.Eggs:FindFirstChild("Zone Eggs")
        
        if eggFolder then
            for _, worldFolder in pairs(eggFolder:GetChildren()) do
                local releaseFolder = worldFolder:FindFirstChild("Release")
                if releaseFolder then
                    for _, egg in pairs(releaseFolder:GetChildren()) do
                        local numStr, eggName = string.match(egg.Name, "^(%d+)%s*|%s*(.+)")
                        if eggName then
                            table.insert(rawEggList, {num = tonumber(numStr) or 999, name = eggName})
                        else
                            table.insert(rawEggList, {num = 999, name = egg.Name})
                        end
                    end
                end
            end
        end

        table.sort(rawEggList, function(a, b) return a.num < b.num end)

        local displayList = {}
        local nameToIdMap = {}

        for _, eggData in ipairs(rawEggList) do
            local displayStr = eggData.num .. " - " .. eggData.name
            table.insert(displayList, displayStr)
            nameToIdMap[displayStr] = eggData.name
        end

        if #displayList == 0 then
            table.insert(displayList, "20 - Tentacle Egg")
            nameToIdMap["20 - Tentacle Egg"] = "Tentacle Egg"
        end

        return displayList, nameToIdMap
    end

    local EggDisplayList, EggNameToIdMap = GetEggList()

    local EggDropdown = Tabs.Eggs:AddDropdown("EggDropdown", {
        Title = "Sélectionner un Œuf",
        Values = EggDisplayList,
        Multi = false,
        Default = 1,
    })

    EggDropdown:OnChanged(function(Value)
        states.selectedEgg = EggNameToIdMap[Value] or "Tentacle Egg"
    end)

    local AutoEggToggle = Tabs.Eggs:AddToggle("AutoEggToggle", {Title = "Activer Auto Open Egg (x99)", Default = false })
    AutoEggToggle:OnChanged(function(state)
        states.autoEgg = state
        if states.autoEgg then
            task.spawn(function()
                while states.autoEgg do
                    pcall(function()
                        if states.selectedEgg and states.selectedEgg ~= "" then
                            local network = ReplicatedStorage:FindFirstChild("Network")
                            local eggRemote = network and network:FindFirstChild("Eggs_RequestPurchase")
                            
                            if eggRemote then
                                -- Envoie 99 au lieu de 1 pour éclore le maximum possible
                                eggRemote:InvokeServer(states.selectedEgg, 99)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end)

    local SectionOptim = Tabs.Eggs:AddSection("Optimisation (Anti-Lag)")

    local DisableAnimToggle = Tabs.Eggs:AddToggle("DisableAnimToggle", {Title = "Désactiver Animations d'Œufs", Default = false })
    DisableAnimToggle:OnChanged(function(state)
        states.disableEggAnimation = state
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if states.disableEggAnimation then
                pcall(function()
                    for _, child in pairs(camera:GetChildren()) do
                        if child.Name == "EggOpenLight" or child.Name == "Eggs" or child.Name == "Pets" then
                            child:Destroy()
                        end
                    end
                    
                    for _, child in pairs(workspace:GetChildren()) do
                        if child.Name == "EggOpenLight" or child.Name == "Eggs" or child.Name == "Pets" then
                            if child:IsA("Model") or child:IsA("Folder") then
                                child:Destroy()
                            end
                        end
                    end
                end)
            end
        end
    end)

    camera.ChildAdded:Connect(function(child)
        if states.disableEggAnimation then
            if child.Name == "EggOpenLight" or child.Name == "Eggs" or child.Name == "Pets" then
                task.spawn(function()
                    task.wait() 
                    if child and child.Parent then child:Destroy() end
                end)
            end
        end
    end)

    -- ==========================================
    -- 7. LOGIQUE DES ÉVÉNEMENTS (LUCKY DEFENSE)
    -- ==========================================
    local SectionLucky = Tabs.Event:AddSection("Lucky Defense")

    local defaultUpgrades = {
        "DefenseMoreDamage", "DefenseMoreLuck", "DefenseMoreCoins", 
        "DefenseHugeChance", "DefenseRewardsLuck", "DefenseMoreDiamonds",
        "DefenseAutoClicker", "DefenseCritDamage"
    }

    local EventUpgradesDropdown = Tabs.Event:AddDropdown("EventUpgradesDropdown", {
        Title = "Améliorations (Choix Multiple)",
        Values = defaultUpgrades,
        Multi = true,
        Default = {},
    })

    EventUpgradesDropdown:OnChanged(function(Value)
        states.selectedEventUpgrades = Value
    end)

    task.spawn(function()
        local knownUpgrades = {}
        for _, v in ipairs(defaultUpgrades) do table.insert(knownUpgrades, v) end
        
        while task.wait(5) do
            pcall(function()
                local instances = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("__INSTANCE_CONTAINER")
                local active = instances and instances:FindFirstChild("Active")
                local luckyDefense = active and active:FindFirstChild("LuckyDefense")
                local upgradesFolder = luckyDefense and luckyDefense:FindFirstChild("Upgrades")
                
                if upgradesFolder then
                    local newFound = false
                    for _, upg in pairs(upgradesFolder:GetDescendants()) do
                        if upg:IsA("Model") and upg.Name ~= "Folder" and not table.find(knownUpgrades, upg.Name) then
                            table.insert(knownUpgrades, upg.Name)
                            newFound = true
                        end
                    end
                    if newFound then
                        EventUpgradesDropdown:SetValues(knownUpgrades)
                    end
                end
            end)
        end
    end)

    local EventUpgradesToggle = Tabs.Event:AddToggle("EventUpgradesToggle", {Title = "Auto Buy Upgrades", Default = false })
    EventUpgradesToggle:OnChanged(function(state)
        states.autoBuyEventUpgrades = state
        if states.autoBuyEventUpgrades then
            task.spawn(function()
                while states.autoBuyEventUpgrades do
                    pcall(function()
                        local network = ReplicatedStorage:FindFirstChild("Network")
                        local upgradeRemote = network and network:FindFirstChild("EventUpgrades: Purchase")
                        
                        if upgradeRemote then
                            local instances = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("__INSTANCE_CONTAINER")
                            local active = instances and instances:FindFirstChild("Active")
                            local luckyDefense = active and active:FindFirstChild("LuckyDefense")
                            local upgradesFolder = luckyDefense and luckyDefense:FindFirstChild("Upgrades")
                            
                            if upgradesFolder then
                                for _, upgrade in pairs(upgradesFolder:GetDescendants()) do
                                    if upgrade:IsA("Model") and upgrade.Name ~= "Folder" and states.selectedEventUpgrades and states.selectedEventUpgrades[upgrade.Name] then
                                        upgradeRemote:InvokeServer(upgrade.Name)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end)

    -- ==========================================
    -- 8. LOGIQUE DES CONSOMMABLES AUTOMATIQUES
    -- ==========================================
    local SectionPotions = Tabs.Consumables:AddSection("Automatisation des Potions")

    local PotionsDropdown = Tabs.Consumables:AddDropdown("PotionsDropdown", {
        Title = "Sélectionner Potions",
        Values = {"Coins Potion", "Luck Potion", "Damage Potion", "Speed Potion", "Treasure Hunter Potion"},
        Multi = true,
        Default = {},
    })
    PotionsDropdown:OnChanged(function(Value) states.selectedPotions = Value end)

    local AutoPotionsToggle = Tabs.Consumables:AddToggle("AutoPotionsToggle", {Title = "Activer Auto Potions", Default = false })
    AutoPotionsToggle:OnChanged(function(state)
        states.autoConsumePotions = state
        if states.autoConsumePotions then
            task.spawn(function()
                while states.autoConsumePotions do
                    pcall(function()
                        local network = ReplicatedStorage:FindFirstChild("Network")
                        local potionRemote = network and network:FindFirstChild("Potions: Consume")
                        
                        if potionRemote then
                            for potionType, active in pairs(states.selectedPotions) do
                                if active and states.autoConsumePotions then
                                    local matches = getInventoryItems(potionType, "Potion")
                                    for _, item in ipairs(matches) do
                                        if states.autoConsumePotions then
                                            potionRemote:FireServer(item.guid, 1)
                                            task.wait(0.1)
                                        end
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

    local SectionFlags = Tabs.Consumables:AddSection("Automatisation des Drapeaux")

    local FlagsDropdown = Tabs.Consumables:AddDropdown("FlagsDropdown", {
        Title = "Sélectionner un Drapeau",
        Values = {"Coins Flag", "Magnet Flag", "Haste Flag", "Fortune Flag", "Diamonds Flag"},
        Multi = false,
        Default = 1,
    })
    FlagsDropdown:OnChanged(function(Value) states.selectedFlag = Value end)

    local AutoFlagsToggle = Tabs.Consumables:AddToggle("AutoFlagsToggle", {Title = "Activer Auto Drapeaux", Default = false })
    AutoFlagsToggle:OnChanged(function(state)
        states.autoPlaceFlags = state
        if states.autoPlaceFlags then
            task.spawn(function()
                while states.autoPlaceFlags do
                    pcall(function()
                        if states.selectedFlag ~= "" then
                            local network = ReplicatedStorage:FindFirstChild("Network")
                            local flagRemote = network and network:FindFirstChild("FlexibleFlags_Consume")
                            
                            if flagRemote then
                                local matches = getInventoryItems(states.selectedFlag, "Flag")
                                if #matches > 0 then
                                    table.sort(matches, function(a, b) return a.tier > b.tier end)
                                    local bestFlag = matches[1]
                                    flagRemote:InvokeServer(bestFlag.realName, bestFlag.guid)
                                end
                            end
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end)

    -- ==========================================
    -- 9. LOGIQUE DE L'AUTO QUEST (AUTOPILOT MULTI-TÂCHES)
    -- ==========================================
    local SectionQuests = Tabs.Quests:AddSection("Autopilot Intelligent")

    Tabs.Quests:AddParagraph({ Title = "🤖 Comment ça marche ?", Content = "Le bot lit vos quêtes actuelles et active automatiquement les fonctions du Hub (Oeufs, Potions, Mine) en arrière-plan sans que vous n'ayez rien à faire." })

    local QuestDisplayParagraph = Tabs.Quests:AddParagraph({ Title = "📜 Status des Quêtes", Content = "Scanneur inactif." })

    local function getActiveQuests()
        local quests = {}
        pcall(function()
            local playerGui = player:FindFirstChild("PlayerGui")
            local goalsSide = playerGui and playerGui:FindFirstChild("GoalsSide")
            local holder = goalsSide and goalsSide:FindFirstChild("Frame")
                and goalsSide.Frame:FindFirstChild("Quests")
                and goalsSide.Frame.Quests:FindFirstChild("QuestsGradient")
                and goalsSide.Frame.Quests.QuestsGradient:FindFirstChild("QuestsHolder")
            
            if holder then
                for _, difficulty in ipairs({"Easy", "Medium", "Hard"}) do
                    local diffFolder = holder:FindFirstChild(difficulty)
                    local goal = diffFolder and diffFolder:FindFirstChild("RankGradient")
                        and diffFolder.RankGradient:FindFirstChild("RankHolder")
                        and diffFolder.RankGradient.RankHolder:FindFirstChild("Goal")
                    local title = goal and goal:FindFirstChild("title")
                    local progress = goal and goal:FindFirstChild("progress")
                    
                    if title and title:IsA("TextLabel") and title.Text ~= "" then
                        table.insert(quests, {
                            difficulty = difficulty,
                            text = title.Text,
                            progress = progress and progress.Text or "0/1"
                        })
                    end
                end
            end
        end)
        return quests
    end

    local function findDiamondBreakable()
        local breakablesFolder = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
        if breakablesFolder then
            for _, group in pairs(breakablesFolder:GetChildren()) do
                for _, breakable in pairs(group:GetChildren()) do
                    local isDiamond = false
                    for _, desc in ipairs(breakable:GetDescendants()) do
                        if desc:IsA("Decal") or desc:IsA("Texture") then
                            if desc.Texture:find("88416525922321") or desc.Texture:find("88416525922321c") then
                                isDiamond = true
                                break
                            end
                        elseif desc:IsA("SpecialMesh") or desc:IsA("MeshPart") then
                            if tostring(desc.MeshId):find("88416525922321") or tostring(desc.TextureId):find("88416525922321") then
                                isDiamond = true
                                break
                            end
                        end
                    end
                    if breakable.Name:lower():find("diamond") or breakable.Name:lower():find("diamant") then
                        isDiamond = true
                    end
                    
                    if isDiamond then
                        local hitbox = breakable:FindFirstChild("Hitbox") or breakable:FindFirstChildWhichIsA("BasePart")
                        if hitbox then
                            return breakable, hitbox, group.Name
                        end
                    end
                end
            end
        end
        return nil
    end

    local questEnabledEgg = false
    local questEnabledPotions = false
    local questEnabledMine = false

    local AutoQuestsToggle = Tabs.Quests:AddToggle("AutoQuestsToggle", {Title = "Démarrer l'Autopilot", Default = false })
    AutoQuestsToggle:OnChanged(function(state)
        states.autoQuests = state
        if states.autoQuests then
            task.spawn(function()
                while states.autoQuests do
                    local quests = getActiveQuests()
                    local hasHatchQuest = false
                    local hasPotionQuest = false
                    local hasDiamondQuest = false
                    local hasMineQuest = false
                    
                    for _, q in ipairs(quests) do
                        local t = q.text:lower()
                        if t:find("hatch") and (t:find("best") or t:find("meilleur") or t:find("egg") or t:find("oeuf")) then
                            hasHatchQuest = true
                        elseif t:find("potion") or t:find("consume") or t:find("utilis") then
                            hasPotionQuest = true
                        elseif t:find("diamond") or t:find("diamant") then
                            hasDiamondQuest = true
                        elseif t:find("dig") or t:find("mine") or t:find("coffre") or t:find("chest") then
                            hasMineQuest = true
                        end
                    end
                    
                    if hasHatchQuest then
                        if not questEnabledEgg then
                            questEnabledEgg = true
                            local bestEggName = "Tentacle Egg"
                            pcall(function()
                                local displayList, nameToIdMap = GetEggList()
                                if #displayList > 0 then
                                    local bestDisplay = displayList[#displayList]
                                    bestEggName = nameToIdMap[bestDisplay] or "Tentacle Egg"
                                end
                            end)
                            states.selectedEgg = bestEggName
                            if AutoEggToggle then AutoEggToggle:SetValue(true) else states.autoEgg = true end
                        end
                    else
                        if questEnabledEgg then
                            questEnabledEgg = false
                            if AutoEggToggle then AutoEggToggle:SetValue(false) else states.autoEgg = false end
                        end
                    end
                    
                    if hasPotionQuest then
                        if not questEnabledPotions then
                            questEnabledPotions = true
                            local hasSelected = false
                            for _, act in pairs(states.selectedPotions) do
                                if act then hasSelected = true break end
                            end
                            if not hasSelected then
                                states.selectedPotions["Coins Potion"] = true
                                states.selectedPotions["Luck Potion"] = true
                            end
                            if AutoPotionsToggle then AutoPotionsToggle:SetValue(true) else states.autoConsumePotions = true end
                        end
                    else
                        if questEnabledPotions then
                            questEnabledPotions = false
                            if AutoPotionsToggle then AutoPotionsToggle:SetValue(false) else states.autoConsumePotions = false end
                        end
                    end
                    
                    if hasDiamondQuest then
                        if questEnabledMine then
                            questEnabledMine = false
                            if AutoMineToggle then AutoMineToggle:SetValue(false) else states.autoMine = false end
                        end
                        
                        local breakable, hitbox, groupName = findDiamondBreakable()
                        if breakable and hitbox then
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                player.Character.HumanoidRootPart.CFrame = hitbox.CFrame + Vector3.new(0, 3, 0)
                            end
                            local network = ReplicatedStorage:FindFirstChild("Network")
                            local damageRemote = network and network:FindFirstChild("Breakables_PlayerDealDamage")
                            if damageRemote then
                                damageRemote:FireServer(groupName)
                                damageRemote:FireServer(groupName)
                            end
                        else
                            pcall(function()
                                local underworld = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("14 | Underworld")
                                local interact = underworld and underworld:FindFirstChild("INTERACT")
                                local spawns = interact and interact:FindFirstChild("BREAKABLE_SPAWNS")
                                local mainSpawn = spawns and spawns:FindFirstChild("Main")
                                if mainSpawn and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                    player.Character.HumanoidRootPart.CFrame = mainSpawn.CFrame + Vector3.new(0, 3, 0)
                                end
                            end)
                        end
                        
                    elseif hasMineQuest then
                        if not questEnabledMine then
                            questEnabledMine = true
                            states.digsiteMode = "Efficiency"
                            if AutoMineToggle then AutoMineToggle:SetValue(true) else states.autoMine = true end
                        end
                    else
                        if questEnabledMine then
                            questEnabledMine = false
                            if AutoMineToggle then AutoMineToggle:SetValue(false) else states.autoMine = false end
                        end
                    end
                    
                    task.wait(1.5)
                end
            end)
        else
            if questEnabledEgg then
                questEnabledEgg = false
                if AutoEggToggle then AutoEggToggle:SetValue(false) else states.autoEgg = false end
            end
            if questEnabledPotions then
                questEnabledPotions = false
                if AutoPotionsToggle then AutoPotionsToggle:SetValue(false) else states.autoConsumePotions = false end
            end
            if questEnabledMine then
                questEnabledMine = false
                if AutoMineToggle then AutoMineToggle:SetValue(false) else states.autoMine = false end
            end
        end
    end)

    task.spawn(function()
        while task.wait(1.5) do
            local quests = getActiveQuests()
            local content = ""
            if #quests == 0 then
                content = "Aucune quête active trouvée. En attente..."
            else
                for _, q in ipairs(quests) do
                    content = content .. string.format("• [%s] %s (%s)\n", q.difficulty, q.text, q.progress)
                end
            end
            pcall(function()
                if states.autoQuests then
                    QuestDisplayParagraph:SetTitle("🟢 Tracker Actif")
                else
                    QuestDisplayParagraph:SetTitle("🔴 Tracker Désactivé")
                end
                QuestDisplayParagraph:SetContent(content)
            end)
        end
    end)

    -- ==========================================
    -- 10. PARAMÈTRES ET FERMETURE
    -- ==========================================
    local SectionUtils = Tabs.Settings:AddSection("Utilitaires")

    local afkConnection
    local AntiAfkToggle = Tabs.Settings:AddToggle("AntiAfkToggle", {Title = "Mode Anti-AFK", Default = false })
    AntiAfkToggle:OnChanged(function(state)
        states.afkMode = state
        if states.afkMode then
            local VirtualUser = game:GetService("VirtualUser")
            afkConnection = player.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        else
            if afkConnection then afkConnection:Disconnect() end
        end
    end)

    Tabs.Settings:AddButton({
        Title = "Fermer le Hub et détruire les scripts",
        Description = "Désactive tout et supprime l'interface de l'écran.",
        Callback = function()
            FlyToggle:SetValue(false)
            NoclipToggle:SetValue(false)
            InfJumpToggle:SetValue(false)
            ESPToggle:SetValue(false)
            ClickTpToggle:SetValue(false)
            SpeedSlider:SetValue(16)
            JumpSlider:SetValue(50)
            AutoTapToggle:SetValue(false)
            AutoCollectToggle:SetValue(false)
            AutoBuyZoneToggle:SetValue(false)
            AutoMineToggle:SetValue(false)
            AutoEggToggle:SetValue(false)
            DisableAnimToggle:SetValue(false)
            EventUpgradesToggle:SetValue(false)
            AntiAfkToggle:SetValue(false)
            AutoPotionsToggle:SetValue(false)
            AutoFlagsToggle:SetValue(false)
            AutoQuestsToggle:SetValue(false)
            
            if auraVisual then auraVisual:Destroy() end
            if espFolder then espFolder:Destroy() end
            
            Fluent:Destroy()
        end
    })

    ThemeManager:SetLibrary(Fluent)
    SaveManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    ThemeManager:SetFolder("PremiumHub")
    SaveManager:SetFolder("PremiumHub/PetSim")
    
    -- Crée l'interface de sauvegarde dans l'onglet Paramètres
    SaveManager:BuildConfigSection(Tabs.Settings)
    ThemeManager:BuildInterfaceSection(Tabs.Settings)

    Window:SelectTab(1)

    -- 🟢 LIGNE AJOUTÉE : Charge automatiquement tes réglages sauvegardés !
    SaveManager:LoadAutoloadConfig()

    Fluent:Notify({
        Title = "💎 Premium Hub Chargé",
        Content = "Interface et configurations chargées !",
        Duration = 5
    })
end

-- ==========================================
-- SYSTEME DE CLEF (UI DE CONNEXION)
-- ==========================================
if CoreGui:FindFirstChild("PremiumHubKeySystem") then
    CoreGui.PremiumHubKeySystem:Destroy()
end

local KeySystemUI = Instance.new("ScreenGui")
KeySystemUI.Name = "PremiumHubKeySystem"
KeySystemUI.Parent = CoreGui
KeySystemUI.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 160)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = KeySystemUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🔑 Hub Privé - Mot de passe"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(0.8, 0, 0, 35)
TextBox.Position = UDim2.new(0.1, 0, 0.35, 0)
TextBox.PlaceholderText = "Entrez la clé d'accès..."
TextBox.Text = ""
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 14
TextBox.Parent = MainFrame

local Corner2 = Instance.new("UICorner")
Corner2.CornerRadius = UDim.new(0, 6)
Corner2.Parent = TextBox

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.8, 0, 0, 35)
SubmitBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
SubmitBtn.Text = "Valider"
SubmitBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Couleur Amethyst
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.Parent = MainFrame

local Corner3 = Instance.new("UICorner")
Corner3.CornerRadius = UDim.new(0, 6)
Corner3.Parent = SubmitBtn

SubmitBtn.MouseButton1Click:Connect(function()
    if TextBox.Text == MOT_DE_PASSE then
        -- Bonne clé : on détruit l'UI de connexion et on lance le Hub
        SubmitBtn.Text = "Succès !"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        task.wait(0.5)
        KeySystemUI:Destroy()
        LoadMainHub()
    else
        -- Mauvaise clé
        SubmitBtn.Text = "Mot de passe incorrect !"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        task.wait(1.5)
        SubmitBtn.Text = "Valider"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    end
end)
