-- LocalScript no StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- Variável para controlar o highlight atual
local currentHighlight = nil
local highlightedObject = nil

-- Função para obter o caminho completo de um objeto
local function getObjectPath(obj)
    local path = obj.Name
    local parent = obj.Parent
    
    while parent and parent ~= game do
        path = parent.Name .. "." .. path
        parent = parent.Parent
    end
    
    return "game." .. path
end

-- Função para criar ESP Box (Highlight)
local function createESPBox(targetObject)
    -- Remove highlight anterior se existir
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
        highlightedObject = nil
    end
    
    if not targetObject or not targetObject.Parent then
        return
    end
    
    -- Cria novo highlight[6][18]
    local highlight = Instance.new("Highlight")
    highlight.Name = "WorkspaceInspectorESP"
    
    -- Configurações do ESP Box
    highlight.FillColor = Color3.fromRGB(255, 100, 100) -- Cor do preenchimento (vermelho claro)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0) -- Cor da borda (amarelo)
    highlight.FillTransparency = 0.7 -- Transparência do preenchimento
    highlight.OutlineTransparency = 0 -- Borda totalmente opaca
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Sempre visível através de paredes[6][18]
    
    -- Aplica o highlight ao objeto
    if targetObject:IsA("Model") then
        highlight.Adornee = targetObject
    else
        highlight.Adornee = targetObject
    end
    
    highlight.Parent = targetObject
    
    -- Atualiza variáveis de controle
    currentHighlight = highlight
    highlightedObject = targetObject
    
    -- Animação de pulsação para chamar atenção
    local pulseInfo = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    local pulseTween = TweenService:Create(highlight, pulseInfo, {
        FillTransparency = 0.9,
        OutlineTransparency = 0.3
    })
    pulseTween:Play()
    
    return highlight
end

-- Função para remover ESP Box
local function removeESPBox()
    if currentHighlight then
        currentHighlight:Destroy()
        currentHighlight = nil
        highlightedObject = nil
    end
end

