local RunService = game:GetService("RunService")

local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Roact = require(Dependencies.Roact)
local Dictionary = require(Vibrant.utils.Dictionary)

local e = Roact.createElement
-----------------------------------------------------------------------------

local function filterTextToNumber(text)
	return tonumber(text)
end

-----------------------------------------------------------------------------

--[[
TODOS:
-------------
1. Consider removing common functionality out of the button events into their own function
2. Support for resizing
]]

local NumericStepper = Roact.PureComponent:extend("NumericStepper")
NumericStepper.defaultProps = {
    -- Behavior
    minValue = 0,
    maxValue = 10,
    value = 5,
    onValueChanged = nil,

    -- Appearance
    borderColor = Color3.fromRGB(35, 35, 35),
    backgroundColor = Color3.fromRGB(65, 65, 65),
    decrementButtonColor = Color3.fromRGB(170, 0, 0),
    incrementButtonColor = Color3.fromRGB(0, 175, 0),
    numberColor = Color3.fromRGB(200, 200, 200),
    disabledBackgroundColor = Color3.fromRGB(125, 125, 125),
    disabledTextColor = Color3.fromRGB(40, 40, 40)
}

function NumericStepper:init()
    self.props.value = math.clamp(self.props.value, self.props.minValue, self.props.maxValue)

    self.isDecrementButtonHoveredBinding, self.updateIsDecrementButtonHovered = Roact.createBinding(false)
    self.isDecrementButtonDownBinding, self.updateIsDecrementButtonDown = Roact.createBinding(false)
    self.decrementButtonConnection = nil

    self.isIncrementButtonHoveredBinding, self.updateIsIncrementButtonHovered = Roact.createBinding(false)
    self.isIncrementButtonDownBinding, self.updateIsIncrementButtonDown = Roact.createBinding(false)
    self.incrementButtonConnection = nil
    
    self.onDecrementButtonMouseEnter = function()
        self.updateIsDecrementButtonHovered(true)
    end

    self.onDecrementButtonMouseLeave = function()
        self.updateIsDecrementButtonHovered(false)
        self.updateIsDecrementButtonDown(false)

        if self.decrementButtonConnection then
            self.decrementButtonConnection:Disconnect()
            self.decrementButtonConnection = nil
        end
    end

    self.onDecrementButtonMouseDown = function()
        self.updateIsDecrementButtonDown(true)

        if self.decrementButtonConnection then
            self.decrementButtonConnection:Disconnect()
        end
        
        local delayTime = 600
        local accumulatedTime = 0
        self.decrementButtonConnection = RunService.Heartbeat:Connect(function(dt)
            accumulatedTime = accumulatedTime + 1000 * dt
            if accumulatedTime >= delayTime then
                accumulatedTime = 0
                delayTime = math.max(delayTime * 0.5, 90)
                
                if not self.props.disabled and type(self.props.onValueChanged) == "function" and self.props.value > self.props.minValue then
                    self.props.onValueChanged(self.props.value - 1)
                end
            end
        end)
    end

    self.onDecrementButtonMouseUp = function()
        self.updateIsDecrementButtonDown(false)

        if self.decrementButtonConnection then
           self.decrementButtonConnection:Disconnect()
            self.decrementButtonConnection = nil
        end
    end

    self.onDecrementButtonMouseClick = function()
        if not self.props.disabled and type(self.props.onValueChanged) == "function" and self.props.value > self.props.minValue then
            self.props.onValueChanged(self.props.value - 1)
        end
    end

    self.onIncrementButtonMouseEnter = function()
        self.updateIsIncrementButtonHovered(true)
    end

    self.onIncrementButtonMouseLeave = function()
        self.updateIsIncrementButtonHovered(false)
        self.updateIsIncrementButtonDown(false)

        if self.incrementButtonConnection then
            self.incrementButtonConnection:Disconnect()
            self.incrementButtonConnection = nil
        end
    end

    self.onIncrementButtonMouseDown = function()
        self.updateIsIncrementButtonDown(true)

        if self.incrementButtonConnection then
            self.incrementButtonConnection:Disconnect()
        end
        
        local delayTime = 600
        local accumulatedTime = 0
        self.incrementButtonConnection = RunService.Heartbeat:Connect(function(dt)
            accumulatedTime = accumulatedTime + 1000 * dt
            if accumulatedTime >= delayTime then
                accumulatedTime = 0
                delayTime = math.max(delayTime * 0.5, 90)
                
                if not self.props.disabled and type(self.props.onValueChanged) == "function" and self.props.value < self.props.maxValue then
                    self.props.onValueChanged(self.props.value + 1)
                end
            end
        end)
    end

    self.onIncrementButtonMouseUp = function()
        self.updateIsIncrementButtonDown(false)

        if self.incrementButtonConnection then
           self.incrementButtonConnection:Disconnect()
            self.incrementButtonConnection = nil
        end
    end

    self.onIncrementButtonMouseClick = function()
        if not self.props.disabled and type(self.props.onValueChanged) == "function" and self.props.value < self.props.maxValue then
            self.props.onValueChanged(self.props.value + 1)
        end
    end

    self.onNumberTextFocusLost = function(textLabel)
        local filteredNumber = filterTextToNumber(textLabel.Text)
        if not filteredNumber then
            -- Set the filtered number to the last known set value
            filteredNumber = self.props.value
        end

        filteredNumber = math.clamp(filteredNumber, self.props.minValue, self.props.maxValue)

        -- The number label value is driven by the value prop passed in. We need to make sure it stays syncd to that
        -- prop value even when users are able to change it via typing
        textLabel.Text = self.props.value

        if filteredNumber ~= self.props.value and type(self.props.onValueChanged) == "function" then
            self.props.onValueChanged(filteredNumber)
        end
    end
