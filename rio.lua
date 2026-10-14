--!nocheck
--!native

--[[                              ...,...,..................                               
                      ,,,,........,.,...,...........,.,...............,                   
                 *,,,,,,.,,,,,,,,,,,,,,,,,,,.......,,.,.................,,.               
                *,,,,,.,,........,,,,,,,,,,,,,,,,,,,,,,,,...............,,,               
                ,,,,,,,,,,,,,,,,,....,,,,,,,,,,,,,,,,,.....,,,,,,........,,,              
                ,,,,,,,*&@@@@@%,,/(**...,,,,,,,,,,,...,**,,,/%&@&%*....,,.,,              
                ,,,,&@(/(((((&@@@@@@@,%*,,,*,*,,,,,**,@@@@@@@@(//////&%...,,              
               ,,,,/,,,,,,,,,,,*(/#@@@@@(%,****,**@@@@@@#(/*,,,,,,,...,/..,,              
               *,,,,,,,,,,,,*******///(@#/******(@@@///*****,,,,,,,,,,,,.,,,              
               *,,,,****************//////*,,,,,****/*************,,,,,,,,,,              
               ,,,*******///    .//////***,,....,**//**/**    .****,**,,,,,,              
               .,,,***//              ***,,.....,,,*/             ,****,,,,,              
               ,,,,,,,,**//********,,,,,,,.......,,,,,*************,...,,,,,(             
               *,,,,,,,,,,,,,,,,...,,,,,,,.........,,,,......,,,,,,,,,..,.,,&             
               #,,******,,,,,,,,,,,,,,,,,,.......,.,.....,,,,,,,,,,,,,,,,,,,#             
                **/////*****,,,,,,,,,,,,,,..........,,,,,,,,,,,,,,,*******,,              
                ***////////********,,,,,,,.........,,.,*************///***,,              
                ****/////////////**,,,,,*,,,,,,,,,,,,,.,,/////**********,*,,              
                ***//////////*,,,,***//****/*//*********,,,,,*((/////*/*,,,               
                *****//@@**,,,,,,,,**/(/########%&///*,,,,,,,,,/*@@/***,,,,               
                 *******@@@**,,,,,,**(/@@@@@@@@@@@@/(**,,***/#/@@@***,,,,,                
                 *********@@@@@@&%@@@@@@@@@(((%@@@@@@@@@&%@@@@@@*,**,,,,,,                
                 .***********//##%&@@@@@@(#////(#@@@@@@&%#///******,,*,,,                 
                  **************,,,,***/**************,,,,******,,***,,,                  
                   ,**********/////////**//////////////*************,,,                   
                     ************///////((@@@@@@%(/******************                     
                       **********//**////(@@@@@@/*****************,                       
                         ****************(@@@@@@/**,************                          
                            *************(&@@@@@/*************                            
                              ,**********/%@@@@&/**********                               
                                  */*//////@@@&%////****                                  
                                     //////&@@&/////*   


-----------------------------------------------------------------

                    discord.gg/vKXWdGT8pc                        

-----------------------------------------------------------------

]]

local arguments = table.pack(...)
local sharedEnv = getgenv and getgenv() or _G
local previous = rawget(sharedEnv, 'Unnamed Enhancements - Cracked')

if type(previous) == 'table' and (previous.status == 'starting' or previous.status == 'entry_returned') then
    return previous
end
if rawget(sharedEnv, 'UE_LOADED') == true then
    return previous
end

local control = {
    status = 'starting',
    started = os.clock(),
    error = nil,
    stopped = false,
}

sharedEnv['Unnamed Enhancements - Cracked'] = control

local previousLoaded = rawget(sharedEnv, 'UE_LOADED')
local previousLibrary = rawget(sharedEnv, 'Library')
local previousOptions = rawget(sharedEnv, 'Options')
local previousToggles = rawget(sharedEnv, 'Toggles')
local budgets = setmetatable({}, {
    __mode = 'k',
})
local schedulerFrame = 0
local heartbeatConnection

local function __step(id)
    if control.stopped then
        error('execution stopped', 0)
    end

    local thread = coroutine.running()
    local state = budgets[thread]

    if not state then
        local now = os.clock()

        state = {
            ticks = 0,
            frame = schedulerFrame,
            started = now,
        }
        budgets[thread] = state
    end

    state.ticks += 1

    if state.ticks % 4096 ~= 0 then
        return
    end

    local now = os.clock()

    if state.frame ~= schedulerFrame then
        state.started = now
        state.ticks = 0
        state.frame = schedulerFrame
    end
    if state.ticks > 50000000 or now - state.started > 20 then
        control.error = 'Execution made no progress: loop ' .. tostring(id)
        control.status = 'error'
        control.stopped = true

        if heartbeatConnection then
            heartbeatConnection:Disconnect()
        end

        error(control.error, 0)
    end
    if state.ticks > 0 and state.ticks % 262144 == 0 and coroutine.isyieldable() then
        task.wait()

        state.frame = schedulerFrame
    end
end

local Native = {}
local Backend = {}

local function buildApplication()
    local runtime = Backend.createRuntime()
    local state = Backend.bindPrimitives(runtime)
    local data = Backend.loadProgramData()

    Backend.initialize(data)

    return state[56](data[1], state[2])
end
local function runApplication()
    local function traceback(err)
        local text = tostring(err)

        return debug and debug.traceback and debug.traceback(text, 2) or text
    end

    local ok, result = xpcall(function()
        assert(type(getgenv) == 'function', 'This file needs a Roblox executor with getgenv.')
        assert(game ~= nil and type(loadstring) == 'function', 'Roblox and loadstring are required.')
        assert(type(buffer) == 'table' and type(bit32) == 'table', 'buffer and bit32 are required.')

        heartbeatConnection = game:GetService('RunService').Heartbeat:Connect(function()
            schedulerFrame += 1
        end)

        local entry = buildApplication()

        return table.pack(entry(table.unpack(arguments, 1, arguments.n)))
    end, traceback)

    if not ok then
        control.error = result
        control.status = 'error'
        control.stopped = true

        if heartbeatConnection then
            heartbeatConnection:Disconnect()
        end

        local failedLibrary = rawget(sharedEnv, 'Library')

        if type(failedLibrary) == 'table' and failedLibrary ~= previousLibrary then
            if type(failedLibrary.Signals) == 'table' then
                for _, signal in failedLibrary.Signals do
                    if typeof(signal) == 'RBXScriptConnection' then
                        signal:Disconnect()
                    end
                end
            end
            if typeof(failedLibrary.ScreenGui) == 'Instance' then
                failedLibrary.ScreenGui:Destroy()
            end
        end

        sharedEnv.Library = previousLibrary
        sharedEnv.Options = previousOptions
        sharedEnv.Toggles = previousToggles
        sharedEnv.UE_LOADED = previousLoaded

        return control
    end

    control.status = 'entry_returned'
    control.elapsed = os.clock() - control.started

    local applicationLibrary = rawget(sharedEnv, 'Library')

    if type(applicationLibrary) == 'table' and applicationLibrary ~= previousLibrary and typeof(applicationLibrary.ScreenGui) == 'Instance' then
        applicationLibrary.ScreenGui.Destroying:Connect(function()
            control.status = 'unloaded'
            control.stopped = true

            if heartbeatConnection then
                heartbeatConnection:Disconnect()
            end

            sharedEnv.UE_LOADED = previousLoaded

            if rawget(sharedEnv, 'Library') == applicationLibrary then
                sharedEnv.Library = previousLibrary
                sharedEnv.Options = previousOptions
                sharedEnv.Toggles = previousToggles
            end
        end)
    end

    return control
end

function Backend.initialize(data)
    local root = data[1]
    local opcodes, destinations, jumpOperands, constantValues, globalNames, memberKeys, sourceRegisters = root[3], root[4], root[5], root[7], root[8], root[9], root[10]

    assert(opcodes[1] == 7 and jumpOperands[1] == 17364, 'Unexpected input version')
    assert(opcodes[17366] == 213 and opcodes[17880] == 42, 'Application boundary changed')

    -- Keep this standalone file from scheduling the old key-protected loader.
    assert(opcodes[20172] == 213 and jumpOperands[20172] == 24
        and globalNames[20172] == 'queue_on_teleport', 'Teleport boundary changed')
    opcodes[20172] = 167
    destinations[20172] = 24
    rawset(constantValues, 20172, function() end)

    opcodes[17366] = 7
    jumpOperands[17366] = 20413
    opcodes[20414] = 213
    jumpOperands[20414] = 2

    rawset(globalNames, 20414, 'os')

    opcodes[20415] = 116
    destinations[20415] = 2
    sourceRegisters[20415] = 2

    rawset(memberKeys, 20415, 'clock')

    opcodes[20416] = 171
    sourceRegisters[20416] = 2
    opcodes[20417] = 7
    jumpOperands[20417] = 2752
    opcodes[20418] = 167
    destinations[20418] = 12

    rawset(constantValues, 20418, 9395)

    local function integrityProduct(inputValue)
        return (inputValue + 63) % 100 * (inputValue % 32)
    end
    local function integrityModulo(inputValue)
        return 327 * inputValue % 10000
    end
    local function integrityOffset(inputValue)
        return 3650 * inputValue % 7115 + 3 * inputValue
    end

    opcodes[20419] = 167
    destinations[20419] = 5

    rawset(constantValues, 20419, integrityProduct)

    opcodes[20420] = 167
    destinations[20420] = 4

    rawset(constantValues, 20420, integrityModulo)

    opcodes[20421] = 167
    destinations[20421] = 3

    rawset(constantValues, 20421, integrityOffset)

    opcodes[20422] = 167
    destinations[20422] = 11

    rawset(constantValues, 20422, 964)

    opcodes[20423] = 167
    destinations[20423] = 6

    rawset(constantValues, 20423, 'Frame')

    opcodes[20424] = 167
    destinations[20424] = 7

    rawset(constantValues, 20424, 'OutlineColor')

    opcodes[20425] = 167
    destinations[20425] = 8

    rawset(constantValues, 20425, 'BindableEvent')

    opcodes[20426] = 167
    destinations[20426] = 9

    rawset(constantValues, 20426, false)

    opcodes[20427] = 167
    destinations[20427] = 10

    rawset(constantValues, 20427, true)

    opcodes[20428] = 7
    jumpOperands[20428] = 1128
    opcodes[17880] = 7
    jumpOperands[17880] = 20417
end
function Native.library(captures)
    local capture09 = captures[9]
    local capture11 = captures[11]
    local uiLibrary = captures[0]
    local capture10 = captures[10]
    local capture17 = captures[17]
    local playersService = captures[22]
    local capture12 = captures[12]
    local capture19 = captures[19]
    local textService = captures[18]
    local userInputService = captures[6]
    local capture08 = captures[8]
    local capture14 = captures[14]
    local capture02 = captures[2]
    local teamsService = captures[21]
    local contextActionService = captures[13]
    local capture01 = captures[1]
    local capture05 = captures[5]
    local capture03 = captures[3]
    local capture16 = captures[16]
    local capture20 = captures[20]
    local capture04 = captures[4]
    local capture07 = captures[7]
    local capture23 = captures[23]
    local capture15 = captures[15]

    return function()
        capture08[3][capture08[2] ] = function()
            local players = playersService:GetPlayers()

            for index = 1, #players do
                __step(5)

                players[index] = players[index].Name
            end

            table.sort(players, function(value028, value029)
                return value028 < value029
            end)

            return players
        end
        capture11[3][capture11[2] ] = function()
            local teams = teamsService:GetTeams()

            for index2 = 1, #teams do
                __step(6)

                teams[index2] = teams[index2].Name
            end

            table.sort(teams, function(value032, value033)
                return value032 < value033
            end)

            return teams
        end

        function uiLibrary:SafeCallback(callback, ...)
            if not callback then
                return
            end
            if not uiLibrary.NotifyOnError then
                return callback(...)
            end

            local success, resultOrError = pcall(callback, ...)

            if not success then
                local matchStart, matchEnd = resultOrError:find(':%d+: ')

                if not matchEnd then
                    return uiLibrary:Notify(resultOrError)
                end

                return uiLibrary:Notify(resultOrError:sub(matchEnd + 1), 3)
            end
        end
        function uiLibrary:AttemptSave()
            if uiLibrary.SaveManager then
                uiLibrary.SaveManager:Save()
            end
        end
        function uiLibrary:Create(classOrInstance, properties)
            local instance3 = classOrInstance

            if typeof(classOrInstance) == 'string' then
                instance3 = Instance.new(classOrInstance)
            end

            for key, value in next, properties do
                __step(7)

                local success2, resultOrError2 = pcall(function()
                    instance3[key] = value
                end)

                if not success2 then
                    capture17(resultOrError2)
                end
            end

            return instance3
        end
        function uiLibrary:EnableFlagCopying(enabled)
            uiLibrary.FlagCopying = enabled
        end
        function uiLibrary:ApplyTextStroke(label)
            label.TextStrokeTransparency = 1

            return uiLibrary:Create('UIStroke', {
                Color = Color3.new(0, 0, 0),
                Thickness = 1,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = label,
            })
        end
        function uiLibrary:CreateLabel(properties2, isHud)
            local textLabel = uiLibrary:Create('TextLabel', {
                BackgroundTransparency = 1,
                Font = uiLibrary.Font,
                TextColor3 = uiLibrary.FontColor,
                TextSize = 16,
                TextStrokeTransparency = 0,
            })

            uiLibrary:ApplyTextStroke(textLabel)
            uiLibrary:AddToRegistry(textLabel, {
                TextColor3 = 'FontColor',
            }, isHud)

            return uiLibrary:Create(textLabel, properties2)
        end
        function uiLibrary:MakeDraggable(frame, dragHeight, respectDragLock)
            frame.Active = true

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if respectDragLock == true and uiLibrary.CantDragForced == true then
                        return
                    end

                    local dragOffset = Vector2.new(capture03.X - frame.AbsolutePosition.X, capture03.Y - frame.AbsolutePosition.Y)

                    if dragOffset.Y > (dragHeight or 40) then
                        return
                    end

                    while userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        __step(8)

                        frame.Position = UDim2.new(0, capture03.X - dragOffset.X + frame.Size.X.Offset * frame.AnchorPoint.X, 0, capture03.Y - dragOffset.Y + frame.Size.Y.Offset * frame.AnchorPoint.Y)

                        capture04:Wait()
                    end
                end
            end)
        end

        local screenGui = Instance.new('ScreenGui', capture10)

        function uiLibrary:MakeDraggableOutline(frame2, dragHeight2, respectDragLock2)
            frame2.Active = true

            frame2.InputBegan:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.MouseButton1 then
                    if respectDragLock2 == true and uiLibrary.CantDragForced == true then
                        return
                    end

                    local dragOffset2 = Vector2.new(capture03.X - frame2.AbsolutePosition.X, capture03.Y - frame2.AbsolutePosition.Y)

                    if dragOffset2.Y > (dragHeight2 or 40) then
                        return
                    end

                    local value070 = uiLibrary:Create(capture01[3][capture01[2] ], {
                        Parent = screenGui,
                        AnchorPoint = frame2.AnchorPoint,
                        BackgroundTransparency = 1,
                        Size = frame2.Size,
                        Position = frame2.Position,
                    })
                    local uIStroke = uiLibrary:Create('UIStroke', {
                        Parent = value070,
                        Color = uiLibrary.AccentColor or Color3.new(0, 0, 0),
                    })

                    uiLibrary.IsDragging = true

                    while(userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) do
                        __step(9)

                        value070.Position = UDim2.new(0, capture03.X - dragOffset2.X + frame2.Size.X.Offset * frame2.AnchorPoint.X, 0, capture03.Y - dragOffset2.Y + frame2.Size.Y.Offset * frame2.AnchorPoint.Y)
                        uIStroke.Color = uiLibrary.AccentColor or Color3.new(0, 0, 0)

                        capture04:Wait()
                    end

                    frame2.Position = value070.Position

                    value070:Destroy()

                    uiLibrary.IsDragging = false
                end
                if input2.UserInputType == Enum.UserInputType.Touch then
                    if respectDragLock2 == true and uiLibrary.CantDragForced == true then
                        return
                    end

                    local value072 = Vector2.new(input2.Position.X - frame2.AbsolutePosition.X, input2.Position.Y - frame2.AbsolutePosition.Y)

                    if value072.Y > (dragHeight2 or 40) then
                        return
                    end

                    local value073 = uiLibrary:Create(capture01[3][capture01[2] ], {
                        Parent = screenGui,
                        AnchorPoint = frame2.AnchorPoint,
                        BackgroundTransparency = 1,
                        Size = frame2.Size,
                        Position = frame2.Position,
                    })
                    local uIStroke2 = uiLibrary:Create('UIStroke', {
                        Parent = value073,
                        Color = uiLibrary.AccentColor or Color3.new(0, 0, 0),
                    })

                    uiLibrary.IsDragging = true

                    local value075 = true
                    local value076

                    value076 = input2.Changed:Connect(function()
                        if input2.UserInputState == Enum.UserInputState.End then
                            value075 = false
                        end
                    end)

                    while value075 do
                        __step(10)

                        value073.Position = UDim2.new(0, input2.Position.X - value072.X + frame2.Size.X.Offset * frame2.AnchorPoint.X, 0, input2.Position.Y - value072.Y + frame2.Size.Y.Offset * frame2.AnchorPoint.Y)
                        uIStroke2.Color = uiLibrary.AccentColor or Color3.new(0, 0, 0)

                        capture04:Wait()
                    end

                    frame2.Position = value073.Position

                    if value076 then
                        value076:Disconnect()
                    end

                    value073:Destroy()

                    uiLibrary.IsDragging = false
                end
            end)
        end
        function uiLibrary:MakeDraggableUsingParent(handle, frame3, dragHeight3, respectDragLock3)
            handle.Active = true

            if uiLibrary.IsMobile == false then
                handle.InputBegan:Connect(function(input3)
                    if input3.UserInputType == Enum.UserInputType.MouseButton1 or input3.UserInputType == Enum.UserInputType.Touch then
                        if respectDragLock3 == true and uiLibrary.CantDragForced == true then
                            return
                        end

                        local dragOffset3 = Vector2.new(capture03.X - frame3.AbsolutePosition.X, capture03.Y - frame3.AbsolutePosition.Y)

                        if dragOffset3.Y > (dragHeight3 or 40) then
                            return
                        end

                        while userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            __step(11)

                            frame3.Position = UDim2.new(0, capture03.X - dragOffset3.X + frame3.Size.X.Offset * frame3.AnchorPoint.X, 0, capture03.Y - dragOffset3.Y + frame3.Size.Y.Offset * frame3.AnchorPoint.Y)

                            capture04:Wait()
                        end
                    end
                end)
            else
                uiLibrary:MakeDraggable(frame3, dragHeight3, respectDragLock3)
            end
        end
        function uiLibrary:MakeResizable(value085, value086)
            value085.Active = true

            local value087 = 25
            local value088 = 0.5
            local value089 = uiLibrary:Create(capture01[3][capture01[2] ], {
                SizeConstraint = Enum.SizeConstraint.RelativeXX,
                BackgroundColor3 = Color3.new(0, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 30, 0, 30),
                Position = UDim2.new(1, -30, 1, -30),
                Visible = true,
                ClipsDescendants = true,
                ZIndex = 1,
                Parent = value085,
            })
            local imageButton = uiLibrary:Create('ImageButton', {
                BackgroundColor3 = uiLibrary.AccentColor,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(2, 0, 2, 0),
                Position = UDim2.new(1, -30, 1, -30),
                ZIndex = 2,
                Parent = value089,
            })
            local uICorner = uiLibrary:Create('UICorner', {
                CornerRadius = UDim.new(0.5, 0),
                Parent = imageButton,
            })

            uiLibrary:AddToRegistry(imageButton, {
                BackgroundColor3 = 'AccentColor',
            })

            value089.Size = UDim2.fromOffset(value087, value087)
            value089.Position = UDim2.new(1, -value087, 1, -value087)
            value086 = value086 or uiLibrary.MinSize

            local value092
            local value093, uIStroke3 = nil, uiLibrary:Create('UIStroke', {
                Color = uiLibrary.AccentColor or Color3.new(0, 0, 0),
            })

            uIStroke3.Color = uiLibrary.AccentColor or Color3.new(0, 0, 0)

            local function value095(value096)
                imageButton.Position = UDim2.new()
                imageButton.Size = UDim2.new(2, 0, 2, 0)
                imageButton.Parent = value089
                imageButton.BackgroundTransparency = value096
                uICorner.Parent = imageButton
                value092 = nil

                if value093 then
                    uIStroke3.Parent = nil
                    value085.Size = value093.Size

                    value093:Destroy()
                end
            end

            if uiLibrary.IsMobile ~= true then
                imageButton.MouseButton1Down:Connect(function()
                    if value092 then
                        return
                    end

                    value092 = Vector2.new(capture03.X - (value085.AbsolutePosition.X + value085.AbsoluteSize.X), capture03.Y - (value085.AbsolutePosition.Y + value085.AbsoluteSize.Y))
                    value093 = uiLibrary:Create(capture01[3][capture01[2] ], {
                        Parent = screenGui,
                        AnchorPoint = value085.AnchorPoint,
                        BackgroundTransparency = 1,
                        Size = value085.Size,
                        Position = value085.Position,
                    })
                    uIStroke3.Parent = value093
                    imageButton.BackgroundTransparency = 1
                    imageButton.Size = UDim2.fromOffset(uiLibrary.ScreenGui.AbsoluteSize.X, uiLibrary.ScreenGui.AbsoluteSize.Y)
                    imageButton.Position = UDim2.new()
                    uICorner.Parent = nil
                    imageButton.Parent = uiLibrary.ScreenGui
                end)
                imageButton.MouseMoved:Connect(function()
                    if not value092 then
                        return
                    end

                    local value097 = Vector2.new(capture03.X - value092.X, capture03.Y - value092.Y)
                    local value098 = Vector2.new(math.clamp(value097.X - value085.AbsolutePosition.X, value086.X, math.huge), math.clamp(value097.Y - value085.AbsolutePosition.Y, value086.Y, math.huge))

                    value093.Size = UDim2.fromOffset(value098.X, value098.Y)
                end)
                imageButton.MouseButton1Up:Connect(function()
                    value095(value088)
                end)
            else
                imageButton.InputBegan:Connect(function(input4)
                    if input4.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end
                    if value092 then
                        return
                    end

                    value092 = Vector2.new(input4.Position.X - (value085.AbsolutePosition.X + value085.AbsoluteSize.X), input4.Position.Y - (value085.AbsolutePosition.Y + value085.AbsoluteSize.Y))
                    value093 = uiLibrary:Create(capture01[3][capture01[2] ], {
                        Parent = screenGui,
                        AnchorPoint = value085.AnchorPoint,
                        BackgroundTransparency = 1,
                        Size = value085.Size,
                        Position = value085.Position,
                    })
                    uIStroke3.Parent = value093
                end)
                imageButton.InputChanged:Connect(function(input5)
                    if input5.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end
                    if not value092 then
                        return
                    end

                    local value101 = Vector2.new(input5.Position.X - value092.X, input5.Position.Y - value092.Y)
                    local value102 = Vector2.new(math.clamp(value101.X - value085.AbsolutePosition.X, value086.X, math.huge), math.clamp(value101.Y - value085.AbsolutePosition.Y, value086.Y, math.huge))

                    value093.Size = UDim2.fromOffset(value102.X, value102.Y)
                end)
                imageButton.InputEnded:Connect(function(input6)
                    if input6.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    value095(value088)
                end)
            end

            value095(value088)
        end
        function uiLibrary:AddToolTip(text, target)
            local textWidth, textHeight = uiLibrary:GetTextBounds(text, uiLibrary.Font, 14)
            local value109 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BackgroundColor3 = uiLibrary.MainColor,
                BorderColor3 = uiLibrary.OutlineColor,
                Size = UDim2.fromOffset(textWidth + 5, textHeight + 4),
                ZIndex = 100,
                Parent = uiLibrary.ScreenGui,
                Visible = false,
            })
            local value110 = uiLibrary:CreateLabel({
                Position = UDim2.fromOffset(3, 1),
                Size = UDim2.fromOffset(textWidth, textHeight),
                TextSize = 14,
                Text = text,
                TextColor3 = uiLibrary.FontColor,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = value109.ZIndex + 1,
                Parent = value109,
            })

            uiLibrary:AddToRegistry(value109, {
                BackgroundColor3 = 'MainColor',
                BorderColor3 = capture15[3][capture15[2] ],
            })
            uiLibrary:AddToRegistry(value110, {
                TextColor3 = 'FontColor',
            })

            local value111 = false

            target.MouseEnter:Connect(function()
                if uiLibrary:MouseIsOverOpenedFrame() then
                    return
                end

                value111 = true
                value109.Position = UDim2.fromOffset(capture03.X + 15, capture03.Y + 12)
                value109.Visible = true

                while value111 do
                    __step(12)
                    capture19.Heartbeat:Wait()

                    value109.Position = UDim2.fromOffset(capture03.X + 15, capture03.Y + 12)
                end
            end)
            target.MouseLeave:Connect(function()
                value111 = false
                value109.Visible = false
            end)

            if capture12[3][capture12[2] ] then
                capture12[3][capture12[2] ]:GetPropertyChangedSignal('Visible'):Connect(function()
                    if capture12[3][capture12[2] ].Visible == false then
                        value111 = false
                        value109.Visible = false
                    end
                end)
            end
        end
        function uiLibrary:OnHighlight(target2, styledInstance, highlightProperties, normalProperties, canHighlight)
            local function value118()
                local registryEntry = uiLibrary.RegistryMap[styledInstance]

                for key2, value2 in next, normalProperties do
                    __step(13)

                    styledInstance[key2] = uiLibrary[value2] or value2

                    if registryEntry and registryEntry.Properties[key2] then
                        registryEntry.Properties[key2] = value2
                    end
                end
            end
            local function value122()
                if canHighlight and not canHighlight() then
                    value118()

                    return
                end

                local registryEntry2 = uiLibrary.RegistryMap[styledInstance]

                for key3, value3 in next, highlightProperties do
                    __step(14)

                    styledInstance[key3] = uiLibrary[value3] or value3

                    if registryEntry2 and registryEntry2.Properties[key3] then
                        registryEntry2.Properties[key3] = value3
                    end
                end
            end

            target2.MouseEnter:Connect(function()
                value122()
            end)
            target2.MouseMoved:Connect(function()
                value122()
            end)
            target2.MouseLeave:Connect(function()
                value118()
            end)
        end
        function uiLibrary:MouseIsOverOpenedFrame()
            for key4, value4 in next, uiLibrary.OpenedFrames do
                __step(15)

                local absolutePosition, absoluteSize = key4.AbsolutePosition, key4.AbsoluteSize

                if capture03.X >= absolutePosition.X and capture03.X <= absolutePosition.X + absoluteSize.X and capture03.Y >= absolutePosition.Y and capture03.Y <= absolutePosition.Y + absoluteSize.Y then
                    return true
                end
            end
        end
        function uiLibrary:IsMouseOverFrame(frame4)
            local absolutePosition2, absoluteSize2 = frame4.AbsolutePosition, frame4.AbsoluteSize

            if capture03.X >= absolutePosition2.X and capture03.X <= absolutePosition2.X + absoluteSize2.X and capture03.Y >= absolutePosition2.Y and capture03.Y <= absolutePosition2.Y + absoluteSize2.Y then
                return true
            end
        end
        function uiLibrary:UpdateDependencyBoxes()
            for key5, value5 in next, uiLibrary.DependencyBoxes do
                __step(16)
                value5:Update()
            end
        end
        function uiLibrary:MapValue(inputValue, inputMin, inputMax, outputMin, outputMax)
            return (1 - (inputValue - inputMin) / (inputMax - inputMin)) * outputMin + (inputValue - inputMin) / (inputMax - inputMin) * outputMax
        end
        function uiLibrary:GetTextBounds(text2, font, fontSize, bounds)
            local textSize = textService:GetTextSize(text2, fontSize, font, bounds or Vector2.new(1920, 1080))

            return textSize.X, textSize.Y
        end
        function uiLibrary:GetDarkerColor(color)
            local hue, saturation, brightness = Color3.toHSV(color)

            return Color3.fromHSV(hue, saturation, brightness / 1.5)
        end

        uiLibrary.AccentColorDark = uiLibrary:GetDarkerColor(uiLibrary.AccentColor)

        function uiLibrary:AddToRegistry(instance, properties3, isHud2)
            local registryIndex = #uiLibrary.Registry + 1
            local registryEntry3 = {
                Instance = instance,
                Properties = properties3,
                Idx = registryIndex,
            }

            table.insert(uiLibrary.Registry, registryEntry3)

            uiLibrary.RegistryMap[instance] = registryEntry3

            if isHud2 then
                table.insert(uiLibrary.HudRegistry, registryEntry3)
            end
        end
        function uiLibrary:RemoveFromRegistry(instance2)
            local registryEntry4 = uiLibrary.RegistryMap[instance2]

            if registryEntry4 then
                for index3 = #uiLibrary.Registry, 1, -1 do
                    __step(17)

                    if uiLibrary.Registry[index3] == registryEntry4 then
                        table.remove(uiLibrary.Registry, index3)
                    end
                end
                for index4 = #uiLibrary.HudRegistry, 1, -1 do
                    __step(18)

                    if uiLibrary.HudRegistry[index4] == registryEntry4 then
                        table.remove(uiLibrary.HudRegistry, index4)
                    end
                end

                uiLibrary.RegistryMap[instance2] = nil
            end
        end
        function uiLibrary:UpdateColorsUsingRegistry()
            for key6, value6 in next, uiLibrary.Registry do
                __step(19)

                for key7, value7 in next, value6.Properties do
                    __step(20)

                    if typeof(value7) == 'string' then
                        value6.Instance[key7] = uiLibrary[value7]
                    elseif typeof(value7) == 'function' then
                        value6.Instance[key7] = value7()
                    end
                end
            end
        end
        function uiLibrary:GiveSignal(connection)
            table.insert(uiLibrary.Signals, connection)
        end
        function uiLibrary:Unload()
            for index5 = #uiLibrary.Signals, 1, -1 do
                __step(21)

                local connection2 = table.remove(uiLibrary.Signals, index5)

                connection2:Disconnect()
            end

            if uiLibrary.OnUnload then
                uiLibrary.OnUnload()
            end

            contextActionService:UnbindAction('Freeze')
            capture16:Destroy()
            capture20:Destroy()
            capture05:Destroy()
            capture09:Destroy()
        end
        function uiLibrary:CreateEvent(eventName)
            self.Events[eventName] = Instance.new(capture02[3][capture02[2] ])
        end
        function uiLibrary:FireEvent(eventName2, ...)
            self.Events[eventName2]:Fire(...)
        end
        function uiLibrary:OnEvent(eventName3)
            return self.Events[eventName3].Event
        end
        function uiLibrary:OnUnload(callback2)
            uiLibrary.OnUnload = callback2
        end

        local inputCallbacks = {}

        function uiLibrary:BindToInput(inputType, callback3)
            inputCallbacks[inputType] = inputCallbacks[inputType] or {}

            table.insert(inputCallbacks[inputType], callback3)
        end

        uiLibrary:GiveSignal(userInputService.InputBegan:Connect(function(input7, ...)
            if not capture07[3][capture07[2] ] then
                return
            end

            local value189 = inputCallbacks[input7.KeyCode] or inputCallbacks[input7.UserInputType]

            if value189 then
                for key8, value8 in pairs(value189)do
                    __step(22)
                    task.spawn(value8, input7, ...)
                end
            end
        end))

        function uiLibrary:AddContextMenu(value193, value194)
            local panel = {Visible = false}

            panel.Options = {}
            panel.Container = uiLibrary:Create('ImageButton', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,
                Visible = false,
                Parent = capture09,
                Image = '',
                Active = false,
                AutoButtonColor = false,
            })
            panel.Inner = uiLibrary:Create(capture01[3][capture01[2] ], {
                BackgroundColor3 = uiLibrary.BackgroundColor,
                BorderColor3 = uiLibrary.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 15,
                Parent = panel.Container,
            })

            uiLibrary:Create('UIListLayout', {
                Name = 'Layout',
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = panel.Inner,
            })
            uiLibrary:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 0),
                Parent = panel.Inner,
            })

            local function value196()
                panel.Container.Position = UDim2.fromOffset(value193.AbsolutePosition.X + value193.AbsoluteSize.X + 4, value193.AbsolutePosition.Y + 1)
            end
            local function value197()
                local value198 = 60

                for key9, value9 in next, panel.Inner:GetChildren()do
                    __step(23)

                    if value9:IsA('TextLabel') then
                        value198 = math.max(value198, value9.TextBounds.X)
                    end
                end

                panel.Container.Size = UDim2.fromOffset(value198 + 8, panel.Inner.Layout.AbsoluteContentSize.Y + 4)
            end

            local value201 = false

            (value194 or value193).InputBegan:Connect(function(input8)
                if input8.UserInputType == Enum.UserInputType.MouseButton1 and not uiLibrary:MouseIsOverOpenedFrame() then
                    return panel:Hide()
                elseif input8.UserInputType == Enum.UserInputType.MouseButton2 and not uiLibrary:MouseIsOverOpenedFrame() then
                    return panel:Show()
                end
            end)
            uiLibrary:BindToInput(Enum.UserInputType.MouseButton1, function()
                if value201 and not uiLibrary:IsMouseOverFrame(panel.Container) then
                    panel:Hide()
                end
            end)
            uiLibrary:BindToInput(Enum.UserInputType.MouseButton2, function()
                if value201 and not uiLibrary:IsMouseOverFrame(panel.Container) and not uiLibrary:IsMouseOverFrame(value193) then
                    panel:Hide()
                end
            end)
            task.spawn(value196)
            task.spawn(value197)
            uiLibrary:AddToRegistry(panel.Inner, {
                BackgroundColor3 = 'BackgroundColor',
                BorderColor3 = capture15[3][capture15[2] ],
            })

            function panel:Show()
                value196()
                value197()

                value201 = true

                for key10, value10 in next, uiLibrary.OpenedFrames do
                    __step(24)

                    if key10.Name == 'Color' then
                        key10.Visible = false
                        uiLibrary.OpenedFrames[key10] = nil
                    end
                end

                self.Container.Visible = true
                uiLibrary.OpenedFrames[panel.Container] = true
            end
            function panel:Hide()
                value201 = false
                self.Container.Visible = false

                task.wait()

                uiLibrary.OpenedFrames[panel.Container] = nil
            end
            function panel:AddOption(text3, callback4)
                if type(callback4) ~= 'function' then
                    callback4 = function() end
                end

                local value210 = uiLibrary:CreateLabel({
                    Active = false,
                    Size = UDim2.new(1, 0, 0, 15),
                    TextSize = 13,
                    Text = text3,
                    ZIndex = 16,
                    Parent = self.Inner,
                    TextXAlignment = Enum.TextXAlignment.Center,
                })

                uiLibrary:OnHighlight(value210, value210, {
                    TextColor3 = 'AccentColor',
                }, {
                    TextColor3 = 'FontColor',
                })
                value210.InputBegan:Connect(function(input9)
                    if input9.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        return
                    end

                    callback4()
                end)

                return value210
            end

            return panel
        end

        uiLibrary:GiveSignal(capture09.DescendantRemoving:Connect(function(value212)
            if capture07[3][capture07[2] ] and uiLibrary.RegistryMap[value212] then
                uiLibrary:RemoveFromRegistry(value212)
            end
        end))

        function uiLibrary:SetWatermarkVisibility(visible)
            uiLibrary.Watermark.Visible = visible
        end
        function uiLibrary:SetWatermark(text4)
            local textWidth2, textHeight2 = uiLibrary:GetTextBounds(text4, uiLibrary.Font, 14)

            uiLibrary.Watermark.Size = UDim2.new(0, textWidth2 + 15, 0, textHeight2 * 1.5 + 3)
            uiLibrary.WatermarkText.Text = text4
        end

        local value219 = {
            BarPosition = {
                Top = UDim2.new(0, -1, 0, 0),
                Left = UDim2.new(0, -1, 0, -1),
                Right = UDim2.new(1, -2, 0, -1),
                Bottom = UDim2.new(0, -1, 1, -2),
            },
            BarSize = {
                Top = UDim2.new(1, 3, 0, 2),
                Left = UDim2.new(0, 3, 1, 2),
                Right = UDim2.new(0, 3, 1, 2),
                Bottom = UDim2.new(1, 3, 0, 2),
            },
        }
        local notificationStyle = uiLibrary.NotificationStyle
        local charFn, maxFn = string.char, math.max
        local value223 = function()
            local overrideColor = notificationStyle.OverrideColor

            if overrideColor then
                return overrideColor()
            end

            return uiLibrary.MainColor, uiLibrary.AccentColor, uiLibrary.OutlineColor, uiLibrary.FontColor
        end
        local value225

        do
            local value226 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BorderColor3 = Color3.new(0, 0, 0),
                Position = UDim2.new(0, 100, 0, 10),
                ClipsDescendants = true,
                ZIndex = 100,
            })
            local value227 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BorderMode = Enum.BorderMode.Inset,
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 101,
                Parent = value226,
                Name = 'inner',
            })
            local value228 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 102,
                Parent = value227,
                Name = 'inner',
            })
            local uIGradient = uiLibrary:Create('UIGradient', {
                Rotation = -90,
                Parent = value228,
            })
            local value230 = uiLibrary:CreateLabel({
                Position = UDim2.new(0, 4, 0, 0),
                Size = UDim2.new(1, -4, 1, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextSize = 14,
                ZIndex = 103,
                Name = 'label',
                Parent = value228,
            })
            local value231 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BorderSizePixel = 0,
                ZIndex = 104,
                Name = 'bar',
                Parent = value226,
            })

            value225 = value226
        end

        function uiLibrary:CreatePopout(settings)
            if type(settings.Title) ~= 'string' then
                settings.Title = 'No title'
            end
            if typeof(settings.Position) ~= 'UDim2' then
                settings.Position = UDim2.fromOffset(175, 50)
            end

            local screenGui2 = Instance.new('ScreenGui')

            capture23(screenGui2)

            screenGui2.ZIndexBehavior = Enum.ZIndexBehavior.Global
            screenGui2.Parent = capture10
            screenGui2.DisplayOrder = (settings.ZIndex or 0) + 19

            if settings.Center then
                settings.AnchorPoint = Vector2.new(0.5, 0.5)
                settings.Position = UDim2.fromScale(0.5, 0.5)
            end

            local popout = {}
            local value236 = uiLibrary:Create(capture01[3][capture01[2] ], {
                AnchorPoint = settings.AnchorPoint,
                BackgroundColor3 = Color3.new(0, 0, 0),
                BorderSizePixel = 0,
                Position = settings.Position,
                Size = UDim2.fromOffset(settings.Size.X, settings.Size.Y),
                Visible = settings.AutoShow,
                ZIndex = 1,
                Parent = screenGui2,
            })

            if not settings.RemoveTopbar then
                uiLibrary:MakeDraggableOutline(value236, 25)
            end

            local value237 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BackgroundColor3 = uiLibrary.MainColor,
                BorderColor3 = uiLibrary.OutlineColor,
                BorderMode = Enum.BorderMode.Inset,
                Position = UDim2.new(0, 1, 0, 1),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = 1,
                Parent = value236,
            })

            uiLibrary:AddToRegistry(value237, {
                BackgroundColor3 = 'MainColor',
                BorderColor3 = capture15[3][capture15[2] ],
            })

            if not settings.RemoveTopbar then
                local value238 = uiLibrary:CreateLabel({
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 25),
                    Text = settings.Title or '',
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 1,
                    Font = uiLibrary.Font,
                    Parent = value237,
                })
                local textLabel2 = uiLibrary:Create('TextLabel', {
                    BackgroundTransparency = 1,
                    Font = uiLibrary.Font,
                    TextColor3 = uiLibrary.AccentColor,
                    TextSize = 16,
                    TextStrokeTransparency = 0,
                    Position = UDim2.new(0, -8, 0, 0),
                    Size = UDim2.new(1, 0, 0, 25),
                    Text = settings.Version or '',
                    RichText = true,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 1,
                    Parent = value237,
                })

                uiLibrary:AddToRegistry(textLabel2, {
                    TextColor3 = 'AccentColor',
                })
            end

            local value240 = settings.RemoveTopbar and 8 or 25
            local value241 = settings.RemoveTopbar and -16 or -33
            local value242 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BackgroundColor3 = uiLibrary.BackgroundColor,
                BorderColor3 = uiLibrary.OutlineColor,
                Position = UDim2.new(0, 8, 0, value240),
                Size = UDim2.new(1, -16, 1, value241),
                ZIndex = 1,
                Parent = value237,
            })

            uiLibrary:AddToRegistry(value242, {
                BackgroundColor3 = 'BackgroundColor',
                BorderColor3 = capture15[3][capture15[2] ],
            })

            local value243 = uiLibrary:Create(capture01[3][capture01[2] ], {
                BackgroundColor3 = uiLibrary.BackgroundColor,
                BorderColor3 = Color3.new(0, 0, 0),
                BorderMode = Enum.BorderMode.Inset,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0),
                ZIndex = 1,
                Parent = value242,
            })

            uiLibrary:AddToRegistry(value243, {
                BackgroundColo... (Tiempo restante: 14 MB)
