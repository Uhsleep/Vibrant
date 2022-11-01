local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Roact = require(Dependencies.Roact)

local Marks = require(script.Marks)
local ThumbValueDisplay = require(script.ThumbValueDisplay)

local e = Roact.createElement
-----------------------------------------------------------------------------

local function lerp(min, max, t)
    return min + (max - min) * t
end

local function invLerp(min, max, val)
    return (val - min) / (max - min)
end

-----------------------------------------------------------------------------
local DefaultNumSteps = 200
local DisabledColor = Color3.fromRGB(125, 125, 125)

local Slider = Roact.PureComponent:extend("Slider")
Slider.defaultProps = {
    -- Behavior
    min = 0,
    max = 10,
    value = 5,
    showMarks = false,
    disabled = false,
    onValueChanged = nil,

    -- Appearance
    thumbColor = Color3.fromRGB(111, 203, 117),
    thumbDownColor = Color3.fromRGB(71, 138, 75),
    emptyColor = Color3.fromRGB(230, 230, 230), -- TODO: Better name for these last 3 things
    markColorCovered = Color3.fromRGB(270, 270, 270),
    markColorUncovered = Color3.fromRGB(30, 30, 30),
}

function Slider:init()
    self.isSliderHoveredBinding, self.updateIsSliderHovered = Roact.createBinding(false)
    self.isThumbHoveredBinding, self.updateIsThumbHovered = Roact.createBinding(false)
    self.isMouseDownBinding, self.updateIsMouseDown = Roact.createBinding(false)

    self.onSliderContainerInputBegan = function(slider, inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and not self.props.disabled then
            self.updateIsMouseDown(true)

            -- Update position since mouse moved might not get called
            self.onSliderContainerMouseMoved(slider, inputObject.Position.X, inputObject.Position.Y)
        end
    end

    self.onSliderContainerInputEnded = function(slider, inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and not self.props.disabled then
            self.updateIsMouseDown(false)
        end
    end

    self.onSliderContainerMouseEnter = function(slider, x, y)
        if not self.props.disabled then
            self.updateIsSliderHovered(true)
        end
    end

    self.onSliderContainerMouseLeave = function(slider, x, y)
        if not self.props.disabled then
            self.updateIsSliderHovered(false)
        end
    end

    self.onSliderContainerMouseMoved = function(slider, x, y)
        if not self.props.disabled and self.isMouseDownBinding:getValue() and type(self.props.onValueChanged) == "function" then
            -- Determine what the value of the slider would be based on the new slider x position
            local trackLeftSide = slider.TrackLeftSide
            local trackRightSide = slider.TrackRightSide
            local trackStartingX = trackLeftSide.AbsolutePosition.X
            local trackEndingX = trackRightSide.AbsolutePosition.X + trackRightSide.AbsoluteSize.X

            local t = math.clamp(invLerp(trackStartingX, trackEndingX, x), 0, 1)
            local value = lerp(self.props.min, self.props.max, t)

            -- Since the slider is comprised of steps (visible or not), we need to push this value towards
            -- the nearest multiple of self.props.step. If no step is provided, we calculate one such that there are
            -- 100 steps from min to max
            local step = self.props.step or (self.props.max - self.props.min) / DefaultNumSteps
            local remainder = value % step

            local nextStep = math.clamp(value - remainder + step, self.props.min, self.props.max)
            local previousStep = math.clamp(value - remainder, self.props.min, self.props.max)

            if nextStep - value < value - previousStep then
                value = nextStep
            else
                value = previousStep
            end

            if value ~= self.props.value then
                self.props.onValueChanged(value)
            end
        end
    end

    self.onThumbMouseEnter = function(thumb, x, y)
        self.updateIsThumbHovered(true)
    end

    self.onThumbMouseLeave = function(thumb, x, y)
        self.updateIsThumbHovered(false)
    end
end

function Slider:render()
    -- Calculate where the thumb should be
    local thumbPositionXScale = math.clamp(invLerp(self.props.min, self.props.max, self.props.value), 0, 1)

    local props = {
        slider = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),

            -- Events
            [Roact.Event.InputBegan] = self.onSliderContainerInputBegan,
            [Roact.Event.InputEnded] = self.onSliderContainerInputEnded,
            [Roact.Event.MouseEnter] = self.onSliderContainerMouseEnter,
            [Roact.Event.MouseLeave] = self.onSliderContainerMouseLeave,
            [Roact.Event.MouseMoved] = self.onSliderContainerMouseMoved
        },

        discreteMarksContainer = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 0, 5),
            ZIndex = 2,
        },

        thumb = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            
            BackgroundColor3 = Roact.joinBindings({self.isThumbHoveredBinding, self.isSliderHoveredBinding, self.isMouseDownBinding}):map(function(values)
                if self.props.disabled then
                    return DisabledColor
                end

                local isThumbHovered = values[1]
                local isSliderHovered = values[2]
                local isMouseDown = values[3]

                if isMouseDown and isSliderHovered then
                    return Color3.new(self.props.thumbColor.R - 0.1, self.props.thumbColor.G - 0.1, self.props.thumbColor.B - 0.1)
                end

                if not isMouseDown and isThumbHovered then
                    return Color3.new(self.props.thumbColor.R + 0.05, self.props.thumbColor.G + 0.05, self.props.thumbColor.B + 0.05)
                end

                return self.props.thumbColor
            end),

            BorderSizePixel = 0,
            Position = UDim2.new(thumbPositionXScale, 0, 0.5, 0),
            Size = UDim2.new(0, 24, 0, 24),
            ZIndex = 3,

            -- Events
            [Roact.Event.MouseEnter] = self.onThumbMouseEnter,
            [Roact.Event.MouseLeave] = self.onThumbMouseLeave
        },

        thumbValueDisplay = {
            value = self.props.value,

            visible =  Roact.joinBindings({self.isThumbHoveredBinding, self.isSliderHoveredBinding, self.isMouseDownBinding}):map(function(values)
                local isThumbHovered = values[1]
                local isSliderHovered = values[2]
                local isMouseDown = values[3]

                return (isMouseDown and isSliderHovered and not self.props.disabled) or isThumbHovered
            end)
        },

        trackLeftSide = {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = self.props.disabled and DisabledColor or self.props.thumbColor,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(thumbPositionXScale, 0, 0, 5),
            ZIndex = 1,
        },

        trackRightSide = {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = self.props.disabled and DisabledColor or self.props.emptyColor,
            Position = UDim2.new(thumbPositionXScale, 0, 0.5, 0),
            Size = UDim2.new(1 - thumbPositionXScale, 0, 0, 5),
            ZIndex = 1,
        }
    }

    local discreteMarksContainer
    if self.props.showMarks and not self.props.disabled then
        local markPositions = self:calculateMarkPositions()
        discreteMarksContainer = e("Frame", props.discreteMarksContainer, {
            Marks = e(Marks, {
                marks = markPositions
            })
        })
    end

    return e("Frame", props.slider, {
        Padding = e("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        }),

        DiscreteMarksContaniner = discreteMarksContainer,

        Thumb = e("Frame", props.thumb, {
            UICorner = e("UICorner", {
                CornerRadius = UDim.new(0, 12)
            }),

            ThumbValueDisplay = e(ThumbValueDisplay, props.thumbValueDisplay)
        }),

        TrackLeftSide = e("Frame", props.trackLeftSide, {
            UICorner = e("UICorner", {
                CornerRadius = UDim.new(0, 3)
            })
        }),

        TrackRightSide = e("Frame", props.trackRightSide, {
            UICorner = e("UICorner", {
                CornerRadius = UDim.new(0, 3)
            })
        })
    })
end

function Slider:willUpdate(nextProps, _)
    if not nextProps.disabled and nextProps.disabled ~= self.props.disabled then
        self.updateIsSliderHovered(false)
        self.updateIsThumbHovered(false)
        self.updateIsMouseDown(false)
    end
end

function Slider:calculateMarkPositions()
    -- These positions should exclude the beginning and ending as those would be 
    -- transparent on the slider anyways. We only want to include the intermediate marks
    local markPositions = {}
    for value = self.props.min, self.props.max, self.props.step do
        if value ~= self.props.min and value ~= self.props.max then 
            table.insert(markPositions, {
                position = invLerp(self.props.min, self.props.max, value),
                color = value > self.props.value and self.props.markColorUncovered or self.props.markColorCovered
            })
        end
    end

    return markPositions
end

return Slider