end

function NumericStepper:render()
    local shouldDisableDecrementButton = self.props.disabled or self.props.value <= self.props.minValue
    local shouldDisableIncrementButton = self.props.disabled or self.props.value >= self.props.maxValue

    local props = {
        border = {
            BackgroundColor3 = self.props.disabled and self.props.disabledColor or self.props.borderColor,
            BackgroundTransparency = self.props.disabled and 0.3 or 0,
            Size = UDim2.new(1, 0, 1, 0)
        },

        decrementContainer = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Size = UDim2.new(0, 26, 1, 0)
        },

        decrementBackground = {
            BackgroundColor3 = self.props.disabled and self.props.disabledColor or self.props.backgroundColor,
            BackgroundTransparency = self:determineButtonBackgroundTransparency(shouldDisableDecrementButton),
            Size = UDim2.new(1, 5, 1, 0),
        },

        decrementButton = {
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 2,
            Text = "",

            BackgroundColor3 =self.isDecrementButtonDownBinding:map(function(isDown)
                return isDown and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255 , 255 ,255)
            end),

            BackgroundTransparency = Roact.joinBindings({self.isDecrementButtonHoveredBinding, self.isDecrementButtonDownBinding}):map(function(values)
                local isHovered = values[0]
                local isDown = values[1]

                if (isHovered or isDown) and not shouldDisableDecrementButton then
                    return 0.9
                end

                return 1
            end),

            -- Events
            [Roact.Event.MouseEnter] = self.onDecrementButtonMouseEnter,
            [Roact.Event.MouseLeave] = self.onDecrementButtonMouseLeave,
            [Roact.Event.MouseButton1Down] = self.onDecrementButtonMouseDown,
            [Roact.Event.MouseButton1Up] = self.onDecrementButtonMouseUp,
            [Roact.Event.MouseButton1Click] = self.onDecrementButtonMouseClick
        },

        decrementButtonLabel = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),

            FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = "-",
            -- TextColor3 = shouldDisableDecrementButton and self.props.backgroundColor or self.props.decrementButtonColor,
            TextColor3 = self:determineButtonIconColor(shouldDisableDecrementButton, self.props.decrementButtonColor),
            TextScaled = false,
            TextSize = 30,
            TextTransparency = self.props.disabled and 0.5 or 0
        },

        numberContainer = {
            BackgroundColor3 = self.props.borderColor,
            BackgroundTransparency = self.props.disabled and 1 or 0,
            BorderSizePixel = 0,
            LayoutOrder = 1,
            Size = UDim2.new(1, -52, 1, 0),
        },

        numberTextContainer = {
            BackgroundColor3 = self.props.disabled and self.props.disabledColor or self.props.backgroundColor,
            BackgroundTransparency = self.props.disabled and 1 or 0,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
        },

        number = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            
            ClipsDescendants = true,

            Text = self.props.value,
            TextColor3 = self.props.disabled and self.props.disabledTextColor or self.props.numberColor,
            TextScaled = false,
            TextSize = 13,
            TextTransparency = self.props.disabled and 0.5 or 0
        },

        incrementContainer = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 2,
            Size = UDim2.new(0, 26, 1, 0)
        },

        incrementBackground = {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = self.props.disabled and self.props.disabledColor or self.props.backgroundColor,
            BackgroundTransparency = self:determineButtonBackgroundTransparency(shouldDisableIncrementButton),
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(1, 5, 1, 0),
        },

        incrementButton = {
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 2,
            Text = "",

            BackgroundColor3 = self.isIncrementButtonDownBinding:map(function(isDown)
                return isDown and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255 , 255 ,255)
            end),

            BackgroundTransparency = Roact.joinBindings({self.isIncrementButtonHoveredBinding, self.isIncrementButtonDownBinding}):map(function(values)
                local isHovered = values[0]
                local isDown = values[1]

                if (isHovered or isDown) and not shouldDisableIncrementButton then
                    return 0.9
                end

                return 1
            end),

            -- Events
            [Roact.Event.MouseEnter] = self.onIncrementButtonMouseEnter,
            [Roact.Event.MouseLeave] = self.onIncrementButtonMouseLeave,
            [Roact.Event.MouseButton1Down] = self.onIncrementButtonMouseDown,
            [Roact.Event.MouseButton1Up] = self.onIncrementButtonMouseUp,
            [Roact.Event.MouseButton1Click] = self.onIncrementButtonMouseClick
        },

        incrementButtonLabel = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),

            FontFace = Font.new("rbxasset://fonts/families/ComicNeueAngular.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Text = "+",
            TextColor3 = self:determineButtonIconColor(shouldDisableIncrementButton, self.props.incrementButtonColor),
            TextScaled = false,
            TextSize = 30,
            TextTransparency = self.props.disabled and 0.5 or 0
        }
    }

    -- Replacing a TextBox with a TextLabel when disabled emulates the removal of
    -- input events (mouse icon changing, being able to click in the text box, etc.)
    -- Roblox doesn't have a way of directly disabling a TextBox, so this is our next best thing
    local numberContent = nil
    if self.props.disabled then
        numberContent = e("TextLabel", props.number)
    else
        local enabledNumberProps = Dictionary.merge(props.number, {
            ClearTextOnFocus = false,

            -- Events
            [Roact.Event.FocusLost] = self.onNumberTextFocusLost
        })

        numberContent = e("TextBox", enabledNumberProps)
    end

    return e("Frame", props.border, {
        UICorner = e("UICorner", { CornerRadius = UDim.new(0, 5) }),
        
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),

        Padding = e("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
        }),

        DecrementContainer = e("Frame", props.decrementContainer, {
            DecrementBackground = e("Frame", props.decrementBackground, {
                UICorner = e("UICorner", { CornerRadius = UDim.new(0, 4) })
            }),

            DecrementButton = e("TextButton", props.decrementButton, {
                Padding = e("UIPadding", { PaddingBottom = UDim.new(0, 5) }),
                DecrementButtonLabel = e("TextLabel", props.decrementButtonLabel)
            })
        }),

        NumberContainer = e("Frame", props.numberContainer, {
            Padding = e("UIPadding", {
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1)
            }),

            TextContainer = e("Frame", props.numberTextContainer, {
                Text = numberContent
            })
        }),

        IncrementContainer = e("Frame", props.incrementContainer, {
            IncrementBackground = e("Frame", props.incrementBackground, {
                UICorner = e("UICorner", { CornerRadius = UDim.new(0, 4) })
            }),

            IncrementButton = e("TextButton", props.incrementButton, {
                Padding = e("UIPadding", {
                    PaddingBottom = UDim.new(0, 3),
                    PaddingLeft = UDim.new(0, 3)
                }),

                IncrementButtonLabel = e("TextLabel", props.incrementButtonLabel)
            })
        })
    })
