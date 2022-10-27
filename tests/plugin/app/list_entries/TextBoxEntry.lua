local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local TextBox = require(Plugin.dependencies.vibrant.components.ui.TextBox)

local e = Roact.createElement
-----------------------------------------------------------------------------

local TextBoxEntry = Roact.Component:extend("TextBoxEntry")

function TextBoxEntry:init()
    self:setState({
        defaultTextBoxText = ""
    })

    self.onDefaultTextBoxTextChanged = function(text)
        self:setState({
            defaultTextBoxText = text
        })
    end
end

function TextBoxEntry:render()
    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),

        DefaultTextBoxContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Size = UDim2.new(0.4, 0, 0, 45),
        }, {
            DefaultTextBox = e(TextBox, {
                errorMessage = "You must give a name for this resource",
                hasError = self.state.defaultTextBoxText:len() == 0,
                placeholderText = "Resource Name",
                text = self.state.defaultTextBoxText,
                onTextChanged = self.onDefaultTextBoxTextChanged,
            })
        }),

        DisabledTextBoxContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.new(0.4, 0, 0, 45),
        }, {
            DisabledTextBox = e(TextBox, {
                disabled = true,
                hasError = false,
                text = "This disabled text box cannot be changed",
            })
        }),
    })
end

return TextBoxEntry