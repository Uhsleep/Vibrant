local Dependencies = require(script.Parent.Parent.Parent.dependencyPaths)
local Roact = require(Dependencies.Roact)

local Dictionary = require(script.Parent.Parent.Parent.utils.Dictionary)
local StudioPluginContext = require(script.Parent.StudioPluginContext)
local StudioToolbarContext = require(script.Parent.StudioToolbarContext)

local e = Roact.createElement
-----------------------------------------------------------------------------
local defaultProps = {
    text = "Button Text",
    backgroundColor = Color3.fromRGB(200, 200, 200),
    textColor = Color3.fromRGB(0, 0, 0),

    onMouseOver = nil,
    onClick = nil
}


local TextButton = Roact.Component:extend("TextButton")

function TextButton:init()
    self.toolbar = self.props.plugin:CreateToolbar(self.props.name)
end

function TextButton:render()
    return e(StudioToolbarContext.Provider, {
        value = self.toolbar
    }, self.props[Roact.Children])
end

-- function TextButton:didMount()
    
-- end

function TextButton:willUnmount()
    self.toolbar:Destroy()
end

return TextButton