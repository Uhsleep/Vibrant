local Vibrant = script:FindFirstAncestor("vibrant")
local Dependencies = require(Vibrant.DependencyPaths)
local Roact = require(Dependencies.Roact)

local StudioPluginContext = require(Vibrant.components.studio.StudioPluginContext)

------------------------------------------------------------------------------------

local Plugin = {}

function Plugin:Init(plugin, pluginName, app)
    plugin.Unloading:Connect(function()
        self:OnUnloading(plugin)
    end)

    plugin.Deactivation:Connect(function()
       self:OnDeactivation(plugin)
    end)

    local element = Roact.createElement(StudioPluginContext.Provider, { value = plugin }, {
        App = Roact.createElement(app, {
            pluginName = pluginName
        })
    })

    self.roactTree = Roact.mount(element, nil, self.name)
end

function Plugin:OnUnloading(plugin)
    if self.roactTree then
        Roact.unmount(self.roactTree)
    end
end

function Plugin:OnDeactivation(plugin)
   
end

return Plugin