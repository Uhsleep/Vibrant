local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local ComboBox = require(Plugin.dependencies.vibrant.components.ui.ComboBox)

local e = Roact.createElement
-----------------------------------------------------------------------------

local ComboBoxEntry = Roact.Component:extend("ComboBoxEntry")

function ComboBoxEntry:init()
    self.onDefaultComboBoxOptionSelected = function(option, index)
        self:setState({
            defaultComboBoxValue = option
        })
    end

    self.onErrorComboBoxOptionSelected = function(option, index)
        self:setState({
            errorComboBoxValue = option
        })
    end


    self:setState({
        defaultComboBoxValue = "",
        errorComboBoxValue = ""
    })
end

function ComboBoxEntry:render()
    return Roact.createFragment({
        ListLayout = e("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 30),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center
        }),

        DefaultComboBoxContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Size = UDim2.new(0.2, 0, 0, 30),
        }, {
            DefaultComboBox = e(ComboBox, {
                options = {
                    "Apple",
                    "Orange",
                    "Banana",
                    "Blueberry",
                    "Mango"
                },

                selectedOption = self.state.defaultComboBoxValue,
                onOptionSelected = self.onDefaultComboBoxOptionSelected
            })
        }),

        ErrorComboBoxContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 2,
            Size = UDim2.new(0.2, 0, 0, 30),
        }, {
            ErrorComboBox = e(ComboBox, {
                options = {
                    "Volkswagen",
                    "Toyota",
                    "Nissan",
                    "Honda",
                    "BMW",
                    "Hyundai",
                    "Ferrari",
                    "Dodge",
                    "Chevrolet",
                    "Aston Martin",
                    "Cadillac"
                },

                placeHolderText = "Choose a car...",
                selectedOption = self.state.errorComboBoxValue,
                hasError = self.state.errorComboBoxValue == "",
                onOptionSelected = self.onErrorComboBoxOptionSelected
            })
        }),

        DisabledComboBoxContainer = e("Frame", {
            BackgroundTransparency = 1,
            LayoutOrder = 3,
            Size = UDim2.new(0.2, 0, 0, 30),
        }, {
            DisabledComboBox = e(ComboBox, {
                options = {
                    "Volkswagen",
                    "Toyota",
                    "Nissan",
                    "Honda",
                    "BMW",
                    "Hyundai",
                    "Ferrari",
                    "Dodge",
                    "Chevrolet",
                    "Aston Martin",
                    "Cadillac"
                },

                disabled = true,
                placeHolderText = "Disabled combo box..."
            })
        }),
    })
end

return ComboBoxEntry