local Root = script.Parent.Parent
local Roact = require(Root.dependencies.Roact)
local StudioPluginContext = require(Root.dependencies.vibrant.components.plugin.StudioPluginContext)
local StudioToolbar = require(Root.dependencies.vibrant.components.plugin.StudioToolbar)
local StudioToolbarButton = require(Root.dependencies.vibrant.components.plugin.StudioToolbarButton)
local StudioDockWidgetGui = require(Root.dependencies.vibrant.components.plugin.StudioDockWidgetGui)

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

            onInitialState = function(enabled)
                print("Got initial state:", enabled)
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
            SomeText = e("TextLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                TextScaled = true,
                Text = "Hello Plugin"
            })
        }),
    })
end

return App