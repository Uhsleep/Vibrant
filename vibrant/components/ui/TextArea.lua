local TextService = game:GetService("TextService")

local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Roact = require(Dependencies.Roact)

local e = Roact.createElement
-----------------------------------------------------------------------------

local TextArea = Roact.PureComponent:extend("TextArea")
TextArea.defaultProps = {
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
    textColor = Color3.fromRGB(213, 213, 213),
    textSize = 12
}

function TextArea:init()
    self.canvasPositionBinding, self.updateCanvasPosition = Roact.createBinding(0)
    self.canvasHeightBinding, self.updateCanvasHeight = Roact.createBinding(0)
    self.isFocusedBinding, self.updateIsFocused = Roact.createBinding(false)

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

    self.onTextChanged = function(textArea)
        -- Roblox does not have a direct way of setting a max character limit on textAreaes so we have to do it ourselves
        if textArea.Text:len() > self.props.maxLength then
            textArea.Text = textArea.Text:sub(1, self.props.maxLength)
            return
        end

        self:CalculateCanvasHeight(textArea)

        if type(self.props.onTextChanged) == "function" then
            self.props.onTextChanged(textArea.Text)
        end
    end

    self.onCursorPositionChanged = function(textArea)
        -- CursorPosition is updated before Text is updated so we defer the calculation until the next frame 
        -- so we can guarantee we'll have the most up-to-date text

        task.defer(function()
            -- Clicking outside of the TextBox
            if textArea.CursorPosition == -1 then
                return
            end
            
            local function calculateSubStrEndPosition(str, currentCursorPosition)
                local index = str:find("%s", currentCursorPosition)
                if not index then
                    return str:len()
                end

                return index - 1
            end
            
            local textContainer = textArea.Parent
            local startScrollPosition = textContainer.CanvasPosition.Y
            local endScrollPosition = startScrollPosition + textContainer.AbsoluteWindowSize.Y
            
            local textBoundsParams = Instance.new("GetTextBoundsParams")
            textBoundsParams.Font = textArea.FontFace
            textBoundsParams.Size = textArea.TextSize
            textBoundsParams.Width = textArea.AbsoluteSize.X
            
            local subStr = textArea.Text:sub(1, calculateSubStrEndPosition(textArea.Text, textArea.CursorPosition))
            textBoundsParams.Text = subStr
            local textSize = TextService:GetTextBoundsAsync(textBoundsParams)
            
            textBoundsParams.Text = ""
            local caratHeight = TextService:GetTextBoundsAsync(textBoundsParams).Y
            local cursorPosition = textSize.Y - caratHeight

            if cursorPosition + caratHeight > endScrollPosition then
                local d = cursorPosition + caratHeight - endScrollPosition
                self.updateCanvasPosition(self.canvasPositionBinding:getValue() + d)
            elseif cursorPosition < startScrollPosition then
                local d = startScrollPosition - cursorPosition
                self.updateCanvasPosition(self.canvasPositionBinding:getValue() - d) 
            end
        end)
    end

    self.onCanvasPositionChanged = function(textScrollingFrame)
        self.updateCanvasPosition(textScrollingFrame.CanvasPosition.Y)
    end

    self.onInputChanged = function(textArea, inputObject)
        -- When the text box is focused we're not able to use the default ScrollingFrame scroll functionality,
        -- so we mimick the behavior here. This does result in two different scrolling behaviors when
        -- focused vs unfocused but ¯\_(ツ)_/¯

        if not self.isFocusedBinding:getValue() then
            return
        end

        if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
            local textContainer = textArea.Parent

            local minValue = 0
            local maxValue = math.max(minValue, textArea.AbsoluteSize.Y - textContainer.AbsoluteWindowSize.Y)
            local scale = 40

            local currentValue = self.canvasPositionBinding:getValue()
            local newValue = math.clamp(currentValue - scale * inputObject.Position.Z, minValue, maxValue)

            self.updateCanvasPosition(newValue)
        end
    end

    self.onTextAreaSizeChanged = function(textArea)
        self:CalculateCanvasHeight(textArea)
    end

    self.onTextFontChanged = function(textArea)
        self:CalculateCanvasHeight(textArea)
    end

    self.onTextSizeChanged = function(textArea)
        self:CalculateCanvasHeight(textArea)
    end
end

