local Dependencies = require(script.Parent.Parent.Parent.dependencyPaths)
local Roact = require(Dependencies.Roact)

local Dictionary = require(script.Parent.Parent.Parent.utils.Dictionary)
local StudioPluginContext = require(script.Parent.StudioPluginContext)
local StudioToolbarContext = require(script.Parent.StudioToolbarContext)

local e = Roact.createElement
-----------------------------------------------------------------------------

local StudioToolbar = Roact.Component:extend("StudioToolbar")

function StudioToolbar:init()
    self.toolbar = self.props.plugin:CreateToolbar(self.props.name)
end

function StudioToolbar:render()
    return e(StudioToolbarContext.Provider, {
        value = self.toolbar
    }, self.props[Roact.Children])
end

-- function StudioToolbar:didMount()
    
-- end

function StudioToolbar:willUnmount()
    self.toolbar:Destroy()
end

function StudioToolbarWrapper(props)
    return e(StudioPluginContext.Consumer, {
        render = function(pluginModule)
            return e(StudioToolbar, Dictionary.merge(props, {
                plugin = pluginModule.plugin
            }))
        end
    })
end

return StudioToolbarWrapper