-- Função para detectar input mobile
local function isMobileDevice()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Criação da GUI principal (mantém a mesma estrutura anterior)
local function createMainGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WorkspaceInspector"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.9, 0, 0.75, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Corner para arredondar
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0.12, 0)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0.05, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🔍 Inspector + ESP"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = header
    
    -- Botão ESP Toggle
    local espToggle = Instance.new("TextButton")
    espToggle.Name = "ESPToggle"
    espToggle.Size = UDim2.new(0.15, 0, 0.8, 0)
    espToggle.Position = UDim2.new(0.68, 0, 0.1, 0)
    espToggle.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    espToggle.BorderSizePixel = 0
    espToggle.Text = "👁️"
    espToggle.TextColor3 = Color3.new(1, 1, 1)
    espToggle.TextScaled = true
    espToggle.Font = Enum.Font.GothamBold
    espToggle.Parent = header
    
    local espToggleCorner = Instance.new("UICorner")
    espToggleCorner.CornerRadius = UDim.new(0, 6)
    espToggleCorner.Parent = espToggle
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.12, 0, 0.8, 0)
    closeButton.Position = UDim2.new(0.86, 0, 0.1, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    -- Área de pesquisa
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.Size = UDim2.new(0.95, 0, 0.1, 0)
    searchFrame.Position = UDim2.new(0.025, 0, 0.15, 0)
    searchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = mainFrame
    
    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchFrame
    
    -- Campo de pesquisa
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(0.85, 0, 0.8, 0)
    searchBox.Position = UDim2.new(0.05, 0, 0.1, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "🔍 Pesquisar + ESP automático..."
    searchBox.Text = ""
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.PlaceholderColor3 = Color3.fromRGB(200, 200, 200)
    searchBox.TextScaled = true
    searchBox.Font = Enum.Font.Gotham
    searchBox.Parent = searchFrame
    
    -- Área de conteúdo
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(0.95, 0, 0.7, 0)
    contentFrame.Position = UDim2.new(0.025, 0, 0.27, 0)
    contentFrame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame
    
    -- ScrollingFrame para resultados
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ResultsScroll"
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.Parent = contentFrame
    
    -- UIListLayout para organizar resultados
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scrollFrame
    
    return screenGui, mainFrame, searchBox, scrollFrame, closeButton, espToggle
end

-- Função para criar item de resultado (modificada para incluir ESP)
local function createResultItem(obj, parent)
    local itemFrame = Instance.new("Frame")
    itemFrame.Name = "ResultItem"
    itemFrame.Size = UDim2.new(1, -10, 0, 85)
    itemFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    itemFrame.BorderSizePixel = 0
    itemFrame.Parent = parent
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 6)
    itemCorner.Parent = itemFrame
    
    -- Nome do objeto
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.55, 0, 0.35, 0)
    nameLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = obj.Name
    nameLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = itemFrame
    
    -- Tipo do objeto
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Name = "TypeLabel"
    typeLabel.Size = UDim2.new(0.25, 0, 0.25, 0)
    typeLabel.Position = UDim2.new(0.73, 0, 0.05, 0)
    typeLabel.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
    typeLabel.BorderSizePixel = 0
    typeLabel.Text = obj.ClassName
    typeLabel.TextColor3 = Color3.new(1, 1, 1)
    typeLabel.TextScaled = true
    typeLabel.Font = Enum.Font.Gotham
    typeLabel.Parent = itemFrame
    
    local typeLabelCorner = Instance.new("UICorner")
    typeLabelCorner.CornerRadius = UDim.new(0, 4)
    typeLabelCorner.Parent = typeLabel
    
    -- Botão ESP
    local espButton = Instance.new("TextButton")
    espButton.Name = "ESPButton"
    espButton.Size = UDim2.new(0.25, 0, 0.25, 0)
    espButton.Position = UDim2.new(0.73, 0, 0.35, 0)
    espButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    espButton.BorderSizePixel = 0
    espButton.Text = "👁️ ESP"
    espButton.TextColor3 = Color3.new(1, 1, 1)
    espButton.TextScaled = true
    espButton.Font = Enum.Font.GothamBold
    espButton.Parent = itemFrame
    
    local espButtonCorner = Instance.new("UICorner")
    espButtonCorner.CornerRadius = UDim.new(0, 4)
    espButtonCorner.Parent = espButton
    
    -- Caminho do objeto
    local pathBox = Instance.new("TextBox")
    pathBox.Name = "PathBox"
    pathBox.Size = UDim2.new(0.65, 0, 0.3, 0)
    pathBox.Position = UDim2.new(0.05, 0, 0.45, 0)
    pathBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    pathBox.BorderSizePixel = 0
    pathBox.Text = getObjectPath(obj)
    pathBox.TextColor3 = Color3.fromRGB(255, 255, 150)
    pathBox.TextScaled = true
    pathBox.Font = Enum.Font.Code
    pathBox.TextEditable = false
    pathBox.ClearTextOnFocus = false
    pathBox.Parent = itemFrame
    
    local pathBoxCorner = Instance.new("UICorner")
    pathBoxCorner.CornerRadius = UDim.new(0, 4)
    pathBoxCorner.Parent = pathBox
    
    -- Botão de copiar
    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyButton"
    copyButton.Size = UDim2.new(0.25, 0, 0.3, 0)
    copyButton.Position = UDim2.new(0.73, 0, 0.65, 0)
    copyButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "📋 Copiar"
    copyButton.TextColor3 = Color3.new(1, 1, 1)
    copyButton.TextScaled = true
    copyButton.Font = Enum.Font.GothamBold
    copyButton.Parent = itemFrame
    
    local copyButtonCorner = Instance.new("UICorner")
    copyButtonCorner.CornerRadius = UDim.new(0, 4)
    copyButtonCorner.Parent = copyButton
    
    -- Funcionalidade do botão ESP
    espButton.MouseButton1Click:Connect(function()
        createESPBox(obj)
        
        -- Feedback visual
        local originalColor = espButton.BackgroundColor3
        espButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        espButton.Text = "✓ Ativo"
        
        wait(1)
        espButton.BackgroundColor3 = originalColor
        espButton.Text = "👁️ ESP"
    end)
    
    -- Funcionalidade do botão copiar (mantém a mesma)
    copyButton.MouseButton1Click:Connect(function()
        pathBox:CaptureFocus()
        pathBox.SelectionStart = 1
        pathBox.CursorPosition = #pathBox.Text + 1
        
        -- Feedback visual
        local originalColor = copyButton.BackgroundColor3
        copyButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        copyButton.Text = "✓ Copiado!"
        
        wait(1)
        copyButton.BackgroundColor3 = originalColor
        copyButton.Text = "📋 Copiar"
    end)
    
    return itemFrame
end