function TextArea:render()
    local props = {
        textAreaContainer = {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0)
        },

        textAreaBorder = {
            Thickness = 2,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

            Color = self.isFocusedBinding:map(function(isFocused)
                if self.props.hasError then
                    return self.props.errorBorderColor
                end

                if self.props.disabled then
                    return self.props.backgroundColor
                end

                return isFocused and self.props.focusedBorderColor or self.props.borderColor
            end)
        },

        textAreaBackground = {
            BackgroundColor3 = self.props.backgroundColor,
            Size = UDim2.new(1, 0, 0.72, 0)
        },

        textAreaScrollingFrame = {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            ScrollBarThickness = 12,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Size = UDim2.new(1, 0, 1, 0),
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,

            CanvasSize = self.canvasHeightBinding:map(function(height)
                return UDim2.new(0, 0, 0, height)
            end),

            CanvasPosition = self.canvasPositionBinding:map(function(val)
                return Vector2.new(0, val)
            end),

            -- Events
            [Roact.Change.CanvasPosition] = self.onCanvasPositionChanged
        },

        textArea = {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            MultiLine = true,
            PlaceholderText = self.props.placeholderText,
            PlaceholderColor3 = self.props.textColor,
            Size = UDim2.new(1, 0, 1, 0),
            Text = self.props.text,
            TextColor3 = self.props.textColor,
            TextEditable = not self.props.disabled,
            TextScaled = false,
            TextSize = self.props.textSize,
            TextTransparency = self.props.text:len() == 0 and 0.5 or 0,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,

            -- Events
            [Roact.Change.AbsoluteSize] = self.onTextAreaSizeChanged,
            [Roact.Change.CursorPosition] = self.onCursorPositionChanged,
            [Roact.Change.Text] = self.onTextChanged,
            [Roact.Change.FontFace] = self.onTextFontChanged,
            [Roact.Change.TextSize] = self.onTextSizeChanged,
            [Roact.Event.Focused] = self.onFocusedGained,
            [Roact.Event.FocusLost] = self.onFocusLost,
            [Roact.Event.InputChanged] = self.onInputChanged,
        },

        disabledTextLabel = {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Text = self.props.text:len() == 0 and self.props.placeholderText or self.props.text,
            TextColor3 = self.props.textColor,
            TextScaled = false,
            TextSize = self.props.textSize,
            TextTransparency = 0.7,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,

            -- Events
            [Roact.Change.AbsoluteSize] = self.onTextAreaSizeChanged
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

    -- Replacing a textArea with a TextLabel when disabled emulates the removal of
    -- input events (mouse icon changing, being able to click in the text box, etc.)
    -- Roblox doesn't have a way of directly disabling a textArea, so this is our next best thing
    local textContent = e("TextBox", props.textArea, {
        -- Allows the carat blinker to show up when the text box is empty
        Padding = e("UIPadding", {
            PaddingLeft = UDim.new(0, 1)
        }),
    })
    
    if self.props.disabled then
        textContent = e("TextLabel", props.disabledTextLabel, {
            Padding = e("UIPadding", {
                PaddingLeft = UDim.new(0, 1)
            })
        })
    end

    return e("Frame", props.textAreaContainer, {
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 3)
        }),

        TextAreaBackground = e("Frame", props.textAreaBackground, {
            UICorner = e("UICorner", { CornerRadius = UDim.new(0, 4) }),
            Border = e("UIStroke", props.textAreaBorder),
            Padding = e("UIPadding", {
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 6)
            }),

            TextAreaScrollingFrame = e("ScrollingFrame", props.textAreaScrollingFrame, {
                TextArea = textContent
            })
        }),

        ErrorMessageLabel = e("TextLabel", props.errorMessage, {
            -- Better align the left side of the error message with the textArea border
            Padding = e("UIPadding", {
                PaddingLeft = UDim.new(0, 2)
            })
        })
    })
end


function TextArea:willUpdate(nextProps)
    -- Force remove focus when we are disabled
    if nextProps.disabled then
        self.updateIsFocused(false)
    end
end

function TextArea:CalculateCanvasHeight(textArea)
    local textBoundsParams = Instance.new("GetTextBoundsParams")
    textBoundsParams.Text = textArea.Text
    textBoundsParams.Font = textArea.FontFace
    textBoundsParams.Size = textArea.TextSize
    textBoundsParams.Width = textArea.AbsoluteSize.X

    local success, result = pcall(TextService.GetTextBoundsAsync, TextService, textBoundsParams)
    if not success then
        warn("Failure calling GetTextBoundsAsync:", result)
    end

    self.updateCanvasHeight(result.Y + 1)
end

return TextArea