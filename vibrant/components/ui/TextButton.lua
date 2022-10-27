local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)

local Assets = require(Vibrant.Assets)
local Roact = require(Dependencies.Roact)

local ButtonBackground = Assets.ButtonBackground
local ButtonBorder = Assets.ButtonBorder

local e = Roact.createElement
-----------------------------------------------------------------------------

local states = {
    inactive = 0,
    active = 1,
    pressed = 2
}

local TextButton = Roact.Component:extend("TextButton")
TextButton.defaultProps = {
    color = Color3.fromRGB(200, 200, 200),
    disabled = false,
    text = "Button Text",
    textColor = Color3.fromRGB(0, 0, 0),
    textFont = Enum.Font.Nunito,
    style = "Border",

    -- Events
    onEnter = nil,
    onLeave = nil,
    onButtonDown = nil,
    onButtonUp = nil,
    onClick = nil,
}

function TextButton:init()
    self.onMouseEnter = function()
        self:setState({
            buttonState = states.active
        })

        if not self.props.disabled and type(self.props.onEnter) == "function" then
            self.props.onEnter()
        end
    end

    self.onMouseLeave = function()
        self:setState({
            buttonState = states.inactive
        })

        if not self.props.disabled and type(self.props.onLeave) == "function" then
            self.props.onLeave()
        end
    end

    self.onMouseDown = function()
        self:setState({
            buttonState = states.pressed
        })

        if not self.props.disabled and type(self.props.onButtonDown) == "function" then
            self.props.onButtonDown()
        end
    end

    self.onMouseUp = function()
        if self.state.buttonState ~= states.active then
            self:setState({
                buttonState = states.active
            })
        end

        if not self.props.disabled and type(self.props.onButtonUp) == "function" then
            self.props.onButtonUp()
        end
    end

    self.onMouseClick = function()
        if not self.props.disabled and type(self.props.onClick) == "function" then
            self.props.onClick()
        end
    end

    self.activeDeltaColor = Vector3.new(-0.05, -0.05, -0.05)
    self.pressedDeltaColor = Vector3.new(-0.15, -0.15, -0.15)

    self:setState({
        buttonState = states.inactive
    })
end

function TextButton:render()
    local props = {
        imageButton = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = ButtonBorder.Image,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(ButtonBorder.Slice.Left, ButtonBorder.Slice.Top, ButtonBorder.Slice.Right, ButtonBorder.Slice.Bottom),
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = self.props.color,

            [Roact.Event.MouseEnter] = self.onMouseEnter,
            [Roact.Event.MouseLeave] = self.onMouseLeave,
            [Roact.Event.MouseButton1Down] = self.onMouseDown,
            [Roact.Event.MouseButton1Up] = self.onMouseUp,
            [Roact.Event.MouseButton1Click] = self.onMouseClick
        },

        imageLabel = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = ButtonBackground.Image,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(ButtonBackground.Slice.Left, ButtonBackground.Slice.Top, ButtonBackground.Slice.Right, ButtonBackground.Slice.Bottom),
            Size = UDim2.new(1, 0, 1, 0),
            ImageColor3 = self.props.color
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
            TextColor3 = self.props.textColor,
            TextScaled = true,
        }
    }

    if self.props.disabled then
        props.imageLabel.ImageTransparency = 0.5
        props.imageButton.ImageTransparency = 0.5
        props.textLabel.TextTransparency = 0.35
    else
        if self.state.buttonState == states.active then
            local activeColor = Color3.new(self.props.color.R + self.activeDeltaColor.X, self.props.color.G + self.activeDeltaColor.Y, self.props.color.B + self.activeDeltaColor.Z)

            props.imageLabel.ImageColor3 = activeColor
            props.imageButton.ImageColor3 = activeColor
        elseif self.state.buttonState == states.pressed then
            local pressedColor = Color3.new(self.props.color.R + self.pressedDeltaColor.X, self.props.color.G + self.pressedDeltaColor.Y, self.props.color.B + self.pressedDeltaColor.Z)

            props.imageLabel.ImageColor3 = pressedColor
            props.imageButton.ImageColor3 = pressedColor
            props.imageButton.ImageTransparency = 1
        end
    end

    if self.props.style == "Borderless" then
        props.imageButton.ImageTransparency = 1
    end

    return e("ImageButton", props.imageButton, {
        ButtonBackground = e("ImageLabel", props.imageLabel, {
            TextContainer = e("Frame", props.textContainer, {
                ButtonText  = e("TextLabel", props.textLabel)
            })
        })
    })
end

return TextButton