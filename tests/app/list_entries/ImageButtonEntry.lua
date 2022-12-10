local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local ImageButton = require(Plugin.dependencies.vibrant.components.ui.ImageButton)

local e = Roact.createElement
-----------------------------------------------------------------------------

local ImageButtonEntry = Roact.Component:extend("ImageButtonEntry")

function ImageButtonEntry:render()
    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 50),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),

        DefaultImageButtonContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 80, 0, 80),
        }, {
            DefaultButton = e(ImageButton, {
                
            })
        }),

        EnabledImageButtonContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 80, 0, 80),
        }, {
            EnabledButton = e(ImageButton, {
                color = Color3.fromRGB(235, 147, 147),
                scaleType = Enum.ScaleType.Stretch
            })
        }),

        DisabledImageButtonContainer = e("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 80, 0, 80),
        }, {
            DisabledButton = e(ImageButton, {
                color = Color3.fromRGB(235, 147, 147),
                disabled = true
            })
        })
    })
end

return ImageButtonEntry