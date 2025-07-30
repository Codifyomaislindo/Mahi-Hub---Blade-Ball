--[[
    ███╗   ███╗ █████╗ ██╗  ██╗██╗    ██╗  ██╗██╗   ██╗██████╗ 
    ████╗ ████║██╔══██╗██║  ██║██║    ██║  ██║██║   ██║██╔══██╗
    ██╔████╔██║███████║███████║██║    ███████║██║   ██║██████╔╝
    ██║╚██╔╝██║██╔══██║██╔══██║██║    ██╔══██║██║   ██║██╔══██╗
    ██║ ╚═╝ ██║██║  ██║██║  ██║██║    ██║  ██║╚██████╔╝██████╔╝
    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    Mahi Hub v3.0 - Blade Ball Script FUNCIONAL
    - Detecção automática da bola melhorada
    - Auto parry funcional corrigido
    - Manual spam com GUI separada
    - Interface otimizada e menor
]]

-- Carregamento da WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    warn("Erro ao carregar WindUI, usando interface alternativa")
    return
end

-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

-- Variáveis Principais
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Detecção correta da velocidade
local DefaultSpeed = Humanoid.WalkSpeed
if DefaultSpeed <= 16 then
    DefaultSpeed = 20 -- Velocidade padrão do Blade Ball
    Humanoid.WalkSpeed = 20
end

-- Estados das Funcionalidades
local AutoParryEnabled = false
local AutoSpamEnabled = false
local ManualSpamEnabled = false
local EspBallEnabled = false
local BallSpeedEnabled = false
local EspPlayerEnabled = false
local AntiAFKEnabled = false

-- Variáveis do Sistema
local ParryRemote = nil
local Ball = nil
local BallSpeedGUI = nil
local ManualSpamGUI = nil
local EspFolder = Instance.new("Folder")
EspFolder.Name = "MahiHubESP"
EspFolder.Parent = Workspace

-- Função para encontrar remotes de parry
local function FindParryRemote()
    ParryRemote = nil
    
    -- Busca no ReplicatedStorage
    if ReplicatedStorage:FindFirstChild("Remotes") then
        local remotes = ReplicatedStorage.Remotes
        for _, remote in pairs(remotes:GetChildren()) do
            if remote:IsA("RemoteEvent") and (
                remote.Name:lower():find("parry") or 
                remote.Name:lower():find("deflect") or
                remote.Name:lower():find("hit") or
                remote.Name == "ParryButtonPress" or
                remote.Name == "ParryAttempt"
            ) then
                ParryRemote = remote
                print("Remote de parry encontrado:", remote.Name)
                return ParryRemote
            end
        end
    end
    
    -- Busca em todo o ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and (
            obj.Name:lower():find("parry") or 
            obj.Name:lower():find("deflect") or
            obj.Name == "ParryButtonPress"
        ) then
            ParryRemote = obj
            print("Remote de parry encontrado em:", obj:GetFullName())
            return ParryRemote
        end
    end
    
    return nil
end

