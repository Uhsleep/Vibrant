local TextService = game:GetService("TextService")

local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)

local Assets = require(Vibrant.Assets)
local Roact = require(Dependencies.Roact)

local TextBoxBackground = Assets.TextBoxBackground
local TextBoxBorder = Assets.TextBoxBorder

local e = Roact.createElement
-----------------------------------------------------------------------------

--[[
TODOS:
--------------------
1. Lower priority: Better handle canvas positioning when removing chunks of text or adding/deleting/editing
    a large string of text within the bounds of the canvas
]]

local TextBox = Roact.Component:extend("TextBox")
TextBox.defaultProps = {
    -- Behavior
    disabled = false,
    errorMessage = "",
    hasError = false,
    maxLength = 5000,
    onTextChanged = nil,
    placeholderText = "Placeholder text...",
    text = "",

    -- Appearance
    backgroundColor = Color3.fromRGB(68, 68, 68),
    borderColor = Color3.fromRGB(30, 30, 30),
    errorBorderColor = Color3.fromRGB(210, 39, 39),
    focusedBorderColor = Color3.fromRGB(32, 113, 138),
    textColor = Color3.fromRGB(213, 213, 213)
}

function TextBox:init()
    self.canvasPositionBinding, self.updateCanvasPosition = Roact.createBinding(0)
    self.isFocused, self.updateIsFocused = Roact.createBinding(false)

    self.onFocusedGained = function()
        if not self.props.disabled then
            self.updateIsFocused(true)
        end
    end

    self.onFocusLost = function()
        if not self.props.disabled then
            self.updateIsFocused(false)
        end
    end

    self.onTextChanged = function(textBox)
        -- Roblox does not have a direct way of setting a max character limit on textboxes so we have to do it ourselves
        if textBox.Text:len() > self.props.maxLength then
            textBox.Text = textBox.Text:sub(1, self.props.maxLength)
            return
        end

        if type(self.props.onTextChanged) == "function" then
            self.props.onTextChanged(textBox.Text)
        end
    end

    self.onCursorPositionChanged = function(textBox)        
        -- CursorPosition is updated before Text is updated so we defer the calculation until the next frame 
        -- so we can guarantee we'll have the most up-to-date text
        task.defer(function()
            if textBox.CursorPosition == -1 then
                return
            end
            
            local textContainer = textBox.Parent
            local scrollBufferWidth = 10 -- How far from the textbox edges should we start scrolling the canvas

            local startPosition = textContainer.CanvasPosition.X + textContainer.Padding.PaddingLeft.Offset
            local startScrollPosition = startPosition + scrollBufferWidth
            
            local subStr = textBox.Text:sub(1, textBox.CursorPosition)
            local textSize = TextService:GetTextSize(subStr, textBox.TextSize, textBox.Font, Vector2.new(math.huge, textContainer.AbsoluteSize.Y))
            local cursorPositionPixels = textSize.X
            
            local endPosition = startPosition + textContainer.AbsoluteWindowSize.X
            local endScrollPosition = endPosition - scrollBufferWidth
            
            if cursorPositionPixels > endScrollPosition then
                local d = cursorPositionPixels - endScrollPosition
                self.updateCanvasPosition(self.canvasPositionBinding:getValue() + d)
            elseif cursorPositionPixels < startScrollPosition then
                local d = startScrollPosition - cursorPositionPixels
                self.updateCanvasPosition(self.canvasPositionBinding:getValue() - d) 
            end
        end)
    end

    self.onSizeChanged = function(textBoxContainer)
        -- Find the largest text size that fits within the height of the textbox and error label. Very hacky
        local textBox = textBoxContainer.TextBoxBorder.TextBoxBackground.TextBoxScrollingFrame.TextBox
        for textSize = 1, 100 do
            textBox.TextSize = textSize

            if textBox.TextBounds.Y > textBox.AbsoluteSize.Y then
                textBox.TextSize = textSize - 1
                break
            end
        end

        local errorMessageLabel = textBoxContainer.ErrorMessageLabel
        for textSize = 1, 100 do
            errorMessageLabel.TextSize = textSize

            if errorMessageLabel.TextBounds.Y > errorMessageLabel.AbsoluteSize.Y then
                errorMessageLabel.TextSize = textSize - 1
                break
            end
        end      
    end
end

