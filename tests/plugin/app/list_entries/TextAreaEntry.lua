local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local TextArea = require(Plugin.dependencies.vibrant.components.ui.TextArea)

local e = Roact.createElement
-----------------------------------------------------------------------------

local TextAreaEntry = Roact.Component:extend("TextAreaEntry")

function TextAreaEntry:init()
    self:setState({
        defaultTextAreaText = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Imperdiet massa tincidunt nunc pulvinar sapien et ligula. Amet nisl purus in mollis nunc sed id. Eget mi proin sed libero enim sed faucibus. Nisl vel pretium lectus quam id leo in vitae turpis. Libero enim sed faucibus turpis in eu mi bibendum. Amet risus nullam eget felis eget nunc lobortis mattis aliquam. Velit laoreet id donec ultrices tincidunt arcu. Pharetra et ultrices neque ornare aenean euismod elementum. Proin nibh nisl condimentum id venenatis a condimentum vitae. Quam viverra orci sagittis eu. Eu tincidunt tortor aliquam nulla facilisi cras. Vel risus commodo viverra maecenas accumsan lacus vel facilisis. Diam sit amet nisl suscipit.\n\nAt quis risus sed vulputate odio. Aliquet porttitor lacus luctus accumsan tortor posuere ac. Lectus vestibulum mattis ullamcorper velit sed ullamcorper. Quis vel eros donec ac. Sem integer vitae justo eget magna fermentum iaculis eu non. Dictum fusce ut placerat orci. Nibh ipsum consequat nisl vel pretium lectus quam id leo. Pulvinar mattis nunc sed blandit libero volutpat sed. Venenatis lectus magna fringilla urna. Commodo nulla facilisi nullam vehicula ipsum a arcu cursus vitae. Non blandit massa enim nec dui. In egestas erat imperdiet sed euismod nisi. Lacinia at quis risus sed. Mollis aliquam ut porttitor leo a diam sollicitudin tempor id. Diam phasellus vestibulum lorem sed. Euismod quis viverra nibh cras. Dolor morbi non arcu risus quis varius quam. Eget est lorem ipsum dolor sit amet consectetur adipiscing elit."

    })

    self.onDefaultTextAreaTextChanged = function(text)
        self:setState({
            defaultTextAreaText = text
        })
    end
end

function TextAreaEntry:render()
    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 50),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top
        }),

        DefaultTextAreaContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Size = UDim2.new(0.45, 0, 0.6, 0),
        }, {
            DefaultTextArea = e(TextArea, {
                text = self.state.defaultTextAreaText,
                onTextChanged = self.onDefaultTextAreaTextChanged
            })
        }),

        DisabledTextAreaContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.new(0.45, 0, 0.6, 0),
        }, {
            DisabledTextArea = e(TextArea, {
                disabled = true,
                text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Imperdiet massa tincidunt nunc pulvinar sapien et ligula. Amet nisl purus in mollis nunc sed id. Eget mi proin sed libero enim sed faucibus. Nisl vel pretium lectus quam id leo in vitae turpis. Libero enim sed faucibus turpis in eu mi bibendum. Amet risus nullam eget felis eget nunc lobortis mattis aliquam. Velit laoreet id donec ultrices tincidunt arcu. Pharetra et ultrices neque ornare aenean euismod elementum. Proin nibh nisl condimentum id venenatis a condimentum vitae. Quam viverra orci sagittis eu. Eu tincidunt tortor aliquam nulla facilisi cras. Vel risus commodo viverra maecenas accumsan lacus vel facilisis. Diam sit amet nisl suscipit.\n\nAt quis risus sed vulputate odio. Aliquet porttitor lacus luctus accumsan tortor posuere ac. Lectus vestibulum mattis ullamcorper velit sed ullamcorper. Quis vel eros donec ac. Sem integer vitae justo eget magna fermentum iaculis eu non. Dictum fusce ut placerat orci. Nibh ipsum consequat nisl vel pretium lectus quam id leo. Pulvinar mattis nunc sed blandit libero volutpat sed. Venenatis lectus magna fringilla urna. Commodo nulla facilisi nullam vehicula ipsum a arcu cursus vitae. Non blandit massa enim nec dui. In egestas erat imperdiet sed euismod nisi. Lacinia at quis risus sed. Mollis aliquam ut porttitor leo a diam sollicitudin tempor id. Diam phasellus vestibulum lorem sed. Euismod quis viverra nibh cras. Dolor morbi non arcu risus quis varius quam. Eget est lorem ipsum dolor sit amet consectetur adipiscing elit."
            })
        }),
    })
end

return TextAreaEntry