-- Função melhorada para detectar a bola automaticamente
local function DetectBall()
    Ball = nil
    
    -- Método 1: Busca em Balls folder
    local ballsFolder = Workspace:FindFirstChild("Balls")
    if ballsFolder then
        for _, obj in pairs(ballsFolder:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name == "Ball" then
                Ball = obj
                return Ball
            end
        end
    end
    
    -- Método 2: Busca por atributos especiais
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" then
            if obj:GetAttribute("realBall") == true or 
               obj:GetAttribute("target") or
               obj.Parent.Name == "Balls" then
                Ball = obj
                return Ball
            end
        end
    end
    
    -- Método 3: Busca geral por características da bola
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" and obj.Size.X > 3 and obj.Size.X < 10 then
            -- Verifica se tem trail ou efeitos visuais típicos de bola
            if obj:FindFirstChildOfClass("Trail") or 
               obj:FindFirstChildOfClass("Attachment") or
               obj.Material == Enum.Material.ForceField or
               obj.Material == Enum.Material.Neon then
                Ball = obj
                return Ball
            end
        end
    end
    
    -- Método 4: Busca por bola em movimento
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Ball" then
            if obj.AssemblyLinearVelocity.Magnitude > 5 then
                Ball = obj
                return Ball
            end
        end
    end
    
    return nil
end

-- Função de parry melhorada
local function PerformParry()
    if not ParryRemote then
        ParryRemote = FindParryRemote()
    end
    
    if ParryRemote then
        -- Tenta diferentes métodos de ativar o parry
        local success = false
        
        -- Método 1: Fire simples
        pcall(function()
            ParryRemote:FireServer()
            success = true
        end)
        
        -- Método 2: Com argumentos
        if not success then
            pcall(function()
                ParryRemote:FireServer(0.5, CFrame.new(), {[1] = 0.5}, {[1] = false})
                success = true
            end)
        end
        
        -- Método 3: Com boolean
        if not success then
            pcall(function()
                ParryRemote:FireServer(true)
                success = true
            end)
        end
        
        return success
    end
    
    return false
end

-- Função para criar GUI do Ball Speed
local function CreateBallSpeedGUI()
    if BallSpeedGUI then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MahiBallSpeed"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 200, 0, 60)
    Frame.Position = UDim2.new(0, 10, 0, 80)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Frame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 255, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = Frame
    
    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(1, 0, 1, 0)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Ball Speed: 0"
    SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
    SpeedLabel.TextScaled = true
    SpeedLabel.Font = Enum.Font.SourceSansBold
    SpeedLabel.Parent = Frame
    
    BallSpeedGUI = SpeedLabel
end

-- Função para criar GUI do Manual Spam (arrastável)
local function CreateManualSpamGUI()
    if ManualSpamGUI then return end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MahiManualSpam"
    ScreenGui.Parent = LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 180, 0, 80)
    Frame.Position = UDim2.new(0.5, -90, 0.3, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Frame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 100, 100)
    UIStroke.Thickness = 2
    UIStroke.Parent = Frame
    
    -- Título arrastável
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0.4, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Manual Spam"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame
    
    -- Botão de Toggle
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0.8, 0, 0.5, 0)
    ToggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    ToggleButton.Text = "OFF"
    ToggleButton.TextColor3 = Color3.new(1, 1, 1)
    ToggleButton.TextScaled = true
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Parent = Frame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ToggleButton
    
    -- Funcionalidade do botão
    ToggleButton.MouseButton1Click:Connect(function()
        ManualSpamEnabled = not ManualSpamEnabled
        if ManualSpamEnabled then
            ToggleButton.Text = "ON"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        else
            ToggleButton.Text = "OFF"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
    
    -- Sistema de arrastar
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            updateInput(input)
        end
    end)
    
    ManualSpamGUI = Frame
end

-- Interface Principal WindUI (menor)
local Window = WindUI:CreateWindow({
    Title = "Mahi Hub v3.0",
    Icon = "zap",
    Author = "Mahi Team",
    Folder = "MahiHub",
    Size = UDim2.fromOffset(480, 360), -- Tamanho reduzido
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = true,
        Anonymous = false
    },
    SideBarWidth = 160, -- Sidebar menor
    HasOutline = true,
})

Window:EditOpenButton({
    Title = "Mahi Hub",
    Icon = "shield",
    CornerRadius = UDim.new(0,10),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("#00BFFF"),
        Color3.fromHex("#FF69B4")
    ),
    Draggable = true,
})

-- Criação das Tabs corrigidas
local MainTab = Window:Tab({ 
    Title = "Main", 
    Icon = "home", 
    Desc = "Funcionalidades principais" 
})

local EspTab = Window:Tab({ 
    Title = "ESP", 
    Icon = "eye", 
    Desc = "Visualizações" 
})

local UtilsTab = Window:Tab({ 
    Title = "Utils", 
    Icon = "settings", 
    Desc = "Utilitários" 
})