-- Função para pesquisar objetos (modificada para ESP automático)
local function searchObjects(query, resultsFrame, autoESP)
    -- Limpar resultados anteriores
    for _, child in pairs(resultsFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "ResultItem" then
            child:Destroy()
        end
    end
    
    if query == "" then
        removeESPBox()
        return
    end
    
    local results = {}
    query = string.lower(query)
    
    -- Pesquisar em todos os descendentes do workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        local name = string.lower(obj.Name)
        local className = string.lower(obj.ClassName)
        
        if string.find(name, query) or string.find(className, query) then
            table.insert(results, obj)
            
            -- Limitar resultados para performance
            if #results >= 50 then
                break
            end
        end
    end
    
    -- Criar itens de resultado
    for _, obj in pairs(results) do
        createResultItem(obj, resultsFrame)
    end
    
    -- ESP automático no primeiro resultado se habilitado
    if autoESP and #results > 0 then
        createESPBox(results[1])
    end
    
    -- Atualizar tamanho do scroll
    local listLayout = resultsFrame:FindFirstChild("UIListLayout")
    if listLayout then
        resultsFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end
end

-- Função para raycast e detectar objetos
local function performRaycast(screenPosition)
    local unitRay = camera:ScreenPointToRay(screenPosition.X, screenPosition.Y)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    
    local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
    
    if raycastResult then
        return raycastResult.Instance
    end
    
    return nil
end

-- Função principal
local function setupWorkspaceInspector()
    local screenGui, mainFrame, searchBox, resultsFrame, closeButton, espToggle = createMainGui()
    local espAutoMode = true -- ESP automático habilitado por padrão
    
    -- Detectar toque na tela (mobile)
    UserInputService.TouchTap:Connect(function(touchPositions, gameProcessedEvent)
        if gameProcessedEvent then return end
        
        local touchPosition = touchPositions[1]
        local hitPart = performRaycast(touchPosition)
        
        if hitPart then
            -- Criar ESP automático do objeto tocado
            createESPBox(hitPart)
            
            -- Mostrar GUI com informações do objeto
            mainFrame.Visible = true
            
            -- Limpar pesquisa anterior
            searchBox.Text = ""
            for _, child in pairs(resultsFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name == "ResultItem" then
                    child:Destroy()
                end
            end
            
            -- Criar item para o objeto tocado
            createResultItem(hitPart, resultsFrame)
            
            -- Atualizar scroll
            local listLayout = resultsFrame:FindFirstChild("UIListLayout")
            if listLayout then
                resultsFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            end
            
            -- Animação de entrada
            mainFrame.Position = UDim2.new(0.05, 0, 1, 0)
            local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Position = UDim2.new(0.05, 0, 0.15, 0)
            })
            tween:Play()
        end
    end)
    
    -- Funcionalidade de pesquisa (com ESP automático)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchObjects(searchBox.Text, resultsFrame, espAutoMode)
    end)
    
    -- Toggle ESP automático
    espToggle.MouseButton1Click:Connect(function()
        espAutoMode = not espAutoMode
        if espAutoMode then
            espToggle.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            espToggle.Text = "👁️"
        else
            espToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            espToggle.Text = "👁️💤"
        end
    end)
    
    -- Botão de fechar
    closeButton.MouseButton1Click:Connect(function()
        removeESPBox() -- Remove ESP ao fechar
        
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(0.05, 0, 1, 0)
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            mainFrame.Visible = false
        end)
    end)
    
    -- Suporte para PC também (clique do mouse)
    if not isMobileDevice() then
        UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
            if gameProcessedEvent then return end
            
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePosition = UserInputService:GetMouseLocation()
                local hitPart = performRaycast(mousePosition)
                
                if hitPart then
                    createESPBox(hitPart)
                    
                    mainFrame.Visible = true
                    
                    searchBox.Text = ""
                    for _, child in pairs(resultsFrame:GetChildren()) do
                        if child:IsA("Frame") and child.Name == "ResultItem" then
                            child:Destroy()
                        end
                    end
                    
                    createResultItem(hitPart, resultsFrame)
                    
                    local listLayout = resultsFrame:FindFirstChild("UIListLayout")
                    if listLayout then
                        resultsFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
                    end
                    
                    mainFrame.Position = UDim2.new(0.05, 0, 1, 0)
                    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                        Position = UDim2.new(0.05, 0, 0.15, 0)
                    })
                    tween:Play()
                end
            end
        end)
    end
end

-- Aguardar o jogador carregar completamente
if player.Character then
    setupWorkspaceInspector()
else
    player.CharacterAdded:Connect(setupWorkspaceInspector)
end