end

function NumericStepper:willUpdate(nextProps)
    nextProps.value = math.clamp(nextProps.value, nextProps.minValue, nextProps.maxValue)

    if nextProps.disabled and nextProps.disabled ~= self.props.disabled then
        self.updateIsDecrementButtonHovered(false)
        self.updateIsDecrementButtonDown(false)

        self.updateIsIncrementButtonHovered(false)
        self.updateIsIncrementButtonDown(false)

        self:removeButtonConnections()
    end
end

function NumericStepper:willUnmount()
    self:removeButtonConnections()
end

function NumericStepper:removeButtonConnections()
    if self.decrementButtonConnection then
        self.decrementButtonConnection:Disconnect()
        self.decrementButtonConnection = nil
    end

    if self.incrementButtonConnection then
        self.incrementButtonConnection:Disconnect()
        self.incrementButtonConnection = nil
    end
end

function NumericStepper:determineButtonBackgroundTransparency(shouldIndividuallyDisable)
    if self.props.disabled then
        return 1
    end

    return shouldIndividuallyDisable and 0.5 or 0
end

function NumericStepper:determineButtonIconColor(shouldIndividuallyDisable, enabledColor)
    if self.props.disable then
        return self.props.disabledTextColor
    end

    return shouldIndividuallyDisable and self.props.backgroundColor or enabledColor
end

return NumericStepper