local RunService = game:GetService("RunService")

local Plugin = require(script.Parent.plugin)

if plugin then
    if not RunService:IsEdit() then
        return
    end

    plugin.Unloading:Connect(function()
        Plugin:OnUnloading(plugin)
    end)

    plugin.Deactivation:Connect(function()
       Plugin:OnDeactivation(plugin)
    end)

    Plugin:Init(plugin)
end