local Plugin = script:FindFirstAncestor("vibrant_plugin")

local Roact = require(Plugin.dependencies.Roact)
local Slider = require(Plugin.dependencies.vibrant.components.ui.Slider)

local e = Roact.createElement
-----------------------------------------------------------------------------

local SliderEntry = Roact.Component:extend("SliderEntry")

function SliderEntry:init()
    self:setState({
        defaultSliderValue = 5,
        discreteSliderValue = 5
    })

    self.onDefaultSliderValueChanged = function(value)
        self:setState({
            defaultSliderValue = value
        })
    end

    self.onDiscreteSliderValueChanged = function(value)
        self:setState({
            discreteSliderValue = value
        })
    end
end

function SliderEntry:render()
    return Roact.createFragment({
        Padding = e("UIPadding", {
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15)
        }),

        SlidersContainer = e("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0)
        }, {
            ListLayout = e("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center
            }),
    
            DefaultSliderContainer = e("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = 0,
                Size = UDim2.new(0.3, 0, 0, 45),
            }, {
                DefaultSlider = e(Slider, {
                    min = 0,
                    max = 10000,
                    step = 100,
                    value = self.state.defaultSliderValue,
                    onValueChanged = self.onDefaultSliderValueChanged,
                })
            }),
    
            DiscreteSliderContainer = e("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.new(0.3, 0, 0, 45),
            }, {
                DiscreteSlider = e(Slider, {
                    value = self.state.discreteSliderValue,
                    onValueChanged = self.onDiscreteSliderValueChanged,
                    
                    max = 20,
                    step = 3,
                    showMarks = true
                })
            }),
    
            DisabledSliderContainer = e("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Size = UDim2.new(0.3, 0, 0, 45),
            }, {
                DisabledSlider = e(Slider, {
                    min = 0,
                    max = 10,
                    value = 5,

                    disabled = true
                })
            }),
        }),
    })
end

return SliderEntry