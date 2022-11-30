local Root = script.Parent
local Roact = require(Root.dependencies.Roact)
local StudioToolbar = require(Root.dependencies.vibrant.components.studio.StudioToolbar)
local StudioToolbarButton = require(Root.dependencies.vibrant.components.studio.StudioToolbarButton)
local StudioDockWidgetGui = require(Root.dependencies.vibrant.components.studio.StudioDockWidgetGui)

local ButtonEntry = require(script.list_entries.ButtonEntry)
local TextBoxEntry = require(script.list_entries.TextBoxEntry)
local SliderEntry = require(script.list_entries.SliderEntry)
local ComboBoxEntry = require(script.list_entries.ComboBoxEntry)
local NumericStepperEntry = require(script.list_entries.NumericStepperEntry)
local TextAreaEntry = require(script.list_entries.TextAreaEntry)
local CheckBoxEntry = require(script.list_entries.CheckBoxEntry)

local e = Roact.createElement
-----------------------------------------------------------------------------

local App = Roact.Component:extend("App")

function App:init()
    self.contentHeightBinding, self.updateContentHeight = Roact.createBinding(0)

    self.OnButton1Clicked = function()
        self:setState(function(prevState)
            return {
                enabled = not prevState.enabled
            }
        end)
    end

    self:setState({
        enabled = false,
    })
end

function App:render()
    local props = {
        toolbar = {
            name = self.props.pluginName
        },

        button1 = {
            text = "Vibrant Demo",
            active = self.state.enabled,
            tooltipDescription = "Shows a demo of all the plugin UI controls",
            onClick = self.OnButton1Clicked
        }
    }

    return Roact.createFragment({
        ToolBar = e(StudioToolbar, props.toolbar, {
            Button1 = e(StudioToolbarButton, props.button1)
        }),


        StudioDockWidget = e(StudioDockWidgetGui, {
            enabled = self.state.enabled,
            title = "Vibrant Demo",
            initialDockState = Enum.InitialDockState.Float,

            onInitialState = function(enabled)
                self:setState({
                    enabled = enabled
                })
            end,

            onClose = function()
                self:setState({
                    enabled = false
                })
            end
        }, {
            Content = e("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.None,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarImageColor3 = Color3.fromRGB(95, 95, 95),
                ScrollingDirection = Enum.ScrollingDirection.Y,
                Size = UDim2.new(1, 0, 1, 0),
                VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,

                CanvasSize = self.contentHeightBinding:map(function(height)
                    return UDim2.new(0, 0, 0, height)
                end)
            }, {
                ListLayout = e("UIListLayout", {
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0, 5),
                    SortOrder = Enum.SortOrder.LayoutOrder,

                    [Roact.Change.AbsoluteContentSize] = function(listLayout)
                        local height = listLayout.AbsoluteContentSize.Y
                        self.updateContentHeight(height)
                    end
                }),
    
                ButtonListEntry = e("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 100),
                    LayoutOrder = 0
                }, {
                    ButtonsEntry = e(ButtonEntry)
                }),
    
                TextBoxListEntry = e("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 100),
                    LayoutOrder = 1
                }, {
                    TextBoxEntry = e(TextBoxEntry)
                }),
    
                SliderListEntry = e("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 100),
                    LayoutOrder = 2
                }, {
                    SliderEntry = e(SliderEntry)
                }),
    
                ComboBoxEntry = e("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 100),
                    LayoutOrder = 3
                }, {
                    ComboBoxEntry = e(ComboBoxEntry)
                }),
    
                NumericStepperEntry = e("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 100),
                    LayoutOrder = 4
                }, {
                    NumericStepper = e(NumericStepperEntry)
                }),

                TextAreaEntry = e("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 300),
                    LayoutOrder = 4
                }, {
                    TextArea = e(TextAreaEntry)
                }),

                CheckBoxEntry = e("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 100),
                    LayoutOrder = 5
                }, {
                    CheckBox = e(CheckBoxEntry)
                })
            })
        }),
    })
end

return App