local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local CheckBox = require(Plugin.dependencies.vibrant.components.ui.CheckBox)

local e = Roact.createElement
-----------------------------------------------------------------------------

local CheckBoxEntry = Roact.Component:extend("CheckBoxEntry")

function CheckBoxEntry:init()
    self.onDefaultCheckBoxValueChanged = function(isChecked)
        self:setState({
            defaultCheckBoxValue = isChecked
        })
    end

    self:setState({
        defaultCheckBoxValue = false
    })
end

function CheckBoxEntry:render()
    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 100),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),

        DefaultCheckBoxContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Size = UDim2.new(0, 25, 0, 25),
        }, {
            DefaultCheckBox = e(CheckBox, {
                checked = self.state.defaultCheckBoxValue,
                onValueChanged = self.onDefaultCheckBoxValueChanged
            })
        }),

        UncheckedDisabledCheckBoxContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.new(0, 25, 0, 25),
        }, {
            UncheckedDisabledCheckBox = e(CheckBox, {
                disabled = true,
                checked = false
            })
        }),

        CheckedDisabledCheckBoxContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Size = UDim2.new(0, 25, 0, 25),
        }, {
            CheckedDisabledCheckBox = e(CheckBox, {
                disabled = true,
                checked = true
            })
        })
    })
end

return CheckBoxEntry