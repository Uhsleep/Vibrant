local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Assets = require(Vibrant.Assets)
local Dictionary = require(Vibrant.utils.Dictionary)
local Roact = require(Dependencies.Roact)

local StudioDockWidgetGuiContext = require(Vibrant.components.studio.StudioDockWidgetGuiContext)
local OptionsList = require(script.OptionsList)

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

local ComboBox = Roact.PureComponent:extend("ComboBox")
ComboBox.defaultProps = {
    -- Behavior
    options = {},
    placeHolderText = "Select an option...",
    selectedOptions = "",
    onOptionSelected = nil,
    disabled = false,
    hasError = false,

    -- Appearance
    borderColor = Color3.fromRGB(35, 35, 35),
    backgroundColor = Color3.fromRGB(65, 65, 65),
    textColor = Color3.fromRGB(170, 170, 170),
    errorBorderColor = Color3.fromRGB(220, 30, 30),
    disabledColor = Color3.fromRGB(125, 125, 125),
}

function ComboBox:init()
    self.comboBoxPositionBinding, self.updateComboBoxPosition = Roact.createBinding(Vector2.new())
    self.comboBoxSizeBinding, self.updateComboBoxSize = Roact.createBinding(Vector2.new())
    self.isDownArrowHoveredBinding, self.updateIsDownArrowHovered = Roact.createBinding(false)

    self.onComboBoxAbsoluteSizeChanged = function(comboBox)
        local padding = comboBox.Padding
        local paddingLeft = padding.PaddingLeft.Offset
        local paddingRight = padding.PaddingRight.Offset
        self.updateComboBoxSize(Vector2.new(comboBox.AbsoluteSize.X - paddingLeft - paddingRight, comboBox.AbsoluteSize.Y))

        -- The down arrow container will always maintain an aspect ratio of 1, so we need to offset
        -- the text container by the down arrow container width so they correctly line up side by side
        local downArrowContainer = comboBox.ComboBoxBackground.DownArrowContainer
        local textContainer = comboBox.ComboBoxBackground.TextContainer
        textContainer.Size = UDim2.new(UDim.new(1, -downArrowContainer.AbsoluteSize.X), textContainer.Size.Y)
    end

    self.onComboBoxAbsolutePositionChanged = function(comboBox)
        local padding = comboBox.Padding
        local paddingLeft = padding.PaddingLeft.Offset
        self.updateComboBoxPosition(Vector2.new(comboBox.AbsolutePosition.X + paddingLeft, comboBox.AbsolutePosition.Y))
    end

    self.onTextContainerSizeChanged = function(textContainer)
        local comboBoxTextLabel = textContainer.SelectedText
        fitTextToTextContainer(comboBoxTextLabel)
    end

    self.onDownArrowContainerMouseEnter = function()
        if not self.props.disabled then
            self.updateIsDownArrowHovered(true)
        end
    end

    self.onDownArrowContainerMouseLeave = function()
        if not self.props.disabled then
            self.updateIsDownArrowHovered(false)
        end
    end

    self.onDownArrowContainerMouseClick = function()
        if not self.props.disabled then
            self:setState({
                isListOpen = not self.state.isListOpen
            })
        end
    end

    self.onOptionSelected = function(option, index)
        self:setState({
            isListOpen = false
        })

        if type(self.props.onOptionSelected) == "function" then
            self.props.onOptionSelected(option, index)
        end
    end

    self.onTextContainerInputEnded = function(comboBoxTextContainer, inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and not self.props.disabled then
            local x = inputObject.Position.X
            local y = inputObject.Position.Y

            if x < comboBoxTextContainer.AbsolutePosition.X or x > comboBoxTextContainer.AbsolutePosition.X + comboBoxTextContainer.AbsoluteSize.X then
                return
            end

            if y < comboBoxTextContainer.AbsolutePosition.Y or y > comboBoxTextContainer.AbsolutePosition.Y + comboBoxTextContainer.AbsoluteSize.Y then
                return
            end
            
            self:setState({
                isListOpen = not self.state.isListOpen
            })
        end
    end

    self:setState({
        isListOpen = false
    })
end

function ComboBox:render()
    -- Attempt to find the selectedOption within the list of options
    -- If not found, set the combo box to blank
    local foundOption = false
    for _, option in ipairs(self.props.options) do
        if option == self.props.selectedOption then
            foundOption = true
            break
        end
    end
    
    local borderColor = self.props.hasError and self.props.errorBorderColor or self.props.borderColor
    if self.props.disabled then
        borderColor = self.props.disabledColor
    end

    local props = {
        optionsList = {
            options = self.props.options,
            backgroundColor = self.props.backgroundColor,
            scrollBarColor = self.props.borderColor,
            size = self.comboBoxSizeBinding,
            textColor = self.props.textColor,
            onOptionSelected = self.onOptionSelected,
            visible = self.state.isListOpen,
            
            position = Roact.joinBindings({ self.comboBoxPositionBinding, self.comboBoxSizeBinding }):map(function(values)
                local absolutePosition = values[1]
                local absoluteSize = values[2]
                
                return UDim2.new(0, absolutePosition.X, 0, absolutePosition.Y + absoluteSize.Y)
            end)
        },

        canvasGroup = {
            BackgroundTransparency = 1,
            GroupTransparency = self.props.disabled and 0.2 or 0,
            Size = UDim2.new(1, 0, 1, 0),

             -- Events
             [Roact.Change.AbsoluteSize] = self.onComboBoxAbsoluteSizeChanged,
             [Roact.Change.AbsolutePosition] = self.onComboBoxAbsolutePositionChanged
        },

        comboBoxBorder = {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = borderColor,
            Thickness = 2,
        },

        comboBoxBackground = {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = self.props.disabled and self.props.disabledColor or self.props.backgroundColor
        },

        textContainer = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0.85, 0, 1, 0), -- TODO: Better handling for this sizing

            [Roact.Change.AbsoluteSize] = self.onTextContainerSizeChanged,
            [Roact.Event.InputEnded] = self.onTextContainerInputEnded
        },

        selectedText = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Text = foundOption and self.props.selectedOption or self.props.placeHolderText,
            TextTransparency = foundOption and 0 or (self.props.disabled and 0 or 0.5),
            TextColor3 = self.props.textColor,
            TextScaled = false,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left
        },

        downArrowContainer = {
            AnchorPoint = Vector2.new(1, 0.5),
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.15, 0, 1, 0),
            ImageTransparency = 1,

            -- Events
            [Roact.Event.MouseEnter] = self.onDownArrowContainerMouseEnter,
            [Roact.Event.MouseLeave] = self.onDownArrowContainerMouseLeave,
            [Roact.Event.MouseButton1Click] = self.onDownArrowContainerMouseClick
        },

        downArrow = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Image = Assets.ComboBoxDownArrow,
            ImageColor3 = self.isDownArrowHoveredBinding:map(function(isDownArrowHovered)
                if not isDownArrowHovered then
                    return self.props.borderColor
                end

                local highlightedColor = Color3.new(self.props.borderColor.R + 0.05, self.props.borderColor.G + 0.05, self.props.borderColor.B + 0.05)
                return highlightedColor
            end)
        }
    }

    local optionsContent = nil
    if self.state.isListOpen then
        -- Calculate the highest Z-Index
        local highestZIndex = 0
        for _, child in ipairs(self.props.dockWidget:GetChildren()) do
            if child:IsA("GuiObject") and child.ZIndex > highestZIndex then
                highestZIndex = child.ZIndex
            end
        end

        props.optionsList.zIndex = highestZIndex + 1
        optionsContent = e(Roact.Portal, { target = self.props.dockWidget }, {
            OptionsList = e(OptionsList, props.optionsList)
        })
    end

    return Roact.createFragment({
        Options = optionsContent,
        
        ComboBox = e("CanvasGroup", props.canvasGroup, {
            Padding = e("UIPadding", {
                PaddingBottom = UDim.new(0, 2),
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                PaddingTop = UDim.new(0, 2)
            }),

            ComboBoxBackground = e("Frame", props.comboBoxBackground, {
                UICorner = e("UICorner", { CornerRadius = UDim.new(0.1, 0) }),
                Border = e("UIStroke", props.comboBoxBorder),
                Padding = e("UIPadding", {
                    PaddingLeft = UDim.new(0, 2),
                    PaddingTop = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 2),
                }),
    
                TextContainer = e("Frame", props.textContainer, {
                    Padding = e("UIPadding", {
                        PaddingLeft = UDim.new(0, 7),
                        PaddingTop = UDim.new(0, 4),
                        PaddingRight = UDim.new(0, 7),
                        PaddingBottom = UDim.new(0, 4),
                    }),
    
                    SelectedText = e("TextLabel", props.selectedText)
                }),
    
                DownArrowContainer = e("ImageButton", props.downArrowContainer, {
                    ARConstraint = e("UIAspectRatioConstraint", {
                        AspectRatio = 1
                    }),

                    Padding = e("UIPadding", {
                        PaddingLeft = UDim.new(0.25, 0),
                        PaddingTop = UDim.new(0.25, 0),
                        PaddingRight = UDim.new(0.25, 0),
                        PaddingBottom = UDim.new(0.25, 0),
                    }),
    
                    DownArrow = e("ImageLabel", props.downArrow)
                })
            }),
        })
    })
end

function ComboBox:willUpdate(nextProps, nextState)
    -- Not sure if this is the right way to do this? Maybe I need to use getDerivedStateFromProps?
    if nextProps.disabled and nextProps.disabled ~= self.props.disabled then
        nextState.isListOpen = false
        self.updateIsDownArrowHovered(false)
    end
end

local function ComboBoxWithDockWidgetContext(props)
    return e(StudioDockWidgetGuiContext.Consumer, {
        render = function(dockWidget)
            return e(ComboBox, Dictionary.merge(props, {
                dockWidget = dockWidget
            }))
        end
    })
end

return ComboBoxWithDockWidgetContext