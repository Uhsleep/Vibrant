local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)

local Assets = require(Vibrant.Assets)
local Roact = require(Dependencies.Roact)

local e = Roact.createElement
-----------------------------------------------------------------------------

local HoveredColorDelta = Vector3.new(0.05, 0.05, 0.05)

local function applyColorDelta(color, delta)
    return Color3.new(color.R + delta.X, color.G + delta.Y, color.B + delta.Z)
end

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

    self.onCheckBoxMouseEnter = function()
        if not self.props.disabled then
            self.updateIsHovered(true)
        end
    end

    self.onCheckBoxMouseLeave = function()
        if not self.props.disabled then
            self.updateIsHovered(false)
        end
    end

    self.onCheckBoxClick = function()
        if not self.props.disabled and type(self.props.onValueChanged) == "function" then
            self.props.onValueChanged(not self.props.checked)
        end
    end
end

function CheckBox:render()
    local props = {
        checkBoxBorder ={
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = self.props.disabled and Color3.fromRGB(125, 125, 125) or self.props.borderColor,
            Thickness = 2,
            Transparency = self.props.disabled and 0.5 or 0,
        },

        checkBoxBackground = {
            AutoButtonColor = false,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            TextTransparency = 1,
            
            BackgroundColor3 = self.isHoveredBinding:map(function(isHovered)
                if self.props.disabled then
                    return Color3.fromRGB(125, 125, 125)
                end
                
                if isHovered then
                    return applyColorDelta(self.props.checkedBackgroundColor, HoveredColorDelta)
                end
                
                return self.props.checkedBackgroundColor
            end),
            
            BackgroundTransparency = self.isHoveredBinding:map(function(isHovered)
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
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Image = Assets.CheckMark,
            ImageColor3 = self.props.disabled and Color3.fromRGB(170, 170, 170) or self.props.checkMarkColor,
            ImageTransparency = self.props.checked and (self.props.disabled and 0.5 or 0) or 1,
            ScaleType = Enum.ScaleType.Fit,
        }
    }

    return e("TextButton", props.checkBoxBackground, {
        UICorner = e("UICorner", { CornerRadius = UDim.new(0, 2) }),
        Border = e("UIStroke", props.checkBoxBorder),
        Padding = e("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 3),
            PaddingRight = UDim.new(0, 3),
            PaddingTop = UDim.new(0, 3),
        }),

        CheckMark = e("ImageLabel", props.checkMark)
    })
end

function CheckBox:willUpdate(nextProps)
    if nextProps.disabled and not self.props.disabled then
        -- Force set the hovered to false
        self.updateIsHovered(false)
    end
end

return CheckBox