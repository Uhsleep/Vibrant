local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local TextButton = require(Plugin.dependencies.vibrant.components.ui.TextButton)

local e = Roact.createElement
-----------------------------------------------------------------------------

local ButtonsEntry = Roact.Component:extend("ButtonsEntry")

function ButtonsEntry:render()
    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),

        DefaultButtonContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.2, 0, 0, 40),
        }, {
            DefaultButton = e(TextButton, {
                
            })
        }),

        EnabledButtonContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.2, 0, 0, 40),
        }, {
            EnabledButton = e(TextButton, {
                text = "Enabled Button",
                color = Color3.fromRGB(235, 147, 147)
            })
        }),

        DisabledButtonContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.2, 0, 0, 40),
        }, {
            DisabledButton = e(TextButton, {
                text = "Disabled Button",
                color = Color3.fromRGB(235, 147, 147),
                disabled = true
            })
        }),

        BorderlessButtonContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 3,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.2, 0, 0, 40),
        }, {
            BorderlessButton = e(TextButton, {
                color = Color3.fromRGB(166, 235, 147),
                style = "Borderless",
                text = "Borderless Button",
                textColor = Color3.fromRGB(39, 62, 40),
                textFont = Enum.Font.Code,
            })
        })
    })
end

return ButtonsEntry