-- TAB MAIN
MainTab:Paragraph({
    Title = "🎯 Auto Parry Funcional",
    Desc = "Sistema de detecção automática da bola",
    Icon = "target"
})

-- Auto Parry
MainTab:Toggle({
    Title = "Auto Parry",
    Desc = "Rebate automaticamente quando necessário",
    Icon = "shield",
    Value = false,
    Callback = function(state)
        AutoParryEnabled = state
        if state then
            FindParryRemote()
            WindUI:Notify({
                Title = "Auto Parry Ativado",
                Content = "Sistema funcional ativo!",
                Icon = "shield-check",
                Duration = 3,
            })
        end
    end
})

-- Auto Spam
MainTab:Toggle({
    Title = "Auto Spam",
    Desc = "Spam automático em situações críticas",
    Icon = "zap",
    Value = false,
    Callback = function(state)
        AutoSpamEnabled = state
    end
})

-- Manual Spam com GUI
MainTab:Toggle({
    Title = "Manual Spam GUI",
    Desc = "Abre GUI arrastável para controle manual",
    Icon = "mouse-pointer-click",
    Value = false,
    Callback = function(state)
        if state then
            CreateManualSpamGUI()
            WindUI:Notify({
                Title = "Manual Spam GUI",
                Content = "GUI arrastável criada! Use o botão para ativar/desativar",
                Icon = "external-link",
                Duration = 4,
            })
        else
            if ManualSpamGUI and ManualSpamGUI.Parent then
                ManualSpamGUI.Parent:Destroy()
                ManualSpamGUI = nil
            end
            ManualSpamEnabled = false
        end
    end
})

-- TAB ESP
EspTab:Paragraph({
    Title = "📡 Sistema ESP",
    Desc = "Visualizações automáticas",
    Icon = "radar"
})

-- ESP Ball
EspTab:Toggle({
    Title = "ESP Ball",
    Desc = "Destaque visual da bola",
    Icon = "circle-dot",
    Value = false,
    Callback = function(state)
        EspBallEnabled = state
        if not state then
            for _, esp in pairs(EspFolder:GetChildren()) do
                if esp.Name:match("Ball_ESP") then
                    esp:Destroy()
                end
            end
        end
    end
})

-- Ball Speed
EspTab:Toggle({
    Title = "Ball Speed",
    Desc = "Monitor de velocidade da bola",
    Icon = "gauge",
    Value = false,
    Callback = function(state)
        BallSpeedEnabled = state
        if state then
            CreateBallSpeedGUI()
        else
            if BallSpeedGUI and BallSpeedGUI.Parent then
                BallSpeedGUI.Parent.Parent:Destroy()
                BallSpeedGUI = nil
            end
        end
    end
})

-- ESP Player
EspTab:Toggle({
    Title = "ESP Player",
    Desc = "Visualização de jogadores",
    Icon = "users",
    Value = false,
    Callback = function(state)
        EspPlayerEnabled = state
        if not state then
            for _, esp in pairs(EspFolder:GetChildren()) do
                if esp.Name:match("Player_ESP") then
                    esp:Destroy()
                end
            end
        end
    end
})

-- TAB UTILS
UtilsTab:Paragraph({
    Title = "⚙️ Velocidade: " .. DefaultSpeed,
    Desc = "Configurações gerais",
    Icon = "settings"
})

-- Anti AFK
UtilsTab:Toggle({
    Title = "Anti AFK",
    Desc = "Previne desconexão automática",
    Icon = "clock",
    Value = false,
    Callback = function(state)
        AntiAFKEnabled = state
    end
})

-- Player Speed
UtilsTab:Input({
    Title = "Player Speed",
    Value = tostring(DefaultSpeed),
    Placeholder = "Digite a velocidade",
    Callback = function(input)
        local speed = tonumber(input)
        if speed and speed > 0 and speed <= 500 then
            if Character and Character:FindFirstChild("Humanoid") then
                Character.Humanoid.WalkSpeed = speed
                WindUI:Notify({
                    Title = "Velocidade Alterada",
                    Content = "Nova velocidade: " .. speed,
                    Icon = "activity",
                    Duration = 2,
                })
            end
        end
    end
})

