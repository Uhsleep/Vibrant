local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Roact = require(Dependencies.Roact)

local e = Roact.createElement
-----------------------------------------------------------------------------

local HoveredColorDelta = Vector3.new(0.05, 0.05, 0.05)
local PressedColorDelta = Vector3.new(-0.15, -0.15, -0.15)

local function applyColorDelta(color, delta)
    return Color3.new(color.R + delta.X, color.G + delta.Y, color.B + delta.Z)
end

-----------------------------------------------------------------------------

local TextButton = Roact.Component:extend("TextButton")
TextButton.defaultProps = {
    -- Behavior
    disabled = false,
    text = "Button Text",
    
    onEnter = nil,
    onLeave = nil,
    onButtonDown = nil,
    onButtonUp = nil,
    onClick = nil,
    
    -- Appearance
    color = Color3.fromRGB(200, 200, 200),
    textColor = Color3.fromRGB(0, 0, 0),
    textFont = Enum.Font.Nunito,
    style = "Border",
}

function TextButton:init()
    self.isHoveredBinding, self.updateIsHovered = Roact.createBinding(false)
    self.isPressedDownBinding, self.updateIsPressedDown = Roact.createBinding(false)

    self.onMouseEnter = function()
        if self.props.disabled then
            return
        end

        self.updateIsHovered(true)

        if type(self.props.onEnter) == "function" then
            self.props.onEnter()
        end
    end

    self.onMouseLeave = function()
        if self.props.disabled then
            return
        end

        self.updateIsHovered(false)
        self.updateIsPressedDown(false)

        if type(self.props.onLeave) == "function" then
            self.props.onLeave()
        end
    end

    self.onMouseDown = function()
        if self.props.disabled then
            return
        end

        self.updateIsPressedDown(true)

        if type(self.props.onButtonDown) == "function" then
            self.props.onButtonDown()
        end
    end

    self.onMouseUp = function()
        if self.props.disabled then
            return
        end

        self.updateIsPressedDown(false)

        if type(self.props.onButtonUp) == "function" then
            self.props.onButtonUp()
        end
    end

    self.onMouseClick = function()
        if self.props.disabled then
            return
        end

        if type(self.props.onClick) == "function" then
            self.props.onClick()
        end
    end
end

function TextButton:render()
    local props = {
        textButton = {
            AutoButtonColor = false,
            BackgroundTransparency = self.props.disabled and 0.2 or 0,
            Text = "",
            Size = UDim2.new(1, 0, 1, 0),
            
            BackgroundColor3 = Roact.joinBindings({ self.isHoveredBinding, self.isPressedDownBinding }):map(function(values)
                local isHovered = values[1]
                local isPressedDown = values[2]

                -- TODO: If disabled, set color to grayish

                if isPressedDown then
                    return applyColorDelta(self.props.color, PressedColorDelta)
                end
                   
                if isHovered then
                    return applyColorDelta(self.props.color, HoveredColorDelta)
                end

                return self.props.color
            end),

            -- Events
            [Roact.Event.MouseEnter] = self.onMouseEnter,
            [Roact.Event.MouseLeave] = self.onMouseLeave,
            [Roact.Event.MouseButton1Down] = self.onMouseDown,
            [Roact.Event.MouseButton1Up] = self.onMouseUp,
            [Roact.Event.MouseButton1Click] = self.onMouseClick
        },

        textButtonBorder = {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            -- TODO: If disabled, set color to graysish
            Color = applyColorDelta(self.props.color, PressedColorDelta),
            Thickness = 2,
            Transparency = self.props.disabled and 0.2 or 0
        },

        textContainer = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.75, 0, 0.75, 0)
        },

        textLabel = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Font = self.props.textFont,
            Size = UDim2.new(1, 0, 1, 0),
            Text = self.props.text,
            TextTransparency = self.props.disabled and 0.2 or 0, 
            TextColor3 = self.props.textColor,
            TextScaled = true,
        }
    }

    local borderStroke = nil
    if self.props.style ~= "Borderless" then
        borderStroke = e("UIStroke", props.textButtonBorder)
    end

    return e("TextButton", props.textButton, {
        UICorner =e ("UICorner", { CornerRadius = UDim.new(0.1, 0) }),
        BorderStroke = borderStroke,

        TextContainer = e("Frame", props.textContainer, {
            ButtonText  = e("TextLabel", props.textLabel)
        })
    })
end

function TextButton:willUpdate(nextProps)
    if nextProps.disabled then
        self.updateIsHovered(false)
        self.updateIsPressedDown(false)
    end
end

return TextButton