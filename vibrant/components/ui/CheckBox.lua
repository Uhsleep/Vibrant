local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)

local Assets = require(Vibrant.Assets)
local Roact = require(Dependencies.Roact)

local CheckBoxBackground = Assets.CheckBoxBackground
local CheckBoxBorder = Assets.TextBoxBorder

local e = Roact.createElement
-----------------------------------------------------------------------------

local CheckBox = Roact.PureComponent:extend("CheckBox")
CheckBox.defaultProps = {
    -- Behavior
    checked = false,
    disabled = false,
    onValueChanged = nil,

    -- Appearance
    borderColor = Color3.fromRGB(35, 35, 35),
    checkedBackgroundColor = Color3.fromRGB(67, 109, 176),
    checkMarkColor = Color3.fromRGB(255, 255, 255)
}

function CheckBox:init()
    self.isHoveredBinding, self.updateIsHovered = Roact.createBinding(false)

    self.onCheckBoxMouseEnter = function(checkBoxBackground, x, y)
        if not self.props.disabled then
            self.updateIsHovered(true)
        end
    end

    self.onCheckBoxMouseLeave = function(checkBoxBackground, x, y)
        if not self.props.disabled then
            self.updateIsHovered(false)
        end
    end

    self.onCheckBoxClick = function(checkBoxBackground, x, y)
        if not self.props.disabled and type(self.props.onValueChanged) == "function" then
            self.props.onValueChanged(not self.props.checked)
        end
    end
end

function CheckBox:render()
    local props = {
        border ={
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Image = CheckBoxBorder.Image,
            ImageColor3 = self.props.disabled and Color3.fromRGB(125, 125, 125) or self.props.borderColor,
            ImageTransparency = self.props.disabled and 0.5 or 0,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(CheckBoxBorder.Slice.Left, CheckBoxBorder.Slice.Top, CheckBoxBorder.Slice.Right, CheckBoxBorder.Slice.Bottom)
        },

        background = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Image = CheckBoxBackground.Image,
            ImageColor3 = self.props.disabled and Color3.fromRGB(125, 125, 125) or self.props.checkedBackgroundColor,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(CheckBoxBackground.Slice.Left, CheckBoxBackground.Slice.Top, CheckBoxBackground.Slice.Right, CheckBoxBackground.Slice.Bottom),

            ImageTransparency = self.isHoveredBinding:map(function(isHovered)
                if self.props.disabled then
                    return 0.5
                end

                if self.props.checked then
                    return 0
                end

                return isHovered and 0.6 or 1
            end),

            -- Events
            [Roact.Event.MouseEnter] = self.onCheckBoxMouseEnter,
            [Roact.Event.MouseLeave] = self.onCheckBoxMouseLeave,
            [Roact.Event.MouseButton1Click] = self.onCheckBoxClick
        },

        checkMark = {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Image = Assets.CheckMark,
            ImageColor3 = self.props.disabled and Color3.fromRGB(170, 170, 170) or self.props.checkMarkColor,
            ImageTransparency = self.props.checked and (self.props.disabled and 0.5 or 0) or 1,
            ScaleType = Enum.ScaleType.Fit,

            BackgroundTransparency = self.isHoveredBinding:map(function(isHovered)
                if not self.props.checked or self.props.disabled then
                    return 1
                end

                return isHovered and 0.9 or 1
            end),
        }
    }

    return e("ImageLabel", props.border, {
        CheckBoxBackground = e("ImageButton", props.background, {
            Padding = e("UIPadding", {
                PaddingBottom = UDim.new(0, 3),
                PaddingLeft = UDim.new(0, 3),
                PaddingRight = UDim.new(0, 3),
                PaddingTop = UDim.new(0, 3),
            }),

            CheckMark = e("ImageLabel", props.checkMark)
        })
    })
end

function CheckBox:willUpdate(nextProps)
    if nextProps.disabled and not self.props.disabled then
        -- Force set the hovered to false
        self.updateIsHovered(false)
    end
end

return CheckBox