-- Função para criar ESP
local function CreateESP(object, name, color)
    if not object or not object.Parent then return end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = name .. "_ESP"
    billboardGui.Adornee = object
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = EspFolder
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 1, 1)
    frame.Parent = billboardGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    return billboardGui
end

-- Loop Principal
local lastParryTime = 0
local lastBallDetection = 0

RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    
    -- Detecta a bola a cada 0.5 segundos ou se não existir
    if not Ball or not Ball.Parent or (currentTime - lastBallDetection) > 0.5 then
        DetectBall()
        lastBallDetection = currentTime
    end
    
    -- Auto Parry
    if AutoParryEnabled and Ball and Character then
        local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart and (currentTime - lastParryTime) > 0.3 then
            local distance = (Ball.Position - humanoidRootPart.Position).Magnitude
            local ballVelocity = Ball.AssemblyLinearVelocity
            local ballSpeed = ballVelocity.Magnitude
            
            -- Lógica simples e funcional
            local shouldParry = false
            
            if distance < 25 and ballSpeed > 20 then
                shouldParry = true
            elseif distance < 15 and ballSpeed > 10 then
                shouldParry = true
            elseif distance < 10 then
                shouldParry = true
            end
            
            if shouldParry then
                if PerformParry() then
                    lastParryTime = currentTime
                end
            end
        end
    end
    
    -- Auto Spam
    if AutoSpamEnabled and Ball and Character then
        local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local distance = (Ball.Position - humanoidRootPart.Position).Magnitude
            local ballSpeed = Ball.AssemblyLinearVelocity.Magnitude
            
            if distance < 15 and ballSpeed > 80 then
                for i = 1, 3 do
                    PerformParry()
                    wait(0.05)
                end
            end
        end
    end
    
    -- Manual Spam
    if ManualSpamEnabled and (currentTime - lastParryTime) > 0.1 then
        if PerformParry() then
            lastParryTime = currentTime
        end
    end
    
    -- Ball Speed Display
    if BallSpeedEnabled and Ball and BallSpeedGUI then
        local speed = math.floor(Ball.AssemblyLinearVelocity.Magnitude)
        BallSpeedGUI.Text = "Ball Speed: " .. speed
        
        if speed > 100 then
            BallSpeedGUI.TextColor3 = Color3.fromRGB(255, 0, 0)
        elseif speed > 50 then
            BallSpeedGUI.TextColor3 = Color3.fromRGB(255, 255, 0)
        else
            BallSpeedGUI.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
    
    -- ESP Ball
    if EspBallEnabled and Ball then
        local existingESP = EspFolder:FindFirstChild("Ball_ESP")
        if not existingESP then
            CreateESP(Ball, "Ball", Color3.fromRGB(255, 100, 100))
        end
    end
    
    -- ESP Players
    if EspPlayerEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local existingESP = EspFolder:FindFirstChild(player.Name .. "_ESP")
                if not existingESP then
                    CreateESP(player.Character.HumanoidRootPart, player.Name, Color3.fromRGB(100, 255, 100))
                end
            end
        end
    end
end)

-- Anti AFK
spawn(function()
    while wait(180) do
        if AntiAFKEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end
end)

-- Respawn handling
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    wait(2)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    
    if Humanoid.WalkSpeed ~= DefaultSpeed then
        Humanoid.WalkSpeed = DefaultSpeed
    end
end)

-- Inicialização
FindParryRemote()
DetectBall()

-- Notificação final
WindUI:Notify({
    Title = "Mahi Hub v3.0 Carregado!",
    Content = "Sistema funcional com detecção automática de bola!",
    Icon = "check-circle",
    Duration = 5,
})

print("=== MAHI HUB v3.0 FUNCIONAL ===")
print("Detecção automática de bola: ✓")
print("Auto parry corrigido: ✓") 
print("Manual spam com GUI: ✓")
print("Interface otimizada: ✓")
