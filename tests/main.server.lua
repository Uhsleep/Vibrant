local RunService = game:GetService("RunService")

local App = require(script.Parent.app)
local Plugin = require(script.Parent.dependencies.vibrant.Plugin)

if plugin then
    if not RunService:IsEdit() then
        return
    end

    Plugin:Init(plugin, "Vibrant Demo Plugin", App)
end