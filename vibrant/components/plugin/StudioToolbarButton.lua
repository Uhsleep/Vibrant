local Assets = require(script.Parent.Parent.Parent.Assets)
local Dependencies = require(script.Parent.Parent.Parent.DependencyPaths)
local Roact = require(Dependencies.Roact)

local Dictionary = require(script.Parent.Parent.Parent.utils.Dictionary)
local StudioToolbarContext = require(script.Parent.StudioToolbarContext)

local e = Roact.createElement
-----------------------------------------------------------------------------

local defaultProps = {
    text = "Toolbar button",
    tooltipDescription = "A toolbar button used to enable/disable plugin widgets",
    icon = Assets.ToolbarButtonDefaultIcon,
    active = false
}

local function ensurePropValues(componentProps, defaultProps)
    for key, value in pairs(defaultProps) do
        componentProps[key] = componentProps[key] or value
    end
end

local StudioToolbarButton = Roact.Component:extend("StudioToolbarButton")

function StudioToolbarButton:init()
    ensurePropValues(self.props, defaultProps)

    self.button = self.props.toolbar:CreateButton(self.props.text .. "Button", self.props.tooltipDescription, self.props.icon, self.props.text)
    self.button:SetActive(self.props.active)
    self.button.ClickableWhenViewportHidden = false

    if self.props.onClick then
        self.button.Click:Connect(self.props.onClick)
    end
end

function StudioToolbarButton:render()
    return nil
end

function StudioToolbarButton:didMount()

end

function StudioToolbarButton:didUpdate(lastProps)
    if self.props.active ~= lastProps.active then
        self.button:SetActive(self.props.active)
    end
end

function StudioToolbarButton:willUnmount()
    self.button:Destroy()
end

function StudioToolbarButtonWrapper(props)
    return e(StudioToolbarContext.Consumer, {
        render = function(toolbar)
            return e(StudioToolbarButton, Dictionary.merge(props, {
                toolbar = toolbar
            }))
        end
    })
end

return StudioToolbarButtonWrapper