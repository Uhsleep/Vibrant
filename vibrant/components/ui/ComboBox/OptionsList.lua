local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Dictionary = require(Vibrant.utils.Dictionary)
local Roact = require(Dependencies.Roact)

local e = Roact.createElement
-----------------------------------------------------------------------------

local function fitTextToTextContainer(textLabel)
    -- Find the largest text size that fits within the height of the textbox and error label. Very hacky
	for textSize = 1, 100 do
		textLabel.TextSize = textSize

		if textLabel.TextBounds.Y > textLabel.AbsoluteSize.Y then
			textLabel.TextSize = textSize - 1
			break
		end
	end
end

-----------------------------------------------------------------------------
local ComboBoxOptionsList = Roact.PureComponent:extend("ComboBoxOptionsList")
ComboBoxOptionsList.defaultProps = {
    -- Behavior
    options = {},
    comboBoxSizeBinding = nil,
    onOptionSelected = nil,

    -- Appearance
    backgroundColor = Color3.fromRGB(65, 65, 65),
    scrollBarcolor = Color3.fromRGB(35, 35, 35),
    textColor = Color3.fromRGB(200, 200, 200)
}

function ComboBoxOptionsList:init()
    self.onOptionComponentSizeChanged = function(optionContainer)
        local optionText = optionContainer.OptionText
        fitTextToTextContainer(optionText)
    end

    self.onAbsoluteContentSizeChanged = function(listLayout)
        local contentHeight = listLayout.AbsoluteContentSize.Y
        local optionsList = listLayout.Parent

        optionsList.CanvasSize = UDim2.new(optionsList.CanvasSize.X, UDim.new(0, contentHeight))
    end


    self.onOptionContainerMouseEnter = function(optionContainer)
        optionContainer.Transparency = 0.9
    end

    self.onOptionContainerMouseLeave = function(optionContainer)
        optionContainer.Transparency = 1
    end

    self.onOptionContainerInputEnded = function(optionContainer, inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			local x = inputObject.Position.X
			local y = inputObject.Position.Y
			
			if x < optionContainer.AbsolutePosition.X or x > optionContainer.AbsolutePosition.X + optionContainer.AbsoluteSize.X then
				return
			end
			
			if y < optionContainer.AbsolutePosition.Y or y > optionContainer.AbsolutePosition.Y + optionContainer.AbsoluteSize.Y then
				return
			end
			
            if type(self.props.onOptionSelected) == "function" then
                local option = optionContainer.OptionText.Text
                local index = optionContainer.LayoutOrder - 1
			    self.props.onOptionSelected(option, index)
            end
		end
    end
end

function ComboBoxOptionsList:render()
    local props = {
        imageButtonInputSink = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = self.props.position,
            ImageTransparency = 1,
            ZIndex = self.props.zIndex,

            Size = self.props.size:map(function(absoluteSize)
                return UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y *  math.clamp(#self.props.options, 1, 8))
            end)
        },

        optionsList = {
            BackgroundColor3 = self.props.backgroundColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = self.props.visible,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarImageColor3 = self.props.scrollBarColor,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            CanvasSize = UDim2.new(0, 0, 0, 0),
        },

        optionContainer = {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,

            Size = self.props.size:map(function(absoluteSize)
                return UDim2.new(1, 0, 0, absoluteSize.Y)
            end),

            [Roact.Change.AbsoluteSize] = self.onOptionComponentSizeChanged,
            [Roact.Event.MouseEnter] = self.onOptionContainerMouseEnter,
            [Roact.Event.MouseLeave] = self.onOptionContainerMouseLeave,
            [Roact.Event.InputEnded] = self.onOptionContainerInputEnded
        },

        optionText = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            TextScaled = false,
            TextColor3 = self.props.textColor,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left
        }
    }

    local children = {
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            SortOrder = Enum.SortOrder.LayoutOrder,

            [Roact.Change.AbsoluteContentSize] = self.onAbsoluteContentSizeChanged
        })
    }

    -- Create options
    for index, option in ipairs(self.props.options) do
        local optionContainerProps = Dictionary.merge(props.optionContainer, {
            LayoutOrder = index
        })

        local optionTextProps = Dictionary.merge(props.optionText, {
            Text = option
        })

        local optionContainer = e("Frame", optionContainerProps, {
            Padding = e("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 8),
            }),

            OptionText = e("TextLabel", optionTextProps)
        })

        local containerName = option .. "Option"
        children[containerName] = optionContainer
    end

    -- Rendering an image (or text) button makes it so inputs don't leak through the drop down list components 
    -- underneath it. Frames alone don't seem to block inputs from going to components underneath them
    return e("ImageButton", props.imageButtonInputSink, {
        OptionsList = e("ScrollingFrame", props.optionsList, children)
    })
end

return ComboBoxOptionsList