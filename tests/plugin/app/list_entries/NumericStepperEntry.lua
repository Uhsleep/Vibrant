local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local NumericStepper = require(Plugin.dependencies.vibrant.components.ui.NumericStepper)

local e = Roact.createElement
-----------------------------------------------------------------------------

local NumericStepperEntry = Roact.Component:extend("NumericStepperEntry")

function NumericStepperEntry:init()
    self.onDefaultNumericStepperValueChanged = function(value)
        self:setState({
            defaultNumericStepperValue = value
        })
    end

    self:setState({
        defaultNumericStepperValue = 5
    })
end

function NumericStepperEntry:render()
    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 30),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),

        DefaultNumericStepperContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Size = UDim2.new(0.08, 0, 0, 30),
        }, {
            DefaultNumericStepper = e(NumericStepper, {
                minValue = 0,
                maxValue = 15,
                value = self.state.defaultNumericStepperValue,

                onValueChanged = self.onDefaultNumericStepperValueChanged
            })
        }),

        DisabledNumericStepperContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.new(0.08, 0, 0, 30),
        }, {
            DisabledNumericStepper = e(NumericStepper, {
                disabled = true,
                disabledColor = Color3.fromRGB(125, 125, 125),
            })
        }),
    })
end

return NumericStepperEntry