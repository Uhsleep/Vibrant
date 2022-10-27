local Root = script.Parent.Parent
local Roact = require(Root.dependencies.Roact)
local StudioPluginContext = require(Root.dependencies.vibrant.components.plugin.StudioPluginContext)
local StudioToolbar = require(Root.dependencies.vibrant.components.plugin.StudioToolbar)
local StudioToolbarButton = require(Root.dependencies.vibrant.components.plugin.StudioToolbarButton)
local StudioDockWidgetGui = require(Root.dependencies.vibrant.components.plugin.StudioDockWidgetGui)

local ButtonsEntry = require(script.list_entries.ButtonsEntry)
local TextBoxEntry = require(script.list_entries.TextBoxEntry)

local e = Roact.createElement
-----------------------------------------------------------------------------

local App = Roact.Component:extend("App")

function App:init()
    self:setState({
        enabled = false,
    })

    self.OnButton1Clicked = function()
        self:setState(function(prevState)
            return {
                enabled = not prevState.enabled
            }
        end)
    end
end

function App:render()
    local props = {
        pluginContext = {
            value = self.props.pluginModule
        },

        toolbar = {
            name = self.props.pluginModule.name
        },

        button1 = {
            text = "Vibrant Demo",
            active = self.state.enabled,
            tooltipDescription = "Shows a demo of all the plugin UI controls",
            onClick = self.OnButton1Clicked
        }
    }

    return e(StudioPluginContext.Provider, props.pluginContext, {
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
            ListLayout = e("UIListLayout", {
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 5)
            }),

            ButtonListEntry = e("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 100)
            }, {
                ButtonsEntry = e(ButtonsEntry)
            }),

            TextBoxListEntry = e("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 100),
            }, {
                TextBoxEntry = e(TextBoxEntry)
            })
        }),
    })
end

return App