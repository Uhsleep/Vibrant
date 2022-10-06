local Roact = require(script.Parent.dependencies.Roact)
local App = require(script.app)

------------------------------------------------------------------------------------

local Plugin = {
    name = "Vibrant Demo Plugin",
    plugin = nil
}

function Plugin:Init(plugin)
    self.plugin = plugin

    local app = Roact.createElement(App, {
        pluginModule = self
    })

    self.roactTree = Roact.mount(app, nil, self.name)
end

function Plugin:OnUnloading(plugin)
    Roact.unmount(self.roactTree)
end

function Plugin:OnDeactivation(plugin)
   
end

return Plugin