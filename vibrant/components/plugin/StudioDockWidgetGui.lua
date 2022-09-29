local Dependencies = require(script.Parent.Parent.Parent.dependencyPaths)
local Roact = require(Dependencies.Roact)
local e = Roact.createElement

local Dictionary = require(script.Parent.Parent.Parent.utils.Dictionary)
local StudioPluginContext = require(script.Parent.StudioPluginContext)

-----------------------------------------------------------------------------

local defaultProps = {
    title = "Dock Widget Gui",
    enabled = false
}

local function ensurePropValues(componentProps, defaultProps)
    for key, value in pairs(defaultProps) do
        componentProps[key] = componentProps[key] or value
    end
end

local StudioDockWidgetGui = Roact.Component:extend("StudioDockWidgetGui")

function StudioDockWidgetGui:init()
    ensurePropValues(self.props, defaultProps)

    local widgetInfo = DockWidgetPluginGuiInfo.new(
        Enum.InitialDockState.Left,
        true,
        false,
        200,
        300,
        150,
        150
    )

    self.dockWidget = self.props.plugin:CreateDockWidgetPluginGui(self.props.title .. "DockWidgetGui", widgetInfo)
    self.dockWidget.Title = self.props.title

    if self.props.onInitialState then
        self.props.onInitialState(self.dockWidget.Enabled)
    end

    self.dockWidget:BindToClose(function()
        if self.props.onClose then
            self.props.onClose()
        else
            self.dockWidget.Enabled = false
        end
    end)
end

function StudioDockWidgetGui:render()
    return e(Roact.Portal, {
        target = self.dockWidget
    }, self.props[Roact.Children])
end

-- function StudioDockWidgetGui:didMount()
    
-- end

function StudioDockWidgetGui:didUpdate(lastProps)
    if self.props.enabled ~= lastProps.enabled then
        self.dockWidget.Enabled = self.props.enabled
    end
end

function StudioDockWidgetGui:willUnmount()
    self.dockWidget:Destroy()
end

function StudioDockWidgetGuiWrapper(props)
    return e(StudioPluginContext.Consumer, {
        render = function(pluginModule)
            return e(StudioDockWidgetGui, Dictionary.merge(props, {
                plugin = pluginModule.plugin
            }))
        end
    })
end

return StudioDockWidgetGuiWrapper