function TextBox:render()
    local props = {
        textBoxContainer = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),

            [Roact.Change.AbsoluteSize] = self.onSizeChanged,
        },

        textBoxBorder = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = TextBoxBorder.Image,

            ImageColor3 = self.isFocused:map(function(isFocused)
                if self.props.hasError then
                    return self.props.errorBorderColor
                end

                if self.props.disabled then
                    return self.props.backgroundColor
                end

                return isFocused and self.props.focusedBorderColor or self.props.borderColor
            end),

            LayoutOrder = 0,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(TextBoxBorder.Slice.Left, TextBoxBorder.Slice.Top, TextBoxBorder.Slice.Right, TextBoxBorder.Slice.Bottom),
            Size = UDim2.new(1, 0, 0.72, 0),
        },

        textBoxBackground = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Image = TextBoxBackground.Image,
            ImageColor3 = self.props.backgroundColor,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(TextBoxBackground.Slice.Left, TextBoxBackground.Slice.Top, TextBoxBackground.Slice.Right, TextBoxBackground.Slice.Bottom),
            Size = UDim2.new(1, 0, 1, 0),
        },

        textBoxScrollingFrame = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            BottomImage = "",

            CanvasPosition = self.canvasPositionBinding:map(function(val)
                return Vector2.new(val, 0)
            end),

            CanvasSize = UDim2.new(0, 10000, 0.5, 0),
            MidImage = "",
            Position = UDim2.new(0.5, 0, 0.5, 0),
            ScrollBarThickness = 0,
            Size = UDim2.new(1, 0, 0.5, 0),
            TopImage = "",
        },

        textBox = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            PlaceholderText = self.props.placeholderText,
            PlaceholderColor3 = self.props.textColor,
            Size = UDim2.new(1, 0, 1, 0),
            Text = self.props.text,
            TextColor3 = self.props.textColor,
            TextEditable = not self.props.disabled,
            TextScaled = false,
            TextTransparency = self.props.text:len() == 0 and 0.5 or 0,
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Left,

            [Roact.Change.CursorPosition] = self.onCursorPositionChanged,
            [Roact.Change.Text] = self.onTextChanged,
            [Roact.Event.Focused] = self.onFocusedGained,
            [Roact.Event.FocusLost] = self.onFocusLost,
        },

        disabledTextLabel = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Text = self.props.text:len() == 0 and self.props.placeholderText or self.props.text,
            TextColor3 = self.props.textColor,
            TextScaled = false,
            TextTransparency = 0.7,
            TextWrapped = false,
            TextXAlignment = Enum.TextXAlignment.Left
        },

        errorMessage = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0.28, 0),
            Text = self.props.errorMessage,
            TextColor3 = self.props.errorBorderColor,
            TextScaled = false,
            TextSize = 8,
            TextTransparency =  self.props.hasError and 0 or 1,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
        }
    }

    -- Replacing a TextBox with a TextLabel when disabled emulates the removal of
    -- input events (mouse icon changing, being able to click in the text box, etc.)
    -- Roblox doesn't have a way of directly disabling a TextBox, so this is our next best thing
    local textContent = e("TextBox", props.textBox)
    if self.props.disabled then
        textContent = e("TextLabel", props.disabledTextLabel)
    end

    return e("Frame", props.textBoxContainer, {
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 3)
        }),

        TextBoxBorder = e("ImageLabel", props.textBoxBorder, {
            TextBoxBackground = e("ImageLabel", props.textBoxBackground, {
                Padding = e("UIPadding", {
                    PaddingLeft = UDim.new(0, 7),
                    PaddingRight = UDim.new(0, 7),
                    PaddingTop = UDim.new(0, 3) -- The TextBox text looks off-center towards the top without this
                }),

                TextBoxScrollingFrame = e("ScrollingFrame", props.textBoxScrollingFrame, {
                    -- Allows the carat blinker to show up when the text box is empty
                    Padding = e("UIPadding", {
                        PaddingLeft = UDim.new(0, 1)
                    }),

                    TextBox = textContent
                })
            })
        }),

        ErrorMessageLabel = e("TextLabel", props.errorMessage, {
            -- Better align the left side of the error message with the textbox border
            Padding = e("UIPadding", {
                PaddingLeft = UDim.new(0, 2)
            })
        })
    })
end

function TextBox:willUpdate(nextProps,_)
    -- Force remove focus when we are disabled
    if nextProps.disabled then
        self.updateIsFocused(false)
    end
end

return TextBox